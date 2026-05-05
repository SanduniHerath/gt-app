/**
 * expert.controller.js — Expert listing, profiles, and reviews.
 */

import { v4 as uuidv4 } from 'uuid';
import FirestoreService from '../services/firestore.service.js';
import { COLLECTIONS, SUB_COLLECTIONS } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

/**
 * GET /api/experts
 */
export const listExperts = async (req, res, next) => {
  try {
    const { specialty, isOnline } = req.query;

    let query = FirestoreService.db
      .collection(COLLECTIONS.EXPERTS)
      .orderBy('rating', 'desc');

    if (specialty) query = query.where('specialties', 'array-contains', specialty);
    if (isOnline !== undefined) query = query.where('isOnline', '==', isOnline === 'true');

    const snap = await query.get();
    const experts = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    return res.json({ experts });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/experts/:expertId
 */
export const getExpert = async (req, res, next) => {
  try {
    const { expertId } = req.params;

    const snap = await FirestoreService.db
      .collection(COLLECTIONS.EXPERTS).doc(expertId).get();

    if (!snap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Expert not found.' });
    }

    // Fetch first 5 reviews
    const reviewsSnap = await FirestoreService.db
      .collection(COLLECTIONS.EXPERTS).doc(expertId)
      .collection(SUB_COLLECTIONS.REVIEWS)
      .orderBy('date', 'desc')
      .limit(5).get();

    const recentReviews = reviewsSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

    return res.json({
      expert: { id: snap.id, ...snap.data(), recentReviews },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/experts/:expertId/reviews
 */
export const listReviews = async (req, res, next) => {
  try {
    const { expertId } = req.params;
    const { limit = 10, startAfter } = req.query;

    let query = FirestoreService.db
      .collection(COLLECTIONS.EXPERTS).doc(expertId)
      .collection(SUB_COLLECTIONS.REVIEWS)
      .orderBy('date', 'desc')
      .limit(Number(limit) + 1);

    if (startAfter) {
      const cursor = await FirestoreService.db
        .collection(COLLECTIONS.EXPERTS).doc(expertId)
        .collection(SUB_COLLECTIONS.REVIEWS).doc(startAfter).get();
      if (cursor.exists) query = query.startAfter(cursor);
    }

    const snap = await query.get();
    const reviews = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    const hasMore = reviews.length > Number(limit);

    return res.json({ reviews: reviews.slice(0, Number(limit)), hasMore });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/experts/:expertId/reviews
 * Uses a Firestore transaction to atomically update the expert's rating.
 */
export const createReview = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { expertId } = req.params;
    const { rating, comment, topic = '' } = req.body;

    // Get user name for denormalisation
    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);

    const reviewId = uuidv4();
    const reviewData = {
      userId: uid,
      userName: user.displayName || 'Anonymous',
      rating,
      comment,
      topic,
      date: FieldValue.serverTimestamp(),
    };

    const expertRef = FirestoreService.db.collection(COLLECTIONS.EXPERTS).doc(expertId);
    const reviewRef = expertRef.collection(SUB_COLLECTIONS.REVIEWS).doc(reviewId);

    let newRating;

    await FirestoreService.runTransaction(async (tx) => {
      const expertSnap = await tx.get(expertRef);
      if (!expertSnap.exists) throw Object.assign(new Error('Expert not found'), { statusCode: 404 });

      const expertData = expertSnap.data();
      const currentCount = expertData.reviewCount || 0;
      const currentRating = expertData.rating || 0;

      // Recalculate running average
      newRating = ((currentRating * currentCount) + rating) / (currentCount + 1);
      newRating = Math.round(newRating * 10) / 10;

      tx.set(reviewRef, reviewData);
      tx.update(expertRef, {
        rating: newRating,
        reviewCount: FieldValue.increment(1),
      });
    });

    return res.status(201).json({
      success: true,
      review: { id: reviewId, ...reviewData },
      newRating,
    });
  } catch (err) {
    next(err);
  }
};
