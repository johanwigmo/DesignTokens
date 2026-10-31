import Foundation
import Testing
@testable import DesignTokens

// MARK: - Theme Docs Gate
//
// Two behaviors:
//
// 1. `docsAreFresh` — the gate. Regenerates palette tables + preview SVGs
//    in memory and requires the committed files to match. Fails whenever a
//    palette change lands without regenerating docs, same philosophy as the
//    WCAG suite: adjust values through the gate, not around it.
//
// 2. `regenerate` — the escape hatch. Rewrites the committed files from the
//    live themes. Run it after any intentional palette change and commit
//    the result. In Xcode: ▶︎ next to `regenerate()` in the Test Navigator,
//    or via xcodebuild:
//
//        xcodebuild test \
//            -destination 'platform=iOS Simulator,name=iPhone 17' \
//            -only-testing:DesignTokensTests/ThemeDocsGateTests/regenerate

@Suite("Theme docs")
struct ThemeDocsGateTests {

    private struct DocSet {
        let doc: ThemeDoc
    }

    private static let tableStart = "<!-- theme-docs:palette:start -->"
    private static let tableEnd = "<!-- theme-docs:palette:end -->"

    /// Documentation/Themes, derived from this file's location so tests can
    /// read and write the real repo files from the simulator sandbox.
    private static let themesDir: URL = {
        let themeDocsDir = URL(fileURLWithPath: #filePath)  // …/Tests/DesignTokensTests/ThemeDocs/ThemeDocsGateTests.swift
            .deletingLastPathComponent()
        let repoRoot = themeDocsDir
            .deletingLastPathComponent()  // Tests/DesignTokensTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // repo root
        return repoRoot.appendingPathComponent("Documentation/Themes")
    }()

    private var docSets: [DocSet] {
        [
            DocSet(doc: .default(DefaultTheme())),
            DocSet(doc: .tiny(TinyTheme())),
        ]
    }

    // MARK: Generated content

    /// The generated markdown block, markers inclusive.
    private func generatedBlock(for set: DocSet) -> String {
        [
            Self.tableStart,
            set.doc.paletteTable(),
            Self.tableEnd,
        ].joined(separator: "\n")
    }

    private func markdownURL(for set: DocSet) -> URL {
        Self.themesDir.appendingPathComponent("\(set.doc.metadata.fileStem).md")
    }

    private func svgURL(for set: DocSet) -> URL {
        Self.themesDir
            .appendingPathComponent("assets")
            .appendingPathComponent("\(set.doc.metadata.fileStem).svg")
    }

    /// Everything between the palette markers (markers inclusive);
    /// throws if the markers are missing from the committed file.
    private func committedBlock(from markdown: String, fileStem: String) throws -> String {
        guard let start = markdown.range(of: Self.tableStart),
              let end = markdown.range(of: Self.tableEnd)
        else {
            throw ThemeDocsError.missingMarkers(fileStem)
        }
        guard start.upperBound <= end.lowerBound else {
            throw ThemeDocsError.invertedMarkers(fileStem)
        }
        return String(markdown[start.lowerBound ..< end.upperBound])
    }

    private enum ThemeDocsError: Error, CustomStringConvertible {
        case missingMarkers(String)
        case invertedMarkers(String)

        var description: String {
            switch self {
            case .missingMarkers(let stem):
                return "\(stem).md is missing the \(ThemeDocsGateTests.tableStart) / \(ThemeDocsGateTests.tableEnd) markers"
            case .invertedMarkers(let stem):
                return "\(stem).md has its palette markers in the wrong order"
            }
        }
    }

    // MARK: The gate

    @Test("Generated palette tables and previews match committed files")
    func docsAreFresh() {
        for set in docSets {
            let stem = set.doc.metadata.fileStem
            let regenerateHint = """
                \(stem) docs are stale — run ThemeDocsGateTests/regenerate \
                (▶︎ in the Test Navigator) and commit the updated files.
                """

            do {
                let markdown = try String(contentsOf: markdownURL(for: set), encoding: .utf8)
                let committed = try committedBlock(from: markdown, fileStem: stem)
                #expect(
                    committed == generatedBlock(for: set),
                    "Palette table in \(stem).md is stale. \(regenerateHint)"
                )
            } catch let docsError as ThemeDocsError {
                #expect(Bool(false), "\(docsError.description) — \(regenerateHint)")
            } catch {
                #expect(Bool(false), "Could not read \(markdownURL(for: set).path): \(error) — \(regenerateHint)")
            }

            do {
                let committedSVG = try String(contentsOf: svgURL(for: set), encoding: .utf8)
                #expect(
                    committedSVG == set.doc.previewSVG(),
                    "Preview SVG for \(stem) is stale. \(regenerateHint)"
                )
            } catch {
                #expect(Bool(false), "Could not read \(svgURL(for: set).path): \(error) — \(regenerateHint)")
            }
        }
    }

    // MARK: Regen

    @Test("Regenerate committed docs from live theme values")
    func regenerate() throws {
        try FileManager.default.createDirectory(
            at: Self.themesDir.appendingPathComponent("assets"),
            withIntermediateDirectories: true
        )

        for set in docSets {
            let stem = set.doc.metadata.fileStem

            // Markdown: replace only the marker block, preserving the
            // hand-written prose around it. Bootstrap by creating the file
            // from the template if it does not exist yet.
            let markdownURL = markdownURL(for: set)
            if !FileManager.default.fileExists(atPath: markdownURL.path) {
                let template = """
                    # \(stem)

                    TODO: hand-written intro.

                    \(Self.tableStart)
                    \(Self.tableEnd)

                    TODO: hand-written rationale and usage.
                    """
                try template.write(to: markdownURL, atomically: true, encoding: .utf8)
            }

            let markdown = try String(contentsOf: markdownURL, encoding: .utf8)
            let withBlock: String
            if let range = markdown.range(of: "\(Self.tableStart)\n\(Self.tableEnd)"),
               markdown.contains(Self.tableStart), markdown.contains(Self.tableEnd)
            {
                // Bare markers (first bootstrap): fill between them.
                let generated = "\(Self.tableStart)\n\(set.doc.paletteTable())\n\(Self.tableEnd)"
                withBlock = markdown.replacingCharacters(in: range, with: generated)
            } else {
                let committed = try committedBlock(from: markdown, fileStem: stem)
                withBlock = markdown.replacingOccurrences(of: committed, with: generatedBlock(for: set))
            }
            try withBlock.write(to: markdownURL, atomically: true, encoding: .utf8)

            // Preview SVG: fully generated.
            try set.doc.previewSVG().write(to: svgURL(for: set), atomically: true, encoding: .utf8)
        }
    }
}
