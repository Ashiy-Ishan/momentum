sealed class AppError implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  const AppError(this.message, {this.details, this.stackTrace});

  @override
  String toString() {
    if (details != null && details!.isNotEmpty) {
      return '$runtimeType: $message ($details)';
    }
    return '$runtimeType: $message';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          details == other.details;

  @override
  int get hashCode => Object.hash(runtimeType, message, details);
}

class DatabaseError extends AppError {
  const DatabaseError(super.message, {super.details, super.stackTrace});
}

class NetworkError extends AppError {
  final int? statusCode;

  const NetworkError(
    super.message, {
    this.statusCode,
    super.details,
    super.stackTrace,
  });

  @override
  bool operator ==(Object other) =>
      super == other && other is NetworkError && statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(super.hashCode, statusCode);
}

class AuthError extends AppError {
  const AuthError(super.message, {super.details, super.stackTrace});
}

class SyncError extends AppError {
  const SyncError(super.message, {super.details, super.stackTrace});
}

class ValidationError extends AppError {
  final String? field;

  const ValidationError(
    super.message, {
    this.field,
    super.details,
    super.stackTrace,
  });

  @override
  bool operator ==(Object other) =>
      super == other && other is ValidationError && field == other.field;

  @override
  int get hashCode => Object.hash(super.hashCode, field);
}

class FileError extends AppError {
  final String? path;

  const FileError(super.message, {this.path, super.details, super.stackTrace});

  @override
  bool operator ==(Object other) =>
      super == other && other is FileError && path == other.path;

  @override
  int get hashCode => Object.hash(super.hashCode, path);
}

class PlatformError extends AppError {
  final String? code;

  const PlatformError(
    super.message, {
    this.code,
    super.details,
    super.stackTrace,
  });

  @override
  bool operator ==(Object other) =>
      super == other && other is PlatformError && code == other.code;

  @override
  int get hashCode => Object.hash(super.hashCode, code);
}
