--//// contact: @_x4yz
--!native

--//// Provides various client-side utility functions for use in local scripts, including:
--//// Player handling, instance creation, raycasting, prediction, connection management, and more.

--//// Public Fields:
--// ClientUtils.LocalPlayer: The current local player.
--// ClientUtils.IsStudio: True if running in Roblox Studio.
--// ClientUtils.IsClient: True if running on the client.

--//// Types:
--// export type ClientUtil_Types = {
--//     [Documentation for each method defined in the module]
--// }

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer:Player = Players.LocalPlayer
if not LocalPlayer then
	repeat
		LocalPlayer = Players.LocalPlayer
		task.wait()
	until LocalPlayer
end

local Mouse:Mouse = LocalPlayer:GetMouse()

export type ClientUtil_Types = {
	LocalPlayer:(Player);
	IsStudio:(boolean);
	IsClient:(boolean);

	GeneralUtils:{
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
			Function:(...any) -> any, 
			...any
		) -> (boolean, any);

		QuickSafeCall:(
			Function:(...any) -> any, 
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
	};
	
	ConnectionUtils:{
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
	};
	
	PlayerUtils:{
		GetPlayerByName:(
			PlayerName:string
		) -> (Player | false?);
		
		GetRandomPlayer:() -> Player;

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
		) -> (BasePart? | false?);
	};
	
	RaycastUtils:{
		GetMouseHitPosition:(
			UseCustomRaycast:boolean?, 
			DirectionMultiplier:number?, 
			RaycastParameters:RaycastParams?
		) -> (Vector3, RaycastResult?);

		GetMouseTarget:(
			UseCustomRaycast:boolean?, 
			DirectionMultiplier:number?, 
			RaycastParameters:RaycastParams?
		) -> (Instance?, RaycastResult?);

		FireRaycast:(
			Origin:Vector3, 
			Direction:Vector3, 
			RaycastParameters:RaycastParams?
		) -> (RaycastResult? | false?);
	};

	PredictionUtils:{
		GetPredictedPosition:(
			BasePartOrPosition:BasePart|Vector3,
			VelocityIfPosition:Vector3?
		) -> (Vector3 | false);

		GetPredictedPositionUsingGravityAndVelocity:(
			BasePartOrPosition:BasePart|Vector3, 
			TimeDelta:number,
			VelocityIfPosition:Vector3?
		) -> (Vector3 | false);
	};
	
	MathUtils:{
		GetAngleBetween:(
			V1:Vector3, 
			V2:Vector3
		) -> (number);
		
		GetAbsoluteValueOfNumber:(
			Value:number
		) -> (number);
		
		GetDistanceFromPosition:(
			From:Vector3, 
			Position:Vector3
		) -> (number);
		
		GetFlatDistance:(
			V1:Vector3, 
			V2:Vector3
		) -> (number);
		
		IsPositionWithinDistance:(
			Position:Vector3, 
			From:Vector3, 
			MaxDistance:number
		) -> (boolean);
		
		IsPositionOutOfDistance:(
			Position:Vector3, 
			From:Vector3, 
			MaxDistance:number
		) -> (boolean);
		
		ClampNumber:(
			Value:number, 
			Min:number, 
			Max:number
		) -> (number);
		
		GetDirection:(
			From:Vector3, 
			To:Vector3
		) -> (Vector3);
	};
}

local ClientUtils = {
	MathUtils = {};
	PredictionUtils = {};
	RaycastUtils = {};
	PlayerUtils = {};
	ConnectionUtils = {};
	GeneralUtils = {};
}
local Connections = {}
local ServicesCache = {}

ClientUtils.IsStudio = RunService:IsStudio()
ClientUtils.IsClient = RunService:IsClient()
ClientUtils.LocalPlayer = LocalPlayer

--// SafeCall
-- Calls a function in a protected (pcall) environment.
-- @param Function (...any) -> any: The function to call.
-- @return success:boolean, result:any
function ClientUtils.GeneralUtils.SafeCall(
	Function:((...any) -> any),
	...
):(boolean, any)
	if (type(Function) ~= "function") then
		return false, "Not a function."
	end

	return pcall(Function, ...)
end

--// QuickSafeCall
-- Same as SafeCall, but spawns the call asynchronously.
-- @param Functio (...any) -> any: The function to call.
-- @return success:boolean, result:any
function ClientUtils.GeneralUtils.QuickSafeCall(
	Function:((...any) -> any),
	...
):(boolean, any)
	if (type(Function) ~= "function") then
		return false, "Not a function."
	end

	task.spawn(pcall, Function, ...)
	return true
end

--// GetService
-- Returns a service from the game by name, with caching.
-- @param ServiceName:string
-- @return ServiceInstance:any?
function ClientUtils.GeneralUtils.GetService(
	ServiceName:string
):(any?)
	if ServicesCache[ServiceName] then
		return ServicesCache[ServiceName]
	end

	local Success, Service = ClientUtils.SafeCall(function()
		return game:GetService(ServiceName)
	end)
	
	if Success and Service then
		ServicesCache[ServiceName] = Service
		return Service
	end
	
	return nil
end

--// GetCamera
-- Gets the current camera, falling back if needed.
-- @return Camera?
function ClientUtils.GeneralUtils.GetCamera():(Camera?)
	return Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")
end

--// WaitForChildWhichIsA
-- Waits for a child of a specific class and optional name.
-- @param Parent:Instance
-- @param ClassName:string
-- @param Name:string?
-- @param TimeOut:number?
-- @return Instance?
function ClientUtils.GeneralUtils.WaitForChildWhichIsA(
	Parent:Instance, 
	ClassName:string, 
	Name:string?, 
	TimeOut:number?
):(Instance?)
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
			local AbsTimeOut:number = ((TimeOut < 0) and -TimeOut) or TimeOut
			local StartTime:number = os.clock()

			if (AbsTimeOut == 0) then
				if Parent and Parent.Parent then
					InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
					if ((type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name)) or InstanceToReturn then
						return InstanceToReturn
					end
				end

				return InstanceToReturn
			end

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

		return InstanceToReturn
	end
end

--// BindToInstance
-- Binds a callback to an instance's event, and disconnects on destroy.
-- @return RBXScriptConnection | false
function ClientUtils.GeneralUtils.BindToInstance(
	Object:Instance,
	Event:RBXScriptSignal,
	Callback:((...any) -> any)
):(RBXScriptConnection|false?)
	if (typeof(Object) ~= "Instance") then
		return false
	end
	if (typeof(Event) ~= "RBXScriptSignal") then
		return false
	end
	if (type(Callback) ~= "function") then
		return false
	end
	
	local Success, Connection = ClientUtils.SafeCall(function()
		return Event:Connect(Callback)
	end)
	
	if Success and (typeof(Connection) == "RBXScriptConnection") then
		Instance.Destroying:Once(ClientUtils.SafeCall(function()
			if Connection and Connection.Connected then
				Connection:Disconnect()
			end
		end))
		
		return Connection
	end
	
	return false
end

--// GetMouseHitPosition
-- Gets the 3D position the mouse is pointing at using raycast or legacy mouse.
-- @param UseCustomRaycast:boolean?
-- @param DirectionMultiplier:number?
-- @param RaycastParams:RaycastParams?
-- @return Vector3, RaycastResult?
function ClientUtils.RaycastUtils.GetMouseHitPosition(
	UseCustomRaycast:boolean?, 
	DirectionMultiplier:number?, 
	RaycastParameters:RaycastParams?
):(Vector3, RaycastResult?)
	if (type(UseCustomRaycast) ~= "boolean") then
		UseCustomRaycast = true
	end
	if not UseCustomRaycast then
		return Mouse.Hit.Position
	end

	local Camera = ClientUtils.GetCamera()
	if not Camera then
		return
	end

	local MouseScreenPosition:Vector2 = UserInputService:GetMouseLocation()
	local RayFromViewport = Camera:ViewportPointToRay(MouseScreenPosition.X, MouseScreenPosition.Y)

	local Multiplier = ((type(DirectionMultiplier) == "number") and DirectionMultiplier) or 1000
	if (Multiplier ~= Multiplier) 
		or (Multiplier == -math.huge) 
		or (Multiplier == math.huge) 
	then
		Multiplier = 1000
	end

	local Result:RaycastResult?

	if (typeof(RaycastParameters) == "RaycastParams") then
		Result = Workspace:Raycast(RayFromViewport.Origin, (RayFromViewport.Direction * Multiplier), RaycastParameters)
	else
		Result = Workspace:Raycast(RayFromViewport.Origin, RayFromViewport.Direction * Multiplier)
	end

	if Result then
		return Result.Position, Result
	else
		return (RayFromViewport.Origin + (RayFromViewport.Direction * 1000))
	end
end

--// GetMouseTarget
-- Gets the instance the mouse is pointing at.
-- @return Instance?, RaycastResult?
function ClientUtils.RaycastUtils.GetMouseTarget(
	UseCustomRaycast:boolean?, 
	DirectionMultiplier:number?, 
	RaycastParameters:RaycastParams?
):(Instance, RaycastResult?)
	if (type(UseCustomRaycast) ~= "boolean") then
		UseCustomRaycast = true
	end
	if not UseCustomRaycast then
		return Mouse.Target
	end

	local Camera = ClientUtils.GetCamera()
	if not Camera then
		return
	end

	local MouseScreenPosition:Vector2 = UserInputService:GetMouseLocation()
	local RayFromViewport = Camera:ViewportPointToRay(MouseScreenPosition.X, MouseScreenPosition.Y)

	local Multiplier = ((type(DirectionMultiplier) == "number") and DirectionMultiplier) or 1000
	if (Multiplier ~= Multiplier) 
		or (Multiplier == -math.huge) 
		or (Multiplier == math.huge) 
	then
		Multiplier = 1000
	end

	local Result:RaycastResult?

	if (typeof(RaycastParameters) == "RaycastParams") then
		Result = Workspace:Raycast(RayFromViewport.Origin, (RayFromViewport.Direction * Multiplier), RaycastParameters)
	else
		Result = Workspace:Raycast(RayFromViewport.Origin, RayFromViewport.Direction * Multiplier)
	end

	if Result then
		return Result.Instance, Result
	else
		return nil
	end
end

--// GetClosestPlayerToCharacter
-- Finds the closest player to the local player's character.
-- @param IgnoreDead:boolean?
-- @return Player?, BasePart?, Distance:number
function ClientUtils.PlayerUtils.GetClosestPlayerToCharacter(
	IgnoreDead:boolean?
):(Player, BasePart, number)
	local ClosestDistance = math.huge
	local ClosestPlayer = nil
	local ClosestPart = nil

	local Character = LocalPlayer.Character
	if not Character then
		return
	end
	local PrimaryPart:BasePart? = Character.PrimaryPart 
		or Character:FindFirstChild("HumanoidRootPart") 
		or Character:FindFirstChild("Head")
	if not PrimaryPart then
		return
	end

	IgnoreDead = ((type(IgnoreDead) == "boolean") and IgnoreDead)

	for _, Player in pairs(Players:GetPlayers()) do
		local PlayerCharacter = Player.Character
		local Humanoid = PlayerCharacter and PlayerCharacter:FindFirstChildWhichIsA("Humanoid")

		if (Player ~= LocalPlayer) 
			and PlayerCharacter 
			and Humanoid 
			and (not IgnoreDead or (Humanoid.Health > 0))
		then
			local PlayerPrimaryPart:BasePart? = PlayerCharacter.PrimaryPart 
				or PlayerCharacter:FindFirstChild("HumanoidRootPart") 
				or PlayerCharacter:FindFirstChild("Head")

			if PlayerPrimaryPart then
				local Distance = (PlayerPrimaryPart.Position - PrimaryPart.Position).Magnitude
				if (Distance < ClosestDistance) then
					ClosestDistance = Distance
					ClosestPlayer = Player
					ClosestPart = PlayerPrimaryPart
				end
			end
		end
	end

	return ClosestPlayer, ClosestPart, ClosestDistance
end

--// GetClosestPlayerToMouseOnScreen
-- Finds the closest player to the mouse in screen space.
-- @param MaxScreenDistance:number?
-- @param IgnoreDead:boolean?
-- @param RequireOnScreen:boolean?
-- @return Player?, BasePart?, Distance:number
function ClientUtils.PlayerUtils.GetClosestPlayerToMouseOnScreen(
	MaxScreenDistance:number?, 
	IgnoreDead:boolean?, 
	RequireOnScreen:boolean?
):(Player, BasePart, number)
	local Camera = ClientUtils.GetCamera()
	if not Camera then
		return
	end

	local MousePosition:Vector2 = UserInputService:GetMouseLocation()
	local ClosestPlayer = nil
	local ClosestDistance = math.huge
	local ClosestPart = nil

	MaxScreenDistance = (((type(MaxScreenDistance) == "number") and MaxScreenDistance > 0) and MaxScreenDistance) 
		or math.huge
	IgnoreDead = ((type(IgnoreDead) == "boolean") and IgnoreDead)
	RequireOnScreen = ((type(RequireOnScreen) == "boolean") and RequireOnScreen) 

	for _, Player in pairs(Players:GetPlayers()) do
		if (Player ~= LocalPlayer) then
			local Character = Player.Character
			local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")

			if Character and Humanoid and (not IgnoreDead or Humanoid.Health > 0) then
				for _, Part in pairs(Character:GetChildren()) do
					if Part and Part:IsA("BasePart") then
						local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)

						if not RequireOnScreen or OnScreen then
							local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePosition).Magnitude
							if (Distance < ClosestDistance) and (Distance <= MaxScreenDistance) then
								ClosestDistance = Distance
								ClosestPlayer = Player
								ClosestPart = Part
							end
						end
					end
				end
			end
		end
	end

	return ClosestPlayer, ClosestPart, ClosestDistance
end

--// GetPredictedPosition
-- Predicts a moving object's future position based on ping.
-- @param BasePartOrPosition:BasePart | Vector3
-- @param VelocityIfPosition:Vector3?
-- @return Vector3 | false
function ClientUtils.PredictionUtils.GetPredictedPosition(
	BasePartOrPosition:BasePart|Vector3,
	VelocityIfPosition:Vector3?
):(Vector3|boolean?)
	local IsVector3 = (typeof(BasePartOrPosition) == "Vector3")
	local IsBasePart = ((typeof(BasePartOrPosition) == "Instance") and BasePartOrPosition:IsA("BasePart"))

	if (not IsVector3 and not IsBasePart) then
		return false
	end
	
	local BasePartOrPositionIsAVector3 = (typeof(BasePartOrPosition) == "Vector3")
	
	if not BasePartOrPositionIsAVector3 and BasePartOrPosition.Anchored then
		return BasePartOrPosition.Position
	end
	
	local Velocity = BasePartOrPositionIsAVector3 and (
		((typeof(VelocityIfPosition) == "Vector3") and VelocityIfPosition) or Vector3.zero
	) or BasePartOrPosition.AssemblyLinearVelocity
	if (Velocity == Vector3.zero) then
		return BasePartOrPosition.Position
	end
	
	local Ping = LocalPlayer:GetNetworkPing()

	local Displacement = (Velocity * (Ping * 1.85))
	local PredictedPosition = (BasePartOrPosition.Position + Displacement)
	
	return PredictedPosition
end

--// GetPredictedPositionUsingGravityAndVelocity
-- Predicts future position with gravity and velocity included.
-- @param BasePartOrPosition:BasePart | Vector3
-- @param TimeDelta:number
-- @param VelocityIfPosition:Vector3?
-- @return Vector3 | false
function ClientUtils.PredictionUtils.GetPredictedPositionUsingGravityAndVelocity(
	BasePartOrPosition:BasePart|Vector3, 
	TimeDelta:number,
	VelocityIfPosition:Vector3?
):(Vector3|false?)
	local IsVector3 = (typeof(BasePartOrPosition) == "Vector3")
	local IsBasePart = ((typeof(BasePartOrPosition) == "Instance") and BasePartOrPosition:IsA("BasePart"))

	if (not IsVector3 and not IsBasePart) then
		return false
	end
	if (type(TimeDelta) ~= "number") then
		TimeDelta = LocalPlayer:GetNetworkPing()
	end
	
	local BasePartOrPositionIsAVector3 = (typeof(BasePartOrPosition) == "Vector3")
	
	if not BasePartOrPositionIsAVector3 and BasePartOrPosition.Anchored then
		return BasePartOrPosition.Position
	end

	local Ping = LocalPlayer:GetNetworkPing()
	local EffectiveTime = (TimeDelta + Ping)

	local CurrentPosition = BasePartOrPositionIsAVector3 and BasePartOrPosition or BasePartOrPosition.Position
	local Velocity = BasePartOrPositionIsAVector3 and (
		((typeof(VelocityIfPosition) == "Vector3") and VelocityIfPosition) or Vector3.zero
	) or BasePartOrPosition.AssemblyLinearVelocity

	if (Velocity == Vector3.zero) or (Velocity.Magnitude < 1e-4) then
		return CurrentPosition
	end

	local ApplyGravity = (math.abs(Velocity.Y) > 1e-3)
	local Gravity = ApplyGravity and Vector3.new(0, -workspace.Gravity, 0) or Vector3.zero

	local Displacement = (Velocity * EffectiveTime) + (0.5 * Gravity * (EffectiveTime ^ 2))
	local PredictedPosition = (CurrentPosition + Displacement)

	return PredictedPosition
end

--// CreateInstance
-- Creates and optionally configures an Instance.
-- @param Class:string
-- @param Properties:{[string]:any}?
-- @return Instance | false, boolean?
function ClientUtils.GeneralUtils.CreateInstance(
	Class:string, 
	Properties:{[string]:any?}
):(Instance, false?)
	if (type(Class) ~= "string") then
		return false
	end
	local UseProperties = (type(Properties) == "table")

	local Success, NewInstance = ClientUtils.SafeCall(function()
		return Instance.new(Class)
	end)
	if not Success or not NewInstance then
		return false
	end

	if UseProperties then
		local ParentPropertyToSet:Instance
		for Property:string, Value:any? in pairs(Properties) do 
			if (Property ~= "Parent") then
				ClientUtils.QuickSafeCall(function()
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

--// SetInstanceProperties
-- Sets multiple properties on an instance, safely.
-- @param Object:Instance
-- @param Properties:{[string]:any}
-- @return boolean
function ClientUtils.GeneralUtils.SetInstanceProperties(
	Object:Instance, 
	Properties:{[string]:any}
):(boolean)
	if (typeof(Object) ~= "Instance") then
		return false
	end
	if (typeof(Properties) ~= "table") then
		return false
	end

	local ParentPropertyToSet:Instance
	for Property:string, Value:any? in pairs(Properties) do 
		if (Property ~= "Parent") then
			ClientUtils.QuickSafeCall(function()
				Object[Property] = Value
			end)
		elseif (Property == "Parent") and (typeof(Value) == "Instance") then
			ParentPropertyToSet = Value
		end
	end

	if ParentPropertyToSet then
		ClientUtils.QuickSafeCall(function()
			Object.Parent = ParentPropertyToSet
		end)
	end

	return true
end

--// GetRandomPlayer
-- Returns a random player from the current player list.
-- @return Player
function ClientUtils.PlayerUtils.GetRandomPlayer():(Player)
	local PlayerList = Players:GetPlayers()
	local AmountOfPlayers = #PlayerList
	if (AmountOfPlayers == 1) then
		return PlayerList[1]
	end

	return PlayerList[math.random(1, AmountOfPlayers)]
end

--// GetPlayerByName
-- Gets a player by name or display name (case-insensitive, partial supported).
-- @param PlayerName:string
-- @return Player | false
function ClientUtils.PlayerUtils.GetPlayerByName(
	PlayerName:string
):(Player|false?)
	if (type(PlayerName) ~= "string") then
		return false
	end
	if (PlayerName == "") or (PlayerName == " ") then
		return false
	end

	local FoundPlayer
	for _, Player:Player in pairs(Players:GetPlayers()) do
		if Player then
			local LoweredName = string.lower(Player.Name)
			local LoweredDisplayName = string.lower(Player.DisplayName)

			local LoweredPlayerName = string.lower(tostring(PlayerName))

			if (LoweredName == LoweredPlayerName) 
				or (LoweredDisplayName == LoweredPlayerName) 
				or LoweredName:match(LoweredPlayerName)
				or LoweredDisplayName:match(LoweredPlayerName)
			then
				FoundPlayer = Player
				break
			end
		end
	end

	return FoundPlayer or false
end

--// IsDescendantOfLocalPlayerCharacter
-- Checks if an instance is part of the local player's character.
-- @param Object:Instance
-- @return boolean
function ClientUtils.PlayerUtils.IsDescendantOfLocalPlayerCharacter(
	Object:Instance
):(boolean)
	local Character = LocalPlayer.Character
	if not Character then
		return false
	end
	if (typeof(Object) ~= "Instance") then
		return false
	end

	return Object:IsDescendantOf(Character)
end

--// IsDescendantOfPlayerCharacter
-- Checks if an instance is part of a given player's character.
-- @param Player:Player
-- @param Object:Instance
-- @return boolean
function ClientUtils.PlayerUtils.IsDescendantOfPlayerCharacter(
	Player:Player,
	Object:Instance
):(boolean)
	local Character = (typeof(Player) == "Instance") and Player:IsA("Player") and Player.Character
	if not Character then
		return false
	end
	if (typeof(Object) ~= "Instance") then
		return false
	end

	return Object:IsDescendantOf(Character)
end

--// IsKeyDown
-- Checks if a specific key is currently held down.
-- @param Key:Enum.KeyCode
-- @return boolean
function ClientUtils.GeneralUtils.IsKeyDown(
	Key:Enum.KeyCode
):(boolean)
	if (typeof(Key) ~= "EnumItem") then
		return false
	end
	if (Key.EnumType ~= Enum.KeyCode) then
		return false
	end

	return UserInputService:IsKeyDown(Key)
end

--// IsOnMobile
-- Returns true if the client is a mobile device (touch without keyboard).
-- @return boolean
function ClientUtils.GeneralUtils.IsOnMobile():(boolean)
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

--// GetAngleBetween
-- Gets the angle between two vectors in degrees.
-- @param V1:Vector3
-- @param V2:Vector3
-- @return number
function ClientUtils.MathUtils.GetAngleBetween(
	V1:Vector3, 
	V2:Vector3
):(number)
	if (typeof(V1) ~= "Vector3") then
		return 0
	end
	if (typeof(V2) ~= "Vector3") then
		return 0
	end

	return math.deg(math.acos(math.clamp(V1.Unit:Dot(V2.Unit), -1, 1)))
end

--// GetDistanceFromPosition
-- Gets the distance from a position.
-- @param From:Vector3
-- @param Position:Vector3
-- @return number
function ClientUtils.MathUtils.GetDistanceFromPosition(
	From:Vector3,
	Position:Vector3
):(number)
	if (typeof(From) ~= "Vector3") then
		return 0
	end
	if (typeof(Position) ~= "Vector3") then
		return 0
	end
	
	local Distance = (Position - From).Magnitude
	return Distance
end

function ClientUtils.MathUtils.GetFlatDistance(
	V1:Vector3, 
	V2:Vector3
):(number)
	if (typeof(V1) ~= "Vector3") then
		return 0
	end
	if (typeof(V2) ~= "Vector3") then
		return 0
	end
	if (V1.X == V2.X) and (V1.Z == V2.Z) then
		return 0
	end

	local Distance = (
		Vector3.new(V1.X, 0, V1.Z) - Vector3.new(V2.X, 0, V2.Z)
	).Magnitude
	return Distance
end

--// IsPositionWithinDistance
-- Returns if position is within distance or not.
-- @param From:Vector3
-- @param Position:Vector3
-- @param MaxDistance:number
-- @return boolean
function ClientUtils.MathUtils.IsPositionWithinDistance(
	Position:Vector3,
	From:Vector3,
	MaxDistance:number
):(boolean)
	if (typeof(Position) ~= "Vector3") then
		return false
	end
	if (typeof(From) ~= "Vector3") then
		return false
	end
	if (type(MaxDistance) ~= "number") then
		return false
	end
	
	if (MaxDistance == math.huge) then
		return true
	end
	if (MaxDistance == -math.huge) then
		return false
	end
	if (MaxDistance ~= MaxDistance) then
		return false
	end

	local Distance = (Position - From).Magnitude
	return (Distance <= MaxDistance)
end

--// IsPositionOutOfDistance
-- Returns if position is out of distance or not.
-- @param From:Vector3
-- @param Position:Vector3
-- @param MaxDistance:number
-- @return boolean
function ClientUtils.MathUtils.IsPositionOutOfDistance(
	Position:Vector3,
	From:Vector3,
	MaxDistance:number
):(boolean)
	if (typeof(Position) ~= "Vector3") then
		return false
	end
	if (typeof(From) ~= "Vector3") then
		return false
	end
	if (type(MaxDistance) ~= "number") then
		return false
	end

	if (MaxDistance == math.huge) then
		return false
	end
	if (MaxDistance == -math.huge) then
		return true
	end
	if (MaxDistance ~= MaxDistance) then
		return true
	end

	local Distance = (Position - From).Magnitude
	return (Distance > MaxDistance)
end


--// GetAbsoluteValueOfNumber
-- Gets the absolute value of a number.
-- @param Value:number
-- @return number
function ClientUtils.MathUtils.GetAbsoluteValueOfNumber(
	Value:number
):(number)
	if (type(Value) ~= "number") then
		return 0
	end
	if (Value ~= Value) then
		return Value
	end

	return math.abs(Value)
end

--// ClampNumber
-- Returns a number between min and max.
-- @param Value:number
-- @param Min:number
-- @param Max:number
-- @return boolean
function ClientUtils.MathUtils.ClampNumber(
	Value:number,
	Min:number,
	Max:number
):(number)
	if (type(Value) ~= "number") then
		return 0
	end
	if (type(Min) ~= "number") then
		return 0
	end
	if (type(Max) ~= "number") then
		return 0
	end
	if (Value ~= Value) then
		return 0
	end
	
	if (Value < Min) then
		return Min
	elseif (Value > Max) then
		return Max
	end
	
	return Value
end

--// GetDirection
-- Returns the normalized direction vector pointing from `From` to `To`. If either vector is invalid or if both positions are equal, returns a zero vector.
-- @param From Vector3 -- The starting position.
-- @param To Vector3 -- The target position.
-- @return Vector3 -- The direction from `From` to `To`, normalized.
function ClientUtils.MathUtils.GetDirection(
	From:Vector3, 
	To:Vector3
):(Vector3)
	if (typeof(From) ~= "Vector3") then
		return Vector3.zero
	end
	if (typeof(To) ~= "Vector3") then
		return Vector3.zero
	end
	if (From == To) then
		return Vector3.zero
	end

	return (To - From).Unit
end

--// FireRaycast
-- Performs a raycast with optional parameters.
-- @param Origin:Vector3
-- @param Direction:Vector3
-- @param RaycastParams:RaycastParams?
-- @return RaycastResult | false
function ClientUtils.RaycastUtils.FireRaycast(
	Origin:Vector3, 
	Direction:Vector3, 
	RaycastParameters:RaycastParams?
):(RaycastResult|false?)
	if (typeof(Origin) ~= "Vector3") then
		return false
	end
	if (typeof(Direction) ~= "Vector3") then
		return false
	end

	if (typeof(RaycastParameters) ~= "RaycastParams") then
		return Workspace:Raycast(Origin, Direction)
	else
		return Workspace:Raycast(Origin, Direction, RaycastParameters)
	end
end

--// GetCharacterPart
-- Returns a preferred part of a player's character, or fallback part.
-- @param Player:Player
-- @param Prefer:string?
-- @return BasePart? | false
function ClientUtils.PlayerUtils.GetCharacterPart(
	Player:Player, 
	Prefer:string?
):(BasePart?|false?)
	local Character = (typeof(Player) == "Instance") and Player:IsA("Player") and Player.Character
	if not Character then
		return false
	end

	if (type(Prefer) == "string") and Character:FindFirstChild(Prefer) then
		local Part = Character:FindFirstChild(Prefer)
		if Part and Part:IsA("BasePart") then
			return Part
		end
	end

	return Character:FindFirstChild("HumanoidRootPart") 
		or Character:FindFirstChild("Head") 
		or Character:FindFirstChildWhichIsA("BasePart")
end

--// IsPointOnScreen
-- Determines if a 3D world point is on screen.
-- @param Position:Vector3
-- @return boolean
function ClientUtils.GeneralUtils.IsPointOnScreen(
	Position:Vector3
):(boolean)
	if (typeof(Position) ~= "Vector3") then
		return false
	end
	local Camera = ClientUtils.GetCamera()
	if not Camera then
		return
	end

	local _, OnScreen = Camera:WorldToViewportPoint(Position)
	return OnScreen
end

--// CreateConnection
-- Binds and stores a named connection.
-- @param Identifier:string
-- @param Signal:RBXScriptSignal
-- @param FunctionToBind:(...any) -> any
-- @return RBXScriptConnection | false
function ClientUtils.ConnectionUtils.CreateConnection(
	Identifier:string,
	Signal:RBXScriptSignal, 
	FunctionToBind:((...any) -> any)
):(RBXScriptConnection|false?)
	if (type(Identifier) ~= "string") then
		return false
	end
	if (typeof(Signal) ~= "RBXScriptSignal") then
		return false
	end
	if (type(FunctionToBind) ~= "function") then
		return false
	end
	
	local Success, Connection = ClientUtils.SafeCall(function()
		return Signal:Connect(FunctionToBind)
	end)
	
	if Success and (typeof(Connection) == "RBXScriptConnection") then
		local ExistingConnection:RBXScriptConnection? = Connections[Identifier]
		if (typeof(ExistingConnection) == "RBXScriptConnection") then
			ClientUtils.SafeCall(function()
				Connections[Identifier] = nil
				if ExistingConnection.Connected then
					ExistingConnection:Disconnect()
				end
			end)
			ExistingConnection = nil
		end
		
		Connections[Identifier] = Connection
	end
	
	return (Success and (typeof(Connection) == "RBXScriptConnection") and Connection or false), ""
end

--// RemoveConnection
-- Disconnects and removes a stored connection.
-- @param Identifier:string
-- @return boolean
function ClientUtils.ConnectionUtils.RemoveConnection(
	Identifier:string
):(boolean)
	if (type(Identifier) ~= "string") then
		return false
	end

	local Success, _ = ClientUtils.SafeCall(function()
		local ExistingConnection:RBXScriptConnection? = Connections[Identifier]
		if (typeof(ExistingConnection) == "RBXScriptConnection") then
			Connections[Identifier] = nil
			if ExistingConnection.Connected then
				ExistingConnection:Disconnect()
			end
			ExistingConnection = nil
		end
	end)

	return Success
end

--// ClearConnections
-- Disconnects all tracked connections.
-- @return boolean
function ClientUtils.ConnectionUtils.ClearConnections():(boolean)
	local Success, _ = ClientUtils.SafeCall(function()
		for Index, Connection:RBXScriptConnection in pairs(Connections) do 
			if (typeof(Connection) == "RBXScriptConnection") then
				Connections[Index] = nil
				if Connection.Connected then
					Connection:Disconnect()
				end
				Connection = nil
			else
				Connections[Index] = nil
			end
		end
	end)

	return Success
end

--// GetConnection
-- Retrieves a stored connection by name.
-- @param Identifier:string
-- @return RBXScriptConnection | false
function ClientUtils.ConnectionUtils.GetConnection(
	Identifier:string
):(RBXScriptConnection|false?)
	if (type(Identifier) ~= "string") then
		return false
	end
	
	local ExistingConnection:RBXScriptConnection? = Connections[Identifier]
	if (typeof(ExistingConnection) == "RBXScriptConnection") then
		return ExistingConnection
	end

	return false
end

return ClientUtils
