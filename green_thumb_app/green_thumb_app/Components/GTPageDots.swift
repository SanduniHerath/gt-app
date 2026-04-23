import SwiftUI

// Onboarding page-indicator dots
struct GTPageDots: View {
    let total: Int
    let current: Int                        // 0-indexed

    var body: some View {
        HStack(spacing: GTSpacing.xs) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == current ? Color.gtDarkGreen : Color.gtLightGreen)
                    .frame(width: i == current ? 28 : 18, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: current)
            }
        }
    }
}

// General purpose progress dots for splash
struct GTLoadingDots: View {
    let count: Int = 3
    @State private var active = 0

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(active == i ? Color.gtAccentGreen : Color.gtLightGreen.opacity(0.5))
                    .frame(width: 10, height: 10)
                    .scaleEffect(active == i ? 1.3 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: active)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                active = (active + 1) % count
            }
        }
    }
}

#Preview("Page Dots") {
    VStack(spacing: 24) {
        GTPageDots(total: 2, current: 0)
        GTPageDots(total: 2, current: 1)
        GTLoadingDots()
    }.padding().background(Color.gtForestGreen)
}

