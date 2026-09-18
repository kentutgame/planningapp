import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/plan_model.dart';
import '../services/planner_service.dart';
import '../theme/stitch_theme.dart';
import '../widgets/node_detail_modal.dart';
import '../widgets/tree_node_card.dart';

class TreeCanvasView extends StatefulWidget {
  final String projectId;
  final bool initialFullScreen;
  final bool isEmbeddedInTab;

  const TreeCanvasView({
    super.key,
    required this.projectId,
    this.initialFullScreen = false,
    this.isEmbeddedInTab = false,
  });

  @override
  State<TreeCanvasView> createState() => _TreeCanvasViewState();
}

class _TreeCanvasViewState extends State<TreeCanvasView> {
  final TransformationController _transformationController =
      TransformationController();
  final PlannerService _plannerService = PlannerService();
  bool _isManualFullScreen = false;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _isManualFullScreen = widget.initialFullScreen;
    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if ((scale - _currentScale).abs() > 0.05) {
        setState(() => _currentScale = scale);
      }
    });

    // Reset ke tengah saat pertama kali dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetZoom();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    // Kembalikan orientasi layar ke mode bebas saat meninggalkan kanvas
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _toggleLandscapeOrientation(bool currentIsLandscape) {
    if (currentIsLandscape) {
      // Putar kembali ke portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // Putar paksa ke landscape (miring layar penuh)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    matrix.scale(1.25);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    matrix.scale(0.8);
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  PlanProject? _getProject() {
    try {
      return _plannerService.projects.firstWhere((p) => p.id == widget.projectId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // Otomatis Full Screen jika posisi HP miring (landscape) ATAU tombol full screen ditekan
    final isFullScreen = _isManualFullScreen || isLandscape;

    return ListenableBuilder(
      listenable: _plannerService,
      builder: (context, _) {
        final project = _getProject();
        if (project == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Proyek Tidak Ditemukan')),
            body: const Center(
              child: Text('Proyek telah dihapus atau tidak tersedia'),
            ),
          );
        }

        final dateFormat = DateFormat('dd MMMM yyyy');

        return Scaffold(
          backgroundColor: StitchColors.darkBackground,
          appBar: isFullScreen
              ? null
              : AppBar(
                  backgroundColor: StitchColors.darkSurface,
                  leading: widget.isEmbeddedInTab
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.account_tree_rounded,
                            color: StitchColors.tealGlow,
                            size: 22,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(project.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Target: ${dateFormat.format(project.targetDate)} • ${project.category}',
                        style: const TextStyle(fontSize: 11, color: StitchColors.textMuted),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Mode Landscape (Layar Penuh)',
                      icon: const Icon(Icons.screen_rotation_rounded, color: StitchColors.tealGlow),
                      onPressed: () => _toggleLandscapeOrientation(isLandscape),
                    ),
                    IconButton(
                      tooltip: 'Layar Penuh (Full Screen)',
                      icon: const Icon(Icons.fullscreen_rounded, color: StitchColors.textPrimary),
                      onPressed: () => setState(() => _isManualFullScreen = true),
                    ),
                  ],
                ),
          body: Stack(
            children: [
              // Grid background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridBackgroundPainter(),
                ),
              ),

              // Interactive Canvas with Zoom In/Out & Pan
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.25,
                maxScale: 2.5,
                boundaryMargin: const EdgeInsets.all(2000),
                constrained: false,
                child: Padding(
                  padding: const EdgeInsets.all(200),
                  child: _buildTreeLayout(project),
                ),
              ),

              // Full Screen Floating Header (Hanya muncul saat manual full screen portrait)
              // Saat mode Landscape, layar 100% murni penuh tanpa bilah atas/bawah!
              if (isFullScreen && !isLandscape)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: StitchColors.darkSurface.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: StitchColors.darkBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.fullscreen_exit_rounded, color: StitchColors.tealGlow),
                          tooltip: 'Keluar Layar Penuh',
                          onPressed: () => setState(() => _isManualFullScreen = false),
                        ),
                        const SizedBox(width: 4),
                        Text(project.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                project.title,
                                style: const TextStyle(
                                  color: StitchColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                'Pohon Keputusan & Kontingensi (Decision Forest)',
                                style: TextStyle(color: StitchColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: project.hasFallbackGlow
                                ? StitchColors.tealGlowSubtle
                                : StitchColors.darkCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: project.hasFallbackGlow
                                  ? StitchColors.tealGlow
                                  : StitchColors.darkBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                project.hasFallbackGlow
                                    ? Icons.bolt_rounded
                                    : Icons.account_tree_outlined,
                                size: 14,
                                color: project.hasFallbackGlow
                                    ? StitchColors.tealGlow
                                    : StitchColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                project.hasFallbackGlow
                                    ? 'Plan B Menyala'
                                    : 'Normal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: project.hasFallbackGlow
                                      ? StitchColors.tealGlow
                                      : StitchColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Jika Landscape: Berikan tombol kecil transparan di pojok kiri atas untuk info/keluar
              if (isLandscape)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(project.emoji, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Text(
                          project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Floating Zoom Controls & Helper Dock
              Positioned(
                bottom: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: StitchColors.darkSurface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StitchColors.darkBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Zoom In',
                        icon: const Icon(Icons.add, color: StitchColors.textPrimary, size: 20),
                        onPressed: _zoomIn,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${(_currentScale * 100).toInt()}%',
                          style: const TextStyle(
                            color: StitchColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Zoom Out',
                        icon: const Icon(Icons.remove, color: StitchColors.textPrimary, size: 20),
                        onPressed: _zoomOut,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 1,
                        height: 24,
                        color: StitchColors.darkBorder,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Reset Kanvas',
                        icon: const Icon(Icons.center_focus_strong_rounded, color: StitchColors.tealGlow, size: 20),
                        onPressed: _resetZoom,
                      ),
                      IconButton(
                        tooltip: isLandscape ? 'Kembali ke Tegak (Portrait)' : 'Miringkan Layar (Landscape)',
                        icon: Icon(
                          isLandscape ? Icons.stay_current_portrait_rounded : Icons.screen_rotation_rounded,
                          color: isLandscape ? StitchColors.tealGlow : StitchColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => _toggleLandscapeOrientation(isLandscape),
                      ),
                      if (!isFullScreen)
                        IconButton(
                          tooltip: 'Layar Penuh',
                          icon: const Icon(Icons.fullscreen_rounded, color: StitchColors.indigoAccent, size: 20),
                          onPressed: () => setState(() => _isManualFullScreen = true),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreeLayout(PlanProject project) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Root Node Card
        TreeNodeCard(
          node: project.rootNode,
          isRoot: true,
          onTap: () => _openNodeEditor(project.rootNode, isRoot: true),
          onAddChild: () => _showAddBranchDialog(project.rootNode.id),
          onToggleStatus: (newStatus) {
            _plannerService.toggleNodeStatus(project.id, project.rootNode.id, newStatus);
          },
        ),

        // If root has children (branches)
        if (project.rootNode.children.isNotEmpty) ...[
          // Connector line vertical down from root
          Container(
            width: 2,
            height: 48,
            color: StitchColors.indigoAccent.withOpacity(0.6),
          ),

          // Horizontal branch connector and parallel branches
          _buildChildrenRow(project, project.rootNode.children),
        ],
      ],
    );
  }

  double _getSubtreeWidth(PlanNode node) {
    if (node.children.isEmpty) {
      return 330.0;
    }
    double total = 0.0;
    for (final child in node.children) {
      total += _getSubtreeWidth(child);
    }
    return math.max(330.0, total);
  }

  Widget _buildChildrenRow(PlanProject project, List<PlanNode> nodes) {
    final List<double> childWidths = nodes.map((n) => _getSubtreeWidth(n)).toList();
    final double totalRowWidth = childWidths.fold(0.0, (sum, w) => sum + w);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Horizontal bar spanning over children
        CustomPaint(
          size: Size(totalRowWidth, 30),
          painter: _TreeBranchConnectorPainter(
            childWidths: childWidths,
          ),
        ),

        // Row of Child Branches with dynamic subtree widths
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(nodes.length, (index) {
            final childNode = nodes[index];
            final w = childWidths[index];
            return SizedBox(
              width: w,
              child: _buildSubTree(project, childNode),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSubTree(PlanProject project, PlanNode node) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Node Card
        TreeNodeCard(
          node: node,
          isRoot: false,
          onTap: () => _openNodeEditor(node, isRoot: false),
          onAddChild: () => _showAddBranchDialog(node.id),
          onToggleStatus: (newStatus) {
            _plannerService.toggleNodeStatus(project.id, node.id, newStatus);
          },
        ),

        // If this node has further children (infinite recursive cascading!)
        if (node.children.isNotEmpty) ...[
          Container(
            width: 2,
            height: 36,
            color: node.status == NodeStatus.fallbackGlow
                ? StitchColors.tealGlow
                : StitchColors.darkBorderActive,
          ),
          _buildChildrenRow(project, node.children),
        ],
      ],
    );
  }

  void _openNodeEditor(PlanNode node, {required bool isRoot}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NodeDetailModal(
          node: node,
          isRoot: isRoot,
          onSave: (updated) {
            _plannerService.updateNode(widget.projectId, updated);
          },
          onToggleStatus: (newStatus) {
            _plannerService.toggleNodeStatus(widget.projectId, node.id, newStatus);
          },
          onDelete: isRoot
              ? null
              : () {
                  _plannerService.deleteNode(widget.projectId, node.id);
                },
        );
      },
    );
  }

  void _showAddBranchDialog(String parentNodeId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedEmoji = '⚡';
    DateTime targetDate = DateTime.now().add(const Duration(days: 5));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dateFormat = DateFormat('dd MMM yyyy');

            return AlertDialog(
              backgroundColor: StitchColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: StitchColors.darkBorder),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add_road_rounded, color: StitchColors.tealGlow, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Tambah Ranting / Sub-Plan',
                    style: TextStyle(color: StitchColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Judul Cabang / Sub-Plan', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: StitchColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Misal: Plan B: Program Diskon Viral',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Deskripsi Singkat', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Catatan opsi atau kriteria pelaksanaan...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tanggal Rencana', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => targetDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: StitchColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: StitchColors.darkBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: StitchColors.tealGlow),
                            const SizedBox(width: 8),
                            Text(
                              dateFormat.format(targetDate),
                              style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: StitchColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchColors.tealGlow,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    _plannerService.addChildNode(
                      projectId: widget.projectId,
                      parentNodeId: parentNodeId,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      emoji: selectedEmoji,
                      targetDate: targetDate,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Tambahkan Cabang', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Custom Painter untuk Garis Penghubung Cabang Pohon
class _TreeBranchConnectorPainter extends CustomPainter {
  final List<double> childWidths;

  _TreeBranchConnectorPainter({
    required this.childWidths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (childWidths.isEmpty) return;

    final paint = Paint()
      ..color = StitchColors.darkBorderActive
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;

    if (childWidths.length == 1) {
      // Garis lurus ke bawah jika hanya 1 anak
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, size.height),
        paint,
      );
      return;
    }

    // Hitung posisi horizontal tengah untuk tiap cabang anak secara presisi
    final List<double> childCenters = [];
    double currentLeft = 0;
    for (final w in childWidths) {
      childCenters.add(currentLeft + (w / 2));
      currentLeft += w;
    }

    final firstChildX = childCenters.first;
    final lastChildX = childCenters.last;

    // Garis horizontal utama
    canvas.drawLine(
      Offset(firstChildX, 10),
      Offset(lastChildX, 10),
      paint,
    );

    // Garis dari parent ke baris horizontal
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, 10),
      paint,
    );

    // Garis vertikal ke masing-masing cabang anak
    for (final childX in childCenters) {
      canvas.drawLine(
        Offset(childX, 10),
        Offset(childX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreeBranchConnectorPainter oldDelegate) {
    return oldDelegate.childWidths != childWidths;
  }
}

// Grid dots background ala Notion / Stitch Canvas
class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF20232B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
