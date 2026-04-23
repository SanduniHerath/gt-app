import Foundation

enum QAStatus: String, Codable { case open, answered, closed }

struct AcceptedAnswer: Identifiable, Codable {
    let id: UUID
    let authorName: String
    let content: String
    let timestamp: Date
    init(id: UUID = .init(), authorName: String, content: String, timestamp: Date = .now) {
        self.id = id; self.authorName = authorName
        self.content = content; self.timestamp = timestamp
    }
}

struct CommunityCommentModel: Identifiable, Codable {
    let id: UUID
    var authorName: String
    var authorAvatarColorHex: String?
    var content: String
    var timestamp: Date
    
    init(id: UUID = .init(), authorName: String, authorAvatarColorHex: String? = nil, content: String, timestamp: Date = .now) {
        self.id = id; self.authorName = authorName; self.authorAvatarColorHex = authorAvatarColorHex
        self.content = content; self.timestamp = timestamp
    }
}

struct CommunityPostModel: Identifiable, Codable {
    let id: UUID
    var authorName: String
    var authorImageURL: String?
    var location: String?
    var category: String?
    var title: String?
    var content: String
    var imageURL: String?
    var avatarColorHex: String?
    var likes: Int
    var comments: Int
    var timestamp: Date
    var tags: [String]
    var commentsList: [CommunityCommentModel]
    
    init(id: UUID = .init(),
         authorName: String,
         authorImageURL: String? = nil,
         location: String? = nil,
         category: String? = nil,
         title: String? = nil,
         content: String,
         imageURL: String? = nil,
         avatarColorHex: String? = nil,
         likes: Int = 0,
         commentsCount: Int = 0,
         timestamp: Date = .now,
         tags: [String] = [],
         commentsList: [CommunityCommentModel] = []) {
        self.id = id; self.authorName = authorName; self.authorImageURL = authorImageURL
        self.location = location; self.category = category; self.title = title
        self.content = content; self.imageURL = imageURL; self.avatarColorHex = avatarColorHex
        self.likes = likes; self.comments = commentsCount; self.timestamp = timestamp; self.tags = tags
        self.commentsList = commentsList
    }
}

struct QAQuestionModel: Identifiable, Codable {
    let id: UUID
    var authorName: String
    var title: String
    var body: String
    var status: QAStatus
    var acceptedAnswer: AcceptedAnswer?
    var answerCount: Int
    var timestamp: Date
    var tags: [String]
    init(id: UUID = .init(), authorName: String, title: String, body: String,
         status: QAStatus = .open, acceptedAnswer: AcceptedAnswer? = nil,
         answerCount: Int = 0, timestamp: Date = .now, tags: [String] = []) {
        self.id = id; self.authorName = authorName; self.title = title
        self.body = body; self.status = status; self.acceptedAnswer = acceptedAnswer
        self.answerCount = answerCount; self.timestamp = timestamp; self.tags = tags
    }
}

extension CommunityPostModel {
    static let samples: [CommunityPostModel] = [
        CommunityPostModel(
            authorName: "Kamani Perera",
            location: "Colombo",
            category: "Disease",
            title: "Saved my tomatoes from early blight – here’s how",
            content: "Noticed yellow spots with dark concentric rings on the lower leaves about 3 weeks ago. Used copper-based fungicide every 7 days + improved bed drainage by adding perlite to the soil. Full recovery visible by day 10.",
            imageURL: "plant_disease_sample", // Placeholder
            avatarColorHex: "00A88E", // Teal
            likes: 142,
            commentsCount: 38,
            timestamp: Date().addingTimeInterval(-7200),
            tags: ["Tomatoes", "Blight"],
            commentsList: [
                CommunityCommentModel(authorName: "Herath G", authorAvatarColorHex: "C49450", content: "This happened to my chillies too! I tried neem oil first but it didn't work as well. Switching to copper now. Thanks for sharing!", timestamp: Date().addingTimeInterval(-2700)),
                CommunityCommentModel(authorName: "Peries T", authorAvatarColorHex: "00C0A3", content: "Did u improve air circulation too? I found that overhead watering makes it much worse – switching to drip helped a lot.", timestamp: Date().addingTimeInterval(-1800))
            ]
        ),
        CommunityPostModel(
            authorName: "Wathsala Fernando",
            location: "Colombo",
            category: "Soil",
            title: "Perfect soil mix for balcony herbs in tropical climate",
            content: "After testing 3 mixes over 2 months, 60% cocopeat + 30% compost + 10% perlite worked best for basil, mint, and curry leaf. Excelent drainage, great moisture retention",
            avatarColorHex: "9766FF", // Purple
            likes: 89,
            commentsCount: 34,
            timestamp: Date().addingTimeInterval(-14400),
            tags: ["Herbs", "Cocopeat", "Balcony"]
        )
    ]
}
