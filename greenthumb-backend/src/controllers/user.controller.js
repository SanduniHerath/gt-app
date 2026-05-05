/**
 * user.controller.js — User profile, stats, and profile image upload.
 */

import FirestoreService from '../services/firestore.service.js';
import StorageService from '../services/storage.service.js';
import { COLLECTIONS, SUB_COLLECTIONS } from '../config/constants.js';

/**
 * GET /api/users/profile
 */
export const getProfile = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
    return res.json({ user });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/users/profile
 * Update allowed profile fields only.
 */
export const updateProfile = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { displayName, handle, location, preferences } = req.body;

    const updates = {};
    if (displayName !== undefined) updates.displayName = displayName;
    if (handle !== undefined) updates.handle = handle;
    if (location !== undefined) updates.location = location;
    if (preferences !== undefined) updates.preferences = preferences;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'NO_FIELDS', message: 'No updatable fields provided.' });
    }

    const updated = await FirestoreService.updateDocument(COLLECTIONS.USERS, uid, updates);
    return res.json({ success: true, user: updated });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/users/profile-image
 * Upload profile avatar to Firebase Storage, update user document.
 */
export const uploadProfileImage = async (req, res, next) => {
  try {
    const { uid } = req.user;

    if (!req.file) {
      return res.status(400).json({ error: 'NO_FILE', message: 'No image file uploaded.' });
    }

    const storagePath = `profiles/${uid}/avatar.jpg`;
    const imageURL = await StorageService.uploadFile(
      req.file.buffer,
      req.file.mimetype,
      storagePath
    );

    await FirestoreService.updateDocument(COLLECTIONS.USERS, uid, { profileImageURL: imageURL });

    return res.json({ success: true, imageURL });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/users/stats
 * Aggregate stats from Firestore subcollections.
 */
export const getStats = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);

    // Count plants
    const plantsSnap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).get();
    const totalPlants = plantsSnap.size;

    // Count care log entries across all plants
    let totalLogEntries = 0;
    for (const plantDoc of plantsSnap.docs) {
      const logsSnap = await FirestoreService.db
        .collection(COLLECTIONS.USERS).doc(uid)
        .collection(SUB_COLLECTIONS.PLANTS).doc(plantDoc.id)
        .collection(SUB_COLLECTIONS.CARE_LOG).get();
      totalLogEntries += logsSnap.size;
    }

    // Load achievement definitions to get total count
    const { createRequire } = await import('module');
    const require = createRequire(import.meta.url);
    const allAchievements = require('../data/achievements.json');

    return res.json({
      totalPlants,
      totalLogEntries,
      wateringStreak: user.wateringStreak || 0,
      totalSessions: user.totalSessions || 0,
      unlockedCount: (user.unlockedAchievements || []).length,
      totalAchievements: allAchievements.length,
    });
  } catch (err) {
    next(err);
  }
};
