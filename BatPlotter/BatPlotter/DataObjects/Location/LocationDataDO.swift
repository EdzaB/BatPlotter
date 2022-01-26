//
//  LocationDataDO.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 22/01/2022.
//

import Foundation

struct LocationDataDO: Codable {
    var data: [LocationDO]

    enum CodingKeys: CodingKey {
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([LocationDO].self, forKey: .data)
    }
}
