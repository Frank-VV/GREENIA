import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.collectionReports)
          .doc(reportId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reporte')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final report = ReportModel.fromFirestore(snap.data!);
        return _ReportDetailView(report: report);
      },
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  final ReportModel report;

  const _ReportDetailView({required this.report});

  Color get _severityColor {
    switch (report.severity) {
      case 'HIGH':
        return AppColors.severityHigh;
      case 'MEDIUM':
        return AppColors.severityMedium;
      default:
        return AppColors.severityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: report.photoUrl.isNotEmpty ? 260 : 0,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            title: const Text('Detalle del reporte'),
            flexibleSpace: report.photoUrl.isNotEmpty
                ? FlexibleSpaceBar(
                    background: Hero(
                      tag: 'report_photo_${report.id}',
                      child: CachedNetworkImage(
                        imageUrl: report.photoUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: cs.surfaceContainerHighest),
                      ),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(context, cs),
                  const SizedBox(height: 16),
                  _buildAuthorRow(context, cs),
                  const SizedBox(height: 16),
                  _buildLocationRow(context, cs),
                  const SizedBox(height: 16),
                  _buildDescription(context),
                  const SizedBox(height: 16),
                  _buildMap(),
                  const SizedBox(height: 16),
                  _buildActions(context, cs),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, ColorScheme cs) {
    Color statusColor;
    String statusLabel;
    switch (report.status) {
      case 'REVIEWING':
        statusColor = AppColors.statusReviewing;
        statusLabel = 'En revisión';
        break;
      case 'RESOLVED':
        statusColor = AppColors.statusResolved;
        statusLabel = 'Atendido';
        break;
      default:
        statusColor = AppColors.statusPending;
        statusLabel = 'Pendiente';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _severityColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Gravedad: ${report.severity == 'HIGH' ? 'Alta' : report.severity == 'MEDIUM' ? 'Media' : 'Baja'}',
            style: TextStyle(color: _severityColor, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        const Spacer(),
        Text(
          AppDateUtils.timeAgo(report.createdAt),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }

  Widget _buildAuthorRow(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: cs.primaryContainer,
          backgroundImage: report.displayAvatar.isNotEmpty
              ? CachedNetworkImageProvider(report.displayAvatar)
              : null,
          child: report.displayAvatar.isEmpty
              ? Text(
                  report.anonymous ? 'A' : (report.userName.isNotEmpty ? report.userName[0].toUpperCase() : '?'),
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.displayName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
            ),
            Text(
              report.neighborhood,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_rounded, color: cs.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            report.address,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(report.description, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildMap() {
    if (report.latitude == 0 && report.longitude == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(report.latitude, report.longitude),
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('report_location'),
              position: LatLng(report.latitude, report.longitude),
            ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          scrollGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.thumb_up_rounded,
            label: '${report.confirmations}',
            sublabel: 'Confirmaciones',
            color: cs.primary,
            onTap: () async {
              HapticFeedback.lightImpact();
              await context.read<ReportRepository>().confirmReport(report.id);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.comment_rounded,
            label: '${report.comments}',
            sublabel: 'Comentarios',
            color: cs.secondary,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
              ),
              Text(
                sublabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
