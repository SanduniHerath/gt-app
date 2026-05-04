import SwiftUI

struct ExpertProfileView: View {
    let expert: ExpertModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 0) {
                HStack {
                    Button(action: { router.pop() }) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 40, height: 40)
                            Image(systemName: "arrow.left")
                                .foregroundColor(.gtForestGreen)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.top, 50)
                
                VStack(spacing: GTSpacing.md) {
                    // Profile Image with Verification
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(avatarColor)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(initials)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.gtLightGreen)
                            .background(Circle().fill(.white))
                            .font(.system(size: 20))
                            .offset(x: -2, y: -2)
                    }
                    
                    VStack(spacing: 4) {
                        Text(expert.name)
                            .font(GTFont.displayMedium())
                            .foregroundColor(.white)
                        
                        Text("\(expert.specialty) – \(expert.department),")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtAccentGreen)
                        Text(expert.location)
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtAccentGreen)
                    }
                }
                .padding(.vertical, GTSpacing.lg)
                
                // Stats Row
                HStack(spacing: 0) {
                    ExpertStatItem(value: String(format: "%.1f", expert.rating), label: "Rating")
                    ExpertStatItem(value: "\(expert.reviewCount)", label: "Reviews")
                    ExpertStatItem(value: "\(expert.experienceYears) yrs", label: "Experience")
                    ExpertStatItem(value: "\(expert.sessionsCount)", label: "Sessions")
                }
                .padding(.bottom, GTSpacing.lg)
            }
            .background(Color.gtForestGreen)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.lg) {
                    // Actions
                    HStack(spacing: GTSpacing.md) {
                        Button(action: { router.navigate(to: .bookSession(expert)) }) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                Text("Book session")
                            }
                            .font(GTFont.labelMedium())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.gtForestGreen)
                            .foregroundColor(.white)
                            .cornerRadius(GTRadius.sm)
                        }
                        
                        Button(action: { router.navigate(to: .expertChat(expert)) }) {
                            HStack(spacing: 8) {
                                Image(systemName: "bubble.left")
                                Text("Message")
                            }
                            .font(GTFont.labelMedium())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: GTRadius.sm)
                                    .stroke(Color.gtForestGreen.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.gtForestGreen)
                        }
                    }
                    .padding(.top, GTSpacing.md)
                    
                    Divider()
                    
                    // Specialization Areas
                    VStack(alignment: .leading, spacing: GTSpacing.md) {
                        Text("Specialization Areas")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(expert.tags, id: \.self) { tag in
                                SpecializationTag(title: tag)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // About Section
                    VStack(alignment: .leading, spacing: GTSpacing.sm) {
                        Text("About")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text(expert.bio)
                            .font(GTFont.bodyMedium())
                            .foregroundColor(.gtTextSecondary)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    // Availability calendar
                    AvailabilityCalendar()
                    
                    Divider()
                    
                    // Reviews Section
                    VStack(alignment: .leading, spacing: GTSpacing.lg) {
                        HStack {
                            Text("Reviews – \(expert.reviews.count)")
                                .font(GTFont.labelLarge())
                                .foregroundColor(.gtTextPrimary)
                            Spacer()
                        }
                        
                        ForEach(expert.reviews) { review in
                            ReviewRow(review: review)
                            if review.id != expert.reviews.last?.id {
                                Divider().padding(.vertical, GTSpacing.xs)
                            }
                        }
                    }
                }
                .padding(GTSpacing.lg)
                .padding(.bottom, GTSpacing.xxl)
            }
            .background(Color(hex: "F2F2F2"))
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
    
    private var initials: String {
        expert.name.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .suffix(2)
            .joined()
            .uppercased()
    }
    
    private var avatarColor: Color {
        if initials.contains("N") { return Color.gtBadgePurpleText.opacity(0.7) }
        return Color.gtBadgeTealText.opacity(0.7)
    }
}

#Preview {
    ExpertProfileView(expert: ExpertModel.samples[0])
        .environmentObject(AppRouter())
}
