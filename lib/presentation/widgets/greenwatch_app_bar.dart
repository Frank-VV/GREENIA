import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/repositories/auth_repository.dart';
import '../../app/routes.dart';

class GreenWatchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? extraActions;
  final PreferredSizeWidget? bottom;
  final bool showLogo;

  const GreenWatchAppBar({
    super.key,
    this.title,
    this.extraActions,
    this.bottom,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthRepository>();

    return AppBar(
      title: showLogo
          ? Row(
              children: [
                Icon(Icons.eco_rounded, color: cs.onPrimary, size: 22),
                const SizedBox(width: 8),
                Text(title ?? 'GreenWatch'),
              ],
            )
          : Text(title ?? 'GreenWatch'),
      automaticallyImplyLeading: false,
      bottom: bottom,
      actions: [
        if (extraActions != null) ...extraActions!,
        IconButton(
          icon: Badge(
            isLabelVisible: false,
            child: Icon(Icons.notifications_rounded, color: cs.onPrimary),
          ),
          onPressed: () {},
          tooltip: 'Notificaciones',
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          child: Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: _buildAvatar(auth, cs),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(AuthRepository auth, ColorScheme cs) {
    final user = auth.userModel;
    final photoUrl = user?.photoUrl ?? '';
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: CachedNetworkImageProvider(photoUrl),
        backgroundColor: cs.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
      child: Text(
        user?.initials ?? '?',
        style: TextStyle(
          color: cs.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
