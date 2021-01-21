//
//  AppDelegate.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 20.01.2021.
//

import UIKit
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = MConfiguration()
        
        GMSServices.provideAPIKey(configuration.googleApiKey)
        GMSPlacesClient.provideAPIKey(configuration.googleApiKey)
        
        let context = MContext(configuration: configuration)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = MMainViewController(context: context)
        let rootNC = UINavigationController(rootViewController: rootVC)
        
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
        
        return true
    }
}

