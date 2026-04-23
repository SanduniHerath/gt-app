import SwiftUI

struct GTFilterChip: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GTFont.labelMedium())
                .foregroundColor(isSelected ? .white : .gtDarkGreen)
                .padding(.horizontal, GTSpacing.md)
                .padding(.vertical, GTSpacing.xxs + 3)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.gtDarkGreen : Color.gtPaleGreen)
                )
        }
    }
}

struct GTSymptomTag: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                }
                Text(title)
                    .font(GTFont.labelSmall())
            }
            .foregroundColor(isSelected ? .white : .gtDarkGreen)
            .padding(.horizontal, GTSpacing.sm)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: GTRadius.sm)
                    .fill(isSelected ? Color.gtDarkGreen : Color.gtPaleGreen)
                    .overlay(
                        RoundedRectangle(cornerRadius: GTRadius.sm)
                            .stroke(Color.gtBorder, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                GTFilterChip(title: "All", isSelected: true)  {}
                GTFilterChip(title: "Healthy") {}
                GTFilterChip(title: "Needs Attention") {}
            }.padding(.horizontal)
        }
        FlexibleTagLayout(tags: ["Yellow Leaves","Brown Tips","Wilting","Root Rot","White Spots","Drooping"], selected: .constant(["Wilting"]))
    }
}

// Flexible wrapping tag layout
struct FlexibleTagLayout: View {
    let tags: [String]
    @Binding var selected: Set<String>

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                GTSymptomTag(title: tag, isSelected: selected.contains(tag)) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if selected.contains(tag) { selected.remove(tag) }
                        else { selected.insert(tag) }
                    }
                }
                .alignmentGuide(.leading) { d in
                    if abs(width - d.width) > geo.size.width {
                        width = 0; height -= d.height + 8
                    }
                    let result = width
                    width = tag == tags.last ? 0 : width - d.width - 8
                    return result
                }
                .alignmentGuide(.top) { _ in height }
            }
        }
    }
}

