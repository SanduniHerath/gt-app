import SwiftUI

// MARK: - Plant List
struct PlantListView: View {
    @EnvironmentObject var plantVM: PlantViewModel
    @EnvironmentObject var router: AppRouter
    @State private var selectedFilter = "All"
    
    let filters = ["All", "Outdoor", "Indoor"]

    var filtered: [PlantModel] {
        var result = plantVM.filteredPlants
        if selectedFilter == "Outdoor" {
            result = result.filter { $0.isOutdoor }
        } else if selectedFilter == "Indoor" {
            result = result.filter { !$0.isOutdoor }
        }
        return result
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack(alignment: .bottomTrailing) {
                // Background
                Color(red: 0.95, green: 0.95, blue: 0.95).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text("My Garden")
                            .font(GTFont.displayMedium())
                            .foregroundColor(.white)
                            .padding(.top, 80) // Status bar padding

                        // Search Bar
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 18, weight: .medium))
                            
                            TextField("", text: $plantVM.searchText, prompt:
                                Text("Search plants...").foregroundColor(.white.opacity(0.5))
                            )
                            .font(GTFont.bodyMedium())
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                        )
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                    .background(Color.gtForestGreen)

                    // Selection Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: {
                                    withAnimation(.interactiveSpring()) {
                                        selectedFilter = filter
                                    }
                                }) {
                                    Text(filter)
                                        .font(GTFont.labelMedium())
                                        .foregroundColor(selectedFilter == filter ? .white : Color.gtTextSecondary)
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedFilter == filter ? Color.gtDarkGreen : .white)
                                        )
                                        .gtShadow(selectedFilter == filter ? GTShadow.button : GTShadow.card)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    }

                    // Grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(filtered) { plant in
                                GTPlantGridCard(plant: plant) {
                                    router.navigate(to: .plantDetails(plant))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100) // Space for TabBar/FAB
                    }
                }

                // FAB
                Button(action: {
                    router.navigate(to: .addPlant)
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gtDarkGreen)
                            .frame(width: 68, height: 68)
                            .gtShadow(GTShadow.button)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 30)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .plantDetails(let plant):
                    PlantDetailsView(plant: plant)
                case .growthTimeline(let plant):
                    PlantTimelineView(plant: plant)
                case .addObservation(let plant):
                    AddObservationView(plant: plant)
                case .addPlant:
                    AddPlantView()
                case .careGuide(let species):
                    CareGuideView(speciesName: species)
                case .smartScheduler(let plantId):
                    SmartSchedulerView(plantId: plantId)
                case .diagnosisResult:
                    DiagnosisResultView()
                case .notifications:
                    NotificationsView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview { PlantListView().environmentObject(PlantViewModel()).environmentObject(AppRouter())
        .environmentObject(AuthViewModel()).environmentObject(DiagnoseViewModel())
        .environmentObject(SchedulerViewModel()).environmentObject(ExpertViewModel())
        .environmentObject(CommunityViewModel()).environmentObject(NotificationsViewModel())
        .environmentObject(ProfileViewModel()) }
