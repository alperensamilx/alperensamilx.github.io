import SwiftUI
import UIKit
import CoreText

// MARK: - Theme

enum AppTheme: String {
    case light, dark
}

// Design tokens from the v6 "Keeper" handoff. The in-app toggle drives the
// palette (defaulting to the system appearance), so tokens live here rather
// than in the asset catalog.
struct Palette: Equatable {
    let bg: Color
    let card: Color
    let card2: Color
    let ink: Color
    let secondary: Color
    let tertiary: Color
    let hairline: Color
    let fill: Color
    let accent: Color
    let accentSoft: Color
    let accentText: Color
    let onAccent: Color
    let amber: Color
    let amberSoft: Color
    let downRed: Color
    let dock: Color
    let shadow1: Color
    let shadow2: Color
    let mapLand: Color
    let mapVisited: Color
    let mapEdge: Color
    let mapStroke: Color

    static let light = Palette(
        bg: Color(hex: 0xF6F4F0),
        card: .white,
        card2: Color(hex: 0xF0EDE7),
        ink: Color(hex: 0x1C1B18),
        secondary: Color(hex: 0x1C1B18).opacity(0.60),
        tertiary: Color(hex: 0x1C1B18).opacity(0.34),
        hairline: Color(hex: 0x1C1B18).opacity(0.10),
        fill: Color(hex: 0x1C1B18).opacity(0.05),
        accent: Color(hex: 0x0F7A6B),
        accentSoft: Color(hex: 0xDFEDE9),
        accentText: Color(hex: 0x0A6156),
        onAccent: Color(hex: 0xF5FBF9),
        amber: Color(hex: 0xB4690E),
        amberSoft: Color(hex: 0xF5E6D2),
        downRed: Color(hex: 0xB3382C),
        dock: Color.white.opacity(0.88),
        shadow1: Color(hex: 0x1C1B18).opacity(0.04),
        shadow2: Color(hex: 0x1C1B18).opacity(0.07),
        mapLand: Color(hex: 0xE7E2D8),
        mapVisited: Color(hex: 0xBFDDD5),
        mapEdge: Color(hex: 0x1C1B18).opacity(0.15),
        mapStroke: .white)

    static let dark = Palette(
        bg: Color(hex: 0x131315),
        card: Color(hex: 0x1C1C1F),
        card2: Color(hex: 0x242428),
        ink: Color(hex: 0xF2F1ED),
        secondary: Color(hex: 0xF2F1ED).opacity(0.62),
        tertiary: Color(hex: 0xF2F1ED).opacity(0.36),
        hairline: Color(hex: 0xF2F1ED).opacity(0.10),
        fill: Color(hex: 0xF2F1ED).opacity(0.06),
        accent: Color(hex: 0x2FA894),
        accentSoft: Color(hex: 0x2FA894).opacity(0.16),
        accentText: Color(hex: 0x54BFAC),
        onAccent: Color(hex: 0x0B2622),
        amber: Color(hex: 0xE3A34F),
        amberSoft: Color(hex: 0xE3A34F).opacity(0.16),
        downRed: Color(hex: 0xE06A5C),
        dock: Color(hex: 0x18181A).opacity(0.9),
        shadow1: Color.black.opacity(0.4),
        shadow2: Color.black.opacity(0.35),
        mapLand: Color(hex: 0x26262A),
        mapVisited: Color(hex: 0x2C4A45),
        mapEdge: Color(hex: 0xF2F1ED).opacity(0.14),
        mapStroke: Color(hex: 0x1C1C1F))

    static func of(_ theme: AppTheme) -> Palette {
        theme == .dark ? .dark : .light
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = Palette.light
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

// MARK: - Typography

// Hanken Grotesk is bundled and registered at launch; falls back to SF Pro.
enum AppFonts {
    private(set) static var hankenAvailable = false

    static func register() {
        let names = ["HankenGrotesk-Regular", "HankenGrotesk-SemiBold",
                     "HankenGrotesk-Bold", "HankenGrotesk-ExtraBold"]
        for name in names where UIFont(name: name, size: 12) == nil {
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
        hankenAvailable = UIFont(name: "HankenGrotesk-Regular", size: 12) != nil
    }

    static func font(size: CGFloat, weight: Font.Weight) -> Font {
        guard hankenAvailable else { return .system(size: size, weight: weight) }
        switch weight {
        case .heavy, .black:
            return .custom("HankenGrotesk-ExtraBold", size: size)
        case .bold:
            return .custom("HankenGrotesk-Bold", size: size)
        case .semibold, .medium:
            return .custom("HankenGrotesk-SemiBold", size: size)
        default:
            return .custom("HankenGrotesk-Regular", size: size)
        }
    }
}

extension Font {
    // Weights map to the CSS reference: 800 -> .heavy, 700 -> .bold, 600 -> .semibold.
    static func hanken(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        AppFonts.font(size: size, weight: weight)
    }
}

// MARK: - Card container

struct CardBackground: ViewModifier {
    @Environment(\.palette) private var p

    func body(content: Content) -> some View {
        content
            .background(p.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: p.shadow1, radius: 1, y: 1)
            .shadow(color: p.shadow2, radius: 12, y: 8)
    }
}

extension View {
    func card() -> some View {
        modifier(CardBackground())
    }
}
