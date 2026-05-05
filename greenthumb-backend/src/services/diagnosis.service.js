/**
 * diagnosis.service.js — Plant disease diagnosis engine.
 * Loads diseaseDatabase.json and scores each disease against user-submitted symptoms.
 * Scoring: matchScore = symptom overlap / disease symptoms  (70% weight)
 *          areaOverlap = affected area overlap / disease areas (30% weight)
 */

import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const diseaseDatabase = require('../data/diseaseDatabase.json');

/**
 * @typedef {Object} DiagnosisResult
 * @property {string}   id               - Disease ID
 * @property {string}   name             - Human-readable disease name
 * @property {number}   confidence       - 0.0 to 1.0
 * @property {string}   severity         - mild | moderate | severe
 * @property {Array}    treatmentSteps
 * @property {string[]} similarConditions
 */

class DiagnosisService {
  /**
   * Analyse symptoms and return the best-matching disease diagnosis.
   * @param {object} params
   * @param {string[]} params.symptoms      - Array of symptom IDs (from symptoms.json)
   * @param {string[]} params.affectedAreas - Array of affected area names
   * @param {string}   params.severity      - mild | moderate | severe
   * @returns {{ diagnosis: DiagnosisResult, alternatives: DiagnosisResult[] }}
   */
  static analyse({ symptoms = [], affectedAreas = [], severity = 'moderate' }) {
    if (symptoms.length === 0) {
      throw Object.assign(new Error('At least one symptom must be provided'), { statusCode: 400 });
    }

    const inputSymptoms = symptoms.map((s) => s.toLowerCase());
    const inputAreas = affectedAreas.map((a) => a.toLowerCase());

    const scored = diseaseDatabase.map((disease) => {
      const diseaseSymptoms = disease.matchingSymptoms.map((s) => s.toLowerCase());
      const diseaseAreas = (disease.affectedAreas || []).map((a) => a.toLowerCase());

      // Symptom match ratio
      const matchingCount = inputSymptoms.filter((s) => diseaseSymptoms.includes(s)).length;
      const matchScore = diseaseSymptoms.length > 0
        ? matchingCount / diseaseSymptoms.length
        : 0;

      // Affected area overlap ratio
      let areaOverlap = 0;
      if (diseaseAreas.length > 0 && inputAreas.length > 0) {
        const areaMatches = inputAreas.filter((a) => diseaseAreas.includes(a)).length;
        areaOverlap = areaMatches / diseaseAreas.length;
      }

      // Weighted confidence score
      const confidenceScore = matchScore * 0.7 + areaOverlap * 0.3;

      return {
        ...disease,
        confidence: Math.min(confidenceScore, 1.0),
        _matchScore: matchScore,
      };
    });

    // Sort by confidence descending
    scored.sort((a, b) => b.confidence - a.confidence);

    // Must have at least some symptom overlap to be a valid diagnosis
    const validResults = scored.filter((d) => d._matchScore > 0);

    if (validResults.length === 0) {
      // Return a generic response when no disease matches
      return {
        diagnosis: {
          id: 'unknown',
          name: 'Unknown Condition',
          confidence: 0,
          severity: severity,
          treatmentSteps: [
            {
              step: 1,
              title: 'Consult an expert',
              description: 'The symptoms provided did not match known disease patterns. Book a session with an agricultural expert for a professional assessment.',
              timing: 'As soon as possible',
            },
          ],
          similarConditions: [],
        },
        alternatives: [],
      };
    }

    const [top, ...rest] = validResults;

    // Clean internal scoring field
    const toResult = ({ _matchScore, ...d }) => ({
      id: d.id,
      name: d.name,
      confidence: Math.round(d.confidence * 100) / 100,
      severity: d.severity,
      treatmentSteps: d.treatmentSteps,
      similarConditions: d.similarConditions || [],
    });

    return {
      diagnosis: toResult(top),
      alternatives: rest.slice(0, 3).map(toResult),
    };
  }
}

export default DiagnosisService;
