import SwiftUI

struct GTPlantCompactCard: View {
    let name: String
    let health: Int
    let icon: String // Emoji
    var imageURL: String? = nil // Real photo URL
    let borderColor: Color
    
    var body: some View {
        HStack(spacing: GTSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(borderColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                if let imageURLString = imageURL,
                   let url = URL(string: imageURLString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().tint(.gtDarkGreen)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            Text(icon).font(.system(size: 24))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text(icon)
                        .font(.system(size: 24))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor.opacity(0.5), lineWidth: 1.5)
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
                
                Text("\(health)%")
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtDarkGreen)
            }
        }
        .padding(.horizontal, GTSpacing.md)
        .padding(.vertical, GTSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .gtShadow(GTShadow.card)
        )
        .frame(width: 160)
    }
}

#Preview {
    HStack {
        GTPlantCompactCard(name: "Tomatoes", health: 88, icon: "🍅", borderColor: .gtDarkGreen)
        GTPlantCompactCard(name: "Rose Bush", health: 54, icon: "🌹", borderColor: .gtStatusUrgent)
    }
    .padding()
    .background(Color.gtBackground)
}

