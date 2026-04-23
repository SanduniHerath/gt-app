import SwiftUI

struct GTSchedulerTaskRow: View {
    let title: String
    let subtitle: String
    let time: String
    let frequency: String
    let iconName: String
    let iconBgColor: Color
    let iconColor: Color
    var isDone: Bool = false
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isDone ? Color.gtDarkGreen : Color.gtAccentGreen.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                    
                    if isDone {
                        Circle()
                            .fill(Color.gtDarkGreen)
                            .frame(width: 32, height: 32)
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBgColor)
                        .frame(width: 48, height: 48)
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: 18))
                }
                
                // Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(GTFont.labelLarge())
                        .foregroundColor(isDone ? .gtTextMuted : .gtTextPrimary)
                        .strikethrough(isDone)
                    
                    Text(subtitle)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextSecondary)
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Metadata
                VStack(alignment: .trailing, spacing: 2) {
                    if isDone {
                        Text("Done")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextMuted)
                    } else {
                        Text(time)
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text(frequency)
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextMuted)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        GTSchedulerTaskRow(
            title: "Water Tomatoes",
            subtitle: "Back garden – 250ml",
            time: "Done",
            frequency: "",
            iconName: "shield",
            iconBgColor: Color.gtBadgeGreenBg,
            iconColor: Color.gtBadgeGreenText,
            isDone: true
        )
        
        GTSchedulerTaskRow(
            title: "Water Rose Bush",
            subtitle: "Front garden – 300ml",
            time: "2.00 PM",
            frequency: "Every 2 days",
            iconName: "drop",
            iconBgColor: Color.gtBadgeTealBg,
            iconColor: Color.gtBadgeTealText,
            isDone: false
        )
    }
    .padding()
    .background(Color.gtTreatmentBg)
}
