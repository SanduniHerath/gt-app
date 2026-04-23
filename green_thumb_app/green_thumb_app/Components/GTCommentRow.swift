import SwiftUI

struct GTCommentRow: View {
    let comment: CommunityCommentModel
    
    var body: some View {
        HStack(alignment: .top, spacing: GTSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: comment.authorAvatarColorHex ?? "Color.gtDarkGreen"))
                    .frame(width: 40, height: 40)
                Text(initials)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(comment.authorName)
                    .font(GTFont.labelMedium())
                    .foregroundColor(.gtTextPrimary)
                
                Text(comment.content)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: GTSpacing.lg) {
                    Text(timeAgo)
                        .font(GTFont.labelSmall())
                        .foregroundColor(.gtTextMuted)
                    
                    Button { /* Reply */ } label: {
                        Text("Reply")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextPrimary.opacity(0.8))
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(.vertical, GTSpacing.md)
    }
    
    private var initials: String {
        comment.authorName.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .prefix(2)
            .joined()
    }
    
    private var timeAgo: String {
        "45 min ago" // Mocked
    }
}

