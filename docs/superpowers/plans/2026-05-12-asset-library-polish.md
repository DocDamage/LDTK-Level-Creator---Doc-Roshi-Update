# Asset Library Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the bundled asset library catalog cards and make existing import picker actions clearer and more useful.

**Architecture:** Keep `AssetLibrary.hx` as the shared metadata helper. Upgrade Home rendering and context-menu actions using those helpers, then apply the same pack labels in tileset, entity, and file-field picker menus.

**Tech Stack:** Haxe, LDtk Electron renderer, jQuery-style UI helpers, existing context-menu and LESS/CSS pipeline.

---

### Task 1: Asset Metadata Helpers

**Files:**
- Modify: `src/electron.renderer/misc/AssetLibrary.hx`

- [ ] **Step 1: Add capability helpers**

Add methods for extension display, counts, and image/audio checks:

```haxe
public static function isAudioPack(pack:AssetLibraryPack) {
	return pack.kind=="Audio";
}

public static function hasImageFiles(pack:AssetLibraryPack) {
	for(ext in getPackExtensions(pack))
		if( ext==".png" || ext==".jpg" || ext==".jpeg" || ext==".gif" || ext==".webp" )
			return true;
	return false;
}

public static function hasAudioFiles(pack:AssetLibraryPack) {
	for(ext in getPackExtensions(pack))
		if( ext==".wav" || ext==".ogg" || ext==".mp3" )
			return true;
	return false;
}
```

- [ ] **Step 2: Add display helpers**

Add small formatting helpers:

```haxe
public static function getExtensionLabel(pack:AssetLibraryPack, limit=5) {
	var exts = getPackExtensions(pack);
	if( exts.length==0 )
		return "mixed files";
	var shown = exts.slice(0, limit);
	var label = shown.join(", ");
	if( exts.length>shown.length )
		label += " +" + (exts.length-shown.length);
	return label;
}

public static function getPackSubtitle(pack:AssetLibraryPack) {
	var bits = [ pack.kind, pack.files+" files" ];
	var exts = getExtensionLabel(pack);
	if( exts.length>0 )
		bits.push(exts);
	return bits.join(" - ");
}
```

- [ ] **Step 3: Compile renderer**

Run: `haxe renderer.debug.hxml`

Expected: successful compile.

### Task 2: Rich Home Cards

**Files:**
- Modify: `src/electron.renderer/page/Home.hx`

- [ ] **Step 1: Render structured card metadata**

Replace card details string assembly with structured fields: badge, file count, extensions, suggested use, author/license.

- [ ] **Step 2: Expand search haystack**

Include kind, extensions, suggested use, author, license, summary, and name in `data-search`.

- [ ] **Step 3: Improve empty/missing text**

Keep graceful fallback messages for missing library folder, missing manifest, and empty manifest.

- [ ] **Step 4: Compile renderer**

Run: `haxe renderer.debug.hxml`

Expected: successful compile.

### Task 3: Action-Oriented Pack Menus

**Files:**
- Modify: `src/electron.renderer/page/Home.hx`

- [ ] **Step 1: Add metadata to menu title**

Show pack subtitle in a disabled/subtext menu row below the title.

- [ ] **Step 2: Add capability-aware actions**

Keep `Open asset folder`, `Copy folder path`, and `Reveal preview image`. Add image/audio-specific action labels that copy the folder path for use in import fields.

- [ ] **Step 3: Compile renderer**

Run: `haxe renderer.debug.hxml`

Expected: successful compile.

### Task 4: Picker Label Polish

**Files:**
- Modify: `src/electron.renderer/ui/modal/panel/EditTilesetDefs.hx`
- Modify: `src/electron.renderer/ui/modal/panel/EditEntityDefs.hx`
- Modify: `src/electron.renderer/ui/FieldInstancesForm.hx`

- [ ] **Step 1: Use consistent pack labels**

Update bundled library context-menu labels to include pack name and extension summary where possible.

- [ ] **Step 2: Preserve filtering behavior**

Keep the current accepted-file filtering in file fields and image-only filtering in tileset/entity flows.

- [ ] **Step 3: Compile renderer**

Run: `haxe renderer.debug.hxml`

Expected: successful compile.

### Task 5: Verification and Commit

**Files:**
- Verify all modified files.

- [ ] **Step 1: Compile both targets**

Run:

```powershell
haxe renderer.debug.hxml
haxe main.debug.hxml
```

Expected: both successful.

- [ ] **Step 2: Validate manifest**

Run manifest path/thumb validation.

Expected: no missing paths and `packs=12`.

- [ ] **Step 3: Verify ignored WAV**

Run tracked/ignored status check for `Suburban Neighborhood_morning.wav` and `.mp3`.

Expected: `.mp3` tracked, `.wav` ignored.

- [ ] **Step 4: Commit**

Run:

```powershell
git add src/electron.renderer/misc/AssetLibrary.hx src/electron.renderer/page/Home.hx src/electron.renderer/ui/modal/panel/EditTilesetDefs.hx src/electron.renderer/ui/modal/panel/EditEntityDefs.hx src/electron.renderer/ui/FieldInstancesForm.hx docs/superpowers/plans/2026-05-12-asset-library-polish.md
git commit -m "Polish bundled asset library workflow"
```
