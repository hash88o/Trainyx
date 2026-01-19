import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Client Detail Page - iOS HIG style with segmented control
class ClientDetailPage extends StatefulWidget {
  final String clientId;

  const ClientDetailPage({super.key, required this.clientId});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  int _selectedSegment = 0; // 0=Overview, 1=Workouts, 2=Diet, 3=Progress

  @override
  Widget build(BuildContext context) {
    // Important: Avoid nesting scrollables inside slivers on web.
    // This structure follows a stable pattern: header + segmented control + Expanded(IndexedStack)
    // where each segment owns its own scrolling.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minSize: 0,
                    onPressed: () => context.pop(),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.chevron_left, color: AppColors.primary, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Clients',
                          style: TextStyle(color: AppColors.primary, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minSize: 0,
                    onPressed: () {},
                    child: Text(
                      'Edit',
                      style: TextStyle(color: AppColors.primary, fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'JD',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Goal: Build Muscle',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                onValueChanged: (value) {
                  if (value != null) setState(() => _selectedSegment = value);
                },
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Overview', style: TextStyle(fontSize: 13)),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Workouts', style: TextStyle(fontSize: 13)),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Diet', style: TextStyle(fontSize: 13)),
                  ),
                  3: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Progress', style: TextStyle(fontSize: 13)),
                  ),
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(
                index: _selectedSegment,
                children: [
                  _OverviewTab(clientId: widget.clientId),
                  _WorkoutsTab(clientId: widget.clientId),
                  _DietTab(clientId: widget.clientId),
                  _ProgressTab(clientId: widget.clientId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overview Tab with workout heatmap calendar
class _OverviewTab extends StatelessWidget {
  final String clientId;

  const _OverviewTab({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          _buildQuickStats(),
          
          const SizedBox(height: 20),
          
          // Workout Heatmap Calendar
          _buildWorkoutHeatmap(),
          
          const SizedBox(height: 20),
          
          // Upcoming Schedule
          _buildUpcomingSchedule(),
          
          const SizedBox(height: 20),
          
          // Notes
          _buildNotes(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return _GroupedSection(
      children: [
        _StatRow(
          icon: CupertinoIcons.sportscourt,
          title: 'Workouts This Month',
          value: '24',
        ),
        _DividerTile(),
        _StatRow(
          icon: CupertinoIcons.flame,
          title: 'Attendance Rate',
          value: '87%',
        ),
        _DividerTile(),
        _StatRow(
          icon: CupertinoIcons.chart_bar,
          title: 'PR\'s This Month',
          value: '12',
        ),
      ],
    );
  }

  Widget _buildWorkoutHeatmap() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Activity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last 6 months',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Heatmap Grid
          _WorkoutHeatmapGrid(),
          
          const SizedBox(height: 12),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
              const SizedBox(width: 6),
              ...List.generate(5, (index) {
                final opacity = index * 0.25;
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index == 0 
                        ? AppColors.surfaceLight
                        : AppColors.primary.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text(
                'More',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Sessions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ScheduleItem(
            day: 'Today',
            time: '9:00 AM',
            workout: 'Push Day',
            isNext: true,
          ),
          _ScheduleItem(
            day: 'Wednesday',
            time: '9:00 AM',
            workout: 'Pull Day',
          ),
          _ScheduleItem(
            day: 'Friday',
            time: '9:00 AM',
            workout: 'Leg Day',
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trainer Notes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.add, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Jan 18, 2026',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Client mentioned shoulder discomfort during overhead press. Recommend lighter weights and focus on form for the next two weeks.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedSection extends StatelessWidget {
  final List<Widget> children;

  const _GroupedSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 48),
      height: 0.5,
      color: AppColors.surfaceLighter,
    );
  }
}

class _WorkoutHeatmapGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final random = math.Random(42); // Fixed seed for consistent mock data
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 4),
          child: Row(
            children: _getMonthLabels(now).map((month) {
              return Expanded(
                child: Text(
                  month,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // Day labels + heatmap
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            Column(
              children: ['', 'M', '', 'W', '', 'F', ''].map((day) {
                return SizedBox(
                  height: 14,
                  child: Text(
                    day,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 9,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 4),
            
            // Heatmap cells
            Expanded(
              child: SizedBox(
                height: 98,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                  ),
                  itemCount: 26 * 7, // ~6 months of weeks
                  itemBuilder: (context, index) {
                    final intensity = random.nextDouble();
                    final hasWorkout = intensity > 0.4;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: hasWorkout
                            ? AppColors.primary.withValues(alpha: intensity * 0.8 + 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<String> _getMonthLabels(DateTime now) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final result = <String>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      result.add(months[date.month - 1]);
    }
    return result;
  }
}

class _ScheduleItem extends StatelessWidget {
  final String day;
  final String time;
  final String workout;
  final bool isNext;

  const _ScheduleItem({
    required this.day,
    required this.time,
    required this.workout,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNext ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: isNext ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNext ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today,
              color: isNext ? AppColors.background : AppColors.textTertiary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: isNext ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$time • $workout',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'NEXT',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Workouts Tab
class _WorkoutsTab extends StatelessWidget {
  final String clientId;

  const _WorkoutsTab({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _WorkoutHistoryCard(
          date: DateTime.now().subtract(Duration(days: index * 2)),
          name: index % 3 == 0 ? 'Push Day' : index % 3 == 1 ? 'Pull Day' : 'Leg Day',
          exercises: 6 + (index % 3),
          duration: Duration(minutes: 45 + index * 5),
          onTap: () {
            // Navigate to workout detail (read-only)
            _showWorkoutDetail(context, 'workout_$index');
          },
        );
      },
    );
  }

  void _showWorkoutDetail(BuildContext context, String workoutId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _WorkoutDetailSheet(workoutId: workoutId),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final DateTime date;
  final String name;
  final int exercises;
  final Duration duration;
  final VoidCallback onTap;

  const _WorkoutHistoryCard({
    required this.date,
    required this.name,
    required this.exercises,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    months[date.month - 1],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.fitness_center, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '$exercises exercises',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${duration.inMinutes} min',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Workout Detail Sheet (Read-only)
class _WorkoutDetailSheet extends StatelessWidget {
  final String workoutId;

  const _WorkoutDetailSheet({required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Day',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'January 19, 2026 • 9:00 AM',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '52 min',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Exercises list (read-only)
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _ExerciseDetailCard(
                    name: 'Bench Press',
                    sets: [
                      SetData(reps: 12, weight: 60, isWarmup: true),
                      SetData(reps: 10, weight: 80),
                      SetData(reps: 8, weight: 90),
                      SetData(reps: 6, weight: 100),
                    ],
                  ),
                  _ExerciseDetailCard(
                    name: 'Incline Dumbbell Press',
                    sets: [
                      SetData(reps: 12, weight: 24),
                      SetData(reps: 10, weight: 28),
                      SetData(reps: 8, weight: 32),
                    ],
                  ),
                  _ExerciseDetailCard(
                    name: 'Shoulder Press',
                    sets: [
                      SetData(reps: 12, weight: 16),
                      SetData(reps: 10, weight: 20),
                      SetData(reps: 8, weight: 22),
                    ],
                  ),
                  _ExerciseDetailCard(
                    name: 'Lateral Raises',
                    sets: [
                      SetData(reps: 15, weight: 8),
                      SetData(reps: 15, weight: 10),
                      SetData(reps: 12, weight: 10),
                    ],
                  ),
                  _ExerciseDetailCard(
                    name: 'Tricep Pushdowns',
                    sets: [
                      SetData(reps: 15, weight: 25),
                      SetData(reps: 12, weight: 30),
                      SetData(reps: 10, weight: 35),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final String name;
  final List<SetData> sets;

  const _ExerciseDetailCard({
    required this.name,
    required this.sets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fitness_center, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Sets table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'SET',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'REPS',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WEIGHT',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Sets
          ...sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: set.isWarmup 
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: set.isWarmup
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'W',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.background,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Text(
                      '${set.reps}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${set.weight} kg',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SetData {
  final int reps;
  final double weight;
  final bool isWarmup;

  SetData({required this.reps, required this.weight, this.isWarmup = false});
}

/// Diet Tab with Plan and Today sub-tabs
class _DietTab extends StatefulWidget {
  final String clientId;

  const _DietTab({required this.clientId});

  @override
  State<_DietTab> createState() => _DietTabState();
}

class _DietTabState extends State<_DietTab> with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _subTabController,
            indicator: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.background,
            unselectedLabelColor: AppColors.textSecondary,
            padding: const EdgeInsets.all(3),
            tabs: const [
              Tab(text: 'Plan'),
              Tab(text: 'Today'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _DietPlanView(clientId: widget.clientId),
              _TodayDietView(clientId: widget.clientId),
            ],
          ),
        ),
      ],
    );
  }
}

/// Diet Plan View - Recommended diet by trainer
class _DietPlanView extends StatelessWidget {
  final String clientId;

  const _DietPlanView({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Daily targets
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.2),
                AppColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Targets',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroTarget(label: 'Calories', value: '2,400', unit: 'kcal'),
                  _MacroTarget(label: 'Protein', value: '180', unit: 'g'),
                  _MacroTarget(label: 'Carbs', value: '280', unit: 'g'),
                  _MacroTarget(label: 'Fat', value: '70', unit: 'g'),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Meal sections
        _MealSection(
          title: 'Breakfast',
          time: '7:00 AM',
          items: ['4 egg whites + 2 whole eggs', 'Oatmeal with banana', 'Black coffee'],
          calories: 450,
        ),
        _MealSection(
          title: 'Pre-Lunch Snack',
          time: '10:00 AM',
          items: ['Greek yogurt', 'Handful of almonds'],
          calories: 200,
        ),
        _MealSection(
          title: 'Lunch',
          time: '1:00 PM',
          items: ['Grilled chicken breast 200g', 'Brown rice 150g', 'Mixed vegetables'],
          calories: 550,
        ),
        _MealSection(
          title: 'Post-Lunch Snack',
          time: '4:00 PM',
          items: ['Protein shake', 'Apple'],
          calories: 180,
        ),
        _MealSection(
          title: 'Pre-Workout',
          time: '5:30 PM',
          items: ['Banana', 'Rice cakes with peanut butter'],
          calories: 220,
        ),
        _MealSection(
          title: 'Post-Workout',
          time: '7:30 PM',
          items: ['Whey protein shake', 'Fast-acting carbs (dextrose)'],
          calories: 200,
        ),
        _MealSection(
          title: 'Dinner',
          time: '8:30 PM',
          items: ['Salmon 180g', 'Sweet potato', 'Steamed broccoli'],
          calories: 480,
        ),
        _MealSection(
          title: 'Supplements',
          time: 'Daily',
          items: ['Whey protein 2 scoops', 'Creatine 5g', 'Fish oil 2 capsules', 'Multivitamin'],
          isSupplements: true,
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MacroTarget extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroTarget({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  final String title;
  final String time;
  final List<String> items;
  final int? calories;
  final bool isSupplements;

  const _MealSection({
    required this.title,
    required this.time,
    required this.items,
    this.calories,
    this.isSupplements = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSupplements 
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSupplements ? Icons.medication : Icons.restaurant,
                      color: isSupplements ? AppColors.accent : AppColors.secondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (calories != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$calories kcal',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Today's Diet View - What client actually ate
class _TodayDietView extends StatelessWidget {
  final String clientId;

  const _TodayDietView({required this.clientId});

  @override
  Widget build(BuildContext context) {
    // Mock data for macros
    const consumed = {'calories': 1850, 'protein': 142, 'carbs': 210, 'fat': 58};
    const targets = {'calories': 2400, 'protein': 180, 'carbs': 280, 'fat': 70};

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Macro Progress Bars
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'vs Recommended',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MacroProgressBar(
                label: 'Calories',
                current: consumed['calories']!,
                target: targets['calories']!,
                unit: 'kcal',
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _MacroProgressBar(
                label: 'Protein',
                current: consumed['protein']!,
                target: targets['protein']!,
                unit: 'g',
                color: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              _MacroProgressBar(
                label: 'Carbs',
                current: consumed['carbs']!,
                target: targets['carbs']!,
                unit: 'g',
                color: AppColors.accent,
              ),
              const SizedBox(height: 12),
              _MacroProgressBar(
                label: 'Fat',
                current: consumed['fat']!,
                target: targets['fat']!,
                unit: 'g',
                color: AppColors.warning,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Add food button
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Add food logging
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Log Food'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        const SizedBox(height: 16),

        // Today's logged meals
        Text(
          'Logged Today',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        _LoggedMealCard(
          time: '7:30 AM',
          name: 'Breakfast',
          items: ['Scrambled eggs (3)', 'Toast with butter', 'Orange juice'],
          calories: 520,
          protein: 28,
        ),
        _LoggedMealCard(
          time: '10:15 AM',
          name: 'Snack',
          items: ['Protein bar'],
          calories: 210,
          protein: 20,
        ),
        _LoggedMealCard(
          time: '1:00 PM',
          name: 'Lunch',
          items: ['Chicken wrap', 'Side salad'],
          calories: 680,
          protein: 45,
        ),
        _LoggedMealCard(
          time: '4:30 PM',
          name: 'Pre-Workout',
          items: ['Banana', 'Pre-workout shake'],
          calories: 240,
          protein: 15,
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final String unit;
  final Color color;

  const _MacroProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / target;
    final isOver = progress > 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            Row(
              children: [
                Text(
                  '$current',
                  style: TextStyle(
                    color: isOver ? AppColors.error : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' / $target $unit',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
                if (isOver) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.warning, size: 14, color: AppColors.error),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isOver ? AppColors.error : color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Target marker
            Positioned(
              left: MediaQuery.of(context).size.width * 0.88 - 32, // Approximate position at 100%
              child: Container(
                width: 2,
                height: 8,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoggedMealCard extends StatelessWidget {
  final String time;
  final String name;
  final List<String> items;
  final int calories;
  final int protein;

  const _LoggedMealCard({
    required this.time,
    required this.name,
    required this.items,
    required this.calories,
    required this.protein,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  items.join(', '),
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$calories kcal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${protein}g protein',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Progress Tab with heatmap and dated photos
class _ProgressTab extends StatelessWidget {
  final String clientId;

  const _ProgressTab({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Workout Heatmap (same as overview)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workout Consistency',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _WorkoutHeatmapGrid(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Less', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  const SizedBox(width: 6),
                  ...List.generate(5, (index) {
                    final opacity = index * 0.25;
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index == 0 
                            ? AppColors.surfaceLight
                            : AppColors.primary.withValues(alpha: opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                  const SizedBox(width: 6),
                  Text('More', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Progress Photos - Date wise
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress Photos',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Add photo upload
              },
              icon: Icon(Icons.add_a_photo, size: 18, color: AppColors.primary),
              label: Text(
                'Add Photo',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Photo timeline
        _PhotoTimelineSection(
          month: 'January 2026',
          photos: [
            PhotoData(date: 'Jan 15', hasPhoto: true),
            PhotoData(date: 'Jan 10', hasPhoto: true),
            PhotoData(date: 'Jan 1', hasPhoto: true),
          ],
        ),
        _PhotoTimelineSection(
          month: 'December 2025',
          photos: [
            PhotoData(date: 'Dec 20', hasPhoto: true),
            PhotoData(date: 'Dec 1', hasPhoto: true),
          ],
        ),
        _PhotoTimelineSection(
          month: 'November 2025',
          photos: [
            PhotoData(date: 'Nov 15', hasPhoto: true),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _PhotoTimelineSection extends StatelessWidget {
  final String month;
  final List<PhotoData> photos;

  const _PhotoTimelineSection({required this.month, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                month,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () {
                    // TODO: Show full photo
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceLighter),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: AppColors.textTertiary,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          photo.date,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoData {
  final String date;
  final bool hasPhoto;

  PhotoData({required this.date, required this.hasPhoto});
}
