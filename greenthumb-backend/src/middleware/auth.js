/**
 * auth.js — Firebase ID token verification middleware.
 * Extracts Bearer token, verifies it, and attaches decoded user to req.user.
 * Returns 401 for missing or invalid tokens.
 */

import { auth } from '../config/firebase.js';

/**
 * Verifies the Firebase ID token from the Authorization header.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'UNAUTHORISED',
        message: 'Missing or malformed Authorization header. Expected: Bearer <token>',
      });
    }

    const token = authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'UNAUTHORISED',
        message: 'No token provided.',
      });
    }

    const decoded = await auth.verifyIdToken(token);

    // Attach user info to request for downstream use
    req.user = {
      uid: decoded.uid,
      email: decoded.email || null,
      name: decoded.name || null,
    };

    next();
  } catch (err) {
    const code = err.code || '';

    if (code === 'auth/id-token-expired') {
      return res.status(401).json({
        error: 'TOKEN_EXPIRED',
        message: 'Your session has expired. Please sign in again.',
      });
    }

    if (code === 'auth/argument-error' || code === 'auth/id-token-revoked') {
      return res.status(401).json({
        error: 'INVALID_TOKEN',
        message: 'Invalid authentication token.',
      });
    }

    return res.status(401).json({
      error: 'UNAUTHORISED',
      message: 'Authentication failed.',
    });
  }
};

export default verifyToken;
