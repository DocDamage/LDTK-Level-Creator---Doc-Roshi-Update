# Asset License Verification

Date: 2026-05-12

This review checks whether the bundled `app/extraFiles/samples/atlas` packs can be redistributed as raw, reusable assets in this public repository. It is not legal advice, but it records the licensing evidence found locally and on public pack pages.

## Result

Most newly imported raw asset packs are **not release-approved for public GitHub distribution**. Several licenses allow use inside a game project, but this repository currently publishes the source PNG/WAV files as an asset library, which is materially closer to redistributing standalone resources.

## Pack Status

| Pack path | Status | Evidence |
| --- | --- | --- |
| `.` | `included-with-upstream-samples` | Original LDtk bundled sample credits. |
| `stages` | `not-release-approved-standalone-source-files` | Contains CraftPix/Free Game Assets style source art. CraftPix allows games with assets, but forbids distributing source art in reusable form. |
| `ansimuz assets` | `partially-release-approved-subassets-need-attribution-review` | Local Ansimuz public-license text allows use, modification, and redistribution for covered art. Retained music/fonts/audio need per-file attribution review. |
| `20000 Icons RPG + Recolors - Full version` | `not-release-approved-redistribution-forbidden` | HoriHori icon page says personal/commercial use is allowed, but redistribution/resale is forbidden. |
| `HoriHori Assets/cards` | `not-release-approved-redistribution-forbidden` | HoriHori cards page uses the same redistribution/resale restriction. |
| `HoriHori Assets/spells` | `not-release-approved-redistribution-forbidden` | HoriHori spells page uses the same redistribution/resale restriction. |
| `HoriHori Assets` | `not-release-approved-redistribution-forbidden` | Same HoriHori bundle family and redistribution/resale restriction. |
| `Spells` | `not-release-approved-standalone-source-files` | CraftPix/Free Game Assets license forbids redistributing source art in reusable form. |
| `CuteSCKR_uncut` | `not-release-approved-standalone-source-files` | Cute SCKR terms allow use in game projects, but prohibit standalone redistribution. |
| `Monster Mega Pack` | `not-release-approved-no-public-redistribution-grant-found` | BattleInkMaps public purchase page confirms a paid raw PNG asset pack; no public raw-file redistribution grant was found. |
| `portraits` | `not-release-approved-standalone-source-files` | CraftPix/Free Game Assets avatar packs use the CraftPix license. |
| `sound effects` | `partially-verified-not-release-approved-mixed-audio` | TomMusic confirms commercial project use with credit. Other retained audio folders still need exact redistribution grants for raw-file publication. |

## Sources Checked

- Local Ansimuz license/readme files:
  - `app/extraFiles/samples/atlas/ansimuz assets/Gothicvania Junk Wasteland Environment/Hurry up and run files/public-license.txt`
  - `app/extraFiles/samples/atlas/ansimuz assets/Gothicvania Cold Corridors/GodotProject/license.pdf`
  - `app/extraFiles/samples/atlas/ansimuz assets/Mountain Dusk Parallax background/Super Mountain Dusk Files/Assets/Version C/layers/public-license.pdf`
  - `app/extraFiles/samples/atlas/ansimuz assets/Underwater Diving/underwater-diving-files/Sound/readme.txt`
- Local TomMusic readme:
  - `app/extraFiles/samples/atlas/sound effects/Free Fantasy SFX Pack By TomMusic/ReadMe.txt`
- Public verification URLs:
  - `https://craftpix.net/file-licenses/`
  - `https://free-game-assets.itch.io/`
  - `https://horihoripixel.itch.io/20000-rpg-icons`
  - `https://horihoripixel.itch.io/12000-rpg-cards`
  - `https://horihoripixel.itch.io/12000-rpg-spells`
  - `https://horihoripixel.itch.io/44000-rpg-icons-cards-spells`
  - `https://comshadow.itch.io/abandoned-hospital-tileset`
  - `https://battleinkmaps.itch.io/monsters-mega-pack/purchase`
  - `https://tommusic.itch.io/free-fantasy-200-sfx-pack/comments`
  - `https://ansimuz.itch.io/gothicvania-cold-corridors`

## Release Recommendation

Do not publish a public release with the non-approved raw asset folders in Git. The safe paths are:

1. Remove non-approved raw asset packs from the repository and replace them with redistributable packs such as CC0, public domain, or explicit open-license assets.
2. Keep only tiny derived thumbnails/starter samples if the source license allows them.
3. Get written redistribution permission from each creator for this exact use case: shipping raw files in a public GitHub repository and app sample asset library.
4. For commercial-use-only licenses, package assets into a non-extractable game/application format only if the license allows that form of distribution.
