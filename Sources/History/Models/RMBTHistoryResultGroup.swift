//
//  RMBTHistoryResultGroup.swift
//  RMBT
//
//  Created by Polina on 12.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

class RMBTHistoryResultGroup: RMBTHistoryResult {
    var loopResults: [RMBTHistoryResult] {
        get { return _loopResults }
    }
    
    override var timestamp: Date! {
        get { return _timestamp }
    }
    
    private var _timestamp: Date!
    private var _loopResults: [RMBTHistoryResult] = []
    
    init(from loopResults: [RMBTHistoryResult]) {
        super.init()
        if let firstResult = loopResults.first {
            _timestamp = firstResult.timestamp
        }
        _loopResults = loopResults
    }
}
