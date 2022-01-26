//
//  VehicleAnnotationDO.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 25/01/2022.
//

import Foundation
import MapKit

class VehicleAnnotationDO: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var model: String?
    var year: String?
    var photoLink: URL?
    var vehicleColor: UIColor?

    init(location: LocationDO, details: VehicleDO?) {
        self.coordinate = CLLocationCoordinate2D(latitude: location.lat ?? 0, longitude: location.lon ?? 0)
        guard let link = details?.foto, let url = URL(string: link) else { return }
        self.title = details?.make
        self.photoLink = url
        self.model = details?.model
        self.year = details?.year
        self.vehicleColor = UIColor.hexStringToUIColor(hex: details?.color)
    }
}
