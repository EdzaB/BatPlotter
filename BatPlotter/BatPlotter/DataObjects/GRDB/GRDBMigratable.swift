//
//  GRDBMigratable.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation
import GRDB

public protocol GRDBMigratable {
    static func addMigrations(to migrator: inout DatabaseMigrator)
}

extension GRDBMigratable {
    static func registerMigrations() {
        GRDBDatabase.registerMigrations(for: Self.self)
    }
}

public func migrateDatabase(completion: @escaping () -> Void) {
    UserDO.registerMigrations()
    VehicleDO.registerMigrations()
    LocationDO.registerMigrations()
    completion()
}
