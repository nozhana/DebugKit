//
//  Queue.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

struct Queue<Element>: RandomAccessCollection, RangeReplaceableCollection {
    private var _array: [Element]
    private let capacity: Int?
    
    init() {
        self._array = []
        self.capacity = nil
    }
    
    @_disfavoredOverload
    init(_ array: [Element] = [], capacity: Int? = nil) {
        self._array = array
        self.capacity = capacity
    }
    
    var startIndex: Int { _array.startIndex }
    var endIndex: Int { _array.endIndex }
    
    mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
        _array.replaceSubrange(subrange, with: newElements)
    }
    
    subscript(position: Int) -> Element {
        get { _array[position] }
        set { _array[position] = newValue }
    }
    
    mutating func push(_ element: Element) {
        _array.insert(element, at: 0)
        if let capacity, _array.count > capacity {
            pop()
        }
    }
    
    @discardableResult
    mutating func pop() -> Element? {
        _array.popLast()
    }
    
    @discardableResult
    mutating func pop(_ count: Int) -> [Element] {
        (0..<count).reduce(into: []) { partialResult, _ in
            guard let last = _array.popLast() else { return }
            partialResult.append(last)
        }
    }
}

extension Queue: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension Queue: Equatable where Element: Equatable {}
extension Queue: Decodable where Element: Decodable {}
extension Queue: Encodable where Element: Encodable {}
