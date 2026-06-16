import "package:auto_size_text/auto_size_text.dart";
import "package:flow/entity/profile.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/profile_picture.dart";
import "package:flow/widgets/home/privacy_toggler.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:moment_dart/moment_dart.dart";

class GreetingsBar extends StatelessWidget {
  QueryBuilder<Profile> qb() => ObjectBox().box<Profile>().query();

  const GreetingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile?>(
      stream: qb()
          .watch(triggerImmediately: true)
          .map((event) => event.findFirst()),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final String dateLine = Moment.now().format("dddd, MMM D");

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfilePicture(
              filePath: profile?.imagePath,
              size: 44.0,
              onTap: profile != null
                  ? () => context.push("/profile/${profile.id}")
                  : null,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    "tabs.home.greetings".t(context, profile?.name ?? "..."),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    dateLine,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            const PrivacyToggler(),
          ],
        );
      },
    );
  }
}
