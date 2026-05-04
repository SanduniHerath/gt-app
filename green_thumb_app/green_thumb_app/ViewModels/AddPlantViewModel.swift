import SwiftUI
import Combine

@MainActor
class AddPlantViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var species: String = ""
    @Published var location: String = "Front garden"
    @Published var potType: String = "Ground"
    @Published var datePlanted: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 14)) ?? Date()
    @Published var notes: String = ""
    @Published var tags: [String] = ["Flowering", "Outdoor", "Fragrant"]
    
    // Options
    let locationOptions = ["Front garden", "Back garden", "Balcony", "Living Room", "Kitchen"]
    let potTypeOptions = ["Ground", "Ceramic Pot", "Plastic Pot", "Terracotta", "Raised Bed"]
    
    // Actions
    var onSave: ((PlantModel) -> Void)?
    var onCancel: (() -> Void)?
    
    func savePlant() {
        // Logic to save the plant to the repository would go here
        // Creating a mock plant model to pass to the next view
        let ageDays = Calendar.current.dateComponents([.day], from: datePlanted, to: Date()).day ?? 0
        
        let newPlant = PlantModel(
            name: name,
            species: species,
            status: .healthy,
            healthScore: 100,
            imageURL: "plant_rose", // Default or selected image
            location: location,
            dateAdded: Date(),
            tags: tags,
            isOutdoor: potType == "Ground",
            ageDays: ageDays
        )
        
        print("Saving plant: \(name)")
        onSave?(newPlant)
    }
    
    func addTag() {
        // Mock add tag logic
        tags.append("New Tag")
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}
