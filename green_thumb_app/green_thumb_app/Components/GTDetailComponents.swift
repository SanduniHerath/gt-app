import SwiftUI

// MARK: - Info Card
struct GTDetailInfoCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20, weight: .semibold))
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
                Text(label)
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

// MARK: - Action Button
struct GTDetailActionButton: View {
    let icon: String
    let label: String
    let color: Color
    var hasAlert: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(hasAlert ? 0.15 : 0.08))
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(hasAlert ? Color.gtStatusUrgent : Color.black.opacity(0.05), lineWidth: 1.5)
                        )
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 24, weight: .medium))
                }
                
                Text(label)
                    .font(GTFont.labelSmall())
                    .foregroundColor(hasAlert ? .gtStatusUrgent : .gtTextPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Note Entry
struct GTNoteEntry: View {
    let dotColor: Color
    let content: String
    let timestamp: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(dotColor)
                .frame(width: 10, height: 10)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(content)
                    .font(GTFont.bodyMedium())
                    .foregroundColor(.gtTextPrimary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(timestamp)
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
