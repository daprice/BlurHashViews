# ``BlurHashViews``

Decode BlurHash strings to SwiftUI `Color`, `MeshGradient`, or an array of colors with various customization options.

## Overview

BlurHash ([blurha.sh](https://blurha.sh)) is a way of representing placeholders for images using a compact string representation. [Existing implementations](https://github.com/woltapp/blurhash) focus on decoding a BlurHash to a small image that can be used as a placeholder. This package allows you to create native SwiftUI views directly from BlurHash encoded strings.

Open `Sources/BlurHashViews/Previews.swift` in Xcode 16 for an interactive SwiftUI preview with example views of BlurHashes from social media sites, allowing you to try different customization options for how they are displayed, including:

- Change the `punch` argument to control the contrast between colors in the BlurHash.
- Generate color palettes consisting of any number of representative colors.
- Decode the BlurHash at different detail levels for more or less complex mesh gradients.
- Adjust the smoothing and color space options provided by SwiftUI MeshGradient.

There's also a decoder that returns the mesh points and colors so you can customize it in code however you want – animate the points to make it swirl, find the most intense color in the image, make custom transitions… whatever you can dream up!

### Compatibility

- iOS/tvOS 13+, macOS 10.15+, watchOS 6+ – Create a SwiftUI `Color` from the average of a BlurHash or generate a palette of representative `Color`s.
- iOS/tvOS 17.0+, macOS 14.0+, watchOS 10.0+ – Generate a palette of representative `Color.Resolved` from a BlurHash.
- iOS/tvOS 18+, macOS 15+, watchOS 11+ – Create a `MeshGradient` from the colors in a BlurHash.

For previous operating systems, the [original BlurHash library](https://github.com/woltapp/blurhash/tree/master/Swift) provides a UIImage-based decoding implementation.
