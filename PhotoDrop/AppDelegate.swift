//
//  AppDelegate.swift
//  PhotoDrop
//
//  Created by Tetiana Babycheva on 7/24/17.
//  Copyright © 2017 babycheva. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        /* ensure locationManager is initalized */
        _ = CurrentLocationController.shared

        /* go to Welcome if there is no PhotoDropUser, else go to map */
        PhotoDropUserController.shared.pullCurrentUser {
            (photoDropUser) in
            if photoDropUser == nil {
                guard let destination = UIStoryboard.init(name: "Welcome", bundle: nil).instantiateInitialViewController() else {
                    return
                }
                self.window?.rootViewController = destination
            } else {
                guard let destination = UIStoryboard.init(name: "Map", bundle: nil).instantiateInitialViewController() else {
                  return
                }
                self.window?.rootViewController = destination
            }
            DispatchQueue.main.async {
                self.window?.makeKeyAndVisible()
            }
        }

        // Override point for customization after application launch.
        return true
    }
    
    

}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            
            delegate.orientationLock = orientation
        }
    }
    
    static func lockOrientation(_ orientaation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
        
        self.lockOrientation(orientaation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}

