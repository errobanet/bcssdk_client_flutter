package net.erroba.bcssdk_client

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
/** BcssdkPlugin */
class BcssdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext;
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bcssdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "faceVerify") {
      val code = call.argument<String>("code")
      faceVerify(code!!, result)
    }
    else if (call.method == "setUrlService") {
      val url = call.argument<String>("url")
      setUrlService(url!!, result)
    }
    else if (call.method == "setColors") {
      val primary = call.argument<String>("primary")
      val onPrimary = call.argument<String>("onPrimary")
      setColors(primary!!,onPrimary!!, result)
    }
    else {
      result.notImplemented()
    }
  }

  private fun faceVerify(code: String, result: MethodChannel.Result) {
    try {
      // Usa reflexión para acceder a las clases del .aar en tiempo de ejecución
      val bcsClientClass = Class.forName("net.erroba.bcssdk.BCSClient")
      val verifyCallbackClass = Class.forName("net.erroba.bcssdk.VerifyCallback")

      val verifyCallback = java.lang.reflect.Proxy.newProxyInstance(
        verifyCallbackClass.classLoader,
        arrayOf(verifyCallbackClass)
      ) { _, method, args ->
        if (method.name == "onResult" && args != null) {
          result.success(args[0].toString()) // Captura la respuesta del callback
        }
        null
      }

      val startVerifyMethod = bcsClientClass.getMethod(
        "startVerify",
        Context::class.java,
        String::class.java,
        verifyCallbackClass
      )

      startVerifyMethod.invoke(null, context, code, verifyCallback)
    } catch (e: Exception) {
      result.error("AAR_ERROR", "Failed to access BCSClient: ${e.message}", null)
    }
  }

  private fun setColors(primary: String, onPrimary: String, result: MethodChannel.Result) {
    try {
      // Accede a la clase BCSClient
      val bcsClientClass = Class.forName("net.erroba.bcssdk.BCSClient")

      // Obtén el método setColors(String, String)
      val setColorsMethod = bcsClientClass.getMethod("setColors", String::class.java, String::class.java)

      // Invoca el método con los parámetros dados
      val success = setColorsMethod.invoke(null, primary, onPrimary) as Boolean

      if (success) {
        result.success("OK")
      } else {
        result.error("VALIDATION", "Invalid color. Format: #001122", null)
      }
    } catch (e: Exception) {
      result.error("AAR_ERROR", "Failed to access setColors: ${e.message}", null)
    }
  }

  private fun setUrlService(url: String, result: MethodChannel.Result) {
    try {
      // Accede a la clase BCSClient
      val bcsClientClass = Class.forName("net.erroba.bcssdk.BCSClient")

      // Obtén el método setUrlService(String)
      val setUrlServiceMethod = bcsClientClass.getMethod("setUrlService", String::class.java)

      // Invoca el método con el parámetro dado
      val success = setUrlServiceMethod.invoke(null, url) as Boolean

      if (success) {
        result.success("OK")
      } else {
        result.error("VALIDATION", "Invalid url", null)
      }
    } catch (e: Exception) {
      result.error("AAR_ERROR", "Failed to access setUrlService: ${e.message}", null)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
