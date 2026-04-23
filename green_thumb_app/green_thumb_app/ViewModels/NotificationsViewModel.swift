import Foundation
import Combine

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = [
        NotificationModel(type: .watering,    title: "Time to Water",      message: "Monstera needs watering today."),
        NotificationModel(type: .fertilizing, title: "Fertilise Due",      message: "Peace Lily fertilisation is overdue."),
        NotificationModel(type: .expert,      title: "Session Confirmed",  message: "Dr. Sarah confirmed your session for tomorrow.", isRead: true),
        NotificationModel(type: .community,   title: "New Reply",          message: "Alice replied to your post about fungus gnats."),
    ]
    var unreadCount: Int { notifications.filter { !$0.isRead }.count }
    func markAllRead() { notifications = notifications.map { var n = $0; n.isRead = true; return n } }
    func markRead(_ notification: NotificationModel) {
        if let idx = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[idx].isRead = true
        }
    }
}
