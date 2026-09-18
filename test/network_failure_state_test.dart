import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:gameon/core/network/network_config.dart';
import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:gameon/features/home/viewmodels/instituciones_load_viewmodel.dart';

void main() {
  // Timeout y SocketException se verifican en ejercicio_5_test.dart.
  for (final failure in [http.ClientException('Failed to fetch')]) {
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
