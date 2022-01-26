//
//  VehicleLocationRequest.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 24/01/2022.
//

import Foundation

public struct VehicleLocationRequest: Request {
    var baseURL: URL? = URL(string: "http://mobi.connectedcar360.net/")
    var path: String = "api"

    var queryItems: [String : String] = [:]

    init(userID: Int) {
        queryItems = [
            "op" : "getlocations",
            "userid" : "\(userID)"
        ]
    }
}
