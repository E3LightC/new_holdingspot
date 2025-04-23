--//// Discord: @_x4yz \\\\--
--// https://www.roblox.com/games/12334109280/Guts-Blackpowder
--//    Made with Wave. https://getwave.gg
--//    Each function has a description if whoever is reading this is curious about what they do.
--//    * This script is entirely made from boredom and my passion for exploiting/pen-testing! *
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--//// Recent Changes \\\\--
--//        Updated ESP System to also add highlights to the new "Cuirassier" zombie type, which was recently seen in action in G&B's new playtest, 
--//   and has multiple variants sitting inside the G&B Dev Zone.
--//        Changed "Feature Overview" and "Key Bindings Overview" to be more technical.
--//        Added new keybind: [Keypad 5]: Enables or disables if "Barrel" zombies can be attacked.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--//// Feature Overview \\\\--
--// [System Logging]
--//        All failures, errors, warnings, and other information are output to the Roblox Developer Console with standardized tags 
--//   (e.g., "[FAIL # EXAMPLE_CONTEXT]: ...", "[INFO # EXAMPLE_CONTEXT]: ...", "[DEBUG # EXAMPLE_CONTEXT]: ...").
--// [Input Bindings]
--//        [Q]: Triggers a shove action against nearby agents within `ShoveRange`, if the equipped tool supports shoving.
--//        [Z] / [X]: Activates an AoE melee attack, targeting all valid agents within a range based on the equipped weapon's parameters.
--//        [G]: Automatically equips a shove-capable tool from the Backpack, if one is available.
--//        [Keypad 1]: Executes a log retrieval action. (Limited to the "Berezina" map.)
--//        [Keypad 2]: Toggles the auto-repair system on or off.
--//        [Keypad 3]: Switches the internal lookup method to identify nearby repairable structures.
--//        [Keypad 4]: Enables or disables "RubiksCube" mode (details below).
--//        [Keypad 5]: Enables or disables if "Barrel" zombies can be attacked.
--//        [U], [F], [G], [H], [J], [Y], [T]: Triggers playback of a predefined fife or drum song. Song mappings are configurable via the `MusicSelections` table.
--// [Combat Behavior]
--//        All melee attacks are forcibly registered as headshots, in which the weapon script that controls said weapon will apply either the weapon’s specific headshot multiplier 
--//   or a default multiplier of 1.5x for increased damage output.
--// [Visuals / ESP System]
--//        Agents are dynamically highlighted with Roblox's `Highlight` instance based on their classification. 
--//   Colors are pulled from the `ESPColors` table, allowing for consistent team or role-based visual cues. 
--//   Highlighting is gated by tag-checking to prevent redundant application.
--// [Tool Manipulation / Exploit Behavior]
--//        When "RubiksCube" mode is active, the script hooks into the `__namecall` metamethod on `game`. 
--//   Any client-side RemoteEvent call where the first argument is `"UpdateLook"` will have its parameters dynamically scrambled 
--//   before being sent. This results in visible character distortion effects, processed server-side.
--//        RemoteEvent calls to `OnAFKSignalReceived` and `ForceKill` are intercepted and blocked locally, 
--//   preventing them from reaching the server.
--//   (Note: This does not stop RemoteEvent calls initiated via external exploit tools.)
--//        The auto-repair feature requires a hammer tool to be equipped. Structural proximity is calculated 
--//   based on the character’s position, not the tool itself, due to how it is implemented.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

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
--//        [Keypad 5]: Enables or disables if "Barrel" zombies can be attacked.
--// [Music Controls]
--//        [U], [F], [G], [H], [J], [Y], [T]: Plays predefined musical tracks using either a fife or a drum, depending on the equipped instrument. 
--//				Song mappings can be customized through the `MusicSelections` table.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--[///////////////////////////////////////////////////////////////////////////////////////////////////]--
--[///////////////////////////////////////////////////////////////////////////////////////////////////]--
--[///////////////////////////////////////////////////////////////////////////////////////////////////]--

local OldTick = tick()

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInputService = game:GetService("UserInputService")

local CanUseHookMetamethod:boolean = (typeof(hookmetamethod) == "function")
if not CanUseHookMetamethod then
	warn("[WARNING]: Your executor does not support 'hookmetamethod'. The script will still run, but the hooking functionality will not execute.")
end
local CanUseGetNameCallMethod:boolean = (typeof(getnamecallmethod) == "function")
if CanUseHookMetamethod and not CanUseGetNameCallMethod then
	warn("[WARNING]: Your executor does not support 'getnamecallmethod'. The script will still run, but the hooking functionality will not execute.")
end

--// Types for silencing warnings.
type VectorLibrary = { 
	create: (x:number, y:number, z:number) -> Vector3;
	magnitude: (vec:Vector3) -> number;
	normalize: (vec:Vector3) -> Vector3;
	cross: (vec1:Vector3, vec2:Vector3) -> Vector3;
	dot: (vec1:Vector3, vec2:Vector3) -> number;
	angle: (vec1:Vector3, vec2:Vector3, axis:Vector3) -> number;
	floor: (vec:Vector3) -> Vector3;
	ceil: (vec:Vector3) -> Vector3;
	abs: (vec:Vector3) -> Vector3;
	sign: (vec:Vector3) -> Vector3;
	clamp: (vec:Vector3, min:Vector3, max:Vector3) -> Vector3;
	max: (any:Vector3) -> Vector3;
	min: (any:Vector3) -> Vector3;

	zero: (Vector3);
	one: (Vector3);
}
type DebugLibrary = {
	info: (level:number, options:string) -> any
}
--//

local vector:VectorLibrary = (getfenv().vector) --// Since Wave doesn't have Lua's global "vector" class?
local debug:DebugLibrary = (getfenv().debug) --// Since debug.info isn't registered for some reason?

--[=[
    Description:
    Waits for a child of a specific class type (`ClassName`) to appear under the given parent (`Parent`) instance. The function continuously checks for the child and optionally accepts a timeout value to limit the wait duration. If no valid child is found, it returns `nil`. Provides detailed logging for invalid input and early termination scenarios.

    Parameters:
    - `Parent: Instance`: The parent instance under which the child is expected to exist.
    - `ClassName: string`: The class type of the child instance to wait for.
    - `TimeOut: number?` (optional): The maximum number of seconds to wait for the child to appear. Defaults to indefinite waiting if not provided.

    Returns:
    - `Instance | nil`: The first child instance of the specified class type, or `nil` if not found within the timeout period or if inputs are invalid.

    Features:
    - **Flexible Timeout**: Allows indefinite or constrained waiting based on the provided `TimeOut`.
    - **Dynamic Validation**:
      - Ensures that `Parent` is a valid instance and `ClassName` is a string.
      - Handles cases where the parent instance is destroyed or invalid during the wait.
    - **Logging and Debugging**:
      - Logs errors for invalid parameters.
      - Provides informational messages if the wait is terminated early (e.g., parent instance invalidated or timeout reached).

    Notes:
    - Uses `FindFirstChildWhichIsA` for efficient child type detection.
    - Can operate without a timeout for cases requiring indefinite waiting.
    - Ensures compatibility with dynamically changing instance hierarchies.

    Example Usage:
    ```lua
    local Parent = workspace
    local ClassName = "Model"
    local TimeOut = 5

    local FoundChild = WaitForChildWhichIsA(Parent, ClassName, TimeOut)
    if FoundChild then
        print("Found child of type", ClassName)
    else
        print("No child of type", ClassName, "found within the timeout.")
    end
    ```

    Edge Cases:
    - Logs a warning and returns `nil` if `Parent` is not an instance or `ClassName` is not a string.
    - Terminates early and logs information if the parent is invalidated during the wait.
    - Honors the timeout if provided, even if the parent instance remains valid.

]=]
local function WaitForChildWhichIsA(Parent:Instance, ClassName:string, TimeOut:number?):(Instance | nil | any)
	if (typeof(Parent) == "Instance") and (type(ClassName) == "string") then
		local InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
		if InstanceToReturn then
			return InstanceToReturn
		end

		local UseTimeOut = (type(TimeOut) == "number")
		local EndedEarly:boolean = false
		local TimeOutWasReached:boolean = false

		if not UseTimeOut then
			repeat
				task.wait()

				if not Parent or not Parent.Parent then
					EndedEarly = true
					break
				end

				InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
			until ((typeof(InstanceToReturn) == "Instance") or EndedEarly or not Parent or not Parent.Parent)
		else
			local AbsTimeOut:number = math.abs(TimeOut or 1)
			local StartTime:number = os.clock()

			repeat
				task.wait()

				if ((os.clock() - StartTime) >= AbsTimeOut) then
					TimeOutWasReached = true
					EndedEarly = true
					break
				end
				if not Parent or not Parent.Parent then
					EndedEarly = true
					break
				end

				InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
			until ((typeof(InstanceToReturn) == "Instance") or EndedEarly or (os.clock() - StartTime) >= AbsTimeOut)
		end

		if EndedEarly then
			local StringToOutput:string = ("[INFO # WaitForChildWhichIsA]: Loop was ended early due to %s")

			if UseTimeOut then
				if TimeOutWasReached then
					StringToOutput = StringToOutput:format("the time out being reached.")
				elseif not TimeOutWasReached then
					StringToOutput = StringToOutput:format(`the "Parent" property of the "Parent" parameter being invalid.`)
				end
			else
				StringToOutput = StringToOutput:format(`the "Parent" property of the "Parent" parameter being invalid.`)
			end

			print(StringToOutput)
		end

		return InstanceToReturn
	else
		if (typeof(Parent) ~= "Instance") then
			warn(`[FAIL # WaitForChildWhichIsA]: "Parent" parameter is not an Instance.`)
			return nil
		end
		if (type(ClassName) ~= "string") then
			warn(`[FAIL # WaitForChildWhichIsA]: "ClassName" parameter is not a string.`)
			return nil
		end
	end

	return nil
end

local OldNameCall = nil
local OldIndex = nil

if not Players.LocalPlayer then
	repeat
		task.wait()
	until Players.LocalPlayer
end
local LocalPlayer:Player = Players.LocalPlayer
local Backpack:Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))::Backpack

local Remotes:Folder = (ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", math.huge))::Folder
local AFKSignal:RemoteEvent = (Remotes:FindFirstChild("OnAFKSignalReceived") or Remotes:WaitForChild("OnAFKSignalReceived", math.huge))::RemoteEvent

local ZombiesFolder:Folder = (Workspace:FindFirstChild("Zombies") or Workspace:WaitForChild("Zombies", math.huge))::Folder
local BotsFolder:Folder = (Workspace:FindFirstChild("Bots") or Workspace:WaitForChild("Bots", 2))::Folder
local BuildingsFolder:Folder = (Workspace:FindFirstChild("Buildings") or Workspace:WaitForChild("Buildings", math.huge))::Folder
local Camera:Camera = (Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera"))::Camera

local Debug:boolean = true
local DebugPrints:boolean = false
local UseVectorLibrary:boolean = true

local RubiksCube:boolean = false

local CanRepair:boolean = true
local BuildingBindEnabled:boolean = false
local HammerCanWarn:boolean = true
local BuildingFetchType:string = "Closest"
local HammerWarnDelay = 1.5
local WaitTimeUntilRepair = 0.125

local DefaultBeatWaitTime:number = 0.15
local ZombieESPWait:number = 0.25

local LastBeatTick:number = 0
local _TimeSinceLastBeat:number = 0

local ShoveRange:number = 15 --// default range variable used for shoving.
local MurderRange:number = 11 --// Used as a backup if can't find weapon range.

local HeadSizeToUse:Vector3 = (UseVectorLibrary and vector.create(6, 9, 4.5)) or Vector3.new(6, 9, 4.5)
local HeadTransparency:number = 0.6

local PreferredWeapon:string = "Pike"
--// true = Ignore Agent
--// false = Include Agent
local AgentTypeList = {
	["Barrel"] = true;
	["BigBoy"] = false;
	["Crawler"] = false;
	["Fast"] = false;
	["Igniter"] = false;
	["Normal"] = false;
	["Sapper"] = false;
	["Bot"] = false;
	["Headless"] = false;
	["Cuirassier"] = false;
}
local AllowedInstruments = {
	["Fife"] = true; --// Plays music while in the backpack and still provides/gains buffs.
	["Drum"] = true; --// Only plays music while equipped by the character.
}
local MusicSelections = {
	["U"] = "Musketer March";
	["F"] = "Bjorneborgarnas Marsch";
	["G"] = "Free America";
	["H"] = "Mazurek D\196\133browskiego";
	["J"] = "Kalina Malina";
	["Y"] = "Kolonni Idushej Ataku";
	["T"] = "Marsh Preobrazhenskogo polka";
}
local ESPColors = {
	["Igniter"] = Color3.fromRGB(255, 255, 0);
	["Runner"] = Color3.fromRGB(0, 255, 255);
	["Sapper"] = Color3.fromRGB(255, 0, 255);
	["Bomber"] = Color3.fromRGB(255, 123, 0);
	["Headless"] = Color3.fromRGB(100, 0, 167);
	["Cuirassier"] = Color3.fromRGB(35, 77, 255);

	["Backup"] = Color3.fromRGB(14, 16, 168);
}
setmetatable(ESPColors, {
	__index = function()
		return ESPColors["Backup"]
	end
})

--// Disconnection/Removing previous script connections if executed more than once.
if _G["FlameTouchRemover"] ~= nil then 
	_G["FlameTouchRemover"]:Disconnect()
	_G["FlameTouchRemover"] = nil
end
if _G["ShoveBind"] ~= nil then 
	_G["ShoveBind"]:Disconnect()
	_G["ShoveBind"] = nil
end
if _G["ShoveEquipper"] ~= nil then
	_G["ShoveEquipper"]:Disconnect()
	_G["ShoveEquipper"] = nil
end
if _G["MurderBind"] ~= nil then 
	_G["MurderBind"]:Disconnect()
	_G["MurderBind"] = nil
end
if _G["RubiksCubeBind"] ~= nil then
	_G["RubiksCubeBind"]:Disconnect()
	_G["RubiksCubeBind"] = nil
end
if _G["MusicBind"] ~= nil then
	_G["MusicBind"]:Disconnect()
	_G["MusicBind"] = nil
end
if _G["FakeAccuracyBeat"] ~= nil then
	coroutine.close(_G["FakeAccuracyBeat"])
	_G["FakeAccuracyBeat"] = nil
end
if _G["OnCameraDescendantAdded"] ~= nil then 
	_G["OnCameraDescendantAdded"]:Disconnect()
	_G["OnCameraDescendantAdded"]= nil
end
if _G["BuildingBind"] ~= nil then
	_G["BuildingBind"]:Disconnect()
	_G["BuildingBind"] = nil
end
if _G["BuildingBindFunc"] ~= nil then
	_G["BuildingBindFunc"]:Disconnect()
	_G["BuildingBindFunc"] = nil
end
if _G["BuildHighlight"] ~= nil then
	_G["BuildHighlight"].Enabled = false
	_G["BuildHighlight"]:Destroy()
	_G["BuildHighlight"] = nil
end
if _G["BuildingFetchTypeBind"] ~= nil then 
	_G["BuildingFetchTypeBind"]:Disconnect()
	_G["BuildingFetchTypeBind"] = nil
end
if _G["GrabLogBind"] ~= nil then 
	_G["GrabLogBind"]:Disconnect()
	_G["GrabLogBind"] = nil
end
if _G["BlockBarrelBind"] ~= nil then 
	_G["BlockBarrelBind"]:Disconnect()
	_G["BlockBarrelBind"] = nil
end
if _G["OnCharacterAdded"] then
	_G["OnCharacterAdded"]:Disconnect()
	_G["OnCharacterAdded"] = nil
end
--//

task.wait(0.2) --// Allow Luau's garbage collector to cleanup.

_G["BuildHighlight"] = Instance.new("Highlight")
_G["BuildHighlight"].DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
_G["BuildHighlight"].OutlineColor = Color3.fromRGB(255, 204, 0)
_G["BuildHighlight"].FillColor = Color3.fromRGB(255, 204, 102)
_G["BuildHighlight"].Parent = ReplicatedFirst
_G["BuildHighlight"].FillTransparency = 0.5
_G["BuildHighlight"].Enabled = true

--[=[
    Description:
    Applies an ESP (Extra Sensory Perception) highlight effect to a given character model, allowing enemy types to be visually identified 
    through colored overlays and optional head recoloring.

    Parameters:
    - `Character: Model`: The character model to highlight. Must be a valid `Model` instance.
    - `Head: BasePart?`: (Optional) The character's head part. If valid, its color is updated to match the assigned type.
    - `IsIgniter: boolean?`: If true, classifies the character as an "Igniter."
    - `IsRunner: boolean?`: If true, classifies the character as a "Runner."
    - `IsSapper: boolean?`: If true, classifies the character as a "Sapper."
    - `IsBomber: boolean?`: If true, classifies the character as a "Bomber."
    - `IsHeadless: boolean?`: If true, classifies the character as "Headless."
    - `IsCuirassier: boolean?`: If true, classifies the character as a "Cuirassier."

    Returns:
    - None (modifies the `Character` in-place).

    Behavior:
    - Validates that `Character` is a `Model` and not already highlighted (tagged `"Highlighted_"`).
    - Determines the character’s type based on the first truthy flag in this priority order:
        `Igniter > Runner > Sapper > Bomber > Headless > Cuirassier`.
    - If a valid type is resolved, applies a `Highlight` instance using the corresponding color from `ESPColors`.
    - Sets the highlight to always render on top, with 50% fill transparency.
    - Optionally changes the `Head` part's color if it exists and is valid.

    Example Usage:
    ```lua
    local characterModel = workspace.EnemyNPC
    local headPart = characterModel:FindFirstChild("Head")

    AddEsp(characterModel, headPart, nil, true)
    --// Applies "Runner" highlight and recolors the head (if provided)
    ```

    Notes:
    - Based on the first matching flag, only one type will be assigned.
    - The `"Highlighted_"` tag prevents reapplying the effect multiple times.
    - `ESPColors` must define a color mapping for each supported type.

    Edge Cases:
    - The function exits immediately if `Character` is not a valid `Model`.
    - If no type flags are truthy, no highlight is applied.
    - If `Head` is not a valid `BasePart`, its color remains unchanged.
]=]
local function AddEsp(Character:Model, Head:BasePart?, IsIgniter:boolean?, IsRunner:boolean?, IsSapper:boolean?, IsBomber:boolean?, IsHeadless:boolean?, IsCuirassier:boolean?)
	if (typeof(Character) ~= "Instance") or not Character:IsA("Model") then
		return
	end
	if Character:HasTag("Highlighted_") then
		return
	end

	local HeadParameterExist:boolean = (typeof(Head) == "Instance" and Head:IsA("BasePart"))
	local Type:string = (IsIgniter and "Igniter") 
		or (IsRunner and "Runner")
		or (IsSapper and "Sapper")
		or (IsBomber and "Bomber")
		or (IsHeadless and "Headless")
		or (IsCuirassier and "Cuirassier")
        or "None"
	local NewHighlight:any

	if (type(Type) == "string") and (Type ~= "None") then
		NewHighlight = Instance.new("Highlight")
		Character:AddTag("Highlighted_")
		NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		NewHighlight.OutlineColor = ESPColors[Type]
		NewHighlight.FillColor = ESPColors[Type]
		NewHighlight.Parent = Character
		NewHighlight.FillTransparency = 0.5
		NewHighlight.Enabled = true
		NewHighlight.Adornee = Character

		if HeadParameterExist and Head then
			Head.Color = ESPColors[Type]
		end
	end
	NewHighlight = nil
end

--[=[
    Description:
    Creates and starts a coroutine that continuously fires a specified `RemoteEvent` to simulate an "accuracy beat."
    This function is typically used to send periodic accuracy updates to the server.

    Parameters:
    - `RemoteEventToUse: RemoteEvent`: The remote event instance that will be fired.
    - `BeatWaitTime: number?` (optional): The delay (in seconds) between each accuracy update. 
      - If `BeatWaitTime` is invalid, the function assigns a default value.
      - If `BeatWaitTime` is not provided, it falls back to `DefaultBeatWaitTime`.
      - If `BeatWaitTime` is less than or equal to `0` or greater than `5`, it defaults to `0.15` seconds.

    Returns:
    - `thread`: The coroutine responsible for continuously firing the remote event.

    Features:
    - Validates that `RemoteEventToUse` is a proper `RemoteEvent` instance before proceeding.
    - Ensures `BeatWaitTime` is within an acceptable range to prevent unreasonable wait times.
    - Uses coroutines to maintain efficiency and avoid blocking the main thread.
    - Implements debug logging to track time since the last beat when debugging is enabled.
    - Fires the remote event with `"UpdateAccuracy"` and a fixed value of `100` at each interval.

    Notes:
    - If `RemoteEventToUse` is invalid, the function returns an empty coroutine.
    - The coroutine runs indefinitely unless manually stopped.
    - Debug mode tracks the time since the last accuracy update and logs it if `DebugPrints` is enabled.

    Example Usage:
    ```lua
	local accuracyEvent = game.ReplicatedStorage:WaitForChild("AccuracyEvent")
	local fakeAccuracyThread = SetupFakeAccuracyBeat(accuracyEvent, 0.2)
	
	--// Stop the coroutine after 5 seconds
	task.delay(5, function()
	    if coroutine.status(fakeAccuracyThread) == "suspended" then
	        coroutine.close(fakeAccuracyThread)
	        print("Fake accuracy beat coroutine stopped after 5 seconds.")
	    end
	end)
    ```

    Edge Cases:
    - If `RemoteEventToUse` is not a valid `RemoteEvent`, the function warns and returns an empty coroutine.
    - If `BeatWaitTime` is out of range, it defaults to `0.15` to ensure smooth operation.
    - Ensures that if `LastBeatTick` is `0`, it initializes before calculating the time since the last beat.
]=]
local function SetupFakeAccuracyBeat(RemoteEventToUse:RemoteEvent, BeatWaitTime:number?):(thread)
	if (typeof(RemoteEventToUse) ~= "Instance") or not RemoteEventToUse:IsA("RemoteEvent") then 
		warn(`[FAIL # SetupFakeAccuracyBeat]: "RemoteEventToUse" is not an Instance, nor a RemoteEvent.  ||| Current script line: {debug.info(1, "l")}`)

		return coroutine.create(function() end)
	end

	if (type(BeatWaitTime) ~= "number") then
		BeatWaitTime = DefaultBeatWaitTime
	elseif (type(BeatWaitTime) == "number") then
		if (BeatWaitTime <= 0) or (BeatWaitTime >= 5) or (BeatWaitTime ~= BeatWaitTime) then
			BeatWaitTime = 0.15
		end
	end

	local NewThread:thread = coroutine.create(function()
		while true do
			if Debug then
				if (LastBeatTick ~= 0) then 
					_TimeSinceLastBeat = (tick() - LastBeatTick)
					if DebugPrints then
						print(`[DEBUG # Fake Accuracy Beat Thread]: _TimeSinceLastBeat = {_TimeSinceLastBeat}.`)
					end
					LastBeatTick = tick()
				elseif (LastBeatTick == 0) then 
					LastBeatTick = tick()
				end
			end

			RemoteEventToUse:FireServer("UpdateAccuracy", 100)
			task.wait(BeatWaitTime)
		end
	end)
	coroutine.resume(NewThread)

	return NewThread
end

--[=[
    Description:
    Retrieves a melee weapon from the player's character or backpack, returning the weapon tool and its associated RemoteEvent and limit range configuration attribute.
    Supports an optional mode to list all available melee weapons instead of returning only the first found.

    Parameters:
    - `ListTools: boolean?` (optional): If `true`, returns a list of all melee weapons found instead of a single tool. Defaults to `false`.

    Returns:
    - If `ListTools` is `false` or `nil`:
        - `Tool: Tool?` - The first melee weapon found.
        - `RemoteEvent: RemoteEvent?` - The weapon's RemoteEvent (if available).
        - `LimitRange: any?` - The weapon's limit range attribute (if available).
    - If `ListTools` is `true`:
        - `List: table` - A list of melee weapons, each containing `{Tool, RemoteEvent, LimitRange}`.

    Features:
    - Searches for the `PreferredWeapon` in the player's character first.
    - Looks for melee weapons by checking for the `"MeleeBase"` child.
    - Also considers `"Musket"` and `"Shovel"` as valid melee weapons.
    - Prioritizes equipped tools (in the character) before searching in the backpack.
    - Ensures that the player's character exists before attempting to retrieve a weapon.
    - Prevents errors by verifying that tools have valid parents before accessing their attributes.

    Notes:
    - If no melee weapon is found, returns `nil` (or an empty list if `ListTools` is `true`).
    - If multiple melee weapons exist and `ListTools` is `false`, the function returns only the first match.
    - If the function fails to find the player's character, a warning is logged, and execution stops.

    Example Usage:
    ```lua
    local weapon, remote, limitRange = GetMeleeWeapon()
    if weapon then
        print("Equipped Melee Weapon:", weapon.Name)
    end

    local availableWeapons = GetMeleeWeapon(true)
    for _, data in pairs(availableWeapons) do
        print("Available Melee Weapon:", data[1].Name)
    end
    ```

    Edge Cases:
    - If `Character` is `nil`, the function logs a warning and exits early.
    - If `Character.Parent` is `nil`, a warning is logged, and execution stops.
    - If `ListTools` is `true`, but no melee weapons are found, an empty table is returned instead of `nil`.

]=]
local function GetMeleeWeapon(ListTools:boolean?):(...any)
	local Character = LocalPlayer.Character

	if not Character then 
		warn(`[FAIL # GetMeleeWeapon]: Your character doesn't exist?  ||| Current script line: {debug.info(1, "l")}`)

		return
	end

	if (Character.Parent == nil) then 
		warn(`[FAIL # GetMeleeWeapon]: Your character's parent is equal to nil.  ||| Current script line: {debug.info(1, "l")}`)

		return
	end

	local List:any = {}

	if not ListTools then
		if Character:FindFirstChild(PreferredWeapon) then 
			local Tool = (Character:FindFirstChild(PreferredWeapon))::Tool

			return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
		end
	elseif ListTools then
		if Character:FindFirstChild(PreferredWeapon) then 
			local Tool = (Character:FindFirstChild(PreferredWeapon))::Tool

			table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
		end
	end

	if Character:FindFirstChildWhichIsA("Tool") then
		for _, Tool in ipairs(Character:GetChildren()) do 
			if (typeof(Tool) == "Instance") and Tool:IsA("Tool") and Tool.Parent then 
				if Tool:FindFirstChild("MeleeBase") then 
					if ListTools then
						table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
						continue
					end

					return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
				else
					if (Tool.Name == "Musket") or (Tool.Name == "Shovel") then 
						if ListTools then
							table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
							continue
						end

						return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
					end
				end
			end
		end
	end
	if Backpack:FindFirstChildWhichIsA("Tool") then
		for _, Tool in ipairs(Backpack:GetChildren()) do 
			if (typeof(Tool) == "Instance") and Tool:IsA("Tool") and Tool.Parent then 
				if Tool:FindFirstChild("MeleeBase") then
					if ListTools then
						table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
						continue
					end

					return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
				else
					if (Tool.Name == "Musket") or (Tool.Name == "Shovel") then 
						if ListTools then
							table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
							continue
						end

						return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
					end
				end
			end
		end
	end

	return (ListTools and List) or nil
end

--[=[
    Description:
    Retrieves nearby agents from the "Zombies" and "Bots" folders that fall within a specified 2D range of a target position 
    or the player’s character. Agents with a "Type" attribute marked as `true` in the `AgentTypeList` are excluded from the results. 
    The distance is calculated on a horizontal plane (the Y-axis is ignored).

    Parameters:
    - `Position` (Vector3 | boolean | nil): If a Vector3 is provided, it will be used as the center of the range check. 
      If false or nil is passed, the function will attempt to use the LocalPlayer’s character position instead.
    - `Range` (number): The detection radius in studs. Negative values are made positive. Values of 0 or invalid types default to 4.

    Returns:
    - `{[number]: any}`: A table containing valid agent models that were found within the specified range. Returns an empty table 
      if none are found or if validation fails.

    Behavior:
    - Validates the `Range` input and applies a fallback value of 4 for edge cases (e.g., 0, NaN, non-number).
    - Determines whether to use a given position or fall back to the player’s character.
    - Warns in the output console if the player character or its root part is unavailable.
    - Iterates through the "Zombies" and "Bots" folders to find matching agents:
        - Agents must be valid models, have a parent, and must not have a `ForceField` instance.
        - The agent’s type must either not exist in `AgentTypeList` or be explicitly marked as `false`.
        - Agents with unknown or unlisted "Type" attributes are included by default.
    - Calculates agent distance in a 2D plane (XZ only) and includes them if within range.
    - Adds `false` into the results table in case of failed agent validation, as a fallback behavior.

    Notes:
    - Uses either Lua's global `vector` library or the standard `Vector3` class, depending on the `UseVectorLibrary` flag.
    - Useful for enemy detection, NPC proximity checks, or environmental interaction logic based on spatial queries.
    - Logs formatted failure messages to the Developer Console to assist with debugging.

    Use Cases:
    - Identifying enemies or bots near the player or a specific point in the game world.
    - Filtering entities based on customizable type exclusions via `AgentTypeList`.
    - Supporting dynamic proximity-based interactions in PvE or PvP systems.

    Example Usage:
    ```lua
    --// Find all agents within 10 studs of the player
    local nearbyAgents = GetAgentsInRange(false, 10)

    --// Find all agents near a specific world position
    local origin = Vector3.new(50, 0, -25)
    local agentsNearPoint = GetAgentsInRange(origin, 12)

    --// Iterate and do something with each agent
    for _, agent in ipairs(nearbyAgents) do
        if agent and agent:IsA("Model") then
            print(`Found nearby agent: {agent.Name}`)
        end
    end
    ```

]=]
local function GetAgentsInRange(Position:Vector3?|boolean?|nil, Range:number):{[number]:any}
	local AgentsInRange:{[number]:any} = {}

	if (type(Range) ~= "number") then 
		warn(`[FAIL # GetAgentsInRange]: "Range" is not a number.  ||| Current script line: {debug.info(1, "l")}`)
		return AgentsInRange
	end

	if (Range == 0) or (Range ~= Range) then 
		Range = 4
	elseif (Range < 0) then 
		Range = math.abs(Range)
	end

	local UsePosition:boolean = (typeof(Position) == "Vector3")
	local CharHRP:any
	if not UsePosition then
		local Character:Model = LocalPlayer.Character
		if not Character or not Character.Parent then
			warn(`[FAIL # GetAgentsInRange]: You do not have a character?  ||| Current script line: {debug.info(1, "l")}`)

			return AgentsInRange
		end

		CharHRP = (Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart)::BasePart
		if not CharHRP or CharHRP:IsA("Model") then 
			warn(`[FAIL # GetAgentsInRange]: No HumanoidRootPart/PrimaryPart found inside the player's character.  ||| Current script line: {debug.info(1, "l")}`)

			return AgentsInRange
		end
	elseif UsePosition then
		CharHRP = Position
	end

	if (#ZombiesFolder:GetChildren() > 0) then 
		for _, Agent in ipairs(ZombiesFolder:GetChildren()) do 
			if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and not Agent:FindFirstChildWhichIsA("ForceField") then 
				local HRP = Agent.PrimaryPart or Agent:FindFirstChild("HumanoidRootPart")

				local ZombieType = Agent:GetAttribute("Type")
				local IgnoreVal = AgentTypeList[ZombieType]

				if HRP and (type(IgnoreVal) == "boolean") and not IgnoreVal then 
					local Distance:number = 0
					if UseVectorLibrary then
						Distance = (not UsePosition)
							and (vector.create(CharHRP.Position.X, 0, CharHRP.Position.Z) - vector.create(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
							or (vector.create(CharHRP.X, 0, CharHRP.Z) - vector.create(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
					else
						Distance = (not UsePosition)
							and (Vector3.new(CharHRP.Position.X, 0, CharHRP.Position.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
							or (Vector3.new(CharHRP.X, 0, CharHRP.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
					end


					if (Distance <= Range) then 
						table.insert(AgentsInRange, Agent)
					end
				elseif HRP and (type(IgnoreVal) ~= "boolean") then
					--// incase the agent's type is *new*, or not in the list.
					table.insert(AgentsInRange, Agent)
				end
			else
				table.insert(AgentsInRange, false)
			end
		end
	end
	
	if not BotsFolder then
		BotsFolder = (Workspace:FindFirstChild("Bots"))
	end
	if BotsFolder and (#BotsFolder:GetChildren() > 0) then 
		for _, Agent in ipairs(BotsFolder:GetChildren()) do 
			if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and not Agent:FindFirstChildWhichIsA("ForceField") then 
				local HRP = Agent.PrimaryPart or Agent:FindFirstChild("HumanoidRootPart")

				local BotType = Agent:GetAttribute("Type")
				local IgnoreVal = AgentTypeList[BotType]

				if HRP and (type(IgnoreVal) == "boolean") and not IgnoreVal then 
					local Distance:number = 0

					if UseVectorLibrary then
						Distance = (not UsePosition)
							and (vector.create(CharHRP.Position.X, 0, CharHRP.Position.Z) - vector.create(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
							or (vector.create(CharHRP.X, 0, CharHRP.Z) - vector.create(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
					else
						Distance = (not UsePosition)
							and (Vector3.new(CharHRP.Position.X, 0, CharHRP.Position.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
							or (Vector3.new(CharHRP.X, 0, CharHRP.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
					end

					if (Distance <= Range) then 
						table.insert(AgentsInRange, Agent)
					end
				elseif HRP and (type(IgnoreVal) ~= "boolean") then 
					--// incase the agent's type is *new*, or not in the list.
					table.insert(AgentsInRange, Agent)
				end
			else
				table.insert(AgentsInRange, false)
			end
		end
	end

	return AgentsInRange
end

--[=[
    Description:
    This function iterates over a table, applying a specified function to each key-value pair. It supports both 
    synchronous and asynchronous execution, determined by the `Instant` parameter. The function ensures proper 
    validation of inputs and provides warnings for invalid parameters.

    Parameters:
    - `Table` (table): A table containing key-value pairs to be iterated over.
    - `Function` (function): A callback function executed for each key-value pair. It receives two arguments: 
      the key and the value.
    - `Instant` (boolean?): Optional. If `true` (default) or not provided, the function executes asynchronously 
      using `task.spawn`. If `false`, the function executes synchronously.

    Returns:
    - void: This function does not return a value.

    Example Usage:
    ```lua
    IterateWithFunction(
        {
            [1] = "Bob",
            [2] = "Cheese",
            ["StringIndex"] = 1
        },
        function(index, value)
            print("Index: " .. tostring(index) .. " | Value: " .. tostring(value))
        end,
        true
    )
    ```
    - Asynchronous execution with `Instant` set to `true` or default.
    - Synchronous execution with `Instant` explicitly set to `false`.

    Behavior:
    - Validates the `Table` and `Function` parameters:
        - Logs a warning and terminates if `Table` is not a table or is `nil`.
        - Logs a warning and terminates if `Function` is not a function or is `nil`.
    - Determines execution mode based on the `Instant` parameter:
        - If `Instant` is `true`, this function applies the sent function asynchronously using `task.spawn`.
        - If `Instant` is `false`, this function applies the function synchronously.
    - Iterates over all key-value pairs in the table, calling the specified function for each pair.
    - Provides default asynchronous behavior if `Instant` is not specified.

    Notes:
    - This function is useful for scenarios requiring flexible execution modes (e.g., UI updates vs. heavy computations).
    - Asynchronous mode can improve performance for computationally intensive or delayed tasks.
 
]=]
local function IterateWithFunction(Table:{[any]: any}, Function:typeof(function(...) end), Instant:boolean?)
	if (type(Instant) ~= "boolean") then
		Instant = true
	end

	if (Table ~= nil) and (Function ~= nil) then 
		if (type(Table) ~= "table") then 
			warn(`[FAIL # IterateWithFunction]: "Table" is not a table.  ||| Current script line: {debug.info(1, "l")}`)

			return
		end

		if (type(Function) ~= "function") then 
			warn(`[FAIL # IterateWithFunction]: "Function" is not a function.  ||| Current script line: {debug.info(1, "l")}`)

			return
		end

		if Instant then 
			for Index:any, Key:any in pairs(Table) do
				task.spawn(Function, Index, Key)
			end
		elseif not Instant then
			for Index:any, Key:any in pairs(Table) do
				Function(Index, Key)
			end
		end
	else
		if (Table == nil) then 
			warn(`[FAIL # IterateWithFunction]: "Table" is equal to nil.  ||| Current script line: {debug.info(1, "l")}`)

			return
		end
		if (Function == nil) then 
			warn(`[FAIL # IterateWithFunction]: "Function" is equal to nil.  ||| Current script line: {debug.info(1, "l")}`)

			return
		end
	end

	return
end

--[=[
    Description:
    This function identifies the building belonging to the local player that has the lowest relative health. It calculates 
    the ratio of `CurrentHealth` to `MaxHealth` for each building and returns the "BuildingHealth" `NumberValue` instance 
    corresponding to the building with the lowest ratio. If no buildings are found, it returns `false`.

    Parameters:
    - None

    Returns:
    - `Instance: NumberValue`: The "BuildingHealth" instance with the lowest relative health.
    - `false`: If no valid buildings are found.

    Notes:
    - Health is calculated as `CurrentHealth / MaxHealth`, where `MaxHealth` is an attribute of the "BuildingHealth" instance.
    - The function logs warnings for missing or invalid data during execution.

    Behavior:
    - Locates the folder containing the local player's buildings within the `BuildingsFolder`.
    - Iterates through all descendants of the folder, identifying instances named "BuildingHealth" that is of type `NumberValue`.
    - Compiles all valid "BuildingHealth" instances into a table.
    - Sorts the table in ascending order based on the relative health (`CurrentHealth / MaxHealth`) of each building.
    - Returns the first instance (lowest relative health) from the sorted table.
    - Logs warnings if:
        - No buildings are found for the player.
        - "BuildingHealth" instances are missing or invalid.

    Example Usage:
    ```lua
    local WeakestBuilding = GetBuildingWithLeastHealth()
    if WeakestBuilding then
        print("The building with the lowest relative health is: ", WeakestBuilding)
    else
        print("No valid buildings were found.")
    end
    ```

    Use Cases:
    - Real-time monitoring and repair systems for player-owned buildings.
    - Identifying weak points in a player's structure during gameplay.
    - Strategically prioritizing building maintenance or defense based on health status.

]=]
local function GetBuildingWithLeastHealth():(any)
	local LocalPlayerUserId:number = LocalPlayer.UserId
	local Healths = {}

	local LocalPlayerBuildings = (BuildingsFolder:FindFirstChild(tostring(LocalPlayerUserId)))::Folder
	if not LocalPlayerBuildings then 
		return false
	end

	for _,  v in pairs(LocalPlayerBuildings:GetDescendants()) do
		if (typeof(v) == "Instance") and (v.Name == "BuildingHealth") and v:IsA("NumberValue") then 
			table.insert(Healths, v)
		else
			continue
		end
	end

	if (#Healths > 0) then 
		table.sort(Healths, function(Arg1, Arg2)
			return (
				(Arg1.Value / (Arg1:GetAttribute("MaxHealth") or Arg1.Value))
					< 
					(Arg2.Value / (Arg2:GetAttribute("MaxHealth") or Arg2.Value))
			)
		end)

		if (typeof(Healths[1]) == "Instance") then 
			return Healths[1]
		elseif not Healths[1] then 
			warn(`[FAIL # GetBuildingWithLeastHealth]: Failed to get a "BuildingHealth" NumberValue.  ||| Current script line: {debug.info(1, "l")}`)
			return false
		end
	else
		warn(`[FAIL # GetBuildingWithLeastHealth]: No buildings found?  ||| Current script line: {debug.info(1, "l")}`)
	end 

	return false
end

--[=[
    Description: 
    Identifies the closest player-made building to the local player's character by calculating the distance between the character and each building's "Bound" part. Returns the "BuildingHealth" instance of the closest building unless it is already at maximum health. If no valid building is found, or all are at maximum health, returns `false`. Returns `nil` if the local player has no buildings.

    Parameters: 
    - None

    Returns: 
    - `Instance: NumberValue`: The "BuildingHealth" instance of the closest building.
    - `false`: If the closest building is at maximum health or no valid building is found.
    - `nil`: If the local player has no buildings.

    Notes:
    - The function checks that the local player's character exists and is properly parented.
    - Each building is represented by a Bound part, which is a BasePart instance located inside the player’s building folder within the BuildingsFolder.
    - The closest building is determined using the `DistanceFromCharacter` method, ensuring accurate distance measurements relative to the local player.
    - The "BuildingHealth" instance is checked against its `MaxHealth` attribute to exclude buildings already at full health.

    Behavior:
    - Locates the folder containing the local player's buildings in the `BuildingsFolder`.
    - Iterates through the folder to find all "Bound" parts associated with buildings.
    - Sorts the buildings by distance from the local player's character.
    - Retrieves the "BuildingHealth" instance of the closest building and checks its health.
    - Returns the "BuildingHealth" instance if the building's health is below its maximum value.
    - Logs warnings if no valid buildings are found or the closest building has invalid data.

    Example Usage:
    ```lua
    local ClosestBuilding = GetClosestBuilding()
    if ClosestBuilding then
        print("The closest building is: ", ClosestBuilding)
    elseif not ClosestBuilding then
        print("The closest building is already at maximum health or invalid.")
    else
        print("No buildings found for the player.")
    end
    ```

    Use Cases:
    - Identifying the nearest building for repair or defense during gameplay.
    - Monitoring player-owned structures based on proximity for strategic purposes.
    - Facilitating dynamic interactions with player-made structures in multiplayer games.

]=]
local function GetClosestBuilding():any
	if not LocalPlayer.Character or not LocalPlayer.Character.Parent then
		return
	end

	local LocalPlayerUserId:number = LocalPlayer.UserId
	local Bounds = {}

	local LocalPlayerBuildings = (BuildingsFolder:FindFirstChild(tostring(LocalPlayerUserId)))::Folder
	if not LocalPlayerBuildings then
		return
	end

	for _,  v in pairs(LocalPlayerBuildings:GetDescendants()) do
		if (typeof(v) == "Instance") and (v.Name == "Bound") and v:IsA("BasePart") then 
			table.insert(Bounds, v)
		else
			continue
		end
	end

	if (#Bounds > 0) then 
		table.sort(Bounds, function(Arg1, Arg2)
			if UseVectorLibrary then
				return (
					(Arg1 and LocalPlayer:DistanceFromCharacter(Arg1.Position) or vector.create(0, 0, 0)) 
						< 
						(Arg2 and LocalPlayer:DistanceFromCharacter(Arg2.Position) or vector.create(0, 0, 0))
				)
			end

			return (
				(Arg1 and LocalPlayer:DistanceFromCharacter(Arg1.Position) or Vector3.new()) 
					< 
					(Arg2 and LocalPlayer:DistanceFromCharacter(Arg2.Position) or Vector3.new())
			)
		end)

		if (typeof(Bounds[1]) == "Instance") and (typeof(Bounds[1].Parent) == "Instance") then 
			local BuildingHealth:NumberValue = (((Bounds[1].Parent)::Part):WaitForChild("BuildingHealth")::NumberValue)

			if (BuildingHealth.Value >= (BuildingHealth:GetAttribute("MaxHealth") or BuildingHealth.Value))  then 
				return false
			end

			return ((Bounds[1].Parent)::Part):WaitForChild("BuildingHealth")
		elseif not Bounds[1] then 
			warn(`[FAIL # GetClosestBuilding]: Failed to find the closest building.  ||| Current script line: {debug.info(1, "l")}`)
			return false
		end
	else
		warn(`[FAIL # GetClosestBuilding]: No buildings found?  ||| Current script line: {debug.info(1, "l")}`)
	end 

	return false
end

--[=[
    Description:
    Counts the total number of valid indices in a specified table, including array-like and dictionary-like indices. 
    If the input is invalid or `nil`, logs appropriate warnings and returns `0`.

    Parameters:
    - `Table: {[any]: any}`: The table whose indexes are to be counted.

    Returns:
    - `number`: The total count of valid indexes with the `Table` parameter.
    - `0`: If the input is `nil` or not of type `table`.

    Notes:
    - Differentiates between valid and invalid inputs, ensuring reliable results.
    - Treats all table indexes (numeric and non-numeric) as valid for counting.
    - Provides helpful warnings for debugging when the input is `nil` or not a table.

    Example Usage:
    ```lua
    local SampleTable = {1, 2, 3, ["Key"] = workspace}
    local MaxIndex = GetMaxIndexOfTable(SampleTable)
    print(`Total indexes: {MaxIndex}`)  --// Output: 4
    ```

    Use Cases:
    - Counting entries in a table regardless of its structure (sequential or non-sequential).
    - Debugging scenarios involving `nil` or improperly formatted tables.
    - Validating and inspecting table content in dynamic Lua scripts.

    Edge Cases:
    - If the `Table` parameter is `nil`, the function logs a warning and returns `0`.
    - If the `Table` is not a table, logs a warning and returns `0`.
    - Empty tables return a count of `0`.

]=]
local function GetMaxIndexOfTable(Table:{[any]: any})
	if (Table ~= nil) then 
		if (type(Table) ~= "table") then 
			warn(`[FAIL # GetMaxIndexOfTable]: "Table" is not a table. Returning 0.  ||| Current script line: {debug.info(1, "l")}`)
			return 0
		end

		local CountToReturn = 0
		for i, v in pairs(Table) do 
			if i then
				CountToReturn += 1
			else
				continue
			end
		end

		return CountToReturn
	else
		if (Table == nil) then 
			warn(`[FAIL # GetMaxIndexOfTable]: "Table" is equal to nil. Returning 0.  ||| Current script line: {debug.info(1, "l")}`)

			return 0
		end
	end

	return 0
end

_G["OnCameraDescendantAdded"] = Camera.DescendantAdded:Connect(function(Orig:Instance)
	if Orig and not Orig:IsA("Highlight") and Orig:IsA("ObjectValue") and (Orig.Name == "Orig") then 
		repeat
			task.wait()
		until Orig.Value and Orig.Parent
		task.wait(ZombieESPWait)

		local Character:Model = (Orig.Parent::Model)
		local Agent:Model = (Orig.Value::Model)
		local Type:string = (Agent and tostring(Agent:GetAttribute("Type"))) or ""

		local IsIgniter:boolean = (Type == "Igniter")
		local IsRunner:boolean = (Type == "Fast")
		local IsSapper:boolean = (Type == "Sapper")
		local IsBomber:boolean = (Type == "Barrel")
		local IsHeadless:boolean = (Type == "Headless")
		local IsCuirassier:boolean = (Type == "Cuirassier")

		if not Character then
			return
		end

		local Head:BasePart?
		if not IsIgniter then
			Head = (Character:FindFirstChild("Head") or Character:WaitForChild("Head", 3))::BasePart or (nil)
		else
			for _, Part:any in pairs(Character:GetChildren()) do 
				if Part and Part:IsA("Part") and (Part.Name == "Head") then
					Head = Part
					Part = nil
					break
				end
			end
		end

		if Head then
			Head.Massless = true
			Head.Size = HeadSizeToUse or (UseVectorLibrary and vector.create(3, 3, 3)) or Vector3.new(3, 3, 3)
			Head.Transparency = HeadTransparency
		end

		task.spawn(pcall, AddEsp, Character, Head,
			IsIgniter,
			IsRunner,
			IsSapper,
			IsBomber,
			IsHeadless,
			IsCuirassier
		)
        Head = nil
	end
end)

_G["BuildingBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Enum.KeyCode.KeypadTwo) then 
			BuildingBindEnabled	= not BuildingBindEnabled
			print(`[INFO # BuildingBind]: "BuildingBindEnabled" is now equal to: {BuildingBindEnabled}`)

			if not BuildingBindEnabled then 
				_G["BuildHighlight"].Adornee = nil
			end
		end
	end
end)

_G["BuildingBindFunc"] = RunService.Stepped:Connect(function()
	if BuildingBindEnabled and LocalPlayer.Character then 
		local Character = LocalPlayer.Character
		Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))::Backpack

		local Hammer = Backpack:FindFirstChild("Hammer") 
			or Character:FindFirstChildWhichIsA("Tool")
			or Character:FindFirstChildWhichIsA("HopperBin")

		if Hammer and (Hammer.Name == "Hammer") then
			local Remote = Hammer:FindFirstChild("RemoteEvent")

			if Remote then 
				local BuildingFound:NumberValue = (BuildingFetchType == "LeastHealth" and GetBuildingWithLeastHealth()) or GetClosestBuilding()

				if (type(BuildingFound) == "boolean") or not CanRepair or (BuildingFound.Value >= (BuildingFound:GetAttribute("MaxHealth") or BuildingFound.Value)) then 
					if not CanRepair then 
						return
					end

					_G["BuildHighlight"].Adornee = nil
					return
				end
				CanRepair = false

				Remote:FireServer("Repair", BuildingFound)
				_G["BuildHighlight"].Adornee = BuildingFound.Parent

				task.spawn(function()
					task.wait(WaitTimeUntilRepair or 0.175)
					CanRepair = true
				end)
			elseif not Remote then 
				warn(`[FAIL # BuildingBindFunc]: Failed to find the hammer's remote event.  ||| Current script line: {debug.info(1, "l")}`)
				return
			end
		else
			if HammerCanWarn then
				HammerCanWarn = false
				warn("[FAIL # BuildingBindFunc]: Failed to find a hammer to use.")

				task.wait(HammerWarnDelay)
				HammerCanWarn = true
			end

			return
		end
	end

	task.wait()
end)

_G["BuildingFetchTypeBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process and Key.KeyCode == (Enum.KeyCode.KeypadThree) then 
		if (BuildingFetchType == "Closest") then 
			BuildingFetchType = "LeastHealth"
		else
			BuildingFetchType = "Closest"
		end

		print(`[INFO # BuildingFetchTypeBind]: "BuildingFetchType" is now equal to: {BuildingFetchType}`)
	end
end)

_G["MusicBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process and LocalPlayer.Character then 
		local Character = LocalPlayer.Character
		local KeyCodeName = tostring(Key.KeyCode.Name)
		local SongName = MusicSelections[KeyCodeName]

		if (type(SongName) == "string") then 
			local FoundInstrument:Tool

			for i:string, v:boolean in pairs(AllowedInstruments) do 
				if (type(i) == "string") and v then 
					FoundInstrument = (Character:FindFirstChild(tostring(i)) or Backpack:FindFirstChild(tostring(i)))::Tool

					if FoundInstrument then 
						print(`[INFO # MusicBind]: Found instrument "{FoundInstrument.Name}".`)
						break
					end
				end
			end

			if( typeof(FoundInstrument) == "Instance") and FoundInstrument:IsA("Tool") then                 
				local Remote = (FoundInstrument:FindFirstChild("RemoteEvent"))::RemoteEvent

				if Remote then 
					if (_G["FakeAccuracyBeat"] ~= nil) then 
						coroutine.close(_G["FakeAccuracyBeat"])
						_G["FakeAccuracyBeat"] = nil
					end

					print(`[INFO # MusicBind]: Attempted to play "{SongName}" with {FoundInstrument.Name}.`)

					Remote:FireServer("Stop")
					Remote:FireServer("Play", SongName)
					_G["FakeAccuracyBeat"] = SetupFakeAccuracyBeat(Remote)

					local Connection
					Connection = FoundInstrument:GetPropertyChangedSignal("Parent"):Connect(function()
						if FoundInstrument.Parent and ((FoundInstrument.Parent).Name == "Backpack") then 
							if (_G["FakeAccuracyBeat"] ~= nil) then 
								coroutine.close(_G["FakeAccuracyBeat"])
								_G["FakeAccuracyBeat"] = nil
							end

							Connection:Disconnect()
						elseif not FoundInstrument.Parent then 
							if (_G["FakeAccuracyBeat"] ~= nil) then 
								coroutine.close(_G["FakeAccuracyBeat"])
								_G["FakeAccuracyBeat"] = nil
							end

							Connection:Disconnect()
						end
					end)
				elseif not Remote then 
					warn(`[FAIL # MusicBind]: Failed to find instrument remote event for the "{FoundInstrument.Name}".  ||| Current script line: {debug.info(1, "l")}`)
					return
				end
			else
				return
			end
		end
	end
end)

_G["RubiksCubeBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Enum.KeyCode.KeypadFour) then 
			RubiksCube = not RubiksCube
			print(`[INFO # RubiksCubeBind]: "RubiksCube" is now equal to: {RubiksCube}`)
		end
	end
end)

_G["BlockBarrelBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Enum.KeyCode.KeypadFive) then 
			if not ReplicatedStorage:FindFirstChild("BlockBarrel") then
                if not _G["_BlockBarrel"] then
                    _G["_BlockBarrel"] = Instance.new("BoolValue")
                    _G["_BlockBarrel"].Name = "BlockBarrel"
                end

                _G["_BlockBarrel"].Parent = ReplicatedStorage
            elseif ReplicatedStorage:FindFirstChild("BlockBarrel") then 
                _G["_BlockBarrel"].Parent = ReplicatedFirst
            end

            local Enabled = (_G["_BlockBarrel"].Parent == ReplicatedStorage) and "enabled" or "disabled"
			print(`[INFO # BlockBarrelBind]: Barrel blocking is now {Enabled}.`)
		end
	end
end)

_G["ShoveEquipper"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then
		if (Key.KeyCode == Enum.KeyCode.G) and LocalPlayer.Character then
			local Character:Model = LocalPlayer.Character
			Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))::Backpack

			local Weapon:Tool = (Backpack:FindFirstChild("Axe") 
				or Backpack:FindFirstChild("Carbine")
				or Backpack:FindFirstChild("Navy Pistol")
				or Backpack:FindFirstChild("Pickaxe"))::Tool

			if Weapon then
				Weapon.Parent = Character
			end
		end
	end
end)

_G["ShoveBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Enum.KeyCode.Q) then 
			if LocalPlayer.Character and LocalPlayer.Character.Parent then
				local Character = LocalPlayer.Character
				local HRP = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
				local AgentsInRange = GetAgentsInRange(false, ShoveRange)

				if (type(AgentsInRange) ~= "table") then 
					warn(`[FAIL # ShoveBind]: AgentsInRange is not a table.  ||| Current script line: {debug.info(1, "l")}  ||| Current script line: {debug.info(1, "l")}`)

					return
				end

				if (#AgentsInRange <= 0) then
					warn(`[FAIL # ShoveBind]: No agents found within a range of {ShoveRange} studs.  ||| Current script line: {debug.info(1, "l")}`)

					return
				end

				if not HRP then 
					warn(`[FAIL # ShoveBind]: Character has no HumanoidRootPart/Torso?  ||| Current script line: {debug.info(1, "l")}`)

					table.clear(AgentsInRange)
					return
				end

				Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))::Backpack
				local Weapon:Tool = (Character:FindFirstChild("Axe") 
					or Character:FindFirstChild("Carbine") 
					or Character:FindFirstChild("Navy Pistol")
					or Character:FindFirstChild("Pickaxe")
					or Backpack:FindFirstChild("Axe") 
					or Backpack:FindFirstChild("Carbine")
					or Backpack:FindFirstChild("Navy Pistol")
					or Backpack:FindFirstChild("Pickaxe"))::Tool

				if Weapon and (typeof(Weapon) == "Instance") and Weapon.Parent then
					local Remote = Weapon:FindFirstChildWhichIsA("RemoteEvent")

					if Remote then
						if (Weapon.Name == "Axe") or (Weapon.Name == "Pickaxe") then
							Remote:FireServer("BraceBlock")

							task.spawn(function()
								task.wait(0.25)
								if Remote and Remote.Parent then
									Remote:FireServer("StopBraceBlock")
								end
							end)
						elseif (Weapon.Name == "Carbine") or (Weapon.Name == "Navy Pistol" )then
							Remote:FireServer("Shove")
						end

						IterateWithFunction(AgentsInRange, function(Key, Agent)
							if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
								local StunArgs:{[number]:any} = {
									[1] = "FeedbackStun";
									[2] = Agent;
									[3] = Agent.PrimaryPart and Agent.PrimaryPart.Position or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position;
								}

								Remote:FireServer(unpack(StunArgs))
							end

							task.wait()
						end)

						table.clear(AgentsInRange)
					elseif not Remote then 
						warn(`[FAIL # ShoveBind]: "Remote" if statement failed.  ||| Current script line: {debug.info(1, "l")}`)

						table.clear(AgentsInRange)
						return
					end
				else
					warn(`[FAIL # ShoveBind]: "Weapon" if statement failed.  ||| Current script line: {debug.info(1, "l")}`)

					table.clear(AgentsInRange)
					return
				end
			end
		end
	end
end)

_G["MurderBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Enum.KeyCode.Z) or (Key.KeyCode == Enum.KeyCode.X) then 
			if LocalPlayer.Character and LocalPlayer.Character.Parent then
				local List:{{}} = GetMeleeWeapon(true)

				for _, Table in pairs(List) do 
					local Weapon = Table[1]
					local WeaponRemote = Table[2]
					local LimitRange = Table[3]

					if Weapon and (typeof(Weapon) == "Instance") then 
						local AgentsInRange:{[number]:Model} = GetAgentsInRange(false, (LimitRange and (LimitRange * 1.8)) or MurderRange)

						if (type(AgentsInRange) ~= "table") then 
							warn(`[FAIL # MurderBind]: AgentsInRange is not a table.  ||| Current script line: {debug.info(1, "l")}`)

							continue
						end

						if (#AgentsInRange <= 0) then
							warn(`[FAIL # MurderBind]: No agents found within a range of {LimitRange and (LimitRange * 1.8) or MurderRange} studs.  ||| Current script line: {debug.info(1, "l")}`)

							continue
						end

						if WeaponRemote and WeaponRemote:IsA("RemoteEvent") then 						
							if (Weapon.Name ~= "Musket") then
								if (Weapon.Name == "Spade") then 
									WeaponRemote:FireServer("Swing", "Over")
								else
									WeaponRemote:FireServer("Swing", "Side")
								end

								IterateWithFunction(AgentsInRange, function(Key:any, Agent:Model) 
									if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
										local HitArgs:{[number]:any} = {
											[1] = "HitZombie";
											[2] = Agent;
											[3] = (Agent.PrimaryPart and Agent.PrimaryPart.Position) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position;
											[4] = true;
											[5] = (UseVectorLibrary and vector.create(math.random(-4096, 4096), math.random(-4096, 4096), math.random(-4096, 4096))) or Vector3.new(math.random(-4096, 4096), math.random(-4096, 4096), math.random(-4096, 4096));
											[6] = (Agent:FindFirstChild("Head") and "Head") or "HumanoidRootPart";
											[7] = (Agent.PrimaryPart and Agent.PrimaryPart.CFrame.LookVector * 5) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).CFrame.LookVector * 5;
										}

										WeaponRemote:FireServer(unpack(HitArgs))
									end
								end)
							elseif (Weapon.Name == "Musket") then
								WeaponRemote:FireServer("ThrustBayonet")

								for _, Agent in pairs(AgentsInRange) do 
									if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
										local HitArgs:{[number]:any} = {
											[1] = "Bayonet_HitZombie";
											[2] = Agent;
											[3] = (Agent.PrimaryPart and Agent.PrimaryPart.Position) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position;
											[4] = true;
										}

										WeaponRemote:FireServer(unpack(HitArgs))
										break
									end
								end
							end

							table.clear(AgentsInRange)
						else
							warn(`[FAIL # MurderBind]: "WeaponRemote" if statement failed.  ||| Current script line: {debug.info(1, "l")}`)

							table.clear(AgentsInRange)
							continue
						end
					else
						warn(`[FAIL # MurderBind]: "Weapon" if statement failed.  ||| Current script line: {debug.info(1, "l")}`)

						continue
					end

					task.wait(0.5)
				end
			end
		end
	end
end)

_G["GrabLogBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Enum.KeyCode.KeypadOne) and LocalPlayer.Character then
			local Character:Model = LocalPlayer.Character
			local Berezina = Workspace:FindFirstChild("Berezina")

			if Berezina then 
				local Modes = Berezina:FindFirstChild("Modes") or Berezina:WaitForChild("Modes", 1)

				if Modes then 
					local Holdout = Modes:FindFirstChild("Holdout") or Modes:WaitForChild("Holdout", 1)

					if Holdout then 
						local EscapeRoute = Holdout:FindFirstChild("EscapeRoute") or Holdout:WaitForChild("EscapeRoute")

						if EscapeRoute then
							local Logs = (EscapeRoute:FindFirstChild("SupplyWagon") and (EscapeRoute:FindFirstChild("SupplyWagon")::Instance):FindFirstChild("Logs") or false)

							if (type(Logs) ~= "boolean") and (typeof(Logs) == "Instance") and (#Logs:GetChildren() > 0) then
								for _, Log in pairs(Logs:GetChildren()) do 
									if Log and Log:IsA("Model") and (Log.Name == "Model") and Log:FindFirstChild("Handle") and (Log:FindFirstChild("Handle")::MeshPart):FindFirstChild("Interact") then 
										((Log:FindFirstChild("Handle")::MeshPart):FindFirstChild("Interact")::RemoteEvent):FireServer()

										local LogTool = (Character:FindFirstChild("Log") or WaitForChildWhichIsA(Character, "Tool", 1))
										if LogTool and (typeof(LogTool) == "Instance") then
											task.wait()
											--LogTool.Parent = Backpack
										else
											continue
										end

										--task.wait()
										return
									else
										continue
									end
								end
							end
						end
						if Holdout:FindFirstChild("Log") then
							for _, Log in pairs(Holdout:GetChildren()) do 
								if Log and Log:IsA("Model") and (Log.Name == "Log") and Log:FindFirstChild("Log") and (Log:FindFirstChild("Log")::MeshPart):FindFirstChild("Interact") then 
									((Log:FindFirstChild("Log")::MeshPart):FindFirstChild("Interact")::RemoteEvent):FireServer()

									local LogTool = (Character:FindFirstChild("Log") or WaitForChildWhichIsA(Character, "Tool"))
									if LogTool and (typeof(LogTool) == "Instance") then
										task.wait()
										--LogTool.Parent = Backpack
									end

									--task.wait()
									return
								else
									continue
								end
							end
						elseif not Holdout:FindFirstChild("Log") then 
							warn("[FAIL # GrabLogBind]: There are no logs to interact with.")

							return
						end

						return
					end
				end

				warn(`[FAIL # GrabLogBind]: "Modes" or "Holdout" if statements failed?  ||| Current script line: {debug.info(1, "l")}`)
				return
			elseif not Berezina then 
				warn(`[FAIL # GrabLogBind]: The current map is not Berezina?  ||| Current script line: {debug.info(1, "l")}`)

				return
			end
		end
	end
end)

if Debug then
	if DebugPrints then
		print(`[DEBUG # INFO]: Connecting workspace.DescendantAdded script signal for global "FlameTouchRemover".`)
	end
	_G["FlameTouchRemover"] = Workspace.DescendantAdded:Connect(function(NewWorkspaceChild)
		if NewWorkspaceChild then
			if (NewWorkspaceChild.Name == "IgniterFire") and NewWorkspaceChild:IsA("BasePart") then
				NewWorkspaceChild.CanTouch = false
				local TouchInterest = NewWorkspaceChild:WaitForChild("TouchInterest", 3)

				if TouchInterest then
					TouchInterest:Destroy()
				end
			end
		end
	end)

--[[    _G["OnCharacterAdded"] = LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
        if NewCharacter then 
            local GrabRemote:RemoteEvent
            local Attempts:number = 0
            local MaxAttempts:number = 10

            repeat
                if NewCharacter and NewCharacter:FindFirstChild("GrabRemote") then 
                    GrabRemote = (NewCharacter:FindFirstChild("GrabRemote"))::RemoteEvent
                    break
                else
                    if not NewCharacter then 
                        break
                    end
                end
                Attempts += 1

                task.wait(0.05)
            until GrabRemote or (Attempts >= MaxAttempts)

            task.wait(0.1)

            repeat 
                task.wait()
            until (#(getconnections(GrabRemote.OnClientEvent)) >= 1)

            print(`[INFO # OnCharacterAdded]: Removing "OnClientEvent" connections from the LocalPlayer's "GrabRemote".`)
            for _, Connection:Connection in pairs(getconnections(GrabRemote.OnClientEvent)) do 
                Connection:Disable()
            end
        end
    end)]]
end

if (_G["AlreadyActive"] == nil) and CanUseHookMetamethod and CanUseGetNameCallMethod then 
	_G["AlreadyActive"] = true

	OldNameCall = hookmetamethod(game, "__namecall", function(Remote, ...)
		local Args = {...}
		local NamecallMethod = getnamecallmethod()

		if (Remote == LocalPlayer) and (NamecallMethod:lower() == "kick") then
			print("[INFO # AntiKick]: An attempt to kick the LocalPlayer was just prevented.")
			return
		end

		if not checkcaller() then
			if (NamecallMethod == "FireServer") then
				--// always returns "nil" technically
				--// (OldNameCall(Remote, unpack(Args)) == nil) = true / (Remote:FireServer(unpack(Args)) == nil) = true
				if (Remote == AFKSignal) or (Remote.Name == "OnAFKSignalReceived") then
					print(`[INFO # Namecall Hook]: "OnAFKSignalReceived" attempted to fire.`)
					return nil
				elseif (Remote.Name == "ForceKill") then 
					print(`[INFO # Namecall Hook]: "ForceKill" remote attempted to fire.`)
					return nil
				else
					if (Args[1] ~= nil) then 
						if (Args[1] == "UpdateAccuracy") then 
							Args[2] = 100
							Remote["FireServer"](Remote, unpack(Args))

							return nil
						elseif (Args[1] == "HitZombie") or (Args[1] == "Bayonet_HitZombie") or (Args[1] == "ThrustCharge") then 
							if (Args[2] ~= nil) and Args[2].Parent and (Args[2]:GetAttribute("Type") == "Barrel") and ReplicatedStorage:FindFirstChild("BlockBarrel") then
								print("[INFO # Namecall Hook]: Player just attempted to hit a barrel zombie, blocking request and replacing with request with nil.")
								return nil
							end

							if (type(Args[4]) == "boolean") then 
								if Args[4] then
									return Remote["FireServer"](Remote, unpack(Args))
								elseif not Args[4] then
									Args[4] = true
									Args[6] = (Args[2] and Args[2]:FindFirstChild("Head") and "Head") or Args[6]
									Remote["FireServer"](Remote, unpack(Args))

									return nil
								end

								return nil
							end

							return Remote["FireServer"](Remote, unpack(Args))
						elseif (Args[1] == "CancelReload") then 
							print("[INFO # Namecall Hook]: CancelReload argument blocked.")
							return nil
						elseif (Args[1] == "Swing") then 
							local Character = LocalPlayer.Character

							if Character then 
								local ToolFound = (
									Character:FindFirstChild("Spade") 
										or Character:FindFirstChild("Sabre") 
										or Character:FindFirstChild("Officer's Sabre") 
										or Character:FindFirstChild("Heavy Sabre")
										or Character:FindFirstChild("Axe")
								)::Tool

								if ToolFound then 
									Args[2] = "Over"
									Remote["FireServer"](Remote, unpack(Args))

									return nil
								end
							end

							return Remote["FireServer"](Remote, ...)
						elseif (Args[1] == "UpdateLook") and RubiksCube then
							--// probably a much better way to do this but
							--// i got lazy!
							--// only works with the hammer/claw hammer now

							local RandomNum1 = math.random(1, 6)
							local RandomNum2 = math.random(1, 6)
							local RandomNum3 = math.random(1, 6)

							Args[2] = math.random(-100, 1000)

							if RandomNum1 == 1 then
								Args[3] = LocalPlayer.Character.Torso["Neck"] or Args[3]
							elseif RandomNum1 == 2 then
								Args[3] = LocalPlayer.Character.Torso["Right Hip"] or Args[3]
							elseif RandomNum1 == 3 then
								Args[3] = LocalPlayer.Character.Torso["Left Shoulder"] or Args[3]
							elseif RandomNum1 == 4 then
								Args[3] = LocalPlayer.Character.Torso["Right Shoulder"] or Args[3]
							elseif RandomNum1 == 5 then
								Args[3] = LocalPlayer.Character.Torso["Left Hip"] or Args[3]
							elseif RandomNum1 == 6 then
								Args[3] = LocalPlayer.Character.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart["Root Hip"] or Args[3]
							else
								Args[3] = LocalPlayer.Character.Torso["Neck"] or Args[3]
							end

							if RandomNum2 == 1 then
								Args[4] = LocalPlayer.Character.Torso["Neck"] or Args[4]
							elseif RandomNum2 == 2 then
								Args[4] = LocalPlayer.Character.Torso["Right Hip"] or Args[4]
							elseif RandomNum2 == 3 then
								Args[4] = LocalPlayer.Character.Torso["Left Shoulder"] or Args[4]
							elseif RandomNum2 == 4 then
								Args[4] = LocalPlayer.Character.Torso["Right Shoulder"] or Args[4]
							elseif RandomNum2 == 5 then
								Args[4] = LocalPlayer.Character.Torso["Left Hip"] or Args[4]
							elseif RandomNum2 == 6 then
								Args[4] = LocalPlayer.Character.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart["Root Hip"] or Args[4]
							else
								Args[4] = LocalPlayer.Character.Torso["Neck"] or Args[4]
							end

							if RandomNum3 == 1 then
								Args[5] = LocalPlayer.Character.Torso["Neck"] or Args[5]
							elseif RandomNum3 == 2 then
								Args[5] = LocalPlayer.Character.Torso["Right Hip"] or Args[5]
							elseif RandomNum3 == 3 then
								Args[5] = LocalPlayer.Character.Torso["Left Shoulder"] or Args[5]
							elseif RandomNum3 == 4 then
								Args[5] = LocalPlayer.Character.Torso["Right Shoulder"] or Args[5]
							elseif RandomNum3 == 5 then
								Args[5] = LocalPlayer.Character.Torso["Left Hip"] or Args[5]
							elseif RandomNum3 == 6 then
								Args[5] = LocalPlayer.Character.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart["Root Hip"] or Args[5]
							else
								Args[5] = LocalPlayer.Character.Torso["Neck"] or Args[5]
							end

							return OldNameCall(Remote, unpack(Args))
						end
					end
				end
			end
		end

		return OldNameCall(Remote, ...)
	end)

	OldIndex = hookmetamethod(game, "__index", function(Self, Method)
		if (Self == LocalPlayer) and (Method:lower() == "kick") then
			if not _G["__PlaceholderFunction"] then
				_G["__PlaceholderFunction"] = function()
					print("[INFO # AntiKick]: An attempt to kick the LocalPlayer was just prevented.")
				end
			end

			return _G["__PlaceholderFunction"]
		end

		return OldIndex(Self, Method)
	end)
end

warn(
	([[ 
        [DISCORD]: @_x4yz

        [INFO]: Script successfully executed!
            [INFO # DETAILS]: Took %s seconds to execute fully.
               [INFO # DETAILS]: Usage of the global "vector" library is %s.
               [INFO # DETAILS]: "Debug" variable is %s.
               [INFO # DETAILS]: "DebugPrints" variable is %s.

            [INFO # MUSIC INFO]: {%s}
        
    ]]):format(
		tostring(tick() - OldTick),
		(UseVectorLibrary and "enabled" or "disabled"),
		(Debug and "enabled" or "disabled"),
		(DebugPrints and "enabled" or "disabled"),
		(function()
			local ReturnString:string = "\n                "

			local MaxIndexes:number = GetMaxIndexOfTable(MusicSelections)
			local CurrentIndex:number = 0
			for i:string, v:string in pairs(MusicSelections) do 
				CurrentIndex += 1

				if (CurrentIndex < MaxIndexes) then   
					ReturnString = (ReturnString..(`Key:  {i}   /   Song:  {v}            `.."\n                "))
				elseif (CurrentIndex >= MaxIndexes) then
					ReturnString =  (ReturnString..(`Key:  {i}   /   Song:  {v}            `.."\n             "))
				end
			end

			return ReturnString
		end)()
	)
)
