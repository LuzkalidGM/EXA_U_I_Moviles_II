import 'dart:async';
import 'package:http/http.dart' as http;
import 'network_failure.dart';
import 'socket_failure_stub.dart' if (dart.library.io) 'socket_failure_io.dart';

/// Aplica un límite configurable y transforma los fallos de transporte.
class NetworkAdapter {
  NetworkAdapter({required this.timeout}) {
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'Debe ser positivo');
    }
  }

  final Duration timeout;

  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      return await Future<T>.sync(request).timeout(timeout);
    } on TimeoutException {
      throw const NetworkFailure(NetworkFailureType.timeout);
    } catch (error) {
      if (isSocketFailure(error) || error is http.ClientException) {
        throw const NetworkFailure(NetworkFailureType.disconnected);
      }
      rethrow;
    }
  }
}
