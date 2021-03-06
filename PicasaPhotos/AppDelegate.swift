//
//  AppDelegate.swift
//  PicasaPhotos
//
//  Created by Le Ngoc Hoan on 6/21/17.
//  Copyright © 2017 Le Ngoc Hoan. All rights reserved.
//

import UIKit
import GGLSignIn
import GoogleSignIn
import GoogleMaps

enum AppMode {
    case Init
    case Login
    case Main
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mode: AppMode = .Init
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().signInSilently()
        GMSServices.provideAPIKey("AIzaSyAe75F2SweH0LHJTqLUIZyrCBiEY1wgw5Y")
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize sign-in
        
        if let _ = GIDSignIn.sharedInstance().currentUser {
            showMain()
        } else {
            showLogin()
        }
        
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
    }

}

extension AppDelegate {
    private func goTo(_ storyboard: UIStoryboard) {
        if let vc = storyboard.instantiateInitialViewController() {
            UIView.transition(from: window!.rootViewController!.view, to: (vc.view)! , duration: 0.5, options: .transitionCrossDissolve, completion: { [weak self] _ in
                self?.window?.rootViewController = vc
            })
        }
    }
    
    func showMain() {
        if mode == .Main { return }
        mode = .Main
        goTo(StoryboardUtil.mainStoryboard)
    }
    
    func showLogin() {
        if mode == .Login { return }
        mode = .Login
        goTo(StoryboardUtil.loginStoryboard)
    }
}

