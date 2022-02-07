//
//  NewsRequest.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 07.02.2022.
//  Copyright © 2022 appscape gmbh. All rights reserved.
//

import Foundation
import ObjectMapper

class NewsRequest: BasicRequest {
    var lastNewsUid: Int64
    
    init(with lastNewsUid: Int64) {
        self.lastNewsUid = lastNewsUid
        super.init()
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        lastNewsUid <- map["lastNewsUid"]
    }
}
