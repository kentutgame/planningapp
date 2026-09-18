import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plan_model.dart';
import '../theme/stitch_theme.dart';

class NodeDetailModal extends StatefulWidget {
  final PlanNode node;
  final bool isRoot;
  final Function(PlanNode updatedNode) onSave;
  final Function(NodeStatus newStatus) onToggleStatus;
  final VoidCallback? onDelete;

  const NodeDetailModal({
    super.key,
    required this.node,
    this.isRoot = false,
    required this.onSave,
    required this.onToggleStatus,
    this.onDelete,
  });

  @override
  State<NodeDetailModal> createState() => _NodeDetailModalState();
}

class _NodeDetailModalState extends State<NodeDetailModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  late String _selectedEmoji;
  late bool _alarmHMinus1;
  late String _alarmHMinus1Time;
  late bool _alarmHariH;
  late String _alarmHariHTime;
  late NodeStatus _status;

  final List<String> _emojis = [
    '🎯', '🚀', '⚡', '📢', '🎁', '🎟️', '💼', '🏢', '📞', '🤝',
    '🌐', '💻', '🏙️', '🏡', '🛡️', '💡', '🔥', '📊', '⭐', '✨'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.node.title);
    _descController = TextEditingController(text: widget.node.description);
    _selectedDate = widget.node.targetDate;
    _selectedEmoji = widget.node.emoji;
    _alarmHMinus1 = widget.node.alarmHMinus1;
    _alarmHMinus1Time = widget.node.alarmHMinus1Time;
    _alarmHariH = widget.node.alarmHariH;
    _alarmHariHTime = widget.node.alarmHariHTime;
    _status = widget.node.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: StitchColors.tealGlow,
              onPrimary: Colors.black,
              surface: StitchColors.darkSurface,
              onSurface: StitchColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showEmojiPicker();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: StitchColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StitchColors.darkBorder),
                    ),
                    child: Text(_selectedEmoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isRoot ? 'Target Utama Project' : 'Detail & Alat Plan',
                        style: const TextStyle(
                          color: StitchColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _titleController.text.isEmpty
                            ? 'Rencana Tanpa Judul'
                            : _titleController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: StitchColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: StitchColors.textMuted),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Judul Field
            const Text(
              'Judul Planning',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: StitchColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Misal: Plan A: Peluncuran Utama',
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Deskripsi Field
            const Text(
              'Deskripsi / Catatan Rencana',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: StitchColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Tuliskan rincian eksekusi atau kriteria rencana...',
              ),
            ),

            const SizedBox(height: 16),

            // Tanggal Target
            const Text(
              'Set Tanggal Pelaksanaan',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: StitchColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StitchColors.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: StitchColors.tealGlow),
                    const SizedBox(width: 12),
                    Text(
                      dateFormat.format(_selectedDate),
                      style: const TextStyle(color: StitchColors.textPrimary, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: StitchColors.textMuted),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Kontrol Status Failover
            if (!widget.isRoot) ...[
              const Text(
                'Status Eksekusi & Kontingensi',
                style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: StitchColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _status == NodeStatus.fallbackGlow
                        ? StitchColors.tealGlow
                        : (_status == NodeStatus.failed
                            ? StitchColors.redFailed.withOpacity(0.5)
                            : StitchColors.darkBorder),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _status == NodeStatus.failed
                              ? Icons.cancel_outlined
                              : (_status == NodeStatus.fallbackGlow
                                  ? Icons.bolt_rounded
                                  : Icons.check_circle_outline),
                          color: _status == NodeStatus.failed
                              ? StitchColors.redFailed
                              : (_status == NodeStatus.fallbackGlow
                                  ? StitchColors.tealGlow
                                  : StitchColors.greenSuccess),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _status == NodeStatus.failed
                                ? 'Rencana Gagal / OFF (Cadangan Otomatis Menyala)'
                                : (_status == NodeStatus.fallbackGlow
                                    ? 'Opsi Cadangan Menyala (Aktif)'
                                    : 'Rencana Berjalan Normal'),
                            style: TextStyle(
                              color: _status == NodeStatus.failed
                                  ? StitchColors.redFailed
                                  : (_status == NodeStatus.fallbackGlow
                                      ? StitchColors.tealGlow
                                      : StitchColors.textPrimary),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _status == NodeStatus.active
                                    ? StitchColors.tealGlow
                                    : StitchColors.darkBorder,
                              ),
                              backgroundColor: _status == NodeStatus.active
                                  ? StitchColors.tealGlowSubtle
                                  : Colors.transparent,
                            ),
                            onPressed: () {
                              setState(() => _status = NodeStatus.active);
                              widget.onToggleStatus(NodeStatus.active);
                            },
                            child: const Text('Aktif', style: TextStyle(color: StitchColors.textPrimary, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _status == NodeStatus.failed
                                    ? StitchColors.redFailed
                                    : StitchColors.darkBorder,
                              ),
                              backgroundColor: _status == NodeStatus.failed
                                  ? StitchColors.redFailedBg
                                  : Colors.transparent,
                            ),
                            onPressed: () {
                              setState(() => _status = NodeStatus.failed);
                              widget.onToggleStatus(NodeStatus.failed);
                            },
                            child: const Text('Gagal (OFF)', style: TextStyle(color: StitchColors.redFailed, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _status == NodeStatus.completed
                                    ? StitchColors.greenSuccess
                                    : StitchColors.darkBorder,
                              ),
                              backgroundColor: _status == NodeStatus.completed
                                  ? StitchColors.greenSuccess.withOpacity(0.15)
                                  : Colors.transparent,
                            ),
                            onPressed: () {
                              setState(() => _status = NodeStatus.completed);
                              widget.onToggleStatus(NodeStatus.completed);
                            },
                            child: const Text('Selesai', style: TextStyle(color: StitchColors.greenSuccess, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Alat Alarm & Pengingat
            const Text(
              'Alat Alarm & Pengingat',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: StitchColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: StitchColors.darkBorder),
              ),
              child: Column(
                children: [
                  // Alarm H-1
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 20, color: StitchColors.tealGlow),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengingat H-1 Plan',
                              style: TextStyle(color: StitchColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Notifikasi 1 hari sebelum hari H (09:00 AM)',
                              style: TextStyle(color: StitchColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _alarmHMinus1,
                        activeColor: StitchColors.tealGlow,
                        onChanged: (val) => setState(() => _alarmHMinus1 = val),
                      ),
                    ],
                  ),
                  const Divider(color: StitchColors.darkBorder, height: 20),
                  // Alarm Hari H
                  Row(
                    children: [
                      const Icon(Icons.alarm_on_rounded, size: 20, color: StitchColors.indigoAccent),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengingat Alarm Hari-H',
                              style: TextStyle(color: StitchColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Alarm aktif pada hari H eksekusi rencana (08:00 AM)',
                              style: TextStyle(color: StitchColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _alarmHariH,
                        activeColor: StitchColors.indigoAccent,
                        onChanged: (val) => setState(() => _alarmHariH = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Simpan & Hapus
            Row(
              children: [
                if (!widget.isRoot && widget.onDelete != null) ...[
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: StitchColors.redFailedBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDelete!();
                    },
                    icon: const Icon(Icons.delete_outline, color: StitchColors.redFailed),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.tealGlow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final updated = widget.node.copyWith(
                        title: _titleController.text.trim().isEmpty
                            ? 'Rencana Baru'
                            : _titleController.text.trim(),
                        description: _descController.text.trim(),
                        emoji: _selectedEmoji,
                        targetDate: _selectedDate,
                        status: _status,
                        alarmHMinus1: _alarmHMinus1,
                        alarmHMinus1Time: _alarmHMinus1Time,
                        alarmHariH: _alarmHariH,
                        alarmHariHTime: _alarmHariHTime,
                      );
                      widget.onSave(updated);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: StitchColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 240,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _emojis.length,
            itemBuilder: (context, index) {
              final emoji = _emojis[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedEmoji = emoji);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
