import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/stitch_theme.dart';
import 'emoji_picker_modal.dart';

class CreatePlanModal extends StatefulWidget {
  final Function({
    required String title,
    required String description,
    required String emoji,
    required DateTime targetDate,
    required String category,
  }) onCreate;

  const CreatePlanModal({super.key, required this.onCreate});

  @override
  State<CreatePlanModal> createState() => _CreatePlanModalState();
}

class _CreatePlanModalState extends State<CreatePlanModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedEmoji = '🚀';
  String _selectedCategory = 'Tech / Go-to-Market';

  final List<String> _categories = [
    'Tech / Go-to-Market',
    'Sales / Enterprise',
    'Operasional',
    'Finansial',
    'Pribadi / Self-Growth',
  ];

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
      setState(() => _selectedDate = picked);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StitchColors.tealGlowSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_task_rounded, color: StitchColors.tealGlow),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buat Proyek Planning Baru',
                        style: TextStyle(
                          color: StitchColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Siapkan strategi utama dan ranting kontingensi cadangan',
                        style: TextStyle(color: StitchColors.textMuted, fontSize: 12),
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

            // Emoji & Title
            const Text(
              'Judul Planning',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: _showEmojiPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: StitchColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StitchColors.darkBorder),
                    ),
                    child: Text(_selectedEmoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(color: StitchColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Misal: Peluncuran Produk Q3 2025',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Kategori
            const Text(
              'Kategori Strategi',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: StitchColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: StitchColors.darkBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: StitchColors.darkSurface,
                  isExpanded: true,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: StitchColors.textPrimary, fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Deskripsi Awal
            const Text(
              'Deskripsi Awal Plan',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: StitchColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Tuliskan deskripsi awal, objektif, atau target rencana...',
              ),
            ),

            const SizedBox(height: 16),

            // Set Tanggal
            const Text(
              'Set Tanggal Pelaksanaan',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
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
                    const Icon(Icons.calendar_month_rounded, size: 18, color: StitchColors.tealGlow),
                    const SizedBox(width: 12),
                    Text(
                      dateFormat.format(_selectedDate),
                      style: const TextStyle(color: StitchColors.textPrimary, fontSize: 14),
                    ),
                    const Spacer(),
                    const Text('Ubah', style: TextStyle(color: StitchColors.tealGlow, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Buat
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchColors.tealGlow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Silakan masukkan judul planning')),
                    );
                    return;
                  }
                  widget.onCreate(
                    title: _titleController.text.trim(),
                    description: _descController.text.trim(),
                    emoji: _selectedEmoji,
                    targetDate: _selectedDate,
                    category: _selectedCategory,
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Buat Plan & Buka Decision Tree',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    EmojiCollection.showPicker(
      context: context,
      selectedEmoji: _selectedEmoji,
      onSelected: (emoji) {
        setState(() => _selectedEmoji = emoji);
      },
    );
  }
}
