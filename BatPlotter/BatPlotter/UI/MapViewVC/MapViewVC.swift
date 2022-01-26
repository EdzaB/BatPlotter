//
//  MapViewVC.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 22/01/2022.
//

import UIKit
import MapKit
import Kingfisher

//MARK: Props
final class MapViewVC: UIViewController {
    private let mapView = MKMapView()
    private let locationManager: CLLocationManager = CLLocationManager()
    private let button = UIButton()
    private var firstTime = true
    var viewModel: PMapViewVM?
}

//MARK: View Lifecycle
extension MapViewVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupLocationManager()
        setupUserLocationButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel?.cleanup()
        viewModel = nil
    }
}

//MARK: UI Setup
extension MapViewVC {
    private func setupMap() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.constrainToSuperview().activate()
        mapView.delegate = self
        mapView.register(VehicleAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: VehicleAnnotationDO.self))

        viewModel?.addAnnotations = { [weak self] annotations in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)

                if self.firstTime {
                    self.firstTime = false
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                }
            }
        }
    }

    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()

        mapView.showsUserLocation = true
    }

    private func setupUserLocationButton() {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24).activate()
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).activate()
        button.widthAnchor.constraint(equalToConstant: 48).activate()
        button.constrainAspectRatio(to: 1)
        button.layer.cornerRadius = 24
        button.backgroundColor = .white
        button.setImage(UIImage(named: "location")?.resizeImage(newWidth: 50), for: .normal)
        button.addTarget(self, action: #selector(goToUserLocation), for: .touchUpInside)
    }
}

//MARK: MKMapView
extension MapViewVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

        return setupAnnotationView(with: annotation as? VehicleAnnotationDO, on: mapView)
    }

    private func setupAnnotationView(with annotation: VehicleAnnotationDO?, on mapView: MKMapView) -> MKAnnotationView {
        guard let annotation = annotation else { return MKAnnotationView() }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: VehicleAnnotationDO.self), for: annotation)

        annotationView.isEnabled = true
        annotationView.image = UIImage(named: "vehicle-round")?.resizeImage(newWidth: 30)

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        mapView.setCenter(coordinate, animated: true)

    }
}

//MARK: User Interaction
extension MapViewVC: VehicleCalloutDelegate {

    @objc private func goToUserLocation() {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }

    func mapView(_ mapView: MKMapView, didTapRouteButton button: UIButton, for annotation: MKAnnotation) {
        showRouteOnMap(destinationCoordinate: annotation.coordinate)
    }

    private func showRouteOnMap(destinationCoordinate: CLLocationCoordinate2D) {

        mapView.removeOverlays(mapView.overlays)

        let sourcePlacemark = MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let sourceAnnotation = MKPointAnnotation()

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }

        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking

        let directions = MKDirections(request: directionRequest)

        directions.calculate { (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }

            guard let fastestRoute = response.routes.first else { return }

            self.mapView.addOverlay((fastestRoute.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = fastestRoute.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: .init(top: 0, left: 50, bottom: 0, right: 50), animated: true)
        }
    }
}
