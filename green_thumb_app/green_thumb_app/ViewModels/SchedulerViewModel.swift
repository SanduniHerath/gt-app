import Foundation
import Combine
import SwiftUI

@MainActor
class SchedulerViewModel: ObservableObject {
    @Published var tasks: [SchedulerTaskModel] = SchedulerTaskModel.samples

    func toggleTask(_ task: SchedulerTaskModel) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx].isCompleted.toggle()
        }
    }
    func addTask(_ task: SchedulerTaskModel) { tasks.append(task) }
    func removeTask(at offsets: IndexSet) { tasks.remove(atOffsets: offsets) }
    var pendingTasks: [SchedulerTaskModel] { tasks.filter { !$0.isCompleted } }
    var completedTasks: [SchedulerTaskModel] { tasks.filter { $0.isCompleted } }
}

