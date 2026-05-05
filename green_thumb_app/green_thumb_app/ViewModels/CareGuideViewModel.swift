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
        let speciesName = "rosa hybrida" // Changed from 'rose' to 'rosa' to match your plant!
        let roseHybrida = CareGuide(
            speciesName: speciesName,
            wateringSchedule: "Water deeply every 2–3 days in summer and every 5–7 days in cooler months. Aim for 300ml per session",
            wateringAmount: "300ml/session",
            wateringFrequency: "2-3 days",
            wateringTips: [
                "Always check soil moisture before watering – insert finger 2cm deep.",
                "Use room-temperature water. Cold water can shock the roots.",
                "Avoid wetting the leaves to prevent fungal diseases."
            ],
            fertilizerInfo: "Use a balanced 10-10-10 fertilizer. Apply at the base of the plant.",
            fertilizerFrequency: "Monthly during growing season",
            safetyTips: [
                "Wear gloves when handling chemicals.",
                "Keep away from children and pets.",
                "Never exceed recommended dosage"
            ],
            seasonalCalendar: [2, 2, 3, 4, 5, 5, 5, 5, 4, 3, 2, 2]
        )
        
        do {
            try db.collection("care_guides").document(speciesName).setData(from: roseHybrida)
            print("📤 Seeded Care Guide for \(speciesName)")
        } catch {
            print("❌ Error seeding: \(error)")
        }
    }
}
