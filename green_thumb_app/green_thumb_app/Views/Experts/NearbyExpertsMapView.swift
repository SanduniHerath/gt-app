import SwiftUI
import MapKit

struct NearbyExpertsMapView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var mapVM = NearbyExpertsMapViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Full Screen Map (iOS 17 native API)
            Map(position: $mapVM.cameraPosition) {
                // Show user's blue dot
                UserAnnotation()

                // Office pins — only nearby ones
                ForEach(mapVM.nearbyOffices) { office in
                    Annotation(office.name, coordinate: office.coordinate, anchor: .bottom) {
                        OfficePinView(
                            isSelected: mapVM.selectedOffice?.id == office.id,
                            isOpen: office.isOpen
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                mapVM.selectOffice(office)
                            }
                        }
                    }
                }

                // Route polyline
                if let route = mapVM.route {
                    MapPolyline(route.polyline)
                        .stroke(.blue.opacity(0.85), style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round,
                            lineJoin: .round
                        ))
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .mapStyle(.standard(emphasis: .automatic))
            .ignoresSafeArea()

            // MARK: - Floating Header
            VStack {
                HStack {
                    Button(action: { router.pop() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gtTextPrimary)
                        }
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Nearby Offices")
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text("\(mapVM.nearbyCount) found · \(mapVM.usingLocationFallback ? "Near Colombo" : "Near you")")
                            .font(GTFont.labelSmall())
                            .foregroundColor(.gtTextSecondary)
                    }
                    .padding(.horizontal, GTSpacing.md)
                    .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
                        )

                    Spacer()

                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.top, 60)
                Spacer()
            }

            // MARK: - Office Detail Card
            if mapVM.showDetailCard, let office = mapVM.selectedOffice {
                OfficeDetailCard(
                    office: office,
                    distance: mapVM.formattedDistance(to: office),
                    onGetDirections: { mapVM.openInAppleMaps(office) },
                    onDismiss: { mapVM.dismissDetailCard() }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: mapVM.showDetailCard)
    }
}

// MARK: - Custom Pin View
struct OfficePinView: View {
    let isSelected: Bool
    let isOpen: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.gtDarkGreen : Color.white)
                .frame(width: isSelected ? 52 : 40, height: isSelected ? 52 : 40)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
                .overlay(
                    Circle()
                        .stroke(isOpen ? Color.gtForestGreen : Color.gray, lineWidth: 3)
                )

            Image(systemName: "building.2.fill")
                .font(.system(size: isSelected ? 22 : 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gtForestGreen)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Office Detail Card
struct OfficeDetailCard: View {
    let office: AgriculturalOffice
    let distance: String?
    let onGetDirections: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            Capsule()
                .fill(Color.gtSeparator)
                .frame(width: 40, height: 4)
                .padding(.top, GTSpacing.md)

            VStack(alignment: .leading, spacing: GTSpacing.md) {
                // Header
                HStack(alignment: .top, spacing: GTSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gtForestGreen.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.gtForestGreen)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(office.name)
                            .font(GTFont.labelLarge())
                            .foregroundColor(.gtTextPrimary)
                        Text(office.address)
                            .font(GTFont.bodySmall())
                            .foregroundColor(.gtTextSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Text(office.isOpen ? "Open" : "Closed")
                        .font(GTFont.labelSmall())
                        .foregroundColor(office.isOpen ? Color(hex: "1A7A2E") : Color(hex: "B00020"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(office.isOpen ? Color(hex: "E6F4EA") : Color(hex: "FDECEA"))
                        )
                }

                Divider()

                // Info rows
                VStack(spacing: GTSpacing.sm) {
                    OfficeDetailRow(icon: "clock.fill", color: .gtAccentGreen, label: "Hours", value: office.openingHours)
                    OfficeDetailRow(icon: "phone.fill", color: .gtForestGreen, label: "Phone", value: office.phone, isPhone: true)
                    if let distance = distance {
                        OfficeDetailRow(icon: "location.fill", color: .gtBadgeTealText, label: "Distance", value: distance)
                    }
                }

                // Buttons
                HStack(spacing: GTSpacing.md) {
                    Button(action: onGetDirections) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.system(size: 15))
                            Text("Get Directions")
                                .font(GTFont.labelMedium())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.gtDarkGreen)
                        .foregroundColor(.white)
                        .cornerRadius(GTRadius.md)
                    }

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gtTextSecondary)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(Color(hex: "F0F0F0")))
                    }
                }
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.top, GTSpacing.md)
            .padding(.bottom, 40)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -4)
        )
    }
}

// MARK: - Detail Row
struct OfficeDetailRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    var isPhone: Bool = false

    var body: some View {
        HStack(spacing: GTSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(GTFont.labelSmall())
                    .foregroundColor(.gtTextMuted)
                if isPhone, let url = URL(string: "tel:\(value.replacingOccurrences(of: " ", with: ""))") {
                    Link(value, destination: url)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtForestGreen)
                } else {
                    Text(value)
                        .font(GTFont.bodySmall())
                        .foregroundColor(.gtTextPrimary)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    NearbyExpertsMapView()
        .environmentObject(AppRouter())
}
