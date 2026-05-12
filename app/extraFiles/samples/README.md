The following files are used here:

 - "Cavernas", a free texture pack by Adam Saltsman (https://adamatomic.itch.io/cavernas)
 - "SunnyLand", a texture pack by Ansimuz (https://ansimuz.itch.io/sunny-land-pixel-game-art)
 - "Inca" by Kronbits (https://kronbits.itch.io/inca-game-assets)
 - "Nuclear Blaze" by Sébastien Benard (https://deepnight.net), under Creative Common Attribution-ShareAlike 4.0 licence (https://creativecommons.org/licenses/by-sa/4.0/)

Additional bundled asset packs live in `atlas/` and are listed in `atlas/assetLibrary.json` so the LDtk home screen can present them as a native asset library. Compatible packs are also exposed from tileset image pickers, entity editor visual pickers, and file path fields such as sound-effect fields.

When adding more packs, keep the files inside `atlas/`, add a representative thumbnail path to `assetLibrary.json`, and fill in `author`, `license`, and `suggestedUse` when available.

Generated contact-sheet previews for the home-screen asset library live in `atlas/_libraryThumbs/`.
