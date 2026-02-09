# AutoPhalanx

**AutoPhalanx** (v1.1.0) is a Windower 4 addon for Final Fantasy XI that automatically equips your Phalanx received-damage-reduction gear when a party member casts **Phalanx** (or **Accession + Phalanx**) on you.

It intelligently calculates AoE range, supports custom spell IDs (like Phalanx II), and automatically resets your gear after the spell lands.

## Features
* **Smart Detection:** Swaps gear when someone casts Phalanx directly on you.
* **AoE Logic:** Detects **Accession + Phalanx**. It calculates if you are within range (10 yalms) of the spell's target before swapping, preventing unnecessary swaps.
* **Auto-Reset:** Automatically sends a command to your GearSwap to reset your gear 4 seconds after the cast is detected.
* **Self-Cast Safety:** Ignores your own casting to prevent conflicts with GearSwap's standard midcast logic.

## Installation
1.  Create a folder named `AutoPhalanx` inside your Windower `addons` directory:
    `.../Windower4/addons/AutoPhalanx/`
2.  Place `AutoPhalanx.lua` into this folder.

## Configuration (Addon Side)
Open `AutoPhalanx.lua` in a text editor. Look for the configuration section at the top:

```lua
local phalanx_command = 'gs equip sets.Phalanx'
```

* **Note on Case Sensitivity:** Ensure `sets.Phalanx` matches the exact capitalization of the set in your GearSwap file (e.g., `sets.Phalanx` vs `sets.phalanx`).

---

## ⚠️ GearSwap Integration (Required) ⚠️

For the **Auto-Reset** feature to work (returning you to your Tank/Idle set after the spell lands), you **MUST** add a specific command handler to your GearSwap file (e.g., `run.lua`).

1.  Open your Job Lua file (e.g., `run.lua`).
2.  Find the function named `self_command(command)`.
3.  Add the following `elseif` block to handle the `update` trigger:

```lua
function self_command(command)
    -- ... your existing commands (C8, C9, etc.) ...

    -- ADD THIS BLOCK:
    elseif command == 'update' then
        equip_current() -- Or whatever function resets your gear
        send_command('@input /echo <----- GearSwap Update Triggered ----->')
    end
end
```

**Why is this needed?**
The addon sends `gs c update` to tell your client "The spell is done, put my normal gear back on." If your `self_command` function does not explicitly listen for `'update'`, your gear will get stuck in the Phalanx set.

---

## Usage
Load the addon in-game:
```text
//lua l AutoPhalanx
```

### Testing
1.  Have a party member cast **Phalanx** on you.
2.  Your gear should swap to `sets.Phalanx`.
3.  After 4 seconds, your gear should automatically swap back to your Idle/Engaged set.

## Requirements
* Windower 4
* `packets` library (Standard)
* `resources` library (Standard)
