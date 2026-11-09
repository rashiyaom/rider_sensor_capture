'use strict';

const {after, before, test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {initializeTestEnvironment} = require('@firebase/rules-unit-testing');

let env;
let admin;

before(async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  env = await initializeTestEnvironment({
    projectId: 'rydesense',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });
  initializeApp({projectId: 'rydesense'});
  admin = getFirestore();
});

after(async () => {
  if (env) await env.cleanup();
});

async function waitForResult(id) {
  const deadline = Date.now() + 20000;
  while (Date.now() < deadline) {
    const snapshot = await admin.doc(`crowdReportResults/${id}`).get();
    if (snapshot.exists) return snapshot.data();
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  throw new Error(`No server result for ${id}`);
}

async function submit(uid, id, latitude = 23.02, longitude = 72.57) {
  const client = env.authenticatedContext(uid).firestore();
  await client.doc(`crowdReports/${id}`).set({
    reportKey: id,
    ownerUid: uid,
    eventType: 'road_impact',
    latitude,
    longitude,
    horizontalAccuracyM: 5,
    observedAtUtc: new Date(),
    source: 'manual',
    evidenceKind: 'rider_confirmation',
    driverConfirmed: true,
    locationShareConsented: true,
  });
  return waitForResult(id);
}

test('three drivers corroborate one event and a repeat driver does not raise its status', async () => {
  const first = await submit('driver-a', 'integration-a');
  assert.equal(first.resultStatus, 'published');
  assert.equal(first.verificationStatus, 'candidate');

  const second = await submit('driver-b', 'integration-b', 23.02005);
  assert.equal(second.sharedEventId, first.sharedEventId);
  assert.equal(second.verificationStatus, 'corroborated');

  const repeat = await submit('driver-a', 'integration-c', 23.02006);
  assert.equal(repeat.sharedEventId, first.sharedEventId);
  assert.equal(repeat.verificationStatus, 'corroborated');

  const third = await submit('driver-c', 'integration-d', 23.02007);
  assert.equal(third.sharedEventId, first.sharedEventId);
  assert.equal(third.verificationStatus, 'verified');

  const event = (await admin.doc(`sharedRoadEvents/${first.sharedEventId}`).get()).data();
  assert.equal(event.independentDriverCount, 3);
  assert.equal(event.reportCount, 4);
});

test('simultaneous first reports converge to one candidate', async () => {
  const [first, second] = await Promise.all([
    submit('parallel-a', 'integration-parallel-a', 24.0, 73.0),
    submit('parallel-b', 'integration-parallel-b', 24.00005, 73.0),
  ]);
  assert.equal(first.resultStatus, 'published');
  assert.equal(second.resultStatus, 'published');
  assert.equal(second.sharedEventId, first.sharedEventId);
  const event = (await admin.doc(`sharedRoadEvents/${first.sharedEventId}`).get()).data();
  assert.equal(event.independentDriverCount, 2);
});
