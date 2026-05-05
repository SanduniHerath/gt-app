import SwiftUI

struct CareGuideView: View {
    let speciesName: String
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = CareGuideViewModel()
    @State private var selectedTab = 0 

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Dark Green Header
            ZStack(alignment: .topLeading) {
                Color.gtForestGreen
                    .frame(height: 170)
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Button {
                            router.pop()
                        } label: {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 44, height: 44)
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Text("Care guide")
                            .font(GTFont.labelLarge())
                            .foregroundColor(Color.gtAccentGreen)
                    }
                    .padding(.top, 20)
                    
                    Text(speciesName)
                        .font(GTFont.displayLarge())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
            }
            
            GTSegmentedTab(options: ["Watering", "Fertiliser"], selectedIndex: $selectedTab)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading care guide...")
                    .tint(.gtDarkGreen)
                Spacer()
            } else if let guide = viewModel.careGuide {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            WateringTabContent(guide: guide)
                        } else {
                            FertiliserTabContent(guide: guide)
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                    .background(Color.gtTreatmentBg)
                }
            } else {
                Spacer()
                Text(viewModel.errorMessage ?? "Could not load care guide")
                    .foregroundColor(.gtTextSecondary)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .background(Color.gtForestGreen.ignoresSafeArea())
        .onAppear {
            viewModel.fetchCareGuide(for: speciesName)
            viewModel.seedCareGuides() // Uncomment once to seed initial data
        }
    }
}

// MARK: - Subviews

struct WateringTabContent: View {
    let guide: CareGuide
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gtBadgeTealBg)
                            .frame(width: 48, height: 48)
                        Image(systemName: "drop.fill")
                            .foregroundColor(Color.gtBadgeTealText)
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Watering schedule")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text("Based on season & climate")
                            .font(GTFont.bodySmall())
                            .foregroundColor(.gtTextSecondary)
                    }
                }
                
                Text(guide.wateringSchedule)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineSpacing(2)
                
                HStack(spacing: 12) {
                    GTStatusBadge(
                        text: guide.wateringAmount,
                        backgroundColor: Color.gtBadgeTealBg,
                        foregroundColor: Color.gtBadgeTealText
                    )
                    
                    GTStatusBadge(
                        text: "Check soil first",
                        backgroundColor: Color.gtBadgeGreenBg,
                        foregroundColor: Color.gtBadgeGreenText
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gtBorder, lineWidth: 1.5))
            
            // Tips
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gtBadgeTealBg)
                            .frame(width: 48, height: 48)
                        Image(systemName: "drop.fill")
                            .foregroundColor(Color.gtBadgeTealText)
                            .font(.system(size: 20))
                    }
                    Text("Watering tips")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(guide.wateringTips, id: \.self) { tip in
                        WateringTipRow(text: tip)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gtBorder, lineWidth: 1.5))
        }
    }
}

struct FertiliserTabContent: View {
    let guide: CareGuide
    
    var body: some View {
        VStack(spacing: 20) {
            GTSafetyCard(
                title: "Safety first",
                points: guide.safetyTips
            )
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Fertilizer Guide")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                
                Text(guide.fertilizerInfo)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                
                GTStatusBadge(
                    text: guide.fertilizerFrequency,
                    backgroundColor: Color.gtBadgeYellowBg,
                    foregroundColor: Color.gtBadgeYellowText
                )
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gtBorder, lineWidth: 1.5))
        }
    }
}

struct WateringTipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gtAccentGreen)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            Text(text)
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
                .lineSpacing(2)
        }
    }
}

struct FertiliserBanner: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fertiliser & chemicals")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                Text("Safe dosage & application guide")
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("View")
                    .font(GTFont.labelLarge())
                Image(systemName: "arrow.right")
            }
            .foregroundColor(Color.gtDiagnosisTitle)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "EADECA")) // Tan background
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gtBadgeYellowText.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    CareGuideView(speciesName: "Rose Bush")
        .environmentObject(AppRouter())
}
