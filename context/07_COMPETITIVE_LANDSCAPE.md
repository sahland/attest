# 07 — Competitive landscape

Read this before writing the README or any marketing copy. The positioning here is load-bearing: it is *why* the product exists and *how* it must describe itself. Do not soften it into "another accessibility checker."

> Traction numbers below are point-in-time (early 2026). Re-verify on pub.dev before quoting them anywhere public.

## The one-line reframe

The Flutter accessibility space is a **crowded keyword, not a crowded category.** Searching "accessibility" on pub.dev returns ~a dozen packages, but most share only the word. When sorted by what they actually *do*, the field that overlaps our position is tiny — and the specific position (compliance instrument: standard-clause mapping + CI baseline gate + auditable conformance artifact) is unoccupied.

## Player map

### Not competitors (different product category; shared keyword only)
- **`accessibility`, `accessibility_features`** — end-user accessibility *settings* widgets (font scaling, colour profiles the user toggles). They modify the app *for* users; they do not audit it. Opposite direction.
- **`flutter_accessibility_service`** — a wrapper over Android's AccessibilityService API (for apps that observe other apps / draw overlays). Unrelated.
- **`flutter_accessibility_checker`** — detects whether OS accessibility features are enabled (for security / UI adaptation). Unrelated.

These exist only to clear up confusion: they are not benchmarks and not threats.

### Adjacent (same goal, different mechanism and different moment in the workflow)
- **`accessibility_tools`** — the most popular and best-maintained. A **debug-mode visual overlay**: highlights issues (tap-area, missing labels, image labels, experimental font-overflow) while a developer clicks around in debug. No tests, no report, no CI gate, no standard mapping. It is a build-time aid and is genuinely *complementary* to us — a team can use both.
- **`accessibility_lint`, `flutter_a11y_lints`** — **static analyzers** (built on `custom_lint` / `analyzer`), operating on source code. `flutter_a11y_lints` is "semantic IR-based," CI-capable via exit codes, but very early (≈1 like / ~130 pub points / tiny downloads, unverified uploader, first release Dec 2025) and uses internal rule IDs (A01…A18), not standard clauses.

### Direct functional overlap (the one to actually study)
- **`flutter_accessibility_scanner`** — runs inside a widget test, walks the tree, computes contrast, emits a JSON report. This is the closest existing thing to us. Gaps: solo author; maps to generic WCAG, **not EN 301 549 clauses**; **no CI baseline gate**; **no conformance artifact / accessibility statement**; **no regression tracking**; last updated mid-2025; modest traction.

### Long-term threats (watch these, not the small packages)
- **The Flutter team** expanding the built-in Guideline API (`meetsGuideline`), today only three checks.
- **An established a11y vendor** (Deque/axe, Level Access, etc.) shipping a Flutter SDK. Their web tooling does not work on Flutter's canvas today; that gap is our window.

## The capability moat (this is real, not a slogan)

Static analyzers and the linters never render anything — they read source/AST/IR. That makes three of the highest-legal-weight checks **physically impossible** for them, and they are exactly where we live:

| Check | Needs | Static analyzer | Debug overlay | Us (runtime test) |
|---|---|---|---|---|
| Real text contrast (1.4.3) | rendered pixels | ✗ can't | partial (live only) | ✓ raster collector |
| Reflow / overflow at 200% text (1.4.4 / 1.4.10) | pumping at scale | ✗ can't | experimental | ✓ text-scale collector |
| True screen-reader transcript (traversal order) | live semantics tree | ✗ can't | ✗ | ✓ snapshot traversal |

We run inside the test harness on the *real* semantics tree, so we can do what source-level tools cannot.

## Explicit differentiation (axis by axis)

| Axis | `accessibility_tools` | `flutter_a11y_lints` | `flutter_accessibility_scanner` | **attest** |
|---|---|---|---|---|
| Where it runs | debug overlay | static analysis | widget test | widget test + CI |
| Mechanism | live tree (debug) | source IR | live tree | serializable snapshot (TREE+RASTER+TEXTSCALE) |
| Standard-clause mapping | none | internal IDs | generic WCAG | **WCAG SC + EN 301 549 clause** |
| CI baseline gate (fail on regression) | no | exit codes only | no | **yes (fingerprint diff)** |
| Conformance artifact / a11y statement | no | no | no | **yes (paid layer, JSON/SARIF/HTML core)** |
| Screen-reader transcript | no | no | no | **yes** |
| Contrast / overflow (rendered) | partial | no | contrast only | **both** |
| Positioning | dev aid | linter | scanner | **compliance instrument** |

The buyer we care about (an engineering manager with an EU legal obligation) cares about the bottom three rows. Nobody else offers them together.

## Honest risks (do not paper over these)

1. **We are not first to "audit in a widget test."** `flutter_accessibility_scanner` already does. Our novelty is the *compliance instrument* framing, not the test integration. If that author adds clause mapping + a CI gate, the gap narrows — so depth and speed matter.
2. **The standard moves.** EN 301 549 v4.1.1 / WCAG 2.2 lands in 2026; versioned rule packs (see `06_ROADMAP.md` M8) are the hedge.
3. **A big incumbent could enter.** Mitigation: go deep on the Flutter-native + EU-compliance combination they are slow to build, and make the CI/baseline ergonomics excellent.

The healthy read: weak adjacent competition + a rising legal driver is the *good* middle. Zero competitors would suggest no demand; a funded incumbent would be a stop sign. We have neither.

## What this means for the build (positioning baked into the product)

- The README leads with the **compliance-instrument** framing and the one-call example — never "yet another accessibility checker."
- **Every finding must cite a standard clause.** This is the single most visible differentiator vs every other tool; it is also a hard guardrail in `CLAUDE.md`.
- The **CI baseline gate is the wedge**, not the rule count. Treat it as a first-class feature with first-class docs, not an afterthought.
- Keep the **honesty framing** ("automated coverage + a structured checklist for the rest") — it is also a competitive asset: tools that overclaim "compliance" create legal risk for their users, and a credible, non-overclaiming tool wins the buyers who actually read the fine print.

## Recommended hands-on due diligence (do this once, early)

Install `flutter_accessibility_scanner` and `flutter_a11y_lints`, run them against the broken `example/` app, and record exactly where each falls short (contrast accuracy, overflow detection, clause mapping, gating). Fold the findings into the README's comparison section. This both validates the differentiation and produces honest, specific marketing copy instead of hand-waving.
