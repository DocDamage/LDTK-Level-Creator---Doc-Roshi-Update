# Doc Roshi bundled asset credits

This document tracks the imported, app-known assets used by the Doc Roshi update. These files live under `app/extraFiles/samples/atlas/` and are referenced by `assetLibrary.json`, starter templates, thumbnails, or sample fields so a fresh checkout can try the update immediately.

Raw source drops and large library folders may remain ignored, but any file referenced by the app manifest or a starter project must stay available in the repository.

## Asset-library packs

| Pack | Repository path | Author / source | License note | Used for |
| --- | --- | --- | --- | --- |
| Classic sample tilesets | `app/extraFiles/samples/atlas/` | LDtk sample artists | See `app/extraFiles/samples/README.md` | Original LDtk sample projects and thumbnails |
| Magic and fantasy stages | `app/extraFiles/samples/atlas/stages/` | Mixed artists | See original files in pack folders | Level themes and generated asset starters |
| Ansimuz environment collection | `app/extraFiles/samples/atlas/ansimuz assets/` | Ansimuz and bundled pack credits | See original license/readme files in pack folders | Side-view and parallax starter material |
| HoriHori icon library | `app/extraFiles/samples/atlas/20000 Icons RPG + Recolors - Full version/` | HoriHori | See original pack terms | RPG icons, item markers, and catalog starters |
| HoriHori card art | `app/extraFiles/samples/atlas/HoriHori Assets/cards/` | HoriHori | See original pack terms | Card, reward, and board-game starter material |
| HoriHori spell effects | `app/extraFiles/samples/atlas/HoriHori Assets/spells/` | HoriHori | See original pack terms | Ability and VFX starter material |
| Elemental spell library | `app/extraFiles/samples/atlas/Spells/` | Mixed artists | See original files in pack folders | Ability, pickup, and effect starter material |
| HoriHori characters and backgrounds | `app/extraFiles/samples/atlas/HoriHori Assets/` | HoriHori | See original pack terms | NPCs, scenes, portraits, and item starter material |
| CuteSCKR tilesets | `app/extraFiles/samples/atlas/CuteSCKR_uncut/` | CuteSCKR | See original pack terms | 78 folder-based tileset starter templates |
| Monster Mega Pack | `app/extraFiles/samples/atlas/Monster Mega Pack/` | BattleInkMaps | See original pack terms | Enemy and encounter starter material |
| Fantasy portraits | `app/extraFiles/samples/atlas/portraits/` | Mixed artists | See original files in pack folders | Dialog, NPC, and party UI starter material |
| Sound effects | `app/extraFiles/samples/atlas/sound effects/` | Mixed artists | See original files in pack folders | Audio file fields and the horror/audio demo |

## Release checks

Before publishing a release from this branch, run:

```powershell
node tools\validate-doc-roshi-assets.js
cd app
npm install
npm run compile
npm run pack-test
```

The validator checks the manifest, starter counts, linked starter samples, thumbnails, featured asset paths, layout grids, marker notes, and generated preview tiles.

## Notes for future imports

When adding more packs:

 - Put app-known assets under `app/extraFiles/samples/atlas/`.
 - Add or update `app/extraFiles/samples/atlas/assetLibrary.json`.
 - Add a representative thumbnail under `app/extraFiles/samples/atlas/_libraryThumbs/` when the pack is visual.
 - Update this credits file with the pack author, source folder, and license note.
 - Run `node tools/validate-doc-roshi-assets.js` before committing.
