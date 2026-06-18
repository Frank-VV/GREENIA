import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/san_jeronimo_data.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _step = 0;
  File? _photoFile;
  double _latitude = kSanJeronimoLat;
  double _longitude = kSanJeronimoLng;
  String _address = '';
  String _neighborhood = kNeighborhoods.first;
  final _descCtrl = TextEditingController();
  String _severity = 'LOW';
  bool _anonymous = false;
  bool _isLoading = false;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _descCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null) return;
    setState(() => _photoFile = File(xfile.path));
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      await _reverseGeocode(_latitude, _longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(_latitude, _longitude)),
      );
      setState(() {});
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address = [
          p.street,
          p.subLocality,
          p.locality,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
      }
    } catch (e) {
      _address = 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
    }
  }

  Future<void> _submit() async {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, describe el problema')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthRepository>();
      final repo = context.read<ReportRepository>();
      final user = auth.userModel;
      if (user == null) return;

      final error = await repo.createReport(
        userId: user.uid,
        userName: user.displayName,
        userAvatar: user.photoUrl,
        photoFile: _photoFile,
        latitude: _latitude,
        longitude: _longitude,
        address: _address,
        neighborhood: _neighborhood,
        description: _descCtrl.text.trim(),
        severity: _severity,
        anonymous: _anonymous,
      );

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Theme.of(context).colorScheme.error),
        );
        return;
      }

      HapticFeedback.heavyImpact();
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.check_circle_rounded,
              color: Theme.of(ctx).colorScheme.primary, size: 48),
          title: const Text('¡Reporte publicado!'),
          content: const Text('Gracias por cuidar San Jerónimo. Tu reporte será revisado por las autoridades.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo reporte'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: cs.onPrimary.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStep(cs),
      ),
    );
  }

  Widget _buildStep(ColorScheme cs) {
    switch (_step) {
      case 0:
        return _buildStep1(cs);
      case 1:
        return _buildStep2(cs);
      case 2:
        return _buildStep3(cs);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(ColorScheme cs) {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paso 1 — Foto del problema',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Toma una foto del problema o selecciónala desde tu galería',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          if (_photoFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(_photoFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Retomar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _step = 1),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Usar esta foto'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 64,
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Tomar foto'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Desde galería'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: const Text('Continuar sin foto'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2(ColorScheme cs) {
    return Column(
      key: const ValueKey(1),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paso 2 — Ubicación',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Arrastra el pin para marcar exactamente el problema',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(_latitude, _longitude),
                            zoom: 16,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('report'),
                              position: LatLng(_latitude, _longitude),
                              draggable: true,
                              onDragEnd: (pos) async {
                                _latitude = pos.latitude;
                                _longitude = pos.longitude;
                                await _reverseGeocode(_latitude, _longitude);
                                setState(() {});
                              },
                            ),
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          onMapCreated: (ctrl) {
                            _mapController = ctrl;
                            _getCurrentLocation();
                          },
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: FloatingActionButton.small(
                            onPressed: _getCurrentLocation,
                            child: const Icon(Icons.my_location_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_address.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_address, style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _neighborhood,
                  decoration: const InputDecoration(
                    labelText: 'Barrio',
                    prefixIcon: Icon(Icons.home_rounded),
                  ),
                  items: kNeighborhoods
                      .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                      .toList(),
                  onChanged: (v) => setState(() => _neighborhood = v ?? kNeighborhoods.first),
                ),
              ],
            ),
          ),
        ),
        _buildNavButtons(
          onBack: () => setState(() => _step = 0),
          onNext: () => setState(() => _step = 2),
        ),
      ],
    );
  }

  Widget _buildStep3(ColorScheme cs) {
    return Column(
      key: const ValueKey(2),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paso 3 — Detalles',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 5,
                  maxLength: AppConstants.maxDescriptionLength,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe lo que encontraste en este lugar...',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _severity,
                  decoration: const InputDecoration(
                    labelText: 'Gravedad',
                    prefixIcon: Icon(Icons.warning_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'HIGH',
                        child: Text('Alta — Requiere atención urgente')),
                    DropdownMenuItem(
                        value: 'MEDIUM',
                        child: Text('Media — Problema moderado')),
                    DropdownMenuItem(
                        value: 'LOW',
                        child: Text('Baja — Observación menor')),
                  ],
                  onChanged: (v) => setState(() => _severity = v ?? 'LOW'),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    secondary: Icon(Icons.person_off_rounded, color: cs.primary),
                    title: const Text('Reportar de forma anónima'),
                    subtitle: const Text('Tu nombre no aparecerá en el reporte'),
                    value: _anonymous,
                    onChanged: (v) => setState(() => _anonymous = v),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildNavButtons(
          onBack: () => setState(() => _step = 1),
          onNext: _isLoading ? null : _submit,
          nextLabel: 'Publicar reporte',
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildNavButtons({
    required VoidCallback? onBack,
    required VoidCallback? onNext,
    String nextLabel = 'Siguiente',
    bool isLoading = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onBack != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Atrás'),
              ),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : onNext,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(nextLabel),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
