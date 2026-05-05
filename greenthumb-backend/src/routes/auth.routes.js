import { Router } from 'express';
import { register, updateFcmToken, getMe } from '../controllers/auth.controller.js';
import verifyToken from '../middleware/auth.js';
import { validateRegister, validateFcmToken, checkValidation } from '../middleware/validate.js';

const router = Router();

// POST /api/auth/register — auth middleware applied inside controller (token still needed for uid)
router.post('/register', verifyToken, validateRegister, checkValidation, register);

// POST /api/auth/fcm-token
router.post('/fcm-token', verifyToken, validateFcmToken, checkValidation, updateFcmToken);

// GET /api/auth/me
router.get('/me', verifyToken, getMe);

export default router;
