import SwiftUI
import Combine

class AddObservationViewModel: ObservableObject {
    // Form data
    @Published var selectedPlant: String
    @Published var species: String
    @Published var location: String
    @Published var potGroundType: String
    @Published var tags: [String]
    @Published var observationNote: String = ""
    
    init(plant: PlantModel? = nil) {
        self.selectedPlant = plant?.name ?? "Rose Bush"
        self.species = plant?.species ?? "Rosa hybrida"
        self.location = plant?.location ?? "Front garden"
        self.potGroundType = plant?.soilType ?? "Ground" // Map soilType to pot/ground for now
        self.tags = plant?.tags ?? ["Flowering", "Outdoor", "Fragrant"]
    }
    
    // Options
    let plantOptions = ["Rose Bush", "Tomatoes", "Monstera", "Boston Fern"]
    let locationOptions = ["Front garden", "Back garden", "Living room", "Balcony"]
    let typeOptions = ["Pot", "Ground", "Hydroponic"]
    let availableTags = ["Flowering", "Outdoor", "Fragrant", "Indoor", "Tropical"]
    
    // Navigation
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    
    func saveObservation() {
        // In a real app, this would create a CareLogEntry and save it to the PlantModel
        print("Saving observation: \(observationNote) for \(selectedPlant)")
        onSave?()
    }
    
    func addTag() {
        // Logic to show a tag picker or add a custom tag
        if let newTag = availableTags.first(where: { !tags.contains($0) }) {
            tags.append(newTag)
        }
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}
