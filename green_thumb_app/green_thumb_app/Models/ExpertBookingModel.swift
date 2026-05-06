import Foundation

struct ExpertBookingModel: Identifiable, Codable {
    let id: String
    let expertId: String
    let expertName: String
    let userId: String
    let date: Date
    let timeSlot: String
    let status: BookingStatus
    let timestamp: Date

    enum BookingStatus: String, Codable {
        case pending
        case confirmed
        case completed
        case cancelled
    }
    
    init(id: String = UUID().uuidString,
         expertId: String,
         expertName: String,
         userId: String,
         date: Date,
         timeSlot: String,
         status: BookingStatus = .confirmed,
         timestamp: Date = Date()) {
        self.id = id
        self.expertId = expertId
        self.expertName = expertName
        self.userId = userId
        self.date = date
        self.timeSlot = timeSlot
        self.status = status
        self.timestamp = timestamp
    }
}
