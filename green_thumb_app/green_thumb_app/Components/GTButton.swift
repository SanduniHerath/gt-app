import SwiftUI

// MARK: - Button Style Variants
enum GTButtonStyle { case primary, secondary, outline, ghost, social, expert }
enum GTButtonSize  { case large, medium, small }

struct GTButton: View {
    let title: String
    var icon: String?           // SF Symbol name
    var trailingIcon: String?
    var style: GTButtonStyle  = .primary
    var size: GTButtonSize    = .large
    var isLoading: Bool       = false
    var isDisabled: Bool      = false
    let action: () -> Void

    private var bgColor: Color {
        switch style {
        case .primary:   return .gtDarkGreen
        case .secondary: return .gtPaleGreen
        case .outline:   return .clear
        case .ghost:     return .clear
        case .social:    return .white
        case .expert:    return Color.gtTreatmentBg.opacity(0.5)
        }
    }
    private var fgColor: Color {
        switch style {
        case .primary:   return .white
        case .secondary: return .gtDarkGreen
        case .outline:   return .gtDarkGreen
        case .ghost:     return .gtDarkGreen
        case .social:    return .gtTextPrimary
        case .expert:    return .gtTextSecondary
        }
    }
    private var borderColor: Color {
        switch style {
        case .outline:   return .gtDarkGreen
        case .social:    return .gtSeparator
        case .expert:    return .gtBorder
        default:         return .clear
        }
    }
    private var height: CGFloat {
        switch size {
        case .large:  return 56
        case .medium: return 46
        case .small:  return 36
        }
    }
    private var font: Font {
        switch size {
        case .large:  return GTFont.buttonLarge()
        case .medium: return GTFont.buttonMedium()
        case .small:  return GTFont.labelMedium()
        }
    }

    var body: some View {
        Button(action: { if !isDisabled && !isLoading { action() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: GTRadius.xl)
                    .fill(bgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: GTRadius.xl)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
                    .frame(height: height)

                if isLoading {
                    ProgressView().tint(fgColor)
                } else {
                    HStack(spacing: GTSpacing.xs) {
                        if let icon { Image(systemName: icon).font(font) }
                        Text(title).font(font)
                        if let t = trailingIcon { Image(systemName: t).font(font) }
                    }
                    .foregroundColor(fgColor)
                }
            }
        }
        .opacity(isDisabled ? 0.5 : 1)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 12) {
        GTButton(title: "Sign in to my garden", action: {})
        GTButton(title: "Use Face ID", icon: "faceid", action: {})
        GTButton(title: "Next", trailingIcon: "arrow.right", action: {})
        GTButton(title: "Google", icon: "g.circle", style: .social, size: .medium, action: {})
        GTButton(title: "Loading", style: .primary, isLoading: true, action: {})
    }
    .padding()
}
