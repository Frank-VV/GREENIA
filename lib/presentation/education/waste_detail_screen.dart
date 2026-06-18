import 'package:flutter/material.dart';
import '../../data/models/waste_category_model.dart';

class WasteDetailScreen extends StatelessWidget {
  final String categoryKey;

  const WasteDetailScreen({super.key, required this.categoryKey});

  @override
  Widget build(BuildContext context) {
    final cat = getWasteCategory(categoryKey);
    if (cat == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Categoría no encontrada')),
      );
    }
    return _WasteDetailView(category: cat);
  }
}

class _WasteDetailView extends StatelessWidget {
  final WasteCategory category;

  const _WasteDetailView({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: category.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color.withValues(alpha: 0.85),
                      category.color,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(category.icon, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoChips(category: category),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: '¿Qué es?',
                    icon: Icons.help_outline_rounded,
                    color: category.color,
                    child: Text(
                      '${category.name} es un residuo de tipo "${category.type}". '
                      'Debe depositarse en ${category.bagColor}.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: '¿Cómo reciclarlo?',
                    icon: Icons.recycling_rounded,
                    color: category.color,
                    child: Column(
                      children: category.tips
                          .map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 20,
                                    color: category.color,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(tip, style: Theme.of(context).textTheme.bodyLarge),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Usos alternativos',
                    icon: Icons.lightbulb_outline_rounded,
                    color: category.color,
                    child: Column(
                      children: category.alternatives
                          .map((alt) => _ExpandableTile(
                                title: alt.title,
                                content: alt.description,
                                color: category.color,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EnvironmentalFactCard(fact: category.impactFact),
                  if (category.hasCompostGuide) ...[
                    const SizedBox(height: 16),
                    _CompostGuideCard(color: category.color),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChips extends StatelessWidget {
  final WasteCategory category;

  const _InfoChips({required this.category});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          avatar: Icon(Icons.category_rounded, size: 16, color: category.color),
          label: Text(category.type),
          backgroundColor: category.color.withValues(alpha: 0.1),
          labelStyle: TextStyle(color: category.color, fontWeight: FontWeight.w600),
          side: BorderSide.none,
        ),
        Chip(
          avatar: Icon(Icons.local_shipping_rounded, size: 16, color: category.color),
          label: Text(category.bagColor),
          backgroundColor: category.color.withValues(alpha: 0.1),
          labelStyle: TextStyle(color: category.color, fontWeight: FontWeight.w600),
          side: BorderSide.none,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ExpandableTile extends StatefulWidget {
  final String title;
  final String content;
  final Color color;

  const _ExpandableTile({
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: widget.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 0, 8),
            child: Text(widget.content, style: Theme.of(context).textTheme.bodyLarge),
          ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ],
    );
  }
}

class _EnvironmentalFactCard extends StatelessWidget {
  final String fact;

  const _EnvironmentalFactCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                  fact,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: cs.onTertiaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompostGuideCard extends StatelessWidget {
  final Color color;

  const _CompostGuideCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.compost_rounded, color: color),
          title: Text(
            'Guía de Compostaje',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompostSection(
                    title: 'Qué compostar',
                    icon: Icons.check_circle_rounded,
                    color: color,
                    items: kCompostGuide.whatToCompost,
                  ),
                  const SizedBox(height: 12),
                  _CompostSection(
                    title: 'Qué NO compostar',
                    icon: Icons.cancel_rounded,
                    color: Theme.of(context).colorScheme.error,
                    items: kCompostGuide.whatNotToCompost,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pasos para compostar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ...kCompostGuide.steps.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: color,
                                child: Text(
                                  '${e.key + 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(e.value),
                                ),
                              ),
                            ],
                          ),
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
}

class _CompostSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _CompostSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
