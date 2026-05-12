# Asset Library Polish Design

## Goal

Make the bundled asset library feel like a built-in catalog instead of a folder shortcut, while improving the existing import paths for tilesets, entity tiles, and file fields.

## Scope

This pass focuses on the Home asset library cards and the existing picker integrations. It does not add a full per-file gallery, audio player, or thumbnail browser inside every pack. Those are larger features that can build on the metadata helpers added here.

## User Experience

The Home asset library should show richer cards with clear pack type, file count, useful extensions, suggested use, author, and license. Users should be able to search across these details and filter by pack kind. Pack menus should remain fast and familiar, but they should expose actions that match the pack: browse/copy/reveal for all packs, and import-oriented actions for packs that contain supported images or audio.

Tileset, entity tile, and file-field pickers should label bundled library choices consistently and show enough metadata for users to choose a pack without opening every folder manually.

## Architecture

`AssetLibrary.hx` remains the single helper for locating the bundled atlas folder, reading the manifest, deriving file extensions, and determining pack capabilities. `Home.hx` uses that helper to render richer cards and build action-oriented context menus. Existing import hooks in `EditTilesetDefs.hx`, `EditEntityDefs.hx`, and `FieldInstancesForm.hx` keep their current structure, with clearer labels and metadata from `AssetLibrary`.

## Data Flow

The manifest provides stable pack metadata. Runtime helpers derive extensions by scanning pack folders and cache those results during the session. UI code reads pack metadata, renders searchable card attributes, and filters cards by kind and free-text query. Picker menus use the same helper methods to show only packs that match accepted file types.

## Error Handling

Missing library folders, missing manifests, empty manifests, missing thumbnails, and unreadable packs continue to degrade gracefully. If a pack folder cannot be scanned for extensions, the UI should still show the manifest metadata and avoid crashing.

## Testing

Compile both renderer and main Haxe targets. Validate the manifest still resolves every pack path and thumbnail. Run a quick status check to confirm the intentionally ignored oversized WAV stays untracked and the MP3 replacement remains tracked.
