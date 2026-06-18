import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  static const String _apiKey = String.fromEnvironment(
    'ANTHROPIC_API_KEY',
    defaultValue: '',
  );
  static const String _model = 'claude-opus-4-8';
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isInitialized = _apiKey.isNotEmpty;
    if (_isInitialized) {
      debugPrint('WasteClassifierService: Claude Vision API lista');
    } else {
      debugPrint('WasteClassifierService: API key no configurada, modo demo activo');
    }
  }

  Future<WasteResult> classify(Uint8List imageBytes) async {
    if (!_isInitialized) return _demoResult();

    try {
      final base64Image = base64Encode(imageBytes);
      final mediaType = _detectMediaType(imageBytes);

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 150,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': mediaType,
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text': _prompt,
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('WasteClassifierService: HTTP ${response.statusCode}: ${response.body}');
        return _demoResult();
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;
      if (content.isEmpty) return _demoResult();

      final text = (content[0] as Map<String, dynamic>)['text'] as String;
      return _parseResponse(text);
    } catch (e) {
      debugPrint('WasteClassifierService.classify error: $e');
      return _demoResult();
    }
  }

  static const String _prompt =
      'Eres un experto en clasificación de residuos sólidos para reciclaje. '
      'Analiza detalladamente esta imagen e identifica el material principal del objeto mostrado.\n\n'
      'Clasifica el residuo en EXACTAMENTE UNA de estas categorías:\n'
      '- cardboard: cajas de cartón, empaques de cartón, cartones de cereal, cartones de huevo\n'
      '- glass: botellas de vidrio, frascos de vidrio, recipientes de vidrio\n'
      '- metal: latas de aluminio, latas de hojalata, tapas metálicas, papel aluminio\n'
      '- paper: periódicos, revistas, papel de oficina, bolsas de papel, papel impreso\n'
      '- plastic: botellas plásticas, bolsas plásticas, envases plásticos, tecnopor/poliestireno\n'
      '- trash: residuos orgánicos, pañales, materiales mixtos no reciclables\n\n'
      'Responde ÚNICAMENTE con un objeto JSON (sin texto adicional):\n'
      '{"category": "<categoría>", "confidence": <0.0 a 1.0>}\n\n'
      'Donde confidence indica tu certeza: 0.9+ muy seguro, 0.7–0.9 seguro, 0.5–0.7 moderado.';

  String _detectMediaType(Uint8List bytes) {
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'image/jpeg';
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/jpeg';
  }

  WasteResult _parseResponse(String text) {
    try {
      final jsonMatch = RegExp(r'\{[^{}]+\}').firstMatch(text.trim());
      if (jsonMatch == null) {
        debugPrint('WasteClassifierService: JSON no encontrado en: $text');
        return _demoResult();
      }

      final parsed = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      final category = parsed['category'] as String?;
      final confidence = (parsed['confidence'] as num?)?.toDouble() ?? 0.5;

      if (category == null || !kLabels.contains(category)) {
        debugPrint('WasteClassifierService: categoría inválida: $category');
        return _demoResult();
      }

      return WasteResult(
        category: category,
        confidence: confidence.clamp(0.0, 1.0),
        isDemo: false,
      );
    } catch (e) {
      debugPrint('WasteClassifierService._parseResponse error: $e');
      return _demoResult();
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
    _isInitialized = false;
  }
}
