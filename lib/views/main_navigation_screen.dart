import 'package:flutter/material.dart';
import '../services/planner_service.dart';
import '../theme/stitch_theme.dart';
import 'planning_list_view.dart';
import 'schedule_view.dart';
import 'profile_view.dart';
import 'tree_canvas_view.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PlannerService _plannerService = PlannerService();
  String? _activeCanvasProjectId;

  @override
  void initState() {
    super.initState();
    // Default canvas ke proyek pertama
    if (_plannerService.projects.isNotEmpty) {
      _activeCanvasProjectId = _plannerService.projects.first.id;
    }
  }

  void _openCanvasForProject(String projectId) {
    setState(() {
      _activeCanvasProjectId = projectId;
      _currentIndex = 1; // Tab Canvas
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // Sembunyikan bottom bar jika pengguna sedang di tab Tree Canvas (index 1) dalam posisi miring (landscape)
    final hideBottomBar = isLandscape && _currentIndex == 1;

    // Canvas Project ID fallback
    final activeId = _activeCanvasProjectId ??
        (_plannerService.projects.isNotEmpty ? _plannerService.projects.first.id : '');

    final List<Widget> pages = [
      PlanningListView(onOpenCanvas: _openCanvasForProject),
      activeId.isNotEmpty
          ? TreeCanvasView(
              key: ValueKey(activeId),
              projectId: activeId,
              isEmbeddedInTab: true,
            )
          : const Center(
              child: Text(
                'Belum ada proyek terpilih. Buat atau pilih rencana dari tab Plans.',
                style: TextStyle(color: StitchColors.textMuted),
              ),
            ),
      const ScheduleView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: StitchColors.darkBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: hideBottomBar
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: StitchColors.darkSurface,
                border: Border(
                  top: BorderSide(color: StitchColors.darkBorder, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.folder_copy_outlined, Icons.folder_copy_rounded, 'Plans'),
                    _buildNavItem(1, Icons.account_tree_outlined, Icons.account_tree_rounded, 'Tree Canvas'),
                    _buildNavItem(2, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Schedule'),
                    _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? StitchColors.tealGlowSubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? StitchColors.tealGlow : StitchColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? StitchColors.tealGlow : StitchColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
