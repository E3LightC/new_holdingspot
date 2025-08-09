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

local ClientUtils = {
	MathUtils = {};
	PredictionUtils = {};
	RaycastUtils = {};
	PlayerUtils = {};
	ConnectionUtils = {};
	GeneralUtils = {};
	StringMathUtils = {};
}

if shared.ClientUtils then
	return shared.ClientUtils
else
	shared.ClientUtils = ClientUtils
	shared.DestroyClientUtils = (function():(boolean)
		shared.ClientUtils = nil
		shared.DestroyClientUtils = nil

		return true
	end)
end

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

local function PadStringRight(
	String:string, 
	Length:number
):(string)
	if (type(String) ~= "string") then
		return ""
	end
	if (type(Length) ~= "number") then
		return ""
	end

	return `{String}{string.rep("0", (Length - #String))}`
end
local function PadStringLeft(
	String:string, 
	Length:number
):(string)
	if (type(String) ~= "string") then
		return ""
	end
	if (type(Length) ~= "number") then
		return ""
	end

	return `{string.rep("0", (Length - #String))}{String}`
end
local function StripTrailingZeros(
	String:string
):(string)
	if (type(String) ~= "string") then
		return ""
	end

	return String:match("^(.-)0*$") or "0"
end
local function StripLeadingZeros(
	String:string
):(string)
	if (type(String) ~= "string") then
		return ""
	end

	return String:match("^0*(.-)$") or "0"
end

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
			Function:((...any) -> any), 
			...any
		) -> (boolean, any);

		QuickSafeCall:(
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

		BatchCreateConnections:(
			ConnectionDefinitions:({[string]:{
				Signal:RBXScriptSignal; 
				Callback:((...any) -> (any));
			}})
		) -> (boolean);
	};

	PlayerUtils:{
		GetPlayerByName:(
			PlayerName:string
		) -> (Player | false?);

		GetRandomPlayer:(() -> Player?);

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
		) -> (RaycastResult | false?);
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

	StringMathUtils:{
		CompareStrings:(
			A:string, 
			B:string
		) -> (number);

		AddStrings:(
			A:string, 
			B:string
		) -> (string);

		SubtractStrings:(
			A:string, 
			B:string
		) -> (string);

		MultiplyStrings:(
			A:string, 
			B:string
		) -> (string);

		DivideStrings:(
			A:string, 
			B:string, 
			DecimalPlaces:number?
		) -> (string);

		AbsString:(
			Value:string
		) -> (string);
	};
}

local Connections = {}
local ServicesCache = {}

ClientUtils.IsStudio = RunService:IsStudio()
ClientUtils.IsClient = RunService:IsClient()
ClientUtils.LocalPlayer = LocalPlayer

--// GeneralUtils
do
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

	--// WaitForCondition
	-- Repeatedly checks a condition until it becomes true or a timeout occurs.
	-- @param Condition:(() -> (boolean))
	-- @param TimeOut:number?
	-- @param Interval:number?
	-- @return boolean
	function ClientUtils.GeneralUtils.WaitForCondition(
		Condition:(() -> (boolean)),
		TimeOut:(number?),
		Interval:(number?)
	):(boolean)
		if (type(Condition) ~= "function") then
			return false
		end
		if (type(TimeOut) ~= "number") then
			TimeOut = 5
		elseif (type(TimeOut) == "number") then
			if (TimeOut ~= TimeOut) or (TimeOut == -math.huge) then
				TimeOut = 0.1
			end
		end
		if (type(Interval) ~= "number") then
			TimeOut = 0.1
		elseif (type(Interval) == "number") then
			if (Interval ~= Interval) or (Interval == math.huge) or (Interval == -math.huge) then
				Interval = 0.1
			end
		end

		local StartTime:number = os.clock()
		local CheckInterval:number = Interval or 0.1

		while (not Condition()) do
			if ((os.clock() - StartTime) >= TimeOut) then
				return false
			end
			task.wait(CheckInterval)
		end

		return true
	end

	--// Ternary
	-- Simple ternary function.
	-- @param Condition:any
	-- @param IfTrue:any
	-- @param IfFalse:any
	-- @return any?
	function ClientUtils.GeneralUtils.Ternary(
		Condition:(any), 
		IfTrue:(any), 
		IfFalse:(any)
	):(any?)
		return Condition and IfTrue or IfFalse
	end
end

--// RaycastUtils
do
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
end

--// PredictionUtils
do
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
end

--// PlayerUtils
do
	--// IsOnSameTeam
	-- Checks if PlayerA is on the same team as PlayerB.
	-- @param PlayerA:boolean
	-- @param PlayerB:boolean
	-- @return boolean
	function ClientUtils.PlayerUtils.IsOnSameTeam(
		PlayerA:Player,
		PlayerB:Player
	):(boolean)
		if (typeof(PlayerA) ~= "Instance") or not PlayerA:IsA("Player") then
			return false
		end
		if (typeof(PlayerB) ~= "Instance") or not PlayerB:IsA("Player") then
			return false
		end
		if PlayerA.Neutral and PlayerB.Neutral then
			return true
		end

		return (PlayerA.Team == PlayerB.Team)
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

	--// GetRandomPlayer
	-- Returns a random player from the current player list.
	-- @return Player
	function ClientUtils.PlayerUtils.GetRandomPlayer():(Player?)
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

	--// GetCharacterPart
	-- Returns a preferred part of a player's character, or fallback part.
	-- @param Player:Player
	-- @param Prefer:string?
	-- @return BasePart? | false
	function ClientUtils.PlayerUtils.GetCharacterPart(
		Player:Player, 
		Prefer:string?
	):(BasePart|false?)
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

	--// GetPlayerCharacterPosition
	-- Gets the position of a player's character, with the option of returning a CFrame instead.
	-- @param Player:Player
	-- @param GetCFrame:boolean?
	-- @return Vector3 | CFrame | false?
	function ClientUtils.PlayerUtils.GetPlayerCharacterPosition(
		Player:Player,
		GetCFrame:boolean?
	):(Vector3|CFrame|false?)
		if (typeof(Player) ~= "Instance") or not Player:IsA("Player") then
			return false
		end
		if (type(GetCFrame) ~= "boolean") then
			GetCFrame = false
		end

		local CharacterPart:(BasePart|false?) = ClientUtils.PlayerUtils.GetCharacterPart(
			Player,
			"HumanoidRootPart"
		)
		if not CharacterPart then
			return false
		end

		return ((typeof(CharacterPart) == "Instance") and CharacterPart:IsA("BasePart") and (
			(not GetCFrame and CharacterPart.Position) or (GetCFrame and CharacterPart.CFrame)
			)) or false
	end

	--// GetPlayersWithinDistance
	-- Gets all players within a specified distance, negative number or NaN for the max distance automatically get set to inf.
	-- @param Player:Player
	-- @param MaxDistance:number?
	-- @return {Player?}
	function ClientUtils.PlayerUtils.GetPlayersWithinDistance(
		ReferencePosition:Vector3,
		MaxDistance:number?
	):({Player?})
		local PlayersInRange = {}

		if (typeof(ReferencePosition) ~= "Vector3") then
			return PlayersInRange
		end
		if (typeof(MaxDistance) ~= "number") then 
			MaxDistance = math.huge
		elseif (type(MaxDistance) == "number") then
			if (MaxDistance ~= MaxDistance) or (MaxDistance <= 0) then
				MaxDistance = math.huge
			end
		end

		for _, Player in pairs(Players:GetPlayers()) do
			if not Player or not Player.Character then 
				continue
			end

			local RootPart = ClientUtils.PlayerUtils.GetCharacterPart(
				Player, 
				"HumanoidRootPart"
			)

			if RootPart then
				if (MaxDistance == math.huge) then
					table.insert(PlayersInRange, Player)
				else
					local Distance = (RootPart.Position - ReferencePosition).Magnitude
					if (Distance <= MaxDistance) then
						table.insert(PlayersInRange, Player)
					end
				end
			end
		end

		return PlayersInRange
	end
end

--// MathUtils
do
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


	--// GetFlatDistance
	-- Gets the distance from a position, not using the Y axis.
	-- @param From:Vector3
	-- @param Position:Vector3
	-- @return number
	function ClientUtils.MathUtils.GetFlatDistance(
		From:Vector3, 
		Position:Vector3
	):(number)
		if (typeof(From) ~= "Vector3") then
			return 0
		end
		if (typeof(Position) ~= "Vector3") then
			return 0
		end
		if (From.X == Position.X) and (From.Z == Position.Z) then
			return 0
		end

		local Distance = (
			Vector3.new(From.X, 0, From.Z) - Vector3.new(Position.X, 0, Position.Z)
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
end

--// ConnectionUtils
do
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

	--// BatchCreateConnections
	-- Create multiple connections at once from an array.
	-- @param ConnectionDefinitions:{[string]:{Signal:RBXScriptSignal; Callback:((...any) -> (any));}}
	-- @return RBXScriptConnection | false
	function ClientUtils.ConnectionUtils.BatchCreateConnections(
		ConnectionDefinitions:({[string]:{
			Signal:RBXScriptSignal; 
			Callback:((...any) -> (any));
		}})
	):(boolean)
		local SuccessCount = 0

		for Identifier:string, Definition:{Signal:RBXScriptSignal; Callback:(() -> (any));} in pairs(ConnectionDefinitions) do
			if (type(Identifier) ~= "string") then
				continue
			end
			if (type(Definition) ~= "table") then
				continue
			end
			if (typeof(Definition.Signal) ~= "RBXScriptSignal")
				or (type(Definition.Callback) ~= "function")
			then
				continue
			end

			local Success = ClientUtils.ConnectionUtils.CreateConnection(
				Identifier, 
				Definition.Signal, 
				Definition.Callback
			)
			if Success then
				SuccessCount += 1
			end
		end

		return (SuccessCount > 0)
	end
end

--// StringMathUtils
do
	function ClientUtils.StringMathUtils.CompareStrings(
		A:string, 
		B:string
	):(number)
		if (type(A) ~= "string") then 
			return 0
		end
		if (type(B) ~= "string") then 
			return 0
		end

		local SignA = 1
		if (A:sub(1, 1) == "-") then
			SignA = -1
			A = A:sub(2)
		elseif (A:sub(1, 1) == "+") then
			A = A:sub(2)
		end

		local SignB = 1
		if (B:sub(1, 1) == "-") then
			SignB = -1
			B = B:sub(2)
		elseif (B:sub(1, 1) == "+") then
			B = B:sub(2)
		end

		if (A == "") or not tostring(A):match("^%d*%.?%d*$") then
			A = "0"
		end
		if (B == "") or not tostring(A):match("^%d*%.?%d*$") then
			B = "0"
		end

		if (SignA > SignB) then 
			return 1 
		end
		if (SignA < SignB) then 
			return -1 
		end

		local AInt:string, AFrac:string = A:match("^(%d*)%.?(%d*)$")
		local BInt:string, BFrac:string = B:match("^(%d*)%.?(%d*)$")

		AInt = StripLeadingZeros(AInt)
		BInt = StripLeadingZeros(BInt)

		if (AInt == "") then
			AInt = "0" 
		end
		if (BInt == "") then
			BInt = "0" 
		end

		if (#AInt > #BInt) then
			return SignA
		elseif (#AInt < #BInt) then
			return -SignA
		else
			for i = 1, #AInt do
				local DigitA = tonumber(AInt:sub(i, i)) or 0
				local DigitB = tonumber(BInt:sub(i, i)) or 0
				if (DigitA > DigitB) then
					return SignA
				elseif (DigitA < DigitB) then
					return -SignA
				end
			end

			local MaxFracLen = math.max(#AFrac, #BFrac)
			AFrac ..= string.rep("0", (MaxFracLen - #AFrac))
			BFrac ..= string.rep("0", (MaxFracLen - #BFrac))

			for i = 1, MaxFracLen do
				local DigitA = tonumber(AFrac:sub(i, i)) or 0
				local DigitB = tonumber(BFrac:sub(i, i)) or 0
				if (DigitA > DigitB) then
					return SignA
				elseif (DigitA < DigitB) then
					return -SignA
				end
			end
		end

		return 0
	end

	function ClientUtils.StringMathUtils.AddStrings(
		A:string, 
		B:string
	):(string)
		if (type(A) ~= "string") then
			return "0"
		end
		if (type(B) ~= "string") then
			return "0"
		end
		if (type(tonumber(A)) ~= "number") then
			return "0"
		end
		if (type(tonumber(B)) ~= "number") then
			return "0"
		end
		if (tonumber(A) == 0) then
			return B
		end
		if (tonumber(B) == 0) then
			return A
		end

		local AInt, AFrac = A:match("^(%d*)%.?(%d*)$")
		local BInt, BFrac = B:match("^(%d*)%.?(%d*)$")

		AInt, AFrac = (AInt or "0"), (AFrac or "")
		BInt, BFrac = (BInt or "0"), (BFrac or "")

		local MaxFracLen = math.max(#AFrac, #BFrac)
		AFrac, BFrac = PadStringRight(AFrac, MaxFracLen), PadStringRight(BFrac, MaxFracLen)

		local FracResult, Carry = "", 0
		for i = MaxFracLen, 1, -1 do
			local DigitA = tonumber(AFrac:sub(i, i)) or 0
			local DigitB = tonumber(BFrac:sub(i, i)) or 0
			local Sum = (DigitA + DigitB + Carry)
			Carry = math.floor(Sum / 10)
			FracResult = `{tostring(Sum % 10)}{FracResult}`
		end

		local MaxIntLen = math.max(#AInt, #BInt)
		AInt, BInt = PadStringLeft(AInt, MaxIntLen), PadStringLeft(BInt, MaxIntLen)

		local IntResult = ""
		for i = MaxIntLen, 1, -1 do
			local DigitA = tonumber(AInt:sub(i, i)) or 0
			local DigitB = tonumber(BInt:sub(i, i)) or 0
			local Sum = (DigitA + DigitB + Carry)
			Carry = math.floor(Sum / 10)
			IntResult = `{tostring(Sum % 10)}{IntResult}`
		end

		if (Carry > 0) then
			IntResult = `{tostring(Carry)}{IntResult}`
		end

		FracResult = FracResult:gsub("0+$", "")

		return (FracResult ~= "") and (`{IntResult}.{FracResult}`) or IntResult
	end

	function ClientUtils.StringMathUtils.SubtractStrings(
		A:string, 
		B:string
	):(string)
		if (type(A) ~= "string") then
			return "0"
		end
		if (type(B) ~= "string") then
			return "0"
		end
		if (type(tonumber(A)) ~= "number") then
			return "0"
		end
		if (type(tonumber(B)) ~= "number") then
			return "0"
		end
		if (tonumber(B) == 0) then
			return A
		end
		if (tonumber(A) == 0) then
			if (tonumber(B) > 0) then
				return `-{B}`
			else
				return B
			end
		end

		if (ClientUtils.StringMathUtils.CompareStrings(A, B) < 0) then
			local PositiveResult = ClientUtils.StringMathUtils.SubtractStrings(B, A)
			return `-{PositiveResult}`
		end

		local AInt, AFrac = A:match("^(%d*)%.?(%d*)$")
		local BInt, BFrac = B:match("^(%d*)%.?(%d*)$")

		AInt, AFrac = (AInt or "0"), (AFrac or "")
		BInt, BFrac = (BInt or "0"), (BFrac or "")

		local MaxFracLen = math.max(#AFrac, #BFrac)
		AFrac, BFrac = PadStringRight(AFrac, MaxFracLen), PadStringRight(BFrac, MaxFracLen)

		local ResultFrac, Borrow = "", 0
		for i = MaxFracLen, 1, -1 do
			local DigitA = tonumber(AFrac:sub(i, i)) or 0
			local DigitB = tonumber(BFrac:sub(i, i)) or 0
			local Diff = (DigitA - DigitB - Borrow)

			if (Diff < 0) then
				Diff = (Diff + 10)
				Borrow = 1
			else
				Borrow = 0
			end

			ResultFrac = `{tostring(Diff)}{ResultFrac}`
		end

		local MaxIntLen = math.max(#AInt, #BInt)
		AInt, BInt = PadStringLeft(AInt, MaxIntLen), PadStringLeft(BInt, MaxIntLen)

		local ResultInt = ""
		for i = MaxIntLen, 1, -1 do
			local DigitA = tonumber(AInt:sub(i, i)) or 0
			local DigitB = tonumber(BInt:sub(i, i)) or 0
			local Diff = (DigitA - DigitB - Borrow)

			if (Diff < 0) then
				Diff = (Diff + 10)
				Borrow = 1
			else
				Borrow = 0
			end

			ResultInt = `{tostring(Diff)}{ResultInt}`
		end

		ResultInt = StripLeadingZeros(ResultInt)
		ResultFrac = StripTrailingZeros(ResultFrac)

		if (ResultInt == "") then
			ResultInt = "0"
		end
		if (ResultFrac ~= "") then
			return (`{ResultInt}.{ResultFrac}`)
		end

		return ResultInt
	end

	function ClientUtils.StringMathUtils.MultiplyStrings(
		A:string, 
		B:string
	):(string)
		if (type(A) ~= "string") then
			return "0"
		end
		if (type(B) ~= "string") then
			return "0"
		end
		if (type(tonumber(A)) ~= "number") then
			return "0"
		end
		if (type(tonumber(B)) ~= "number") then
			return "0"
		end
		if ((tonumber(A) == 0) or (tonumber(B) == 0)) then
			return "0"
		end

		local AInt, AFrac = A:match("^(%d*)%.?(%d*)$")
		local BInt, BFrac = B:match("^(%d*)%.?(%d*)$")

		AInt, AFrac = (AInt or "0"), (AFrac or "")
		BInt, BFrac = (BInt or "0"), (BFrac or "")

		local DecimalPlaces = (#AFrac + #BFrac)

		local AWhole, BWhole = (`{AInt}{AFrac}`), (`{BInt}{BFrac}`)

		local ADigits = {}
		for I = #AWhole, 1, -1 do
			table.insert(ADigits, tonumber(AWhole:sub(I, I)))
		end

		local BDigits = {}
		for I = #BWhole, 1, -1 do
			table.insert(BDigits, tonumber(BWhole:sub(I, I)))
		end

		local Result = table.create((#ADigits + #BDigits), 0)

		for I = 1, #ADigits do
			for J = 1, #BDigits do
				Result[(I + J - 1)] += (ADigits[I] * BDigits[J])
			end
		end

		for I = 1, #Result do
			if (Result[I] >= 10) then
				local Carry = (Result[I] // 10)
				Result[I] %= 10
				Result[(I + 1)] += Carry
			end
		end

		while (#Result > 1 and Result[#Result] == 0) do
			table.remove(Result, #Result)
		end

		local Str:string = ""
		for I = #Result, 1, -1 do
			Str ..= tostring(Result[I])
		end

		if (DecimalPlaces > 0) then
			if (#Str <= DecimalPlaces) then
				Str = `{string.rep("0", (DecimalPlaces - #Str + 1))}{Str}`
			end
			local IntPart = Str:sub(1, (#Str - DecimalPlaces))
			local FracPart = Str:sub(#Str - DecimalPlaces + 1)

			FracPart = (FracPart:match("^(.-)0*$") or "")
			if (FracPart ~= "") then
				Str = (`{IntPart}.{FracPart}`)
			else
				Str = IntPart
			end
		end

		Str = Str:match("^0*(.-)$")
		if (Str == "") then
			Str = "0"
		end

		return Str
	end

	function ClientUtils.StringMathUtils.DivideStrings(
		A:string, 
		B:string, 
		DecimalPlaces:number?
	):(string)
		if (type(A) ~= "string") then
			return "0"
		end
		if (type(B) ~= "string") then
			return "0"
		end
		if (type(tonumber(A)) ~= "number") then
			return "0"
		end
		if (type(tonumber(B)) ~= "number") then
			return "0"
		end
		if (tonumber(B) == 0) then
			return "0"
		end
		if (tonumber(A) == 0) then
			return "0"
		end

		DecimalPlaces = (
			(type(DecimalPlaces) == "number") 
			and (DecimalPlaces == DecimalPlaces) 
			and (math.abs(DecimalPlaces) ~= math.huge) 
			and DecimalPlaces
		) or 10

		local Sign = ""
		if (A:sub(1, 1) == "-") ~= (B:sub(1, 1) == "-") then
			Sign = "-"
		end
		A = A:gsub("^[+-]", "")
		B = B:gsub("^[+-]", "")

		local AInt, AFrac = A:match("^(%d*)%.?(%d*)$")
		local BInt, BFrac = B:match("^(%d*)%.?(%d*)$")
		AInt, AFrac = (AInt or "0"), (AFrac or "")
		BInt, BFrac = (BInt or "0"), (BFrac or "")

		local Shift = math.max(#AFrac, #BFrac)
		A = `{AInt}{AFrac}{string.rep("0", (Shift - #AFrac))}`
		B = `{BInt}{BFrac}{string.rep("0", (Shift - #BFrac))}`

		A, B = StripLeadingZeros(A), StripLeadingZeros(B)
		if (A == "") then 
			A = "0" 
		end
		if (B == "") then 
			B = "0" 
		end

		local Result, Remainder = "", ""
		local Count = 0
		local Decimals = 0
		local StartedDecimal = false

		while true do
			if (#A > 0) then
				Remainder ..= A:sub(1,1)
				A = A:sub(2)
			else
				if not StartedDecimal then
					Result ..= "."
					StartedDecimal = true
				end

				if (Remainder == "0") then
					break
				end
				
				Remainder ..= "0"
				Decimals += 1

				if (Decimals > DecimalPlaces) then
					break
				end
			end

			Remainder = StripLeadingZeros(Remainder)
			if (Remainder == "") then 
				Remainder = "0"
			end

			local Digit = 0
			if (ClientUtils.StringMathUtils.CompareStrings(Remainder, B) >= 0) then
				while (ClientUtils.StringMathUtils.CompareStrings(Remainder, B) >= 0) do
					Remainder = ClientUtils.StringMathUtils.SubtractStrings(Remainder, B)
					Digit += 1
				end
			end
			Result ..= tostring(Digit)

			if (#A == 0) and (Remainder == "0") and (not StartedDecimal or (Decimals >= DecimalPlaces)) then
				break
			end
		end

		Result = StripLeadingZeros(Result)
		Result = StripTrailingZeros(Result)
		if Result:sub(1,1) == "." then
			Result = `{"0"}{Result}`
		end
		if (Result == "") then
			Result = "0"
		end

		Result = Result:gsub("%.$", "")

		if (Result == "") then
			Result = "0"
		end

		return `{Sign}{Result}`
	end

	function ClientUtils.StringMathUtils.AbsString(
		Value:string
	):(string)
		if (type(A) ~= "string") then
			return "0"
		end
		if (type(tonumber(A)) ~= "number") then
			return "0"
		end

		if (A:sub(1, 1) == "-") then
			return A:sub(2)
		end
		return A
	end
end

return ClientUtils
