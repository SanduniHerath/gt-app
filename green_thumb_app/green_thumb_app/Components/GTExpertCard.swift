import SwiftUI

struct GTExpertCard: View {
    let expert: ExpertModel
    var onViewProfile: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: GTSpacing.md) {
            // Header: Top Rated & Availability
            HStack {
                if expert.isTopRated {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("Top rated")
                            .font(GTFont.labelSmall())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gtBadgeYellowBg)
                    .foregroundColor(Color.gtBadgeYellowText)
                    .cornerRadius(GTRadius.full)
                }
                
                Text(expert.isOnline ? "Available today" : "Next available – Tomorrow")
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                
                Spacer()
            }

            HStack(alignment: .top, spacing: GTSpacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(avatarColor)
                        .frame(width: 54, height: 54)
                    Text(initials)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(expert.name)
                        .font(GTFont.displaySmall())
                        .font(.system(size: 18)) // Override slightly for card
                        .foregroundColor(.gtTextPrimary)
                    
                    Text("\(expert.specialty) – \(expert.location)")
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextSecondary)
                    
                    HStack(spacing: 4) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { star in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(star < Int(expert.rating) ? .orange : .gtSeparator)
                            }
                        }
                        Text(String(format: "%.1f", expert.rating))
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextPrimary)
                        Text("(\(expert.reviewCount) reviews)")
                            .font(GTFont.bodySmall())
                            .foregroundColor(.gtTextMuted)
                    }
                }
            }

            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GTSpacing.xs) {
                    ForEach(expert.tags, id: \.self) { tag in
                        Text(tag)
                            .font(GTFont.labelSmall())
                            .padding(.horizontal, 24)
                            .padding(.vertical, 6)
                            .background(tagBgColor(for: tag))
                            .foregroundColor(tagTextColor(for: tag))
                            .cornerRadius(GTRadius.full)
                    }
                }
            }
            
            // Available Slots
            if !expert.availableSlots.isEmpty {
                HStack(spacing: GTSpacing.sm) {
                    ForEach(expert.availableSlots.prefix(3)) { slot in
                        Text(formatTime(slot.date))
                            .font(GTFont.labelSmall())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gtPaleGreen)
                            .foregroundColor(.gtDarkGreen)
                            .overlay(Capsule().stroke(Color.gtMidGreen.opacity(0.3), lineWidth: 1))
                            .cornerRadius(GTRadius.full)
                    }
                }
            }

            // Footer
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(expert.pricePerHour == 0 ? "Free – Govt (officer)" : "$\(Int(expert.pricePerHour))/hr")
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                    Text(expert.department)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                }
                
                Spacer()
                
                Button(action: { onViewProfile?() }) {
                    Text("View Profile")
                        .font(GTFont.labelSmall())
                        .foregroundColor(.gtDarkGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .stroke(Color.gtMidGreen, lineWidth: 1)
                                .background(Color.gtPaleGreen.opacity(0.3))
                        )
                }
                .cornerRadius(GTRadius.full)
            }
        }
        .padding(GTSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.lg)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GTRadius.lg)
                .stroke(Color.gtMidGreen.opacity(0.2), lineWidth: 1.5)
        )
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

    private func tagBgColor(for tag: String) -> Color {
        switch tag {
        case "Disease": return Color(hex: "FEE5E5")
        case "Organic": return Color.gtBadgeGreenBg
        case "Greenhouse": return Color.gtBadgeGreenBg
        default: return Color.gtPaleGreen
        }
    }

    private func tagTextColor(for tag: String) -> Color {
        switch tag {
        case "Disease": return Color(hex: "C44545")
        case "Organic": return Color.gtBadgeGreenText
        case "Greenhouse": return Color.gtBadgeGreenText
        default: return Color.gtDarkGreen
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(ExpertModel.samples) { e in GTExpertCard(expert: e) }
    }.padding()
}
