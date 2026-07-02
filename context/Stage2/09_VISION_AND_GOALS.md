# 09 — Vision & Goals

This is the anchor document. Every other doc, every roadmap phase, and every design decision serves what is written here. Read it first.

## Mission — why we exist

Enable any Flutter team to build apps everyone can use, and to **prove it continuously** — in CI, on every change.

Today that is not possible. Flutter renders to its own canvas, so the entire web-accessibility toolchain (axe-core, Lighthouse, WAVE) is blind to it. What exists on pub.dev is dev-time linters and one-off scanners, not instruments a team can trust. There is a real, unfilled gap between "Flutter is one of the largest UI toolkits in the world" and "the accessibility of a Flutter app is verifiable." We close that gap.

## Vision — the world if we win

Gating a Flutter pull request on accessibility becomes as routine and unremarkable as gating on passing tests or code coverage. `attest` is the default tool teams reach for, and its clause-mapped output is treated as ground truth — by engineers fixing issues, by auditors assembling evidence, and by legal teams answering to the European Accessibility Act.

## Goal — what "we succeeded" concretely means

De-facto standard status for Flutter accessibility, on two legs that must both hold:

1. **Adoption.** The tool that appears in CI templates, tutorials, and starter kits; a verified publisher; broad, organic usage; the top answer to "how do I check accessibility in Flutter."
2. **Earned trust.** The part that makes adoption defensible: **published, validated correctness** — precision/recall against a real labelled corpus, and demonstrated agreement with what real VoiceOver/TalkBack actually announce. Trust is claimed by no one and earned by measurement.

Funded by a sustainable **open-core** model: the instrument is free OSS; the hosted dashboard, PR-annotation service, and formal conformance/statement artifacts are the paid layer.

## What "world standard" means — and the current gap

World standard is **not** more rules. We already have the features. The gap — the honest "we are far from it" — is the scaffolding around them:

1. **Proven correctness.** A validation corpus and tracked precision/recall per rule; cross-validation against real assistive tech. (`10_QUALITY_AND_CORRECTNESS.md`)
2. **Comprehensive, auditable, current standards coverage.** Rigorous WCAG / EN 301 549 mapping, versioned packs, kept up to date. (`12_STANDARDS_TRACEABILITY.md`)
3. **A rule set that scales past one maintainer.** A public Rule API and a contribution path so coverage grows without a single bottleneck. (`11_RULE_AUTHORING.md`)
4. **Professional operation.** Disciplined releases, versioning, support policy, and security handling. (`13_RELEASE_AND_SUPPORT.md`, `14_GOVERNANCE_AND_CONTRIBUTING.md`)
5. **Frictionless adoption.** Documentation and DX so good that wiring `attest` into a project is a five-minute job.

We have (1)–(5) mostly unbuilt. That is the work of this stage.

## Non-goals — what we deliberately are not

- **Not a certification authority.** We produce evidence; we do not issue legal compliance certificates.
- **Not a replacement for human audit or real assistive-technology testing.** We complement them and say so, always.
- **Not a runtime library.** We are a dev/test/CI tool; we never ship in the user's app binary.
- **Not a rule-count vanity project.** A validated, low-false-positive rule beats ten noisy ones.
- **Not a data collector.** Zero telemetry by default. It runs in people's CI; it must never phone home.

## Guiding principles (the tie-breakers)

When a decision is unclear, these settle it, in order:

1. **Trust over reach.** If a change could make the tool wrong, it does not ship, however popular the feature.
2. **Honesty over marketing.** We never overclaim coverage or compliance. The honesty framing is a competitive asset, not a limitation.
3. **Correctness over breadth.** Validate what exists before adding more.
4. **Ergonomics over configurability.** The default path must be excellent; power is opt-in.
5. **Openness over lock-in.** The OSS instrument must be fully useful on its own; the paid layer earns money by convenience, never by crippling the core.

## The one-sentence version

> Make accessibility a verifiable, continuously-enforced default in every Flutter codebase — and be trusted enough that our output is treated as the truth, because we measured it.
