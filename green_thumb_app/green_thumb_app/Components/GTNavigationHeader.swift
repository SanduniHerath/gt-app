import SwiftUI

struct GTNavigationHeader: View {
    let title: String
    var subtitle: String? = nil
    var showBack: Bool = false
    var backAction: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            if showBack {
                Button { backAction?() } label: {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 38, height: 38)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }

            VStack(alignment: showBack ? .leading : .center, spacing: 2) {
                Text(title)
                    .font(GTFont.labelLarge())
                    .foregroundColor(.white)
                if let subtitle {
                    Text(subtitle)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            if let trailingIcon {
                Button { trailingAction?() } label: {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 38, height: 38)
                        Image(systemName: trailingIcon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal, GTSpacing.md)
        .padding(.vertical, GTSpacing.sm)
    }
}

#Preview {
    VStack {
        GTNavigationHeader(title: "My Garden", trailingIcon: "bell.fill") {}
        GTNavigationHeader(title: "Plant Details", showBack: true) {}
    }
    .background(Color.gtForestGreen)
}

