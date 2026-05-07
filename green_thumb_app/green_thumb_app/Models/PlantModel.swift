import Foundation

// MARK: - Plant Status
enum PlantStatus: String, Codable, CaseIterable {
    case healthy    = "Healthy"
    case warning    = "Needs Attention"
    case critical   = "Critical"
    case recovering = "Recovering"
}

// MARK: - Care Log Entry Type
enum TimelineEntryType: String, Codable, CaseIterable {
    case watering    = "Watering"
    case fertilizing = "Fertilizing"
    case repotting   = "Repotting"
    case pruning     = "Pruning"
    case observation = "Observation"
    case diagnosis   = "Diagnosis"
}

// MARK: - Care Log Entry
struct CareLogEntry: Identifiable, Codable {
    let id: UUID
    let type: TimelineEntryType
    let date: Date
    let title: String
    let note: String
    let statusBadge: String?
    let colorHex: String?
    let imageURL: String?

    init(
        id: UUID = .init(),
        type: TimelineEntryType,
        date: Date = .now,
        title: String,
        note: String,
        statusBadge: String? = nil,
        colorHex: String? = nil,
        imageURL: String? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.title = title
        self.note = note
        self.statusBadge = statusBadge
        self.colorHex = colorHex
        self.imageURL = imageURL
    }
}

// MARK: - Plant Model
struct PlantModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var species: String
    var nickname: String?
    var status: PlantStatus
    var healthScore: Double   // 0–100
    var imageURL: String?
    var location: String
    var dateAdded: Date
    var lastWatered: Date?
    var nextWateringDate: Date?
    var careLogs: [CareLogEntry]
    var tags: [String]
    var streakDays: Int
    var isOutdoor: Bool
    var dailyWater: String
    var sunlight: String
    var soilType: String
    var ageDays: Int
    var initialNote: String?
    var lastDiagnosisName: String?   // ✅ Disease name from last diagnosis
    var lastDiagnosisDate: Date?     // ✅ When the diagnosis was made

    init(
        id: UUID = .init(),
        name: String,
        species: String,
        nickname: String? = nil,
        status: PlantStatus = .healthy,
        healthScore: Double = 90,
        imageURL: String? = nil,
        location: String = "Living Room",
        dateAdded: Date = .now,
        lastWatered: Date? = nil,
        nextWateringDate: Date? = nil,
        careLogs: [CareLogEntry] = [],
        tags: [String] = [],
        streakDays: Int = 0,
        isOutdoor: Bool = false,
        dailyWater: String = "Unknown",
        sunlight: String = "Unknown",
        soilType: String = "Unknown",
        ageDays: Int = 0,
        initialNote: String? = nil,
        lastDiagnosisName: String? = nil,
        lastDiagnosisDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.nickname = nickname
        self.status = status
        self.healthScore = healthScore
        self.imageURL = imageURL
        self.location = location
        self.dateAdded = dateAdded
        self.lastWatered = lastWatered
        self.nextWateringDate = nextWateringDate
        self.careLogs = careLogs
        self.tags = tags
        self.streakDays = streakDays
        self.isOutdoor = isOutdoor
        self.dailyWater = dailyWater
        self.sunlight = sunlight
        self.soilType = soilType
        self.ageDays = ageDays
        self.initialNote = initialNote
        self.lastDiagnosisName = lastDiagnosisName
        self.lastDiagnosisDate = lastDiagnosisDate
    }
}

extension PlantModel {
    var calculatedAge: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Use startOfDay to compare full calendar days
        let startOfPlanting = calendar.startOfDay(for: dateAdded)
        let startOfNow = calendar.startOfDay(for: now)
        
        let components = calendar.dateComponents([.day, .month, .year], from: startOfPlanting, to: startOfNow)
        
        if let year = components.year, year > 0 {
            return "\(year)y \(components.month ?? 0)m"
        } else if let month = components.month, month > 0 {
            return "\(month)m \(components.day ?? 0)d"
        } else {
            let days = components.day ?? 0
            return "\(days) \(days == 1 ? "day" : "days")"
        }
    }
}

// MARK: - Sample Data
extension PlantModel {
    static let samples: [PlantModel] = [
        PlantModel(name: "Tomatoes", species: "Solanum lycopersicum", status: .healthy, healthScore: 88, location: "Back garden", streakDays: 7, isOutdoor: true, dailyWater: "450ml", sunlight: "Full sun", soilType: "Loamy", ageDays: 32, initialNote: "Planted in a sunny spot with organic compost."),
        PlantModel(name: "Rose Bush", species: "Rosa", status: .warning, healthScore: 54, location: "Front garden", careLogs: [
            CareLogEntry(type: .observation, date: Calendar.current.date(byAdding: .hour, value: -4, to: .now)!, title: "Yellowing leaves noticed", note: "Lower leaves turning yellow. Possible nitrogen deficiency or root stress. Reduced watering frequency.", statusBadge: "Disease alert", colorHex: "E67E22"),
            CareLogEntry(type: .fertilizing, date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, title: "Fertiliser applied", note: "NPK 10-5-5 applied.", statusBadge: "Fertiliser", colorHex: "F1C40F"),
            CareLogEntry(type: .watering, date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, title: "Regular watering 300ml", note: "Two new buds forming on east stem. Looking very healthy after last week's rain", statusBadge: "Watering", colorHex: "1ABC9C")
        ], streakDays: 2, isOutdoor: true, dailyWater: "300ml", sunlight: "Full sun", soilType: "Sandy", ageDays: 42, initialNote: "Gift from mother-in-law. Planted in sandy soil near the fence."),
        PlantModel(name: "Boston Fern", species: "Nephrolepis exaltata", status: .healthy, healthScore: 80, location: "Living room", streakDays: 3, isOutdoor: false, dailyWater: "200ml", sunlight: "Partial shade", soilType: "Peat moss", ageDays: 120, initialNote: "Likes high humidity. Kept near the humidifier."),
        PlantModel(name: "Monstera", species: "Monstera deliciosa", status: .healthy, healthScore: 92, location: "Living Room", streakDays: 12, isOutdoor: false, dailyWater: "500ml", sunlight: "Indirect light", soilType: "Potting mix", ageDays: 240, initialNote: "Started from a cutting. Developing great fenestrations."),
    ]
}
