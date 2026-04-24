import 'package:equatable/equatable.dart';
 
/// Base class for all domain-level failures.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
 
  @override
  List<Object?> get props => [message];
}
 
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau. Vérifiez votre connexion.']);
}
 
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache local.']);
}