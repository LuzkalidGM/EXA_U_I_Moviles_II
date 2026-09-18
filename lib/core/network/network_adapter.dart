/// Aplica un límite configurable a cada petición de red.
class NetworkAdapter {
  NetworkAdapter({required this.timeout}) {
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'Debe ser positivo');
    }
  }

  final Duration timeout;

  Future<T> execute<T>(Future<T> Function() request) {
    return Future<T>.sync(request).timeout(timeout);
  }
}
