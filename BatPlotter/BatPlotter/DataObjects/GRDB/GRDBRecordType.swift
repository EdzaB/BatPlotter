//
//  GRDBRecordType.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation
import GRDB

public protocol GRDBRecordType: GRDBMigratable, FetchableRecord, PersistableRecord, Hashable, Codable {}

public extension GRDBRecordType {

    static func fetch(identifier: DatabaseIdentifier = .default, _ predicate: SQLSpecificExpressible) -> [Self] {
        try! GRDBDatabase.database(identifier: identifier).read { db in
            try filter(predicate).fetchAll(db)
        }
    }

    static func fetchAll(identifier: DatabaseIdentifier = .default) -> [Self] {
        try! GRDBDatabase.database(identifier: identifier).read { db in
            try fetchAll(db)
        }
    }

    static func updateAll(identifier: DatabaseIdentifier = .default, with entities: [Self]) {
        
    }

    static func replaceAll(identifier: DatabaseIdentifier = .default, with entities: [Self]) {
        _ = try! GRDBDatabase.database(identifier: identifier).write { db in
            try deleteAll(db)
            for entity in entities {
                try entity.save(db)
            }
        }
    }

    static func deleteAll(identifier: DatabaseIdentifier = .default) {
        _ = try! GRDBDatabase.database(identifier: identifier).write { db in
            try deleteAll(db)
        }
    }
}
