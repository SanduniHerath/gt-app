import SwiftUI

struct GTTabBar: View {
    @Binding var selectedTab: Int

    private let items: [(icon: String, label: String)] = [
        ("house.fill",      "Home"),
        ("leaf.fill",       "My Garden"),
        ("magnifyingglass",  "Diagnose"),
        ("person.2",        "Experts"),
        ("person.crop.circle", "Profile"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { idx in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = idx
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: items[idx].icon)
                            .font(.system(size: idx == selectedTab ? 24 : 20, weight: .semibold))
                            .foregroundColor(idx == selectedTab ? .gtDarkGreen : .gtTextMuted)
                            .scaleEffect(idx == selectedTab ? 1.1 : 1.0)

                        Text(items[idx].label)
                            .font(.system(size: 10, weight: idx == selectedTab ? .semibold : .regular, design: .rounded))
                            .foregroundColor(idx == selectedTab ? .gtDarkGreen : .gtTextMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, GTSpacing.xs)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
        }
        .padding(.horizontal, GTSpacing.xs)
        .background(
            Rectangle()
                .fill(.white)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
        )
    }
}

#Preview {
    GTTabBar(selectedTab: .constant(0))
}
