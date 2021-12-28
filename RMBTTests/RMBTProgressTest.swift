//
//  RMBTProgressTest.swift
//  RMBTTest
//
//  Created by Sergey Glushchenko on 28.12.2021.
//  Copyright © 2021 appscape gmbh. All rights reserved.
//

import XCTest
@testable import RMBT

class RMBTProgressTest: XCTestCase {

    func testSimple() {
        let p = RMBTProgress(totalUnitCount: 100)
        XCTAssertEqual(p.fractionCompleted, 0.0, accuracy: FLT_EPSILON)
        p.completedUnitCount = 25
        XCTAssertEqual(p.fractionCompleted, 0.25, accuracy: FLT_EPSILON)
        p.completedUnitCount = 200
        XCTAssertEqual(p.fractionCompleted, 1.0, accuracy: FLT_EPSILON, "Clamp")
    }

    func testChildren() {
        let c1 = RMBTProgress(totalUnitCount: 40)
        c1.completedUnitCount = 20
        let c2 = RMBTProgress(totalUnitCount: 40)
        
        let b1 = RMBTCompositeProgress(with: [c1, c2])

        // Both children count equally: so (0.5+0)/2=0.25
        XCTAssertEqual(b1.fractionCompleted, 0.25, accuracy: FLT_EPSILON);
        let b2 = RMBTProgress(totalUnitCount: 40)

        let a = RMBTCompositeProgress(with: [b1, b2])
        XCTAssertEqual(a.fractionCompleted, 0.125, accuracy: FLT_EPSILON)

        c1.completedUnitCount = 0
        XCTAssertEqual(a.fractionCompleted, 0.0, accuracy: FLT_EPSILON)

        c2.completedUnitCount = 10
        XCTAssertEqual(a.fractionCompleted, 0.0625, accuracy: FLT_EPSILON)

        c1.completedUnitCount = 40
        // (1 + 0.25)/2 = 0.625, (0.625+0)/2 = 0.25
        XCTAssertEqual(a.fractionCompleted, 0.3125, accuracy: FLT_EPSILON)
    }

    func testNotify() {
        var updates: [Float] = []
        let b1 = RMBTProgress(totalUnitCount: 10)
        let b2 = RMBTProgress(totalUnitCount: 100)
        
        let a = RMBTCompositeProgress(with: [b1, b2])

        a.onFractionCompleteChange = { p in
            updates.append(p)
        };

        b1.onFractionCompleteChange = { p in
            updates.append(p)
        }

        b1.completedUnitCount = 2
        b1.completedUnitCount = 4
        b1.completedUnitCount = 20


        XCTAssertEqual(updates.count, 6); // 3 for b1, 3 for a
        XCTAssertEqual(updates[0], 0.2, accuracy: FLT_EPSILON);
        XCTAssertEqual(updates[1], 0.1, accuracy: FLT_EPSILON);
        XCTAssertEqual(updates[2], 0.4, accuracy: FLT_EPSILON);
        XCTAssertEqual(updates[3], 0.2, accuracy: FLT_EPSILON);
        XCTAssertEqual(updates[4], 1.0, accuracy: FLT_EPSILON);
        XCTAssertEqual(updates[5], 0.5, accuracy: FLT_EPSILON);
    }

}
