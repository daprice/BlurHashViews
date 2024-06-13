// Based on https://github.com/woltapp/blurhash by Wolt Enterprises, modified by Dale Price
//
// Copyright (c) 2018 Wolt Enterprises
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

internal func decodeDC(_ value: Int) -> SIMD3<Float> {
	let intR = value >> 16
	let intG = (value >> 8) & 255
	let intB = value & 255
	return .init(sRGBToLinear(intR), sRGBToLinear(intG), sRGBToLinear(intB))
}

internal func decodeAC(_ value: Int, maximumValue: Float) -> SIMD3<Float> {
	let quantR = value / (19 * 19)
	let quantG = (value / 19) % 19
	let quantB = value % 19
	
	return SIMD3(
		signPow((Float(quantR) - 9) / 9, 2),
		signPow((Float(quantG) - 9) / 9, 2),
		signPow((Float(quantB) - 9) / 9, 2)
	) * maximumValue
}

internal func signPow(_ value: Float, _ exp: Float) -> Float {
	return copysign(pow(abs(value), exp), value)
}

fileprivate func sRGBToLinear<Type: BinaryInteger>(_ value: Type) -> Float {
	let v = Float(Int64(value)) / 255
	if v <= 0.04045 { return v / 12.92 }
	else { return pow((v + 0.055) / 1.055, 2.4) }
}

fileprivate let encodeCharacters: [String] = {
	return "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~".map { String($0) }
}()

fileprivate let decodeCharacters: [String: Int] = {
	var dict: [String: Int] = [:]
	for (index, character) in encodeCharacters.enumerated() {
		dict[character] = index
	}
	return dict
}()

internal extension String {
	func decode83() -> Int {
		var value: Int = 0
		for character in self {
			if let digit = decodeCharacters[String(character)] {
				value = value * 83 + digit
			}
		}
		return value
	}
}

internal extension String {
	subscript (offset: Int) -> Character {
		return self[index(startIndex, offsetBy: offset)]
	}
	
	subscript (bounds: CountableClosedRange<Int>) -> Substring {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		return self[start...end]
	}
	
	subscript (bounds: CountableRange<Int>) -> Substring {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		return self[start..<end]
	}
}
