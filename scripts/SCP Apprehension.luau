--// @_x4yz
--// https://www.roblox.com/games/3264184746/SCP-Apprehension

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Holder = Workspace:WaitForChild("Holder")
local Baseplate = Workspace:WaitForChild("Baseplate")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteFunction = Remotes:WaitForChild("RemoteFunction")
local PlayerRemote = Remotes:WaitForChild(`Player{LocalPlayer.UserId}`)

_G["__TimesRan"] = (type(_G["__TimesRan"]) ~= "number") and 1 or (_G["__TimesRan"] + 1)
local OldTimesRan = _G["__TimesRan"]

if _G["__BringItem"] then
	_G["__BringItem"]:Disconnect()
	_G["__BringItem"] = nil
end
if _G["__DropItemsAtBaseplate"] then
	_G["__DropItemsAtBaseplate"]:Disconnect()
	_G["__DropItemsAtBaseplate"] = nil
end

local NewRandom = Random.new()
local EspColors = {
    ["Beretta"] = Color3.fromRGB(102, 50, 168); -- purple
    ["M249"] = Color3.fromRGB(36, 178, 191); -- cyan
    ["MP5"] = Color3.fromRGB(50, 168, 85); -- green
    ["P90"] = Color3.fromRGB(219, 206, 20); -- yellow
    ["Medkit"] = Color3.fromRGB(219, 33, 20); -- red
	["Gate"] = Color3.fromRGB(219, 98, 22); -- orange
	["Elevator"] = Color3.fromRGB(44, 117, 255) -- electric blue
}
local KeyCodeItems = {
	[Enum.KeyCode.Z] = "P90";
	[Enum.KeyCode.X] = "Medkit";
	[Enum.KeyCode.V] = "05 Keycard";
	[Enum.KeyCode.B] = "M249";
	[Enum.KeyCode.N] = "MP5";
	[Enum.KeyCode.M] = "Facility Manager Keycard";
}
local Adornments = {}

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

	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.CanCollide = false
	Part.Size = Vector3.new(0.1, 0.1, 0.1)
	Part.CFrame = CenterCFrame
	Part.Transparency = 1
	Part.Name = "__GateEspCenter"
	Part.Parent = Model

	local Adornment = Instance.new("BoxHandleAdornment")
	local NewGUID = HttpService:GenerateGUID()
	Adornments[NewGUID] = Adornment

	local Connection
	Connection = Model.Destroying:Connect(function()
		Adornment.Adornee = nil
		Adornment:Destroy()
		Adornments[NewGUID] = nil
		if Connection then
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
			local Primary = Model.PrimaryPart or Model:FindFirstChild("Handle")
			if Primary then
				return Model, Primary
			end
		else
			continue
		end
	end

	for _, Model in pairs(Workspace:GetChildren()) do
		if Model:IsA("Model") and (Model.Name == Name) and Model:FindFirstChild("Pickup") then
			local Primary = Model.PrimaryPart or Model:FindFirstChild("Handle")
			if Primary then
				return Model, Primary
			end
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

task.spawn(function()
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
end)

_G["__BringItem"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		local Item:Model?, Primary:BasePart?

		local ItemName = KeyCodeItems[Key.KeyCode]
		if (type(ItemName) ~= "string") then
			return
		end

		Item, Primary = GetItem(ItemName)
		if Item and Item:FindFirstChild("Pickup") and Primary and Character_Primary then
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
