# Evidencia del ejercicio 4 — Examen tipo 4

## Captura de terminal requerida

Desde la raíz del proyecto, ejecuta:

```sh
flutter test test/ejercicio_4_test.dart --reporter expanded
```

Captura el comando y la salida completa de las tres pruebas, incluyendo `+3: All tests passed!`. Amplía el terminal si las líneas no caben. `pruebas.txt` conserva la salida íntegra de la ejecución aprobada; no sustituye la captura del terminal que pide el enunciado.

## Qué comprueba cada caso

- **(a) Arranque limpio:** cada prueba crea un cliente Supabase nuevo sin restaurar almacenamiento local. La sesión es nula, `hasSession` es falso y el controlador inicia sin carga, datos ni error. El mock registra cero peticiones.
- **(b) Simulación exitosa:** el cliente HTTP simulado responde 200 con JSON de una instalación ficticia. Se valida la consulta GET a la tabla real con `estado=eq.1`, el paso por carga, los datos convertidos a `InstitucionDeportiva`, la salida del progreso y las notificaciones del controlador.
- **(c) Error de servidor:** el mock devuelve HTTP 500 y un error JSON. Se comprueba `PostgrestException`, ausencia de datos, indicadores desactivados y una sola llamada HTTP después de dejar pasar el siguiente ciclo de ejecución. Reintentar queda disponible, pero no se ejecuta automáticamente.

## Explicación técnica para el PDF

«Se inyectó un cliente HTTP simulado en un cliente Supabase aislado. Las pruebas ejecutan HomeViewModel, el adaptador y el controlador reales, comprobando el estado inicial sin sesión, el mapeo y actualización del estado ante HTTP 200, y la transición a error ante HTTP 500 sin reintentos automáticos. El mock intercepta las solicitudes, por lo que no se necesita backend ni emulador.»

No se utilizan la cuenta de prueba, claves reales ni tokens. El dominio `.invalid` y la clave ficticia solo sirven para construir el cliente de pruebas. La renovación automática de tokens está desactivada y cada cliente se libera en `tearDown`.

## Código de apoyo para la sustentación

En `test/ejercicio_4_test.dart`, revisa `setUp`, `MockClient`, los tres casos y `tearDown`. Las respuestas HTTP incluyen `request` porque el parser de Supabase utiliza los metadatos de la petición original.

En `lib/features/home/viewmodels/home_viewmodel.dart`, revisa la inyección opcional de `SupabaseClient`: producción usa `Supabase.instance.client`; las pruebas usan su cliente aislado. No se simulan los resultados del controlador: los JSON pasan por el servicio y el modelo reales.

Se verificaron las tres pruebas de este ítem y las doce anteriores. El ejercicio 5 se presentará por separado.
