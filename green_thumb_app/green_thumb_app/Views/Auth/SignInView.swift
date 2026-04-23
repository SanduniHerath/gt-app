import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var router: AppRouter
    @State private var goOTP = false
    
    var body: some View {
        VStack(spacing: 0) {
            GTAuthHeader()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.lg) {
                    GTSegmentedControl(options: ["Sign in", "Register"], selectedIndex: .constant(0))
                        .onTapGesture { router.navigate(to: .register) }
                        .padding(.top, GTSpacing.md)
                    
                    VStack(spacing: GTSpacing.md) {
                        GTTextField(
                            label: "Enter Mobile Number",
                            placeholder: "07X XXXX XXX",
                            text: $authVM.phoneNumber,
                            keyboardType: .phonePad
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
        .navigationDestination(isPresented: $goOTP) { OTPVerificationView() }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppRouter())
    }
}
