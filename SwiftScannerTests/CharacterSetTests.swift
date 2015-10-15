//
//  CharacterSetTests.swift
//  SwiftScanner
//
//  Created by Ben Cochran on 10/15/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import XCTest
@testable import SwiftScanner


class CharacterSetTests: XCTestCase {
    
    func testSetInclusion() {
        let set = CharacterSet.Set([Character("a"), Character("&"), Character("🇬🇧")])
        
        XCTAssert(set.contains("a"))
        XCTAssert(set.contains("&"))
        XCTAssert(set.contains("🇬🇧"))
        XCTAssertFalse(set.contains("b"))
        XCTAssertFalse(set.contains("🇺🇸"))
        XCTAssertFalse(set.contains("\0"))
        XCTAssertFalse(set.contains("\u{0}"))
        XCTAssertFalse(set.contains("\u{1}"))
        XCTAssertFalse(set.contains("\u{10}"))
    }
    
    func testInversion() {
        let set = CharacterSet.Set([Character("a"), Character("&"), Character("🇬🇧")]).invert()
        
        XCTAssertFalse(set.contains("a"))
        XCTAssertFalse(set.contains("&"))
        XCTAssertFalse(set.contains("🇬🇧"))
        XCTAssert(set.contains("b"))
        XCTAssert(set.contains("🇺🇸"))
        XCTAssert(set.contains("\0"))
        XCTAssert(set.contains("\u{0}"))
        XCTAssert(set.contains("\u{1}"))
        XCTAssert(set.contains("\u{10}"))
        
    }

    func testUnion() {
        let lowercase = CharacterSet(string: "abcdefghijklmnopqrstuvwxyz")
        let digits = CharacterSet(string: "0123456789")
        let alphanum = lowercase.union(digits)
        
        XCTAssert(alphanum.contains("a"))
        XCTAssert(alphanum.contains("m"))
        XCTAssert(alphanum.contains("z"))
        XCTAssert(alphanum.contains("0"))
        XCTAssert(alphanum.contains("5"))
        XCTAssert(alphanum.contains("9"))
        XCTAssertFalse(alphanum.contains("A"))
        XCTAssertFalse(alphanum.contains("Z"))
        XCTAssertFalse(alphanum.contains("\0"))
        XCTAssertFalse(alphanum.contains("é"))
        XCTAssertFalse(alphanum.contains("@"))
    }

    func testIntersection() {
        let first = CharacterSet(string: "abcdefghijklmnopqr")
        let last = CharacterSet(string: "ijklmnopqrstuvwxyz")
        let middle = first.intersect(last)
        
        XCTAssert(middle.contains("i"))
        XCTAssert(middle.contains("m"))
        XCTAssert(middle.contains("r"))
        XCTAssertFalse(middle.contains("d"))
        XCTAssertFalse(middle.contains("w"))
        XCTAssertFalse(middle.contains("M"))
        XCTAssertFalse(middle.contains("🇺🇸"))
    }

    
    func testSubtraction() {
        let lowercase = CharacterSet(string: "abcdefghijklmnopqrstuvwxyz")
        let vowels = CharacterSet(string: "aeiou")
        let consonants = lowercase.subtract(vowels)
        
        XCTAssert(consonants.contains("b"))
        XCTAssert(consonants.contains("z"))
        XCTAssertFalse(consonants.contains("a"))
        XCTAssertFalse(consonants.contains("e"))
        XCTAssertFalse(consonants.contains("i"))
        XCTAssertFalse(consonants.contains("o"))
        XCTAssertFalse(consonants.contains("u"))
        XCTAssertFalse(consonants.contains("A"))
        XCTAssertFalse(consonants.contains("B"))
        XCTAssertFalse(consonants.contains("\0"))
    }
    
    func testPerformanceExample() {
        self.measureBlock {
            let lowercase = CharacterSet(string: "abcdefghijklmnopqrstuvwxyz")
            let vowels = CharacterSet(string: "aeiou")
            let consonants = lowercase.subtract(vowels)
            
            let surrogatePairRange = ClosedInterval<Int>(0xD800, 0xE000)
            
            for i in 0..<100_000 {
                guard !surrogatePairRange.contains(i) else { continue }
                let character = Character(UnicodeScalar(i))
                consonants.contains(character)
            }
        }
    }

}
