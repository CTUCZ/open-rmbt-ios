//
//  RMBTMapOptionsFilter.swift
//  RMBT
//
//  Created by Sergey Glushchenko on 18.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import UIKit

@objc final class RMBTMapOptionsFilter: NSObject {
    @objc public var icon: UIImage? {
        // TODO: Remake it, because if we will use another language then we should put localization for each word from response
        switch title {
        case "Zeitraum", "Period":
            return UIImage(named: "map_options_period")
        case "Betreiber", "Operator":
            return UIImage(named: "map_options_provider")
        case "Statistik", "Statistics":
            return UIImage(named: "map_options_statistic")
        case "Technologie", "Technology":
            return UIImage(named: "map_options_technologies")
        default:
            return nil
        }
    }
    @objc public var title: String = ""
    @objc public var possibleValues: [RMBTMapOptionsFilterValue] = []
    @objc public var activeValue: RMBTMapOptionsFilterValue?
    
    @objc(initWithResponse:) public init(with response: [String: Any]) {
        super.init()
        title = response["title"] as? String ?? ""
        let options = response["options"] as? [[String: Any]] ?? []
        possibleValues = options.map { subresponse in
            let filterValue = RMBTMapOptionsFilterValue(with: subresponse)
            if filterValue.isDefault {
                activeValue = filterValue
            }
            return filterValue
        }
    }
}
