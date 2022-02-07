//
//  RMBTNews.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 08.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import Foundation
import ObjectMapper

class RMBTNews: Mappable {
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        title <- map[Keys.title.rawValue]
        text <- map[Keys.text.rawValue]
        uid <- map[Keys.uid.rawValue]
    }
    
    private enum Keys: String {
        case title
        case text
        case uid
    }
    
    var title: String = ""
    var text: String = ""
    var uid: Int64 = 0

    init(with response: [String: Any]) {
        title = response[Keys.title.rawValue] as? String ?? ""
        text = response[Keys.text.rawValue] as? String ?? ""
        uid = response[Keys.uid.rawValue] as? Int64 ?? 0
    }
}
