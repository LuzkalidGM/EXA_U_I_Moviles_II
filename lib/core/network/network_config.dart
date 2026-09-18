import 'network_adapter.dart';

/// Configuración de red del recurso evaluado, fuera de las pantallas.
class NetworkConfig {
  static NetworkAdapter createAdapter() {
    return NetworkAdapter(timeout: const Duration(seconds: 3));
  }
}
