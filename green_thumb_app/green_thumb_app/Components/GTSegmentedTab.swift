import SwiftUI

struct GTSegmentedTab: View {
    let options: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<options.count, id: \.self) { idx in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = idx
                        }
                    } label: {
                        VStack(spacing: 12) {
                            Text(options[idx])
                                .font(GTFont.labelLarge())
                                .foregroundColor(selectedIndex == idx ? .gtTextPrimary : .gtTextMuted)
                            
                            // Underline
                            Rectangle()
                                .fill(selectedIndex == idx ? Color.gtDarkGreen : Color.clear)
                                .frame(height: 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                    }
                }
            }
            .background(Color.white)
            
            Divider()
                .background(Color.gtBorder.opacity(0.5))
        }
    }
}

#Preview {
    @State var selected = 0
    return GTSegmentedTab(options: ["Watering", "Fertiliser"], selectedIndex: $selected)
}
