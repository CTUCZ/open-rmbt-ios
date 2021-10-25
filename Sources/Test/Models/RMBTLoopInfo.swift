//
//  RMBTLoopInfo.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 17.09.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

@objc final class RMBTLoopInfo: NSObject {
    @objc var waitMeters: UInt = 0
    @objc var waitMinutes: UInt = 0
    
    @objc var current: UInt = 0 // 1-based, but initialized with 0 -> increment before first run
    @objc var total: UInt = 0
    
    @objc init(with meters: UInt, minutes: UInt, total: UInt) {
        self.waitMeters = meters
        self.waitMinutes = minutes
        self.total = total
    }
    
    @objc func increment() {
        current += 1
    }
    
    @objc var isFinished: Bool {
        return current >= total
    }
    
    @objc var params: [String: Any] {
        return [
            "loopmode_info": [
                "max_delay": waitMinutes,
                "max_movement": waitMeters,
                "max_tests": total,
                "test_counter": current,
                // text_counter was a typo in old server api, send for compatibility
                "text_counter": current
            ]
        ]
    }
}
