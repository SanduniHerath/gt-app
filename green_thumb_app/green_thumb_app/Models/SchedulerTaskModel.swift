import Foundation

enum TaskType: String, Codable, CaseIterable {
    case water    = "Water"
    case fertilize = "Fertilize"
    case repot    = "Repot"
    case prune    = "Prune"
    case inspect  = "Inspect"
    case mist     = "Mist"

    var icon: String {
        switch self {
        case .water:     return "💧"
        case .fertilize: return "🌿"
        case .repot:     return "🪴"
        case .prune:     return "✂️"
        case .inspect:   return "🔍"
        case .mist:      return "💦"
        }
    }
}

struct SchedulerTaskModel: Identifiable, Codable {
    let id: UUID
    var plantId: UUID
    var plantName: String
    var taskType: TaskType
    var dueDate: Date
    var isCompleted: Bool
    var notes: String?

    init(id: UUID = .init(), plantId: UUID = .init(), plantName: String,
         taskType: TaskType, dueDate: Date, isCompleted: Bool = false, notes: String? = nil) {
        self.id = id; self.plantId = plantId; self.plantName = plantName
        self.taskType = taskType; self.dueDate = dueDate
        self.isCompleted = isCompleted; self.notes = notes
    }
}

extension SchedulerTaskModel {
    static let samples: [SchedulerTaskModel] = [
        SchedulerTaskModel(plantName: "Monstera",    taskType: .water,     dueDate: .now),
        SchedulerTaskModel(plantName: "Peace Lily",  taskType: .fertilize, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: .now)!),
        SchedulerTaskModel(plantName: "Pothos",      taskType: .mist,      dueDate: Calendar.current.date(byAdding: .day, value: 2, to: .now)!),
        SchedulerTaskModel(plantName: "Snake Plant", taskType: .inspect,   dueDate: Calendar.current.date(byAdding: .day, value: 3, to: .now)!),
    ]
}

