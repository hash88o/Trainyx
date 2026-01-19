import 'package:equatable/equatable.dart';

/// Base failure class for domain layer errors
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Local database failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidCredentials() =>
      const AuthFailure(message: 'Invalid email or password', code: 'INVALID_CREDENTIALS');

  factory AuthFailure.sessionExpired() =>
      const AuthFailure(message: 'Session expired. Please login again', code: 'SESSION_EXPIRED');

  factory AuthFailure.unauthorized() =>
      const AuthFailure(message: 'You are not authorized to perform this action', code: 'UNAUTHORIZED');
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Not found failures
class NotFoundFailure extends Failure {
  final String? entityType;
  final String? entityId;

  const NotFoundFailure({
    required super.message,
    this.entityType,
    this.entityId,
  });

  factory NotFoundFailure.client(String id) => NotFoundFailure(
        message: 'Client not found',
        entityType: 'Client',
        entityId: id,
      );

  factory NotFoundFailure.workout(String id) => NotFoundFailure(
        message: 'Workout not found',
        entityType: 'Workout',
        entityId: id,
      );
}

/// Conflict failures (e.g., sync conflicts)
class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, super.code});
}

