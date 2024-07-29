//
//  KMeans.swift
//  BlurHashViews
//
//  Created by Dale Price on 7/28/24.
//

import Foundation
import simd

func distance_squared<P: SIMD>(_ lhs: P, _ rhs: P) -> P.Scalar where P.Scalar: FloatingPoint {
	let diff = rhs - lhs
	let diffSquared = diff * diff
	return diffSquared.sum()
}

extension Collection where Element: SIMD, Element.Scalar: FloatingPoint, Self.Index: Hashable {
	var center: Element {
		self.reduce(.zero, +) / Element.Scalar(count)
	}
	
	typealias Cluster = (center: Element, points: [Element])
	
	func kMeansClusters(upTo maxClusterCount: Int, convergeDistance: Element.Scalar) -> [Cluster] {
		// Randomly select initial centers
		var centers = randomElements(count: maxClusterCount)
		guard !centers.isEmpty else { return [] }
		
		var clusters: [[Element]]
		
		var moveDistanceSquared = Element.Scalar.zero
		
		repeat {
			clusters = .init(repeating: [], count: centers.count)
			
			// sort points into clusters
			for point in self {
				let closestCenterIndex = centers.enumerated().min(by: { distance_squared($0.element, point) < distance_squared($1.element, point) })!.offset
				clusters[closestCenterIndex].append(point)
			}
			
			let newCenters = clusters.map(\.center)
			
			// calculate how far the centers have moved since the last iteration
			moveDistanceSquared = zip(centers, newCenters).reduce(Element.Scalar.zero) {
				$0 + distance_squared($1.0, $1.1)
			}
			
			centers = newCenters
		} while moveDistanceSquared > convergeDistance * convergeDistance
		
		return centers.enumerated().map { Cluster($0.element, clusters[$0.offset]) }
	}
}

extension Collection {
	func randomElements(count sampleCount: Int) -> [Self.Element] where Self.Index: Hashable {
		guard sampleCount < count else { return .init(self) }
		
		var remainingIndices = Set<Index>(self.indices)
		var result: [Self.Element] = []
		result.reserveCapacity(sampleCount)
		repeat {
			guard let index = remainingIndices.randomElement() else { return result }
			remainingIndices.remove(index)
			result.append(self[index])
		} while result.count < sampleCount
		return result
	}
}
