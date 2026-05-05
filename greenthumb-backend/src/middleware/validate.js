/**
 * validate.js — express-validator rule sets and result checker.
 * Import the validation arrays and checkValidation into your routes.
 */

import { body, param, query, validationResult } from 'express-validator';
import { TASK_TYPES, ENTRY_TYPES, LOCATION_TYPES, SEVERITY_LEVELS, POST_CATEGORIES } from '../config/constants.js';

/**
 * Middleware that reads express-validator results and short-circuits with 400 on failure.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
export const checkValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'VALIDATION_ERROR',
      message: 'Request validation failed.',
      details: errors.array().map((e) => ({ field: e.path, message: e.msg })),
    });
  }
  next();
};

// ── Auth ──────────────────────────────────────────────────────────────────────
export const validateRegister = [
  body('displayName').trim().notEmpty().withMessage('displayName is required'),
  body('email').isEmail().withMessage('A valid email is required'),
  body('location').optional().isString(),
];

export const validateFcmToken = [
  body('fcmToken').trim().notEmpty().withMessage('fcmToken is required'),
];

// ── Plant ─────────────────────────────────────────────────────────────────────
export const validatePlant = [
  body('name').trim().notEmpty().withMessage('Plant name is required'),
  body('species').trim().notEmpty().withMessage('Species is required'),
  body('locationType')
    .optional()
    .isIn([...LOCATION_TYPES, 'outdoor', 'indoor'])
    .withMessage(`locationType must be one of: ${LOCATION_TYPES.join(', ')}`),
  body('location').optional().isString(),
  body('tags').optional().isArray(),
];

// ── Care Log ──────────────────────────────────────────────────────────────────
export const validateCareLog = [
  body('entryType')
    .isIn(ENTRY_TYPES)
    .withMessage(`entryType must be one of: ${ENTRY_TYPES.join(', ')}`),
  body('title').trim().notEmpty().withMessage('title is required'),
  body('body').optional().isString(),
  body('amount').optional().isString(),
  body('date').optional().isISO8601().withMessage('date must be ISO8601 format'),
];

// ── Scheduler Task ────────────────────────────────────────────────────────────
export const validateTask = [
  body('plantId').trim().notEmpty().withMessage('plantId is required'),
  body('plantName').trim().notEmpty().withMessage('plantName is required'),
  body('taskType')
    .isIn(TASK_TYPES)
    .withMessage(`taskType must be one of: ${TASK_TYPES.join(', ')}`),
  body('scheduledDate').isISO8601().withMessage('scheduledDate must be ISO8601 format'),
  body('frequency').optional().isString(),
  body('amount').optional().isString(),
];

// ── Diagnosis ─────────────────────────────────────────────────────────────────
export const validateDiagnosis = [
  body('plantId').trim().notEmpty().withMessage('plantId is required'),
  body('symptoms').isArray({ min: 1 }).withMessage('At least one symptom is required'),
  body('affectedAreas').optional().isArray(),
  body('severity')
    .isIn(SEVERITY_LEVELS)
    .withMessage(`severity must be one of: ${SEVERITY_LEVELS.join(', ')}`),
];

// ── Expert Review ─────────────────────────────────────────────────────────────
export const validateReview = [
  body('rating').isInt({ min: 1, max: 5 }).withMessage('rating must be between 1 and 5'),
  body('comment').trim().notEmpty().withMessage('comment is required'),
  body('topic').optional().isString(),
];

// ── Session ───────────────────────────────────────────────────────────────────
export const validateBookSession = [
  body('expertId').trim().notEmpty().withMessage('expertId is required'),
  body('topic').trim().notEmpty().withMessage('topic is required'),
  body('scheduledTime').isISO8601().withMessage('scheduledTime must be ISO8601 format'),
  body('plantId').optional().isString(),
];

export const validateMessage = [
  body('body').trim().notEmpty().withMessage('Message body is required'),
  body('attachmentURL').optional().isURL(),
  body('attachmentType').optional().isIn(['image', 'document', 'plant-report']),
];

// ── Community Post ────────────────────────────────────────────────────────────
export const validatePost = [
  body('title').trim().notEmpty().withMessage('title is required'),
  body('body').trim().notEmpty().withMessage('body is required'),
  body('category')
    .isIn(POST_CATEGORIES)
    .withMessage(`category must be one of: ${POST_CATEGORIES.join(', ')}`),
  body('keywords').optional().isArray(),
  body('imageURL').optional().isURL(),
];

// ── Community Question ────────────────────────────────────────────────────────
export const validateQuestion = [
  body('title')
    .trim()
    .notEmpty()
    .isLength({ max: 200 })
    .withMessage('title is required and must be under 200 characters'),
  body('body').trim().notEmpty().withMessage('body is required'),
  body('keywords').optional().isArray(),
];

export const validateAnswer = [
  body('body').trim().notEmpty().withMessage('Answer body is required'),
];

// ── User Profile ──────────────────────────────────────────────────────────────
export const validateProfileUpdate = [
  body('displayName').optional().trim().notEmpty(),
  body('handle').optional().trim().notEmpty(),
  body('location').optional().isString(),
  body('preferences').optional().isObject(),
];
