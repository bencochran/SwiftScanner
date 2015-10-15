//
//  StringScanning.swift
//  SwiftScanner
//
//  Created by Ben Cochran on 10/15/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

extension String {
    var scanner: Scanner<String.CharacterView> {
        var scanner = Scanner(collection: self.characters)
        scanner.skipTest = CharacterSet.whitespaceAndNewlines.contains
        return scanner
    }
}

extension Scanner where Collection.Generator.Element == Character, Collection.SubSequence.Generator.Element == Character {
    public mutating func scanString(string: String) -> Bool {
        return scanMatchingSequence(string.characters)
    }
    
    public mutating func scanCharactersFromSet(set: CharacterSet) -> String? {
        return scanSequence(set.contains).map(String.init)
    }
    
    public mutating func scanDouble() -> Double? {
        return attempt {
            guard let string = scanCharactersFromSet(.decimalDigits) else {
                return nil
            }
            return Double(string)
        }
    }
}
