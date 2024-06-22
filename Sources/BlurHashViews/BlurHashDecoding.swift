// Based on portions of https://github.com/woltapp/blurhash by Wolt Enterprises, modified by Dale Price
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
import simd

internal func decodeDC(_ value: Int) -> SIMD3<Float> {
	let intR = value >> 16
	let intG = (value >> 8) & 255
	let intB = value & 255
	return .init(sRGBToLinear(intR), sRGBToLinear(intG), sRGBToLinear(intB))
}

internal func decodeAC(_ value: Int, maximumValue: Float) -> SIMD3<Float> {
	let quant: SIMD3<Float> = [
		Float(value / (19 * 19)),
		Float((value / 19) % 19),
		Float(value % 19)
	]
	
	return signSquared((quant - 9.0) / 9.0) * maximumValue
}

internal func signSquared(_ value: SIMD3<Float>) -> SIMD3<Float> {
	return sign(value) * value * value
}

fileprivate func sRGBToLinear<Type: BinaryInteger>(_ value: Type) -> Float {
	let v = Float(Int64(value)) / 255
	if v <= 0.04045 { return v / 12.92 }
	else { return pow((v + 0.055) / 1.055, 2.4) }
}

internal struct ParsingError: Error {}

/// Decode the first numCharacters of the substring using custom base 83 format.
///
/// The substring is advanced to no longer contain the decoded characters if successful.
internal func decode83(numCharacters: Int, from input: inout Substring.UTF8View) throws -> Int {
	guard input.count >= numCharacters else { throw ParsingError() }

	var value: Int = 0
	for _ in 0 ..< numCharacters {
		if let digit = try? input.popFirst()?.decode83() {
			value = value * 83 + digit
		}
	}

	return value
}

private extension UInt8 {
	func decode83() throws -> Int {
		let index = Int(self) - 35
		guard lookupTable.indices.contains(index)  else { throw ParsingError() }

		let value = lookupTable[index]
		guard value != -1 else { throw ParsingError() }

		return value
	}
}

/// Lookup table to find the Int representation for a character. The indices of the table are the
/// character ASCII values minus the ASCII value of the lowest character (35) so that the lowest
/// character is at index 0. The value in the table is that character's position within the encoding
/// character set:
/// 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~
private let lookupTable = [
	62, // #
	63, // $
	64, // %
	-1,
	-1,
	-1,
	-1,
	65, // *
	66, // +
	67, // ,
	68, // -
	69, // .
	-1,
	0, // 0
	1, // 1
	2, // 2
	3, // 3
	4, // 4
	5, // 5
	6, // 6
	7, // 7
	8, // 8
	9, // 9
	70, // :
	71, // ;
	-1,
	72, // =
	-1,
	73, // ?
	74, // @
	10, // A
	11, // B
	12, // C
	13, // D
	14, // E
	15, // F
	16, // G
	17, // H
	18, // I
	19, // J
	20, // K
	21, // L
	22, // M
	23, // N
	24, // O
	25, // P
	26, // Q
	27, // R
	28, // S
	29, // T
	30, // U
	31, // V
	32, // W
	33, // X
	34, // Y
	35, // Z
	75, // [
	-1,
	76, // ]
	77, // ^
	78, // _
	-1,
	36, // a
	37, // b
	38, // c
	39, // d
	40, // e
	41, // f
	42, // g
	43, // h
	44, // i
	45, // j
	46, // k
	47, // l
	48, // m
	49, // n
	50, // o
	51, // p
	52, // q
	53, // r
	54, // s
	55, // t
	56, // u
	57, // v
	58, // w
	59, // x
	60, // y
	61, // z
	79, // {
	80, // |
	81, // }
	82, // ~
]
