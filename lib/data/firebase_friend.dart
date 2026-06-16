import "package:cloud_firestore/cloud_firestore.dart";

/// Public Firestore user profile (discoverable users).
class FirebaseUserProfile {
  const FirebaseUserProfile({
    required this.userId,
    required this.displayName,
    required this.handle,
    this.email,
    this.discoverable = true,
  });

  final String userId;
  final String displayName;
  final String handle;
  final String? email;
  final bool discoverable;

  String get handleLabel => handle.startsWith("@") ? handle : "@$handle";

  factory FirebaseUserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FirebaseUserProfile(
      userId: doc.id,
      displayName: (data["displayName"] as String?)?.trim() ?? "",
      handle: (data["handle"] as String?)?.trim() ?? doc.id,
      email: data["email"] as String?,
      discoverable: data["discoverable"] as bool? ?? true,
    );
  }
}

enum FriendRequestStatus { pending, accepted, declined, cancelled }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.fromDisplayName,
    required this.fromHandle,
    required this.toDisplayName,
    required this.toHandle,
    this.createdAt,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final FriendRequestStatus status;
  final String fromDisplayName;
  final String fromHandle;
  final String toDisplayName;
  final String toHandle;
  final DateTime? createdAt;

  bool isIncoming(String currentUserId) => toUserId == currentUserId;

  bool isOutgoing(String currentUserId) => fromUserId == currentUserId;

  factory FriendRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final String fromUserId = data["fromUserId"] as String? ?? "";
    final String toUserId = data["toUserId"] as String? ?? "";
    return FriendRequest(
      id: "${fromUserId}_$toUserId",
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: _statusFromString(data["status"] as String?),
      fromDisplayName: data["fromDisplayName"] as String? ?? "",
      fromHandle: data["fromHandle"] as String? ?? "",
      toDisplayName: data["toDisplayName"] as String? ?? "",
      toHandle: data["toHandle"] as String? ?? "",
      createdAt: (data["createdAt"] as Timestamp?)?.toDate(),
    );
  }

  /// `users/{toUserId}/incomingFriendRequests/{fromUserId}`
  factory FriendRequest.fromIncomingDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final String fromUserId = data["fromUserId"] as String? ?? doc.id;
    final String toUserId = data["toUserId"] as String? ?? "";
    return FriendRequest(
      id: "${fromUserId}_$toUserId",
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: _statusFromString(data["status"] as String?),
      fromDisplayName: data["fromDisplayName"] as String? ?? "",
      fromHandle: data["fromHandle"] as String? ?? "",
      toDisplayName: data["toDisplayName"] as String? ?? "",
      toHandle: data["toHandle"] as String? ?? "",
      createdAt: (data["createdAt"] as Timestamp?)?.toDate(),
    );
  }

  /// `users/{fromUserId}/outgoingFriendRequests/{toUserId}`
  factory FriendRequest.fromOutgoingDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final String fromUserId = data["fromUserId"] as String? ?? "";
    final String toUserId = data["toUserId"] as String? ?? doc.id;
    return FriendRequest(
      id: "${fromUserId}_$toUserId",
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: _statusFromString(data["status"] as String?),
      fromDisplayName: data["fromDisplayName"] as String? ?? "",
      fromHandle: data["fromHandle"] as String? ?? "",
      toDisplayName: data["toDisplayName"] as String? ?? "",
      toHandle: data["toHandle"] as String? ?? "",
      createdAt: (data["createdAt"] as Timestamp?)?.toDate(),
    );
  }

  static FriendRequestStatus _statusFromString(String? raw) {
    switch (raw) {
      case "accepted":
        return FriendRequestStatus.accepted;
      case "declined":
        return FriendRequestStatus.declined;
      case "cancelled":
        return FriendRequestStatus.cancelled;
      default:
        return FriendRequestStatus.pending;
    }
  }
}

class FirebaseFriend {
  const FirebaseFriend({
    required this.userId,
    required this.displayName,
    required this.handle,
    this.addedAt,
  });

  final String userId;
  final String displayName;
  final String handle;
  final DateTime? addedAt;

  String get handleLabel => handle.startsWith("@") ? handle : "@$handle";

  factory FirebaseFriend.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FirebaseFriend(
      userId: doc.id,
      displayName: data["displayName"] as String? ?? "",
      handle: data["handle"] as String? ?? doc.id,
      addedAt: (data["addedAt"] as Timestamp?)?.toDate(),
    );
  }
}

String normalizeFriendHandle(String raw) {
  return raw.trim().toLowerCase().replaceAll(RegExp(r"^@+"), "");
}
