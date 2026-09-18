import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/institucion_deportiva.dart';

/// Estado de carga de las instalaciones y control de reintentos manuales.
class InstitucionesLoadViewModel extends ChangeNotifier {
  InstitucionesLoadViewModel({
    required Future<List<InstitucionDeportiva>> Function() fetchInstituciones,
  }) : _fetchInstituciones = fetchInstituciones;

  final Future<List<InstitucionDeportiva>> Function() _fetchInstituciones;
  List<InstitucionDeportiva> instituciones = [];
  Object? error;
  bool isLoading = false;
  bool isRetrying = false;
  int failedManualRetries = 0;
  int cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _disposed = false;

  bool get canRetry => error != null && !isLoading && cooldownSeconds == 0;

  Future<void> load() => _execute(manualRetry: false);

  Future<void> retry() async {
    if (!canRetry || _disposed) return;
    await _execute(manualRetry: true);
  }

  Future<void> _execute({required bool manualRetry}) async {
    if (_disposed || isLoading || cooldownSeconds > 0) return;
    isLoading = true;
    isRetrying = manualRetry;
    if (!manualRetry) error = null;
    notifyListeners();
    try {
      final result = await _fetchInstituciones();
      if (_disposed) return;
      instituciones = result;
      error = null;
      failedManualRetries = 0;
    } catch (failure) {
      if (_disposed) return;
      error = failure;
      if (manualRetry) {
        failedManualRetries++;
        if (failedManualRetries >= 3) _startCooldown();
      }
    } finally {
      if (!_disposed) {
        isLoading = false;
        isRetrying = false;
        notifyListeners();
      }
    }
  }

  void _startCooldown() {
    cooldownSeconds = 10;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      cooldownSeconds--;
      if (cooldownSeconds == 0) {
        timer.cancel();
        failedManualRetries = 0;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
