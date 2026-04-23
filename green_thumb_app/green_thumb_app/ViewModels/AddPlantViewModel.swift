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
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    
    func savePlant() {
        // Logic to save the plant to the repository would go here
        print("Saving plant: \(name)")
        onSave?()
    }
    
    func addTag() {
        // Mock add tag logic
        tags.append("New Tag")
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}
