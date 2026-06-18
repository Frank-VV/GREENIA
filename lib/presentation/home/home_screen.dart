import 'package:flutter/material.dart';
import '../education/education_screen.dart';
import '../scanner/scanner_screen.dart';
import '../schedule/schedule_screen.dart';
import '../community/community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<_TabItem> _tabs = [
    _TabItem(label: 'Educación', icon: Icons.menu_book_rounded),
    _TabItem(label: 'Escanear', icon: Icons.document_scanner_rounded),
    _TabItem(label: 'Horarios', icon: Icons.schedule_rounded),
    _TabItem(label: 'Comunidad', icon: Icons.groups_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          EducationScreen(),
          ScannerScreen(),
          ScheduleScreen(),
          CommunityScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _tabs
            .asMap()
            .entries
            .map(
              (e) => BottomNavigationBarItem(
                icon: e.key == 1
                    ? _ScannerTabIcon(
                        isSelected: _currentIndex == 1,
                        icon: e.value.icon,
                      )
                    : Icon(e.value.icon),
                activeIcon: e.key == 1
                    ? _ScannerTabIcon(
                        isSelected: true,
                        icon: e.value.icon,
                      )
                    : Icon(e.value.icon),
                label: e.value.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ScannerTabIcon extends StatelessWidget {
  final bool isSelected;
  final IconData icon;

  const _ScannerTabIcon({required this.isSelected, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? cs.primary : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        icon,
        color: isSelected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
        size: 22,
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;

  const _TabItem({required this.label, required this.icon});
}
