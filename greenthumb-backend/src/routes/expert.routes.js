import { Router } from 'express';
import { listExperts, getExpert, listReviews, createReview } from '../controllers/expert.controller.js';
import verifyToken from '../middleware/auth.js';
import { validateReview, checkValidation } from '../middleware/validate.js';

const router = Router();

router.use(verifyToken);

router.get('/', listExperts);
router.get('/:expertId', getExpert);
router.get('/:expertId/reviews', listReviews);
router.post('/:expertId/reviews', validateReview, checkValidation, createReview);

export default router;
