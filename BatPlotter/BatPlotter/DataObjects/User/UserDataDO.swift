//
//  UserDataDO.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation

public struct UserDataDO: Decodable {
    let data: [UserDO]

    enum CodingKeys: CodingKey {
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([UserDO].self, forKey: .data).filter { $0.userid != nil }
    }
}
