# AutoDefense

**AutoDefense** (v1.1.0) is a consolidated Windower 4 addon for Final Fantasy XI that manages your defensive gear swaps automatically. It currently handles **Phalanx**, **Cursna**, and **Regen** by inspecting incoming packets to detect spells cast on you from other party members.

## Features

### 🛡️ Auto Phalanx
* **Smart Detection:** Automatically equips `sets.PhalanxReceived` when **Phalanx** or **Phalanx II** is cast on you.
* **AoE Logic:** Intelligent detection for **Accession + Phalanx**. The addon calculates the distance between you and the spell's target. If you are within range (10 yalms) to receive the buff, it swaps your gear.
* **Packet Precision:** Uses advanced sub-parameter detection to distinguish between Phalanx I and II, ensuring reliable triggers even if the server sends generic animation IDs.

### 💚 Auto Regen (Rune Fencer Exclusive)
* **Smart Detection:** Automatically equips `sets.RegenReceived` when **Regen I, II, III, IV, or V** is cast on you.
* **RUN Only:** Because received-Regen potency gear is highly specific and limited (e.g., Erilaz Earring +1, Morgelai), the Regen swap logic will **only** trigger if your current main job is Rune Fencer. It will safely ignore Regen casts on all other jobs.
* **AoE Logic:** Fully supports **Accession + Regen** using the same intelligent 10-yalm distance detection.

### 💀 Auto Cursna
* **Doom Safety Check:** Swaps to `sets.CursnaReceived` **ONLY** if you are currently **Doomed**.
    * If you are not Doomed, the addon ignores Cursna casts to prevent unnecessary gear swaps.
* **AoE Support:** Just like Phalanx, it detects **Accession + Cursna** and checks if you are in range and Doomed before swapping.
* **Anti-Spam:** Intelligent timer handling prevents your gear from resetting mid-cast if multiple healers are spamming Cursna on you simultaneously.

### ⚡ Shared Features
* **Priority Execution:** Always prioritizes survival over mitigation or recovery. If multiple spells land simultaneously, the swap priority is: **Cursna > Phalanx > Regen**.
* **Party Requirement:** To save resources, the logic **only** runs when you are in a party. If you are Solo, the addon stays dormant.
* **Auto-Reset:** Automatically sends a command to your GearSwap to reset your gear 4 seconds after the last spell is detected.
* **Self-Cast Safety:** Ignores your own casting to prevent conflicts with GearSwap's standard midcast logic.

---

## Installation
1.  Create a folder named `AutoDefense` inside your Windower `addons` directory:
    `.../Windower4/addons/AutoDefense/`
2.  Place `AutoDefense.lua` into this folder.

## Configuration (Addon Side)
Open `AutoDefense.lua` in a text editor. Look for the configuration section at the top:

```lua
local phalanx_cmd = 'gs equip sets.PhalanxReceived'
local cursna_cmd  = 'gs equip sets.CursnaReceived'
local regen_cmd   = 'gs equip sets.RegenReceived'
```

* **Note on Case Sensitivity:** Ensure `sets.PhalanxReceived`, `sets.CursnaReceived`, and `sets.RegenReceived` match the exact capitalization of the sets in your GearSwap file.

---

## ⚠️ GearSwap Integration (Required) ⚠️

For the **Auto-Reset** feature to work (returning you to your Tank/Idle set after the spell lands), you **MUST** add a specific command handler to your GearSwap file (e.g., `run.lua`).

### 1. Define Your Sets
Ensure these sets exist in your `get_sets()` function:

```lua
sets.PhalanxReceived = {
    -- Your Phalanx received gear (Taeon, Herculean, etc.)
}

sets.CursnaReceived = {
    ring1="Purity Ring",
    waist="Gishdubar Sash",
    legs="Shabti Cuisses +1",
    -- Any other gear that improves Cursna success rate
}

sets.RegenReceived = {
    right_ear="Erilaz Earring +1",
    -- Any other received Regen gear
}
```

### 2. Update `self_command`
Find the function named `self_command(command)` in your job Lua and add the `update` block:

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
The addon sends `gs c update` to tell your client "The spell is done, put my normal gear back on." If your `self_command` function does not explicitly listen for `'update'`, your gear will get stuck in the defensive set.

---

## Usage
Load the addon in-game:
```text
//lua l AutoDefense
```

### Testing
1.  **Join a Party:** The addon will not trigger if you are Solo.
2.  **Phalanx Test:** Have a party member cast Phalanx on you. Your gear should swap to `sets.PhalanxReceived`.
3.  **Regen Test:** Ensure you are on Rune Fencer (RUN). Have someone cast Regen on you. Your gear should swap to `sets.RegenReceived`. (If you are on any other job, nothing should happen).
4.  **Cursna Test:**
    * **Normal:** Have someone cast Cursna on you while you are healthy. **Nothing should happen.**
    * **Doomed:** Get Doomed (e.g., from a spell or ability). Have someone cast Cursna. Your gear should swap to `sets.CursnaReceived`.

## Requirements
* Windower 4
* `resources` library (Standard)

## Copyright
**Copyright (c) 2026 Voliathon**
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.


2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
