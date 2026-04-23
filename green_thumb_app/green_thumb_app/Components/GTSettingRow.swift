import SwiftUI

struct GTSettingRow: View {
    let icon: String
    let iconBgColor: Color
    let title: String
    let subtitle: String?
    var showNewBadge: Bool = false
    var trailingContent: AnyView? = nil
    
    init(icon: String, iconBgColor: Color, title: String, subtitle: String? = nil, showNewBadge: Bool = false, trailingContent: AnyView? = nil) {
        self.icon = icon
        self.iconBgColor = iconBgColor
        self.title = title
        self.subtitle = subtitle
        self.showNewBadge = showNewBadge
        self.trailingContent = trailingContent
    }
    
    // Convenience init for toggles
    init(icon: String, iconBgColor: Color, title: String, subtitle: String? = nil, showNewBadge: Bool = false, isOn: Binding<Bool>) {
        self.icon = icon
        self.iconBgColor = iconBgColor
        self.title = title
        self.subtitle = subtitle
        self.showNewBadge = showNewBadge
        self.trailingContent = AnyView(
            Toggle("", isOn: isOn)
                .tint(.gtDarkGreen)
                .labelsHidden()
        )
    }

    var body: some View {
        HStack(spacing: GTSpacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconBgColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconBgColor)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                    
                    if showNewBadge {
                        Text("New")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gtDarkGreen)
                            .clipShape(Capsule())
                    }
                }
                
                if let subtitle {
                    Text(subtitle)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Trailing Content
            if let trailingContent {
                trailingContent
            }
        }
        .padding(.vertical, GTSpacing.sm)
    }
}
