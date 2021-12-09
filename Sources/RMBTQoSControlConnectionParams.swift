//
//  RMBTQoSControlConnectionParams.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 09.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc class RMBTQoSControlConnectionParams: NSObject {

    @objc private(set) var serverAddress: String
    @objc private(set) var port: UInt
    
    init(with serverAddress: String, port: UInt) {
        self.serverAddress = serverAddress;
        self.port = port
    }
    
    override var description: String {
        return String(format: "%@:%ld", serverAddress, port)
    }
}

extension RMBTQoSControlConnectionParams: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
