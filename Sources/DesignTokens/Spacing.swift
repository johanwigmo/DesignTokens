import SwiftUI

// MARK: - Spacing Tokens

/// A spacing scale built on a 4pt base grid.
///
/// The 4pt grid aligns with Apple's own layout metrics and keeps
/// all spacing values pixel-perfect on @2x and @3x displays.
///
/// Raw scale (`xxs` → `xxxl`) plus semantic aliases (`inset`,
/// `gap`, `section`) so views read naturally.
public struct ThemeSpacing: Sendable {

    // MARK: Raw Scale

    /// 2pt — hairline gaps, tight icon padding.
    public let xxs: CGFloat
    /// 4pt — minimum content padding.
    public let xs: CGFloat
    /// 8pt — compact internal spacing.
    public let sm: CGFloat
    /// 12pt — default gap between related elements.
    public let md: CGFloat
    /// 16pt — standard content inset / padding.
    public let lg: CGFloat
    /// 24pt — section spacing.
    public let xl: CGFloat
    /// 32pt — major section breaks.
    public let xxl: CGFloat
    /// 48pt — screen-level margins or hero spacing.
    public let xxxl: CGFloat

    // MARK: Semantic Aliases

    /// Default content inset from screen edges (16pt).
    public var inset: CGFloat { lg }
    /// Default gap between sibling elements (12pt).
    public var gap: CGFloat { md }
    /// Spacing between sections (24pt).
    public var section: CGFloat { xl }
    /// Tight padding inside compact components (8pt).
    public var compact: CGFloat { sm }

    // MARK: Accessibility

    /// Minimum interactive target dimension (44pt per HIG).
    public let minTapTarget: CGFloat

    public init(
        xxs: CGFloat = 2,
        xs: CGFloat = 4,
        sm: CGFloat = 8,
        md: CGFloat = 12,
        lg: CGFloat = 16,
        xl: CGFloat = 24,
        xxl: CGFloat = 32,
        xxxl: CGFloat = 48,
        minTapTarget: CGFloat = 44
    ) {
        self.xxs = xxs
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
        self.minTapTarget = minTapTarget
    }

    /// Default 4pt-grid spacing.
    public static let `default` = ThemeSpacing()
}
