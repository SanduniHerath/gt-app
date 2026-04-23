import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var otpCode: [String] = ["", "", "", ""]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    @Published var selectedTab: Int = 0 // 0 = Sign In, 1 = Register

    func sendOTP() {
        guard phoneNumber.count >= 9 else {
            errorMessage = "Enter a valid mobile number"; return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
        }
    }

    func verifyOTP() {
        let code = otpCode.joined()
        guard code.count == 4 else { errorMessage = "Enter all 4 digits"; return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isLoading = false
            self.isAuthenticated = true
        }
    }

    func signInWithFaceID() { isAuthenticated = true }
    func signOut() { isAuthenticated = false; phoneNumber = ""; otpCode = ["","","",""] }
}
