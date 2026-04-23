import SwiftUI

struct GardenAnalyticsView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedPeriod = 0
    
    // Mock data for streak: last 14 days
    let streakDays = [false, true, true, false, true, false, true, true, false, true, true, true, true, true]
    
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
                
                Text("Garden Analytics")
                    .font(GTFont.displaySmall())
                    .foregroundColor(.gtTextPrimary)
                    .padding(.leading, GTSpacing.sm)
                
                Spacer()
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.top, GTSpacing.lg)
            .padding(.bottom, GTSpacing.md)
            .background(Color.gtBackground)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.lg) {
                    // Period Toggle
                    GTSegmentedControl(options: ["Week", "Month"], selectedIndex: $selectedPeriod)
                        .padding(.top, GTSpacing.sm)
                    
                    // Main Stats 3-column
                    HStack(spacing: GTSpacing.sm) {
                        SmallStatCard(value: "26", label: "Watering sessions", color: .gtWatering)
                        SmallStatCard(value: "10", label: "Fertilizer sessions", color: .gtFertilizer)
                        SmallStatCard(value: "2", label: "Diseases treated", color: .gtStatusUrgent)
                    }
                    
                    // Watering Streak
                    GTStreakGrid(days: streakDays)
                    
                    // Disease History
                    VStack(alignment: .leading, spacing: GTSpacing.sm) {
                        Text("Disease history this season")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        
                        VStack(spacing: GTSpacing.md) {
                            GTHealthRow(name: "Leaf Yellowing", progress: 0.8, color: Color(red: 0.9, green: 0.4, blue: 0.3), countLabel: "4×")
                            GTHealthRow(name: "Root rot (minor)", progress: 0.5, color: Color(red: 1.0, green: 0.7, blue: 0.2), countLabel: "2×")
                            GTHealthRow(name: "Aphid infestation", progress: 0.15, color: Color(red: 0.6, green: 0.5, blue: 0.9), countLabel: "1×")
                        }
                        .padding(GTSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: GTRadius.md)
                                .fill(Color.white)
                                .gtShadow(GTShadow.card)
                        )
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, GTSpacing.lg)
            }
            .background(Color.gtBackground)
        }
        .navigationBarHidden(true)
    }
}

private struct SmallStatCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(GTFont.displayMedium())
                .foregroundColor(color)
            Text(label)
                .font(GTFont.labelSmall())
                .foregroundColor(.gtTextMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding(GTSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(Color.white)
                .gtShadow(GTShadow.card)
        )
    }
}

#Preview {
    NavigationStack {
        GardenAnalyticsView()
            .environmentObject(AppRouter())
    }
}

