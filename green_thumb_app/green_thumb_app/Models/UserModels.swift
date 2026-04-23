import Foundation

enum NotificationType: String, Codable {
    case watering, fertilizing, diagnosis, expert, community, system
    var icon: String {
        switch self {
        case .watering:    return "💧"
        case .fertilizing: return "🌿"
        case .diagnosis:   return "🔬"
        case .expert:      return "👨‍🌾"
        case .community:   return "🌱"
        case .system:      return "⚙️"
        }
    }
}

struct NotificationModel: Identifiable, Codable {
    let id: UUID
    var type: NotificationType
    var title: String
    var message: String
    var timestamp: Date
    var isRead: Bool
    init(id: UUID = .init(), type: NotificationType, title: String,
         message: String, timestamp: Date = .now, isRead: Bool = false) {
        self.id = id; self.type = type; self.title = title
        self.message = message; self.timestamp = timestamp; self.isRead = isRead
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    init(id: UUID = .init(), title: String, description: String,
         icon: String, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id; self.title = title; self.description = description
        self.icon = icon; self.isUnlocked = isUnlocked; self.unlockedDate = unlockedDate
    }
}

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var handle: String
    var memberSince: String
    var userType: String
    var phone: String
    var email: String?
    var avatarURL: String?
    var gardenCount: Int
    var plantCount: Int
    var streakDays: Int
    var sessionsCount: Int
    var logEntriesCount: Int
    var achievements: [Achievement]
    var notificationsEnabled: Bool
    
    init(id: UUID = .init(),
         name: String = "Green Gardener",
         handle: String = "@green.gardener",
         memberSince: String = "Jan 2025",
         userType: String = "Home Grower",
         phone: String = "",
         email: String? = nil,
         avatarURL: String? = nil,
         gardenCount: Int = 1,
         plantCount: Int = 4,
         streakDays: Int = 7,
         sessionsCount: Int = 0,
         logEntriesCount: Int = 0,
         achievements: [Achievement] = [],
         notificationsEnabled: Bool = true) {
        self.id = id; self.name = name; self.handle = handle
        self.memberSince = memberSince; self.userType = userType
        self.phone = phone; self.email = email; self.avatarURL = avatarURL
        self.gardenCount = gardenCount; self.plantCount = plantCount
        self.streakDays = streakDays; self.sessionsCount = sessionsCount
        self.logEntriesCount = logEntriesCount
        self.achievements = achievements; self.notificationsEnabled = notificationsEnabled
    }
}
