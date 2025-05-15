--// @_x4yz
--// https://www.roblox.com/games/3264184746/SCP-Apprehension

local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

_G["__TimesRan"] = (type(_G["__TimesRan"]) ~= "number") and 1 or (_G["__TimesRan"] + 1)
local OldTimesRan = _G["__TimesRan"]

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

    if (ModelName == "MP5") then
        PrimaryPart = Model:FindFirstChild("Handle")
        Model.PrimaryPart = PrimaryPart
    end
    if not PrimaryPart then
        return
    end

    local EspColor = EspColors[ModelName]
    if (typeof(EspColor) ~= "Color3") then 
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
        Connection = nil
    end)

    --warn("adding esp for "..ModelName)
    Adornment.Name = "__EspBox"
    Adornment.Adornee = Model.PrimaryPart
    Adornment.Size = (Model:GetExtentsSize() + Vector3.new(2.5, 2.5, 2.5))
    Adornment.AlwaysOnTop = true
    Adornment.ZIndex = 10
    Adornment.Transparency = 0.2
    Adornment.Color3 = EspColors[ModelName]
    Adornment.Parent = Model
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
            task.wait(0.125)
        else
            task.spawn(DeleteOldEsps)
            break
        end

		task.wait()
    end
end)
