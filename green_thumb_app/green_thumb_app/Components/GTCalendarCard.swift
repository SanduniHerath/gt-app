import SwiftUI

struct GTCalendarCard: View {
    @Binding var selectedDate: Date
    let taskDates: [Date] // Dates that should have a blue dot
    let days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    
    // Logic for May 2026
    private var monthName: String {
        selectedDate.formatted(.dateTime.month(.wide).year())
    }
    
    private var dates: [Int] { Array(1...31) }
    private var startOffset: Int { 5 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Month Header
            HStack {
                Text(monthName)
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { changeMonth(by: -1) }) {
                        calendarNavButton(icon: "chevron.left")
                    }
                    Button(action: { changeMonth(by: 1) }) {
                        calendarNavButton(icon: "chevron.right")
                    }
                }
            }
            
            // Calendar Content
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextPrimary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                    ForEach(0..<startOffset, id: \.self) { _ in
                        Text("").frame(height: 36)
                    }
                    
                    ForEach(dates, id: \.self) { date in
                        let isSelected = Calendar.current.component(.day, from: selectedDate) == date
                        let isToday = Calendar.current.isDateInToday(selectedDate) && Calendar.current.component(.day, from: Date()) == date
                        let hasTask = hasTaskOn(day: date)
                        
                        VStack(spacing: 4) {
                            Text("\(date)")
                                .font(GTFont.bodyMedium())
                                .foregroundColor(isSelected ? .white : .gtTextPrimary)
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isSelected ? Color.gtDarkGreen : (isToday ? Color.gtDarkGreen.opacity(0.1) : Color.clear))
                                )
                            
                            // Task Indicator Dot
                            Circle()
                                .fill(hasTask ? Color.gtBadgeTealBg : Color.clear)
                                .frame(width: 4, height: 4)
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            updateSelectedDate(day: date)
                        }
                    }
                }
            }
            
            HStack(spacing: 6) {
                Circle().fill(Color.gtBadgeTealBg).frame(width: 8, height: 8)
                Text("Scheduled Tasks").font(GTFont.bodySmall()).foregroundColor(Color.gtTextMuted)
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white).gtShadow(GTShadow.card))
    }
    
    private func hasTaskOn(day: Int) -> Bool {
        taskDates.contains { date in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let currentMonthComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
            return components.year == currentMonthComponents.year && 
                   components.month == currentMonthComponents.month && 
                   components.day == day
        }
    }
    
    private func calendarNavButton(icon: String) -> some View {
        ZStack {
            Circle().fill(Color.white).frame(width: 32, height: 32).gtShadow(GTShadow.card)
            Image(systemName: icon).font(.system(size: 14, weight: .bold)).foregroundColor(.gtTextPrimary)
        }
    }
    
    private func updateSelectedDate(day: Int) {
        var components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        components.day = day
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
    
    private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

#Preview {
    GTCalendarCard(selectedDate: .constant(Date()), taskDates: [])
        .padding()
        .background(Color.gtTreatmentBg)
}
