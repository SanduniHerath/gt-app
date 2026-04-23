import Foundation
import Combine

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var posts: [CommunityPostModel] = CommunityPostModel.samples
    @Published var selectedCategory: String = "All"
    @Published var newPostText: String = ""

    var filteredPosts: [CommunityPostModel] {
        if selectedCategory == "All" {
            return posts
        } else if selectedCategory == "Disease tips" {
            return posts.filter { $0.category == "Disease" }
        } else {
            return posts.filter { $0.category == selectedCategory }
        }
    }

    func likePost(_ post: CommunityPostModel) {
        if let idx = posts.firstIndex(where: { $0.id == post.id }) {
            posts[idx].likes += 1
        }
    }
    
    func submitPost() {
        guard !newPostText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let post = CommunityPostModel(authorName: "You", category: "General", content: newPostText, avatarColorHex: "4B6A4B")
        posts.insert(post, at: 0)
        newPostText = ""
    }

    func addComment(to postId: UUID, text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if let idx = posts.firstIndex(where: { $0.id == postId }) {
            let newComment = CommunityCommentModel(
                authorName: "You",
                authorAvatarColorHex: "4B6A4B",
                content: text
            )
            posts[idx].commentsList.append(newComment)
            posts[idx].comments += 1
        }
    }
}
