import 'app_error.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(AppError error) = Failure<T>;

  T? get valueOrNull;
  AppError? get errorOrNull;
  bool get isSuccess;
  bool get isFailure;

  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  });

  Result<R> map<R>(R Function(T value) transform);

  Result<R> flatMap<R>(Result<R> Function(T value) transform);
}

final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  T get valueOrNull => value;

  @override
  AppError? get errorOrNull => null;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) => success(value);

  @override
  Result<R> map<R>(R Function(T value) transform) =>
      Success<R>(transform(value));

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      transform(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Result<$T>.success($value)';
}

final class Failure<T> extends Result<T> {
  final AppError error;

  const Failure(this.error);

  @override
  T? get valueOrNull => null;

  @override
  AppError get errorOrNull => error;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) => failure(error);

  @override
  Result<R> map<R>(R Function(T value) transform) => Failure<R>(error);

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      Failure<R>(error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() => 'Result<$T>.failure($error)';
}
