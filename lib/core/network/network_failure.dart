enum NetworkFailureType { timeout, disconnected }

/// Error de conectividad expresado en términos de la aplicación.
class NetworkFailure implements Exception {
  const NetworkFailure(this.type);

  final NetworkFailureType type;

  String get message => switch (type) {
    NetworkFailureType.timeout => 'Tiempo agotado',
    NetworkFailureType.disconnected => 'Sin conexión',
  };

  @override
  String toString() => message;
}
