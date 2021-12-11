//
//  UIView+Position.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

extension UIView {
    var frameOrigin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    var frameSize: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }

    var frameX: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    
    var frameY: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    

    // Setting these modifies the origin but not the size.
    var frameRight: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            self.frame.origin.x = newValue - self.frame.size.width
        }
    }
    
    var frameBottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            self.frame.origin.y = newValue - self.frame.size.height
        }
    }
    
    var frameWidth: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var frameHeight: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    var boundsOrigin: CGPoint {
        get {
            return self.bounds.origin
        }
        set {
            self.bounds.origin = newValue
        }
    }
    
    var boundsSize: CGSize {
        get {
            return self.bounds.size
        }
        set {
            self.bounds.size = newValue
        }
    }

    var boundsX: CGFloat {
        get {
            return self.bounds.origin.x
        }
        set {
            self.bounds.origin.x = newValue
        }
    }
    
    var boundsY: CGFloat {
        get {
            return self.bounds.origin.y
        }
        set {
            self.bounds.origin.y = newValue
        }
    }
    
    var boundsRight: CGFloat {
        get {
            return self.bounds.origin.x + self.bounds.size.width
        }
        set {
            self.bounds.origin.x = newValue - self.bounds.size.width
        }
    }
    
    var boundsBottom: CGFloat {
        get {
            return self.bounds.origin.y + self.bounds.size.height
        }
        set {
            self.bounds.origin.y = newValue - self.bounds.size.height
        }
    }
   
    var boundsWidth: CGFloat {
        get {
            return self.bounds.size.width
        }
        set {
            self.bounds.size.width = newValue
        }
    }
    
    var boundsHeight: CGFloat {
        get {
            return self.bounds.size.height
        }
        set {
            self.bounds.size.height = newValue
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center.x = newValue
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center.y = newValue
        }
    }
}
