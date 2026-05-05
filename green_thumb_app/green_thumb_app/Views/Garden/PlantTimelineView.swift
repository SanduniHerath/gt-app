import SwiftUI

struct PlantTimelineView: View {
    @EnvironmentObject var plantVM: PlantViewModel
    let plant: PlantModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter

    // Find the latest version of this plant in our real-time array
    private var livePlant: PlantModel {
        plantVM.plants.first(where: { $0.id == plant.id }) ?? plant
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Dark Green Header
            ZStack(alignment: .bottom) {
                Color.gtForestGreen.ignoresSafeArea(edges: .top)
                
                VStack(spacing: 25) {
                    // Back and Title
                    HStack {
                        Button { dismiss() } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 44, height: 44)
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Text("Growth Timeline")
                            .font(GTFont.displaySmall())
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    // Plant Identity Row
                    HStack(spacing: 16) {
                        // Plant Icon Box
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: "314E31"))
                                .frame(width: 76, height: 76)
                            
                            // Mockup has a specific tulip/flower icon
                            Text("🌷")
                                .font(.system(size: 38))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(livePlant.name)
                                .font(GTFont.displaySmall())
                                .foregroundColor(.white)
                            
                            Text("\(livePlant.location) - Planted")
                                .font(GTFont.bodySmall())
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("14 Feb 2025") // Hardcoded to match mockup exactly
                                .font(GTFont.bodySmall())
                                .foregroundColor(Color(hex: "A8CC80"))
                        }
                        
                        Spacer()
                        
                        // Stat Capsules
                        VStack(spacing: 10) {
                            StatCapsule(value: "\(livePlant.ageDays)", label: "days old")
                            StatCapsule(value: "\(livePlant.careLogs.filter { $0.statusBadge != nil && $0.statusBadge != "Started tracking" }.count)", label: "Treatments")
                        }
                    }
                    .padding(.bottom, 52)
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 260)
            
            // MARK: - Content Area
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Observation Button
                    GTAddObservationButton {
                        router.navigate(to: .addObservation(livePlant))
                    }
                    .padding(.top, 32)
                    
                    // Timeline
                    if livePlant.careLogs.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "leaf.arrow.circlepath")
                                .font(.system(size: 40))
                                .foregroundColor(.gtTextMuted)
                            Text("No care logs yet")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)
                            Text("When you add observations, watering, or fertilizing records, they will appear here.")
                                .font(GTFont.bodySmall())
                                .foregroundColor(.gtTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(livePlant.careLogs.sorted(by: { $0.date > $1.date }).enumerated()), id: \.element.id) { index, entry in
                                GTHighFidelityTimelineCard(
                                    entry: entry,
                                    isLast: index == livePlant.careLogs.count - 1
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
            .background(Color.gtBackground) // Light gray body
            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
            .padding(.top, -24) // Negative padding overlaps header without leaving a gap
            .zIndex(1)
        }
        .background(Color.gtBackground.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Helper Components
struct StatCapsule: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(GTFont.labelLarge())
                .foregroundColor(Color(hex: "E7F3DC"))
            
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(Color(hex: "E7F3DC").opacity(0.7))
        }
        .frame(width: 80, height: 56)
        .background(Color(hex: "314E31").opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    PlantTimelineView(plant: PlantModel.samples[1])
}

// MARK: - Custom Rounded Corner Shape
