/**
 * fcm.service.js — Firebase Cloud Messaging push notifications.
 * All functions log errors but NEVER throw — a failed push must not crash the API.
 */

import { messaging } from '../config/firebase.js';

class FCMService {
  /**
   * Send a push notification to a single device token.
   * @param {string} fcmToken - Device FCM registration token
   * @param {string} title - Notification title
   * @param {string} body - Notification body
   * @param {object} data - Optional key-value data payload (all strings)
   * @returns {Promise<string|null>} FCM message ID or null on failure
   */
  static async sendToToken(fcmToken, title, body, data = {}) {
    if (!fcmToken) {
      console.warn('[FCM] Skipping send — no fcmToken provided');
      return null;
    }

    // FCM data payload values must all be strings
    const stringData = Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    );

    try {
      const messageId = await messaging.send({
        token: fcmToken,
        notification: { title, body },
        data: stringData,
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });
      console.log(`[FCM] Sent to token ...${fcmToken.slice(-8)}: "${title}"`);
      return messageId;
    } catch (err) {
      console.error(`[FCM] Failed to send to token: ${err.message}`);
      return null;
    }
  }

  /**
   * Send a push notification to multiple device tokens (multicast).
   * @param {string[]} tokens
   * @param {string} title
   * @param {string} body
   * @param {object} data
   * @returns {Promise<{successCount: number, failureCount: number}>}
   */
  static async sendToMultipleTokens(tokens, title, body, data = {}) {
    if (!tokens || tokens.length === 0) {
      console.warn('[FCM] Skipping multicast — no tokens provided');
      return { successCount: 0, failureCount: 0 };
    }

    const stringData = Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    );

    try {
      const response = await messaging.sendEachForMulticast({
        tokens,
        notification: { title, body },
        data: stringData,
      });
      console.log(`[FCM] Multicast: ${response.successCount} sent, ${response.failureCount} failed`);
      return {
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (err) {
      console.error(`[FCM] Multicast failed: ${err.message}`);
      return { successCount: 0, failureCount: tokens.length };
    }
  }

  /**
   * Send a push notification to a Firebase topic.
   * @param {string} topic
   * @param {string} title
   * @param {string} body
   * @param {object} data
   */
  static async sendToTopic(topic, title, body, data = {}) {
    const stringData = Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    );

    try {
      const messageId = await messaging.send({
        topic,
        notification: { title, body },
        data: stringData,
      });
      console.log(`[FCM] Sent to topic "${topic}": "${title}"`);
      return messageId;
    } catch (err) {
      console.error(`[FCM] Failed to send to topic "${topic}": ${err.message}`);
      return null;
    }
  }
}

export default FCMService;
