//
//  File.swift
//  BlurHashViews
//
//  Created by Dale Price on 5/21/25.
//

import SwiftUI

@available(iOS 17, tvOS 17, visionOS 1, macOS 14, watchOS 10, macCatalyst 17, *)
extension Color.Resolved {
	
	/// Use k-Means++ algorithm to generate a palette of `Color.Resolved` from the predominant colors in a BlurHash.
	///
	/// This version of the method takes a `RandomNumberGenerator` instance that will be used to generate the palette. Unless you use a deterministic random number generator with a preset seed, the results will be different every time. For a version that uses GameplayKit's deterministic pseudorandom number generator to generate the same result every time it's called, use ``generatePalette(count:fromBlurHash:punch:randomSeed:)``.
	///
	/// - Parameters:
	///   - blurHash: The BlurHash string to extract colors from.
	///   - punch: Adjusts the contrast of the decoded colors. See the [BlurHash documentation](https://github.com/woltapp/blurhash#what-is-the-punch-parameter-in-some-of-these-implementations) for an explanation.
	///   - count: The number of colors desired in the palette.
	///   - generator: A `RandomNumberGenerator` instance to use for the algorithm.
	/// - Returns: An array of `Color.Resolved` representing the major colors in the blurhash.
	public static func generatePalette<R: RandomNumberGenerator>(count: Int = 4, fromBlurHash blurHash: String, punch: Float = 1, using generator: inout R) -> [Color.Resolved]? {
		guard let colors = try? decodeColors(fromBlurHash: blurHash, punch: punch) else {
			return nil
		}
		
		return BlurHashViews.getPalette(from: colors.map { SIMD4($0, 1.0) }, count: count, using: &generator)
			.map {
				Color.Resolved(colorSpace: .sRGBLinear, red: $0.red, green: $0.green, blue: $0.blue, opacity: $0.opacity)
			}
	}
	
	/// Use k-Means++ algorithm to generate a palette of `Color.Resolved` from the predominant colors in a BlurHash.
	///
	/// This version of the method uses GameplayKit's pseudorandom number generator to return deterministic results for the same parameters on a given architecture. For a version that lets you provide your own `RandomNumberGenerator` instance, use ``generatePalette(count:fromBlurHash:punch:using:)``.
	///
	/// - Parameters:
	///   - blurHash: The BlurHash string to extract colors from.
	///   - punch: Adjusts the contrast of the decoded colors. See the [BlurHash documentation](https://github.com/woltapp/blurhash#what-is-the-punch-parameter-in-some-of-these-implementations) for an explanation.
	///   - count: The number of colors desired in the palette.
	///   - randomSeed: The seed for the pseudorandom number generator. Changing this value may result in different colors being picked for the palette, but it will always return the same results for a given seed on a given architecture.
	/// - Returns: An array of `Color.Resolved` representing the major colors in the blurhash.
	public static func generatePalette(count: Int = 4, fromBlurHash blurHash: String, punch: Float = 1, randomSeed: UInt64 = .zero) -> [Color.Resolved]? {
		var generator = SeedableLinearCongruentialRandomNumberGenerator(seed: randomSeed)
		return generatePalette(count: count, fromBlurHash: blurHash, punch: punch, using: &generator)
	}
}

extension Color {
	/// Use k-Means++ algorithm to generate a color palette from the predominant colors in a BlurHash.
	///
	/// This version of the method takes a `RandomNumberGenerator` instance that will be used to generate the palette. Unless you use a deterministic random number generator with a preset seed, the results will be different every time. For a version that uses GameplayKit's deterministic pseudorandom number generator to generate the same result every time it's called, use ``generatePalette(count:fromBlurHash:punch:randomSeed:)``.
	///
	/// - Parameters:
	///   - blurHash: The BlurHash string to extract colors from.
	///   - punch: Adjusts the contrast of the decoded colors. See the [BlurHash documentation](https://github.com/woltapp/blurhash#what-is-the-punch-parameter-in-some-of-these-implementations) for an explanation.
	///   - count: The number of colors desired in the palette.
	///   - generator: A `RandomNumberGenerator` instance to use for the algorithm.
	/// - Returns: An array of `Color` representing the major colors in the blurhash.
	public static func generatePalette<R: RandomNumberGenerator>(count: Int = 4, fromBlurHash blurHash: String, punch: Float = 1, using generator: inout R) -> [Color]? {
		guard let colors = try? decodeColors(fromBlurHash: blurHash, punch: punch) else {
			return nil
		}
		
		return BlurHashViews.getPalette(from: colors.map { SIMD4($0, 1.0) }, count: count, using: &generator)
			.map {
				Color(.sRGBLinear, red: Double($0.red), green: Double($0.green), blue: Double($0.blue), opacity: Double($0.opacity))
			}
	}
	
	/// Use k-Means++ algorithm to generate a color palette from the colors in a BlurHash.
	///
	/// This version of the method uses GameplayKit's pseudorandom number generator to return deterministic results for the same parameters on a given architecture. For a version that lets you provide your own `RandomNumberGenerator` instance, use ``generatePalette(count:fromBlurHash:punch:using:)``.
	///
	/// - Parameters:
	///   - blurHash: The BlurHash string to extract colors from.
	///   - punch: Adjusts the contrast of the decoded colors. See the [BlurHash documentation](https://github.com/woltapp/blurhash#what-is-the-punch-parameter-in-some-of-these-implementations) for an explanation.
	///   - count: The number of colors desired in the palette.
	///   - randomSeed: The seed for the pseudorandom number generator. Changing this value may result in different colors being picked for the palette, but it will always return the same results for a given seed on a given architecture.
	/// - Returns: An array of `Color` representing the major colors in the blurhash.
	public static func generatePalette(count: Int = 4, fromBlurHash blurHash: String, punch: Float = 1, randomSeed: UInt64 = .zero) -> [Color]? {
		var generator = SeedableLinearCongruentialRandomNumberGenerator(seed: randomSeed)
		return generatePalette(count: count, fromBlurHash: blurHash, punch: punch, using: &generator)
	}
}
