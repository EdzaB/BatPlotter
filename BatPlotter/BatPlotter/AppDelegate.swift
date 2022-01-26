//
//  AppDelegate.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 17/01/2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var rootWindow: UIWindow!
    private var appFlow: AppFlow!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        rootWindow = UIWindow()
        appFlow = AppFlow(with: rootWindow)
        appFlow.start()

        whereIsMySQLite()
        return true
    }

    func whereIsMySQLite() {
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding

        print(path ?? "Not found")
    }
}

