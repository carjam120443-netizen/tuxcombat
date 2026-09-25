# 🐧 Tux Combat

Tux Combat is a small, open-source 2D mascot fighting-game prototype made with Godot.

The goal is to build a fun, original, Linux-and-open-source-themed fighter without copying characters, stages, music, or other protected content from existing commercial fighting games.

## Current prototype

- 🐧 Tux-inspired player character drawn procedurally in Godot
- 🥊 Punch and kick attacks
- 🦘 Jumping, crouching, and side-to-side movement
- ❤️ Health bars
- 🔄 Best-of-3 round system
- 🤖 Simple CPU opponent
- 🎮 Keyboard controls plus basic gamepad support
- 🖥️ 16:9 PC presentation
- 🎨 No external art assets required yet
- 📦 Ready to expand into real sprites, animations, stages, audio, and additional fighters

## Controls

### Player 1

| Action | Keyboard |
|---|---|
| Move | A / D |
| Jump | W |
| Crouch | S |
| Punch | J |
| Kick | K |

A compatible gamepad can also control Player 1 with the left stick/D-pad, A for punch, B for kick, and Y for jump.

### Player 2 / CPU

The second fighter is currently CPU-controlled.

## Run it

1. Install Godot 4.x.
2. Clone this repository.
3. Open the repository as a Godot project.
4. Press **Play Project**.

The prototype intentionally uses procedural drawing and GDScript so the project can run without a large asset download.

## Development stack

- **Godot 4.x** — game engine and 2D renderer
- **GDScript** — gameplay code
- **Git + GitHub** — source control and collaboration
- Optional later tools: Aseprite/Krita for original art, Audacity/LMMS for original audio, and GitHub Actions for automated builds.

Godot provides a dedicated 2D renderer/physics system and supports desktop exports for Windows and Linux.

## Roadmap

### Phase 1 — Playable prototype
- [x] Basic arena
- [x] Tux-inspired fighter
- [x] Movement
- [x] Jump
- [x] Crouch
- [x] Punch
- [x] Kick
- [x] Health
- [x] Rounds
- [x] CPU opponent
- [x] Gamepad input

### Phase 2 — Make it a real game
- [ ] Proper sprite sheets
- [ ] Idle/walk/jump/crouch/attack animations
- [ ] Hit and hurt boxes
- [ ] Better CPU behavior
- [ ] Character select screen
- [ ] Title screen
- [ ] Pause menu
- [ ] Sound effects
- [ ] Original music
- [ ] Multiple arenas
- [ ] Local 2-player mode

### Phase 3 — Content
- [ ] More original/free-to-use characters
- [ ] Character-specific moves
- [ ] Intro and victory animations
- [ ] Training mode
- [ ] Arcade mode
- [ ] Settings
- [ ] Controller remapping
- [ ] Accessibility options

### Phase 4 — Releases
- [ ] Windows build
- [ ] Linux x86_64 build
- [ ] GitHub Releases
- [ ] Automated builds
- [ ] Optional itch.io release
- [ ] Evaluate Steam release later

## Character and asset licensing

Not every mascot or logo on the internet is automatically free to use. Every character, logo, sprite, sound, font, and music track added to the game should have a documented license or permission.

Tux is an image created by Larry Ewing; The Linux Foundation specifically notes that Tux is not owned by The Linux Foundation. Trademark and artwork-use rules can still apply, so this repository does not claim that every Tux or Linux-related asset is freely usable in every context.

See [CHARACTERS.md](CHARACTERS.md) for the project's asset/licensing notes.

For new fighters, prefer:
- Original characters created for this project.
- Public-domain/CC0 assets.
- Clearly licensed assets whose terms allow game distribution.
- Assets with required attribution recorded in the repository.

## Project structure

- main.tscn
- project.godot
- scripts/fighter.gd
- scripts/main.gd
- CHARACTERS.md
- CONTRIBUTING.md
- LICENSE
- .gitignore

## License

The original source code in this repository is released under the MIT License. See LICENSE.

Third-party names, characters, artwork, trademarks, fonts, sounds, and other assets remain subject to their own rights and licenses.

## Status

🚧 Early prototype — expect bugs, placeholder visuals, and rapid changes.

Built as a GitHub-first game project. 🐧💻
