//
//  Color+averageFromBlurHash.swift
//
//
//  Created by Dale Price on 6/13/24.
//

import SwiftUI

public extension Color {
	/// Create a `Color` from the average color in a BlurHash.
	///
	/// Returns `nil` if the BlurHash string is invalid.
	init?(averageFromBlurHash blurHash: String) {
		var substring = blurHash.utf8.dropFirst(2)
		guard let value = try? decode83(numCharacters: 4, from: &substring) else { return nil }

		let rgb = decodeDC(value)
		self.init(.sRGBLinear, red: Double(rgb.x), green: Double(rgb.y), blue: Double(rgb.z))
	}
}
