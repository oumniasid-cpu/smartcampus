/// Base class for all use cases.
/// [Result] = return type wrapped in Either
/// [Params] = input parameters
abstract class UseCase<Result, Params> {
  Future<Result> call(Params params);
}

/// Use when a use case needs no parameters.
class NoParams {
  const NoParams();
}
