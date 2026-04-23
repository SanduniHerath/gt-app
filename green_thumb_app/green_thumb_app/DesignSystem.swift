import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary greens
    static let gtForestGreen   = Color(red: 0.157, green: 0.247, blue: 0.157)  // #283F28 – dark bg
    static let gtDarkGreen     = Color(red: 0.192, green: 0.306, blue: 0.192)  // #314E31 – buttons
    static let gtMidGreen      = Color(red: 0.337, green: 0.498, blue: 0.267)  // #567F44 – logo accent
    static let gtLightGreen    = Color(red: 0.659, green: 0.800, blue: 0.502)  // #A8CC80 – inactive dot
    static let gtPaleGreen     = Color(red: 0.906, green: 0.953, blue: 0.863)  // #E7F3DC – chip bg
    static let gtAccentGreen   = Color(red: 0.478, green: 0.690, blue: 0.310)  // #7AB04F – subtagline

    // Neutrals
    static let gtWhite         = Color.white
    static let gtBackground    = Color(red: 0.965, green: 0.980, blue: 0.953)  // Off-white body
    static let gtTextPrimary   = Color(red: 0.118, green: 0.118, blue: 0.118)  // #1E1E1E
    static let gtTextSecondary = Color(red: 0.459, green: 0.459, blue: 0.459)  // #757575
    static let gtTextMuted     = Color(red: 0.620, green: 0.620, blue: 0.620)  // #9E9E9E
    static let gtBorder        = Color(red: 0.820, green: 0.890, blue: 0.780)  // pale green border
    static let gtSeparator     = Color(red: 0.878, green: 0.878, blue: 0.878)  // #E0E0E0

    // Social
    static let gtGoogleRed     = Color(red: 0.918, green: 0.263, blue: 0.208)
    static let gtAppleBlack    = Color.black
    
    // Semantic
    static let gtStatusUrgent  = Color(red: 0.92, green: 0.34, blue: 0.34) // Urgent red
    static let gtWatering      = Color(red: 0.40, green: 0.78, blue: 0.94) // Water blue
    static let gtFertilizer    = Color(red: 0.76, green: 0.60, blue: 0.42) // Fertilizer brown
    static let gtStreak        = Color(red: 0.95, green: 0.60, blue: 0.10) // Streak orange
    
    // Diagnosis Result Specific
    static let gtDiagnosisPink   = Color(hex: "FEE5E5")
    static let gtDiagnosisTitle  = Color(hex: "8B1A1A")
    static let gtDiagnosisText   = Color(hex: "C44545")
    static let gtTreatmentBg     = Color(hex: "F2F2F2")
    
    // Badge Colors
    static let gtBadgeYellowBg   = Color(hex: "F4E7C4")
    static let gtBadgeYellowText = Color(hex: "A88B32")
    static let gtBadgeTealBg     = Color(hex: "D0F2F2")
    static let gtBadgeTealText   = Color(hex: "4B9B9B")
    static let gtBadgeGreenBg    = Color(hex: "E0F4D0")
    static let gtBadgeGreenText  = Color(hex: "78A33E")
    static let gtBadgePurpleBg   = Color(hex: "E6DDF2")
    static let gtBadgePurpleText = Color(hex: "9370DB")
    
    // Safety & Warnings
    static let gtSafetyBg        = Color(hex: "FDE7E7")
    static let gtSafetyBorder    = Color(hex: "EE9E9E")
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct GTFont {
    // Display / Headline — Serif feel (uses "Georgia" as system fallback)
    static func displayLarge()  -> Font { .custom("Georgia",        size: 34, relativeTo: .largeTitle) }
    static func displayMedium() -> Font { .custom("Georgia",        size: 28, relativeTo: .title) }
    static func displaySmall()  -> Font { .custom("Georgia",        size: 22, relativeTo: .title2) }

    // Body / UI — System rounded
    static func bodyLarge()     -> Font { .system(size: 17, weight: .regular, design: .rounded) }
    static func bodyMedium()    -> Font { .system(size: 15, weight: .regular, design: .rounded) }
    static func bodySmall()     -> Font { .system(size: 13, weight: .regular, design: .rounded) }

    // Label
    static func labelLarge()    -> Font { .system(size: 15, weight: .semibold, design: .rounded) }
    static func labelMedium()   -> Font { .system(size: 13, weight: .semibold, design: .rounded) }
    static func labelSmall()    -> Font { .system(size: 11, weight: .semibold, design: .rounded) }

    // Button
    static func buttonLarge()   -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    static func buttonMedium()  -> Font { .system(size: 15, weight: .semibold, design: .rounded) }

    // Italic accent
    static func accentItalic()  -> Font { .custom("Georgia-Italic", size: 28, relativeTo: .title) }
    static func accentItalicMedium() -> Font { .custom("Georgia-Italic", size: 22, relativeTo: .title2) }
}

// MARK: - Spacing Scale
struct GTSpacing {
    static let xxs: CGFloat =  4
    static let xs:  CGFloat =  8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
struct GTRadius {
    static let xs:  CGFloat =  6
    static let sm:  CGFloat = 10
    static let md:  CGFloat = 14
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 28
    static let full: CGFloat = 999
}

// MARK: - Shadow
struct GTShadow {
    static let card = Shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    static let button = Shadow(color: Color.gtDarkGreen.opacity(0.30), radius: 8, x: 0, y: 4)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func gtShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
