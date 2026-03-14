import Testing
@testable import DesignTokens

@Suite("ThemeSpacing")
struct SpacingTests {

    private let spacing = ThemeSpacing.default

    @Test("Default scale follows the 4pt grid")
    func defaultScale() {
        #expect(spacing.xxs == 2)
        #expect(spacing.xs == 4)
        #expect(spacing.sm == 8)
        #expect(spacing.md == 12)
        #expect(spacing.lg == 16)
        #expect(spacing.xl == 24)
        #expect(spacing.xxl == 32)
        #expect(spacing.xxxl == 48)
    }

    @Test("Semantic aliases map to the correct raw values")
    func semanticAliases() {
        #expect(spacing.inset == spacing.lg)
        #expect(spacing.gap == spacing.md)
        #expect(spacing.section == spacing.xl)
        #expect(spacing.compact == spacing.sm)
    }

    @Test("Minimum tap target meets HIG 44pt requirement")
    func minTapTarget() {
        #expect(spacing.minTapTarget == 44)
    }

    @Test("Custom init overrides default values")
    func customInit() {
        let custom = ThemeSpacing(sm: 10, lg: 20, minTapTarget: 48)
        #expect(custom.sm == 10)
        #expect(custom.lg == 20)
        #expect(custom.minTapTarget == 48)
        // Non-overridden values keep defaults
        #expect(custom.xxs == 2)
    }
}
