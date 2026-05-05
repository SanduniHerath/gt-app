/**
 * app.js — Express application setup.
 * Wires together middleware, routes, and the global error handler.
 * Does NOT call listen() — that's server.js's job.
 */

import 'express-async-errors';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

// Routes
import authRoutes         from './routes/auth.routes.js';
import userRoutes         from './routes/user.routes.js';
import plantRoutes        from './routes/plant.routes.js';
import schedulerRoutes    from './routes/scheduler.routes.js';
import diagnosisRoutes    from './routes/diagnosis.routes.js';
import expertRoutes       from './routes/expert.routes.js';
import sessionRoutes      from './routes/session.routes.js';
import notificationRoutes from './routes/notification.routes.js';
import communityRoutes    from './routes/community.routes.js';
import staticRoutes       from './routes/static.routes.js';

// Middleware
import errorHandler from './middleware/errorHandler.js';

const app = express();

// ── Security & Utility Middleware ─────────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: '*', // Tighten for production
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(morgan(process.env.NODE_ENV === 'development' ? 'dev' : 'combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ── Health Check ──────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'GreenThumb API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// ── API Routes ────────────────────────────────────────────────────────────────
// Static data (no auth required — must be mounted before other routes)
app.use('/api/static',        staticRoutes);

// Authenticated routes
app.use('/api/auth',          authRoutes);
app.use('/api/users',         userRoutes);
app.use('/api/plants',        plantRoutes);
app.use('/api/tasks',         schedulerRoutes);
app.use('/api/diagnosis',     diagnosisRoutes);
app.use('/api/experts',       expertRoutes);
app.use('/api/sessions',      sessionRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/community',     communityRoutes);

// ── 404 Handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    error: 'NOT_FOUND',
    message: `Route ${req.method} ${req.originalUrl} not found.`,
  });
});

// ── Global Error Handler (must be last) ───────────────────────────────────────
app.use(errorHandler);

export default app;
