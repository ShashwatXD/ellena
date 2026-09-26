sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  Object? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(Object error, StackTrace? stackTrace) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Failure(:final error, :final stackTrace) => failure(error, stackTrace),
    };
  }

  static Future<Result<T>> capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
    }
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;
}
