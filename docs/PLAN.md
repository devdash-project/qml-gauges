# qml-gauges development plan

This document tracks the active development plan for the qml-gauges library.
For the durable architectural reference, see CLAUDE.md. For audit outputs and
historical investigations, see docs/audits/.

Last updated: 2026-05-11 (theme Phases 3–4 landed: legacy IndustrialGauge / RadialGauge3D templates retired in favour of GaugeTheme presets; ClassicWhite preset added; RadialGauge gains scriptLabel / brandLabel)

## Project framing

qml-gauges is a QML component library for building analog automotive
instrument clusters. It targets Qt 6.10+ on Linux (development on EndeavourOS,
deployment on NVIDIA Jetson Orin NX). It serves two audiences:

1. The devdash project's specific needs — including Moon Patrol's custom
   instrument cluster, which favors an industrial/utilitarian aesthetic.
2. External users who may want different aesthetics — modern OEM clusters,
   chrome-trimmed hot rod gauges, racing-style black-faced gauges, etc.

The library must support both without privileging either. Wide property surface
serves external users; preset composites serve discoverability.

## Design philosophy

- **Layered architecture.** Primitives → Compounds → Templates → Presets.
  Each tier composes the one below. Wide configurability at the bottom,
  opinionated coherence at the top.
- **Presets, not pruning.** The property surface is intentionally wide.
  Discoverability comes from preset composites that set coherent defaults,
  not from removing properties that some user might want.
- **Rendering capability is sufficient.** Audits confirmed the Shape/CurveRenderer,
  MultiEffect, ConicalGradient/RadialGradient toolkit is adequate for OEM-quality
  output. The historical gap between current renders and the target aesthetic
  is vocabulary (what to render, what defaults to use), not rendering technology
  (how the pixels are drawn).
- **Hardware target informs technique.** Jetson Orin NX has plenty of GPU
  headroom for 2D rendering, but MultiEffect chains and Quick3D scenes have
  real cost. Per-preset perf budgets matter when multiple gauges render
  simultaneously.
- **Real instrument ≠ modern OLED cluster.** These are different aesthetics
  with different vocabulary. Library serves both via separate presets; neither
  is the "default."

## Theme architecture

(Landed 2026-05-11, Phases 1–4. Phase 5 below.)

A **theme** is the orthogonal styling layer that sits beside the preset
composites. It is the `GaugeTheme` singleton in the `DevDash.Gauges.Theme`
submodule (structured like Primitives / Compounds / Templates: its own
qmldir + CMake registration).

- **Tokens, not gauge-specific properties.** The theme defines concept-level
  tokens — `background`, `surface`, `surfaceElevated`, `primary`,
  `foreground`, `warning`, `critical`, `overlay` (colours), plus
  `typographyFontFamily` / `typographyNumeralFontFamily` / `typographyScale`,
  `effectsGlow` / `effectsShadow` / `effectsTexture`, `tickStyle`,
  `bezelStyle` (mode-independent). Each gauge family maps the tokens onto its
  own elements (radial: `surface` → face; future bar: `surface` → background).
  The theme never names a specific gauge type. Full token reference: CLAUDE.md
  "Theme system", and the doc comment in `src/theme/GaugeTheme.qml`.
- **Two orthogonal axes: preset and mode.** `activeTheme` (default
  `industrial`) selects the aesthetic family; `mode` (`"light"` / `"dark"`)
  selects the day / night colour set. They vary independently. The intended
  driver on Moon Patrol is the C++ host calling `GaugeTheme.setMode(...)` off
  ambient-light readings; QML reacts via the `colors` binding.
- **Per-instance overrides preserved.** Gauge templates default each styling
  property to a theme token (`property color faceColor:
  GaugeTheme.colors.surface`); an explicit assignment on an instance still
  wins. The theme supplies defaults, not mandates.
- **Public surface is just `GaugeTheme`.** The presets (`industrial`,
  `modernOEM`, `classicWhite`) are nested `QtObject`s defined inside
  `GaugeTheme.qml` — not separate importable types. Adding a preset = adding
  another nested `QtObject` + a `setTheme()` case.

Phase status: Phases 1–4 complete.
- Phase 1 (theme infrastructure) + Phase 2 (RadialGauge consumes the theme).
- Phase 3 — retired the legacy preset-composite templates. Because RadialGauge
  already read the theme tokens, this was done as "migrate the explorer
  consumers to `RadialGauge` + `GaugeTheme.setTheme(...)`, then delete
  `IndustrialGauge.qml` / `RadialGauge3D.qml`" rather than the originally-
  envisioned "make those templates *be* the presets". Side-effect: the
  effects `RadialGauge3D` hard-wired (chrome3d bezel, glass overlay, domed
  centre cap, tick/needle glow) are not yet driven by the theme — see Backlog.
- Phase 4 — added the `classicWhite` preset (vintage white-face aesthetic) and
  the `scriptLabel` / `brandLabel` decorative face-text slots on RadialGauge.

Remaining: Phase 5 — explorer preset/mode selection UX.

## Aesthetic targets (presets)

A preset is a nested token set inside `GaugeTheme.qml` (a `light`/`dark`
colour pair plus mode-independent typography/effect/shape tokens). Any
template reads the active preset's tokens for its defaults; per-instance
properties still override. (Earlier in the project, presets were planned as
template *composites*; the theme layer replaced that — see the decisions log.)
Reference images for each live in docs/references/.

### Industrial (Moon Patrol's home — the default preset)

- Military / utilitarian aesthetic. Drawn from WWII aircraft instruments,
  industrial process gauges, mil-spec automotive gauges.
- Matte black or olive-painted bezel, ideally with visible fasteners (screws
  or rivets at compass points).
- Painted dial face with subtle texture (paint grain, slight warmth).
- Cream/aged-white tick marks and numerals; stencil or industrial typeface.
- Simple painted needle with drop shadow; no glow, no neon, no inner illumination.
- No colored value arc — the needle alone indicates value (with optional
  static redline zone arc).

Reference images: gauge-needle.png (hero design target, copied to
docs/references/), Auto Meter Antique Beige, Speedhut JDM Datsun Z
(black variant), Auto Meter Pro Comp.

**Status:** completed 2026-05-10 as the `IndustrialGauge` template; retired
2026-05-11 (Phase 3). The aesthetic now lives in the `industrial` `GaugeTheme`
preset (`src/theme/GaugeTheme.qml`) — the default preset — and a bare
`RadialGauge` picks it up. The old template's per-feature toggles (chevron
ticks, no value arc, etc.) are reproduced on the explorer demo page's
`RadialGauge` instance for now; folding the chevron/no-arc style choices into
theme tokens RadialGauge reads is the Phase-3 follow-up (see Backlog). The
original composite's implementation choices, kept for the token rationale:
- Face color `#0a0905` (very dark warm black); bezel color `#1a1815`
  (warm matte black, flat style); tick/numeral/label color `#e8e4d8`
  (warm cream); needle color `#d4cfc0` (painted aluminum tone);
  redline color `#7a1f15` at 0.4 opacity.
- GaugeTickRing with `tickShape: "chevron"`. The chevron passthrough
  was added to GaugeTickRing as part of this work (it was already on
  the underlying GaugeTick primitive).
- Needle: tapered shape, `frontGradient: true` + `gradientStyle:
  "cylinder"` + `hasShadow: true`; all other effects off.
- Center cap: filled disc at bezel color, no border, no gradient.
- Label rendered inside the dial face (verticalCenterOffset 22% of
  gauge size) rather than at the bottom margin.
- Font is **deferred**: `fontFamily: "DIN, DIN 1451, sans-serif"`
  fallback chain only. A FontLoader-installed industrial typeface
  will pick up automatically. See Open Questions.
- Paint-grain texture is **deferred**: `faceTextureSource` exposed
  for downstream use, default empty (flat paint). See Backlog.
- Bezel fasteners **integrated** 2026-05-10 via the new `BezelScrews`
  primitive. Default count 4, slot-style heads, slightly lighter than
  the bezel so the heads read as raised painted metal. Exposed as
  `bezelScrewCount`, `bezelScrewAngleOffset`, `bezelScrewHeadStyle`.
  Set count to 0 to disable.

Verification (against the same gauge config rendered by RadialGauge):
- coverage_ratio: 0.72 (well above the 0.3 threshold for "real gauge
  fills meaningful screen area").
- Top three colors of the cropped gauge render are all warm-black
  with neutral cream highlights; zero saturated blue/orange pixels
  (RadialGauge for the same config has #10b0f0 blue as its 2nd-most
  dominant color).
- SSIM vs. RadialGauge: 0.765 — meaningfully below 1.0; the preset
  is visibly distinct from the modern template baseline.

### ChromeClassicGauge

- Hot-rod aftermarket aesthetic. Polished chrome bezel with visible screws,
  cream or red face, painted needle with chrome center boss.
- Most ambitious from a rendering standpoint — chrome quality is the
  differentiator. May benefit from Bezel3D's PBR rendering if buildability and
  perf prove acceptable.

Reference images: Auto Meter dual-gauge with chrome bezel + 4 screws,
Classic Instruments speedo.

### PerformanceBlackGauge

- Racing aftermarket aesthetic. Matte black bezel, black face, white/yellow
  ticks, red needle with substantial painted body and visible center hub.
- Aesthetic of cars where every gauge is doing real work and looks the part.

Reference images: Auto Meter Pro Comp Lite, Speedhut Classic Black Tach.

### ModernOEM (modern OEM digital cluster)

- The OEM digital cluster aesthetic. Glow effects, gradient backgrounds,
  digital readouts, value arcs filling behind/instead of the needle.
- **Status:** the `modernOEM` `GaugeTheme` preset (added Phase 2; the only
  consumer, the `RadialGauge3D` template, was retired Phase 3). Colour tokens
  (near-black gradient face, bright-orange accent, chrome-grey bezel,
  light-grey marks) are live. The effects `RadialGauge3D` hard-wired —
  `chrome3d` bezel, glass overlay, domed centre cap, tick/needle glow — are
  *not* yet wired into RadialGauge from the `bezelStyle` / `effectsGlow`
  tokens; that's the Phase-3 follow-up in the Backlog. Until then the explorer
  demo page renders the colour-token version.

Reference images: Hyundai Palisade cluster (`docs/references/hyundai-palisade.jpg`).

### ClassicWhite (vintage white-face)

- Vintage white-face aesthetic, inspired by classic aftermarket gauges (the
  Classic Instruments "Velocity White" speedo in `docs/references/` is the
  visual touchstone). No specific product's dial art or wordmarks are
  reproduced — the aesthetic is captured via theme tokens only.
- Cool pearl-white dial (`#f4f3f0`), thick matte-black bezel, bold geometric
  orange-red numerals & ticks, orange-red painted needle with form shading,
  small orange centre hub. Needle-only (no value arc). Dark mode dims
  everything, shifts the accent warmer (amber) for night vision, and drops
  the white face to a warm dark grey.
- The product's distinctive script wordmark behind the needle and its
  manufacturer branding at the bottom are deliberately *not* reproduced;
  RadialGauge's `scriptLabel` / `brandLabel` slots (added Phase 4, empty by
  default) are where a user puts their own.
- **Status:** completed 2026-05-11 (Phase 4). The `classicWhite` `GaugeTheme`
  preset + `src/templates/RadialGauge.qml` `scriptLabel` / `brandLabel` +
  `explorer/qml/pages/ClassicWhitePage.qml`.

Reference image: `docs/references/Screenshot_20251129-203149.png` (Classic
Instruments Velocity White).

## Known capabilities and gaps

As of 2026-05-10. Based on audit outputs in docs/audits/.

### Inventory

- 11 primitives, 10 compounds, 1 template (RadialGauge). BezelScrews joined
  the primitives roster 2026-05-10. The `RadialGauge3D` and `IndustrialGauge`
  templates were retired 2026-05-11 (Phase 3) once their aesthetics moved into
  GaugeTheme presets.
- 1 theme singleton: `GaugeTheme` (in `DevDash.Gauges.Theme`), landed
  2026-05-11. Carries 3 presets (`industrial`, `modernOEM`, `classicWhite`) as
  inline nested objects.
- Module URIs: `DevDash.Gauges`, `DevDash.Gauges.Theme`,
  `DevDash.Gauges.Primitives`, `DevDash.Gauges.Compounds`.
- The four Needle* sub-primitives now live in Compounds (alongside GaugeNeedle)
  rather than Primitives — they have no plausible standalone use outside
  GaugeNeedle today.
- Quick3D primitives (Bezel3D, CenterCap3D) are conditionally built; buildability
  and PBR responsiveness verified 2026-05-10 (see Verified capabilities below).

### Verified capabilities

Verified working on 2026-05-10. See docs/audits/capability-verification.md
for screenshots, methodology, and pixel-diff numbers.

- **`GaugeTick.tickShape`** — all five enum values ("rectangle", "block",
  "triangle", "rounded-dot", "chevron") render and produce distinct pixel
  output. Distinctness varies: chevron is strongly differentiated (V-shape,
  ~10× the pixel diff of other variants); triangle and rounded-dot are
  mid-tier (tapered profiles); rectangle and block differ only in corner
  rounding.
- **`GaugeFace.textureSource`** — loads via `file://` URL and renders. Caveats:
  not exposed in the GaugeFace property panel UI; rendered region is
  rectangular, not circle-clipped to the face.
- **Bezel3D / CenterCap3D** — conditionally-built Quick3D primitives are
  present and responsive to PBR material property changes (roughness 0.08 vs
  1.0 produces categorically different appearance). Buildability confirmed
  in current environment.

### Remaining dead-knob inventory

Approximately 40% of declared properties on primitives remain unused by any
consumer. See docs/audits/property-usage.md for the full list. Pruning is
deferred until after the first two presets are built, when we have empirical
data on which properties get reached for; see decisions log (2026-05-10).

## Tooling status

### MCP server (devdash-mcp)

- Source: /home/yeep/Projects/personal/active/devdash-project/devdash-mcp/
- Build: `cd devdash-mcp && .venv/bin/python -m pip install -e .`
- Run: `.venv/bin/devdash-mcp`
- Registered: yes (Claude Code local scope, project-bound to qml-gauges).
- Status: ✓ Connected.

See devdash-mcp/MCP_USAGE.md for full setup notes.

### MCP capability tiers

| Tier | Capability | Status |
|------|-----------|--------|
| 1 | Render primitive with property overrides | Partial — assembled via navigate + set_property + screenshot; no single wrapper |
| 2 | Property matrix sweep | Absent (constructable from tier 1) |
| 3 | Pixel-level introspection | **Complete** — bounding_box, color_histogram, perceptual_hash, image_compare, image_structural_diff |
| 4 | Image diffing (SSIM, perceptual) | **Good coverage** — image_compare for global similarity (SSIM + mean diff); image_structural_diff for small-feature change detection (count, bbox, centroid of diffs) |
| 5 | Semantic geometry queries | Absent (deferred) |
| 6 | Animation capture | Absent (deferred) |
| 7 | Performance instrumentation | Absent (relevant when Jetson perf budget questions become concrete) |

Total tools exposed: 25 (was 17 at last documentation).

### Additional MCP capabilities

These don't fit the tier framework cleanly but matter for verification work:

- **`qml_explorer_freeze_property` / `freeze_all_properties`** — break animation
  bindings during verification so a value can be inspected without the
  binding immediately overwriting it. Used as the workaround for the
  MCP-cannot-evaluate-bindings limitation.
- **`qml_explorer_logs_get`** — captures explorer stdout/stderr when the
  explorer was launched by the MCP session.
- **Token-efficient screenshot returns.** Screenshot tools default to
  path-only returns; pixel data is opt-in via `inline_thumbnail`. ROI
  cropping is supported on capture.
- **Wayland (Hyprland) screenshot capture** is now routed automatically
  alongside X11. Previously Wayland-native windows weren't enumerable and
  required `grim` workarounds (see docs/audits/capability-verification.md).

See devdash-mcp/docs/TOOL_GUIDANCE.md for the "which tool when" reference.

## Active work

No active work item. Theme system Phases 1–4 shipped 2026-05-11
(`DevDash.Gauges.Theme` singleton with `industrial`, `modernOEM` and
`classicWhite` presets; RadialGauge consumes the colour/font tokens and now
exposes `scriptLabel` / `brandLabel`; the `IndustrialGauge` and `RadialGauge3D`
templates are gone). Next on the theme track: Phase 5 — explorer preset/mode
selection UX (a real UI, not just the MCP test hook on RadialGaugePage). Two
follow-ups surfaced by Phase 3 are in the Backlog: wiring the remaining theme
tokens (`tickStyle`, `bezelStyle`, `effectsGlow`/`effectsShadow`/`effectsTexture`,
`typographyScale`) into RadialGauge so presets differ in *structure*, not just
colour; and a `GaugeFaceLabel` compound. Independent of all that, the next
aesthetic target preset is still PerformanceBlack or ChromeClassic.

## Backlog

Work units that are well-scoped but not active.

- **Wire the remaining theme tokens into RadialGauge (Phase-3 follow-up).**
  RadialGauge currently reads only the colour tokens and the typography
  *family* tokens. The structural/effect tokens — `tickStyle` (so `industrial`
  gets its chevron ticks back), `bezelStyle` (so `modernOEM` gets a `chrome3d`
  bezel and `classicWhite` a thick flat one), `effectsGlow` / `effectsShadow`
  / `effectsTexture` (modern-OEM glow, painted-needle shadow), `typographyScale`
  — aren't consumed. Until they are, `industrial` and `modernOEM` differ only
  in colour through a plain RadialGauge (SSIM ≈ 0.97 between the two demo
  renders), and the explorer demo pages reproduce the missing structure via
  per-instance properties. Also re-home the `RadialGauge3D` glass overlay /
  domed centre cap, which have no token at all yet (new tokens, or accept they
  stay instance-only options).
- **Effect consistency cleanup.** Three specific fixes: Canvas→RadialGradient
  vignette migration in GlassOverlay, layer.smooth normalization across
  MultiEffect users, GaugeTick MultiEffect split (separate glow from shadow).
  Approved, low risk. Independent of file reorganization; ship standalone.
- **Explorer protocol enhancement — `resolveProperty` action.** The MCP cannot
  evaluate QML bindings directly; only the QML runtime can. Currently
  `get_property` on a pure-binding value returns "not found" with an
  instructive error message. A protocol enhancement on the explorer side
  could return the resolved value. Low priority; the `freeze_property`
  workaround is adequate.
- **Hyprland workspace-aware error messaging in MCP.** When the explorer
  process exists but its window isn't enumerable (moved to a hidden
  workspace, or window destroyed without process exit), the MCP should
  detect this and return a diagnostic error rather than generic "window
  not found." Minor developer-experience improvement.
- **Paint-grain texture asset for IndustrialGauge.** `faceTextureSource`
  is plumbed through, but no asset exists. Need a tileable warm-black
  paint-grain image at ~512×512 or larger; aim for very subtle grain so
  it doesn't dominate the dial. Watch for the rectangular-clip caveat
  (textureSource doesn't circle-clip to the face).
- **Industrial typeface loaded via FontLoader.** IndustrialGauge currently
  uses a generic `"DIN, DIN 1451, sans-serif"` fallback chain. Pick one
  from the candidates in Open Questions, license-check, and wire a
  FontLoader in either the template or a Theme singleton.
- **Label-inside-face rendering helper.** RadialGauge now has three ad-hoc
  on-face `Text` items (`scriptLabel`, `brandLabel`, and the industrial-style
  label-inside-the-dial idea). A small `GaugeFaceLabel` compound (positioned
  along a configurable radial offset, with the same colour/font wiring as the
  tick ring) would deduplicate this and give every preset a consistent
  face-text mechanism.
- **ChromeClassicGauge preset.** Blocked on Bezel3D viability assessment.
  BezelScrews primitive landed 2026-05-10 and is reusable here.
- **PerformanceBlackGauge preset.** Depends on verified-working needle
  configurations. Lower priority than IndustrialGauge.
- **Tier 2 MCP wrapper** (`render_matrix`). Useful once tier 1 wrapper exists.
- **Tier 7 MCP perf instrumentation.** Defer until Jetson budget questions
  become concrete (e.g., when running multiple gauges simultaneously in the
  deployed dashboard).
- **Reference image baseline for visual regression.** Baseline each preset's
  demo-page render (via tier 3 perceptual hash) so any future change that
  affects rendered output is caught.
- **Deeper effect-unification refactor** (bevel technique consistency across
  primitives, gradient declaration patterns). Deferred — not blocking,
  significant scope, limited visual payoff.

## Decisions log

- **2026-05-11: ClassicWhite preset implemented from a reference image.**
  The aesthetic of a classic aftermarket white-face gauge (the Classic
  Instruments "Velocity White" speedo in docs/references/) is captured via
  GaugeTheme tokens only — pearl-white surface, matte-black bezel, orange-red
  primary/foreground, flat bezel style, shadow-only effects. No part of the
  specific product's dial art or wordmarks is reproduced. The product's script
  wordmark behind the needle and its bottom branding line are deliberately
  left out; RadialGauge's new `scriptLabel` / `brandLabel` properties (empty by
  default) let a user place their own text in those spots without forking the
  template.

- **2026-05-11: Phase 3 done as "retire the legacy templates", not "templates
  become presets".** The original Phase-3 plan was to make `IndustrialGauge` /
  `RadialGauge3D` *be* the `industrial` / `modernOEM` presets. But once Phase 2
  had RadialGauge consuming the theme, those templates were pure
  property-default sets with no remaining reason to exist — so Phase 3 just
  migrated the explorer consumers to `RadialGauge` + `GaugeTheme.setTheme(...)`
  and deleted the files. Trade-off: RadialGauge consumes only the colour/font
  tokens, so the structural/effect distinctions the old templates hard-wired
  (chevron ticks, chrome3d bezel, glass overlay, glow) are lost until the
  remaining tokens are wired in — tracked in the Backlog. Per-page demo
  instances reproduce the missing structure for now.

- **2026-05-11: Theme = concept-level tokens, not gauge-specific properties.**
  The theme defines abstract tokens (`surface`, `primary`, `foreground`, …)
  rather than properties like `faceColor` or `needleColor`. Rationale: the
  theme must work across multiple gauge families (radial, future bar, future
  digital); concept-level tokens let each family interpret them appropriately
  (a radial gauge maps `surface` → its face; a bar gauge would map `surface` →
  its background) without the theme ever needing to know about specific gauge
  types.

- **2026-05-11: Theme submodule at `DevDash.Gauges.Theme`; public API is just
  `GaugeTheme`.** The theme lives in its own submodule, structured like
  Primitives / Compounds / Templates. The presets (`industrial`, `modernOEM`)
  are *not* separate importable types — they are nested `QtObject`s inside
  `GaugeTheme.qml`. Downstream code only ever touches `GaugeTheme`.

- **2026-05-11: Presets inlined into `GaugeTheme.qml`, not separate `.qml`
  files; `onSurface` token renamed `foreground`.** The original design had
  `IndustrialPreset.qml` / `ModernOEMPreset.qml` referenced by the singleton.
  Empirically, a QML *singleton* that references same-module types is not
  reliably loadable at runtime from a compiled `qt_add_qml_module` resource —
  the auto-generated qmldir's `prefer :/...` line breaks the relative
  resolution of the referenced types, and the failure mode is *silent* (the
  module just fails to import, no diagnostic on stderr, qmllint stays green).
  Inlining the presets as nested `QtObject`s sidesteps it. Separately, the
  Material-design token name `onSurface` had to become `foreground`: a
  property whose name starts with `on` + uppercase is mis-parsed by
  qmlcachegen as a signal-handler binding (works in the QML interpreter, fails
  in AOT). Both are tooling constraints, not design choices — revisit if a
  future Qt fixes either.

- **2026-05-10: GaugeTickRing gains `tickShape` passthrough.** The
  underlying GaugeTick primitive already exposed `tickShape` (verified
  in capability-verification.md), but the compound that consumed it
  hardcoded the rectangle default. Adding a passthrough is a one-line
  compound enhancement, not a new primitive — kept within the "no new
  primitives in this prompt" scope for IndustrialGauge.

- **2026-05-10: BezelScrews is a primitive, not a GaugeBezel style.**
  Two options were on the table: a separate `BezelScrews` primitive vs.
  a `style: "screwed"` option on GaugeBezel. Decision: separate primitive.
  Rationale: fasteners are conceptually independent of the bezel — they
  may appear on mounting plates, instrument panels, sub-bezels, or
  different bezel styles (matte/chrome/painted). A standalone primitive
  composes across all of those without bloating GaugeBezel's property
  surface or forcing every bezel style to participate in fastener
  geometry. IndustrialGauge layers BezelScrews on top of GaugeBezel;
  ChromeClassicGauge will do the same with different colors.



Short entries documenting non-obvious decisions and their rationale.

- **2026-05-10: Presets-not-pruning for discoverability.** Property surface
  stays wide; preset composites provide coherent aesthetic defaults. Rationale:
  library is published, downstream users may need any of the existing
  properties. Removing them is a breaking change with unclear benefit.

- **2026-05-10: No fragment-shader rewrite of primitives.** Audit confirmed
  Qt6 rendering stack (CurveRenderer, MultiEffect, declarative gradients)
  is technically adequate. Gap to "looks real" is aesthetic vocabulary, not
  rendering tech. Reserved as a future option if specific primitives prove
  inadequate.

- **2026-05-10: Dead-knob properties retained.** Properties never used by our
  own templates stay in the library's primitive API. Same rationale as
  presets-not-pruning: library serves downstream users beyond our own templates.

- **2026-05-10: MCP grows tier-by-tier, not all at once.** Each tier is
  implemented, exercised in real work, and validated before the next tier
  is added. Avoids speculative capability that goes unused or is shaped
  wrong for actual needs.

- **2026-05-10: No backward compatibility constraints.** This is a single-
  developer pre-release codebase with no external users. Tool signatures,
  return shapes, property names, file layout, and API surfaces can change
  freely whenever the change is better. No deprecation cycles, no
  compatibility shims. Applies to MCP tools, QML primitives, file
  organization, and anything else. Supersedes earlier reasoning that
  invoked "library serves downstream users."

- **2026-05-10: Dead-knob retention reconsidered.** The prior decision rested
  on "library serves downstream users beyond our own templates." Given no
  external users, pruning is on the table. Deferred until after the first
  two presets are built, when there is empirical data on which properties
  get reached for. Revisit then.

- **2026-05-10: File reorganization completed (Alternative B + subfolder
  grouping).** Needle sub-primitives moved from Primitives to Compounds
  alongside GaugeNeedle; primitives grouped into arc/, frame/ (face +
  bezel), center/, tick/, overlays/, 3d/; compounds grouped into arc/,
  tick/, needle/, readout/; radial/ renamed to templates/. URI of the four
  Needle* types changed from DevDash.Gauges.Primitives to
  DevDash.Gauges.Compounds; no external consumers exist. The only argument
  against was preserving module URIs for downstream users; with no external
  users, cleaner architecture wins.

## Open questions

Decisions to make, not work to do.

- **Font choice for IndustrialGauge.** Candidates: DIN 1451 (engineered/utility,
  widely available), Allied Stencil (overtly military), Eurostile (1960s
  aerospace), Letter Gothic (typewriter/early-computing). Licensing implications
  vary. Loaded via Qt FontLoader.
- **Animation damping work.** Currently deprioritized for Moon Patrol. May
  matter for the published library's quality bar — needle behavior is a
  significant "realness" cue. Revisit after presets land.
