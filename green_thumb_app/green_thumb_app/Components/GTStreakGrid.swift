import SwiftUI

struct GTStreakGrid: View {
    // 14 booleans representing watered status
    let days: [Bool]
    let goalLabel: String = "daily"
    
    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.sm) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Watering streak")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                Text("Last 14 days – streak goal: \(goalLabel)")
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextMuted)
            }
            
            VStack(spacing: GTSpacing.sm) {
                // Days grid (7x2)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(0..<14, id: \.self) { index in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index < days.count && days[index] ? Color.gtDarkGreen : Color.gtSeparator)
                                .aspectRatio(1, contentMode: .fit)
                                // ♿ VoiceOver: reads each day's status aloud
                                .accessibilityLabel("Day \(index + 1): \(index < days.count && days[index] ? "Watered" : "Missed")")
                            Text("\(index + 1)").font(GTFont.labelSmall()).foregroundColor(.gtTextMuted)
                                .accessibilityHidden(true) // Number covered by label above
                        }
                    }
                }
                
                // Legend
                HStack(spacing: GTSpacing.md) {
                    Label("Watered", systemImage: "square.fill")
                        .font(GTFont.labelSmall())
                        .foregroundColor(.gtTextSecondary)
                        .tint(.gtDarkGreen)
                    Label("Missed", systemImage: "square.fill")
                        .font(GTFont.labelSmall())
                        .foregroundColor(.gtTextSecondary)
                        .tint(.gtSeparator)
                }
                .labelStyle(GTCompactLabelStyle(iconColor: .gtDarkGreen, missedColor: .gtSeparator))
            }
            .padding(GTSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: GTRadius.md)
                    .fill(Color.white)
                    .gtShadow(GTShadow.card)
            )
        }
    }
}

struct GTCompactLabelStyle: LabelStyle {
    let iconColor: Color
    let missedColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .imageScale(.small)
            configuration.title
        }
    }
}

#Preview {
    GTStreakGrid(days: [false, true, true, false, true, false, true, true, false, true, true, true, true, true])
        .padding()
        .background(Color.gtBackground)
}

