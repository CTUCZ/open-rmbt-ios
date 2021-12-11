//
//  RMBTQoSDNSTest.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 10.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc class RMBTQoSDNSTest: RMBTQoSTest {

    private var executor: RMBTQOSDNSTestExecutor?
    
    override init?(with params: [String : Any]) {
        super.init(with: params)
        executor = RMBTQOSDNSTestExecutor(params: params)
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
