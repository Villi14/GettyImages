 //
//  AppDelegate.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/1/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let screen = UIScreen.main
        self.window = UIWindow(frame: screen.bounds)
        let searchVC = SearchPhotoViewController()
        let navigationVC = UINavigationController(rootViewController: searchVC)
        self.window?.rootViewController = navigationVC
        self.window?.makeKeyAndVisible()
        return true
    }
}

