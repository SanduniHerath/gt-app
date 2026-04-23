import SwiftUI

struct GTSettingCard<Content: View>: View {
    let title: String?
    let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.md) {
            if let title {
                Text(title)
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                    .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, GTSpacing.md)
            .padding(.vertical, GTSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: GTRadius.lg)
                    .fill(Color.white)
                    .gtShadow(GTShadow.card)
            )
        }
        .padding(.horizontal, GTSpacing.lg)
    }
}
