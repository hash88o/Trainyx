import '../../../../core/utils/result.dart';
import '../entities/workout.dart';

/// Parameters for starting a new workout
class StartWorkoutParams {
  final String? templateId;
  final String? clientId; // For trainer logging client's workout
  final String? name;

  const StartWorkoutParams({
    this.templateId,
    this.clientId,
    this.name,
  });
}

/// Parameters for logging a set
class LogSetParams {
  final String exerciseLogId;
  final SetType type;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? rpe;

  const LogSetParams({
    required this.exerciseLogId,
    this.type = SetType.normal,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
  });
}

/// Parameters for adding an exercise to a workout
class AddExerciseParams {
  final String workoutId;
  final String exerciseId;
  final int? targetSets;
  final String? targetReps;
  final double? targetWeight;
  final int? supersetGroup;

  const AddExerciseParams({
    required this.workoutId,
    required this.exerciseId,
    this.targetSets,
    this.targetReps,
    this.targetWeight,
    this.supersetGroup,
  });
}

/// Filter options for workout history
class WorkoutFilter {
  final String? userId;
  final String? clientId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? templateId;
  final bool? hasNotes;
  final int? minDurationMinutes;
  final int? maxDurationMinutes;

  const WorkoutFilter({
    this.userId,
    this.clientId,
    this.fromDate,
    this.toDate,
    this.templateId,
    this.hasNotes,
    this.minDurationMinutes,
    this.maxDurationMinutes,
  });

  /// Creates a filter for this week's workouts
  factory WorkoutFilter.thisWeek({String? clientId}) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return WorkoutFilter(
      clientId: clientId,
      fromDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      toDate: now,
    );
  }

  /// Creates a filter for this month's workouts
  factory WorkoutFilter.thisMonth({String? clientId}) {
    final now = DateTime.now();
    return WorkoutFilter(
      clientId: clientId,
      fromDate: DateTime(now.year, now.month, 1),
      toDate: now,
    );
  }
}

/// Repository interface for workout operations
abstract interface class WorkoutRepository {
  // --- Active Workout Operations ---

  /// Gets the currently active workout (if any)
  Future<Result<Workout?>> getActiveWorkout();

  /// Starts a new workout
  Future<Result<Workout>> startWorkout(StartWorkoutParams params);

  /// Completes the current workout
  Future<Result<WorkoutSummary>> completeWorkout(String workoutId);

  /// Discards the current workout (deletes without saving)
  Future<Result<void>> discardWorkout(String workoutId);

  /// Watches the active workout for real-time updates
  Stream<Workout?> watchActiveWorkout();

  // --- Exercise Operations ---

  /// Adds an exercise to a workout
  Future<Result<ExerciseLog>> addExercise(AddExerciseParams params);

  /// Removes an exercise from a workout
  Future<Result<void>> removeExercise(String exerciseLogId);

  /// Reorders exercises in a workout
  Future<Result<void>> reorderExercises(String workoutId, List<String> exerciseLogIds);

  // --- Set Operations ---

  /// Logs a new set for an exercise
  Future<Result<WorkoutSet>> logSet(LogSetParams params);

  /// Updates an existing set
  Future<Result<WorkoutSet>> updateSet(String setId, LogSetParams params);

  /// Deletes a set
  Future<Result<void>> deleteSet(String setId);

  // --- History Operations ---

  /// Gets workout history with pagination
  Future<Result<List<Workout>>> getWorkoutHistory({
    WorkoutFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Gets a single workout by ID with all details
  Future<Result<Workout>> getWorkoutById(String id);

  /// Gets workout stats for a user or client
  Future<Result<WorkoutStats>> getWorkoutStats({
    String? clientId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Watches workout history for real-time updates
  Stream<List<Workout>> watchWorkoutHistory({
    WorkoutFilter? filter,
    int limit = 10,
  });

  // --- Resume/Edit Operations ---

  /// Resumes a completed workout (reopens for editing)
  Future<Result<Workout>> resumeWorkout(String workoutId);

  /// Updates workout notes
  Future<Result<void>> updateWorkoutNotes(String workoutId, String notes);

  /// Updates workout selfie
  Future<Result<void>> updateWorkoutSelfie(String workoutId, String imagePath);
}

/// Aggregated workout statistics
class WorkoutStats {
  final int totalWorkouts;
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final Duration totalDuration;
  final double averageDurationMinutes;
  final int workoutsThisWeek;
  final int workoutsThisMonth;
  final int currentStreak; // Consecutive weeks with workouts
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final Map<String, int> workoutsByDayOfWeek;
  final List<MostUsedExercise> mostUsedExercises;

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.totalDuration,
    required this.averageDurationMinutes,
    required this.workoutsThisWeek,
    required this.workoutsThisMonth,
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    required this.workoutsByDayOfWeek,
    required this.mostUsedExercises,
  });
}

/// Exercise usage stats
class MostUsedExercise {
  final String exerciseId;
  final String exerciseName;
  final int timesPerformed;
  final double bestWeight;
  final double best1RM;

  const MostUsedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.timesPerformed,
    required this.bestWeight,
    required this.best1RM,
  });
}

