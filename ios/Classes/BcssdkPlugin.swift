import Flutter
import UIKit

public class BcssdkPlugin: NSObject, FlutterPlugin {
    var result: FlutterResult?
    var viewController: UIViewController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "bcssdk", binaryMessenger: registrar.messenger())
        let instance = BcssdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Obtener el viewController actual
        if let rootVC = UIApplication.shared.delegate?.window??.rootViewController {
            instance.viewController = rootVC
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result

        switch call.method {
        case "faceVerify":
            guard let args = call.arguments as? [String: Any],
                  let code = args["code"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Código requerido", details: nil))
                return
            }
            faceVerify(code: code)
        case "setUrlService":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "URL requerida", details: nil))
                return
            }
            setUrlService(url: url)
        case "setColors":
            guard let args = call.arguments as? [String: Any],
                  let primary = args["primary"] as? String,
                  let onPrimary = args["onPrimary"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Colores requeridos", details: nil))
                return
            }
            setColors(primary: primary, onPrimary: onPrimary)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func faceVerify(code: String) {
        guard let viewController = self.viewController else {
            result?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No se pudo obtener el ViewController", details: nil))
            return
        }

        if let sdkClientClass = NSClassFromString("bcssdk.BcsSdkClient") as? NSObject.Type {
            let sdkClient = sdkClientClass.init()
            //let selector = Selector("startVerifyWithFrom:code:completion:")
            let selector = Selector("startVerifyFrom:code:completion:")

            if sdkClient.responds(to: selector) {
                let completion: (String) -> Void = { [weak self] resultado in
                    DispatchQueue.main.async {
                        self?.result?(resultado)
                    }
                }
                let invocation = { (target: AnyObject, selector: Selector, args: [Any]) -> Void in
                    let method = sdkClient.method(for: selector)
                    let implementation = unsafeBitCast(method, to: (@convention(c) (AnyObject, Selector, UIViewController, String, @escaping (String) -> Void) -> Void).self)
                    implementation(target, selector, viewController, code, completion)
                }
                invocation(sdkClient, selector, [viewController, code, completion])
                //result?("OK")
            } else {
                result?(FlutterError(code: "METHOD_NOT_FOUND", message: "Método no encontrado en BcsSdkClient", details: nil))
            }
        } else {
            result?(FlutterError(code: "CLASS_NOT_FOUND", message: "BcsSdkClient no está disponible", details: nil))
        }
    }

    private func setUrlService(url: String) {
        if let sdkClientClass = NSClassFromString("bcssdk.BcsSdkClient") as? NSObject.Type {
            let sdkClient = sdkClientClass.init()

            let selector = Selector("setUrlServiceWithUrl:")
            if sdkClient.responds(to: selector) {
                sdkClient.perform(selector, with: url)
                result?("OK")
            } else {
                result?(FlutterError(code: "METHOD_NOT_FOUND", message: "Método no encontrado en BcsSdkClient", details: nil))
            }
        } else {
            result?(FlutterError(code: "CLASS_NOT_FOUND", message: "BcsSdkClient no está disponible", details: nil))
        }
    }

    private func setColors(primary: String, onPrimary: String) {
        if let sdkClientClass = NSClassFromString("bcssdk.BcsSdkClient") as? NSObject.Type {
            let sdkClient = sdkClientClass.init()
            let selector = NSSelectorFromString("setColorsWithPrimary:onPrimary:")
            if sdkClient.responds(to: selector) {
                sdkClient.perform(selector, with: primary, with: onPrimary)
                result?("OK")
            } else {
                result?(FlutterError(code: "METHOD_NOT_FOUND", message: "Método no encontrado en BcsSdkClient", details: nil))
            }
        } else {
            result?(FlutterError(code: "CLASS_NOT_FOUND", message: "BcsSdkClient no está disponible", details: nil))
        }
    }
}
