import SwiftUI

struct GTCalendarCard: View {
    let days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    let dates = Array(1...30) // Simplified for April 2026
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Month Header
            HStack {
                Text("April 2026")
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .gtShadow(GTShadow.card)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.gtTextPrimary)
                        }
                    }
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .gtShadow(GTShadow.card)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.gtTextPrimary)
                        }
                    }
                }
            }
            
            // Calendar Content
            VStack(spacing: 16) {
                // Days Row
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextPrimary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Dates Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                    // Offset for April 2026 starting on Wednesday
                    ForEach(0..<3, id: \.self) { _ in
                        Text("")
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                    }
                    
                    ForEach(dates, id: \.self) { date in
                        let isToday = (date == 3)
                        let isTaskDay = (date == 8 || date == 24)
                        
                        Text("\(date)")
                            .font(GTFont.bodyMedium())
                            .foregroundColor(isToday ? .white : .gtTextPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Group {
                                    if isToday {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gtDarkGreen)
                                    } else if isTaskDay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gtBadgeTealBg)
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.gtBadgeTealBg)
                    .frame(width: 8, height: 8)
                Text("Watering")
                    .font(GTFont.bodySmall())
                    .foregroundColor(Color.gtTextMuted)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .gtShadow(GTShadow.card)
        )
    }
}

#Preview {
    GTCalendarCard()
        .padding()
        .background(Color.gtTreatmentBg)
}
