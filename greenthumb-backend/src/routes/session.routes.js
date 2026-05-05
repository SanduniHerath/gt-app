import { Router } from 'express';
import {
  bookSession, listSessions, getSession,
  updateSessionStatus, listMessages, sendMessage,
} from '../controllers/session.controller.js';
import verifyToken from '../middleware/auth.js';
import { validateBookSession, validateMessage, checkValidation } from '../middleware/validate.js';

const router = Router();

router.use(verifyToken);

router.post('/book', validateBookSession, checkValidation, bookSession);
router.get('/', listSessions);
router.get('/:sessionId', getSession);
router.put('/:sessionId/status', updateSessionStatus);
router.get('/:sessionId/messages', listMessages);
router.post('/:sessionId/messages', validateMessage, checkValidation, sendMessage);

export default router;
