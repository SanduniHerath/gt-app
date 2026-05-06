import SwiftUI

struct ExpertSessionChatView: View {
    let expert: ExpertModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var expertVM: ExpertViewModel
    @State private var messageText: String = ""
    @State private var isExpertTyping: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { router.pop() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.gtTextPrimary)
                        }
                    }
                    
                    // Avatar
                    ZStack(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(avatarColor)
                                .frame(width: 48, height: 48)
                            Text(initials)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Circle()
                            .fill(Color(hex: "4CAF50")) // Online green
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color(hex: "F2F2F2"), lineWidth: 2))
                            .offset(x: -1, y: -1)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(expert.name)
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text("\(expert.specialty) - Online")
                            .font(GTFont.bodySmall())
                            .foregroundColor(.gtTextSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 80)
                .padding(.bottom, 20)
                .background(Color(hex: "F2F2F2"))
                
                // MARK: - Banner
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "31541D"))
                            .frame(width: 36, height: 36)
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "78B960"))
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Session active - Advisory")
                            .font(GTFont.labelMedium())
                            .foregroundColor(Color(hex: "14280E"))
                        Text("Connected via Green Thumb")
                            .font(GTFont.labelSmall())
                            .foregroundColor(Color.gtTextSecondary.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(hex: "D0E2C9"))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(hex: "1F4512").opacity(0.2)),
                    alignment: .bottom
                )
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Today")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextSecondary)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity) // Ensures "Today" is centered and pushes width
                        
                        ForEach(expertVM.chatMessages) { message in
                            if message.isFromUser {
                                UserMessageBubble(text: message.content, time: formatTime(message.timestamp))
                            } else {
                                ExpertMessageBubble(expertInitials: initials, expertColor: avatarColor, text: message.content, time: formatTime(message.timestamp))
                            }
                        }
                        
                        if isExpertTyping {
                            HStack {
                                TypingIndicator()
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                                Spacer()
                            }
                            .id("typing")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(Color(hex: "E0E0E0")) // Apply background to ScrollView to fill width
                .onChange(of: expertVM.chatMessages.count) { _ in
                    withAnimation { proxy.scrollTo(expertVM.chatMessages.last?.id, anchor: .bottom) }
                }
            }
            
            // MARK: - Input Bar
            HStack(spacing: 12) {
                Button(action: {}) {
                    Circle()
                        .fill(Color(hex: "F2F2F2"))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "paperclip")
                                .foregroundColor(.gtTextSecondary)
                                .font(.system(size: 20))
                        )
                        .overlay(Circle().stroke(Color.gtBorder, lineWidth: 1))
                }
                
                HStack {
                    TextField("Type a message...", text: $messageText)
                        .font(GTFont.bodyMedium())
                        .foregroundColor(.gtTextPrimary)
                        .onSubmit { sendMessage() }
                }
                .padding(.horizontal, 20)
                .frame(height: 52)
                .background(
                    Capsule()
                        .fill(Color(hex: "E7F0E2"))
                        .overlay(Capsule().stroke(Color.gtBorder.opacity(0.5), lineWidth: 1))
                )
                
                Button(action: sendMessage) {
                    Circle()
                        .fill(Color(hex: "14280E"))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "location.north.fill")
                                .rotationEffect(Angle(degrees: 45))
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 40)
            .background(Color.white)
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            expertVM.startChat(with: expert)
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Logic
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        expertVM.sendChatMessage(expert: expert, content: messageText)
        messageText = ""
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
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
    ExpertSessionChatView(expert: ExpertModel.samples[0])
        .environmentObject(AppRouter())
        .environmentObject(ExpertViewModel())
}

// MARK: - Components

struct ExpertMessageBubble: View {
    let expertInitials: String
    let expertColor: Color
    let text: String
    let time: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack {
                Circle()
                    .fill(expertColor)
                    .frame(width: 40, height: 40)
                Text(expertInitials)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(text)
                    .font(GTFont.bodyMedium())
                    .foregroundColor(.gtTextPrimary)
                    .lineSpacing(4)
                
                Text(time)
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
            }
            .padding(16)
            .background(
                CustomRoundedCorners(tl: 20, tr: 20, bl: 4, br: 20)
                .fill(Color.white)
            )
            
            Spacer(minLength: 40)
        }
    }
}

struct UserMessageBubble: View {
    let text: String
    let time: String
    
    var body: some View {
        HStack {
            Spacer(minLength: 60)
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(text)
                    .font(GTFont.bodyMedium())
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        CustomRoundedCorners(tl: 20, tr: 20, bl: 20, br: 4)
                        .fill(Color(hex: "14280E"))
                    )
                
                Text(time)
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextSecondary)
            }
        }
    }
}

struct UserAttachmentBubble: View {
    let text: String
    let filename: String
    let filesize: String
    let time: String
    
    var body: some View {
        HStack {
            Spacer(minLength: 60)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(text)
                    .font(GTFont.bodyMedium())
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "31541D"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "photo.fill")
                            .foregroundColor(Color(hex: "78B960"))
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(filename)
                            .font(GTFont.labelMedium())
                            .foregroundColor(Color(hex: "1E1E1E"))
                        Text(filesize)
                            .font(GTFont.labelSmall())
                            .foregroundColor(Color(hex: "1E1E1E").opacity(0.6))
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "B8C5B0"))
                )
                
                Text(time)
                    .font(GTFont.labelSmall())
                    .foregroundColor(Color.white.opacity(0.7))
            }
            .padding(16)
            .background(
                CustomRoundedCorners(tl: 20, tr: 20, bl: 20, br: 4)
                .fill(Color(hex: "14280E"))
            )
        }
    }
}

// MARK: - Animated Typing Indicator

struct TypingIndicator: View {
    @State private var dotOffset1: CGFloat = 0
    @State private var dotOffset2: CGFloat = 0
    @State private var dotOffset3: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(Color.white.opacity(0.8)).frame(width: 6, height: 6).offset(y: dotOffset1)
            Circle().fill(Color.white.opacity(0.8)).frame(width: 6, height: 6).offset(y: dotOffset2)
            Circle().fill(Color.white.opacity(0.8)).frame(width: 6, height: 6).offset(y: dotOffset3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            CustomRoundedCorners(tl: 20, tr: 20, bl: 4, br: 20)
            .fill(Color(hex: "14280E"))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever().delay(0.0)) { dotOffset1 = -5 }
            withAnimation(.easeInOut(duration: 0.5).repeatForever().delay(0.2)) { dotOffset2 = -5 }
            withAnimation(.easeInOut(duration: 0.5).repeatForever().delay(0.4)) { dotOffset3 = -5 }
        }
    }
}

// MARK: - Helpers

struct CustomRoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.size.width
        let h = rect.size.height
        let trCenter = CGPoint(x: w - tr, y: tr)
        let brCenter = CGPoint(x: w - br, y: h - br)
        let blCenter = CGPoint(x: bl, y: h - bl)
        let tlCenter = CGPoint(x: tl, y: tl)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: trCenter, radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: brCenter, radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: blCenter, radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: tlCenter, radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.addLine(to: CGPoint(x: w / 2.0, y: 0))
        return path
    }
}
