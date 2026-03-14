import SwiftUI
import UIKit

// MARK: - WCAG Contrast Utilities

/// Helpers for verifying WCAG 2.1 contrast ratios at runtime.
///
/// Useful during development and testing. In production, relying
/// on Apple's semantic colors guarantees AA compliance in both
/// light and dark mode automatically.
public enum ContrastCheck {

    /// WCAG 2.1 minimum contrast ratios.
    public enum Level: Double, Sendable {
        /// Normal text ≥ 14pt bold or ≥ 18pt regular.
        case largeAA = 3.0
        /// Normal text (body, caption, etc.).
        case normalAA = 4.5
        /// Enhanced contrast for normal text.
        case normalAAA = 7.0
    }

    /// Calculate the WCAG contrast ratio between two `UIColor` values.
    ///
    /// Returns a value between 1 (identical) and 21 (black on white).
    public static func ratio(between foreground: UIColor, and background: UIColor) -> Double {
        let fgLum = relativeLuminance(of: foreground)
        let bgLum = relativeLuminance(of: background)
        let lighter = max(fgLum, bgLum)
        let darker = min(fgLum, bgLum)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Check whether a foreground/background pair meets a given WCAG level.
    public static func passes(
        foreground: UIColor,
        background: UIColor,
        level: Level = .normalAA
    ) -> Bool {
        ratio(between: foreground, and: background) >= level.rawValue
    }

    // MARK: Internal

    private static func relativeLuminance(of color: UIColor) -> Double {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        func linearize(_ channel: CGFloat) -> Double {
            let c = Double(channel)
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }
}

// MARK: - Debug Overlay (Development Only)

/// A view modifier that overlays the contrast ratio during development.
///
/// ```swift
/// Text("Hello")
///     .contrastDebug(foreground: .label, background: .systemBackground)
/// ```
public struct ContrastDebugModifier: ViewModifier {
    let foreground: UIColor
    let background: UIColor

    public func body(content: Content) -> some View {
        content.overlay(alignment: .topTrailing) {
            #if DEBUG
            let ratio = ContrastCheck.ratio(between: foreground, and: background)
            let passes = ratio >= ContrastCheck.Level.normalAA.rawValue
            Text(String(format: "%.1f:1", ratio))
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(passes ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(4)
            #endif
        }
    }
}

public extension View {
    func contrastDebug(foreground: UIColor, background: UIColor) -> some View {
        modifier(ContrastDebugModifier(foreground: foreground, background: background))
    }
}
