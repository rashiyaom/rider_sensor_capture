# Older feature validation — first software round (8 November 2026)

## Executed checks

| Check | Result | What it establishes |
|---|---|---|
| `flutter analyze --no-pub` | No issues | The current Dart source passes static analysis. |
| `flutter test --no-pub --concurrency=1` | 296 passed | Existing unit, widget and local database regressions pass. Most use synthetic data or platform mocks. |
| `flutter test --no-pub docs/audit/reproductions_test.dart` | 6 passed | The original timestamp, buffer, feature-window and split failures remain repaired in synthetic cases. |
| `flutter test --no-pub docs/audit/generated_training_smoke_test.dart` | 1 passed | The generated Python trainer processes a string-labeled event window with the installed Python packages. |
| `flutter build apk --debug` | Passed | Android debug APK compiles with native ARM Java 21 on this host. It has not been installed or exercised on a phone. |

## Finding and repair in this round

The generated `train_baseline.py` used SciPy `stats.mode` for event-type strings. With installed SciPy 1.18.1, this raised `TypeError` on a labeled window and prevented model training. The generator now uses `collections.Counter`, and the smoke test executes the generated function on a labeled fixture. The final training message now asks for held-out rider/ride validation before using the model for decisions.

## Accuracy and method limits still open

1. The earlier generated Python trainer formed windows by **row count**; a two-device 50 Hz fixture showed its first 75-row window spanned only **0.74 s** despite a configured **1.5 s** width. The executable command now requires the Dart-exported, elapsed-time `features_windowed` CSV and its disjoint split metadata, and rejects raw CSVs. The legacy extraction function remains in the generated source for exploratory compatibility but is not the trainer's command-line path. A real multi-device parity corpus remains open.
2. The current test suite uses synthetic event fixtures; no independently labeled road-ride corpus was supplied. Detection sensitivity, specificity, false alerts per hour, label agreement and warning lead time cannot be estimated from these tests. The live detector uses heuristic scores that are not calibrated probabilities (AUD-13).
3. The trainer's chronological purged split prevents raw-sample overlap in its own windows, but a result from one ride is not evidence of generalization to unseen riders, vehicles, routes or sensor mounts. The evaluation protocol should hold out whole riders and rides and report per-event precision/recall and confusion matrices.
4. Android background capture, BLE/Polar sample-rate fidelity, audio routing and GPS warning timing still require instrumented physical-device sessions. `flutter devices --machine` lists only macOS and Chrome on this host, so no Android phone/emulator runtime test was possible. An APK build is a compilation check only (AUD-09, AUD-15–18).
5. The earlier audit's trip deletion, offline-tile display, hazard import and camera-ingest findings (AUD-20–22, AUD-25) have not been retested or repaired in this round. They must be included in the next functional pass before relying on history cleanup, offline maps or camera evidence.

The software tests support continued controlled development. They do not yet validate research accuracy or road-use reliability.

The Cloud Functions dependency audit currently reports eight **moderate** production advisories and no high or critical production advisories. Most fixes require moving `firebase-admin` from major version 13 to 14, while the installed `firebase-functions` package declares peer support only through admin 13. That upgrade needs a separate Functions compatibility and emulator pass.
