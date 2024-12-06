
import 'dart:ui';

import 'package:bcssdk_client/verify_result.dart';

import 'bcssdk_platform_interface.dart';

class Bcssdk {

  Future<VerifyResult> faceVerify(String code) async {
   return BcssdkPlatform.instance.faceVerify(code);
  }

  Future<void> setUrlService(String url) async {
    return BcssdkPlatform.instance.setUrlService(url);
  }

  Future<void> setColors(Color primary, Color onPrimary) async {
    await BcssdkPlatform.instance.setColors(primary, onPrimary);
  }

  String colorToHex(Color color) {
    String hexColor = color.value.toRadixString(16).padLeft(8, '0');
    return '#${hexColor.substring(2)}'; // Omite los dos primeros caracteres que corresponden al alfa
  }
}
