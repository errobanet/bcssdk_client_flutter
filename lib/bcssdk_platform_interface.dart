import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bcssdk_method_channel.dart';
import 'verify_result.dart';

abstract class BcssdkPlatform extends PlatformInterface {
  /// Constructs a BcssdkPlatform.
  BcssdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static BcssdkPlatform _instance = MethodChannelBcssdk();

  /// The default instance of [BcssdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelBcssdk].
  static BcssdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BcssdkPlatform] when
  /// they register themselves.
  static set instance(BcssdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<VerifyResult> faceVerify(String code) async {
    throw UnimplementedError('faceVerify() has not been implemented.');
  }

  Future<void> setUrlService(String url) async {
    throw UnimplementedError('setUrlService() has not been implemented.');  }

  Future<void> setColors(Color primary, Color onPrimary) async {
    throw UnimplementedError('setColors() has not been implemented.');
  }
}

