/**
 * auth.controller.js — Handles registration, FCM token updates, and current user fetch.
 */

import FirestoreService from '../services/firestore.service.js';
import { COLLECTIONS } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

/**
 * POST /api/auth/register
 * Firebase user already exists — this creates the Firestore user document.
 */
export const register = async (req, res, next) => {
  try {
    const { uid, email } = req.user;
    const { displayName, location = '' } = req.body;

    // Check if user document already exists
    let existingUser = null;
    try {
      existingUser = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
    } catch (_) {
      // 404 = doesn't exist yet, which is expected
    }

    if (existingUser) {
      return res.status(200).json({
        success: true,
        user: { uid, displayName: existingUser.displayName, email: existingUser.email },
      });
    }

    const now = FieldValue.serverTimestamp();
    const userData = {
      displayName,
      email,
      handle: `@${displayName.toLowerCase().replace(/\s+/g, '.')}`,
      profileImageURL: null,
      location,
      fcmToken: null,
      wateringStreak: 0,
      totalSessions: 0,
      memberSince: now,
      preferences: {
        tempUnit: 'C',
        waterUnit: 'ml',
        biometricEnabled: false,
        notificationsOn: true,
      },
      unlockedAchievements: [],
      createdAt: now,
    };

    await FirestoreService.setDocument(COLLECTIONS.USERS, uid, userData);

    return res.status(201).json({
      success: true,
      user: { uid, displayName, email },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/auth/fcm-token
 * Update the user's FCM device token.
 */
export const updateFcmToken = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { fcmToken } = req.body;

    await FirestoreService.updateDocument(COLLECTIONS.USERS, uid, { fcmToken });

    return res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/auth/me
 * Return the current authenticated user's Firestore profile.
 */
export const getMe = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);

    return res.json({ user });
  } catch (err) {
    next(err);
  }
};
