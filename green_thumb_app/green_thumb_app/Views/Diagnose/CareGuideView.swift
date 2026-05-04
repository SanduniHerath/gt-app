import SwiftUI

struct CareGuideView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedTab = 0 // 0: Watering, 1: Fertiliser
    @State private var currentAppTab = 2 // Diagnose tab is active in the screenshot

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Dark Green Header
            ZStack(alignment: .topLeading) {
                Color.gtForestGreen
                    .frame(height: 170)
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Back and Status
                    HStack(spacing: 12) {
                        Button {
                            router.pop()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
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
                    
                    Text("Rose Bush")
                        .font(GTFont.displayLarge())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
            }
            
            // MARK: - Underlined Tabs
            GTSegmentedTab(options: ["Watering", "Fertiliser"], selectedIndex: $selectedTab)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if selectedTab == 0 {
                        WateringTabContent()
                    } else {
                        FertiliserTabContent()
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(24)
                .background(Color.gtTreatmentBg)
            }
            .background(Color.gtTreatmentBg)
            
            
        }
        .navigationBarHidden(true)
        .background(Color.gtForestGreen.ignoresSafeArea())
    }
}

// MARK: - Subviews

struct WateringTabContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Watering Schedule Card
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
                
                Text("Water deeply every 2–3 days in summer and every 5–7 days in cooler months. Aim for 300ml per session")
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineSpacing(2)
                
                HStack(spacing: 12) {
                    GTStatusBadge(
                        text: "300ml/session",
                        backgroundColor: Color.gtBadgeTealBg,
                        foregroundColor: Color.gtBadgeTealText
                    )
                    
                    GTStatusBadge(
                        text: "Morning preferred",
                        backgroundColor: Color.gtBadgeGreenBg,
                        foregroundColor: Color.gtBadgeGreenText
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.gtBorder, lineWidth: 1.5)
            )
            
            // MARK: - Seasonal Calendar Card
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gtBadgeYellowBg)
                            .frame(width: 48, height: 48)
                        Image(systemName: "calendar")
                            .foregroundColor(Color.gtBadgeYellowText)
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Seasonal calendar")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text("Watering frequency by month")
                            .font(GTFont.bodySmall())
                            .foregroundColor(.gtTextSecondary)
                    }
                }
                
                GTSeasonalCalendar()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.gtBorder, lineWidth: 1.5)
            )
            
            // MARK: - Watering Tips Card
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
                    WateringTipRow(text: "Always check soil moisture before watering – insert finger 2cm deep.")
                    WateringTipRow(text: "Use room-temperature water. Cold water can shock the roots.")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.gtBorder, lineWidth: 1.5)
            )
            
            // MARK: - Fertiliser Banner
            FertiliserBanner()
        }
    }
}

struct FertiliserTabContent: View {
    var body: some View {
        VStack(spacing: 20) {
            GTSafetyCard(
                title: "Safety first",
                points: [
                    "Wear gloves when handling chemicals.",
                    "Keep away from children and pets.",
                    "Never exceed recommended dosage"
                ]
            )
            
            GTFertiliserCard()
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
    CareGuideView()
}
