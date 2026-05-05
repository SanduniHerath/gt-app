/**
 * notification.controller.js — Send push notifications via FCM.
 */

import FCMService from '../services/fcm.service.js';
import FirestoreService from '../services/firestore.service.js';
import { COLLECTIONS } from '../config/constants.js';

/**
 * POST /api/notifications/send
 * Send a push notification to a single user by userId.
 */
export const sendNotification = async (req, res, next) => {
  try {
    const { userId, title, body, type = 'system', data = {} } = req.body;

    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, userId);

    if (!user.fcmToken) {
      return res.status(400).json({
        error: 'NO_FCM_TOKEN',
        message: 'User does not have a registered device token.',
      });
    }

    const messageId = await FCMService.sendToToken(
      user.fcmToken,
      title,
      body,
      { type, ...data }
    );

    return res.json({ success: true, messageId: messageId || 'sent' });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/notifications/send-bulk
 * Send to multiple users by userIds array.
 */
export const sendBulkNotification = async (req, res, next) => {
  try {
    const { userIds, title, body, type = 'system' } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({ error: 'INVALID_INPUT', message: 'userIds array is required.' });
    }

    // Fetch fcmTokens for all users
    const tokenPromises = userIds.map(async (uid) => {
      try {
        const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
        return user.fcmToken || null;
      } catch (_) {
        return null;
      }
    });

    const tokens = (await Promise.all(tokenPromises)).filter(Boolean);

    const { successCount, failureCount } = await FCMService.sendToMultipleTokens(
      tokens, title, body, { type }
    );

    return res.json({ success: true, successCount, failureCount });
  } catch (err) {
    next(err);
  }
};
