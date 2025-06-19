local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	repeat
		LocalPlayer = Players.LocalPlayer
		task.wait()
	until LocalPlayer
end

local Mouse = LocalPlayer:GetMouse()

local ClientUtils = {}

function ClientUtils:WaitForChildWhichIsA(
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

function ClientUtils:GetMouseHitPosition(
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
	
	local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")
	if not Camera then
		return Vector3.zero
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

function ClientUtils:GetClosestPlayerToCharacter(
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
	
	IgnoreDead = ((type(IgnoreDead) == "boolean") and IgnoreDead) or true
	
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

function ClientUtils:GetClosestPlayerToMouseOnScreen(
	MaxScreenDistance:number?, 
	IgnoreDead:boolean?, 
	RequireOnScreen:boolean?
):(Player, BasePart, number)
	local Camera = Workspace.CurrentCamera
	if not Camera then
		return nil
	end

	local MousePosition:Vector2 = UserInputService:GetMouseLocation()
	local ClosestPlayer = nil
	local ClosestDistance = math.huge
	local ClosestPart = nil

	MaxScreenDistance = ((type(MaxScreenDistance) == "number" and MaxScreenDistance > 0) and MaxScreenDistance) 
		or math.huge
	IgnoreDead = ((type(IgnoreDead) == "boolean") and IgnoreDead) 
		or true
	RequireOnScreen = ((type(RequireOnScreen) == "boolean") and RequireOnScreen) 
		or false

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

function ClientUtils:GetPredictedPosition(BasePart:BasePart)
	if (typeof(BasePart) ~= "Instance") or not BasePart:IsA("BasePart") then
		return Vector3.zero
	end

	if BasePart.Anchored then
		return BasePart.Position
	end

	local Ping = LocalPlayer:GetNetworkPing()
	local Displacement = (BasePart.AssemblyLinearVelocity * (Ping * 1.85))

	local PredictedPosition = (BasePart.Position + Displacement)
	return PredictedPosition
end

function ClientUtils:GetPredictedPositionWithPositionAndVelocity(Position:Vector3, Velocity:Vector3)
	if (typeof(Position) ~= "Vector3") then
		return Vector3.zero
	end
	if (typeof(Velocity) ~= "Vector3") then
		return Vector3.zero
	end

	local Ping = LocalPlayer:GetNetworkPing()
	local Displacement = (Velocity * (Ping * 1.85))

	local PredictedPosition = (Position + Displacement)
	return PredictedPosition
end

return ClientUtils
