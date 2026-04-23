import SwiftUI

struct GTNotificationRow: View {
    let notification: NotificationModel
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: GTSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.gtPaleGreen)
                    .frame(width: 44, height: 44)
                Text(notification.type.icon)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(notification.title)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
                Text(notification.message)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineLimit(2)
                Text(notification.timestamp.formatted(.relative(presentation: .named)))
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color.gtDarkGreen)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
            }
        }
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(notification.isRead ? Color.white : Color.gtPaleGreen.opacity(0.4))
        )
        .onTapGesture { onTap?() }
    }
}

#Preview {
    VStack(spacing: 8) {
        GTNotificationRow(notification: NotificationModel(type: .watering, title: "Time to Water", message: "Your Monstera needs watering today."))
        GTNotificationRow(notification: NotificationModel(type: .expert, title: "Session Confirmed", message: "Dr. Sarah confirmed your session.", isRead: true))
    }.padding()
}

