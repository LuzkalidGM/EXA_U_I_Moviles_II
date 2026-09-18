# Evidencia del ejercicio 2 — Examen tipo 4

El enunciado pide una captura del constructor del cliente o adaptador que muestre el parámetro configurable del timeout.

## Capturas que debes tomar en el editor

1. Abre `lib/core/network/network_adapter.dart` y captura la clase completa. `NetworkAdapter({required this.timeout})` recibe la duración por constructor; rechaza duraciones no positivas. `execute` aplica `.timeout(timeout)` a la petición recibida y devuelve su resultado o error.
2. Abre `lib/core/network/network_config.dart` y captura la factoría completa. Aquí se configura `Duration(seconds: 3)`, fuera de las pantallas.
3. Como evidencia de integración, captura el constructor de `HomeViewModel` y la llamada `_networkAdapter.execute` en `lib/features/home/viewmodels/home_viewmodel.dart`. La consulta real de Supabase pasa por el adaptador, también cuando el usuario pulsa Reintentar.

## Explicación técnica para el PDF

«Se incorporó un adaptador de red que recibe el tiempo de espera por constructor. Una factoría configura tres segundos y HomeViewModel permite inyectar otro adaptador. Cada consulta de instalaciones se ejecuta mediante este adaptador; si no concluye dentro del límite, Future.timeout finaliza la espera con TimeoutException y el controlador del ejercicio 1 abandona el estado de carga.»

El límite termina la espera del cliente; `Future.timeout` no cancela la petición subyacente. Una respuesta tardía no reemplaza el error ni actualiza las instalaciones porque la carga espera el Future limitado.

## Verificación realizada

```sh
flutter test test/network_adapter_test.dart test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```

Nueve pruebas aprobadas. Las dos nuevas comprueban que una petición pendiente vence exactamente a los tres segundos, y que con un límite inyectado de cinco segundos una respuesta de cuatro segundos se recibe correctamente. El reloj simulado evita esperar segundos reales y no utiliza conexión ni emulador.

```sh
flutter analyze lib/core/network lib/features/home/viewmodels/home_viewmodel.dart test/network_adapter_test.dart
```

Resultado: `No issues found!`.

Al completar el ejercicio 2, los mensajes de dominio estaban pendientes. Se incorporaron posteriormente en el ejercicio 3; consulta su guía. La presentación de los ejercicios 4 y 5 sigue pendiente.
