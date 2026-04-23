import SwiftUI

struct GTCard: View {
    var cornerRadius: CGFloat = GTRadius.lg
    var padding: CGFloat = GTSpacing.md
    var backgroundColor: Color = .white
    @ViewBuilder let content: () -> any View

    var body: some View {
        AnyView(content())
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .gtShadow(GTShadow.card)
            )
    }
}

// A plant card used in lists
struct GTPlantCard: View {
    let plant: PlantModel

    var body: some View {
        HStack(spacing: GTSpacing.md) {
            // Plant avatar placeholder
            ZStack {
                RoundedRectangle(cornerRadius: GTRadius.md)
                    .fill(Color.gtPaleGreen)
                    .frame(width: 64, height: 64)
                Text("🪴").font(.system(size: 32))
            }

            VStack(alignment: .leading, spacing: GTSpacing.xxs) {
                Text(plant.name)
                    .font(GTFont.labelLarge())
                    .foregroundColor(.gtTextPrimary)
                Text(plant.species)
                    .font(GTFont.bodySmall())
                    .foregroundColor(.gtTextSecondary)
                HStack(spacing: GTSpacing.xxs) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.gtTextMuted)
                    Text(plant.location)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextMuted)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: GTSpacing.xxs) {
                GTStatusBadge.status(plant.status)
                GTHealthBar(value: plant.healthScore / 100)
                    .frame(width: 56)
            }
        }
        .padding(GTSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: GTRadius.md)
                .fill(.white)
                .gtShadow(GTShadow.card)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(PlantModel.samples) { plant in
            GTPlantCard(plant: plant)
        }
    }.padding()
}
