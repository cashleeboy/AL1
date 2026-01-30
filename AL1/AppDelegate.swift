//
//  AppDelegate.swift
//  AL1
//
//  Created by cashlee on 2025/12/12.
//

import UIKit
import AlamofireImage
import AdjustSdk

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let adjustToken = "b1x43quil24g"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ScreenRotator.shared.rotation(to: .portrait)
        ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange = true
        ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange = true
        
        // 服务器返回图片的 Content-Type（响应头）被设置为 application/force-download，
        // 而 AlamofireImage 默认只接受标准的图片格式（如 image/jpeg, image/png 等）
        ImageResponseSerializer.addAcceptableImageContentTypes(["application/force-download"])
        
//        ScreenRotator.shared.orientationMaskDidChange = { orientationMask in
//            print("*** orientatioin mask = \(orientationMask)")
//        }
        
        adjustInit()
        return true
    }
    
    func adjustInit() {
        let adjustConfig = ADJConfig(appToken: adjustToken, environment: ADJEnvironmentSandbox)
        adjustConfig?.logLevel = ADJLogLevel.verbose
        Adjust.initSdk(adjustConfig)
        
        Adjust.adid { adid in
            if let adid {
                RequestHeaderConfig.adjustAdid = adid
                KeychainStorage.save(key: DeviceIDManager.adjustAdidKey, data: adid)
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return ScreenRotator.shared.orientationMask
    }
    
}

