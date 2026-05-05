import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published States
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    @Published var selectedTab: Int = 0
    
    private let db = Firestore.firestore()
    
    // MARK: - Init
    init() {
        isAuthenticated = Auth.auth().currentUser != nil
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
            
            self.createUserDocument(uid: user.uid, email: email, name: name)
            self.isLoading = false
            self.isAuthenticated = true
        }
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
    
    // MARK: - Face ID placeholder
    func signInWithFaceID() {
        isAuthenticated = true
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

