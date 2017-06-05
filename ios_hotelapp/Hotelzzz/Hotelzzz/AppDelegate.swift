//
//  AppDelegate.swift
//  Hotelzzz
//
//  Created by Steve Johnson on 3/21/17.
//  Copyright © 2017 Hipmunk, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.2717360258, green: 0.6549535394, blue: 0.8871139288, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        return true
    }
}
