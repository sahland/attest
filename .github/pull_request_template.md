<!-- Thanks! Keep the PR small and self-contained; rule PRs and engine PRs
     are reviewed separately. -->

## What & why

<!-- One or two sentences. Link the issue if there is one. -->

## Definition of done

- [ ] Tests cover the change (for a rule: violating **and** clean fixtures)
- [ ] `melos run analyze` clean, `melos run format:check` clean
- [ ] All tests green, including the corpus metrics gate
- [ ] New public members have dartdoc with an example
- [ ] CHANGELOG entry in the same PR (Keep a Changelog style)
- [ ] No breaking API change without a major bump

## For a new rule (delete otherwise)

- [ ] Permanent id `attest/<kebab-case>`, criterion cited (WCAG + EN 301 549)
- [ ] Correct standard-pack membership (WCAG 2.2-only criteria gated)
- [ ] Cheapest detection method that works (TREE unless justified)
- [ ] Adversarial fixtures for known false-positive traps
- [ ] Corpus cases added and the metrics gate green
- [ ] Confidence honest; heuristics tagged, suppressible, with a declared
      precision bar
- [ ] Fix suggestion correct and actionable
