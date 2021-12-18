//
//  RMBTMapOptionsOverlay.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 18.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc final public class RMBTMapOptionsOverlay: NSObject {
    @objc public var identifier: String
    @objc public var localizedDescription: String
    @objc public var localizedSummary: String
    
    @objc public init(identifier: String, localizedDescription: String, localizedSummary: String) {
        self.identifier = identifier
        self.localizedDescription = localizedDescription
        self.localizedSummary = localizedSummary
    }
}
