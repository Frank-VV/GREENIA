import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../app/routes.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;

  const ReportCard({super.key, required this.report});

  Color _severityColor() {
    switch (report.severity) {
      case 'HIGH':
        return AppColors.severityHigh;
      case 'MEDIUM':
        return AppColors.severityMedium;
      default:
        return AppColors.severityLow;
    }
  }

  IconData _severityIcon() {
    switch (report.severity) {
      case 'HIGH':
        return Icons.report_problem_rounded;
      case 'MEDIUM':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _severityLabel() {
    switch (report.severity) {
      case 'HIGH':
        return 'Alta';
      case 'MEDIUM':
        return 'Media';
      default:
        return 'Baja';
    }
  }

  Widget _statusChip(BuildContext context) {
    Color color;
    String label;
    switch (report.status) {
      case 'REVIEWING':
        color = AppColors.statusReviewing;
        label = 'En revisión';
        break;
      case 'RESOLVED':
        color = AppColors.statusResolved;
        label = 'Atendido';
        break;
      default:
        color = AppColors.statusPending;
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sevColor = _severityColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.reportDetail, arguments: report.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildAvatar(cs),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.displayName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${report.neighborhood} · ${AppDateUtils.timeAgo(report.createdAt)}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.55),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sevColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_severityIcon(), size: 14, color: sevColor),
                        const SizedBox(width: 4),
                        Text(
                          _severityLabel(),
                          style: TextStyle(
                            color: sevColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (report.photoUrl.isNotEmpty)
              Hero(
                tag: 'report_photo_${report.id}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: report.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: cs.surfaceContainerHighest),
                    errorWidget: (_, __, ___) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.image_not_supported_rounded, color: cs.outline),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.address,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (report.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  _ActionButton(
                    icon: Icons.thumb_up_outlined,
                    label: '${report.confirmations}',
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await context.read<ReportRepository>().confirmReport(report.id);
                    },
                  ),
                  _ActionButton(
                    icon: Icons.comment_outlined,
                    label: '${report.comments}',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.reportDetail, arguments: report.id),
                  ),
                  _ActionButton(
                    icon: Icons.share_rounded,
                    label: 'Compartir',
                    onTap: () {},
                  ),
                  const Spacer(),
                  _statusChip(context),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs) {
    final avatar = report.displayAvatar;
    if (avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(avatar),
        backgroundColor: cs.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: cs.primaryContainer,
      child: Text(
        report.anonymous ? 'A' : (report.userName.isNotEmpty ? report.userName[0].toUpperCase() : '?'),
        style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}
