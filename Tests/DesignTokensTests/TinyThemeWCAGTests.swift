import Testing
import SwiftUI
import UIKit
@testable import DesignTokens

/// Enforced WCAG 2.1 conformance for TinyTheme — AA, scoped:
///
/// - 4.5:1 for anything read as normal text (label, labelSecondary)
/// - 3:1 for iconography and UI component boundaries (onPrimary on fills,
///   filled/ringed circles, status glyphs, status glyphs on the capsule
///   tint the app composites them over)
/// - labelTertiary/labelQuaternary are exempt: subordinate by design, same
///   tradeoff Apple's own system grays make
///
/// Both modes are asserted for every pair; a failing shade fails the build
/// and must be re-picked to the nearest passing one.
@Suite("TinyTheme WCAG")
struct TinyThemeWCAGTests {

    private let theme = TinyTheme()

    /// The app's chip recipe: role color at 14% opacity composited over the
    /// row surface. The tint factor is the recipe constant, not the color's
    /// own alpha. Kept here so the gate tests what users actually see.
    private func capsule(_ color: Color, on surface: Color, dark: Bool) -> UIColor {
        let foreground = resolved(color, dark: dark)
        let base = resolved(surface, dark: dark)

        var fr: CGFloat = 0, fgc: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 1
        var br: CGFloat = 0, bgc: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 1
        foreground.getRed(&fr, green: &fgc, blue: &fb, alpha: &fa)
        base.getRed(&br, green: &bgc, blue: &bb, alpha: &ba)

        let tint: CGFloat = 0.14
        return UIColor(
            red: fr * tint + br * (1 - tint),
            green: fgc * tint + bgc * (1 - tint),
            blue: fb * tint + bb * (1 - tint),
            alpha: 1
        )
    }

    private func resolved(_ color: Color, dark: Bool) -> UIColor {
        let traits = UITraitCollection(userInterfaceStyle: dark ? .dark : .light)
        return UIColor(color).resolvedColor(with: traits)
    }

    private func assertPass(
        _ foreground: Color,
        on background: Color,
        level: ContrastCheck.Level = .normalAA,
        dark: Bool,
        _ pairName: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let actual = ContrastCheck.ratio(
            between: resolved(foreground, dark: dark),
            and: resolved(background, dark: dark)
        )
        let passes = actual >= level.rawValue
        #expect(
            passes,
            "\(pairName) \(dark ? "dark" : "light") fails \(level.rawValue):1 — measured \(String(format: "%.2f", actual)):1",
            sourceLocation: sourceLocation
        )
    }

    private func assertGlyphPass(
        _ glyph: Color,
        on background: Color,
        dark: Bool,
        _ pairName: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        assertPass(glyph, on: background, level: .largeAA, dark: dark, pairName, sourceLocation: sourceLocation)
    }

    private func forBothModes(
        _ body: (_ dark: Bool) -> Void,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        for dark in [false, true] {
            body(dark)
        }
    }

    // MARK: Text (4.5:1, normalAA)

    @Test("Label clears AA on every reading surface, both modes")
    func labelOnReadingSurfaces() {
        forBothModes { dark in
            assertPass(theme.label, on: theme.background, dark: dark, "label/background")
            assertPass(theme.label, on: theme.surface, dark: dark, "label/surface")
            assertPass(theme.label, on: theme.surfaceSecondary, dark: dark, "label/surfaceSecondary")
        }
    }

    @Test("Secondary label clears AA on every reading surface, both modes")
    func secondaryLabelOnReadingSurfaces() {
        forBothModes { dark in
            assertPass(theme.labelSecondary, on: theme.background, dark: dark, "labelSecondary/background")
            assertPass(theme.labelSecondary, on: theme.surface, dark: dark, "labelSecondary/surface")
            assertPass(theme.labelSecondary, on: theme.surfaceSecondary, dark: dark, "labelSecondary/surfaceSecondary")
        }
    }

    @Test("Secondary label clears AA on its own capsule composite, both modes")
    func neutralChipTextOnCapsule() {
        forBothModes { dark in
            let capsule = capsule(theme.labelSecondary, on: theme.surfaceSecondary, dark: dark)
            let ratio = ContrastCheck.ratio(between: resolved(theme.labelSecondary, dark: dark), and: capsule)
            #expect(ratio >= 4.5, "labelSecondary on its own capsule \(dark ? "dark" : "light") — measured \(String(format: "%.2f", ratio)):1")
        }
    }

    // MARK: Glyphs and component boundaries (3:1, largeAA)

    @Test("Checkmark color clears 3:1 on primary fill, both modes")
    func onPrimaryOnPrimary() {
        forBothModes { dark in
            assertGlyphPass(theme.onPrimary, on: theme.primary, dark: dark, "onPrimary/primary")
        }
    }

    @Test("Primary reads as a component boundary on card surfaces, both modes")
    func primaryRingOnSurfaces() {
        forBothModes { dark in
            assertGlyphPass(theme.primary, on: theme.surface, dark: dark, "primary/surface")
            assertGlyphPass(theme.primary, on: theme.surfaceSecondary, dark: dark, "primary/surfaceSecondary")
        }
    }

    @Test("Status glyphs clear 3:1 on card surfaces, both modes")
    func statusGlyphsOnSurfaces() {
        forBothModes { dark in
            assertGlyphPass(theme.success, on: theme.surfaceSecondary, dark: dark, "success/surfaceSecondary")
            assertGlyphPass(theme.warning, on: theme.surfaceSecondary, dark: dark, "warning/surfaceSecondary")
            assertGlyphPass(theme.destructive, on: theme.surfaceSecondary, dark: dark, "destructive/surfaceSecondary")
        }
    }

    @Test("Status glyphs clear 3:1 on their own capsule composite, both modes")
    func statusGlyphsOnCapsule() {
        forBothModes { dark in
            var composite = capsule(theme.primary, on: theme.surfaceSecondary, dark: dark)
            var icon = resolved(theme.primary, dark: dark)
            #expect(ContrastCheck.ratio(between: icon, and: composite) >= 3.0, "primary glyph on capsule \(dark ? "dark" : "light")")

            composite = capsule(theme.warning, on: theme.surfaceSecondary, dark: dark)
            icon = resolved(theme.warning, dark: dark)
            #expect(ContrastCheck.ratio(between: icon, and: composite) >= 3.0, "warning glyph on capsule \(dark ? "dark" : "light")")

            composite = capsule(theme.destructive, on: theme.surfaceSecondary, dark: dark)
            icon = resolved(theme.destructive, dark: dark)
            #expect(ContrastCheck.ratio(between: icon, and: composite) >= 3.0, "destructive glyph on capsule \(dark ? "dark" : "light")")

            composite = capsule(theme.success, on: theme.surfaceSecondary, dark: dark)
            icon = resolved(theme.success, dark: dark)
            #expect(ContrastCheck.ratio(between: icon, and: composite) >= 3.0, "success glyph on capsule \(dark ? "dark" : "light")")
        }
    }
}
