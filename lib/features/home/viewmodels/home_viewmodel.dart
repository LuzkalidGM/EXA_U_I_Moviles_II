import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer; // Para logs más estructurados
import 'package:gameon/core/network/network_adapter.dart';
import 'package:gameon/core/network/network_config.dart';

// Sugerencia: si prefieres usar debugPrint en lugar de developer.log,
// reemplaza developer.log(...) por debugPrint(...).

// ViewModel encargado de la lógica para obtener instalaciones deportivas
class HomeViewModel {
  HomeViewModel({NetworkAdapter? networkAdapter, SupabaseClient? client})
    : _networkAdapter = networkAdapter ?? NetworkConfig.createAdapter(),
      _client = client;

  final NetworkAdapter _networkAdapter;
  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;
  bool get hasSession => _supabase.auth.currentSession != null;

  // Obtiene la lista de instalaciones deportivas activas desde Supabase
  Future<List<InstitucionDeportiva>> fetchInstituciones() async {
    final client = _supabase;

    // Log de sesión / autenticación
    developer.log(
      'fetchInstituciones: iniciando. Authenticated=$hasSession userId=${client.auth.currentUser?.id}',
      name: 'HomeViewModel',
    );

    try {
      developer.log(
        'fetchInstituciones: ejecutando query instituciones_deportivas (estado=1)...',
        name: 'HomeViewModel',
      );

      // Realiza la consulta a la tabla 'instituciones_deportivas' filtrando por estado = 1
      final data = await _networkAdapter.execute(
        () => client.from('instituciones_deportivas').select().eq('estado', 1),
      );

      developer.log(
        'fetchInstituciones: respuesta raw tipo=${data.runtimeType} tamaño=${data.length}',
        name: 'HomeViewModel',
      );

      // Convierte la respuesta en una lista de objetos InstitucionDeportiva
      final lista = (data as List)
          .map((json) => InstitucionDeportiva.fromJson(json))
          .toList();

      developer.log(
        'fetchInstituciones: mapeo completado. Registros=${lista.length}',
        name: 'HomeViewModel',
      );

      return lista;
    } on PostgrestException catch (e, st) {
      // Logs detallados de la excepción de Postgrest (RLS / permisos / sintaxis)
      developer.log(
        'PostgrestException al consultar instituciones. code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}',
        name: 'HomeViewModel',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow; // Permite que la UI lo capture y muestre
    } catch (e, st) {
      developer.log(
        'Error inesperado al consultar instituciones: $e',
        name: 'HomeViewModel',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    } finally {
      developer.log('fetchInstituciones: finalizado', name: 'HomeViewModel');
    }
  }
}
