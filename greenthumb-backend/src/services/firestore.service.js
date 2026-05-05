/**
 * firestore.service.js — Central Firestore abstraction layer.
 * All controllers must use these methods — never call Firestore directly.
 */

import { db, admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

class FirestoreService {
  // ── Document Operations ────────────────────────────────────────────────────

  /**
   * Fetch a single document.
   * @param {string} collection
   * @param {string} docId
   * @returns {Promise<{id: string, ...data}>}
   */
  static async getDocument(collection, docId) {
    const ref = db.collection(collection).doc(docId);
    const snap = await ref.get();
    if (!snap.exists) {
      const err = new Error(`Document ${docId} not found in ${collection}`);
      err.statusCode = 404;
      err.code = 'not-found';
      throw err;
    }
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Read] ${collection}/${docId}`);
    }
    return { id: snap.id, ...snap.data() };
  }

  /**
   * Set (create or overwrite) a document.
   * @param {string} collection
   * @param {string} docId
   * @param {object} data
   */
  static async setDocument(collection, docId, data) {
    const ref = db.collection(collection).doc(docId);
    await ref.set(data);
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] SET ${collection}/${docId}`);
    }
    return { id: docId, ...data };
  }

  /**
   * Update specific fields on a document.
   * @param {string} collection
   * @param {string} docId
   * @param {object} data
   */
  static async updateDocument(collection, docId, data) {
    const ref = db.collection(collection).doc(docId);
    await ref.update(data);
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] UPDATE ${collection}/${docId}`);
    }
    return { id: docId, ...data };
  }

  /**
   * Delete a document.
   * @param {string} collection
   * @param {string} docId
   */
  static async deleteDocument(collection, docId) {
    await db.collection(collection).doc(docId).delete();
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] DELETE ${collection}/${docId}`);
    }
  }

  // ── Collection Queries ─────────────────────────────────────────────────────

  /**
   * Fetch a collection with optional filters, ordering, and pagination.
   * @param {string} collection
   * @param {Array<[field, op, value]>} filters  - e.g. [['status','==','active']]
   * @param {{ field: string, direction?: 'asc'|'desc' }} orderBy
   * @param {number} limit
   * @param {object|null} startAfterDoc - Firestore DocumentSnapshot for cursor
   * @returns {Promise<Array<{id: string, ...data}>>}
   */
  static async getCollection(collection, filters = [], orderBy = null, limit = 20, startAfterDoc = null) {
    let query = db.collection(collection);

    for (const [field, op, value] of filters) {
      query = query.where(field, op, value);
    }

    if (orderBy) {
      query = query.orderBy(orderBy.field, orderBy.direction || 'asc');
    }

    if (startAfterDoc) {
      query = query.startAfter(startAfterDoc);
    }

    query = query.limit(limit);

    const snapshot = await query.get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Fetch a subcollection with optional filters and ordering.
   * @param {string} collection
   * @param {string} docId
   * @param {string} subcollection
   * @param {Array<[field, op, value]>} filters
   * @param {{ field: string, direction?: 'asc'|'desc' }} orderBy
   * @param {number} limit
   * @param {string|null} startAfterId - doc ID for cursor-based pagination
   */
  static async getSubcollection(collection, docId, subcollection, filters = [], orderBy = null, limit = 20, startAfterId = null) {
    let query = db.collection(collection).doc(docId).collection(subcollection);

    for (const [field, op, value] of filters) {
      query = query.where(field, op, value);
    }

    if (orderBy) {
      query = query.orderBy(orderBy.field, orderBy.direction || 'asc');
    }

    if (startAfterId) {
      const cursorDoc = await db.collection(collection).doc(docId).collection(subcollection).doc(startAfterId).get();
      if (cursorDoc.exists) {
        query = query.startAfter(cursorDoc);
      }
    }

    query = query.limit(limit);

    const snapshot = await query.get();
    return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  }

  /**
   * Add a document to a subcollection with an auto-generated or provided ID.
   * @param {string} collection
   * @param {string} docId
   * @param {string} subcollection
   * @param {object} data
   * @param {string|null} customId
   */
  static async addToSubcollection(collection, docId, subcollection, data, customId = null) {
    const ref = customId
      ? db.collection(collection).doc(docId).collection(subcollection).doc(customId)
      : db.collection(collection).doc(docId).collection(subcollection).doc();

    await ref.set(data);
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] ADD ${collection}/${docId}/${subcollection}/${ref.id}`);
    }
    return { id: ref.id, ...data };
  }

  /**
   * Update a document inside a subcollection.
   */
  static async updateSubcollectionDoc(collection, docId, subcollection, subDocId, data) {
    const ref = db.collection(collection).doc(docId).collection(subcollection).doc(subDocId);
    await ref.update(data);
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] UPDATE ${collection}/${docId}/${subcollection}/${subDocId}`);
    }
    return { id: subDocId, ...data };
  }

  /**
   * Delete a document from a subcollection.
   */
  static async deleteSubcollectionDoc(collection, docId, subcollection, subDocId) {
    await db.collection(collection).doc(docId).collection(subcollection).doc(subDocId).delete();
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] DELETE ${collection}/${docId}/${subcollection}/${subDocId}`);
    }
  }

  // ── Atomic Operations ──────────────────────────────────────────────────────

  /**
   * Run a Firestore transaction.
   * @param {(transaction: FirebaseFirestore.Transaction) => Promise<any>} updateFn
   */
  static async runTransaction(updateFn) {
    return db.runTransaction(updateFn);
  }

  /**
   * Add a value to an array field atomically.
   */
  static async arrayUnion(collection, docId, field, value) {
    await db.collection(collection).doc(docId).update({
      [field]: FieldValue.arrayUnion(value),
    });
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] ARRAY_UNION ${collection}/${docId}.${field}`);
    }
  }

  /**
   * Remove a value from an array field atomically.
   */
  static async arrayRemove(collection, docId, field, value) {
    await db.collection(collection).doc(docId).update({
      [field]: FieldValue.arrayRemove(value),
    });
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] ARRAY_REMOVE ${collection}/${docId}.${field}`);
    }
  }

  /**
   * Increment a numeric field atomically.
   * @param {string} collection
   * @param {string} docId
   * @param {string} field
   * @param {number} amount
   */
  static async increment(collection, docId, field, amount = 1) {
    await db.collection(collection).doc(docId).update({
      [field]: FieldValue.increment(amount),
    });
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] INCREMENT ${collection}/${docId}.${field} by ${amount}`);
    }
  }

  /**
   * Delete all documents in a subcollection (for cleanup on parent delete).
   * @param {string} collection
   * @param {string} docId
   * @param {string} subcollection
   */
  static async deleteSubcollection(collection, docId, subcollection) {
    const snap = await db.collection(collection).doc(docId).collection(subcollection).get();
    const batch = db.batch();
    snap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Firestore Write] DELETE_SUBCOLLECTION ${collection}/${docId}/${subcollection} (${snap.size} docs)`);
    }
  }

  /** Expose FieldValue for use in controllers */
  static get FieldValue() {
    return FieldValue;
  }

  /** Expose raw db reference for complex queries */
  static get db() {
    return db;
  }
}

export default FirestoreService;
