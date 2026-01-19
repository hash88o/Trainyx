import '../errors/failures.dart';

/// Result type for handling success/failure without exceptions
/// Usage: Either<Failure, User> result = await repository.getUser(id);
sealed class Result<T> {
  const Result();

  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure
  bool get isFailure => this is Error<T>;

  /// Gets the value if Success, throws if Failure
  T get value {
    if (this is Success<T>) {
      return (this as Success<T>)._value;
    }
    throw StateError('Cannot get value from Error result');
  }

  /// Gets the failure if Error, throws if Success
  Failure get failure {
    if (this is Error<T>) {
      return (this as Error<T>)._failure;
    }
    throw StateError('Cannot get failure from Success result');
  }

  /// Transforms the value if Success, returns unchanged if Error
  Result<R> map<R>(R Function(T value) transform) {
    if (this is Success<T>) {
      return Success(transform((this as Success<T>)._value));
    }
    return Error((this as Error<T>)._failure);
  }

  /// Transforms the value asynchronously if Success
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) transform) async {
    if (this is Success<T>) {
      return Success(await transform((this as Success<T>)._value));
    }
    return Error((this as Error<T>)._failure);
  }

  /// Chains another Result-returning operation
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    if (this is Success<T>) {
      return transform((this as Success<T>)._value);
    }
    return Error((this as Error<T>)._failure);
  }

  /// Executes a function based on success or failure
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>)._value);
    }
    return onFailure((this as Error<T>)._failure);
  }

  /// Gets the value or a default
  T getOrElse(T defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>)._value;
    }
    return defaultValue;
  }

  /// Gets the value or computes a default
  T getOrElseCompute(T Function(Failure failure) compute) {
    if (this is Success<T>) {
      return (this as Success<T>)._value;
    }
    return compute((this as Error<T>)._failure);
  }
}

/// Represents a successful result
final class Success<T> extends Result<T> {
  final T _value;

  const Success(this._value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other._value == _value);

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Success($_value)';
}

/// Represents a failed result
final class Error<T> extends Result<T> {
  final Failure _failure;

  const Error(this._failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Error<T> && other._failure == _failure);

  @override
  int get hashCode => _failure.hashCode;

  @override
  String toString() => 'Error($_failure)';
}

/// Extension for cleaner creation
extension ResultExtensions<T> on T {
  Result<T> toSuccess() => Success(this);
}

extension FailureExtensions on Failure {
  Result<T> toError<T>() => Error<T>(this);
}

