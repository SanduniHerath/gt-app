import SwiftUI

struct DiagnosisResultView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var diagnoseVM: DiagnoseViewModel
    @State private var selectedTab = 2 // "Diagnose" is index 2

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Pink Header Section
                    ZStack(alignment: .topLeading) {
                        Color.gtDiagnosisPink
                            .frame(height: 320)
                            .ignoresSafeArea(edges: .top)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            // Back Button
                            Button {
                                router.selectedTab = 2
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
                            .padding(.top, 60)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Diagnosis complete")
                                    .font(GTFont.labelMedium())
                                    .foregroundColor(Color.gtDiagnosisText)
                                
                                Text("Nitrogen Deficiency")
                                    .font(GTFont.displayMedium())
                                    .foregroundColor(Color.gtDiagnosisTitle)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // MARK: - Overlapping Plant Card
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            // Plant Icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "F9D5D5"))
                                    .frame(width: 56, height: 56)
                                Text("🌷")
                                    .font(.system(size: 28))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rose Bush – Front garden")
                                    .font(GTFont.labelLarge())
                                    .foregroundColor(.gtTextPrimary)
                                
                                Text("Symptoms: yellow leaves, brown spots, slow growth")
                                    .font(GTFont.bodySmall())
                                    .foregroundColor(.gtTextSecondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gtBorder, lineWidth: 1)
                                )
                                .gtShadow(GTShadow.card)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, -60)
                    
                    // MARK: - Treatment Plan Section
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Treatment plan")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                            .padding(.top, 32)
                        
                        VStack(spacing: 12) {
                            GTTreatmentStepRow(
                                number: 1,
                                title: "Apply nitrogen-rich fertiliser",
                                description: "Use NPK 20-5-10 or blood meal. Apply 2 tablespoon per liter of water.",
                                badgeText: "Do within 2 days",
                                badgeBg: Color.gtBadgeYellowBg,
                                badgeFg: Color.gtBadgeYellowText
                            )
                            
                            GTTreatmentStepRow(
                                number: 2,
                                title: "Adjust watering frequency",
                                description: "Reduce to every 3 days. Overwatering flushes nitrogen from soil",
                                badgeText: "Ongoing",
                                badgeBg: Color.gtBadgeTealBg,
                                badgeFg: Color.gtBadgeTealText
                            )
                            
                            GTTreatmentStepRow(
                                number: 3,
                                title: "Test soil pH",
                                description: "Nitrogen uptake is best at pH 6.0–7.0. Adjust with limit if too acidic",
                                badgeText: "Optional",
                                badgeBg: Color.gtBadgeGreenBg,
                                badgeFg: Color.gtBadgeGreenText
                            )
                            
                            GTTreatmentStepRow(
                                number: 4,
                                title: "Monitor and re-diagnose",
                                description: "Check for improvement after 7 days. If no change, consult an expert",
                                badgeText: "7 days later",
                                badgeBg: Color.gtBadgePurpleBg,
                                badgeFg: Color.gtBadgePurpleText
                            )
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            GTButton(
                                title: "View full care guide",
                                style: .primary,
                                action: {
                                    router.navigate(to: .careGuide)
                                }
                            )
                            
                            GTButton(
                                title: "Book expert",
                                style: .expert,
                                action: {
                                    if let sampleExpert = ExpertModel.samples.first {
                                        router.navigate(to: .bookSession(sampleExpert))
                                    }
                                }
                            )
                        }
                        .padding(.vertical, 32)
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 24)
                    .background(Color.gtTreatmentBg)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Tab Bar
            //GTTabBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .background(Color.gtTreatmentBg.ignoresSafeArea())
    }
}

#Preview {
    DiagnosisResultView()
        .environmentObject(DiagnoseViewModel())
}
