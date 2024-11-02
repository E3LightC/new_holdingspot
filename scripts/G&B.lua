--//// @_x4yz \\\\--

--//// stuff. \\\\--
--// if you have a axe, and are able to shove with it, press Q \\--
--// when killing a group/horde of zombies, pressing Z or X will help with it will help clear them out \\--
--// all hits done with melee will be sent to the server as if you hitting the head \\--
--// while "RubiksCube" is toggled on, when you have any gun/tool that updates the way you're looking, it will jumble your character up, like a rubik's cube! \\--
--// this script also blocks out the "OnAFKSignalReceived" remote and "ForceKill" remote if it is called by a non-exploit script \\--
--// for auto repair to work, you must have a hammer and atleast have equipped it once (repair radius seems to based on HumanoidRootPart or something else so you can technically repair something while the hammer is lets say, 3000 studs away, as long as your character is near the building) \\--

--//// binds \\\\--
--// Q / Shove Bind \\--
--// Z or X / Murder Bind \\--
--// K to toggle auto repair \\--
--// L to toggle "RubiksCube" \\--
--// U, F, G, H, J, Y, T to play music with fife or drum. \\--

--[/////////////////////////////]--
--[/////////////////////////////]--
--[/////////////////////////////]--

local OldTick = tick()

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Backpack = Player.Backpack
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", math.huge)
local AFKSignal = Remotes:FindFirstChild("OnAFKSignalReceived") or Remotes:WaitForChild("OnAFKSignalReceived", math.huge)

local ZombiesFolder = Workspace:FindFirstChild("Zombies") or Workspace:WaitForChild("Zombies", math.huge)
local BotsFolder = Workspace:FindFirstChild("Bots") or Workspace:WaitForChild("Bots", math.huge)
local BuildingsFolder = Workspace:FindFirstChild("Buildings") or Workspace:WaitForChild("Buildings", math.huge)

local Camera = Workspace.CurrentCamera

local RubiksCube = false

local CanRepair = true
local WaitTimeUntilRepair = 0.175
local BuildingBindEnabled = false
local HammerWarnDelay = 0.25
local HammerCanWarn = true

local FakeAccuracyBeatWaitTime = 0.15

local NewChildWaitTime = 0.25

local ShoveRange = 15 --// default range that is always used in this script for shoving.
local MurderRange = 11 --// Used as a backup if can't find weapon range.

local HeadSizeToUse = Vector3.new(6, 9, 4.5)
local HeadTransparency = 1

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
local PreferredWeapon = "Pike"

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

--// Binds.
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

if _G["OnClientZombieModelAdded"] ~= nil then 
    _G["OnClientZombieModelAdded"]:Disconnect()
	_G["OnClientZombieModelAdded"]= nil
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
--//

task.wait(0.15) --// attempting to let luau's garbage collect do its cleaning

_G["OnClientZombieModelAdded"] = Camera.ChildAdded:Connect(function(NewChild)
    task.spawn(function()
        if NewChild ~= nil and string.find(NewChild.Name, "m_Zombie") or NewChild.Name == "m_Zombie" then 
            task.wait(NewChildWaitTime)
            
            local Head
            local IsIgniter = false
            local IsRunner = false
            local IsSapper = false
            local IsBomber = false

            for i, v in pairs(NewChild:GetChildren()) do 
                if typeof(v) == "Instance" and v:IsA("BasePart") and v.Name == "Head" then 
                    Head = v

                    if Head:FindFirstChild("Eat") then 
                        IsRunner = true
                        break
                    end
                    if NewChild:FindFirstChild("Axe") then 
                        IsSapper = true
                        break
                    end
                    if NewChild:FindFirstChild("Barrel") then 
                        IsBomber = true
                        break
                    end
                elseif typeof(v) == "Instance" and v:IsA("Model") and v.Name == "Head" then 
                    IsIgniter = true

                    if Head ~= nil then 
                        break
                    end
                end

                task.wait()
            end

            if typeof(Head) == "Instance" and Head:IsA("BasePart") then 
                Head.Massless = true
                Head.Size = HeadSizeToUse or Vector3.new(3, 3, 3)
                Head.Transparency = HeadTransparency or 0.6

                if IsIgniter then
                    --// Igniter
                    local NewHighlight = Instance.new("Highlight")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    NewHighlight.FillColor = Color3.fromRGB(255, 255, 0)
                    NewHighlight.Parent = NewChild
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = NewChild
                elseif IsRunner then
                    --// Runner
                    local NewHighlight = Instance.new("Highlight")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                    NewHighlight.FillColor = Color3.fromRGB(0, 255, 255)
                    NewHighlight.Parent = NewChild
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = NewChild
                elseif IsSapper then 
                    --// Sapper
                    local NewHighlight = Instance.new("Highlight")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(255, 0, 255)
                    NewHighlight.FillColor = Color3.fromRGB(255, 0, 255)
                    NewHighlight.Parent = NewChild
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = NewChild
                elseif IsBomber then 
                    --// Bomber
                    local NewHighlight = Instance.new("Highlight")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = Color3.fromRGB(255, 123, 0)
                    NewHighlight.FillColor = Color3.fromRGB(255, 123, 0)
                    NewHighlight.Parent = NewChild
                    NewHighlight.FillTransparency = 0.5
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = NewChild
                end

                for _, ZombPart in pairs(NewChild:GetChildren()) do 
                    if typeof(ZombPart) == "Instance" and ZombPart:IsA("BasePart") and ZombPart.Name ~= "Head" --[[and ZombPart.Name ~= "HumanoidRootPart"]] then 
                        ZombPart.CanQuery = false
                    end
                end
                Head = nil
                
                return
            elseif typeof(Head) ~= "Instance" then
                Head = nil
                warn("[FAIL # OnClientZombieModelAdded]: Failed to find the head body part in \""..tostring(NewChild:GetFullName()).."\".")

                return
            end
        else
            NewChild = nil
            return
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
local function SetupFakeAccuracyBeat(RemoteEventToUse:RemoteEvent)
    if typeof(RemoteEventToUse) ~= "Instance" or not RemoteEventToUse:IsA("RemoteEvent") then 
        warn("[FAIL # SetupFakeAccuracyBeat]: \"RemoteEventToUse\" is not a Instance, nor a RemoteEvent")

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

local function GetMeleeWeapon()
	local Character = Player.Character

	if Character == nil then 
		warn("[FAIL # GetMeleeWeapon]: Your character doesn't exist?")

		return false
	end

	if Character.Parent == nil then 
		warn("[FAIL # GetMeleeWeapon]: Your character's parent is equal to nil.")

		return false
	end

    if Character:FindFirstChild(PreferredWeapon) then 
        local Tool = Character:FindFirstChild(PreferredWeapon)
        return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
    end

    if Character:FindFirstChildWhichIsA("Tool") then
        for _, Tool:Tool in ipairs(Character:GetChildren()) do 
            if Tool ~= nil and Tool:IsA("Tool") and Tool.Parent ~= nil then 
                if Tool:FindFirstChild("MeleeBase") then 
                    return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
				else
					if Tool.Name == "Musket" then 
						return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent"), Tool:FindFirstChild("Configuration") and (Tool:FindFirstChild("Configuration")::Configuration):GetAttribute("LimitRange")
					end
                end
            end
        end
    end

    if Backpack:FindFirstChildWhichIsA("Tool") then
        for _, Tool:Tool in ipairs(Backpack:GetChildren()) do 
            if Tool ~= nil and Tool:IsA("Tool") and Tool.Parent ~= nil then 
                if Tool:FindFirstChild("MeleeBase") then 
                    return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent")
				else
					if Tool.Name == "Musket" then 
						return Tool, Tool:FindFirstChildWhichIsA("RemoteEvent")
					end
                end
            end
        end
    end
    
	return false
end

local function GetAgentsInRange(Range:number)
	if Range == nil then 
		warn("[FAIL # GetAgentsInRange]: \"Range\" is equal to nil.")

		return
	end

	if typeof(Range) ~= "number" then 
		warn("[FAIL # GetAgentsInRange]: \"Range\" is not a number.")

		return
	end

	if Range == 0 or Range == (0/0) or Range == (-(0/0)) then 
		Range = 4
	elseif Range < 0 then 
		Range = -Range
	end

	local Character = Player.Character
	local CharHRP = Character and Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart

	if not CharHRP or CharHRP:IsA("Model") then 
		warn("[FAIL # GetAgentsInRange]: No HumanoidRootPart/PrimaryPart found inside in the player's character.")

		return
	end

	local AgentsInRange = {}

	if Character ~= nil and Character.Parent ~= nil then 
		if #ZombiesFolder:GetChildren() > 0 then 
			for _, Agent:Model in ipairs(ZombiesFolder:GetChildren()) do 
				if Agent ~= nil and Agent.Parent ~= nil then 
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
			for _, Agent:Model in ipairs(BotsFolder:GetChildren()) do 
				if Agent ~= nil and Agent.Parent ~= nil then 
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

	return
end

local function SortFunc(Table:{[any]: any}, Func:typeof(function(...) end))
	if Table ~= nil and Func ~= nil then 
		if typeof(Table) ~= "table" then 
			warn("[FAIL # SortFunc]: \"Table\" is not a table.")

			return
		end

		if typeof(Func) ~= "function" then 
			warn("[FAIL # SortFunc]: \"Func\" is not a function.")

			return
		end

		for i, v in pairs(Table) do
            task.spawn(Func, i, v)
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

local function GetBuildingWithLeastHealth()
	local Healths = {}
	local Pos = 1

	for i, v in pairs(BuildingsFolder:GetDescendants()) do
		if typeof(v) == "Instance" and v.Name == "BuildingHealth" and v:IsA("NumberValue") then 
			table.insert(Healths, Pos, v)
			Pos += 1
		end
	end

	if #Healths > 0 then 
		table.sort(Healths, function(Arg1, Arg2)
			return (Arg1.Value / (Arg1:GetAttribute("MaxHealth") or Arg1.Value) ) < (Arg2.Value / (Arg2:GetAttribute("MaxHealth") or Arg2.Value))
		end)

		if Healths[1] ~= nil then 
            return Healths[1]
        elseif Healths[1] == nil then 
            warn("[FAIL # GetBuildingWithLeastHealth]: Failed to get a \"BuildingHealth\" NumberValue.")
            return false
        end
    else
        warn("[FAIL # GetBuildingWithLeastHealth]: No buildings found?")
	end 

	return false
end

_G["BuildingBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.K then 
            BuildingBindEnabled	= not BuildingBindEnabled
            print("[INFO # BuildingBind]: \"BuildingBindEnabled\" is now equal to: "..tostring(BuildingBindEnabled))

			if not BuildingBindEnabled then 
				_G["BuildHighlight"].Adornee = nil
			end
        end
    end
end)

_G["BuildingBindFunc"] = RunService.Stepped:Connect(function()
	if BuildingBindEnabled and Player.Character ~= nil then 
		local Character = Player.Character
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
                warn("[FAIL # MusicBind]: Failed to find remote event for hammer.")
                
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
	if not Process and Player.Character then 
        local Character = Player.Character
		local KeyCodeName = tostring(Key.KeyCode.Name)
        local SongName = MusicSelections[KeyCodeName]

        if typeof(SongName) == "string" then 
            local FoundInstrument:Tool

            for i:string, v:boolean in pairs(AllowedInstruments) do 
                if typeof(i) == "string" and v then 
                    FoundInstrument = Character:FindFirstChild(i) or Backpack:FindFirstChild(i)
                    if FoundInstrument then 
                        print("[INFO # MusicBind]: Found instrument "..tostring(FoundInstrument.Name)..".")
                        break
                    end
                end
            end

            if FoundInstrument ~= nil and FoundInstrument:IsA("Tool") then                 
                local Remote = FoundInstrument:FindFirstChild("RemoteEvent")

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
                warn("[FAIL # MusicBind]: Failed to find a instrument to use.")

                return
            end
        end
    end
end)

_G["RubiksCubeBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.L then 
            RubiksCube = not RubiksCube
            print("[INFO # RubiksCubeBind]: \"RubiksCube\" is now equal to: "..tostring(RubiksCube))
        end
    end
end)

_G["ShoveBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process then 
		if Key.KeyCode == Enum.KeyCode.Q then 
			if Player.Character ~= nil and Player.Character.Parent ~= nil then
				local Character = Player.Character
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

				if Weapon and typeof(Weapon) == "Instance" and Weapon.Parent ~= nil then
					local Remote = Weapon:FindFirstChildWhichIsA("RemoteEvent")

					if Remote then
						if Weapon.Name == "Axe" then
							Remote:FireServer("BraceBlock")

							task.spawn(function()
								task.wait(0.25)
								if Remote ~= nil and Remote.Parent ~= nil then
									Remote:FireServer("StopBraceBlock")
								end
							end)
						elseif Weapon.Name == "Carbine" or Weapon.Name == "Navy Pistol" then
							Remote:FireServer("Shove")
						end

						SortFunc(AgentsInRange, function(Key, Agent)
							if Agent ~= nil and Agent:IsA("Model") and Agent.Parent ~= nil and Agent:FindFirstChild("Head") and Agent:FindFirstChild("State") then 
								local StunArgs = {
									[1] = "FeedbackStun";
									[2] = Agent;
									[3] = Agent:WaitForChild("Head").Position;
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
			if Player.Character ~= nil and Player.Character.Parent ~= nil then
				local Weapon:boolean, WeaponRemote:RemoteEvent, LimitRange:number = GetMeleeWeapon()

				if Weapon ~= nil and typeof(Weapon) ~= "boolean" then 
                	local AgentsInRange:{[number]:Model} = GetAgentsInRange(LimitRange and (LimitRange * 1.8) or MurderRange)

                    if typeof(AgentsInRange) ~= "table" then 
                        warn("[FAIL # MurderBind]: \"AgentsInRange\" is not a table.")
                        
                        return
                    end

                    if #AgentsInRange <= 0 then
                        warn("[FAIL # MurderBind]: No agents found within a range of "..tostring(LimitRange and (LimitRange * 1.8) or MurderRange).." studs.")

                        return
                    end

					if WeaponRemote ~= nil and WeaponRemote:IsA("RemoteEvent") then 						
						if Weapon.Name ~= "Musket" then
							if Weapon.Name ~= "Spade" then 
                                WeaponRemote:FireServer("Swing", "Over")
                            else
                                WeaponRemote:FireServer("Swing", "Side")
                            end

							SortFunc(AgentsInRange, function(Key, Agent) 
								if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent ~= nil and Agent:FindFirstChild("Head") and Agent:FindFirstChild("State") then 
									local HitArgs = {
										[1] = "HitZombie";
										[2] = Agent;
										[3] = (Agent:WaitForChild("Head", math.huge)::BasePart).Position;
										[4] = true;
									}
	
									WeaponRemote:FireServer(unpack(HitArgs))
								end
							end)
						elseif Weapon.Name == "Musket" then
							WeaponRemote:FireServer("ThrustBayonet")

                            for i, Agent in pairs(AgentsInRange) do 
                                if typeof(Agent) == "Instance" and Agent:IsA("Model") and Agent.Parent ~= nil and Agent:FindFirstChild("Head") and Agent:FindFirstChild("State") then 
                                    local HitArgs = {
                                        [1] = "Bayonet_HitZombie";
                                        [2] = Agent;
                                        [3] = (Agent:WaitForChild("Head", math.huge)::BasePart).Position;
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

local OldNameCall = nil
if _G["AlreadyActive"] == nil then 
	_G["AlreadyActive"] = true

	OldNameCall = hookmetamethod(game, "__namecall", function(Remote, ...)
		local Args = {...}
		local NamecallMethod = getnamecallmethod()

		if not checkcaller() then
            if NamecallMethod == "FireServer" then
                --// always returns "nil" technically
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

                            return OldNameCall(Remote, unpack(Args))
                        elseif Args[1] == "HitZombie" or Args[1] == "Bayonet_HitZombie" or Args[1] == "ThrustCharge" then 
                            if Args[2] ~= nil and Args[2].Parent ~= nil and (Args[2]:GetAttribute("Type") == "Barrel") then
                                print("[INFO # Namecall Hook]: Player just attempted to hit a barrel zombie, blocking request and replacing with request with nil.")
                                
                                return nil
                            end

                            if typeof(Args[4]) == "boolean" then 
                                Args[4] = true
                            end

                            Remote["FireServer"](Remote, unpack(Args))
                            return nil
                        elseif Args[1] == "CancelReload" then 
                            print("[INFO # Namecall Hook]: CancelReload argument blocked.")
                            return nil
                        elseif Args[1] == "Swing" then 
                            local Character = Player.Character

                            if Character then 
                                local Spade:Tool = Character:FindFirstChild("Spade")
                                
                                if Spade then 
                                    Args[2] = "Over"

                                    Remote["FireServer"](Remote, unpack(Args))
                                    return nil
                                end
                            end

                            Remote["FireServer"](Remote, ...)
                            return nil
                        elseif Args[1] == "UpdateLook" and RubiksCube then
                            --// probably a much better way to do this but
                            --// i got lazy!
                            
                            local RandomNum1 = math.random(1, 6)
                            local RandomNum2 = math.random(1, 6)
                            local RandomNum3 = math.random(1, 6)

                            Args[2] = math.random(-100, 1000)

                            if RandomNum1 == 1 then
                                Args[3] = Player.Character.Torso["Neck"] or Args[3]
                            elseif RandomNum1 == 2 then
                                Args[3] = Player.Character.Torso["Right Hip"] or Args[3]
                            elseif RandomNum1 == 3 then
                                Args[3] = Player.Character.Torso["Left Shoulder"] or Args[3]
                            elseif RandomNum1 == 4 then
                                Args[3] = Player.Character.Torso["Right Shoulder"] or Args[3]
                            elseif RandomNum1 == 5 then
                                Args[3] = Player.Character.Torso["Left Hip"] or Args[3]
                            elseif RandomNum1 == 6 then
                                Args[3] = --[[Player.Character.Torso["Left Shoulder"] or Args[3] ]] Player.Character.HumanoidRootPart and Player.Character.HumanoidRootPart["Root Hip"] or Args[3]
                            else
                                Args[3] = Player.Character.Torso["Neck"] or Args[3]
                            end

                            if RandomNum2 == 1 then
                                Args[4] = Player.Character.Torso["Neck"] or Args[4]
                            elseif RandomNum2 == 2 then
                                Args[4] = Player.Character.Torso["Right Hip"] or Args[4]
                            elseif RandomNum2 == 3 then
                                Args[4] = Player.Character.Torso["Left Shoulder"] or Args[4]
                            elseif RandomNum2 == 4 then
                                Args[4] = Player.Character.Torso["Right Shoulder"] or Args[4]
                            elseif RandomNum2 == 5 then
                                Args[4] = Player.Character.Torso["Left Hip"] or Args[4]
                            elseif RandomNum2 == 6 then
                                Args[4] = --[[Player.Character.Torso["Left Shoulder"] or Args[4] ]] Player.Character.HumanoidRootPart and Player.Character.HumanoidRootPart["Root Hip"] or Args[4]
                            else
                                Args[4] = Player.Character.Torso["Neck"] or Args[4]
                            end

                            if RandomNum3 == 1 then
                                Args[5] = Player.Character.Torso["Neck"] or Args[5]
                            elseif RandomNum3 == 2 then
                                Args[5] = Player.Character.Torso["Right Hip"] or Args[5]
                            elseif RandomNum3 == 3 then
                                Args[5] = Player.Character.Torso["Left Shoulder"] or Args[5]
                            elseif RandomNum3 == 4 then
                                Args[5] = Player.Character.Torso["Right Shoulder"] or Args[5]
                            elseif RandomNum3 == 5 then
                                Args[5] = Player.Character.Torso["Left Hip"] or Args[5]
                            elseif RandomNum3 == 6 then
                                Args[5] = --[[Player.Character.Torso["Left Shoulder"] or Args[5] ]] Player.Character.HumanoidRootPart and Player.Character.HumanoidRootPart["Root Hip"] or Args[5]
                            else
                                Args[5] = Player.Character.Torso["Neck"] or Args[5]
                            end

                            return OldNameCall(Remote, unpack(Args))
                        end
                    end
                end
            end
		end

		return OldNameCall(Remote, ...)
	end)
end

warn(
    ([[ 
        [INFO # END OF SCRIPT]: script successfully executed!
           -/ Took %s seconds to run.
    ]]):format(tostring(tick() - OldTick))
)
