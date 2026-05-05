import { Router } from 'express';
import { listTasks, createTask, updateTask, deleteTask, getUpcomingTasks } from '../controllers/scheduler.controller.js';
import verifyToken from '../middleware/auth.js';
import { validateTask, checkValidation } from '../middleware/validate.js';

const router = Router();

router.use(verifyToken);

router.get('/', listTasks);
router.post('/', validateTask, checkValidation, createTask);
router.get('/upcoming', getUpcomingTasks);
router.put('/:taskId', updateTask);
router.delete('/:taskId', deleteTask);

export default router;
