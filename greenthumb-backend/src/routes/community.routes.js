import { Router } from 'express';
import {
  listPosts, createPost, getPost, toggleLike, toggleSave,
  listComments, createComment,
  listQuestions, createQuestion, getQuestion,
  createAnswer, acceptAnswer, voteQuestion,
} from '../controllers/community.controller.js';
import verifyToken from '../middleware/auth.js';
import { validatePost, validateQuestion, validateAnswer, checkValidation } from '../middleware/validate.js';

const router = Router();

router.use(verifyToken);

// Posts
router.get('/posts', listPosts);
router.post('/posts', validatePost, checkValidation, createPost);
router.get('/posts/:postId', getPost);
router.post('/posts/:postId/like', toggleLike);
router.post('/posts/:postId/save', toggleSave);
router.get('/posts/:postId/comments', listComments);
router.post('/posts/:postId/comments', createComment);

// Q&A
router.get('/questions', listQuestions);
router.post('/questions', validateQuestion, checkValidation, createQuestion);
router.get('/questions/:questionId', getQuestion);
router.post('/questions/:questionId/answers', validateAnswer, checkValidation, createAnswer);
router.post('/questions/:questionId/answers/:answerId/accept', acceptAnswer);
router.post('/questions/:questionId/vote', voteQuestion);

export default router;
