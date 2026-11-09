'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const {
  distanceMeters,
  findNearestActiveEvent,
  validateReport,
  verificationStatus,
} = require('../domain');

const now = Date.UTC(2026, 10, 6, 12);
const baseReport = {
  reportKey: 'report-1',
  ownerUid: 'driver-1',
  eventType: 'road_impact',
  latitude: 19.076,
  longitude: 72.8777,
  horizontalAccuracyM: 8,
  observedAtUtc: new Date(now - 1000),
  source: 'ml',
  evidenceKind: 'imu_impact',
  evidenceConfidence: 0.9,
  driverConfirmed: true,
  locationShareConsented: true,
};

test('accepts a recent, consented road impact with accurate GPS', () => {
  assert.equal(validateReport(baseReport, 'report-1', now), null);
});

test('rejects weak GPS, missing consent, and unsupported labels', () => {
  assert.equal(validateReport({...baseReport, horizontalAccuracyM: 15.1}, 'report-1', now), 'invalid_gps_accuracy');
  assert.equal(validateReport({...baseReport, locationShareConsented: false}, 'report-1', now), 'missing_confirmation_or_consent');
  assert.equal(validateReport({...baseReport, eventType: 'pothole'}, 'report-1', now), 'unsupported_event_type');
});

test('marks reports older than the active window as stale', () => {
  const old = new Date(now - 31 * 24 * 60 * 60 * 1000);
  assert.equal(validateReport({...baseReport, observedAtUtc: old}, 'report-1', now), 'stale_report');
});

test('matches only an active event within 35 metres', () => {
  const nearby = {latitude: 19.0761, longitude: 72.8777, lastObservedAt: new Date(now - 1000)};
  const distant = {latitude: 19.08, longitude: 72.88, lastObservedAt: new Date(now - 1000)};
  assert.ok(distanceMeters(baseReport, nearby) < 35);
  assert.equal(findNearestActiveEvent([distant, nearby], baseReport, now), nearby);
  assert.equal(findNearestActiveEvent([distant], baseReport, now), null);
});

test('requires distinct-driver counts to progress through the lifecycle', () => {
  assert.equal(verificationStatus(1), 'candidate');
  assert.equal(verificationStatus(2), 'corroborated');
  assert.equal(verificationStatus(3), 'verified');
});
