import SwiftUI

// Inline form used in both RegisterView (standalone) and SignUpView Register tab
struct RegisterFormView: View {
    @State private var name     = ""
    @State private var phone    = ""
    @State private var email    = ""

    var body: some View {
        VStack(spacing: GTSpacing.md) {
            GTTextField(label: "Name", placeholder: "Sanduni Herath", text: $name)
            GTTextField(label: "Email address", placeholder: "you@gmail.com", text: $email, keyboardType: .emailAddress)
            GTTextField(label: "Phone Number", placeholder: "07X XXXX XXX", text: $phone, keyboardType: .phonePad)

            GTButton(title: "Register to my garden") {
                // Register action
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

            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.lg) {
                    GTSegmentedControl(options: ["Sign in", "Register"], selectedIndex: .constant(1))
                        .onTapGesture { router.pop() }
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
