//
//  StringScannerTests.swift
//  SwiftScanner
//
//  Created by Ben Cochran on 11/7/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import XCTest
@testable import SwiftScanner

class StringScannerTests: XCTestCase {

    func testSimpleScanning() {
        let string = "The quick brown fox jumps over the lazy dog."
        var scanner = string.scanner
        
        XCTAssert(scanner.scanCharacterFromSet(CharacterSet.letters) == "T")
        XCTAssert(scanner.scanCharacterFromSet(CharacterSet.letters) == "h")
        XCTAssert(scanner.scanCharacterFromSet(CharacterSet.letters) == "e")
        XCTAssert(scanner.scanString("quick"))
        XCTAssert(scanner.scanString("brown"))
        XCTAssert(scanner.scanString("fox jumps"))
        XCTAssertFalse(scanner.scanString("under"))
        XCTAssert(scanner.scanString("over"))
        scanner.skip()
        XCTAssert(scanner.remainingString == "the lazy dog.")
    }
    
}
