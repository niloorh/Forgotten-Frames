# Forgotten Frames

**Forgotten Frames** is a 2D, turn-based roguelike game developed as a project for a university **Game Design & Development** course. Built with **Godot 4.3** and **GDScript**, the game combines tactical movement, enemy encounters, environmental hazards, and progressively challenging stages on a compact grid.

The project explores how a small set of mechanics can create meaningful decisions through turn-based combat, randomized encounters, and unlockable abilities.

## Game Overview

The player enters an **8 × 8 arena** and must defeat every enemy to advance to the next stage. Each action matters: moving, attacking, waiting, or using an ability gives enemies an opportunity to respond. Hazards on the board create additional risks for both the player and enemies.

Each game mode contains **five stages** with changing enemy compositions. The positions of the player, enemies, and hazards are generated at the start of each stage, so encounters vary between attempts.

## Core Gameplay

### Turn-Based Movement and Combat

- Navigate the arena one tile at a time using the arrow keys.
- Attack an adjacent enemy by attempting to move into its occupied tile.
- Choose to skip a turn, allowing enemies to act without moving the player.
- Plan each move around enemy positions, remaining health, and environmental hazards.
- Clear all enemies to progress; losing all health ends the attempt.

### Enemy Behaviors

Three enemy variants implement distinct movement and combat routines. Enemy compositions change from stage to stage, introducing more difficult encounters as the player progresses.

Enemy actions take place after the player's turn. Their movement and attack decisions are handled by separate behavior functions, making the different enemy types easier to inspect and extend.

### Randomized Encounters and Hazards

At the beginning of a stage, the game randomly assigns valid grid positions to the player, enemies, and hazards. Placement checks help avoid conflicting spawns. Hazards damage characters that occupy their positions during turn resolution, adding another tactical consideration to movement and combat.

### Game Modes and Progression

The game provides two difficulty modes:

- **Normal:** Introduces the enemy types across five stages, building up the challenge progressively.
- **Hard:** Uses more demanding enemy combinations across its five stages.

Completing stages leads to the next encounter, while completing a full mode leads to a victory screen. A defeat leads to a game-over screen with navigation back to the main menu.

### Unlockable Abilities

The progression system supports two special attacks:

- **Cross ability:** Damages enemies aligned with the player along the same row or column.
- **Square ability:** Damages enemies in the surrounding 3 × 3 area.

Special abilities are selected from the main menu once unlocked. The game stores completed unlocks locally, allowing access to unlocked difficulty and ability options in later sessions.

## Controls

| Key | Action |
| --- | --- |
| **Arrow keys** | Move one tile or attack an enemy occupying the destination tile |
| **Space** | Pass a turn |
| **Q** | Activate the selected special ability |

## Technical Implementation

The game uses **Godot scenes** for its interface, characters, hazards, stage transitions, and end states. The primary gameplay logic is implemented in GDScript.

Key implementation details include:

- **Grid management:** Coordinates define tile positions, movement limits, adjacency, and occupancy.
- **Turn processing:** Player input triggers movement or combat, followed by enemy actions and game-state checks.
- **Enemy logic:** Dedicated routines handle the three enemy variants.
- **Stage configuration:** Structured data defines enemy compositions for both modes and all five stages.
- **Dynamic spawning:** Random positions are generated for stage entities, with placement validation.
- **Combat and health:** Damage, character defeat, hazard interactions, and stage completion are managed during the game loop.
- **Progress persistence:** Unlock states are serialized as JSON using Godot's `FileAccess` API and stored in `user://forgotten_frames.save`.
- **Scene transitions:** Separate scenes represent the main menu, active game, stage completion, victory, and defeat.


## Development Tools

- **Engine:** Godot 4.3
- **Language:** GDScript
- **Game type:** 2D, turn-based roguelike

