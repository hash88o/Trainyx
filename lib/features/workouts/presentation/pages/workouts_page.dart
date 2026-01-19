import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../workouts/workout_state.dart';

/// Workouts Page - Main workout screen with Start Empty Workout, Routines, and Workout in Progress banner
class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  bool _myRoutinesExpanded = true;

  // Mock routines data
  final List<RoutineData> _routines = [
    RoutineData(
      id: '1',
      name: 'Chest Workout',
      exercises: [
        'Incline Bench Press (Dumbbell)',
        'Decline Bench Press (Machine)',
        'Overhead Press (Smith Machine)',
      ],
    ),
  ];

  // Mock workout history
  final List<WorkoutHistoryData> _workouts = [
    WorkoutHistoryData(
      id: '1',
      name: 'Push Day',
      date: DateTime(2026, 1, 19, 9, 0),
      duration: const Duration(minutes: 52),
      exercises: ['Bench Press', 'Incline DB Press', 'Shoulder Press'],
      totalVolume: 12500,
    ),
    WorkoutHistoryData(
      id: '2',
      name: 'Pull Day',
      date: DateTime(2026, 1, 17, 10, 30),
      duration: const Duration(minutes: 58),
      exercises: ['Deadlift', 'Barbell Rows', 'Pull-ups'],
      totalVolume: 15200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final workoutState = Provider.of<WorkoutState>(context);
    final hasActiveWorkout = workoutState.hasActiveWorkout;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Large title
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                pinned: true,
                floating: true,
                leading: const SizedBox.shrink(),
                leadingWidth: 0,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Workout',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.37,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Start Empty Workout button
                      _StartEmptyWorkoutButton(
                        onTap: () => _handleStartWorkout(context, workoutState),
                      ),

                      const SizedBox(height: 24),

                      // Routines section
                      _RoutinesSection(
                        onNewRoutine: () {
                          // TODO: Navigate to new routine
                        },
                        onExplore: () {
                          // TODO: Navigate to explore
                        },
                      ),

                      const SizedBox(height: 24),

                      // My Routines section
                      _MyRoutinesSection(
                        routines: _routines,
                        isExpanded: _myRoutinesExpanded,
                        onToggle: () => setState(() => _myRoutinesExpanded = !_myRoutinesExpanded),
                        onStartRoutine: (routine) {
                          _handleStartWorkout(context, workoutState, routineId: routine.id);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Workout History
                      Text(
                        'Recent Workouts',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Workout history list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final workout = _workouts[index];
                      return _WorkoutHistoryTile(
                        workout: workout,
                        onTap: () => _showWorkoutDetail(context, workout),
                      );
                    },
                    childCount: _workouts.length,
                  ),
                ),
              ),

              // Bottom padding for Workout in Progress banner
              SliverToBoxAdapter(
                child: SizedBox(height: hasActiveWorkout ? 100 : 100),
              ),
            ],
          ),

          // Workout in Progress banner (bottom)
          if (hasActiveWorkout)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _WorkoutInProgressBanner(
                onResume: () => context.go(AppRoutes.activeWorkout),
                onDiscard: () => _showDiscardConfirmation(context, workoutState),
              ),
            ),
        ],
      ),
    );
  }

  void _handleStartWorkout(BuildContext context, WorkoutState workoutState, {String? routineId}) {
    if (workoutState.hasActiveWorkout) {
      _showWorkoutInProgressDialog(context, workoutState);
    } else {
      // Start new workout
      context.go(AppRoutes.activeWorkout);
    }
  }

  void _showWorkoutInProgressDialog(BuildContext context, WorkoutState workoutState) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('You have a workout in progress'),
        content: const Text('If you start a new workout, your old workout will be permanently deleted.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.activeWorkout);
            },
            child: const Text('Resume workout in progress'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              workoutState.discardWorkout();
              context.go(AppRoutes.activeWorkout);
            },
            child: const Text('Start new workout'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDiscardConfirmation(BuildContext context, WorkoutState workoutState) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text('Are you sure you want to discard the workout in progress?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              workoutState.discardWorkout();
              Navigator.pop(context);
            },
            child: const Text('Discard Workout'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetail(BuildContext context, WorkoutHistoryData workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _WorkoutDetailSheet(workout: workout),
    );
  }
}

class _StartEmptyWorkoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StartEmptyWorkoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.add_circled, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Start Empty Workout',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutinesSection extends StatelessWidget {
  final VoidCallback onNewRoutine;
  final VoidCallback onExplore;

  const _RoutinesSection({
    required this.onNewRoutine,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Routines',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {
                // TODO: Add routine
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(CupertinoIcons.add, color: AppColors.primary, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RoutineActionButton(
                icon: CupertinoIcons.doc_text,
                label: 'New Routine',
                onTap: onNewRoutine,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoutineActionButton(
                icon: CupertinoIcons.search,
                label: 'Explore',
                onTap: onExplore,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoutineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoutineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyRoutinesSection extends StatelessWidget {
  final List<RoutineData> routines;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(RoutineData) onStartRoutine;

  const _MyRoutinesSection({
    required this.routines,
    required this.isExpanded,
    required this.onToggle,
    required this.onStartRoutine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Icon(
                isExpanded ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_right,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'My Routines (${routines.length})',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...routines.map((routine) => _RoutineCard(
                routine: routine,
                onStart: () => onStartRoutine(routine),
                onOptions: () {
                  // TODO: Show options
                },
              )),
        ],
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final RoutineData routine;
  final VoidCallback onStart;
  final VoidCallback onOptions;

  const _RoutineCard({
    required this.routine,
    required this.onStart,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  routine.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: onOptions,
                child: Icon(CupertinoIcons.ellipsis, color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            routine.exercises.join(', '),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: onStart,
              child: const Text('Start Routine'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutInProgressBanner extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const _WorkoutInProgressBanner({
    required this.onResume,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.surfaceLighter, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Workout in Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: onResume,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.play_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Resume',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: onDiscard,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.xmark_circle, color: AppColors.error, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Discard',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHistoryTile extends StatelessWidget {
  final WorkoutHistoryData workout;
  final VoidCallback onTap;

  const _WorkoutHistoryTile({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[workout.date.month - 1]} ${workout.date.day}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(CupertinoIcons.sportscourt, color: AppColors.textTertiary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateStr • ${workout.exercises.length} exercises • ${workout.duration.inMinutes} min',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right, color: AppColors.textTertiary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Read-only workout detail sheet
class _WorkoutDetailSheet extends StatelessWidget {
  final WorkoutHistoryData workout;

  const _WorkoutDetailSheet({required this.workout});

  @override
  Widget build(BuildContext context) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              workout.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.lock, size: 12, color: AppColors.textTertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Read Only',
                                    style: TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${months[workout.date.month - 1]} ${workout.date.day}, ${workout.date.year} • ${_formatTime(workout.date)}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: CupertinoIcons.sportscourt,
                      value: '${workout.exercises.length}',
                      label: 'Exercises',
                    ),
                    Container(width: 1, height: 36, color: AppColors.surfaceLighter),
                    _StatItem(
                      icon: CupertinoIcons.repeat,
                      value: '12',
                      label: 'Total Sets',
                    ),
                    Container(width: 1, height: 36, color: AppColors.surfaceLighter),
                    _StatItem(
                      icon: CupertinoIcons.time,
                      value: '${workout.duration.inMinutes}',
                      label: 'Minutes',
                    ),
                    Container(width: 1, height: 36, color: AppColors.surfaceLighter),
                    _StatItem(
                      icon: CupertinoIcons.chart_bar,
                      value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}k',
                      label: 'Volume (kg)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: workout.exercises.map((exercise) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(CupertinoIcons.sportscourt, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exercise,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// Data models
class RoutineData {
  final String id;
  final String name;
  final List<String> exercises;

  RoutineData({
    required this.id,
    required this.name,
    required this.exercises,
  });
}

class WorkoutHistoryData {
  final String id;
  final String name;
  final DateTime date;
  final Duration duration;
  final List<String> exercises;
  final int totalVolume;

  WorkoutHistoryData({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.exercises,
    required this.totalVolume,
  });
}
