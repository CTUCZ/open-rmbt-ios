//
//  RMBTHistoryMapCell.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import MapKit

class RMBTHistoryMapCell: UITableViewCell {

    static let ID = "RMBTHistoryMapCell"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rootView: UIView!
    
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            let pin = RMBTMeasurementPin(id: "", title: "Pin", coordinate: coordinate)
            mapView.addAnnotation(pin)
            mapView.selectAnnotation(pin, animated: false)
            mapView.setCenter(coordinate, zoom: 12, animated: false)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rootView.layer.cornerRadius = 8
        self.mapView.delegate = self
    }
}

extension RMBTHistoryMapCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is RMBTMeasurementPin {
            let identifier = "Pin"
            guard let image = UIImage(named: "map_pin_small_icon") else { return nil }
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView.image = image
            annotationView.canShowCallout = false
            annotationView.centerOffset = CGPoint(x: 0, y: -image.size.height / 2)
            annotationView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            return annotationView
        }
        return nil
    }
}
