//
//  MeshGradient+fromBlurHash.swift
//
//
//  Created by Dale Price on 6/13/24.
//

import SwiftUI

@available(iOS 18, tvOS 18, visionOS 2, macOS 15, watchOS 11, macCatalyst 13, *)
extension MeshGradient {
	
	/// Stores the colors and points for creating a `MeshGradient`.
	public struct Mesh: Equatable, Sendable {
		public enum DetailLevel: Hashable, Codable, Sendable, Equatable {
			/// Match the number of components originally encoded in the BlurHash.
			case unchanged
			/// Define a number of vertices to calculate along the X and Y dimensions.
			///
			/// Higher numbers of vertices take longer to decode.
			case vertices(width: Int, height: Int)
			/// Produces a simple mesh gradient with one color at each corner.
			static let simple: DetailLevel = .vertices(width: 2, height: 2)
		}
		
		/// The number of vertices along the X axis.
		public var width: Int
		/// The number of vertices points along the Y axis.
		public var height: Int
		/// The colors of the mesh.
		public var colors: MeshGradient.Colors
		/// An array of 2D locations and their control points.
		public var points: MeshGradient.Locations
		
		public init(width: Int, height: Int, colors: MeshGradient.Colors, points: MeshGradient.Locations) {
			self.width = width
			self.height = height
			self.colors = colors
			self.points = points
		}
		
		/// Create a Mesh by decoding a BlurHash string.
		///
		/// You only need to call this yourself if you want to cache the results of BlurHash decoding (this method is somewhat costly) or you want to customize the colors or points. Otherwise, you can call ``SwiftUICore/MeshGradient/init(_:background:smoothsColors:colorSpace:)`` directly.
		///
		/// Returns `nil` if the BlurHash string is invalid.
		///
		/// - Parameters:
		///   - blurHash: The BlurHash string to create a Mesh from.
		///   - punch: Adjusts the contrast if the decoded colors. See the [BlurHash documentation](https://github.com/woltapp/blurhash#what-is-the-punch-parameter-in-some-of-these-implementations) for an explanation.
		///   - detail: The level of detail to decode from the BlurHash.
		public init?(fromBlurHash blurHash: String, punch: Float = 1, detail: DetailLevel = .unchanged) {
			typealias Point = SIMD2<Float>
			
			guard blurHash.count >= 6 else { return nil }
			
			let sizeFlag = String(blurHash[0]).decode83()
			let numY = (sizeFlag / 9) + 1
			let numX = (sizeFlag % 9) + 1
			
			let yPoints: Int
			let xPoints: Int
			switch detail {
			case .unchanged:
				yPoints = numY
				xPoints = numX
			case .vertices(let width, let height):
				yPoints = height
				xPoints = width
			}
			
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
				colors: .colors(colors),
				points: .points(points)
			)
		}
	}
	
	/// Create a MeshGradient from a ``Mesh``.
	///
	/// Equivalent to `init(width:height:locations:colors:background:smoothsColors:colorSpace:)` but useful if you are caching ``SwiftUICore/MeshGradient/Mesh`` instances created from BlurHash strings using ``SwiftUICore/MeshGradient/Mesh/init(fromBlurHash:punch:detail:)``.
	public init(_ mesh: Mesh, background: Color = .clear, smoothsColors: Bool = true, colorSpace: Gradient.ColorSpace = .perceptual) {
		self.init(
			width: mesh.width,
			height: mesh.height,
			locations: mesh.points,
			colors: mesh.colors,
			smoothsColors: smoothsColors,
			colorSpace: colorSpace
		)
	}
	
	/// Create a MeshGradient from a BlurHash string.
	///
	/// Returns `nil` if the BlurHash is invalid.
	///
	/// If performance is an issue, you can decode the BlurHash to a ``SwiftUICore/MeshGradient/Mesh`` using ``SwiftUICore/MeshGradient/Mesh/init(fromBlurHash:punch:detail:)`` and cache the resulting mesh. Then call ``SwiftUICore/MeshGradient/init(_:background:smoothsColors:colorSpace:)`` to create the mesh gradient.
	///
	/// - Parameters:
	///   - blurHash: The BlurHash string to create a Mesh from.
	///   - punch: Adjusts the contrast if the decoded colors. See the [BlurHash documentation](https://github.com/woltapp/blurhash#what-is-the-punch-parameter-in-some-of-these-implementations) for an explanation.
	///   - detail: The level of detail to decode from the BlurHash.
	///   - smoothsColors: Whether cubic interpolation should be used for the colors in the mesh.
	///   - colorSpace: The color space in which to interpolate vertex colors.
	public init?(fromBlurHash blurHash: String, punch: Float = 1, detail: Mesh.DetailLevel = .unchanged, smoothsColors: Bool = true, colorSpace: Gradient.ColorSpace = .perceptual) {
		guard let mesh = Mesh(fromBlurHash: blurHash, punch: punch, detail: detail) else {
			return nil
		}
		
		self.init(mesh, smoothsColors: smoothsColors, colorSpace: colorSpace)
	}
}
