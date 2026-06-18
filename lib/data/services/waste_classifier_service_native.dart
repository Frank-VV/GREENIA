import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class WasteResult {
  final String category;
  final double confidence;
  final bool isDemo;

  const WasteResult({
    required this.category,
    required this.confidence,
    this.isDemo = false,
  });
}

class WasteClassifierService {
  static const List<String> kLabels = [
    'cardboard',
    'glass',
    'metal',
    'paper',
    'plastic',
    'trash',
  ];
  static const int kInputSize = 380;

  Interpreter? _interpreter;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        'assets/waste_model.tflite',
        options: options,
      );
      _isInitialized = true;
      debugPrint('WasteClassifierService: modelo cargado correctamente');
    } catch (e) {
      _isInitialized = false;
      debugPrint('WasteClassifierService: modelo no disponible, modo demo activo. Error: $e');
    }
  }

  Future<WasteResult> classify(Uint8List imageBytes) async {
    if (!_isInitialized || _interpreter == null) {
      return _demoResult();
    }

    try {
      final input = await compute(_preprocessInIsolate, imageBytes);
      if (input == null) return _demoResult();

      final output = List.generate(1, (_) => List.filled(kLabels.length, 0.0));
      _interpreter!.run(input, output);

      final probabilities = output[0];
      int maxIdx = 0;
      double maxVal = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxVal) {
          maxVal = probabilities[i];
          maxIdx = i;
        }
      }

      return WasteResult(
        category: kLabels[maxIdx],
        confidence: maxVal,
        isDemo: false,
      );
    } catch (e) {
      debugPrint('WasteClassifierService.classify error: $e');
      return _demoResult();
    }
  }

  static List<List<List<List<double>>>>? _preprocessInIsolate(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final resized = img.copyResize(
        decoded,
        width: kInputSize,
        height: kInputSize,
        interpolation: img.Interpolation.linear,
      );

      return List.generate(
        1,
        (_) => List.generate(
          kInputSize,
          (y) => List.generate(
            kInputSize,
            (x) {
              final pixel = resized.getPixel(x, y);
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
            },
          ),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  WasteResult _demoResult() {
    return const WasteResult(
      category: 'plastic',
      confidence: 0.0,
      isDemo: true,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
