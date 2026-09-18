# Evidencia del ejercicio 3 — Examen tipo 4

## Código que debes capturar

1. En `lib/core/network/network_adapter.dart`, captura `execute`: `on TimeoutException` lanza `NetworkFailureType.timeout`; el segundo bloque detecta sockets y `http.ClientException` y lanza `NetworkFailureType.disconnected`. `rethrow` conserva los demás errores.
2. En `lib/core/network/network_failure.dart`, captura la clase que convierte estos tipos en **Tiempo agotado** y **Sin conexión**.
3. En `lib/features/home/viewmodels/instituciones_load_viewmodel.dart`, captura `errorMessage` y el bloque `finally` de `_execute`: `isLoading` e `isRetrying` pasan a `false` y `notifyListeners()` actualiza la pantalla.
4. En `lib/features/home/views/home_view.dart`, captura el `Text` que utiliza `_instalaciones.errorMessage`.

`socket_failure_io.dart` reconoce `SocketException` en Android y otras plataformas con dart:io. Su importación condicional mantiene la compilación web, donde el cliente HTTP informa fallos de transporte mediante `ClientException`.

## Explicación para el PDF

«El adaptador intercepta las excepciones de timeout y transporte y las transforma en errores de dominio con mensajes Tiempo agotado y Sin conexión. El controlador almacena el error y siempre desactiva los indicadores de carga en finally. La vista escucha los cambios y muestra el mensaje correspondiente junto al botón Reintentar.»

## Verificación

`01_sin_conexion.png` es una captura auténtica del emulador con Wi-Fi y datos desactivados temporalmente. Muestra **Sin conexión**, sin spinner y con Reintentar habilitado. Ambos servicios se restauraron después.

El timeout se comprobó con reloj simulado y una respuesta demorada cuatro segundos: a los tres segundos aparece **Tiempo agotado** con carga desactivada; la respuesta tardía no borra el error. También se verificaron `SocketException` y `ClientException` durante un reintento: ambos muestran **Sin conexión** y desactivan los dos indicadores.

```sh
flutter test test/network_failure_state_test.dart test/network_adapter_test.dart test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```

Resultado: **12 pruebas aprobadas**. Para una captura de terminal, ejecuta este comando y captura la salida junto al comando. No se ha fabricado una captura de timeout en producción: su comprobación está en las pruebas.

El análisis estático no encontró errores ni advertencias; aparecen cuatro avisos informativos anteriores por `withOpacity` obsoleto en la vista de Inicio.

Este ítem exige una captura del código que intercepta y transforma las fallas. Los ejercicios 4 y 5 se presentarán por separado.
