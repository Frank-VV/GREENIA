import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';
import '../widgets/report_card.dart';
import '../widgets/loading_widget.dart' as gw;
import '../../app/routes.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Row(
                children: [
                  Icon(Icons.eco_rounded, color: cs.onPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reportes Comunidad',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.secondary],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
                  child: Text(
                    'Comparte problemas ambientales\nen San Jerónimo',
                    style: TextStyle(
                      color: cs.onPrimary.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _ReportFeed(stream: context.read<ReportRepository>().allReports()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createReport),
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Nuevo reporte'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
  }
}

class _ReportFeed extends StatelessWidget {
  final Stream<List<ReportModel>> stream;

  const _ReportFeed({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: gw.LoadingShimmerList(),
          );
        }
        if (snap.hasError) {
          return SliverFillRemaining(
            child: gw.ErrorWidget(
              message: 'Error al cargar los reportes',
              onRetry: () {},
            ),
          );
        }
        final reports = snap.data ?? [];
        if (reports.isEmpty) {
          return const SliverFillRemaining(
            child: gw.EmptyWidget(
              message: 'Aún no hay reportes.\n¡Sé el primero en reportar!',
              icon: Icons.campaign_rounded,
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '${reports.length} reporte${reports.length != 1 ? 's' : ''} publicado${reports.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                );
              }
              return ReportCard(report: reports[i - 1]);
            },
            childCount: reports.length + 1,
          ),
        );
      },
    );
  }
}
