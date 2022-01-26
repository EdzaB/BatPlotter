//
//  FlowController.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 21/01/2022.
//

import UIKit

protocol FlowController {
    func start()
    var rootController: UINavigationController? { get set }
}
