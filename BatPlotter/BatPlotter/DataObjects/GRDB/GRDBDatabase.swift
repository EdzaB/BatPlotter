//
//  GRDBDatabase.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation
import GRDB

struct GRDBDatabase {
    fileprivate static var databaseWriters: [DatabaseIdentifier : DatabaseWriter] = [:]
    private static var migrationTypes: [GRDBMigratable.Type] = []

    static func database(identifier: DatabaseIdentifier) throws -> DatabaseWriter {
        if let existingWriter = databaseWriters[identifier] {
            return existingWriter
        }

        func createDatabaseWriter() throws -> DatabaseWriter {
            switch identifier {
            case .inMemory:
                return DatabaseQueue()
            default:
                let databaseURL = try FileManager.default
                    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathExtension(try identifier.filename())
                    .appendingPathExtension("sqlite")

                print(databaseURL.path)
                return try DatabasePool(path: databaseURL.path)
            }
        }

        let writter = try createDatabaseWriter()

        databaseWriters[identifier] = writter
        try migrator.migrate(writter)

        return writter
    }

    private init() {}
}

extension GRDBDatabase {
    static func registerMigrations(for type: GRDBMigratable.Type) {
        guard !migrationTypes.map({ "\($0)" }).contains("\(type)") else { return }
        migrationTypes.append(type)
    }

    private static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        for migrationType in migrationTypes {
            migrationType.addMigrations(to: &migrator)
        }
        return migrator
    }
}


public enum DatabaseIdentifier: Hashable {
    case inMemory(key: String)
    case `default`

    func getWriter() throws -> DatabaseWriter {
        return try GRDBDatabase.database(identifier: self)
    }

    func closeWriter() throws {
        GRDBDatabase.databaseWriters.removeValue(forKey: self)
    }

    func filename() throws -> String {
        switch self {
        case .default:
            return "BatPlotter"
        default:
            throw NetworkErrors.failedToContructURL
        }
    }

    func fileURL() throws -> URL {
        return try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(try filename())
            .appendingPathExtension("sqlite")
    }
}

public let databaseQueue = DispatchQueue(label: "com.batplotter.databaseQueue", qos: .userInteractive)
