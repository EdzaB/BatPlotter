//
//  SplashScreenViewModel.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 17/01/2022.
//

import Foundation
import UIKit

protocol PSplashScreenVM {
    var onSyncCompletion: (() -> Void)? { get set }
    var navigateToUserList: (() -> Void)? { get set }
    var onErrorOccur: ((String) -> Void)? { get set }
}

final class SplashScreenVM: PSplashScreenVM {
    var navigateToUserList: (() -> Void)?
    var onSyncCompletion: (() -> Void)?
    var onErrorOccur: ((String) -> Void)?

    init() {
        performInitialSync()
    }

    private func performInitialSync() {
        migrateDatabase {
            Network.shared.getUserData({ [weak self] result in
                do {
                    try result.get()
                    self?.syncCompleted()
                } catch {
                    self?.handleErrors(error: error)
                }
            })
        }
    }

    private func syncCompleted() {
        onSyncCompletion?()
    }

    private func handleErrors(error: Error) {
        onErrorOccur?(error.localizedDescription)
    }
}
