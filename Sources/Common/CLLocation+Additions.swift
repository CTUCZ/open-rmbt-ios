//
//  CLLocation+Additions.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.10.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import CoreLocation

extension BinaryFloatingPoint {
    var dms: (degrees: Int, minutes: Double) {
        let seconds: Double = Double(self * 3600)
        let degrees = Int(seconds / 3600)
        let minutes = (seconds - Double(degrees * 3600)) / 60
        return (degrees, minutes)
    }
}

extension CLLocation {
    var dms: String { latitude + " " + longitude }
    var latitude: String {
        let (degrees, minutes) = coordinate.latitude.dms
        
        return String(format: "%@ %d°%.3f'", degrees >= 0 ? String.n : String.s, abs(degrees), minutes)
    }
    var longitude: String {
        let (degrees, minutes) = coordinate.longitude.dms
        return String(format: "%@ %d°%.3f'", degrees >= 0 ? String.e : String.w, abs(degrees), minutes)
    }
}

private extension String {
    static let n = NSLocalizedString("location_location_direction_n", comment: "N")
    static let s = NSLocalizedString("location_location_direction_s", comment: "S")
    static let e = NSLocalizedString("location_location_direction_e", comment: "E")
    static let w = NSLocalizedString("location_location_direction_w", comment: "W")
}
