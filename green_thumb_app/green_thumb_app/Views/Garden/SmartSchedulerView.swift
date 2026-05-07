import SwiftUI

struct SmartSchedulerView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var viewModel: SchedulerViewModel
    @State private var selectedDate = Date()
    
    // Optional plantId filter
    var plantId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Dark Green Header
            ZStack(alignment: .topLeading) {
                Color.gtForestGreen
                    .frame(height: 180)
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        router.pop()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 24)
                    
                    Text("Scheduler")
                        .font(GTFont.displayLarge())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Calendar
                    GTCalendarCard(
                        selectedDate: $selectedDate,
                        taskDates: viewModel.tasks.map { $0.dueDate }
                    )
                    .padding(.top, 8)
                    
                    // Tasks Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(Calendar.current.isDateInToday(selectedDate) ? "Tasks – Today" : "Tasks – \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            let dayTasks = viewModel.tasks(for: selectedDate)
                            
                            if dayTasks.isEmpty {
                                Text("No tasks scheduled for this day.")
                                    .font(GTFont.bodySmall())
                                    .foregroundColor(.gtTextSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(dayTasks) { task in
                                        GTSchedulerTaskRow(
                                            title: "\(task.taskType.rawValue) \(task.plantName)",
                                            subtitle: task.notes ?? "Regular maintenance",
                                            time: task.isCompleted ? "Done" : task.dueDate.formatted(date: .omitted, time: .shortened),
                                            frequency: "", // Can add this to model later
                                            iconName: iconForType(task.taskType),
                                            iconBgColor: bgColorForType(task.taskType),
                                            iconColor: colorForType(task.taskType),
                                            isDone: task.isCompleted,
                                            onTap: { viewModel.toggleTask(task) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(24)
            }
            .background(Color.gtTreatmentBg)
        }
        .navigationBarHidden(true)
        .background(Color.gtForestGreen.ignoresSafeArea())
        .onAppear {
            viewModel.fetchTasks(for: plantId)
        }
    }
    
    private func iconForType(_ type: TaskType) -> String {
        switch type {
        case .water: return "drop.fill"
        case .fertilize: return "shield.fill"
        case .repot: return "leaf.fill"
        default: return "info.circle.fill"
        }
    }
    
    private func bgColorForType(_ type: TaskType) -> Color {
        switch type {
        case .water: return Color.gtBadgeTealBg
        case .fertilize: return Color.gtBadgeGreenBg
        case .repot: return Color.gtBadgeYellowBg
        default: return Color.gtBadgeTealBg
        }
    }
    
    private func colorForType(_ type: TaskType) -> Color {
        switch type {
        case .water: return Color.gtBadgeTealText
        case .fertilize: return Color.gtBadgeGreenText
        case .repot: return Color.gtBadgeYellowText
        default: return Color.gtBadgeTealText
        }
    }
}

#Preview {
    SmartSchedulerView()
}
