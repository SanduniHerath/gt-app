/**
 * scheduler.controller.js — Smart scheduler tasks (create, list, complete, delete).
 */

import { v4 as uuidv4 } from 'uuid';
import FirestoreService from '../services/firestore.service.js';
import FCMService from '../services/fcm.service.js';
import { COLLECTIONS, SUB_COLLECTIONS } from '../config/constants.js';
import { admin } from '../config/firebase.js';

const { FieldValue } = admin.firestore;

/**
 * GET /api/tasks
 */
export const listTasks = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { date, taskType } = req.query;

    let query = FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.TASKS)
      .orderBy('scheduledDate', 'asc');

    if (taskType) query = query.where('taskType', '==', taskType);

    if (date) {
      const start = new Date(date);
      start.setHours(0, 0, 0, 0);
      const end = new Date(date);
      end.setHours(23, 59, 59, 999);
      query = query.where('scheduledDate', '>=', start).where('scheduledDate', '<=', end);
    }

    const snap = await query.get();
    const tasks = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    const now = new Date();
    const todayCount = tasks.filter((t) => {
      const scheduled = t.scheduledDate?._seconds
        ? new Date(t.scheduledDate._seconds * 1000)
        : new Date(t.scheduledDate);
      return scheduled.toDateString() === now.toDateString();
    }).length;

    const pendingCount = tasks.filter((t) => !t.isCompleted).length;

    return res.json({ tasks, todayCount, pendingCount });
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/tasks
 */
export const createTask = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { plantId, plantName, taskType, scheduledDate, frequency = 'One-time', amount } = req.body;

    const taskId = uuidv4();
    const taskData = {
      plantId,
      plantName,
      taskType,
      scheduledDate: new Date(scheduledDate),
      frequency,
      amount: amount || null,
      isCompleted: false,
      createdAt: FieldValue.serverTimestamp(),
    };

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.TASKS).doc(taskId).set(taskData);

    // Send push notification for the task
    try {
      const user = await FirestoreService.getDocument(COLLECTIONS.USERS, uid);
      if (user.fcmToken) {
        await FCMService.sendToToken(
          user.fcmToken,
          `Reminder: ${taskType} — ${plantName}`,
          `Scheduled for ${new Date(scheduledDate).toLocaleString()}`,
          { type: 'task', taskId, plantId }
        );
      }
    } catch (_) { /* FCM errors don't block response */ }

    return res.status(201).json({ success: true, task: { id: taskId, ...taskData } });
  } catch (err) {
    next(err);
  }
};

/**
 * PUT /api/tasks/:taskId
 */
export const updateTask = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { taskId } = req.params;
    const { scheduledDate, frequency, isCompleted } = req.body;

    const updates = {};
    if (scheduledDate !== undefined) updates.scheduledDate = new Date(scheduledDate);
    if (frequency !== undefined) updates.frequency = frequency;
    if (isCompleted !== undefined) updates.isCompleted = isCompleted;

    // If completing a watering task — update plant.lastWatered and add care log entry
    if (isCompleted === true) {
      const taskSnap = await FirestoreService.db
        .collection(COLLECTIONS.USERS).doc(uid)
        .collection(SUB_COLLECTIONS.TASKS).doc(taskId).get();

      if (taskSnap.exists) {
        const task = taskSnap.data();
        if (task.taskType === 'watering' || task.taskType === 'water') {
          // Update plant lastWatered
          await FirestoreService.db
            .collection(COLLECTIONS.USERS).doc(uid)
            .collection(SUB_COLLECTIONS.PLANTS).doc(task.plantId)
            .update({ lastWatered: FieldValue.serverTimestamp() });

          // Auto-create care log entry
          await FirestoreService.db
            .collection(COLLECTIONS.USERS).doc(uid)
            .collection(SUB_COLLECTIONS.PLANTS).doc(task.plantId)
            .collection(SUB_COLLECTIONS.CARE_LOG).add({
              entryType: 'watering',
              title: `Watered ${task.amount || ''}`.trim(),
              body: `Task completed via Smart Scheduler`,
              amount: task.amount || null,
              photoURL: null,
              date: FieldValue.serverTimestamp(),
              createdAt: FieldValue.serverTimestamp(),
            });
        }
      }
    }

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.TASKS).doc(taskId).update(updates);

    return res.json({ success: true, task: { id: taskId, ...updates } });
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /api/tasks/:taskId
 */
export const deleteTask = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const { taskId } = req.params;

    await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.TASKS).doc(taskId).delete();

    return res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/tasks/upcoming
 */
export const getUpcomingTasks = async (req, res, next) => {
  try {
    const { uid } = req.user;
    const days = Number(req.query.days) || 7;

    const now = new Date();
    const end = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

    const snap = await FirestoreService.db
      .collection(COLLECTIONS.USERS).doc(uid)
      .collection(SUB_COLLECTIONS.TASKS)
      .where('scheduledDate', '>=', now)
      .where('scheduledDate', '<=', end)
      .orderBy('scheduledDate', 'asc')
      .get();

    const tasks = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.json({ tasks });
  } catch (err) {
    next(err);
  }
};
