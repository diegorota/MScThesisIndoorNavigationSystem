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

import Darwin

public struct Complex<Element: Real>: Value {
    public var real: Element = 0.0
    public var imag: Element = 0.0

    public init() {}

    public init(integerLiteral value: Int) {
        real = Element(value)
    }

    public init(real: Element, imag: Element) {
        self.real = real
        self.imag = imag
    }

    public var magnitude: Element {
        if let real = real as? Double, let imag = imag as? Double {
            return hypot(real, imag) as! Element
        } else if let real = real as? Float, let imag = imag as? Float {
            return hypot(real, imag) as! Element
        }
        fatalError()
    }

    public var phase: Element {
        if let real = real as? Double, let imag = imag as? Double {
            return atan2(imag, real) as! Element
        } else if let real = real as? Float, let imag = imag as? Float {
            return atan2(imag, real) as! Element
        }
        fatalError()
    }

    public static func abs(_ x: Complex) -> Complex {
        return Complex(real: x.magnitude, imag: 0.0)
    }

    public var hashValue: Int {
        return real.hashValue ^ imag.hashValue
    }
    
    public var description: String {
        return "\(real) + \(imag)i"
    }
}

public func ==<T: Real>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
    return lhs.real == rhs.real && lhs.imag == rhs.imag
}

public func <<T: Real>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
    return lhs.real < rhs.real || (lhs.real == rhs.real && lhs.imag < rhs.imag)
}

// MARK: - Double

public func +(lhs: Complex<Double>, rhs: Complex<Double>) -> Complex<Double> {
    return Complex<Double>(real: lhs.real + rhs.real, imag: lhs.imag + rhs.imag)
}

public func -(lhs: Complex<Double>, rhs: Complex<Double>) -> Complex<Double> {
    return Complex<Double>(real: lhs.real - rhs.real, imag: lhs.imag - rhs.imag)
}

public func *(lhs: Complex<Double>, rhs: Complex<Double>) -> Complex<Double> {
    return Complex<Double>(real: lhs.real * rhs.real - lhs.imag * rhs.imag, imag: lhs.real * rhs.imag + lhs.imag * rhs.real)
}

public func *(x: Complex<Double>, a: Double) -> Complex<Double> {
    return Complex<Double>(real: x.real * a, imag: x.imag * a)
}

public func *(a: Double, x: Complex<Double>) -> Complex<Double> {
    return Complex<Double>(real: x.real * a, imag: x.imag * a)
}

public func /(lhs: Complex<Double>, rhs: Complex<Double>) -> Complex<Double> {
    let rhsMagSq = rhs.real*rhs.real + rhs.imag*rhs.imag
    return Complex<Double>(
        real: (lhs.real*rhs.real + lhs.imag*rhs.imag) / rhsMagSq,
        imag: (lhs.imag*rhs.real - lhs.real*rhs.imag) / rhsMagSq)
}

public func /(x: Complex<Double>, a: Double) -> Complex<Double> {
    return Complex<Double>(real: x.real / a, imag: x.imag / a)
}

public func /(a: Double, x: Complex<Double>) -> Complex<Double> {
    let xMagSq = x.real*x.real + x.imag*x.imag
    return Complex<Double>(real: a*x.real / xMagSq, imag: -a*x.imag / xMagSq)
}


// MARK: - Float

public func +(lhs: Complex<Float>, rhs: Complex<Float>) -> Complex<Float> {
    return Complex<Float>(real: lhs.real + rhs.real, imag: lhs.imag + rhs.imag)
}

public func -(lhs: Complex<Float>, rhs: Complex<Float>) -> Complex<Float> {
    return Complex<Float>(real: lhs.real - rhs.real, imag: lhs.imag - rhs.imag)
}

public func *(lhs: Complex<Float>, rhs: Complex<Float>) -> Complex<Float> {
    return Complex<Float>(real: lhs.real * rhs.real - lhs.imag * rhs.imag, imag: lhs.real * rhs.imag + lhs.imag * rhs.real)
}

public func *(x: Complex<Float>, a: Float) -> Complex<Float> {
    return Complex<Float>(real: x.real * a, imag: x.imag * a)
}

public func *(a: Float, x: Complex<Float>) -> Complex<Float> {
    return Complex<Float>(real: x.real * a, imag: x.imag * a)
}

public func /(lhs: Complex<Float>, rhs: Complex<Float>) -> Complex<Float> {
    let rhsMagSq = rhs.real*rhs.real + rhs.imag*rhs.imag
    return Complex<Float>(
        real: (lhs.real*rhs.real + lhs.imag*rhs.imag) / rhsMagSq,
        imag: (lhs.imag*rhs.real - lhs.real*rhs.imag) / rhsMagSq)
}

public func /(x: Complex<Float>, a: Float) -> Complex<Float> {
    return Complex<Float>(real: x.real / a, imag: x.imag / a)
}

public func /(a: Float, x: Complex<Float>) -> Complex<Float> {
    let xMagSq = x.real*x.real + x.imag*x.imag
    return Complex<Float>(real: a*x.real / xMagSq, imag: -a*x.imag / xMagSq)
}
