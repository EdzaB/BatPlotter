//
//  Network.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 22/01/2022.
//

import Foundation

final class Network {
    static let shared = Network()

    func getUserData(_ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        UserListRequest().submit { (result: Result<UserDataDO, Error>) in
            do {
                let details = try result.get().data
                UserDO.replaceAll(with: details)
                var allVehicles = [VehicleDO]()
                details.forEach {
                    allVehicles.append(contentsOf: $0.vehicles)
                }
                VehicleDO.replaceAll(with: allVehicles)
                completionHandler(.success(()))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    func getVehicleData(for userID: Int, _ completionHandler: @escaping (Result<[LocationDO], Error>) -> Void) {
        VehicleLocationRequest(userID: userID).submit { (result: Result<LocationDataDO, Error>) in
            do {
                var details = try result.get().data
                var filteredDetails = [LocationDO]()

                // If lat or lon == nil, get cached data for that vehicle
                if details.contains(where: { $0.isEmpty }) {
                    let filtered = details.map { return $0.isEmpty ? String($0.vehicleid) : "" }
                    filteredDetails = LocationDO.fetch(filtered.contains(VehicleDO.CodingKeys.vehicleid))
                    details.removeAll(where: { $0.isEmpty })
                    filteredDetails.append(contentsOf: details)
                }

                if filteredDetails.isEmpty {
                    LocationDO.replaceAll(with: details)
                    completionHandler(.success(details))
                } else {
                    LocationDO.replaceAll(with: filteredDetails)
                    completionHandler(.success(filteredDetails))
                }
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}
