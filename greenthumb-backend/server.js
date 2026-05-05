/**
 * server.js — Entry point.
 * Loads environment variables, starts the Express server,
 * and handles unhandled errors gracefully.
 */

import 'dotenv/config';
import app from './src/app.js';

const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';

const server = app.listen(PORT, () => {
  console.log('');
  console.log('🌱  GreenThumb API Server');
  console.log(`    Listening on  : http://localhost:${PORT}`);
  console.log(`    Environment   : ${ENV}`);
  console.log(`    Base URL      : http://localhost:${PORT}/api`);
  console.log('');
});

// Graceful shutdown on unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('[UnhandledRejection]', reason);
  server.close(() => process.exit(1));
});

// Graceful shutdown on uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('[UncaughtException]', err);
  server.close(() => process.exit(1));
});

export default server;
