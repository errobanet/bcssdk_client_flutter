# bcssdk

Plugin de flutter para eluso de BCSSDK

## Instalacion componente BCS
Para poder utilizar BCS de forma rápida edita el archivo `pubspec.yaml` y agrega la dependencia de `bcssdk_client`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  #Otras dependencias
  bcssdk_client: ^1.3.2
```
<aside class="positive">
No olvides hacer el 'flutter pub get'
</aside>

## Primeros pasos

Este es un proyecto de uso de BCSSDK para verificaciones de identidad.
El ejemplo de este repositorio NO tiene las dependencias de framework.
* Android: archivo bcssdk.1.x.x.aar
* iOS: bcssdk.xcframework

Los mismos son provistos al equipo de desarrollo por erroba.

## Permisos
La verificación de identidad con rostro necesita algunos permisos en el dispositivo:
* Cámara
* Micrófono

Estos permisos debes solicitarlos con tu app, en el ejemplo podes ver como hacerlo con el widget de permissions_handler.

## Librerias nativas - Android

Primero vamos a copiar algunas librerias nativas que son necesarias que funcione el proyecto.

1. Copia el archivo `bcssdk-x.x.x.aar` a la carpeta `android/app/libs`
2. Edita el archivo `android/app/build.gradle`, cambia la `minSdk` por `26` y agrega la dependencia `implementation files('libs/bcssdk-1.x.x.aar')`:

Debería quedarte algo así:

![image_caption](https://raw.githubusercontent.com/errobanet/bcssdk_client_flutter/main/images/android.png)

## Librerias nativas - iOS

Para iOS es necesario referenciar el bcssdk.xcframework en el proyecto del Runner.

1. Abre el Runner con Xcode
2. Referencia el framework bcssdk.xcframework (lo puedes arrastrar desde finder y elige la opcion copy files)
3. En la configuración general del Runner, chequea que el framework este referenciado y este como "Embed & Sign":

![image_caption](https://raw.githubusercontent.com/errobanet/bcssdk_client_flutter/main/images/ios_ref01.png)

4. En Build Phases, en la seccion de "Copy Bundle Resources", agrega "bcssdk.xcframework"

![image_caption](https://raw.githubusercontent.com/errobanet/bcssdk_client_flutter/main/images/ios_ref02.png)

## Utilización del cliente

A continuacion vamos a mostrar el uso suponiendo que ya tenemos un código de transacción para verificar.

### Verificación

Ya tenemos todo configurado, vamos a usar el cliente!

Para llamar a la verificación solo tenes que llamar la función `_bcsPlugin.faceVerify(code);`

Te dejamos un ejemplo de chequeo de permisos y llamada. Poniendo este código en un Widget solo tenes que llamar a la función `processVerifyAsync(code)` con el código generado en el servidor.

```dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'bcs_face_verify.dart';

Future processVerifyAsync(String code) async{
    final checkPermissions = await this._checkPermissions();
    if (!checkPermissions) {
      /// Manejar permisos denegados
    }
    else {
      var result = await _verifyFace(code);
      /// manejo de respuesta
    }
  }

  Future<VerifyResult> _verifyFace(String code) async {
    return _bcsPlugin.faceVerify(code);
  }

  Future<bool> _checkPermissions() async {
    var p1 = await Permission.camera.request();
    var p2 = await Permission.microphone.request();
    return p1.isGranted && p2.isGranted;
  }
```

### Respuestas

La respuesta de la llamada a `faceVerify` es una enumeración de `VerifyResult`. Puede ser uno de los siguientes valores:

* DONE
* CANCELED
* PERMISSIONS_ERROR
* CONNECTION_ERROR
* TRANSACTION_NOT_FOUND


> Según la respuesta obtenida es la acción que debes realizar en tu app.

#### DONE

La operación finalizó en el servidor, debes obtener el resultado desde tu backend, puede ser tanto Verificado como NO verificado.

#### CANCELED

El usuario canceló la operación, generalmente con la opción o gesto de volver.

#### PERMISSIONS_ERROR

Esta respuesta se da cuando no hay permisos para cámara y microfono, debes haberlos solicitado antes y verificarlos.

#### CONNECTION_ERROR

No fue posible conectar con los servidores de BCS, puede deberse a un problema de conectividad entre el dispositivo e internet/servidores de BCS.

#### TRANSACTION_NOT_FOUND

No se encontró la transacción x el identificador `code`. Ten en cuenta que después de creada solo puede ser procesada en un período corto de tiempo.

## Estilos

La interfaz de la verificación es minimalista, el único control de interacción con el usuario es un botón para `Reintentar` la operación.

Podes establecer los colores para los controles llamando a la función `setColors` del plugin.

```dart
  Future<void> _initializePluginColors() async {
    // Obtener los colores del tema actual y se los paso al plugin.
    Color primary = Theme.of(context).colorScheme.primary;
    Color onPrimary = Theme.of(context).colorScheme.onPrimary;
    await _bcsPlugin.setColors(primary, onPrimary);
  }
```

## Ambiente QA/Docker

Por defecto el cliente utiliza el ambiente productivo. Si deseas usar al ambiente de calidad o desarrollo con docker podes cambiar la URL de los servicios.

Para hacerlo está disponible la función `setUrlService` en la api.

```dart
  Future<VerifyResult> _verifyFace(String code) async {
    await _bcsPlugin.setUrlService("https://url_ambiente");
    return _bcsPlugin.faceVerify(code);
  }
```

> No dejes este código en el RELEASE de tu aplicación.

## Servicio BCS

Para utilizar la verificación, previamente debes haber generado un código de transacción desde el backend de tu aplicación.

![image_caption](https://raw.githubusercontent.com/errobanet/bcssdk_client_flutter/main/images/app_seq.png)


>Es recomendable NO exponer en tus APIS la identificación de la persona, sino hacerlo sobre algún identificador de onboarding o transacción. De esta froma podés prevenir el uso de tu API por terceros.


