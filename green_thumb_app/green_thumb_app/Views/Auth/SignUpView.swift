import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var goOTP      = false
    @State private var goRegister = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {

                // ── Dark green header ─────────────────────────────────────
                VStack(alignment: .leading, spacing: GTSpacing.sm) {
                    // Logo row
                    GTLogoHeader(iconSize: 30)
                        .padding(.top, GTSpacing.lg)

                    // Welcome text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back,")
                            .font(GTFont.displaySmall())
                            .foregroundColor(.white)

                        Text("green gardener.")
                            .font(.custom("Georgia-Italic", size: 22))
                            .foregroundColor(.gtAccentGreen)
                    }
                    .padding(.top, GTSpacing.xs)
                    .padding(.bottom, GTSpacing.lg)
                }
                .padding(.horizontal, GTSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gtForestGreen)

                // ── White card ────────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: GTSpacing.md) {

                        // Sign in / Register segmented tab
                        GTSegmentedControl(
                            options: ["Sign in", "Register"],
                            selectedIndex: $authVM.selectedTab
                        )
                        .padding(.top, GTSpacing.md)

                        if authVM.selectedTab == 0 {
                            // ── Sign in tab ──
                            VStack(spacing: GTSpacing.md) {
                                GTTextField(
                                    label: "Enter Mobile Number",
                                    placeholder: "07X XXXX XXX",
                                    text: $authVM.phoneNumber,
                                    keyboardType: .phonePad
                                )

                                // Error message
                                if let err = authVM.errorMessage {
                                    Text(err)
                                        .font(GTFont.bodySmall())
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                GTButton(
                                    title: "Sign in to my garden",
                                    style: .primary,
                                    isLoading: authVM.isLoading
                                ) {
                                    authVM.sendOTP()
                                    if authVM.errorMessage == nil { goOTP = true }
                                }

                                GTButton(
                                    title: "Use Face ID",
                                    icon: "faceid",
                                    style: .primary
                                ) {
                                    authVM.signInWithFaceID()
                                }

                                // Divider
                                HStack {
                                    Rectangle().fill(Color.gtSeparator).frame(height: 1)
                                    Text("or continue with")
                                        .font(GTFont.bodySmall())
                                        .foregroundColor(.gtTextMuted)
                                        .fixedSize()
                                    Rectangle().fill(Color.gtSeparator).frame(height: 1)
                                }
                                .padding(.vertical, GTSpacing.xxs)

                                // Social buttons
                                HStack(spacing: GTSpacing.md) {
                                    SocialButton(label: "Google", icon: "g.circle.fill", iconColor: .gtGoogleRed) {}
                                    SocialButton(label: "Apple",  icon: "apple.logo",    iconColor: .black) {}
                                }
                            }
                        } else {
                            // ── Register tab ──
                            RegisterFormView()
                        }
                    }
                    .padding(.horizontal, GTSpacing.lg)
                    .padding(.bottom, GTSpacing.xxl)
                }
                .background(Color.white)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goOTP) { OTPVerificationView() }
    }
}



// MARK: - Social Button
struct SocialButton: View {
    let label: String
    let icon: String
    var iconColor: Color = .gtTextPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: GTSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(label)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, GTSpacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: GTRadius.xl)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: GTRadius.xl)
                            .stroke(Color.gtSeparator, lineWidth: 1.5)
                    )
            )
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppRouter())
            .environmentObject(PlantViewModel())
            .environmentObject(DiagnoseViewModel())
            .environmentObject(SchedulerViewModel())
            .environmentObject(ExpertViewModel())
            .environmentObject(CommunityViewModel())
            .environmentObject(NotificationsViewModel())
            .environmentObject(ProfileViewModel())
    }
}
