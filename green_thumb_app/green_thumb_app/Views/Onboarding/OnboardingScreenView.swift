import SwiftUI

// MARK: - Shared Onboarding Layout
private struct OnboardingLayout: View {
    let pageIndex: Int          // 0-indexed
    let totalPages: Int
    let featureLabel: String
    let headline: String
    let description: String
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ── Upper illustration area (dark green) ──────────────────
                ZStack {
                    Color.gtForestGreen

                    // Hand-holding-plant illustration using emoji + shapes
                    PlantIllustration()
                        .offset(y: 20)
                }
                .frame(height: geo.size.height * 0.44)
                .ignoresSafeArea(edges: .top)

                // ── White content card ────────────────────────────────────
                VStack(alignment: .leading, spacing: GTSpacing.md) {

                    // Feature chip
                    GTStatusBadge.feature(featureLabel)
                        .padding(.top, GTSpacing.lg)

                    // Headline — 2-line serif
                    Text(headline)
                        .font(GTFont.displayMedium())
                        .foregroundColor(.gtTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Description
                    Text(description)
                        .font(GTFont.bodyMedium())
                        .foregroundColor(.gtTextSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    // Page dots
                    GTPageDots(total: totalPages, current: pageIndex)
                        .padding(.vertical, GTSpacing.xs)

                    Spacer(minLength: GTSpacing.sm)

                    // Next button
                    GTButton(title: "Next", trailingIcon: "arrow.right", action: onNext)

                    // Skip
                    Button(action: onSkip) {
                        Text("Skip intro")
                            .font(GTFont.labelMedium())
                            .foregroundColor(.gtTextSecondary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, GTSpacing.xs)
                }
                .padding(.horizontal, GTSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Plant illustration (hand holding seedling)
private struct PlantIllustration: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // Leaves
            ZStack {
                // Left leaf
                Ellipse()
                    .fill(Color(red:0.36, green:0.72, blue:0.25))
                    .frame(width: 70, height: 110)
                    .rotationEffect(.degrees(-25))
                    .offset(x: -36, y: 20)

                // Right leaf
                Ellipse()
                    .fill(Color(red:0.44, green:0.78, blue:0.30))
                    .frame(width: 70, height: 110)
                    .rotationEffect(.degrees(25))
                    .offset(x: 36, y: 20)

                // Leaf veins
                Path { p in
                    p.move(to:   CGPoint(x: -36, y: 70))
                    p.addLine(to: CGPoint(x: -36, y: -20))
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                .offset(x: 0, y: 20)

                Path { p in
                    p.move(to:   CGPoint(x: 36, y: 70))
                    p.addLine(to: CGPoint(x: 36, y: -20))
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                .offset(x: 0, y: 20)

                // Stem
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red:0.40, green:0.25, blue:0.12))
                    .frame(width: 10, height: 55)
                    .offset(y: 75)
            }

            // Soil / earth mound
            Ellipse()
                .fill(Color(red:0.45, green:0.28, blue:0.14))
                .frame(width: 120, height: 45)
                .offset(y: -8)

            // Hand
            ZStack {
                // Palm
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red:0.91, green:0.73, blue:0.61))
                    .frame(width: 150, height: 55)
                    .rotationEffect(.degrees(-5))

                // Fingers (simplified as rounded rects)
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red:0.91, green:0.73, blue:0.61))
                            .frame(width: 22, height: 40)
                    }
                }
                .offset(y: -28)
            }
            .offset(y: -10)
            Spacer(minLength: 8)
        }
        .frame(maxWidth: 200)
    }
}

// MARK: - Screen 1
struct OnboardingScreen1View: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var goNext = false
    @State private var goSkip = false

    var body: some View {
        OnboardingLayout(
            pageIndex: 0,
            totalPages: 2,
            featureLabel: "FEATURE 01 OF 02",
            headline: "Diagnose your plants instantly",
            description: "Describe symptoms or snap a photo – GreenThumb identifies disease, pests, and defeciencies and gives you a step-by-step treatment plan",
            onNext: { goNext = true },
            onSkip: { goSkip = true }
        )
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goNext) { OnboardingScreen2View() }
        .navigationDestination(isPresented: $goSkip) { SignUpView() }
    }
}

// MARK: - Screen 2
struct OnboardingScreen2View: View {
    @State private var goNext = false

    var body: some View {
        OnboardingLayout(
            pageIndex: 1,
            totalPages: 2,
            featureLabel: "FEATURE 02 OF 02",
            headline: "Diagnose your plants instantly",
            description: "Describe symptoms or snap a photo – GreenThumb identifies disease, pests, and defeciencies and gives you a step-by-step treatment plan",
            onNext: { goNext = true },
            onSkip: { goNext = true }
        )
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goNext) { SignUpView() }
    }
}

#Preview("Screen 1") {
    NavigationStack {
        OnboardingScreen1View()
            .environmentObject(AppRouter())
            .environmentObject(AuthViewModel())
            .environmentObject(PlantViewModel())
            .environmentObject(DiagnoseViewModel())
            .environmentObject(SchedulerViewModel())
            .environmentObject(ExpertViewModel())
            .environmentObject(CommunityViewModel())
            .environmentObject(NotificationsViewModel())
            .environmentObject(ProfileViewModel())
    }
}

#Preview("Screen 2") {
    NavigationStack {
        OnboardingScreen2View()
    }
}
