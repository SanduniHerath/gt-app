import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var router: AppRouter
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 0) {
            GTAuthHeader()
                .padding(.top, GTSpacing.xxl)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.lg) {
                    GTSegmentedControl(options: ["Sign in", "Register"], selectedIndex: .constant(0)) { idx in
                        if idx == 1 { router.navigate(to: .register) }
                    }
                    .padding(.top, GTSpacing.md)
                    
                    VStack(spacing: GTSpacing.md) {
                        GTTextField(
                            label: "Enter Email address",
                            placeholder: "you@gmail.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        GTTextField(
                            label: "Enter Password",
                            placeholder: "",
                            text: $password,
                            isSecure: true
                        )
                        
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
                            router.selectedTab = 0 // 🏠 Reset to Home tab
                            authVM.signIn(email: email, password: password)
                        }
                        
                        GTButton(
                            title: "Use Face ID",
                            icon: "faceid",
                            style: .primary
                        ) {
                            router.selectedTab = 0 // 🏠 Reset to Home tab
                            authVM.signInWithFaceID()
                        }
                        
                        HStack {
                            Rectangle().fill(Color.gtSeparator).frame(height: 1)
                            Text("or continue with")
                                .font(GTFont.bodySmall())
                                .foregroundColor(.gtTextMuted)
                            Rectangle().fill(Color.gtSeparator).frame(height: 1)
                        }
                        .padding(.vertical, GTSpacing.xs)
                        
                        HStack(spacing: GTSpacing.md) {
                            SocialButton(label: "Google", icon: "g.circle.fill", iconColor: .gtGoogleRed) {}
                            SocialButton(label: "Apple",  icon: "apple.logo",    iconColor: .black) {}
                        }
                    }
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.bottom, GTSpacing.xxxl)
            }
            .background(Color.white)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

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
        SignInView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppRouter())
    }
}
