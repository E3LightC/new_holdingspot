local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

if _G["UltimateSpammerRocket"] then
    _G["UltimateSpammerRocket"]:Disconnect()
    _G["UltimateSpammerRocket"] = nil
end

local LocalPlayer:Player = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SendAbility:RemoteEvent = (LocalPlayer:WaitForChild("SendAbility")::RemoteEvent)

_G["UltimateSpammerRocket"] = UserInputService.InputBegan:Connect(function(...)
    local Arguments:{any} = {...}
    local Key:InputObject = Arguments[1]
    local Process:boolean = Arguments[2]

    if (Key.KeyCode == Enum.KeyCode.Z) and not Process then
        SendAbility:FireServer(
            "R",
            {LocalPlayer; 9e9}
        )
        SendAbility:FireServer(
            "Ult",
            {
                LocalPlayer;
                9e9;
                Mouse.Hit.Position,
                true
            }
        )
    end
end)
