//
//  UserDO.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 21/01/2022.
//

import Foundation
import GRDB

@objc
public final class UserDO: APIObject {
    var userid: Int?
    var name: String = ""
    var surname: String = ""
    var foto: String = ""

    var vehicles: [VehicleDO] = []

    enum CodingKeys: CodingKey {
        case userid, owner, vehicles, name, surname, foto
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userid = try container.decodeIfPresent(Int.self, forKey: .userid)

        //Check any empty objects >:(
        if userid != nil {

            // Check if decoding from original json
            if container.contains(.owner) {
                let ownerContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .owner)
                name = try ownerContainer.decode(String.self, forKey: .name)
                surname = try ownerContainer.decode(String.self, forKey: .surname)
                foto = try ownerContainer.decode(String.self, forKey: .foto)
                vehicles = try container.decode([VehicleDO].self, forKey: .vehicles)

                // Decode from database
            } else {
                name = try container.decode(String.self, forKey: .name)
                surname = try container.decode(String.self, forKey: .surname)
                foto = try container.decode(String.self, forKey: .foto)
            }
        }

        super.init(id: String(userid ?? 0))
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userid, forKey: .userid)
        try container.encode(name, forKey: .name)
        try container.encode(surname, forKey: .surname)
        try container.encode(foto, forKey: .foto)
    }

    public override class func addMigrations(to migrator: inout DatabaseMigrator) {
        migrator.registerMigration("createUserTable", migrate: { db in
            try db.create(table: databaseTableName, body: { t in
                t.column("userid", .integer).primaryKey()
                t.column("name", .text)
                t.column("surname", .text)
                t.column("foto", .text)
            })
        })
    }
}

extension UserDO {
    public static var list: [UserDO] {
        return UserDO.fetchAll()
    }

    public var url: URL? {
        guard let urlString = self.foto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: urlString)
    }
}
