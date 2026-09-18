import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:gameon/features/home/viewmodels/instituciones_load_viewmodel.dart';

void main() {
  test(
    'El fallo inicial no reintenta automáticamente ni cuenta como manual',
    () async {
      var calls = 0;
      final vm = InstitucionesLoadViewModel(
        fetchInstituciones: () async {
          calls++;
          throw StateError('Fallo de red');
        },
      );
      addTearDown(vm.dispose);
      await vm.load();
      expect(calls, 1);
      expect(vm.error, isNotNull);
      expect(vm.failedManualRetries, 0);
      expect(vm.isLoading, isFalse);
      expect(vm.canRetry, isTrue);
    },
  );

  test(
    'El reintento muestra carga local, evita duplicados y recupera la carga',
    () async {
      var calls = 0;
      final response = Completer<List<InstitucionDeportiva>>();
      final vm = InstitucionesLoadViewModel(
        fetchInstituciones: () async {
          calls++;
          if (calls == 1) throw StateError('Fallo de red');
          return response.future;
        },
      );
      addTearDown(vm.dispose);
      await vm.load();
      final retry = vm.retry();
      expect(vm.isRetrying, isTrue);
      expect(vm.canRetry, isFalse);
      await vm.retry();
      expect(calls, 2);
      response.complete([]);
      await retry;
      expect(vm.error, isNull);
      expect(vm.isLoading, isFalse);
      expect(vm.isRetrying, isFalse);
      expect(vm.failedManualRetries, 0);
    },
  );

  test(
    'Tres reintentos manuales fallidos bloquean diez segundos sin peticiones extra',
    () {
      fakeAsync((clock) {
        var calls = 0;
        final vm = InstitucionesLoadViewModel(
          fetchInstituciones: () async {
            calls++;
            throw StateError('Fallo de red');
          },
        );
        unawaited(vm.load());
        clock.flushMicrotasks();
        for (var attempt = 0; attempt < 3; attempt++) {
          unawaited(vm.retry());
          clock.flushMicrotasks();
        }
        expect(calls, 4);
        expect(vm.cooldownSeconds, 10);
        expect(vm.canRetry, isFalse);
        unawaited(vm.retry());
        clock.flushMicrotasks();
        expect(calls, 4);
        clock.elapse(const Duration(seconds: 9));
        expect(vm.canRetry, isFalse);
        expect(vm.cooldownSeconds, 1);
        clock.elapse(const Duration(seconds: 1));
        expect(vm.cooldownSeconds, 0);
        expect(vm.canRetry, isTrue);
        expect(calls, 4);
        vm.dispose();
      });
    },
  );
}
