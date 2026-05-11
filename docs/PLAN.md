# qml-gauges development plan

This document tracks the active development plan for the qml-gauges library.
For the durable architectural reference, see CLAUDE.md. For audit outputs and
historical investigations, see docs/audits/.

Last updated: 2026-05-10 (BezelScrews primitive landed and integrated into IndustrialGauge)

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

## Aesthetic targets (presets)

Each preset is a thin composite that sets property defaults on the underlying
primitives. Reference images for each live in docs/references/.

### IndustrialGauge (Moon Patrol's home)

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

**Status:** completed 2026-05-10. `src/templates/IndustrialGauge.qml`.
Implementation choices:
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

### ModernOEMGauge

- The OEM digital cluster aesthetic. Glow effects, gradient backgrounds,
  digital readouts, value arcs filling behind/instead of the needle.
- Approximately equivalent to current `RadialGauge3D` template with full
  effects enabled.

Reference images: Hyundai Palisade cluster.

## Known capabilities and gaps

As of 2026-05-10. Based on audit outputs in docs/audits/.

### Inventory

- 11 primitives, 10 compounds, 3 templates (RadialGauge, RadialGauge3D,
  IndustrialGauge — the last is the first preset). BezelScrews joined
  the primitives roster 2026-05-10.
- Module URIs: `DevDash.Gauges`, `DevDash.Gauges.Primitives`, `DevDash.Gauges.Compounds`.
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

No active work item. BezelScrews primitive shipped 2026-05-10 and is
integrated into IndustrialGauge by default. Next likely deliverable is
the second preset (PerformanceBlackGauge or ChromeClassicGauge).

## Backlog

Work units that are well-scoped but not active.

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
- **Label-inside-face rendering helper.** IndustrialGauge places the
  label inside the dial via `verticalCenterOffset`. Other presets will
  want the same. A small `GaugeFaceLabel` compound (positioned along a
  configurable radial offset, with the same color/font wiring as the
  tick ring) would deduplicate this.
- **ChromeClassicGauge preset.** Blocked on Bezel3D viability assessment.
  BezelScrews primitive landed 2026-05-10 and is reusable here.
- **PerformanceBlackGauge preset.** Depends on verified-working needle
  configurations. Lower priority than IndustrialGauge.
- **Tier 2 MCP wrapper** (`render_matrix`). Useful once tier 1 wrapper exists.
- **Tier 7 MCP perf instrumentation.** Defer until Jetson budget questions
  become concrete (e.g., when running multiple gauges simultaneously in the
  deployed dashboard).
- **Reference image baseline for visual regression.** Once IndustrialGauge
  exists and renders correctly, baseline its output via tier 3 perceptual
  hash; any future change that affects the rendered output is caught.
- **Deeper effect-unification refactor** (bevel technique consistency across
  primitives, gradient declaration patterns). Deferred — not blocking,
  significant scope, limited visual payoff.

## Decisions log

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
