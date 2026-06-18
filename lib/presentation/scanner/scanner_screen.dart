import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/services/waste_classifier_service.dart';
import '../../app/routes.dart';
import 'scan_result_screen.dart';

enum _ScannerState { idle, scanning, error }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;
  bool _isTorchOn = false;
  _ScannerState _state = _ScannerState.idle;

  late AnimationController _laserCtrl;
  late Animation<double> _laserAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _laserCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _laserAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _laserCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      if (mounted) setState(() => _isCameraInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _laserCtrl.dispose();
    _pulseCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = context.read<List<CameraDescription>>();
    if (cameras.isEmpty) return;

    final idx = _isFrontCamera
        ? cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front)
        : cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    final cameraIdx = idx < 0 ? 0 : idx;

    final ctrl = CameraController(
      cameras[cameraIdx],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      _controller = ctrl;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _flipCamera() async {
    await _controller?.dispose();
    setState(() {
      _isCameraInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });
    await _initCamera();
  }

  Future<void> _toggleTorch() async {
    if (_controller == null) return;
    try {
      _isTorchOn = !_isTorchOn;
      await _controller!.setFlashMode(_isTorchOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (_) {}
  }

  Future<void> _captureAndClassify() async {
    if (_controller == null || !_isCameraInitialized || _state == _ScannerState.scanning) return;
    setState(() => _state = _ScannerState.scanning);
    try {
      final xfile = await _controller!.takePicture();
      final bytes = await xfile.readAsBytes();
      await _classify(bytes);
    } catch (e) {
      _showError();
    }
  }

  Future<void> _pickFromGallery() async {
    if (_state == _ScannerState.scanning) return;
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xfile == null) return;
    setState(() => _state = _ScannerState.scanning);
    final bytes = await xfile.readAsBytes();
    await _classify(bytes);
  }

  Future<void> _classify(Uint8List imageBytes) async {
    final service = context.read<WasteClassifierService>();
    try {
      final result = await service.classify(imageBytes);
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.scanResult,
        arguments: ScanResultArguments(result: result, imageBytes: imageBytes),
      );
    } catch (e) {
      _showError();
    } finally {
      if (mounted) setState(() => _state = _ScannerState.idle);
    }
  }

  void _showError() {
    if (!mounted) return;
    setState(() => _state = _ScannerState.error);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo identificar el residuo. Intenta de nuevo'),
        duration: Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _state = _ScannerState.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Escáner IA'),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded),
            onPressed: _toggleTorch,
            tooltip: 'Linterna',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraInitialized && _controller != null)
            CameraPreview(_controller!)
          else
            const ColoredBox(color: Colors.black),
          if (_state == _ScannerState.scanning)
            _buildScanningOverlay()
          else
            _buildIdleOverlay(),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _buildControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleOverlay() {
    const frameSize = 240.0;
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(color: Colors.transparent),
              Center(
                child: Container(
                  width: frameSize,
                  height: frameSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            width: frameSize,
            height: frameSize,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(frameSize, frameSize),
                  painter: _CornerPainter(),
                ),
                AnimatedBuilder(
                  animation: _laserAnim,
                  builder: (_, __) => Positioned(
                    top: 8 + _laserAnim.value * (frameSize - 24),
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF2E7D32).withValues(alpha: 0.9),
                            const Color(0xFF4CAF50),
                            const Color(0xFF2E7D32).withValues(alpha: 0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Icon(Icons.photo_camera_rounded, color: Colors.white54, size: 20),
              const SizedBox(height: 8),
              Text(
                'Apunta la cámara al residuo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF4CAF50)),
            const SizedBox(height: 24),
            Text(
              'Analizando con IA...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ControlButton(
            icon: Icons.photo_library_rounded,
            size: 44,
            onTap: _state == _ScannerState.scanning ? null : _pickFromGallery,
            tooltip: 'Galería',
          ),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: _state == _ScannerState.idle ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: GestureDetector(
              onTap: _state == _ScannerState.scanning ? null : _captureAndClassify,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: _state == _ScannerState.scanning ? Colors.grey : Colors.white,
                ),
                child: const Icon(
                  Icons.camera_rounded,
                  size: 36,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          _ControlButton(
            icon: Icons.flip_camera_android_rounded,
            size: 44,
            onTap: _state == _ScannerState.scanning ? null : _flipCamera,
            tooltip: 'Voltear',
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.size,
    this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  static const double cornerLen = 24.0;
  static const double cornerRadius = 6.0;
  static const double strokeWidth = 3.0;
  static const color = Color(0xFF2E7D32);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(const Offset(0, cornerLen), const Offset(0, cornerRadius), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
        3.14, -1.57, false, paint);
    canvas.drawLine(const Offset(cornerRadius, 0), const Offset(cornerLen, 0), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - cornerLen, 0), Offset(size.width - cornerRadius, 0), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - cornerRadius * 2, 0, cornerRadius * 2, cornerRadius * 2),
        -1.57, -1.57, false, paint);
    canvas.drawLine(Offset(size.width, cornerRadius), Offset(size.width, cornerLen), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - cornerLen), Offset(0, size.height - cornerRadius), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        3.14, 1.57, false, paint);
    canvas.drawLine(Offset(cornerRadius, size.height), Offset(cornerLen, size.height), paint);

    // Bottom-right
    canvas.drawLine(
        Offset(size.width - cornerLen, size.height), Offset(size.width - cornerRadius, size.height), paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width - cornerRadius * 2, size.height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        0, 1.57, false, paint);
    canvas.drawLine(Offset(size.width, size.height - cornerRadius), Offset(size.width, size.height - cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
