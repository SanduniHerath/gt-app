import SwiftUI
import Firebase

@main
struct green_thumb_appApp: App {
    
    init() {
        FirebaseApp.configure()
        NotificationManager.shared.requestAuthorization()
    }
    
    @StateObject private var router         = AppRouter()
    @StateObject private var authVM         = AuthViewModel()
    @StateObject private var plantVM        = PlantViewModel()
    @StateObject private var diagnoseVM     = DiagnoseViewModel()
    @StateObject private var schedulerVM    = SchedulerViewModel()
    @StateObject private var expertVM       = ExpertViewModel()
    @StateObject private var communityVM    = CommunityViewModel()
    @StateObject private var notificationsVM = NotificationsViewModel()
    @StateObject private var profileVM      = ProfileViewModel()

    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                MainTabView()
                    .environmentObject(router)
                    .environmentObject(authVM)
                    .environmentObject(plantVM)
                    .environmentObject(diagnoseVM)
                    .environmentObject(schedulerVM)
                    .environmentObject(expertVM)
                    .environmentObject(communityVM)
                    .environmentObject(notificationsVM)
                    .environmentObject(profileVM)
            } else {
                SplashScreenView()
                    .environmentObject(router)
                    .environmentObject(authVM)
                    .environmentObject(plantVM)
                    .environmentObject(diagnoseVM)
                    .environmentObject(schedulerVM)
                    .environmentObject(expertVM)
                    .environmentObject(communityVM)
                    .environmentObject(notificationsVM)
                    .environmentObject(profileVM)
            }
        }
    }
}

