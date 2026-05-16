#!/usr/bin/env swift
//
// generate_icon.swift
// Generates the Repeto app icon using AppKit.
//
// Usage (from project root):
//   swift scripts/generate_icon.swift
//
// Output: Repeto/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
//
// Design tokens (from TOKENS.md):
//   accent color : #007AFF
//   background   : white
//   corner radius: none (Apple clips the icon automatically)

import AppKit
import Foundation

// MARK: - Token constants

let accentColor = NSColor(red: 0.0 / 255, green: 122.0 / 255, blue: 255.0 / 255, alpha: 1.0)
let backgroundColor = NSColor.white
let canvasSize = 1024

// MARK: - Bitmap context

guard let bitmapRep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: canvasSize,
    pixelsHigh: canvasSize,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Error: failed to create NSBitmapImageRep\n", stderr)
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)

let ctx = NSGraphicsContext.current!
ctx.imageInterpolation = .high

let bounds = NSRect(x: 0, y: 0, width: canvasSize, height: canvasSize)

// MARK: - Background

backgroundColor.setFill()
bounds.fill()

// MARK: - Circular accent background

let circleInset: CGFloat = 80
let circleRect = bounds.insetBy(dx: circleInset, dy: circleInset)
let circlePath = NSBezierPath(ovalIn: circleRect)
accentColor.setFill()
circlePath.fill()

// MARK: - "R" letter

let fontSize: CGFloat = 520
let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white
]
let letter = "R" as NSString
let letterSize = letter.size(withAttributes: attributes)
let letterOrigin = NSPoint(
    x: (CGFloat(canvasSize) - letterSize.width) / 2 + 12,
    y: (CGFloat(canvasSize) - letterSize.height) / 2
)
letter.draw(at: letterOrigin, withAttributes: attributes)

NSGraphicsContext.restoreGraphicsState()

// MARK: - Write PNG

guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
    fputs("Error: failed to encode PNG\n", stderr)
    exit(1)
}

let outputURL = URL(fileURLWithPath: "Repeto/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")

do {
    try pngData.write(to: outputURL)
    print("Wrote \(outputURL.path) (\(canvasSize)×\(canvasSize)px)")
} catch {
    fputs("Error writing file: \(error)\n", stderr)
    exit(1)
}
