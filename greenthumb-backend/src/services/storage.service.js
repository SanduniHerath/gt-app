/**
 * storage.service.js — Firebase Storage file operations.
 * Handles upload, delete, and signed URL generation.
 */

import { bucket } from '../config/firebase.js';

class StorageService {
  /**
   * Upload a file buffer to Firebase Storage and return its public download URL.
   * @param {Buffer} buffer - File data buffer
   * @param {string} mimeType - e.g. 'image/jpeg'
   * @param {string} storagePath - e.g. 'plants/uid/plantId/main.jpg'
   * @returns {Promise<string>} Public download URL
   */
  static async uploadFile(buffer, mimeType, storagePath) {
    const file = bucket.file(storagePath);

    await file.save(buffer, {
      metadata: {
        contentType: mimeType,
        cacheControl: 'public, max-age=31536000',
      },
    });

    // Make the file publicly readable
    await file.makePublic();

    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
    console.log(`[Storage Upload] ${storagePath} → ${publicUrl}`);
    return publicUrl;
  }

  /**
   * Delete a file from Firebase Storage by its storage path.
   * @param {string} storagePath
   */
  static async deleteFile(storagePath) {
    try {
      await bucket.file(storagePath).delete();
      console.log(`[Storage Delete] ${storagePath}`);
    } catch (err) {
      // Log but don't throw — file may already be deleted
      console.warn(`[Storage Delete] Failed to delete ${storagePath}: ${err.message}`);
    }
  }

  /**
   * Generate a signed (temporary, private) download URL.
   * @param {string} storagePath
   * @param {number} expiresInSeconds - How long the URL is valid
   * @returns {Promise<string>} Signed URL
   */
  static async getSignedURL(storagePath, expiresInSeconds = 3600) {
    const [url] = await bucket.file(storagePath).getSignedUrl({
      action: 'read',
      expires: Date.now() + expiresInSeconds * 1000,
    });
    return url;
  }
}

export default StorageService;
