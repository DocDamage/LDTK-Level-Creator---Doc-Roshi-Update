# Technical Debt Audit

Date: 2026-05-12  
Branch/head audited: `dev-1.5.4` at `df7b62cea`  
Scope: whole app, with extra attention to the Doc Roshi bundled asset update, release packaging, CI, dependency posture, and maintainability hotspots.

## Executive Summary

The app is currently buildable and the recent release hardening is working: `node tools\validate-doc-roshi-assets.js`, `node tools\validate-release-config.js`, and `npm audit --audit-level=low` all pass. The largest debt is not the Haxe app logic itself; it is the newly bundled asset payload and the lack of a formal asset-normalization pipeline. The repository now tracks roughly `96k` sample files and about `3.65 GB` under `app/extraFiles/samples/atlas`, including many source-drop sidecar files that are not app-native art/audio.

The main engineering risks are:

1. Huge bundled asset footprint makes clone, CI, packaging, and review slow and fragile.
2. Asset source drops include non-user-facing sidecar formats and large source files.
3. License/attribution is documented at pack level, but not yet verified per file or per license text.
4. Core renderer files remain large and tightly coupled.
5. Several silent catch blocks and TODOs hide recoverable failures.
6. The app has no lockfile committed, so reproducibility relies on pinned versions but not full transitive dependency locking.

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

- `app/extraFiles/samples`: `96,381` tracked files, about `3,675.0 MB`.
- `app/extraFiles/samples/atlas`: `95,882` tracked files, about `3,648.9 MB`.
- Top tracked asset extensions include about `91,673 .png`, `1,427 .wav`, `341 .gif`, `78 .psd`, plus many engine/editor sidecars.

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

### 2. Raw Source-Drop Sidecar Files Are Still Tracked

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

### 3. Oversized Audio Still Needs Cleanup

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

### 4. Asset Licensing Is Not Yet Release-Grade

Evidence:

- `docs/DOC_ROSHI_ASSET_CREDITS.md` maps packs to authors and broad license notes.
- Most entries say “See original pack terms” or “See original files in pack folders.”
- The repository ships assets directly, so broad attribution may not be enough.

Impact:

- Release/legal risk if pack licenses require specific wording, links, redistribution terms, or bundled license files.
- Reviewers and users cannot quickly verify whether redistribution is allowed.

Recommendation:

- Add a per-pack license manifest with:
  - original URL/source,
  - author,
  - license name,
  - redistribution permission,
  - required attribution text,
  - local license file path.
- Fail CI if a pack in `assetLibrary.json` lacks a license manifest entry.
- Keep license files next to imported assets or in `docs/licenses/asset-packs/`.

## Medium Severity Debt

### 5. Core Renderer Files Are Large And Highly Coupled

Evidence from line counts:

- `src/electron.renderer/page/Editor.hx`: `2458` lines.
- `src/electron.renderer/misc/JsTools.hx`: `1346` lines.
- `src/electron.renderer/data/Project.hx`: `1134` lines.
- `src/electron.renderer/page/Home.hx`: `948` lines.
- `src/electron.renderer/ui/FieldInstancesForm.hx`: `870` lines.
- `src/electron.renderer/ui/modal/panel/EditLayerDefs.hx`: `902` lines.

Impact:

- Changes are harder to reason about and review.
- UI, state management, file IO, and project behavior are mixed in a few large modules.
- Regression risk rises because small changes touch high-traffic files.

Recommendation:

- Extract Home asset-library UI into a dedicated module, e.g. `ui/AssetLibraryBrowser.hx`.
- Move asset-library rendering details out of `Home.hx`; keep Home responsible for page composition.
- Split `JsTools.hx` by domain over time: file/path helpers, DOM helpers, image helpers, Electron helpers.
- Avoid large refactors in one commit; carve out one stable helper at a time with compile checks.

### 6. Silent Catch Blocks Hide Failure Modes

Evidence:

- `src/electron.renderer/misc/AssetLibrary.hx:120`, `179`, `245`, `306` swallow failures.
- `src/electron.renderer/page/CrashReport.hx:128` swallows a catch.
- `src/electron.renderer/page/Editor.hx:617` catches and ignores `Dynamic`.
- `src/electron.renderer/misc/FileWatcher.hx:66` catches and returns false.

Impact:

- Broken asset folders, malformed manifests, file watcher failures, and rendering failures can degrade silently.
- Support/debugging gets harder because users see missing UI rather than actionable errors.

Recommendation:

- Add lightweight debug logging in asset-library catch blocks.
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

### 8. Dependency Reproducibility Is Better But Still Not Locked

Evidence:

- `app/package.json` versions are now pinned.
- `app/package-lock.json` is ignored in `.gitignore`.

Impact:

- Direct dependencies are stable, but transitive dependency resolution can still change between installs.
- CI and local builds can diverge if registry metadata changes.

Recommendation:

- Reconsider ignoring `app/package-lock.json`.
- If lockfile remains ignored, document that this project intentionally relies on exact direct versions and audit validation instead.
- Prefer committing the lockfile for release branches.

### 9. CI Modernization Is Partial

Evidence:

- Workflows now use Node 20 and modern GitHub Actions.
- Haxe setup still uses `krdlab/setup-haxe@v1`.
- GitHub Actions branch discovery still uses deprecated `set-output` in workflows.

Impact:

- Future GitHub runner changes may break CI.
- Deprecated syntax can become a hard failure later.

Recommendation:

- Replace `echo "::set-output name=v::..."` with `$GITHUB_OUTPUT`.
- Review whether a newer Haxe setup action is available and stable.
- Add `node tools/validate-release-config.js` coverage for deprecated `set-output`.

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

### 12. Validation Is Useful But Narrow

Evidence:

- `tools/validate-doc-roshi-assets.js` validates starter counts, paths, preview tiles, and blocked executable/runtime files.
- `tools/validate-release-config.js` validates pinned direct dependencies, packager filters, and stale workflow versions.

Impact:

- Good guardrails exist, but they do not yet cover:
  - max file size,
  - source-drop sidecar extensions,
  - per-pack license completeness,
  - manifest file-count accuracy for every pack,
  - broken thumbnail dimensions/corrupt images.

Recommendation:

- Extend validation in small steps.
- First add blocked sidecar and max-size checks.
- Then add per-pack license manifest checks.

## Recommended Remediation Order

1. Remove or quarantine raw source-drop sidecars from `atlas`.
2. Remove the tracked `Suburban Neighborhood_morning.wav` if it is still in Git, and keep only the MP3 for app-known use.
3. Add max-size and sidecar-extension validation to `tools/validate-doc-roshi-assets.js`.
4. Create a strict `docs/asset_license_manifest.json` and validate every `assetLibrary.json` pack against it.
5. Replace GitHub Actions `set-output` usage with `$GITHUB_OUTPUT`.
6. Decide whether to commit `app/package-lock.json` for release reproducibility.
7. Extract the Home asset-library browser into a focused Haxe module.
8. Add logging or user-visible diagnostics for asset manifest parse/read failures.
9. Add lazy preview paging/search inside the asset browser.
10. Triage old TODOs, starting with exporter correctness and file watcher rename behavior.

## Suggested Next Implementation Slice

The highest-value next slice is asset payload cleanup:

- Update ignore rules for sidecar/source-drop formats.
- Remove sidecar/source files from Git where they are not app-known assets.
- Extend `validate-doc-roshi-assets.js` to reject them.
- Recompute `assetLibrary.json` pack counts.
- Run:

```powershell
node tools\validate-doc-roshi-assets.js
node tools\validate-release-config.js
cd app
npm audit --audit-level=low
npm run compile
npm run pack-test
```

That slice directly attacks the biggest release risk without destabilizing core editor behavior.
