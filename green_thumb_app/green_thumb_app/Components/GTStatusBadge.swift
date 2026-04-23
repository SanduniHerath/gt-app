import SwiftUI

// GTStatusBadge — pill-shaped label for plant health / features
struct GTStatusBadge: View {
    let text: String
    var backgroundColor: Color = .gtPaleGreen
    var foregroundColor: Color = .gtDarkGreen
    var font: Font = GTFont.labelSmall()
    var horizontalPadding: CGFloat = GTSpacing.md
    var verticalPadding: CGFloat = GTSpacing.xxs + 2

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                Capsule().fill(backgroundColor)
            )
    }
}

// Convenience preset for feature counter chips (e.g. "FEATURE 01 OF 02")
extension GTStatusBadge {
    static func feature(_ text: String) -> GTStatusBadge {
        GTStatusBadge(
            text: text,
            backgroundColor: Color(red: 0.859, green: 0.937, blue: 0.780),  // #DBEFc7
            foregroundColor: Color(red: 0.259, green: 0.420, blue: 0.180),  // #426B2E
            font: .system(size: 12, weight: .semibold, design: .rounded)
        )
    }
    static func status(_ status: PlantStatus) -> GTStatusBadge {
        let (bg, fg): (Color, Color) = {
            switch status {
            case .healthy:    return (.gtPaleGreen,                         .gtDarkGreen)
            case .warning:    return (Color(red:1,green:0.95,blue:0.8),    Color(red:0.6,green:0.4,blue:0))
            case .critical:   return (Color(red:1,green:0.9,blue:0.9),     Color(red:0.7,green:0.1,blue:0.1))
            case .recovering: return (Color(red:0.9,green:0.95,blue:1),    Color(red:0.2,green:0.3,blue:0.7))
            }
        }()
        return GTStatusBadge(text: status.rawValue, backgroundColor: bg, foregroundColor: fg)
    }
}

#Preview {
    VStack(spacing: 8) {
        GTStatusBadge.feature("FEATURE 01 OF 02")
        GTStatusBadge.status(.healthy)
        GTStatusBadge.status(.warning)
        GTStatusBadge.status(.critical)
    }.padding()
}

