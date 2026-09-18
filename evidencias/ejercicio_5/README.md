# Evidencia del ejercicio 5 — Examen tipo 4

## Capturas requeridas

1. Abre `test/ejercicio_5_test.dart` y captura el código de las dos pruebas en imágenes legibles. Puedes tomar una captura por caso.
2. Ejecuta en el terminal desde la raíz del proyecto:

```sh
flutter test test/ejercicio_5_test.dart --reporter expanded
```

Captura el comando y la salida completa, con los casos (a), (b) y `+2: All tests passed!`. `pruebas.txt` conserva la salida auténtica de la ejecución aprobada; para el PDF se necesita también la captura de terminal.

## Explicación técnica

**(a) Timeout:** el doble de prueba devuelve un Future que responde después de cuatro segundos. Se utiliza la factoría real con límite de tres segundos. El reloj simulado permite comprobar que a los 2.999 segundos todavía hay carga y al llegar a tres segundos el estado contiene **Tiempo agotado**, con `isLoading` e `isRetrying` en falso. Al llegar la respuesta tardía, el error se mantiene y no se genera otra petición.

**(b) Desconexión:** el doble lanza una `SocketException`. El adaptador real la transforma en el error de aplicación **Sin conexión**. El controlador deja de cargar y permite reintentar. Se verifica también un reintento manual fallido: su spinner local se activa durante la petición y se desactiva al recibir la excepción.

Estas pruebas no usan backend, credenciales ni emulador. `fakeAsync` simula el paso del tiempo; el límite de producción sigue siendo de tres segundos reales.

## Verificación conjunta

```sh
flutter test test/ejercicio_4_test.dart test/ejercicio_5_test.dart test/network_failure_state_test.dart test/network_adapter_test.dart test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```

Resultado: **15 pruebas aprobadas**. `pruebas_completas.txt` conserva la salida. El análisis de los archivos modificados no encontró problemas.

Los casos de timeout y socket se trasladaron desde las comprobaciones del ejercicio 3 a este archivo y se ampliaron, evitando pruebas duplicadas. La prueba adicional de transporte web permanece en `network_failure_state_test.dart`.

Los cinco ejercicios están implementados. El PDF final todavía debe reunir las capturas y explicaciones de cada ítem, con carátula de tipo 4 y nombre `SI988-EXPRAC-U1-ApellidoNombre.pdf`. La sustentación y validación del docente siguen siendo parte de la entrega.
