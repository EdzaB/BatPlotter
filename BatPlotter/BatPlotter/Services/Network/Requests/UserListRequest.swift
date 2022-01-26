//
//  UserListRequest.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation

public struct UserListRequest: Request {
    var baseURL: URL? = URL(string: "http://mobi.connectedcar360.net/")
    var path: String = "api"
    var queryItems: [String: String] = [
        "op": "list"
    ]

    init() {}
}
