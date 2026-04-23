import SwiftUI

struct GTPickerField<SelectionValue: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var selection: SelectionValue
    let options: [SelectionValue]
    let formatter: (SelectionValue) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.xxs) {
            Text(label)
                .font(GTFont.labelMedium())
                .foregroundColor(.gtTextSecondary)

            Menu {
                Picker(label, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(formatter(option)).tag(option)
                    }
                }
            } label: {
                HStack {
                    Text(formatter(selection).isEmpty ? placeholder : formatter(selection))
                        .font(GTFont.bodyMedium())
                        .foregroundColor(formatter(selection).isEmpty ? .gtTextMuted : .gtTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gtTextSecondary)
                }
                .padding(.horizontal, GTSpacing.md)
                .padding(.vertical, GTSpacing.sm + 2)
                .background(
                    RoundedRectangle(cornerRadius: GTRadius.sm)
                        .fill(Color.gtPaleGreen.opacity(0.3)) // Matches the light look
                        .overlay(
                            RoundedRectangle(cornerRadius: GTRadius.sm)
                                .stroke(Color.gtBorder, lineWidth: 1.0)
                        )
                )
            }
        }
    }
}

#Preview {
    GTPickerField(
        label: "Plant",
        placeholder: "Select a plant",
        selection: .constant("Rose Bush"),
        options: ["Rose Bush", "Tomatoes", "Monstera"],
        formatter: { $0 }
    )
    .padding()
}
