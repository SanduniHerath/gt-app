/**
 * session.controller.js — Expert session booking, status updates, and chat messaging.
 */

import { v4 as uuidv4 } from 'uuid';
import FirestoreService from '../services/firestore.service.js';
import FCMService from '../services/fcm.service.js';
import { COLLECTIONS, SUB_COLLECTIONS, SESSION_STATUS, ACHIEVEMENT_IDS } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

/**
 * POST /api/sessions/book
 */
export const bookSession = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { expertId, scheduledTime, topic, plantId } = req.body;

    const [user, expertSnap] = await Promise.all([
      FirestoreService.getDocument(COLLECTIONS.USERS, uid),
      FirestoreService.db.collection(COLLECTIONS.EXPERTS).doc(expertId).get(),
    ]);

    if (!expertSnap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Expert not found.' });
    }
    const expert = expertSnap.data();

    const sessionId = uuidv4();
    const sessionData = {
      userId: uid,
      expertId,
      topic,
      scheduledTime: new Date(scheduledTime),
      status: SESSION_STATUS.PENDING,
      plantId: plantId || null,
      participants: [uid, expertId],
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId).set(sessionData);

    // Increment user totalSessions
    await FirestoreService.increment(COLLECTIONS.USERS, uid, 'totalSessions');

    // Check for first_session achievement
    const newAchievements = [];
    if (!(user.unlockedAchievements || []).includes(ACHIEVEMENT_IDS.FIRST_SESSION)) {
      await FirestoreService.arrayUnion(COLLECTIONS.USERS, uid, 'unlockedAchievements', ACHIEVEMENT_IDS.FIRST_SESSION);
      newAchievements.push(ACHIEVEMENT_IDS.FIRST_SESSION);
    }

    // Check ten_sessions achievement
    const updatedUser = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
    if (updatedUser.totalSessions >= 10 && !(updatedUser.unlockedAchievements || []).includes(ACHIEVEMENT_IDS.TEN_SESSIONS)) {
      await FirestoreService.arrayUnion(COLLECTIONS.USERS, uid, 'unlockedAchievements', ACHIEVEMENT_IDS.TEN_SESSIONS);
      newAchievements.push(ACHIEVEMENT_IDS.TEN_SESSIONS);
    }

    // Notify expert
    if (expert.fcmToken) {
      await FCMService.sendToToken(
        expert.fcmToken,
        'New session booked',
        `${user.displayName} has booked a session on ${topic}`,
        { type: 'session', sessionId }
      );
    }

    // Confirm to user
    if (user.fcmToken) {
      await FCMService.sendToToken(
        user.fcmToken,
        'Session confirmed!',
        `Your session with ${expert.name} is booked for ${new Date(scheduledTime).toLocaleString()}`,
        { type: 'session', sessionId }
      );
    }

    return res.status(201).json({
      success: true,
      session: { id: sessionId, ...sessionData },
      newAchievements,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/sessions
 */
export const listSessions = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { status } = req.query;

    let query = FirestoreService.db
      .collection(COLLECTIONS.SESSIONS)
      .where('participants', 'array-contains', uid)
      .orderBy('scheduledTime', 'desc');

    if (status) query = query.where('status', '==', status);

    const snap = await query.get();
    const sessions = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    return res.json({ sessions });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/sessions/:sessionId
 */
export const getSession = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { sessionId } = req.params;

    const snap = await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId).get();

    if (!snap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Session not found.' });
    }

    const session = snap.data();
    if (!session.participants.includes(uid)) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'You are not a participant in this session.' });
    }

    return res.json({ session: { id: snap.id, ...session } });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/sessions/:sessionId/status
 */
export const updateSessionStatus = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { sessionId } = req.params;
    const { status } = req.body;

    const snap = await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId).get();

    if (!snap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Session not found.' });
    }

    const session = snap.data();
    if (!session.participants.includes(uid)) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'Not a participant.' });
    }

    const updates = { status };
    if (status === SESSION_STATUS.COMPLETED) {
      updates.completedAt = FieldValue.serverTimestamp();
      // Increment expert totalSessions
      await FirestoreService.increment(COLLECTIONS.EXPERTS, session.expertId, 'totalSessions');
    }

    await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId).update(updates);

    return res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/sessions/:sessionId/messages
 */
export const listMessages = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { sessionId } = req.params;
    const { limit = 50 } = req.query;

    // Verify participant
    const sessionSnap = await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId).get();
    if (!sessionSnap.exists || !sessionSnap.data().participants.includes(uid)) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'Not a participant.' });
    }

    const snap = await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId)
      .collection(SUB_COLLECTIONS.MESSAGES)
      .orderBy('timestamp', 'asc')
      .limit(Number(limit))
      .get();

    const messages = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.json({ messages });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/sessions/:sessionId/messages
 */
export const sendMessage = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { sessionId } = req.params;
    const { body, attachmentURL, attachmentType } = req.body;

    // Verify participant
    const sessionSnap = await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId).get();
    if (!sessionSnap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Session not found.' });
    }

    const session = sessionSnap.data();
    if (!session.participants.includes(uid)) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'Not a participant.' });
    }

    const sender = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);

    const messageId = uuidv4();
    const messageData = {
      senderId: uid,
      senderName: sender.displayName || 'User',
      body,
      timestamp: FieldValue.serverTimestamp(),
      attachmentURL: attachmentURL || null,
      attachmentType: attachmentType || null,
    };

    await FirestoreService.db
      .collection(COLLECTIONS.SESSIONS).doc(sessionId)
      .collection(SUB_COLLECTIONS.MESSAGES).doc(messageId).set(messageData);

    // Notify the other participant
    const otherParticipantId = session.participants.find((p) => p !== uid);
    if (otherParticipantId) {
      try {
        // Try user collection first, then expert
        let recipientFcmToken = null;
        try {
          const recipient = await FirestoreService.getDocument(COLLECTIONS.USERS, otherParticipantId);
          recipientFcmToken = recipient.fcmToken;
        } catch (_) {
          const expertSnap = await FirestoreService.db
            .collection(COLLECTIONS.EXPERTS).doc(otherParticipantId).get();
          if (expertSnap.exists) recipientFcmToken = expertSnap.data().fcmToken;
        }

        if (recipientFcmToken) {
          await FCMService.sendToToken(
            recipientFcmToken,
            `New message from ${sender.displayName || 'User'}`,
            body.length > 80 ? body.slice(0, 80) + '…' : body,
            { type: 'message', sessionId }
          );
        }
      } catch (_) { /* don't block on notification errors */ }
    }

    return res.status(201).json({ success: true, message: { id: messageId, ...messageData } });
  } catch (err) {
    next(err);
  }
};
