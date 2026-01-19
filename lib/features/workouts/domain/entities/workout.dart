import 'package:equatable/equatable.dart';

/// Represents a workout session
class Workout extends Equatable {
  final String id;
  final String userId;
  final String? trainerId;
  final String? templateId;
  final String? name;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;
  final String? selfieUrl;
  final List<ExerciseLog> exercises;
  final DateTime createdAt;

  const Workout({
    required this.id,
    required this.userId,
    this.trainerId,
    this.templateId,
    this.name,
    required this.startTime,
    this.endTime,
    this.notes,
    this.selfieUrl,
    this.exercises = const [],
    required this.createdAt,
  });

  /// Returns workout duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Returns formatted duration string (e.g., "1h 23m")
  String get durationFormatted {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    return '${d.inMinutes}m';
  }

  /// Whether the workout is still in progress
  bool get isActive => endTime == null;

  /// Total number of sets across all exercises
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  /// Total number of completed sets (not warmup)
  int get completedSets => exercises.fold(
        0,
        (sum, ex) => sum + ex.sets.where((s) => s.type != SetType.warmup).length,
      );

  /// Total volume (weight × reps) across all exercises
  double get totalVolume => exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);

  /// Number of personal records achieved in this workout
  int get prCount => exercises.fold(
        0,
        (sum, ex) => sum + ex.sets.where((s) => s.isPR).length,
      );

  /// Number of exercises in this workout
  int get exerciseCount => exercises.length;

  /// Creates a copy with modified fields
  Workout copyWith({
    String? id,
    String? userId,
    String? trainerId,
    String? templateId,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? selfieUrl,
    List<ExerciseLog>? exercises,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainerId: trainerId ?? this.trainerId,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        trainerId,
        templateId,
        name,
        startTime,
        endTime,
        notes,
        selfieUrl,
        exercises,
        createdAt,
      ];
}

/// Represents an exercise performed within a workout
class ExerciseLog extends Equatable {
  final String id;
  final String workoutId;
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImage;
  final int sequence;
  final String? notes;
  final List<WorkoutSet> sets;
  final int? supersetGroup;

  const ExerciseLog({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImage,
    required this.sequence,
    this.notes,
    this.sets = const [],
    this.supersetGroup,
  });

  /// Total volume for this exercise
  double get totalVolume => sets.fold(0.0, (sum, set) => sum + set.volume);

  /// Best weight lifted in this exercise
  double get bestWeight {
    if (sets.isEmpty) return 0;
    return sets.map((s) => s.weight ?? 0).reduce((a, b) => a > b ? a : b);
  }

  /// Best estimated 1RM from sets in this exercise
  double get best1RM {
    if (sets.isEmpty) return 0;
    return sets.map((s) => s.estimated1RM).reduce((a, b) => a > b ? a : b);
  }

  /// Whether this exercise is part of a superset
  bool get isSuperset => supersetGroup != null;

  /// Number of completed sets
  int get completedSetCount => sets.where((s) => s.type != SetType.warmup).length;

  /// Number of warmup sets
  int get warmupSetCount => sets.where((s) => s.type == SetType.warmup).length;

  ExerciseLog copyWith({
    String? id,
    String? workoutId,
    String? exerciseId,
    String? exerciseName,
    String? exerciseImage,
    int? sequence,
    String? notes,
    List<WorkoutSet>? sets,
    int? supersetGroup,
  }) {
    return ExerciseLog(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImage: exerciseImage ?? this.exerciseImage,
      sequence: sequence ?? this.sequence,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
      supersetGroup: supersetGroup ?? this.supersetGroup,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutId,
        exerciseId,
        exerciseName,
        sequence,
        notes,
        sets,
        supersetGroup,
      ];
}

/// Type of set
enum SetType {
  normal('Normal'),
  warmup('Warmup'),
  dropset('Drop Set'),
  failure('To Failure');

  final String label;
  const SetType(this.label);
}

/// Represents a single set within an exercise
class WorkoutSet extends Equatable {
  final String id;
  final String exerciseLogId;
  final int setNumber;
  final SetType type;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? rpe; // Rate of Perceived Exertion (1-10)
  final bool isPR;
  final DateTime completedAt;

  const WorkoutSet({
    required this.id,
    required this.exerciseLogId,
    required this.setNumber,
    this.type = SetType.normal,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
    this.isPR = false,
    required this.completedAt,
  });

  /// Calculate volume (weight × reps)
  double get volume => (weight ?? 0) * (reps ?? 0);

  /// Brzycki formula for estimated 1 Rep Max
  double get estimated1RM {
    if (weight == null || reps == null || reps == 0) return 0;
    if (reps == 1) return weight!;
    // Brzycki formula: weight / (1.0278 - 0.0278 * reps)
    return weight! / (1.0278 - 0.0278 * reps!);
  }

  /// Whether this is a strength set (has weight and reps)
  bool get isStrengthSet => weight != null && reps != null;

  /// Whether this is a cardio set (has duration or distance)
  bool get isCardioSet => durationSeconds != null || distanceMeters != null;

  /// Formatted duration string
  String? get durationFormatted {
    if (durationSeconds == null) return null;
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  /// RPE description
  String? get rpeDescription {
    if (rpe == null) return null;
    if (rpe! <= 5) return 'Easy';
    if (rpe! <= 7) return 'Moderate';
    if (rpe! <= 8) return 'Hard';
    if (rpe! <= 9) return 'Very Hard';
    return 'Maximum Effort';
  }

  WorkoutSet copyWith({
    String? id,
    String? exerciseLogId,
    int? setNumber,
    SetType? type,
    double? weight,
    int? reps,
    int? durationSeconds,
    double? distanceMeters,
    double? rpe,
    bool? isPR,
    DateTime? completedAt,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      exerciseLogId: exerciseLogId ?? this.exerciseLogId,
      setNumber: setNumber ?? this.setNumber,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      rpe: rpe ?? this.rpe,
      isPR: isPR ?? this.isPR,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        exerciseLogId,
        setNumber,
        type,
        weight,
        reps,
        durationSeconds,
        distanceMeters,
        rpe,
        isPR,
        completedAt,
      ];
}

/// Summary of a completed workout
class WorkoutSummary extends Equatable {
  final String workoutId;
  final String? name;
  final Duration duration;
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final int exerciseCount;
  final int prCount;
  final List<String> exerciseNames;
  final DateTime completedAt;

  const WorkoutSummary({
    required this.workoutId,
    this.name,
    required this.duration,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.exerciseCount,
    required this.prCount,
    required this.exerciseNames,
    required this.completedAt,
  });

  /// Creates a summary from a completed workout
  factory WorkoutSummary.fromWorkout(Workout workout) {
    final totalReps = workout.exercises.fold<int>(
      0,
      (sum, ex) => sum + ex.sets.fold<int>(0, (s, set) => s + (set.reps ?? 0)),
    );

    return WorkoutSummary(
      workoutId: workout.id,
      name: workout.name,
      duration: workout.duration,
      totalSets: workout.totalSets,
      totalReps: totalReps,
      totalVolume: workout.totalVolume,
      exerciseCount: workout.exerciseCount,
      prCount: workout.prCount,
      exerciseNames: workout.exercises.map((e) => e.exerciseName).toList(),
      completedAt: workout.endTime ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        workoutId,
        name,
        duration,
        totalSets,
        totalReps,
        totalVolume,
        exerciseCount,
        prCount,
        exerciseNames,
        completedAt,
      ];
}

