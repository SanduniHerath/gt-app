import { Router } from 'express';
import {
  listPlants, createPlant, getPlant, updatePlant,
  deletePlant, uploadPlantPhoto, getPlantHealth,
} from '../controllers/plant.controller.js';
import {
  listCareLog, createCareLogEntry, createCareLogPhoto, deleteCareLogEntry,
} from '../controllers/carelog.controller.js';
import verifyToken from '../middleware/auth.js';
import { validatePlant, validateCareLog, checkValidation } from '../middleware/validate.js';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });

router.use(verifyToken);

// Plant CRUD
router.get('/', listPlants);
router.post('/', validatePlant, checkValidation, createPlant);
router.get('/:plantId', getPlant);
router.put('/:plantId', updatePlant);
router.delete('/:plantId', deletePlant);
router.post('/:plantId/photo', upload.single('photo'), uploadPlantPhoto);
router.get('/:plantId/health', getPlantHealth);

// Care log (nested under plant)
router.get('/:plantId/carelog', listCareLog);
router.post('/:plantId/carelog', validateCareLog, checkValidation, createCareLogEntry);
router.post('/:plantId/carelog/photo', upload.single('photo'), createCareLogPhoto);
router.delete('/:plantId/carelog/:entryId', deleteCareLogEntry);

export default router;
