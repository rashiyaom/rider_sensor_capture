'use strict';

const EARTH_RADIUS_M = 6371008.8;
const MATCH_RADIUS_M = 35;
const ACTIVE_WINDOW_MS = 30 * 24 * 60 * 60 * 1000;
const FUTURE_CLOCK_SKEW_MS = 5 * 60 * 1000;

const ALLOWED_SOURCES = new Set(['ml', 'camera', 'voice', 'manual']);

function asMillis(value) {
  if (value instanceof Date) return value.getTime();
  if (value && typeof value.toMillis === 'function') return value.toMillis();
  return Number.NaN;
}

function validateReport(data, reportId, nowMs = Date.now()) {
  if (!data || typeof data !== 'object') return 'invalid_payload';
  if (data.reportKey !== reportId || typeof data.ownerUid !== 'string' || !data.ownerUid) {
    return 'invalid_identity';
  }
  if (data.eventType !== 'road_impact') return 'unsupported_event_type';
  if (typeof data.latitude !== 'number' || !Number.isFinite(data.latitude) ||
      data.latitude < -90 || data.latitude > 90 ||
      typeof data.longitude !== 'number' || !Number.isFinite(data.longitude) ||
      data.longitude < -180 || data.longitude > 180) {
    return 'invalid_location';
  }
  if (typeof data.horizontalAccuracyM !== 'number' ||
      !Number.isFinite(data.horizontalAccuracyM) ||
      data.horizontalAccuracyM <= 0 || data.horizontalAccuracyM > 15) {
    return 'invalid_gps_accuracy';
  }
  if (!ALLOWED_SOURCES.has(data.source) || typeof data.evidenceKind !== 'string' ||
      data.evidenceKind.trim().length === 0) {
    return 'invalid_evidence_source';
  }
  if (data.driverConfirmed !== true || data.locationShareConsented !== true) {
    return 'missing_confirmation_or_consent';
  }
  if (data.evidenceConfidence != null &&
      (typeof data.evidenceConfidence !== 'number' ||
       !Number.isFinite(data.evidenceConfidence) ||
       data.evidenceConfidence < 0 || data.evidenceConfidence > 1)) {
    return 'invalid_confidence';
  }
  const observedAtMs = asMillis(data.observedAtUtc);
  if (!Number.isFinite(observedAtMs) || observedAtMs > nowMs + FUTURE_CLOCK_SKEW_MS) {
    return 'invalid_observation_time';
  }
  if (observedAtMs < nowMs - ACTIVE_WINDOW_MS) return 'stale_report';
  return null;
}

function distanceMeters(a, b) {
  const toRadians = (degrees) => degrees * Math.PI / 180;
  const dLat = toRadians(b.latitude - a.latitude);
  const dLon = toRadians(b.longitude - a.longitude);
  const lat1 = toRadians(a.latitude);
  const lat2 = toRadians(b.latitude);
  const h = Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return 2 * EARTH_RADIUS_M * Math.asin(Math.min(1, Math.sqrt(h)));
}

function verificationStatus(independentDriverCount) {
  if (independentDriverCount >= 3) return 'verified';
  if (independentDriverCount >= 2) return 'corroborated';
  return 'candidate';
}

function findNearestActiveEvent(events, report, nowMs = Date.now()) {
  let nearest = null;
  let nearestDistance = MATCH_RADIUS_M;
  for (const event of events) {
    const observedAtMs = asMillis(event.lastObservedAt);
    if (!Number.isFinite(observedAtMs) || observedAtMs < nowMs - ACTIVE_WINDOW_MS) continue;
    const distance = distanceMeters(report, event);
    if (distance <= nearestDistance) {
      nearest = event;
      nearestDistance = distance;
    }
  }
  return nearest;
}

module.exports = {
  ACTIVE_WINDOW_MS,
  MATCH_RADIUS_M,
  asMillis,
  distanceMeters,
  findNearestActiveEvent,
  validateReport,
  verificationStatus,
};
