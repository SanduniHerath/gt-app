import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch router.selectedTab {
                case 0: HomeDashboardView()
                case 1: PlantListView()
                case 2: SymptomCheckerView()
                case 3: ExpertFindView()
                case 4: UserProfileView()
                default: HomeDashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GTTabBar(selectedTab: $router.selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: router.selectedTab) { _ in
            router.popToRoot()
        }
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

