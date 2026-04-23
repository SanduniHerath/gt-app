import Foundation

struct AvailableSlot: Identifiable, Codable {
    let id: UUID
    let date: Date
    let isBooked: Bool
    init(id: UUID = .init(), date: Date, isBooked: Bool = false) {
        self.id = id; self.date = date; self.isBooked = isBooked
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let senderId: String
    let content: String
    let timestamp: Date
    var isFromUser: Bool
    init(id: UUID = .init(), senderId: String, content: String,
         timestamp: Date = .now, isFromUser: Bool) {
        self.id = id; self.senderId = senderId; self.content = content
        self.timestamp = timestamp; self.isFromUser = isFromUser
    }
}

struct ExpertReview: Identifiable, Codable {
    let id: UUID
    let authorName: String
    let rating: Int
    let content: String
    let date: String
    init(id: UUID = .init(), authorName: String, rating: Int, content: String, date: String) {
        self.id = id; self.authorName = authorName; self.rating = rating; self.content = content; self.date = date
    }
}

struct ExpertModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var specialty: String
    var department: String
    var location: String
    var rating: Double
    var reviewCount: Int
    var experienceYears: Int
    var sessionsCount: Int
    var pricePerHour: Double
    var imageURL: String?
    var bio: String
    var availableSlots: [AvailableSlot]
    var isOnline: Bool
    var distanceKm: Double?
    var tags: [String]
    var isGovtOfficer: Bool
    var isTopRated: Bool
    var reviews: [ExpertReview]

    init(id: UUID = .init(),
         name: String,
         specialty: String,
         department: String = "",
         location: String = "",
         rating: Double = 4.8,
         reviewCount: Int = 0,
         experienceYears: Int = 0,
         sessionsCount: Int = 0,
         pricePerHour: Double = 50,
         imageURL: String? = nil,
         bio: String = "",
         availableSlots: [AvailableSlot] = [],
         isOnline: Bool = false,
         distanceKm: Double? = nil,
         tags: [String] = [],
         isGovtOfficer: Bool = false,
         isTopRated: Bool = false,
         reviews: [ExpertReview] = []) {
        self.id = id; self.name = name; self.specialty = specialty
        self.department = department; self.location = location
        self.rating = rating; self.reviewCount = reviewCount
        self.experienceYears = experienceYears; self.sessionsCount = sessionsCount
        self.pricePerHour = pricePerHour; self.imageURL = imageURL
        self.bio = bio; self.availableSlots = availableSlots
        self.isOnline = isOnline; self.distanceKm = distanceKm
        self.tags = tags; self.isGovtOfficer = isGovtOfficer
        self.isTopRated = isTopRated; self.reviews = reviews
    }
}

extension ExpertModel {
    static let samples: [ExpertModel] = [
        ExpertModel(
            name: "Dr. Nimal Perera",
            specialty: "Agri Officer",
            department: "Dept. of Agriculture",
            location: "Colombo",
            rating: 4.9,
            reviewCount: 127,
            experienceYears: 8,
            sessionsCount: 340,
            pricePerHour: 0,
            bio: "Dr. Nimal Perera is a senior agricultural officer with 8 years of experience in plant pathology and home garden advisory. He specialises in diagnosing and treating diseases in flowering plants, vegetables, and ornamnetal species. He holds an Phd in Plant Pathology from the University of Peradeniya.",
            availableSlots: [
                AvailableSlot(date: Calendar.current.date(byAdding: .day, value: 3, to: .now)!)
            ],
            isOnline: true,
            distanceKm: 0.5,
            tags: ["Disease diagnosis", "Organic farming", "Soil health", "Roses & ornamentals", "Pest management"],
            isGovtOfficer: true,
            isTopRated: true,
            reviews: [
                ExpertReview(authorName: "Ashan K.", rating: 5, content: "Dr. Perera diagnosed my rose bush problem in minutes. His advice was clear and practical. The plant is already recovering after following his treatmenr plan!", date: "2 days ago"),
                ExpertReview(authorName: "Ashan K.", rating: 5, content: "Dr. Perera diagnosed my rose bush problem in minutes. His advice was clear and practical. The plant is already recovering after following his treatmenr plan!", date: "2 days ago")
            ]
        ),
        ExpertModel(
            name: "Dr. Saman Kumara",
            specialty: "Plant Pathologist",
            department: "Plant pathology Dept.",
            location: "Kandy",
            rating: 4.7,
            reviewCount: 84,
            experienceYears: 12,
            sessionsCount: 520,
            pricePerHour: 0,
            bio: "Specializing in identification and treatment of plant diseases.",
            availableSlots: [
                AvailableSlot(date: Calendar.current.date(byAdding: .day, value: 4, to: .now)!)
            ],
            isOnline: false,
            distanceKm: 4.2,
            tags: ["Disease", "Greenhouse"],
            isGovtOfficer: true,
            isTopRated: false
        )
    ]
}
