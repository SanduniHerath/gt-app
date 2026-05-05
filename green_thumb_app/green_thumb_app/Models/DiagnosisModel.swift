import Foundation
import SwiftUI

struct TreatmentStep: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let badgeText: String
    let badgeType: BadgeType
    
    enum BadgeType: String, Codable {
        case urgent, ongoing, optional, future
        
        var colors: (bg: Color, fg: Color) {
            switch self {
            case .urgent: return (.gtBadgeYellowBg, .gtBadgeYellowText)
            case .ongoing: return (.gtBadgeTealBg, .gtBadgeTealText)
            case .optional: return (.gtBadgeGreenBg, .gtBadgeGreenText)
            case .future: return (.gtBadgePurpleBg, .gtBadgePurpleText)
            }
        }
    }
}

struct DiagnosisResultData: Identifiable, Codable {
    var id = UUID()
    let name: String
    let probability: Int
    let description: String
    let symptomsMatch: [String]
    let treatmentPlan: [TreatmentStep]
}

struct DiagnosisKnowledgeBase {
    static let database: [DiagnosisResultData] = [
        DiagnosisResultData(
            name: "Overwatering",
            probability: 95,
            description: "Roots are suffocating due to excess water, leading to yellowing and root rot.",
            symptomsMatch: ["Yellow leaves", "Wilting", "Root smell"],
            treatmentPlan: [
                TreatmentStep(title: "Stop watering immediately", description: "Allow the soil to dry out completely before next session.", badgeText: "Immediate", badgeType: .urgent),
                TreatmentStep(title: "Improve drainage", description: "Ensure the pot has holes and the soil mix is well-draining.", badgeText: "Required", badgeType: .ongoing),
                TreatmentStep(title: "Remove affected leaves", description: "Trim yellow or mushy leaves to prevent fungal growth.", badgeText: "Optional", badgeType: .optional)
            ]
        ),
        DiagnosisResultData(
            name: "Nitrogen Deficiency",
            probability: 88,
            description: "The plant lacks essential nutrients required for chlorophyll production.",
            symptomsMatch: ["Yellow leaves", "Slow growth"],
            treatmentPlan: [
                TreatmentStep(title: "Apply nitrogen fertiliser", description: "Use NPK 20-5-10 or blood meal. Apply 2 tablespoon per liter.", badgeText: "Do within 2 days", badgeType: .urgent),
                TreatmentStep(title: "Adjust watering", description: "Reduce to every 3 days. Overwatering flushes nitrogen.", badgeText: "Ongoing", badgeType: .ongoing),
                TreatmentStep(title: "Test soil pH", description: "Nitrogen uptake is best at pH 6.0-7.0.", badgeText: "Optional", badgeType: .optional)
            ]
        ),
        DiagnosisResultData(
            name: "Powdery Mildew",
            probability: 92,
            description: "A common fungal disease that appears as white flour-like spots.",
            symptomsMatch: ["White powder", "Brown spots"],
            treatmentPlan: [
                TreatmentStep(title: "Apply fungicide", description: "Use neem oil or a milk-water spray solution (40/60).", badgeText: "ASAP", badgeType: .urgent),
                TreatmentStep(title: "Increase air circulation", description: "Move plant to a better ventilated area.", badgeText: "Ongoing", badgeType: .ongoing),
                TreatmentStep(title: "Prune affected parts", description: "Remove leaves covered in white powder immediately.", badgeText: "Required", badgeType: .urgent)
            ]
        )
    ]
}
