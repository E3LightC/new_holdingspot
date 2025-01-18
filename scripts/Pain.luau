--!strict
--//// Discord: @_x4yz \\\\--
--// https://www.roblox.com/games/6230718877/Pain
--// soon

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local function AttemptToFire(Remote:RemoteFunction, Position:Vector3):(boolean)
    if typeof(Remote) ~= "Instance" then
        --//warn("[FAIL # FireAttempt]: \"RemoteEvent\" is not a RemoteEvent")
        return false
    end
    if type(Position) ~= "vector" or type(Position["Z"]) ~= "number" then
        --//warn("[FAIL # FireAttempt]: \"Position\" is not a vector")
        return false
    end

    task.spawn(Remote.InvokeServer, Remote, Position)
    return true
end

local function GetPositionFromPart(Part:BasePart, ApplyPrediction:boolean?):(Vector3?|boolean)
    if typeof(Part) ~= "Instance" or not Part:IsA("BasePart") then
        --//warn("[FAIL # FireAttempt]: \"Part\" is not a BasePart")
        return false
    end
    if type(ApplyPrediction) ~= "boolean" then
        ApplyPrediction = true
    end 

    if not ApplyPrediction then
        return Part.Position
    else
        local Position:Vector3 = Part.Position
        local Velocity:Vector3 = Part.AssemblyLinearVelocity
        Velocity.Y /= 4

        return (
            Position 
                * 
            (Velocity 
                * 
                (
                    LocalPlayer:GetNetworkPing() 
                        + 
                    0.0075
                )
            )
        )
    end
end

