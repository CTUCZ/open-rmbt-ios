//
//  RMBTHistoryLoopResult.swift
//  RMBT
//
//  Created by Polina Gurina on 12.11.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation

class RMBTHistoryLoopResult: RMBTHistoryResult {
    var loopResults: [RMBTHistoryResult] {
        get { return _loopResults }
    }
    
    override var loopUuid: String! {
        get { return _loopUuid }
    }
    
    override var networkTypeServerDescription: String! {
        get { return _networkTypeServerDescription }
    }

    override var timeString: String! {
        get { return _timeString }
    }
    
    override var timestamp: Date! {
        get { return _timestamp }
    }
    
    private var _networkTypeServerDescription: String!
    private var _timeString: String!
    private var _loopResults: [RMBTHistoryResult] = []
    private var _loopUuid: String!
    private var _timestamp: Date!
    
    init(from loopResults: [RMBTHistoryResult]) {
        super.init()
        if let firstResult = loopResults.last {
            _timestamp = firstResult.timestamp
            _timeString = firstResult.timeString
            _networkTypeServerDescription = firstResult.networkTypeServerDescription
            _loopUuid = firstResult.loopUuid ?? firstResult.uuid
        }
        _loopResults = loopResults
    }
}
