import SwiftUI

struct GTSafetyCard: View {
    let title: String
    let points: [String]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gtDiagnosisText.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color.gtDiagnosisText)
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(GTFont.labelLarge())
                    .foregroundColor(Color.gtDiagnosisTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(points, id: \.self) { point in
                        Text(point)
                            .font(GTFont.bodySmall())
                            .foregroundColor(Color.gtDiagnosisTitle.opacity(0.8))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gtSafetyBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gtSafetyBorder, lineWidth: 1.5)
        )
    }
}

#Preview {
    GTSafetyCard(
        title: "Safety first",
        points: [
            "Wear gloves when handling chemicals.",
            "Keep away from children and pets.",
            "Never exceed recommended dosage"
        ]
    )
    .padding()
}
