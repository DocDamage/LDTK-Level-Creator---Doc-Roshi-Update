# Bundled Template Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four sample LDtk templates that showcase the bundled asset library.

**Architecture:** Generate compact LDtk JSON projects in `app/extraFiles/samples` with relative atlas asset references, plus PNG thumbnails in `app/extraFiles/samples/thumbs`.

**Tech Stack:** LDtk JSON, PowerShell/Python generation for structured sample artifacts, Haxe compile verification.

---

### Task 1: Select Representative Assets

**Files:**
- Read: `app/extraFiles/samples/atlas/assetLibrary.json`
- Read: selected image/audio files under `app/extraFiles/samples/atlas`

- [ ] Pick stable files for RPG, platformer, top-down, and horror/audio templates.
- [ ] Prefer already tracked, moderately sized PNG/WAV/OGG/MP3 files.
- [ ] Use relative paths from `app/extraFiles/samples`.

### Task 2: Generate LDtk Projects

**Files:**
- Create: `app/extraFiles/samples/Doc_Roshi_RPG_Room.ldtk`
- Create: `app/extraFiles/samples/Doc_Roshi_Platformer_Template.ldtk`
- Create: `app/extraFiles/samples/Doc_Roshi_TopDown_Template.ldtk`
- Create: `app/extraFiles/samples/Doc_Roshi_Horror_Audio_Demo.ldtk`

- [ ] Generate valid LDtk JSON with normal project headers, layer definitions, entity definitions, tileset references, and one compact level per template.
- [ ] Include tutorial text describing which bundled packs the template uses.
- [ ] Keep externalLevels disabled and avoid embedding raw binary asset data.

### Task 3: Generate Thumbnails

**Files:**
- Create: `app/extraFiles/samples/thumbs/Doc_Roshi_RPG_Room.png`
- Create: `app/extraFiles/samples/thumbs/Doc_Roshi_Platformer_Template.png`
- Create: `app/extraFiles/samples/thumbs/Doc_Roshi_TopDown_Template.png`
- Create: `app/extraFiles/samples/thumbs/Doc_Roshi_Horror_Audio_Demo.png`

- [ ] Generate readable thumbnails that match the Home sample shelf format.
- [ ] Use visual cues from each template type.

### Task 4: Verify

**Files:**
- Verify created samples and thumbnails.

- [ ] Parse all four `.ldtk` files as JSON.
- [ ] Confirm each thumbnail exists.
- [ ] Run `haxe renderer.debug.hxml`.
- [ ] Run `haxe main.debug.hxml`.
- [ ] Confirm the original oversized WAV is still ignored and the MP3 replacement is tracked.

### Task 5: Commit and Push

**Files:**
- Add spec, plan, samples, and thumbnails.

- [ ] Commit with message `Add bundled asset template samples`.
- [ ] Push `dev-1.5.4` to `doc-roshi`.
