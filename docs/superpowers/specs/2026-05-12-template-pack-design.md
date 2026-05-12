# Bundled Template Pack Design

## Goal

Add multiple sample projects that demonstrate the newly bundled asset library as ready-to-use LDtk templates.

## Samples

The pack will add four small projects under `app/extraFiles/samples`:

- `Doc_Roshi_RPG_Room.ldtk`: a compact room template using RPG-friendly visual assets and entity placeholders.
- `Doc_Roshi_Platformer_Template.ldtk`: a side-view level template for platformer prototyping.
- `Doc_Roshi_TopDown_Template.ldtk`: a top-down map template for exploration or dungeon layouts.
- `Doc_Roshi_Horror_Audio_Demo.ldtk`: a horror-themed layout with file fields pointing at bundled audio assets, including the MP3 replacement for the oversized WAV.

Each sample gets a matching `app/extraFiles/samples/thumbs/*.png` thumbnail so it appears properly on the Home examples shelf.

## Scope

These are starter templates, not finished games. They should load quickly, use relative asset paths into `atlas`, and show the asset library as part of the app experience. The templates should avoid huge embedded data and should not duplicate raw assets.

## Architecture

The templates will be generated as normal LDtk project JSON files using the existing sample format. They will use internal LDtk definitions for layers, entities, fields, and tilesets. Asset references will point to the bundled atlas folder using sample-relative paths, so cloning the GitHub repo is enough to open them.

## Verification

Verify each project is valid JSON and includes matching thumbnail files. Compile renderer and main Haxe targets to ensure the sample shelf code still builds. Confirm the oversized original WAV stays ignored and the MP3 audio reference is tracked.
