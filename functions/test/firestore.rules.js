const { after, before, test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');

let env;
let alice;
let bob;
let guest;

before(async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, 'Start the Firestore emulator first');
  env = await initializeTestEnvironment({
    projectId: 'demo-ridesense-rules',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });
  alice = env.authenticatedContext('alice', { email: 'alice@example.com' }).firestore();
  bob = env.authenticatedContext('bob', { email: 'bob@example.com' }).firestore();
  guest = env.unauthenticatedContext().firestore();
});

after(async () => {
  if (env) await env.cleanup();
});

function profile(uid = 'alice') {
  const now = new Date('2026-11-08T00:00:00.000Z');
  return {
    uid,
    name: 'Alice Rider',
    email: `${uid}@example.com`,
    ageBand: '25–34',
    ridingExperience: '1–3 years',
    vehicleDescription: 'Motorcycle',
    profileConsent: true,
    profileConsentVersion: 'profile-v1',
    profileConsentedAt: now,
    createdAt: now,
    updatedAt: now,
  };
}

function report(ownerUid = 'alice', reportKey = 'report-a') {
  return {
    reportKey,
    ownerUid,
    eventType: 'road_impact',
    latitude: 23.02,
    longitude: 72.57,
    horizontalAccuracyM: 5,
    observedAtUtc: new Date('2026-11-08T00:00:00.000Z'),
    source: 'manual',
    evidenceKind: 'rider_confirmation',
    driverConfirmed: true,
    locationShareConsented: true,
  };
}

test('profile can be created and read only by its owner', async () => {
  await assertFails(guest.doc('userProfiles/alice').set(profile()));
  await assertFails(bob.doc('userProfiles/alice').set(profile()));
  await assertSucceeds(alice.doc('userProfiles/alice').set(profile()));
  await assertSucceeds(alice.doc('userProfiles/alice').get());
  await assertFails(bob.doc('userProfiles/alice').get());
  await assertFails(alice.collection('userProfiles').get());
});

test('profile rejects missing consent, foreign UID and unexpected fields', async () => {
  const carol = env.authenticatedContext('carol', { email: 'carol@example.com' }).firestore();
  await assertFails(alice.doc('userProfiles/carol').set(profile('carol')));
  await assertFails(carol.doc('userProfiles/carol').set({ ...profile('carol'), profileConsent: false }));
  await assertFails(carol.doc('userProfiles/carol').set({ ...profile('carol'), phone: '+10000000000' }));
  await assertFails(carol.doc('userProfiles/carol').set({ ...profile('carol'), email: 'someone-else@example.com' }));
});

test('profile permits limited edits but preserves identity and consent', async () => {
  await assertSucceeds(alice.doc('userProfiles/alice').update({ name: 'Alice Updated' }));
  await assertFails(alice.doc('userProfiles/alice').update({ email: 'new@example.com' }));
  await assertFails(alice.doc('userProfiles/alice').update({ profileConsent: false }));
  await assertFails(alice.doc('userProfiles/alice').delete());
});

test('crowd report requires owner, confirmation, consent and usable coordinates', async () => {
  await assertFails(guest.doc('crowdReports/report-a').set(report()));
  await assertFails(bob.doc('crowdReports/report-a').set(report()));
  await assertFails(alice.doc('crowdReports/report-a').set({ ...report(), driverConfirmed: false }));
  await assertFails(alice.doc('crowdReports/report-a').set({ ...report(), locationShareConsented: false }));
  await assertFails(alice.doc('crowdReports/report-a').set({ ...report(), horizontalAccuracyM: 100 }));
  await assertFails(alice.doc('crowdReports/report-a').set({ ...report(), latitude: 123 }));
  await assertFails(alice.doc('crowdReports/report-a').set({ ...report(), reportKey: 'different' }));
  await assertSucceeds(alice.doc('crowdReports/report-a').set(report()));
  await assertSucceeds(alice.doc('crowdReports/report-a').get());
  await assertFails(bob.doc('crowdReports/report-a').get());
  await assertFails(alice.collection('crowdReports').get());
});

test('crowd report allows an identical retry but no edits or deletion', async () => {
  await assertSucceeds(alice.doc('crowdReports/report-a').set(report()));
  await assertFails(alice.doc('crowdReports/report-a').update({ latitude: 23.03 }));
  await assertFails(alice.doc('crowdReports/report-a').delete());
});

test('shared events and private results are server-writable only', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const admin = context.firestore();
    await admin.doc('sharedRoadEvents/event-a').set({ status: 'candidate' });
    await admin.doc('crowdReportResults/report-a').set({ ownerUid: 'alice', resultStatus: 'published' });
  });
  await assertSucceeds(alice.doc('sharedRoadEvents/event-a').get());
  await assertFails(guest.doc('sharedRoadEvents/event-a').get());
  await assertFails(alice.doc('sharedRoadEvents/event-a').set({ status: 'verified' }));
  await assertSucceeds(alice.doc('crowdReportResults/report-a').get());
  await assertFails(bob.doc('crowdReportResults/report-a').get());
  await assertFails(alice.collection('crowdReportResults').get());
  await assertFails(alice.doc('crowdReportResults/report-a').set({ ownerUid: 'alice' }));
});
