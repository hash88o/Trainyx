import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Active Workout Page - Log Workout screen matching the reference design
class ActiveWorkoutPage extends StatefulWidget {
  const ActiveWorkoutPage({super.key});

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  final List<ActiveExerciseData> _exercises = [
    ActiveExerciseData(
      name: 'Treadmill',
      isCardio: true,
      sets: [
        ActiveSetData(
          reps: null,
          weight: null,
          distance: 0.45,
          time: const Duration(minutes: 5),
          isCompleted: true,
        ),
        ActiveSetData(
          reps: null,
          weight: null,
          distance: 0.84,
          time: const Duration(minutes: 10),
          isCompleted: true,
        ),
      ],
      previousBest: '0.45 km in 05:00',
    ),
    ActiveExerciseData(
      name: 'Bench Press',
      isCardio: false,
      sets: [
        ActiveSetData(reps: 12, weight: 60, isWarmup: true, isCompleted: true),
        ActiveSetData(reps: 10, weight: 80, isCompleted: true),
        ActiveSetData(reps: 8, weight: 90, isCompleted: false),
        ActiveSetData(reps: 6, weight: 100, isCompleted: false),
      ],
      previousBest: '100 kg × 6',
    ),
  ];

  Timer? _timer;
  Duration _workoutDuration = const Duration(seconds: 68);
  bool _restTimerEnabled = false;

  @override
  void initState() {
    super.initState();
    _startWorkoutTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWorkoutTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _workoutDuration += const Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSets = _exercises.fold(0, (sum, e) => sum + e.sets.length);
    final completedSets = _exercises.fold(0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
    final totalVolume = _exercises.fold(0.0, (sum, e) => sum + e.totalVolume);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => context.pop(),
          child: Icon(CupertinoIcons.chevron_down, color: AppColors.textPrimary),
        ),
        title: Row(
          children: [
            Text(
              'Log Workout',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(CupertinoIcons.time, color: AppColors.textSecondary, size: 18),
          ],
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: _finishWorkout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Finish',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryStat(
                  label: 'Duration',
                  value: _formatDuration(_workoutDuration),
                  valueColor: AppColors.primary,
                ),
                _SummaryStat(
                  label: 'Volume',
                  value: '${totalVolume.toInt()} kg',
                ),
                _SummaryStat(
                  label: 'Sets',
                  value: '$completedSets',
                ),
                Icon(CupertinoIcons.person_2, color: AppColors.textTertiary, size: 20),
                Icon(CupertinoIcons.person_2_fill, color: AppColors.textTertiary, size: 20),
              ],
            ),
          ),

          // Exercises list
          Expanded(
            child: _exercises.isEmpty
                ? _EmptyWorkoutState(onAddExercise: _showAddExercise)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _exercises.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _exercises.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: CupertinoButton.filled(
                            onPressed: _showAddExercise,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.add, size: 18),
                                const SizedBox(width: 6),
                                const Text('Add Exercise'),
                              ],
                            ),
                          ),
                        );
                      }
                      return _ExerciseCard(
                        exercise: _exercises[index],
                        exerciseIndex: index,
                        restTimerEnabled: _restTimerEnabled,
                        onSetCompleted: (setIndex) {
                          setState(() {
                            final current = _exercises[index].sets[setIndex];
                            _exercises[index].sets[setIndex] =
                                current.copyWith(isCompleted: true);
                          });
                        },
                        onAddSet: () {
                          setState(() {
                            final lastSet = _exercises[index].sets.last;
                            if (_exercises[index].isCardio) {
                              _exercises[index].sets.add(ActiveSetData(
                                distance: lastSet.distance,
                                time: lastSet.time,
                                isCompleted: false,
                              ));
                            } else {
                              _exercises[index].sets.add(ActiveSetData(
                                reps: lastSet.reps,
                                weight: lastSet.weight,
                                isCompleted: false,
                              ));
                            }
                          });
                        },
                        onRemoveSet: (setIndex) {
                          setState(() {
                            _exercises[index].sets.removeAt(setIndex);
                          });
                        },
                        onUpdateSet: (setIndex, data) {
                          setState(() {
                            _exercises[index].sets[setIndex] = data;
                          });
                        },
                        onOptions: () => _showExerciseOptions(context, index),
                        onToggleRestTimer: (enabled) {
                          setState(() => _restTimerEnabled = enabled);
                        },
                      );
                    },
                  ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.surfaceLighter, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {
                      // TODO: Show settings
                    },
                    color: AppColors.surfaceLight,
                    child: const Text('Settings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    onPressed: _showDiscardConfirmation,
                    color: AppColors.surfaceLight,
                    child: Text(
                      'Discard Workout',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  void _showAddExercise() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const _AddExercisePage(),
      ),
    ).then((selectedExercises) {
      if (selectedExercises != null && selectedExercises.isNotEmpty) {
        setState(() {
          for (final exerciseName in selectedExercises) {
            _exercises.add(ActiveExerciseData(
              name: exerciseName,
              isCardio: exerciseName.toLowerCase().contains('treadmill') ||
                  exerciseName.toLowerCase().contains('running'),
              sets: [
                if (exerciseName.toLowerCase().contains('treadmill'))
                  ActiveSetData(distance: 0, time: Duration.zero, isCompleted: false)
                else
                  ActiveSetData(reps: 10, weight: 0, isCompleted: false),
              ],
            ));
          }
        });
      }
    });
  }

  void _showExerciseOptions(BuildContext context, int exerciseIndex) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Reorder exercises
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.arrow_up_arrow_down, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Text('Reorder Exercises'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Replace exercise
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.arrow_2_squarepath, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Text('Replace Exercise'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Add to superset
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Text('Add To Superset'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _exercises.removeAt(exerciseIndex);
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.delete, color: AppColors.error),
                const SizedBox(width: 8),
                Text('Remove Exercise', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDiscardConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text('Are you sure you want to discard the workout in progress?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.pop();
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

  void _finishWorkout() {
    // TODO: Complete workout
    context.pop();
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _EmptyWorkoutState extends StatelessWidget {
  final VoidCallback onAddExercise;

  const _EmptyWorkoutState({required this.onAddExercise});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.sportscourt,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Get started',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an exercise to start your workout',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: onAddExercise,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.add, size: 18),
                  const SizedBox(width: 6),
                  const Text('Add Exercise'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ActiveExerciseData exercise;
  final int exerciseIndex;
  final bool restTimerEnabled;
  final Function(int) onSetCompleted;
  final VoidCallback onAddSet;
  final Function(int) onRemoveSet;
  final Function(int, ActiveSetData) onUpdateSet;
  final VoidCallback onOptions;
  final Function(bool) onToggleRestTimer;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.restTimerEnabled,
    required this.onSetCompleted,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateSet,
    required this.onOptions,
    required this.onToggleRestTimer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.sportscourt,
                  color: AppColors.textTertiary,
                  size: 20,
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
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (exercise.isCardio)
                      Text(
                        'Primary: Cardio',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                  ],
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

          const SizedBox(height: 12),

          // Notes field
          CupertinoTextField(
            placeholder: 'Add notes here...',
            placeholderStyle: TextStyle(color: AppColors.textTertiary),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
          ),

          const SizedBox(height: 12),

          // Rest timer toggle
          Row(
            children: [
              Icon(CupertinoIcons.time, color: AppColors.textTertiary, size: 16),
              const SizedBox(width: 6),
              Text(
                'Rest Timer:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: restTimerEnabled,
                onChanged: onToggleRestTimer,
                activeColor: AppColors.primary,
              ),
              const Spacer(),
              Text(
                restTimerEnabled ? 'ON' : 'OFF',
                style: TextStyle(
                  color: restTimerEnabled ? AppColors.primary : AppColors.textTertiary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sets table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'SET',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'PREVIOUS',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (exercise.isCardio) ...[
                  SizedBox(
                    width: 70,
                    child: Text(
                      'KM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      'TIME',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: 70,
                    child: Text(
                      'KG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      'REPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sets
          ...exercise.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return _SetRow(
              setNumber: index + 1,
              set: set,
              isCardio: exercise.isCardio,
              previousBest: exercise.previousBest,
              onCompleted: () => onSetCompleted(index),
              onUpdate: (data) => onUpdateSet(index, data),
            );
          }),

          const SizedBox(height: 8),

          // Add set button
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: onAddSet,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.add, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Add Set',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setNumber;
  final ActiveSetData set;
  final bool isCardio;
  final String? previousBest;
  final VoidCallback onCompleted;
  final Function(ActiveSetData) onUpdate;

  const _SetRow({
    required this.setNumber,
    required this.set,
    required this.isCardio,
    this.previousBest,
    required this.onCompleted,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? AppColors.primary.withValues(alpha: 0.1)
            : set.isWarmup
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: set.isCompleted
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 40,
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
                    '$setNumber',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),

          // Previous best
          Expanded(
            child: Text(
              previousBest ?? '-',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
            ),
          ),

          // Input fields
          if (isCardio) ...[
            SizedBox(
              width: 70,
              height: 36,
              child: CupertinoTextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                controller: TextEditingController(
                    text: (set.distance ?? 0).toStringAsFixed(2)),
                onChanged: (value) {
                  final distance = double.tryParse(value) ?? set.distance;
                  onUpdate(set.copyWith(distance: distance));
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              height: 36,
              child: CupertinoTextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                controller: TextEditingController(
                    text: _formatTime(set.time ?? Duration.zero)),
                onChanged: (value) {
                  // Parse MM:SS format
                  final parts = value.split(':');
                  if (parts.length == 2) {
                    final minutes = int.tryParse(parts[0]) ?? 0;
                    final seconds = int.tryParse(parts[1]) ?? 0;
                    onUpdate(set.copyWith(time: Duration(minutes: minutes, seconds: seconds)));
                  }
                },
              ),
            ),
          ] else ...[
            SizedBox(
              width: 70,
              height: 36,
              child: CupertinoTextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                controller: TextEditingController(text: set.weight?.toStringAsFixed(0) ?? '0'),
                onChanged: (value) {
                  final weight = double.tryParse(value) ?? set.weight ?? 0;
                  onUpdate(set.copyWith(weight: weight));
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              height: 36,
              child: CupertinoTextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                controller: TextEditingController(text: set.reps?.toString() ?? '0'),
                onChanged: (value) {
                  final reps = int.tryParse(value) ?? set.reps ?? 0;
                  onUpdate(set.copyWith(reps: reps));
                },
              ),
            ),
          ],

          const SizedBox(width: 8),

          // Complete checkbox
          GestureDetector(
            onTap: set.isCompleted ? null : onCompleted,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: set.isCompleted ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: set.isCompleted ? AppColors.primary : AppColors.surfaceLighter,
                ),
              ),
              child: set.isCompleted
                  ? Icon(CupertinoIcons.checkmark, color: AppColors.background, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Add Exercise Page - Matching the reference design
class _AddExercisePage extends StatefulWidget {
  const _AddExercisePage();

  @override
  State<_AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<_AddExercisePage> {
  final _searchController = TextEditingController();
  final Set<String> _selectedExercises = {};
  String _selectedEquipment = 'All Equipment';
  String _selectedMuscle = 'All Muscles';

  final List<String> _recentExercises = [
    'Treadmill',
    'Squat (Bodyweight)',
    'Hack Squat (Machine)',
    'Lunge',
    'Leg Press (Machine)',
    'Lying Leg Curl (Machine)',
    'Leg Extension (Machine)',
  ];

  final List<String> _allExercises = [
    'Treadmill',
    'Squat (Bodyweight)',
    'Hack Squat (Machine)',
    'Lunge',
    'Leg Press (Machine)',
    'Lying Leg Curl (Machine)',
    'Leg Extension (Machine)',
    'Bench Press',
    'Incline Bench Press',
    'Deadlift',
    'Barbell Rows',
    'Pull-ups',
    'Shoulder Press',
    'Lateral Raises',
    'Bicep Curls',
    'Tricep Pushdowns',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _allExercises.where((e) {
      final matchesSearch = _searchController.text.isEmpty ||
          e.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.primary, fontSize: 17),
          ),
        ),
        title: Text(
          'Add Exercise',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: _selectedExercises.isEmpty
                ? null
                : () => Navigator.pop(context, _selectedExercises.toList()),
            child: Text(
              'Create',
              style: TextStyle(
                color: _selectedExercises.isEmpty
                    ? AppColors.textTertiary
                    : AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: 'Search exercise',
              placeholderStyle: TextStyle(color: AppColors.textTertiary),
              style: TextStyle(color: AppColors.textPrimary),
              backgroundColor: AppColors.surface,
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Filter buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    label: _selectedEquipment,
                    onTap: () {
                      // TODO: Show equipment picker
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterButton(
                    label: _selectedMuscle,
                    onTap: () {
                      // TODO: Show muscle picker
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent Exercises section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Exercises',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                final isSelected = _selectedExercises.contains(exercise);
                final isRecent = _recentExercises.contains(exercise);

                return _ExerciseListItem(
                  exercise: exercise,
                  isSelected: isSelected,
                  isRecent: isRecent,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedExercises.remove(exercise);
                      } else {
                        _selectedExercises.add(exercise);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Add X exercises button
          if (_selectedExercises.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.surfaceLighter, width: 0.5),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () => Navigator.pop(context, _selectedExercises.toList()),
                  child: Text('Add ${_selectedExercises.length} exercise${_selectedExercises.length > 1 ? 's' : ''}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              Icon(CupertinoIcons.chevron_down, color: AppColors.textTertiary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final String exercise;
  final bool isSelected;
  final bool isRecent;
  final VoidCallback onTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.isSelected,
    required this.isRecent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.sportscourt,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategory(exercise),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRecent)
                Icon(
                  CupertinoIcons.chart_bar,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategory(String exercise) {
    if (exercise.toLowerCase().contains('treadmill') ||
        exercise.toLowerCase().contains('running')) {
      return 'Cardio';
    }
    if (exercise.toLowerCase().contains('squat') ||
        exercise.toLowerCase().contains('lunge') ||
        exercise.toLowerCase().contains('leg')) {
      return 'Quadriceps';
    }
    if (exercise.toLowerCase().contains('curl')) {
      return 'Hamstrings';
    }
    return 'Chest';
  }
}

// Data models
class ActiveExerciseData {
  final String name;
  final bool isCardio;
  final List<ActiveSetData> sets;
  final String? previousBest;

  ActiveExerciseData({
    required this.name,
    required this.isCardio,
    required this.sets,
    this.previousBest,
  });

  double get totalVolume {
    if (isCardio) return 0;
    return sets.fold(0.0, (sum, s) => sum + ((s.weight ?? 0) * (s.reps ?? 0)));
  }
}

class ActiveSetData {
  final int? reps;
  final double? weight;
  final double? distance;
  final Duration? time;
  final bool isWarmup;
  final bool isCompleted;

  ActiveSetData({
    this.reps,
    this.weight,
    this.distance,
    this.time,
    this.isWarmup = false,
    required this.isCompleted,
  });

  ActiveSetData copyWith({
    int? reps,
    double? weight,
    double? distance,
    Duration? time,
    bool? isWarmup,
    bool? isCompleted,
  }) {
    return ActiveSetData(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      distance: distance ?? this.distance,
      time: time ?? this.time,
      isWarmup: isWarmup ?? this.isWarmup,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
