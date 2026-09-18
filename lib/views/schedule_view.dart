import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plan_model.dart';
import '../services/planner_service.dart';
import '../theme/stitch_theme.dart';
import 'tree_canvas_view.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final PlannerService _plannerService = PlannerService();
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _plannerService,
      builder: (context, _) {
        final eventsByDate = _plannerService.getEventsByDate();
        final selectedEvents = eventsByDate.entries
            .where((entry) => _isSameDay(entry.key, _selectedDate))
            .expand((entry) => entry.value)
            .toList();

        final monthFormat = DateFormat('MMMM yyyy');
        final agendaDateFormat = DateFormat('EEEE, dd MMMM yyyy');

        return Scaffold(
          backgroundColor: StitchColors.darkBackground,
          appBar: AppBar(
            backgroundColor: StitchColors.darkSurface,
            title: const Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: StitchColors.tealGlow, size: 20),
                SizedBox(width: 8),
                Text(
                  'Kalender Strategi & Jadwal',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.today_rounded, color: StitchColors.tealGlow),
                tooltip: 'Kembali ke Hari Ini',
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _focusedMonth = DateTime(now.year, now.month, 1);
                    _selectedDate = DateTime(now.year, now.month, now.day);
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar Container
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StitchColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StitchColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      // Month & Navigation Header
                      Row(
                        children: [
                          Text(
                            monthFormat.format(_focusedMonth),
                            style: const TextStyle(
                              color: StitchColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, color: StitchColors.textSecondary),
                            onPressed: _previousMonth,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, color: StitchColors.textSecondary),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Day of Week Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((day) {
                          return SizedBox(
                            width: 38,
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  color: StitchColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),

                      // Calendar Grid Days
                      _buildMonthCalendarGrid(eventsByDate),
                    ],
                  ),
                ),

                // Agenda Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_rounded, size: 16, color: StitchColors.tealGlow),
                      const SizedBox(width: 8),
                      Text(
                        'Agenda: ${agendaDateFormat.format(_selectedDate)}',
                        style: const TextStyle(
                          color: StitchColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: StitchColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: StitchColors.darkBorder),
                        ),
                        child: Text(
                          '${selectedEvents.length} Plan',
                          style: const TextStyle(color: StitchColors.tealGlow, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // Agenda Items List
                if (selectedEvents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_available_outlined, size: 40, color: StitchColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 10),
                          const Text(
                            'Tidak ada target rencana pada tanggal ini.',
                            style: TextStyle(color: StitchColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final item = selectedEvents[index];
                      final PlanProject project = item['project'] as PlanProject;
                      final PlanNode node = item['node'] as PlanNode;
                      final isGlow = node.status == NodeStatus.fallbackGlow;
                      final isFailed = node.status == NodeStatus.failed;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: StitchColors.darkCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isGlow
                                ? StitchColors.tealGlow.withOpacity(0.6)
                                : (isFailed ? StitchColors.redFailed.withOpacity(0.4) : StitchColors.darkBorder),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: StitchColors.darkSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(node.emoji, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(
                            node.title,
                            style: TextStyle(
                              color: StitchColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: isFailed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Proyek: ${project.title}',
                                style: const TextStyle(color: StitchColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (isGlow)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: StitchColors.tealGlowSubtle,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '⚡ Opsi Kontingensi Menyala',
                                        style: TextStyle(color: StitchColors.tealGlow, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  else if (isFailed)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: StitchColors.redFailedBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Gagal (OFF)',
                                        style: TextStyle(color: StitchColors.redFailed, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: StitchColors.darkSurface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Aktif',
                                        style: TextStyle(color: StitchColors.textSecondary, fontSize: 10),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (node.alarmHMinus1)
                                    const Text('🔔 H-1', style: TextStyle(color: StitchColors.tealGlow, fontSize: 10, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  if (node.alarmHariH)
                                    const Text('⏰ Hari-H', style: TextStyle(color: StitchColors.indigoAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: StitchColors.tealGlow),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TreeCanvasView(projectId: project.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthCalendarGrid(Map<DateTime, List<Map<String, dynamic>>> eventsByDate) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    // Day of week offset (0 = Sunday in DateTime.weekday % 7)
    final startOffset = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;
    final now = DateTime.now();

    List<Widget> dayCells = [];

    // Empty cells before start of month
    for (int i = 0; i < startOffset; i++) {
      dayCells.add(const SizedBox(width: 38, height: 42));
    }

    // Days of month
    for (int day = 1; day <= totalDays; day++) {
      final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _isSameDay(cellDate, _selectedDate);
      final isToday = _isSameDay(cellDate, now);

      // Check if this day has events
      final dayEvents = eventsByDate.entries
          .where((entry) => _isSameDay(entry.key, cellDate))
          .expand((e) => e.value)
          .toList();

      final hasEvents = dayEvents.isNotEmpty;
      final hasGlowEvent = dayEvents.any((e) {
        final node = e['node'] as PlanNode;
        return node.status == NodeStatus.fallbackGlow;
      });

      dayCells.add(
        InkWell(
          onTap: () {
            setState(() => _selectedDate = cellDate);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? StitchColors.tealGlow
                  : (isToday ? StitchColors.darkSurface : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(color: StitchColors.tealGlow, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.black
                        : (isToday ? StitchColors.tealGlow : StitchColors.textPrimary),
                  ),
                ),
                if (hasEvents) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.black
                          : (hasGlowEvent ? StitchColors.tealGlow : StitchColors.indigoAccent),
                      shape: BoxShape.circle,
                    ),
                  ),
                ] else
                  const SizedBox(height: 7),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      children: dayCells,
    );
  }
}
