//
//  RMBTMeasurementPin.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 29.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit
import MapKit

class RMBTMeasurementPin: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let id: String
    let title: String?
    
    init(id: String, title: String?, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
    }
}
