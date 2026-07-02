# Contributing to attest

Thanks for helping make Flutter apps verifiably accessible. Contributions of
every size are welcome — the most valuable ones, in order:

1. **Real-world false positives.** If attest flagged something that is actually
   fine, that report is gold: every confirmed false positive becomes a
   permanent adversarial fixture in the validation corpus. Open a bug with a
   minimal repro widget.
2. **New rules.** The Rule contract makes a rule PR small and self-contained.
3. **Corpus fixtures** for existing rules — labelled positive, clean and
   adversarial cases.
4. **Documentation** fixes and clarity improvements.

## Setting up

The repo is a Dart pub workspace orchestrated with melos.

```sh
# Requires Flutter >= 3.32 (which ships Dart >= 3.8).
dart pub global activate melos
melos bootstrap
```

## Running the checks

Every PR must keep all of these green:

```sh
melos run analyze        # dart/flutter analyze, infos fatal
melos run format:check   # dart format, no diffs
melos run test           # all unit + widget tests, incl. the corpus gate
```

The corpus metrics gate runs as an ordinary test
(`packages/attest/test/corpus/metrics_test.dart`): it recomputes per-rule
precision and recall over the labelled corpus and fails on any regression, any
false positive on a clean case, or a heuristic dropping below its declared
precision bar.

## Definition of done

A change is done only when all of these hold:

- Tests cover it — for a rule change, a violating fixture **and** a clean
  fixture; for a correctness bug, a fixture that fails before the fix and
  passes after.
- `dart analyze` is clean and `dart format` is applied.
- Every new public member has dartdoc with at least one example.
- The public API did not break without a major bump, and the change has a
  CHANGELOG entry (Keep a Changelog style) in the same PR.

## Adding a rule

Read the rule-authoring contract first: `context/Stage2/11_RULE_AUTHORING.md`.
The short version:

- A rule is a pure, deterministic function over `SemanticsSnapshot`; it never
  touches live Flutter types.
- It **must** cite a `Criterion` (WCAG SC + EN 301 549 clause) — a finding with
  no citable clause is not allowed.
- It ships with violating, clean and adversarial fixtures, plus corpus cases
  (see `packages/attest/test/corpus/README.md`).
- If the check relies on inference, it is `heuristic`: tagged in output,
  suppressible in one line, and it declares a precision bar in
  `declaredHeuristicPrecision`.
- Rule IDs are permanent. Never rename a shipped ID.

Paste the authoring checklist from `11_RULE_AUTHORING.md` into the PR
description and tick it off.

## Higher-risk areas

The engine, the data model, the criteria registry and the release tooling are
load-bearing for every rule, so changes there get stricter review. Propose the
change in an issue first; keep rule PRs and engine PRs separate.

## Security issues

Do **not** open a public issue — see [SECURITY.md](SECURITY.md).
