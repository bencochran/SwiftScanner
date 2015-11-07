//
//  Scanner.swift
//  SwiftScanner
//
//  Created by Ben Cochran on 10/15/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

public struct Scanner<Collection : CollectionType> : GeneratorType {
    public typealias Element = Collection.Generator.Element
    
    /// The collection that this scanner is scanning
    public let collection: Collection
    
    /// The current position of the scanner in `collection`.
    public var location: Collection.Index
    
    /// Elements passing this test will be skipped by the scanner when looking
    /// for scannable elements.
    ///
    /// Defaults to nil, meaning no elements will be skipped.
    public var skipTest: (Element -> Bool)?
    
    public init(collection: Collection) {
        self.collection = collection
        location = collection.startIndex
    }
    
    /// `true` if the scanner is currently at the beginning of the collection
    public var atBeginning: Bool { return location == collection.startIndex }
    
    /// `true` if the scanner is currently at the end of the collection
    public var atEnd: Bool { return location == collection.endIndex }
    
    /// `true` if the scanner is currently at an element that passes `skipTest`
    public var atSkipped: Bool {
        guard !atEnd else { return false }
        guard let test = skipTest else { return false }
        return test(collection[location])
    }
    
    /// The element at the current position of the scanner (or nil if the
    /// scanner is at the end)
    public var current: Element? {
        guard !atEnd else { return nil }
        return collection[location]
    }
    
    /// The remaining subsequence from the current position to the end of the
    /// collection or nil if the scanner is at the end. Note: this does not
    /// first skip elements according to `skipTest`.
    public var remaining: Collection.SubSequence? {
        guard !atEnd else { return nil }
        return collection[location..<collection.endIndex]
    }
    
    /// Move the scanner from the current position until `skipTest` is not true
    /// If `skipTest` is nil, nothing is changed
    public mutating func skip() {
        guard let test = skipTest else { return }
        scanUpTo { !test($0) }
    }
    
    /// Return the current element and advance the scanner to the next element.
    /// If the scanner is current at the end, returns nil and no change of
    /// position is made.
    public mutating func next() -> Element? {
        guard !atEnd else { return nil }
        let element = current
        location = location.advancedBy(1, limit: collection.endIndex)
        return element
    }
    
    /// Move the scanner to the previous element (or if it was already at the
    /// beginning, no change is made)
    public mutating func previous() {
        guard !atBeginning else { return }
        location = location.advancedBy(-1, limit: collection.startIndex)
    }
    
    /// Perform the given closure, returning its result and resetting the
    /// scanner's location if the closure returns false. If `skip` is true,
    /// `skip()` is called before the closure (see `skip()` for details)
    public mutating func attempt(skip skip: Bool = true, @noescape test: () -> Bool) -> Bool {
        return attempt { test() ? true : nil } ?? false
    }
    
    /// Perform the given closure, returning its result and resetting the
    /// scanner's location if the closure returns nil. If `skip` is true,
    /// `skip()` is called before the closure (see `skip()` for details)
    public mutating func attempt<T>(skip skip: Bool = true, @noescape extractor: () -> T?) -> T? {
        let savedLocation = location
        
        if skip { self.skip() }
        
        // Attempt the extraction
        let result = extractor()
        
        // Reset the position if the closure failed
        if result == nil { location = savedLocation }
        
        return result
    }
    
    /// Perform the given test, returning its result and resetting the
    /// scanner's location regardless of the result
    public mutating func peek(@noescape test: () -> Bool) -> Bool {
        return peek { test() ? true : nil } ?? false
    }
    
    /// Perform the given extraction, returning its result and resetting the
    /// scanner's location regardless of the result
    public mutating func peek<T>(@noescape extractor: () -> T?) -> T? {
        let savedLocation = location
        let result = extractor()
        location = savedLocation
        return result
    }
    
    /// Scan a subsequence until the given test returns `true` or the end of the
    /// collection is reached. If the first tested element returns `true`, an
    /// empty sequence is returned.
    public mutating func scanUpTo(@noescape test: Element -> Bool) -> Collection.SubSequence {
        let start = location
        var element: Element
        repeat {
            guard !atEnd else { return collection[start..<location] }
            element = collection[location]
            location = location.advancedBy(1, limit: collection.endIndex)
        } while !test(element)
        
        // Rewind one so we're pointing at the element that passed the test
        location = location.advancedBy(-1, limit: collection.startIndex)
        return collection[start..<location]
    }
    
    /// Scans a single element if it passes the test and returns the result. If
    /// the current element doesn’t pass the test the scanner position is reset.
    public mutating func scanElement(@noescape test: Element -> Bool) -> Bool {
        return scanElement(test).map { _ in true } ?? false
    }
    
    /// Scans and returns a single element that passes the test. If the current
    /// element doesn’t pass the test the scanner position is reset and nil is
    /// returned
    public mutating func scanElement(@noescape test: Element -> Bool) -> Element? {
        return attempt {
            if let element = next() {
                if test(element) {
                    return element
                }
            }
            return nil
        }
    }

    
    /// Scan a subsequence until the given test returns `false` or the end of
    /// the collection is reached. If the first tested element returns `false`,
    /// nil is returned.
    public mutating func scanSequence(@noescape test: Element -> Bool) -> Collection.SubSequence? {
        return attempt {
            let start = location
            
            while let element = next() {
                if !test(element) {
                    previous() // rewind
                    break
                }
            }
            
            guard start.distanceTo(location) > 0 else { return nil }
            
            return collection[start..<location]
        }
    }
}

extension Scanner where Collection.Generator.Element : Equatable {
    /// Test for a series of elements matching the given sequence
    public mutating func scanMatchingSequence<S : SequenceType where S.Generator.Element == Element>(sequence: S) -> Bool {
        return attempt {
            var searchGenerator = sequence.generate()
            
            while true {
                let searchElement = searchGenerator.next()
                if searchElement == nil {
                    return true
                }
                
                let element = next()
                if element == nil {
                    break
                }
                
                if element != searchElement {
                    break
                }
            }
            
            return false
        }
    }
    
    /// Scan a single element from the given sequence
    public mutating func scanElementFromSequence<S : SequenceType where S.Generator.Element == Element>(sequence: S) -> Element? {
        return scanElement(sequence.contains)
    }
    
    /// Test for an element matching the given element
    public mutating func scanElement(element: Element) -> Bool {
        return scanElement { $0 == element }
    }
}

extension Scanner where Collection.Generator.Element : Hashable {
    /// Advance the scanner until finding an element from the given set and
    /// return the subsequence that was found before the matching element.
    public mutating func scanUpToElementFromSet(set: Set<Element>) -> Collection.SubSequence {
        return scanUpTo(set.contains)
    }
    
    /// Scan a single element from the given set and return it if it is found.
    public mutating func scanElementFromSet(set: Set<Element>) -> Element? {
        return attempt {
            if let element = next() {
                if set.contains(element) {
                    return element
                }
            }
            return nil
        }
    }
    
    /// Scan a subsequence of elements that are found in the given set
    public mutating func scanSequenceFromSet(set: Set<Element>) -> Collection.SubSequence? {
        return scanSequence(set.contains)
    }
}
