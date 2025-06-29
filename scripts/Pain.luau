--// @_x4yz

local Utils = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/Utils.luau")
)()

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

local function SelectTargetFunction():(boolean)
    local Player:Player?, Part:BasePart, Distance:number = GetClosestPlayerToMouseOnScreen(math.huge, true, false)
    if not Player or not Part or not Distance then
        _G.TargetedPlayer = ""
        return false
    end

    _G.TargetedPlayer = Player.Name
    return true
end
local function ToggleStatusFunction():(boolean)
    if (_G.ToggledStatus) then
		_G.ToggledStatus = false
	else
		_G.ToggledStatus = true
	end
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
    if not _G.ToggledStatus then 
        return
    end

    local TargetPlayerName:string = _G.TargetedPlayer
    if not TargetPlayerName then 
        return
    end
    local TargetPlayer:(Player|boolean?) = GetPlayerByName(TargetPlayerName)
    if not TargetPlayer or (typeof(TargetPlayer) ~= "Instance") or not TargetPlayer:IsA("Player") then 
        return
    end
    local BasePart:BasePart? = GetCharacterPart(TargetPlayer, "Torso")
    if not BasePart then 
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

    local PredictedPosition:(Vector3|boolean)? = GetPredictedPositionUsingGravityAndVelocity(BasePart, TimeDelta)
    if not PredictedPosition or (typeof(PredictedPosition) ~= "Vector3") then 
        return
    end
    
    coroutine.wrap(CoroutinedFireFunction)(PredictedPosition, RemoteFunction)
end

_G.ToggledStatus = false
if _G.MainRunServiceLoop then 
    _G.MainRunServiceLoop:Disconnect()
    _G.MainRunServiceLoop = nil
end

_G.MainRunServiceLoop = RunService.Heartbeat:Connect(MainLoopFunction)

ContextActionService:UnbindAction("_SelectTarget__")
ContextActionService:UnbindAction("_ToggleStatus__")

ContextActionService:BindAction("_SelectTarget__", function(_, InputState)
    if (InputState == Enum.UserInputState.Begin) then 
		task.spawn(SelectTargetFunction)
    end

    return Enum.ContextActionResult.Pass
end, false, Keybinds.SelectTarget)
ContextActionService:BindAction("_ToggleStatus__", function(_, InputState)
    if (InputState == Enum.UserInputState.Begin) then 
        task.spawn(ToggleStatusFunction)
    end

    return Enum.ContextActionResult.Pass
end, false, Keybinds.ToggleStatus)
