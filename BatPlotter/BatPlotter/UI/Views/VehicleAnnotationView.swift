//
//  VehicleAnnotationView.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 25/01/2022.
//

import UIKit
import MapKit
import Kingfisher

final class VehicleAnnotationView: MKAnnotationView {

    private let animationDuration = 0.25

    private weak var calloutView: VehicleCalloutView?
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let annotation = annotation as? VehicleAnnotationDO else { return }

        isUserInteractionEnabled = true
        canShowCallout = false
        image = UIImage(named: "vehicle-round")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard let annotation = annotation as? VehicleAnnotationDO else { return }

        if selected {
            self.calloutView?.removeFromSuperview()

            let calloutView = VehicleCalloutView(annotation: annotation)
            calloutView.add(to: self)
            self.calloutView = calloutView

            if animated {
                calloutView.alpha = 0
                UIView.animate(withDuration: animationDuration) {
                    calloutView.alpha = 1
                }
            }
        } else {
            guard let calloutView = calloutView else { return }

            if animated {
                UIView.animate(withDuration: animationDuration, animations: {
                    calloutView.alpha = 0
                }, completion: { _ in
                    calloutView.removeFromSuperview()
                })
            } else {
                calloutView.removeFromSuperview()
            }
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) { return hitView }

        if let calloutView = calloutView {
            let pointInCalloutView = convert(point, to: calloutView)
            return calloutView.hitTest(pointInCalloutView, with: event)
        }

        return nil
    }
}
