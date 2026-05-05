import SwiftUI

struct GTOTPField: View {
    @Binding var code: [String]
    let count: Int
    @FocusState private var focusedIndex: Int?

    var body: some View {
        HStack(spacing: GTSpacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: GTRadius.md)
                        .fill(Color.gtPaleGreen.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: GTRadius.md)
                                .stroke(focusedIndex == index ? Color.gtDarkGreen : Color.gtBorder, lineWidth: 2)
                        )
                        .frame(width: 48, height: 56)

                    TextField("", text: $code[index])
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.gtTextPrimary)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .focused($focusedIndex, equals: index)
                        .onChange(of: code[index]) { _, newVal in
                            // Keep only last character
                            if newVal.count > 1 {
                                code[index] = String(newVal.suffix(1))
                            }
                            // Auto-advance
                            if !newVal.isEmpty && index < count - 1 {
                                focusedIndex = index + 1
                            }
                            // Auto-retreat on clear
                            if newVal.isEmpty && index > 0 {
                                focusedIndex = index - 1
                            }
                        }
                }
            }
        }
        .onAppear { focusedIndex = 0 }
    }
}

#Preview {
    GTOTPField(code: .constant(["", "", "", ""]), count: 4)
        .padding()
}
