/**
 * App-wide constants shared across controllers and services.
 */

export const COLLECTIONS = {
  USERS: 'users',
  EXPERTS: 'experts',
  SESSIONS: 'sessions',
  POSTS: 'posts',
  QUESTIONS: 'questions',
};

export const SUB_COLLECTIONS = {
  PLANTS: 'plants',
  CARE_LOG: 'careLog',
  TASKS: 'tasks',
  DIAGNOSES: 'diagnoses',
  REVIEWS: 'reviews',
  MESSAGES: 'messages',
  COMMENTS: 'comments',
  ANSWERS: 'answers',
};

export const PLANT_STATUS = {
  HEALTHY: 'healthy',
  NEEDS_CARE: 'needsCare',
  CRITICAL: 'critical',
};

export const SESSION_STATUS = {
  PENDING: 'pending',
  ACTIVE: 'active',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
};

export const TASK_TYPES = ['watering', 'fertiliser', 'treatment', 'pruning', 'soiling', 'water', 'fertilize', 'repot', 'prune', 'inspect', 'mist'];

export const ENTRY_TYPES = ['watering', 'fertiliser', 'disease', 'treatment', 'note', 'photo', 'observation', 'fertilizing', 'repotting', 'pruning', 'diagnosis'];

export const LOCATION_TYPES = ['backyard', 'balcony', 'greenhouse', 'indoor', 'outdoor'];

export const SEVERITY_LEVELS = ['mild', 'moderate', 'severe'];

export const POST_CATEGORIES = ['Disease', 'Watering', 'Soil', 'Greenhouse', 'Pest', 'General', 'Herbs'];

export const EXPERT_SPECIALTIES = ['Disease', 'Soil', 'Greenhouse', 'Organic', 'Pests', 'Roses'];

export const ACHIEVEMENT_IDS = {
  FIRST_PLANT: 'first_plant',
  STREAK_7: 'streak_7',
  STREAK_30: 'streak_30',
  FIRST_SESSION: 'first_session',
  TEN_SESSIONS: 'ten_sessions',
  DIAGNOSED: 'diagnosed',
};

// Health score thresholds
export const HEALTH_SCORE = {
  HEALTHY_MIN: 0.7,
  NEEDS_CARE_MIN: 0.4,
};

// Pagination defaults
export const PAGINATION = {
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
};
