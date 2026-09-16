# Development roadmap

## Milestone 1 — Product foundation (implemented)

- New Uigarjin visual system: warm paper, deep teal, copper accents, restrained surfaces.
- Home dashboard, sequential learning collection, review collection, and settings.
- Refined lesson canvas and results, optional ink polishing, configurable guidance and haptics.
- Persisted completions, best tracing scores, lesson counts, and preferences.
- Storage error recovery, responsive layout tests, and a reproducible design preview exporter.

The content remains the original six preview forms. This milestone does not imply expert approval of that material or production readiness.

## Milestone 2 — Verified introductory course

Decide the primary learner audience and teaching language with the project owner. Work with a traditional Mongolian teacher to verify letter shapes, stroke order, connections, explanations, and pronunciation.

Introduce a content schema with stable course/unit/lesson IDs, sources, review status, form relationships, and content versions. Verify vertical text shaping and font licensing before adding connected words. Replace preview data with a coherent reviewed introductory unit.

Completion criteria: learners can finish one accurate introductory unit; every instructional asset has a source and review status; vertical examples render correctly on the supported devices.

## Milestone 3 — Deeper practice and retention

Add watch → trace → reduced guide → independent practice, recording each mode separately. Resume unfinished sessions and introduce scheduled review based on actual attempts and recency. Calibrate feedback with real learner samples; retain original ink for comparison.

Completion criteria: interrupted lessons recover; review scheduling is deterministic and tested; assisted scores are distinct from independent writing performance.

## Milestone 4 — Beta and release

Run learner/teacher usability sessions. Verify Android and iOS device layouts, persistence, stylus input, drawing latency, screen-reader navigation, and reduced motion. Add automated build checks, app icons, launch assets, and release signing. Resolve accessibility gaps that cannot be validated by layout tests alone.

Completion criteria: reviewed content, passing automated checks, successful device trials, no known progress-loss defects, and configured production signing. Account sync, subscriptions, leaderboards, and store publication remain separate scope decisions.
