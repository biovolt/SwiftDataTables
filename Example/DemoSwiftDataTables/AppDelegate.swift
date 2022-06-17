//
//  AppDelegate.swift
//  SwiftDataTables
//
//  Created by pavankataria on 03/09/2017.
//  Copyright (c) 2017 pavankataria. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let instance = MenuViewController()
        navigationController = UINavigationController(rootViewController: instance)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}
