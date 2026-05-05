/**
 * plant.controller.js — CRUD for user plants plus health score calculation.
 */

import { v4 as uuidv4 } from 'uuid';
import FirestoreService from '../services/firestore.service.js';
import StorageService from '../services/storage.service.js';
import { COLLECTIONS, SUB_COLLECTIONS, PLANT_STATUS, HEALTH_SCORE } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

/** Helper: derive status string from numeric health score */
const scoreToStatus = (score) => {
  if (score >= HEALTH_SCORE.HEALTHY_MIN) return PLANT_STATUS.HEALTHY;
  if (score >= HEALTH_SCORE.NEEDS_CARE_MIN) return PLANT_STATUS.NEEDS_CARE;
  return PLANT_STATUS.CRITICAL;
};

/**
 * GET /api/plants
 */
export const listPlants = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { locationType, sortBy = 'dateAdded', order = 'desc', limit = 50 } = req.query;

    const filters = [];
    if (locationType) filters.push(['locationType', '==', locationType]);

    const plants = await FirestoreService.getSubcollection(
      COLLECTIONS.USERS, uid, SUB_COLLECTIONS.PLANTS,
      filters,
      { field: sortBy, direction: order },
      Number(limit)
    );

    return res.json({ plants, total: plants.length });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/plants
 */
export const createPlant = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { name, species, locationType = 'indoor', location = '', tags = [], dateAdded } = req.body;

    const plantId = uuidv4();
    const plantData = {
      name,
      species,
      locationType,
      location,
      tags,
      healthScore: 1.0,
      status: PLANT_STATUS.HEALTHY,
      wateringStreak: 0,
      photoURL: null,
      lastWatered: null,
      dateAdded: dateAdded ? new Date(dateAdded) : FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    };

    const plant = await FirestoreService.addToSubcollection(
      COLLECTIONS.USERS, uid, SUB_COLLECTIONS.PLANTS, plantData, plantId
    );

    return res.status(201).json({ success: true, plant: { id: plantId, ...plantData } });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/plants/:plantId
 */
export const getPlant = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;

    const plant = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId).get();

    if (!plant.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Plant not found.' });
    }

    return res.json({ plant: { id: plant.id, ...plant.data() } });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/plants/:plantId
 */
export const updatePlant = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;
    const { name, location, locationType, tags, healthScore } = req.body;

    const updates = {};
    if (name !== undefined) updates.name = name;
    if (location !== undefined) updates.location = location;
    if (locationType !== undefined) updates.locationType = locationType;
    if (tags !== undefined) updates.tags = tags;
    if (healthScore !== undefined) {
      updates.healthScore = healthScore;
      updates.status = scoreToStatus(healthScore);
    }

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId).update(updates);

    return res.json({ success: true, plant: { id: plantId, ...updates } });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/plants/:plantId
 * Deletes plant and all its subcollections.
 */
export const deletePlant = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;

    // Delete subcollections first
    await FirestoreService.deleteSubcollection(
      `${COLLECTIONS.USERS}/${uid}/${SUB_COLLECTIONS.PLANTS}`, plantId, SUB_COLLECTIONS.CARE_LOG
    );

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId).delete();

    // Also clean up any tasks referencing this plant
    const tasksSnap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.TASKS)
      .where('plantId', '==', plantId).get();

    const batch = FirestoreService.db.batch();
    tasksSnap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    return res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/plants/:plantId/photo
 */
export const uploadPlantPhoto = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;

    if (!req.file) {
      return res.status(400).json({ error: 'NO_FILE', message: 'No photo uploaded.' });
    }

    const storagePath = `plants/${uid}/${plantId}/main.jpg`;
    const photoURL = await StorageService.uploadFile(
      req.file.buffer, req.file.mimetype, storagePath
    );

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId).update({ photoURL });

    return res.json({ success: true, photoURL });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/plants/:plantId/health
 * Recalculates and persists the plant health score.
 */
export const getPlantHealth = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId } = req.params;

    const plantSnap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId).get();

    if (!plantSnap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Plant not found.' });
    }

    const plant = plantSnap.data();
    let score = 1.0;
    const now = Date.now();

    // Penalty: days since last watered vs recommended frequency (assume 3-day default)
    if (plant.lastWatered) {
      const lastWateredMs = plant.lastWatered._seconds
        ? plant.lastWatered._seconds * 1000
        : plant.lastWatered.toMillis?.() ?? now;
      const daysSinceWatered = (now - lastWateredMs) / (1000 * 60 * 60 * 24);
      const recommendedFreq = 3;
      if (daysSinceWatered > recommendedFreq * 2) score -= 0.4;
      else if (daysSinceWatered > recommendedFreq) score -= 0.2;
    } else {
      score -= 0.1; // Never been watered
    }

    // Penalty: missed tasks in last 7 days
    const sevenDaysAgo = new Date(now - 7 * 24 * 60 * 60 * 1000);
    const missedTasksSnap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.TASKS)
      .where('plantId', '==', plantId)
      .where('isCompleted', '==', false)
      .where('scheduledDate', '<=', new Date())
      .get();
    const missedCount = missedTasksSnap.size;
    score -= Math.min(missedCount * 0.1, 0.3);

    // Penalty: recent severe diagnoses
    const diagnosesSnap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.DIAGNOSES)
      .where('plantId', '==', plantId)
      .where('severity', '==', 'severe')
      .get();
    if (diagnosesSnap.size > 0) score -= 0.2;

    const healthScore = Math.max(0, Math.min(1, score));
    const status = scoreToStatus(healthScore);

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId).update({ healthScore, status });

    return res.json({ healthScore, status });
  } catch (err) {
    next(err);
  }
};
