--!strict
--//// Discord: @_x4yz \\\\--
--// https://www.roblox.com/games/12334109280/UPDATE-Guts-Blackpowder

--//// Features Overview \\\\--
--// - Press **Q** to shove in an area when using a weapon (if shoving is supported for said weapon). 
--// - When fighting a group or horde of zombies, use **Z** or **X** to help clear them out.
--// - All melee hits are registered as headshots increasing your damage output.
--// - When "RubiksCube" is toggled on, equipping the hammer/claw hammer will scramble your character’s appearance like a Rubik’s Cube.
--// - Blocks the "OnAFKSignalReceived" and "ForceKill" remotes if they are called/fired by non-exploit scripts.
--// - Auto-repair requires having a hammer. Repairs work based on your proximity to the building, not the hammer itself (even if the hammer is far away, as long as your character is near the building, repairs will function).
--// - Check the developer console for errors or warnings (e.g., "[FAIL # example]: ...").
--// - Additional functionality may also be included.

--//// Key Bindings \\\\--
--// **Q**: Shove (Axe only).
--// **Z** / **X**: Clear zombies (Murder Bind).
--// **Keypad 1**: Grab Log Bind (only available in Berezina).
--// **Keypad 2**: Toggle auto-repair.
--// **Keypad 3**: Toggle building fetch type.
--// **Keypad 4**: Toggle "RubiksCube."
--// **U**, **F**, **G**, **H**, **J**, **Y**, **T**: Play music with fife or drum.

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
    if typeof(Parent) == "Instance" and type(ClassName) == "string" then
        local InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
        if InstanceToReturn then
            return InstanceToReturn
        end

        local UseTimeOut = (type(TimeOut) == "number")
        local EndedEarly: boolean = false
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
                    StringToOutput = StringToOutput:format("the \".Parent\" value of the \"Parent\" parameter being invalid.")
                end
            else
                StringToOutput = StringToOutput:format("the \".Parent\" value of the \"Parent\" parameter being invalid.")
            end
            
            print(StringToOutput)
        end

        return InstanceToReturn
    else
        if typeof(Parent) ~= "Instance" then
            warn("[FAIL # WaitForChildWhichIsA]: \"Parent\" is not an Instance.")
            return nil
        end
        if type(ClassName) ~= "string" then
            warn("[FAIL # WaitForChildWhichIsA]: \"ClassName\" is not a string.")
            return nil
        end
    end

    return nil
end

local LocalPlayer:Player = Players.LocalPlayer
local Backpack:Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))::Backpack

local Remotes = (ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", math.huge))::Folder
local AFKSignal = (Remotes:FindFirstChild("OnAFKSignalReceived") or Remotes:WaitForChild("OnAFKSignalReceived", math.huge))::RemoteEvent

local ZombiesFolder = (Workspace:FindFirstChild("Zombies") or Workspace:WaitForChild("Zombies", math.huge))::Folder
local BotsFolder = (Workspace:FindFirstChild("Bots") or Workspace:WaitForChild("Bots", math.huge))::Folder
local BuildingsFolder = (Workspace:FindFirstChild("Buildings") or Workspace:WaitForChild("Buildings", math.huge))::Folder
local Camera = (Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera"))::Camera

local Debug = true

local RubiksCube = false

local CanRepair = true
local BuildingBindEnabled = false
local HammerCanWarn = true
local BuildingFetchType = "Closest"

local HammerWarnDelay = 0.5
local NewZombieHeadWaitTime = 0.25
local WaitTimeUntilRepair = 0.125
local DefaultBeatWaitTime = 0.15

local ShoveRange = 15 --// default range variable used for shoving.
local MurderRange = 11 --// Used as a backup if can't find weapon range.

local HeadSizeToUse = Vector3.new(6, 9, 4.5)
local HeadTransparency = 0.6

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
local PreferredWeapon = "Pike"

--// Disconnection/Removing previous script connections if executed more than once.
if _G["FlameTouchRemover"] ~= nil then 
    _G["FlameTouchRemover"]:Disconnect()
    _G["FlameTouchRemover"] = nil
end

if _G["ShoveBind"] ~= nil then 
	_G["ShoveBind"]:Disconnect()
	_G["ShoveBind"] = nil
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

if _G["OnCharacterAdded"] then
    _G["OnCharacterAdded"]:Disconnect()
	_G["OnCharacterAdded"] = nil
end
--//

task.wait(0.2) --// Allow Luau's garbage collector to cleanup.

_G["OnCameraDescendantAdded"] = Camera.DescendantAdded:Connect(function(Head:Instance)
    task.spawn(function()
        if Head and not Head:IsA("Highlight") and Head:IsA("BasePart") and Head.Name == "Head" then 
            task.wait(NewZombieHeadWaitTime)

            local Character = Head and Head.Parent or nil
            if Character then 
                local IsIgniter = false
                local IsRunner = false
                local IsSapper = false
                local IsBomber = false

                if Head:FindFirstChild("Eat") then 
                    IsRunner = true
                end
                if Character:FindFirstChild("Axe") then 
                    IsSapper = true
                end
                if Character:FindFirstChild("Barrel") then 
                    IsBomber = true
                end

                for i, v in pairs(Character:GetChildren()) do 
                    if typeof(v) == "Instance" and v:IsA("Model") and v.Name == "Head" then 
                        IsIgniter = true
                        break
                    end

                    task.wait()
                end

                Head.Massless = true
                Head.Size = HeadSizeToUse or Vector3.new(3, 3, 3)
                Head.Transparency = HeadTransparency or 0.6
                Head.CastShadow = false
                if IsIgniter then
                    --// Igniter
                    local NewHighlight = Instance.new("Highlight")
                    Character:AddTag("Highlighted")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    NewHighlight.FillColor = Color3.fromRGB(255, 255, 0)
                    NewHighlight.Parent = Character
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = Character
                elseif IsRunner then
                    --// Runner
                    local NewHighlight = Instance.new("Highlight")
                    Character:AddTag("Highlighted")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                    NewHighlight.FillColor = Color3.fromRGB(0, 255, 255)
                    NewHighlight.Parent = Character
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = Character
                elseif IsSapper then 
                    --// Sapper
                    local NewHighlight = Instance.new("Highlight")
                    Character:AddTag("Highlighted")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(255, 0, 255)
                    NewHighlight.FillColor = Color3.fromRGB(255, 0, 255)
                    NewHighlight.Parent = Character
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = Character
                elseif IsBomber then 
                    --// Bomber
                    local NewHighlight = Instance.new("Highlight")
                    Character:AddTag("Highlighted")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(255, 123, 0)
                    NewHighlight.FillColor = Color3.fromRGB(255, 123, 0)
                    NewHighlight.Parent = Character
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = Character
                end

                --//for _, ZombPart:any in pairs(Character:GetChildren()) do 
                --//    if typeof(ZombPart) == "Instance" and ZombPart:IsA("BasePart") and ZombPart.Name ~= "Head" --[[and ZombPart.Name ~= "HumanoidRootPart"]] then 
                --//        ZombPart.CanQuery = false
                --//        ZombPart = nil
                --//    end
                --//end

                return
            end
        end
    end)
end)

_G["BuildHighlight"] = Instance.new("Highlight")
_G["BuildHighlight"].DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
_G["BuildHighlight"].OutlineColor = Color3.fromRGB(255, 204, 0)
_G["BuildHighlight"].FillColor = Color3.fromRGB(255, 204, 102)
_G["BuildHighlight"].Parent = ReplicatedFirst
_G["BuildHighlight"].FillTransparency = 0.5
_G["BuildHighlight"].Enabled = true

local LastBeatTick = 0
local _TimeSinceLastBeat = 0

--[=[
    Description:
    This function initializes a coroutine thread to simulate periodic accuracy updates for an instrument. 
    It utilizes a provided `RemoteEvent` to send accuracy-related data to the server at specified intervals.

    Parameters:
    - `RemoteEventToUse` (Instance<RemoteEvent>): The RemoteEvent instance to send accuracy-related updates.
    - `BeatWaitTime` (number?): Optional. The time interval (in seconds) between successive accuracy updates. 
      If not provided, invalid, or out of the allowed range (0 < `BeatWaitTime` < 10), it defaults to 0.15 seconds.

    Returns:
    - thread: A coroutine thread that repeatedly dispatches "UpdateAccuracy" events with a fixed accuracy value of 100.
      If `RemoteEventToUse` is invalid, the function returns an empty coroutine thread.

    Behavior:
    - Validates `RemoteEventToUse` to ensure it is a valid `RemoteEvent`. If not, a warning will be logged and an empty thread is returned.
    - Verifies `BeatWaitTime`:
        - If not provided or invalid, defaults to `DefaultBeatWaitTime`.
        - If the provided value is outside the range (0, 5), it defaults to 0.15 seconds.
    - The coroutine repeatedly fires "UpdateAccuracy" events to the server at the specified interval (`BeatWaitTime`).
    - In debug mode, logs the time elapsed between beats (`_TimeSinceLastBeat`) for diagnostic purposes.

    Notes:
    - Useful for simulating or testing accuracy update behavior for instruments.
    - The coroutine runs indefinitely until explicitly stopped.
    - Default behavior ensures safe and reliable operation within a reasonable time interval range.
]=]
local function SetupFakeAccuracyBeat(RemoteEventToUse:RemoteEvent, BeatWaitTime:number?):(thread)
    if typeof(RemoteEventToUse) ~= "Instance" or not RemoteEventToUse:IsA("RemoteEvent") then 
        warn("[FAIL # SetupFakeAccuracyBeat]: \"RemoteEventToUse\" is not an Instance, nor a RemoteEvent.")

        return coroutine.create(function() end)
    end

    if type(BeatWaitTime) ~= "number" then
        BeatWaitTime = DefaultBeatWaitTime
    elseif type(BeatWaitTime) == "number" then
        if (BeatWaitTime <= 0) or (BeatWaitTime >= 5) then
            BeatWaitTime = 0.15
        end
    end
    
    local NewThread = coroutine.create(function()
        while true do
            if Debug then
                if LastBeatTick ~= 0 then 
                    _TimeSinceLastBeat = (tick() - LastBeatTick)
                    if Debug then
                        --//warn("[DEBUG # Fake Accuracy Beat Thread]: _TimeSinceLastBeat = "..tostring(_TimeSinceLastBeat)..".")
                    end
                    LastBeatTick = tick()
                elseif LastBeatTick == 0 then 
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
    This function searches for a suitable melee weapon for the local player. It prioritizes the player's "PreferredWeapon" 
    but includes fallback logic to find other tools in the character or backpack. It also identifies and returns any 
    associated RemoteEvent and configuration attributes.

    Parameters:
    - None

    Returns:
    - Tool | nil: The tool instance found, if any.
    - RemoteEvent | nil: The RemoteEvent associated with the tool, if present.
    - boolean | nil: The "LimitRange" configuration attribute, if applicable.

    Behavior:
    - Validates the local player's character and its parent to ensure the player is active in the game.
    - Searches the character for a tool matching the `PreferredWeapon`. If found, it returns the tool, its RemoteEvent, 
      and its "LimitRange" attribute (if configured).
    - If the `PreferredWeapon` is not found, it searches for tools containing the server script "MeleeBase". If no such tool is found, 
      it prioritizes tools named "Musket" or "Shovel" as fallback options.
    - If no tool is found in the character, it searches the player's backpack using the same criteria.

    Notes:
    - Logs warnings if the character is missing or unparented.
    - Returns `nil` for all values if no suitable tool is located.
]=]
local function GetMeleeWeapon():(...any)
	local Character = LocalPlayer.Character

	if not Character then 
		warn("[FAIL # GetMeleeWeapon]: Your character doesn't exist?")

		return
	end

	if Character.Parent == nil then 
		warn("[FAIL # GetMeleeWeapon]: Your character's parent is equal to nil.")

		return
	end

    if Character:FindFirstChild(PreferredWeapon) then 
        local Tool = (Character:FindFirstChild(PreferredWeapon))::Tool
        
        return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
    end

    if Character:FindFirstChildWhichIsA("Tool") then
        for _, Tool in ipairs(Character:GetChildren()) do 
            if typeof(Tool) == "Instance" and Tool:IsA("Tool") and Tool.Parent then 
                if Tool:FindFirstChild("MeleeBase") then 
                    return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
				else
					if Tool.Name == "Musket" or Tool.Name == "Shovel" then 
						return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
					end
                end
            end
        end
    end

    if Backpack:FindFirstChildWhichIsA("Tool") then
        for _, Tool in ipairs(Backpack:GetChildren()) do 
            if typeof(Tool) == "Instance" and Tool:IsA("Tool") and Tool.Parent then 
                if Tool:FindFirstChild("MeleeBase") then 
                    return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent")
				else
					if Tool.Name == "Musket" or Tool.Name == "Shovel" then 
						return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent")
					end
                end
            end
        end
    end
    
	return
end

--[=[
    Description:
    This function retrieves agents within the "Zombies" and "Bots" folders located within a specified range of 
    a given position or the player's character. Agents whose "Type" attribute matches an entry in the `AgentTypeList` 
    table with a truthy value is excluded from the results. The function calculates distances in a 2D plane (ignoring Y-axis differences).

    Parameters:
    - `Position` (Vector3 | boolean): Specifies the center point for the search. If a Vector3 is provided, it is used as the position. 
      If `false` is passed, the function uses the player's character's position.
    - `Range` (number): Defines the radius of the search. Negative values are treated as positive. A default of 4 is used 
      for invalid or zero values.

    Returns:
    - `{[number]: any}`: A list of agents (models) within the specified range. Returns an empty table if no valid agents are found.

    Behavior:
    - Validates the input parameter 'Range'. If it is invalid or set to zero, the function assigns a default value of 4 to ensure proper functionality.
    - If the `Position` parameter is `false`, the function will attempt to use the LocalPlayer's character position. Logs warnings 
      if the character or its HumanoidRootPart/PrimaryPart is missing.
    - Iterates through the "Zombies" and "Bots" folders to find agents. Checks if:
      - The agent is a valid model with a parent.
      - The agent does not have a `ForceField` instance.
      - The agent's "Type" attribute is either absent or mapped to a false value in the `AgentTypeList`.
    - Calculates distances in a 2D plane between the specified position and each agent.
    - Adds valid agents to the results table. Includes agents with unknown or unlisted "Type" attributes.

    Notes:
    - Logs warnings for invalid inputs or missing character components.
    - Excludes agents with "Type" attributes marked as truthy in the `AgentTypeList`.
    - Implements robust handling for edge cases, including scenarios with missing agents or the addition of new agent types.

    Use Cases:
    - This function is ideal for detecting nearby enemies, NPCs, or objects in a game environment based on proximity.
    - It supports filtering by agent type and handling dynamic game scenarios.
]=]
local function GetAgentsInRange(Position:Vector3?|boolean?|nil, Range:number):{[number]:any}
	local AgentsInRange:{[number]:any} = {}
    
    if type(Range) ~= "number" then 
		warn("[FAIL # GetAgentsInRange]: \"Range\" is not a number.")

		return AgentsInRange
	end

	if Range == 0 or Range == (0/0) or Range == (-(0/0)) then 
		Range = 4
	elseif Range < 0 then 
		Range = -Range
	end

    local UsePosition:boolean = (typeof(Position) == "Vector3")
    local CharHRP:any
    if not UsePosition then
        local Character:Model = LocalPlayer.Character
        if not Character or not Character.Parent then
            warn("[FAIL # GetAgentsInRange]: You do not have a character?")

            return AgentsInRange
        end
        
        CharHRP = (Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart)::BasePart
        if not CharHRP or CharHRP:IsA("Model") then 
            warn("[FAIL # GetAgentsInRange]: No HumanoidRootPart/PrimaryPart found inside in the player's character.")

            return AgentsInRange
        end
    elseif UsePosition then
        CharHRP = Position
    end

	if #ZombiesFolder:GetChildren() > 0 then 
		for _, Agent in ipairs(ZombiesFolder:GetChildren()) do 
			if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent and not Agent:FindFirstChildWhichIsA("ForceField") then 
				local HRP = Agent.PrimaryPart or Agent:FindFirstChild("HumanoidRootPart")

				local ZombieType = Agent:GetAttribute("Type")
				local IgnoreVal = AgentTypeList[ZombieType]

				if HRP and type(IgnoreVal) == "boolean" and not IgnoreVal then 
					local Distance:number = (not UsePosition)
                        and (Vector3.new(CharHRP.Position.X, 0, CharHRP.Position.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
                        or (Vector3.new(CharHRP.X, 0, CharHRP.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude

					if Distance <= Range then 
						table.insert(AgentsInRange, Agent)
					end
				elseif HRP and type(IgnoreVal) ~= "boolean" then
					--// incase the agent's type is *new*, or not in the list.
					table.insert(AgentsInRange, Agent)
				end
            else
                table.insert(AgentsInRange, false)
			end
		end
	end

	if #BotsFolder:GetChildren() > 0 then 
		for _, Agent in ipairs(BotsFolder:GetChildren()) do 
			if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent and not Agent:FindFirstChildWhichIsA("ForceField") then 
				local HRP = Agent.PrimaryPart or Agent:FindFirstChild("HumanoidRootPart")

				local BotType = Agent:GetAttribute("Type")
				local IgnoreVal = AgentTypeList[BotType]

				if HRP and type(IgnoreVal) == "boolean" and not IgnoreVal then 
					local Distance = (not UsePosition)
                        and (Vector3.new(CharHRP.Position.X, 0, CharHRP.Position.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude
                        or (Vector3.new(CharHRP.X, 0, CharHRP.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude

					if Distance <= Range then 
						table.insert(AgentsInRange, Agent)
					end
				elseif HRP and type(IgnoreVal) ~= "boolean" then 
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

    Use Cases:
    - Iterating over configuration tables, applying transformations, or triggering specific actions for each entry.
    - Dynamically handling large datasets in-game systems with minimal blocking of the main thread.
]=]
local function IterateWithFunction(Table:{[any]: any}, Function:typeof(function(...) end), Instant:boolean?)
	if type(Instant) ~= "boolean" then
        Instant = true
    end

    if Table ~= nil and Function ~= nil then 
		if type(Table) ~= "table" then 
			warn("[FAIL # IterateWithFunction]: \"Table\" is not a table.")

			return
		end

		if type(Function) ~= "function" then 
			warn("[FAIL # IterateWithFunction]: \"Function\" is not a function.")

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
        if Table == nil then 
            warn("[FAIL # IterateWithFunction]: \"Table\" is equal to nil.")

            return
        end
        if Function == nil then 
            warn("[FAIL # IterateWithFunction]: \"Function\" is equal to nil.")

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
    - `Instance<NumberValue>`: The "BuildingHealth" instance with the lowest relative health.
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
local function GetBuildingWithLeastHealth():any
    local LocalPlayerUserId:number = LocalPlayer.UserId
	local Healths = {}

    local LocalPlayerBuildings = (BuildingsFolder:FindFirstChild(tostring(LocalPlayerUserId)))::Folder
    if not LocalPlayerBuildings then 
        return false
    end

	for _,  v in pairs(LocalPlayerBuildings:GetDescendants()) do
		if typeof(v) == "Instance" and v.Name == "BuildingHealth" and v:IsA("NumberValue") then 
			table.insert(Healths, v)
		end
	end

	if #Healths > 0 then 
		table.sort(Healths, function(Arg1, Arg2)
			return (Arg1.Value / (Arg1:GetAttribute("MaxHealth") or Arg1.Value) ) < (Arg2.Value / (Arg2:GetAttribute("MaxHealth") or Arg2.Value))
		end)

		if typeof(Healths[1]) == "Instance" then 
            return Healths[1]
        elseif not Healths[1] then 
            warn("[FAIL # GetBuildingWithLeastHealth]: Failed to get a \"BuildingHealth\" NumberValue.")
            return false
        end
    else
        warn("[FAIL # GetBuildingWithLeastHealth]: No buildings found?")
	end 

	return false
end

--[=[
    Description: 
    Identifies the closest player-made building to the local player's character by calculating the distance between the character and each building's "Bound" part. Returns the "BuildingHealth" instance of the closest building unless it is already at maximum health. If no valid building is found, or all are at maximum health, returns `false`. Returns `nil` if the local player has no buildings.

    Parameters: 
    - None

    Returns: 
    - `Instance<NumberValue>`: The "BuildingHealth" instance of the closest building.
    - `false`: If the closest building is at maximum health or no valid building is found.
    - `nil`: If the local player has no buildings.

    Notes:
    - The function checks that the local player's character exists and is properly parented.
    - Each building is represented by a "Bound" part, a `BasePart` instance within the player's building folder in `BuildingsFolder`.
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
    elseif ClosestBuilding == false then
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
		if typeof(v) == "Instance" and v.Name == "Bound" and v:IsA("BasePart") then 
			table.insert(Bounds, v)
		end
	end

	if #Bounds > 0 then 
		table.sort(Bounds, function(Arg1, Arg2)
            return (Arg1 and LocalPlayer:DistanceFromCharacter(Arg1.Position) or Vector3.new()) < (Arg2 and LocalPlayer:DistanceFromCharacter(Arg2.Position) or Vector3.new())
		end)

		if typeof(Bounds[1]) == "Instance" and typeof(Bounds[1].Parent) == "Instance" then 
            local BuildingHealth:NumberValue = (((Bounds[1].Parent)::Part):WaitForChild("BuildingHealth")::NumberValue)

            if ( BuildingHealth.Value >= (BuildingHealth:GetAttribute("MaxHealth") or BuildingHealth.Value) )  then 
                return false
            end

            return ((Bounds[1].Parent)::Part):WaitForChild("BuildingHealth")
        elseif not Bounds[1] then 
            warn("[FAIL # GetClosestBuilding]: Failed to find the closest building.")
            return false
        end
    else
        warn("[FAIL # GetClosestBuilding]: No buildings found?")
	end 

	return false
end

--[=[
    Description:
    Counts the total number of valid indices in a given table, including both array-like and dictionary-like indices. 
    If the input is invalid or `nil`, logs appropriate warnings and returns `0`.

    Parameters:
    - `Table: {[any]: any}`: The table whose indices are to be counted.

    Returns:
    - `number`: The total count of valid indices in the table.
    - `0`: If the input is `nil` or not of type `table`.

    Notes:
    - Differentiates between valid and invalid inputs, ensuring reliable results.
    - Treats all table indices (numeric and non-numeric) as valid for counting.
    - Provides helpful warnings for debugging when the input is `nil` or not a table.

    Example Usage:
    ```lua
    local SampleTable = {1, 2, 3, ["Key"] = "Value"}
    local MaxIndex = GetMaxIndexOfTable(SampleTable)
    print("Total indices:", MaxIndex)  -- Output: 4
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
    if Table ~= nil then 
		if type(Table) ~= "table" then 
			warn("[FAIL # GetMaxIndexOfTable]: \"Table\" is not a table. Returning 0")

			return 0
		end

		local CountToReturn = 0

        for i, v in pairs(Table) do 
            if i then
                CountToReturn += 1
            end
        end

        return CountToReturn
    else
        if Table == nil then 
            warn("[FAIL # GetMaxIndexOfTable]: \"Table\" is equal to nil. Returning 0")

            return 0
        end
	end

	return 0
end

_G["BuildingBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.KeypadTwo then 
            BuildingBindEnabled	= not BuildingBindEnabled
            print("[INFO # BuildingBind]: \"BuildingBindEnabled\" is now equal to: "..tostring(BuildingBindEnabled))

			if not BuildingBindEnabled then 
				_G["BuildHighlight"].Adornee = nil
			end
        end
    end
end)

_G["BuildingBindFunc"] = RunService.Stepped:Connect(function()
	if BuildingBindEnabled and LocalPlayer.Character then 
		local Character = LocalPlayer.Character
		local Hammer = Backpack:FindFirstChild("Hammer") 
			or Character:FindFirstChildWhichIsA("Tool")
			or Character:FindFirstChildWhichIsA("HopperBin")

		if Hammer and Hammer.Name == "Hammer" then
			local Remote = Hammer:FindFirstChild("RemoteEvent")

			if Remote then 
				local BuildingFound:NumberValue = (BuildingFetchType == "LeastHealth" and GetBuildingWithLeastHealth() or GetClosestBuilding())

				if type(BuildingFound) == "boolean" or not CanRepair or ( BuildingFound.Value >= (BuildingFound:GetAttribute("MaxHealth") or BuildingFound.Value) ) then 
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
                warn("[FAIL # BuildingBindFunc]: Failed to find the hammer's remote event.")
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
    if not Process and Key.KeyCode == Enum.KeyCode.KeypadThree then 
        if BuildingFetchType == "Closest" then 
            BuildingFetchType = "LeastHealth"
        else
            BuildingFetchType = "Closest"
        end

        print("[INFO # BuildingFetchTypeBind]: \"BuildingFetchType\" is now equal to: "..tostring(BuildingFetchType))
    end
end)

-- u f g h j k l
_G["MusicBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process and LocalPlayer.Character then 
        local Character = LocalPlayer.Character
		local KeyCodeName = tostring(Key.KeyCode.Name)
        local SongName = MusicSelections[KeyCodeName]

        if type(SongName) == "string" then 
            local FoundInstrument:Tool

            for i:string, v:boolean in pairs(AllowedInstruments) do 
                if type(i) == "string" and v then 
                    FoundInstrument = (Character:FindFirstChild(tostring(i)) or Backpack:FindFirstChild(tostring(i)))::Tool

                    if FoundInstrument then 
                        print("[INFO # MusicBind]: Found instrument \""..tostring(FoundInstrument.Name).."\".")
                        break
                    end
                end
            end

            if typeof(FoundInstrument) == "Instance" and FoundInstrument:IsA("Tool") then                 
                local Remote = (FoundInstrument:FindFirstChild("RemoteEvent"))::RemoteEvent
                
                if Remote then 
                    if _G["FakeAccuracyBeat"] ~= nil then 
                        coroutine.close(_G["FakeAccuracyBeat"])
                        _G["FakeAccuracyBeat"] = nil
                    end

                    print("[INFO # MusicBind]: Attempted to play \""..tostring(SongName).."\" with "..tostring(FoundInstrument.Name)..".")
                    
                    Remote:FireServer("Stop")
                    Remote:FireServer("Play", SongName)
                    _G["FakeAccuracyBeat"] = SetupFakeAccuracyBeat(Remote)

                    local Connection
                    Connection = FoundInstrument:GetPropertyChangedSignal("Parent"):Connect(function()
                        if FoundInstrument.Parent and FoundInstrument.Parent.Name == "Backpack" then 
                            if _G["FakeAccuracyBeat"] ~= nil then 
                                coroutine.close(_G["FakeAccuracyBeat"])
                                _G["FakeAccuracyBeat"] = nil
                            end
                            
                            Connection:Disconnect()
                        elseif not FoundInstrument.Parent then 
                            if _G["FakeAccuracyBeat"] ~= nil then 
                                coroutine.close(_G["FakeAccuracyBeat"])
                                _G["FakeAccuracyBeat"] = nil
                            end
                            
                            Connection:Disconnect()
                        end
                    end)
                elseif not Remote then 
                    warn("[FAIL # MusicBind]: Failed to find instrument remote event for the "..tostring(FoundInstrument.Name)..".")
                    
                    return
                end
            else
                --warn("[FAIL # MusicBind]: Failed to find an instrument to use.")

                return
            end
        end
    end
end)

_G["RubiksCubeBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.KeypadFour then 
            RubiksCube = not RubiksCube
            print("[INFO # RubiksCubeBind]: \"RubiksCube\" is now equal to: "..tostring(RubiksCube))
        end
    end
end)

_G["ShoveBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.Q then 
			if LocalPlayer.Character and LocalPlayer.Character.Parent then
				local Character = LocalPlayer.Character
				local HRP = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
				local AgentsInRange = GetAgentsInRange(false, ShoveRange)

				if type(AgentsInRange) ~= "table" then 
                    warn("[FAIL # ShoveBind]: \"AgentsInRange\" is not a table.")

					return
				end

				if (#AgentsInRange <= 0) then
					warn("[FAIL # ShoveBind]: No agents found within a range of "..tostring(ShoveRange).." studs.")
                    
					return
				end

				if not HRP then 
					warn("[FAIL # ShoveBind]: Character has no HumanoidRootPart/Torso?")
                    
                    table.clear(AgentsInRange)
					return
				end

				local Weapon = Character:FindFirstChild("Axe") 
                    or Character:FindFirstChild("Carbine") 
                    or Character:FindFirstChild("Navy Pistol")
                    or Character:FindFirstChild("Pickaxe")
                    or Backpack:FindFirstChild("Axe") 
                    or Backpack:FindFirstChild("Carbine")
                    or Backpack:FindFirstChild("Navy Pistol")
                    or Backpack:FindFirstChild("Pickaxe")

				if Weapon and typeof(Weapon) == "Instance" and Weapon.Parent then
					local Remote = Weapon:FindFirstChildWhichIsA("RemoteEvent")

					if Remote then
						if Weapon.Name == "Axe" or Weapon.Name == "Pickaxe" then
							Remote:FireServer("BraceBlock")

							task.spawn(function()
								task.wait(0.25)
								if Remote and Remote.Parent then
									Remote:FireServer("StopBraceBlock")
								end
							end)
						elseif Weapon.Name == "Carbine" or Weapon.Name == "Navy Pistol" then
							Remote:FireServer("Shove")
						end

						IterateWithFunction(AgentsInRange, function(Key, Agent)
							if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
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
                        warn("[FAIL # ShoveBind]: \"Remote\" if statement failed.")

                        table.clear(AgentsInRange)
                        return
					end
                else
                    warn("[FAIL # ShoveBind]: \"Weapon\" if statement failed.")

                    table.clear(AgentsInRange)
                    return
				end
			end
		end
	end
end)

_G["MurderBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.Z or Key.KeyCode == Enum.KeyCode.X then 
			if LocalPlayer.Character and LocalPlayer.Character.Parent then
				local Weapon:Tool, WeaponRemote:RemoteEvent, LimitRange:number = GetMeleeWeapon()

				if Weapon and typeof(Weapon) == "Instance" then 
                	local AgentsInRange:{[number]:Model} = GetAgentsInRange(false, LimitRange and (LimitRange * 1.8) or MurderRange)

                    if type(AgentsInRange) ~= "table" then 
                        warn("[FAIL # MurderBind]: \"AgentsInRange\" is not a table.")

                        return
                    end

                    if #AgentsInRange <= 0 then
                        warn("[FAIL # MurderBind]: No agents found within a range of "..tostring(LimitRange and (LimitRange * 1.8) or MurderRange).." studs.")

                        return
                    end

					if WeaponRemote and WeaponRemote:IsA("RemoteEvent") then 						
						if Weapon.Name ~= "Musket" then
							if Weapon.Name == "Spade" then 
                                WeaponRemote:FireServer("Swing", "Over")
                            else
                                WeaponRemote:FireServer("Swing", "Side")
                            end

							IterateWithFunction(AgentsInRange, function(Key:any, Agent:Model) 
								if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
									local HitArgs:{[number]:any} = {
										[1] = "HitZombie";
										[2] = Agent;
										[3] = (Agent.PrimaryPart and Agent.PrimaryPart.Position) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position;
										[4] = true;
                                        [5] = Vector3.new(0, 4096, 0);
                                        [6] = "HumanoidRootPart";
                                        [7] = (Agent.PrimaryPart and Agent.PrimaryPart.CFrame.LookVector * 5) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).CFrame.LookVector * 5;
									}
	
									WeaponRemote:FireServer(unpack(HitArgs))
								end
							end)
						elseif Weapon.Name == "Musket" then
							WeaponRemote:FireServer("ThrustBayonet")

                            for _, Agent in pairs(AgentsInRange) do 
                                if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
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
                        warn("[FAIL # MurderBind]: \"WeaponRemote\" if statement failed.")

                        table.clear(AgentsInRange)
                        return
					end
                else
                    warn("[FAIL # MurderBind]: \"Weapon\" if statement failed.")

                    return
				end
			end
		end
	end
end)

_G["GrabLogBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if not Process then 
        if Key.KeyCode == Enum.KeyCode.KeypadOne and LocalPlayer.Character then
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

                            if type(Logs) ~= "boolean" and typeof(Logs) == "Instance" and (#Logs:GetChildren() > 0) then
                                for _, Log in pairs(Logs:GetChildren()) do 
                                    if Log and Log:IsA("Model") and Log.Name == "Model" and Log:FindFirstChild("Handle") and (Log:FindFirstChild("Handle")::MeshPart):FindFirstChild("Interact") then 
                                        ((Log:FindFirstChild("Handle")::MeshPart):FindFirstChild("Interact")::RemoteEvent):FireServer()
                                        
                                        local LogTool = (Character:FindFirstChild("Log") or WaitForChildWhichIsA(Character, "Tool", 1))
                                        if LogTool and typeof(LogTool) == "Instance" then
                                            LogTool.Parent = Backpack
                                        end

                                        task.wait()
                                        --return
                                    else
                                        continue
                                    end
                                end
                            end
                        end
                        if Holdout:FindFirstChild("Log") then
                            for _, Log in pairs(Holdout:GetChildren()) do 
                                if Log and Log:IsA("Model") and Log.Name == "Log" and Log:FindFirstChild("Log") and (Log:FindFirstChild("Log")::MeshPart):FindFirstChild("Interact") then 
                                    ((Log:FindFirstChild("Log")::MeshPart):FindFirstChild("Interact")::RemoteEvent):FireServer()
                                    
                                    local LogTool = (Character:FindFirstChild("Log") or WaitForChildWhichIsA(Character, "Tool", 1))
                                    if LogTool and typeof(LogTool) == "Instance" then
                                        LogTool.Parent = Backpack
                                    end

                                    task.wait()
                                    --return
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

                warn("[FAIL # GrabLogBind]: \"Modes\" or \"Holdout\" if statements failed?")
                return
            elseif not Berezina then 
                warn("[FAIL # GrabLogBind]: The current map is not Berezina?")

                return
            end
        end
    end
end)

if Debug then
    print("[INFO # DEBUG]: The \"Debug\" variable is active.")
    _G["FlameTouchRemover"] = Workspace.DescendantAdded:Connect(function(NewWorkspaceChild)
        if NewWorkspaceChild then
            if NewWorkspaceChild.Name == "IgniterFire" and NewWorkspaceChild:IsA("BasePart") then
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
            until GrabRemote or Attempts >= MaxAttempts

            task.wait(0.1)

            repeat 
                task.wait()
            until #(getconnections(GrabRemote.OnClientEvent)) >= 1

            print("[INFO # OnCharacterAdded]: Removing \"OnClientEvent\" connections from the LocalPlayer's \"GrabRemote\".")
            for _, Connection:Connection in pairs(getconnections(GrabRemote.OnClientEvent)) do 
                Connection:Disable()
            end
        end
    end)]]
end

local OldNameCall = nil
local OldIndex = nil

if _G["AlreadyActive"] == nil then 
	_G["AlreadyActive"] = true

	OldNameCall = hookmetamethod(game, "__namecall", function(Remote, ...)
		local Args = {...}
		local NamecallMethod = getnamecallmethod()

		if Remote == LocalPlayer and (NamecallMethod:lower() == "kick") then
            print("[INFO # AntiKick]: An attempt to kick the LocalPlayer was just prevented.")
			return
	    end

		if not checkcaller() then
            if NamecallMethod == "FireServer" then
                --// always returns nil technically
                --// (OldNameCall(Remote, unpack(Args)) == nil) = true / (Remote:FireServer(unpack(Args)) == nil) = true
                if Remote == AFKSignal or Remote.Name == "OnAFKSignalReceived" then
                    print("[INFO # Namecall Hook]: \"OnAFKSignalReceived\" attempted to fire.")
                    return nil
                elseif Remote.Name == "ForceKill" then 
                    print("[INFO # Namecall Hook]: \"ForceKill\" remote attempted to fire.")
                    return nil
                else
                    if Args[1] ~= nil then 
                        if Args[1] == "UpdateAccuracy" then 
                            Args[2] = 100
                            Remote["FireServer"](Remote, unpack(Args))
                            
                            return nil
                        elseif Args[1] == "HitZombie" or Args[1] == "Bayonet_HitZombie" or Args[1] == "ThrustCharge" then 
                            if Args[2] ~= nil and Args[2].Parent and (Args[2]:GetAttribute("Type") == "Barrel") then
                                print("[INFO # Namecall Hook]: Player just attempted to hit a barrel zombie, blocking request and replacing with request with nil.")
                                return nil
                            end

                            if type(Args[4]) == "boolean" then 
                                if Args[4] then
                                    return Remote["FireServer"](Remote, unpack(Args))
                                elseif not Args[4] then
                                    Args[4] = true
                                    Args[6] = "Head"
                                    Args[5] = (Args[5] * 50)
                                    Args[7] = (Args[7] * 50)
                                    Remote["FireServer"](Remote, unpack(Args))
                                    
                                    return nil
                                end

                                return nil
                            end
                            
                            return Remote["FireServer"](Remote, unpack(Args))
                        elseif Args[1] == "CancelReload" then 
                            print("[INFO # Namecall Hook]: CancelReload argument blocked.")
                            return nil
                        elseif Args[1] == "Swing" then 
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
                        elseif Args[1] == "UpdateLook" and RubiksCube then
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
                                Args[3] = --[[Player.Character.Torso["Left Shoulder"] or Args[3] ]] LocalPlayer.Character.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart["Root Hip"] or Args[3]
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
                                Args[4] = --[[Player.Character.Torso["Left Shoulder"] or Args[4] ]] LocalPlayer.Character.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart["Root Hip"] or Args[4]
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
                                Args[5] = --[[Player.Character.Torso["Left Shoulder"] or Args[5] ]] LocalPlayer.Character.HumanoidRootPart and LocalPlayer.Character.HumanoidRootPart["Root Hip"] or Args[5]
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
        if Self == LocalPlayer and (Method:lower() == "kick") then
            return (function()
                print("[INFO # AntiKick]: An attempt to kick the LocalPlayer was just prevented.")
            end)
        end

        return OldIndex(Self, Method)
	end)
end

warn(
    ([[ 
        [DISCORD]: @_x4yz
        [INFO # END OF SCRIPT]: Script successfully executed!
            [INFO # DETAILS]: Took %s seconds to fully execute.
            [INFO # MUSIC INFO]: {%s}
        
    ]]):format(
        tostring(tick() - OldTick),
        (function()
            local ReturnString:string = "\n                "

            local MaxIndexes:number = GetMaxIndexOfTable(MusicSelections)
            local CurrentIndex:number = 0
            for i, v in pairs(MusicSelections) do 
                CurrentIndex += 1

                if CurrentIndex < MaxIndexes then   
                    ReturnString = ReturnString..([[Key:  %s   /   Song:  %s            ]].."\n                "):format(
                        tostring(i), tostring(v)
                    )
                elseif CurrentIndex >= MaxIndexes then
                    ReturnString = ReturnString..([[Key:  %s   /   Song:  %s            ]].."\n             "):format(
                        tostring(i), tostring(v)
                    )
                end
            end

            return ReturnString
        end)()
    )
)
