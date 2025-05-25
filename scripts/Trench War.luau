--//// @_x4yz
--// https://www.roblox.com/games/117036812620193/Trench-War

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

if _G["__MainBind"] then
    _G["__MainBind"]:Disconnect()
    _G["__MainBind"] = nil
end

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack

local Camera = Workspace.CurrentCamera

local Event = ReplicatedStorage:WaitForChild("Event")

local SpawnParameters = {[2] = Vector3.new()}

local BindFunctions = {
    [Enum.KeyCode.Z] = (function()
        local Weapon = Backpack:FindFirstChild("Pistol")
        local RemoteEvent = Weapon and Weapon:FindFirstChild("RemoteEvent")

        if RemoteEvent then
            for _, Player:Player in pairs(Players:GetPlayers()) do 
                if (Player ~= LocalPlayer) and Player.Character then
                    local Character = Player.Character
                    local Humanoid = Character:FindFirstChild("Humanoid") or Character:FindFirstChildWhichIsA("Humanoid")
                    if not Humanoid or (Humanoid.Health <= 0) then
                        continue
                    end

                    RemoteEvent:FireServer(Humanoid, 9e9, {
                        0;
                        CFrame.identity;
                    })
                end
            end
        end
    end);
    [Enum.KeyCode.X] = (function()
        local Weapon = Backpack:FindFirstChild("Pistol")
        local RemoteEvent = Weapon and Weapon:FindFirstChild("RemoteEvent")

        if RemoteEvent then
            for _, Player:Player in pairs(Players:GetPlayers()) do 
                if (Player ~= LocalPlayer) and Player.Character then
                    local Character = Player.Character
                    local Humanoid = Character:FindFirstChild("Humanoid") or Character:FindFirstChildWhichIsA("Humanoid")
                    if not Humanoid or (Humanoid.Health <= 0) then
                        continue
                    end

                    RemoteEvent:FireServer(Humanoid, -9e9, {
                        0;
                        CFrame.identity;
                    })
                end
            end
        end
    end);

    [Enum.KeyCode.KeypadOne] = (function()
        local Character = LocalPlayer.Character
        local PrimaryPart = Character and (Character.PrimaryPart or Character:FindFirstChild("Head"))

        if PrimaryPart then
            local OldCFrame = PrimaryPart.CFrame
            local OldCameraCFrame = Camera.CFrame
            local Connection
            
            Connection = LocalPlayer.CharacterAdded:Connect(function(NewCharacter:Model)
                repeat
                    task.wait()
                until NewCharacter.PrimaryPart
                local NewPrimaryPart = NewCharacter.PrimaryPart
                
                NewPrimaryPart.CFrame = OldCFrame
                Camera.CFrame = OldCameraCFrame
                Camera.CameraType = Enum.CameraType.Custom
                
                Connection:Disconnect()
                Connection = nil
            end)

            Camera.CameraType = Enum.CameraType.Scriptable
            Event:FireServer("Spawn", SpawnParameters)
        end
    end);
}

_G["__MainBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if not Process then
        local KeyCode = Key.KeyCode
        local BindFunction = BindFunctions[KeyCode]

        if (type(BindFunction) == "function") then
            task.spawn(BindFunction)
        end
    end
end)
