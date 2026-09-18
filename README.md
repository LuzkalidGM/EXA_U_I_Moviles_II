# GameOn Mobile

App móvil Flutter para reservas deportivas y pagos seguros con PayPal.

## Características principales
- Reserva de canchas y áreas deportivas.
- Gestión de horarios y disponibilidad.
- Pago seguro integrado con PayPal (WebView embebido).
- Conversión automática de moneda (Soles a USD).
- Estados de reserva: Pendiente, Confirmada, En curso, Completada.
- Persistencia de datos de pago (monto, método, fecha, orderId).
- Experiencia de usuario moderna y profesional.

## Estructura del proyecto
- `lib/features/home/`: Pantallas y lógica de inicio.
- `lib/features/reservas/`: Lógica de reservas, ViewModels y vistas.
- `lib/features/reservas/viewmodels/`: MVVM para reservas y pagos.
- `lib/features/reservas/views/`: UI de resumen, calendario y pago.
- `lib/features/reservas/services/paypal_service.dart`: Integración con PayPal vía Supabase Edge Functions.
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`: Soporte multiplataforma.

## Instalación y ejecución
1. Instala Flutter **3.35.7** (Dart **3.9.2**): https://docs.flutter.dev/get-started/install
	Para Android, utiliza el SDK **36**, las herramientas `cmdline-tools` y el JDK **21** incluido en Android Studio. Esta versión de Flutter es compatible con el Gradle **8.12** del proyecto; Flutter 3.47 requiere actualizar Gradle.
2. Clona el repositorio:
	```sh
	git clone https://github.com/LuzkalidGM/EXA_U_I_Moviles_II.git
	cd EXA_U_I_Moviles_II
	```
3. Instala dependencias:
	```sh
	flutter pub get
	```
4. Ejecuta la app:
	```sh
	flutter run --debug -d emulator-5554
	```
	Inicia primero un emulador desde Android Studio o con `flutter emulators --launch Pixel_8_Pro`. Si utilizas otro dispositivo, consulta su identificador con `flutter devices` y reemplaza `emulator-5554`.

## Configuración de PayPal
- Sandbox: Usar credenciales de prueba en Edge Function.
- Producción: Cambiar a credenciales live y endpoint real.

## Examen tipo 4 — Ejercicio 1: reintento manual

Las instalaciones de Inicio se vuelven a consultar tras iniciar sesión. Ante un fallo, la pantalla muestra un botón **Reintentar**. Durante la petición, el botón queda deshabilitado y muestra un spinner local. Tres reintentos manuales consecutivos fallidos lo bloquean durante diez segundos; al terminar ese plazo se habilita sin realizar una petición automática. Una respuesta correcta reinicia el contador.

Archivos afectados:
- `lib/features/home/viewmodels/instituciones_load_viewmodel.dart`: estado de carga, reintento manual, contador y temporizador de bloqueo.
- `lib/features/home/views/home_view.dart`: recarga tras login, vista de error y botón con progreso y cuenta regresiva.
- `test/instituciones_retry_test.dart`: tres pruebas del control de reintentos, duplicados y bloqueo.
- `pubspec.yaml` y `pubspec.lock`: dependencia directa `fake_async` para comprobar el temporizador sin esperar diez segundos reales.
- `evidencias/ejercicio_1/`: capturas reales del emulador, resultado de pruebas y guía para el PDF.

Verificación:
```sh
flutter test test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```
Resultado: **7 pruebas aprobadas** (3 de reintento y 4 de login). Estas pruebas corresponden a la verificación del primer ejercicio y del login existente; los ejercicios 2 a 5 aún están pendientes.

Consulta la [guía de evidencias del ejercicio 1](evidencias/ejercicio_1/README.md).

## Examen tipo 4 — Ejercicio 2: timeout configurable

La consulta de instalaciones utiliza un adaptador de red cuyo constructor recibe `Duration timeout`. La factoría configura **3 segundos** fuera de las pantallas. `HomeViewModel` permite inyectar otro adaptador y aplica el límite en cada consulta, incluidos los reintentos manuales.

Archivos afectados:
- `lib/core/network/network_adapter.dart`: constructor configurable y aplicación del límite mediante `Future.timeout`.
- `lib/core/network/network_config.dart`: factoría con la configuración de tres segundos.
- `lib/features/home/viewmodels/home_viewmodel.dart`: inyección del adaptador y ejecución de la consulta Supabase a través de él.
- `test/network_adapter_test.dart`: verifica el vencimiento a los tres segundos y un límite alternativo de cinco segundos.
- `evidencias/ejercicio_2/README.md`: guía para capturar y explicar el código.

```sh
flutter test test/network_adapter_test.dart test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```
Resultado al completar este ítem: **9 pruebas aprobadas**. El análisis de los archivos del ejercicio 2 no encontró problemas. La transformación de errores se incorpora en el ejercicio 3, descrito a continuación.

Consulta la [guía de evidencias del ejercicio 2](evidencias/ejercicio_2/README.md).

## Examen tipo 4 — Ejercicio 3: errores de conectividad

El adaptador transforma `TimeoutException` en el error de aplicación **Tiempo agotado** y `SocketException` o `http.ClientException` en **Sin conexión**. La pantalla muestra el mensaje del error de dominio. El controlador termina la carga general y el progreso local del reintento en su bloque `finally`; conserva el reintento manual del ejercicio 1. Los errores ajenos a transporte se propagan sin convertirlos en desconexión.

Archivos afectados:
- `lib/core/network/network_adapter.dart`: captura y transformación de errores.
- `lib/core/network/network_failure.dart`: tipos y mensajes del error de aplicación.
- `lib/core/network/socket_failure_io.dart` y `socket_failure_stub.dart`: detección de sockets mediante importación condicional, compatible con Android y web.
- `lib/features/home/viewmodels/instituciones_load_viewmodel.dart`: expone `errorMessage` para la vista.
- `lib/features/home/views/home_view.dart`: muestra el mensaje semántico.
- `test/network_adapter_test.dart`: valida el nuevo error de dominio al vencer el límite.
- `test/network_failure_state_test.dart`: valida timeout, socket y transporte web, con indicadores de carga desactivados.
- `evidencias/ejercicio_3/`: captura real sin conexión y guía para el PDF.

```sh
flutter test test/network_failure_state_test.dart test/network_adapter_test.dart test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```
Resultado: **12 pruebas aprobadas**. El análisis de los archivos modificados no encontró errores ni advertencias; la vista conserva cuatro avisos informativos anteriores de `withOpacity` obsoleto. Se verificó **Sin conexión** en el emulador con Wi-Fi y datos temporalmente desactivados, y se restauró la conexión al terminar.

Consulta la [guía de evidencias del ejercicio 3](evidencias/ejercicio_3/README.md). La presentación de los ejercicios 4 y 5 todavía está pendiente.

## Examen tipo 4 — Ejercicio 4: tres pruebas con cliente simulado

`test/ejercicio_4_test.dart` utiliza `http.MockClient` inyectado en un cliente Supabase aislado, sin conexión al backend ni emulador. Ejecuta exactamente los tres casos del enunciado:
- Arranque limpio: sesión nula, estado sin datos ni error y cero peticiones.
- Respuesta exitosa HTTP 200: consulta la tabla y filtro reales, convierte el JSON a instalaciones y notifica el cambio del estado.
- Error de servidor HTTP 500: conserva `PostgrestException`, desactiva la carga y registra una única petición, sin reintento automático.

Archivos afectados:
- `lib/features/home/viewmodels/home_viewmodel.dart`: acepta un cliente Supabase opcional por constructor y expone `hasSession`; la app continúa utilizando su cliente compartido cuando no se inyecta otro.
- `test/ejercicio_4_test.dart`: mock HTTP, datos ficticios y las tres pruebas unitarias.
- `evidencias/ejercicio_4/pruebas.txt`: salida íntegra de la ejecución aprobada.
- `evidencias/ejercicio_4/README.md`: instrucciones para la captura de terminal y explicación para el PDF.

```sh
flutter test test/ejercicio_4_test.dart --reporter expanded
```
Resultado: **3 pruebas aprobadas**. Las 12 pruebas anteriores también pasaron (15 verificadas en total). El análisis de los archivos de este ítem no encontró problemas. Consulta la [guía de evidencias del ejercicio 4](evidencias/ejercicio_4/README.md).

## Examen tipo 4 — Ejercicio 5: pruebas de timeout y desconexión

`test/ejercicio_5_test.dart` contiene exactamente las dos pruebas especializadas del enunciado:
- Una respuesta simulada demorada **4 segundos**, superior al límite configurado de **3 segundos**, produce **Tiempo agotado** y desactiva la carga. Se comprueba el límite exacto y que la respuesta tardía no elimina el error.
- Una `SocketException` forzada produce **Sin conexión** y desactiva la carga general y el progreso del reintento manual.

Se trasladaron a este archivo los casos de timeout y socket que se verificaban durante el ejercicio 3, ampliando sus comprobaciones. `test/network_failure_state_test.dart` conserva el caso adicional de transporte web; no se duplican las pruebas.

Archivos afectados:
- `test/ejercicio_5_test.dart`: dos pruebas especializadas con el adaptador y controlador reales.
- `test/network_failure_state_test.dart`: conserva la verificación de `ClientException` web.
- `evidencias/ejercicio_5/pruebas.txt`: salida íntegra de las dos pruebas aprobadas.
- `evidencias/ejercicio_5/pruebas_completas.txt`: salida de la verificación conjunta de los seis archivos de pruebas.
- `evidencias/ejercicio_5/README.md`: guía de capturas y explicación técnica.

```sh
flutter test test/ejercicio_5_test.dart --reporter expanded
```
Resultado: **2 pruebas aprobadas**, sin conexión ni emulador. El análisis de ambos archivos modificados no encontró problemas.

Verificación conjunta:
```sh
flutter test test/ejercicio_4_test.dart test/ejercicio_5_test.dart test/network_failure_state_test.dart test/network_adapter_test.dart test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```
Resultado: **15 pruebas aprobadas**.

Los cinco ejercicios del tipo 4 están implementados y su código está subido al repositorio. Las referencias a pendientes en las secciones anteriores describen el avance al completar cada etapa. Queda preparar las capturas del editor y terminal, reunirlas en el PDF con carátula y nombre exigido, y realizar la sustentación. Consulta la [guía de evidencias del ejercicio 5](evidencias/ejercicio_5/README.md).

## Notas técnicas
- El flujo de pago se realiza dentro de la app usando WebView.
- El overlay de carga cubre toda la pantalla durante el procesamiento de pago y reserva.
- El tipo de cambio es configurable (por defecto 3.7).

## Contacto y soporte
- Autor: 
- Issues y soporte: Usar el sistema de issues de GitHub.

---
¡Gracias por usar GameOn Mobile!
