import SwiftUI

struct PlantDetailsView: View {
    let plant: PlantModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @State private var selectedTab = 0 // 0: Notes, 1: Timeline

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Fixed Header
            ZStack(alignment: .bottom) {
                Color.gtForestGreen.ignoresSafeArea(edges: .top)
                
                HStack {
                    Button { 
                        router.selectedTab = 1
                        router.popToRoot()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .gtShadow(GTShadow.card)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }
            .frame(height: 110)
            
            // MARK: - Scrollable Area
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Image
                    ZStack(alignment: .topLeading) {
                        ZStack {
                            Rectangle()
                                .fill(Color.gtPaleGreen.opacity(0.15))
                            Text(plant.name.contains("Rose") ? "🌹" : "🪴")
                                .font(.system(size: 140))
                                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        }
                        .aspectRatio(1.5, contentMode: .fit)
                        
                        Text("\(Int(plant.healthScore))%")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtStatusUrgent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Capsule())
                            .padding(20)
                            .gtShadow(GTShadow.card)
                    }

                    VStack(alignment: .leading, spacing: 28) {
                        // Identity
                        VStack(alignment: .leading, spacing: 12) {
                            Text(plant.name)
                                .font(GTFont.displayMedium())
                                .foregroundColor(.gtTextPrimary)
                            
                            HStack(spacing: 14) {
                                Text(plant.status == .warning ? "Needs care" : "Healthy")
                                    .font(GTFont.labelSmall())
                                    .foregroundColor(plant.status == .warning ? .gtStatusUrgent : .gtDarkGreen)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(plant.status == .warning ? Color.gtStatusUrgent.opacity(0.1) : Color.gtPaleGreen)
                                    .clipShape(Capsule())
                                
                                Text(plant.isOutdoor ? "Outdoor" : "Indoor")
                                    .font(GTFont.labelSmall())
                                    .foregroundColor(.gtDarkGreen)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.gtPaleGreen)
                                    .clipShape(Capsule())
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gtTextMuted)
                                    Text(plant.location)
                                        .font(GTFont.bodyMedium())
                                        .foregroundColor(.gtTextMuted)
                                }
                            }
                        }
                        .padding(.top, 24)

                        // Info Grid
                        HStack(spacing: 10) {
                            GTDetailInfoCard(icon: "drop.fill", value: plant.dailyWater, label: "Daily water", iconColor: .gtWatering)
                            GTDetailInfoCard(icon: "sun.max.fill", value: plant.sunlight, label: "Sunlight", iconColor: .orange)
                            GTDetailInfoCard(icon: "square.grid.2x2", value: plant.soilType, label: "Soil type", iconColor: .gtDarkGreen)
                            GTDetailInfoCard(icon: "calendar", value: "\(plant.ageDays) days", label: "Age", iconColor: .purple)
                        }

                        // Action Grid
                        HStack(spacing: 0) {
                            GTDetailActionButton(icon: "drop.fill", label: "Water", color: .gtWatering) {
                                router.navigate(to: .careGuide(plant.species))
                            }
                            GTDetailActionButton(icon: "exclamationmark.triangle", label: "Diagnose", color: .gtStatusUrgent, hasAlert: true) {
                                router.navigate(to: .diagnosisResult)
                            }
                            GTDetailActionButton(icon: "book", label: "Care guide", color: .gtDarkGreen) {
                                router.navigate(to: .careGuide(plant.species))
                            }
                            GTDetailActionButton(icon: "calendar.badge.clock", label: "Schedule", color: .orange) {
                                router.navigate(to: .smartScheduler)
                            }
                        }
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .gtShadow(GTShadow.card)
                        )

                        // Tabbed Section
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Button { withAnimation { selectedTab = 0 } } label: {
                                    VStack(spacing: 14) {
                                        Text("Notes")
                                            .font(GTFont.displaySmall())
                                            .foregroundColor(selectedTab == 0 ? .gtTextPrimary : .gtTextMuted)
                                        Rectangle()
                                            .fill(selectedTab == 0 ? Color.gtDarkGreen : Color.clear)
                                            .frame(height: 5)
                                            .frame(maxWidth: 90)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                Button {
                                    router.navigate(to: .growthTimeline(plant))
                                } label: {
                                    VStack(spacing: 14) {
                                        Text("Timeline")
                                            .font(GTFont.displaySmall())
                                            .foregroundColor(selectedTab == 1 ? .gtTextPrimary : .gtTextMuted)
                                        Rectangle()
                                            .fill(selectedTab == 1 ? Color.gtDarkGreen : Color.clear)
                                            .frame(height: 5)
                                            .frame(maxWidth: 90)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .background(Color(red: 0.88, green: 0.90, blue: 0.88).opacity(0.5))
                            
                            Rectangle()
                                .fill(Color.gtSeparator.opacity(0.4))
                                .frame(height: 1)
                            
                            if selectedTab == 0 {
                                VStack(spacing: 0) {
                                    GTNoteEntry(dotColor: .orange, content: "Noticed yellowing on lower leaves. Maybe nitrogen deficiency or overwatering. Reduced watering to every 2 days", timestamp: "Today 8.30 AM")
                                    Divider()
                                    GTNoteEntry(dotColor: .gtAccentGreen, content: "Two new buds forming on the east-facing stem. Growth looking good after last week's rain", timestamp: "3 days ago 9.00 AM")
                                    Divider()
                                    GTNoteEntry(dotColor: .gtWatering, content: "Watered 300ml. Noticed new lateral shoot emerging from second node - healthy sign", timestamp: "4 days ago 7.15 AM")
                                }
                            } else {
                                // Growth Timeline Integration
                                Button(action: {
                                    router.navigate(to: .growthTimeline(plant))
                                }) {
                                    VStack(spacing: 20) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.gtPaleGreen)
                                                .frame(width: 80, height: 80)
                                            Image(systemName: "chart.bar.doc.horizontal.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.gtDarkGreen)
                                        }
                                        
                                        VStack(spacing: 8) {
                                            Text("Explore Growth Timeline")
                                                .font(GTFont.displaySmall())
                                                .foregroundColor(.gtTextPrimary)
                                            
                                            Text("See your Rose Bush journey since 14 Feb 2025")
                                                .font(GTFont.bodyMedium())
                                                .foregroundColor(.gtTextSecondary)
                                        }
                                        
                                        HStack {
                                            Text("View Full History")
                                                .font(GTFont.labelMedium())
                                            Image(systemName: "chevron.right")
                                        }
                                        .foregroundColor(.gtDarkGreen)
                                        .padding(.vertical, 8)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.white)
                                            .gtShadow(GTShadow.card)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(Color.gtBorder, lineWidth: 1)
                                            )
                                    )
                                }
                                .padding(.top, 24)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    
                    // Final Spacer
                    Spacer(minLength: 150)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        PlantDetailsView(plant: PlantModel.samples[1])
    }
    .environmentObject(PlantViewModel())
    .environmentObject(AppRouter())
    .environmentObject(AuthViewModel())
    .environmentObject(DiagnoseViewModel())
    .environmentObject(SchedulerViewModel())
    .environmentObject(ExpertViewModel())
    .environmentObject(CommunityViewModel())
    .environmentObject(NotificationsViewModel())
    .environmentObject(ProfileViewModel())
}
