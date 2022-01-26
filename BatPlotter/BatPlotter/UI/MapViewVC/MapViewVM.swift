//
//  MapViewVM.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 22/01/2022.
//

import Foundation
import MapKit

protocol PMapViewVM {
    var addAnnotations: (([MKAnnotation]) -> Void)? { get set }
    func cleanup()
}

final class MapViewVM: PMapViewVM {

    private var locations = [LocationDO]()
    private var details = [VehicleDO]()
    private let userID: Int
    private var detailsTimer: Timer?
    private var locationTimer: Timer?
    var addAnnotations: (([MKAnnotation]) -> Void)?

    init(userID: Int) {
        self.userID = userID
        getLocations(firstTime: true)
        startTimers()
    }

    @objc private func getLocations(firstTime: Bool) {
        Network.shared.getVehicleData(for: userID, { [weak self] result in
            do {
                let details = try result.get()
                self?.locations = details
                if firstTime {
                    self?.getVehiclesDetailsById()
                }
            } catch {
                self?.handleErrors(error: error)
            }
        })
    }

    private func handleErrors(error: Error) {
        
    }

    @objc private func locationToAnnotation() {
        let annotations = locations.map { location -> VehicleAnnotationDO in
            let details = details.first(where: { $0.vehicleid == location.vehicleid })
            let a = VehicleAnnotationDO(location: location, details: details)
            return a
        }
        addAnnotations?(annotations)
    }

    private func getVehiclesDetailsById() {
        let vehicleIDs = locations.map { String($0.vehicleid) }
        let results = VehicleDO.fetch(vehicleIDs.contains(VehicleDO.CodingKeys.vehicleid))
        details = results
        locationToAnnotation()
    }

    private func startTimers() {
        guard detailsTimer == nil && locationTimer == nil else { return }
        detailsTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(getLocations), userInfo: nil, repeats: true)
        locationTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(locationToAnnotation), userInfo: nil, repeats: true)
    }

    private func stopTimers() {
        detailsTimer?.invalidate()
        locationTimer?.invalidate()

        detailsTimer = nil
        locationTimer = nil
    }

    func cleanup() {
        stopTimers()
        LocationDO.deleteAll()
    }
}
