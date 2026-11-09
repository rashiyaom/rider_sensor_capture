# Firebase implementation and validation plan

## Scope and principles

- Keep high-rate IMU and location capture on-device while the study's storage, consent, retention, and export requirements are confirmed. Do not silently upload raw trips.
- Preserve a stable Firebase Auth UID as the pseudonymous participant key. Keep profile fields separate from event data and collect only the approved fields.
- Keep crowd reports as participant-confirmed observations. Candidate/corroborated/verified are workflow states, not ground-truth labels.
- Require explicit consent for every new class of cloud data and make synchronization status visible.

## Work plan

1. **Account identity and participant profile (implemented locally)**
   - First sign-in: phone OTP, then collect name, email, age band, riding experience, and vehicle description; link email/password to the same Auth UID.
   - Returning sign-in: email/password, with password reset/change actions in account settings. Keep phone OTP available for recovery.
   - Store the profile at `userProfiles/{uid}` with owner-only client access. Firebase Console IAM admins can inspect the profile document and Auth record.
   - Validate the profile fields and test first registration, retry, duplicate email, password login, reset, and profile rules.

2. **Crowd-report correctness and feedback**
   - Pagination, retry affordances, app-resume sync, UID scoping, and displayed server outcomes are implemented locally.
   - Add Firestore Rules Emulator tests and transaction/idempotency tests for dense-area matching. Add App Check and server-side abuse/rate controls before open distribution.

3. **Research data synchronization design**
   - Decide which artifacts must survive device loss: trip metadata, reviewed events, raw sensor samples, feedback, alerts, and camera evidence.
   - Define schema/versioning, user ownership, consent text, retention/deletion, de-identification, and offline outbox before implementation.
   - Keep raw sensor exports reproducible and avoid changing event labels or timestamps during upload.

4. **Release and operational validation**
   - Verify Firebase project settings, deployed rules/indexes/functions, SMS regions/quotas, and admin access in the actual Firebase project.
   - Build and smoke-test on a supported Android host/device; test offline/online, auth persistence, permissions, upload recovery, and account deletion/retention.
   - Set billing alerts and monitor OTP, Firestore reads/writes, Function failures, and report processing latency.

## Current milestone status

- Milestone 1 implementation is in place: OTP onboarding, profile capture, email/password linking and sign-in, password reset, settings-based password change, and owner-only `userProfiles/{uid}` rules.
- Age is collected as a band (not date of birth); vehicle is a free-text make/model/type field with a prompt not to enter a registration plate. This assumes an adult-only cohort. Confirm that against the approved protocol before production.
- The profile form records a consent version and server timestamp. The displayed wording must be reviewed against the study's approved participant information and retention policy before production use.
- Removed the fixed crowd-event candidate query limit with paginated, active-event-only reads. Failed/pending reports now have an explicit retry control, retry on page open/app resume, and display the server's published/rejected/stale result when available. Sync is scoped to the signed-in UID.
- The full Flutter suite passes serially (296 tests), full-project analysis reports no issues, and Cloud Function unit tests pass (5 tests).
- Native ARM Java 21 was used for emulator validation on 8 November. It was removed at the user's request on 9 November; Flutter now uses the existing native Java 17 for APK builds. Firestore emulator tests need Java 21 if rerun.
- The Firestore emulator starts with Java 21. Six emulator-backed rules tests pass for profile ownership, consent and Auth-email matching, report validity and retry behavior, and server-only collections. Re-run them with `cd functions && npm run test:rules`.

Next: test OTP/password lifecycle and crowd report processing against the Auth/Functions emulators and a real Android device. Settle the approved data-sync/retention scope before uploading any trip or raw sensor records.

8 November validation update: the Firestore + Functions emulator integration suite passes the complete crowd-report lifecycle for distinct, repeat and concurrent reporters. Read-only inspection of the live `rydesense` project found zero deployed functions and no geohash/last-observed index. A deployment dry run compiled the rules but stopped because Cloud Build requires a Blaze billing upgrade. The production build and signing setup were removed at the user's request on 9 November; a debug APK is available for pilot testing.
