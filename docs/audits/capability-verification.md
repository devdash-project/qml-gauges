# Capability Verification — Dead-Knob Audit

**Date:** 2026-05-10
**Explorer build commit:** `82863508` (`feat: add 3D gauge components and visual improvements`)
**Verifier:** Claude Code (Opus 4.7) via devdash MCP server
**MCP tools used:** `qml_explorer_{launch,navigate,set_property,get_property,list_properties,get_state}`,
`image_compare`, `image_bounding_box`, `image_perceptual_hash`.
**Note on screenshot capture:** The MCP `screenshot_gauge_preview` / `screenshot_capture` tools
returned `Window 'explorer' not found` because the explorer ran as a Wayland-native window
under Hyprland and the MCP enumerates X11 clients only. Worked around with `grim` (Wayland
screenshot tool) + a Python crop helper, producing equivalent left-60% × center-80% preview
crops at 809×1020 px. The MCP image-inspection tools accepted the resulting PNGs unchanged.

All screenshots scratch-located in `/tmp/qml-verify/`; not committed.

---

## Verification 1 — `GaugeTick.tickShape`

**Hypothesis under test:** Five enum values are declared; only `"rectangle"` is exercised
by any consumer. Are the remaining four implemented and visually distinct?

**Setup.** Navigated to GaugeTick page. Property panel hardcodes `angle` to an animation
(`-135 + animationValue * 2.7`); first capture pass produced near-identical perceptual
hashes across shapes because the tick was at different rotational positions. Pinned
`angle = 0` and `distanceFromCenter = 100` via MCP `set_property` (this overrides the
QML binding) before re-capturing. Also bumped `tickWidth = 10` and `length = 40`
(within documented ranges) to maximise per-shape pixel surface. Each property change
was confirmed by reading the value back via `get_property` before screenshotting.

**Results.**

```
tickShape verification (post-animation-pin):
  rectangle:   rendered=YES, hash=0101011905132367, bbox=(0,0)-(809,1020), coverage=0.7731
  block:       rendered=YES, hash=0101011905132367, distinct_from_rectangle=YES (subtle)
  triangle:    rendered=YES, hash=0101011905132367, distinct_from_rectangle=YES
  rounded-dot: rendered=YES, hash=0101011905132367, distinct_from_rectangle=YES
  chevron:     rendered=YES, hash=0101011905132367, distinct_from_rectangle=YES (clearest)
```

All five values were accepted by the property setter without error and confirmed via
`get_property`. All five produced non-zero pixel deltas vs every other value — none
was silently ignored.

**Perceptual-hash distance matrix.** dHash returned distance 0 for every pair. dHash
downsamples to 9×8 grayscale, and a 10×40 px tick on an 809×1020 image is below that
resolving threshold. **The hash tool was useless at this scale**; pixel-level metrics
were diagnostic.

**Pairwise diff geometry** (count of pixels with channel-sum diff > 5; bounding box of
those pixels in the full preview crop):

| A | B | diff_pixels | centroid (x,y) | bbox |
|---|---|-------------|---------------|------|
| rectangle | block       |   6 | (598,276) | (597,276)–(600,277) |
| rectangle | triangle    |  50 | (598,285) | (597,276)–(600,292) |
| rectangle | rounded-dot |  39 | (599,287) | (597,279)–(600,292) |
| rectangle | chevron     | 112 | (598,282) | (592,275)–(605,292) |
| block     | triangle    |  44 | (598,286) | (597,278)–(600,292) |
| block     | rounded-dot |  45 | (599,285) | (597,276)–(600,292) |
| block     | chevron     | 112 | (598,282) | (592,275)–(605,292) |
| triangle  | rounded-dot |  36 | (598,283) | (597,276)–(600,291) |
| triangle  | chevron     |  98 | (598,281) | (592,275)–(605,292) |
| rounded-dot | chevron   | 102 | (598,281) | (592,275)–(605,292) |

**Mean per-pixel RGB diff (0–255 scale)** from `image_compare`:

|             | block    | triangle | rounded-dot | chevron  |
|-------------|----------|----------|-------------|----------|
| rectangle   | 0.000232 | 0.004204 | 0.003400    | 0.011779 |
| block       |   —      | 0.003972 | 0.003632    | 0.012011 |
| triangle    |   —      |   —      | 0.000804    | 0.009588 |
| rounded-dot |   —      |   —      |   —         | 0.009612 |

SSIM across all pairs is ≥ 0.9997 — expected, since the tick is < 0.2 % of the image area.

**Interpretation.**

- **All 5 values render** without QML errors or property rejection.
- **All 5 produce distinct pixel output.** No value is silently aliased to another.
- **Distinctness magnitudes vary substantially**, in three tiers:
  - **Tier 1 (most distinct): `chevron`.** Diff bbox extends laterally (x=592–605, 13 px
    wide) vs others' 3-px-wide bbox — the V-shape genuinely occupies different geometry.
    Pixel diffs ~100, ~10× the inter-non-chevron diffs.
  - **Tier 2 (mid-distinct): rectangle/block vs triangle/rounded-dot.** ~40-50 px diff,
    same x-range as the others. Source inspection confirms triangle/rounded-dot taper
    the shape (visible in zoomed crops as wider-at-outer, narrower-at-inner profiles)
    where rectangle/block are uniform width.
  - **Tier 3 (subtle): rectangle vs block, triangle vs rounded-dot.** 6 px and 36 px
    respectively. Source (`src/primitives/GaugeTick.qml:294-349`) confirms rectangle has
    `radius: roundedEnds ? tickWidth/2 : 0` (default true) while block has `radius: 0`.
    With `tickWidth=10`, the visible difference is the 5-px corner-rounding only.
    These pairs are technically distinct but **visually near-identical at typical
    tick sizes** — consumers picking between them should expect roundedEnds semantics
    to dominate.

**Status: WORKING.** All five enum values are functional and produce distinct renders.
Caveat for downstream preset authors: rectangle/block and triangle/rounded-dot pairs
produce visually subtle differences at default tick proportions.

---

## Verification 2 — `GaugeFace.textureSource`

**Hypothesis under test:** Property is wired through the primitive but never set
anywhere. Does it actually load and render an image?

**Setup.** Navigated to GaugeFace page. `qml_explorer_list_properties` revealed
`textureSource` is **not exposed in the page's property panel metadata** — only diameter,
borderWidth, color, borderColor, faceOpacity, useGradient, gradientCenter, gradientEdge,
antialiasing are. Inspection of `src/primitives/GaugeFace.qml:90,134` confirmed the
property exists on the primitive and feeds an `Image { source: root.textureSource }`.
The MCP `set_property` call still succeeded by setting the property on the underlying
QML object (bypassing the panel UI).

Generated a 128×128 red/blue 16-px checkerboard PNG at `/tmp/qml-verify/test_texture.png`.
Captured baseline first, then set `textureSource = "file:///tmp/qml-verify/test_texture.png"`,
confirmed via `get_property`, captured again.

**Results.**

| Metric | Value |
|--------|-------|
| SSIM (baseline vs textured) | 0.935635 |
| Mean per-pixel RGB diff | 14.45 (out of 255) |
| Perceptual hash distance | 8 |
| Visual confirmation | Checkerboard fills full gauge face area |

The checkerboard pattern is clearly visible filling the face. `file://` URL scheme worked
on first attempt; no alternative schemes tried.

**Side observation (not a verification target, but worth noting in the report):** The
texture renders in a **square** region matching the face's bounding rectangle, not a
disc clipped to the face circle. `src/primitives/GaugeFace.qml:118` uses `clip: true`,
which is rectangular clipping only — circular clipping would require an OpacityMask
or shader. This is a pre-existing rendering choice, not a verification finding, but
preset authors planning to use textureSource should be aware they'll need to mask
externally for textures meant to look "painted on the dial."

**Status: WORKING.** Texture loads and renders. Caveats:
1. Not exposed in the GaugeFace property panel — UI-only consumers can't reach it.
2. Rendered region is rectangular, not circular.

---

## Verification 3 — `Bezel3D` buildability and rendering

**Hypothesis under test:** Quick3D primitive conditionally built; buildability and
visual quality unverified.

**Results.**

- **Bezel3D appears in the explorer's component list.** Navigation to `Bezel3D` succeeded;
  `get_state` returned a page with PBR property metadata (outerRadius, innerRadius,
  color, metalness, roughness, specularAmount, iblExposure, lightBrightness, lightAngle).
- **Renders non-empty output at defaults.** Bounding box covers full image
  (coverage_ratio = 0.770) — the page's background is non-flat, so the box tool
  reports high coverage; visual inspection confirms a chrome ring is rendered
  centered in the preview area with characteristic mirror-style reflections and a
  visible inner/outer rim.
- **Responsive to property changes.** Changed `roughness` from default 0.08 (mirror polish)
  to 1.0 (matte). Property readback confirmed 1.0. Comparison:
  - SSIM: 0.958859 (significantly different)
  - Mean pixel diff: 2.73
  - Perceptual hash distance: 9
  - Visual: Default render shows mirror-chrome with dark reflection center; matte
    render shows uniform diffuse light gray with no reflections. Categorically different
    material appearance — PBR pipeline is live.

**Status: WORKING.** Bezel3D is built, navigable, renders non-empty, and is responsive
to PBR property changes.

---

## Unexpected behaviors & MCP quirks

1. **Wayland-only window invisible to MCP screenshot tools.** Documented above; worked
   around with `grim`. Worth filing as an MCP-server issue (separate repo) for
   Wayland-host scenarios.

2. **`mcp__devdash__qml_explorer_get_property` returns "not found" on bound properties
   it can still set.** During Verification 1, `get_property("angle")` returned
   `Property 'angle' not found` while the property was bound to an animation expression.
   `set_property("angle", 0)` succeeded (breaking the binding) and subsequent
   `get_property("angle")` returned `"0"`. Pattern: read-when-bound fails; write succeeds
   and stabilises the property. Same behaviour observed for `showInnerCircle` (hardcoded
   in the page QML, never settable from the panel).

3. **GaugeTick page hardcodes `angle` to a running animation.** This actively interferes
   with property verification of any non-rotational attribute — the tick is in a different
   position every frame, contaminating image diffs. First pass on Verification 1 showed
   identical perceptual hashes across all five shapes (apparent regression) until the
   animation was pinned. The cure (setting `angle` directly via MCP) breaks the binding
   cleanly but is non-obvious; a future MCP wrapper or page-level "freeze animation" toggle
   would prevent this trap.

4. **`textureSource` is functional but UI-orphaned on GaugeFace.** The primitive supports
   it; the explorer page omits it from `properties: [...]` metadata. A reasonable preset
   author exploring via the property panel would conclude the texture knob doesn't exist.

5. **`devdash_logs_get` is for the separate `devdash` application, not `qml-gauges-explorer`.**
   Called as instructed; returned a connection error pointing at a different repo's
   binary. Explorer's own stdout/stderr are piped to the MCP and not retained — no
   QML console warnings could be inspected for this session. No QML errors surfaced in
   the rendered output, but absence-of-evidence applies.

6. **Perceptual hash is too coarse for small-element verification.** dHash at 9×8 returned
   distance 0 across all five tickShape values (despite all five producing distinct
   pixels). For sub-1 %-coverage features, only `mean_pixel_diff` and `image_bounding_box`
   were diagnostic. Worth noting for future verification prompts: don't rely on hash
   distance alone for small primitives.

No QML console errors, render glitches, or property-setter rejections were observed
during the session. The explorer process (PID 2601620) remained stable; no relaunch
was required.

---

## Summary

| Capability | Classification | Notes |
|------------|---------------|-------|
| `GaugeTick.tickShape` — 5 enum values | **Working** | All five render distinctly. rectangle/block and triangle/rounded-dot pairs are visually subtle at default proportions. Chevron is the only obviously-different shape. |
| `GaugeFace.textureSource` | **Working (with caveats)** | Texture loads via `file://` URL and renders. Not exposed in property-panel UI; rendered region is rectangular (no circular masking). |
| `Bezel3D` build + render | **Working** | Conditionally-built Quick3D primitive is present, renders chrome material at defaults, and responds to PBR property changes. |

None of the three flagged capabilities is broken or indeterminate. All three are
viable inputs for the IndustrialGauge / ChromeClassicGauge preset construction
listed in `docs/PLAN.md`. Preset authors should be aware of the textureSource
caveats and of the limited visual distinctness within the tickShape rectangle/block
and triangle/rounded-dot pairs.
