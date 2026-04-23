import SwiftUI

struct GTTextArea: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.xxs) {
            Text(label)
                .font(GTFont.labelMedium())
                .foregroundColor(.gtTextSecondary)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(GTFont.bodyMedium())
                        .foregroundColor(.gtTextMuted)
                        .padding(.horizontal, GTSpacing.md)
                        .padding(.vertical, GTSpacing.sm + 4)
                }
                
                TextEditor(text: $text)
                    .font(GTFont.bodyMedium())
                    .foregroundColor(.gtTextPrimary)
                    .scrollContentBackground(.hidden) // Required to show background color
                    .padding(.horizontal, GTSpacing.sm)
                    .padding(.vertical, GTSpacing.sm)
                    .frame(minHeight: minHeight)
            }
            .background(
                RoundedRectangle(cornerRadius: GTRadius.sm)
                    .fill(Color.gtPaleGreen.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: GTRadius.sm)
                            .stroke(Color.gtBorder, lineWidth: 1.0)
                    )
            )
        }
    }
}

#Preview {
    GTTextArea(
        label: "Observation",
        placeholder: "Any observation about the plant...",
        text: .constant("")
    )
    .padding()
}
