//
//  UserListVM.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 21/01/2022.
//

import UIKit
import Foundation
import CoreData

protocol PUserListVM {
    var users: [UserDO] { get }
    var reloadCells: (() -> Void)? { get set }
    var stopRefreshing: (() -> Void)? { get set }
    func navigateToMap(for index: Int)
    func getUserList()
}

final class UserListVM: PUserListVM {

    var users = [UserDO]()

    var stopRefreshing: (() -> Void)?
    var reloadCells: (() -> Void)?
    var navigateToMapView: ((Int) -> Void)?

    init() {
        getUserList()
    }

    func getUserList() {
        users = UserDO.list
        stopRefreshing?()
    }

    func navigateToMap(for index: Int) {
        guard let userid = users[index].userid else { return }
        navigateToMapView?(userid)
    }
}
