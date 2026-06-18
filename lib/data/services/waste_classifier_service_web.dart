import 'dart:typed_data';

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
  bool get isInitialized => false;

  Future<void> initialize() async {}

  Future<WasteResult> classify(Uint8List imageBytes) async {
    return const WasteResult(category: 'plastic', confidence: 0.0, isDemo: true);
  }

  void dispose() {}
}
