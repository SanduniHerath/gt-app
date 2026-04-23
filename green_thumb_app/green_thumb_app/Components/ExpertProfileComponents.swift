import SwiftUI

// MARK: - Expert Stat Item
struct ExpertStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(GTFont.displaySmall())
                .font(.system(size: 20))
                .foregroundColor(.white)
            Text(label)
                .font(GTFont.labelSmall())
                .foregroundColor(.gtAccentGreen)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Specialization Tag
struct SpecializationTag: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(GTFont.labelSmall())
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(tagBgColor)
            .foregroundColor(tagTextColor)
            .cornerRadius(GTRadius.full)
    }
    
    private var tagBgColor: Color {
        if title.contains("Disease") { return Color(hex: "FEE5E5") }
        if title.contains("Organic") { return Color(hex: "E8F5E9") }
        if title.contains("Soil") { return Color(hex: "E0F2F1") }
        if title.contains("Roses") { return Color(hex: "F3E5F5") }
        if title.contains("Pest") { return Color(hex: "FFF3E0") }
        return Color.gtPaleGreen
    }
    
    private var tagTextColor: Color {
        if title.contains("Disease") { return Color(hex: "C44545") }
        if title.contains("Organic") { return Color(hex: "2E7D32") }
        if title.contains("Soil") { return Color(hex: "00796B") }
        if title.contains("Roses") { return Color(hex: "7B1FA2") }
        if title.contains("Pest") { return Color(hex: "E65100") }
        return Color.gtDarkGreen
    }
}

// MARK: - Availability Calendar
struct AvailabilityCalendar: View {
    let days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    let dates = ["", "1", "2", "3", "4", "5", "6"]
    let availableDates = ["3", "4", "5"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.md) {
            Text("Availability this week")
                .font(GTFont.labelLarge())
                .foregroundColor(.gtTextPrimary)
            
            HStack(spacing: 0) {
                ForEach(0..<days.count, id: \.self) { idx in
                    VStack(spacing: 12) {
                        Text(days[idx])
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextSecondary)
                        
                        ZStack {
                            if availableDates.contains(dates[idx]) {
                                RoundedRectangle(cornerRadius: GTRadius.sm)
                                    .fill(Color.gtLightGreen.opacity(0.5))
                                    .frame(width: 36, height: 36)
                            }
                            
                            Text(dates[idx])
                                .font(GTFont.bodyMedium())
                                .foregroundColor(dates[idx].isEmpty ? .clear : .gtTextPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Review Row
struct ReviewRow: View {
    let review: ExpertReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.sm) {
            HStack(spacing: GTSpacing.md) {
                Circle()
                    .fill(Color.gtDarkGreen.opacity(0.8))
                    .frame(width: 38, height: 38)
                    .overlay(Text(initials).font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.authorName)
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { star in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(star < review.rating ? .orange : .gtSeparator)
                        }
                    }
                }
                
                Spacer()
                
                Text(review.date)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextMuted)
            }
            
            Text(review.content)
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
                .lineSpacing(2)
            
            Text("Disease diagnosis")
                .font(GTFont.labelSmall())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.gtBadgeGreenBg)
                .foregroundColor(Color.gtBadgeGreenText)
                .cornerRadius(GTRadius.full)
        }
    }
    
    private var initials: String {
        review.authorName.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
    }
}
