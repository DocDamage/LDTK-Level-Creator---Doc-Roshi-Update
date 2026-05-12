The following files are used here:

 - "Cavernas", a free texture pack by Adam Saltsman (https://adamatomic.itch.io/cavernas)
 - "SunnyLand", a texture pack by Ansimuz (https://ansimuz.itch.io/sunny-land-pixel-game-art)
 - "Inca" by Kronbits (https://kronbits.itch.io/inca-game-assets)
 - "Nuclear Blaze" by Sébastien Benard (https://deepnight.net), under Creative Common Attribution-ShareAlike 4.0 licence (https://creativecommons.org/licenses/by-sa/4.0/)

Additional bundled asset packs live in `atlas/` and are listed in `atlas/assetLibrary.json` so the LDtk home screen can present them as a native asset library. Compatible packs are also exposed from tileset image pickers, entity editor visual pickers, and file path fields such as sound-effect fields.

When adding more packs, keep the files inside `atlas/`, add a representative thumbnail path to `assetLibrary.json`, and fill in `author`, `license`, and `suggestedUse` when available.

Generated contact-sheet previews for the home-screen asset library live in `atlas/_libraryThumbs/`.

## Doc Roshi asset starter update

This branch adds a large bundled starter library on top of the original LDtk samples:

 - `Doc_Roshi_Asset_*.ldtk`: 151 asset-pack starter projects generated from the bundled `atlas/` folders.
 - `Doc_Roshi_CuteSCKR_*.ldtk`: 78 CuteSCKR starter projects, one for each imported CuteSCKR folder.
 - Other `Doc_Roshi_*.ldtk` templates: RPG room, platformer, top-down, and horror/audio demo samples.

The Home screen exposes these as sample templates with filters for environments, catalog/UI assets, characters, audio, CuteSCKR, and core examples. The Asset Library also links matching packs back to their starter templates, so a user can browse an asset pack and open a ready-to-edit LDtk project from the same place.

The starter projects intentionally reference imported, app-known assets under `atlas/`. The raw source folders can remain ignored, but the assets referenced by `assetLibrary.json`, sample thumbnails, and the LDtk starter files must stay available in the repository so a fresh checkout can open the templates immediately.

Run `node tools/validate-doc-roshi-assets.js` from the repository root after regenerating or importing assets. The check validates the bundled asset manifest, thumbnails, linked starter samples, FeaturedAsset paths, marker notes, layout grids, and generated preview tiles.
