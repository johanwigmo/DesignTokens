import SwiftUI
import UIKit
@testable import DesignTokens

// MARK: - Theme Doc Generator
//
// Generates the palette table + SVG preview card for each shipped theme from
// its live values. Lives in the test target so docs can be gated: if a palette
// change makes compiled themes and committed docs diverge,
// `ThemeDocsGateTests` fails until the committed files are regenerated.

// MARK: Token model

/// One documented color token of a theme, with provenance.
struct TokenSpec {
    enum Role {
        /// Read as text — checked against `background` at 4.5:1.
        case text
        /// Read as a component boundary / glyph — checked at 3:1.
        case component
        /// A surface or deliberately-subordinate color — not contrast-checked.
        case decorative
    }

    let key: String
    let color: Color
    /// The system color the theme inherits, or nil if the theme owns the value.
    let mapsTo: String?
    let role: Role
    /// Token the contrast column measures against — `background` for
    /// everything except `onPrimary`, which lives on a fill.
    let contrastAgainst: String

    init(
        key: String,
        color: Color,
        mapsTo: String? = nil,
        role: Role,
        contrastAgainst: String = "background"
    ) {
        self.key = key
        self.color = color
        self.mapsTo = mapsTo
        self.role = role
        self.contrastAgainst = contrastAgainst
    }

    var contrastTarget: Double? {
        switch role {
        case .text: 4.5
        case .component: 3.0
        case .decorative: nil
        }
    }
}

/// A titled grouping of tokens in the preview card.
struct TokenGroup {
    let title: String
    let tokens: [TokenSpec]
}

// MARK: Spec definitions

enum ThemeDoc {

    case tiny(TinyTheme)
    case `default`(DefaultTheme)

    var metadata: Metadata {
        switch self {
        case .tiny(let theme):
            return Metadata(
                name: theme.name,
                fileStem: "TinyTheme",
                fontFamilies: "ui-rounded, -apple-system, 'Helvetica Neue', sans-serif",
                tagline: "Warm paper surfaces · Gruvbox accents · rounded ramp"
            )
        case .default(let theme):
            return Metadata(
                name: theme.name,
                fileStem: "DefaultTheme",
                fontFamilies: "-apple-system, 'Helvetica Neue', sans-serif",
                tagline: "Stock iOS · system colors · standard metrics"
            )
        }
    }

    struct Metadata {
        let name: String
        let fileStem: String
        let fontFamilies: String
        let tagline: String
    }

    /// The full palette documented in the markdown table.
    var palette: [TokenSpec] {
        let theme: Theme

        switch self {
        case .tiny(let t): theme = t
        case .default(let t): theme = t
        }

        func spec(
            _ key: String,
            _ color: Color,
            _ mapsTo: String? = nil,
            _ role: TokenSpec.Role,
            contrastAgainst against: String = "background"
        ) -> TokenSpec {
            TokenSpec(key: key, color: color, mapsTo: mapsTo, role: role, contrastAgainst: against)
        }

        switch self {
        case .tiny(let t):
            return [
                spec("primary", t.primary, nil, .component),
                spec("secondary", t.secondary, nil, .component),
                spec("accent", t.accent, nil, .component),
                spec("background", t.background, nil, .decorative),
                spec("backgroundSecondary", t.backgroundSecondary, ".secondarySystemBackground", .decorative),
                spec("backgroundTertiary", t.backgroundTertiary, ".tertiarySystemBackground", .decorative),
                spec("surface", t.surface, nil, .decorative),
                spec("surfaceSecondary", t.surfaceSecondary, nil, .decorative),
                spec("label", t.label, nil, .text),
                spec("labelSecondary", t.labelSecondary, nil, .text),
                spec("labelTertiary", t.labelTertiary, ".tertiaryLabel", .decorative),
                spec("labelQuaternary", t.labelQuaternary, ".quaternaryLabel", .decorative),
                spec("separator", t.separator, ".separator", .decorative),
                spec("onPrimary", t.onPrimary, nil, .component, contrastAgainst: "primary"),
                spec("success", t.success, nil, .component),
                spec("warning", t.warning, nil, .component),
                spec("destructive", t.destructive, nil, .component),
                spec("info", t.info, nil, .component),
            ]

        case .default(let t):
            return [
                spec("primary", t.primary, ".accentColor*", .component),
                spec("secondary", t.secondary, ".secondaryLabel", .component),
                spec("accent", t.accent, ".accentColor*", .component),
                spec("background", theme.background, ".systemBackground", .decorative),
                spec("backgroundSecondary", theme.backgroundSecondary, ".secondarySystemBackground", .decorative),
                spec("backgroundTertiary", theme.backgroundTertiary, ".tertiarySystemBackground", .decorative),
                spec("surface", theme.surface, ".systemGroupedBackground", .decorative),
                spec("surfaceSecondary", theme.surfaceSecondary, ".secondarySystemGroupedBackground", .decorative),
                spec("label", theme.label, ".label", .text),
                spec("labelSecondary", theme.labelSecondary, ".secondaryLabel", .text),
                spec("labelTertiary", theme.labelTertiary, ".tertiaryLabel", .decorative),
                spec("labelQuaternary", theme.labelQuaternary, ".quaternaryLabel", .decorative),
                spec("separator", theme.separator, ".separator", .decorative),
                spec("onPrimary", theme.onPrimary, ".white", .component, contrastAgainst: "primary"),
                spec("success", theme.success, ".green", .component),
                spec("warning", theme.warning, ".orange", .component),
                spec("destructive", theme.destructive, ".red", .component),
                spec("info", theme.info, ".blue", .component),
            ]
        }
    }

    /// Groupings shown in the SVG preview card.
    var groups: [TokenGroup] {
        let byKey = Dictionary(uniqueKeysWithValues: palette.map { ($0.key, $0) })

        func group(_ title: String, _ keys: [String]) -> TokenGroup {
            TokenGroup(title: title, tokens: keys.compactMap { byKey[$0] })
        }

        return [
            group("Brand", ["primary", "secondary", "accent", "onPrimary"]),
            group("Surfaces", ["background", "surface", "surfaceSecondary", "separator"]),
            group("Text", ["label", "labelSecondary", "labelTertiary", "labelQuaternary"]),
            group("Status", ["success", "warning", "destructive", "info"]),
        ]
    }

    /// Footnote appended to generated tables, or nil.
    var tableFootnote: String? {
        switch self {
        case .tiny: nil
        case .default:
            "* Brand colors follow the user's chosen accent color in Settings; `#007AFF` is the iOS default."
        }
    }

    // MARK: Color resolution

    /// Resolves a (possibly adaptive) color to a concrete sRGB UIColor per mode.
    /// Same approach as the WCAG suite — relies on the dynamic provider
    /// surviving the Color→UIColor conversion.
    static func resolved(_ color: Color, dark: Bool) -> UIColor {
        let traits = UITraitCollection(userInterfaceStyle: dark ? .dark : .light)
        return UIColor(color).resolvedColor(with: traits)
    }

    static func resolvedHex(_ color: Color, dark: Bool, alpha: CGFloat = 1) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved(color, dark: dark).getRed(&r, green: &g, blue: &b, alpha: &a)
        // Weak system colors (tertiaryLabel, separator…) resolve as black or
        // white at partial alpha — an RGB-only hex would misstate them.
        let alphaChannel = min(a, alpha)
        if alphaChannel < 0.999 {
            return String(
                format: "#%02X%02X%02X%02X",
                Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)), Int(round(alphaChannel * 255))
            )
        }
        return String(format: "#%02X%02X%02X", Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
    }

    // MARK: Markdown palette table

    func paletteTable() -> String {
        let byKey = Dictionary(uniqueKeysWithValues: palette.map { ($0.key, $0) })

        var lines = [
            "| Token | Light | Dark | Maps to | AA vs background |",
            "|-------|-------|------|---------|------------------|",
        ]

        for token in palette {
            let lightHex = Self.resolvedHex(token.color, dark: false)
            let darkHex = Self.resolvedHex(token.color, dark: true)
            let mapsTo = token.mapsTo ?? "—"

            let aa: String
            if let target = token.contrastTarget, let pair = byKey[token.contrastAgainst] {
                let light = ContrastCheck.ratio(
                    between: Self.resolved(token.color, dark: false),
                    and: Self.resolved(pair.color, dark: false)
                )
                let dark = ContrastCheck.ratio(
                    between: Self.resolved(token.color, dark: true),
                    and: Self.resolved(pair.color, dark: true)
                )
                let passes = light >= target && dark >= target
                let pairNote = token.contrastAgainst == "background" ? "" : " (on \(token.contrastAgainst))"
                aa = "≥\(fmt(CGFloat(target))) — min \(String(format: "%.2f", min(light, dark))):1 \(passes ? "✓" : "✗")\(pairNote)"
            } else {
                aa = "—"
            }

            lines.append(
                "| `\(token.key)` | `\(lightHex)` | `\(darkHex)` | `\(mapsTo)` | \(aa) |"
            )
        }

        if let footnote = tableFootnote {
            lines.append("")
            lines.append(footnote)
        }

        return lines.joined(separator: "\n")
    }

    // MARK: SVG preview card

    func previewSVG() -> String {
        let pad: CGFloat = 18
        let panelWidth: CGFloat = 400
        let gap: CGFloat = 20
        let cellWidth = (panelWidth - pad * 2) / 4
        let swatchWidth: CGFloat = 74
        let swatchHeight: CGFloat = 46
        let swatchRadius: CGFloat = 9
        let firstContentY: CGFloat = pad + 40  // start y of first group title
        let nameBaseline: CGFloat = 14         // swatch bottom → token name baseline
        let hexBaseline: CGFloat = 26          // swatch bottom → hex baseline
        let rowTrailing: CGFloat = 38          // swatch bottom → next group title y
        let bottomPad: CGFloat = 26

        // Panel height mirrors the walk below: header zone + one block per
        // group (title line, swatch, labels, trailing gap), minus the
        // trailing gap of the last group.
        let perGroup: CGFloat = 16 + swatchHeight + rowTrailing
        let panelHeight = firstContentY + perGroup * CGFloat(groups.count) - rowTrailing + bottomPad

        let width = panelWidth * 2 + gap
        let height = panelHeight

        var s: [String] = []
        s.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
        s.append("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\(Int(width))\" height=\"\(Int(height))\" viewBox=\"0 0 \(Int(width)) \(Int(height))\">")

        for (index, dark) in [false, true].enumerated() {
            let panelX = (panelWidth + gap) * CGFloat(index)
            let bg = Self.resolvedHex(palette.first { $0.key == "background" }!.color, dark: dark)

            s.append("<g>")
            // Panel
            s.append("<rect x=\"\(fmt(panelX))\" y=\"0\" width=\"\(fmt(panelWidth))\" height=\"\(fmt(panelHeight))\" rx=\"14\" fill=\"\(bg)\"/>")

            let ink = palette.first { $0.key == "label" }!.color
            let inkHex = Self.resolvedHex(ink, dark: dark)
            let subInk = palette.first { $0.key == "labelSecondary" }!.color

            // Header
            s.append(
                "<text x=\"\(fmt(panelX + pad))\" y=\"30\" font-family=\"\(metadata.fontFamilies)\" font-size=\"15\" font-weight=\"600\" fill=\"\(inkHex)\">\(escape(metadata.name)) · \(dark ? "Dark" : "Light")</text>"
            )
            s.append(
                "<text x=\"\(fmt(panelX + pad))\" y=\"48\" font-family=\"\(metadata.fontFamilies)\" font-size=\"9.5\" fill=\"\(Self.resolvedHex(subInk, dark: dark))\">\(escape(metadata.tagline))</text>"
            )

            // Type sample, top right in the theme's ramp
            s.append(
                "<text x=\"\(fmt(panelX + panelWidth - pad))\" y=\"44\" font-family=\"\(metadata.fontFamilies)\" font-size=\"26\" font-weight=\"500\" text-anchor=\"end\" fill=\"\(inkHex)\">Aa</text>"
            )

            var y: CGFloat = firstContentY
            for group in groups {
                // Group title
                s.append(
                    "<text x=\"\(fmt(panelX + pad))\" y=\"\(fmt(y + 10))\" font-family=\"\(metadata.fontFamilies)\" font-size=\"9\" letter-spacing=\"1.2\" fill=\"\(Self.resolvedHex(subInk, dark: dark))\">\(escape(group.title.uppercased()))</text>"
                )
                y += 16

                let swatchY = y

                for (cellIndex, token) in group.tokens.enumerated() {
                    let cellX = panelX + pad + cellWidth * CGFloat(cellIndex) + (cellWidth - swatchWidth) / 2
                    let fillHex = Self.resolvedHex(token.color, dark: dark)
                    let isOnPrimaryChip = token.key == "onPrimary"
                    let chipFill = isOnPrimaryChip
                        ? Self.resolvedHex(palette.first { $0.key == "primary" }!.color, dark: dark)
                        : fillHex

                    var rectAttrs = "x=\"\(fmt(cellX))\" y=\"\(fmt(swatchY))\" width=\"\(fmt(swatchWidth))\" height=\"\(fmt(swatchHeight))\" rx=\"\(fmt(swatchRadius))\""
                    switch token.key {
                    case "separator":
                        // A hairline drawn inside the slot instead of a slab
                        s.append("<rect \(rectAttrs) fill=\"none\"/>")
                        s.append(
                            "<line x1=\"\(fmt(cellX + 10))\" y1=\"\(fmt(swatchY + swatchHeight / 2))\" x2=\"\(fmt(cellX + swatchWidth - 10))\" y2=\"\(fmt(swatchY + swatchHeight / 2))\" stroke=\"\(fillHex)\" stroke-width=\"1.4\"/>"
                        )
                    case "background", "surface", "surfaceSecondary":
                        // Surfaces sit on the panel background — ring them so
                        // near-identical values stay visible
                        let ringHex = Self.resolvedHex(subInk, dark: dark, alpha: 0.45)
                        s.append("<rect \(rectAttrs) fill=\"\(chipFill)\" stroke=\"\(ringHex)\" stroke-width=\"1\"/>")
                    case "onPrimary":
                        s.append("<rect \(rectAttrs) fill=\"\(chipFill)\"/>")
                        s.append(
                            "<text x=\"\(fmt(cellX + swatchWidth / 2))\" y=\"\(fmt(swatchY + swatchHeight / 2 + 6))\" font-family=\"\(metadata.fontFamilies)\" font-size=\"16\" font-weight=\"600\" text-anchor=\"middle\" fill=\"\(fillHex)\">Aa</text>"
                        )
                    default:
                        s.append("<rect \(rectAttrs) fill=\"\(chipFill)\"/>")
                    }

                    // Labels below the swatch
                    let nameHex = Self.resolvedHex(ink, dark: dark, alpha: 0.85)
                    let hexLabelColor = Self.resolvedHex(subInk, dark: dark, alpha: 0.9)
                    s.append(
                        "<text x=\"\(fmt(cellX + swatchWidth / 2))\" y=\"\(fmt(swatchY + swatchHeight + nameBaseline))\" font-family=\"\(metadata.fontFamilies)\" font-size=\"9.5\" text-anchor=\"middle\" fill=\"\(nameHex)\">\(escape(token.key))</text>"
                    )
                    s.append(
                        "<text x=\"\(fmt(cellX + swatchWidth / 2))\" y=\"\(fmt(swatchY + swatchHeight + hexBaseline))\" font-family=\"ui-monospace, 'SF Mono', Menlo, monospace\" font-size=\"8.5\" text-anchor=\"middle\" fill=\"\(hexLabelColor)\">\(isOnPrimaryChip ? "on \(chipFill)" : fillHex)</text>"
                    )
                }

                y = swatchY + swatchHeight + rowTrailing
            }
            s.append("</g>")
        }

        s.append("</svg>")
        return s.joined(separator: "\n")
    }

    private func fmt(_ value: CGFloat) -> String {
        let rounded = (value * 100).rounded() / 100
        return String(format: "%.2f", rounded).replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }

    private func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
