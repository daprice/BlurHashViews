//
//  File.swift
//  BlurHashViews
//
//  Created by Dale Price on 7/28/24.
//

import SwiftUI

@available(iOS 18, tvOS 18, visionOS 2, macOS 15, watchOS 11, macCatalyst 13, *)
extension MeshGradient.Mesh {
	enum MeshColorPaletteError: Error {
		case unknownMeshGradientColorCase
	}
	
	func getPalette(count: Int = 4, resolvingColorsIn environmentValues: EnvironmentValues) throws -> [Color.Resolved] {
		let resolvedColors = switch colors {
		case .resolvedColors(let resolvedColors):
			resolvedColors
		case .colors(let colors):
			colors.map { $0.resolve(in: environmentValues) }
		@unknown default:
			throw MeshColorPaletteError.unknownMeshGradientColorCase
		}
		
		return resolvedColors.getPalette(count: count)
	}
}
