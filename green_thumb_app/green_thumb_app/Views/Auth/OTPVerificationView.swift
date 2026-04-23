import SwiftUI

struct OTPVerificationView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            GTAuthHeader(onBack: { router.pop() })

            // ── White content area ────────────────────────────────────
            VStack(spacing: GTSpacing.xl) {
                // Instruction
                Text("Enter 4 digit code sent to \(authVM.phoneNumber.isEmpty ? "07X XXXX XXX" : authVM.phoneNumber)")
                    .font(GTFont.bodyMedium())
                    .foregroundColor(.gtTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, GTSpacing.xl)

                // OTP boxes
                GTOTPField(code: $authVM.otpCode, count: 4)

                // Error
                if let err = authVM.errorMessage {
                    Text(err)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.red)
                }

                VStack(spacing: GTSpacing.sm) {
                    // Verify button
                    GTButton(
                        title: "Verify & Sign in",
                        style: .primary,
                        isLoading: authVM.isLoading
                    ) {
                        authVM.verifyOTP()
                    }

                    // Resend
                    Button {
                        authVM.otpCode = ["","","",""]
                        authVM.errorMessage = nil
                    } label: {
                        Text("Resend code")
                            .font(GTFont.labelMedium())
                            .foregroundColor(.gtTextSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, GTSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        OTPVerificationView()
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
