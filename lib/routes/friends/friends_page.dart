import "package:flow/data/firebase_friend.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/firebase_friends_service.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFriendsService service = FirebaseFriendsService();

    return Scaffold(
      appBar: AppBar(
        title: Text("friends.title".t(context)),
        actions: [
          IconButton(
            tooltip: "friends.find".t(context),
            onPressed: () => context.push("/friends/find"),
            icon: const Icon(Symbols.person_add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<FirebaseUserProfile?>(
          future: service.getMyProfile(),
          builder: (context, profileSnap) {
            final FirebaseUserProfile? me = profileSnap.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (me != null) _MyHandleBanner(profile: me),
                Expanded(
                  child: StreamBuilder<List<FirebaseFriend>>(
                    stream: service.watchFriends(),
                    builder: (context, friendsSnap) {
                      if (!friendsSnap.hasData) {
                        return const Spinner.center();
                      }
                      final friends = friendsSnap.data!;

                      return StreamBuilder<List<FriendRequest>>(
                        stream: service.watchIncomingPending(),
                        builder: (context, incomingSnap) {
                          if (!incomingSnap.hasData) {
                            return const Spinner.center();
                          }
                          final incoming = incomingSnap.data!;

                          return StreamBuilder<List<FriendRequest>>(
                            stream: service.watchOutgoingPending(),
                            builder: (context, outgoingSnap) {
                              if (!outgoingSnap.hasData) {
                                return const Spinner.center();
                              }
                              final outgoing = outgoingSnap.data!;

                              if (friends.isEmpty &&
                                  incoming.isEmpty &&
                                  outgoing.isEmpty) {
                                return _EmptyFriends(
                                  onFind: () => context.push("/friends/find"),
                                );
                              }

                              return ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  8.0,
                                  16.0,
                                  24.0,
                                ),
                                children: [
                                  if (incoming.isNotEmpty) ...[
                                    _SectionTitle(
                                      label: "friends.incomingRequests".t(
                                        context,
                                      ),
                                    ),
                                    ...incoming.map(
                                      (req) => _IncomingRequestTile(
                                        request: req,
                                        onAccept: () => _accept(
                                          context,
                                          req,
                                        ),
                                        onDecline: () => _decline(
                                          context,
                                          req,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                  ],
                                  if (outgoing.isNotEmpty) ...[
                                    _SectionTitle(
                                      label: "friends.outgoingRequests".t(
                                        context,
                                      ),
                                    ),
                                    ...outgoing.map(
                                      (req) => _OutgoingRequestTile(
                                        request: req,
                                        onCancel: () => _cancel(
                                          context,
                                          req,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                  ],
                                  if (friends.isNotEmpty) ...[
                                    _SectionTitle(
                                      label: "friends.myFriends".t(context),
                                    ),
                                    ...friends.map(
                                      (friend) => _FriendTile(
                                        friend: friend,
                                        onRemove: () => _remove(
                                          context,
                                          friend,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push("/friends/find"),
        icon: const Icon(Symbols.person_search_rounded),
        label: Text("friends.find".t(context)),
      ),
    );
  }

  Future<void> _accept(BuildContext context, FriendRequest req) async {
    try {
      await FirebaseFriendsService().acceptRequest(req);
      if (!context.mounted) return;
      _snack(context, "friends.accepted".t(context));
    } catch (e) {
      _snack(context, e.toString());
    }
  }

  Future<void> _decline(BuildContext context, FriendRequest req) async {
    try {
      await FirebaseFriendsService().declineRequest(req);
    } catch (e) {
      _snack(context, e.toString());
    }
  }

  Future<void> _cancel(BuildContext context, FriendRequest req) async {
    try {
      await FirebaseFriendsService().cancelOutgoingRequest(req);
    } catch (e) {
      _snack(context, e.toString());
    }
  }

  Future<void> _remove(BuildContext context, FirebaseFriend friend) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("friends.remove.title".t(context)),
        content: Text(
          "friends.remove.message".t(context, {
            "name": friend.displayName.isNotEmpty
                ? friend.displayName
                : friend.handleLabel,
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("general.cancel".t(context)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("friends.remove.confirm".t(context)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await FirebaseFriendsService().removeFriend(friend);
    } catch (e) {
      _snack(context, e.toString());
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _MyHandleBanner extends StatelessWidget {
  const _MyHandleBanner({required this.profile});

  final FirebaseUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: Material(
        color: scheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Symbols.alternate_email_rounded, color: scheme.primary),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "friends.yourHandle".t(context),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      profile.handleLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend, required this.onRemove});

  final FirebaseFriend friend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String title = friend.displayName.isNotEmpty
        ? friend.displayName
        : friend.handleLabel;
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            title.isNotEmpty ? title[0].toUpperCase() : "?",
          ),
        ),
        title: Text(title),
        subtitle: Text(friend.handleLabel),
        trailing: IconButton(
          tooltip: "friends.remove.confirm".t(context),
          onPressed: onRemove,
          icon: const Icon(Symbols.person_remove_rounded),
        ),
      ),
    );
  }
}

class _IncomingRequestTile extends StatelessWidget {
  const _IncomingRequestTile({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final String name = request.fromDisplayName.isNotEmpty
        ? request.fromDisplayName
        : "@${request.fromHandle}";
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "friends.request.wantsToConnect".t(context),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: Text("friends.decline".t(context)),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: FilledButton(
                    onPressed: onAccept,
                    child: Text("friends.accept".t(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OutgoingRequestTile extends StatelessWidget {
  const _OutgoingRequestTile({required this.request, required this.onCancel});

  final FriendRequest request;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final String name = request.toDisplayName.isNotEmpty
        ? request.toDisplayName
        : "@${request.toHandle}";
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(name),
        subtitle: Text("friends.request.pending".t(context)),
        trailing: TextButton(
          onPressed: onCancel,
          child: Text("friends.cancelRequest".t(context)),
        ),
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends({required this.onFind});

  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.group_rounded,
              size: 64.0,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16.0),
            Text(
              "friends.empty.title".t(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              "friends.empty.subtitle".t(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),
            FilledButton.icon(
              onPressed: onFind,
              icon: const Icon(Symbols.person_search_rounded),
              label: Text("friends.find".t(context)),
            ),
          ],
        ),
      ),
    );
  }
}
