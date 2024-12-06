import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bcssdk_platform_interface.dart';
import 'verify_result.dart';

/// An implementation of [BcssdkPlatform] that uses method channels.
class MethodChannelBcssdk extends BcssdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bcssdk');

  @override
  Future<VerifyResult> faceVerify(String code) async {
    var ret = await methodChannel.invokeMethod<String>('faceVerify', <String, dynamic>{'code': code});
    return VerifyResult.values.byName(ret!);
  }

  @override
  Future<void> setUrlService(String url) async {
    await methodChannel.invokeMethod<String>('setUrlService', <String, dynamic>{'url': url});
  }

  @override
  Future<void> setColors(Color primary, Color onPrimary) async {
    await methodChannel.invokeMethod<String>('setColors', <String, dynamic>{'primary': colorToHex(primary), 'onPrimary':  colorToHex(onPrimary)});
  }

  String colorToHex(Color color) {
    String hexColor = color.value.toRadixString(16).padLeft(8, '0');
    return '#${hexColor.substring(2)}'; // Omite los dos primeros caracteres que corresponden al alfa
  }
}
