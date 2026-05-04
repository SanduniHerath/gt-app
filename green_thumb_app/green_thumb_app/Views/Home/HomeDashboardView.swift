import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject var plantVM:        PlantViewModel
    @EnvironmentObject var schedulerVM:    SchedulerViewModel
    @EnvironmentObject var notificationsVM: NotificationsViewModel
    @EnvironmentObject var profileVM:      ProfileViewModel
    @EnvironmentObject var router:         AppRouter
    @State private var showNotifications  = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Header (Forest Green) ─────────────────────────────
                    VStack(alignment: .leading, spacing: GTSpacing.xs) {
                        HStack {
                            GTAvatar(name: profileVM.profile.name, size: 40)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Good morning")
                                    .font(GTFont.bodySmall())
                                    .foregroundColor(.white.opacity(0.8))
                                Text(profileVM.profile.name)
                                    .font(GTFont.labelLarge())
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button { showNotifications = true } label: {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, GTSpacing.lg)
                        .padding(.bottom, GTSpacing.md)
                    }
                    .padding(.horizontal, GTSpacing.lg)
                    .background(Color.gtForestGreen)

                    // ── Body (Light Gray) ─────────────────────────────────
                    VStack(alignment: .leading, spacing: GTSpacing.lg) {
                        // 2x2 Stat Grid
                        VStack(spacing: GTSpacing.sm) {
                            HStack(spacing: GTSpacing.sm) {
                                Button {
                                    router.navigate(to: .gardenAnalytics)
                                } label: {
                                    GTGridStatCard(value: "12", label: "Total Plants", icon: "leaf.fill", color: .gtAccentGreen)
                                }
                                GTGridStatCard(value: "7", label: "Day Streak", icon: "flame.fill", subtext: "personal best", color: .gtStreak)
                            }
                            HStack(spacing: GTSpacing.sm) {
                                GTGridStatCard(value: "3", label: "Today Tasks", icon: "clock.fill", subtext: "2 pending", color: .gtWatering)
                                GTGridStatCard(value: "1", label: "Active alerts", icon: "triangle.fill", subtext: "Needs care", color: .gtStatusUrgent)
                            }
                        }
                        .padding(.top, GTSpacing.lg)
                        
                        // Alert Banner
                        GTAlertBanner(
                            title: "Rose Bush Yellow Leaves",
                            subtitle: "Possible nitrogen deficiency detected",
                            actionTitle: "Diagnose"
                        ) {
                            // Diagnosis action
                        }

                        // Today's tasks
                        VStack(alignment: .leading, spacing: GTSpacing.sm) {
                            Text("Today's tasks")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)
                            
                            VStack(spacing: GTSpacing.sm) {
                                HomeTaskRow(title: "Water Tomatoes", subtitle: "Back garden – 250ml", icon: "leaf.fill", color: .gtAccentGreen, isDone: true)
                                HomeTaskRow(title: "Water Rose Bush", subtitle: "Front garden – 300ml", icon: "drop.fill", color: .gtWatering, time: "2:00 PM")
                                HomeTaskRow(title: "Fertilise Basil", subtitle: "Balcony pot – NPK 10-10-10", icon: "square.grid.2x2.fill", color: .gtFertilizer, time: "5:00 PM")
                            }
                        }
                        
                        // Garden health
                        VStack(alignment: .leading, spacing: GTSpacing.sm) {
                            Text("Garden health")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)
                            
                            VStack(spacing: GTSpacing.md) {
                                GTHealthRow(name: "Tomatoes", progress: 0.88, color: .gtAccentGreen)
                                GTHealthRow(name: "Rose Bush", progress: 0.54, color: .orange)
                                GTHealthRow(name: "Basil", progress: 0.95, color: .teal)
                                GTHealthRow(name: "Chilli", progress: 0.72, color: .gtAccentGreen)
                            }
                            .padding(GTSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: GTRadius.md)
                                    .fill(Color.white)
                                    .gtShadow(GTShadow.card)
                            )
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, GTSpacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red:0.95, green:0.95, blue:0.95))
                }
            }
            .background(
                VStack(spacing: 0) {
                    Color.gtForestGreen.frame(height: 400)
                    Color(red: 0.95, green: 0.95, blue: 0.95)
                }
                .ignoresSafeArea()
            )
            .navigationDestination(isPresented: $showNotifications) { NotificationsView() }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .gardenAnalytics:
                    GardenAnalyticsView()
                case .plantDetails(let plant):
                    PlantDetailsView(plant: plant)
                case .growthTimeline(let plant):
                    PlantTimelineView(plant: plant)
                case .addPlant:
                    AddPlantView()
                case .careGuide:
                    CareGuideView()
                case .diagnosisResult:
                    DiagnosisResultView()
                case .nearbyExperts:
                    NearbyExpertsMapView()
                case .notifications:
                    NotificationsView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Local Components
struct GTGridStatCard: View {
    let value: String
    let label: String
    let icon: String
    var subtext: String? = nil
    var color: Color = .gtDarkGreen
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }
            
            Text(value)
                .font(GTFont.displaySmall())
                .foregroundColor(.gtTextPrimary)
            
            Text(label)
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
            
            if let subtext {
                Text(subtext)
                    .font(GTFont.labelSmall())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(color.opacity(0.1)))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(Color.white)
                .gtShadow(GTShadow.card)
        )
    }
}

struct HomeTaskRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isDone: Bool = false
    var time: String? = nil
    
    var body: some View {
        HStack(spacing: GTSpacing.md) {
            ZStack {
                Circle()
                    .stroke(isDone ? Color.gtAccentGreen : Color.gtBorder, lineWidth: 2)
                    .frame(width: 28, height: 28)
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gtAccentGreen)
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GTFont.labelMedium())
                    .foregroundColor(isDone ? .gtTextMuted : .gtTextPrimary)
                    .strikethrough(isDone)
                Text(subtitle)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextMuted)
            }
            
            Spacer()
            
            if isDone {
                Text("Done")
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            } else if let time {
                Text(time)
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }
        }
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(Color.white)
                .gtShadow(GTShadow.card)
        )
    }
}


#Preview {
    HomeDashboardView()
        .environmentObject(AppRouter()).environmentObject(AuthViewModel())
        .environmentObject(PlantViewModel()).environmentObject(DiagnoseViewModel())
        .environmentObject(SchedulerViewModel()).environmentObject(ExpertViewModel())
        .environmentObject(CommunityViewModel()).environmentObject(NotificationsViewModel())
        .environmentObject(ProfileViewModel())
}
