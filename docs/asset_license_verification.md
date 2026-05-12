# Asset License Verification

Date: 2026-05-12

This review checks whether the bundled `app/extraFiles/samples/atlas` packs can be used privately and whether they can be redistributed publicly as raw, reusable assets. It is not legal advice, but it records the licensing evidence found locally and on public pack pages.

## Result

For a private/personal-use project, the imported packs can stay in a private repository for local prototyping. They are **not approved for public raw-asset redistribution** unless explicit creator permission is obtained. Several licenses allow use inside a game project, but publishing the source PNG/WAV files as an asset library is materially closer to redistributing standalone resources.

## Pack Status

| Pack path | Status | Evidence |
| --- | --- | --- |
| `.` | `included-with-upstream-samples` | Original LDtk bundled sample credits. |
| `stages` | `private-use-only-public-raw-redistribution-not-approved` | Private project use is acceptable; CraftPix allows games with assets, but forbids distributing source art in reusable form. |
| `ansimuz assets` | `private-use-ok-public-subassets-need-attribution-review` | Private project use is acceptable. Local Ansimuz public-license text allows use, modification, and redistribution for covered art. Retained music/fonts/audio need per-file attribution review before public redistribution. |
| `20000 Icons RPG + Recolors - Full version` | `private-use-only-public-redistribution-forbidden` | Private project use is acceptable; HoriHori icon page says personal/commercial use is allowed, but redistribution/resale is forbidden. |
| `HoriHori Assets/cards` | `private-use-only-public-redistribution-forbidden` | Private project use is acceptable; HoriHori cards page uses the same redistribution/resale restriction. |
| `HoriHori Assets/spells` | `private-use-only-public-redistribution-forbidden` | Private project use is acceptable; HoriHori spells page uses the same redistribution/resale restriction. |
| `HoriHori Assets` | `private-use-only-public-redistribution-forbidden` | Private project use is acceptable; same HoriHori bundle family and redistribution/resale restriction. |
| `Spells` | `private-use-only-public-raw-redistribution-not-approved` | Private project use is acceptable; CraftPix/Free Game Assets license forbids redistributing source art in reusable form. |
| `CuteSCKR_uncut` | `private-use-only-public-raw-redistribution-not-approved` | Private project use is acceptable; Cute SCKR terms allow use in game projects, but prohibit standalone redistribution. |
| `Monster Mega Pack` | `private-use-only-no-public-redistribution-grant-found` | Private project use is acceptable if legitimately obtained; no public raw-file redistribution grant was found. |
| `portraits` | `private-use-only-public-raw-redistribution-not-approved` | Private project use is acceptable; CraftPix/Free Game Assets avatar packs use the CraftPix license. |
| `sound effects` | `private-use-ok-public-mixed-audio-not-fully-verified` | Private project use is acceptable. TomMusic confirms commercial project use with credit. Other retained audio folders still need exact redistribution grants for raw-file publication. |

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

## Repository Recommendation

Keep this repository private while it contains the imported raw asset packs. The app can continue to be used privately and personally. Do not publish a public release, public source repo, or public downloadable build containing the non-approved raw asset folders unless one of these is true:

1. Remove non-approved raw asset packs from the repository and replace them with redistributable packs such as CC0, public domain, or explicit open-license assets.
2. Keep only tiny derived thumbnails/starter samples if the source license allows them.
3. Get written redistribution permission from each creator for this exact use case: shipping raw files in a public GitHub repository and app sample asset library.
4. For commercial-use-only licenses, package assets into a non-extractable game/application format only if the license allows that form of distribution.
