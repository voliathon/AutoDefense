# AutoPhalanx

**AutoPhalanx** (v1.0.1) is a Windower 4 addon for Final Fantasy XI that automatically equips your Phalanx received-damage-reduction gear when a party member casts **Phalanx** (or **Accession + Phalanx**) on you.

## Features
* **Direct Detection:** Swaps gear when someone casts Phalanx directly on you.
* **AoE Logic:** Intelligently detects **Accession + Phalanx**. It calculates if you are within range (10 yalms) of the spell's target before swapping, preventing unnecessary swaps when you are out of range.
* **Self-Cast Safety:** Ignores your own casting to prevent conflicts with GearSwap's standard midcast logic.

## Installation
1.  Create a folder named `AutoPhalanx` inside your Windower `addons` directory:
    `.../Windower4/addons/AutoPhalanx/`
2.  Place `AutoPhalanx.lua` into this folder.

## Configuration
Open `AutoPhalanx.lua` in a text editor (like Notepad++ or VS Code). Look for the **CONFIGURATION** section at the top:

```lua
local phalanx_command = 'gs equip sets.Phalanx'
```

* **If you use GearSwap:** Change `'gs equip sets.Phalanx'` to match the specific set name in your Lua file (e.g., `sets.midcast.Phalanx` or `sets.engaged.Phalanx`).
* **If you use in-game macros:** Change it to an input command, such as:
    `local phalanx_command = 'input /equipset 10'`

## Usage
Load the addon in-game:
```text
//lua l AutoPhalanx
```

### Testing
1.  Have a Scholar party member use **Accession**.
2.  Have them cast **Phalanx** on themselves while you are standing nearby.
3.  You should see a chat message: `[AutoPhalanx] AoE Phalanx incoming! Swapping gear.` and your gear will swap immediately.

## Requirements
* Windower 4
* `packets` library (Standard with Windower)

* `resources` library (Standard with Windower)
