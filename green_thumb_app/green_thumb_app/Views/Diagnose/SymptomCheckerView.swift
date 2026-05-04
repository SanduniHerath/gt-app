import SwiftUI

struct SymptomCheckerView: View {
    @EnvironmentObject var diagnoseVM: DiagnoseViewModel
    @EnvironmentObject var plantVM: PlantViewModel
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss
    @State private var showResult = false
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                // MARK: - Dark Green Header
                ZStack(alignment: .bottom) {
                    Color.gtForestGreen.ignoresSafeArea(edges: .top)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Back and Title
                        HStack (spacing: 25){
                            Button {
                                if let plant = diagnoseVM.selectedPlant {
                                    router.navigate(to: .plantDetails(plant))
                                } else {
                                    router.selectedTab = 1
                                }
                            } label: {
                                ZStack {
                                    Circle().fill(Color.white).frame(width: 44, height: 44)
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Text("Symptom Checker")
                                .font(GTFont.displaySmall())
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        Text("Describe what you are seeing - our service will diagnose your plant and suggest treatment.")
                            .font(GTFont.bodySmall())
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                        
                        // Selected Plant Selection Menu
                        Menu {
                            ForEach(plantVM.plants) { plant in
                                Button {
                                    diagnoseVM.selectedPlant = plant
                                } label: {
                                    Label(plant.name, systemImage: "leaf")
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gtDarkGreen)
                                        .frame(width: 48, height: 48)
                                    Text("🌷") // In a real app, this might come from plant icons
                                        .font(.system(size: 24))
                                }
                                
                                Text(diagnoseVM.selectedPlant?.name ?? "Select Plant")
                                    .font(GTFont.labelLarge())
                                    .foregroundColor(.white)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Spacer()
                                
                                Text("Change")
                                    .font(GTFont.labelSmall())
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                        }
                        .padding(.bottom, 40) // Space for the overlapping content
                    }
                    .padding(.horizontal, 24)
                }
                .frame(height: 300)
                
                // MARK: - Content Area
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // Describe Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gtDarkGreen, lineWidth: 1.5)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gtDarkGreen)
                                }
                                Text("Describe what you're seeing")
                                    .font(GTFont.labelLarge())
                                    .foregroundColor(.gtTextPrimary)
                            }
                            
                            GTTextArea(
                                label: "",
                                placeholder: "e.g. Lower leaves turning yellow with brown edges, soft stem near base...",
                                text: $diagnoseVM.symptomText
                            )
                        }
                        
                        // Symptoms Tag Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Select matching symptoms")
                                .font(GTFont.labelMedium())
                                .foregroundColor(.gtTextSecondary)
                            
                            FlowLayout(spacing: 10) {
                                ForEach(diagnoseVM.commonSymptoms, id: \.self) { symptom in
                                    SymptomTag(
                                        title: symptom,
                                        isSelected: diagnoseVM.selectedSymptoms.contains(symptom),
                                        action: { diagnoseVM.toggleSymptom(symptom) }
                                    )
                                }
                            }
                        }
                        
                        // Severity Section
                        VStack(alignment: .leading, spacing: 14) {
                            GTSeverityCard(value: $diagnoseVM.severity)
                        }
                        
                        // Affected Parts Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Select matching symptoms") // As per mockup
                                .font(GTFont.labelMedium())
                                .foregroundColor(.gtTextSecondary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(diagnoseVM.affectedParts, id: \.self) { part in
                                    AffectedPartCard(
                                        part: part,
                                        isSelected: diagnoseVM.selectedParts.contains(part),
                                        action: { diagnoseVM.togglePart(part) }
                                    )
                                }
                            }
                        }
                        
                        // Analyse Button
                        GTButton(
                            title: "Analyse symptoms",
                            style: .primary,
                            action: {
                                diagnoseVM.analyze()
                                router.navigate(to: .diagnosisResult)
                            }
                        )
                        .padding(.top, 10)
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .background(Color.gtBackground)
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .padding(.top, -24)
                }
                .background(Color.gtBackground)
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .diagnosisResult:
                    DiagnosisResultView()
                case .careGuide:
                    CareGuideView()
                case .bookSession(let expert):
                    ExpertBookSessionView(expert: expert)
                case .notifications:
                    NotificationsView()
                case .plantDetails(let plant):
                    PlantDetailsView(plant: plant)
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Subviews

struct SymptomTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GTFont.labelSmall())
                .foregroundColor(isSelected ? tagContentColor : .gtTextSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? tagBgColor : Color.white)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? tagContentColor : Color.gtBorder, lineWidth: 1.2)
                        )
                )
        }
    }
    
    private var tagBgColor: Color {
        if title == "Yellow leaves" || title == "Brown spots" { return Color.gtStatusUrgent.opacity(0.1) }
        if title == "Wilting" { return Color.orange.opacity(0.1) }
        if title == "Slow growth" { return Color.gtAccentGreen.opacity(0.1) }
        return Color.gtPaleGreen
    }
    
    private var tagContentColor: Color {
        if title == "Yellow leaves" || title == "Brown spots" { return Color.gtStatusUrgent }
        if title == "Wilting" { return Color.orange }
        if title == "Slow growth" { return Color.gtDarkGreen }
        return Color.gtDarkGreen
    }
}

struct GTSeverityCard: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Severity level")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                Spacer()
                Text(severityLabel)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Slider(value: $value, in: 0...1, step: 0.5)
                    .tint(.orange)
                
                HStack {
                    Text("Mild").font(GTFont.labelSmall()).foregroundColor(.gtTextMuted)
                    Spacer()
                    Text("Moderate").font(GTFont.labelSmall()).foregroundColor(.gtTextMuted)
                    Spacer()
                    Text("Severe").font(GTFont.labelSmall()).foregroundColor(.gtTextMuted)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gtBorder, lineWidth: 1.5)
                .background(Color.white)
        )
    }
    
    private var severityLabel: String {
        if value < 0.25 { return "Mild" }
        if value < 0.75 { return "Moderate" }
        return "Severe"
    }
}

struct AffectedPartCard: View {
    let part: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .gtDarkGreen : .gtTextMuted)
                
                Text(part)
                    .font(GTFont.labelSmall())
                    .foregroundColor(isSelected ? .gtDarkGreen : .gtTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.gtPaleGreen : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.gtDarkGreen : Color.gtBorder, lineWidth: 1.2)
                    )
            )
        }
    }
    
    private var iconName: String {
        switch part {
        case "Leaves": return "shield"
        case "Stems": return "leaf.fill"
        case "Roots": return "square.grid.2x2"
        case "Buds": return "lightbulb"
        case "Whole": return "shield"
        case "Fruit": return "shield"
        default: return "leaf"
        }
    }
}


#Preview {
    SymptomCheckerView()
        .environmentObject(DiagnoseViewModel())
        .environmentObject(PlantViewModel())
        .environmentObject(AppRouter())
}




