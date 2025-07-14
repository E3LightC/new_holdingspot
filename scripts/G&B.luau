--//// Discord: @_x4yz \\\\--
--// https://www.roblox.com/games/12334109280/Guts-Blackpowder
--//    Made with Wave and Swift. [https://getwave.gg] [https://getswift.gg] | This script should work with most executors, as most of it is standard Roblox Luau.
--//    Each function has a description if whoever is reading this is curious about what they do.
--//    * This script is entirely made from boredom and my passion for exploiting/pen-testing! *
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--//// Recent Changes \\\\--
--//        Converted all user input connections to use a table full of keycodes for easier ability to change binds.
--//        Grab log keybind removed, fixed in dev zone.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--//// Feature Overview \\\\--
--// [System Logging]
--//        All failures, errors, warnings, and other information are output to the Roblox Developer Console; also look out for outputs with standardized tags.
--//   (e.g., "[FAIL # EXAMPLE_CONTEXT]: ...", "[INFO # EXAMPLE_CONTEXT]: ...", "[DEBUG # EXAMPLE_CONTEXT]: ...").
--// [Input Bindings]
--//        [Q] — Shove nearby agents (if tool allows) (ignores "Barrel" agents).
--//        [Z] / [X] — AoE melee attack with current weapon.
--//        [G] — Auto-equip shove-capable tool from Backpack.
--//        [Numpad 1] — Toggle auto-repair system.
--//        [Numpad 2] — Switch auto-repair targeting mode.
--//        [Numpad 3] — Allow/disallow "Barrel" agents targeting.
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
--//        [Numpad 1] — Toggle auto-repair system.
--//        [Numpad 2] — Switch auto-repair targeting mode.
--//        [Numpad 3] — Allow/disallow "Barrel" zombie targeting.
--// [Music]
--//        [U, F, G, H, J, Y, T] — Play fife/drum songs; mapped via `MusicSelections`.
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--[///////////////////////////////////////////////////////////////////////////////////////////////////]--
--[/////////////////////////////////////////// CODE BELOW ////////////////////////////////////////////]--
--[///////////////////////////////////////////////////////////////////////////////////////////////////]--

local OldClock = os.clock()

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInputService = game:GetService("UserInputService")

local hookmetamethod:(
        Object:any,
        Metamethod:string,
        Hook:((...any) -> (...any))
) -> ((...any) -> (...any)) = getfenv().hookmetamethod
local getnamecallmethod:(
    nil
) -> (string) = getfenv().getnamecallmethod
local checkcaller:(
    nil
) -> (boolean) = getfenv().checkcaller
local getgenv = getfenv().getgenv or (function()
	return _G
end)

local CanUseHookMetamethod:boolean = (type(hookmetamethod) == "function")
local CanUseGetNameCallMethod:boolean = (type(getnamecallmethod) == "function")
local CanUseGetCheckCaller:boolean = (type(checkcaller) == "function")
if not CanUseHookMetamethod then
	warn("[WARNING]: Your executor does not support 'hookmetamethod'. The script will still run, but the hooking functionality will not execute.")
elseif not CanUseGetNameCallMethod then
    warn("[WARNING]: Your executor does not support 'getnamecallmethod'. The script will still run, but the hooking functionality will not execute.")
elseif not CanUseGetCheckCaller then
    warn("[WARNING]: Your executor does not support 'checkcaller'. The script will still run, but the hooking functionality will not execute.")
end
local OldNameCall = nil
local OldIndex = nil

--// Types for silencing warnings.
type VectorLibrary = { 
	create: (x:number, y:number, z:number) -> (Vector3);
	magnitude: (vec:Vector3) -> (number);
	normalize: (vec:Vector3) -> (Vector3);
	cross: (vec1:Vector3, vec2:Vector3) -> (Vector3);
	dot: (vec1:Vector3, vec2:Vector3) -> number;
	angle: (vec1:Vector3, vec2:Vector3, axis:Vector3) -> (number);
	floor: (vec:Vector3) -> (Vector3);
	ceil: (vec:Vector3) -> (Vector3);
	abs: (vec:Vector3) -> (Vector3);
	sign: (vec:Vector3) -> (Vector3);
	clamp: (vec:Vector3, min:Vector3, max:Vector3) -> (Vector3);
	max: (any:Vector3) -> (Vector3);
	min: (any:Vector3) -> (Vector3);

	zero: (Vector3);
	one: (Vector3);
}
type DebugLibrary = {
	info: (level:number, options:string) -> (any)
}
--//

local vector:VectorLibrary = (getfenv().vector) --// Since Wave doesn't have Lua's global "vector" class?
local debug:DebugLibrary = (getfenv().debug) --// Since debug.info isn't registered for some reason?
local ClientSubtitles:BindableEvent = (ReplicatedStorage:FindFirstChild("ClientSubtitles") or ReplicatedStorage:WaitForChild("ClientSubtitles", math.huge))::BindableEvent

--[=[
    Description:
    Generates a rich text string by replacing numbered placeholders with formatted font tags in a template.
    Useful for dynamically inserting colored and styled text into UI elements.

    Parameters:
    - `TemplateString: string`: The template string containing placeholders like `[1]`, `[2]`, etc.
    - `...: table`: A variable list of tables, each with:
        - `Text: string` (required) — the text to insert.
        - `Color: Color3 or string` (optional) — the color of the text, either a hex string or a Color3.
        - `Font: string` (optional) — the font to use, defaults to `"Roboto"`.

    Returns:
    - `string`: The generated rich text string. If an error occurs, it returns `"[NO_TEMPLATE]"`.

    Behavior:
    - Replaces `[n]` markers in the template with corresponding formatted text.
    - Invalid or missing data results in `[INVALID_DATA]` or `[INVALID_TEXT]` placeholders.
    - If `TemplateString` is invalid, it sends a client subtitle warning and logs a warning to the developer console.
    - Defaults to white color (`#FFFFFF`) and `"Merriweather"` font if not specified.

    Notes:
    - This function supports both Color3 and hex string color formats.
    - Designed for use with Roblox's `RichText` feature enabled.

    Example Usage:
    ```lua
    local Text = GenerateText("[1] won against [2]!", 
        {Text = "Player1", Color = Color3.new(1, 1, 0)}, 
        {Text = "Boss", Color = "#FF0000"}
    )
    TextLabel.Text = Text
    ```

    Edge Cases:
    - If `TemplateString` is not a string, a client subtitle is fired and "[NO_TEMPLATE]" is returned.
    - If a replacement table is missing, "[INVALID_DATA]" is inserted.
    - If `Text` inside the replacement table is not a string, "[INVALID_TEXT]" is inserted.

]=]
local function GenerateText(
    TemplateString:string, 
    ...
):(string)
    if (type(TemplateString) ~= "string") then 
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GenerateText] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
        warn(`[FAIL # GenerateText]: "TemplateString" parameter is not a string.  ||| Current script line: {debug.info(1, "l")}`)

        return ("[NO_TEMPLATE]")
    end

	local Parameters = {...}
	local Result = TemplateString:gsub("%[(%d+)%]", function(IndexString)
		local CurrentIndex = tonumber(IndexString)
		local Data = Parameters[CurrentIndex]
        
        if (type(Data) ~= "table") then 
            return ("[INVALID_DATA]")
        end
        if (type(Data["Text"]) ~= "string") then 
            Data["Text"] = ("[INVALID_TEXT]")
        end

		local Color = ((typeof(Data["Color"]) == "Color3") and `#{Data["Color"]:ToHex()}`) 
            or ((type(Data["Color"]) == "string") and Data["Color"]) 
            or "#FFFFFF"
		local Font = Data["Font"] or "Merriweather"

		return string.format("<font color=\"%s\" face=\"%s\">%s</font>", Color, Font, Data["Text"])
	end)

	return Result
end

--[=[
    Description:
    Waits for a child of a specific class type (`ClassName`) under the given `Parent` instance.
    Optionally accepts a `Name` to match and a `TimeOut` duration to limit how long to wait.
    Returns the found instance if successful, or `nil` if the inputs are invalid or if the wait fails.

    Parameters:
    - `Parent: Instance`: The instance to search within.
    - `ClassName: string`: The class name to search for (e.g., `"Model"`, `"RemoteEvent"`).
    - `Name: string?` (optional): If provided, the instance must also match this name.
    - `TimeOut: number?` (optional): If provided, the wait will be limited to this many seconds. If omitted, waits indefinitely.

    Returns:
    - `Instance | nil`: The first matching child instance found, or `nil` if not found or if parameters are invalid.

    Features:
    - **Flexible Class Filtering**: Uses `FindFirstChildWhichIsA` for type-specific child searches.
    - **Optional Name Match**: Supports exact name filtering for more precise results.
    - **Timeout Support**: Waits indefinitely or for a specified duration based on `TimeOut`.
    - **Safe Exit Conditions**:
        - Terminates if the parent is destroyed or becomes invalid.
        - Respects the timeout limit if provided.
    - **Informative Logging**:
        - Warnings for invalid `Parent` or `ClassName` types.
        - Info prints when early termination occurs due to timeout or hierarchy invalidation.

    Notes:
    - The function checks twice per cycle: once before `task.wait()` and once after.
    - If `Name` is provided, both class and name must match to return early.
    - Re-checks `Parent` validity in every loop iteration to avoid runtime errors.

    Example Usage:
    ```lua
    local Event = WaitForChildWhichIsA(ReplicatedStorage, "RemoteEvent", "GameRemote", 3)
    if Event then
        Event:FireServer("Fire", Vector3.new())
    else
        warn("RemoteEvent not found in time.")
    end

	local Name = nil
	local TimeOut = 3
	local RemoteEvent = WaitForChildWhichIsA(ReplicatedStorage, "RemoteEvent", Name, TimeOut)
    if RemoteEvent then
        print("Found an Instance which is a remote event without using the `Name` parameter!")
    else
        warn("RemoteEvent not found in time.")
    end
    ```

    Edge Cases:
    - Logs and returns `nil` if `Parent` is not an `Instance`.
    - Logs and returns `nil` if `ClassName` is not a `string`.
    - Returns `nil` if the timeout is reached or if `Parent` is destroyed mid-wait.

]=]
local function WaitForChildWhichIsA(
    Parent:Instance, 
    ClassName:string, 
    Name:string?, 
    TimeOut:number?
):(Instance|nil)
	if (typeof(Parent) == "Instance") and (type(ClassName) == "string") then
		local InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
		if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
			return InstanceToReturn
		end

		local UseTimeOut = (type(TimeOut) == "number")
		local EndedEarly:boolean = false
		local TimeOutWasReached:boolean = false

		if not UseTimeOut then
			repeat
				if not Parent or not Parent.Parent then
					EndedEarly = true
					break
				end
                InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end

                task.wait()
				InstanceToReturn = Parent and Parent:FindFirstChildWhichIsA(ClassName)
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end
			until ((typeof(InstanceToReturn) == "Instance") or EndedEarly or not Parent or not Parent.Parent)
		else
			local AbsTimeOut:number = math.abs(TimeOut or 1)
			local StartTime:number = os.clock()

			repeat
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
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end

                task.wait()
				InstanceToReturn = Parent and Parent:FindFirstChildWhichIsA(ClassName)
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end
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
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# WaitForChildWhichIsA] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
		if (typeof(Parent) ~= "Instance") then
			warn(`[FAIL # WaitForChildWhichIsA]: "Parent" parameter is not an Instance.  ||| Current script line: {debug.info(1, "l")}`)
			return nil
		end
		if (type(ClassName) ~= "string") then
			warn(`[FAIL # WaitForChildWhichIsA]: "ClassName" parameter is not a string.  ||| Current script line: {debug.info(1, "l")}`)
			return nil
		end
	end

	return nil
end

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
local BotsFolder:Folder = (Workspace:FindFirstChild("Bots"))::Folder
local BuildingsFolder:Folder = (Workspace:FindFirstChild("Buildings") or Workspace:WaitForChild("Buildings", math.huge))::Folder
local Camera:Camera = (Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera"))::Camera

local Debug:boolean = true
local DebugPrints:boolean = false
local UseVectorLibrary:boolean = true

local CanRepair:boolean = true
local BuildingBindEnabled:boolean = false
local HammerCanWarn:boolean = true
local BuildingFetchType:string = "Closest"
local HammerWarnDelay:number = 1.5
local WaitTimeUntilRepair:number = 0.125

local DefaultBeatWaitTime:number = 0.15
local ZombieESPWait:number = 0.25

local LastBeatTick:number = 0
local TimeSinceLastBeat:number = 0

local ShoveRange:number = 15 --// default range variable used for shoving.
local MurderRange:number = 11 --// used as a backup if can't find weapon range.

local HeadSizeToUse:Vector3 = (UseVectorLibrary and vector.create(6, 9, 4.5)) or Vector3.new(6, 9, 4.5)
local HeadTransparency:number = 0.6

local MAX_HIGHLIGHTS:number = 29

local PreferredWeapon:{string} = {"Pike";"Lance"}
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
local Binds = {
	["ShoveEquipper_Bind"] = Enum.KeyCode.G;
	["ShoveBind_Bind"] = Enum.KeyCode.Q;
	
	["MurderBind_BindOne"] = Enum.KeyCode.Z;
	["MurderBind_BindTwo"] = Enum.KeyCode.X;
	
	["BuildingBind_Bind"] = Enum.KeyCode.KeypadOne;
	["BuildingFetchTypeBind_Bind"] = Enum.KeyCode.KeypadTwo;
	["BlockBarrelBind_Bind"] = Enum.KeyCode.KeypadThree;
}
local HighlightPool = {} -- Stores unused highlights
local ActiveHighlights = {} -- Tracks highlights currently in use
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

--// disconnection of previous script connections if executed more than once.
if getgenv()["FlameTouchRemover"] ~= nil then 
	getgenv()["FlameTouchRemover"]:Disconnect()
	getgenv()["FlameTouchRemover"] = nil
end
if getgenv()["ShoveBind"] ~= nil then 
	getgenv()["ShoveBind"]:Disconnect()
	getgenv()["ShoveBind"] = nil
end
if getgenv()["ShoveEquipper"] ~= nil then
	getgenv()["ShoveEquipper"]:Disconnect()
	getgenv()["ShoveEquipper"] = nil
end
if getgenv()["MurderBind"] ~= nil then 
	getgenv()["MurderBind"]:Disconnect()
	getgenv()["MurderBind"] = nil
end
if getgenv()["MusicBind"] ~= nil then
	getgenv()["MusicBind"]:Disconnect()
	getgenv()["MusicBind"] = nil
end
if getgenv()["FakeAccuracyBeat"] ~= nil then
	coroutine.close(getgenv()["FakeAccuracyBeat"])
	getgenv()["FakeAccuracyBeat"] = nil
end
if getgenv()["OnCameraDescendantAdded"] ~= nil then 
	getgenv()["OnCameraDescendantAdded"]:Disconnect()
	getgenv()["OnCameraDescendantAdded"]= nil
end
if getgenv()["BuildingBind"] ~= nil then
	getgenv()["BuildingBind"]:Disconnect()
	getgenv()["BuildingBind"] = nil
end
if getgenv()["BuildingBindFunc"] ~= nil then
	getgenv()["BuildingBindFunc"]:Disconnect()
	getgenv()["BuildingBindFunc"] = nil
end
if getgenv()["BuildHighlight"] ~= nil then
	getgenv()["BuildHighlight"].Enabled = false
	getgenv()["BuildHighlight"]:Destroy()
	getgenv()["BuildHighlight"] = nil
end
if getgenv()["BuildingFetchTypeBind"] ~= nil then 
	getgenv()["BuildingFetchTypeBind"]:Disconnect()
	getgenv()["BuildingFetchTypeBind"] = nil
end
if getgenv()["BlockBarrelBind"] ~= nil then 
	getgenv()["BlockBarrelBind"]:Disconnect()
	getgenv()["BlockBarrelBind"] = nil
end
if getgenv()["OnCharacterAdded"] then
	getgenv()["OnCharacterAdded"]:Disconnect()
	getgenv()["OnCharacterAdded"] = nil
end

getgenv()["BuildHighlight"] = Instance.new("Highlight")
getgenv()["BuildHighlight"].DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
getgenv()["BuildHighlight"].OutlineColor = Color3.fromRGB(255, 204, 0)
getgenv()["BuildHighlight"].FillColor = Color3.fromRGB(255, 204, 102)
getgenv()["BuildHighlight"].Parent = ReplicatedFirst
getgenv()["BuildHighlight"].FillTransparency = 0.5
getgenv()["BuildHighlight"].Enabled = true

--[=[
    Description:
    Retrieves a `Highlight` instance from the reuse pool, or creates a new one if allowed.
    Enforces a maximum limit (`MAX_HIGHLIGHTS`) to prevent excessive instance creation.
    If the limit is reached and no pooled highlights are available, the oldest active highlight is recycled.

    Returns:
    - `Highlight`: A `Highlight` instance, either reused, newly created, or recycled.

    Features:
    - **Object Pooling**:
        - Prioritizes reuse from `HighlightPool` to minimize instance creation overhead.
    - **Instance Cap**:
        - Respects `MAX_HIGHLIGHTS` to avoid unbounded memory usage.
    - **Automatic Recycling**:
        - When the cap is reached, it recycles the oldest active highlight by clearing its `Adornee`.

    Notes:
    - Recycled highlights have their `Adornee` property cleared to prepare for reuse.
    - The function does not parent or configure the returned `Highlight`—that must be handled externally.

    Example Usage:
    ```lua
    local Highlight = GetHighlight()
    Highlight.Adornee = SomePart
    Highlight.FillColor = Color3.new(1, 0, 0)
    Highlight.Parent = SomePart
    ```

    Edge Cases:
    - If the pool is empty and the active list is at capacity, the first (oldest) highlight is always reused.
    - `HighlightPool` and `ActiveHighlights` must be properly initialized externally for this function to work correctly.

]=]
local function GetHighlight()
    if (#HighlightPool > 0) then
        return table.remove(HighlightPool)
    elseif (#ActiveHighlights < MAX_HIGHLIGHTS) then
        local NewHighlight = Instance.new("Highlight")
        table.insert(ActiveHighlights, NewHighlight)
        return NewHighlight
    else
        --//warn("[WARNING]: Highlight limit reached. Reusing the oldest highlight.")
        local OldestHighlight = ActiveHighlights[1]
        table.remove(ActiveHighlights, 1)
        OldestHighlight.Adornee = nil
        return OldestHighlight
    end
end

--[=[
    Description:
    Applies a visual ESP (Extra Sensory Perception) highlight effect to a zombie `Character` model based on its type (e.g., Igniter, Runner, etc.). 
    Uses a pooled `Highlight` system for performance, avoids re-highlighting already tagged characters, and supports cleanup when the character is removed.

    Parameters:
    - `Character: Model`: The zombie model to which the highlight effect should be applied.
    - `Head: BasePart?` (optional): The character's head part; if provided, it is recolored to match the ESP highlight.
    - `IsIgniter: boolean?` (optional): Whether the character is of type "Igniter".
    - `IsRunner: boolean?` (optional): Whether the character is of type "Runner".
    - `IsSapper: boolean?` (optional): Whether the character is of type "Sapper".
    - `IsBomber: boolean?` (optional): Whether the character is of type "Bomber".
    - `IsHeadless: boolean?` (optional): Whether the character is of type "Headless".
    - `IsCuirassier: boolean?` (optional): Whether the character is of type "Cuirassier".

    Returns:
    - `nil`: This function does not return a value. It handles all behavior internally.

    Features:
    - **Zombie Type Recognition**:
        - Determines zombie type based on provided boolean flags, defaulting to `"None"` if no type is matched.
    - **Highlight Pooling**:
        - Reuses highlights from a pool to optimize performance and prevent exceeding Roblox's instance limits.
    - **Safe Highlight Application**:
        - Applies `Highlight` only if the model is valid and not already tagged.
        - Uses `DepthMode = AlwaysOnTop` for better visibility.
    - **Auto Cleanup**:
        - Listens for the character's removal (`AncestryChanged`) to recycle the highlight instance back into the pool.
    - **Optional Head Color Sync**:
        - If a valid `Head` is given, it is recolored to match the ESP type.

    Notes:
    - Requires `HighlightPool`, `ESPColors`, and `ReplicatedFirst` to be defined externally.
    - Tag `"Highlighted_"` is used to prevent reapplying highlights to the same character.
    - If no available highlight exists, the function waits and retries after a delay using `task.delay`.

    Example Usage:
    ```lua
    for _, Zombie in ipairs(Zombies:GetChildren()) do
        if Zombie:IsA("Model") then
            local Head = Zombie:FindFirstChild("Head")
            AddEsp(Zombie, Head, true) --// Treat as an Igniter
        end
    end
    ```

    Edge Cases:
    - Logs an error and aborts if `Character` is not a valid `Model`.
    - Skips re-highlighting if the character already has the `Highlighted_` tag.
    - Retries automatically if no highlights are currently available from the pool.

]=]
local function AddEsp(
    Character:Model, 
    Head:BasePart?, 
    IsIgniter:boolean?, 
    IsRunner:boolean?, 
    IsSapper:boolean?, 
    IsBomber:boolean?, 
    IsHeadless:boolean?, 
    IsCuirassier:boolean?
):(nil)
	if (typeof(Character) ~= "Instance") or not Character:IsA("Model") then
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# AddEsp] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
        warn(`[FAIL # AddEsp]: "Character" parameter is not an Instance, nor a Model.  ||| Current script line: {debug.info(1, "l")}`)

		return
	end
	if Character:HasTag("Highlighted_") then
		return
	end

	local Type:string = (IsIgniter and "Igniter") 
		or (IsRunner and "Runner")
		or (IsSapper and "Sapper")
		or (IsBomber and "Bomber")
		or (IsHeadless and "Headless")
		or (IsCuirassier and "Cuirassier")
        or "None"

	if (type(Type) == "string") and (Type ~= "None") then
		local NewHighlight = GetHighlight()
		if not NewHighlight then
			task.delay(ZombieESPWait, AddEsp, Character, Head, IsIgniter, IsRunner, IsSapper, IsBomber, IsHeadless, IsCuirassier)
			return 
		end

		Character:AddTag("Highlighted_")
		NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		NewHighlight.OutlineColor = ESPColors[Type]
		NewHighlight.FillColor = ESPColors[Type]
		NewHighlight.FillTransparency = 0.5
		NewHighlight.Enabled = true
		NewHighlight.Adornee = Character
		NewHighlight.Parent = ReplicatedFirst
		
		local Connection
        Connection = Character.AncestryChanged:Connect(function()
            if not Character.Parent then
                NewHighlight.Adornee = nil
                NewHighlight.Enabled = false
                NewHighlight.Parent = nil
                table.insert(HighlightPool, NewHighlight) -- Return to pool
                Connection:Disconnect()
				Connection = nil
            end
        end)

		if Head and (typeof(Head) == "Instance" and Head:IsA("BasePart")) then
			Head.Color = ESPColors[Type]
		end
	end

    return
end

--[=[
    Description:
    Starts a coroutine that repeatedly fires a RemoteEvent to simulate an "accuracy beat" mechanic, likely used to maintain perfect accuracy or trick server-side systems. 
    This loop operates at a regular interval defined by `BeatWaitTime`, defaulting to a preset if the value is invalid or omitted.

    Parameters:
    - `RemoteEventToUse: RemoteEvent`: The `RemoteEvent` that will be fired to the server with the "UpdateAccuracy" signal.
    - `BeatWaitTime: number?` (optional): Time (in seconds) between each accuracy update. If omitted or invalid, defaults to `0.15`.

    Returns:
    - `thread`: The coroutine object representing the running loop. If input is invalid, returns an inert coroutine.

    Features:
    - **Validation and Fallbacks**:
        - Verifies that `RemoteEventToUse` is a valid `RemoteEvent` instance.
        - Uses a fallback `BeatWaitTime` (default 0.15s) if not provided or invalid.
    - **Accuracy Looping**:
        - Continuously sends an `"UpdateAccuracy"` signal with a value of `100` to the server.
        - Interval controlled via `BeatWaitTime`.
    - **Debug Mode**:
        - If `Debug` is enabled, logs the time between beats (`TimeSinceLastBeat`) using `os.clock()`.
        - Uses `LastBeatTick` and `DebugPrints` for internal debug output tracking.
    - **Safe Thread Creation**:
        - Gracefully handles invalid input by returning a do-nothing coroutine.
        - Coroutine is started immediately after creation with `coroutine.resume`.

    Notes:
    - Intended to be used in client-side scripts where regular accuracy updates are expected or required.
    - Will silently fail if `RemoteEventToUse` is invalid, but still return a coroutine to avoid runtime errors.

    Example Usage:
    ```lua
    local AccuracyBeatThread = SetupFakeAccuracyBeat(RemoteEvent, 0.2)
    ```

    Edge Cases:
    - If `RemoteEventToUse` is not a `RemoteEvent`, logs an error and returns an empty coroutine.
    - If `BeatWaitTime` is not a number, NaN, ≤ 0, or ≥ 5, the default of `0.15` is used.

]=]
local function SetupFakeAccuracyBeat(
    RemoteEventToUse:RemoteEvent, 
    BeatWaitTime:number?
):(thread)
	if (typeof(RemoteEventToUse) ~= "Instance") or not RemoteEventToUse:IsA("RemoteEvent") then 
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# SetupFakeAccuracyBeat] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
		warn(`[FAIL # SetupFakeAccuracyBeat]: "RemoteEventToUse" is not an Instance, nor a RemoteEvent.  ||| Current script line: {debug.info(1, "l")}`)

		return coroutine.create(function() end)
	end

	if (type(BeatWaitTime) ~= "number") then
		BeatWaitTime = DefaultBeatWaitTime
	else
		if (BeatWaitTime <= 0) or (BeatWaitTime >= 5) or (BeatWaitTime ~= BeatWaitTime) then
			BeatWaitTime = 0.15
		end
	end

	local NewThread:thread = coroutine.create(function()
		while true do
			if Debug then
				if (LastBeatTick ~= 0) then 
					TimeSinceLastBeat = (os.clock() - LastBeatTick)
					if DebugPrints then
						print(`[DEBUG # Fake Accuracy Beat Thread]: TimeSinceLastBeat = {TimeSinceLastBeat}.`)
					end
					LastBeatTick = os.clock()
				elseif (LastBeatTick == 0) then 
					LastBeatTick = os.clock()
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
    Attempts to find and return melee weapon tools associated with the local player’s character or backpack. 
    It prioritizes a predefined list of preferred weapons (`PreferredWeapon`), then scans the character and backpack for tools classified as melee weapons or certain ranged tools by name.
    Can return either the first found melee weapon’s details or a list of all melee weapons based on the `ListTools` flag.

    Parameters:
    - `ListTools: boolean?` (optional): 
        - If `true`, the function returns a list of all melee weapons found.
        - If `false` or omitted, returns only the first suitable melee weapon found.

    Returns:
    - If `ListTools` is `false` or omitted:
        - `table?`: A single-element array containing `{Tool, RemoteEvent, LimitRange}` for the first matching melee weapon found, or `nil` if none found.
    - If `ListTools` is `true`:
        - `table`: A list of tables, each containing `{Tool, RemoteEvent, LimitRange}` for every matching melee weapon found.
    - Returns `nil` if the player’s character or required instances are missing.

    Features:
    - **Prioritized Weapon Selection**: Checks a preferred weapon list first before scanning character and backpack.
    - **Flexible Output**: Supports returning either a single weapon or a comprehensive list.
    - **Robust Validation**: Validates existence and parenting of the player’s character before proceeding.
    - **Attribute Extraction**: Retrieves important weapon attributes like `LimitRange` from tool configuration.
    - **Supports Melee and Select Ranged Tools**: Identifies melee weapons by internal markers and includes specific ranged tools by name.
    - **Graceful Failure Handling**: Provides client subtitle warnings and debug logging if character is invalid.

    Details:
    - Checks if the local player’s character exists and is properly parented.
    - Searches weapons in the following order:
        1. Preferred weapons by name in the character.
        2. Any melee tool (identified by presence of "MeleeBase" scro[t]) in the character.
        3. Certain named weapons ("Musket", "Shovel", "Rifle") in the character.
        4. Same as (2) and (3), but in the player’s Backpack.
    - For each found tool, returns:
        - The `Tool` instance.
        - The first `RemoteEvent` child of the tool.
        - The "LimitRange" attribute from the tool’s "Configuration" child, if it exists.
    - If no weapons are found, returns `nil` or an empty list based on `ListTools`.
    - Fires client subtitles and warns if the character is missing or invalid.

    Notes:
    - Designed for use in Roblox where melee weapons are `Tool` instances with specific internal structure.
    - `PreferredWeapon` is expected to be a list of tool names (strings) prioritized for selection.
    - Uses `WaitForChildWhichIsA` to safely get the backpack if it’s not immediately available.
    - Returns early when not listing all tools for efficiency.

    Example Usage:
    ```lua
    -- Get first melee weapon
    local WeaponData = GetMeleeWeapon()
    if WeaponData then
        local Tool, RemoteEvent, LimitRange = unpack(WeaponData[1])
        print("Found weapon:", Tool.Name)
    end

    -- Get list of all melee weapons
    local AllWeapons = GetMeleeWeapon(true)
    for _, WeaponInfo in ipairs(AllWeapons) do
        local Tool = WeaponInfo[1]
        print("Weapon:", Tool.Name)
    end
    ```

    Edge Cases:
    - If the local player’s character is `nil` or unparented, warns and returns `nil`.
    - If no melee weapons are found and `ListTools` is `false`, returns `nil`.
    - If `ListTools` is `true` but no weapons found, returns an empty list.
]=]
local function GetMeleeWeapon(
    ListTools:boolean?
):(...any)
	local Character = LocalPlayer.Character

	if not Character then 
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetMeleeWeapon] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
		warn(`[FAIL # GetMeleeWeapon]: Your character doesn't exist?  ||| Current script line: {debug.info(1, "l")}`)

		return
	end

	if (Character.Parent == nil) then
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetMeleeWeapon] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
		warn(`[FAIL # GetMeleeWeapon]: Your character's parent is equal to \`nil\`.  ||| Current script line: {debug.info(1, "l")}`)

		return
	end

	local List:{any} = {}
    for _, ToolName in pairs(PreferredWeapon) do 
	    if Character:FindFirstChild(ToolName) then 
            local Tool = (Character:FindFirstChild(ToolName))::Tool

			if not ListTools then
				return {{Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")}}
			end
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

					return {{Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")}}
				else
					if (Tool.Name == "Musket") or (Tool.Name == "Shovel") or (Tool.Name == "Rifle") then 
						if ListTools then
							table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
							continue
						end

						return {{Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")}}
					end
				end
			end
		end
	end

    Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))::Backpack
	if Backpack:FindFirstChildWhichIsA("Tool") then
		for _, Tool in ipairs(Backpack:GetChildren()) do 
			if (typeof(Tool) == "Instance") and Tool:IsA("Tool") and Tool.Parent then 
				if Tool:FindFirstChild("MeleeBase") then
					if ListTools then
						table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
						continue
					end

					return {{Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")}}
				else
					if (Tool.Name == "Musket") or (Tool.Name == "Shovel") or (Tool.Name == "Rifle") then 
						if ListTools then
							table.insert(List, {Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")})
							continue
						end

						return {{Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")}}
					end
				end
			end
		end
	end

	return (ListTools and List) or nil
end

--[=[
    Description:
    Retrieves a list of agent models (Zombies and Bots) within a specified horizontal range from a given position or the local player's character position.
    Agents are filtered based on their "Type" attribute using an ignore list (`AgentTypeList`), and only agents without active ForceFields are considered.
    The function handles validation of input parameters and the local player’s character, and gracefully returns an empty list with warnings on errors.

    Parameters:
    - `Position: Vector3?` (optional):
        - The world position to check range from.
        - If `nil` or invalid, defaults to the local player's HumanoidRootPart or PrimaryPart position.
    - `Range: number`:
        - The radius within which agents are considered "in range".
        - If invalid or zero, defaults to 4.
        - Negative values are converted to positive.

    Returns:
    - `{[number]: Model}`: A list of agent models (instances of type "Model") found within the given range.
      - If no agents are found or errors occur, it returns an empty list.
      - May include `false` entries where invalid agents are encountered (possibly for debugging).

    Features:
    - **Flexible Positioning**: Accepts an explicit position or uses the local player’s character position if none is given.
    - **Horizontal Distance Calculation**: Computes distance ignoring vertical differences (Y-axis), focusing on the XZ-plane.
    - **Agent Type Filtering**: Uses `AgentTypeList` to optionally ignore certain agent types.
    - **ForceField Check**: Excludes agents currently protected by a ForceField.
    - **Supports Multiple Agent Sources**: Scans both `ZombiesFolder` and `BotsFolder` in the Workspace.
    - **Vector Library Optimization**: Uses a custom vector library for distance calculations if enabled, falling back to `Vector3` otherwise.
    - **Robust Error Handling**: Provides client subtitles and debug warnings for invalid parameters or missing character data.

    Details:
    - Validates `Range` parameter; defaults and sanitizes as needed.
    - Determines search position from provided `Position` or player's HumanoidRootPart/PrimaryPart.
    - Iterates through the children of `ZombiesFolder` and `BotsFolder`:
        - Checks instance type, parenting, and ForceField presence.
        - Retrieves the agent's primary part or HumanoidRootPart.
        - Checks agent's "Type" attribute against `AgentTypeList` to decide inclusion.
        - Calculates horizontal distance ignoring the Y-axis.
        - Adds an agent to the result list if within range or is an unknown type.
    - Returns a table containing all qualifying agent models.

    Usage Example:
    ```lua
    local AgentsNearPlayer = GetAgentsInRange(nil, 10)
    for _, Agent in ipairs(AgentsNearPlayer) do
        print("Agent nearby:", Agent.Name)
    end

    local SpecificPosition = Vector3.new(100, 0, 50)
    local AgentsNearPoint = GetAgentsInRange(SpecificPosition, 5)
    print(#AgentsNearPoint, "agents found near point.")
    ```

    Notes:
    - `ZombiesFolder` and `BotsFolder` are assumed to be folders in the Workspace containing agent models.
    - `AgentTypeList` is a table mapping agent types (string) to booleans indicating whether to ignore them (`true` to ignore).
    - `ClientSubtitles` and `GenerateText` are used for user feedback on errors.
    - The function can return `false` in the results list where invalid or filtered agents are found; this may be intentional for debugging or could be filtered out as needed.
	
]=]
local function GetAgentsInRange(
    Position:(Vector3|nil?), 
    Range:number
):{[number]:any}
	local AgentsInRange:{[number]:any} = {}

	if (type(Range) ~= "number") then 
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetAgentsInRange] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
		warn(`[FAIL # GetAgentsInRange]: "Range" is not a number.  ||| Current script line: {debug.info(1, "l")}`)
		
        return AgentsInRange
	end

	if (Range == 0) or (Range ~= Range) then 
		Range = 4
	elseif (Range < 0) then 
		Range = -Range
	end

	local UsePosition:boolean = (typeof(Position) == "Vector3")
	local CharHRP:any
	if not UsePosition then
		local Character = LocalPlayer.Character
		if not Character or not Character.Parent then
            ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetAgentsInRange] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
			warn(`[FAIL # GetAgentsInRange]: You do not have a character?  ||| Current script line: {debug.info(1, "l")}`)

			return AgentsInRange
		end

		CharHRP = (Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart)::BasePart
		if not CharHRP or CharHRP:IsA("Model") then 
            ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetAgentsInRange] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
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
    Iterates over all key-value pairs in a given table and applies a provided function to each pair.
    The iteration can be performed either instantly by spawning new tasks for each call (asynchronous),
    or sequentially (synchronously), based on the optional `Instant` parameter.

    Parameters:
    - `Table: {[any]: any}`:
        - The table to iterate over.
        - Must be a valid Lua table; otherwise, the function warns and returns early.
    - `Function: function`:
        - The function to call for each key-value pair.
        - The function is invoked with two arguments: the key and the value.
        - The function must be valid; otherwise, it warns and returns early.
    - `Instant: boolean?` (optional):
        - Defaults to `true`.
        - If `true`, each call to `Function` is spawned as a separate task asynchronously using `task.spawn`.
        - If `false`, the function is called synchronously for each pair, blocking until each call completes.

    Behavior:
    - Validates inputs and reports issues with client subtitles and console warnings.
    - If `Instant` is `true`, uses `task.spawn` to run each function call concurrently, which can improve performance for independent operations.
    - If `Instant` is `false`, runs the function calls one-by-one in the main thread.

    Returns:
    - None (returns `nil` explicitly).

    Usage Example:
    ```lua
    local SampleTable = {a = 1, b = 2, c = 3}
    
    -- Synchronous iteration
    IterateWithFunction(SampleTable, function(Key, Value)
        print(Key, Value)
    end, false)
    
    -- Asynchronous iteration
    IterateWithFunction(SampleTable, function(Key, Value)
        print(Key, Value)
    end) --// Instant defaults to true
    ```

    Notes:
    - This function can be useful for running operations on many items concurrently to improve responsiveness.
    - Be cautious with side-effects or shared state when using asynchronous iteration.
    - Input validation helps prevent silent failures and aids debugging.

]=]
local function IterateWithFunction(
    Table:{[any]:any}, 
    Function:((any, any) -> (any)), 
    Instant:boolean?
):(nil)
	if (type(Instant) ~= "boolean") then
		Instant = true
	end

	if (type(Table) ~= "table") then 
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# IterateWithFunction] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
		warn(`[FAIL # IterateWithFunction]: "Table" is not a table.  ||| Current script line: {debug.info(1, "l")}`)

		return
	end

	if (type(Function) ~= "function") then 
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# IterateWithFunction] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
		warn(`[FAIL # IterateWithFunction]: "Function" is not a function.  ||| Current script line: {debug.info(1, "l")}`)

		return
	end

	if Instant then 
		for Index:any, Key:any in pairs(Table) do
			task.spawn(Function, Index, Key)
		end
	else
		for Index:any, Key:any in pairs(Table) do
			Function(Index, Key)
		end
	end

	return
end

--[=[
    Description:
    Retrieves the building with the lowest health percentage owned by the local player.

    Behavior:
    - Finds the folder corresponding to the local player's buildings inside the global `BuildingsFolder`.
    - Collects all descendant `NumberValue` instances named "BuildingHealth" within that folder.
    - Sorts these health values based on their current health percentage relative to their maximum health.
      - Maximum health is read from the attribute `"MaxHealth"` on each `NumberValue`. If absent, uses the current value as max health.
    - Returns the `NumberValue` instance representing the building with the least health percentage.
    - If no buildings are found, or no valid health values exist, returns `false`.

    Parameters:
    - None (relies on global/local variables such as `LocalPlayer` and `BuildingsFolder`).

    Returns:
    - The `NumberValue` instance of the building health with the lowest health ratio, or
    - `false` if no valid building health is found or an error occurs.

    Error Handling:
    - Warns and fires a client subtitle message if the buildings folder for the player is missing.
    - Warns and fires a client subtitle if no valid "BuildingHealth" NumberValue is found after sorting.
    - Warns if no buildings are found under the player's folder.

    Usage:
    ```lua
    local LowestHealthBuilding = GetBuildingWithLeastHealth()
    if LowestHealthBuilding then
        print("Lowest health building found:", LowestHealthBuilding:GetFullName())
    else
        print("No building found or error occurred.")
    end
    ```

    Notes:
    - Assumes `BuildingsFolder` is a global or previously defined folder containing player buildings grouped by UserId.
    - Assumes `ClientSubtitles` and `GenerateText` are available for client-side notifications.

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
		else
            ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetBuildingWithLeastHealth] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
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
    Finds and returns the `BuildingHealth` NumberValue of the closest building to the local player's character,
    but only if that building is not already at full health.

    Behavior:
    - Checks if the local player's character exists and is properly parented.
    - Retrieves all descendant parts named "Bound" from the local player's buildings folder inside `BuildingsFolder`.
    - Sorts these parts based on their distance from the player using `DistanceFromCharacter()`.
      - Supports optional optimization via the `UseVectorLibrary` flag.
    - Checks the `BuildingHealth` NumberValue under the closest building:
      - If the building's current health is **below** its `MaxHealth` (or the current health if the attribute is missing), it returns the `BuildingHealth` value.
      - If the building is at full health, returns `false`.

    Parameters:
    - None (relies on global variables: `LocalPlayer`, `BuildingsFolder`, `UseVectorLibrary`, `ClientSubtitles`, `GenerateText`).

    Returns:
    - The `NumberValue` instance named `BuildingHealth` of the nearest building that is not at full health.
    - `false` if:
        - No valid buildings exist,
        - All buildings are at full health,
        - Any error occurs during the lookup or health evaluation.

    Error Handling:
    - Early return if the local player does not have a valid character.
    - Warns and fires a subtitle if the closest building can't be determined or is missing.
    - Warns if no building "Bound" parts were found for the local player.

    Usage:
    ```lua
    local NearestBuildingHealth = GetClosestBuilding()
    if NearestBuildingHealth then
        print("Closest damaged building health:", NearestBuildingHealth.Value)
    else
        print("No nearby damaged buildings found.")
    end
    ```

    Notes:
    - A "Bound" part is assumed to be a unique marker under each building model used for proximity checks.
    - The `BuildingHealth` NumberValue must be a direct child of the building model for this function to succeed.
    - Health check uses `(Value >= MaxHealth)` logic to determine if a building should be ignored.

]=]
local function GetClosestBuilding():(any)
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
				(Arg1 and LocalPlayer:DistanceFromCharacter(Arg1.Position) or vector.zero) 
					< 
					(Arg2 and LocalPlayer:DistanceFromCharacter(Arg2.Position) or vector.zero)
			)
		end)

		if (typeof(Bounds[1]) == "Instance") and Bounds[1].Parent then 
			local BuildingHealth:NumberValue = (((Bounds[1].Parent)::Part):WaitForChild("BuildingHealth")::NumberValue)

			if (BuildingHealth.Value >= ((BuildingHealth:GetAttribute("MaxHealth")::number) or BuildingHealth.Value))  then 
				return false
			end

			return ((Bounds[1].Parent)::Part):WaitForChild("BuildingHealth")
		else
            ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetClosestBuilding] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
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
    Counts and returns the number of key-value pairs in the provided table, regardless of whether the keys are sequential indices.
    This effectively returns the number of elements (entries) in the table.

    Behavior:
    - Verifies that the input is a table.
    - Iterates through all key-value pairs using `pairs()`.
    - Increments a counter for each valid key found.
    - Returns the final count.

    Parameters:
    - `Table: {[any]: any}` — The table to evaluate.

    Returns:
    - `number`: Total number of entries in the table.
      - Returns `0` if the input is `nil` or not a table.

    Error Handling:
    - If the input is `nil` or not a table:
        - Fires a subtitle message using `ClientSubtitles` and `GenerateText`.
        - Logs a warning with debug line info.
        - Returns `0`.

    Usage Example:
    ```lua
    local Data = { a = 1; b = 2; c = 3 }
    local Count = GetMaxIndexOfTable(Data)
    print("Total entries:", Count) --> Output: 3
    ```

    Notes:
    - This function is not limited to arrays or numerical indices; it supports any Lua table.
    - The function name may imply array indexing (`#` operator), but it uses a custom count, making it more reliable for dictionaries.

]=]
local function GetMaxIndexOfTable(
    Table:{[any]: any}
):(number)
	if (Table ~= nil) then 
		if (type(Table) ~= "table") then
            ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetMaxIndexOfTable] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
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
        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# GetMaxIndexOfTable] Invalid parameters were identified, check developer console for more information.   "; Color = "#FF5555";}), 4)
		if (Table == nil) then 
			warn(`[FAIL # GetMaxIndexOfTable]: "Table" is equal to \`nil\`. Returning 0.  ||| Current script line: {debug.info(1, "l")}`)

			return 0
		end
	end

	return 0
end

getgenv()["OnCameraDescendantAdded"] = Camera.DescendantAdded:Connect(function(
    Orig:Instance
):(nil)
	if Orig and not Orig:IsA("Highlight") and Orig:IsA("ObjectValue") and (Orig.Name == "Orig") then 
		repeat
			task.wait()
		until not Orig or Orig.Value and Orig.Parent
		if not Orig then
			return
		end
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

		local Head:BasePart
		if not IsIgniter then
			Head = (Character:FindFirstChild("Head") or Character:WaitForChild("Head", 3))::BasePart
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

		if IsRunner and Agent and Agent.Parent and Agent.PrimaryPart then
			local AgentPrimaryPart = Agent.PrimaryPart
			local FakePart = Instance.new("Part")
			FakePart.Name = "FakeHead"
			FakePart.Size = Head.Size
			FakePart.Transparency = Head.Transparency
			FakePart.CFrame = Head.CFrame
			FakePart.CanCollide = false
			FakePart.Parent = Character

			local Weld = Instance.new("Weld")
			Weld.Part0 = AgentPrimaryPart
			Weld.Part1 = FakePart
			Weld.Parent = AgentPrimaryPart

			Agent.ChildAdded:Connect(function(Hitbox:Instance)
				if Hitbox:IsA("Model") and string.find(Hitbox.Name, "_Reb_") then
					repeat 
						task.wait() 
					until not Hitbox or Hitbox.PrimaryPart
                    
					local PrimaryPart = Hitbox and Hitbox:IsDescendantOf(Workspace) and Hitbox.PrimaryPart

					if PrimaryPart then
						PrimaryPart.Anchored = true
					end
				end
			end)
		end

		coroutine.wrap(pcall)(AddEsp, Character, Head,
			IsIgniter,
			IsRunner,
			IsSapper,
			IsBomber,
			IsHeadless,
			IsCuirassier
		)
	end

    return
end)

getgenv()["BuildingBindFunc"] = RunService.Stepped:Connect(function()
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

				if (type(BuildingFound) == "boolean") or not CanRepair or (BuildingFound.Value >= ((BuildingFound:GetAttribute("MaxHealth")::number) or BuildingFound.Value)) then 
					if not CanRepair then 
						return
					end

					getgenv()["BuildHighlight"].Adornee = nil
					return
				end
				CanRepair = false

				Remote:FireServer("Repair", BuildingFound)
				getgenv()["BuildHighlight"].Adornee = BuildingFound.Parent

				task.spawn(function()
					task.wait(WaitTimeUntilRepair or 0.175)
					CanRepair = true
				end)
			else
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
end)

getgenv()["MusicBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
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
					if (getgenv()["FakeAccuracyBeat"] ~= nil) then 
						coroutine.close(getgenv()["FakeAccuracyBeat"])
						getgenv()["FakeAccuracyBeat"] = nil
					end

					print(`[INFO # MusicBind]: Attempted to play "{SongName}" with {FoundInstrument.Name}.`)

					Remote:FireServer("Stop")
					Remote:FireServer("Play", SongName)
					getgenv()["FakeAccuracyBeat"] = SetupFakeAccuracyBeat(Remote)

					local Connection
					Connection = FoundInstrument:GetPropertyChangedSignal("Parent"):Connect(function()
						if FoundInstrument.Parent and ((FoundInstrument.Parent).Name == "Backpack") then 
							if (getgenv()["FakeAccuracyBeat"] ~= nil) then 
								coroutine.close(getgenv()["FakeAccuracyBeat"])
								getgenv()["FakeAccuracyBeat"] = nil
							end

							Connection:Disconnect()
						elseif not FoundInstrument.Parent then 
							if (getgenv()["FakeAccuracyBeat"] ~= nil) then 
								coroutine.close(getgenv()["FakeAccuracyBeat"])
								getgenv()["FakeAccuracyBeat"] = nil
							end

							Connection:Disconnect()
						end
					end)
				else
                    ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# MusicBind] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
					warn(`[FAIL # MusicBind]: Failed to find instrument remote event for the "{FoundInstrument.Name}".  ||| Current script line: {debug.info(1, "l")}`)
					return
				end
			else
				return
			end
		end
	end
end)

getgenv()["ShoveEquipper"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then
		if (Key.KeyCode == Binds["ShoveEquipper_Bind"]) and LocalPlayer.Character then
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

getgenv()["ShoveBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Binds["ShoveBind_Bind"]) then 
			if LocalPlayer.Character and LocalPlayer.Character.Parent then
				local Character = LocalPlayer.Character
				local HRP = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
				local AgentsInRange = GetAgentsInRange(nil, ShoveRange)

				if (type(AgentsInRange) ~= "table") then
                    ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# ShoveBind] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4) 
					warn(`[FAIL # ShoveBind]: AgentsInRange is not a table.  ||| Current script line: {debug.info(1, "l")}  ||| Current script line: {debug.info(1, "l")}`)

					return
				end

				if (#AgentsInRange <= 0) then
					warn(`[FAIL # ShoveBind]: No agents found within a range of {ShoveRange} studs.  ||| Current script line: {debug.info(1, "l")}`)

					return
				end

				if not HRP then 
                    ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# ShoveBind] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
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
                        local ParentWasBackpack:boolean = false
                        if (Weapon.Parent == Backpack) then
                            ParentWasBackpack = true
                            Weapon.Parent = Character
                        end

						if (Weapon.Name == "Axe") or (Weapon.Name == "Pickaxe") then
							Remote:FireServer("BraceBlock")

							task.spawn(function()
								task.wait(0.25)
								if Remote and Remote.Parent then
									Remote:FireServer("StopBraceBlock")
								end
							end)
						elseif (Weapon.Name == "Carbine") or (Weapon.Name == "Navy Pistol") then
							Remote:FireServer("Shove")
						end

						IterateWithFunction(AgentsInRange, function(Key, Agent)
							if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
								Remote:FireServer("FeedbackStun", 
									Agent,
									(Agent.PrimaryPart and Agent.PrimaryPart.Position or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position)
								)
							end

							task.wait()
						end)

                        if ParentWasBackpack then 
                            Weapon.Parent = Backpack
                        end
						table.clear(AgentsInRange)
					else
                        ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# ShoveBind] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
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

getgenv()["MurderBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Binds["MurderBind_BindOne"]) or (Key.KeyCode == Binds["MurderBind_BindTwo"]) then 
			if LocalPlayer.Character and LocalPlayer.Character.Parent then
				local List:{{}} = GetMeleeWeapon(false)

				for _, Table in pairs(List) do 
					local Weapon = Table[1]
					local WeaponRemote = Table[2]
					local LimitRange = Table[3]

					if Weapon and (typeof(Weapon) == "Instance") then 
						local AgentsInRange:{[number]:Model} = GetAgentsInRange(nil, (LimitRange and (LimitRange * 1.8)) or MurderRange)

						if (type(AgentsInRange) ~= "table") then 
                            ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# MurderBind] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
							warn(`[FAIL # MurderBind]: AgentsInRange is not a table.  ||| Current script line: {debug.info(1, "l")}`)

							continue
						end

						if (#AgentsInRange <= 0) then
							warn(`[FAIL # MurderBind]: No agents found within a range of {LimitRange and (LimitRange * 1.8) or MurderRange} studs.  ||| Current script line: {debug.info(1, "l")}`)

							continue
						end

						if WeaponRemote and WeaponRemote:IsA("RemoteEvent") then			
							if (Weapon.Name ~= "Musket") and (Weapon.Name ~= "Rifle") then
								if (Weapon.Name == "Spade") then 
									WeaponRemote:FireServer("Swing", "Over")
								else
									WeaponRemote:FireServer("Swing", "Side")
								end

								IterateWithFunction(AgentsInRange, function(Key:any, Agent:Model) 
									if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
										WeaponRemote:FireServer("HitZombie",
											Agent,
											((Agent.PrimaryPart and Agent.PrimaryPart.Position) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position),
											true,
											(UseVectorLibrary and vector.create(math.random(-4096, 4096), math.random(-4096, 4096), math.random(-4096, 4096))) or Vector3.new(math.random(-4096, 4096), math.random(-4096, 4096), math.random(-4096, 4096)),
											((Agent:FindFirstChild("Head") and "Head") or "HumanoidRootPart"),
											((Agent.PrimaryPart and Agent.PrimaryPart.CFrame.LookVector * 5) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).CFrame.LookVector * 5)
										)
									end
								end)
							elseif (Weapon.Name == "Musket") or (Weapon.Name == "Rifle") then
								WeaponRemote:FireServer("ThrustBayonet")

								for _, Agent in pairs(AgentsInRange) do 
									if (typeof(Agent) == "Instance") and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
										WeaponRemote:FireServer("Bayonet_HitZombie",
											Agent,
											((Agent.PrimaryPart and Agent.PrimaryPart.Position) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position),
											true,
											(UseVectorLibrary and vector.create(math.random(-4096, 4096), math.random(-4096, 4096), math.random(-4096, 4096))) or Vector3.new(math.random(-4096, 4096), math.random(-4096, 4096), math.random(-4096, 4096)),
											((Agent:FindFirstChild("Head") and "Head") or "HumanoidRootPart"),
											((Agent.PrimaryPart and Agent.PrimaryPart.CFrame.LookVector * 5) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).CFrame.LookVector * 5)
										)
										break
									end
								end
							end

							table.clear(AgentsInRange)
						else
                            ClientSubtitles:Fire(GenerateText("[1]", {Text = "   [# MurderBind] A if statement has failed, check developer console for more information.   "; Color = "#FF5555";}), 4)
							warn(`[FAIL # MurderBind]: "WeaponRemote" if statement failed.  ||| Current script line: {debug.info(1, "l")}`)

							table.clear(AgentsInRange)
							continue
						end
					else
						warn(`[FAIL # MurderBind]: "Weapon" if statement failed.  ||| Current script line: {debug.info(1, "l")}`)

						continue
					end

					task.wait()
				end
			end
		end
	end
end)

getgenv()["BuildingBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Binds["BuildingBind_Bind"]) then 
			BuildingBindEnabled	= not BuildingBindEnabled
			print(`[INFO # BuildingBind]: "BuildingBindEnabled" is now equal to: {BuildingBindEnabled}`)

			if not BuildingBindEnabled then 
				getgenv()["BuildHighlight"].Adornee = nil
			end
		end
	end
end)

getgenv()["BuildingFetchTypeBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process and (Key.KeyCode == Binds["BuildingFetchTypeBind_Bind"]) then 
		if (BuildingFetchType == "Closest") then 
			BuildingFetchType = "LeastHealth"
		else
			BuildingFetchType = "Closest"
		end

		print(`[INFO # BuildingFetchTypeBind]: "BuildingFetchType" is now equal to: {BuildingFetchType}`)
	end
end)

getgenv()["BlockBarrelBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if (Key.KeyCode == Binds["BlockBarrelBind_Bind"]) then 
			if not ReplicatedStorage:FindFirstChild("BlockBarrel") then
                if not getgenv()["_BlockBarrel"] then
                    getgenv()["_BlockBarrel"] = Instance.new("BoolValue")
                    getgenv()["_BlockBarrel"].Name = "BlockBarrel"
                end

                getgenv()["_BlockBarrel"].Parent = ReplicatedStorage
            elseif ReplicatedStorage:FindFirstChild("BlockBarrel") then 
                getgenv()["_BlockBarrel"].Parent = ReplicatedFirst
            end

            local Enabled = (getgenv()["_BlockBarrel"].Parent == ReplicatedStorage) and "enabled" or "disabled"
			print(`[INFO # BlockBarrelBind]: Barrel blocking is now {Enabled}.`)
		end
	end
end)

if Debug then
	if DebugPrints then
		print(`[DEBUG # INFO]: Connecting "Workspace.DescendantAdded" script signal for global "FlameTouchRemover".`)
	end
	getgenv()["FlameTouchRemover"] = Workspace.DescendantAdded:Connect(function(NewWorkspaceChild)
		if NewWorkspaceChild then
			if (NewWorkspaceChild.Name == "IgniterFire") and NewWorkspaceChild:IsA("BasePart") then
				local TouchInterest = NewWorkspaceChild:WaitForChild("TouchInterest", 3)

				if TouchInterest then
					TouchInterest:Destroy()
				end
                NewWorkspaceChild.CanTouch = false
			end
		end
	end)

--[[    getgenv()["OnCharacterAdded"] = LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
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

if (getgenv()["AlreadyActive"] == nil) and CanUseHookMetamethod and CanUseGetNameCallMethod and CanUseGetCheckCaller then 
	getgenv()["AlreadyActive"] = true

	OldNameCall = hookmetamethod(game, "__namecall", function(Remote, ...)
		local Parameters = {...}
		local NamecallMethod = getnamecallmethod()

		if (Remote == LocalPlayer) and (NamecallMethod:lower() == "kick") then
			print(`[INFO # AntiKick]: An attempt to kick the "LocalPlayer" was just prevented.`)
			return
		end

		if not checkcaller() then
			if (NamecallMethod == "FireServer") then
				--// always returns "nil" technically
				--// (OldNameCall(Remote, unpack(Parameters)) == nil) = true / (Remote:FireServer(unpack(Parameters)) == nil) = true
				
				if (Remote == AFKSignal) or (Remote.Name == "OnAFKSignalReceived") then
					print(`[INFO # Namecall Hook]: "OnAFKSignalReceived" attempted to fire.`)
					return nil
				elseif (Remote.Name == "ForceKill") then 
					print(`[INFO # Namecall Hook]: "ForceKill" remote attempted to fire.`)
					return nil
				else
					if (Parameters[1] ~= nil) then 
						if (Parameters[1] == "UpdateAccuracy") then 
							Remote["FireServer"](Remote, "UpdateAccuracy", 100)

							return nil
						elseif (Parameters[1] == "HitZombie") or (Parameters[1] == "Bayonet_HitZombie") then 
							if (Parameters[2] ~= nil) and Parameters[2].Parent and (Parameters[2]:GetAttribute("Type") == "Barrel") and ReplicatedStorage:FindFirstChild("BlockBarrel") then
								print("[INFO # Namecall Hook]: Player just attempted to hit a barrel zombie, blocking request and replacing with request with nil.")
								return nil
							end

							if (type(Parameters[4]) == "boolean") then 
								if Parameters[4] then
									return Remote["FireServer"](Remote, unpack(Parameters))
								elseif not Parameters[4] then
									Parameters[4] = true
									if (Parameters[1] == "Bayonet_HitZombie") then 
										--// Bayonet_HitZombie takes 5 parameters, instead of 6.
										Parameters[5] = (Parameters[2] and Parameters[2]:FindFirstChild("Head") and "Head") or Parameters[5]
									else
										Parameters[6] = (Parameters[2] and Parameters[2]:FindFirstChild("Head") and "Head") or Parameters[6]
									end
									Remote["FireServer"](Remote, unpack(Parameters))

									return nil
								end

								return nil
							end

							return Remote["FireServer"](Remote, unpack(Parameters))
						elseif (Parameters[1] == "ChargeBayonet") or (Parameters[1] == "ThrustCharge")  then 
							local Agent = Parameters[2] and Parameters[2].Parent and (Parameters[2]:IsA("BindableEvent") and Parameters[2].Parent) or Parameters[2]
							if not Agent then 
								return nil
							end

							if Agent.Parent and (Agent:GetAttribute("Type") == "Barrel") and ReplicatedStorage:FindFirstChild("BlockBarrel") then
								print("[INFO # Namecall Hook]: Player just attempted to hit a barrel zombie, blocking request and replacing with request with nil.")
								return nil
							end

							Remote["FireServer"](Remote, unpack(Parameters))
							return nil
						elseif (Parameters[1] == "CancelReload") then 
							print(`[INFO # Namecall Hook]: "CancelReload" argument blocked.`)
							return nil
						elseif (Parameters[1] == "Swing") then 
							local Character = LocalPlayer.Character

							if Character then 
								local ToolFound = (
									Character:FindFirstChild("Spade") 
									    or Character:FindFirstChild("Axe")
                                        or Character:FindFirstChild("Pickaxe")
										or Character:FindFirstChild("Sabre") 
										or Character:FindFirstChild("Officer's Sabre") 
										or Character:FindFirstChild("Heavy Sabre")
								)::Tool

								if ToolFound then 
									if (ToolFound.Name == "Heavy Sabre") then 
										Parameters[2] = "Thrust"
									else
										Parameters[2] = "Over"
									end
									Remote["FireServer"](Remote, Parameters[1], Parameters[2])

									return nil
								end
							end

							return Remote["FireServer"](Remote, ...)
						end
					end
				end
			end
		end

		return OldNameCall(Remote, ...)
	end)

	OldIndex = hookmetamethod(game, "__index", function(Self, Method)
		if (Self == LocalPlayer) and (Method:lower() == "kick") then
			if not getgenv()["__PlaceholderFunction"] then
				getgenv()["__PlaceholderFunction"] = (function()
					print("[INFO # AntiKick]: An attempt to kick the LocalPlayer was just prevented.")
				end)
			end

			return getgenv()["__PlaceholderFunction"]
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
		tostring(os.clock() - OldClock),
		(UseVectorLibrary and "enabled" or "disabled"),
		(Debug and "enabled" or "disabled"),
		(DebugPrints and "enabled" or "disabled"),
		(function():(string)
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
ClientSubtitles:Fire("   Script successfully executed, <i>check developer console by pressing F9 or typing \"/console\" into chat to see more information.</i>   ")
