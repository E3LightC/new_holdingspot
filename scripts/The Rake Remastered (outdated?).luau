--// @_x4yz
--// https://www.roblox.com/games/2413927524/UPD-The-Rake-REMASTERED

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if _G["__MainInputBegin"] then
    _G["__MainInputBegin"]:Disconnect()
    _G["__MainInputBegin"] = nil
end
if _G["__RunServiceLoop"] then
    _G["__RunServiceLoop"]:Disconnect()
    _G["__RunServiceLoop"] = nil
end

local LocalPlayer = Players.LocalPlayer

local Filter_Folder = Workspace:WaitForChild("Filter")
local Debris_Folder = Workspace:WaitForChild("Debris")

local TKSMNA = ReplicatedStorage:WaitForChild("TKSMNA")

local ScrapSpawns_Folder = Filter_Folder:WaitForChild("ScrapSpawns")
local SupplyCrates_Folder = Debris_Folder:WaitForChild("SupplyCrates")

local LastEspUpdate = 0
local TimeToWaitBeforeNextUpdate = 0.125

local ScrapEspEnabled = false
local SupplyCratesEspEnabled = false
local FlareEspEnabled = false
local RakeEspEnabled = false

local function GetScraps()
    local Scraps = {}

    for _, ScrapModel in pairs(ScrapSpawns_Folder:GetDescendants()) do 
        if ScrapModel and ScrapModel:FindFirstChild("LevelVal") and ScrapModel:FindFirstChild("PointsVal") then
            local LevelVal = ScrapModel:WaitForChild("LevelVal", 1)
            table.insert(Scraps, {ScrapModel, LevelVal.Value})
        end
    end

    return Scraps
end

local function GetSupplyCrates()
    local SupplyCrates = {}

    for _, SupplyCrateModel in pairs(SupplyCrates_Folder:GetDescendants()) do 
        if SupplyCrateModel and SupplyCrateModel:FindFirstChild("UnlockValue") then
            table.insert(SupplyCrates, SupplyCrateModel)
        end
    end

    return SupplyCrates
end

local function HighlightScraps()
	for _, ScrapData in ipairs(GetScraps()) do
		local ScrapModel = ScrapData[1]
        local Level = ScrapData[2]
        if not ScrapModel or not Level then
            continue
        end
		local Primary = ScrapModel:FindFirstChild("Scrap") or ScrapModel:FindFirstChildWhichIsA("BasePart")
		if not Primary then
			continue
		end

		for _, Child in ipairs(ScrapModel:GetChildren()) do
			if Child:IsA("BoxHandleAdornment") and (Child.Name == "ScrapBox") then
				Child:Destroy()
			elseif Child:IsA("BillboardGui") and (Child.Name == "ScrapLevelGui") then
				Child:Destroy()
			end
		end

		local Box = Instance.new("BoxHandleAdornment")
		Box.Name = "ScrapBox"
		Box.Adornee = Primary
		Box.Size = vector.create(2.5, 2.5, 2.5)
		Box.ZIndex = 5
		Box.AlwaysOnTop = true
		Box.Color3 = Color3.fromRGB(255, 215, 0)
		Box.Transparency = 0.25
		Box.AdornCullingMode = Enum.AdornCullingMode.Never

		local Gui = Instance.new("BillboardGui")
		Gui.Name = "ScrapLevelGui"
		Gui.Adornee = Primary
		Gui.Size = UDim2.new(0, 100, 0, 40)
		Gui.StudsOffset = Vector3.new(0, 3, 0)
		Gui.AlwaysOnTop = true

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 1, 0)
		Label.BackgroundTransparency = 1
		Label.Text = `Scrap | Level {tostring(Level)}`
		Label.TextColor3 = Color3.new(1, 1, 0)
		Label.TextStrokeTransparency = 0.5
		Label.TextScaled = true
		Label.Font = Enum.Font.SourceSansBold

        Box.Parent = ScrapModel
		Gui.Parent = ScrapModel
        Label.Parent = Gui
	end
end

local function HighlightSupplyCrates()
	for _, SupplyCrateModel in ipairs(GetSupplyCrates()) do
		local Primary = SupplyCrateModel:FindFirstChildWhichIsA("BasePart")
		if not Primary then
			continue
		end

		for _, Child in ipairs(SupplyCrateModel:GetChildren()) do
			if Child:IsA("BoxHandleAdornment") and (Child.Name == "SupplyBox") then
				Child:Destroy()
			elseif Child:IsA("BillboardGui") and (Child.Name == "SupplyGui") then
				Child:Destroy()
			end
		end

		local Box = Instance.new("BoxHandleAdornment")
		Box.Name = "SupplyBox"
		Box.Adornee = Primary
		Box.Size = Primary.Size
		Box.ZIndex = 5
		Box.AlwaysOnTop = true
		Box.Color3 = Color3.fromRGB(0, 255, 127)
		Box.Transparency = 0.25
		Box.AdornCullingMode = Enum.AdornCullingMode.Never

		local Gui = Instance.new("BillboardGui")
		Gui.Name = "SupplyGui"
		Gui.Adornee = Primary
		Gui.Size = UDim2.new(0, 100, 0, 30)
		Gui.StudsOffset = Vector3.new(0, 3, 0)
		Gui.AlwaysOnTop = true

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, 0, 1, 0)
		Label.BackgroundTransparency = 1
		Label.Text = "Supply Crate"
		Label.TextColor3 = Color3.new(0, 1, 0.5)
		Label.TextStrokeTransparency = 0.5
		Label.TextScaled = true
		Label.Font = Enum.Font.SourceSansBold

		Box.Parent = SupplyCrateModel
		Gui.Parent = SupplyCrateModel
		Label.Parent = Gui
	end
end

local function HighlightFlare()
	local FlarePickupModel = Workspace:FindFirstChild("FlareGunPickUp", true)
    if not FlarePickupModel then
        --//warn("[FAIL # HighlightFlare]: Failed to find flare gun pickup.")
        return
    end
	local Primary = FlarePickupModel:FindFirstChild("FlareGun") or FlarePickupModel:FindFirstChildWhichIsA("BasePart")
	if not Primary then
        warn("[FAIL # HighlightFlare]: The flare gun has no part.")
		return
	end

	for _, Child in ipairs(FlarePickupModel:GetChildren()) do
		if Child:IsA("BoxHandleAdornment") and (Child.Name == "FlareGunBox") then
			Child:Destroy()
		elseif Child:IsA("BillboardGui") and (Child.Name == "FlareGunGui") then
			Child:Destroy()
		end
	end

	local Box = Instance.new("BoxHandleAdornment")
	Box.Name = "FlareGunBox"
	Box.Adornee = Primary
	Box.Size = FlarePickupModel:GetExtentsSize()
	Box.ZIndex = 5
	Box.AlwaysOnTop = true
	Box.Color3 = Color3.new(0, 1, 1)
	Box.Transparency = 0.8
	Box.AdornCullingMode = Enum.AdornCullingMode.Never

	local Gui = Instance.new("BillboardGui")
	Gui.Name = "FlareGunGui"
	Gui.Adornee = Primary
	Gui.Size = UDim2.new(0, 100, 0, 20)
	Gui.StudsOffset = Vector3.new(0, 3, 0)
	Gui.AlwaysOnTop = true

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = `The Rake`
	Label.TextColor3 = Color3.new(0, 1, 1)
	Label.TextStrokeTransparency = 0.5
	Label.TextScaled = true
	Label.Font = Enum.Font.SourceSansBold

    Box.Parent = RakeModel
	Gui.Parent = RakeModel
    Label.Parent = Gui
end

local function HighlightRake()
	local RakeModel = Workspace:FindFirstChild("Rake", true)
    if not RakeModel then
        --//warn("[FAIL # HighlightRake]: Failed to find the Rake.")
        return
    end
	local Primary = RakeModel.PrimaryPart or RakeModel:FindFirstChild("HumanoidRootPart")
	if not Primary then
        warn("[FAIL # HighlightRake]: The Rake has no `PrimaryPart`, nor a HumanoidRootPart.")
		return
	end

	for _, Child in ipairs(RakeModel:GetChildren()) do
		if Child:IsA("BoxHandleAdornment") and (Child.Name == "RakeBox") then
			Child:Destroy()
		elseif Child:IsA("BillboardGui") and (Child.Name == "RakeGui") then
			Child:Destroy()
		end
	end

	local Box = Instance.new("BoxHandleAdornment")
	Box.Name = "RakeBox"
	Box.Adornee = Primary
	Box.Size = RakeModel:GetExtentsSize()
	Box.ZIndex = 5
	Box.AlwaysOnTop = true
	Box.Color3 = Color3.new(1, 0, 0)
	Box.Transparency = 0.8
	Box.AdornCullingMode = Enum.AdornCullingMode.Never

	local Gui = Instance.new("BillboardGui")
	Gui.Name = "RakeGui"
	Gui.Adornee = Primary
	Gui.Size = UDim2.new(0, 100, 0, 20)
	Gui.StudsOffset = Vector3.new(0, 3, 0)
	Gui.AlwaysOnTop = true

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = `The Rake`
	Label.TextColor3 = Color3.new(1, 0, 0)
	Label.TextStrokeTransparency = 0.5
	Label.TextScaled = true
	Label.Font = Enum.Font.SourceSansBold

    Box.Parent = RakeModel
	Gui.Parent = RakeModel
    Label.Parent = Gui
end

local function InfiniteStamina()
	for _, Connection in pairs(getconnections(TKSMNA.Event)) do 
		if Connection and Connection.Enabled then
			Connection:Disconnect()
		end
	end
    for _, Module:ModuleScript in pairs(getloadedmodules()) do
        if (Module.Name == "M_H") then
            local Required = require(Module)
            if Required and Required.TakeStamina then
                local OldTakeStamina = Required.TakeStamina
                Required.TakeStamina = function(Self, Amount)
                    if (Amount > 0) then
                        return
                    end
                    
                    return OldTakeStamina(Self, Amount)
                end
            else
                warn("[FAIL # InfiniteStamina]: M_H module does not have a `TakeStamina` function or is incorrectly structured.")
            end
        end
    end
end

local BindFunctions = {
    [Enum.KeyCode.KeypadOne] = InfiniteStamina;
    [Enum.KeyCode.KeypadTwo] = (function()
        ScrapEspEnabled = not ScrapEspEnabled
        print(`[INFO]: \`ScrapEspEnabled\` is now toggled {ScrapEspEnabled and "on" or "off"}.`)
    end);
    [Enum.KeyCode.KeypadThree] = (function()
        FlareEspEnabled = not FlareEspEnabled
        print(`[INFO]: \`FlareEspEnabled\` is now toggled {FlareEspEnabled and "on" or "off"}.`)
    end);
    [Enum.KeyCode.KeypadFour] = (function()
        SupplyCratesEspEnabled = not SupplyCratesEspEnabled
        print(`[INFO]: \`SupplyCratesEspEnabled\` is now toggled {SupplyCratesEspEnabled and "on" or "off"}.`)
    end);
    [Enum.KeyCode.KeypadFive] = (function()
        RakeEspEnabled = not RakeEspEnabled
        print(`[INFO]: \`RakeEspEnabled\` is now toggled {RakeEspEnabled and "on" or "off"}.`)
    end);
}

_G["__MainInputBegin"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if not Process then
        local KeyCode = Key.KeyCode
        local BindFunction = BindFunctions[KeyCode]

        if (type(BindFunction) == "function") then
            coroutine.wrap(BindFunction)()
        end
    end
end)

_G["__RunServiceLoop"] = RunService.Heartbeat:Connect(function()
    if ((tick() - LastEspUpdate) >= TimeToWaitBeforeNextUpdate) then
        LastEspUpdate = tick()

        if ScrapEspEnabled then
            coroutine.wrap(HighlightScraps)()
        end
	    if SupplyCratesEspEnabled then
		    coroutine.wrap(HighlightSupplyCrates)()
	    end
        if FlareEspEnabled then
		    coroutine.wrap(HighlightFlare)()
        end
        if RakeEspEnabled then
            coroutine.wrap(HighlightRake)()
        end
    end
end)
