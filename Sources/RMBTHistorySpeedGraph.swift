//
//  RMBTHistorySpeedGraph.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 11.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc class RMBTHistorySpeedGraph: NSObject {

    private (set) var throughputs: [RMBTThroughput] = []
    
    @objc(initWithResponse:)
    init(with response: [[String: Any]]) {
        var bytes: UInt64 = 0
        var t: UInt64 = 0
        throughputs = response.map({ entry in
            let end = UInt64(entry["time_elapsed"] as? Int ?? 0) * NSEC_PER_MSEC
            let deltaBytes = UInt64(entry["bytes_total"] as? Double ?? 0) - bytes
            
            let result = RMBTThroughput(length: deltaBytes, startNanos: t, endNanos: end)
            
            t = end
            bytes += deltaBytes
            return result
        })
    }
    
    override var description: String {
        return throughputs.map({ t in
            return "[\(RMBTHelpers.RMBTSecondsString(with: Int64(t.endNanos))) \(RMBTSpeedMbpsString(t.kilobitsPerSecond()))]"
        }).joined(separator: "-")
    }
}
