import "package:cloud_firestore/cloud_firestore.dart";
import "package:flow/data/firebase_friend.dart";
import "package:flow/services/Firebase_auth_service.dart";

class FirebaseFriendsService {
  static FirebaseFriendsService? _instance;

  factory FirebaseFriendsService() =>
      _instance ??= FirebaseFriendsService._();

  FirebaseFriendsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuthService().currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      _db.collection("users").doc(userId);

  CollectionReference<Map<String, dynamic>> _friendsRef(String userId) =>
      _userRef(userId).collection("friends");

  CollectionReference<Map<String, dynamic>> _incomingRef(String userId) =>
      _userRef(userId).collection("incomingFriendRequests");

  CollectionReference<Map<String, dynamic>> _outgoingRef(String userId) =>
      _userRef(userId).collection("outgoingFriendRequests");

  Map<String, Object?> _requestPayload({
    required String fromUserId,
    required String toUserId,
    required String fromDisplayName,
    required String fromHandle,
    required String toDisplayName,
    required String toHandle,
    String status = "pending",
  }) {
    return {
      "fromUserId": fromUserId,
      "toUserId": toUserId,
      "status": status,
      "fromDisplayName": fromDisplayName,
      "fromHandle": fromHandle,
      "toDisplayName": toDisplayName,
      "toHandle": toHandle,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  /// Exact match on @handle or email (discoverable users only).
  Future<FirebaseUserProfile?> findUser(String query) async {
    final String? uid = _uid;
    if (uid == null) return null;

    final String trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.contains("@") && trimmed.contains(".")) {
      final snap = await _db
          .collection("users")
          .where("email", isEqualTo: trimmed.toLowerCase())
          .where("discoverable", isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final profile = FirebaseUserProfile.fromDoc(snap.docs.first);
      if (profile.userId == uid) return null;
      return profile;
    }

    final String handleLower = normalizeFriendHandle(trimmed);
    final snap = await _db
        .collection("users")
        .where("handleLower", isEqualTo: handleLower)
        .where("discoverable", isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final profile = FirebaseUserProfile.fromDoc(snap.docs.first);
    if (profile.userId == uid) return null;
    return profile;
  }

  Stream<List<FirebaseFriend>> watchFriends() {
    final String? uid = _uid;
    if (uid == null) return Stream.value(const []);

    return _friendsRef(uid).snapshots().map((snap) {
      final list = snap.docs.map(FirebaseFriend.fromDoc).toList();
      list.sort(
        (a, b) => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ),
      );
      return list;
    });
  }

  Stream<List<FriendRequest>> watchIncomingPending() {
    final String? uid = _uid;
    if (uid == null) return Stream.value(const []);

    return _incomingRef(uid)
        .where("status", isEqualTo: "pending")
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map(FriendRequest.fromIncomingDoc)
              .toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Stream<List<FriendRequest>> watchOutgoingPending() {
    final String? uid = _uid;
    if (uid == null) return Stream.value(const []);

    return _outgoingRef(uid)
        .where("status", isEqualTo: "pending")
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map(FriendRequest.fromOutgoingDoc)
              .toList();
          list.sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
          return list;
        });
  }

  Future<FirebaseUserProfile?> getMyProfile() async {
    final String? uid = _uid;
    if (uid == null) return null;
    final snap = await _userRef(uid).get();
    if (!snap.exists) return null;
    return FirebaseUserProfile.fromDoc(snap);
  }

  Future<bool> areFriends(String otherUserId) async {
    final String? uid = _uid;
    if (uid == null) return false;
    final snap = await _friendsRef(uid).doc(otherUserId).get();
    return snap.exists;
  }

  Future<FriendRequest?> getPendingRequestBetween(String otherUserId) async {
    final String? uid = _uid;
    if (uid == null) return null;

    final DocumentSnapshot<Map<String, dynamic>> incoming = await _incomingRef(
      uid,
    ).doc(otherUserId).get();
    if (incoming.exists) {
      final FriendRequest req = FriendRequest.fromIncomingDoc(incoming);
      if (req.status == FriendRequestStatus.pending) return req;
    }

    final DocumentSnapshot<Map<String, dynamic>> outgoing = await _outgoingRef(
      uid,
    ).doc(otherUserId).get();
    if (outgoing.exists) {
      final FriendRequest req = FriendRequest.fromOutgoingDoc(outgoing);
      if (req.status == FriendRequestStatus.pending) return req;
    }

    return null;
  }

  Future<void> sendFriendRequest(FirebaseUserProfile target) async {
    final String? uid = _uid;
    if (uid == null) throw StateError("Not signed in");
    if (target.userId == uid) {
      throw FirebaseFriendsException("cannotAddSelf");
    }

    if (await areFriends(target.userId)) {
      throw FirebaseFriendsException("alreadyFriends");
    }

    final FriendRequest? existing = await getPendingRequestBetween(
      target.userId,
    );
    if (existing != null) {
      if (existing.isOutgoing(uid)) {
        throw FirebaseFriendsException("requestAlreadySent");
      }
      throw FirebaseFriendsException("theyAlreadyRequested");
    }

    final FirebaseUserProfile? myProfile = await getMyProfile();
    if (myProfile == null) {
      throw FirebaseFriendsException("profileMissing");
    }

    final Map<String, Object?> payload = _requestPayload(
      fromUserId: uid,
      toUserId: target.userId,
      fromDisplayName: myProfile.displayName,
      fromHandle: myProfile.handle,
      toDisplayName: target.displayName,
      toHandle: target.handle,
    );

    final batch = _db.batch();
    batch.set(_incomingRef(target.userId).doc(uid), payload);
    batch.set(_outgoingRef(uid).doc(target.userId), payload);
    await batch.commit();
  }

  Future<void> acceptRequest(FriendRequest request) async {
    final String? uid = _uid;
    if (uid == null) throw StateError("Not signed in");
    if (request.toUserId != uid) {
      throw StateError("Only the recipient can accept");
    }

    final FirebaseUserProfile? myProfile = await getMyProfile();
    if (myProfile == null) {
      throw FirebaseFriendsException("profileMissing");
    }

    final batch = _db.batch();
    final Map<String, Object?> accepted = {
      "status": "accepted",
      "respondedAt": FieldValue.serverTimestamp(),
    };

    batch.update(_incomingRef(uid).doc(request.fromUserId), accepted);
    batch.update(_outgoingRef(request.fromUserId).doc(uid), accepted);

    final Map<String, Object?> friendPayload = {
      "displayName": "",
      "handle": "",
      "addedAt": FieldValue.serverTimestamp(),
    };

    batch.set(_friendsRef(uid).doc(request.fromUserId), {
      ...friendPayload,
      "displayName": request.fromDisplayName,
      "handle": request.fromHandle,
    });
    batch.set(_friendsRef(request.fromUserId).doc(uid), {
      ...friendPayload,
      "displayName": myProfile.displayName,
      "handle": myProfile.handle,
    });

    await batch.commit();
  }

  Future<void> declineRequest(FriendRequest request) async {
    final String? uid = _uid;
    if (uid == null) throw StateError("Not signed in");
    if (request.toUserId != uid) {
      throw StateError("Only the recipient can decline");
    }

    final batch = _db.batch();
    final Map<String, Object?> patch = {
      "status": "declined",
      "respondedAt": FieldValue.serverTimestamp(),
    };
    batch.update(_incomingRef(uid).doc(request.fromUserId), patch);
    batch.update(_outgoingRef(request.fromUserId).doc(uid), patch);
    await batch.commit();
  }

  Future<void> cancelOutgoingRequest(FriendRequest request) async {
    final String? uid = _uid;
    if (uid == null) throw StateError("Not signed in");
    if (request.fromUserId != uid) {
      throw StateError("Only the sender can cancel");
    }

    final batch = _db.batch();
    final Map<String, Object?> patch = {
      "status": "cancelled",
      "respondedAt": FieldValue.serverTimestamp(),
    };
    batch.update(_outgoingRef(uid).doc(request.toUserId), patch);
    batch.update(_incomingRef(request.toUserId).doc(uid), patch);
    await batch.commit();
  }

  Future<void> removeFriend(FirebaseFriend friend) async {
    final String? uid = _uid;
    if (uid == null) throw StateError("Not signed in");

    final batch = _db.batch();
    batch.delete(_friendsRef(uid).doc(friend.userId));
    batch.delete(_friendsRef(friend.userId).doc(uid));
    await batch.commit();
  }

  String messageFor(FirebaseFriendsException code) {
    switch (code.code) {
      case "cannotAddSelf":
        return "You cannot add yourself.";
      case "alreadyFriends":
        return "You are already friends.";
      case "requestAlreadySent":
        return "Friend request already sent.";
      case "theyAlreadyRequested":
        return "They already sent you a request — check Requests.";
      case "profileMissing":
        return "Your profile is not ready. Sign out and sign in again.";
      case "notFound":
        return "No user found with that handle or email.";
      default:
        return code.code;
    }
  }
}

class FirebaseFriendsException implements Exception {
  FirebaseFriendsException(this.code);

  final String code;

  @override
  String toString() => "FirebaseFriendsException($code)";
}
