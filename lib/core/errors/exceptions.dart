/// Base exception for data layer errors
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exceptions from API calls
class ServerException extends AppException {
  final int? statusCode;
  final dynamic response;

  const ServerException({
    required super.message,
    super.code,
    this.statusCode,
    this.response,
  });

  factory ServerException.fromStatusCode(int statusCode, [String? message]) {
    final msg = message ?? _defaultMessage(statusCode);
    return ServerException(
      message: msg,
      statusCode: statusCode,
      code: 'HTTP_$statusCode',
    );
  }

  static String _defaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation error';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      case 503:
        return 'Service unavailable';
      default:
        return 'Server error';
    }
  }
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection'});
}

/// Cache/local storage exceptions
class CacheException extends AppException {
  const CacheException({required super.message, super.code});

  factory CacheException.notFound(String key) => CacheException(
        message: 'Cache key not found: $key',
        code: 'CACHE_NOT_FOUND',
      );

  factory CacheException.expired(String key) => CacheException(
        message: 'Cache expired for key: $key',
        code: 'CACHE_EXPIRED',
      );
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({required super.message, super.code});

  factory AuthException.invalidToken() => const AuthException(
        message: 'Invalid or expired token',
        code: 'INVALID_TOKEN',
      );

  factory AuthException.refreshFailed() => const AuthException(
        message: 'Failed to refresh authentication',
        code: 'REFRESH_FAILED',
      );
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
  });
}

/// Sync exceptions
class SyncException extends AppException {
  final String? conflictingEntityId;

  const SyncException({
    required super.message,
    super.code,
    this.conflictingEntityId,
  });
}

