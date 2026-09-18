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

## Notas técnicas
- El flujo de pago se realiza dentro de la app usando WebView.
- El overlay de carga cubre toda la pantalla durante el procesamiento de pago y reserva.
- El tipo de cambio es configurable (por defecto 3.7).

## Contacto y soporte
- Autor: 
- Issues y soporte: Usar el sistema de issues de GitHub.

---
¡Gracias por usar GameOn Mobile!
