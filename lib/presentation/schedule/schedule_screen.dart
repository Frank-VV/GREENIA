import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/san_jeronimo_data.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  CollectionRoute? _selectedRoute;
  GoogleMapController? _mapController;
  late TabController _tabCtrl;

  // 0=all, 1=mon/thu, 2=tue/fri, 3=wed/sat, 4=organic
  int _dayFilter = 0;

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  static const _tabs = ['Todos', 'Lun/Jue', 'Mar/Vie', 'Mié/Sáb', 'Orgánicos'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      setState(() {
        _dayFilter = _tabCtrl.index;
        _selectedRoute = null;
        _updateMap(null);
      });
    });
    _buildAcopioMarkers();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _buildAcopioMarkers() {
    for (final p in kAcopioPoints) {
      _markers.add(Marker(
        markerId: MarkerId('acopio_${p.id}'),
        position: LatLng(p.lat, p.lng),
        infoWindow: InfoWindow(title: p.name, snippet: p.schedule),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
  }

  void _selectRoute(CollectionRoute route) {
    setState(() => _selectedRoute = route);
    _updateMap(route);
    _scrollToMap();
  }

  void _updateMap(CollectionRoute? route) {
    _polylines.clear();
    if (route == null) return;

    final color = route.type == 'organic'
        ? const Color(0xFFFF6F00)
        : const Color(0xFF2E7D32);

    _polylines.add(Polyline(
      polylineId: PolylineId(route.id),
      points: route.routePoints,
      color: color,
      width: 5,
      patterns: const [],
    ));

    // Add a marker at the center of the route
    _markers.removeWhere((m) => m.markerId.value == 'route_center');
    _markers.add(Marker(
      markerId: const MarkerId('route_center'),
      position: route.center,
      infoWindow: InfoWindow(
        title: 'Ruta ${route.number} — ${route.name}',
        snippet: '${route.daysLabel} | ${route.timeStart}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        route.type == 'organic' ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
      ),
    ));

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(route.center, 14.8),
    );
  }

  late final ScrollController _scrollCtrl = ScrollController();

  void _scrollToMap() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  List<CollectionRoute> get _filteredRoutes {
    final allRoutes = [...kOrganicRoutes, ...kGeneralRoutes];
    switch (_dayFilter) {
      case 1: // Lun/Jue
        return allRoutes.where((r) => r.days.contains(1) || r.days.contains(4)).toList();
      case 2: // Mar/Vie
        return allRoutes.where((r) => r.days.contains(2) || r.days.contains(5)).toList();
      case 3: // Mié/Sáb
        return allRoutes.where((r) => r.days.contains(3) || r.days.contains(6)).toList();
      case 4: // Orgánicos
        return kOrganicRoutes;
      default:
        return allRoutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (context, _) => [
          _buildSliverAppBar(cs),
        ],
        body: Column(
          children: [
            _buildTabBar(cs),
            Expanded(
              child: _buildRouteList(cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme cs) {
    final today = DateTime.now().weekday; // 1=Mon..7=Sun
    final dayNames = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      title: const Text(
        'Rutas de Recolección',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary, cs.secondary],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 100),
              // Day pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final d = i + 1;
                    final isToday = d == today;
                    return _DayPill(
                      label: dayNames[d],
                      isToday: isToday,
                      primaryColor: cs.onPrimary,
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatBadge(
                      icon: Icons.eco_rounded,
                      label: '${kOrganicRoutes.length} rutas orgánicas',
                      color: const Color(0xFFFF6F00),
                    ),
                    const SizedBox(width: 8),
                    _StatBadge(
                      icon: Icons.local_shipping_rounded,
                      label: '${kGeneralRoutes.length} rutas generales',
                      color: cs.onPrimary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Interactive map
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(kSanJeronimoLat, kSanJeronimoLng),
                            zoom: 13.8,
                          ),
                          markers: _markers,
                          polylines: _polylines,
                          mapType: MapType.normal,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          onMapCreated: (ctrl) => _mapController = ctrl,
                        ),
                        if (_selectedRoute == null)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.touch_app_rounded,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Toca una ruta para verla en el mapa',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_selectedRoute != null)
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: (_selectedRoute!.type == 'organic'
                                        ? const Color(0xFFFF6F00)
                                        : Colors.green.shade700)
                                    .withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.route_rounded,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ruta ${_selectedRoute!.number} — ${_selectedRoute!.name}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedRoute = null);
                                      _updateMap(null);
                                      _mapController?.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          const LatLng(kSanJeronimoLat, kSanJeronimoLng),
                                          13.8,
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.close_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ColorScheme cs) {
    return Container(
      color: cs.surface,
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurface.withValues(alpha: 0.5),
        indicatorColor: cs.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildRouteList(ColorScheme cs) {
    final routes = _filteredRoutes;
    if (routes.isEmpty) {
      return const Center(
        child: Text('No hay rutas para este filtro'),
      );
    }

    // Group by type for "Todos" view
    final organicRoutes = routes.where((r) => r.type == 'organic').toList();
    final generalRoutes = routes.where((r) => r.type == 'general').toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (organicRoutes.isNotEmpty) ...[
          const _SectionHeader(
            icon: Icons.eco_rounded,
            title: 'Residuos Orgánicos',
            subtitle: 'Recojo diferenciado de restos de comida',
            color: Color(0xFFFF6F00),
          ),
          ...organicRoutes.map((r) => _RouteCard(
                route: r,
                isSelected: _selectedRoute?.id == r.id,
                onTap: () => _selectRoute(r),
              )),
        ],
        if (generalRoutes.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.local_shipping_rounded,
            title: 'Recolección General',
            subtitle: 'Turno Mañana: 5:00 a.m. – 10:00 a.m.',
            color: cs.primary,
          ),
          ...generalRoutes.map((r) => _RouteCard(
                route: r,
                isSelected: _selectedRoute?.id == r.id,
                onTap: () => _selectRoute(r),
              )),
        ],
        // Info note
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: cs.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Espera al camión recolector en tu calle. '
                    'Sacar residuos fuera de horario está prohibido y es sancionado con multas.',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _DayPill extends StatelessWidget {
  final String label;
  final bool isToday;
  final Color primaryColor;

  const _DayPill({
    required this.label,
    required this.isToday,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 44,
      decoration: BoxDecoration(
        color: isToday
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(top: 3),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final CollectionRoute route;
  final bool isSelected;
  final VoidCallback onTap;

  const _RouteCard({
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  Color get _typeColor =>
      route.type == 'organic' ? const Color(0xFFFF6F00) : const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? _typeColor.withValues(alpha: 0.08)
            : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _typeColor : cs.outline.withValues(alpha: 0.15),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.03),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route number badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _typeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      route.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Route info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isSelected ? _typeColor : cs.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13, color: cs.onSurface.withValues(alpha: 0.55)),
                        const SizedBox(width: 4),
                        Text(
                          route.daysLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule_rounded,
                            size: 13, color: cs.onSurface.withValues(alpha: 0.55)),
                        const SizedBox(width: 4),
                        Text(
                          'desde ${route.timeStart}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      route.sectors.take(3).join(' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      // Streets list
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: route.streets
                            .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _typeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _typeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.map_rounded, size: 13, color: _typeColor),
                          const SizedBox(width: 4),
                          Text(
                            'Ruta visible en el mapa ↑',
                            style: TextStyle(
                              fontSize: 11,
                              color: _typeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow / map icon
              Icon(
                isSelected ? Icons.keyboard_arrow_up_rounded : Icons.map_rounded,
                color: isSelected ? _typeColor : cs.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
