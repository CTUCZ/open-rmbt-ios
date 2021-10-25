//
//  CLLocation+Additions.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.10.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

extension BinaryFloatingPoint {
    var dms: (degrees: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self * 3600)
        let degrees = seconds / 3600
        seconds = abs(seconds % 3600)
        return (degrees, seconds / 60, seconds % 60)
    }
}

extension CLLocation {
    var dms: String { latitude + " " + longitude }
    var latitude: String {
        let (degrees, minutes, seconds) = coordinate.latitude.dms
        
        return String(format: "%@ %d°%d,%d'", degrees >= 0 ? String.n : String.s, abs(degrees), minutes, seconds)
    }
    var longitude: String {
        let (degrees, minutes, seconds) = coordinate.longitude.dms
        return String(format: "%@ %d°%d,%d'", degrees >= 0 ? String.e : String.w, abs(degrees), minutes, seconds)
    }
}

private extension String {
    static let n = NSLocalizedString("location_location_direction_n", comment: "N")
    static let s = NSLocalizedString("location_location_direction_s", comment: "S")
    static let e = NSLocalizedString("location_location_direction_e", comment: "E")
    static let w = NSLocalizedString("location_location_direction_w", comment: "W")
}
