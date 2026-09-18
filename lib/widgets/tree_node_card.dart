import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plan_model.dart';
import '../theme/stitch_theme.dart';

class TreeNodeCard extends StatefulWidget {
  final PlanNode node;
  final bool isRoot;
  final VoidCallback onTap;
  final VoidCallback onAddChild;
  final Function(NodeStatus newStatus) onToggleStatus;

  const TreeNodeCard({
    super.key,
    required this.node,
    this.isRoot = false,
    required this.onTap,
    required this.onAddChild,
    required this.onToggleStatus,
  });

  @override
  State<TreeNodeCard> createState() => _TreeNodeCardState();
}

class _TreeNodeCardState extends State<TreeNodeCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isGlow = widget.node.status == NodeStatus.fallbackGlow;
    final isFailed = widget.node.status == NodeStatus.failed;
    final isCompleted = widget.node.status == NodeStatus.completed;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        Border border;
        List<BoxShadow> boxShadow = [];

        if (isGlow) {
          border = Border.all(
            color: StitchColors.tealGlow.withOpacity(_glowAnimation.value),
            width: 2.0,
          );
          boxShadow = [
            BoxShadow(
              color: StitchColors.tealGlow.withOpacity(0.35 * _glowAnimation.value),
              blurRadius: 16 * _glowAnimation.value,
              spreadRadius: 2 * _glowAnimation.value,
            ),
          ];
        } else if (isFailed) {
          border = Border.all(
            color: StitchColors.redFailed.withOpacity(0.6),
            width: 1.5,
          );
        } else if (isCompleted) {
          border = Border.all(
            color: StitchColors.greenSuccess.withOpacity(0.8),
            width: 1.5,
          );
        } else if (widget.isRoot) {
          border = Border.all(
            color: StitchColors.indigoAccent.withOpacity(0.8),
            width: 1.8,
          );
        } else {
          border = Border.all(color: StitchColors.darkBorder, width: 1);
        }

        return Container(
          width: 290,
          decoration: BoxDecoration(
            color: isGlow
                ? Color.lerp(StitchColors.darkCard, const Color(0xFF132F2E), 0.5)
                : (isFailed ? const Color(0xFF26191C) : StitchColors.darkCard),
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: boxShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Badge & Header Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: StitchColors.darkSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: StitchColors.darkBorder),
                          ),
                          child: Text(
                            widget.node.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusPill(isGlow, isFailed, isCompleted),
                        ),
                        // Quick switch failover toggle for child nodes
                        if (!widget.isRoot)
                          Tooltip(
                            message: isFailed ? 'Rencana Gagal' : 'Klik jika Gagal',
                            child: InkWell(
                              onTap: () {
                                if (isFailed) {
                                  widget.onToggleStatus(NodeStatus.active);
                                } else {
                                  widget.onToggleStatus(NodeStatus.failed);
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isFailed ? StitchColors.redFailed : StitchColors.darkSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isFailed ? StitchColors.redFailed : StitchColors.darkBorder,
                                  ),
                                ),
                                child: Text(
                                  isFailed ? 'OFF' : 'ON',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isFailed ? Colors.white : StitchColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.node.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isFailed ? StitchColors.textMuted : StitchColors.textPrimary,
                        decoration: isFailed ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (widget.node.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.node.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: StitchColors.textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),
                    const Divider(color: StitchColors.darkBorder, height: 1),
                    const SizedBox(height: 10),

                    // Date & Alarms
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 4,
                      spacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 11, color: StitchColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(widget.node.targetDate),
                              style: const TextStyle(fontSize: 11, color: StitchColors.textMuted),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.node.alarmHMinus1)
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: StitchColors.tealGlowSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications_active, size: 10, color: StitchColors.tealGlow),
                                    SizedBox(width: 2),
                                    Text(
                                      'H-1',
                                      style: TextStyle(fontSize: 10, color: StitchColors.tealGlow, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.node.alarmHariH)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: StitchColors.indigoAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.alarm, size: 10, color: StitchColors.indigoAccent),
                                    SizedBox(width: 2),
                                    Text(
                                      'Hari-H',
                                      style: TextStyle(fontSize: 10, color: StitchColors.indigoAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Add Sub-Plan Button
                    InkWell(
                      onTap: widget.onAddChild,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: StitchColors.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: StitchColors.darkBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 14,
                              color: isGlow ? StitchColors.tealGlow : StitchColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isRoot ? '+ Tambah Cabang Plan' : '+ Tambah Sub-Plan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isGlow ? StitchColors.tealGlow : StitchColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusPill(bool isGlow, bool isFailed, bool isCompleted) {
    if (isGlow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: StitchColors.tealGlow.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: StitchColors.tealGlow.withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 12, color: StitchColors.tealGlow),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'MENYALA (Cadangan)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: StitchColors.tealGlow,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (isFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: StitchColors.redFailedBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close_rounded, size: 12, color: StitchColors.redFailed),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Gagal (OFF)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: StitchColors.redFailed),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: StitchColors.greenSuccess.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Selesai',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: StitchColors.greenSuccess),
        ),
      );
    }

    if (widget.isRoot) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: StitchColors.indigoAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Target Utama',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: StitchColors.indigoAccent),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Aktif Normal',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: StitchColors.textSecondary),
      ),
    );
  }
}
