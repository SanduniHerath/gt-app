import { Router } from 'express';
import { sendNotification, sendBulkNotification } from '../controllers/notification.controller.js';
import verifyToken from '../middleware/auth.js';

const router = Router();

router.use(verifyToken);

router.post('/send', sendNotification);
router.post('/send-bulk', sendBulkNotification);

export default router;
