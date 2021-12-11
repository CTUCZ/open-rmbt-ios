//
//  RMBTProgress.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

// Ligtweight replacement for NSProgress that supports iOS 8 and allows for simple composition
// without use of thread-associated variables and without reliance on KVO.

class RMBTProgressBase: NSObject {
    @objc private(set) var fractionCompleted: Float = 0
    fileprivate weak var parent: RMBTCompositeProgress?
    
    @objc var onFractionCompleteChange: (_ p: Float) -> Void = { _ in }
    
    fileprivate func notify() {
        onFractionCompleteChange(self.fractionCompleted)
        if let parent = parent {
            parent.notify()
        }
    }
}

@objc class RMBTProgress: RMBTProgressBase {
    @objc private(set) var totalUnitCount: UInt64 = 0
    
    private var _completedUnitCount: UInt64 = 0
    @objc var completedUnitCount: UInt64 {
        get {
            return _completedUnitCount
        }
        set {
            _completedUnitCount = min(totalUnitCount, newValue) // clamp
            self.notify()
        }
    }
    
    @objc(initWithTotalUnitCount:)
    init(totalUnitCount: UInt64) {
        super.init()
        completedUnitCount = 0
        self.totalUnitCount = totalUnitCount
    }

    override var fractionCompleted: Float {
        return totalUnitCount == 0 ? 0 : Float(completedUnitCount) / Float(totalUnitCount)
    }
    
    override var description: String {
        return "RMBTProgress \(self.fractionCompleted) (\(completedUnitCount)/\(totalUnitCount)"
    }
}

@objc class RMBTCompositeProgress: RMBTProgressBase {
    var children: [RMBTProgressBase] = []
    
    @objc(initWithChildren:)
    init(with children: [RMBTProgressBase]) {
        super.init()
        self.children = children
        self.children.forEach( { $0.parent = self })
    }
    
    override var fractionCompleted: Float {
        var total: Float = 0
        if (children.count > 0) {
            children.forEach({ total += $0.fractionCompleted })
            
            return total / Float(children.count)
        } else {
            return 0
        }
    }

    override var description: String {
        return "RMBTCompositeProgress \(self.fractionCompleted) (\(children)"
    }
}
