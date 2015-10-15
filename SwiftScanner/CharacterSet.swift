//
//  CharacterSet.swift
//  SwiftScanner
//
//  Created by Ben Cochran on 10/15/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

public enum CharacterSet {
    case Set(Swift.Set<Character>)
    // Ranges are … problematic. Leaving them out for now
    // case Range(ClosedInterval<Character>)
    indirect case Inverted(CharacterSet)
    indirect case Union(CharacterSet, CharacterSet)
    indirect case Intersection(CharacterSet, CharacterSet)
}

extension CharacterSet {
    public func contains(character: Character) -> Bool {
        switch self {
        case let .Set(set):
            return set.contains(character)
        // case let .Range(range):
        //     return range.contains(character)
        case let .Inverted(characterSet):
            return !characterSet.contains(character)
        case let .Union(left, right):
            return left.contains(character) || right.contains(character)
        case let .Intersection(left, right):
            return left.contains(character) && right.contains(character)
        }
    }
}

extension CharacterSet {
    public func invert() -> CharacterSet {
        return .Inverted(self)
    }
    
    public func union(other: CharacterSet) -> CharacterSet {
        return .Union(self, other)
    }
    
    public func subtract(other: CharacterSet) -> CharacterSet {
        return intersect(other.invert())
    }
    
    public func intersect(other: CharacterSet) -> CharacterSet {
        return .Intersection(self, other)
    }
}

extension CharacterSet {
    public init<S: SequenceType where S.Generator.Element == Character>(_ sequence: S) {
        self = .Set(Swift.Set(sequence))
    }
    public init(string: String) {
        self = .Set(Swift.Set(string.characters))
    }
}

extension CharacterSet {
    public static var whitespace: CharacterSet {
        return CharacterSet(string: " \t\n\r")
    }
    public static var whitespaceAndNewlines: CharacterSet {
        return whitespace.union(newlines)
    }
    public static var decimalDigits: CharacterSet {
        return CharacterSet(string: "0123456789Ee-.")
    }
    public static var letters: CharacterSet {
        return lowercaseLetters.union(uppercaseLetters)
    }
    public static var lowercaseLetters: CharacterSet {
        return CharacterSet(string: "abcdefghijklmnopqrstuvwxyz")
    }
    public static var uppercaseLetters: CharacterSet {
        return CharacterSet(string: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    }
    public static var alpanumeric: CharacterSet {
        return letters.union(decimalDigits)
    }
    public static var punctuation: CharacterSet {
        return CharacterSet(string: ".,!?;:")
    }
    public static var newlines: CharacterSet {
        return CharacterSet(string: "\n\r")
    }
}


//public struct CharacterSet {
////    private var inverted: Bool
//    private var set: Set<Character>
//    
//    public init(_ set: Set<Character>) {
//        self.set = set
//    }
//    public init<S: SequenceType where S.Generator.Element == Character>(_ sequence: S) {
//        set = Set(sequence)
//    }
//    public init(string: String) {
//        set = Set(string.characters)
//    }
//    
//    public func contains(character: Character) -> Bool {
//        return set.contains(character)
//    }
//}
//
//extension CharacterSet {
//    public func union(other: CharacterSet) -> CharacterSet {
//        return CharacterSet(set.union(other.set))
//    }
//    
//    public func subtract(other: CharacterSet) -> CharacterSet {
//        return CharacterSet(set.subtract(other.set))
//    }
//    
//    public func intersect(other: CharacterSet) -> CharacterSet {
//        return CharacterSet(set.intersect(other.set))
//    }
//}
//
//extension CharacterSet {
//    public static var whitespace: CharacterSet {
//        return CharacterSet(string: " \t\n\r")
//    }
//    public static var whitespaceAndNewlines: CharacterSet {
//        return whitespace.union(newlines)
//    }
//    public static var decimalDigits: CharacterSet {
//        return CharacterSet(string: "0123456789Ee-.")
//    }
//    public static var letters: CharacterSet {
//        return lowercaseLetters.union(uppercaseLetters)
//    }
//    public static var lowercaseLetters: CharacterSet {
//        return CharacterSet(string: "abcdefghijklmnopqrstuvwxyz")
//    }
//    public static var uppercaseLetters: CharacterSet {
//        return CharacterSet(string: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
//    }
//    public static var alpanumeric: CharacterSet {
//        return letters.union(decimalDigits)
//    }
//    public static var punctuation: CharacterSet {
//        return CharacterSet(string: ".,!?;:")
//    }
//    public static var newlines: CharacterSet {
//        return CharacterSet(string: "\n\r")
//    }
//}
//
//let a = Character("a")...Character("z")




