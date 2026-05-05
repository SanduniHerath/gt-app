/**
 * community.controller.js — Posts, comments, Q&A questions, answers, likes, saves.
 */

import { v4 as uuidv4 } from 'uuid';
import FirestoreService from '../services/firestore.service.js';
import FCMService from '../services/fcm.service.js';
import { COLLECTIONS, SUB_COLLECTIONS } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

// ── Posts ──────────────────────────────────────────────────────────────────────

/**
 * GET /api/community/posts
 */
export const listPosts = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { category, limit = 20, startAfter } = req.query;

    let query = FirestoreService.db
      .collection(COLLECTIONS.POSTS)
      .orderBy('createdAt', 'desc')
      .limit(Number(limit) + 1);

    if (category && category !== 'All') query = query.where('category', '==', category);

    if (startAfter) {
      const cursor = await FirestoreService.db
        .collection(COLLECTIONS.POSTS).doc(startAfter).get();
      if (cursor.exists) query = query.startAfter(cursor);
    }

    const snap = await query.get();
    const rawPosts = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    const hasMore = rawPosts.length > Number(limit);

    const posts = rawPosts.slice(0, Number(limit)).map((p) => ({
      ...p,
      isLiked: (p.likedBy || []).includes(uid),
      isSaved: (p.savedBy || []).includes(uid),
    }));

    return res.json({ posts, hasMore });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/posts
 */
export const createPost = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { title, body, category, keywords = [], imageURL } = req.body;

    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
    const postId = uuidv4();

    const postData = {
      authorId: uid,
      authorName: user.displayName || 'User',
      authorImageURL: user.profileImageURL || null,
      title,
      body,
      category,
      keywords,
      imageURL: imageURL || null,
      likeCount: 0,
      commentCount: 0,
      likedBy: [],
      savedBy: [],
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db.collection(COLLECTIONS.POSTS).doc(postId).set(postData);

    return res.status(201).json({ success: true, post: { id: postId, ...postData } });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/community/posts/:postId
 */
export const getPost = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { postId } = req.params;

    const snap = await FirestoreService.db.collection(COLLECTIONS.POSTS).doc(postId).get();
    if (!snap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Post not found.' });
    }

    const post = snap.data();
    return res.json({
      post: {
        id: snap.id,
        ...post,
        isLiked: (post.likedBy || []).includes(uid),
        isSaved: (post.savedBy || []).includes(uid),
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/posts/:postId/like  (toggle)
 */
export const toggleLike = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { postId } = req.params;

    const postRef = FirestoreService.db.collection(COLLECTIONS.POSTS).doc(postId);

    let isLiked;
    let likeCount;

    await FirestoreService.runTransaction(async (tx) => {
      const snap = await tx.get(postRef);
      if (!snap.exists) throw Object.assign(new Error('Post not found'), { statusCode: 404 });

      const post = snap.data();
      const likedBy = post.likedBy || [];
      isLiked = likedBy.includes(uid);

      if (isLiked) {
        tx.update(postRef, {
          likedBy: FieldValue.arrayRemove(uid),
          likeCount: FieldValue.increment(-1),
        });
        likeCount = (post.likeCount || 1) - 1;
        isLiked = false;
      } else {
        tx.update(postRef, {
          likedBy: FieldValue.arrayUnion(uid),
          likeCount: FieldValue.increment(1),
        });
        likeCount = (post.likeCount || 0) + 1;
        isLiked = true;
      }
    });

    return res.json({ success: true, likeCount, isLiked });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/posts/:postId/save  (toggle)
 */
export const toggleSave = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { postId } = req.params;

    const postRef = FirestoreService.db.collection(COLLECTIONS.POSTS).doc(postId);
    let isSaved;

    await FirestoreService.runTransaction(async (tx) => {
      const snap = await tx.get(postRef);
      if (!snap.exists) throw Object.assign(new Error('Post not found'), { statusCode: 404 });

      const savedBy = snap.data().savedBy || [];
      isSaved = savedBy.includes(uid);

      tx.update(postRef, {
        savedBy: isSaved
          ? FieldValue.arrayRemove(uid)
          : FieldValue.arrayUnion(uid),
      });
      isSaved = !isSaved;
    });

    return res.json({ success: true, isSaved });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/community/posts/:postId/comments
 */
export const listComments = async (req, res, next) => {
  try {
    const { postId } = req.params;

    const snap = await FirestoreService.db
      .collection(COLLECTIONS.POSTS).doc(postId)
      .collection(SUB_COLLECTIONS.COMMENTS)
      .orderBy('createdAt', 'asc')
      .get();

    const comments = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.json({ comments });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/posts/:postId/comments
 */
export const createComment = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { postId } = req.params;
    const { body } = req.body;

    const [user, postSnap] = await Promise.all([
      FirestoreService.getDocument(COLLECTIONS.USERS, uid),
      FirestoreService.db.collection(COLLECTIONS.POSTS).doc(postId).get(),
    ]);

    if (!postSnap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Post not found.' });
    }
    const post = postSnap.data();

    const commentId = uuidv4();
    const commentData = {
      authorId: uid,
      authorName: user.displayName || 'User',
      authorImageURL: user.profileImageURL || null,
      body,
      isExpert: false,
      likeCount: 0,
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db
      .collection(COLLECTIONS.POSTS).doc(postId)
      .collection(SUB_COLLECTIONS.COMMENTS).doc(commentId).set(commentData);

    await FirestoreService.db
      .collection(COLLECTIONS.POSTS).doc(postId)
      .update({ commentCount: FieldValue.increment(1) });

    // Notify post author if different user
    if (post.authorId !== uid) {
      try {
        const author = await FirestoreService.getDocument(COLLECTIONS.USERS, post.authorId);
        if (author.fcmToken) {
          await FCMService.sendToToken(
            author.fcmToken,
            `${user.displayName || 'Someone'} commented on your post`,
            body.length > 80 ? body.slice(0, 80) + '…' : body,
            { type: 'comment', postId }
          );
        }
      } catch (_) {}
    }

    return res.status(201).json({ success: true, comment: { id: commentId, ...commentData } });
  } catch (err) {
    next(err);
  }
};

// ── Q&A ────────────────────────────────────────────────────────────────────────

/**
 * GET /api/community/questions
 */
export const listQuestions = async (req, res, next) => {
  try {
    const { status, limit = 20, startAfter } = req.query;

    let query = FirestoreService.db
      .collection(COLLECTIONS.QUESTIONS)
      .orderBy('createdAt', 'desc')
      .limit(Number(limit) + 1);

    if (status) query = query.where('status', '==', status);

    if (startAfter) {
      const cursor = await FirestoreService.db
        .collection(COLLECTIONS.QUESTIONS).doc(startAfter).get();
      if (cursor.exists) query = query.startAfter(cursor);
    }

    const snap = await query.get();
    const questions = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    const hasMore = questions.length > Number(limit);

    return res.json({ questions: questions.slice(0, Number(limit)), hasMore });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/questions
 */
export const createQuestion = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { title, body, keywords = [] } = req.body;

    const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
    const questionId = uuidv4();

    const questionData = {
      authorId: uid,
      authorName: user.displayName || 'User',
      title,
      body,
      keywords,
      status: 'open',
      upvotes: 0,
      answerCount: 0,
      viewCount: 0,
      acceptedAnswerId: null,
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db.collection(COLLECTIONS.QUESTIONS).doc(questionId).set(questionData);

    return res.status(201).json({ success: true, question: { id: questionId, ...questionData } });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/community/questions/:questionId
 */
export const getQuestion = async (req, res, next) => {
  try {
    const { questionId } = req.params;

    const snap = await FirestoreService.db.collection(COLLECTIONS.QUESTIONS).doc(questionId).get();
    if (!snap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Question not found.' });
    }

    // Increment viewCount
    await snap.ref.update({ viewCount: FieldValue.increment(1) });

    const answersSnap = await FirestoreService.db
      .collection(COLLECTIONS.QUESTIONS).doc(questionId)
      .collection(SUB_COLLECTIONS.ANSWERS)
      .orderBy('createdAt', 'asc').get();

    const answers = answersSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

    return res.json({
      question: { id: snap.id, ...snap.data() },
      answers,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/questions/:questionId/answers
 */
export const createAnswer = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { questionId } = req.params;
    const { body } = req.body;

    const [user, questionSnap] = await Promise.all([
      FirestoreService.getDocument(COLLECTIONS.USERS, uid),
      FirestoreService.db.collection(COLLECTIONS.QUESTIONS).doc(questionId).get(),
    ]);

    if (!questionSnap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Question not found.' });
    }

    // Check if answerer is a verified expert
    const expertSnap = await FirestoreService.db.collection(COLLECTIONS.EXPERTS).doc(uid).get();
    const isExpert = expertSnap.exists;

    const answerId = uuidv4();
    const answerData = {
      authorId: uid,
      authorName: user.displayName || 'User',
      authorImageURL: user.profileImageURL || null,
      body,
      isExpert,
      upvotes: 0,
      isAccepted: false,
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db
      .collection(COLLECTIONS.QUESTIONS).doc(questionId)
      .collection(SUB_COLLECTIONS.ANSWERS).doc(answerId).set(answerData);

    // Update question status and answerCount
    const newStatus = isExpert ? 'expertReplied' : 'answered';
    await FirestoreService.db
      .collection(COLLECTIONS.QUESTIONS).doc(questionId)
      .update({
        answerCount: FieldValue.increment(1),
        status: newStatus,
      });

    // Notify question author
    const question = questionSnap.data();
    if (question.authorId !== uid) {
      try {
        const author = await FirestoreService.getDocument(COLLECTIONS.USERS, question.authorId);
        if (author.fcmToken) {
          await FCMService.sendToToken(
            author.fcmToken,
            isExpert ? '🌿 Expert answered your question!' : 'New answer on your question',
            `${user.displayName || 'Someone'} answered: "${question.title}"`,
            { type: 'answer', questionId }
          );
        }
      } catch (_) {}
    }

    return res.status(201).json({ success: true, answer: { id: answerId, ...answerData } });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/questions/:questionId/answers/:answerId/accept
 */
export const acceptAnswer = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { questionId, answerId } = req.params;

    const questionSnap = await FirestoreService.db
      .collection(COLLECTIONS.QUESTIONS).doc(questionId).get();

    if (!questionSnap.exists) {
      return res.status(404).json({ error: 'NOT_FOUND', message: 'Question not found.' });
    }

    if (questionSnap.data().authorId !== uid) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'Only the question author can accept an answer.' });
    }

    await FirestoreService.db
      .collection(COLLECTIONS.QUESTIONS).doc(questionId)
      .collection(SUB_COLLECTIONS.ANSWERS).doc(answerId)
      .update({ isAccepted: true });

    await FirestoreService.db
      .collection(COLLECTIONS.QUESTIONS).doc(questionId)
      .update({ acceptedAnswerId: answerId });

    return res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/community/questions/:questionId/vote
 */
export const voteQuestion = async (req, res, next) => {
  try {
    const { questionId } = req.params;
    const { direction } = req.body;

    const amount = direction === 'up' ? 1 : -1;
    const questionRef = FirestoreService.db.collection(COLLECTIONS.QUESTIONS).doc(questionId);

    let upvotes;
    await FirestoreService.runTransaction(async (tx) => {
      const snap = await tx.get(questionRef);
      if (!snap.exists) throw Object.assign(new Error('Question not found'), { statusCode: 404 });
      upvotes = (snap.data().upvotes || 0) + amount;
      tx.update(questionRef, { upvotes: FieldValue.increment(amount) });
    });

    return res.json({ success: true, upvotes });
  } catch (err) {
    next(err);
  }
};
