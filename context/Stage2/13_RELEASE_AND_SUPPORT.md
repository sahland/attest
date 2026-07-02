# 13 — Release & Support

Professional release discipline is part of "world standard." A tool teams wire into CI must be predictable: no surprise breakage, a clear support window, and an honest changelog. This document defines how we version, release, support, and deprecate.

## Versioning across three packages

`attest`, `attest_flutter`, and `attest_cli` are versioned **independently** but coherently:

- Strict **semantic versioning** per package. Anything under a package's `lib/` (not `lib/src/`) is public API; a breaking change requires a major bump.
- Because `attest_flutter` and `attest_cli` depend on `attest`, a breaking change in the core cascades: bump the core major, then bump the dependents that must adapt. Coordinate these in one release train (melos can orchestrate).
- Dependents declare a caret range on the core (`attest: ^x.y.z`) so patch/minor core releases flow without a dependent release.

## The road to 1.0 and what it commits to

1.0 is a promise, not a milestone number. Before cutting 1.0 (per `09_VISION_AND_GOALS.md` and `10_QUALITY_AND_CORRECTNESS.md`):

- The public API is reviewed and frozen; anything not ready ships `@experimental` and is exempt from the stability promise.
- The correctness bar (`10`) is met: corpus, tracked precision/recall, zero FP on clean fixtures.
- Verified publisher is in place.

After 1.0, the public API does not break within a major. Experimental APIs may change in minors but must be clearly marked and changelogged.

## Release process (repeatable checklist)

```
[ ] All CI green: analyze clean, format clean, tests + goldens pass, coverage >= threshold
[ ] Correctness metrics computed; no precision/recall regressions
[ ] pana score checked on each changed package
[ ] CHANGELOG.md updated for each changed package (Keep a Changelog style)
[ ] Version bumped per semver; dependent constraints updated if core changed
[ ] dart doc generates clean on public members
[ ] Tag the release; publish in dependency order (attest -> attest_flutter/attest_cli)
[ ] Announce notable releases (blog/community) when user-visible
```

Never publish a package whose CI is red or whose changelog is stale. A compliance tool that ships sloppily undercuts its own message.

## Support policy

- **Flutter/Dart versions:** support the **latest N stable Flutter releases** (state N explicitly, e.g. the current and previous three). `attest_flutter` requires Flutter ≥ 3.32 today for the tri-state semantics API; the pure-Dart `attest` core carries a lower floor set to its true minimum. Document both, and re-check the floor each time it could be lowered or must rise.
- **`attest` versions:** support the current major with patches; security fixes may be backported to the previous major for a stated window.
- **Track new stable Flutter within one release cycle.** Semantics-API drift is the standing maintenance tax; budget for it rather than being caught out.

## Deprecation policy

- Announce a deprecation in the CHANGELOG and with `@Deprecated('...; use X')` in code, one minor before any removal is even scheduled.
- Removal happens only on a major bump, with a migration note.
- **Never rename a rule ID or silently change a standard pack's meaning** — both move users' baselines and ignores under them. Treat them as breaking changes with explicit migration.

## Changelog discipline

Every user-visible change lands with its CHANGELOG entry in the same PR, grouped as Added / Changed / Fixed / Deprecated / Removed / Security. For a tool that audits others, "we document our own changes rigorously" is not optional — it is congruent with the product.

## Security releases

Security issues (see `14_GOVERNANCE_AND_CONTRIBUTING.md`) get an expedited release outside the normal cadence, a clear advisory, and a `Security` changelog entry. Because `attest` runs in CI with access to source and build environments, treat any issue that could affect that environment as high priority.
