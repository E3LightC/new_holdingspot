--// @_x4yz
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
        ["GeneratorESPSize"] = Vector3.new(5, 3, 5);

        ["ItemColors"] = {
            ["Medkit"] = Color3.new(1, 0, 0);
            ["BloxyCola"] = Color3.fromRGB(239, 184, 56);
        };
        ["PlayerColors"] = {
            ["Survivor"] = Color3.fromRGB(14, 41, 211);
            ["Killer"] = Color3.new(0, 1, 1);
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
        ["GeneratorESPSize"] = Vector3.new(5, 3, 5);

        ["ItemColors"] = {
            ["Medkit"] = Color3.new(1, 0, 0);
            ["BloxyCola"] = Color3.fromRGB(239, 184, 56);
        };
        ["PlayerColors"] = {
            ["Survivor"] = Color3.fromRGB(14, 41, 211);
            ["Killer"] = Color3.new(0, 1, 1);
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

local LocalPlayer = Players.LocalPlayer

local Map = Workspace:WaitForChild("Map")
local PlayersFolder = Workspace:WaitForChild("Players")

local Ingame = Map:WaitForChild("Ingame")

local KillersFolder = PlayersFolder:WaitForChild("Killers")
local SurvivorsFolder = PlayersFolder:WaitForChild("Survivors")

local Systems:Folder = ReplicatedStorage:WaitForChild("Systems")
local Modules:Folder = ReplicatedStorage:WaitForChild("Modules")

local CharacterSystems:Folder = Systems:WaitForChild("Character")
local CharacterSystems_Game:Folder = CharacterSystems:WaitForChild("Game")
local SprintingSystem:ModuleScript = require(CharacterSystems_Game:WaitForChild("Sprinting"))

local Network:ModuleScript = Modules:WaitForChild("Network")
local UnreliableRemoteEvent:UnreliableRemoteEvent = Network:WaitForChild("UnreliableRemoteEvent")

local Misc:Folder = Modules:WaitForChild("Misc")
local FlowGameManager:ModuleScript = require(Misc:WaitForChild("FlowGameManager"))

local ChatWindowConfig = TextChatService:WaitForChild("ChatWindowConfiguration")

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

local function GetRoundPlayers():({
    ["Survivors"]:{Model};
    ["Killers"]:{Model};
})
    return {
        ["Survivors"] = SurvivorsFolder:GetChildren();
        ["Killers"] = KillersFolder:GetChildren();
    }
end

local function MakeHighlight(
    Size:Vector3?,
    Name:string?
):(BoxHandleAdornment)
    local Highlight = CreateInstance("BoxHandleAdornment", {
        Transparency = 0.6;
        AlwaysOnTop = true;
        ZIndex = 5;
        Size = ((typeof(Size) == "Vector3") and Size) or Vector3.new(3, 3, 3);
        Name = ((type(Name) == "string") and Name) or "ProvidedHighlight";
    })

    return Highlight
end

local function ApplyPlayerHighlight(
    Character:Model, 
    Role:string
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

    local Highlight = MakeHighlight(ScriptSettings.EspSettings.PlayerESPSize, "__")
    local ColorToUse = ScriptSettings.EspSettings.PlayerColors[Role] or Color3.new(1, 1, 1)

    Highlight.Color3 = ColorToUse
    Highlight.Adornee = RootPart
    Highlight.Parent = RootPart

    local Connection; Connection = PlayerEspToggle:GetPropertyChangedSignal("Value"):Connect(function()
        if not Highlight then
            Connection:Disconnect()
            Connection = nil
            return
        end

        if not PlayerEspToggle.Value then 
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
                --[[repeat
                    if RootPart:FindFirstChild("__") then
                        RootPart:FindFirstChild("__"):Destroy()
                    else
                        break
                    end

                    task.wait()
                until not RootPart:FindFirstChild("__")]]
            end

            local Highlight = MakeHighlight(ScriptSettings.EspSettings.ItemESPSize, "__")
            local ColorToUse = ScriptSettings.EspSettings.ItemColors[Item.Name] or Color3.new(1, 1, 1)

            Highlight.Color3 = ColorToUse
            Highlight.Adornee = ItemRoot
            Highlight.Parent = ItemRoot

            local Connection; Connection = ItemEspToggle:GetPropertyChangedSignal("Value"):Connect(function()
                if not Highlight then
                    Connection:Disconnect()
                    Connection = nil
                    return
                end

                if not ItemEspToggle.Value then 
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

            local Highlight = MakeHighlight(ScriptSettings.EspSettings.GeneratorESPSize, "__")
            local ColorToUse = ScriptSettings.EspSettings.GeneratorColor or Color3.new(1, 1, 1)

            Highlight.Color3 = ColorToUse
            Highlight.Adornee = ItemRoot
            Highlight.Parent = ItemRoot

            local Connection; Connection = GeneratorEspToggle:GetPropertyChangedSignal("Value"):Connect(function()
                if not Highlight then
                    Connection:Disconnect()
                    Connection = nil
                    return
                end

                if not GeneratorEspToggle.Value then 
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
        if Survivor and Survivor:IsA("Model") and (Players:GetPlayerFromCharacter(Survivor) ~= LocalPlayer) then 
            task.spawn(ApplyPlayerHighlight, Survivor, "Survivor")
        end
    end
    for _, Killer:Model in pairs(RoundPlayers.Killers) do 
        if Killer and Killer:IsA("Model") and (Players:GetPlayerFromCharacter(Killer) ~= LocalPlayer) then 
            task.spawn(ApplyPlayerHighlight, Killer, "Killer")
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
    Theme = "Amber Glow";

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
            ItemEspToggle.Value = Value
        end;
    })
    MainTab:CreateToggle({
        Name = "Player ESP";
        CurrentValue = DefaultSettings.StaminaSettings.PlayerESPEnabled;
        Flag = "PlayerEspEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.StaminaSettings.PlayerESPEnabled = Value
            PlayerEspToggle.Value = Value
        end;
    })
    MainTab:CreateToggle({
        Name = "Generator ESP";
        CurrentValue = DefaultSettings.EspSettings.GeneratorESPEnabled;
        Flag = "GeneratorEspEnabled_Flag";
        Callback = function(Value)
            getgenv().ScriptSettings.EspSettings.GeneratorESPEnabled = Value
            GeneratorEspToggle.Value = Value
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
            AutoGenToggle.Value = Value
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

    while true do
        if ItemEspToggle.Value then 
            task.spawn(HighlightItems)
        end
        if PlayerEspToggle.Value then 
            task.spawn(HighlightPlayers)
        end
        if GeneratorEspToggle.Value then 
            task.spawn(HighlightGenerators)
        end
        if AutoGenToggle.Value then
            local InGenerator = (FlowGameManager.activeGame ~= nil)

            if (InGenerator and not WasInGenerator) then
                Started = os.clock()
            end

            if (InGenerator) then
                local TimePassed = (os.clock() - Started)
                if (TimePassed >= ScriptSettings.Misc.AutoGenSpeed) then
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
