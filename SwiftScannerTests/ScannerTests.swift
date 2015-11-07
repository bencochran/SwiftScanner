//
//  ScannerTests.swift
//  SwiftScannerTests
//
//  Created by Ben Cochran on 10/15/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import XCTest
@testable import SwiftScanner

class SwiftScannerTests: XCTestCase {
    
    func testExample() {
        var scanner = Scanner(collection: 0..<50)
        XCTAssertFalse(scanner.scanElement(1))
        XCTAssert(scanner.scanElement(0))
        XCTAssert(scanner.scanElement(1))
        XCTAssert(scanner.scanElement(2))
        XCTAssert(scanner.scanMatchingSequence(3..<47))
        XCTAssert(scanner.scanElement(47))
        XCTAssert(scanner.scanElementFromSequence(0..<100) == 48)
        XCTAssert(scanner.scanElement(49))
        XCTAssertNil(scanner.scanElementFromSequence(0..<100))
    }
    
}
