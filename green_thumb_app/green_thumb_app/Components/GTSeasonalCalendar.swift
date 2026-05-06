import SwiftUI

struct GTSeasonalCalendar: View {
    let data: [String: String]?
    
    init(data: [String: String]? = nil) {
        self.data = data
    }

    struct MonthData: Identifiable {
        let id = UUID()
        let name: String
        let intensity: Int // 1 to 5
    }
    
    let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(0..<12, id: \.self) { index in
                    let monthKey = monthNames[index]
                    let intensityString = data?[monthKey] ?? "every7days"
                    let intensity = intensityValue(for: intensityString)
                    
                    VStack(spacing: 6) {
                        Text(monthKey)
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextSecondary)
                        
                        Circle()
                            .fill(colorForIntensity(intensity))
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(bgColorForIntensity(intensity))
                    )
                }
            }
            
            // Legend
            HStack(spacing: 20) {
                legendItem(color: Color.gtDiagnosisText, label: "Water daily")
                legendItem(color: Color.gtBadgeYellowText, label: "Every 2 days")
                legendItem(color: Color.gtBadgeTealText, label: "Every 5 days")
            }
            .padding(.top, 4)
        }
    }
    
    private func intensityValue(for string: String) -> Int {
        switch string.lowercased() {
        case "daily": return 5
        case "every2days": return 4
        case "every3days": return 3
        case "every5days": return 2
        case "every7days": return 1
        case "every10days": return 0
        case "every14days": return 0
        default: return 1
        }
    }
    
    private func colorForIntensity(_ intensity: Int) -> Color {
        if intensity >= 5 { return Color.gtDiagnosisText }
        if intensity >= 3 { return Color.gtBadgeYellowText }
        return Color.gtBadgeTealText
    }
    
    private func bgColorForIntensity(_ intensity: Int) -> Color {
        if intensity >= 5 { return Color.gtDiagnosisPink }
        if intensity >= 3 { return Color.gtBadgeYellowBg }
        return Color.gtBadgeTealBg
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(GTFont.labelSmall())
                .foregroundColor(.gtTextSecondary)
        }
    }
}

#Preview {
    GTSeasonalCalendar()
        .padding()
}

