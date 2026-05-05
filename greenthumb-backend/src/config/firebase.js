/**
 * Firebase Admin SDK — Singleton initialisation.
 * Exports: admin, db (Firestore), auth (Firebase Auth), bucket (Storage), messaging (FCM)
 */

import admin from 'firebase-admin';

let app;

if (!admin.apps.length) {
  const privateKey = process.env.FIREBASE_PRIVATE_KEY
    ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
    : undefined;

  app = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    }),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  });
} else {
  app = admin.apps[0];
}

/** @type {import('firebase-admin/firestore').Firestore} */
const db = admin.firestore();

/** @type {import('firebase-admin/auth').Auth} */
const auth = admin.auth();

/** @type {import('firebase-admin/storage').Storage} */
const bucket = admin.storage().bucket();

/** @type {import('firebase-admin/messaging').Messaging} */
const messaging = admin.messaging();

// Use ISO timestamps for consistency with the iOS app
db.settings({ ignoreUndefinedProperties: true });

export { admin, db, auth, bucket, messaging };
export default app;
