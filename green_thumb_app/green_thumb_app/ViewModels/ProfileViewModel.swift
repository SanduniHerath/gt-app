import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile = UserProfile(
        name: "Sanduni Herath",
        handle: "@Sandu.grows",
        memberSince: "Feb 2025",
        userType: "Home Grower",
        phone: "07X XXXX XXX",
        gardenCount: 2,
        plantCount: 12,
        streakDays: 7,
        sessionsCount: 3,
        logEntriesCount: 18,
        achievements: [
            Achievement(title: "First Sprout",   description: "Added your first plant",  icon: "🌱", isUnlocked: true),
            Achievement(title: "Week Streak",    description: "7-day care streak",       icon: "🔥", isUnlocked: true),
            Achievement(title: "Plant Doctor",   description: "Diagnosed 5 plants",      icon: "🔬", isUnlocked: false),
            Achievement(title: "Community Star", description: "10 post likes received",  icon: "⭐", isUnlocked: false),
        ]
    )
    @Published var notificationsEnabled: Bool = true

    func updateName(_ name: String) { profile.name = name }
}
