import SwiftUI

struct ExpertSessionChatView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var router: AppRouter
    @State private var messageText: String = ""
    @State private var isExpertTyping: Bool = false
    
    // Initial mock messages
    @State private var messages: [ChatMessage] = [
        ChatMessage(senderId: "expert_1", content: "Hello! I've reviewed your Rose Bush. The yellowing pattern on the lower leaves strongly suggests nitrogen deficiency. Can u share a photo of the affected leaves?", isFromUser: false),
        // The attachment is handled separately in this mockup logic for now
        ChatMessage(senderId: "user_1", content: "Sure, here's a photo I took this morning.", isFromUser: true),
        ChatMessage(senderId: "expert_1", content: "Thank you. The photo confirms nitrogen deficiency. The yellowing starts at the base and moves upward - classic symptom. Apply NPK 20-5-10 twice this week", isFromUser: false)
    ]
    
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
                                .fill(Color(hex: "A374F9")) // Purple
                                .frame(width: 48, height: 48)
                            Text("NP")
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
                        Text("Dr. Nimal Perera")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text("Agricultural officer - Online")
                            .font(GTFont.bodySmall())
                            .foregroundColor(.gtTextSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Circle()
                                .fill(Color(hex: "D0DFCD")) // Light gray green
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(Color.gtForestGreen)
                                        .font(.system(size: 16))
                                )
                        }
                        
                        Button(action: {}) {
                            Circle()
                                .fill(Color(hex: "D0DFCD")) // Light gray green
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(Color.gtForestGreen)
                                        .font(.system(size: 18))
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 80)
                .padding(.bottom, 20)
                .background(Color(hex: "F2F2F2")) // Header BG from SS
                
                // MARK: - Banner
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "31541D")) // Dark Green BG for icon
                            .frame(width: 36, height: 36)
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "78B960")) // Light Green icon
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Session active - Rose Bush diagnosis")
                            .font(GTFont.labelMedium())
                            .foregroundColor(Color(hex: "14280E"))
                        Text("45 min left")
                            .font(GTFont.labelSmall())
                            .foregroundColor(Color.gtTextSecondary.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(hex: "D0E2C9")) // Banner BG from SS
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
                        Text("Today 3:00 PM")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextSecondary)
                            .padding(.top, 16)
                        
                        ForEach(messages) { message in
                            if message.isFromUser {
                                // Check if it's the specific mock attachment message
                                if message.content.contains("photo I took this morning") {
                                    UserAttachmentBubble(
                                        text: message.content,
                                        filename: "rose_leaves.jpg",
                                        filesize: "Photo 2.1 MB",
                                        time: formatTime(message.timestamp)
                                    )
                                } else {
                                    UserMessageBubble(text: message.content, time: formatTime(message.timestamp))
                                }
                            } else {
                                ExpertMessageBubble(text: message.content, time: formatTime(message.timestamp))
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
                        
                        // "More" button remains as a static element for now at the bottom of historical context if needed
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                Circle()
                                    .fill(Color(hex: "14280E"))
                                    .frame(width: 60, height: 40)
                                    .overlay(
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .bold))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .onChange(of: messages.count) { _ in
                    withAnimation { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
                }
                .onChange(of: isExpertTyping) { typing in
                    if typing {
                        withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                    }
                }
            }
            .background(Color(hex: "E0E0E0")) // Chat area BG from SS
            
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
                        .fill(Color(hex: "E7F0E2")) // Light green field BG
                        .overlay(Capsule().stroke(Color.gtBorder.opacity(0.5), lineWidth: 1))
                )
                
                Button(action: sendMessage) {
                    Circle()
                        .fill(Color(hex: "14280E")) // Dark Green send button
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
    }
    
    // MARK: - Logic
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(senderId: "user_1", content: messageText, isFromUser: true)
        messages.append(newMessage)
        messageText = ""
        
        // Simulate expert typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { isExpertTyping = true }
            
            // Expert stops typing and sends a reply
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation { isExpertTyping = false }
                let reply = ChatMessage(senderId: "expert_1", content: "That looks like progress! Keep following the schedule.", isFromUser: false)
                messages.append(reply)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Components

struct ExpertMessageBubble: View {
    let text: String
    let time: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "A374F9"))
                    .frame(width: 40, height: 40)
                Text("NP")
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
            .fill(Color(hex: "14280E")) // iOS Expert style bubble
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

#Preview {
    ExpertSessionChatView()
}
