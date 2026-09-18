# Evidencias del ejercicio 1 — Examen tipo 4

## Capturas reales del emulador

1. `01_error.png`: error al cargar instalaciones y botón Reintentar visible.
2. `02_bloqueo.png`: bloqueo temporal tras tres reintentos manuales fallidos; la captura muestra nueve segundos restantes.
3. `03_recuperado.png`: instalaciones cargadas mediante reintento manual después de restaurar la conexión.

Para obtenerlas se desactivó temporalmente Wi-Fi y datos únicamente en el emulador. Al terminar se restauraron ambos. No se cambió el backend ni se insertaron errores artificiales en el código de producción.

## Código que debes capturar para el PDF

Abre `lib/features/home/viewmodels/instituciones_load_viewmodel.dart` y captura `retry`, `_execute` y `_startCooldown`. Explica que el fallo inicial no cuenta como reintento manual, que `isLoading` evita peticiones simultáneas y que el temporizador habilita el botón sin llamar al servicio.

En `lib/features/home/views/home_view.dart`, captura el bloque `AnimatedBuilder` con el botón `ElevatedButton.icon`: `canRetry` controla su habilitación, `isRetrying` muestra el spinner local y `cooldownSeconds` muestra la cuenta regresiva.

La transición de sesión en `_onPerfilVmChange` vuelve a cargar las instalaciones después del login.

## Pruebas

```sh
flutter test test/instituciones_retry_test.dart test/login_page_test.dart --reporter expanded
```

`pruebas.txt` conserva la salida con siete pruebas aprobadas. Para una captura de terminal, ejecuta el comando en tu entorno y captura el comando junto con la salida. Las tres pruebas nuevas comprueban ausencia de reintento automático, progreso y prevención de duplicados, y bloqueo de diez segundos. Las otras cuatro verifican el login existente.

Para este ítem, el enunciado exige capturar el código del reintento, la UI de error y un reintento exitoso o el bloqueo temporal. Todavía no se ha creado el PDF final ni desarrollado los ejercicios 2 a 5.
