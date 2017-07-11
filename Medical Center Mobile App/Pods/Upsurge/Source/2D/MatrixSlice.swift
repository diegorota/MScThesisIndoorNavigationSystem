// Copyright © 2015 Venture Media Labs.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation


open class MatrixSlice<T: Value>: MutableQuadraticType, CustomStringConvertible, Equatable {
    public typealias Index = (Int, Int)
    public typealias Slice = MatrixSlice<Element>
    public typealias Element = T

    open var rows: Int
    open var columns: Int
    
    open var base: Matrix<Element>
    open var span: Span

    open func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        let index = linearIndex(span.startIndex)
        return try base.withUnsafeBufferPointer { pointer in
            let start = pointer.baseAddress! + index
            return try body(UnsafeBufferPointer(start: start, count: pointer.count - index))
        }
    }

    open func withUnsafePointer<R>(_ body: (UnsafePointer<Element>) throws -> R) rethrows -> R {
        let index = linearIndex(span.startIndex)
        return try base.withUnsafePointer { pointer in
            return try body(pointer + index)
        }
    }

    open func withUnsafeMutableBufferPointer<R>(_ body: (UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        let index = linearIndex(span.startIndex)
        return try base.withUnsafeMutableBufferPointer { pointer in
            let start = pointer.baseAddress! + index
            return try body(UnsafeMutableBufferPointer(start: start, count: pointer.count - index))
        }
    }

    open func withUnsafeMutablePointer<R>(_ body: (UnsafeMutablePointer<Element>) throws -> R) rethrows -> R {
        let index = linearIndex(span.startIndex)
        return try base.withUnsafeMutablePointer { pointer in
            return try body(pointer + index)
        }
    }
    
    open var arrangement: QuadraticArrangement {
        return .rowMajor
    }
    
    open var stride: Int {
        return base.dimensions[1]
    }
    
    open var step: Int {
        return base.elements.step
    }

    init(base: Matrix<Element>, span: Span) {
        assert(Span(zeroTo: base.dimensions).contains(span))
        self.base = base
        self.span = span
        
        rows = span.dimensions[0]
        columns = span.dimensions[1]
    }
    
    open subscript(indices: Int...) -> Element {
        get {
            return self[indices]
        }
        set {
            self[indices] = newValue
        }
    }
    
    open subscript(indices: [Int]) -> Element {
        get {
            assert(indices.count == 2)
            return base[indices]
        }
        set {
            assert(indices.count == 2)
            base[indices] = newValue
        }
    }
    
    fileprivate subscript(span: Span) -> Slice {
        get {
            assert(self.span.contains(span))
            return MatrixSlice(base: base, span: span)
        }
        set {
            assert(self.span.contains(span))
            assert(self.span ≅ newValue.span)
            for (lhsIndex, rhsIndex) in zip(span, newValue.span) {
                self[lhsIndex] = newValue[rhsIndex]
            }
        }
    }
    
    open subscript(intervals: IntervalType...) -> Slice {
        get {
            return self[intervals]
        }
        set {
            self[intervals] = newValue
        }
    }
    
    open subscript(intervals: [IntervalType]) -> Slice {
        get {
            let span = Span(base: self.span, intervals: intervals)
            return self[span]
        }
        set {
            let span = Span(base: self.span, intervals: intervals)
            self[span] = newValue
        }
    }
    
    open func indexIsValid(_ indices: [Int]) -> Bool {
        assert(indices.count == dimensions.count)
        for (i, index) in indices.enumerated() {
            if index < span[i].lowerBound || span[i].upperBound < index {
                return false
            }
        }
        return true
    }
    
    open var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = (0..<columns).map{"\(self[Interval(integerLiteral: span.startIndex[0] + i), Interval(integerLiteral: span.startIndex[1] + $0)])"}.joined(separator: "\t")
            
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}

// MARK: - Equatable

public func ==<T>(lhs: MatrixSlice<T>, rhs: Matrix<T>) -> Bool {
    assert(lhs.span ≅ rhs.span)
    for (lhsIndex, rhsIndex) in zip(lhs.span, rhs.span) {
        if lhs[lhsIndex] != rhs[rhsIndex] {
            return false
        }
    }
    return true
}

public func ==<T>(lhs: MatrixSlice<T>, rhs: MatrixSlice<T>) -> Bool {
    assert(lhs.span ≅ rhs.span)
    for (lhsIndex, rhsIndex) in zip(lhs.span, rhs.span) {
        if lhs[lhsIndex] != rhs[rhsIndex] {
            return false
        }
    }
    return true
}

public func ==<T>(lhs: MatrixSlice<T>, rhs: Tensor<T>) -> Bool {
    assert(lhs.span ≅ rhs.span)
    for (lhsIndex, rhsIndex) in zip(lhs.span, rhs.span) {
        if lhs[lhsIndex] != rhs[rhsIndex] {
            return false
        }
    }
    return true
}

public func ==<T>(lhs: MatrixSlice<T>, rhs: TensorSlice<T>) -> Bool {
    assert(lhs.span ≅ rhs.span)
    for (lhsIndex, rhsIndex) in zip(lhs.span, rhs.span) {
        if lhs[lhsIndex] != rhs[rhsIndex] {
            return false
        }
    }
    return true
}

public func ==<T>(lhs: MatrixSlice<T>, rhs: TwoDimensionalTensorSlice<T>) -> Bool {
    assert(lhs.span ≅ rhs.span)
    for (lhsIndex, rhsIndex) in zip(lhs.span, rhs.span) {
        if lhs[lhsIndex] != rhs[rhsIndex] {
            return false
        }
    }
    return true
}

