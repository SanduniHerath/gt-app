import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import LocalAuthentication

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published States
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    @Published var selectedTab: Int = 0
    @Published var biometricType: LABiometryType = .none
    
    private let db = Firestore.firestore()
    
    // MARK: - Init
    init() {
        isAuthenticated = Auth.auth().currentUser != nil
        checkBiometricAvailability()
    }
    
    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }
    
    // MARK: - Email Sign In
    func signIn(email: String, password: String) {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            // 💾 Save to Keychain for future Face ID use
            self.saveCredentials(email: email, password: password)
            self.selectedTab = 0 // 🏠 Reset to Home tab
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Email Registration
    func register(email: String, password: String, name: String) {
        guard !email.isEmpty && !password.isEmpty && !name.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else { 
                self.isLoading = false
                return 
            }
            
            // 💾 Save to Keychain for future Face ID use
            self.saveCredentials(email: email, password: password)
            
            self.createUserDocument(uid: user.uid, email: email, name: name)
            self.isLoading = false
            self.selectedTab = 0 // 🏠 Reset to Home tab
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Keychain Helpers
    private func saveCredentials(email: String, password: String) {
        if let emailData = email.data(using: .utf8),
           let passwordData = password.data(using: .utf8) {
            KeychainHelper.shared.save(emailData, service: "green-thumb-auth", account: "user-email")
            KeychainHelper.shared.save(passwordData, service: "green-thumb-auth", account: "user-password")
        }
    }
    
    private func getCredentials() -> (String, String)? {
        if let emailData = KeychainHelper.shared.read(service: "green-thumb-auth", account: "user-email"),
           let passwordData = KeychainHelper.shared.read(service: "green-thumb-auth", account: "user-password"),
           let email = String(data: emailData, encoding: .utf8),
           let password = String(data: passwordData, encoding: .utf8) {
            return (email, password)
        }
        return nil
    }
    
    // MARK: - Firestore User Creation
    private func createUserDocument(uid: String, email: String, name: String) {
        let data: [String: Any] = [
            "uid": uid,
            "email": email,
            "name": name,
            "handle": name.lowercased().replacingOccurrences(of: " ", with: ""),
            "memberSince": Date(),
            "userType": "Home Grower",
            "gardenCount": 0,
            "plantCount": 0,
            "streakDays": 0,
            "sessionsCount": 0,
            "logEntriesCount": 0
        ]
        
        db.collection("users").document(uid).setData(data, merge: true)
    }
    
    // MARK: - Face ID logic
    func signInWithFaceID() {
        // 🛡️ Check if enabled in App Settings
        let isFaceIDEnabled = UserDefaults.standard.object(forKey: "faceIDEnabled") as? Bool ?? true
        guard isFaceIDEnabled else {
            self.errorMessage = "Face ID is disabled in settings. Please enable it to use biometric login."
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Sign in to your Green Thumb dashboard"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                Task { @MainActor in
                    if success {
                        // 1. Scan successful! 
                        if let user = Auth.auth().currentUser {
                            // Already have a session
                            self.selectedTab = 0 // 🏠 Reset to Home tab
                            self.isAuthenticated = true
                        } else if let (email, password) = self.getCredentials() {
                            // 2. No session, but we have saved credentials in the Vault!
                            self.isLoading = true
                            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                                self.isLoading = false
                                if let error = error {
                                    self.errorMessage = "Automatic login failed: \(error.localizedDescription)"
                                } else {
                                    self.selectedTab = 0 // 🏠 Reset to Home tab
                                    self.isAuthenticated = true
                                }
                            }
                        } else {
                            // 3. No session and no saved credentials
                            self.errorMessage = "No saved account found. Please sign in manually once to enable Face ID."
                        }
                    } else {
                        if let error = authenticationError as? LAError {
                            switch error.code {
                            case .userCancel: break
                            default: self.errorMessage = "Face ID failed. Please try again."
                            }
                        }
                    }
                }
            }
        } else {
            self.errorMessage = "Face ID is not available or not set up."
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.selectedTab = 0 // 🏠 Reset to Home for next login
            isAuthenticated = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

