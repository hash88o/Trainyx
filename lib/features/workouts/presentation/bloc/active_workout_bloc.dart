import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';

// --- Events ---

abstract class ActiveWorkoutEvent extends Equatable {
  const ActiveWorkoutEvent();

  @override
  List<Object?> get props => [];
}

/// Load any existing active workout on app start
class LoadActiveWorkout extends ActiveWorkoutEvent {}

/// Start a new workout
class StartWorkout extends ActiveWorkoutEvent {
  final String? templateId;
  final String? clientId;
  final String? name;

  const StartWorkout({this.templateId, this.clientId, this.name});

  @override
  List<Object?> get props => [templateId, clientId, name];
}

/// Add an exercise to the current workout
class AddExercise extends ActiveWorkoutEvent {
  final String exerciseId;
  final int? targetSets;
  final String? targetReps;
  final double? targetWeight;

  const AddExercise({
    required this.exerciseId,
    this.targetSets,
    this.targetReps,
    this.targetWeight,
  });

  @override
  List<Object?> get props => [exerciseId, targetSets, targetReps, targetWeight];
}

/// Remove an exercise from the current workout
class RemoveExercise extends ActiveWorkoutEvent {
  final String exerciseLogId;

  const RemoveExercise(this.exerciseLogId);

  @override
  List<Object?> get props => [exerciseLogId];
}

/// Log a set for an exercise
class LogSet extends ActiveWorkoutEvent {
  final String exerciseLogId;
  final SetType type;
  final double? weight;
  final int? reps;
  final double? rpe;

  const LogSet({
    required this.exerciseLogId,
    this.type = SetType.normal,
    this.weight,
    this.reps,
    this.rpe,
  });

  @override
  List<Object?> get props => [exerciseLogId, type, weight, reps, rpe];
}

/// Update an existing set
class UpdateSet extends ActiveWorkoutEvent {
  final String setId;
  final double? weight;
  final int? reps;
  final double? rpe;
  final SetType? type;

  const UpdateSet({
    required this.setId,
    this.weight,
    this.reps,
    this.rpe,
    this.type,
  });

  @override
  List<Object?> get props => [setId, weight, reps, rpe, type];
}

/// Delete a set
class DeleteSet extends ActiveWorkoutEvent {
  final String setId;

  const DeleteSet(this.setId);

  @override
  List<Object?> get props => [setId];
}

/// Complete the current workout
class CompleteWorkout extends ActiveWorkoutEvent {
  final String? selfieImagePath;

  const CompleteWorkout({this.selfieImagePath});

  @override
  List<Object?> get props => [selfieImagePath];
}

/// Discard the current workout
class DiscardWorkout extends ActiveWorkoutEvent {}

/// Update workout notes
class UpdateWorkoutNotes extends ActiveWorkoutEvent {
  final String notes;

  const UpdateWorkoutNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

// --- States ---

abstract class ActiveWorkoutState extends Equatable {
  const ActiveWorkoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class ActiveWorkoutInitial extends ActiveWorkoutState {}

/// Loading state
class ActiveWorkoutLoading extends ActiveWorkoutState {}

/// No active workout
class NoActiveWorkout extends ActiveWorkoutState {}

/// Workout is in progress
class WorkoutInProgress extends ActiveWorkoutState {
  final Workout workout;
  final Duration elapsed;
  final bool isSaving;

  const WorkoutInProgress({
    required this.workout,
    required this.elapsed,
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [workout, elapsed, isSaving];

  WorkoutInProgress copyWith({
    Workout? workout,
    Duration? elapsed,
    bool? isSaving,
  }) {
    return WorkoutInProgress(
      workout: workout ?? this.workout,
      elapsed: elapsed ?? this.elapsed,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Workout completed successfully
class WorkoutCompleted extends ActiveWorkoutState {
  final WorkoutSummary summary;

  const WorkoutCompleted(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// Error state
class ActiveWorkoutError extends ActiveWorkoutState {
  final String message;
  final ActiveWorkoutState previousState;

  const ActiveWorkoutError({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

// --- Bloc ---

class ActiveWorkoutBloc extends Bloc<ActiveWorkoutEvent, ActiveWorkoutState> {
  final WorkoutRepository _repository;
  StreamSubscription<Workout?>? _workoutSubscription;
  Timer? _timerSubscription;

  ActiveWorkoutBloc({
    required WorkoutRepository repository,
  })  : _repository = repository,
        super(ActiveWorkoutInitial()) {
    on<LoadActiveWorkout>(_onLoadActiveWorkout);
    on<StartWorkout>(_onStartWorkout);
    on<AddExercise>(_onAddExercise);
    on<RemoveExercise>(_onRemoveExercise);
    on<LogSet>(_onLogSet);
    on<UpdateSet>(_onUpdateSet);
    on<DeleteSet>(_onDeleteSet);
    on<CompleteWorkout>(_onCompleteWorkout);
    on<DiscardWorkout>(_onDiscardWorkout);
    on<UpdateWorkoutNotes>(_onUpdateWorkoutNotes);
  }

  Future<void> _onLoadActiveWorkout(
    LoadActiveWorkout event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    emit(ActiveWorkoutLoading());

    final result = await _repository.getActiveWorkout();

    result.fold(
      onSuccess: (workout) {
        if (workout != null) {
          _startTimer(emit, workout);
          emit(WorkoutInProgress(
            workout: workout,
            elapsed: DateTime.now().difference(workout.startTime),
          ));
        } else {
          emit(NoActiveWorkout());
        }
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: NoActiveWorkout(),
        ));
      },
    );

    // Subscribe to workout updates
    _workoutSubscription = _repository.watchActiveWorkout().listen(
      (workout) {
        if (workout != null && state is WorkoutInProgress) {
          final currentState = state as WorkoutInProgress;
          add(LoadActiveWorkout()); // Refresh
        }
      },
    );
  }

  Future<void> _onStartWorkout(
    StartWorkout event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    emit(ActiveWorkoutLoading());

    final result = await _repository.startWorkout(
      StartWorkoutParams(
        templateId: event.templateId,
        clientId: event.clientId,
        name: event.name,
      ),
    );

    result.fold(
      onSuccess: (workout) {
        _startTimer(emit, workout);
        emit(WorkoutInProgress(
          workout: workout,
          elapsed: Duration.zero,
        ));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: NoActiveWorkout(),
        ));
      },
    );
  }

  Future<void> _onAddExercise(
    AddExercise event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    emit(currentState.copyWith(isSaving: true));

    final result = await _repository.addExercise(
      AddExerciseParams(
        workoutId: currentState.workout.id,
        exerciseId: event.exerciseId,
        targetSets: event.targetSets,
        targetReps: event.targetReps,
        targetWeight: event.targetWeight,
      ),
    );

    result.fold(
      onSuccess: (exerciseLog) {
        final updatedExercises = [...currentState.workout.exercises, exerciseLog];
        emit(currentState.copyWith(
          workout: currentState.workout.copyWith(exercises: updatedExercises),
          isSaving: false,
        ));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState.copyWith(isSaving: false),
        ));
      },
    );
  }

  Future<void> _onRemoveExercise(
    RemoveExercise event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    emit(currentState.copyWith(isSaving: true));

    final result = await _repository.removeExercise(event.exerciseLogId);

    result.fold(
      onSuccess: (_) {
        final updatedExercises = currentState.workout.exercises
            .where((e) => e.id != event.exerciseLogId)
            .toList();
        emit(currentState.copyWith(
          workout: currentState.workout.copyWith(exercises: updatedExercises),
          isSaving: false,
        ));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState.copyWith(isSaving: false),
        ));
      },
    );
  }

  Future<void> _onLogSet(
    LogSet event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    final result = await _repository.logSet(
      LogSetParams(
        exerciseLogId: event.exerciseLogId,
        type: event.type,
        weight: event.weight,
        reps: event.reps,
        rpe: event.rpe,
      ),
    );

    result.fold(
      onSuccess: (newSet) {
        // Update the exercise log with the new set
        final updatedExercises = currentState.workout.exercises.map((exercise) {
          if (exercise.id == event.exerciseLogId) {
            return exercise.copyWith(sets: [...exercise.sets, newSet]);
          }
          return exercise;
        }).toList();

        emit(currentState.copyWith(
          workout: currentState.workout.copyWith(exercises: updatedExercises),
        ));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState,
        ));
      },
    );
  }

  Future<void> _onUpdateSet(
    UpdateSet event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    final result = await _repository.updateSet(
      event.setId,
      LogSetParams(
        exerciseLogId: '', // Not needed for update
        type: event.type ?? SetType.normal,
        weight: event.weight,
        reps: event.reps,
        rpe: event.rpe,
      ),
    );

    result.fold(
      onSuccess: (updatedSet) {
        // Update the set in the exercise log
        final updatedExercises = currentState.workout.exercises.map((exercise) {
          final updatedSets = exercise.sets.map((set) {
            if (set.id == event.setId) {
              return updatedSet;
            }
            return set;
          }).toList();
          return exercise.copyWith(sets: updatedSets);
        }).toList();

        emit(currentState.copyWith(
          workout: currentState.workout.copyWith(exercises: updatedExercises),
        ));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState,
        ));
      },
    );
  }

  Future<void> _onDeleteSet(
    DeleteSet event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    final result = await _repository.deleteSet(event.setId);

    result.fold(
      onSuccess: (_) {
        // Remove the set from the exercise log
        final updatedExercises = currentState.workout.exercises.map((exercise) {
          final updatedSets = exercise.sets.where((s) => s.id != event.setId).toList();
          return exercise.copyWith(sets: updatedSets);
        }).toList();

        emit(currentState.copyWith(
          workout: currentState.workout.copyWith(exercises: updatedExercises),
        ));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState,
        ));
      },
    );
  }

  Future<void> _onCompleteWorkout(
    CompleteWorkout event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    emit(currentState.copyWith(isSaving: true));

    // Upload selfie if provided
    if (event.selfieImagePath != null) {
      await _repository.updateWorkoutSelfie(
        currentState.workout.id,
        event.selfieImagePath!,
      );
    }

    final result = await _repository.completeWorkout(currentState.workout.id);

    result.fold(
      onSuccess: (summary) {
        _stopTimer();
        emit(WorkoutCompleted(summary));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState.copyWith(isSaving: false),
        ));
      },
    );
  }

  Future<void> _onDiscardWorkout(
    DiscardWorkout event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    emit(currentState.copyWith(isSaving: true));

    final result = await _repository.discardWorkout(currentState.workout.id);

    result.fold(
      onSuccess: (_) {
        _stopTimer();
        emit(NoActiveWorkout());
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState.copyWith(isSaving: false),
        ));
      },
    );
  }

  Future<void> _onUpdateWorkoutNotes(
    UpdateWorkoutNotes event,
    Emitter<ActiveWorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    final result = await _repository.updateWorkoutNotes(
      currentState.workout.id,
      event.notes,
    );

    result.fold(
      onSuccess: (_) {
        emit(currentState.copyWith(
          workout: currentState.workout.copyWith(notes: event.notes),
        ));
      },
      onFailure: (failure) {
        emit(ActiveWorkoutError(
          message: failure.message,
          previousState: currentState,
        ));
      },
    );
  }

  void _startTimer(Emitter<ActiveWorkoutState> emit, Workout workout) {
    _stopTimer();
    _timerSubscription = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is WorkoutInProgress) {
        final currentState = state as WorkoutInProgress;
        // Timer updates are handled by the UI via elapsed calculation
        // This is just to trigger rebuilds
      }
    });
  }

  void _stopTimer() {
    _timerSubscription?.cancel();
    _timerSubscription = null;
  }

  @override
  Future<void> close() {
    _workoutSubscription?.cancel();
    _stopTimer();
    return super.close();
  }
}

