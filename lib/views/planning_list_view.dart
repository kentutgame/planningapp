import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/planner_service.dart';
import '../services/profile_service.dart';
import '../theme/stitch_theme.dart';
import '../widgets/create_plan_modal.dart';
import 'tree_canvas_view.dart';

class PlanningListView extends StatefulWidget {
  final Function(String projectId)? onOpenCanvas;

  const PlanningListView({super.key, this.onOpenCanvas});

  @override
  State<PlanningListView> createState() => _PlanningListViewState();
}

class _PlanningListViewState extends State<PlanningListView> {
  final PlannerService _plannerService = PlannerService();
  final ProfileService _profileService = ProfileService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreatePlanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CreatePlanModal(
          onCreate: ({
            required String title,
            required String description,
            required String emoji,
            required DateTime targetDate,
            required String category,
          }) async {
            await _plannerService.addProject(
              title: title,
              description: description,
              emoji: emoji,
              targetDate: targetDate,
              category: category,
            );
            if (!mounted) return;
            final createdProject = _plannerService.projects.first;
            _navigateToCanvas(createdProject.id);
          },
        );
      },
    );
  }

  void _navigateToCanvas(String projectId) {
    if (widget.onOpenCanvas != null) {
      widget.onOpenCanvas!(projectId);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreeCanvasView(projectId: projectId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return ListenableBuilder(
      listenable: Listenable.merge([_plannerService, _profileService]),
      builder: (context, _) {
        final userName = _profileService.profile.name;
        final filteredProjects = _plannerService.projects.where((p) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          backgroundColor: StitchColors.darkBackground,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top Header with Greeting
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: StitchColors.darkCard,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: StitchColors.darkBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: StitchColors.tealGlow),
                              SizedBox(width: 6),
                              Text(
                                'RUANG STRATEGI • AKTIF',
                                style: TextStyle(
                                  color: StitchColors.tealGlow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Salam Header
                        Text(
                          'Hai $userName, rencanakan strategimu hari ini ✨',
                          style: const TextStyle(
                            color: StitchColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Petakan cabang probabilitas, amankan skenario cadangan, dan jalankan rencana secara adaptif.',
                          style: TextStyle(
                            color: StitchColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tombol Buat Plan Baru
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StitchColors.tealGlow,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _openCreatePlanModal,
                            icon: const Icon(Icons.add_rounded, size: 20, color: Colors.black),
                            label: const Text(
                              '+ Buat Plan Baru',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Search Bar
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, size: 18, color: StitchColors.textMuted),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16, color: StitchColors.textMuted),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            hintText: 'Cari skenario, fallback node, atau kata kunci...',
                            filled: true,
                            fillColor: StitchColors.darkCard,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: StitchColors.darkBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: StitchColors.darkBorder),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section Title
                        Row(
                          children: [
                            const Text(
                              'Semua Plan',
                              style: TextStyle(
                                color: StitchColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: StitchColors.darkCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: StitchColors.darkBorder),
                              ),
                              child: Text(
                                '${filteredProjects.length}',
                                style: const TextStyle(
                                  color: StitchColors.tealGlow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Projects List
                if (filteredProjects.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'Tidak ada rencana yang cocok dengan pencarian.',
                          style: TextStyle(color: StitchColors.textMuted),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final project = filteredProjects[index];
                          final hasGlow = project.hasFallbackGlow;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: StitchColors.darkCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: hasGlow
                                    ? StitchColors.tealGlow.withOpacity(0.6)
                                    : StitchColors.darkBorder,
                                width: hasGlow ? 1.5 : 1.0,
                              ),
                              boxShadow: hasGlow
                                  ? [
                                      BoxShadow(
                                        color: StitchColors.tealGlow.withOpacity(0.12),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category & Menu
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: StitchColors.darkSurface,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: StitchColors.darkBorder),
                                        ),
                                        child: Text(
                                          project.category,
                                          style: const TextStyle(
                                            color: StitchColors.textSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz, color: StitchColors.textMuted, size: 20),
                                        color: StitchColors.darkSurface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: const BorderSide(color: StitchColors.darkBorder),
                                        ),
                                        onSelected: (val) {
                                          if (val == 'delete') {
                                            _plannerService.deleteProject(project.id);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, color: StitchColors.redFailed, size: 18),
                                                SizedBox(width: 8),
                                                Text('Hapus Proyek', style: TextStyle(color: StitchColors.redFailed, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Emoji & Title
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(project.emoji, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              project.title,
                                              style: const TextStyle(
                                                color: StitchColors.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (project.description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                project.description,
                                                style: const TextStyle(
                                                  color: StitchColors.textSecondary,
                                                  fontSize: 12,
                                                  height: 1.35,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Status Indicator Pill
                                  if (hasGlow)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: StitchColors.tealGlowSubtle,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: StitchColors.tealGlow.withOpacity(0.3)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.bolt_rounded, size: 14, color: StitchColors.tealGlow),
                                          SizedBox(width: 6),
                                          Text(
                                            'Plan A Gagal → Plan B Menyala (Switch to fallback)',
                                            style: TextStyle(
                                              color: StitchColors.tealGlow,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: StitchColors.darkSurface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline, size: 14, color: StitchColors.greenSuccess),
                                          SizedBox(width: 6),
                                          Text(
                                            'Strategi Berjalan Normal',
                                            style: TextStyle(
                                              color: StitchColors.textSecondary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 14),
                                  const Divider(color: StitchColors.darkBorder, height: 1),
                                  const SizedBox(height: 12),

                                  // Footer Stats & Button Buka Tree Canvas
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    runSpacing: 10,
                                    spacing: 8,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 12, color: StitchColors.textMuted),
                                          const SizedBox(width: 6),
                                          Text(
                                            dateFormat.format(project.targetDate),
                                            style: const TextStyle(color: StitchColors.textMuted, fontSize: 11),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '•  ${project.activeBranchesCount} Cabang (${project.totalNodesCount} Node)',
                                            style: const TextStyle(color: StitchColors.textMuted, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: StitchColors.darkSurface,
                                          foregroundColor: StitchColors.tealGlow,
                                          side: const BorderSide(color: StitchColors.darkBorder),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () => _navigateToCanvas(project.id),
                                        icon: const Icon(Icons.account_tree_outlined, size: 14),
                                        label: const Text(
                                          'Buka Tree Canvas',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredProjects.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
