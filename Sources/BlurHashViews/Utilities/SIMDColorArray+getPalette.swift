//
//  File.swift
//  BlurHashViews
//
//  Created by Dale Price on 7/28/24.
//

import SwiftUI
import SwiftKMeansPlusPlus
import simd

internal extension SIMD4<Float> {
	var red: Float { self[0] }
	var green: Float { self[1] }
	var blue: Float { self[2] }
	var opacity: Float { self[3] }
}

/// Use k-Means++ algorithm to generate a color palette from the given set of colors.
/// - Parameters:
///   - colors: Array of `SIMD4` representing RGBA colors in SRGB linear color space.
///   - resultCount: Number of colors in the resulting palette.
///   - generator: `RandomNumberGenerator` to use for the k-Means++ algorithm.
/// - Returns: Array of `SIMD4` with length `resultCount` representing RGBA colors in SRGB linear color space.
internal func getPalette<R: RandomNumberGenerator>(
	from colors: [SIMD4<Float>],
	count resultCount: Int = 4,
	using generator: inout R
) -> [SIMD4<Float>] {
	guard let minRed = colors.min(by: { $0.red < $1.red })?.red,
		  let maxRed = colors.max(by: { $0.red < $1.red })?.red,
		  let minGreen = colors.min(by: { $0.green < $1.green })?.green,
		  let maxGreen = colors.max(by: { $0.green < $1.green })?.green,
		  let minBlue = colors.min(by: { $0.blue < $1.blue })?.blue,
		  let maxBlue = colors.max(by: { $0.blue < $1.blue })?.blue,
		  let minAlpha = colors.min(by: { $0.opacity < $1.opacity })?.opacity,
		  let maxAlpha = colors.max(by: { $0.opacity < $1.opacity })?.opacity else {
		return []
	}
	
	let totalDistanceSquared = pow(maxRed - minRed, 2) + pow(maxGreen - minGreen, 2) + pow(maxBlue - minBlue, 2) + pow(maxAlpha - minAlpha, 2)
	let totalDistance = sqrt(totalDistanceSquared)
	guard totalDistance > 0 else {
		// All colors are equal, return the array as-is, limited by count
		return Array(colors.prefix(resultCount))
	}
	
	let clusters = colors.kMeansClusters(upTo: resultCount, convergeDistance: totalDistance / 100, using: &generator)
	
	return clusters
		.sorted(by: { $0.points.count == $1.points.count ? $0.center.sum() > $1.center.sum() : $0.points.count > $1.points.count })
		.map { cluster in
			let closestColorToCenter = cluster.points.min(by: { distanceSquared($0, cluster.center) < distanceSquared($1, cluster.center) }) ?? cluster.center
			return closestColorToCenter
		}
}

/// Calculate the squared euclidean distance between any two SIMD "points".
fileprivate func distanceSquared<P: SIMD>(_ lhs: P, _ rhs: P) -> P.Scalar where P.Scalar: FloatingPoint {
	let diff = rhs - lhs
	let diffSquared = diff * diff
	return diffSquared.sum()
}
