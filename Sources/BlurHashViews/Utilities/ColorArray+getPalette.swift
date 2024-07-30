//
//  File.swift
//  BlurHashViews
//
//  Created by Dale Price on 7/28/24.
//

import SwiftUI

// TODO: WIP - optionally include x and y positions within mesh as input to the k-means algorithm

@available(iOS 17.0, *)
@available(iOS 17, tvOS 17, visionOS 1, macOS 14, watchOS 10, macCatalyst 13, *)
extension [Color.Resolved] {
	func getPalette(count resultCount: Int = 4) -> [Color.Resolved] {
		guard let minRed = self.min(by: { $0.red < $1.red })?.red,
			  let maxRed = self.max(by: { $0.red < $1.red })?.red,
			  let minGreen = self.min(by: { $0.green < $1.green })?.green,
			  let maxGreen = self.max(by: { $0.green < $1.green })?.green,
			  let minBlue = self.min(by: { $0.blue < $1.blue })?.blue,
			  let maxBlue = self.max(by: { $0.blue < $1.blue })?.blue,
			  let minAlpha = self.min(by: { $0.opacity < $1.opacity })?.opacity,
			  let maxAlpha = self.max(by: { $0.opacity < $1.opacity })?.opacity else {
			return []
		}
		
		let totalDistanceSquared = pow(maxRed - minRed, 2) + pow(maxGreen - minGreen, 2) + pow(maxBlue - minBlue, 2) + pow(maxAlpha - minAlpha, 2)
		guard totalDistanceSquared > 0 else {
			// All colors are equal, return the array as-is, limited by count
			return .init(self.prefix(resultCount))
		}
		
		let colorVectors = map { color in
			return SIMD4(color.linearRed, color.linearGreen, color.linearBlue, color.opacity)
		}
		let clusters = colorVectors.kMeansClusters(upTo: resultCount, convergeDistanceSquared: totalDistanceSquared / 100)
		
		return clusters.sorted(by: { $0.points.count > $1.points.count }).map { cluster in
			let closestColorToCenter = cluster.points.min(by: { distance_squared($0, cluster.center) < distance_squared($1, cluster.center) }) ?? cluster.center
//			let closestColorToCenter = cluster.center
			return Color.Resolved(colorSpace: .sRGBLinear, red: closestColorToCenter[0], green: closestColorToCenter[1], blue: closestColorToCenter[2], opacity: closestColorToCenter[3])
		}
	}
}
