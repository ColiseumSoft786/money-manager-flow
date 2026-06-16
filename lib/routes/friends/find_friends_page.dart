import "package:flow/data/firebase_friend.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/firebase_friends_service.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  final TextEditingController _queryController = TextEditingController();
  final FirebaseFriendsService _service = FirebaseFriendsService();

  bool _searching = false;
  bool _sending = false;
  FirebaseUserProfile? _result;
  bool _alreadyFriends = false;
  FriendRequest? _pendingRequest;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final String query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _result = null;
      _alreadyFriends = false;
      _pendingRequest = null;
    });

    try {
      final FirebaseUserProfile? found = await _service.findUser(query);
      bool friends = false;
      FriendRequest? pending;
      if (found != null) {
        friends = await _service.areFriends(found.userId);
        pending = await _service.getPendingRequestBetween(found.userId);
      }
      if (!mounted) return;
      setState(() {
        _result = found;
        _alreadyFriends = friends;
        _pendingRequest = pending;
        _searching = false;
      });
      if (found == null) {
        _showMessage("friends.error.notFound".t(context));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
      _showMessage(e.toString());
    }
  }

  Future<void> _acceptRequest(FriendRequest request) async {
    setState(() => _sending = true);
    try {
      await _service.acceptRequest(request);
      if (!mounted) return;
      setState(() {
        _alreadyFriends = true;
        _pendingRequest = null;
      });
      _showMessage("friends.accepted".t(context));
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendRequest() async {
    final FirebaseUserProfile? target = _result;
    if (target == null) return;

    setState(() => _sending = true);
    try {
      await _service.sendFriendRequest(target);
      if (!mounted) return;
      _showMessage("friends.request.sent".t(context));
    } on FirebaseFriendsException catch (e) {
      _showMessage(_localizedError(e));
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _localizedError(FirebaseFriendsException e) {
    switch (e.code) {
      case "cannotAddSelf":
        return "friends.error.cannotAddSelf".t(context);
      case "alreadyFriends":
        return "friends.error.alreadyFriends".t(context);
      case "requestAlreadySent":
        return "friends.error.requestAlreadySent".t(context);
      case "theyAlreadyRequested":
        return "friends.error.theyAlreadyRequested".t(context);
      case "profileMissing":
        return "friends.error.profileMissing".t(context);
      default:
        return e.code;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseUserProfile? result = _result;

    return Scaffold(
      appBar: AppBar(
        title: Text("friends.find".t(context)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              "friends.find.hint".t(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _queryController,
              autocorrect: false,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: "friends.find.placeholder".t(context),
                prefixIcon: const Icon(Symbols.search_rounded),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Spinner.inline(size: 20.0),
                      )
                    : IconButton(
                        onPressed: _search,
                        icon: const Icon(Symbols.arrow_forward_rounded),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            if (result != null)
              _SearchResultCard(
                profile: result,
                sending: _sending,
                alreadyFriends: _alreadyFriends,
                pendingRequest: _pendingRequest,
                onAdd: _sendRequest,
                onAccept: _pendingRequest == null
                    ? null
                    : () => _acceptRequest(_pendingRequest!),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.profile,
    required this.sending,
    required this.alreadyFriends,
    required this.pendingRequest,
    required this.onAdd,
    required this.onAccept,
  });

  final FirebaseUserProfile profile;
  final bool sending;
  final bool alreadyFriends;
  final FriendRequest? pendingRequest;
  final VoidCallback onAdd;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final String title = profile.displayName.isNotEmpty
        ? profile.displayName
        : profile.handleLabel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    title.isNotEmpty ? title[0].toUpperCase() : "?",
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(profile.handleLabel),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (alreadyFriends)
              Text(
                "friends.error.alreadyFriends".t(context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (pendingRequest != null && onAccept != null)
              FilledButton.icon(
                onPressed: sending ? null : onAccept,
                icon: const Icon(Symbols.check_rounded),
                label: Text("friends.accept".t(context)),
              )
            else if (pendingRequest != null)
              Text(
                "friends.request.pending".t(context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              FilledButton.icon(
                onPressed: sending ? null : onAdd,
                icon: sending
                    ? const Spinner.inline(
                        size: 18.0,
                        color: Colors.white,
                      )
                    : const Icon(Symbols.person_add_rounded),
                label: Text("friends.add".t(context)),
              ),
          ],
        ),
      ),
    );
  }
}
