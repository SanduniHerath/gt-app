import SwiftUI

struct GTFertiliserCard: View {
    let product: String
    let frequency: String
    let instructions: String
    let tips: [String]
    
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
                    Text(product)
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                    Text("Fertiliser")
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
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
                statItem(title: "Base", subtitle: "Application", color: Color.gtBadgeGreenText, bg: Color.gtBadgeGreenBg)
                statItem(title: frequency, subtitle: "Frequency", color: Color.gtBadgeYellowText, bg: Color.gtBadgeYellowBg)
                statItem(title: "Soil", subtitle: "Target", color: Color.gtBadgeTealText, bg: Color.gtBadgeTealBg)
            }
            
            // Instruction
            Text(instructions)
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
                .lineSpacing(4)
            
            // Tips Section
            if !tips.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(0..<tips.count, id: \.self) { index in
                        WateringTipRow(text: tips[index])
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .frame(maxWidth: UIScreen.main.bounds.width - 48, alignment: .leading)
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
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
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
    GTFertiliserCard(
        product: "NPK 10-5-5",
        frequency: "14 days",
        instructions: "Apply at the base of the plant.",
        tips: ["Wear gloves", "Avoid rain"]
    )
    .padding()
}
