import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case 0: HomeDashboardView()
                case 1: PlantListView()
                case 2: SymptomCheckerView()
                case 3: ExpertFindView()
                case 4: UserProfileView()
                default: HomeDashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GTTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
        .environmentObject(AuthViewModel())
        .environmentObject(PlantViewModel())
        .environmentObject(DiagnoseViewModel())
        .environmentObject(SchedulerViewModel())
        .environmentObject(ExpertViewModel())
        .environmentObject(CommunityViewModel())
        .environmentObject(NotificationsViewModel())
        .environmentObject(ProfileViewModel())
}

