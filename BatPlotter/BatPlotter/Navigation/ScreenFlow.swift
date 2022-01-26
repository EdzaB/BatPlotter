//
//  ScreenFlow.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 21/01/2022.
//

import UIKit

final class ScreenFlow: FlowController {
    internal var rootController: UINavigationController?

    init(with rootController: UINavigationController?) {
        self.rootController = rootController
    }

    func start() {
        let vc = SplashScreenVC()
        let vm = SplashScreenVM()
        vm.navigateToUserList = { [weak self] in
            self?.navigateToList()
        }
        vc.viewModel = vm
        rootController = UINavigationController(rootViewController: vc)
    }

    private func navigateToList() {
        let vc = UserListVC()
        let vm = UserListVM()
        vm.navigateToMapView = { [weak self] userID in
            self?.navigateToMap(with: userID)
        }
        vc.viewModel = vm
        rootController?.viewControllers = [vc]
    }

    private func navigateToMap(with userID: Int) {
        let vc = MapViewVC()
        let vm = MapViewVM(userID: userID)
        vc.viewModel = vm
        rootController?.pushViewController(vc, animated: true)
    }
}
