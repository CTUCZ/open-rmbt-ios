//
//  RMBTSpeedTest.swift
//  RMBTTest
//
//  Created by Sergey Glushchenko on 28.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import XCTest
import RMBT

class RMBTSpeedTest: XCTestCase {

    func testFormatting() {
        XCTAssertEqual(RMBTSpeedMbpsString(11221), "11 Mbps")
        
        XCTAssertEqual(RMBTSpeedMbpsString(11500), "12 Mbps") // bankers' rounding
        XCTAssertEqual(RMBTSpeedMbpsString(11490), "11 Mbps")
        
        XCTAssertEqual(RMBTSpeedMbpsString(11490), "11 Mbps")
        XCTAssertEqual(RMBTSpeedMbpsString(11490), "11 Mbps")
        XCTAssertEqual(RMBTSpeedMbpsString(11490), "11 Mbps")
        
        XCTAssertEqual(RMBTSpeedMbpsString(154), "0.15 Mbps")
        XCTAssertEqual(RMBTSpeedMbpsString(155), "0.16 Mbps")
        
        XCTAssertEqual(RMBTSpeedMbpsString(123000), "120 Mbps")
        
        XCTAssertEqual(RMBTSpeedMbpsString(1250), "1.2 Mbps")
    }

}
