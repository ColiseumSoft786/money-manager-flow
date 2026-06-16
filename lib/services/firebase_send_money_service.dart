import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flow/data/firebase_friend.dart";
import "package:flow/data/firebase_transfer.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/entity/account.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/Firebase_auth_service.dart";
import "package:flow/services/firebase_friends_service.dart";
import "package:flow/services/user_preferences.dart";
import "package:logging/logging.dart";
import "package:uuid/uuid.dart";

final Logger _log = Logger("FirebaseSendMoneyService");

class FirebaseSendMoneyService {
  static FirebaseSendMoneyService? _instance;

  factory FirebaseSendMoneyService() =>
      _instance ??= FirebaseSendMoneyService._();

  FirebaseSendMoneyService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuthService().currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _incomingRef(String userId) =>
      _db.collection("users").doc(userId).collection("incomingTransfers");

  CollectionReference<Map<String, dynamic>> _outgoingRef(String userId) =>
      _db.collection("users").doc(userId).collection("outgoingTransfers");

  /// Send money to any discoverable user — no friend request required.
  Future<String> sendMoney({
    required FirebaseUserProfile recipient,
    required double amount,
    required String fromAccountUuid,
    required String transactionTitle,
    String? note,
  }) async {
    final String? uid = _uid;
    if (uid == null) throw StateError("Not signed in");
    if (recipient.userId == uid) {
      throw SendMoneyException("cannotSendToSelf");
    }
    if (amount <= 0) {
      throw SendMoneyException("invalidAmount");
    }

    final Account? account = AccountsService().findOneActiveSync(
      fromAccountUuid,
    );
    if (account == null) {
      throw SendMoneyException("accountNotFound");
    }
    if (!canSendFromAccount(account, amount)) {
      throw SendMoneyException("insufficientFunds");
    }

    final FirebaseUserProfile? me =
        await FirebaseFriendsService().getMyProfile();
    if (me == null) {
      throw SendMoneyException("profileMissing");
    }

    final String transferId = const Uuid().v4();
    final String currency = account.currency;
    final String localTxUuid = const Uuid().v4();

    final Map<String, Object?> payload = {
      "fromUserId": uid,
      "toUserId": recipient.userId,
      "amount": amount,
      "currency": currency,
      "note": note?.trim() ?? "",
      "fromDisplayName": me.displayName,
      "fromHandle": me.handle,
      "toDisplayName": recipient.displayName,
      "toHandle": recipient.handle,
      "status": "sent",
      "bookedLocally": false,
      "senderLocalTransactionUuid": localTxUuid,
      "createdAt": FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    batch.set(_incomingRef(recipient.userId).doc(transferId), payload);
    batch.set(_outgoingRef(uid).doc(transferId), payload);
    await batch.commit();

    account.createAndSaveTransaction(
      amount: -amount.abs(),
      title: transactionTitle,
      description: note?.trim().isNotEmpty == true ? note!.trim() : null,
      uuidOverride: localTxUuid,
      extraTags: ["peer_transfer", "peer_transfer_out"],
    );

    return transferId;
  }

  Stream<List<PeerTransfer>> watchOutgoing() {
    final String? uid = _uid;
    if (uid == null) return Stream.value(const []);

    return _outgoingRef(uid).limit(50).snapshots().map((snap) {
      final list = snap.docs.map(PeerTransfer.fromDoc).toList();
      list.removeWhere((t) => t.status == "cancelled_local");
      list.sort(
        (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
          a.createdAt ?? DateTime(0),
        ),
      );
      return list;
    });
  }

  String messageFor(SendMoneyException e) {
    switch (e.code) {
      case "cannotSendToSelf":
        return "Cannot send money to yourself.";
      case "invalidAmount":
        return "Enter an amount greater than zero.";
      case "accountNotFound":
        return "Choose a valid account.";
      case "profileMissing":
        return "Your online profile is missing. Sign out and sign in again.";
      case "insufficientFunds":
        return "sendMoney.error.insufficientFunds".tr();
      default:
        return e.code;
    }
  }

  /// Spendable funds on [account] (balance, or credit limit + balance for cards).
  static double availableForSpending(Account account) {
    final double balance = account.balance.amount;
    if (account.accountType == AccountType.creditLine) {
      return balance + (account.creditLimit ?? 0);
    }
    return balance;
  }

  static bool canSendFromAccount(Account account, double amount) {
    if (amount <= 0) return false;
    return availableForSpending(account) >= amount;
  }

  /// When the user removes the local expense, mark the Firestore outgoing row.
  Future<void> markOutgoingCancelledByLocalTransactionUuid(
    String localTransactionUuid,
  ) async {
    final String? uid = _uid;
    if (uid == null || localTransactionUuid.isEmpty) return;

    try {
      final snap = await _outgoingRef(uid)
          .where("senderLocalTransactionUuid", isEqualTo: localTransactionUuid)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return;
      await snap.docs.first.reference.update({
        "status": "cancelled_local",
        "cancelledAt": FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      _log.warning(
        "Failed to mark outgoing transfer cancelled for $localTransactionUuid",
        e,
        st,
      );
    }
  }
}

/// Listens for incoming peer transfers and books income on this device.
class FirebaseIncomingTransfersListener {
  static FirebaseIncomingTransfersListener? _instance;

  factory FirebaseIncomingTransfersListener() =>
      _instance ??= FirebaseIncomingTransfersListener._();

  FirebaseIncomingTransfersListener._();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void restart() {
    stop();
    final String? uid = FirebaseAuthService().currentUser?.uid;
    if (uid == null) return;

    _subscription = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("incomingTransfers")
        .where("bookedLocally", isEqualTo: false)
        .snapshots()
        .listen(
          (snap) => _onIncoming(uid, snap),
          onError: (Object e, StackTrace st) {
            _log.warning("Incoming transfers listener failed", e, st);
          },
        );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _onIncoming(
    String myUid,
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    for (final doc in snap.docs) {
      final PeerTransfer transfer = PeerTransfer.fromDoc(doc);
      if (transfer.bookedLocally || transfer.toUserId != myUid) continue;
      await _bookIncoming(myUid, transfer);
    }
  }

  Future<void> _bookIncoming(String myUid, PeerTransfer transfer) async {
    try {
      final String localUuid = const Uuid().v4();
      final String currency = transfer.currency.isNotEmpty
          ? transfer.currency
          : UserPreferencesService().primaryCurrency;

      Account? account = AccountsService().findOneActiveSync(
        UserPreferencesService().primaryAccountUuid,
      );
      account ??= (await AccountsService().getAll())
          .where((a) => !a.archived && a.currency == currency)
          .firstOrNull;
      account ??= (await AccountsService().getAll())
          .where((a) => !a.archived)
          .firstOrNull;

      if (account == null) {
        _log.warning("No account to book incoming transfer ${transfer.id}");
        return;
      }

      final String senderLabel = transfer.fromDisplayName.isNotEmpty
          ? transfer.fromDisplayName
          : "@${transfer.fromHandle}";

      account.createAndSaveTransaction(
        amount: transfer.amount.abs(),
        title: "sendMoney.receivedTitle".tr({"name": senderLabel}),
        description: transfer.note?.isNotEmpty == true ? transfer.note : null,
        uuidOverride: localUuid,
        extraTags: ["peer_transfer", "peer_transfer_in"],
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(myUid)
          .collection("incomingTransfers")
          .doc(transfer.id)
          .update({
            "bookedLocally": true,
            "localTransactionUuid": localUuid,
            "status": "received",
            "receivedAt": FieldValue.serverTimestamp(),
          });
    } catch (e, st) {
      _log.warning(
        "Failed to book incoming transfer ${transfer.id}",
        e,
        st,
      );
    }
  }
}

class SendMoneyException implements Exception {
  SendMoneyException(this.code);

  final String code;

  @override
  String toString() => "SendMoneyException($code)";
}
