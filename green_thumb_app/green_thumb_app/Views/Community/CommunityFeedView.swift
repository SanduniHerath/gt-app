import SwiftUI

// MARK: - Community Feed
struct CommunityFeedView: View {
    @EnvironmentObject var communityVM: CommunityViewModel
    @State private var showNewPost = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    Text("Community").font(GTFont.displaySmall()).foregroundColor(.white)
                    Spacer()
                    Button { showNewPost = true } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                    }
                }
                .padding(.horizontal, GTSpacing.lg).padding(.vertical, GTSpacing.xxxl).padding(.top, GTSpacing.sm)
                .background(Color.gtForestGreen)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: GTSpacing.sm) {
                        ForEach(communityVM.posts) { post in
                            GTCommunityPost(post: post) { communityVM.likePost(post) }
                        }
                    }
                    .padding(GTSpacing.lg)
                }
                .background(Color(red:0.97,green:0.98,blue:0.96))
            }
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $showNewPost) {
                NewPostSheet(vm: communityVM)
            }
        }
    }
}

struct NewPostSheet: View {
    @ObservedObject var vm: CommunityViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: GTSpacing.lg) {
            HStack {
                Text("New Post").font(GTFont.labelLarge())
                Spacer()
                Button("Cancel") { dismiss() }.foregroundColor(.gtDarkGreen)
            }
            TextEditor(text: $vm.newPostText)
                .frame(height: 150)
                .padding(GTSpacing.sm)
                .background(RoundedRectangle(cornerRadius: GTRadius.md).stroke(Color.gtBorder, lineWidth: 1.5))
            GTButton(title: "Post") { vm.submitPost(); dismiss() }
            Spacer()
        }
        .padding(GTSpacing.lg)
    }
}

// MARK: - Community Post Detail
struct CommunityPostView: View {
    let post: CommunityPostModel
    var body: some View {
        VStack { Text(post.content).font(GTFont.bodyLarge()).padding() }
    }
}

#Preview { CommunityFeedView().environmentObject(CommunityViewModel()).environmentObject(AppRouter())
        .environmentObject(AuthViewModel()).environmentObject(PlantViewModel())
        .environmentObject(DiagnoseViewModel()).environmentObject(SchedulerViewModel())
        .environmentObject(ExpertViewModel()).environmentObject(NotificationsViewModel())
        .environmentObject(ProfileViewModel()) }

