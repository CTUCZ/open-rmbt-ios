//
//  MKMapView+Additions.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 28.08.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    public func getZoom() -> Double {
      // function returns current zoom of the map
        var angleCamera = Double(self.camera.pitch)// rotation
      if angleCamera > 270 {
        angleCamera = 360 - angleCamera
      } else if angleCamera > 90 {
        angleCamera = abs(angleCamera - 180)
      }
      let angleRad = M_PI * angleCamera / 180 // map rotation in radians
      let width = Double(self.frame.size.width)
      let height = Double(self.frame.size.height)
      let heightOffset : Double = 20
      // the offset (status bar height) which is taken by MapKit
      // into consideration to calculate visible area height.
      // calculating Longitude span corresponding to normal
      // (non-rotated) width
      let spanStraight = width * self.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
      return log2(360 * ((width / 128) / spanStraight))
    }
    
    public func setCenter(_ centerCoordinate: CLLocationCoordinate2D, zoom: Double, animated: Bool) {
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 60.0 / pow(2, zoom) * Double(self.frame.size.width) / 256.0)
        self.setRegion(MKCoordinateRegion(center: centerCoordinate, span: span), animated: animated)
    }
}
