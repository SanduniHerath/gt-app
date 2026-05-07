import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var profileVM:  ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("pushNotificationsEnabled") private var pushNotifications = true
    @AppStorage("diseaseAlertsEnabled") private var diseaseAlerts = true
    @AppStorage("faceIDEnabled") private var faceIDEnabled = true
    @AppStorage("eventManagementEnabled") private var eventManagementEnabled = true
    @AppStorage("locationServicesEnabled") private var locationServices = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(alignment: .leading, spacing: GTSpacing.md) {
                // Top Navigation
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .circleButton()
                    }
                    Spacer()
                }
                .padding(.horizontal, GTSpacing.lg)
                .padding(.top, 54)
                
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(GTFont.displayLarge())
                        .foregroundColor(.white)
                    
                    Text("Manage your GreenThumb preferences")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gtLightGreen)
                }
                .padding(.horizontal, GTSpacing.lg)
                
                // Profile Dashboard Card
                HStack(spacing: GTSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.gtLightGreen)
                            .frame(width: 64, height: 64)
                        Text(initials)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(profileVM.profile.name)
                            .font(GTFont.labelLarge())
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                        
                        Text(profileVM.profile.email ?? "no-email@example.com")
                            .font(GTFont.bodySmall())
                            .foregroundColor(Color.gtLightGreen.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(GTSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: GTRadius.lg)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .background(Color.white.opacity(0.05))
                )
                .padding(.horizontal, GTSpacing.lg)
                .padding(.bottom, GTSpacing.lg)
            }
            .background(Color.gtForestGreen)
            
            // Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: GTSpacing.lg) {
                    // Notifications
                    GTSettingCard(title: "Notifications") {
                        GTSettingRow(
                            icon: "bell.fill",
                            iconBgColor: Color(hex: "D2B48C"),
                            title: "Push notifications",
                            subtitle: "Watering reminders & alerts",
                            isOn: $pushNotifications
                        )
                        Divider()
                        GTSettingRow(
                            icon: "exclamationmark.triangle.fill",
                            iconBgColor: Color(hex: "EE9E9E"),
                            title: "Disease alerts",
                            subtitle: "Immediate push when detected",
                            isOn: $diseaseAlerts
                        )
                    }
                    .padding(.top, GTSpacing.lg)
                    
                    // Security
                    GTSettingCard(title: "Security") {
                        GTSettingRow(
                            icon: "lock.fill",
                            iconBgColor: Color.gtLightGreen,
                            title: "Face ID/ Touch ID",
                            subtitle: "Biometric login enabled",
                            isOn: $faceIDEnabled
                        )
                    }
                    
                    // Advanced
                    GTSettingCard(title: "Advanced features") {
                        GTSettingRow(
                            icon: "calendar",
                            iconBgColor: Color.gtLightGreen,
                            title: "Gardeners events management",
                            subtitle: "manage your garden events",
                            showNewBadge: true,
                            isOn: $eventManagementEnabled
                        )
                        Divider()
                        GTSettingRow(
                            icon: "mappin.circle.fill",
                            iconBgColor: Color(hex: "40E0D0"),
                            title: "Location services",
                            subtitle: "For garden map & nearby offices",
                            isOn: $locationServices
                        )
                    }
                    
                    // Danger Zone
                    GTSettingCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DANGER ZONE")
                                .font(GTFont.labelMedium())
                                .foregroundColor(.orange)
                            
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.gtStatusUrgent)
                                Text("Delete account")
                                    .font(GTFont.labelMedium())
                                    .foregroundColor(.gtStatusUrgent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gtTextMuted)
                            }
                        }
                        .padding(.vertical, GTSpacing.sm)
                    }
                    
                    // Footer
                    VStack(spacing: 4) {
                        Text("GreenThumb")
                            .font(GTFont.labelMedium())
                            .foregroundColor(.gtTextPrimary.opacity(0.8))
                        Text("Version 1.0.0 (Build 42)")
                            .font(GTFont.bodySmall())
                            .foregroundColor(.gtTextMuted)
                    }
                    .padding(.vertical, GTSpacing.xl)
                    .padding(.bottom, GTSpacing.xxl)
                }
            }
            .background(Color.gtBackground)
        }
        .background(Color.gtForestGreen)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
    
    private var initials: String {
        profileVM.profile.name.components(separatedBy: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .prefix(2)
            .joined()
    }
}

#Preview {
    AppSettingsView()
        .environmentObject(ProfileViewModel())
}
