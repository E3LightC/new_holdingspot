* **discord: @_x4yz**
# *holding spot for scripts i've made*

# *functioning scripts*
 * [Guts & Blackpowder Script (PC only)](https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/G%26B.luau)
 * [3008 Script (PC and Mobile)](https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/3008.luau)

# *other stuff*
 * [Infinite Yield FOV Plugin](https://github.com/E3LightC/new_holdingspot/blob/main/scripts/FOV_Commands.iy)

 
# *loadstrings*
  ```lua
--//// Discord: @_x4yz \\\\--
--// https://www.roblox.com/games/12334109280/Guts-Blackpowder
--//    Made with Wave. https://getwave.gg | This script should work with most executors, as most of it is standard Roblox Luau.
--//    Each function has a description if whoever is reading this is curious about what they do.
--//    * This script is entirely made from boredom and my passion for exploiting/pen-testing! *
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--//// Recent Changes \\\\--
--//        Updated ESP System to also add highlights to the new "Cuirassier" zombie type, which was recently seen in action in G&B's new playtest, 
--//   and has multiple variants sitting inside the G&B Dev Zone.
--//        Changed "Feature Overview" and "Key Bindings Overview" to be more technical.
--//        More debugging/logging features, also utilizing G&B's "ClientSubtitles" BindableEvent.
--//        Removed Rubik's cube bind [Keypad 4], and replaced with a key bind to that enable or disable if "Barrel" zombies can be attacked.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--//// Feature Overview \\\\--
--// [System Logging]
--//        All failures, errors, warnings, and other information are output to the Roblox Developer Console; also look out for outputs with standardized tags.
--//   (e.g., "[FAIL # EXAMPLE_CONTEXT]: ...", "[INFO # EXAMPLE_CONTEXT]: ...", "[DEBUG # EXAMPLE_CONTEXT]: ...").
--// [Input Bindings]
--//        [Q] — Shove nearby agents (if tool allows) (ignores "Barrel" agents).
--//        [Z] / [X] — AoE melee attack with current weapon.
--//        [G] — Auto-equip shove-capable tool from Backpack.
--//        [Numpad 1] — Retrieve logs (Berezina map only).
--//        [Numpad 2] — Toggle auto-repair system.
--//        [Numpad 3] — Switch auto-repair targeting mode.
--//        [Numpad 4] — Allow/disallow "Barrel" agents targeting.
--//        [U], [F], [G], [H], [J], [Y], [T]: Triggers playback of a predefined fife or drum song. Song mappings are configurable via the `MusicSelections` table.
--// [Combat Behavior]
--//        All melee attacks are forcibly registered as headshots, in which the base melee module that controls said weapon on the server side will apply either the weapon’s specific headshot multiplier 
--//   or a default multiplier of 2.3x for increased damage output.
--// [Visuals / ESP System]
--//        Agents are highlighted using Roblox's `Highlight` based on type, with colors from `ESPColors`. 
--//   Tags prevent redundant highlights.
--// [Tool Manipulation / Exploit Behavior]
--//        RemoteEvents `OnAFKSignalReceived` and `ForceKill` are locally blocked (external exploit calls not affected).
--//        Auto-repair uses a hammer tool and checks character proximity, not the tool’s proximity when repairing structures.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--//// Key Bindings Overview \\\\--
--// [Combat]
--//        [Q] — Shove nearby agents (if tool allows).
--//        [Z] / [X] — AoE melee attack.
--//        [G] — Auto-equip shove-capable tool from Backpack.
--// [Utility]
--//        [Numpad 1] — Retrieve logs (Berezina map only).
--//        [Numpad 2] — Toggle auto-repair system.
--//        [Numpad 3] — Switch auto-repair targeting mode.
--//        [Numpad 4] — Allow/disallow "Barrel" zombie targeting.
--// [Music]
--//        [U, F, G, H, J, Y, T] — Play fife/drum songs; mapped via `MusicSelections`.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

loadstring(game:HttpGet("https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/G%26B.luau", true))()
  ```
  * Guts & Blackpowder Script
  ```lua
--// 3008 Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/3008.luau", true))()
  ```
