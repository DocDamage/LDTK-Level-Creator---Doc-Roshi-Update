# Asset Workstation V2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the second asset-workstation layer: health diagnostics, template dependency previews, direct tileset import, local tags, clone manifests, editor recent assets, and stronger audio preview tools.

**Architecture:** Keep the asset workflow split into shared data helpers and focused UI modals. `misc.AssetLibraryDiagnostics` owns health/template reference analysis, `misc.AssetLibraryState` owns local user organization, and small `ui.*` modules expose actions without growing `Home.hx` or editor panels.

**Tech Stack:** Haxe renderer code, Electron/Node filesystem access, jQuery UI patterns already used by LDtk, SCSS compiled to `app.min.css`.

---

### Task 1: Diagnostics And Template References

**Files:**
- Create: `src/electron.renderer/misc/AssetLibraryDiagnostics.hx`
- Modify: `src/electron.renderer/misc/AssetLibrary.hx`

- [ ] Add diagnostics types for pack health, template references, clone manifests, and dependency summaries.
- [ ] Parse starter LDtk JSON recursively and collect strings that reference `atlas/...`.
- [ ] Detect missing referenced files and group references by image/audio/other.
- [ ] Write a sibling `.asset-manifest.json` when a starter is cloned.
- [ ] Verify with `npm run compile`.

### Task 2: Health Dashboard

**Files:**
- Create: `src/electron.renderer/ui/AssetHealthDashboard.hx`
- Modify: `src/electron.renderer/ui/AssetLibraryPanel.hx`
- Modify: `app/assets/tpl/pages/home.html`
- Modify: `app/assets/css/app.scss`

- [ ] Add a `Health` button to the asset library tools.
- [ ] Render summary counts and issue lists using diagnostics.
- [ ] Keep the dashboard read-only with locate/open actions.
- [ ] Regenerate `app/assets/css/app.min.css`.

### Task 3: Tags And Collections

**Files:**
- Modify: `src/electron.renderer/misc/AssetLibraryState.hx`
- Modify: `src/electron.renderer/ui/AssetLibraryPanel.hx`
- Modify: `src/electron.renderer/ui/AssetPackBrowser.hx`

- [ ] Store local per-pack tag arrays in `localStorage`.
- [ ] Add `tag:<name>` filters and tag chips to pack cards/browser.
- [ ] Add context actions for quick tag assignment.
- [ ] Make tag text searchable.

### Task 4: Template Dependency Preview

**Files:**
- Modify: `src/electron.renderer/ui/TemplateWizard.hx`
- Modify: `app/assets/css/app.scss`

- [ ] Show dependency counts on each template card.
- [ ] Add an expandable dependency panel with image/audio/missing references.
- [ ] Keep create/open/reveal actions available from the same card.

### Task 5: Direct Tileset Import And Editor Recents

**Files:**
- Create: `src/electron.renderer/ui/AssetImportTools.hx`
- Modify: `src/electron.renderer/ui/AssetPackBrowser.hx`
- Modify: `src/electron.renderer/ui/modal/panel/EditTilesetDefs.hx`
- Modify: `src/electron.renderer/ui/modal/panel/EditEntityDefs.hx`

- [ ] Add a reusable current-editor tileset import helper.
- [ ] Add an `Import as tileset` action to image previews when an editor is open.
- [ ] Add recent asset quick buttons to tileset/entity bundled asset pickers.
- [ ] Track imported files in `AssetLibraryState`.

### Task 6: Audio Preview Mixer

**Files:**
- Modify: `src/electron.renderer/ui/AssetPackBrowser.hx`
- Modify: `app/assets/css/app.scss`

- [ ] Add volume control for all audio previews in the pack browser.
- [ ] Add selected-audio toggles and copy selected audio paths.
- [ ] Keep stop-all behavior.

### Task 7: Verification And Commit

**Files:**
- Modify: `app/assets/css/app.min.css`

- [ ] Run `npx sass app/assets/css/app.scss app/assets/css/app.min.css --style=compressed --no-source-map`.
- [ ] Run `npm run compile`.
- [ ] Run `node tools\validate-doc-roshi-assets.js`.
- [ ] Run `node tools\validate-release-config.js`.
- [ ] Run `git diff --check`.
- [ ] Commit and push to `doc-roshi/dev-1.5.4`.
