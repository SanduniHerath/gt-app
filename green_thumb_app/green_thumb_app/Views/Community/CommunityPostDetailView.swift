import SwiftUI

struct CommunityPostDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var communityVM: CommunityViewModel
    let post: CommunityPostModel
    
    @State private var commentText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .circleButton()
                }
                Spacer()
                Text("Post")
                    .font(GTFont.displayLarge())
                    .foregroundColor(.gtTextPrimary)
                    .offset(x: -20)
                Spacer()
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.top, 64) // Lowered header as requested
            .padding(.bottom, GTSpacing.md)
            .background(Color(hex: "E5E5E5"))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Author Row
                    HStack(spacing: GTSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: post.avatarColorHex ?? "Color.gtDarkGreen"))
                                .frame(width: 48, height: 48)
                            Text(initials)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.authorName)
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)
                            
                            Text("\(post.location ?? "Unknown") - 2 hours ago - \(post.likes) likes")
                                .font(GTFont.bodySmall())
                                .foregroundColor(.gtTextMuted)
                        }
                    }
                    .padding(GTSpacing.lg)
                    .background(Color.white)
                    
                    // Post Media
                    if let imageURL = post.imageURL {
                        ZStack {
                            Color.gtPaleGreen.opacity(0.5)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.gtDarkGreen.opacity(0.2))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .background(Color.white)
                    }
                    
                    // Post Content
                    VStack(alignment: .leading, spacing: GTSpacing.md) {
                        if let title = post.title {
                            Text(title)
                                .font(GTFont.labelLarge())
                                .font(.system(size: 18))
                                .foregroundColor(.gtTextPrimary)
                                .lineSpacing(2)
                        }
                        
                        Text(post.content)
                            .font(GTFont.bodyMedium())
                            .foregroundColor(.gtTextSecondary)
                            .lineSpacing(4)
                        
                        // Tags
                        HStack(spacing: GTSpacing.sm) {
                            ForEach(post.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(tag == "Blight" ? .gtStatusUrgent : .gtDarkGreen)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(tag == "Blight" ? Color.gtStatusUrgent.opacity(0.12) : Color.gtPaleGreen)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, GTSpacing.xs)
                    }
                    .padding(GTSpacing.lg)
                    .background(Color.white)
                    
                    // Engagement Bar
                    GTPostEngagementBar(
                        likes: post.likes,
                        comments: post.commentsList.count
                    )
                    
                    // Comments Section
                    VStack(alignment: .leading, spacing: GTSpacing.md) {
                        Text("Comments - \(String(format: "%02d", post.commentsList.count))")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                            .padding(.top, GTSpacing.sm)
                        
                        VStack(spacing: 0) {
                            ForEach(post.commentsList) { comment in
                                GTCommentRow(comment: comment)
                                if comment.id != post.commentsList.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(GTSpacing.lg)
                }
            }
            .background(Color(hex: "E0E0E0"))
            .safeAreaInset(edge: .bottom) {
                // Bottom Input Bar - Refined for keyboard behavior
                HStack(spacing: GTSpacing.md) {
                    Circle()
                        .fill(Color.gtForestGreen)
                        .frame(width: 44, height: 44)
                        .overlay(Text("SH").font(.system(size: 16, weight: .bold)).foregroundColor(.white))
                    
                    HStack {
                        TextField("Add a comment", text: $commentText)
                            .font(GTFont.bodySmall())
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.gtPaleGreen.opacity(0.4))
                    .clipShape(Capsule())
                    
                    Button {
                        communityVM.addComment(to: post.id, text: commentText)
                        commentText = ""
                        hideKeyboard()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.gtForestGreen)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.vertical, GTSpacing.sm)
                .background(Color.white)
                .gtShadow(GTShadow.card)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
    
    private var initials: String {
        post.authorName.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .prefix(2)
            .joined()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CommunityPostDetailView(post: CommunityPostModel.samples[0])
        .environmentObject(CommunityViewModel())
}
