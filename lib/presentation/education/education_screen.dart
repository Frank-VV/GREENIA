import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/waste_category_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/category_card.dart';
import '../../app/routes.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _searchQuery = '';

  List<WasteCategory> get _filteredCategories {
    final cats = kWasteCategories.values.toList();
    if (_searchQuery.isEmpty) return cats;
    return cats
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.type.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildAvatar(AuthRepository auth, ColorScheme cs) {
    final user = auth.userModel;
    final photoUrl = user?.photoUrl ?? '';
    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: CachedNetworkImageProvider(photoUrl),
        backgroundColor: cs.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
      child: Text(
        user?.initials ?? '?',
        style: TextStyle(color: cs.onPrimary, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 180,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Badge(isLabelVisible: false, child: Icon(Icons.notifications_rounded, color: cs.onPrimary)),
              onPressed: () {},
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: _buildAvatar(context.watch<AuthRepository>(), cs),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary, cs.secondary],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Aprende a clasificar',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Guía oficial para vecinos de San Jerónimo',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: cs.onPrimary.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar categoría...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cat = _filteredCategories[index];
                return CategoryCard(
                  category: cat,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.wasteDetail,
                    arguments: cat.key,
                  ),
                );
              },
              childCount: _filteredCategories.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
          ),
        ),
        if (_filteredCategories.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'No se encontraron categorías',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    ),
    );
  }
}
