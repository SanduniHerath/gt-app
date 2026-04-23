import SwiftUI

struct SmartSchedulerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentAppTab = 1 // My Garden tab is active in the screenshot
    @State private var completedTaskIds: Set<String> = ["task_tomatoes"] // Tomatoes starts as done
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Dark Green Header
            ZStack(alignment: .topLeading) {
                Color.gtForestGreen
                    .frame(height: 180)
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        dismiss()
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
                    .padding(.top, 44)
                    
                    Text("Schedular")
                        .font(GTFont.displayLarge())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Calendar
                    GTCalendarCard()
                        .padding(.top, 8)
                    
                    // Tasks Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tasks – Today")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        
                        VStack(spacing: 12) {
                            GTSchedulerTaskRow(
                                title: "Water Tomatoes",
                                subtitle: "Back garden – 250ml",
                                time: "Done",
                                frequency: "",
                                iconName: "shield.fill",
                                iconBgColor: Color.gtBadgeGreenBg,
                                iconColor: Color.gtBadgeGreenText,
                                isDone: completedTaskIds.contains("task_tomatoes"),
                                onTap: { toggleTask("task_tomatoes") }
                            )
                            
                            GTSchedulerTaskRow(
                                title: "Water Rose Bush",
                                subtitle: "Front garden – 300ml",
                                time: "2.00 PM",
                                frequency: "Every 2 days",
                                iconName: "drop.fill",
                                iconBgColor: Color.gtBadgeTealBg,
                                iconColor: Color.gtBadgeTealText,
                                isDone: completedTaskIds.contains("task_rose"),
                                onTap: { toggleTask("task_rose") }
                            )
                            
                            GTSchedulerTaskRow(
                                title: "Fertilise Basil",
                                subtitle: "Balcony pot – NPK 10–10–10",
                                time: "5.00 PM",
                                frequency: "Every 14 days",
                                iconName: "square.grid.2x2.fill",
                                iconBgColor: Color.gtBadgeYellowBg,
                                iconColor: Color.gtBadgeYellowText,
                                isDone: completedTaskIds.contains("task_basil"),
                                onTap: { toggleTask("task_basil") }
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(24)
            }
            .background(Color.gtTreatmentBg)
            
            // Tab Bar
            GTTabBar(selectedTab: $currentAppTab)
        }
        .navigationBarHidden(true)
        .background(Color.gtForestGreen.ignoresSafeArea())
    }
    
    private func toggleTask(_ id: String) {
        if completedTaskIds.contains(id) {
            completedTaskIds.remove(id)
        } else {
            completedTaskIds.insert(id)
        }
    }
}

#Preview {
    SmartSchedulerView()
}
