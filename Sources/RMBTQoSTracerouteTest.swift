//
//  RMBTQoSTracerouteTest.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc class RMBTQoSTracerouteTest: RMBTQoSTest {

    private var executor: RMBTQoSTracerouteTestExecutor?
    
    init?(with params: [String : Any], masked: Bool) {
        super.init(with: params)
        executor = RMBTQoSTracerouteTestExecutor(params: params, masked: masked)
        executor?.concurrencyGroup = self.concurrencyGroup
        executor?.uid = self.uid
        executor?.timeoutNanos = self.timeoutNanos
    }
    
    override func cancel() {
        executor?.cancelled = true
        super.cancel()
    }
    
    override func main() {
        assert(!self.isCancelled)
        executor?.main()
    }
    
    override var result: [String: Any] {
        return executor?.result() as? [String: Any] ?? [:]
    }
    
    override var description: String {
        return executor?.description ?? ""
    }
    
}
