//
//  RMBTNews.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 08.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

class RMBTNews: NSObject {
    private enum Keys: String {
        case title
        case text
        case uid
    }
    
    let title: String
    let text: String
    let uid: Int64

    init(with response: [String: Any]) {
        title = response[Keys.title.rawValue] as? String ?? ""
        text = response[Keys.text.rawValue] as? String ?? ""
        uid = response[Keys.uid.rawValue] as? Int64 ?? 0
    }
}
