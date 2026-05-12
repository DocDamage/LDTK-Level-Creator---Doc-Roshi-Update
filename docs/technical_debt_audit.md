# Technical Debt Audit

Date: 2026-05-12  
Branch/head audited: `dev-1.5.4` at `df7b62cea`  
Scope: whole app, with extra attention to the Doc Roshi bundled asset update, release packaging, CI, dependency posture, and maintainability hotspots.

## Executive Summary

The app is currently buildable and the recent release hardening is working: `node tools\validate-doc-roshi-assets.js`, `node tools\validate-release-config.js`, `npm audit --audit-level=low`, and `npm run compile` all pass. The largest remaining debt is not the Haxe app logic itself; it is the newly bundled asset payload and the lack of a formal asset-normalization pipeline. Follow-up cleanup removed tracked source-drop sidecars, deleted the local ignored raw WAV copy, committed `app/package-lock.json`, added release validation for the license manifest and blocked asset extensions, and added a tracked atlas max-size guard.

The main engineering risks are:

1. Huge bundled asset footprint makes clone, CI, packaging, and review slow and fragile.
2. Asset source drops still need a formal import/normalization pipeline even though known sidecars are now blocked.
3. License/attribution has now been checked against local files and public pack pages; the imported packs are documented for private/personal use, but most are not approved for public raw-asset redistribution.
4. Core renderer files remain large and tightly coupled.
5. Several old TODOs hide correctness risks outside the asset-library path.

## Current Health Checks

Verified during this audit:

```powershell
node tools\validate-doc-roshi-assets.js
node tools\validate-release-config.js
npm audit --audit-level=low
```

Results:

- Doc Roshi asset validation passed: `233` starters, `151` asset starters, `78` CuteSCKR starters.
- Release config validation passed.
- NPM audit reports `0 vulnerabilities`.
- Git working tree was clean before the audit document was written.

## High Severity Debt

### 1. Bundled Asset Payload Is Too Large For Long-Term Repo Health

Evidence:

- `app/extraFiles/samples`: `95,148` tracked files, about `3,424.2 MiB`.
- `app/extraFiles/samples/atlas`: `94,649` tracked files, about `3,398.1 MiB`.
- Top tracked atlas extensions include about `92,453 .png`, `1,427 .wav`, `341 .gif`, and `218 .ogg`.
- `tools/validate-doc-roshi-assets.js` now rejects tracked atlas files larger than `16 MiB`.

Impact:

- Fresh clones and pulls become expensive.
- GitHub browsing, diffs, and history operations slow down.
- Packaging and CI are more likely to hit time, cache, or artifact-size limits.
- Every future asset cleanup becomes harder because Git history keeps the weight.

Recommendation:

- Create an asset normalization pipeline that copies only app-known distributable assets into `atlas`.
- Keep raw source drops ignored outside the repository or in a separate release artifact store.
- Convert large WAV loops to compressed preview formats when the app only needs prototype playback.
- Consider Git LFS or release assets if full-resolution originals must remain available.

### 2. Raw Source-Drop Sidecar Files Needed Cleanup

Status: handled for known sidecar extensions in the follow-up cleanup. `.gitignore`, `app/electron-builder.json`, and `tools/validate-doc-roshi-assets.js` now block these classes from returning.

Evidence:

Tracked examples include:

- `.DS_Store`
- `.import`
- `.md5`
- `.stex`
- `.cfg`
- `.meta`
- `.tscn`
- `.gd`
- `.ctex`
- `.sample`
- `.cs`
- `.psd`
- `.pck`

Example paths:

- `app/extraFiles/samples/atlas/ansimuz assets/Cyberpunk streets/SynthCitiesGodot/.DS_Store`
- `app/extraFiles/samples/atlas/ansimuz assets/Cyberpunk streets/SynthCitiesGodot/CityLayers/back.png.import`
- `app/extraFiles/samples/atlas/ansimuz assets/Warped Super Grotto Escape Collection/Windows/SuperGrottoEscape.pck`
- `app/extraFiles/samples/atlas/stages/undead land objects/Objects.psd`

Impact:

- Users get project/editor internals rather than a clean LDtk asset library.
- Packaged builds carry files the app does not preview or import directly.
- Some file types may trigger antivirus, signing, quarantine, or platform packaging behavior.

Recommendation:

- Extend `.gitignore`, `app/electron-builder.json`, and `tools/validate-doc-roshi-assets.js` to reject non-distributable source-drop sidecars.
- Decide which source formats are intentionally shipped. If PSD/Aseprite files are wanted, document that explicitly. Otherwise strip them.
- Recompute `assetLibrary.json` counts after cleanup.

### 3. Oversized Audio Needed Cleanup

Status: handled for the known raw WAV path in the working tree. `tools/validate-doc-roshi-assets.js` now rejects the converted-away WAV if it is ever tracked again.

Evidence:

Largest asset file found:

- `app/extraFiles/samples/atlas/sound effects/Horror SFX Free/Ambient/Suburban Neighborhood_morning.wav`: `141.56 MB`

The `.gitignore` already ignores this path, but it still appears in the working asset tree scan. If tracked, it should be removed from Git. If untracked, it should be removed from the working copy before packaging tests.

Impact:

- One file dominates clone/package cost.
- It duplicates the already generated MP3 path used by the horror/audio demo.
- It undermines the previous “convert WAV to MP3” cleanup intent.

Recommendation:

- Confirm `git ls-files` for this exact WAV.
- If tracked: `git rm --cached` or `git rm`, depending on whether a local raw copy should remain.
- Add validator coverage for explicitly forbidden large raw audio paths.
- Consider a max-size validator for tracked atlas files, with allowlisted exceptions only.

### 4. Asset Licensing Requires Private-Only Distribution

Status: verified for the current project intent. This app update is for private/personal use, and `docs/asset_license_manifest.json` now records that distinction explicitly. Public raw-asset redistribution remains blocked unless permissions change.

Evidence:

- `docs/DOC_ROSHI_ASSET_CREDITS.md` maps packs to authors and broad license notes.
- HoriHori public pack pages allow project use but forbid redistribution/resale.
- Cute SCKR public terms allow game-project use but prohibit standalone resource redistribution.
- CraftPix/Free Game Assets licenses allow game distribution but prohibit redistributing source art in reusable form.
- BattleInkMaps has no public raw-file redistribution grant on the checked purchase page.
- Ansimuz is partially verified through local public-license files, but retained music/font/audio side-assets still need attribution review.

Impact:

- Private/personal use is the intended scope and is documented.
- Public GitHub distribution of many retained raw PNG/WAV files likely violates or exceeds the verified asset-pack terms.
- Attribution alone is not enough for packs that prohibit standalone redistribution.

Recommendation:

- Keep this repository private while it contains raw packs marked `private-use-*`.
- Remove or replace every private-only raw asset pack before a public release.
- Keep only assets with CC0/public-domain/open redistribution terms or explicit written permission for this repository use case.
- Keep local license files next to any retained redistributable assets.

## Medium Severity Debt

### 5. Core Renderer Files Are Large And Highly Coupled

Status: partially handled. The asset pack modal was extracted into `src/electron.renderer/ui/AssetPackBrowser.hx`, and the Home asset library pack list/filter/context-menu behavior was extracted into `src/electron.renderer/ui/AssetLibraryPanel.hx`. Home now keeps page-level coordination and sample navigation.

Evidence from line counts:

- `src/electron.renderer/page/Editor.hx`: `2458` lines.
- `src/electron.renderer/misc/JsTools.hx`: `1346` lines.
- `src/electron.renderer/data/Project.hx`: `1134` lines.
- `src/electron.renderer/page/Home.hx`: `787` lines.
- `src/electron.renderer/ui/AssetLibraryPanel.hx`: `225` lines.
- `src/electron.renderer/ui/AssetPackBrowser.hx`: `139` lines.
- `src/electron.renderer/ui/FieldInstancesForm.hx`: `870` lines.
- `src/electron.renderer/ui/modal/panel/EditLayerDefs.hx`: `902` lines.

Impact:

- Changes are harder to reason about and review.
- UI, state management, file IO, and project behavior are mixed in a few large modules.
- Regression risk rises because small changes touch high-traffic files.

Recommendation:

- Keep asset-library list behavior in `ui.AssetLibraryPanel` and modal behavior in `ui.AssetPackBrowser`.
- Continue extracting unrelated Home sample/recents rendering into focused helpers only when changing those areas.
- Split `JsTools.hx` by domain over time: file/path helpers, DOM helpers, image helpers, Electron helpers.
- Avoid large refactors in one commit; carve out one stable helper at a time with compile checks.

### 6. Silent Catch Blocks Hide Failure Modes

Status: mostly handled for known empty catch blocks. Asset-library scan/manifest catches now log context; crash auto-reload cleanup, editor input blur, and queued file reload catches now log failure details.

Evidence:

- `src/electron.renderer/misc/AssetLibrary.hx` previously swallowed asset scan/manifest failures.
- `src/electron.renderer/page/CrashReport.hx` previously swallowed settings-save failures after a crash.
- `src/electron.renderer/page/Editor.hx` previously swallowed jQuery blur failures for the Back command.
- `src/electron.renderer/misc/FileWatcher.hx` previously caught queued reload errors and only returned `false`.

Impact:

- Broken asset folders, malformed manifests, file watcher failures, and rendering failures can degrade silently.
- Support/debugging gets harder because users see missing UI rather than actionable errors.

Recommendation:

- Keep lightweight diagnostic logging in targeted catch blocks.
- Surface manifest parse errors on Home instead of returning an empty pack list.
- Add validator tests for malformed manifest behavior.
- Keep user-facing messages concise, but log technical detail for diagnostics.

### 7. TODO/HACK Hotspots Mark Real Feature Gaps

Evidence:

- `src/electron.renderer/exporter/Tiled.hx:23`: multi-world export hack.
- `src/electron.renderer/exporter/Tiled.hx:373`: entity refs not exported.
- `src/electron.renderer/exporter/GameMakerStudio2.hx`: multiple TODO dynamic fields.
- `src/electron.renderer/data/inst/LayerInstance.hx:475`: layer offset coordinate calculation marked untested.
- `src/electron.renderer/misc/FileWatcher.hx:27`: rename support missing.
- `src/electron.renderer/page/Editor.hx:1045`: allocation optimization TODO.
- `src/electron.common/Settings.hx:323`: UI scale hack.

Impact:

- Exporters and file watching are brittle around edge cases.
- Some TODOs affect correctness, not polish.

Recommendation:

- Triage TODOs into correctness, performance, and cosmetic buckets.
- Prioritize exporter correctness and file watcher rename support.
- Add regression samples for multi-world export, entity references, and layer offset calculations.

### 8. Dependency Reproducibility Is Now Lockfile-Based

Status: handled for the Electron app. `app/package-lock.json` is now committed and CI/release docs use `npm ci`.

Evidence:

- `app/package.json` versions are now pinned.
- `app/package-lock.json` is ignored in `.gitignore`.

Residual recommendation:

- Keep `app/package-lock.json` updated whenever `app/package.json` changes.
- Use `npm ci` in CI and release verification.

### 9. CI Modernization Is Mostly Handled

Status: handled for Node/action versions and deprecated `set-output` usage.

Evidence:

- Workflows now use Node 20 and modern GitHub Actions.
- Haxe setup still uses `krdlab/setup-haxe@v1`.
Residual recommendation:

- Review whether a newer Haxe setup action is available and stable.

## Lower Severity Debt

### 10. Generated Build Outputs Are Ignored But Mentioned In README

Evidence:

- `.gitignore` excludes `app/assets/main.js`, `app/assets/js/renderer.js`, generated CSS, and source maps.
- README explains compile output paths.

Impact:

- This is mostly fine for source builds, but users browsing GitHub may expect runnable app assets.

Recommendation:

- Keep generated outputs ignored.
- Make README clearer that a source checkout must compile before `npm run start`.

### 11. Asset Library Preview Limit Is Fixed

Evidence:

- `AssetLibrary.getPreviewFiles(pack, limit=120)` hardcodes default preview limit.

Impact:

- Large packs may hide useful files.
- Small packs work well, but the UI has no paging/lazy loading yet.

Recommendation:

- Add paging or search inside the pack browser.
- Load previews incrementally to avoid scanning and rendering too much at once.

### 12. Validation Is Useful But Still Growing

Evidence:

- `tools/validate-doc-roshi-assets.js` validates starter counts, paths, preview tiles, and blocked executable/runtime files.
- `tools/validate-release-config.js` validates pinned direct dependencies, packager filters, and stale workflow versions.
- The asset validator now also validates tracked atlas file existence, blocked source-drop extensions, explicitly forbidden raw audio paths, and max tracked atlas file size.

Impact:

- Good guardrails exist, but they do not yet cover:
  - manifest file-count accuracy for every pack,
  - broken thumbnail dimensions/corrupt images.

Recommendation:

- Extend validation in small steps.
- Keep per-pack license manifest statuses aligned with the private/personal-use scope.
- Add manifest file-count accuracy checks for every pack.
- Add corrupt-image/thumbnail dimension checks.

## Recommended Remediation Order

1. Remove or quarantine raw source-drop sidecars from `atlas`.
2. Remove the tracked `Suburban Neighborhood_morning.wav` if it is still in Git, and keep only the MP3 for app-known use.
3. Add max-size and sidecar-extension validation to `tools/validate-doc-roshi-assets.js`.
4. Create a strict `docs/asset_license_manifest.json` and validate every `assetLibrary.json` pack against it.
5. Extract the Home asset-library browser into a focused Haxe module.
6. Add lazy preview paging/search inside the asset browser.
7. Triage old TODOs, starting with exporter correctness and file watcher rename behavior.

## Suggested Next Implementation Slice

The highest-value next slice is asset import/normalization automation:

- Add a small tool that scans `atlas/assetLibrary.json` packs and reports count drift, corrupt/missing thumbnails, and unsupported preview files.
- Use that report before manually editing asset packs.
- Leave broader `Editor.hx`/`JsTools.hx` decomposition for separate, testable slices.
- Run:

```powershell
node tools\validate-doc-roshi-assets.js
node tools\validate-release-config.js
cd app
npm ci
npm audit --audit-level=low
npm run compile
npm run pack-test
```

That slice directly attacks the biggest release risk without destabilizing core editor behavior.
