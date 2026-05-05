import { Router } from 'express';
import { getProfile, updateProfile, uploadProfileImage, getStats } from '../controllers/user.controller.js';
import verifyToken from '../middleware/auth.js';
import { validateProfileUpdate, checkValidation } from '../middleware/validate.js';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

router.use(verifyToken);

router.get('/profile', getProfile);
router.put('/profile', validateProfileUpdate, checkValidation, updateProfile);
router.post('/profile-image', upload.single('image'), uploadProfileImage);
router.get('/stats', getStats);

export default router;
