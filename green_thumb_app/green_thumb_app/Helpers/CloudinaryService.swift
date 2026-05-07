import UIKit
import Foundation

/// Uploads images to Cloudinary using unsigned upload preset.
/// No SDK needed — pure URLSession POST.
///
/// 🔧 SETUP: Replace these two constants with your own values from cloudinary.com
struct CloudinaryService {
    
    // ⚠️ REPLACE THESE WITH YOUR OWN CLOUDINARY VALUES
    private static let cloudName   = "dpphlrsjg"     // e.g. "my-garden-app"
    private static let uploadPreset = "green thumb" // e.g. "green_thumb_unsigned"
    
    // ─────────────────────────────────────────────────────────────
    /// Upload a UIImage and return its hosted URL string.
    /// Throws if the network request fails or the response is invalid.
    static func upload(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.badURL)
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Build multipart/form-data body
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // upload_preset field
        body.appendFormField(name: "upload_preset", value: uploadPreset, boundary: boundary)
        
        // file field
        body.appendFileField(
            name: "file",
            fileName: "plant_\(Date().timeIntervalSince1970).jpg",
            mimeType: "image/jpeg",
            data: imageData,
            boundary: boundary
        )
        
        // Close multipart body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "Cloudinary", code: 0, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        // Parse the secure URL from the response JSON
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let secureURL = json["secure_url"] as? String else {
            throw NSError(domain: "Cloudinary", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse image URL from response"])
        }
        
        print("✅ Cloudinary: Image uploaded → \(secureURL)")
        return secureURL
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Data helpers for building multipart body

private extension Data {
    mutating func appendFormField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }
    
    mutating func appendFileField(name: String, fileName: String, mimeType: String, data: Data, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(data)
        append("\r\n".data(using: .utf8)!)
    }
}
