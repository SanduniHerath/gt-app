import SwiftUI

struct GardenAnalyticsView: View {
    @EnvironmentObject var router:      AppRouter
    @EnvironmentObject var plantVM:     PlantViewModel
    @EnvironmentObject var schedulerVM: SchedulerViewModel
    @State private var selectedPeriod = 0

    // ── Computed stats from real data ──────────────────────────────
    private var wateringSessions: Int {
        schedulerVM.tasks.filter { $0.taskType == .water && $0.isCompleted }.count
    }
    private var fertilizerSessions: Int {
        schedulerVM.tasks.filter { $0.taskType == .fertilize && $0.isCompleted }.count
    }
    private var diseasesTreated: Int {
        plantVM.plants.filter { $0.lastDiagnosisName != nil }.count
    }
    private var diagnosedPlants: [PlantModel] {
        plantVM.plants.filter { $0.lastDiagnosisName != nil }
    }
    private var averageHealth: Double {
        guard !plantVM.plants.isEmpty else { return 0 }
        return plantVM.plants.map { $0.healthScore }.reduce(0, +) / Double(plantVM.plants.count)
    }

    // Static streak pattern (historical daily data not yet tracked in Firestore)
    let streakDays = [false, true, true, false, true, false, true, true, false, true, true, true, true, true]

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ─────────────────────────────────────────────
            HStack {
                // ♿ Touch Target: circle is 38pt, expand to 44pt minimum
                Button { router.pop() } label: {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 38, height: 38).gtShadow(GTShadow.card)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gtTextPrimary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("Back")
                .accessibilityHint("Double-tap to go back to the home dashboard")

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

                    // ── Dynamic 3-column stat cards ─────────────────
                    HStack(spacing: GTSpacing.sm) {
                        SmallStatCard(
                            value: "\(wateringSessions)",
                            label: "Watering sessions",
                            color: .gtWatering
                        )
                        SmallStatCard(
                            value: "\(fertilizerSessions)",
                            label: "Fertilizer sessions",
                            color: .gtFertilizer
                        )
                        SmallStatCard(
                            value: "\(diseasesTreated)",
                            label: "Diseases treated",
                            color: .gtStatusUrgent
                        )
                    }

                    // ── Average Garden Health ───────────────────────
                    if !plantVM.plants.isEmpty {
                        VStack(alignment: .leading, spacing: GTSpacing.sm) {
                            Text("Overall garden health")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)

                            HStack(spacing: GTSpacing.md) {
                                // Big health score circle
                                ZStack {
                                    Circle()
                                        .stroke(healthColor(for: averageHealth).opacity(0.15), lineWidth: 10)
                                        .frame(width: 80, height: 80)
                                    Circle()
                                        .trim(from: 0, to: averageHealth / 100)
                                        .stroke(healthColor(for: averageHealth), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 80, height: 80)
                                        .animation(.easeOut(duration: 0.8), value: averageHealth)
                                    Text("\(Int(averageHealth))%")
                                        .font(GTFont.labelLarge())
                                        .foregroundColor(.gtTextPrimary)
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(plantVM.plants.count) plants in your garden")
                                        .font(GTFont.bodyMedium())
                                        .foregroundColor(.gtTextSecondary)
                                    Text(averageHealth >= 85 ? "🌿 Garden is thriving!" : averageHealth >= 65 ? "⚠️ Some plants need care" : "🚨 Urgent attention needed")
                                        .font(GTFont.labelMedium())
                                        .foregroundColor(healthColor(for: averageHealth))
                                }

                                Spacer()
                            }
                            .padding(GTSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: GTRadius.md)
                                    .fill(Color.white)
                                    .gtShadow(GTShadow.card)
                            )
                        }
                    }

                    // ♿ VoiceOver: each streak day dot reads its status
                    GTStreakGrid(days: streakDays)
                        .accessibilityElement(children: .contain)

                    // ── Disease History (Dynamic) ───────────────────
                    VStack(alignment: .leading, spacing: GTSpacing.sm) {
                        Text("Disease history")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)

                        if diagnosedPlants.isEmpty {
                            Text("No diseases diagnosed yet. Your garden is healthy! 🌿")
                                .font(GTFont.bodySmall())
                                .foregroundColor(.gtTextSecondary)
                                .padding(.vertical, 12)
                        } else {
                            VStack(spacing: GTSpacing.md) {
                                ForEach(diagnosedPlants) { plant in
                                    GTHealthRow(
                                        name: "\(plant.name) – \(plant.lastDiagnosisName ?? "")",
                                        progress: plant.healthScore / 100,
                                        color: healthColor(for: plant.healthScore),
                                        countLabel: plant.status == .critical ? "Critical" : "Warning"
                                    )
                                }
                            }
                            .padding(GTSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: GTRadius.md)
                                    .fill(Color.white)
                                    .gtShadow(GTShadow.card)
                            )
                        }
                    }

                    // ── Per-Plant Health Breakdown ──────────────────
                    if !plantVM.plants.isEmpty {
                        VStack(alignment: .leading, spacing: GTSpacing.sm) {
                            Text("Plant health breakdown")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)

                            VStack(spacing: GTSpacing.md) {
                                ForEach(plantVM.plants) { plant in
                                    Button {
                                        router.navigate(to: .plantDetails(plant))
                                    } label: {
                                        GTHealthRow(
                                            name: plant.name,
                                            progress: plant.healthScore / 100,
                                            color: healthColor(for: plant.healthScore)
                                        )
                                    }
                                }
                            }
                            .padding(GTSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: GTRadius.md)
                                    .fill(Color.white)
                                    .gtShadow(GTShadow.card)
                            )
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, GTSpacing.lg)
            }
            .background(Color.gtBackground)
        }
        .navigationBarHidden(true)
    }

    private func healthColor(for score: Double) -> Color {
        if score < 60 { return .gtStatusUrgent }
        if score < 85 { return .orange }
        return .gtAccentGreen
    }
}

// MARK: - SmallStatCard
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
            .environmentObject(PlantViewModel())
            .environmentObject(SchedulerViewModel())
    }
}
