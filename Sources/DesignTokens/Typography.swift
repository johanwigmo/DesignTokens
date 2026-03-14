import SwiftUI

// MARK: - Typography Tokens

/// Wraps Apple's built-in `TextStyle` system with semantic names.
///
/// Uses `Font.TextStyle` under the hood so Dynamic Type works
/// automatically — no hardcoded point sizes.
///
/// WCAG note: By using Dynamic Type exclusively, text scales with
/// the user's accessibility settings, satisfying WCAG 1.4.4
/// (Resize Text) up to 200%+ enlargement.
public struct ThemeTypography: Sendable {

    // MARK: Display / Hero

    /// Large titles — navigation bar large title style.
    public let largeTitle: Font
    /// Primary title.
    public let title: Font
    /// Secondary title.
    public let title2: Font
    /// Tertiary title.
    public let title3: Font

    // MARK: Content

    /// Emphasized body text (semibold headline).
    public let headline: Font
    /// Standard body text — the default reading size.
    public let body: Font
    /// Secondary content, slightly smaller than body.
    public let callout: Font
    /// Supplementary text such as dates or bylines.
    public let subheadline: Font

    // MARK: Supporting

    /// Footnotes, annotations.
    public let footnote: Font
    /// Small labels, timestamps.
    public let caption: Font
    /// Smallest text — legal, disclaimers.
    public let caption2: Font

    public init(
        largeTitle: Font = .largeTitle,
        title: Font = .title,
        title2: Font = .title2,
        title3: Font = .title3,
        headline: Font = .headline,
        body: Font = .body,
        callout: Font = .callout,
        subheadline: Font = .subheadline,
        footnote: Font = .footnote,
        caption: Font = .caption,
        caption2: Font = .caption2
    ) {
        self.largeTitle = largeTitle
        self.title = title
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption = caption
        self.caption2 = caption2
    }

    /// System defaults — SF Pro with Dynamic Type.
    public static let `default` = ThemeTypography()

    /// All text styles using a system font design (serif, rounded, monospaced).
    ///
    /// Dynamic Type still works automatically.
    ///
    /// ```swift
    /// var typography: ThemeTypography { .system(.serif) }
    /// ```
    public static func system(_ design: Font.Design) -> ThemeTypography {
        ThemeTypography(
            largeTitle: .system(.largeTitle, design: design),
            title: .system(.title, design: design),
            title2: .system(.title2, design: design),
            title3: .system(.title3, design: design),
            headline: .system(.headline, design: design),
            body: .system(.body, design: design),
            callout: .system(.callout, design: design),
            subheadline: .system(.subheadline, design: design),
            footnote: .system(.footnote, design: design),
            caption: .system(.caption, design: design),
            caption2: .system(.caption2, design: design)
        )
    }

    /// All text styles using a custom font family with Dynamic Type scaling.
    ///
    /// Each style maps to its corresponding `TextStyle` for proper scaling.
    /// Falls back gracefully to the system font if the family isn't found.
    ///
    /// ```swift
    /// var typography: ThemeTypography { .custom("Georgia") }
    /// ```
    public static func custom(_ family: String) -> ThemeTypography {
        ThemeTypography(
            largeTitle: .custom(family, size: 34, relativeTo: .largeTitle),
            title: .custom(family, size: 28, relativeTo: .title),
            title2: .custom(family, size: 22, relativeTo: .title2),
            title3: .custom(family, size: 20, relativeTo: .title3),
            headline: .custom(family, size: 17, relativeTo: .headline),
            body: .custom(family, size: 17, relativeTo: .body),
            callout: .custom(family, size: 16, relativeTo: .callout),
            subheadline: .custom(family, size: 15, relativeTo: .subheadline),
            footnote: .custom(family, size: 13, relativeTo: .footnote),
            caption: .custom(family, size: 12, relativeTo: .caption),
            caption2: .custom(family, size: 11, relativeTo: .caption2)
        )
    }
}

// MARK: - Font Convenience Extensions

public extension Font {
    /// Shorthand for themed typography: `Font.themed(.body)`
    static func themed(_ keyPath: KeyPath<ThemeTypography, Font>, from typography: ThemeTypography = .default) -> Font {
        typography[keyPath: keyPath]
    }
}
