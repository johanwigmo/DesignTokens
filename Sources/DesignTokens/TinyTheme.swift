import SwiftUI
import UIKit

// MARK: - TinyTheme (house style)

/// The Tiny Apps house theme: calm warm paper surfaces, Gruvbox-family
/// accents, rounded type ramp. Named for the umbrella it serves — meant to
/// carry across future Tiny apps once it settles.
///
/// ```swift
/// ContentView()
///     .theme(TinyTheme())
/// ```
public struct TinyTheme: Theme {
    public let name = "Tiny"

    // Ember — Gruvbox orange pulled toward UI-muted so caption-size tinted
    // chips hold AA on paper.
    public let primary = adaptive(0xB85C38, dark: 0xD98B5F)
    public let secondary = adaptive(0x7A6A58, dark: 0xA89A88)
    public let accent = adaptive(0xB85C38, dark: 0xD98B5F)

    // Ink — owned (not system defaults) because paper shifts the baseline;
    // the WCAG suite guarantees AA for both on every reading surface.
    public let label = adaptive(0x2C2A26, dark: 0xECE9E3)
    public let labelSecondary = adaptive(0x5F594F, dark: 0xB5B0A6)

    // Paper — warm cream in light, warm near-black in dark.
    public let background = adaptive(0xF7F5EF, dark: 0x141310)
    public let surface = adaptive(0xEEEBE2, dark: 0x1C1A17)
    public let surfaceSecondary = adaptive(0xFFFFFF, dark: 0x26231F)

    // Gruvbox status family: olive green, amber yellow, faded red.
    public let success = adaptive(0x5F7A29, dark: 0x98A948)
    public let warning = adaptive(0xA87C1B, dark: 0xD7A83F)
    public let destructive = adaptive(0xAF3232, dark: 0xD96A5F)
    public let info = adaptive(0x458588, dark: 0x83A598)

    // White check on light ember; dark-paper check on the brighter dark
    // ember, where white drops under 3:1.
    public let onPrimary = adaptive(0xFFFFFF, dark: 0x141310)

    public let typography = ThemeTypography.system(.rounded)

    public init() {}
}

func adaptive(_ light: UInt, dark: UInt) -> Color {
    Color(UIColor { trait in
        let value = trait.userInterfaceStyle == .dark ? dark : light
        return UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    })
}
