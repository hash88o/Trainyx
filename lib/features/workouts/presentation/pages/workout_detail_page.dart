import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Workout Detail Page - Read-only view of completed workout
class WorkoutDetailPage extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    // Mock data - would be fetched based on workoutId
    final workout = _getMockWorkout();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Workout Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        workout.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, size: 14, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              'Read Only',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.formattedDate,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        icon: Icons.fitness_center,
                        value: '${workout.exercises.length}',
                        label: 'Exercises',
                      ),
                      _StatDivider(),
                      _StatColumn(
                        icon: Icons.repeat,
                        value: '${workout.totalSets}',
                        label: 'Sets',
                      ),
                      _StatDivider(),
                      _StatColumn(
                        icon: Icons.access_time,
                        value: workout.formattedDuration,
                        label: 'Duration',
                      ),
                      _StatDivider(),
                      _StatColumn(
                        icon: Icons.trending_up,
                        value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}k',
                        label: 'Volume (kg)',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Exercises section
            Text(
              'Exercises',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            // Exercise cards
            ...workout.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _ExerciseDetailCard(
                exerciseNumber: index + 1,
                exercise: exercise,
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  WorkoutDetailData _getMockWorkout() {
    return WorkoutDetailData(
      id: workoutId,
      name: 'Push Day',
      date: DateTime(2026, 1, 19, 9, 0),
      duration: const Duration(minutes: 52),
      exercises: [
        ExerciseDetailData(
          name: 'Bench Press',
          sets: [
            SetDetailData(reps: 12, weight: 60, isWarmup: true),
            SetDetailData(reps: 10, weight: 80),
            SetDetailData(reps: 8, weight: 90),
            SetDetailData(reps: 6, weight: 100),
          ],
        ),
        ExerciseDetailData(
          name: 'Incline Dumbbell Press',
          sets: [
            SetDetailData(reps: 12, weight: 24),
            SetDetailData(reps: 10, weight: 28),
            SetDetailData(reps: 8, weight: 32),
          ],
        ),
        ExerciseDetailData(
          name: 'Shoulder Press',
          sets: [
            SetDetailData(reps: 12, weight: 16),
            SetDetailData(reps: 10, weight: 20),
            SetDetailData(reps: 8, weight: 22),
          ],
        ),
        ExerciseDetailData(
          name: 'Lateral Raises',
          sets: [
            SetDetailData(reps: 15, weight: 8),
            SetDetailData(reps: 15, weight: 10),
            SetDetailData(reps: 12, weight: 10),
          ],
        ),
        ExerciseDetailData(
          name: 'Tricep Pushdowns',
          sets: [
            SetDetailData(reps: 15, weight: 25),
            SetDetailData(reps: 12, weight: 30),
            SetDetailData(reps: 10, weight: 35),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.surfaceLighter,
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final int exerciseNumber;
  final ExerciseDetailData exercise;

  const _ExerciseDetailCard({
    required this.exerciseNumber,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$exerciseNumber',
                    style: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
                      exercise.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${exercise.sets.length} sets • ${exercise.totalReps} total reps',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${exercise.totalVolume.toStringAsFixed(0)} kg',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Sets table
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          'SET',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'REPS',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'WEIGHT',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          'VOLUME',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1, color: AppColors.surfaceLighter),
                
                // Rows
                ...exercise.sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  final volume = (set.reps * set.weight).toInt();
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: set.isWarmup ? AppColors.warning.withValues(alpha: 0.08) : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: set.isWarmup
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'W',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.background,
                                      fontSize: 11,
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
                            '${set.weight.toInt()} kg',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text(
                            '$volume kg',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data models
class WorkoutDetailData {
  final String id;
  final String name;
  final DateTime date;
  final Duration duration;
  final List<ExerciseDetailData> exercises;

  WorkoutDetailData({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.exercises,
  });

  String get formattedDate {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  int get totalVolume => exercises.fold(0, (sum, e) => sum + e.totalVolume.toInt());
}

class ExerciseDetailData {
  final String name;
  final List<SetDetailData> sets;

  ExerciseDetailData({required this.name, required this.sets});

  int get totalReps => sets.fold(0, (sum, s) => sum + s.reps);

  double get totalVolume => sets.fold(0.0, (sum, s) => sum + (s.reps * s.weight));
}

class SetDetailData {
  final int reps;
  final double weight;
  final bool isWarmup;

  SetDetailData({required this.reps, required this.weight, this.isWarmup = false});
}
