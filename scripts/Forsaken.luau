--// contact: @_x4yz
--// https://www.roblox.com/games/18687417158/NOLI-Forsaken

--// cyan highlight = killer
--// blue highlight = survivor
--// purple highlight = generator
--// red highlight = medkit
--// yellow/gold highlight = bloxy cola

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")

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

local function CreateInstance(
    Class:string, 
    Properties:{[string]:any?}
):(Instance|boolean?)
    if (type(Class) ~= "string") then
        return false
    end
    local UseProperties = (type(Properties) == "table")

    local Success, NewInstance = pcall(function()
        return Instance.new(Class)
    end)
    if not Success or not NewInstance then
        return false
    end

    if UseProperties then
        local ParentPropertyToSet:Instance
        for Property:string, Value:any? in pairs(Properties) do 
            if (Property ~= "Parent") then
                task.spawn(pcall, function()
                    NewInstance[Property] = Value
                end)
            elseif (Property == "Parent") and (typeof(Value) == "Instance") then
                ParentPropertyToSet = Value
            end
        end

        if ParentPropertyToSet then
            NewInstance.Parent = ParentPropertyToSet
        end
    end

    return NewInstance
end

local Rayfield = loadstring(
    game:HttpGet('https://sirius.menu/rayfield')
)()

if getgenv().ScriptThread then 
    coroutine.close(getgenv().ScriptThread)
    getgenv().ScriptThread = nil
end
if not getgenv().ItemEspToggle then 
    getgenv().ItemEspToggle = CreateInstance("BoolValue", {
        Name = "__ItemESP";
    })
end
if not getgenv().PlayerEspToggle then 
    getgenv().PlayerEspToggle = CreateInstance("BoolValue", {
        Name = "__PlayerESP";
    })
end
if not getgenv().GeneratorEspToggle then 
    getgenv().GeneratorEspToggle = CreateInstance("BoolValue", {
        Name = "__GeneratorEsp";
    })
end
if not getgenv().AutoGenToggle then 
    getgenv().AutoGenToggle = CreateInstance("BoolValue", {
        Name = "__AutoGen";
    })
end
getgenv().ScriptSettings = {
    --// Stamina.
    ["StaminaSettings"] = {
        ["InfiniteStamina"] = false;
        ["CustomStaminaLimit"] = 100;
        ["CustomStaminaGainRate"] = 20;
        ["CustomStaminaLossRate"] = 10;
        ["CustomSprintSpeed"] = 26;
    };

    --// ESP.
    ["EspSettings"] = {
        ["ItemESPEnabled"] = false;
        ["PlayerESPEnabled"] = false;
        ["GeneratorESPEnabled"] = false;
        ["ItemESPSize"] = Vector3.new(3, 3, 3);
        ["PlayerESPSize"] = Vector3.new(3, 5, 3);
        ["KillerBlockingESPSize"] = Vector3.new(5, 5, 5);
        ["GeneratorESPSize"] = Vector3.new(5, 3, 5);

        ["ItemColors"] = {
            ["Medkit"] = Color3.new(1, 0, 0);
            ["BloxyCola"] = Color3.fromRGB(239, 184, 56);
        };
        ["PlayerColors"] = {
            ["Survivor"] = Color3.fromRGB(14, 41, 211);
            ["Killer"] = Color3.new(0, 1, 1);
            ["KillerBlocking"] = Color3.new(0, 1, 0);
        };
        ["GeneratorColor"] = Color3.fromRGB(182, 16, 189);
    };

    --// Misc.
    ["Misc"] = {
        ["FootstepsEnabled"] = true;
        ["AutoGenEnabled"] = false;
        ["AutoGenSpeed"] = 7;
    };
}
local DefaultSettings = {
    --// Do not change any of the following unless you know what you are doing.

    --// Stamina.
    ["StaminaSettings"] = {
        ["InfiniteStamina"] = false;
        ["CustomStaminaLimit"] = 100;
        ["CustomStaminaGainRate"] = 20;
        ["CustomStaminaLossRate"] = 10;
        ["CustomSprintSpeed"] = 26;
    };

    --// ESP.
    ["EspSettings"] = {
        ["ItemESPEnabled"] = false;
        ["PlayerESPEnabled"] = false;
        ["GeneratorESPEnabled"] = false;
        ["ItemESPSize"] = Vector3.new(3, 3, 3);
        ["PlayerESPSize"] = Vector3.new(3, 5, 3);
        ["GeneratorESPSize"] = Vector3.new(5, 5, 5);
        ["KillerBlockingESPSize"] = Vector3.new(4, 5, 4);

        ["ItemColors"] = {
            ["Medkit"] = Color3.new(1, 0, 0);
            ["BloxyCola"] = Color3.fromRGB(239, 184, 56);
        };
        ["PlayerColors"] = {
            ["Survivor"] = Color3.fromRGB(14, 41, 211);
            ["Killer"] = Color3.new(0, 1, 1);
            ["KillerBlocking"] = Color3.new(0, 1, 0);
        };
        ["GeneratorColor"] = Color3.fromRGB(182, 16, 189);
    };

    --// Misc.
    ["Misc"] = {
        ["FootstepsEnabled"] = true;
        ["AutoGenEnabled"] = false;
        ["AutoGenSpeed"] = 7;
    };
}

local TableInsert = table.insert
local TableFind = table.find

local LocalPlayer = Players.LocalPlayer

local Map = Workspace:WaitForChild("Map")
local PlayersFolder = Workspace:WaitForChild("Players")

local Ingame = Map:WaitForChild("Ingame")

local KillersFolder = PlayersFolder:WaitForChild("Killers")
local SurvivorsFolder = PlayersFolder:WaitForChild("Survivors")

local Systems:Folder = ReplicatedStorage:WaitForChild("Systems")
local Modules:Folder = ReplicatedStorage:WaitForChild("Modules")
local Assets:Folder = ReplicatedStorage:WaitForChild("Assets")

local CharacterSystems:Folder = Systems:WaitForChild("Character")
local CharacterSystems_Game:Folder = CharacterSystems:WaitForChild("Game")
local SprintingSystem:ModuleScript = require(CharacterSystems_Game:WaitForChild("Sprinting"))

local Network:ModuleScript = Modules:WaitForChild("Network")
local UnreliableRemoteEvent:UnreliableRemoteEvent = Network:WaitForChild("UnreliableRemoteEvent")

local AssetKillers = Assets:WaitForChild("Killers")
local Skins = Assets:WaitForChild("Skins")
local KillerSkins = Skins:WaitForChild("Killers")

local Misc:Folder = Modules:WaitForChild("Misc")
local FlowGameManager:ModuleScript = require(Misc:WaitForChild("FlowGameManager"))

local ChatWindowConfig = TextChatService:WaitForChild("ChatWindowConfiguration")

local function FetchAnimationsOfKiller(KillerName:string, AnimationIdentifiers:{string}):({number?})
	local Animations = {}

	if (type(KillerName) ~= "string") then
		return Animations
	end
    if (type(AnimationIdentifiers) ~= "table") then
        return Animations
    end

	local function ExtractAnimations(AnimationsTable:{string})
		if (type(AnimationsTable) ~= "table") then 
            return 
        end

		for Identifier:string, AnimationIdOrTable:string|{string} in pairs(AnimationsTable) do
			if (type(AnimationIdOrTable) == "string") then
				if TableFind(AnimationIdentifiers, tostring(Identifier)) then
					local Id = tonumber(string.match(AnimationIdOrTable, "%d+"))
					if Id then
						TableInsert(Animations, Id)
					end
				end
			elseif (type(AnimationIdOrTable) == "table") then
				for SubIdentifier:string, IdStr:string in pairs(AnimationIdOrTable) do
					if (type(IdStr) == "string") and TableFind(AnimationIdentifiers, tostring(SubIdentifier)) then
						local Id = tonumber(string.match(IdStr, "%d+"))
						if Id then
							TableInsert(Animations, Id)
						end
					end
				end
			end
		end
	end

	local KillerFolder_Assets:Folder = AssetKillers:FindFirstChild(KillerName)
	if KillerFolder_Assets then
		local ConfigModule:ModuleScript = KillerFolder_Assets:FindFirstChild("Config")
		if ConfigModule and ConfigModule:IsA("ModuleScript") then
			local Config = require(ConfigModule)
			ExtractAnimations(Config.Animations)
		end
	end

	local KillerFolder_Skins:Folder = KillerSkins:FindFirstChild(KillerName)
	if KillerFolder_Skins then
		for _, SkinFolder:Folder in pairs(KillerFolder_Skins:GetChildren()) do
			if SkinFolder:IsA("Folder") then
				local ConfigModule:ModuleScript = SkinFolder:FindFirstChild("Config")
				if ConfigModule and ConfigModule:IsA("ModuleScript") then
					local Config = require(ConfigModule)
					ExtractAnimations(Config.Animations)
				end
			end
		end
	end

	return Animations
end

local KillerAnimations = {
    ["Jason"] = FetchAnimationsOfKiller("Jason", {"Slash";"Behead";"GashingWoundStart"}); --[[{
        126830014841198;
        126355327951215;
        102228729296384;
    };]]
    ["JohnDoe"] = FetchAnimationsOfKiller("JohnDoe", {"Slash"}); --[[{
        105458270463374;
    };]]
    ["Noli"] = FetchAnimationsOfKiller("Noli", {"Stab";"LoopCharge";"LoopDashCombo"}); --[[{
        109230267448394;
        93841120533318;
    };]]
    ["c00lkidd"] = FetchAnimationsOfKiller("c00lkidd", {"Attack";"WalkspeedOverrideStart";"WalkspeedOverrideLoop"}); --[[{
        18885909645;
        106776364623742;
    };]]
    ["1x1x1x1"] = FetchAnimationsOfKiller("1x1x1x1", {"Slash";"MassInfection"}); --[[{
        83829782357897;
    };]]
}

local function GetMaxIndexOfTable(
    Table:{[any]:any}
):(number)
	if (Table ~= nil) then 
		if (type(Table) ~= "table") then
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
	end

	return 0
end

local function GetRoundPlayers():({
    ["Survivors"]:{Model};
    ["Killers"]:{Model};
})
    return {
        ["Survivors"] = SurvivorsFolder:GetChildren();
        ["Killers"] = KillersFolder:GetChildren();
    }
end

local function GetKillerAnimations():({[Model]:{AnimationTrack?}})
    local RoundPlayers:{
        ["Survivors"]:{Model};
        ["Killers"]:{Model};
    } = GetRoundPlayers()

    if (type(RoundPlayers) ~= "table") then 
        return false
    end
    if (type(RoundPlayers.Killers) ~= "table") then 
        return false
    end
    if (#RoundPlayers.Killers <= 0) then 
        return false
    end

    local Tracks = {}
    for _, Killer:Model in pairs(RoundPlayers.Killers) do
        if Killer then
            local Humanoid:Humanoid = Killer:FindFirstChildWhichIsA("Humanoid")
            if not Humanoid then
                continue
            end
            local Animator:Animator = Humanoid:FindFirstChildWhichIsA("Animator")
            if not Animator then
                continue
            end

            local Animations:{AnimationTrack} = Animator:GetPlayingAnimationTracks()
            Tracks[Killer] = Animations
        end
    end

    return Tracks
end

local function GetKillersThatCanBeBlocked()
    local Animations:{
        [Model]:{AnimationTrack?}
    } = GetKillerAnimations()

    if (type(Animations) ~= "table") then
        return false
    end
    if (GetMaxIndexOfTable(Animations) <= 0) then
        return false
    end

    local KillersWhichShouldBeBlocked = {}
    for Killer:Model, AnimationTracks:{AnimationTrack} in pairs(Animations) do
        if (typeof(Killer) ~= "Instance") or not Killer:IsA("Model") or (Killer.Parent ~= KillersFolder) then
            continue
        end
        if (type(AnimationTracks) ~= "table") then
            continue
        end

        local AnimationsForKiller:{number} = KillerAnimations[Killer.Name]
        if (type(AnimationsForKiller) ~= "table") then
            continue
        end

        for _, Track:AnimationTrack in pairs(AnimationTracks) do
            if not Track then
                continue 
            end
        
            local TrackId = tonumber(Track.Animation.AnimationId:match("%d+"))
            if TrackId then
                if table.find(AnimationsForKiller, TrackId) then
                    KillersWhichShouldBeBlocked[Killer] = true
                else
                    KillersWhichShouldBeBlocked[Killer] = false
                end
            end
        end
    end

    return KillersWhichShouldBeBlocked
end

local function GetItems():({Tool?})
    local Items = {}
    local CurrentMap = Ingame:FindFirstChild("Map")

    if not CurrentMap then 
        for _, Item:Tool in pairs(Workspace:GetChildren()) do 
            if Item and Item:IsA("Tool") and Item:FindFirstChild("ItemRoot") then 
                TableInsert(Items, Item)
            end
        end
    else
        for _, Item:Tool in pairs(CurrentMap:GetChildren()) do 
            if Item and Item:IsA("Tool") and Item:FindFirstChild("ItemRoot") then 
                TableInsert(Items, Item)
            end
        end
        for _, Item:Tool in pairs(Workspace:GetChildren()) do 
            if Item and Item:IsA("Tool") and Item:FindFirstChild("ItemRoot") then 
                TableInsert(Items, Item)
            end
        end
    end

    for _, Item:Tool in pairs(Ingame:GetChildren()) do 
        if Item and Item:IsA("Tool") and Item:FindFirstChild("ItemRoot") then 
            TableInsert(Items, Item)
        end
    end

    return Items
end

local function GetGenerators():({Model?}|boolean?)
    local Generators = {}
    local CurrentMap = Ingame:FindFirstChild("Map")

    if not CurrentMap then 
        return false
    end

    for _, Generator in pairs(CurrentMap:GetChildren()) do 
        if Generator and Generator:IsA("Model") and (Generator.Name == "Generator") and Generator:FindFirstChild("Progress") then 
            TableInsert(Generators, Generator)
        end
    end

    return Generators
end

local function MakeHighlight(
    Size:Vector3?,
    Transparency:number?,
    Name:string?
):(BoxHandleAdornment)
    local Highlight = CreateInstance("BoxHandleAdornment", {
        Transparency = ((type(Transparency) == "number") and Transparency) or 0.6;
        AlwaysOnTop = true;
        ZIndex = 5;
        Size = ((typeof(Size) == "Vector3") and Size) or Vector3.new(3, 3, 3);
        Name = ((type(Name) == "string") and Name) or "ProvidedHighlight";
    })

    return Highlight
end

local function ApplyPlayerHighlight(
    Character:Model, 
    Role:("Survivor"|"Killer"|"KillerBlocking")
):(boolean)
    if (typeof(Character) ~= "Instance") or not Character:IsA("Model") then 
        return false
    end
    if (type(Role) ~= "string") then 
        return false
    end
    local RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
    if not RootPart then 
        return 
    end

    if RootPart:FindFirstChild("__") then
        if (Role == "KillerBlocking") then 
            if RootPart:FindFirstChild("__K") then
                return
            end
        elseif (Role == "Killer") then
            if RootPart:FindFirstChild("__K") then
                RootPart:FindFirstChild("__K"):Destroy()
            end

            return
        else
            return
        end
    end

    local Highlight = (Role ~= "KillerBlocking") and MakeHighlight(getgenv().ScriptSettings.EspSettings.PlayerESPSize, 0.6, "__") 
        or (Role == "KillerBlocking") and MakeHighlight(getgenv().ScriptSettings.EspSettings.KillerBlockingESPSize, 0.8, "__K")
    local ColorToUse = getgenv().ScriptSettings.EspSettings.PlayerColors[Role] or Color3.new(1, 1, 1)

    Highlight.Color3 = ColorToUse
    Highlight.Adornee = RootPart
    Highlight.Parent = RootPart

    local Connection; Connection = getgenv().PlayerEspToggle:GetPropertyChangedSignal("Value"):Connect(function()
        if not Highlight then
            Connection:Disconnect()
            Connection = nil
            return
        end

        if not getgenv().PlayerEspToggle.Value then 
            Highlight:Destroy()
            Connection:Disconnect()
            Connection = nil
            return
        end
    end)
end

local function HighlightItems():(boolean)
    local Items:{Tool?} = GetItems()
    if (type(Items) ~= "table") then 
        return false
    end
    if (#Items <= 0) then 
        return false
    end

    for _, Item:Tool in pairs(Items) do 
        if Item and Item:IsA("Tool") and Item:FindFirstChild("ItemRoot") then 
            local ItemRoot = Item:FindFirstChild("ItemRoot")
            if ItemRoot:FindFirstChild("__") then
                return
            end

            local Highlight = MakeHighlight(getgenv().ScriptSettings.EspSettings.ItemESPSize, 0.6, "__")
            local ColorToUse = getgenv().ScriptSettings.EspSettings.ItemColors[Item.Name] or Color3.new(1, 1, 1)

            Highlight.Color3 = ColorToUse
            Highlight.Adornee = ItemRoot
            Highlight.Parent = ItemRoot

            local Connection; Connection = getgenv().ItemEspToggle:GetPropertyChangedSignal("Value"):Connect(function()
                if not Highlight then
                    Connection:Disconnect()
                    Connection = nil
                    return
                end

                if not getgenv().ItemEspToggle.Value then 
                    Highlight:Destroy()
                    Connection:Disconnect()
                    Connection = nil
                    return
                end
            end)
        end
    end

    return true
end

local function HighlightGenerators():(boolean)
    local Generators:({Model?}|boolean?) = GetGenerators()
    
    if (type(Generators) ~= "table") then 
        return false
    end
    if (#Generators <= 0) then 
        return false
    end

    for _, Generator:Model in pairs(Generators) do 
        if Generator and Generator:IsA("Model") and (Generator.Name == "Generator") and Generator:FindFirstChild("Progress") then 
            local ItemRoot = Generator:FindFirstChild("Main")
            if not ItemRoot then 
                return
            end
            
            if ItemRoot:FindFirstChild("__") then
                return
                --[[repeat
                    if RootPart:FindFirstChild("__") then
                        RootPart:FindFirstChild("__"):Destroy()
                    else
                        break
                    end

                    task.wait()
                until not RootPart:FindFirstChild("__")]]
            end

            local Highlight = MakeHighlight(getgenv().ScriptSettings.EspSettings.GeneratorESPSize, 0.6, "__")
            local ColorToUse = getgenv().ScriptSettings.EspSettings.GeneratorColor or Color3.new(1, 1, 1)

            Highlight.Color3 = ColorToUse
            Highlight.Adornee = ItemRoot
            Highlight.Parent = ItemRoot

            local Connection; Connection = getgenv().GeneratorEspToggle:GetPropertyChangedSignal("Value"):Connect(function()
                if not Highlight then
                    Connection:Disconnect()
                    Connection = nil
                    return
                end

                if not getgenv().GeneratorEspToggle.Value then 
                    Highlight:Destroy()
                    Connection:Disconnect()
                    Connection = nil
                    return
                end
            end)
        end
    end

    return true
end

local function HighlightPlayers():(boolean)
    local RoundPlayers:{
        ["Survivors"]:{Model};
        ["Killers"]:{Model};
    } = GetRoundPlayers()
    if (type(RoundPlayers) ~= "table") then 
        return false
    end
    if (type(RoundPlayers.Survivors) ~= "table") or (type(RoundPlayers.Killers) ~= "table") then 
        return false
    end
    if (#RoundPlayers.Survivors <= 0) and (#RoundPlayers.Killers <= 0) then 
        return false
    end
    for _, Survivor:Model in pairs(RoundPlayers.Survivors) do 
        if Survivor and Survivor:IsA("Model") then
            if (Players:GetPlayerFromCharacter(Survivor) ~= LocalPlayer) then 
                task.spawn(ApplyPlayerHighlight, Survivor, "Survivor")
            end
        end
    end

    local KillersThatCanBeBlocked = GetKillersThatCanBeBlocked()
    if (type(KillersThatCanBeBlocked) ~= "table") then
        return false
    else
        for _, Killer:Model in pairs(RoundPlayers.Killers) do 
            if Killer and Killer:IsA("Model") then 
                if (Players:GetPlayerFromCharacter(Killer) ~= LocalPlayer) then
                    if KillersThatCanBeBlocked[Killer] then
                        task.spawn(ApplyPlayerHighlight, Killer, "KillerBlocking")
                    else
                        task.spawn(ApplyPlayerHighlight, Killer, "Killer")
                    end
                end
            end
        end
    end

    return true
end

local function AttemptToCompleteGeneratorPuzzle():(boolean)
    local ActivePuzzle = FlowGameManager.activeGame
    if (type(ActivePuzzle) ~= "table") then 
        return false
    end
    local CompletedEvent = ActivePuzzle.completedEvent
    if (typeof(CompletedEvent) ~= "Instance") or not CompletedEvent:IsA("BindableEvent") then 
        return false
    end

    CompletedEvent:Fire("finishedPuzzle")
    return true
end

if not getgenv().ScriptExecutedAlready then
    getgenv().ScriptExecutedAlready = true
    print("Running hook.")
    local OldUnreliableRemoteEventHook; OldUnreliableRemoteEventHook = hookmetamethod(UnreliableRemoteEvent, "__namecall", function(Self, ...)
        local Args = {...}
        local NamecallMethod = getnamecallmethod()

        if checkcaller() then 
            return OldUnreliableRemoteEventHook(Self, ...)
        end

        if (NamecallMethod == "FireServer") then 
            if (Args[1] == "FootstepPlayed") and (type(Args[2]) == "number") then 
                if not getgenv().ScriptSettings.Misc.FootstepsEnabled then
                    return nil
                end
            end
        end

        return OldUnreliableRemoteEventHook(Self, ...)
    end)
end

local Window = Rayfield:CreateWindow({
    Name = "Roblox - Forsaken - @_x4yz";
    Icon = "moon-star";
    LoadingTitle = "Forsaken Script - Rayfield UI";
    LoadingSubtitle = "         By @_x4yz";
    Theme = "AmberGlow";

    DisableRayfieldPrompts = false;
    DisableBuildWarnings = false;

    ConfigurationSaving = {
        Enabled = true;
        FolderName = nil;
        FileName = "ForsakenHub_x4yz";
    };

    KeySystem = false;
})

local MainTab = Window:CreateTab("Main", 4483362458)
do
    MainTab:CreateSection("Stamina (Use carefully around players.)")
    MainTab:CreateToggle({
        Name = "Infinite Stamina  (BE CAREFUL, RISKY)";
        CurrentValue = DefaultSettings.StaminaSettings.InfiniteStamina;
        Flag = "InfiniteStaminaEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.InfiniteStamina = Value
            SprintingSystem.StaminaLossDisabled = Value
        end;
    })
    MainTab:CreateSlider({
        Name = "Max Stamina  (DON'T SET TOO HIGH, RISKY)";
        Range = {0, 500};
        Increment = 10;
        Suffix = "Stamina";
        CurrentValue = DefaultSettings.StaminaSettings.CustomStaminaLimit;
        Flag = "MaxStamina_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.CustomStaminaLimit = Value
            SprintingSystem.MaxStamina = Value
        end;
    })
    MainTab:CreateSlider({
        Name = "Stamina Gain Rate  (DON'T SET TOO HIGH, CAN BE RISKY)";
        Range = {0, 100};
        Increment = 5;
        Suffix = "";
        CurrentValue = DefaultSettings.StaminaSettings.CustomStaminaGainRate;
        Flag = "StaminaGainRate_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.CustomStaminaGainRate = Value
            SprintingSystem.StaminaGain = Value
        end;
    })
    MainTab:CreateSlider({
        Name = "Stamina Loss Rate (here cause why not)";
        Range = {0, 100};
        Increment = 5;
        Suffix = "";
        CurrentValue = DefaultSettings.StaminaSettings.CustomStaminaLossRate;
        Flag = "StaminaLossRate_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.CustomStaminaLossRate = Value
            SprintingSystem.StaminaLoss = Value
        end;
    })
    MainTab:CreateSlider({
        Name = "Sprint Speed  (DON'T SET TOO HIGH, RISKY)";
        Range = {0, 100};
        Increment = 2;
        Suffix = "";
        CurrentValue = DefaultSettings.StaminaSettings.CustomSprintSpeed;
        Flag = "SprintSpeed_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.CustomSprintSpeed = Value
            SprintingSystem.SprintSpeed = Value
        end;
    })
end
do
    MainTab:CreateSection("ESP")
    MainTab:CreateToggle({
        Name = "Item ESP";
        CurrentValue = DefaultSettings.StaminaSettings.ItemESPEnabled;
        Flag = "ItemEspEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.ItemESPEnabled = Value
            getgenv().ItemEspToggle.Value = Value
        end;
    })
    MainTab:CreateToggle({
        Name = "Player ESP";
        CurrentValue = DefaultSettings.StaminaSettings.PlayerESPEnabled;
        Flag = "PlayerEspEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.PlayerESPEnabled = Value
            getgenv().PlayerEspToggle.Value = Value
        end;
    })
    MainTab:CreateToggle({
        Name = "Generator ESP";
        CurrentValue = DefaultSettings.EspSettings.GeneratorESPEnabled;
        Flag = "GeneratorEspEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.EspSettings.GeneratorESPEnabled = Value
            getgenv().GeneratorEspToggle.Value = Value
        end;
    })
end
do
    MainTab:CreateSection("Misc")
    MainTab:CreateToggle({
        Name = "Footsteps Enabled (Off for silent footsteps.)";
        CurrentValue = DefaultSettings.Misc.FootstepsEnabled;
        Flag = "SilentFootstepsEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.Misc.FootstepsEnabled = Value
        end;
    })
    MainTab:CreateToggle({
        Name = "Auto Generator Puzzle";
        CurrentValue = DefaultSettings.Misc.AutoGenEnabled;
        Flag = "AutoGenEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.Misc.AutoGenEnabled = Value
            getgenv().AutoGenToggle.Value = Value
        end;
    })
    MainTab:CreateSlider({
        Name = "Auto Generator Puzzle Speed";
        Range = {0, 20};
        Increment = 1;
        Suffix = "Second(s)";
        CurrentValue = DefaultSettings.Misc.AutoGenSpeed;
        Flag = "AutoGenSpeed_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.Misc.AutoGenSpeed = Value
        end;
    })
end

getgenv().ScriptThread = coroutine.create(function()
    local Started = 0
    local WasInGenerator = false
    local OldSolutionText = ""

    while true do
        if getgenv().ItemEspToggle.Value then 
            task.spawn(HighlightItems)
        end
        if getgenv().PlayerEspToggle.Value then 
            task.spawn(HighlightPlayers)
        end
        if getgenv().GeneratorEspToggle.Value then 
            task.spawn(HighlightGenerators)
        end

        if getgenv().AutoGenToggle.Value then
            local ActiveGame = FlowGameManager.activeGame
            local InGenerator = (ActiveGame ~= nil)

            if InGenerator then
                local CurrentSolutionText = ActiveGame.SolutionText

                if not WasInGenerator then
                    Started = os.clock()
                    OldSolutionText = CurrentSolutionText
                elseif (CurrentSolutionText ~= OldSolutionText) then
                    Started = os.clock()
                    OldSolutionText = CurrentSolutionText
                    task.wait(0.05)
                end

                local TimePassed = (os.clock() - Started)
                if (TimePassed >= getgenv().ScriptSettings.Misc.AutoGenSpeed) then
                    task.spawn(AttemptToCompleteGeneratorPuzzle)
                    Started = os.clock()
                end
            end

            WasInGenerator = InGenerator
        else
            WasInGenerator = false
        end

        SprintingSystem.MaxStamina = getgenv().ScriptSettings.StaminaSettings.CustomStaminaLimit
        SprintingSystem.StaminaLossDisabled = getgenv().ScriptSettings.StaminaSettings.InfiniteStamina
        SprintingSystem.StaminaGain = getgenv().ScriptSettings.StaminaSettings.CustomStaminaGainRate
        SprintingSystem.StaminaLoss = getgenv().ScriptSettings.StaminaSettings.CustomStaminaLossRate
        SprintingSystem.SprintSpeed = getgenv().ScriptSettings.StaminaSettings.CustomSprintSpeed
        ChatWindowConfig.Enabled = true

        task.wait(0.025)
    end
end)
coroutine.resume(ScriptThread)
