import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var notifyVM: NotificationsViewModel
    @State private var selectedFilter = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button { router.pop() } label: {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 38, height: 38).gtShadow(GTShadow.card)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gtTextPrimary)
                    }
                }
                
                Text("Notifications")
                    .font(GTFont.displaySmall())
                    .foregroundColor(.gtTextPrimary)
                    .padding(.leading, GTSpacing.sm)
                
                Spacer()
                
                Button { notifyVM.markAllRead() } label: {
                    Text("Mark all read")
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtMidGreen)
                }
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.top, 20)
            .padding(.bottom, GTSpacing.md)
            .background(Color.gtBackground)
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: GTSpacing.lg) {
                    if notifyVM.notifications.isEmpty {
                        VStack(spacing: 20) {
                            Spacer(minLength: 100)
                            Image(systemName: "bell.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gtTextMuted)
                            Text("No notifications yet")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextMuted)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(notifyVM.notifications) { notification in
                            NotificationCard(
                                title: notification.title,
                                subtitle: notification.message,
                                time: "Just now", // In a real app, format notification.timestamp
                                icon: iconForType(notification.type),
                                color: colorForType(notification.type),
                                actionTitle: notification.type == .expert ? "View Session" : nil,
                                action: {
                                    // Handle actions
                                }
                            )
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.top, GTSpacing.md)
            }
        }
        .background(Color.gtBackground)
        .navigationBarHidden(true)
    }
    
    private func iconForType(_ type: NotificationType) -> String {
        switch type {
        case .watering: return "drop.fill"
        case .fertilizing: return "leaf.fill"
        case .diagnosis: return "waveform.path.ecg.rectangle"
        case .expert: return "person.2.fill"
        case .community: return "bubble.left.fill"
        case .system: return "gearshape.fill"
        }
    }
    
    private func colorForType(_ type: NotificationType) -> Color {
        switch type {
        case .watering: return .gtWatering
        case .fertilizing: return .gtDarkGreen
        case .diagnosis: return .gtStatusUrgent
        case .expert: return .gtAccentGreen
        case .community: return .gtBadgeTealText
        case .system: return .gtTextMuted
        }
    }
}

// MARK: - Reusable Local Components
struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GTFont.labelMedium())
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(isSelected ? Color.gtForestGreen : Color.white)
                .foregroundColor(isSelected ? .white : .gtTextMuted)
                .clipShape(Capsule())
                .gtShadow(isSelected ? GTShadow.card : Shadow(color: .clear, radius: 0, x: 0, y: 0))
        }
    }
}

struct NotificationCard: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let color: Color
    var badgeText: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(width: 4)
            
            HStack(alignment: .top, spacing: GTSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Spacer()
                        if let badgeText {
                            Text(badgeText)
                                .font(GTFont.labelSmall())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(color.opacity(0.1))
                                .foregroundColor(color)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(subtitle)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextSecondary)
                        .lineLimit(3)
                    
                    Text(time)
                        .font(GTFont.labelSmall())
                        .foregroundColor(.gtTextMuted)
                    
                    if let actionTitle {
                        Button { action?() } label: {
                            Text(actionTitle)
                                .font(GTFont.labelSmall())
                                .foregroundColor(color)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Capsule().stroke(color, lineWidth: 1.5))
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(GTSpacing.md)
        }
        .background(Color.white)
        .cornerRadius(GTRadius.md)
        .gtShadow(GTShadow.card)
    }
}

#Preview {
    NotificationsView()
        .environmentObject(AppRouter())
}

#Preview {
    NotificationsView().environmentObject(NotificationsViewModel())
}
