import SwiftUI

struct GTSeasonalCalendar: View {
    struct MonthData: Identifiable {
        let id = UUID()
        let name: String
        let dotColor: Color
        let bgColor: Color
    }
    
    let months: [MonthData] = [
        MonthData(name: "Jan", dotColor: Color.gtBadgeTealText,   bgColor: Color.gtBadgeTealBg),
        MonthData(name: "Feb", dotColor: Color.gtBadgeTealText,   bgColor: Color.gtBadgeTealBg),
        MonthData(name: "Mar", dotColor: Color.gtBadgeYellowText, bgColor: Color.gtBadgeYellowBg),
        MonthData(name: "Apr", dotColor: Color.gtBadgeGreenText,  bgColor: Color.gtBadgeGreenBg),
        MonthData(name: "May", dotColor: Color.gtDarkGreen,      bgColor: Color.gtBadgeGreenBg),
        MonthData(name: "Jun", dotColor: Color.gtDiagnosisText,  bgColor: Color.gtDiagnosisPink),
        MonthData(name: "Jul", dotColor: Color.gtDiagnosisText,  bgColor: Color.gtDiagnosisPink),
        MonthData(name: "Aug", dotColor: Color.gtDiagnosisText,  bgColor: Color.gtDiagnosisPink),
        MonthData(name: "Sep", dotColor: Color.gtBadgeYellowText, bgColor: Color.gtBadgeYellowBg),
        MonthData(name: "Oct", dotColor: Color.gtBadgeGreenText,  bgColor: Color.gtBadgeGreenBg),
        MonthData(name: "Nov", dotColor: Color.gtBadgeTealText,   bgColor: Color.gtBadgeTealBg),
        MonthData(name: "Dec", dotColor: Color.gtBadgeTealText,   bgColor: Color.gtBadgeTealBg)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(months) { month in
                    VStack(spacing: 6) {
                        Text(month.name)
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextSecondary)
                        
                        Circle()
                            .fill(month.dotColor)
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(month.bgColor)
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

