import Foundation

struct CareGuide: Identifiable, Codable {
    var id: String { speciesName }
    let speciesName: String
    let watering: WateringInfo
    let sunlight: SunlightInfo
    let soil: SoilInfo
    let fertiliser: FertiliserInfo
    let pruning: PruningInfo
}

struct WateringInfo: Codable {
    let schedule: String
    let amount: String
    let tips: [String]
    let seasonalCalendar: [String: String]
}

struct SunlightInfo: Codable {
    let requirement: String
    let tips: [String]
}

struct SoilInfo: Codable {
    let type: String
    let tips: [String]
}

struct FertiliserInfo: Codable {
    let product: String
    let frequency: String
    let tips: [String]
}

struct PruningInfo: Codable {
    let frequency: String
    let tips: [String]
}
