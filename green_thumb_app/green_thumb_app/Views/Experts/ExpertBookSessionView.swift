import SwiftUI

struct ExpertBookSessionView: View {
    let expert: ExpertModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var expertVM: ExpertViewModel
    @EnvironmentObject var notifyVM: NotificationsViewModel
    
    @State private var selectedDate: String = "3"
    @State private var selectedTime: String = "3:00 PM"
    
    let timeSlots = ["9:00 AM", "11:00 AM", "3:00 PM", "5:00 PM", "6:00 PM"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.pop() }) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.left")
                            .foregroundColor(.gtForestGreen)
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                
                Text("Schedule Session")
                    .font(GTFont.displaySmall())
                    .foregroundColor(.gtTextPrimary)
                    .padding(.leading, GTSpacing.md)
                
                Spacer()
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.top, 80)
            
            // Expert Info
            HStack(spacing: GTSpacing.md) {
                ZStack {
                    Circle()
                        .fill(avatarColor)
                        .frame(width: 64, height: 64)
                    Text(initials)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(expert.name)
                        .font(GTFont.displaySmall())
                        .font(.system(size: 20))
                        .foregroundColor(.gtTextPrimary)
                    
                    Text("\(expert.specialty) – \(expert.department),")
                        .font(GTFont.labelSmall())
                        .foregroundColor(.gtAccentGreen)
                    Text(expert.location)
                        .font(GTFont.labelSmall())
                        .foregroundColor(.gtAccentGreen)
                }
                
                Spacer()
            }
            .padding(GTSpacing.lg)
            .padding(.top, GTSpacing.md)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: GTSpacing.xl) {
                    
                    // Availability this week
                    AvailabilityCalendarView(selectedDate: $selectedDate)
                    
                    // Available time slots
                    VStack(alignment: .leading, spacing: GTSpacing.lg) {
                        Text("Available time slots")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        
                        FlowLayout(spacing: 12) {
                            ForEach(timeSlots, id: \.self) { time in
                                TimeSlotButton(time: time, isSelected: selectedTime == time) {
                                    selectedTime = time
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Confirm Button
                    Button(action: {
                        // Create a mock date for the selected day in current week
                        let date = Date() // In a real app, calculate based on selectedDate
                        expertVM.bookSession(expert: expert, date: date, timeSlot: selectedTime)
                    }) {
                        HStack {
                            Spacer()
                            Text("Confirm Session")
                                .font(GTFont.buttonLarge())
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                        }
                        .padding(.vertical, 20)
                        .background(Color.gtDarkGreen)
                        .foregroundColor(.white)
                        .cornerRadius(GTRadius.xl)
                    }
                }
                .padding(GTSpacing.lg)
            }
        }
        .background(Color(hex: "D9D9D9")) // Matched gray background
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .onChange(of: expertVM.bookingSuccess) { success in
            if success {
                // Add notification
                notifyVM.addNotification(
                    type: .expert,
                    title: "Session Confirmed",
                    message: "Success! Your session with \(expert.name) on May \(selectedDate) at \(selectedTime) is confirmed."
                )
                
                // Navigate
                router.navigate(to: .notifications)
                
                // Reset flag
                expertVM.bookingSuccess = false
            }
        }
    }
    
    private var initials: String {
        expert.name.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .suffix(2)
            .joined()
            .uppercased()
    }
    
    private var avatarColor: Color {
        if initials.contains("N") { return Color.gtBadgePurpleText.opacity(0.7) }
        return Color.gtBadgeTealText.opacity(0.7)
    }
}

// MARK: - Subviews
struct AvailabilityCalendarView: View {
    @Binding var selectedDate: String
    let days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    let dates = ["", "1", "2", "3", "4", "5", "6"]
    let availableDates = ["3", "4", "5"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.lg) {
            Text("Availability this week")
                .font(GTFont.labelLarge())
                .foregroundColor(.gtTextPrimary)
            
            HStack(spacing: 0) {
                ForEach(0..<days.count, id: \.self) { idx in
                    VStack(spacing: 12) {
                        Text(days[idx])
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextSecondary)
                        
                        Button(action: {
                            if availableDates.contains(dates[idx]) {
                                selectedDate = dates[idx]
                            }
                        }) {
                            ZStack {
                                if dates[idx] == selectedDate {
                                    RoundedRectangle(cornerRadius: GTRadius.sm)
                                        .fill(Color.gtForestGreen)
                                        .frame(width: 44, height: 44)
                                } else if availableDates.contains(dates[idx]) {
                                    RoundedRectangle(cornerRadius: GTRadius.sm)
                                        .fill(Color.gtLightGreen.opacity(0.5))
                                        .frame(width: 44, height: 44)
                                }
                                
                                Text(dates[idx])
                                    .font(GTFont.bodyLarge())
                                    .foregroundColor(dates[idx] == selectedDate ? .white : (dates[idx].isEmpty ? .clear : .gtTextPrimary))
                            }
                        }
                        .disabled(!availableDates.contains(dates[idx]))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct TimeSlotButton: View {
    let time: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(time)
                .font(GTFont.labelSmall())
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: GTRadius.sm)
                        .fill(isSelected ? Color.gtForestGreen : buttonBg)
                )
                .foregroundColor(isSelected ? .white : .gtTextPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: GTRadius.sm)
                        .stroke(isSelected ? Color.clear : Color.gtSeparator, lineWidth: 1)
                )
        }
    }
    
    private var buttonBg: Color {
        if time == "5:00 PM" || time == "6:00 PM" {
            return Color.gtLightGreen.opacity(0.3)
        }
        return .white
    }
}

#Preview {
    ExpertBookSessionView(expert: ExpertModel.samples[0])
        .environmentObject(AppRouter())
}
