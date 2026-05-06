import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreData

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
    
    // MARK: - Fetch Plants (Real-time with Local Cache)
    func fetchPlants() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.plants = []
            return
        }
        
        isLoading = true
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("users").document(uid).collection("plants")
            .order(by: "dateAdded", descending: true)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                
                if let error = error {
                    print("⚠️ Firestore Offline/Error: \(error.localizedDescription). Switching to Local Cache.")
                    self.loadFromLocalCache(uid: uid) // 💾 Fallback to Disk
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                
                let fetchedPlants = documents.compactMap { doc -> PlantModel? in
                    try? doc.data(as: PlantModel.self)
                }
                
                self.plants = fetchedPlants
                
                // 💾 Update Local Cache
                self.syncToLocalCache(fetchedPlants, uid: uid)
            }
    }
    
    // MARK: - Core Data Sync
    private func syncToLocalCache(_ plants: [PlantModel], uid: String) {
        let context = PersistenceController.shared.container.viewContext
        
        // 1. Clear old cache for this user
        clearLocalCache(uid: uid)
        
        // 2. Add new data
        for plant in plants {
            let cached = CachedPlant(context: context)
            cached.id = plant.id.uuidString
            cached.name = plant.name
            cached.species = plant.species
            cached.userId = uid
            cached.imageURL = plant.imageURL
        }
        
        PersistenceController.shared.save()
    }
    
    private func loadFromLocalCache(uid: String) {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<CachedPlant> = NSFetchRequest(entityName: "CachedPlant")
        request.predicate = NSPredicate(format: "userId == %@", uid)
        
        do {
            let cachedItems = try context.fetch(request)
            self.plants = cachedItems.map { cached in
                PlantModel(
                    id: UUID(uuidString: cached.id ?? "") ?? UUID(),
                    name: cached.name ?? "",
                    species: cached.species ?? "",
                    imageURL: cached.imageURL
                )
            }
            print("💾 Successfully loaded \(self.plants.count) plants from Local Core Data!")
        } catch {
            print("❌ Failed to fetch from Core Data: \(error)")
        }
    }
    
    private func clearLocalCache(uid: String) {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedPlant")
        request.predicate = NSPredicate(format: "userId == %@", uid)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("❌ Error clearing cache: \(error)")
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
            
            // 🔔 Immediate notification for demo
            NotificationManager.shared.sendImmediateNotification(
                id: "add-plant-\(plant.id.uuidString)",
                title: "New Plant Added! 🪴",
                body: "\(plant.name) has been successfully added to your garden."
            )
            
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
        // We use a non-isolated way to remove the listener
        let listener = listenerRegistration
        listener?.remove()
    }
}
