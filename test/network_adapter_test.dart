import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/network/network_adapter.dart';
import 'package:gameon/core/network/network_config.dart';

void main() {
  test('La configuración corta una petición pendiente a los tres segundos', () {
    fakeAsync((clock) {
      final adapter = NetworkConfig.createAdapter();
      final response = Completer<String>();
      Object? failure;
      var calls = 0;
      unawaited(
        adapter
            .execute(() {
              calls++;
              return response.future;
            })
            .then<void>((_) {}, onError: (Object error) => failure = error),
      );
      clock.flushMicrotasks();
      clock.elapse(const Duration(milliseconds: 2999));
      expect(failure, isNull);
      clock.elapse(const Duration(milliseconds: 1));
      expect(failure, isA<TimeoutException>());
      expect(calls, 1);
    });
  });

  test(
    'El constructor permite otro límite y devuelve la respuesta a tiempo',
    () {
      fakeAsync((clock) {
        final adapter = NetworkAdapter(timeout: const Duration(seconds: 5));
        String? result;
        Object? failure;
        unawaited(
          adapter
              .execute(
                () => Future.delayed(const Duration(seconds: 4), () => 'OK'),
              )
              .then<void>(
                (value) => result = value,
                onError: (Object error) => failure = error,
              ),
        );
        clock.flushMicrotasks();
        clock.elapse(const Duration(seconds: 3));
        expect(result, isNull);
        expect(failure, isNull);
        clock.elapse(const Duration(seconds: 1));
        expect(result, 'OK');
        expect(failure, isNull);
      });
    },
  );
}
