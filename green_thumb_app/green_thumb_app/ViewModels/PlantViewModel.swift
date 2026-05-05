import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PlantViewModel: ObservableObject {
    @Published var plants: [PlantModel] = []
    @Published var selectedPlant: PlantModel? = nil
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init() {
        fetchPlants()
    }

    var filteredPlants: [PlantModel] {
        guard !searchText.isEmpty else { return plants }
        return plants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.species.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Fetch Plants (Real-time)
    func fetchPlants() {
        guard let uid = Auth.auth().currentUser?.uid else { 
            self.plants = [] // No user logged in
            return 
        }

        isLoading = true
        
        // Remove existing listener if any
        listenerRegistration?.remove()

        // Set up real-time listener for this user's plants
        listenerRegistration = db.collection("users").document(uid).collection("plants")
            .order(by: "dateAdded", descending: true)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let documents = querySnapshot?.documents else { return }
                
                // Decode Firestore documents into PlantModel array
                self.plants = documents.compactMap { doc -> PlantModel? in
                    try? doc.data(as: PlantModel.self)
                }
            }
    }

    // MARK: - Add Plant
    func addPlant(_ plant: PlantModel) {
        guard let uid = Auth.auth().currentUser?.uid else { 
            print("❌ Cannot add plant: No user logged in")
            return 
        }
        
        print("Saving plant to Firestore for user: \(uid)")
        
        do {
            try db.collection("users").document(uid).collection("plants")
                .document(plant.id.uuidString)
                .setData(from: plant)
            print("✅ Plant saved successfully!")
        } catch {
            self.errorMessage = "Could not save plant: \(error.localizedDescription)"
            print("❌ Firestore Save Error: \(error.localizedDescription)")
        }
    }


    // MARK: - Remove Plant
    func removePlant(at offsets: IndexSet) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        for index in offsets {
            let plant = plants[index]
            db.collection("users").document(uid).collection("plants")
                .document(plant.id.uuidString)
                .delete()
        }
    }

    // MARK: - Update Plant
    func updatePlant(_ plant: PlantModel) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("users").document(uid).collection("plants")
                .document(plant.id.uuidString)
                .setData(from: plant, merge: true)
        } catch {
            self.errorMessage = "Could not update plant: \(error.localizedDescription)"
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
