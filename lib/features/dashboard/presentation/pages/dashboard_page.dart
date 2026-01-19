import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_theme.dart';

/// Trainer Dashboard with calendar, reminders, and client overview
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();
  bool _showCalendar = false;

  // Mock data for reminders
  final Map<DateTime, List<ReminderData>> _reminders = {
    DateTime(2026, 1, 19): [
      ReminderData(title: 'Review John\'s progress', time: '10:00 AM'),
      ReminderData(title: 'Call new client', time: '2:00 PM'),
    ],
    DateTime(2026, 1, 20): [
      ReminderData(title: 'Update Sarah\'s diet plan', time: '11:00 AM'),
    ],
    DateTime(2026, 1, 22): [
      ReminderData(title: 'Monthly assessments', time: '9:00 AM'),
    ],
  };

  // Mock data for today's clients
  final List<TodayClientData> _todayClients = [
    TodayClientData(
      id: '1',
      name: 'John Doe',
      time: '9:00 AM',
      workout: 'Push Day',
      lastWorkout: '2 days ago',
      dietCompliance: 0.85,
      status: ClientStatus.scheduled,
    ),
    TodayClientData(
      id: '2',
      name: 'Sarah Miller',
      time: '10:30 AM',
      workout: 'HIIT Session',
      lastWorkout: 'Yesterday',
      dietCompliance: 0.92,
      status: ClientStatus.inProgress,
    ),
    TodayClientData(
      id: '5',
      name: 'Chris Lee',
      time: '4:00 PM',
      workout: 'Full Body',
      lastWorkout: 'Today',
      dietCompliance: 0.78,
      status: ClientStatus.completed,
    ),
    TodayClientData(
      id: '3',
      name: 'Mike Thompson',
      time: '5:30 PM',
      workout: 'Strength Training',
      lastWorkout: '3 days ago',
      dietCompliance: 0.65,
      status: ClientStatus.scheduled,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final remindersForSelectedDate = _getRemindersForDate(_selectedDate);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.bell),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceLight,
                  child: Text(
                    'TR',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Good ${_getGreeting()}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // Summary (subtle, not “cardy”)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _InsetGroup(
                children: [
                  _InsetRow(
                    leading: const Icon(CupertinoIcons.person_2),
                    title: 'Today’s clients',
                    trailingText: '${_todayClients.length}',
                  ),
                  _InsetDivider(),
                  _InsetRow(
                    leading: const Icon(CupertinoIcons.check_mark_circled),
                    title: 'Completed',
                    trailingText:
                        '${_todayClients.where((c) => c.status == ClientStatus.completed).length}',
                  ),
                  _InsetDivider(),
                  _InsetRow(
                    leading: const Icon(CupertinoIcons.clock),
                    title: 'Upcoming',
                    trailingText:
                        '${_todayClients.where((c) => c.status == ClientStatus.scheduled).length}',
                  ),
                ],
              ),
            ),
          ),

          // This Week (calendar toggle)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: _SectionHeader(
                title: 'This week',
                subtitle: 'Calendar and reminders',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _InsetGroup(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _showCalendar = !_showCalendar),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.calendar),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(_selectedDate),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  remindersForSelectedDate.isEmpty
                                      ? 'No reminders'
                                      : '${remindersForSelectedDate.length} reminder${remindersForSelectedDate.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _showCalendar
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showCalendar) ...[
                    _InsetDivider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: _buildCalendarWidget(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _showAddReminderDialog,
                          child: const Text('Add reminder'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Reminders
          if (remindersForSelectedDate.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _SectionHeader(
                  title: _isSameDay(_selectedDate, DateTime.now())
                      ? 'Today'
                      : _formatDate(_selectedDate),
                  subtitle: 'Reminders',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _InsetGroup(
                  children: [
                    for (int i = 0; i < remindersForSelectedDate.length; i++) ...[
                      _ReminderRow(reminder: remindersForSelectedDate[i]),
                      if (i != remindersForSelectedDate.length - 1) _InsetDivider(),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // Today’s schedule
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionHeader(title: 'Today’s schedule'),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.clients),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              child: _InsetGroup(
                children: [
                  for (int i = 0; i < _todayClients.length; i++) ...[
                    _ScheduleRow(
                      client: _todayClients[i],
                      onTap: () => context.go(AppRoutes.clientDetailPath(_todayClients[i].id)),
                    ),
                    if (i != _todayClients.length - 1) _InsetDivider(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick action: start session
        },
        child: const Icon(CupertinoIcons.play_fill),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  List<ReminderData> _getRemindersForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _reminders[key] ?? [];
  }

  Widget _buildCalendarWidget() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    
    return Column(
        children: [
          // Month Year Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(CupertinoIcons.chevron_left, color: AppColors.textSecondary, size: 20),
                onPressed: () {
                  // TODO: Previous month
                },
              ),
              Text(
                _getMonthYear(_selectedDate),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary, size: 20),
                onPressed: () {
                  // TODO: Next month
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return SizedBox(
                width: 36,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Calendar grid (simplified - showing current week + surrounding)
          ...List.generate(5, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final date = startOfWeek.add(Duration(days: weekIndex * 7 + dayIndex - 7));
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, now);
                  final hasReminder = _getRemindersForDate(date).isNotEmpty;
                  final isCurrentMonth = date.month == now.month;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary 
                            : isToday 
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected 
                                  ? AppColors.background
                                  : isCurrentMonth
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                              fontSize: 14,
                              fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          if (hasReminder && !isSelected)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),

          const SizedBox(height: 12),

        ],
    );
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add Reminder',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDate(_selectedDate),
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder',
                  hintText: 'What do you want to remember?',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setDialogState(() => selectedTime = time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.time, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _formatTime(selectedTime),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Save reminder
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthYear(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (_isSameDay(date, DateTime.now())) {
      return 'Today';
    }
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _InsetGroup extends StatelessWidget {
  final List<Widget> children;
  const _InsetGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLighter, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.surfaceLighter,
    );
  }
}

class _InsetRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String trailingText;

  const _InsetRow({
    required this.leading,
    required this.title,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconTheme(
            data: const IconThemeData(color: AppColors.textTertiary, size: 20),
            child: leading,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            trailingText,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final ReminderData reminder;
  const _ReminderRow({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            reminder.time,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder.title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
          Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final TodayClientData client;
  final VoidCallback onTap;
  const _ScheduleRow({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusText = switch (client.status) {
      ClientStatus.scheduled => 'Scheduled',
      ClientStatus.inProgress => 'In progress',
      ClientStatus.completed => 'Done',
    };

    final statusColor = switch (client.status) {
      ClientStatus.scheduled => AppColors.textSecondary,
      ClientStatus.inProgress => AppColors.primary,
      ClientStatus.completed => AppColors.secondary,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                client.initials,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          client.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${client.time} • ${client.workout}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// Data models
enum ClientStatus { scheduled, inProgress, completed }

class TodayClientData {
  final String id;
  final String name;
  final String time;
  final String workout;
  final String lastWorkout;
  final double dietCompliance;
  final ClientStatus status;

  TodayClientData({
    required this.id,
    required this.name,
    required this.time,
    required this.workout,
    required this.lastWorkout,
    required this.dietCompliance,
    required this.status,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

class ReminderData {
  final String title;
  final String time;

  ReminderData({required this.title, required this.time});
}
