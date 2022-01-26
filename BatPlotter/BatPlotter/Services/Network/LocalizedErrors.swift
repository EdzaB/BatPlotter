//
//  LocalizedErrors.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 23/01/2022.
//

import Foundation

public enum NetworkErrors: LocalizedError {
    case failedToContructURL
    case noDataReturned
    case serverIsOverloaded
    case requestStatusError(status: Int?, errorMessage: String)


    #if debug
    public var errorDescription: String? {
        localizedDescription
    }

    public var localizedDescription: String {
        switch self {
        case .failedToContructURL:
            return "Failed to contruct URL"
        case .noDataReturned:
            return "No data returned"
        case .serverIsOverloaded:
            return "Server is overloaded"
        }
    }
    #endif
}
