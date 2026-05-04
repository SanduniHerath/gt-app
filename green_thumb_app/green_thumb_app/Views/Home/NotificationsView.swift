import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var router: AppRouter
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
                
                Button { /* Action */ } label: {
                    Text("Mark all read")
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtMidGreen)
                }
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.top, GTSpacing.lg)
            .padding(.bottom, GTSpacing.md)
            .background(Color.gtBackground)
            
            // Filters
            HStack(spacing: GTSpacing.sm) {
                FilterTab(title: "All", isSelected: selectedFilter == 0) { selectedFilter = 0 }
                FilterTab(title: "Watering", isSelected: selectedFilter == 1) { selectedFilter = 1 }
                FilterTab(title: "Disease", isSelected: selectedFilter == 2) { selectedFilter = 2 }
                Spacer()
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.bottom, GTSpacing.md)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: GTSpacing.lg) {
                    // NEW section
                    VStack(alignment: .leading, spacing: GTSpacing.sm) {
                        Text("NEW – 2 UNREAD")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextMuted)
                        
                        VStack(spacing: GTSpacing.md) {
                            NotificationCard(
                                title: "Disease alert",
                                subtitle: "Your Rose Bush signs of leaf yellowing. Diagnose now to prevent spreading",
                                time: "2 min ago",
                                icon: "exclamationmark.triangle.fill",
                                color: .gtStatusUrgent,
                                badgeText: "Urgent",
                                actionTitle: "Diagnose now",
                                action: {
                                    router.navigate(to: .diagnosisResult)
                                }
                            )
                            
                            NotificationCard(
                                title: "Time to water",
                                subtitle: "Rose Bush is due for watering at 2:00 PM today. 300ml recommended",
                                time: "15 min ago",
                                icon: "drop.fill",
                                color: .gtWatering,
                                actionTitle: "Mark done"
                            )
                        }
                    }
                    
                    // EARLIER section
                    VStack(alignment: .leading, spacing: GTSpacing.sm) {
                        Text("EARLIER")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextMuted)
                        
                        NotificationCard(
                            title: "Session confirmed",
                            subtitle: "Mr. Nimal Perera confirmed your 3:00 PM session for tomorrow.",
                            time: "Yesterday 4:22 PM",
                            icon: "person.2.fill",
                            color: .gtAccentGreen,
                            actionTitle: "View Session"
                        )
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, GTSpacing.lg)
            }
        }
        .background(Color.gtBackground)
        .navigationBarHidden(true)
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
