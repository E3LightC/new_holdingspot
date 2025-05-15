--// @_x4yz
--// https://www.roblox.com/games/3264184746/SCP-Apprehension

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteFunction = Remotes:WaitForChild("RemoteFunction")

_G["__TimesRan"] = (type(_G["__TimesRan"]) ~= "number") and 1 or (_G["__TimesRan"] + 1)
local OldTimesRan = _G["__TimesRan"]

if _G["__PickupP90"] then
	_G["__PickupP90"]:Disconnect()
	_G["__PickupP90"] = nil
end

local NewRandom = Random.new()
local EspColors = {
    ["Beretta"] = Color3.fromRGB(102, 50, 168); -- purple
    ["M249"] = Color3.fromRGB(36, 178, 191); -- cyan
    ["MP5"] = Color3.fromRGB(50, 168, 85); -- green
    ["P90"] = Color3.fromRGB(219, 206, 20); -- yellow
    ["Medkit"] = Color3.fromRGB(219, 33, 20); -- red
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
    Adornment.Transparency = 0.2
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

local function UpdateEsps()
    for _, Model in pairs(Workspace:GetDescendants()) do
        if Model and Model:IsA("Model") and Model:FindFirstChild("Pickup") then
            if EspColors[Model.Name] and (OldTimesRan == _G["__TimesRan"]) then
                task.delay(NewRandom:NextNumber(0.1, 0.15), AddEspBoxForItem, Model)
            end

            continue
        end
    end
end

local function GetItem(Name: string): Model?
	local ClosestModel:Model = nil
	local ClosestDistance = math.huge
	local Primary:BasePart

	for _, Model in pairs(Workspace:GetDescendants()) do
		if Model:IsA("Model") and (Model.Name == Name) and Model:FindFirstChild("Pickup") then
			Primary = Model.PrimaryPart or Model:FindFirstChild("Handle")
			if Primary then
				local Distance = (Primary.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
				if (Distance < ClosestDistance) then
					ClosestDistance = Distance
					ClosestModel = Model
				end
			end
		end
	end

	return ClosestModel, Primary
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
            task.spawn(UpdateEsps)
            task.wait(0.1)
        else
            task.spawn(DeleteOldEsps)
            break
        end

		task.wait()
    end
end)

_G["__PickupP90"] = UserInputService.InputBegan:Connect(function(Key, Process)
	if (Key.KeyCode == Enum.KeyCode.Z) and not Process and LocalPlayer.Character then
		local Character = LocalPlayer.Character
		local Character_Primary = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
		local Item:Model?, Primary:BasePart? = GetItem("P90")

		if Item and Item:FindFirstChild("Pickup") and Primary and Character_Primary then
			RemoteFunction:InvokeServer("VerifyPickup", {Position = Character_Primary.Position; Parent = Item})
		end
	end
end)
