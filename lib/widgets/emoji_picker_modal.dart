import 'package:flutter/material.dart';
import '../theme/stitch_theme.dart';

class EmojiCollection {
  static const Map<String, List<String>> categories = {
    'Strategi & Sukses': [
      '🚀', '🎯', '⚡', '💡', '🔥', '🏆', '⭐', '✨', '👑', '🎖️',
      '🥇', '💎', '📈', '🔮', '🌟', '💥', '🏁', '🎉', '💪', '🧠',
    ],
    'Bisnis & Finansial': [
      '💼', '🏢', '📊', '💰', '💵', '💳', '🏦', '🤝', '📈', '📉',
      '🏷️', '📦', '🛒', '📑', '🧾', '🪙', '⚖️', '📋', '📁', '🗂️',
    ],
    'Teknologi & Produk': [
      '💻', '📱', '🌐', '🛡️', '⚙️', '🤖', '🛰️', '🕹️', '📡', '🔋',
      '💾', '🖥️', '⌨️', '🖱️', '🔌', '📡', '🧪', '🧬', '🔬', '🔧',
    ],
    'Komunikasi & Tim': [
      '📢', '📞', '💬', '👥', '🧑‍💻', '👩‍💼', '👨‍💼', '🤝', '📣', '✉️',
      '📬', '📮', '🎙️', '🎥', '💡', '🔔', '🔕', '📌', '📍', '🏷️',
    ],
    'Kreatif & Desain': [
      '🎨', '✍️', '📸', '🎬', '📐', '✏️', '🖌️', '🎭', '🎼', '🧩',
      '🌈', '✨', '💡', '🧵', '🧶', '✒️', '📕', '📖', '📝', '🗒️',
    ],
    'Lifestyle & Pertumbuhan': [
      '🌱', '🌿', '🌲', '☀️', '☕', '🧘', '🏃', '📚', '🎯', '🚲',
      '✈️', '🏖️', '⛰️', '🏕️', '🏡', '⏰', '⏳', '🗓️', '📅', '❤️',
    ],
    'Status & Simbol': [
      '✅', '❌', '⚠️', '🚨', '🛑', '⛔', '🟢', '🔴', '🟡', '🔵',
      '🟣', '🟠', '⚪', '⚫', '🚩', '🏁', '🔄', '🔁', '🔀', '⏳',
    ],
  };

  static List<String> get allEmojis {
    final List<String> all = [];
    for (final list in categories.values) {
      all.addAll(list);
    }
    return all;
  }

  static void showPicker({
    required BuildContext context,
    required String selectedEmoji,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StitchColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _EmojiPickerModal(
          initialEmoji: selectedEmoji,
          onSelected: onSelected,
        );
      },
    );
  }
}

class _EmojiPickerModal extends StatefulWidget {
  final String initialEmoji;
  final ValueChanged<String> onSelected;

  const _EmojiPickerModal({
    required this.initialEmoji,
    required this.onSelected,
  });

  @override
  State<_EmojiPickerModal> createState() => _EmojiPickerModalState();
}

class _EmojiPickerModalState extends State<_EmojiPickerModal> {
  String _activeCategory = EmojiCollection.categories.keys.first;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentList = _searchQuery.isEmpty
        ? (EmojiCollection.categories[_activeCategory] ?? [])
        : EmojiCollection.allEmojis
            .where((e) => true)
            .toList();

    return SafeArea(
      child: Container(
        height: 480,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            Row(
              children: [
                const Icon(Icons.emoji_emotions_rounded, color: StitchColors.tealGlow, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Pilih Ikon Rencana',
                  style: TextStyle(
                    color: StitchColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: StitchColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Kategori Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: EmojiCollection.categories.keys.map((cat) {
                  final isSelected = cat == _activeCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : StitchColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: StitchColors.tealGlow,
                      backgroundColor: StitchColors.darkCard,
                      side: BorderSide(
                        color: isSelected ? StitchColors.tealGlow : StitchColors.darkBorder,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _activeCategory = cat;
                            _searchQuery = '';
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // Grid Emojis
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final emoji = currentList[index];
                  final isCurrent = emoji == widget.initialEmoji;

                  return InkWell(
                    onTap: () {
                      widget.onSelected(emoji);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? StitchColors.tealGlow.withOpacity(0.2)
                            : StitchColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? StitchColors.tealGlow
                              : StitchColors.darkBorder.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
