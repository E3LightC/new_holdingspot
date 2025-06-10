--//// Discord: @_x4yz \\\\--
--// https://www.roblox.com/games/3264184746/SCP-Apprehension

--//// Key Bindings Overview \\\\--
--// [Item Pickup]
--//        [Z] — Pickup "P90"
--//        [X] — Pickup "MP5"
--//        [V] — Pickup "M249"
--//        [L] — Pickup "Beretta"
--//        [B] — Pickup "Medkit"
--//        [N] — Pickup "05 Keycard"
--//        [M] — Pickup "Facility Manager Keycard"
--// [Item Utility]
--//        [Numpad 1] — Drop all items at baseplate
--//        [Numpad 2] — Pickup item at mouse
--//        [Numpad 3] — Bring all items to player
--//        [Numpad 4] — Pickup all items and consume each one
--//        [Numpad 5] — Pickup item at mouse and consume it
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

--[///////////////////////////////////////////////////////////////////////////////////////////////////]--
--[/////////////////////////////////////////// CODE BELOW ////////////////////////////////////////////]--
--[///////////////////////////////////////////////////////////////////////////////////////////////////]--

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local Mouse = LocalPlayer:GetMouse()

local Holder = Workspace:WaitForChild("Holder")
local Baseplate = Workspace:WaitForChild("Baseplate")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteFunction = Remotes:WaitForChild("RemoteFunction")
local PlayerRemote = Remotes:WaitForChild(`Player{LocalPlayer.UserId}`)

_G["__TimesRan"] = (type(_G["__TimesRan"]) ~= "number") and 1 or (_G["__TimesRan"] + 1)
local OldTimesRan = _G["__TimesRan"]

if _G["__PickupItem"] then
	_G["__PickupItem"]:Disconnect()
	_G["__PickupItem"] = nil
end
if _G["__DropItemsAtBaseplate"] then
	_G["__DropItemsAtBaseplate"]:Disconnect()
	_G["__DropItemsAtBaseplate"] = nil
end
if _G["__PickupItemAtMouse"] then
	_G["__PickupItemAtMouse"]:Disconnect()
	_G["__PickupItemAtMouse"] = nil
end
if _G["__BringAllItems"] then
	_G["__BringAllItems"]:Disconnect()
	_G["__BringAllItems"] = nil
end
if _G["__ConsumeAllItems"] then
	_G["__ConsumeAllItems"]:Disconnect()
	_G["__ConsumeAllItems"] = nil
end
if _G["__ConsumeItemAtMouse"] then
	_G["__ConsumeItemAtMouse"]:Disconnect()
	_G["__ConsumeItemAtMouse"] = nil
end

local NewRandom = Random.new()
local EspColors = {
    ["Beretta"] = Color3.fromRGB(102, 50, 168); --// purple
    ["M249"] = Color3.fromRGB(36, 178, 191); --// cyan
    ["MP5"] = Color3.fromRGB(50, 168, 85); --// green
    ["P90"] = Color3.fromRGB(219, 206, 20); --// yellow
    ["Medkit"] = Color3.fromRGB(219, 33, 20); --// red
	["Gate"] = Color3.fromRGB(219, 98, 22); --// orange
	["Elevator"] = Color3.fromRGB(44, 117, 255) --// electric blue
}
local KeyCodeItems = {
	[Enum.KeyCode.Z] = "P90";
	[Enum.KeyCode.X] = "MP5";
	[Enum.KeyCode.V] = "M249";

	[Enum.KeyCode.B] = "Medkit";

	[Enum.KeyCode.N] = "05 Keycard";
	[Enum.KeyCode.M] = "Facility Manager Keycard";
	[Enum.KeyCode.KeypadSeven] = "Beretta";
}
local Adornments = {}

local function GetSlots():{(string|nil?)}
	local LocalPlayer_Inventory = Backpack:FindFirstChild("Inventory")
	if not LocalPlayer_Inventory then
		return {}
	end

	local Slots = {}
	for _, Slot in pairs(LocalPlayer_Inventory:GetChildren()) do 
		if Slot and Slot:IsA("StringValue") then
			table.insert(Slots, {Slot.Name, Slot.Value})
		end
	end

	return Slots
end

local function AddEspBoxForItem(Model:Model)
    if not Model then 
		return 
	end

    local PrimaryPart = Model.PrimaryPart
    local ModelName = Model.Name

    if ModelName == "MP5" then
        PrimaryPart = Model:FindFirstChild("Handle")
        Model.PrimaryPart = PrimaryPart
    end
    if not PrimaryPart then 
		return 
	end

    local EspColor = EspColors[ModelName]
    if typeof(EspColor) ~= "Color3" then
		return 
	end
    if Model:FindFirstChild("__EspBox") then
		return 
	end

    local Adornment = Instance.new("BoxHandleAdornment")
    local NewGUID = HttpService:GenerateGUID()
    Adornments[NewGUID] = Adornment

    local Connection
    Connection = Model.Destroying:Connect(function()
        Adornment.Adornee = nil
        Adornment:Destroy()
        Adornments[NewGUID] = nil
        Connection:Disconnect()
    end)

    Adornment.Name = "__EspBox"
    Adornment.Adornee = PrimaryPart
    Adornment.Size = Model:GetExtentsSize() + Vector3.new(1.25, 1.25, 1.25)
    Adornment.AlwaysOnTop = true
    Adornment.ZIndex = 10
    Adornment.Transparency = 0.5
    Adornment.Color3 = EspColor
    Adornment.Parent = Model

    if not PrimaryPart:FindFirstChild("__EspLabel") then
        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "__EspLabel"
        Billboard.Adornee = PrimaryPart
        Billboard.Size = UDim2.new(0, 50, 0, 20)
        Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        Billboard.AlwaysOnTop = true
        Billboard.Parent = PrimaryPart

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 1, 0)
		Label.BackgroundTransparency = 1
		Label.Text = ModelName
		Label.TextColor3 = EspColor
		Label.TextScaled = true
		Label.TextStrokeTransparency = 0.5
		Label.TextSize = 14
		Label.Font = Enum.Font.SourceSansBold
		Label.Parent = Billboard
    end
end

local function AddEspBoxForModel(Model:Model, EspColorName:string)
	if not Model then 
		return 
	end
	if Model:FindFirstChild("__EspBox") then 
		return 
	end
	if (type(EspColorName) ~= "string") then
		return
	end
	local EspColor = EspColors[EspColorName]
	if (typeof(EspColor) ~= "Color3") then
		return
	end

	local Size = Model:GetExtentsSize()
	local CenterCFrame = Model:GetModelCFrame()

	local Part = Model:FindFirstChild("__EspCenter") or Instance.new("Part")
	Part.Anchored = true
	Part.CanCollide = false
	Part.Size = Vector3.new(0.1, 0.1, 0.1)
	Part.CFrame = CenterCFrame
	Part.Transparency = 1
	Part.Name = "__EspCenter"
	Part.Parent = Model

	local Adornment = Instance.new("BoxHandleAdornment")
	local NewGUID = HttpService:GenerateGUID()
	Adornments[NewGUID] = Adornment

	local Connection
	local Connection2
	
	Connection = Model.Destroying:Connect(function()
		Adornment.Adornee = nil
		Adornment:Destroy()
		Adornments[NewGUID] = nil
		if Connection then
			Connection:Disconnect()
		end
	end)
	Connection2 = Adornment.Destroying:Connect(function()
		Adornments[NewGUID] = nil
		if Connection then
			Connection:Disconnect()
		end
		if Connection2 then
			Connection:Disconnect()
		end
	end)

	Adornment.Name = "__EspBox"
	Adornment.Adornee = Part
	Adornment.Size = (Size + Vector3.new(2.5, 2.5, 2.5))
	Adornment.AlwaysOnTop = true
	Adornment.ZIndex = 8
	Adornment.Transparency = 0.5
	Adornment.Color3 = EspColor
	Adornment.Parent = Model

    if not Part:FindFirstChild("__EspLabel") then
		local Billboard = Instance.new("BillboardGui")
		Billboard.Name = "__EspLabel"
		Billboard.Adornee = Part
		Billboard.Size = UDim2.new(0, 80, 0, 20)
		Billboard.StudsOffset = Vector3.new(0, Size.Y / 2 + 2, 0)
		Billboard.AlwaysOnTop = true
		Billboard.Parent = Part

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 1, 0)
		Label.BackgroundTransparency = 1
		Label.Text = Model.Name
		Label.TextColor3 = EspColor
		Label.TextScaled = true
		Label.TextStrokeTransparency = 0.5
		Label.TextSize = 12
		Label.Font = Enum.Font.SourceSansBold
		Label.Parent = Billboard
    end
end

local function UpdateEsps()
	for _, Model:Model in pairs(Workspace:GetDescendants()) do
		if Model and Model:IsA("Model") and Model:FindFirstChild("Pickup") then
			if EspColors[Model.Name] and (OldTimesRan == _G["__TimesRan"]) then
				task.delay(NewRandom:NextNumber(0.1, 0.2), AddEspBoxForItem, Model)
				task.wait()
			end
		else
			continue
		end
	end

	for _, Model:Model in pairs(Holder:GetDescendants()) do
		if Model and Model:FindFirstChild("Event") and (
			Model.Name == "Elevator" or 
			Model.Name == "Elevator2" or 
			Model.Name == "GateA_Elevator" or 
			Model.Name == "GateB_Elevator"
		) then
			task.delay(NewRandom:NextNumber(0.1, 0.2), AddEspBoxForModel, Model, "Elevator")
			task.wait()
		elseif Model and (Model.Name == "Gate A") or (Model.Name == "Gate B") then
			task.delay(NewRandom:NextNumber(0.1, 0.2), AddEspBoxForModel, Model, "Gate")
			task.wait()
		end
	end
end

local function GetItem(Name:string):Model?
	for _, Model in pairs(Workspace:GetDescendants()) do
		if Model:IsA("Model") and (Model.Name == Name) and Model:FindFirstChild("Pickup") and not (Model.Parent == Workspace) then
			return Model
		else
			continue
		end
	end

	for _, Model in pairs(Workspace:GetChildren()) do
		if Model:IsA("Model") and (Model.Name == Name) and Model:FindFirstChild("Pickup") then
			return Model
		else
			continue
		end
	end
end

local function DeleteOldEsps()
    for UsedGUID, Adornment in pairs(Adornments) do
        if Adornment and Adornment.Parent and (type(UsedGUID) == "string") then
            Adornment:Destroy()
            Adornments[UsedGUID] = nil
        end
    end
end

coroutine.wrap(function()
    while true do 
        if (OldTimesRan == _G["__TimesRan"]) then
            UpdateEsps()
            task.wait(0.125)
        else
            task.spawn(DeleteOldEsps)
            break
        end

		task.wait()
    end
end)()

_G["__PickupItem"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		if not Character_Primary then
			return
		end
		local Item:Model?

		local ItemName = KeyCodeItems[Key.KeyCode]
		if (type(ItemName) ~= "string") then
			return
		end

		Item = GetItem(ItemName)
		if Item and Item:FindFirstChild("Pickup") then
			RemoteFunction:InvokeServer("VerifyPickup", {Position = Character_Primary.Position; Parent = Item})
		end
	end
end)

_G["__DropItemsAtBaseplate"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if (Key.KeyCode == Enum.KeyCode.KeypadOne) and not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		if not Character_Primary then
			return
		end

		local Old = Character_Primary.CFrame
		local CFrameToSet = (Baseplate.CFrame * CFrame.new(0, 25, 0))
		Character_Primary.CFrame = CFrameToSet

		task.wait(0.15)
		for Num = 1, 8 do 
			Character_Primary.CFrame = CFrameToSet
			PlayerRemote:FireServer("DropItem", Num)
			task.wait()
		end

		task.wait(0.05)
		Character_Primary.CFrame = Old
	end
end)

_G["__PickupItemAtMouse"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if (Key.KeyCode == Enum.KeyCode.KeypadTwo) and not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		if not Character_Primary then
			return
		end

		local Hit:BasePart? = Mouse.Target
		if not Hit then
			return
		end
		local HitParent:Model? = Hit.Parent
		if not HitParent or not HitParent:IsA("Model") or not HitParent:FindFirstChild("Pickup") then
			return
		end

		RemoteFunction:InvokeServer("VerifyPickup", {Position = Character_Primary.Position; Parent = HitParent})
	end
end)

_G["__BringAllItems"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if (Key.KeyCode == Enum.KeyCode.KeypadThree) and not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		if not Character_Primary then
			return
		end

		local Num = 1
		for _, Model in pairs(Workspace:GetDescendants()) do
			if Model:IsA("Model") and Model:FindFirstChild("Pickup") then
				repeat
					PlayerRemote:FireServer("DropItem", Num)
					Num += 1
					task.wait()
				until RemoteFunction:InvokeServer("VerifyPickup", {Position = Character_Primary.Position; Parent = Model})

				Num = 1
				PlayerRemote:FireServer("DropItem", Num)
			else
				continue
			end
		end
	end
end)

_G["__ConsumeAllItems"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if (Key.KeyCode == Enum.KeyCode.KeypadFour) and not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		if not Character_Primary then
			return
		end

		local Num = 1
		for _, Model in pairs(Workspace:GetDescendants()) do
			if Model:IsA("Model") and Model:FindFirstChild("Pickup") then
				repeat
					PlayerRemote:FireServer("DropItem", Num)
					Num += 1
					task.wait()
				until RemoteFunction:InvokeServer("VerifyPickup", {Position = Character_Primary.Position; Parent = Model}) or not Model

				Num = 1
				PlayerRemote:FireServer("UseMedkit", Num)
			else
				continue
			end
		end
	end
end)

_G["__ConsumeItemAtMouse"] = UserInputService.InputBegan:Connect(function(Key, Process) 
	if (Key.KeyCode == Enum.KeyCode.KeypadFive) and not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		if not Character_Primary then return end

		local Hit:BasePart? = Mouse.Target
		if not Hit then return end

		local HitParent:Model? = Hit.Parent
		if not HitParent or not HitParent:IsA("Model") or not HitParent:FindFirstChild("Pickup") then
			return
		end

		local PreviousSlots = GetSlots()
		RemoteFunction:InvokeServer("VerifyPickup", {Position = Character_Primary.Position; Parent = HitParent})
		local CurrentSlots = GetSlots()

		for _, NewSlot in pairs(CurrentSlots) do
			local Found = false
			for _, OldSlot in pairs(PreviousSlots) do
				if (OldSlot[1] == NewSlot[1]) and (OldSlot[2] == NewSlot[2]) then
					Found = true
					break
				end
			end

			if not Found then
				local Number = tonumber(NewSlot[1]:match("%d+"))
				if Number then
					PlayerRemote:FireServer("UseMedkit", Number)
				end
				break
			end
		end
	end
end)
