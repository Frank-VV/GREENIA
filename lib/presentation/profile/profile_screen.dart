import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/report_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/san_jeronimo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../app/routes.dart';
import '../../app/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthRepository>().loadUserModel();
    });
  }

  Future<void> _editNeighborhood() async {
    final auth = context.read<AuthRepository>();
    String? selected = auth.userModel?.neighborhood ?? kNeighborhoods.first;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Tu barrio', style: Theme.of(ctx2).textTheme.titleLarge),
              ),
              const Divider(height: 1),
              ...kNeighborhoods.map(
                (n) => ListTile(
                  title: Text(n),
                  trailing: n == selected
                      ? Icon(Icons.check_rounded, color: Theme.of(ctx2).colorScheme.primary)
                      : null,
                  onTap: () {
                    setSt(() => selected = n);
                    Navigator.pop(ctx2);
                    auth.updateNeighborhood(n);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final auth = context.read<AuthRepository>();
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await auth.logout();
    if (mounted) nav.pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final user = auth.userModel;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            automaticallyImplyLeading: false,
            title: const Text('Mi Perfil'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.secondary],
                  ),
                ),
                child: user == null
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          _buildAvatar(user.photoUrl, user.initials, cs),
                          const SizedBox(height: 12),
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${user.neighborhood} · ${user.zone}',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null) _buildStatsGrid(user.uid, user.reportsCount, user.scansCount, cs),
                  const SizedBox(height: 20),
                  Text('Configuración', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildOptions(cs),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String photoUrl, String initials, ColorScheme cs) {
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: CachedNetworkImageProvider(photoUrl),
        backgroundColor: cs.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white.withValues(alpha: 0.25),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(String uid, int reportsCount, int scansCount, ColorScheme cs) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.collectionReports)
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final reports = snap.data?.docs.map(ReportModel.fromFirestore).toList() ?? [];
        final resolved = reports.where((r) => r.status == 'RESOLVED').length;
        final totalConfirmations = reports.fold<int>(0, (acc, r) => acc + r.confirmations);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _StatCard(label: 'Mis reportes', value: '$reportsCount', icon: Icons.flag_rounded, color: cs.primary),
            _StatCard(label: 'Escaneos', value: '$scansCount', icon: Icons.document_scanner_rounded, color: cs.secondary),
            _StatCard(label: 'Confirmaciones', value: '$totalConfirmations', icon: Icons.thumb_up_rounded, color: cs.tertiary),
            _StatCard(label: 'Atendidos', value: '$resolved', icon: Icons.check_circle_rounded, color: Colors.teal),
          ],
        );
      },
    );
  }

  Widget _buildOptions(ColorScheme cs) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.home_rounded, color: cs.primary),
            title: const Text('Mi barrio'),
            subtitle: Text(context.watch<AuthRepository>().userModel?.neighborhood ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _editNeighborhood,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(Icons.notifications_rounded, color: cs.primary),
            title: const Text('Notificaciones'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const Divider(height: 1),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => SwitchListTile(
              secondary: Icon(Icons.dark_mode_rounded, color: cs.primary),
              title: const Text('Modo oscuro'),
              value: themeProvider.isDark,
              onChanged: themeProvider.toggle,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info_outline_rounded, color: cs.primary),
            title: const Text('Acerca de GreenWatch'),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GreenWatch',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.eco_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 48,
      ),
      children: const [
        Text(
          'GreenWatch es una aplicación para fomentar la clasificación y disposición '
          'correcta de residuos sólidos en el distrito de San Jerónimo, Cusco.\n\n'
          'Desarrollado como parte de una tesis de la Universidad Continental — 2026.\n\n'
          'Alcaldía: Prof. Máximo Rimachi Morales',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

