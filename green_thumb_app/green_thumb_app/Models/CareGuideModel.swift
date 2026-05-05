import Foundation

struct CareGuide: Identifiable, Codable {
    var id: String { speciesName }
    let speciesName: String
    let wateringSchedule: String
    let wateringAmount: String
    let wateringFrequency: String
    let wateringTips: [String]
    let fertilizerInfo: String
    let fertilizerFrequency: String
    let safetyTips: [String]
    let seasonalCalendar: [Int] // 12 integers representing intensity/frequency per month
}
