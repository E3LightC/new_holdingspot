type ClientUtils = {
	LocalPlayer:(Player);
}
type GeneralUtils = {
    CreateInstance:(
        Class:string, 
        Properties:{[string]:any}?
    ) -> (Instance | false, boolean?);

    WaitForChildWhichIsA:(
        Parent:Instance, 
        ClassName:string, 
        Name:string?, 
        TimeOut:number?
    ) -> (Instance?);

    BindToInstance:(
        Object:Instance,
        Event:RBXScriptSignal,
        Callback:((...any) -> any)
    ) -> (RBXScriptConnection | false?);

    SetInstanceProperties:(
        Object:Instance, 
        Properties:{[string]:any}
    ) -> (boolean);

    SafeCall:(
        Function:((...any) -> any), 
        ...any
    ) -> (boolean, any);

	QuickSafeCall:(
		Function:((...any) -> any), 
		...any
	) -> (boolean, any);

	QuickCall:(
		Function:((...any) -> any), 
		...any
	) -> (boolean, any);

    GetService:(
        ServiceName:string
    ) -> (any?);

    IsKeyDown:(
        Key:Enum.KeyCode
    ) -> (boolean);

    IsOnMobile:() -> (boolean);

    IsPointOnScreen:(
        Position:Vector3
    ) -> (boolean);

    GetCamera:() -> (Camera?)
}
type ConnectionUtils = {
	CreateConnection:(
		Identifier:string,
		Signal:RBXScriptSignal,
		FunctionToBind:((...any) -> any)
	) -> (RBXScriptConnection | false?);

	RemoveConnection:(
		Identifier:string
	) -> (boolean);

	ClearConnections:() -> (boolean);

	GetConnection:(
		Identifier:string
	) -> (RBXScriptConnection | false?);

	BatchCreateConnections:(
		ConnectionDefinitions:({[string]:{
			Signal:RBXScriptSignal; 
			Callback:((...any) -> (any));
		}})
	) -> (boolean);
}
type PredictionUtils ={
	GetPredictedPosition:(
		BasePartOrPosition:BasePart|Vector3,
		VelocityIfPosition:Vector3?
	) -> (Vector3 | false);

	GetPredictedPositionUsingGravityAndVelocity:(
		BasePartOrPosition:BasePart|Vector3, 
		TimeDelta:number,
		VelocityIfPosition:Vector3?
	) -> (Vector3 | false);
}
type PlayerUtils = {
	GetPlayerByName:(
		PlayerName:string
	) -> (Player | false?);

	GetRandomPlayer:(() -> Player?);

	GetPlayers:(() -> {Player?});
	
	GetPlayerCharacterHumanoid:(
		Player:Player
	) -> (Humanoid | false?);

	IsDescendantOfLocalPlayerCharacter:(
		Object:Instance
	) -> (boolean);

	IsDescendantOfPlayerCharacter:(
		Player:Player, 
		Object:Instance
	) -> (boolean);

	GetClosestPlayerToCharacter:(
		IgnoreDead:boolean?
	) -> (Player?, BasePart?, number);

	GetClosestPlayerToMouseOnScreen:(
		MaxScreenDistance:number?, 
		IgnoreDead:boolean?, 
		RequireOnScreen:boolean?
	) -> (Player?, BasePart?, number);

	GetCharacterPart:(
		Player:Player, 
		Prefer:string?
	) -> (BasePart | false?);

	GetPlayerCharacterPosition:(
		Player:Player,
		GetCFrame:boolean?
	) -> (Vector3|CFrame|false?);

	IsOnSameTeam:(
		PlayerA:Player,
		PlayerB:Player
	) -> (boolean);

	GetPlayersWithinDistance:(
		ReferencePosition:Vector3,
		MaxDistance:number?
	) -> ({Player?});

	WaitForCondition:(
		Condition:(() -> (boolean)),
		TimeOut:number?,
		Interval:number?
	) -> (boolean);

	Ternary:(
		Condition:any, 
		IfTrue:any, 
		IfFalse:any
	) -> (any?);
}

local ClientUtils:ClientUtils = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/Utils.luau")
)()

local LocalPlayer:Player = ClientUtils.LocalPlayer
local PlayerGui:PlayerGui = LocalPlayer.PlayerGu

local GeneralUtils:GeneralUtils = ClientUtils.GeneralUtils
local ConnectionUtils:ConnectionUtils = ClientUtils.ConnectionUtils
local PlayerUtils:PlayerUtils = ClientUtils.PlayerUtils
local PredictionUtils:PredictionUtils = ClientUtils.PredictionUtils

local UserInputService:UserInputService = GeneralUtils.GetService("UserInputService")
local RunService:RunService = GeneralUtils.GetService("RunService")

ConnectionUtils.ClearConnections()

local Settings = shared.Settings
if not shared.Settings then
    Settings = shared.Settings
    shared.Settings = {
        MainSettings = {
            AutoChooseWeapon = false;
            WeaponChoice = "Minigun";
        };

        MinigunSettings = {
            Enabled = false;
            IgnoreDead = true;
            ShootType = "Prediction"; --// "Prediction" | "NoPrediction"
            TargetType = "Closest"; --// "Closest" | "LeastHealth"
            PredictionOffset = 0;
        };
    }
end

local function GetTarget():(Player|false?, BasePart|false?)
    local Target:Player? = nil
    local TargetPart:BasePart? = nil

    if (Settings.MinigunSettings.TargetType == "Closest") then
        Target, TargetPart = PlayerUtils.GetClosestPlayerToCharacter(Settings.MinigunSettings.IgnoreDead)
    elseif (Settings.MinigunSettings.TargetType == "LeastHealth") then
        local Players:{Player?} = PlayerUtils.GetPlayers()
        local LowestHealth:number = math.huge

        for _, Player:Player? in pairs(Players) do
            if Player and Player.Character then
                local Humanoid:Humanoid|false? = PlayerUtils.GetPlayerCharacterHumanoid(Player)
                if not Humanoid then
                    continue
                end
                if Settings.MinigunSettings.IgnoreDead and (Humanoid.Health <= 0) then
                    continue
                end

                if (Humanoid.Health < LowestHealth) then
                    LowestHealth = Humanoid.Health
                    Target, TargetPart = Player, PlayerUtils.GetCharacterPart(Player, "HumanoidRootPart")
                end
            end
        end
    end

    if not Target and not TargetPart then
        return false, false
    end
    return Target, TargetPart
end

local function GetPositionToFireAt(
    BasePart:BasePart,
    TimeDeltaForPrediction:number?
):(Vector3|false?)
    if (typeof(BasePart) ~= "Instance") or not BasePart:IsA("BasePart") then
        return false
    end

    local ShootType:("Prediction"|"NoPrediction") = Settings.MinigunSettings.ShootType

    if (ShootType == "NoPrediction") then
        return BasePart.Position
    elseif (ShootType == "Prediction") then
        if (type(TimeDeltaForPrediction) ~= "number") or (TimeDeltaForPrediction ~= TimeDeltaForPrediction) or (math.abs(TimeDeltaForPrediction) == math.huge) then
            TimeDeltaForPrediction = 0
        end

        return PredictionUtils.GetPredictedPositionUsingGravityAndVelocity(
            BasePart,
            TimeDeltaForPrediction
        )
    end

    return false
end

ConnectionUtils.CreateConnection("MinigunLoop", RunService.Heartbeat, function(Delta:number)
    local Character = LocalPlayer.Character
    if Settings.MinigunSettings.Enabled and Character then
        local Minigun:Model = Character:FindFirstChild("Minigun")
        if not Minigun then
            return
        end
        local ShootRemote:RemoteFunction = Minigun:FindFirstChildWhichIsA("RemoteFunction")
        if not ShootRemote then
            return
        end

        local Target:Player? = nil
        local TargetPart:BasePart? = nil

        Target, TargetPart = GetTarget()

        if Target and TargetPart and Target.Parent and TargetPart.Parent then
            local Position:Vector3|false? = GetPositionToFireAt(TargetPart, Delta)
            if not Position or (typeof(Position) ~= "Vector3") then
                return
            end

            GeneralUtils.QuickSafeCall(ShootRemote.InvokeServer, ShootRemote, 
                Position
            )
        end
    end
end)

ConnectionUtils.CreateConnection("AutoChooser", LocalPlayer.CharacterAdded, function()
    if Settings.MainSettings.AutoChooseWeapon then
        local SelectGUI:ScreenGui = PlayerGui:WaitForChild("Select")
        SelectGUI.Enabled = false
        local Frame:Frame = SelectGUI:WaitForChild("Frame")
        local RemoteEvent:RemoteEvent = GeneralUtils.WaitForChildWhichIsA(Frame, "RemoteEvent", "RemoteEvent", 3)

        if not RemoteEvent then
            return
        end

        RemoteEvent:FireServer(Settings.MainSettings.WeaponChoice)
        SelectGUI.Enabled = false
    end
end)
