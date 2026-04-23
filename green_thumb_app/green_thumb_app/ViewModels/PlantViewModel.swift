import Foundation
import Combine
import SwiftUI

@MainActor
class PlantViewModel: ObservableObject {
    @Published var plants: [PlantModel] = PlantModel.samples
    @Published var selectedPlant: PlantModel? = nil
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    var filteredPlants: [PlantModel] {
        guard !searchText.isEmpty else { return plants }
        return plants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.species.localizedCaseInsensitiveContains(searchText)
        }
    }

    func addPlant(_ plant: PlantModel) { plants.append(plant) }
    func removePlant(at offsets: IndexSet) { plants.remove(atOffsets: offsets) }
    func updatePlant(_ plant: PlantModel) {
        if let idx = plants.firstIndex(where: { $0.id == plant.id }) { plants[idx] = plant }
    }
}
