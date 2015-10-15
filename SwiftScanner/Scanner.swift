//
//  Scanner.swift
//  SwiftScanner
//
//  Created by Ben Cochran on 10/15/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

public struct Scanner<Collection : CollectionType> : GeneratorType {
    public typealias Element = Collection.Generator.Element
    public let collection: Collection
    public var location: Collection.Index
    //    public var skippedElements: Set<Element>?
    public var skipTest: (Element -> Bool)?
    
    public init(collection: Collection) {
        self.collection = collection
        location = collection.startIndex
    }
    
    public var atBeginning: Bool { return location == collection.startIndex }
    public var atEnd: Bool { return location == collection.endIndex }
    public var atSkipped: Bool {
        guard !atEnd else { return false }
        return skipTest?(collection[location]) ?? false
    }
    
    public mutating func skip() {
        guard let test = skipTest else { return }
        scanUpTo { !test($0) }
    }
    
    internal var current: Element? {
        guard !atEnd else { return nil }
        return collection[location]
    }
    
    public mutating func next() -> Element? {
        guard !atEnd else { return nil }
        defer { location = location.advancedBy(1, limit: collection.endIndex) }
        return collection[location]
    }
    
    public mutating func previous() {
        guard !atBeginning else { return }
        location = location.advancedBy(-1, limit: collection.startIndex)
    }
    
    public mutating func attempt(skip skip: Bool = true, @noescape closure: () -> Bool) -> Bool {
        return attempt { closure() ? true : nil } ?? false
    }
    
    public mutating func attempt<T>(skip skip: Bool = true, @noescape closure: () -> T?) -> T? {
        let savedLocation = location
        if skip { self.skip() }
        let result = closure()
        if result == nil {
            location = savedLocation
        }
        return result
    }
    
    public mutating func peek(@noescape closure: () -> Bool) -> Bool {
        return peek { closure() ? true : nil } ?? false
    }
    
    public mutating func peek<T>(@noescape closure: () -> T?) -> T? {
        let savedLocation = location
        defer { location = savedLocation }
        return closure()
    }
    
    public mutating func scanUpTo(@noescape test: Element -> Bool) -> Collection.SubSequence {
        let start = location
        var element: Element
        repeat {
            guard location != collection.endIndex else { return collection[start..<location] }
            element = collection[location]
            location = location.advancedBy(1, limit: collection.endIndex)
        } while !test(element)
        location = location.advancedBy(-1, limit: collection.startIndex)
        return collection[start..<location]
    }
    
    public mutating func scanElement(@noescape test: Element -> Bool) -> Bool {
        return attempt {
            next().map(test) ?? false
        }
    }
    
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
    
    public mutating func scanElement(element: Element) -> Bool {
        return scanElement { $0 == element }
    }
}

extension Scanner where Collection.Generator.Element : Hashable {
    public mutating func scanUpToElementFromSet(set: Set<Element>) -> Collection.SubSequence {
        return scanUpTo(set.contains)
    }
    
    
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
    
    public mutating func scanSequenceFromSet(set: Set<Element>) -> Collection.SubSequence? {
        return scanSequence(set.contains)
    }
}
