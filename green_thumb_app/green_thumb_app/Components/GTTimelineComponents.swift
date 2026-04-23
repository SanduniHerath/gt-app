import SwiftUI

// MARK: - Add Observation Button
struct GTAddObservationButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "A8CC80"))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.gtForestGreen)
                }
                
                Text("Add today’s observation")
                    .font(GTFont.labelLarge())
                    .foregroundColor(Color(hex: "283F28"))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "E7F3DC").opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            .foregroundColor(Color(hex: "314E31").opacity(0.4))
                    )
            )
        }
    }
}

// MARK: - Timeline Entry View
struct GTHighFidelityTimelineCard: View {
    let entry: CareLogEntry
    let isLast: Bool
    
    // Determine color based on hex or type
    private var accentColor: Color {
        if let hex = entry.colorHex {
            return Color(hex: hex)
        }
        return .gtMidGreen
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left Column: Dot and Connector
            VStack(spacing: 0) {
                // The Dot
                Circle()
                    .fill(accentColor)
                    .frame(width: 16, height: 16)
                    .gtShadow(GTShadow.card)
                
                // The Line
                if !isLast {
                    Rectangle()
                        .fill(Color(hex: "A8CC80")) // Light green connector as per mockup
                        .frame(width: 4)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 40)
            .padding(.top, 32) // Align dot with center of the card's top header
            
            // Right Column: Card Content
            VStack(alignment: .leading, spacing: 14) {
                // Header (Icon + Date/Time)
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(.gtTextMuted)
                    
                    Text(entry.date.formatted(.dateTime.day().month(.wide).year().hour().minute()))
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextSecondary)
                }
                
                // Title
                Text(entry.title)
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                
                // Note
                Text(entry.note)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Status Badge
                if let badge = entry.statusBadge {
                    Text(badge)
                        .font(GTFont.labelSmall())
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .gtShadow(GTShadow.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(accentColor.opacity(0.6), lineWidth: 1.5)
                    )
            )
            .padding(.bottom, isLast ? 40 : 20)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GTAddObservationButton {}
            .padding(.horizontal, 24)
        
        GTHighFidelityTimelineCard(
            entry: CareLogEntry(
                type: .observation,
                title: "Yellowing leaves noticed",
                note: "Lower leaves turning yellow. Possible nitrogen deficiency or root stress. Reduced watering frequency.",
                statusBadge: "Disease alert",
                colorHex: "E67E22"
            ),
            isLast: false
        )
        .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gtBackground)
}

