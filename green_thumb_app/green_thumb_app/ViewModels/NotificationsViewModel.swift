import Foundation
import Combine

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = [
        NotificationModel(type: .community,   title: "Welcome to Green Thumb", message: "Start by adding your first plant or exploring experts!"),
    ]
    var unreadCount: Int { notifications.filter { !$0.isRead }.count }
    func markAllRead() { notifications = notifications.map { var n = $0; n.isRead = true; return n } }
    func markRead(_ notification: NotificationModel) {
        if let idx = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[idx].isRead = true
        }
    }
    
    func addNotification(type: NotificationType, title: String, message: String) {
        let newNotification = NotificationModel(type: type, title: title, message: message)
        notifications.insert(newNotification, at: 0)
    }
}
