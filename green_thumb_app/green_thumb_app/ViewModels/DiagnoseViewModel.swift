import Foundation
import Combine

@MainActor
class DiagnoseViewModel: ObservableObject {
    @Published var symptomText: String = ""
    @Published var selectedSymptoms: [String] = []
    @Published var severity: Double = 0.5 // 0.0: Mild, 0.5: Moderate, 1.0: Severe
    @Published var selectedParts: Set<String> = ["Leaves", "Roots"]
    @Published var selectedPlant: PlantModel? = PlantModel.samples[1] // Default to Rose Bush
    
    @Published var diagnosisResult: String? = nil
    @Published var isAnalyzing: Bool = false

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.diagnosisResult = "Possible overwatering detected. Reduce watering frequency and ensure good drainage."
            self.isAnalyzing = false
        }
    }
}
