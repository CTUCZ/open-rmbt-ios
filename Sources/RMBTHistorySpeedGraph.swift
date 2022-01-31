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
    private (set) var points: [CGPoint] = []
    
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
        points = RMBTHistorySpeedGraph.createPoints(from: response)
    }
    
    override var description: String {
        return throughputs.map({ t in
            return "[\(RMBTHelpers.RMBTSecondsString(with: Int64(t.endNanos))) \(RMBTSpeedMbpsString(t.kilobitsPerSecond()))]"
        }).joined(separator: "-")
    }
    
    // Pulled from the Android app
    private static func createPoints(from items: [[String: Any]]) -> [CGPoint] {
        var points: [CGPoint] = []
        let maxTimeEntry = items.max(by: { a, b in
            guard let timeA = a["time_elapsed"] as? Int, let timeB = b["time_elapsed"] as? Int else {
                return false
            }
            return timeA < timeB
        })
        if let maxTimeEntry = maxTimeEntry {
            let maxTime = Double(maxTimeEntry["time_elapsed"] as? Int ?? 0)
            let firstItemProgress = ( Double(items.first?["time_elapsed"] as? Int ?? 0) / maxTime ) * 100
            let firstItem = RMBTHistorySpeedGraph.getYPos(from: items.first!)
            if (firstItemProgress > 0) {
                points.append(
                    CGPoint(x: 0, y: firstItem )
                )
            }
            for item in items {
                let x = Double(item["time_elapsed"] as? Int ?? 0) / maxTime
                let y = RMBTHistorySpeedGraph.getYPos(from: item)
                points.append(CGPoint(x: x, y: y))
            }
        }
        return points
    }
    
    private static func getYPos(from speedItem: [String: Any]) -> Double {
        let value = speedItem["bytes_total"] as? Double ?? 0
        let time = Double(speedItem["time_elapsed"] as? Int ?? 1)
        return toLog(value * 8000 / time)
    }
    
    private static func toLog(_ value: Double) -> Double {
        if value < 1e5 {
            return 0
        }
        return (2 + log10(value / 1e7)) / 4
    }
}
