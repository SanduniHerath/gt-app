import SwiftUI

// MARK: - Expert Find
struct ExpertFindView: View {
    @EnvironmentObject var expertVM: ExpertViewModel
    @EnvironmentObject var router: AppRouter
    @State private var showProfile: ExpertModel? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: { router.pop() }) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 44, height: 44)
                            Image(systemName: "arrow.left")
                                .foregroundColor(.gtForestGreen)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Find an Expert")
                            .font(GTFont.displayMedium())
                            .foregroundColor(.white)
                        Text("Connect with certified agricultural officers")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtAccentGreen)
                    }
                    .padding(.leading, GTSpacing.sm)
                    
                    Spacer()
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.top, 60)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                    TextField("", text: $expertVM.searchText, prompt:
                                Text("Search by name or speciality...")
                                    .foregroundColor(.white.opacity(0.6))
                    )
                    .font(GTFont.bodyMedium())
                    .foregroundColor(.white)
                }
                .padding(.horizontal, GTSpacing.md)
                .padding(.vertical, GTSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: GTRadius.md)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .background(Color.white.opacity(0.1))
                )
                .padding(.horizontal, GTSpacing.lg)
                .padding(.top, GTSpacing.lg)
                .padding(.bottom, GTSpacing.lg)
            }
            .background(Color.gtForestGreen)
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GTSpacing.md) {
                    filterChip(title: "All")
                    filterChip(title: "Disease")
                    filterChip(title: "Greenhouse")
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.vertical, GTSpacing.md)
            }
            .background(Color(hex: "F2F2F2"))

            // Expert List with Footer
            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.md) {
                    ForEach(expertVM.filteredExperts) { expert in
                        GTExpertCard(expert: expert)
                            .onTapGesture { showProfile = expert }
                    }
                    
                    // Fixed Footer Button moved inside ScrollView
                    GTButton(title: "Find nearby agricultural officers", style: .primary) {
                        // Nearby action
                    }
                    .padding(.top, GTSpacing.md)
                    .padding(.bottom, GTSpacing.lg)
                }
                .padding(GTSpacing.lg)
            }
            .background(Color(hex: "F2F2F2"))
        }
        .ignoresSafeArea(edges: .top)
        .navigationDestination(item: $showProfile) { expert in
            ExpertProfileView(expert: expert)
        }
    }

    private func filterChip(title: String) -> some View {
        Button(action: {
            withAnimation { expertVM.selectedFilter = title }
        }) {
            Text(title)
                .font(GTFont.labelMedium())
                .foregroundColor(expertVM.selectedFilter == title ? .white : .gtTextSecondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(expertVM.selectedFilter == title ? Color.gtForestGreen : .white)
                )
        }
    }
}

// MARK: - Nearby Map stubs
struct NearbyExpertsMapView: View {
    var body: some View { Text("Nearby Experts Map").font(GTFont.displaySmall()) }
}

#Preview { ExpertFindView().environmentObject(ExpertViewModel()).environmentObject(AppRouter())
        .environmentObject(AuthViewModel()).environmentObject(PlantViewModel())
        .environmentObject(DiagnoseViewModel()).environmentObject(SchedulerViewModel())
        .environmentObject(CommunityViewModel()).environmentObject(NotificationsViewModel())
        .environmentObject(ProfileViewModel()) }
