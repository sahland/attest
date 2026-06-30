# 04 — Conventions (Google/Flutter-grade)

These are the standards that make a package feel like the Flutter team wrote it. Treat them as hard requirements, not suggestions.

## Sources of truth

- **Effective Dart** — Style, Documentation, Usage, Design. This is the baseline for everything below.
- **`package:flutter_lints`** — the Flutter team's recommended lint set (it extends `package:lints/recommended.yaml`). Use it as the analysis base for all packages here. (A stricter community option is `very_good_analysis`; do not adopt it without a reason, since `flutter_lints` is the canonical "Google standard.")
- **pub.dev scoring (pana)** — the package gets scored on conventions, docs, platform support, and up-to-date dependencies. Aim for full marks; run `pana` before any publish.

> Verify current versions yourself before pinning. Do not copy version numbers from these docs.

## Analysis & formatting

- Every package has an `analysis_options.yaml` that includes `package:flutter_lints/flutter.yaml` and enables a few extra strictness rules (e.g. `public_member_api_docs`, `require_trailing_commas`).
- `dart analyze` must be **clean** — zero warnings, zero infos — across the workspace.
- `dart format .` is applied to everything. Trailing commas everywhere so the formatter lays out widgets/args vertically.
- Treat analyzer warnings as build failures in CI.

## Package layout

```
lib/
  a11y_audit.dart        # the barrel: curated public exports only
  src/                   # all implementation; never exported directly
    model/
    rules/
    engine/
    report/
test/
example/                 # runnable example (required for pub.dev score)
CHANGELOG.md
README.md
LICENSE                  # BSD-3-Clause or MIT (match the Flutter ecosystem; pick one and be consistent)
pubspec.yaml
analysis_options.yaml
```

- Nothing in `lib/src/` is exported except through the barrel. Consumers import only `package:a11y_audit/a11y_audit.dart`.
- Keep files focused; one primary public type per file, file name in `snake_case` matching the type.

## Public API & documentation

- **Every public member has a dartdoc comment.** No exceptions — `public_member_api_docs` enforces it. The first sentence is a concise summary; it shows up in API search.
- Include at least one **code example** in the dartdoc of every public entry point (the `auditAccessibility` extension, `AuditConfig`, the matchers).
- Use `{@template}` / `{@macro}` to avoid duplicating shared doc fragments.
- Mark anything unstable with `@experimental` (from `package:meta`) and say so in the doc.
- `@visibleForTesting` for members that exist only for tests; never widen visibility just to test.
- `dart doc` must generate with no warnings about missing documentation.

## Language & style

- Sound null safety throughout. Avoid `late` unless genuinely justified; prefer constructor-initialized `final`.
- Immutable value types: `final` fields, `const` constructors where possible, value equality (`==`/`hashCode`, or `package:equatable` / Dart records where they fit). The whole data model is immutable.
- Avoid `dynamic`; prefer precise types and generics.
- Prefer enums (or sealed classes) over boolean parameters when a third state is plausible.
- Errors: throw `ArgumentError`/`StateError` for programmer mistakes; never swallow exceptions silently. Collectors that can legitimately produce nothing (e.g. no contrast samples in a pure-Dart test) degrade gracefully rather than throw.
- No `print`; the library does not log to stdout. The CLI owns all user-facing output.

## Versioning & changelog

- Strict **semantic versioning**. Anything under `lib/` is public API; a breaking change requires a major bump.
- Start at `0.1.0` (the `0.x` series signals pre-1.0 but should still avoid gratuitous breaks).
- Keep a `CHANGELOG.md` updated in the same PR as the change, following the "Keep a Changelog" style.
- Keep the three packages' versions independent; melos can coordinate releases.

## pubspec hygiene

- A clear `description` (60–180 chars), `repository`, `issue_tracker`, `homepage`, and `topics` (e.g. `accessibility`, `a11y`, `testing`, `wcag`).
- Declare supported `platforms` accurately.
- Keep dependency constraints reasonable (caret ranges), and keep them current — stale deps cost pana points.

## README (the package's storefront)

- Lead with the one-call example from `02_API_DESIGN.md`.
- State the honesty framing prominently (no overclaiming).
- Show the failure output, the CI setup, and the baseline workflow.
- Badges: pub version, likes, pub points, coverage.

## CI

- Run `analyze`, `format --set-exit-if-changed`, `test --coverage`, and `pana` on every PR.
- Run the broken `example/` app's a11y tests as an integration check that real findings are produced.
