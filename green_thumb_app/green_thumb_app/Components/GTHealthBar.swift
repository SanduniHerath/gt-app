import SwiftUI

struct GTHealthBar: View {
    let value: Double      // 0.0 – 1.0
    var height: CGFloat = 6
    var customColor: Color? = nil

    private var barColor: Color {
        if let customColor { return customColor }
        if value >= 0.75 { return .gtAccentGreen }
        if value >= 0.45 { return Color(red:0.9,green:0.7,blue:0.1) }
        return Color(red:0.85,green:0.25,blue:0.2)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gtPaleGreen)
                Capsule()
                    .fill(barColor)
                    .frame(width: geo.size.width * CGFloat(value))
            }
        }
        .frame(height: height)
    }
}

struct GTStatCard: View {
    let value: String
    let label: String
    var icon: String = "leaf.fill"
    var accent: Color = .gtDarkGreen

    var body: some View {
        VStack(spacing: GTSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(accent)
            Text(value)
                .font(GTFont.displaySmall())
                .foregroundColor(.gtTextPrimary)
            Text(label)
                .font(GTFont.bodySmall())
                .foregroundColor(.gtTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(GTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(.white)
                .gtShadow(GTShadow.card)
        )
    }
}

#Preview {
    VStack {
        GTHealthBar(value: 0.88).frame(width: 200).padding()
        HStack {
            GTStatCard(value: "7", label: "Plants",  icon: "leaf.fill")
            GTStatCard(value: "14", label: "Streak", icon: "flame.fill", accent: .orange)
            GTStatCard(value: "3", label: "Tasks Due", icon: "checklist")
        }.padding()
    }
}
