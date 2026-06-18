import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/waste_category_model.dart';
import '../../data/services/waste_classifier_service.dart';
import '../../app/routes.dart';

class ScanResultArguments {
  final WasteResult result;
  final Uint8List? imageBytes;

  const ScanResultArguments({required this.result, this.imageBytes});
}

class ScanResultScreen extends StatefulWidget {
  final ScanResultArguments arguments;

  const ScanResultScreen({super.key, required this.arguments});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confidenceCtrl;
  late Animation<double> _confidenceAnim;

  WasteResult get result => widget.arguments.result;
  WasteCategory? get category => getWasteCategory(result.category);

  @override
  void initState() {
    super.initState();
    _confidenceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _confidenceAnim = Tween<double>(begin: 0, end: result.confidence).animate(
      CurvedAnimation(parent: _confidenceCtrl, curve: Curves.easeOut),
    );
    _confidenceCtrl.forward();
  }

  @override
  void dispose() {
    _confidenceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = category;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado del escaneo')),
      body: cat == null
          ? const Center(child: Text('Categoría no identificada'))
          : _buildContent(cat, cs),
    );
  }

  Widget _buildContent(WasteCategory cat, ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.isDemo)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.science_rounded, size: 16, color: cs.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo demostración — modelo IA no disponible',
                      style: TextStyle(fontSize: 12, color: cs.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          _buildHeader(cat, cs),
          const SizedBox(height: 16),
          _buildConfidenceBar(cat, cs),
          const SizedBox(height: 20),
          _buildDisposalSection(cat, cs),
          const SizedBox(height: 20),
          _buildEnvironmentalFact(cat, cs),
          const SizedBox(height: 20),
          _buildAlternatives(cat, cs),
          const SizedBox(height: 32),
          _buildButtons(cat),
        ],
      ),
    );
  }

  Widget _buildHeader(WasteCategory cat, ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: widget.arguments.imageBytes != null
                  ? MemoryImage(widget.arguments.imageBytes!)
                  : null,
              backgroundColor: cs.surfaceContainerHighest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: cat.color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    cat.type,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_shipping_rounded, size: 14, color: cat.color),
                        const SizedBox(width: 6),
                        Text(
                          cat.bagColor,
                          style: TextStyle(
                            color: cat.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(WasteCategory cat, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confianza de la IA',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
            ),
            AnimatedBuilder(
              animation: _confidenceAnim,
              builder: (_, __) => Text(
                result.isDemo ? '—' : '${(_confidenceAnim.value * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: cat.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _confidenceAnim,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: result.isDemo ? 0 : _confidenceAnim.value,
              minHeight: 10,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cat.color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisposalSection(WasteCategory cat, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo desecharlo?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...cat.howToDispose.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: cat.color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(e.value, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildEnvironmentalFact(WasteCategory cat, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco_rounded, color: cs.onTertiaryContainer, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dato ambiental',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                        color: cs.onTertiaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  cat.impactFact,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onTertiaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternatives(WasteCategory cat, ColorScheme cs) {
    if (cat.alternatives.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Usos alternativos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cat.alternatives
                .map(
                  (alt) => GestureDetector(
                    onTap: () => _showAlternativeDetail(alt),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cat.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.recycling_rounded, size: 16, color: cat.color),
                          const SizedBox(width: 6),
                          Text(
                            alt.title,
                            style: TextStyle(
                              color: cat.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  void _showAlternativeDetail(Alternative alt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alt.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(alt.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(WasteCategory cat) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Escanear otro'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.wasteDetail,
              arguments: cat.key,
            ),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Más información'),
          ),
        ),
      ],
    );
  }
}
