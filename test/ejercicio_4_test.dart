import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameon/features/home/viewmodels/home_viewmodel.dart';
import 'package:gameon/features/home/viewmodels/instituciones_load_viewmodel.dart';

void main() {
  late SupabaseClient client;
  late HomeViewModel service;
  late InstitucionesLoadViewModel state;
  late Future<http.Response> Function(http.Request) respond;
  var requests = 0;

  setUp(() {
    requests = 0;
    respond = (request) async => http.Response('[]', 200, request: request);
    client = SupabaseClient(
      'https://gameon-test.example.invalid',
      'test-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) {
        requests++;
        return respond(request);
      }),
    );
    service = HomeViewModel(client: client);
    state = InstitucionesLoadViewModel(
      fetchInstituciones: service.fetchInstituciones,
    );
  });

  tearDown(() async {
    state.dispose();
    await client.dispose();
  });

  test('(a) Arranque limpio: sin sesión preexistente ni peticiones', () {
    expect(client.auth.currentSession, isNull);
    expect(service.hasSession, isFalse);
    expect(state.instituciones, isEmpty);
    expect(state.error, isNull);
    expect(state.isLoading, isFalse);
    expect(requests, 0);
  });

  test(
    '(b) Respuesta HTTP exitosa: actualiza el estado con instalaciones',
    () async {
      final response = Completer<void>();
      respond = (request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/rest/v1/instituciones_deportivas');
        expect(request.url.queryParameters['estado'], 'eq.1');
        await response.future;
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'usuario_instalacion_id': 10,
              'nombre': 'Cancha de prueba GameOn',
              'direccion': 'Tacna',
              'latitud': -18.0,
              'longitud': -70.2,
              'tarifa': 50,
              'telefono': '000000000',
              'email': 'cancha@example.invalid',
              'estado': 1,
            },
          ]),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      };
      var changes = 0;
      state.addListener(() => changes++);
      final load = state.load();
      expect(state.isLoading, isTrue);
      response.complete();
      await load;
      expect(state.error, isNull);
      expect(state.instituciones, hasLength(1));
      expect(state.instituciones.single.nombre, 'Cancha de prueba GameOn');
      expect(state.instituciones.single.tarifa, 50.0);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
      expect(changes, 2);
      expect(requests, 1);
    },
  );

  test(
    '(c) Error HTTP de servidor: estado de error sin reintentos automáticos',
    () async {
      respond = (request) async => http.Response(
        jsonEncode({'code': 'XX000', 'message': 'Error de servidor simulado'}),
        500,
        request: request,
        headers: {'content-type': 'application/json'},
      );
      await state.load();
      expect(state.error, isA<PostgrestException>());
      expect(
        (state.error as PostgrestException).message,
        'Error de servidor simulado',
      );
      expect(state.instituciones, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isRetrying, isFalse);
      expect(state.failedManualRetries, 0);
      expect(state.canRetry, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(requests, 1);
    },
  );
}
