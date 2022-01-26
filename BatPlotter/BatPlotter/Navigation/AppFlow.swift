//
//  AppFlow.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 17/01/2022.
//

import UIKit

final class AppFlow: FlowController {
    private var window: UIWindow
    internal var rootController: UINavigationController?
    private var childFlow: FlowController?

    init(with window: UIWindow) {
        self.window = window
        window.makeKeyAndVisible()
    }

    func start() {
        let screenFlow = ScreenFlow(with: rootController)
        screenFlow.start()
        window.rootViewController = screenFlow.rootController
        childFlow = screenFlow
    }
}
