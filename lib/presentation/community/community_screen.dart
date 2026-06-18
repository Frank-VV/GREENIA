import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';
import '../widgets/report_card.dart';
import '../widgets/loading_widget.dart' as gw;
import '../widgets/greenwatch_app_bar.dart';
import '../../app/routes.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GreenWatchAppBar(
          title: 'Comunidad',
          showLogo: true,
          bottom: TabBar(
            labelColor: cs.onPrimary,
            unselectedLabelColor: cs.onPrimary.withValues(alpha: 0.7),
            indicatorColor: cs.onPrimary,
            tabs: const [
              Tab(text: 'Pendientes'),
              Tab(text: 'En revisión / Atendidos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReportList(stream: context.read<ReportRepository>().pendingReports()),
            _ReportList(stream: context.read<ReportRepository>().reviewedReports()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.createReport),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('Nuevo reporte'),
        ),
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  final Stream<List<ReportModel>> stream;

  const _ReportList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const gw.LoadingShimmerList();
        }
        if (snap.hasError) {
          return gw.ErrorWidget(
            message: 'Error al cargar los reportes',
            onRetry: () {},
          );
        }
        final reports = snap.data ?? [];
        if (reports.isEmpty) {
          return const gw.EmptyWidget(
            message: 'No hay reportes en esta sección',
            icon: Icons.inbox_rounded,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: reports.length,
          itemBuilder: (_, i) => ReportCard(report: reports[i]),
        );
      },
    );
  }
}
