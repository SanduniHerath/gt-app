/**
 * static.routes.js — Public static data routes (NO auth required).
 * Serves hardcoded JSON data files that the iOS app can cache on first launch.
 */

import { Router } from 'express';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const router = Router();

// Load all static data at startup (cache in memory)
const symptoms      = require('../data/symptoms.json');
const species       = require('../data/plantSpecies.json');
const careGuides    = require('../data/careGuides.json');
const fertilisers   = require('../data/fertilisers.json');
const achievements  = require('../data/achievements.json');
const offices       = require('../data/officeLocations.json');

/** GET /api/static/symptoms */
router.get('/symptoms', (req, res) => {
  res.json({ symptoms });
});

/** GET /api/static/species */
router.get('/species', (req, res) => {
  res.json({ species });
});

/** GET /api/static/care-guide/:speciesId */
router.get('/care-guide/:speciesId', (req, res) => {
  const { speciesId } = req.params;
  const careGuide = careGuides[speciesId];

  if (!careGuide) {
    return res.status(404).json({
      error: 'NOT_FOUND',
      message: `No care guide found for species: ${speciesId}`,
    });
  }

  res.json({ careGuide });
});

/** GET /api/static/fertilisers?plantSpecies=rosa_hybrida */
router.get('/fertilisers', (req, res) => {
  const { plantSpecies } = req.query;

  if (plantSpecies) {
    const filtered = fertilisers.filter(
      (f) => !f.safeForPlants || f.safeForPlants.includes(plantSpecies)
    );
    return res.json({ fertilisers: filtered });
  }

  res.json({ fertilisers });
});

/** GET /api/static/achievements */
router.get('/achievements', (req, res) => {
  res.json({ achievements });
});

/** GET /api/static/office-locations */
router.get('/office-locations', (req, res) => {
  res.json({ offices });
});

export default router;
