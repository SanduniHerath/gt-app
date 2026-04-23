import SwiftUI

struct GTTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var prefix: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.xxs) {
            Text(label)
                .font(GTFont.labelMedium())
                .foregroundColor(.gtTextSecondary)

            HStack {
                if let prefix {
                    Text(prefix)
                        .font(GTFont.bodyMedium())
                        .foregroundColor(.gtTextMuted)
                }
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(GTFont.bodyMedium())
                        .foregroundColor(.gtTextPrimary)
                } else {
                    TextField(placeholder, text: $text)
                        .font(GTFont.bodyMedium())
                        .foregroundColor(.gtTextPrimary)
                        .keyboardType(keyboardType)
                }
            }
            .padding(.horizontal, GTSpacing.md)
            .padding(.vertical, GTSpacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: GTRadius.xl)
                    .fill(Color.gtPaleGreen.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: GTRadius.xl)
                            .stroke(Color.gtBorder, lineWidth: 1.5)
                    )
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GTTextField(label: "Enter Mobile Number", placeholder: "07X XXXX XXX", text: .constant(""), keyboardType: .phonePad)
        GTTextField(label: "Password", placeholder: "••••••••", text: .constant(""), isSecure: true)
    }
    .padding()
}
