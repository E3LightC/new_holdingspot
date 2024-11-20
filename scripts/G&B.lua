--!strict
--//// @_x4yz \\\\--

--//// stuff. \\\\--
--// if you have an axe, and can shove with it, press Q \\--
--// when killing a group/horde of zombies, pressing Z or X will help with it will help clear them out \\--
--// all hits done with melee will be sent to the server as if you are hitting the head \\--
--// while "RubiksCube" is toggled on, when you have any gun/tool that updates the way you're looking, it will jumble your character up, like a rubik's cube! \\--
--// this script also blocks out the "OnAFKSignalReceived" remote and "ForceKill" remote if it is called by a non-exploit script \\--
--// for auto repair to work, you must have a hammer and at least have equipped it once (repair radius seems to be based on HumanoidRootPart or something else so you can technically repair something while the hammer is let us say, 3000 studs away, as long as your character is near the building) \\--
--// check developer console for errors, or any warning similar to " [FAIL # blahblahblah]: ... " \\--
--// and a few more things \\--

--//// binds \\\\--
--// Q / Shove Bind \\--
--// Z or X / Murder Bind \\--
--// Keypad 1 / Grab Log Bind (only works on Berezina) \\--
--// Keypad 2 to toggle auto repair \\--
--// Keypad 3 to toggle "RubiksCube" \\--
--// U, F, G, H, J, Y, T to play music with fife or drum. \\--

--[/////////////////////////////]--
--[/////////////////////////////]--
--[/////////////////////////////]--

local OldTick = tick()

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer:Player = Players.LocalPlayer
local Backpack:Backpack = LocalPlayer.Backpack

local Remotes = (ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", math.huge))::Folder
local AFKSignal = (Remotes:FindFirstChild("OnAFKSignalReceived") or Remotes:WaitForChild("OnAFKSignalReceived", math.huge))::RemoteEvent

local ZombiesFolder = (Workspace:FindFirstChild("Zombies") or Workspace:WaitForChild("Zombies", math.huge))::Folder
local BotsFolder = (Workspace:FindFirstChild("Bots") or Workspace:WaitForChild("Bots", math.huge))::Folder
local BuildingsFolder = (Workspace:FindFirstChild("Buildings") or Workspace:WaitForChild("Buildings", math.huge))::Folder
local Camera = (Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera"))::Camera

local RubiksCube = false

local CanRepair = true
local BuildingBindEnabled = false
local HammerCanWarn = true

local HammerWarnDelay = 0.25
local NewZombieHeadWaitTime = 0.25
local WaitTimeUntilRepair = 0.175
local FakeAccuracyBeatWaitTime = 0.15

local ShoveRange = 15 --// range variable that is used for shoving.
local MurderRange = 11 --// Used as a backup if can't find weapon range.

local HeadSizeToUse = Vector3.new(6, 9, 4.5)
local HeadTransparency = 0.6

--// true = ignore
--// false = don't ignore
local ZombieTypesList = {
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
    ["Fife"] = true; --// can play music while inside backpack and give buffs
    ["Drum"] = true; --// only can play while inside character
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

--// disconnecting and removing stuff if the script already has been executed.
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

if _G["GrabLogBind"] ~= nil then 
    _G["GrabLogBind"]:Disconnect()
	_G["GrabLogBind"] = nil
end
--//

task.wait(0.2) --// attempting to let Luau's garbage collector do its things
_G["OnCameraDescendantAdded"] = Camera.DescendantAdded:Connect(function(Head:Instance)
    task.spawn(function()
        if Head and not Head:IsA("Highlight") and Head:IsA("BasePart") and Head.Name == "Head" then 
            task.wait(NewZombieHeadWaitTime)

            local Character = Head.Parent
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

                for _, ZombPart:any in pairs(Character:GetChildren()) do 
                    if typeof(ZombPart) == "Instance" and ZombPart:IsA("BasePart") and ZombPart.Name ~= "Head" --[[and ZombPart.Name ~= "HumanoidRootPart"]] then 
                        ZombPart.CanQuery = false
                        ZombPart = nil
                    end
                end

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
    Info: This function uses coroutine functions to create a thread that repeatedly updates the accuracy of an instrument
        using its remote event emulating the actual system in a way.

    Parameter count: 1

    Parameter types: Instance(RemoteEvent)

    returns: thread
]=]
local function SetupFakeAccuracyBeat(RemoteEventToUse:RemoteEvent)
    if typeof(RemoteEventToUse) == "Instance" or not RemoteEventToUse:IsA("RemoteEvent") then 
        warn("[FAIL # SetupFakeAccuracyBeat]: \"RemoteEventToUse\" is not an Instance, nor a RemoteEvent")

        return coroutine.create(function() end)
    end
    
    local NewThread = coroutine.create(function()
        while true do
            if LastBeatTick ~= 0 then 
                _TimeSinceLastBeat = (tick() - LastBeatTick)
                --//--[[warn("[DEBUG # Fake Accuracy Beat Thread]: _TimeSinceLastBeat = "..tostring(_TimeSinceLastBeat)..".")]]
                LastBeatTick = tick()
            elseif LastBeatTick == 0 then 
                LastBeatTick = tick()
            end

            RemoteEventToUse:FireServer("UpdateAccuracy", 100)
            
            task.wait(FakeAccuracyBeatWaitTime)
        end
    end)
    coroutine.resume(NewThread)

    return NewThread
end

--[=[
    Info: This function requires that the local player's character does exist, and not be parented to nothing/nil.
        This function attempts to find a tool with the same name as whatever the "PreferredWeapon" string variable is equal to.
        If not found, then it continues to search for any tool that the local player's character contains with a server script named 
        "MeleeBase" within that said tool, if still not found then, it does the same thing but with the player's backpack.

    Parameter count: 0

    Parameter types: none

    returns: none
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
    Info: This function attempts to find all agents within the "Zombies" and "Bots" folders ignoring any agent that
        has an attribute named "Type" that is equal to true in the "ZombieTypesList" table variable that is within the 
        range of the "Range" number parameter.

    Parameter count: 1

    Parameter types: number

    returns: table
]=]
local function GetAgentsInRange(Range:number)
	if Range == nil then 
		warn("[FAIL # GetAgentsInRange]: \"Range\" is equal to nil.")

		return {}
	end

	if typeof(Range) ~= "number" then 
		warn("[FAIL # GetAgentsInRange]: \"Range\" is not a number.")

		return {}
	end

	if Range == 0 or Range == (0/0) or Range == (-(0/0)) then 
		Range = 4
	elseif Range < 0 then 
		Range = -Range
	end

	local Character:Model = LocalPlayer.Character
    if not Character or not Character.Parent then 
        return {}
    end

	local CharHRP = (Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart)::BasePart
	if not CharHRP or CharHRP:IsA("Model") then 
		warn("[FAIL # GetAgentsInRange]: No HumanoidRootPart/PrimaryPart found inside in the player's character.")

		return {}
	end

	local AgentsInRange = {}


		if #ZombiesFolder:GetChildren() > 0 then 
			for _, Agent in ipairs(ZombiesFolder:GetChildren()) do 
				if typeof(Agent) == "Instance" and Agent.Parent then 
					local HRP = Agent:FindFirstChild("HumanoidRootPart")

					local ZombieType = Agent:GetAttribute("Type")
					local IgnoreVal = ZombieTypesList[ZombieType]

					if HRP and typeof(IgnoreVal) == "boolean" and not IgnoreVal then 
						local Distance = (Vector3.new(CharHRP.Position.X, 0, CharHRP.Position.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude

						if Distance <= Range then 
							table.insert(AgentsInRange, Agent)
						end
					elseif HRP and typeof(IgnoreVal) ~= "boolean" then
						--// this is incase it is a new type, or renamed type.
						table.insert(AgentsInRange, Agent)
					end
				end
			end
		end

		if #BotsFolder:GetChildren() > 0 then 
			for _, Agent in ipairs(BotsFolder:GetChildren()) do 
				if typeof(Agent) == "Instance" and Agent.Parent then 
					local HRP = Agent:FindFirstChild("HumanoidRootPart")

					local BotType = Agent:GetAttribute("Type")
					local IgnoreVal = ZombieTypesList[BotType]

					if HRP and typeof(IgnoreVal) == "boolean" and not IgnoreVal then 
						local Distance = (Vector3.new(CharHRP.Position.X, 0, CharHRP.Position.Z) - Vector3.new(HRP.Position.X, 0, HRP.Position.Z)).Magnitude

						if Distance <= Range then 
							table.insert(AgentsInRange, Agent)
						end
					elseif HRP and typeof(IgnoreVal) ~= "boolean" then 
						--// this is incase it is a new type, or renamed type.
						table.insert(AgentsInRange, Agent)
					end
				end
			end
		end

		return AgentsInRange
end

--[=[
    Info: This function takes a table, and a function, then loops through the table firing said function with 
        the index and value.

    Example: SortFunc({
        [1] = "bob",
        [2] = "Cheese", 
        ["StringIndex"] = 1
        }, function(i, v) 
            print("index: "..tostring(i).."\n value: "..tostring(v))
        end,
        true
    )

    Parameter count: 3

    Parameter types: table, function, boolean or nil/nothing

    returns: none
]=]
local function SortFunc(Table:{[any]: any}, Func:typeof(function(...) end), Instant:boolean?)
	if typeof(Instant) ~= "boolean" then
        Instant = true
    end

    if Table ~= nil and Func ~= nil then 
		if typeof(Table) ~= "table" then 
			warn("[FAIL # SortFunc]: \"Table\" is not a table.")

			return
		end

		if typeof(Func) ~= "function" then 
			warn("[FAIL # SortFunc]: \"Func\" is not a function.")

			return
		end

		if Instant then 
            for i, v in pairs(Table) do
                task.spawn(Func, i, v)
            end
        elseif not Instant then
            for i, v in pairs(Table) do
                Func(i, v)
            end
        end
    else
        if Table == nil then 
            warn("[FAIL # SortFunc]: \"Table\" is equal to nil.")

            return
        end
        if Func == nil then 
            warn("[FAIL # SortFunc]: \"Func\" is equal to nil.")

            return
        end
	end

	return
end

--[=[
    Info: This function attempts to find the player-made building with the least amount of health in value, by 
        dividing the max health by the current health returning a value between 1 and 0 which is used to compare all the buildings.

    Parameter count: 0

    Parameter types: none

    returns: Instance(NumberValue)
]=]
local function GetBuildingWithLeastHealth():any
    local LocalPlayerUserId:number = LocalPlayer.UserId
	local Healths = {}

    local LocalPlayerBuildings = (BuildingsFolder:FindFirstChild(tostring(LocalPlayerUserId)))::Folder
    if not LocalPlayerBuildings then 
        return
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

local function GetMaxIndexOfTable(Table:{[any]: any})
    if Table ~= nil then 
		if typeof(Table) ~= "table" then 
			warn("[FAIL # GetMaxIndexOfTable]: \"Table\" is not a table.")

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
            warn("[FAIL # GetMaxIndexOfTable]: \"Table\" is equal to nil.")

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
				local BuildingWithLeastHealth:NumberValue = GetBuildingWithLeastHealth()

				if typeof(BuildingWithLeastHealth) == "boolean" or not CanRepair or ( BuildingWithLeastHealth.Value == BuildingWithLeastHealth:GetAttribute("MaxHealth") ) then 
					if not CanRepair then 
						return
					end

					_G["BuildHighlight"].Adornee = nil
					return
				end
				CanRepair = false

				Remote:FireServer("Repair", BuildingWithLeastHealth)
				_G["BuildHighlight"].Adornee = BuildingWithLeastHealth.Parent

				task.spawn(function()
					task.wait(WaitTimeUntilRepair or 0.175)
					CanRepair = true
				end)
            elseif not Remote then 
                warn("[FAIL # MusicBind]: Failed to find the hammer's remote event.")
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

-- u f g h j k l
_G["MusicBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process and LocalPlayer.Character then 
        local Character = LocalPlayer.Character
		local KeyCodeName = tostring(Key.KeyCode.Name)
        local SongName = MusicSelections[KeyCodeName]

        if typeof(SongName) == "string" then 
            local FoundInstrument:Tool

            for i:string, v:boolean in pairs(AllowedInstruments) do 
                if typeof(i) == "string" and v then 
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
                warn("[FAIL # MusicBind]: Failed to find an instrument to use.")

                return
            end
        end
    end
end)

_G["RubiksCubeBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.KeypadThree then 
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
				local AgentsInRange = GetAgentsInRange(ShoveRange)

				if typeof(AgentsInRange) ~= "table" then 
                    warn("[FAIL # ShoveBind]: \"AgentsInRange\" is not a table.")

					return
				end

				if not HRP then 
					warn("[FAIL # ShoveBind]: Character has no HumanoidRootPart/Torso?")

					return
				end

				if (#AgentsInRange <= 0) then
					warn("[FAIL # ShoveBind]: No agents found within a range of "..tostring(ShoveRange).." studs.")
                    
					return
				end

				local Weapon = Character:FindFirstChild("Axe") 
                    or Character:FindFirstChild("Carbine") 
                    or Character:FindFirstChild("Navy Pistol")
                    or Backpack:FindFirstChild("Axe") 
                    or Backpack:FindFirstChild("Carbine")
                    or Backpack:FindFirstChild("Navy Pistol")

				if Weapon and typeof(Weapon) == "Instance" and Weapon.Parent then
					local Remote = Weapon:FindFirstChildWhichIsA("RemoteEvent")

					if Remote then
						if Weapon.Name == "Axe" then
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

						SortFunc(AgentsInRange, function(Key, Agent)
							if Agent ~= nil and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
								local StunArgs = {
									[1] = "FeedbackStun";
									[2] = Agent;
									[3] = Agent.PrimaryPart and Agent.PrimaryPart.Position or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position;
								}

								Remote:FireServer(unpack(StunArgs))
							end

							task.wait()
						end)
                    elseif not Remote then 
                        warn("[FAIL # ShoveBind]: \"Remote\" if statement failed.")

                        return
					end
                else
                    warn("[FAIL # ShoveBind]: \"Weapon\" if statement failed.")

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
                	local AgentsInRange:{[number]:Model} = GetAgentsInRange(LimitRange and (LimitRange * 1.8) or MurderRange)

                    if typeof(AgentsInRange) ~= "table" then 
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

							SortFunc(AgentsInRange, function(Key:any, Agent:Model) 
								if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent and Agent:FindFirstChild("State") then 
									local HitArgs:{[number]:any} = {
										[1] = "HitZombie";
										[2] = Agent;
										[3] = (Agent.PrimaryPart and Agent.PrimaryPart.Position) or (Agent:WaitForChild("HumanoidRootPart", math.huge)::BasePart).Position;
										[4] = true;
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
                    else
                        warn("[FAIL # MurderBind]: \"WeaponRemote\" if statement failed.")

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
            local Berezina = Workspace:FindFirstChild("Berezina")

            if Berezina then 
                local Modes = Berezina:FindFirstChild("Modes") or Berezina:WaitForChild("Modes", 1)

                if Modes then 
                    local Holdout = Modes:FindFirstChild("Holdout") or Modes:WaitForChild("Holdout", 1)

                    if Holdout then 
                        if Holdout:FindFirstChild("Log") then
                            for _, Log in pairs(Holdout:GetChildren()) do 
                                if Log and Log:IsA("Model") and Log.Name == "Log" and Log:FindFirstChild("Log") and (Log:FindFirstChild("Log")::MeshPart):FindFirstChild("Interact") then 
                                    ((Log:FindFirstChild("Log")::MeshPart):FindFirstChild("Interact")::RemoteEvent):FireServer()
                                    return
                                else
                                    continue
                                end
                            end
                        elseif not Holdout:FindFirstChild("Log") then 
                            warn("[FAIL # GrabLogBind]: There are no logs to interact with.")
                            
                            return
                        end
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

local OldNameCall = nil
local OldIndex = nil
if _G["AlreadyActive"] == nil then 
	_G["AlreadyActive"] = true

	OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
		local Args = {...}
		local NamecallMethod = getnamecallmethod()

		if Self == LocalPlayer and (NamecallMethod:lower() == "kick") then
			return
	    end

		if not checkcaller() then
            if NamecallMethod == "FireServer" then
                --// always returns "nil" technically
                --// (OldNameCall(Remote, unpack(Args)) == nil) = true / (Remote:FireServer(unpack(Args)) == nil) = true
                if Self == AFKSignal or Self.Name == "OnAFKSignalReceived" then
                    print("[INFO # Namecall Hook]: \"OnAFKSignalReceived\" attempted to fire.")
                    return nil
                elseif Self.Name == "ForceKill" then 
                    print("[INFO # Namecall Hook]: \"ForceKill\" remote attempted to fire.")
                    return nil
                else
                    if Args[1] ~= nil then 
                        if Args[1] == "UpdateAccuracy" then 
                            Args[2] = 100
                            Self["FireServer"](Self, unpack(Args))
                            
                            return nil
                        elseif Args[1] == "HitZombie" or Args[1] == "Bayonet_HitZombie" or Args[1] == "ThrustCharge" then 
                            if Args[2] ~= nil and Args[2].Parent and (Args[2]:GetAttribute("Type") == "Barrel") then
                                print("[INFO # Namecall Hook]: Player just attempted to hit a barrel zombie, blocking request and replacing with request with nil.")
                                return nil
                            end

                            if typeof(Args[4]) == "boolean" then 
                                if Args[4] then
                                    return Self["FireServer"](Self, unpack(Args))
                                elseif not Args[4] then
                                    Args[4] = true
                                    Self["FireServer"](Self, unpack(Args))
                                    
                                    return nil
                                end

                                return nil
                            end
                            
                            return Self["FireServer"](Self, unpack(Args))
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
                                    Self["FireServer"](Self, unpack(Args))
                                    
                                    return nil
                                end
                            end

                            return Self["FireServer"](Self, ...)
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

                            return OldNameCall(Self, unpack(Args))
                        end
                    end
                end
            end
		end

		return OldNameCall(Self, ...)
	end)

    OldIndex = hookmetamethod(game, "__index", function(Self, Method)
        if Self == LocalPlayer and (Method:lower() == "kick") then
            return error("Expected ':' not '.' calling member function Kick", 2)
        end

        return OldIndex(Self, Method)
    end)
end

warn(
    ([[ 
        [DISCORD]: @_x4yz
        [INFO # END OF SCRIPT]: script successfully executed!
            [INFO # DETAILS]: Took %s seconds to run.
            [INFO # Music Bind Info]: {%s}
        
    ]]):format(
        tostring(tick() - OldTick),
        (function()
            local ReturnString = "\n                "

            local MaxIndexes: number = GetMaxIndexOfTable(MusicSelections)
            local CurrentIndex = 0
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
