# AutoDefense

**AutoDefense** (v1.1.0) is a consolidated Windower 4 addon for Final Fantasy XI that manages your defensive gear swaps automatically. It currently handles **Phalanx**, **Cursna**, and **Regen** by inspecting incoming packets to detect spells cast on you from other party members.

## Features

### 🛡️ Auto Phalanx
* **Smart Detection:** Automatically equips `sets.PhalanxReceived` when **Phalanx** or **Phalanx II** is cast on you.
* **AoE Logic:** Intelligent detection for **Accession + Phalanx**. The addon calculates the distance between you and the spell's target. If you are within range (10 yalms) to receive the buff, it swaps your gear.
* **Packet Precision:** Uses advanced sub-parameter detection to distinguish between Phalanx I and II, ensuring reliable triggers even if the server sends generic animation IDs.

### 💚 Auto Regen (Rune Fencer Exclusive)
* **Smart Detection:** Automatically equips `sets.RegenReceived` when **Regen I, II, III, IV, or V** is cast on you.
* **RUN Only:** Because Regen Received gear is highly specific and limited (e.g., Erilaz Earring +1 and Morgelai), the Regen swap logic will **only** trigger if your current main job is Rune Fencer. It will safely ignore Regen casts on all other jobs.
* **AoE Logic:** Fully supports **Accession + Regen** using the same intelligent 10-yalm distance detection.

### 💀 Auto Cursna
* **Doom Safety Check:** Swaps to `sets.CursnaReceived` **ONLY** if you are currently **Doomed**.
    * If you are not Doomed, the addon ignores Cursna casts to prevent unnecessary gear swaps.
* **AoE Support:** Just like Phalanx, it detects **Accession + Cursna** and checks if you are in range and Doomed before swapping.
* **Anti-Spam:** Intelligent timer handling prevents your gear from resetting mid-cast if multiple healers are spamming Cursna on you simultaneously.
* **⚠️ Yagrush Limitation:** If a White Mage uses the Mythic weapon **Yagrush** to make Cursna an AoE, the addon *cannot* predict it if the spell is targeted at another player. Because Yagrush is a passive effect, there is no "Accession" ability used beforehand, meaning the addon has no way to warn your client to swap gear before the spell lands. 

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

