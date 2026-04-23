import SwiftUI

struct GTFertiliserCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header Section
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gtBadgeGreenBg)
                        .frame(width: 56, height: 56)
                    Image(systemName: "shield.fill")
                        .foregroundColor(Color.gtBadgeGreenText)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("NPK 20-5-10")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                    Text("Fertiliser")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nitrogen-rich")
                        Text("Granular")
                    }
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                }
                
                Spacer()
                
                Text("Recommended")
                    .font(GTFont.labelSmall())
                    .foregroundColor(Color.gtBadgeGreenText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.gtBadgeGreenBg))
            }
            
            Divider()
                .background(Color.gtBorder.opacity(0.5))
            
            // Stats Section
            HStack(spacing: 12) {
                statItem(title: "2 tbsp", subtitle: "Per liter", color: Color.gtBadgeGreenText, bg: Color.gtBadgeGreenBg)
                statItem(title: "14 days", subtitle: "Frequency", color: Color.gtBadgeYellowText, bg: Color.gtBadgeYellowBg)
                statItem(title: "Soil", subtitle: "Application", color: Color.gtBadgeTealText, bg: Color.gtBadgeTealBg)
            }
            
            // Instruction
            Text("How to apply: Dissolve 2 tablespoons in 1 liter of water. Apply directly to soil at the base of the plant. Avoid contact with leaves. Water normally after application.")
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
                .lineSpacing(4)
            
            // Tags
            HStack(spacing: 10) {
                tagItem(text: "Safe for roses", bg: Color.gtBadgeGreenBg, fg: Color.gtBadgeGreenText)
                tagItem(text: "Wear gloves", bg: Color.gtBadgeYellowBg, fg: Color.gtBadgeYellowText)
                tagItem(text: "Avoid rain day", bg: Color.gtDiagnosisPink, fg: Color.gtDiagnosisText)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .gtShadow(GTShadow.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gtBorder, lineWidth: 1.5)
        )
    }
    
    private func statItem(title: String, subtitle: String, color: Color, bg: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(subtitle)
                .font(GTFont.labelSmall())
                .foregroundColor(.gtTextMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(RoundedRectangle(cornerRadius: 16).fill(bg.opacity(0.5)))
    }
    
    private func tagItem(text: String, bg: Color, fg: Color) -> some View {
        Text(text)
            .font(GTFont.labelSmall())
            .foregroundColor(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(bg))
    }
}

#Preview {
    GTFertiliserCard()
        .padding()
}
