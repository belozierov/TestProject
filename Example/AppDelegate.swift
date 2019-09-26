//
//  AppDelegate.swift
//  Example
//
//  Created by Alex Belozierov on 8/12/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        TransformerRegistrator.register(withName: "DaysFrom1970") { value in
            let from = Date(timeIntervalSince1970: 0)
            return (value as? String).flatMap(ISO8601DateFormatter().date)
                .flatMap { Calendar.current.dateComponents([.day], from: from, to: $0).day }
        }
        
        return true
    }

}
