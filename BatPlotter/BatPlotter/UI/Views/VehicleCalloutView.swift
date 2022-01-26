//
//  VehicleCalloutView.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 26/01/2022.
//

import UIKit
import MapKit
import SwiftUI

protocol VehicleCalloutDelegate: AnyObject {
    func mapView(_ mapView: MKMapView, didTapRouteButton button: UIButton, for annotation: MKAnnotation)
}

final class VehicleCalloutView: UIView {
    private let imageView = UIImageView(image: UIImage(named: "placeholder"))
    private let nameLabel = UILabel()
    private let colorView = UIView()
    private let addressLabel = UILabel()
    private let plotRouteButton = UIButton()
    let imageHeight = CGFloat(100)

    private let edgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
    private var contentView = UIView()

    private let bubbleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.fillColor = UIColor.white.cgColor
        layer.lineWidth = 0.1
        return layer
    }()

    private var annotation: VehicleAnnotationDO?

    init(annotation: VehicleAnnotationDO) {
        super.init(frame: .zero)
        self.annotation = annotation
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let contentViewPoint = convert(point, to: contentView)
        return contentView.hitTest(contentViewPoint, with: event)
    }

    func add(to annotationView: MKAnnotationView) {
        annotationView.addSubview(self)

        bottomAnchor.constraint(equalTo: annotationView.topAnchor, constant: annotationView.calloutOffset.y).activate()
        centerXAnchor.constraint(equalTo: annotationView.centerXAnchor, constant: annotationView.calloutOffset.x).activate()
    }

    private func configureView() {

        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: topAnchor, constant: edgeInsets.top / 2).activate()
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -edgeInsets.bottom - edgeInsets.right / 2).activate()
        contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeInsets.left / 2).activate()
        contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeInsets.right / 2).activate()
        contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: edgeInsets.left + edgeInsets.right).activate()
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: edgeInsets.top + edgeInsets.bottom).activate()

        layer.insertSublayer(bubbleLayer, at: 0)

        [imageView, nameLabel, colorView, addressLabel, plotRouteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        configureImageView()
        configureColorView()
        configureTitleView()
        configureAddressView()
        configureRouteButton()
    }

    private func configureImageView() {
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).activate()
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).activate()
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).activate()

        imageView.heightAnchor.constraint(equalToConstant: imageHeight).activate()
        imageView.widthAnchor.constraint(equalToConstant: imageHeight).activate()

        imageView.layer.cornerRadius = imageHeight / 2
        imageView.layer.masksToBounds = true

        imageView.kf.setImage(with: annotation?.photoLink, placeholder: UIImage(named: "placeholder"), options: nil, completionHandler: nil)

    }

    private func configureColorView() {
        colorView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).activate()
        colorView.rightAnchor.constraint(equalTo: imageView.rightAnchor).activate()
        colorView.heightAnchor.constraint(equalToConstant: imageHeight / 3).activate()
        colorView.widthAnchor.constraint(equalToConstant: imageHeight / 3).activate()

        colorView.layer.cornerRadius = imageHeight / 6
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 0.5

        colorView.backgroundColor = annotation?.vehicleColor
    }

    private func configureTitleView() {
        guard
            let make = annotation?.title,
            let model = annotation?.model,
            let year = annotation?.year
        else { return }

        nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).activate()
        nameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 12).activate()
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor).activate()

        //To avoid names longer than the screen
        nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width).activate()
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.1

        nameLabel.text = "\(make), \(model), \(year)"
        nameLabel.textAlignment = .left
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
    }

    private func configureAddressView() {
        guard let annotation = annotation else { return }

        addressLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).activate()
        addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).activate()
        addressLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 12).activate()

        //To avoid names longer than the screen
        addressLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width).activate()
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.minimumScaleFactor = 0.1

        getAddressFromLatLon(lat: annotation.coordinate.latitude, lon: annotation.coordinate.longitude)
        addressLabel.textAlignment = .left
        addressLabel.font = .systemFont(ofSize: 15)
    }

    private func configureRouteButton() {
        plotRouteButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 12).activate()
        plotRouteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).activate()
        plotRouteButton.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 12).activate()
        plotRouteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).activate()
        plotRouteButton.heightAnchor.constraint(equalToConstant: 24).activate()

        plotRouteButton.setTitle("Plot route to car", for: .normal)
        plotRouteButton.addTarget(self, action: #selector(plotRoutePressed), for: .touchUpInside)
        plotRouteButton.backgroundColor = #colorLiteral(red: 0.8348986506, green: 0.8419699073, blue: 0.8527527452, alpha: 1)
        plotRouteButton.setTitleColor(.black, for: .normal)

        plotRouteButton.layer.cornerRadius = 12
        plotRouteButton.layer.masksToBounds = true

        plotRouteButton.titleLabel?.font = .systemFont(ofSize: 14)

    }

    @objc func plotRoutePressed() {
        if let mapView = mapView, let delegate = mapView.delegate as? VehicleCalloutDelegate, let annotation = annotation {
            delegate.mapView(mapView, didTapRouteButton: plotRouteButton, for: annotation)
        }
    }

    private func getAddressFromLatLon(lat: Double, lon: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        center.latitude = lat
        center.longitude = lon

        let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)

        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: { [weak self] (placemarks, error) in
            guard let pm = placemarks?.first else {
                print("reverse geodcode fail: \(error!.localizedDescription)")
                return
            }

            var addressString : String = ""
            if let subLocal = pm.subLocality {
                addressString = addressString + subLocal + ", "
            }
            if let thoroughfare = pm.thoroughfare {
                addressString = addressString + thoroughfare + ", "
            }
            if let locality = pm.locality {
                addressString = addressString + locality
            }

            self?.addressLabel.text = addressString
        })
    }
}

//MARK: Path'n'stuff
extension VehicleCalloutView {

    func updatePath() {
        let path = UIBezierPath()
        var point = CGPoint(x: bounds.width - edgeInsets.right, y: bounds.height - edgeInsets.bottom)

        path.move(to: point)

        addRoundedCalloutPointer(to: path)

        // bottom left
        point.x = edgeInsets.left
        path.addLine(to: point)

        // lower left corner
        var controlPoint = CGPoint(x: 0, y: bounds.height - edgeInsets.bottom)
        point = CGPoint(x: 0, y: controlPoint.y - edgeInsets.left)
        path.addQuadCurve(to: point, controlPoint: controlPoint)

        // left
        point.y = edgeInsets.top
        path.addLine(to: point)

        // top left corner
        controlPoint = CGPoint.zero
        point = CGPoint(x: edgeInsets.left, y: 0)
        path.addQuadCurve(to: point, controlPoint: controlPoint)

        // top
        point = CGPoint(x: bounds.width - edgeInsets.left, y: 0)
        path.addLine(to: point)

        // top right corner
        controlPoint = CGPoint(x: bounds.width, y: 0)
        point = CGPoint(x: bounds.width, y: edgeInsets.top)
        path.addQuadCurve(to: point, controlPoint: controlPoint)

        // right
        point = CGPoint(x: bounds.width, y: bounds.height - edgeInsets.bottom - edgeInsets.right)
        path.addLine(to: point)

        // lower right corner
        controlPoint = CGPoint(x: bounds.width, y: bounds.height - edgeInsets.bottom)
        point = CGPoint(x: bounds.width - edgeInsets.right, y: bounds.height - edgeInsets.bottom)
        path.addQuadCurve(to: point, controlPoint: controlPoint)

        path.close()

        bubbleLayer.path = path.cgPath
    }

    func addRoundedCalloutPointer(to path: UIBezierPath) {

        // lower right
        var point = CGPoint(x: bounds.width / 2.0 + edgeInsets.bottom, y: bounds.height - edgeInsets.bottom)
        path.addLine(to: point)

        // right side of arrow
        var controlPoint = CGPoint(x: bounds.width / 2.0, y: bounds.height - edgeInsets.bottom)
        point = CGPoint(x: bounds.width / 2.0, y: bounds.height)
        path.addQuadCurve(to: point, controlPoint: controlPoint)

        // left of pointer
        controlPoint = CGPoint(x: point.x, y: bounds.height - edgeInsets.bottom)
        point = CGPoint(x: point.x - edgeInsets.bottom, y: controlPoint.y)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
    }
}

//MARK: MapView
extension VehicleCalloutView {
    var mapView: MKMapView? {
        var view = superview
        while view != nil {
            if let mapView = view as? MKMapView { return mapView }
            view = view?.superview
        }
        return nil
    }
}
