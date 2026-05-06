import SwiftUI

struct CareGuideView: View {
    let speciesName: String
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = CareGuideViewModel()
    @State private var selectedTab = 0 
    let tabOptions = ["Watering", "Care", "Fertiliser"]

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
            
            GTSegmentedTab(options: tabOptions, selectedIndex: $selectedTab)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading care guide...")
                    .tint(.gtDarkGreen)
                Spacer()
            } else if let guide = viewModel.careGuide {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            if selectedTab == 0 {
                                WateringTabContent(guide: guide)
                            } else if selectedTab == 1 {
                                CareTabContent(guide: guide)
                            } else {
                                FertiliserTabContent(guide: guide)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
                .background(Color.gtTreatmentBg)
            } else {
                Spacer()
                Text(viewModel.errorMessage ?? "No care guide found for \(speciesName)")
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
                
                Text(guide.watering.schedule)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineSpacing(2)
                
                HStack(spacing: 12) {
                    GTStatusBadge(
                        text: guide.watering.amount,
                        backgroundColor: Color.gtBadgeTealBg,
                        foregroundColor: Color.gtBadgeTealText
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gtBorder, lineWidth: 1.5))
            
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
                
                GTSeasonalCalendar(data: guide.watering.seasonalCalendar)
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
            
            // Tips
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gtBadgeTealBg)
                            .frame(width: 48, height: 48)
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color.gtBadgeTealText)
                            .font(.system(size: 20))
                    }
                    Text("Watering tips")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    let tips = guide.watering.tips
                    ForEach(0..<tips.count, id: \.self) { index in
                        WateringTipRow(text: tips[index])
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

struct CareTabContent: View {
    let guide: CareGuide
    
    var body: some View {
        VStack(spacing: 20) {
            // Sunlight
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                    }
                    Text("Sunlight")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                }
                Text(guide.sunlight.requirement)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    let tips = guide.sunlight.tips
                    ForEach(0..<tips.count, id: \.self) { index in
                        WateringTipRow(text: tips[index])
                    }
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gtBorder, lineWidth: 1.5))
            
            // Soil
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brown.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.brown)
                            .font(.system(size: 20))
                    }
                    Text("Soil & Environment")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                }
                Text(guide.soil.type)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    let tips = guide.soil.tips
                    ForEach(0..<tips.count, id: \.self) { index in
                        WateringTipRow(text: tips[index])
                    }
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gtBorder, lineWidth: 1.5))
            
            // Pruning
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gtDarkGreen.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: "scissors")
                            .foregroundColor(Color.gtDarkGreen)
                            .font(.system(size: 20))
                    }
                    Text("Pruning")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                }
                Text(guide.pruning.frequency)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    let tips = guide.pruning.tips
                    ForEach(0..<tips.count, id: \.self) { index in
                        WateringTipRow(text: tips[index])
                    }
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gtBorder, lineWidth: 1.5))
        }
    }
}

struct FertiliserTabContent: View {
    let guide: CareGuide
    
    var body: some View {
        let frequencyRaw = guide.fertiliser.frequency
        // Extract the number from the string (e.g., "14" from "Every 14 days...")
        let number = frequencyRaw.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }.first ?? "14"
        let shortFrequency = "\(number)d"
        
        GTFertiliserCard(
            product: guide.fertiliser.product,
            frequency: shortFrequency,
            instructions: "\(frequencyRaw). \(guide.fertiliser.tips.first ?? "")",
            tips: Array(guide.fertiliser.tips.dropFirst())
        )
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
