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
    
    // Navigation
    var onSave: ((PlantModel) -> Void)?
    var onCancel: (() -> Void)?
    
    private var plant: PlantModel?
    
    init(plant: PlantModel? = nil) {
        self.plant = plant
        self.selectedPlant = plant?.name ?? "Rose Bush"
        self.species = plant?.species ?? "Rosa hybrida"
        self.location = plant?.location ?? "Front garden"
        self.potGroundType = plant?.isOutdoor ?? true ? "Ground" : "Pot"
        self.tags = plant?.tags ?? ["Flowering", "Outdoor", "Fragrant"]
    }
    
    // Options
    let plantOptions = ["Rose Bush", "Tomatoes", "Monstera", "Boston Fern"]
    let locationOptions = ["Front garden", "Back garden", "Living room", "Balcony"]
    let typeOptions = ["Pot", "Ground", "Hydroponic"]
    let availableTags = ["Flowering", "Outdoor", "Fragrant", "Indoor", "Tropical"]

    func saveObservation() {
        guard var updatedPlant = plant else { return }
        
        let newEntry = CareLogEntry(
            type: .observation,
            date: Date(),
            title: "Observation",
            note: observationNote
        )
        
        updatedPlant.careLogs.append(newEntry)
        
        print("Saving observation to Firebase for \(updatedPlant.name)")
        onSave?(updatedPlant)
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
