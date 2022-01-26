//
//  APIObject.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation
import GRDB

@objc
public class APIObject: NSObject, GRDBRecordType {
    public internal(set) var id: String

    init(id: String) {
        self.id = id
        super.init()
    }

    // MARK: GRDB Record
    public class func addMigrations(to migrator: inout DatabaseMigrator) {}

    static func == (lhs: APIObject, rhs: APIObject) -> Bool {
        return lhs.id == rhs.id
    }
}
