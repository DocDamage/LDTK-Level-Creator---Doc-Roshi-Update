# Whole App Polish Robustness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden the Doc Roshi LDtk branch for release by reducing asset-library UI fragility, preventing unsafe bundled runtime files, and verifying compile/package health.

**Architecture:** Keep changes close to existing LDtk patterns. Centralize asset-library safety helpers in `AssetLibrary.hx`, make Home UI rendering use text-safe jQuery insertion, and keep repo/package safety enforced by the Node validator and `.gitignore`.

**Tech Stack:** Haxe renderer code, Electron app packaging, Node validation script, GitHub Actions.

---

### Task 1: Asset-Library Helper Hardening

**Files:**
- Modify: `src/electron.renderer/misc/AssetLibrary.hx`

- [ ] Add helpers for safe URL paths, null-safe display fields, and blocked runtime extensions.
- [ ] Use the blocked extension list in pack scanning so executable/runtime files never appear in extension labels or previews.
- [ ] Run `npm run compile` from `app`.

### Task 2: Home Asset UI Polish

**Files:**
- Modify: `src/electron.renderer/page/Home.hx`

- [ ] Replace HTML string interpolation for pack names, summaries, metadata, and preview labels with `.text(...)`.
- [ ] Use the new asset URL helper for image backgrounds and audio sources.
- [ ] Add clearer empty/error text for missing folders, manifests, previews, and over-limit previews.
- [ ] Run `npm run compile` from `app`.

### Task 3: Release Guard Verification

**Files:**
- Modify if needed: `tools/validate-doc-roshi-assets.js`
- Modify if needed: `.gitignore`
- Modify if needed: `app/electron-builder.json`

- [ ] Verify `node tools\validate-doc-roshi-assets.js`.
- [ ] Verify `npm audit --audit-level=low`.
- [ ] Verify `npm run pack-test`.
- [ ] Commit and push the hardening pass.
