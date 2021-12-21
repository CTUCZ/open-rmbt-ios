//
//  CLLocation+RMBTFormat.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    static var timestampFormatter: DateFormatter = {
        let timestampFormatter = DateFormatter()
        timestampFormatter.dateFormat = "HH:mm:ss"
        return timestampFormatter
    }()
    func rmbtFormattedString() -> String {
        var latSeconds = Int(round(fabs(self.coordinate.latitude * 3600)))
        let latDegrees = latSeconds / 3600
        latSeconds = latSeconds % 3600
        
        let latMinutes: CLLocationDegrees = Double(latSeconds) / 60.0
        
        var longSeconds = Int(round(fabs(self.coordinate.longitude * 3600)))
        let longDegrees = longSeconds / 3600
        longSeconds = longSeconds % 3600
        let longMinutes: CLLocationDegrees = Double(longSeconds) / 60.0
        
        let latDirection = (self.coordinate.latitude  >= 0) ? "N" : "S"
        let longDirection = (self.coordinate.longitude >= 0) ? "E" : "W"
        
        return String(format: "%@ %ld° %.3f' %@ %ld° %.3f' (+/- %.0fm)\n@%@", latDirection, Int(latDegrees), latMinutes, longDirection, Int(longDegrees), longMinutes, self.horizontalAccuracy, CLLocation.timestampFormatter.string(from: self.timestamp))
    }
    
    @objc func paramsDictionary() -> [String: Any] {
        return [
            "long": self.coordinate.longitude,
            "lat":  self.coordinate.latitude,
            "time": RMBTHelpers.RMBTTimestamp(with: self.timestamp),
            "accuracy": self.horizontalAccuracy,
            "altitude": self.altitude,
            "speed": (self.speed > 0.0 ? self.speed : 0.0)
        ]
    }
}
