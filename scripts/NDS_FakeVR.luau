--// @_x4yz
--// https://www.roblox.com/games/189707/Natural-Disaster-Survival
--// experimental

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

StarterGui:SetCore("AvatarContextMenuEnabled", false)

local function NewAngles(
	...
):(CFrame)
	local X, Y, Z = ...
	if (type(X) ~= "number") or (X ~= X) then
		return CFrame.identity
	end
	if (type(Y) ~= "number") or (Y ~= Y) then
		return CFrame.identity
	end
	if (type(Z) ~= "number") or (Z ~= Z) then
		return CFrame.identity
	end

	return CFrame.Angles(math.rad(X), math.rad(Y), math.rad(Z))
end

local function MakeProxyPart(
    Name:string?, 
    Size:Vector3?, 
    Color:Color3?, 
    Parent:Instance?
):(BasePart?)
    if (type(Name) ~= "string") then
        Name = "Part"
    end
    if (typeof(Size) ~= "Vector3") then
        Size = Vector3.new(4, 1.2, 2)
    end
    if (typeof(Color) ~= "Color3") then
        Color = Color3.fromRGB(163, 162, 165)
    end

    local Part = Instance.new("Part")
    Part.Name = Name
    Part.Size = Size
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanTouch = false
    Part.CanQuery = false
    Part.Material = Enum.Material.SmoothPlastic
    Part.Transparency = 0.4
    Part.Color = Color
    
    if (typeof(Parent) == "Instance") then
        Part.Parent = Parent
    end

    return Part
end

local LocalPlayer = Players.LocalPlayer

local NexusVRCharacterModel = ReplicatedStorage:WaitForChild("NexusVRCharacterModel")
local ReplicationReady:RemoteEvent = NexusVRCharacterModel:WaitForChild("ReplicationReady")
local UpdateInputs:RemoteEvent = NexusVRCharacterModel:WaitForChild("UpdateInputs")

local DelayPerFire:number = 0.03 --// How long it takes before each input update
local SmoothFactor:number = 0.35 --// Used for CFrame lerping

local CurrentRArm:CFrame
local CurrentLArm:CFrame

local PlayingEmote = nil --// Emote data
local EmoteStartTime:number = 0 --// Time(os.clock) when emote was started
local Emotes = {
    ["Wave"] = {
        {0.0;  CFrame.new(-0.5, -1.2, -1.8);  nil};
        {0.2;  (CFrame.new(-0.5, -0.6, -1.6) * NewAngles(0, 0, 60));  nil};
        {0.4;  CFrame.new(-0.5, -1.2, -1.8);  nil};
        {0.6;  (CFrame.new(-0.5, -0.6, -1.6) * NewAngles(0, 0, 60));  nil};
        {0.8;  CFrame.new(-0.5, -1.2, -1.8);  nil};
        {1;  (CFrame.new(-0.5, -0.6, -1.6) * NewAngles(0, 0, 60));  nil};
		{1.2;  CFrame.new(-0.5, -1.2, -1.8);  nil};
    };

	["Point"] = {
		{0.0;  CFrame.new(-0.8, -1.5, -2.1);  nil};
		{0.2;  CFrame.new(-0.5, -1.2, -1.8);  nil};
		{0.4;  (CFrame.new(-0.3, -0.6, -2.2) * NewAngles(-15, 0, 0));  nil};
		{0.7;  (CFrame.new(-0.3, -0.6, -2.2) * NewAngles(-15, 0, 0));  nil};
		{1.1;  CFrame.new(-0.5, -1.2, -1.8);  nil};
	};

	["Cheer"] = {
		{0.0;  nil;  nil};
		{0.3;  (CFrame.new(-1.2, 1, -1.5) * NewAngles(60, 0, 0));  (CFrame.new(1.2, 1, -1.5) * NewAngles(60, 0, 0))};
		{0.45;  (CFrame.new(-1.2, 1.2, -1.5) * NewAngles(60, 0, 0));  (CFrame.new(1.2, 1.2, -1.5) * NewAngles(60, 0, 0))};
		{0.7;  (CFrame.new(-1.2, 1.4, -1.2) * NewAngles(60, 0, 0));  (CFrame.new(1.2, 1.4, -1.2) * NewAngles(60, 0, 0))};
		{1.1;  (CFrame.new(-1.2, 1.4, -1.2) * NewAngles(60, 0, 0));  (CFrame.new(1.2, 1.4, -1.2) * NewAngles(60, 0, 0))};
		{1.45;  nil;  nil};
	};
}
local EmoteKeys = {
	[Enum.KeyCode.E] = "Wave";
	[Enum.KeyCode.F] = "Point";
	[Enum.KeyCode.C] = "Cheer";
}

if shared.InputCoroutine then
	pcall(coroutine.close, shared.InputCoroutine)
	shared.InputCoroutine = nil
end
if shared.InputHandler then
	shared.InputHandler:Disconnect()
	shared.InputHandler = nil
end
shared.GhostMode = false

shared.InputHandler = UserInputService.InputBegan:Connect(function(Input, P)
	if P then 
		return 
	end

	if (Input.KeyCode == Enum.KeyCode.Z) then
		if shared.GhostMode then
			shared.GhostMode = false
		else 
			shared.GhostMode = true
		end
		print(`Ghost Mode is now {shared.GhostMode and "enabled." or "disabled."}`)
		return
	end

	if (type(PlayingEmote) == "table") then
		return
	end
	local EmoteNameFromInput = EmoteKeys[Input.KeyCode]
	if (type(EmoteNameFromInput) == "string") then
		PlayingEmote = Emotes[EmoteNameFromInput]
		EmoteStartTime = os.clock()
	end
end)

local function GetInputs(
	Type:string?, 
	CustomCFrame:CFrame?
):(CFrame, CFrame, CFrame)
	if (type(Type) ~= "string") then
		Type = "Server"
	end

    if shared.GhostMode and (Type == "Server") then
        return CFrame.new(0, -9e9, 0), CFrame.new(0, -9e9, 0), CFrame.new(0, -9e9, 0)
    end

	local Camera = Workspace.CurrentCamera
	if (typeof(CustomCFrame) == "CFrame") then
		Camera = {CFrame = CustomCFrame}
	end
	if not Camera then
		return CFrame.identity, CFrame.identity, CFrame.identity
	end

    local Character = LocalPlayer.Character
    local Head:BasePart = Character and Character:FindFirstChild("Head")
    if not Head then
        return CFrame.identity, CFrame.identity, CFrame.identity
    end
    
	local CurrentCameraCFrame:CFrame = Camera.CFrame
	local CurrentLookVector:Vector3 = CurrentCameraCFrame.LookVector

	local ForwardXZ:Vector3 = Vector3.new(CurrentLookVector.X, 0, CurrentLookVector.Z)
	if (ForwardXZ.Magnitude <= 0.001) then
		ForwardXZ = Vector3.zAxis
	end
	local YawOnly:CFrame = CFrame.lookAt(Vector3.zero, ForwardXZ.Unit)

	local RightPressed:boolean = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	local LeftPressed:boolean = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	local CtrlPressed:boolean = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)

	local HeadInputOffset:CFrame = CFrame.new(0, 0.3, 0)
	if CtrlPressed then
		HeadInputOffset = CFrame.new(0, -1, 0)
	end
    
    local HeadPos:Vector3 = (Head.CFrame * HeadInputOffset).Position
    local HeadInput:CFrame = (CFrame.new(HeadPos) * CurrentCameraCFrame.Rotation)

	local TargetR:CFrame = not RightPressed and (
		((CFrame.new(HeadPos) * YawOnly) * CFrame.new(-1.75, -3, 0)) * NewAngles(-65, 0, 0)
	) or (HeadInput * CFrame.new(-0.75, -1.5, 0))
	local TargetL:CFrame = not LeftPressed and (
		((CFrame.new(HeadPos) * YawOnly) * CFrame.new(1.75, -3, 0)) * NewAngles(-65, 0, 0)
	) or (HeadInput * CFrame.new(0.75, -1.5, 0))

	if RightPressed then
		TargetR *= (CFrame.new(-0.5, 1, -2) * NewAngles(-15, 0, 0))
	end
	if LeftPressed then
		TargetL *= (CFrame.new(0.5, 1, -2) * NewAngles(-15, 0, 0))
	end
	if RightPressed and LeftPressed then
		TargetR *= NewAngles(0, 15, 0)
		TargetL *= NewAngles(0, -15, 0)
	end

	if PlayingEmote then
		local Elapsed = (os.clock() - EmoteStartTime)
		local Sequence = PlayingEmote
		local LastFrame, NextFrame

		if (#Sequence <= 0) then
			PlayingEmote = nil
			return CFrame.identity, CFrame.identity, CFrame.identity
		end

		for i = 1, (#Sequence - 1) do
			if (Elapsed >= Sequence[i][1]) and (Elapsed < Sequence[i + 1][1]) then
				LastFrame = Sequence[i]
				NextFrame = Sequence[i + 1]
				break
			end
		end

		if LastFrame and NextFrame then
			local Alpha = ((Elapsed - LastFrame[1])) / ((NextFrame[1] - LastFrame[1]))

			if LastFrame[2] or NextFrame[2] then
				local RLast = LastFrame[2] or (CurrentCameraCFrame:Inverse() * TargetR)
				local RNext = NextFrame[2] or (CurrentCameraCFrame:Inverse() * TargetR)
				TargetR = (CurrentCameraCFrame * RLast:Lerp(RNext, Alpha))
			end
			if LastFrame[3] or NextFrame[3] then
				local LLast = LastFrame[3] or (CurrentCameraCFrame:Inverse() * TargetL)
				local LNext = NextFrame[3] or (CurrentCameraCFrame:Inverse() * TargetL)
				TargetL = (CurrentCameraCFrame * LLast:Lerp(LNext, Alpha))
			end
		end

		if (Elapsed > Sequence[#Sequence][1]) then
			PlayingEmote = nil
		end
	end

	if not CurrentRArm then
		CurrentRArm = TargetR
	end
	if not CurrentLArm then
		CurrentLArm = TargetL
	end

	CurrentRArm = CurrentRArm:Lerp(TargetR, SmoothFactor)
	CurrentLArm = CurrentLArm:Lerp(TargetL, SmoothFactor)

	return HeadInput, CurrentRArm, CurrentLArm
end

ReplicationReady:FireServer()
shared.InputCoroutine = coroutine.create(function()
	while task.wait(DelayPerFire) do 
		local InputOne, InputTwo, InputThree = GetInputs("Server")
		UpdateInputs:FireServer(InputOne, InputTwo, InputThree)
	end
end)
coroutine.resume(shared.InputCoroutine)

--//
--// Client visualization.
--//
do
	if shared.VRVisualCoroutine then
		pcall(coroutine.close, shared.VRVisualCoroutine)
		shared.VRVisualCoroutine = nil
	end
	if shared.OldProxyModel then
		shared.OldProxyModel:Destroy()
		shared.OldProxyModel = nil
	end

    local ProxyModel = Instance.new("Model")
	shared.OldProxyModel = ProxyModel
    ProxyModel.Name = "VR_VisualProxy"
    ProxyModel.Parent = Workspace

	local HeadProxy = MakeProxyPart("HeadProxy", 
		Vector3.new(1, 1, 1), Color3.fromRGB(200, 200, 255), ProxyModel
	)
	local RightHandProxy = MakeProxyPart("RightHandProxy", 
		Vector3.new(0.5, 0.5, 0.5), Color3.fromRGB(255, 150, 150), ProxyModel
	)
	local LeftHandProxy = MakeProxyPart("LeftHandProxy", 
		Vector3.new(0.5, 0.5, 0.5), Color3.fromRGB(150, 150, 255), ProxyModel
	)

	local CurH, CurR, CurL = nil, nil, nil
	shared.VRVisualCoroutine = coroutine.create(function()
		while true do
			local Success, HeadCF, RightCF, LeftCF = pcall(GetInputs, "")
			if Success and HeadCF and RightCF and LeftCF then
				if not CurH then
					CurH = HeadCF 
				end
				if not CurR then 
					CurR = RightCF 
				end
				if not CurL then 
					CurL = LeftCF
				end

				CurH = CurH:Lerp(HeadCF, SmoothFactor)
				CurR = CurR:Lerp(RightCF, SmoothFactor)
				CurL = CurL:Lerp(LeftCF, SmoothFactor)

				HeadProxy.CFrame = CurH
				RightHandProxy.CFrame = CurR
				LeftHandProxy.CFrame  = CurL

				if shared.GhostMode then
					HeadProxy.Color = Color3.new(0, 1, 0)
					RightHandProxy.Color = Color3.new(0, 1, 0)
					LeftHandProxy.Color = Color3.new(0, 1, 0)
				else
					HeadProxy.Color = Color3.fromRGB(200, 200, 255)
					RightHandProxy.Color = Color3.fromRGB(255, 150, 150)
					LeftHandProxy.Color = Color3.fromRGB(150, 150, 255)
				end
			end

			task.wait()
		end
	end)
	coroutine.resume(shared.VRVisualCoroutine)
end
