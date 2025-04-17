* **discord: @_x4yz**
# *holding spot for scripts i've made*

# *functioning scripts*
 * [Guts & Blackpowder Script (PC only)](https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/G%26B.luau)
 * [3008 Script (PC and Mobile)](https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/3008.luau)

# *other stuff*
 * [Infinite Yield FOV Plugin](https://github.com/E3LightC/new_holdingspot/blob/main/scripts/FOV_Commands.iy)

 
# *loadstrings*
  ```lua
--//// Feature Overview \\\\--
--// [System Logging]
--//        All failures, errors, warnings, and other information are output to the Roblox Developer Console with standardized tags 
--//   (e.g., "[FAIL # EXAMPLE_CONTEXT]: ...", "[INFO # EXAMPLE_CONTEXT]: ...", "[DEBUG # EXAMPLE_CONTEXT]: ...").
--// [Input Bindings]
--//        [Q]: Triggers a shove action against nearby zombie entities within `ShoveRange`, if the equipped tool supports shoving.
--//        [Z] / [X]: Activates an AoE melee attack, targeting all valid zombie entities within range based on the equipped weapon's parameters.
--//        [G]: Automatically equips a shove-capable tool from the Backpack, if one is available.
--//        [Keypad 1]: Executes a log retrieval action. (Limited to the "Berezina" map.)
--//        [Keypad 2]: Toggles the auto-repair system on or off.
--//        [Keypad 3]: Switches the internal lookup method to identify nearby repairable structures.
--//        [Keypad 4]: Enables or disables "RubiksCube" mode (details below).
--//        [U], [F], [G], [H], [J], [Y], [T]: Triggers playback of a predefined fife or drum song. Song mappings are configurable via the `MusicSelections` table.
--// [Combat Behavior]
--//        All melee attacks are forcibly registered as headshots, applying either the weapon’s specific headshot multiplier 
--//   or a default multiplier of 1.5x for increased damage output.
--// [Visuals / ESP System]
--//        Zombie entities are dynamically highlighted with Roblox's `Highlight` instance based on their classification. 
--//   Colors are pulled from the `ESPColors` table, allowing for consistent team or role-based visual cues. 
--//   Highlighting is gated by tag-checking to prevent redundant application.
--// [Tool Manipulation / Exploit Behavior]
--//        While "RubiksCube" mode is enabled, equipping a hammer or claw hammer forcibly distorts the character’s model 
--//   by repeatedly triggering the `UpdateLook` remote. (Note: this effect is processed server-side.)
--//        Client-fired RemoteEvent calls to `OnAFKSignalReceived` and `ForceKill` are blocked and will not propagate.
--//   (Note: This does not block RemoteEvent calls triggered externally via exploit tools or injection methods.)
--//        Auto-repair requires a hammer-type tool to be equipped. The player’s character position determines the structure's proximity
--//   rather than the tool itself, due to design limitations in tool implementation.

--//// Key Bindings Overview \\\\--
--// [Combat Actions]
--//        [Q]: Executes a shove against nearby zombie entities within `ShoveRange`, if supported by the current tool.
--//        [Z] / [X]: Triggers a kill aura, dealing AoE melee damage to all valid zombies within range based on the equipped weapon.
--//        [G]: Searches the Backpack for a compatible shove-capable tool and equips it automatically.
--// [Utility Actions]
--//        [Keypad 1]: Initiates a log retrieval action. Only available on the **Berezina** map.
--//        [Keypad 2]: Toggles the auto-repair system to automate building repairs.
--//        [Keypad 3]: Switches the targeting method used by auto-repair to locate valid structures.
--//        [Keypad 4]: Toggles **RubiksCube** mode, which scrambles the character model using `UpdateLook` on hammer tools.
--// [Music Controls]
--//        [U], [F], [G], [H], [J], [Y], [T]: Plays predefined musical tracks using either a fife or a drum, depending on the equipped instrument. 
--//				Song mappings can be customized through the `MusicSelections` table.

loadstring(game:HttpGet("https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/G%26B.luau", true))()
  ```
  * Guts & Blackpowder Script
  ```lua
--// 3008 Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/3008.luau", true))()
  ```
