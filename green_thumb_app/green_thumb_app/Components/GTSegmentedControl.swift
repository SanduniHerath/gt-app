import SwiftUI

struct GTSegmentedControl: View {
    let options: [String]
    @Binding var selectedIndex: Int
    var onChanged: ((Int) -> Void)? = nil

    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<options.count, id: \.self) { idx in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = idx
                        onChanged?(idx)
                    }
                } label: {
                    Text(options[idx])
                        .font(GTFont.labelMedium())
                        .foregroundColor(selectedIndex == idx ? .gtTextPrimary : .gtTextMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, GTSpacing.sm)
                        .background(
                            ZStack {
                                if selectedIndex == idx {
                                    RoundedRectangle(cornerRadius: GTRadius.xl)
                                        .fill(Color.white)
                                        .gtShadow(GTShadow.card)
                                        .matchedGeometryEffect(id: "activeTab", in: namespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.xl)
                .fill(Color(red: 0.94, green: 0.95, blue: 0.92))
        )
    }
    
    @Namespace private var namespace
}

#Preview {
    @State var selected = 0
    return GTSegmentedControl(options: ["Sign in", "Register"], selectedIndex: $selected)
        .padding()
}
