import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../core/constants/san_jeronimo_data.dart';
import '../../core/utils/date_utils.dart';
import '../widgets/loading_widget.dart' as gw;
import '../widgets/greenwatch_app_bar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  ScheduleModel? _schedule;
  bool _loading = true;
  String? _error;
  String _selectedZone = '';
  Timer? _countdownTimer;
  Duration? _countdown;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchedule());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _loadSchedule() async {
    setState(() => _loading = true);
    final auth = context.read<AuthRepository>();
    final repo = context.read<ScheduleRepository>();
    try {
      await auth.loadUserModel();
      final zone = auth.userModel?.zone ?? 'Zona Centro';
      _selectedZone = zone;

      _schedule = await repo.getScheduleForZone(zone);

      _buildMarkers();
      _startCountdown();
    } catch (e) {
      _error = 'Error al cargar los horarios: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeZone(String zoneName) async {
    setState(() {
      _selectedZone = zoneName;
      _loading = true;
    });
    try {
      final repo = context.read<ScheduleRepository>();
      _schedule = await repo.getScheduleForZone(zoneName);
      _startCountdown();
    } catch (e) {
      _error = 'Error al cargar la zona';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_schedule == null) return;
    _countdown = AppDateUtils.countdownToCollection(_schedule!.timeStart);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_countdown != null && _countdown!.inSeconds > 0) {
          _countdown = _countdown! - const Duration(seconds: 1);
        }
      });
    });
  }

  void _buildMarkers() {
    _markers.clear();
    for (final point in kAcopioPoints) {
      _markers.add(
        Marker(
          markerId: MarkerId(point.id),
          position: LatLng(point.lat, point.lng),
          infoWindow: InfoWindow(
            title: point.name,
            snippet: point.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
  }

  Future<void> _showZonePicker() async {
    const zones = kZoneNames;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seleccionar zona',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            ...zones.map(
              (z) => ListTile(
                leading: Icon(
                  Icons.location_on_rounded,
                  color: z == _selectedZone
                      ? Theme.of(ctx).colorScheme.primary
                      : null,
                ),
                title: Text(z),
                trailing: z == _selectedZone
                    ? Icon(Icons.check_rounded,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _changeZone(z);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (!status.isGranted) return;
      await _scheduleReminder();
    } else {
      await _notificationsPlugin.cancelAll();
    }
  }

  Future<void> _scheduleReminder() async {
    await _notificationsPlugin.show(
      0,
      'Recordatorio de recolección',
      'Hoy es día de recolección en $_selectedZone',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'collection_reminder',
          'Recordatorios de recolección',
          channelDescription: 'Notificaciones de días de recolección',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio activado para hoy')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(
        appBar: GreenWatchAppBar(title: 'Horarios'),
        body: gw.LoadingShimmerList(itemCount: 4),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: const GreenWatchAppBar(title: 'Horarios'),
        body: gw.ErrorWidget(message: _error!, onRetry: _loadSchedule),
      );
    }

    return Scaffold(
      appBar: const GreenWatchAppBar(title: 'Horarios'),
      body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(cs),
          _buildZoneSelector(cs),
          if (_schedule != null) ...[
            _buildNextCollection(cs),
            _buildWeekCalendar(cs),
          ] else
            Padding(
              padding: const EdgeInsets.all(24),
              child: gw.EmptyWidget(
                message: 'No hay horarios disponibles para $_selectedZone',
                icon: Icons.schedule_rounded,
              ),
            ),
          _buildMapSection(cs),
          _buildReminderSwitch(cs),
          const SizedBox(height: 32),
        ],
      ),
    ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horarios de Recolección',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            'San Jerónimo, Cusco',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onPrimary.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSelector(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: _showZonePicker,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.map_rounded, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu zona de recolección',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    Text(
                      _selectedZone,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: cs.primary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: cs.primary, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextCollection(ColorScheme cs) {
    final schedule = _schedule!;
    final nextDate = AppDateUtils.nextCollectionDate(schedule.daysOfWeek);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: cs.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
          color: cs.primaryContainer.withValues(alpha: 0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time_filled_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Próxima recolección',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (nextDate != null) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: cs.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    AppDateUtils.formatDate(nextDate),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: cs.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    schedule.scheduleRange,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: schedule.wasteTypes
                    .map(
                      (t) => Chip(
                        label: Text(t),
                        backgroundColor: cs.primaryContainer,
                        labelStyle: TextStyle(color: cs.primary, fontSize: 12),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (_countdown != null && _countdown!.inSeconds > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      'En ${AppDateUtils.formatDuration(_countdown!)}',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendar(ColorScheme cs) {
    final schedule = _schedule!;
    final today = AppDateUtils.flutterWeekdayToApp(DateTime.now().weekday);
    const dayLabels = ['D', 'L', 'M', 'X', 'J', 'V', 'S'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Días de recolección', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final appDay = i + 1;
              final isCollectionDay = schedule.daysOfWeek.contains(appDay);
              final isToday = appDay == today;
              return _DayCircle(
                label: dayLabels[i],
                isCollectionDay: isCollectionDay,
                isToday: isToday,
                primaryColor: cs.primary,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Puntos de Acopio', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 280,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(kSanJeronimoLat, kSanJeronimoLng),
                  zoom: 14.5,
                ),
                markers: _markers,
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (ctrl) => _mapController = ctrl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSwitch(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: SwitchListTile(
          secondary: Icon(Icons.notifications_active_rounded, color: cs.primary),
          title: const Text('Activar recordatorio'),
          subtitle: const Text('Recibe una notificación el día de recolección'),
          value: false,
          onChanged: _toggleReminder,
        ),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String label;
  final bool isCollectionDay;
  final bool isToday;
  final Color primaryColor;

  const _DayCircle({
    required this.label,
    required this.isCollectionDay,
    required this.isToday,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BoxDecoration decoration;

    if (isCollectionDay && isToday) {
      bg = primaryColor;
      fg = Colors.white;
      decoration = BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: 3),
      );
    } else if (isCollectionDay) {
      bg = primaryColor.withValues(alpha: 0.15);
      fg = primaryColor;
      decoration = BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: 2),
      );
    } else if (isToday) {
      bg = Colors.grey.withValues(alpha: 0.2);
      fg = Theme.of(context).colorScheme.onSurface;
      decoration = BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: 2),
      );
    } else {
      bg = Colors.grey.withValues(alpha: 0.1);
      fg = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
      decoration = BoxDecoration(color: bg, shape: BoxShape.circle);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: decoration,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
