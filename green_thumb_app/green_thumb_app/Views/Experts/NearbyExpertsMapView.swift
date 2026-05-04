import SwiftUI
import MapKit

struct OfficerLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct NearbyExpertsMapView: View {
    @EnvironmentObject var router: AppRouter
    
    // Mock data for markers
    let officers = [
        OfficerLocation(name: "Officer A", coordinate: CLLocationCoordinate2D(latitude: 32.7850, longitude: -96.8000)),
        OfficerLocation(name: "Officer B", coordinate: CLLocationCoordinate2D(latitude: 32.7750, longitude: -96.7900)),
        OfficerLocation(name: "Officer C", coordinate: CLLocationCoordinate2D(latitude: 32.7800, longitude: -96.8100)),
        OfficerLocation(name: "Officer D", coordinate: CLLocationCoordinate2D(latitude: 32.7700, longitude: -96.8050))
    ]
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    router.pop()
                }) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 44, height: 44)
                            .gtShadow(GTShadow.card)
                        
                        Image(systemName: "arrow.left")
                            .foregroundColor(.gtTextPrimary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                
                Spacer()
                
                Text("Nearby Officers")
                    .font(GTFont.displayMedium())
                    .foregroundColor(.gtTextPrimary)
                
                Spacer()
                
                // Invisible placeholder to center the title
                Circle()
                    .fill(.clear)
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, GTSpacing.lg)
            .padding(.top, 60)
            .padding(.bottom, GTSpacing.lg)
            .background(Color.white)
            
            // Map Container
            ZStack {
                Color(red: 0.9, green: 0.9, blue: 0.9) // Background color matching the screenshot's gray area
                
                Map(coordinateRegion: $region, annotationItems: officers) { officer in
                    MapAnnotation(coordinate: officer.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                            .background(Circle().fill(.white).frame(width: 20, height: 20))
                    }
                }
                .cornerRadius(GTRadius.lg)
                .padding(GTSpacing.lg)
                .gtShadow(GTShadow.card)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

#Preview {
    NearbyExpertsMapView()
        .environmentObject(AppRouter())
}
