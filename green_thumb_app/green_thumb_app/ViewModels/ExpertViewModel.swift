import Foundation
import Combine

@MainActor
class ExpertViewModel: ObservableObject {
    @Published var experts: [ExpertModel] = ExpertModel.samples
    @Published var selectedExpert: ExpertModel? = nil
    @Published var messages: [ChatMessage] = []
    @Published var messageInput: String = ""
    @Published var searchText: String = ""

    @Published var selectedFilter: String = "All"

    var filteredExperts: [ExpertModel] {
        var base = experts
        if selectedFilter != "All" {
            base = base.filter { $0.tags.contains(selectedFilter) }
        }
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.specialty.localizedCaseInsensitiveContains(searchText) || $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) }
    }

    func sendMessage() {
        guard !messageInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let msg = ChatMessage(senderId: "user", content: messageInput, isFromUser: true)
        messages.append(msg)
        messageInput = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let reply = ChatMessage(senderId: "expert", content: "Thanks for your message! I'll review your plant's symptoms and get back to you shortly.", isFromUser: false)
            self.messages.append(reply)
        }
    }
}
