//
//  AppDelegate.swift
//  Hospital
//
//  Created by Simone Montalto on 15/03/17.
//  Copyright © 2017 MontaltoRota. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = UserDefaults.standard


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var initialviewController: UINavigationController
        if defaults.bool(forKey: UserDefaultsKeys.rememberMeKey) && defaults.bool(forKey: UserDefaultsKeys.touchIDKey) || !defaults.bool(forKey: UserDefaultsKeys.rememberMeKey) {
            initialviewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as! UINavigationController
        } else {
            initialviewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeNavigation") as! UINavigationController
        }
        
        self.window?.rootViewController = initialviewController
        self.window?.makeKeyAndVisible()
        
        // Configura colore della navigation bar
        UINavigationBar.appearance().barTintColor = Colors.mediumColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        // Configura colore della tab bar
        UITabBar.appearance().barTintColor = Colors.mediumColor
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = Colors.darkColor
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        if !defaults.bool(forKey: UserDefaultsKeys.rememberMeKey) {
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        defaults.set(false, forKey: UserDefaultsKeys.checkinDoneKey)
    }

}

