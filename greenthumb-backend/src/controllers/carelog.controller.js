/**
 * carelog.controller.js — Care log entries per plant with streak and achievement logic.
 */

import { v4 as uuidv4 } from 'uuid';
import FirestoreService from '../services/firestore.service.js';
import StorageService from '../services/storage.service.js';
import { COLLECTIONS, SUB_COLLECTIONS, PLANT_STATUS, HEALTH_SCORE, ACHIEVEMENT_IDS } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

/** Recalculate consecutive watering streak for a plant */
const calcWateringStreak = async (uid, plantId) => {
  const logs = await FirestoreService.getSubcollection(
    COLLECTIONS.USERS, uid, `${SUB_COLLECTIONS.PLANTS}/${plantId}/${SUB_COLLECTIONS.CARE_LOG}`,
    [['entryType', '==', 'watering']],
    { field: 'date', direction: 'desc' },
    60
  );

  if (logs.length === 0) return 0;

  let streak = 1;
  const msPerDay = 86400000;

  for (let i = 0; i < logs.length - 1; i++) {
    const curr = logs[i].date?._seconds ? logs[i].date._seconds * 1000 : Date.now();
    const prev = logs[i + 1].date?._seconds ? logs[i + 1].date._seconds * 1000 : Date.now();
    const diff = Math.round((curr - prev) / msPerDay);
    if (diff <= 1) streak++;
    else break;
  }
  return streak;
};

/** Check and unlock achievements, return array of newly unlocked IDs */
const checkAchievements = async (uid, context) => {
  const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
  const unlocked = user.unlockedAchievements || [];
  const newlyUnlocked = [];

  const unlock = async (id) => {
    if (!unlocked.includes(id)) {
      await FirestoreService.arrayUnion(COLLECTIONS.USERS, uid, 'unlockedAchievements', id);
      newlyUnlocked.push(id);
    }
  };

  if (context.wateringStreak >= 7) await unlock(ACHIEVEMENT_IDS.STREAK_7);
  if (context.wateringStreak >= 30) await unlock(ACHIEVEMENT_IDS.STREAK_30);

  return newlyUnlocked;
};

/**
 * GET /api/plants/:plantId/carelog
 */
export const listCareLog = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;
    const { entryType, limit = 20, startAfter } = req.query;

    const filters = [];
    if (entryType) filters.push(['entryType', '==', entryType]);

    const basePath = `${COLLECTIONS.USERS}/${uid}/${SUB_COLLECTIONS.PLANTS}/${plantId}`;
    const entries = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId)
      .collection(SUB_COLLECTIONS.CARE_LOG)
      .orderBy('date', 'desc')
      .limit(Number(limit) + 1)
      .get()
      .then((snap) => snap.docs.map((d) => ({ id: d.id, ...d.data() })));

    const hasMore = entries.length > Number(limit);
    return res.json({ entries: entries.slice(0, Number(limit)), hasMore });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/plants/:plantId/carelog
 */
export const createCareLogEntry = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;
    const { entryType, title, body = '', amount, date } = req.body;

    const entryId = uuidv4();
    const entryData = {
      entryType,
      title,
      body,
      amount: amount || null,
      photoURL: null,
      date: date ? new Date(date) : FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId)
      .collection(SUB_COLLECTIONS.CARE_LOG).doc(entryId).set(entryData);

    let streakUpdated = false;
    let newAchievements = [];

    // Watering-specific logic
    if (entryType === 'watering') {
      const streak = await calcWateringStreak(uid, plantId);

      // Update plant
      await FirestoreService.db
        .collection(COLLECTIONS.USERS).doc(uid)
        .collection(SUB_COLLECTIONS.PLANTS).doc(plantId)
        .update({
          lastWatered: FieldValue.serverTimestamp(),
          wateringStreak: streak,
        });

      // Update user streak if better
      const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
      if (streak > (user.wateringStreak || 0)) {
        await FirestoreService.updateDocument(COLLECTIONS.USERS, uid, { wateringStreak: streak });
        streakUpdated = true;
      }

      // Check achievements
      newAchievements = await checkAchievements(uid, { wateringStreak: streak });
    }

    return res.status(201).json({
      success: true,
      entry: { id: entryId, ...entryData },
      streakUpdated,
      newAchievements,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/plants/:plantId/carelog/photo
 */
export const createCareLogPhoto = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;

    if (!req.file) {
      return res.status(400).json({ error: 'NO_FILE', message: 'No photo uploaded.' });
    }

    const entryId = uuidv4();
    const storagePath = `carelog/${uid}/${plantId}/${entryId}.jpg`;
    const photoURL = await StorageService.uploadFile(
      req.file.buffer, req.file.mimetype, storagePath
    );

    const entryData = {
      entryType: req.body.entryType || 'photo',
      title: req.body.title || 'Photo log',
      body: req.body.body || '',
      amount: null,
      photoURL,
      date: FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId)
      .collection(SUB_COLLECTIONS.CARE_LOG).doc(entryId).set(entryData);

    return res.status(201).json({ success: true, entry: { id: entryId, ...entryData, photoURL } });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/plants/:plantId/carelog/:entryId
 */
export const deleteCareLogEntry = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId, entryId } = req.params;

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId)
      .collection(SUB_COLLECTIONS.CARE_LOG).doc(entryId).delete();

    return res.json({ success: true });
  } catch (err) {
    next(err);
  }
};
