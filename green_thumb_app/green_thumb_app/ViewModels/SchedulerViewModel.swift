import Foundation
import Combine
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SchedulerViewModel: ObservableObject {
    @Published var tasks: [SchedulerTaskModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let collectionName = "scheduler_tasks"
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        // fetchTasks() // Only uncomment to fetch all tasks globally
        // seedTasks()  // Only uncomment once to seed
    }

    func seedTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // 1. DELETE all old tasks first to ensure a clean slate
        db.collection(collectionName).whereField("userId", isEqualTo: userId).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { $0.reference.delete() }
            
            // 2. NOW create the fresh, correct tasks
            self.db.collection("users").document(userId).collection("plants").getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                
                for doc in docs {
                    let plantId = doc.documentID
                    let plantName = doc.data()["name"] as? String ?? "Plant"
                    
                    let taskData: [(TaskType, Date, String)] = [
                        (.water,     Date(), "Morning session: 300ml"),
                        (.fertilize, Date(), "Use rose-specific liquid feed"),
                        (.prune,     Calendar.current.date(byAdding: .day, value: 1, to: Date())!, "Remove spent blooms"),
                        (.inspect,   Calendar.current.date(byAdding: .day, value: 2, to: Date())!, "Check for aphids under leaves")
                    ]
                    
                    for (type, date, note) in taskData {
                        let taskId = "\(plantId)-\(type.rawValue)"
                        let task = SchedulerTaskModel(
                            id: taskId, userId: userId, plantId: plantId, plantName: plantName,
                            taskType: type, dueDate: date, notes: note
                        )
                        try? self.db.collection(self.collectionName).document(task.id).setData(from: task)
                    }
                }
                print("✅ Clean Sweep Complete! Your database is now tidy.")
            }
        }
    }

    func fetchTasks(for plantId: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        // 1. STOP any existing listener so it doesn't fight with the new one
        listenerRegistration?.remove()
        
        var query = db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
        
        // 2. APPLY strict plant filter if provided
        if let pid = plantId, !pid.isEmpty {
            query = query.whereField("plantId", isEqualTo: pid)
            print("🔍 Filtering tasks for plant ID: \(pid)")
        } else {
            print("📋 Fetching all tasks for user")
        }
        
        // 3. START the fresh listener
        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("❌ Firestore Error: \(error.localizedDescription)")
                return
            }
            
            let fetchedTasks = snapshot?.documents.compactMap { doc in
                try? doc.data(as: SchedulerTaskModel.self)
            } ?? []
            
            // Sort by date and time
            self.tasks = fetchedTasks.sorted(by: { $0.dueDate < $1.dueDate })
            print("✅ Successfully fetched \(self.tasks.count) tasks")
        }
    }

    func toggleTask(_ task: SchedulerTaskModel) {
        let docRef = db.collection(collectionName).document(task.id)
        docRef.updateData(["isCompleted": !task.isCompleted]) { error in
            if let error = error {
                print("❌ Error updating task: \(error.localizedDescription)")
            }
        }
    }
    
    func addTask(plantId: String, plantName: String, type: TaskType, dueDate: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newTask = SchedulerTaskModel(
            userId: userId,
            plantId: plantId,
            plantName: plantName,
            taskType: type,
            dueDate: dueDate
        )
        
        do {
            try db.collection(collectionName).document(newTask.id).setData(from: newTask)
        } catch {
            print("❌ Error adding task: \(error.localizedDescription)")
        }
    }

    var pendingTasks: [SchedulerTaskModel] { tasks.filter { !$0.isCompleted } }
    var completedTasks: [SchedulerTaskModel] { tasks.filter { $0.isCompleted } }
    
    // Group tasks by date for the calendar/list with duplicate prevention
    func tasks(for date: Date) -> [SchedulerTaskModel] {
        let dayTasks = tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        
        // Final safety check: ensure unique tasks in the UI
        var uniqueTasks: [SchedulerTaskModel] = []
        var seenKeys: Set<String> = []
        
        for task in dayTasks {
            let key = "\(task.plantId)-\(task.taskType.rawValue)"
            if !seenKeys.contains(key) {
                uniqueTasks.append(task)
                seenKeys.insert(key)
            }
        }
        
        return uniqueTasks
    }
}

