import 'dart:async';
import 'dart:io';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:gameon/core/network/network_config.dart';
import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:gameon/features/home/viewmodels/instituciones_load_viewmodel.dart';

void main() {
  test('Timeout abandona carga y muestra Tiempo agotado', () {
    fakeAsync((clock) {
      final adapter = NetworkConfig.createAdapter();
      final vm = InstitucionesLoadViewModel(
        fetchInstituciones: () => adapter.execute(
          () => Future.delayed(
            const Duration(seconds: 4),
            () => <InstitucionDeportiva>[],
          ),
        ),
      );
      unawaited(vm.load());
      expect(vm.isLoading, isTrue);
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 3));
      expect(vm.errorMessage, 'Tiempo agotado');
      expect(vm.isLoading, isFalse);
      expect(vm.isRetrying, isFalse);
      expect(vm.canRetry, isTrue);
      clock.elapse(const Duration(seconds: 1));
      expect(vm.errorMessage, 'Tiempo agotado');
      vm.dispose();
    });
  });

  for (final failure in [
    const SocketException('Red no disponible'),
    http.ClientException('Failed to fetch'),
  ]) {
    test(
      '${failure.runtimeType} muestra Sin conexión y termina el reintento',
      () async {
        final adapter = NetworkConfig.createAdapter();
        var calls = 0;
        final vm = InstitucionesLoadViewModel(
          fetchInstituciones: () =>
              adapter.execute<List<InstitucionDeportiva>>(() async {
                calls++;
                throw failure;
              }),
        );
        addTearDown(vm.dispose);
        await vm.load();
        await vm.retry();
        expect(vm.errorMessage, 'Sin conexión');
        expect(vm.isLoading, isFalse);
        expect(vm.isRetrying, isFalse);
        expect(vm.canRetry, isTrue);
        expect(calls, 2);
      },
    );
  }
}
