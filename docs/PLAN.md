# qml-gauges development plan

This document tracks the active development plan for the qml-gauges library.
For the durable architectural reference, see CLAUDE.md. For audit outputs and
historical investigations, see docs/audits/.

Last updated: 2026-05-12 (ClassicWhite 2D/3D variants + `GaugeQuality` singleton landed — new `effects3DEnabled` flag selects `CenterCap3D` vs. a form-shaded 2D `GaugeCenterCap` for the domed hub; `GaugeTickLabel` gained a `"halo"` form-shading mode; new theme tokens `centerCapStyle`, `effectsTextShadingMode`, `effectsTextShadingColor`; ClassicWhite numerals are now dark glyphs with an orange-red halo. See "ClassicWhite 2D/3D variants + GaugeQuality singleton (2026-05-12)" below. Previously — 2026-05-11 — ClassicWhite typographic-character refinement landed: Barlow Condensed bundled into the theme module via a FontLoader on `GaugeTheme` and pointed at by ClassicWhite's `typographyNumeralFontFamily`; `GaugeTickLabel` gained a `hasFormShading` capability driven by a `MultiEffect` directional shadow; a new theme token `effectsTextShading` opts a preset into form-shaded numerals — true on classicWhite, false on industrial / modernOEM so their rendered output is unchanged. See "ClassicWhite refinement (2026-05-11)" below for the capability-test outcome. Before that — same date — the `chrome3d` `GaugeBezel` fill bug was fixed in commit `29d00cf` (chrome3d rebuilt as a true annulus). And MCP-follow-up explorer fixes: PropertyPanel now mirrors binding-derived target changes into the editor UI and the state server, so `qml_explorer_get_state` is no longer stale after `GaugeTheme.setTheme()`; and a new `resetProperty` WS action / `qml_explorer_reset_property` tool re-establishes a property's binding after `set_property` pinned it — see the Decisions log. Earlier the same day: theme Phase 5 — the explorer's header bar gained a preset selector + gauge mode toggle (`GaugeThemeControls`) driving the `GaugeTheme` singleton globally, populated declaratively from `presetNames` / `presetMetadata` and reflecting `activeTheme` / `mode` reactively. And Phases 3–4 — legacy IndustrialGauge / RadialGauge3D templates retired in favour of GaugeTheme presets; ClassicWhite preset added; RadialGauge gained scriptLabel / brandLabel; the Phase-3 follow-up wired the structural theme tokens — tickStyle, bezelStyle, effectsGlow/effectsShadow/effectsTexture, typographyScale — into RadialGauge so the three presets render structurally distinct, not just colour-shifted (Industrial-vs-ModernOEM SSIM 0.965 → 0.77). The whole theme track (Phases 1–5) is complete.)

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

(Landed 2026-05-11, Phases 1–5 — the theme track is complete.)

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
  The theme never names a specific gauge type. RadialGauge maps every token
  today (colours → face/bezel/needle/arc/tick colours; `tickStyle` → tick
  shape; `bezelStyle` → bezel style; `effectsGlow` → tick + needle glow;
  `effectsShadow` → needle shadow; `effectsTexture` → face-texture gate;
  `typographyScale` → label/numeral/readout sizes). Full token-to-property
  table: CLAUDE.md "Theme system"; the doc comment in
  `src/theme/GaugeTheme.qml` covers the token semantics.
- **Preset registry as data.** `GaugeTheme.presetNames` (ordered internal
  names) and `GaugeTheme.presetMetadata` (`{displayName, description}` per
  preset) expose the preset list as plain data; the explorer's Phase-5 preset
  selector is built declaratively off it. Adding a preset now touches three
  co-located spots in `GaugeTheme.qml`: the nested `QtObject`, a `setTheme()`
  case, and a registry entry — and it shows up in the selector with no explorer
  change. (No `swatch` field yet — see Backlog.)
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

Phase status: Phases 1–5 complete (the theme track is finished); the Phase-3
token follow-up is also done.
- Phase 1 (theme infrastructure) + Phase 2 (RadialGauge consumes the colour
  and font-family tokens).
- Phase 3 — retired the legacy preset-composite templates. Because RadialGauge
  already read the theme tokens, this was done as "migrate the explorer
  consumers to `RadialGauge` + `GaugeTheme.setTheme(...)`, then delete
  `IndustrialGauge.qml` / `RadialGauge3D.qml`" rather than the originally-
  envisioned "make those templates *be* the presets".
- Phase 4 — added the `classicWhite` preset (vintage white-face aesthetic) and
  the `scriptLabel` / `brandLabel` decorative face-text slots on RadialGauge.
- Phase-3 follow-up (landed same day) — RadialGauge now consumes the
  *structural* tokens too: `tickStyle` → `tickShape`, `bezelStyle` →
  `GaugeBezel.style`, `effectsGlow` → `tickGlow` + `needleOuterGlow`,
  `effectsShadow` → `needleShadow`, `effectsTexture` → a `faceTexture` gate on
  `faceTextureSource`, `typographyScale` → the label / numeral / readout font
  sizes. Verified: a plain RadialGauge themed `industrial` vs `modernOEM` went
  from SSIM ≈ 0.965 (colour-only difference) to ≈ 0.77 (chevron vs rectangle
  ticks, flat vs `chrome3d` bezel, no-glow vs glow). Per-instance overrides
  still win; structural tokens are mode-independent (don't change with
  light/dark). One leftover, backlogged: the `RadialGauge3D`-era glass overlay
  and domed centre cap have no token at all. (Wiring `bezelStyle` →
  `GaugeBezel.style` also surfaced a pre-existing `chrome3d` fill bug — a filled
  360° arc that painted over the dial — fixed the same day in `29d00cf` by
  rebuilding the chrome3d shape as a true annulus; see the Decisions log.)
- Also landed: `GaugeTheme.presetNames` / `presetMetadata` — the preset list
  as enumerable data, the foundation for the Phase-5 selector.
- Phase 5 (landed 2026-05-11) — the explorer's header bar gains
  `GaugeThemeControls` (`explorer/qml/components/GaugeThemeControls.qml`): a
  preset selector ComboBox + a gauge light/dark mode toggle, both driving the
  `GaugeTheme` singleton globally. The selector is built declaratively off
  `presetNames` / `presetMetadata` (display name as label, description as a
  per-option tooltip) and reflects `activeTheme` reactively — a preset-demo
  page's `Component.onCompleted: setTheme(...)` shows up as the selected item,
  and the user can deviate via the selector with nothing reverting it (pages
  set the preset only on load). The mode toggle is independent of the
  explorer's own UI light/dark toggle (so a light explorer UI can show
  dark-mode gauges, or vice versa). The `themeName` / `themeMode` synthetic
  properties on `RadialGaugePage` remain as an MCP verification harness — they
  manipulate the same global state the selector now reflects.

No Phase 6: the theme track is complete. (Remaining theme-adjacent work is
backlog: the `RadialGauge3D`-era glass overlay / domed centre cap have no token
yet, the `swatch`-per-preset idea, and a `GaugeFaceLabel` compound.)

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
`RadialGauge` picks it up, including the chevron ticks (now from the
`tickStyle` token) and the painted-needle drop shadow (`effectsShadow`). The
"needle-only, no value arc" choice has no theme token — `showValueArc` is a
RadialGauge feature toggle, not a token — so the explorer demo page still sets
that per-instance. The original composite's implementation choices, kept for
the token rationale:
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
  light-grey marks) are live, and as of the Phase-3 token follow-up so are the
  structural ones: `bezelStyle: "chrome3d"`, `tickStyle: "rectangle"`,
  `effectsGlow: true` now reach RadialGauge. Two effects the old `RadialGauge3D`
  hard-wired still have no theme token — the glass overlay and the domed centre
  cap — so they remain instance-only (in the Backlog). (Wiring `chrome3d`
  through also exposed a `GaugeBezel` fill bug — the 360° arc painted over the
  dial — fixed in `29d00cf`: the chrome3d shape is now a true annulus.)

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
  `explorer/qml/pages/ClassicWhitePage.qml`. **Refined 2026-05-11** with
  bundled typography and form-shaded numerals — see *ClassicWhite refinement
  (2026-05-11)* below.

Reference image: `docs/references/Screenshot_20251129-203149.png` (Classic
Instruments Velocity White).

#### ClassicWhite refinement (2026-05-11)

First capability-test prompt for the library — how close can we get to a
specific real-world reference (the Velocity White speedo)? Two highest-impact
gaps to close: the numerals' typographic character (the prior Helvetica/Roboto
fallback chain read as flat web-app sans, not painted-on geometric condensed
sans) and the absence of any dimensional cue on the numerals (the reference's
numerals read as painted-with-depth, not flat-coloured text). Both landed:

- **Typography.** Bundled **Barlow Condensed** (SIL OFL) under
  `src/assets/fonts/` — geometric condensed sans in Regular / SemiBold / Bold
  weights, the OFL license file shipped alongside. The theme module's qrc
  bundle picks the .ttf files up via `qt_add_qml_module`'s `RESOURCES`
  argument with explicit `QT_RESOURCE_ALIAS` aliases, so the qrc path is
  stable (`qrc:/DevDash/Gauges/Theme/fonts/<file>.ttf`) regardless of source
  layout. Three `FontLoader`s live on the `GaugeTheme` singleton at startup,
  and the loaded family name is exposed as `GaugeTheme.barlowCondensedFamily`
  — classicWhite's `typographyNumeralFontFamily` binds to it, so the literal
  string "Barlow Condensed" is never hard-coded in QML.
- **Form shading.** `GaugeTickLabel` gained `hasFormShading` /
  `formShadingIntensity` / `lightAngle` / `formShadingColor` properties. With
  shading on, the `Text` element is wrapped in a `layer.enabled` and gets a
  `MultiEffect` shadow whose offset vector is derived from `lightAngle`
  (default -45°: light from upper-left) and whose magnitude scales with both
  `fontSize` and intensity. At the default 0.4 intensity the offset stays
  well below the glyph stroke width, so the result reads as a slightly raised
  painted numeral rather than a duplicated glyph. The shadow color defaults to
  `Qt.darker(text-color, 1.8)` so the shading is hue-consistent with the
  glyph (the paint-on-paint look). `GaugeTickRing` proxies through
  `labelFormShading` / `labelFormShadingIntensity` to each major-tick label.
- **Theme gating.** A new theme token `effectsTextShading` — separate from
  `effectsShadow` (which is for *solid* objects: the needle) — lets a preset
  declare painted-text shading independently. `classicWhite.effectsTextShading
  = true`; `industrial` and `modernOEM` carry `false`, so the rendered output
  of both is unchanged (their typography is flat stencil/sans, not painted).
  `RadialGauge.tickLabelFormShading` defaults to `GaugeTheme.effectsTextShading`.

Verification:
- Screenshots: `docs/audits/classicwhite-typography-2026-05-11/`
  (`classicwhite-light.png`, `classicwhite-dark.png`,
  `industrial-light-unchanged.png`, `modernoem-light-unchanged.png`).
- Reference perceptual-hash distance is dominated by the reference's phone-
  chrome (status bar, browser bar) which the gauge crop does not contain, so
  raw Hamming distance moved from ~25 → ~30 (slightly *worse* by that metric,
  because the new render shares less *non-gauge* pixel structure with the
  reference). The metric isn't load-bearing here.
- The load-bearing test is human visual judgment side-by-side. Outcome: the
  Barlow Condensed numerals make a far larger visible difference than the form
  shading. The shading at default intensity is intentionally subtle — the
  small font sizes at our preview scale don't carry much sub-pixel depth — but
  it is present and the dimensional cue does register. Pushed to 0.7 the
  effect is more pronounced without breaking the depth read; pushed to 1.0 it
  starts to look like duplicate glyphs. Default of 0.4 ships.
- Industrial and ModernOEM presets visually unchanged
  (`industrial-light-unchanged.png`, `modernoem-light-unchanged.png`).

Technical notes for future similar work:
- `MultiEffect` on a `Text` requires `layer.enabled: true` (the effect
  operates on a rasterised texture of the source). `layer.smooth: true` keeps
  glyphs crisp on high-DPI displays. Each enabled `GaugeTickLabel` now carries
  one layer + one `MultiEffect` — at typical gauge counts (8-10 major ticks)
  this is fine on Jetson Orin NX, but a future bar gauge with many more text
  elements may want a different approach (e.g. baking the shadow into a
  pre-rendered atlas).
- Bundling fonts via `qt_add_qml_module(... RESOURCES ...)` with
  `QT_RESOURCE_ALIAS` worked cleanly first try. The alternative —
  `qt_add_resources` to a separate prefix — would have been less localised to
  the theme module.
- Backlog item to consider: extract the "Text + form-shading shadow" pattern
  to a reusable `FormShadedText` primitive if a second consumer appears (e.g.
  the `gaugeLabel` slot or a future face wordmark wants the same treatment).

#### ClassicWhite 2D/3D variants + GaugeQuality singleton (2026-05-12)

- New singleton `GaugeQuality` (in `DevDash.Gauges.Theme`, alongside
  `GaugeTheme`) — the foundation for a *graphics-settings architecture*.
  Currently one flag, `effects3DEnabled`, plus `setQuality("full"|"reduced")`.
  It's the lever for "best with 3D / best without 3D" choices: elements that
  ship both a Quick3D and a 2D rendering path pick between them off this flag,
  switchable at runtime parallel to theme switching. Deliberately minimal — add
  flags as more effects become quality-sensitive (textures, MultiEffect chains,
  a low-fidelity typography scale override are the obvious next ones).
- ClassicWhite now has **two first-class variants**, not a degraded fallback
  pair:
  - **Numerals** (same in both variants): near-black glyphs (`foreground` =
    `#1a1a1a`) ringed by an orange-red **halo** — `GaugeTickLabel` gained
    `formShadingMode: "shadow" | "halo"` ("halo" = centered, no offset, larger
    intensity-driven blur, saturated colour); the preset's old orange-red glyph
    colour became the halo colour via the new `effectsTextShadingMode` /
    `effectsTextShadingColor` theme tokens.
  - **Centre hub**: new `centerCapStyle` theme token (`"flat" | "dome"`).
    ClassicWhite is `"dome"`; RadialGauge then renders `CenterCap3D` (Quick3D
    cone, painted-matte material, upper-left key light) when
    `GaugeQuality.effects3DEnabled`, else a form-shaded 2D `GaugeCenterCap`
    (`hasFormShading` — a single radial gradient with the focal point pulled
    ~30% of the radius toward `lightAngle`). Industrial / ModernOEM are
    `"flat"` and unchanged.
- Verification (2026-05-12): both variants render the white-face look — dark
  numerals + visible orange halo, orange needle, orange domed hub. At the
  default 30 px centre-cap diameter the 2D form-shaded dome and the 3D cone are
  hard to tell apart; the 3D advantage only really shows at larger hub sizes.
  CenterCap3D's API exposes `diameter` / `color` / `metalness` / `roughness` /
  `specularAmount` / `iblExposure` / `lightBrightness` / `lightAngle` only — the
  mesh is a *dome*, not a cone, and there's no geometry control to make it one.
  Dark-mode halo is muddier (amber glyphs under a brighter-orange aura — low
  separation); not perfected this pass. Frame-time MCP tool returned 0 samples
  on the gauge pages (no continuous animation; the needle tween completes faster
  than the sampling window engages), so per-variant cost wasn't quantified — but
  the 2D variant only adds one cached-able `Shape`, the halo reuses the existing
  per-numeral `MultiEffect` layer with different params, and the 3D variant adds
  a `View3D` (a full 3D render pass — the expensive one).
- Backlog: keep adding quality-sensitive effects to `GaugeQuality` as they're
  built; give CenterCap3D a cone mesh + geometry knobs; consider a mode-dependent
  `effectsTextShadingColor` so dark-mode halos dim with the rest of the palette.

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

Total tools exposed: 26 (up from the 17 documented earlier — the image-diff
suite, the screenshot/telemetry/logs tools and the `qml_explorer_*` freeze /
reset / status / logs introspection tools landed since; the most recent
addition is `qml_explorer_reset_property`).

### Additional MCP capabilities

These don't fit the tier framework cleanly but matter for verification work:

- **`qml_explorer_freeze_property` / `freeze_all_properties`** — break animation
  bindings during verification so a value can be inspected without the
  binding immediately overwriting it.
- **`qml_explorer_reset_property`** — the inverse: re-establish a property's
  binding after `set_property` / `freeze` pinned it to a literal. Backed by the
  explorer's `resetProperty` action (2026-05-11); restores from the property
  metadata's `reset` expression (the GaugeTheme token it defaults to) or its
  documented `default`. See the Decisions log.
- **Binding-derived state is now live.** PropertyPanel publishes a property's
  value to the state server not just at page load but whenever it changes via a
  QML binding (e.g. a `GaugeTheme.setTheme()` flowing through
  `RadialGauge.faceColor`), so `qml_explorer_get_state` / `get_property` return
  the *current* resolved value, not the load-time one (2026-05-11).
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

No active work item. The theme track is complete: Phases 1–5 shipped
2026-05-11 — the `DevDash.Gauges.Theme` singleton with `industrial`,
`modernOEM` and `classicWhite` presets; RadialGauge consumes every token
(colour, font, `tickStyle` / `bezelStyle` / the `effects*` flags /
`typographyScale`) as defaults and exposes `scriptLabel` / `brandLabel`; the
`IndustrialGauge` and `RadialGauge3D` templates are gone; `GaugeTheme` exposes
`presetNames` / `presetMetadata`; and the explorer's header bar drives all of
it via `GaugeThemeControls` (preset selector + gauge mode toggle). Next, pick
from the Backlog: the next aesthetic target preset (PerformanceBlack or
ChromeClassic), re-homing the `RadialGauge3D`-era glass overlay / domed centre
cap (no theme token yet), the `swatch`-per-preset idea, a `GaugeFaceLabel`
compound, or the effect-consistency cleanup.

## Backlog

Work units that are well-scoped but not active.

- **~~Wire the remaining theme tokens into RadialGauge~~ — DONE (Phase-3
  follow-up, 2026-05-11).** RadialGauge now consumes `tickStyle` → `tickShape`,
  `bezelStyle` → `GaugeBezel.style`, `effectsGlow` → `tickGlow` +
  `needleOuterGlow`, `effectsShadow` → `needleShadow`, `effectsTexture` →
  `faceTexture` (gating `faceTextureSource`), `typographyScale` → label /
  numeral / readout font sizes. A plain RadialGauge themed `industrial` vs
  `modernOEM` went from SSIM ≈ 0.965 (colour only) to ≈ 0.77. The two
  sub-items below spun out of this work.
- **Re-home the `RadialGauge3D` glass overlay / domed centre cap.** Neither
  has a theme token — the original token set only covered colours, tick/bezel
  style, and the three `effects*` flags. Decide whether to add tokens (an
  `overlayStyle` / a `centerCapStyle`, say) or accept these stay per-instance
  options on RadialGauge. Until then the explorer demo pages reproduce them
  per-instance.
- **~~`chrome3d` `GaugeBezel` fill bug~~ — FIXED (2026-05-11, commit `29d00cf`).**
  The `chrome3d` style drew a single 360° `PathAngleArc` with a `ConicalGradient`
  `fillGradient`; a filled 360° arc closes through the centre, so the Shape
  painted a solid chrome disc over the dial, ticks, needle and centre cap. Latent
  until the Phase-3 follow-up wired `bezelStyle` → `GaugeBezel.style` through
  RadialGauge (`showBezel` defaults false, so it was never exercised before) —
  `modernOEM` uses `chrome3d` and rendered unusably. Fixed by rebuilding the
  chrome3d shape as a true annulus (an outer circle + an inner circle in one
  `ShapePath` with `OddEvenFill`), so the gradient fills only the ring between
  `outerRadius` and `innerRadius`; same outer/inner silhouette as the flat
  style. The non-3d `chrome` style was always unaffected (nested Rectangle
  borders).
- **Per-preset representative swatch colour.** Add a `swatch` field to
  `GaugeTheme.presetMetadata` so a selector can show a colour chip per preset.
  Deferred because "what *is* a preset's representative colour" is itself a
  design question (the `primary` accent? a face/accent pairing? light-mode or
  dark-mode?) — decide that first.
- **Effect consistency cleanup.** Three specific fixes: Canvas→RadialGradient
  vignette migration in GlassOverlay, layer.smooth normalization across
  MultiEffect users, GaugeTick MultiEffect split (separate glow from shadow).
  Approved, low risk. Independent of file reorganization; ship standalone.
- **~~Explorer protocol enhancement — resolve bound property values for the
  MCP~~ — effectively DONE (2026-05-11).** The MCP can't evaluate QML bindings
  itself, but PropertyPanel now publishes a property's resolved value to the
  state server both at page load *and* whenever a binding re-evaluates it, so
  `get_state` carries it and `get_property`'s fallback finds it (no separate
  `resolveProperty` action needed for the panel-backed pages). A bound value
  that has no editor on its page still won't appear — that's the residual gap,
  but it hasn't bitten anything; revisit only if it does.
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
  FontLoader in either the template or a Theme singleton. (Infrastructure
  now exists: `GaugeTheme` carries `FontLoader`s and `qt_add_qml_module`'s
  `RESOURCES` + `QT_RESOURCE_ALIAS` pattern is established by the 2026-05-11
  Barlow Condensed bundle.)
- **`FormShadedText` reusable primitive.** The `Text` + `layer.enabled` +
  `MultiEffect`-shadow pattern that `GaugeTickLabel.hasFormShading` ships
  could be extracted to its own primitive if a second consumer wants it
  (a face wordmark slot, the `gaugeLabel` text, the digital readout's
  number, etc.). Doing it preemptively would be premature abstraction;
  do it once the second use site exists.
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

- **2026-05-11: ClassicWhite refinement — new `effectsTextShading` token, not
  a reuse of `effectsShadow`.** Form-shaded numerals could plausibly default
  off `effectsShadow` (and the original prompt suggested that). But Industrial
  and ModernOEM both carry `effectsShadow: true` (for the needle's drop
  shadow), and giving their numerals painted-relief shading would change
  their rendered output — which the prompt also forbade. So shading on solid
  objects (needle) and shading on text are now expressed as two tokens, not
  one. A side benefit: presets that want a needle shadow *without* painted
  text (Industrial, ModernOEM) and presets that want painted text *with* a
  matching needle (ClassicWhite) are both expressible; a hypothetical preset
  that wanted painted text without a needle shadow would also work. The new
  token's mode-independence matches the rest of the `effects*` family.

- **2026-05-11: Font family looked up from FontLoader.name, not hard-coded.**
  Theme preset `typographyNumeralFontFamily` strings point at
  `GaugeTheme.barlowCondensedFamily` (which resolves from the loader's
  `name` property) rather than the literal "Barlow Condensed". This avoids
  the silent fallback when the font's reported family differs from what's
  on disk (different builds report subtly different names — "Barlow
  Condensed" vs "BarlowCondensed-Regular" vs the OS-canonicalised form), and
  surfaces a load failure as a default-sans render rather than a wrong-font
  string lookup that no one notices.

- **2026-05-11: PropertyPanel now mirrors binding-derived target changes; new
  `resetProperty` protocol action.** Two MCP-follow-up fixes. (1) Each property
  editor connects to its target's `<name>Changed` signal and re-publishes the
  value to the editor UI and the state server, with a re-entrancy guard so the
  editor's resulting `valueChanged` doesn't push back onto the target (which
  would clobber the binding it's mirroring — and would also break an animated
  property's binding, e.g. `RadialGauge.value`). Closes the
  `get_state`-is-stale-after-`GaugeTheme.setTheme()` issue. (2) `StateServer`
  gains a `resetProperty` action → `resetPropertyRequested(name)` →
  `PropertyPanel.onResetPropertyRequested`, which re-creates the binding via
  `Qt.binding` from an optional `reset:` function on the property's metadata
  entry — the GaugeTheme-token *expression* the template defaults to (e.g.
  `faceColor`'s `() => GaugeTheme.colors.surface`) — or falls back to the
  metadata `default` literal for non-theme-bound properties. The `reset:`
  expression lives in the *page* metadata (`RadialGaugePage.qml`) so
  PropertyPanel stays gauge-agnostic; it's only metadata, so it serialises to
  `null` over the WS protocol (the MCP doesn't use it). Verified end-to-end via
  `qml_explorer_reset_property`: `set faceColor=#ff0000` → `setTheme(classicWhite)`
  (face stays red) → `reset_property("faceColor")` → face = classicWhite surface
  `#2b2620` → `setTheme(modernOEM)` → face tracks to `#060606`. Reset also
  exercised on bool / real / string / int editors. The old `resolveProperty`
  backlog idea is obsoleted for panel-backed pages (the resolved values are now
  in `get_state`).
- **2026-05-11: Phase-5 selector took "Option B" — kept the per-page
  `setTheme()` calls, made the selector reactive.** The explorer's preset
  selector reflects `GaugeTheme.activeTheme` (mapping the active nested
  `QtObject` back to its `presetNames` entry), so a preset-demo page's
  `Component.onCompleted: GaugeTheme.setTheme(...)` shows up as the selected
  item — the per-page "this page demonstrates the Industrial preset" semantic
  is preserved *and* the user can deviate via the selector, with nothing
  reverting it because pages set the preset only on load, never continuously.
  No new GaugeTheme API: the selector consumes the existing `presetNames` /
  `presetMetadata` / `activeTheme` / `mode` / `setTheme` / `setMode`. The
  gauge mode toggle is deliberately a *separate* control from the explorer's
  own UI light/dark toggle (the `Theme` singleton): they're orthogonal, so a
  light explorer UI can render dark-mode gauges (night-driving simulation) or
  vice versa. `currentIndex` on the ComboBox is pushed imperatively (not a
  plain binding) because the control writes to it on user activation, which
  would break a binding — a small `syncToActive()` guarded by an
  index-already-equal check keeps it consistent both ways. The `themeName` /
  `themeMode` synthetic-property hook on `RadialGaugePage` was kept (not
  removed) as an MCP verification harness — it drives the same global state the
  selector reflects, which is exactly what makes it a useful test of the
  selector's reactivity.

- **2026-05-11: Structural-token wiring kept RadialGauge's existing property
  names; didn't rename to a `*Has*` convention.** The Phase-3 follow-up changed
  the *defaults* of `needleShadow` / `needleOuterGlow` / `tickGlow` to read
  from `effectsShadow` / `effectsGlow`, and added `tickShape` / `bezelStyle` /
  `faceTexture` / `faceTextureSource`, rather than renaming the booleans to
  match a theme-token naming convention. Rationale: the existing names are
  already what `RadialGaugePage`'s property metadata, the per-page demos, and
  the tests reference; renaming would churn the explorer for no functional
  gain. New properties use the sub-component's name where one exists
  (`tickShape` matches `GaugeTickRing.tickShape`; `bezelStyle` maps to
  `GaugeBezel.style`). The `chrome3d` `GaugeBezel` fill bug surfaced by this
  wiring was *not* fixed in the same change — it's a primitive bug, kept to its
  own commit; it landed next as `29d00cf` (the chrome3d shape rebuilt as a true
  annulus).

- **2026-05-11: `presetMetadata` ships no `swatch` field yet.** `presetNames` +
  `presetMetadata` (displayName + description) are enough for the Phase-5
  selector to be declarative. A representative-colour chip per preset was
  considered and deferred — picking *which* colour represents a preset (accent?
  face? a pairing? which mode?) is a design call to make when the selector's
  visual design is on the table, not a data-plumbing one. Backlogged.

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
  and deleted the files. Trade-off accepted at the time: RadialGauge consumed
  only the colour/font tokens, so the structural/effect distinctions the old
  templates hard-wired (chevron ticks, chrome3d bezel, glass overlay, glow) were
  lost until the remaining tokens were wired in. Mostly resolved the same day by
  the Phase-3 follow-up (which added `tickStyle` / `bezelStyle` / the `effects*`
  flags / `typographyScale` to RadialGauge — see above); the glass overlay and
  domed centre cap still have no token (Backlog), and the per-page demo
  instances reproduce those for now.

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
