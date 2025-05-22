//
//  SeedableLinearCongruentialRandomNumberGenerator.swift
//  SwiftKMeansPlusPlus
//
//  Created by Dale Price on 5/16/25.
//

import Foundation
import GameplayKit

/// The numbers this generates aren't going to be very random, but they will be consistent for a given seed on a given architecture.
struct SeedableLinearCongruentialRandomNumberGenerator: RandomNumberGenerator {
	let source: GKLinearCongruentialRandomSource
	
	var seed: UInt64 {
		source.seed
	}
	
	init(seed: UInt64) {
		source = .init(seed: seed)
	}
	
	func next() -> UInt64 {
		var nextValue = UInt64()
		// GKLinearCongruentialRandomSource only gives us plain Int, so chain Ints together to make a UInt64
		for _ in 0..<(UInt64.bitWidth / UInt.bitWidth) {
			nextValue <<= UInt.bitWidth
			nextValue += UInt64(UInt(bitPattern: source.nextInt()))
		}
		return nextValue
	}
}
