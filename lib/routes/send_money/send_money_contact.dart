import "package:flow/data/firebase_friend.dart";
import "package:flow/data/firebase_transfer.dart";

/// Someone the user has sent money to before (from outgoing transfers).
class SendMoneyContact {
  const SendMoneyContact({
    required this.userId,
    required this.displayName,
    required this.handle,
  });

  final String userId;
  final String displayName;
  final String handle;

  String get handleLabel => handle.startsWith("@") ? handle : "@$handle";

  String get displayLabel =>
      displayName.isNotEmpty ? displayName : handleLabel;

  String get shortName {
    final String base = displayName.isNotEmpty
        ? displayName.split(RegExp(r"\s+")).first
        : handle.replaceAll("@", "");
    return base.isEmpty ? "?" : base.toUpperCase();
  }

  String get initials {
    if (displayName.isNotEmpty) {
      final parts = displayName.trim().split(RegExp(r"\s+"));
      if (parts.length >= 2) {
        return "${parts.first[0]}${parts[1][0]}".toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    final h = handle.replaceAll("@", "");
    return h.length >= 2
        ? h.substring(0, 2).toUpperCase()
        : (h.isNotEmpty ? h[0].toUpperCase() : "?");
  }

  FirebaseUserProfile toProfile() => FirebaseUserProfile(
    userId: userId,
    displayName: displayName,
    handle: handle,
  );

  static List<SendMoneyContact> fromTransfers(List<PeerTransfer> transfers) {
    final List<SendMoneyContact> result = [];
    final Set<String> seen = {};
    for (final PeerTransfer t in transfers) {
      if (t.toUserId.isEmpty || !seen.add(t.toUserId)) continue;
      result.add(
        SendMoneyContact(
          userId: t.toUserId,
          displayName: t.toDisplayName,
          handle: t.toHandle,
        ),
      );
    }
    return result;
  }
}
