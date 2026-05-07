import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject var plantVM:        PlantViewModel
    @EnvironmentObject var schedulerVM:    SchedulerViewModel
    @EnvironmentObject var notificationsVM: NotificationsViewModel
    @EnvironmentObject var profileVM:      ProfileViewModel
    @EnvironmentObject var router:         AppRouter
    @State private var showNotifications  = false

    var body: some View {
        NavigationStack(path: $router.path) {
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
                        // 2x2 Stat Grid — all cards navigate to Garden Analytics
                        VStack(spacing: GTSpacing.sm) {
                            HStack(spacing: GTSpacing.sm) {
                                let totalPlants = plantVM.plants.count
                                GTGridStatCard(
                                    value: "\(totalPlants)", 
                                    label: "Total Plants", 
                                    icon: "leaf.fill", 
                                    color: .gtAccentGreen
                                )
                                .onTapGesture { router.navigate(to: .gardenAnalytics) }
                                
                                let globalStreak = profileVM.profile.streakDays
                                GTGridStatCard(
                                    value: "\(globalStreak)", 
                                    label: "Day Streak", 
                                    icon: "flame.fill", 
                                    subtext: "personal best", 
                                    color: .gtStreak
                                )
                                .onTapGesture { router.navigate(to: .gardenAnalytics) }
                            }
                            HStack(spacing: GTSpacing.sm) {
                                let todayTasks = schedulerVM.tasks(for: Date())
                                let pendingCount = todayTasks.filter { !$0.isCompleted }.count
                                GTGridStatCard(
                                    value: "\(todayTasks.count)", 
                                    label: "Today Tasks", 
                                    icon: "clock.fill", 
                                    subtext: "\(pendingCount) pending", 
                                    color: .gtWatering
                                )
                                .onTapGesture { router.navigate(to: .gardenAnalytics) }
                                
                                let alertCount = plantVM.plants.filter { $0.status == .warning || $0.status == .critical }.count
                                GTGridStatCard(
                                    value: "\(alertCount)", 
                                    label: "Active alerts", 
                                    icon: "triangle.fill", 
                                    subtext: alertCount > 0 ? "\(alertCount) needs care" : "All healthy", 
                                    color: alertCount > 0 ? .gtStatusUrgent : .gtDarkGreen
                                )
                                .onTapGesture { router.navigate(to: .gardenAnalytics) }
                            }
                        }
                        .padding(.top, GTSpacing.lg)
                        
                        // Alert Banner (Dynamic — shows real diagnosis name)
                        if let alertingPlant = plantVM.plants.first(where: { $0.status == .warning || $0.status == .critical }) {
                            let diagnosisSubtitle: String = {
                                if let disease = alertingPlant.lastDiagnosisName {
                                    return "\(disease) detected – tap to view treatment"
                                }
                                return alertingPlant.status == .critical
                                    ? "Critical health — immediate care needed"
                                    : "Symptoms noticed — run a diagnosis"
                            }()
                            GTAlertBanner(
                                title: "\(alertingPlant.name) needs attention",
                                subtitle: diagnosisSubtitle,
                                actionTitle: "Check"
                            ) {
                                router.navigate(to: .plantDetails(alertingPlant))
                            }
                        }

                        // Today's tasks
                        VStack(alignment: .leading, spacing: GTSpacing.sm) {
                            Text("Today's tasks")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)
                            
                            let todayTasks = schedulerVM.tasks(for: Date())
                            if todayTasks.isEmpty {
                                Text("No tasks for today. Enjoy your garden!")
                                    .font(GTFont.bodySmall())
                                    .foregroundColor(.gtTextSecondary)
                                    .padding(.vertical, 10)
                            } else {
                                VStack(spacing: GTSpacing.sm) {
                                    ForEach(todayTasks.prefix(3)) { task in
                                        HomeTaskRow(
                                            title: "\(task.taskType.rawValue) \(task.plantName)", 
                                            subtitle: task.notes ?? "Maintenance", 
                                            icon: iconForType(task.taskType), 
                                            color: colorForType(task.taskType), 
                                            isDone: task.isCompleted,
                                            time: task.isCompleted ? nil : task.dueDate.formatted(date: .omitted, time: .shortened)
                                        )
                                        .onTapGesture {
                                            schedulerVM.toggleTask(task)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Garden health
                        VStack(alignment: .leading, spacing: GTSpacing.sm) {
                            Text("Garden health")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)
                            
                            if plantVM.plants.isEmpty {
                                Text("Add plants to see health status.")
                                    .font(GTFont.bodySmall())
                                    .foregroundColor(.gtTextSecondary)
                                    .padding(.vertical, 10)
                            } else {
                                VStack(spacing: GTSpacing.md) {
                                    ForEach(plantVM.plants.prefix(4)) { plant in
                                        GTHealthRow(
                                            name: plant.name, 
                                            progress: plant.healthScore / 100, 
                                            color: healthColor(for: plant.healthScore)
                                        )
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
                case .careGuide(let species):
                    CareGuideView(speciesName: species)
                case .symptomChecker:
                    SymptomCheckerView()
                case .diagnosisResult:
                    DiagnosisResultView()
                case .nearbyExperts:
                    NearbyExpertsMapView()
                case .notifications:
                    NotificationsView()
                case .smartScheduler(let plantId):
                    SmartSchedulerView(plantId: plantId)
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Helper Functions
extension HomeDashboardView {
    private func iconForType(_ type: TaskType) -> String {
        switch type {
        case .water: return "drop.fill"
        case .fertilize: return "shield.fill"
        case .repot: return "leaf.fill"
        case .prune: return "scissors"
        case .inspect: return "magnifyingglass"
        default: return "info.circle.fill"
        }
    }
    
    private func colorForType(_ type: TaskType) -> Color {
        switch type {
        case .water: return .gtWatering
        case .fertilize: return .gtAccentGreen
        case .repot: return .orange
        case .prune: return .gtStatusUrgent
        case .inspect: return .gtDarkGreen
        default: return .gtTextMuted
        }
    }
    
    private func healthColor(for score: Double) -> Color {
        if score < 60 { return .gtStatusUrgent }
        if score < 85 { return .orange }
        return .gtAccentGreen
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
