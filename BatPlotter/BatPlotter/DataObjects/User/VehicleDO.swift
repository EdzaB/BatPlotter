//
//  VehicleDO.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 21/01/2022.
//

import Foundation
import GRDB

@objc
final public class VehicleDO: APIObject {
    public var vehicleid: Int
    public var make: String
    public var model: String
    public var year: String
    public var color: String
    public var vin: String
    public var foto: String

    enum CodingKeys: String, CodingKey, ColumnExpression {
        case vehicleid, make, model, year, color, vin, foto
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vehicleid = try container.decode(Int.self, forKey: .vehicleid)
        make = try container.decode(String.self, forKey: .make)
        model = try container.decode(String.self, forKey: .model)
        year = try container.decode(String.self, forKey: .year)
        color = try container.decode(String.self, forKey: .color)
        vin = try container.decode(String.self, forKey: .vin)
        foto = try container.decode(String.self, forKey: .foto)

        super.init(id: String(vehicleid))
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vehicleid, forKey: .vehicleid)
        try container.encode(make, forKey: .make)
        try container.encode(model, forKey: .model)
        try container.encode(year, forKey: .year)
        try container.encode(color, forKey: .color)
        try container.encode(vin, forKey: .vin)
        try container.encode(foto, forKey: .foto)
    }

    public override static func addMigrations(to migrator: inout DatabaseMigrator) {
        migrator.registerMigration("createVehicleTable") { db in
            try db.create(table: databaseTableName) { t in
                t.column("vehicleid", .integer).primaryKey()
                t.column("make", .text)
                t.column("model", .text)
                t.column("year", .text)
                t.column("color", .text)
                t.column("vin", .double)
                t.column("foto", .double)
            }
        }
    }
}
