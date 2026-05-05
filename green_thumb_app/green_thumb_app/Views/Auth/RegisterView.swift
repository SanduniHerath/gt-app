import SwiftUI

// Inline form used in both RegisterView (standalone) and SignUpView Register tab
struct RegisterFormView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: GTSpacing.md) {
            GTTextField(label: "Name", placeholder: "Sanduni Herath", text: $name)
            GTTextField(label: "Email address", placeholder: "you@gmail.com", text: $email, keyboardType: .emailAddress)
            GTTextField(label: "Password", placeholder: "........" , text: $password, isSecure: true)

            if let err = authVM.errorMessage {
                Text(err)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            GTButton(title: "Register to my garden", isLoading: authVM.isLoading) {
                authVM.register(email: email, password: password, name: name)
            }
            .padding(.top, GTSpacing.xs)
        }
    }
}


struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            GTAuthHeader()
                .padding(.top, GTSpacing.xxl)

            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.lg) {
                    GTSegmentedControl(options: ["Sign in", "Register"], selectedIndex: .constant(1)) { idx in
                        if idx == 0 { router.pop() }
                    }
                    .padding(.top, GTSpacing.md)
                    
                    RegisterFormView()
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.bottom, GTSpacing.xxl)
            }
            .background(Color.white)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack { RegisterView().environmentObject(AuthViewModel()).environmentObject(AppRouter())
            .environmentObject(PlantViewModel()).environmentObject(DiagnoseViewModel())
            .environmentObject(SchedulerViewModel()).environmentObject(ExpertViewModel())
            .environmentObject(CommunityViewModel()).environmentObject(NotificationsViewModel())
            .environmentObject(ProfileViewModel()) }
}
