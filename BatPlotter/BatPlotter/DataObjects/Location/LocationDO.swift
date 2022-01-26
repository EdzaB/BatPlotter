//
//  LocationDO.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 22/01/2022.
//

import Foundation
import GRDB

@objc
final public class LocationDO: APIObject {
    let vehicleid: Int
    let lat: Double?
    let lon: Double?

    enum CodingKeys: CodingKey {
        case vehicleid, lat, lon
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vehicleid = try container.decode(Int.self, forKey: .vehicleid)
        lat = try container.decodeIfPresent(Double.self, forKey: .lat)
        lon = try container.decodeIfPresent(Double.self, forKey: .lon)

        super.init(id: String(vehicleid))
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vehicleid, forKey: .vehicleid)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(lon, forKey: .lon)
    }

    // Seperate Table for Locations, to overwrite when looking at new users
    public override class func addMigrations(to migrator: inout DatabaseMigrator) {
        migrator.registerMigration("createLocationTable", migrate: { db in
            try db.create(table: databaseTableName, body: { t in
                t.column("vehicleid", .integer).primaryKey()
                t.column("lat", .double)
                t.column("lon", .double)
            })
        })
    }

    var isEmpty: Bool {
        return lat == nil || lon == nil
    }
}
