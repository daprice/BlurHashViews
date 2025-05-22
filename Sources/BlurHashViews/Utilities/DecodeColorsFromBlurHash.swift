//
//  ColorArrayFromBlurHash.swift
//  BlurHashViews
//
//  Created by Dale Price on 5/21/25.
//

import Foundation

/// Extract all color vertices defined in a BlurHash string as SIMD3.
/// - Parameters:
///   - blurHash: The BlurHash string to extract colors from.
///   - punch: Adjusts the contrast of the decoded colors. See the [BlurHash documentation](https://github.com/woltapp/blurhash#what-is-the-punch-parameter-in-some-of-these-implementations) for an explanation.
/// - Returns: An array of `SIMD3` representing each of the colors as SRGB Linear.
internal func decodeColors(fromBlurHash blurHash: String, punch: Float = 1) throws -> [SIMD3<Float>] {
	let (numX, numY, rawColors) = try parse(blurHash: blurHash, punch: punch)

	let numColors = numX * numY

	var colors: [SIMD3<Float>] = .init(repeating: .zero, count: numColors)

	for y in 0 ..< numY {
		for x in 0 ..< numX {
			let index = x + y * numX

			for j in 0 ..< numY {
				let yBasis = cos(Float.pi * Float(y) * Float(j) / Float(numY - 1))
				for i in 0 ..< numX {
					let basis = cos(Float.pi * Float(x) * Float(i) / Float(numX - 1)) * yBasis
					let color = rawColors[i + j * numX]
					colors[index] += color * basis
				}
			}
		}
	}

	return colors
}
