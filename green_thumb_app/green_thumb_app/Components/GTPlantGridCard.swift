import SwiftUI

struct GTPlantGridCard: View {
    let plant: PlantModel
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                // Background
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.gtPaleGreen.opacity(0.4), Color.gtBackground]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    if let imageURLString = plant.imageURL,
                       let imageURL = URL(string: imageURLString) {
                        // ✅ Real photo from Cloudinary
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .tint(.gtDarkGreen)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140) // Fixed height to match placeholder
                                    .clipped()
                            case .failure:
                                Text(emojiForPlant(plant.name))
                                    .font(.system(size: 64))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // Emoji placeholder
                        Text(emojiForPlant(plant.name))
                            .font(.system(size: 64))
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                }
                .frame(height: 140) // ✅ Force same height for all card tops
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Percentage Badge
                Text("\(Int(plant.healthScore))%")
                    .font(GTFont.labelSmall())
                    .foregroundColor(Color.gtTextPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(plant.name)
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                    .lineLimit(1)
                
                // Location & Type
                Text("\(plant.location) \(plant.isOutdoor ? "Outdoor" : "Indoor")")
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineLimit(1)
                
                // Progress Bar
                GTHealthBar(
                    value: plant.healthScore / 100,
                    height: 8,
                    customColor: progressBarColor
                )
                .padding(.vertical, 4)
                
                // Bottom Row
                HStack {
                    // Streak
                    if plant.status == .healthy {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            Text("\(plant.streakDays) days")
                                .font(GTFont.labelSmall())
                                .foregroundColor(.gtTextSecondary)
                        }
                    } else {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.gtStatusUrgent)
                                .font(.system(size: 14))
                            Text("Alert")
                                .font(GTFont.labelSmall())
                                .foregroundColor(.gtStatusUrgent)
                        }
                    }
                    
                    Spacer()
                    
                    // Action Button
                    actionView
                }
                .padding(.top, 4)
            }
            .padding(GTSpacing.sm)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .gtShadow(GTShadow.card)
        .onTapGesture { onTap?() }
    }
    
    private var progressBarColor: Color {
        if plant.healthScore < 60 { return .gtStatusUrgent }
        if plant.healthScore < 85 { return .gtWatering }
        return .gtAccentGreen
    }
    
    @ViewBuilder
    private var actionView: some View {
        if plant.status == .warning || plant.status == .critical {
            Button(action: {}) {
                Text("Diagnose")
                    .font(GTFont.labelSmall())
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.15))
                    .clipShape(Capsule())
            }
        } else if plant.healthScore < 90 {
            Button(action: {}) {
                Text("Water today")
                    .font(GTFont.labelSmall())
                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.2, green: 0.7, blue: 0.9).opacity(0.15))
                    .clipShape(Capsule())
            }
        } else {
            Text("Good")
                .font(GTFont.labelSmall())
                .foregroundColor(.gtDarkGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gtPaleGreen)
                .clipShape(Capsule())
        }
    }
    
    private func emojiForPlant(_ name: String) -> String {
        let n = name.lowercased()
        if n.contains("tomato") { return "🍅" }
        if n.contains("rose") { return "🌹" }
        if n.contains("fern") { return "🌿" }
        return "🪴"
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        ForEach(PlantModel.samples) { plant in
            GTPlantGridCard(plant: plant)
        }
    }
    .padding()
    .background(Color.gtBackground)
}
