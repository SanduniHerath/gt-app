import SwiftUI

// GreenThumb SVG-style logo rendered in pure SwiftUI
struct GTLogoIcon: View {
    var size: CGFloat = 80
    var primaryColor: Color = .gtLightGreen
    var houseColor: Color = Color(red: 0.20, green: 0.35, blue: 0.20)

    var body: some View {
        ZStack {
            // Left leaf
            Ellipse()
                .fill(primaryColor)
                .frame(width: size * 0.48, height: size * 0.72)
                .rotationEffect(.degrees(-30))
                .offset(x: -size * 0.26, y: -size * 0.05)

            // Right leaf
            Ellipse()
                .fill(primaryColor)
                .frame(width: size * 0.48, height: size * 0.72)
                .rotationEffect(.degrees(30))
                .offset(x: size * 0.26, y: -size * 0.05)

            // Centre top leaf
            Ellipse()
                .fill(primaryColor)
                .frame(width: size * 0.40, height: size * 0.65)
                .offset(x: 0, y: -size * 0.12)

            // Ground arc
            Ellipse()
                .fill(primaryColor)
                .frame(width: size * 0.90, height: size * 0.28)
                .offset(y: size * 0.30)

            // House body
            RoundedRectangle(cornerRadius: 4)
                .fill(houseColor)
                .frame(width: size * 0.30, height: size * 0.22)
                .offset(y: size * 0.08)

            // House roof triangle
            Triangle()
                .fill(houseColor)
                .frame(width: size * 0.42, height: size * 0.18)
                .offset(y: -size * 0.04)

            // Window
            RoundedRectangle(cornerRadius: 2)
                .fill(primaryColor.opacity(0.6))
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(y: size * 0.065)
        }
        .frame(width: size, height: size)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

// Inline header logo (small icon + "GreenThumb" text)
struct GTLogoHeader: View {
    var iconSize: CGFloat = 32
    var textColor: Color  = .white
    var dark: Bool = false

    var body: some View {
        HStack(spacing: GTSpacing.xs) {
            GTLogoIcon(size: iconSize,
                       primaryColor: dark ? .gtLightGreen : .gtLightGreen,
                       houseColor: dark ? .gtDarkGreen : Color(red:0.18,green:0.32,blue:0.18))
            Text("GreenThumb")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        GTLogoIcon(size: 120)
        GTLogoHeader()
    }
    .padding()
    .background(Color.gtForestGreen)
}
