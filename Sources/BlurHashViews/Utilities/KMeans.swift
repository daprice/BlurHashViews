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

extension Collection where Element: SIMD, Element.Scalar: BinaryFloatingPoint, Element.Scalar.RawSignificand: FixedWidthInteger, Self.Index: Hashable {
	var center: Element {
		self.reduce(.zero, +) / Element.Scalar(count)
	}
	
	typealias Cluster = (center: Element, points: [Element])
	
	// K-Means++ initialization algorithm from https://en.wikipedia.org/wiki/K-means++#Improved_initialization_algorithm
	func initialClusterCenters(upTo maxClusterCount: Int) -> [Element] {
		// Start with one center chosen at random
		guard let initialCenterIndex = indices.randomElement() else { return [] }
		var centers = [self[initialCenterIndex]]
		var remainingIndices = Set<Index>(indices).subtracting([initialCenterIndex])
		
		// Until `maxClusterCount` centers are chosen, repeat choosing another center
		repeat {
			// Calculate distance squared between each point and the nearest center that has already been chosen
			let remainingPointIndicesWithDistancesSquared = remainingIndices.reduce(into: [Index: Element.Scalar]()) { result, pointIndex in
				let point = self[pointIndex]
				let distanceSquaredToNearestCenter = centers.map({ distance_squared(point, $0) }).min()
				result[pointIndex] = distanceSquaredToNearestCenter
			}
			
			// Choose a point at random to be the new center, using squared distance as weighted probability
			guard let weightedRandomPointIndex = remainingPointIndicesWithDistancesSquared.randomElement(weight: \.value) else { return centers }
			
			// Add the chosen point as a new center and remove it from the eligible points to be centers
			centers.append(self[weightedRandomPointIndex.key])
			remainingIndices.remove(weightedRandomPointIndex.key)
		} while centers.count < maxClusterCount
		
		return centers
	}
	
	func kMeansClusters(upTo maxClusterCount: Int, convergeDistanceSquared: Element.Scalar) -> [Cluster] {
		// Select initial centers according to K-means++
		var centers = initialClusterCenters(upTo: maxClusterCount)
		
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
		} while moveDistanceSquared > convergeDistanceSquared
		
		return centers.enumerated().map { Cluster($0.element, clusters[$0.offset]) }
	}
}

extension Int {
	// Inspired by https://stackoverflow.com/a/30309951/6833424
	/// Generate a random integer between 0 and `weights.count`, using the values in `weights` as relative probabilities.
	static func random<W: RandomAccessCollection>(weights: W) -> Int where W.Index == Int, W.Element: BinaryFloatingPoint, W.Element.RawSignificand: FixedWidthInteger {
		guard !weights.isEmpty else {
			return weights.startIndex
		}
		
		let sum = weights.reduce(0, +)
		let random = W.Element.random(in: 0 ..< sum)
		
		var accumulated: W.Element = 0.0
		for (index, weight) in weights.enumerated() {
			accumulated += weight
			if random < accumulated {
				return index
			}
		}
		
		return weights.endIndex - 1
	}
}

extension Collection {
	/// Returns a random element from the collection, weighted by the specified probability value.
	func randomElement<W: BinaryFloatingPoint>(weight: KeyPath<Self.Element, W>) -> Self.Element? where W.RawSignificand: FixedWidthInteger {
		guard !isEmpty else { return nil }
		
		let indices = Array(indices)
		let weights = indices.map { self[$0][keyPath: weight] }
		let random = Int.random(weights: weights)
		return self[indices[random]]
	}
}

extension Collection {
	/// Return up to a certain number of random elements from the collection, with the relative chance of sampling each one determined by the provided key path.
	func randomSample<W: BinaryFloatingPoint>(count sampleCount: Int, weight: KeyPath<Self.Element, W>) -> [Self.Element] where Self.Index: Hashable, W.RawSignificand: FixedWidthInteger {
		guard sampleCount < count else { return .init(self) }
		
		var remainingIndicesAndWeights: [Index: W] = indices.reduce(into: [:], { result, next in
			result[next] = self[next][keyPath: weight]
		})
		
		var result: [Self.Element] = []
		result.reserveCapacity(sampleCount)
		
		repeat {
			guard let (index, _) = remainingIndicesAndWeights.map({ ($0.key, $0.value) }).randomElement(weight: \.1) else { return result }
			remainingIndicesAndWeights.removeValue(forKey: index)
			result.append(self[index])
		} while result.count < sampleCount
		return result
	}
}
