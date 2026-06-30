# 03 — Ruleset (the 12 starter rules)

Each rule is a pure function over `SemanticsSnapshot` (see `01_ARCHITECTURE.md`). Field names below refer to `SemanticsNodeData`. Every rule binds to a `Criterion`; a rule without a citable criterion is not allowed.

## Legend

- **Method** — TREE (snapshot walk), RASTER (needs `contrastSamples`), TEXTSCALE (needs `textScaleObservations`).
- **Confidence** — `deterministic` (math/structure) or `heuristic` (best-effort; ship with easy suppression and a visible `heuristic` tag in output).

## Index

| ID | Rule | WCAG | Lvl | EN 301 549 | Method | Severity | Confidence |
|----|------|------|-----|------------|--------|----------|------------|
| `a11y/interactive-name` | Interactive element has no accessible name | 4.1.2 | A | §11.5.2.5 | TREE | error | deterministic |
| `a11y/image-alt` | Image/icon has no text alternative | 1.1.1 | A | §11.5.2.5 | TREE | error | deterministic |
| `a11y/contrast` | Insufficient text contrast | 1.4.3 | AA | §11.5.2.4 | RASTER | error | deterministic* |
| `a11y/target-size` | Touch target too small | 2.5.8 | AA | §11.x | TREE | warning | deterministic |
| `a11y/text-overflow` | Layout overflows at enlarged text | 1.4.4 / 1.4.10 | AA | §11.x | TEXTSCALE | error | deterministic |
| `a11y/ambiguous-name` | Duplicate/ambiguous accessible names | 2.4.6 | AA | §11.x | TREE | warning | heuristic |
| `a11y/placeholder-name` | Placeholder instead of a real name | 2.4.6 / 4.1.2 | A/AA | §11.5.2.5 | TREE | warning | deterministic |
| `a11y/field-label` | Form field/control has no label | 1.3.1 / 3.3.2 | A | §11.x | TREE | error | deterministic |
| `a11y/heading-structure` | Heading semantics missing | 1.3.1 / 2.4.6 | A/AA | §11.x | TREE | warning | heuristic |
| `a11y/state-exposed` | Control state not announced | 4.1.2 | A | §11.5.2.5 | TREE | warning | heuristic |
| `a11y/focus-order` | Illogical focus order | 2.4.3 | A | §11.x | TREE | warning | heuristic |
| `a11y/focus-trap` | Unreachable interactive element | 2.1.1 / 2.4.3 | A | §11.x | TREE | error | deterministic |

\* `a11y/contrast` is deterministic in its math but false-positive-prone over gradients/images; use `warning` for borderline ratios.

---

### `a11y/interactive-name` — interactive element has no accessible name
**WCAG 4.1.2 (A) · EN 301 549 §11.5.2.5**

Screen readers announce such an element as a bare "button". The most frequent and most severe finding.

**Detect:** node has `actions` containing `tap`, or `flags` containing `isButton`/`isLink`; AND `label.trim()` is empty AND `tooltip.trim()` is empty AND no descendant text node supplies a name.

**False positives:** gesture-only wrappers (swipes), decorative tap zones → suppress via inline ignore.
**Fix:** `Semantics(label: 'Pay', button: true, child: ...)` or `IconButton(tooltip: ...)`.

---

### `a11y/image-alt` — image/icon has no text alternative
**WCAG 1.1.1 (A) · EN 301 549 §11.5.2.5**

**Detect:** `flags` contains `isImage` AND `label.trim()` is empty AND the node is not excluded from semantics. Also flag an `Icon`/`IconButton` that is the only meaningful child of an interactive node with an empty label.

**False positives:** purely decorative images that are *correctly* hidden are not violations — a properly `ExcludeSemantics`-wrapped image never reaches the snapshot. So we only flag a semantics-visible image with no label.
**Fix:** `Image(..., semanticLabel: '...')`, or `ExcludeSemantics` for true decoration.

---

### `a11y/contrast` — insufficient text contrast
**WCAG 1.4.3 (AA) · EN 301 549 §11.5.2.4**

Thresholds: normal text ≥ 4.5:1; large text (≥ 24px, or ≥ 18.66px bold) ≥ 3:1.

**Detect (RASTER):** for each text node, read the matching `ContrastSample` (foreground glyph luminance vs averaged background) and compute `(L_hi + 0.05) / (L_lo + 0.05)`.

```dart
double contrastRatio(double l1, double l2) {
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}
```

**False positives:** text over gradients/photos, translucent layers, and **disabled controls — WCAG 1.4.3 exempts them, so filter out nodes whose `flags` lack `isEnabled`.** Borderline (4.3–4.5) → downgrade to `warning`.
**Fix:** adjust theme colour; the report suggests the nearest passing shade.

---

### `a11y/target-size` — touch target too small
**WCAG 2.5.8 (AA, WCAG 2.2) · platform guidance: Material 48×48, iOS 44×44**

**Detect (TREE):** node has `tap` action; compute global size from `bounds`; flag if the smaller side is below the configured threshold (`TargetSizeMode.platform` = 48/44, `.wcagMinimum` = 24).

**False positives:** 2.5.8 exempts inline links, essential controls, and targets with adequate spacing → keep `warning`, and consider spacing to neighbours before flagging.
**Fix:** add `padding`/`SizedBox`, or `MaterialTapTargetSize.padded`.

---

### `a11y/text-overflow` — layout overflows at enlarged text
**WCAG 1.4.4 + 1.4.10 (AA)**

The Flutter-specific killer feature: large system fonts routinely break `Row`/`Column` (`RenderFlex overflowed`), and web tools cannot see it.

**Detect (TEXTSCALE):** read `textScaleObservations` for scales 1.3 and 2.0; a violation is a captured overflow error or text whose paint bounds exceed its container.
**Fix:** use `Flexible`/`FittedBox`, allow wrapping, drop fixed heights.

---

### `a11y/ambiguous-name` — duplicate/ambiguous accessible names
**WCAG 2.4.6 (AA) · heuristic**

**Detect (TREE):** multiple interactive nodes on one screen share an identical label, where the label is generic or identical across differing actions (two "Delete" buttons with no qualifier).
**Fix:** qualify the labels ("Delete profile photo" vs "Delete account").

---

### `a11y/placeholder-name` — placeholder instead of a real name
**WCAG 2.4.6 / 4.1.2 · EN 301 549 §11.5.2.5**

**Detect (TREE):** `label` matches a denylist of generic/placeholder tokens (`button`, `image`, `icon`, `label`, `text`, `todo`, `untitled`, lone emoji, …), case-insensitive, with localized variants.
**Fix:** provide a meaningful label.

---

### `a11y/field-label` — form field/control has no label
**WCAG 1.3.1 + 3.3.2 (A) · 4.1.2**

**Detect (TREE):** `flags` contains `isTextField`, OR has checked/toggled state (checkbox/switch/radio); AND `label.trim()` empty AND no associated labeling node nearby. Note: placeholder/`hintText` does **not** count as a label — flag that common mistake.
**Fix:** `InputDecoration(labelText: ...)` or wrap in `Semantics(label: ...)`; associate checkboxes with their captions.

---

### `a11y/heading-structure` — heading semantics missing
**WCAG 1.3.1 + 2.4.6 · heuristic**

**Detect (TREE):** a visually "heading-like" text node (large `textStyle.fontSize` + bold) exists, but no node carries the `isHeader` flag. Noisy → `warning`, tagged `heuristic`, easy to bulk-suppress.
**Fix:** `Semantics(header: true, child: Text(...))`.

---

### `a11y/state-exposed` — control state not announced
**WCAG 4.1.2 (A) · EN 301 549 §11.5.2.5 · heuristic**

**Detect (TREE):** a custom control (a `GestureDetector` with a `tap` action) visually conveys selected/active state but the node lacks checked/selected/toggled flags. Hard to generalize; start with custom tabs/chips/toggles.
**Fix:** propagate state via `Semantics(selected: true)` / `toggled`.

---

### `a11y/focus-order` — illogical focus order
**WCAG 2.4.3 (A) · heuristic**

**Detect (TREE):** compare `childrenInTraversalOrder` against visual reading order (sort by global `bounds`: top-to-bottom, then start-to-end per `textDirection`). Flag large inversions.
**Fix:** order with `FocusTraversalGroup` / `Semantics(sortKey: OrdinalSortKey(...))`.

---

### `a11y/focus-trap` — unreachable interactive element
**WCAG 2.1.1 + 2.4.3 (A)**

**Detect (TREE):** an interactive node (has `tap` action) that is either flagged `isHidden` while still tappable, or sits behind `ExcludeSemantics` and is thus absent from traversal order while visually present and clickable. Such an element exists for sighted users but is unreachable by screen reader/keyboard.
**Fix:** remove the erroneous `ExcludeSemantics`/`isHidden`; return the element to the semantics tree.

---

## What this set deliberately does NOT cover

State this in README and report output:

- **1.4.1** — information by colour alone (needs meaning analysis).
- **1.2.x** — media captions / audio description.
- **3.3.x** — usefulness of error messages.
- **Meaningfulness of alt text** — we see *that* a label exists, not whether it helps.
- **Real screen-reader testing** (TalkBack/VoiceOver) — irreplaceable; we complement it.

Framing: *we catch everything machine-checkable, and hand you a structured checklist for the rest.*
