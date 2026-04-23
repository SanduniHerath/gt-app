import SwiftUI

struct GTCommunityPostCard: View {
    let post: CommunityPostModel
    
    var body: some View {
        NavigationLink(destination: CommunityPostDetailView(post: post)) {
            VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: GTSpacing.sm) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: post.avatarColorHex ?? "Color.gtDarkGreen"))
                        .frame(width: 40, height: 40)
                    Text(initials)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                    
                    Text("\(post.location ?? "Unknown") - \(timeAgo)")
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                }
                
                Spacer()
                
                // Category Tag
                if let category = post.category {
                    Text(category)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: categoryColorHex).opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: categoryColorHex).opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(GTSpacing.md)
            
            // Image Section (Optional)
            if let imageURL = post.imageURL {
                ZStack {
                    Color.gtPaleGreen.opacity(0.5) // Background for the image
                    
                    Image(systemName: "leaf.fill") // Placeholder for actual image
                        .font(.system(size: 60))
                        .foregroundColor(.gtDarkGreen.opacity(0.2))
                    
                    // In a real app, this would be an AsyncImage
                     Rectangle()
                         .fill(Color.gtLightGreen.opacity(0.3))
                         .overlay(
                             Image(systemName: "photo")
                                 .foregroundColor(.white)
                         )
                }
                .frame(height: 180)
                .clipped()
            }
            
            // Text Section
            VStack(alignment: .leading, spacing: GTSpacing.sm) {
                if let title = post.title {
                    Text(title)
                        .font(GTFont.labelLarge())
                        .foregroundColor(.gtTextPrimary)
                        .lineLimit(2)
                }
                
                Text(post.content)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .lineLimit(3)
                
                // Content specific tags (Blight, Cocopeat etc)
                if post.category == "Disease" {
                    HStack {
                        Spacer()
                        Text("Blight")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gtDarkGreen.opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gtLightGreen.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
                
                // Footer Tags
                HStack(spacing: GTSpacing.sm) {
                    ForEach(post.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gtTextSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gtPaleGreen)
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 4)
            }
            .padding(GTSpacing.md)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: GTRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: GTRadius.lg)
                .stroke(Color.gtBorder.opacity(0.5), lineWidth: 1)
        )
        .gtShadow(GTShadow.card)
        .buttonStyle(PlainButtonStyle()) // Ensure it looks like a card, not a nav link
        }
    }
    
    private var initials: String {
        post.authorName.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .prefix(2)
            .joined()
    }
    
    private var timeAgo: String {
        "2 hours ago" // Mocked
    }
    
    private var categoryColorHex: String {
        switch post.category {
        case "Disease": return "EE9E9E" // Reddish
        case "Soil": return "A8CC80" // Green
        default: return "A8CC80"
        }
    }
}
