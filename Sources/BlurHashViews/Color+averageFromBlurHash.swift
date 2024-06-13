//
//  Color+averageFromBlurHash.swift
//
//
//  Created by Dale Price on 6/13/24.
//

import SwiftUI

public extension Color {
	/// Create a `Color` from the average color in a BlurHash.
	init?(averageFromBlurHash blurHash: String) {
		guard blurHash.count >= 6 else { return nil }
		let value = String(blurHash[2 ..< 6]).decode83()
		let rgb = decodeDC(value)
		self.init(.sRGBLinear, red: Double(rgb.x), green: Double(rgb.y), blue: Double(rgb.z))
	}
}
