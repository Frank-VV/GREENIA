import 'dart:convert';
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
      'Eres un sistema experto de visión artificial especializado en clasificación precisa de residuos sólidos. '
      'Analiza esta imagen con máximo detalle para identificar el material principal.\n\n'
      'PROCESO OBLIGATORIO DE ANÁLISIS:\n'
      'Paso 1: Identifica EXACTAMENTE qué objeto o material aparece en la imagen.\n'
      'Paso 2: Determina de qué material está compuesto (orgánico, plástico, papel, vidrio, metal, cartón).\n'
      'Paso 3: Asigna la categoría correcta basándote SOLO en el material, no en el color.\n\n'
      'REGLAS CRÍTICAS DE CLASIFICACIÓN:\n\n'
      '• "trash" → TODOS los residuos orgánicos/biológicos/no reciclables:\n'
      '  - Frutas y cáscaras: cáscara de plátano/banana, cáscara de naranja/limón/mango, restos de manzana\n'
      '  - Verduras: hojas, tallos, restos de cocina\n'
      '  - Restos de comida preparada, huesos, semillas\n'
      '  - Pañales, papel higiénico usado, servilletas usadas\n'
      '  - Cerámica rota, ropa vieja\n'
      '  REGLA: Si el objeto es de origen vegetal/animal/comida → SIEMPRE "trash" sin excepción\n\n'
      '• "plastic" → Solo materiales sintéticos de polímero artificial:\n'
      '  - Botellas PET, bolsas plásticas de polietileno, envases de yogur/margarina\n'
      '  - Tapas de plástico, sorbetes, envoltorios de caramelo\n'
      '  - Tecnopor/poliestireno expandido\n'
      '  REGLA: Solo es plástico si es claramente artificial/sintético, nunca si es orgánico\n\n'
      '• "cardboard" → Cartón y papel grueso:\n'
      '  - Cajas de cartón, empaques corrugados, cartones de cereal, cartones de huevo\n\n'
      '• "glass" → Vidrio transparente o de color:\n'
      '  - Botellas de vidrio, frascos de mermelada/salsa, vasos de vidrio\n\n'
      '• "metal" → Materiales metálicos:\n'
      '  - Latas de aluminio (bebidas), latas de hojalata (atún, frijoles), papel aluminio\n\n'
      '• "paper" → Papel delgado:\n'
      '  - Periódicos, revistas, papel de oficina, bolsas de papel kraft\n\n'
      'Asigna confianza 0.97+ cuando el objeto es claramente identificable.\n'
      'Responde ÚNICAMENTE con JSON válido sin texto adicional:\n'
      '{"category": "<categoría>", "confidence": <número 0.0-1.0>}';

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
