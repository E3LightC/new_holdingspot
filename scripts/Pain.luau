--!strict
--//// Discord: @_x4yz \\\\--
--// https://www.roblox.com/games/6230718877/Pain
--// not done

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if _G["BoxCreator"] then
    _G["BoxCreator"]:Disconnect()
    _G["BoxCreator"] = nil
end

if _G["Selector"] then
    _G["Selector"]:Disconnect()
    _G["Selector"] = nil
end

if _G["Toggler"] then
    _G["Toggler"]:Disconnect()
    _G["Toggler"] = nil
end
_G["IsToggled"] = false

if _G["MainLoop"] then
    _G["MainLoop"]:Disconnect()
    _G["MainLoop"] = nil
end

local function GetPositionFromPart(Part:BasePart, ApplyPrediction:boolean?):(Vector3)
    if typeof(Part) ~= "Instance" or not Part:IsA("BasePart") then
        --//warn("[FAIL # FireAttempt]: \"Part\" is not a BasePart")
        return Vector3.new()
    end
    if type(ApplyPrediction) ~= "boolean" then
        ApplyPrediction = true
    end 

    if not ApplyPrediction then
        return Part.Position
    else
        local Velocity:Vector3 = Vector3.new(Part.AssemblyLinearVelocity.X, 0, Part.AssemblyLinearVelocity.Z)
        return (Velocity == Vector3.zero and Part.Position) or (Part.Position + (Velocity * LocalPlayer:GetNetworkPing()))
    end
end

local function AttemptToFire(Remote:RemoteFunction, Position:Vector3, PrimaryPart:BasePart):(boolean)
    if typeof(Remote) ~= "Instance" then
        --//warn("[FAIL # FireAttempt]: \"RemoteEvent\" is not a RemoteEvent")
        return false
    end
    if typeof(PrimaryPart) ~= "Instance" then
        --//warn("[FAIL # FireAttempt]: \"RemoteEvent\" is not a RemoteEvent")
        return false
    end
    if type(Position) ~= "vector" or type(Position["Z"]) ~= "number" then
        --//warn("[FAIL # FireAttempt]: \"Position\" is not a vector")
        return false
    end
    if (Position == Vector3.zero) and (PrimaryPart.Position.Magnitude ~= 0) then
        task.spawn(Remote.InvokeServer, Remote, GetPositionFromPart(PrimaryPart, true))
        return true
    end

    task.spawn(Remote.InvokeServer, Remote, Position)
    return true
end

_G["BoxCreator"] = RunService.RenderStepped:Connect(function()
    for _, Player in pairs(Players:GetPlayers()) do 
        if Player and Player.Character and not Player.Character:FindFirstChild("__BoxTarget") then
            local Character:Model = Player.Character
            local BoxPart:Part = Instance.new("Part")
            BoxPart.Name = "__BoxTarget"
            BoxPart.CanCollide = false
            BoxPart.Size = Vector3.new(5, 5, 5)
            BoxPart.Transparency = 0.7
            BoxPart.Color = Color3.fromRGB(0, 0, 255)
            BoxPart.Massless = true
            BoxPart.Parent = Character

            local Weld = Instance.new("Weld")
            Weld.Part0 = BoxPart
            Weld.Part1 = (Character.PrimaryPart or Character:WaitForChild("HumanoidRootPart")::BasePart)
            Weld.C0 = CFrame.new(0, 1.5, 0)
            Weld.Parent = BoxPart
        end
    end
end)

_G["Selector"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if Key.KeyCode == Enum.KeyCode.Q and not Process then
        local MouseTarget = Mouse.Target

        if MouseTarget and MouseTarget.Parent then
            local Character:Model = (MouseTarget.Parent::Model)
            local PlayerSelected = Players:GetPlayerFromCharacter(Character)
            
            if Character:FindFirstChild("__BoxTarget") and PlayerSelected then
                _G["TargetSelected"] = tostring(PlayerSelected.Name)
                return
            end
        else
            _G["TargetSelected"] = nil
            return
        end
    end
end)

_G["Toggler"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if Key.KeyCode == Enum.KeyCode.Z and not Process then
        _G["IsToggled"] = not _G["IsToggled"]
        warn(
            ("Script is now toggled %s"):format(_G["IsToggled"] and "on." or "off.")
        )
    end
end)

_G["MainLoop"] = RunService.Heartbeat:Connect(function()
    if _G["IsToggled"] and type(_G["TargetSelected"]) == "string" then
        local TargetSelected:Player = (Players:FindFirstChild(tostring(_G["TargetSelected"]))::Player) 

        if TargetSelected and TargetSelected.Character then
            local LocalPlayerCharacter = LocalPlayer.Character
            local TargetCharacter = TargetSelected.Character
            local PrimaryPart:BasePart = (TargetCharacter.PrimaryPart or TargetCharacter:FindFirstChild("Head")::BasePart)

            if LocalPlayerCharacter and PrimaryPart then
                local Weapon:Model = (LocalPlayerCharacter:FindFirstChild("Minigun") or LocalPlayerCharacter:FindFirstChild("Hitman"))::Model

                if Weapon and Weapon:FindFirstChildWhichIsA("RemoteFunction") then
                    local Remote:RemoteFunction = (Weapon:FindFirstChildWhichIsA("RemoteFunction")::RemoteFunction)
                    AttemptToFire(Remote, (GetPositionFromPart(PrimaryPart, true)), PrimaryPart)
                end
            end
        end
    end
end)
