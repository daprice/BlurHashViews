//
//  File.swift
//  
//
//  Created by Dale Price on 6/13/24.
//

import SwiftUI

@available(iOS 18, tvOS 18, visionOS 2, macOS 15, watchOS 11, macCatalyst 13, *)
public extension MeshGradient {
	enum BlurHashGradientDetailLevel: Hashable, Codable, Sendable, Equatable {
		case standard
		case simple
	}
	
	init?(fromBlurHash blurHash: String, punch: Float = 1, detail: BlurHashGradientDetailLevel = .standard, smoothsColors: Bool = true, colorSpace: Gradient.ColorSpace = .perceptual) {
		typealias Point = SIMD2<Float>
		
		guard blurHash.count >= 6 else { return nil }
		
		let sizeFlag = String(blurHash[0]).decode83()
		let numY = (sizeFlag / 9) + 1
		let numX = (sizeFlag % 9) + 1
		
		let yPoints = detail == .simple ? 2 : numY
		let xPoints = detail == .simple ? 2 : numX
		
		let quantisedMaximumValue = String(blurHash[1]).decode83()
		let maximumValue = Float(quantisedMaximumValue + 1) / 166
		
		guard blurHash.count == 4 + 2 * numX * numY else { return nil }
		
		let rawColors: [SIMD3<Float>] = (0 ..< numX * numY).map { i in
			if i == 0 {
				let value = String(blurHash[2 ..< 6]).decode83()
				return decodeDC(value)
			} else {
				let value = String(blurHash[4 + i * 2 ..< 4 + i * 2 + 2]).decode83()
				return decodeAC(value, maximumValue: maximumValue * punch)
			}
		}
		
		let colors: [Color] = (0 ..< yPoints).flatMap { y in
			(0 ..< xPoints).map { x in
				var rgb = SIMD3<Float>(0.0, 0.0, 0.0)
				
				for j in 0 ..< numY {
					let yBasis = cos(Float.pi * Float(y) * Float(j) / Float(yPoints - 1))
					for i in 0 ..< numX {
						let basis = cos(Float.pi * Float(x) * Float(i) / Float(xPoints - 1)) * yBasis
						let color = rawColors[i + j * numX]
						rgb += color * basis
					}
				}
				
				return Color(.sRGBLinear, red: Double(rgb.x), green: Double(rgb.y), blue: Double(rgb.z))
			}
		}
		
		let points: [Point] = (0 ..< yPoints).flatMap { y in
			(0 ..< xPoints).map { x in
				SIMD2(x: Float(x) / Float(xPoints - 1), y: Float(y) / Float(yPoints - 1))
			}
		}
		
		self.init(
			width: xPoints,
			height: yPoints,
			points: points,
			colors: colors,
			smoothsColors: smoothsColors,
			colorSpace: colorSpace
		)
	}
}
