/**
 * diagnosis.controller.js — Plant disease diagnosis via symptom matching engine.
 */

import { v4 as uuidv4 } from 'uuid';
import DiagnosisService from '../services/diagnosis.service.js';
import FirestoreService from '../services/firestore.service.js';
import FCMService from '../services/fcm.service.js';
import { COLLECTIONS, SUB_COLLECTIONS, PLANT_STATUS, ACHIEVEMENT_IDS } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

/**
 * POST /api/diagnosis/analyse
 */
export const analyseDiagnosis = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId, symptoms, affectedAreas = [], severity = 'moderate' } = req.body;

    // Verify plant belongs to user
    const plantSnap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId).get();

    if (!plantSnap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Plant not found.' });
    }
    const plant = plantSnap.data();

    // Run diagnosis engine
    const { diagnosis, alternatives } = DiagnosisService.analyse({ symptoms, affectedAreas, severity });

    // Save to Firestore
    const diagnosisId = uuidv4();
    const diagnosisData = {
      plantId,
      plantName: plant.name,
      symptoms,
      affectedAreas,
      severity,
      result: diagnosis.name,
      confidence: diagnosis.confidence,
      treatmentSteps: diagnosis.treatmentSteps,
      similarConditions: diagnosis.similarConditions,
      date: FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.DIAGNOSES).doc(diagnosisId).set(diagnosisData);

    // Update plant status based on severity
    const newStatus = severity === 'severe' ? PLANT_STATUS.CRITICAL : PLANT_STATUS.NEEDS_CARE;
    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.PLANTS).doc(plantId)
      .update({ status: newStatus });

    // Check and unlock "diagnosed" achievement (first diagnosis)
    const newAchievements = [];
    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
    if (!(user.unlockedAchievements || []).includes(ACHIEVEMENT_IDS.DIAGNOSED)) {
      await FirestoreService.arrayUnion(COLLECTIONS.USERS, uid, 'unlockedAchievements', ACHIEVEMENT_IDS.DIAGNOSED);
      newAchievements.push(ACHIEVEMENT_IDS.DIAGNOSED);
    }

    // Push notification
    if (user.fcmToken) {
      await FCMService.sendToToken(
        user.fcmToken,
        `Diagnosis complete — ${plant.name}`,
        `Detected: ${diagnosis.name} (${Math.round(diagnosis.confidence * 100)}% confidence)`,
        { type: 'diagnosis', diagnosisId, plantId }
      );
    }

    return res.status(201).json({
      diagnosis: { id: diagnosisId, ...diagnosis },
      alternatives,
      newAchievements,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/diagnosis
 */
export const listDiagnoses = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId, limit = 10 } = req.query;

    let query = FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.DIAGNOSES)
      .orderBy('date', 'desc')
      .limit(Number(limit));

    if (plantId) query = query.where('plantId', '==', plantId);

    const snap = await query.get();
    const diagnoses = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    return res.json({ diagnoses });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/diagnosis/:diagnosisId
 */
export const getDiagnosis = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { diagnosisId } = req.params;

    const snap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.DIAGNOSES).doc(diagnosisId).get();

    if (!snap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Diagnosis not found.' });
    }

    return res.json({ diagnosis: { id: snap.id, ...snap.data() } });
  } catch (err) {
    next(err);
  }
};
