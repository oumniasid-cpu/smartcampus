/// Base class for all use cases.
/// [Type]   = return type wrapped in Either
/// [Params] = input parameters
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}
 
/// Use when a use case needs no parameters.
class NoParams {
  const NoParams();
}