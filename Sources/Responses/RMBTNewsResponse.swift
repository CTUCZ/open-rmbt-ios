//
//  RMBTNewsResponse.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 07.02.2022.
//  Copyright © 2022 appscape gmbh. All rights reserved.
//

import Foundation
import ObjectMapper

class RMBTNewsResponse: BasicResponse {

    var news: [RMBTNews] = []
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        news <- map["news"]
    }
}
