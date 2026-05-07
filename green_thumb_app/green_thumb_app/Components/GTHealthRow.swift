import SwiftUI

struct GTHealthRow: View {
    let name: String
    let progress: Double // 0.0 - 1.0
    var color: Color = .gtAccentGreen
    var countLabel: String? = nil
    
    var body: some View {
        HStack(spacing: GTSpacing.md) {
            Text(name)
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
                .frame(width: 80, alignment: .leading)
            
            GTHealthBar(value: progress, height: 8, customColor: color)
            
            Text(countLabel ?? "\(Int(progress * 100))%")
                .font(GTFont.labelSmall())
                .foregroundColor(.gtTextPrimary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GTHealthRow(name: "Tomatoes", progress: 0.88)
        GTHealthRow(name: "Rose Bush", progress: 0.54, color: .orange)
        GTHealthRow(name: "Basil", progress: 0.95, color: .teal)
    }
    .padding()
}
