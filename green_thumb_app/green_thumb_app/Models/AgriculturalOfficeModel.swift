import Foundation
import MapKit

struct AgriculturalOffice: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let phone: String
    let openingHours: String
    let isOpen: Bool
    let coordinate: CLLocationCoordinate2D

    // Sample Sri Lanka offices
    static let samples: [AgriculturalOffice] = [
        AgriculturalOffice(
            name: "Colombo Dept. of Agriculture",
            address: "80/5, Rajamalwatta Rd, Battaramulla",
            phone: "+94 11 2 786 200",
            openingHours: "Mon–Fri, 8:30 AM – 4:30 PM",
            isOpen: true,
            coordinate: CLLocationCoordinate2D(latitude: 6.9022, longitude: 79.9044)
        ),
        AgriculturalOffice(
            name: "Kandy Agriculture Office",
            address: "10 Sangaraja Mw, Kandy 20000",
            phone: "+94 81 2 222 415",
            openingHours: "Mon–Fri, 8:30 AM – 4:30 PM",
            isOpen: true,
            coordinate: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337)
        ),
        AgriculturalOffice(
            name: "Galle District Agriculture",
            address: "Wakwella Rd, Galle 80000",
            phone: "+94 91 2 222 391",
            openingHours: "Mon–Fri, 8:30 AM – 4:30 PM",
            isOpen: false,
            coordinate: CLLocationCoordinate2D(latitude: 6.0535, longitude: 80.2210)
        ),
        AgriculturalOffice(
            name: "Kurunegala Agri Extension",
            address: "Rajapihilla Mw, Kurunegala",
            phone: "+94 37 2 222 364",
            openingHours: "Mon–Fri, 8:30 AM – 4:30 PM",
            isOpen: true,
            coordinate: CLLocationCoordinate2D(latitude: 7.4867, longitude: 80.3647)
        ),
        AgriculturalOffice(
            name: "Jaffna Agriculture Office",
            address: "Hospital Rd, Jaffna 40000",
            phone: "+94 21 2 222 415",
            openingHours: "Mon–Fri, 8:30 AM – 4:30 PM",
            isOpen: true,
            coordinate: CLLocationCoordinate2D(latitude: 9.6615, longitude: 80.0255)
        ),
        AgriculturalOffice(
            name: "Ratnapura Agri Office",
            address: "Colombo Rd, Ratnapura 70000",
            phone: "+94 45 2 222 410",
            openingHours: "Mon–Fri, 8:30 AM – 4:30 PM",
            isOpen: false,
            coordinate: CLLocationCoordinate2D(latitude: 6.6828, longitude: 80.3992)
        )
    ]
}
