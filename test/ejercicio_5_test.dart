import 'dart:async';
import 'dart:io';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/network/network_config.dart';
import 'package:gameon/core/network/network_failure.dart';
import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:gameon/features/home/viewmodels/instituciones_load_viewmodel.dart';

void main() {
  test('(a) Respuesta de 4s: Tiempo agotado a los 3s y carga desactivada', () {
    fakeAsync((clock) {
      final adapter = NetworkConfig.createAdapter();
      var requests = 0;
      final state = InstitucionesLoadViewModel(
        fetchInstituciones: () => adapter.execute(() {
          requests++;
          return Future.delayed(
            const Duration(seconds: 4),
            () => <InstitucionDeportiva>[],
          );
        }),
      );
      unawaited(state.load());
      clock.flushMicrotasks();
      expect(adapter.timeout, const Duration(seconds: 3));
      clock.elapse(const Duration(milliseconds: 2999));
      expect(state.isLoading, isTrue);
      expect(state.error, isNull);
      clock.elapse(const Duration(milliseconds: 1));
      expect(state.error, isA<NetworkFailure>());
      expect(state.errorMessage, 'Tiempo agotado');
      expect(state.isLoading, isFalse);
      expect(state.isRetrying, isFalse);
      expect(state.canRetry, isTrue);
      expect(requests, 1);
      clock.elapse(const Duration(seconds: 1));
      expect(state.errorMessage, 'Tiempo agotado');
      expect(state.isLoading, isFalse);
      expect(requests, 1);
      state.dispose();
    });
  });

  test('(b) SocketException: Sin conexión y carga desactivada', () async {
    final adapter = NetworkConfig.createAdapter();
    var requests = 0;
    final state = InstitucionesLoadViewModel(
      fetchInstituciones: () =>
          adapter.execute<List<InstitucionDeportiva>>(() async {
            requests++;
            throw const SocketException('Sin red en el doble de prueba');
          }),
    );
    addTearDown(state.dispose);
    final load = state.load();
    expect(state.isLoading, isTrue);
    await load;
    expect(state.error, isA<NetworkFailure>());
    expect(state.errorMessage, 'Sin conexión');
    expect(state.isLoading, isFalse);
    expect(state.isRetrying, isFalse);
    expect(state.canRetry, isTrue);
    expect(requests, 1);
    final retry = state.retry();
    expect(state.isRetrying, isTrue);
    expect(state.canRetry, isFalse);
    await retry;
    expect(state.errorMessage, 'Sin conexión');
    expect(state.isLoading, isFalse);
    expect(state.isRetrying, isFalse);
    expect(requests, 2);
  });
}
