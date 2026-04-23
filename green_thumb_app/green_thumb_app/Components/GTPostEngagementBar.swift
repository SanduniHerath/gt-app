import SwiftUI

struct GTPostEngagementBar: View {
    let likes: Int
    let comments: Int
    var onLike: (() -> Void)? = nil
    var onComment: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            Button { onLike?() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.gtStatusUrgent)
                    Text("\(likes)")
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            
            Divider()
                .frame(height: 24)
            
            Button { onComment?() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.gtTextMuted)
                    Text("\(comments)")
                        .font(GTFont.labelMedium())
                        .foregroundColor(.gtTextPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            
            Divider()
                .frame(height: 24)
            
            // Empty space for layout balance
            Spacer()
                .frame(maxWidth: .infinity)
        }
        .background(Color.white)
        .overlay(
            VStack {
                Divider()
                Spacer()
                Divider()
            }
        )
    }
}
