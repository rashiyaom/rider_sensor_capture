'use strict';

const crypto = require('node:crypto');
const {initializeApp} = require('firebase-admin/app');
const {FieldValue, Timestamp, getFirestore} = require('firebase-admin/firestore');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {logger} = require('firebase-functions');
const {geohashQueryBounds, geohashForLocation} = require('geofire-common');
const {
  ACTIVE_WINDOW_MS,
  MATCH_RADIUS_M,
  findNearestActiveEvent,
  validateReport,
  verificationStatus,
} = require('./domain');

initializeApp();

const db = getFirestore();
const ACTIVE_EVENT_PAGE_SIZE = 250;

async function readActiveEventsInGeohashRange(start, end, nowMs) {
  const events = [];
  let cursor = null;
  while (true) {
    let query = db.collection('sharedRoadEvents')
      .where('geohash', '>=', start)
      .where('geohash', '<=', end)
      .where('lastObservedAt', '>=', Timestamp.fromMillis(nowMs - ACTIVE_WINDOW_MS))
      .orderBy('geohash')
      .orderBy('lastObservedAt')
      .limit(ACTIVE_EVENT_PAGE_SIZE);
    if (cursor) query = query.startAfter(cursor);

    const snapshot = await query.get();
    events.push(...snapshot.docs);
    if (snapshot.size < ACTIVE_EVENT_PAGE_SIZE) return events;
    cursor = snapshot.docs[snapshot.docs.length - 1];
  }
}

exports.processCrowdReport = onDocumentCreated({
  document: 'crowdReports/{reportId}',
  region: 'asia-south1',
  retry: true,
  // Pilot serialization prevents simultaneous first reports from creating
  // separate candidates for the same nearby impact before a shard queue exists.
  maxInstances: 1,
  concurrency: 1,
}, async (event) => {
  const reportId = event.params.reportId;
  const report = event.data?.data();
  if (!report) return;

  const reportResultRef = db.collection('crowdReportResults').doc(reportId);
  const alreadyProcessed = await reportResultRef.get();
  if (alreadyProcessed.exists) return;

  const nowMs = Date.now();
  const validationError = validateReport(report, reportId, nowMs);
  if (validationError) {
    await reportResultRef.set({
      ownerUid: typeof report.ownerUid === 'string' ? report.ownerUid : '',
      resultStatus: validationError === 'stale_report' ? 'stale' : 'rejected',
      reasonCode: validationError,
      processedAt: FieldValue.serverTimestamp(),
    });
    logger.info('Crowd report not published', {reportId, reasonCode: validationError});
    return;
  }

  const observedAtMs = report.observedAtUtc.toMillis();
  const reportPoint = {latitude: report.latitude, longitude: report.longitude};
  const bounds = geohashQueryBounds(
    [report.latitude, report.longitude],
    MATCH_RADIUS_M,
  );
  const eventSnapshots = await Promise.all(bounds.map(([start, end]) =>
    readActiveEventsInGeohashRange(start, end, nowMs)));
  const candidateMap = new Map();
  for (const documents of eventSnapshots) {
    for (const eventDoc of documents) {
      candidateMap.set(eventDoc.id, {
        id: eventDoc.id,
        ref: eventDoc.ref,
        ...eventDoc.data(),
      });
    }
  }
  const nearest = findNearestActiveEvent(
    [...candidateMap.values()],
    reportPoint,
    nowMs,
  );
  const eventRef = nearest
    ? candidateMap.get(nearest.id).ref
    : db.collection('sharedRoadEvents').doc(`event_${reportId}`);

  const contributorId = crypto.createHash('sha256')
    .update(report.ownerUid)
    .digest('hex');
  const contributorRef = eventRef.collection('contributors').doc(contributorId);
  await db.runTransaction(async (transaction) => {
    const resultSnapshot = await transaction.get(reportResultRef);
    if (resultSnapshot.exists) return;

    const [eventSnapshot, contributorSnapshot] = await Promise.all([
      transaction.get(eventRef),
      transaction.get(contributorRef),
    ]);
    const existing = eventSnapshot.exists ? eventSnapshot.data() : null;
    const isNewDriver = !contributorSnapshot.exists;
    const independentDriverCount =
      (existing?.independentDriverCount || 0) + (isNewDriver ? 1 : 0);
    const lastObservedMs = Math.max(
      existing?.lastObservedAt?.toMillis?.() || 0,
      observedAtMs,
    );
    const newEvent = {
      eventType: 'road_impact',
      latitude: existing?.latitude ?? report.latitude,
      longitude: existing?.longitude ?? report.longitude,
      geohash: existing?.geohash ?? geohashForLocation([
        report.latitude,
        report.longitude,
      ]),
      status: verificationStatus(independentDriverCount),
      independentDriverCount,
      reportCount: (existing?.reportCount || 0) + 1,
      firstObservedAt: existing?.firstObservedAt ?? report.observedAtUtc,
      lastObservedAt: Timestamp.fromMillis(lastObservedMs),
      updatedAt: FieldValue.serverTimestamp(),
    };

    if (isNewDriver) {
      transaction.create(contributorRef, {
        ownerUid: report.ownerUid,
        firstReportId: reportId,
        observedAt: report.observedAtUtc,
      });
    }
    if (eventSnapshot.exists) transaction.update(eventRef, newEvent);
    else transaction.create(eventRef, newEvent);
    transaction.create(reportResultRef, {
      ownerUid: report.ownerUid,
      resultStatus: 'published',
      sharedEventId: eventRef.id,
      verificationStatus: newEvent.status,
      independentDriverCount,
      processedAt: FieldValue.serverTimestamp(),
    });
  });
});
