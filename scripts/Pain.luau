local Utils = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/Utils.luau")
)
local Services = Utils.Services

local Players:Players = Services.Players
local RunService:RunService = Services.RunService
local ContextActionService:ContextActionService = Services.ContextActionService

local LocalPlayer = Players.LocalPlayer

local Keybinds = {
    SelectTarget = Enum.KeyCode.Q;
    ToggleStatus = Enum.KeyCode.Z;
}

local GetPredictedPositionUsingGravityAndVelocity:(
    BasePart:BasePart, 
    TimeDelta:number
) -> (Vector3|boolean?) = Utils.GetPredictedPositionUsingGravityAndVelocity
local GetPlayerByName:(
    PlayerName:string
) -> (Player|boolean?) = Utils.GetPlayerByName
local GetClosestPlayerToMouseOnScreen:(
    MaxScreenDistance:number?, 
    IgnoreDead:boolean?, 
    RequireOnScreen:boolean?
) -> (Player, BasePart, number) = Utils.GetClosestPlayerToMouseOnScreen
local GetCharacterPart:(
    Player:Player, 
    Prefer:string?
) -> (BasePart?) = Utils.GetCharacterPart

local function SelectTarget():(boolean)
    local Player:Player?, Part:BasePart, Distance:number = GetClosestPlayerToMouseOnScreen(math.huge, true, false)
    if not Player or not Part or not Distance then
        shared.TargetedPlayer = ""
        return false
    end

    shared.TargetedPlayer = Player.Name
    return true
end
local function ToggleStatus():(boolean)
    shared.ToggledStatus = not shared.ToggleStatus
    return true
end
local function GetWeaponModel():(Model|boolean?)
    local Character = LocalPlayer.Character
    if not Character then 
        return false
    end

    local WeaponModel = Character:FindFirstChild("Minigun")
        or Character:FindFirstChild("Hitman")
    return WeaponModel or false
end
local function CoroutinedFireFunction(PredictedPosition:Vector3, RemoteFunction:RemoteFunction)
    if (typeof(RemoteFunction) ~= "Instance") or not RemoteFunction:IsA("RemoteFunction") then 
        return
    end
    if (typeof(PredictedPosition) ~= "Vector3") then 
        return
    end

    RemoteFunction:InvokeServer(PredictedPosition)
end

local function MainLoopFunction(TimeDelta:number)
    if not shared.ToggledStatus then 
        return
    end

    local TargetPlayerName:string = shared.TargetedPlayer
    if not TargetPlayerName then 
        return
    end
    local TargetPlayer:(Player|boolean?) = GetPlayerByName(TargetPlayerName)
    if not TargetPlayer or (typeof(TargetPlayer) ~= "Instance") or not TargetPlayer:IsA("Player") then 
        return
    end
    local PrimaryPart:BasePart? = GetCharacterPart(TargetPlayer, "Torso")
    if not PrimaryPart then 
        return
    end
    local WeaponModel:(Model|boolean)? = GetWeaponModel()
    if not WeaponModel or (typeof(WeaponModel) ~= "Instance") or not WeaponModel:IsA("Model") then 
        return
    end
    local RemoteFunction:RemoteFunction? = WeaponModel:FindFirstChildWhichIsA("RemoteFunction")
    if not RemoteFunction then 
        return
    end

    local PredictedPosition:(Vector3|boolean)? = GetPredictedPositionUsingGravityAndVelocity(PrimaryPart, TimeDelta)
    if not PredictedPosition or (typeof(PredictedPosition) ~= "Vector3") then 
        return
    end
    
    coroutine.wrap(CoroutinedFireFunction)(PredictedPosition, RemoteFunction)
end

shared.ToggledStatus = false
if shared.MainRunServiceLoop then 
    shared.MainRunServiceLoop:Disconnect()
    shared.MainRunServiceLoop = nil
end

shared.MainRunServiceLoop = RunService.Heartbeat:Connect(MainLoopFunction)

ContextActionService:UnbindAction("_SelectTarget__")
ContextActionService:UnbindAction("_ToggleStatus__")

ContextActionService:BindAction("_SelectTarget__", function(_, InputState)
    if (InputState == Enum.UserInputState.Begin) then 
        SelectTarget()
    end
end, false, Keybinds.SelectTarget)
ContextActionService:BindAction("_ToggleStatus__", function(_, InputState)
    if (InputState == Enum.UserInputState.Begin) then 
        ToggleStatus()
    end
end, false, Keybinds.ToggleStatus)
