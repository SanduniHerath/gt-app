import SwiftUI

struct GTTreatmentStepRow: View {
    let number: Int
    let title: String
    let description: String
    let badgeText: String?
    let badgeBg: Color
    let badgeFg: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number Circle
            ZStack {
                Circle()
                    .fill(Color.gtBadgeGreenText)
                    .frame(width: 32, height: 32)
                Text("\(number)")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                
                Text(description)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineSpacing(2)
                
                if let badgeText = badgeText {
                    GTStatusBadge(
                        text: badgeText,
                        backgroundColor: badgeBg,
                        foregroundColor: badgeFg,
                        font: GTFont.labelSmall(),
                        horizontalPadding: 12,
                        verticalPadding: 6
                    )
                    .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
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
    }
    .padding()
}
