/**
 * errorHandler.js — Global Express error handler (4-argument middleware).
 * Maps Firebase and app errors to consistent HTTP responses.
 */

const FIREBASE_ERROR_MAP = {
  'auth/id-token-expired':   { status: 401, code: 'TOKEN_EXPIRED' },
  'auth/id-token-revoked':   { status: 401, code: 'TOKEN_REVOKED' },
  'auth/user-not-found':     { status: 404, code: 'USER_NOT_FOUND' },
  'not-found':               { status: 404, code: 'NOT_FOUND' },
  'permission-denied':       { status: 403, code: 'FORBIDDEN' },
  'resource-exhausted':      { status: 429, code: 'RATE_LIMITED' },
  'already-exists':          { status: 409, code: 'ALREADY_EXISTS' },
  'invalid-argument':        { status: 400, code: 'INVALID_ARGUMENT' },
  'unauthenticated':         { status: 401, code: 'UNAUTHORISED' },
};

/**
 * @param {Error} err
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  const isDev = process.env.NODE_ENV === 'development';

  if (isDev) {
    console.error('[Error]', err.stack || err.message);
  } else {
    console.error('[Error]', err.message);
  }

  // Firebase-specific errors
  const firebaseMatch = err.code ? FIREBASE_ERROR_MAP[err.code] : null;
  if (firebaseMatch) {
    return res.status(firebaseMatch.status).json({
      error: firebaseMatch.code,
      message: err.message || 'An error occurred.',
    });
  }

  // Validation errors from express-validator (passed via next())
  if (err.type === 'VALIDATION_ERROR') {
    return res.status(400).json({
      error: 'VALIDATION_ERROR',
      message: 'Request validation failed.',
      details: err.details,
    });
  }

  // App-level known errors
  if (err.statusCode) {
    return res.status(err.statusCode).json({
      error: err.code || 'APP_ERROR',
      message: err.message,
    });
  }

  // Default 500
  return res.status(500).json({
    error: 'INTERNAL_SERVER_ERROR',
    message: isDev ? err.message : 'An unexpected error occurred. Please try again.',
  });
};

export default errorHandler;
