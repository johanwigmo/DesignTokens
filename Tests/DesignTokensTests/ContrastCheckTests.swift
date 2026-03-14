import Testing
import UIKit
@testable import DesignTokens

@Suite("ContrastCheck")
struct ContrastCheckTests {

    @Test("Black on white produces maximum contrast ratio (21:1)")
    func blackOnWhite() {
        let ratio = ContrastCheck.ratio(between: .black, and: .white)
        #expect(ratio == 21.0)
    }

    @Test("Identical colors produce minimum contrast ratio (1:1)")
    func identicalColors() {
        let ratio = ContrastCheck.ratio(between: .red, and: .red)
        #expect(ratio == 1.0)
    }

    @Test("Ratio is symmetric regardless of argument order")
    func symmetry() {
        let ab = ContrastCheck.ratio(between: .blue, and: .white)
        let ba = ContrastCheck.ratio(between: .white, and: .blue)
        #expect(ab == ba)
    }

    @Test("Black on white passes all WCAG levels")
    func blackOnWhitePassesAll() {
        #expect(ContrastCheck.passes(foreground: .black, background: .white, level: .normalAAA))
        #expect(ContrastCheck.passes(foreground: .black, background: .white, level: .normalAA))
        #expect(ContrastCheck.passes(foreground: .black, background: .white, level: .largeAA))
    }

    @Test("Low contrast pair fails normalAA")
    func lowContrastFails() {
        let lightGray = UIColor(white: 0.7, alpha: 1)
        let white = UIColor.white
        #expect(!ContrastCheck.passes(foreground: lightGray, background: white, level: .normalAA))
    }

    @Test("Default level is normalAA (4.5:1)")
    func defaultLevel() {
        // A mid-gray that passes largeAA (3.0) but fails normalAA (4.5)
        let gray = UIColor(white: 0.55, alpha: 1)
        let passesLargeAA = ContrastCheck.passes(foreground: gray, background: .white, level: .largeAA)
        let passesDefault = ContrastCheck.passes(foreground: gray, background: .white)
        #expect(passesLargeAA)
        #expect(!passesDefault)
    }
}
