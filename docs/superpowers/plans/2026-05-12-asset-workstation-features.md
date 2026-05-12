# Asset Workstation Feature Pass

Date: 2026-05-12
Scope: make the bundled Doc Roshi asset library feel intentional inside the LDtk fork.

## Goal

Turn the current asset list and starter samples into a small asset workstation:

- discover templates by use case,
- inspect packs with richer metadata,
- search by multiple terms instead of exact substrings,
- remember favorites and recent packs/files,
- make asset images faster to bring into tilesets/entities,
- improve audio preview controls,
- show a private-use scope warning,
- clone starter templates into a user project path while keeping atlas references valid.

## Implementation Tasks

1. Add local asset library state.
   - New `misc.AssetLibraryState` stores favorites and recents in `window.localStorage`.
   - Keep storage private to the renderer and tolerant of malformed JSON.
   - Track pack paths, preview file paths, and starter template paths.

2. Strengthen shared asset search/helpers.
   - Add tokenized matching helper so `"horror audio"` matches text containing both words.
   - Add reusable starter aggregation and asset-relative path helpers.
   - Add template clone helpers that rewrite `atlas/...` references to a relative path from the new project location.

3. Build a Template Wizard.
   - New `ui.TemplateWizard` modal lists all asset-backed starters.
   - Filters: all, RPG, platformer, top-down, horror/audio, CuteSCKR, recent/favorites.
   - Actions: open starter, create project from starter, reveal file.

4. Enhance Home asset entry points.
   - Add a `Templates` button beside `Examples` and `Assets`.
   - Add a private-use banner and recent/favorite strip to the asset library panel.
   - Improve pack card favorite controls and search/filter behavior.

5. Upgrade Asset Pack Browser.
   - Add inspector chips for counts, author/license/use, private-use scope.
   - Add favorite pack/file controls, recent tracking, image/audio filter, stop audio, and copy path actions.
   - Keep current preview paging so very large packs do not flood the DOM.

6. Improve editor import affordances.
   - Keep existing folder picker flow.
   - Add image preview menu entries for copying absolute/atlas-relative paths.
   - Mark imported preview files recent so Home can surface them.

7. Verify.
   - Run `npm run compile`.
   - Run asset/release validators if feature code touches asset contracts.

## Notes

This pass avoids changing raw asset contents. It makes the app better at using the already-ingested assets and keeps generated/runtime state in browser local storage instead of expanding project settings.
