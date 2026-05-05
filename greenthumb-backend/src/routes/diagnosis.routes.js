import { Router } from 'express';
import { analyseDiagnosis, listDiagnoses, getDiagnosis } from '../controllers/diagnosis.controller.js';
import verifyToken from '../middleware/auth.js';
import { validateDiagnosis, checkValidation } from '../middleware/validate.js';

const router = Router();

router.use(verifyToken);

router.post('/analyse', validateDiagnosis, checkValidation, analyseDiagnosis);
router.get('/', listDiagnoses);
router.get('/:diagnosisId', getDiagnosis);

export default router;
