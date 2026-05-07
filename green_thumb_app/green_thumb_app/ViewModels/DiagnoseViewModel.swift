import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class DiagnoseViewModel: ObservableObject {
    @Published var symptomText: String = ""
    @Published var selectedSymptoms: [String] = []
    @Published var severity: Double = 0.5 // 0.0: Mild, 0.5: Moderate, 1.0: Severe
    @Published var selectedParts: Set<String> = ["Leaves", "Roots"]
    @Published var selectedPlant: PlantModel? = nil   // Set by SymptomCheckerView plant picker
    
    @Published var currentResult: DiagnosisResultData? = nil
    @Published var isAnalyzing: Bool = false
    @Published var knowledgeBase: [DiagnosisResultData] = []
    
    private let db = Firestore.firestore()
    
    init() {
        fetchKnowledgeBase()
        //seedDatabase()
    }
    
    func fetchKnowledgeBase() {
        db.collection("diagnoses").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching knowledge base: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("⚠️ No documents found in 'diagnoses' collection")
                return
            }
            
            print("🔍 Found \(documents.count) raw documents in Firestore. Attempting to decode...")
            
            self.knowledgeBase = documents.compactMap { doc -> DiagnosisResultData? in
                do {
                    let data = try doc.data(as: DiagnosisResultData.self)
                    return data
                } catch {
                    print("❌ Decoding failed for doc \(doc.documentID): \(error)")
                    return nil
                }
            }
            
            print("✅ Successfully loaded \(self.knowledgeBase.count) diagnoses from Firestore")
        }
    }
    
    // Call this function ONCE to populate your Firestore with the initial data
    func seedDatabase() {
        let initialData = [
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
        
        for diagnosis in initialData {
            do {
                try db.collection("diagnoses").addDocument(from: diagnosis)
                print("📤 Uploaded \(diagnosis.name) to Firestore")
            } catch {
                print("❌ Error seeding: \(error)")
            }
        }
    }
    
    let commonSymptoms = [
        "Yellow leaves", "Brown spots", "Wilting",
        "White powder", "Sticky residue", "Holes in leaves",
        "Slow growth", "Root smell"
    ]
    
    let affectedParts = ["Leaves", "Stems", "Roots", "Buds", "Whole", "Fruit"]
    
    func toggleSymptom(_ symptom: String) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.removeAll { $0 == symptom }
        } else {
            selectedSymptoms.append(symptom)
        }
    }
    
    func togglePart(_ part: String) {
        if selectedParts.contains(part) {
            selectedParts.remove(part)
        } else {
            selectedParts.insert(part)
        }
    }
    
    func analyze() {
        isAnalyzing = true
        
        // Simple matching logic
        let userSymptoms = Set(selectedSymptoms)
        
        var bestMatch: DiagnosisResultData? = nil
        var highestScore = -1
        
        // Use the data loaded from Firestore
        for entry in knowledgeBase {
            let entrySymptoms = Set(entry.symptomsMatch)
            let intersection = userSymptoms.intersection(entrySymptoms)
            let score = intersection.count
            
            if score > highestScore && score > 0 {
                highestScore = score
                bestMatch = entry
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Fallback to the first available diagnosis if no perfect match found
            let result = bestMatch ?? self.knowledgeBase.first
            self.currentResult = result
            self.isAnalyzing = false
            
            // ✅ Write diagnosis result back to the plant in Firestore
            if let diagnosis = result, let plant = self.selectedPlant {
                self.updatePlantHealth(plant: plant, diagnosis: diagnosis)
            }
            
            // 🔔 Schedule 7-day follow-up reminder
            if let diagnosis = result {
                let plantName = self.selectedPlant?.name ?? "your plant"
                NotificationManager.shared.scheduleIntervalNotification(
                    id: "followup-\(diagnosis.name)-\(Date().timeIntervalSince1970)",
                    title: "Disease Check Reminder 🔍",
                    body: "Check your \(plantName) — it has been 7 days since your \(diagnosis.name.lowercased()) diagnosis.",
                    interval: 7 * 24 * 60 * 60 // 7 days in seconds
                )
            }
        }
    }
    
    // MARK: - Write Diagnosis Back to Plant
    private func updatePlantHealth(plant: PlantModel, diagnosis: DiagnosisResultData) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ Cannot update plant health: No user logged in")
            return
        }
        
        // Severity (0.0 mild → 1.0 severe) drives health penalty: up to -45 pts
        let severityPenalty = severity * 45.0
        let newHealthScore  = max(10.0, plant.healthScore - severityPenalty)
        let newStatus       = newHealthScore < 50 ? PlantStatus.critical.rawValue
        : PlantStatus.warning.rawValue
        
        let docRef = Firestore.firestore()
            .collection("users").document(userId)
            .collection("plants").document(plant.id.uuidString)
        
        docRef.updateData([
            "healthScore":        newHealthScore,
            "status":             newStatus,
            "lastDiagnosisName": diagnosis.name,
            "lastDiagnosisDate": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("❌ Failed to update plant health: \(error.localizedDescription)")
            } else {
                print("✅ Plant health updated → \(plant.name): \(diagnosis.name) | score: \(Int(newHealthScore))%")
            }
        }
    }
    
}
