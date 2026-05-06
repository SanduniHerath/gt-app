import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CareGuideViewModel: ObservableObject {
    @Published var careGuide: CareGuide? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    func fetchCareGuide(for species: String) {
        isLoading = true
        errorMessage = nil
        
        let docId = species.lowercased().trimmingCharacters(in: .whitespaces)
        print("🔍 Attempting to fetch care guide for: [\(docId)] from collection 'care_guides'")
        
        db.collection("care_guides").document(docId).getDocument { snapshot, error in
            self.isLoading = false
            
            if let error = error {
                print("❌ Firestore Error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let snapshot = snapshot else {
                print("⚠️ Snapshot is nil")
                return
            }
            
            if !snapshot.exists {
                print("⚠️ Document does not exist for species: [\(docId)] in 'care_guides'")
                self.errorMessage = "No care guide found for \(species)"
                return
            }
            
            print("✅ Document found! Attempting to decode data...")
            
            do {
                self.careGuide = try snapshot.data(as: CareGuide.self)
                print("🎉 Successfully decoded Care Guide for \(species)")
            } catch {
                print("❌ Decoding Error: \(error)")
                self.errorMessage = "Error decoding care guide: \(error.localizedDescription)"
            }
        }
    }
    
    // Helper to seed initial data (call once if needed)
    func seedCareGuides() {
        let guides = [
            CareGuide(
                speciesName: "rosa hybrida",
                watering: WateringInfo(
                    schedule: "Every 2–3 days in summer, every 5–7 days in cooler months",
                    amount: "300ml per session",
                    tips: [
                        "Check soil moisture before watering — top 2cm should be dry",
                        "Water at the base, never overhead — wet petals cause fungal disease",
                        "Water early morning so leaves dry before evening"
                    ],
                    seasonalCalendar: [
                        "Jan": "every5days", "Feb": "every5days", "Mar": "every3days",
                        "Apr": "every2days", "May": "every2days", "Jun": "every2days",
                        "Jul": "every2days", "Aug": "every2days", "Sep": "every3days",
                        "Oct": "every3days", "Nov": "every5days", "Dec": "every5days"
                    ]
                ),
                sunlight: SunlightInfo(
                    requirement: "Full sun — minimum 6 hours direct sunlight daily",
                    tips: [
                        "Morning sun is preferred over harsh afternoon sun",
                        "In extreme heat, provide light afternoon shade",
                        "Roses in shade produce fewer blooms and are more prone to disease"
                    ]
                ),
                soil: SoilInfo(
                    type: "Sandy loam, slightly acidic (pH 6.0–6.5)",
                    tips: [
                        "Mix compost into native soil at planting for moisture retention",
                        "Mulch around base to conserve moisture and suppress weeds",
                        "Avoid heavy clay — roses need good drainage"
                    ]
                ),
                fertiliser: FertiliserInfo(
                    product: "NPK 10-5-5 or rose-specific fertiliser",
                    frequency: "Every 14 days during growing season",
                    tips: [
                        "Stop fertilising 6 weeks before expected frost",
                        "Use banana peels in soil for natural potassium boost",
                        "Epsom salt (magnesium sulphate) spray promotes lusher foliage"
                    ]
                ),
                pruning: PruningInfo(
                    frequency: "Major prune once per year (late winter), deadhead regularly",
                    tips: [
                        "Cut at 45° angle just above an outward-facing bud",
                        "Remove all dead, crossing, or inward-growing canes",
                        "Sterilise pruning shears before and after use to prevent disease spread"
                    ]
                )
            ),
            CareGuide(
                speciesName: "solanum lycopersicum",
                watering: WateringInfo(
                    schedule: "Every 2 days consistently — irregular watering causes blossom end rot",
                    amount: "450ml per session, more in fruiting stage",
                    tips: [
                        "Consistent soil moisture is critical during fruiting",
                        "Avoid wetting leaves — promotes early blight",
                        "Water deeply to encourage deep root growth"
                    ],
                    seasonalCalendar: [
                        "Jan": "every3days", "Feb": "every3days", "Mar": "every2days",
                        "Apr": "daily", "May": "daily", "Jun": "daily",
                        "Jul": "daily", "Aug": "daily", "Sep": "every2days",
                        "Oct": "every2days", "Nov": "every3days", "Dec": "every3days"
                    ]
                ),
                sunlight: SunlightInfo(
                    requirement: "Full sun — 8+ hours daily",
                    tips: [
                        "Insufficient sun reduces fruit set significantly",
                        "Grow against a south-facing wall for heat reflection",
                        "Use shade cloth during extreme heat above 38°C"
                    ]
                ),
                soil: SoilInfo(
                    type: "Rich loamy soil, pH 6.0–6.8",
                    tips: [
                        "Add plenty of compost before planting",
                        "Calcium-rich soil prevents blossom end rot",
                        "Raised beds warm up faster and improve drainage"
                    ]
                ),
                fertiliser: FertiliserInfo(
                    product: "NPK 5-10-10 (low nitrogen, high phosphorus/potassium)",
                    frequency: "Every 10–14 days",
                    tips: [
                        "Switch to high-potassium fertiliser once fruits set",
                        "Too much nitrogen causes lush foliage but little fruit",
                        "Calcium spray on developing fruits prevents cracking"
                    ]
                ),
                pruning: PruningInfo(
                    frequency: "Pinch suckers weekly",
                    tips: [
                        "Remove suckers from leaf axils for indeterminate varieties",
                        "Stake or cage plants early to support heavy fruit",
                        "Remove lower leaves touching soil to prevent disease splash-up"
                    ]
                )
            ),
            CareGuide(
                speciesName: "monstera deliciosa",
                watering: WateringInfo(
                    schedule: "Every 7 days in summer, every 10–14 days in winter",
                    amount: "500ml or until water drains from pot",
                    tips: [
                        "Allow top 3–4cm of soil to dry between waterings",
                        "Yellowing lower leaves indicate overwatering",
                        "Use room-temperature water — cold water shocks tropical roots"
                    ],
                    seasonalCalendar: [
                        "Jan": "every14days", "Feb": "every14days", "Mar": "every10days",
                        "Apr": "every7days", "May": "every7days", "Jun": "every7days",
                        "Jul": "every7days", "Aug": "every7days", "Sep": "every10days",
                        "Oct": "every10days", "Nov": "every14days", "Dec": "every14days"
                    ]
                ),
                sunlight: SunlightInfo(
                    requirement: "Bright indirect light — no direct sun on leaves",
                    tips: [
                        "Direct sun causes bleaching and brown scorch marks",
                        "Will survive in lower light but grows slower",
                        "Rotate pot quarterly for even leaf development"
                    ]
                ),
                soil: SoilInfo(
                    type: "Well-draining aroid potting mix",
                    tips: [
                        "Add perlite or orchid bark to standard potting mix",
                        "Repot every 2 years or when roots emerge from drainage holes",
                        "Use a pot with drainage holes — Monsteras hate sitting in water"
                    ]
                ),
                fertiliser: FertiliserInfo(
                    product: "Balanced liquid fertiliser (10-10-10)",
                    frequency: "Monthly during growing season, none in winter",
                    tips: [
                        "Half-strength fertiliser is safer than full-strength",
                        "Flush soil every few months to prevent salt build-up",
                        "Leaf shine spray (not chemical) keeps leaves glossy"
                    ]
                ),
                pruning: PruningInfo(
                    frequency: "As needed — trim yellowed leaves and overgrown stems",
                    tips: [
                        "Stem cuttings with a node can be propagated in water",
                        "Wear gloves — Monstera sap can irritate skin",
                        "Cut just below a leaf node for clean healing"
                    ]
                )
            )
        ]
        
        for guide in guides {
            do {
                try db.collection("care_guides").document(guide.speciesName).setData(from: guide)
                print("📤 Seeded Care Guide for \(guide.speciesName)")
            } catch {
                print("❌ Error seeding \(guide.speciesName): \(error)")
            }
        }
    }
}
