--// @_x4yz
--// https://www.roblox.com/games/86340697076369/DOOMED-2-DIE

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AbilityServer = Remotes:WaitForChild("AbilityServer")
local DamageEvent = Remotes:WaitForChild("DamageEvent")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local GameModules = Modules:WaitForChild("Game")
local Tools = GameModules:WaitForChild("Tools")
local GunSettings = Tools:WaitForChild("GunSettings")

local GameFolder = Workspace:WaitForChild("Game")
local NPCs = GameFolder:WaitForChild("NPCs")

local LocalPlayer = Players.LocalPlayer

if getgenv()["__MainInputBegin"] then
    getgenv()["__MainInputBegin"]:Disconnect()
    getgenv()["__MainInputBegin"] = nil
end
if getgenv()["__MainInputEnd"] then
    getgenv()["__MainInputEnd"]:Disconnect()
    getgenv()["__MainInputEnd"] = nil
end

local function GetCharacterPos(
    GetCFrame:boolean?
):(Vector3|boolean?)
    if (type(GetCFrame) ~= "boolean") then 
        GetCFrame = false
    end

    local Character = LocalPlayer.Character
    if not Character then 
        return false
    end
    local PrimaryPart = Character.PrimaryPart
    if not PrimaryPart then 
        return false
    end

    return GetCFrame and PrimaryPart.CFrame
        or PrimaryPart.Position
end

local BindFunctions = {
    --// || technician/engi ||
    [Enum.KeyCode.KeypadOne] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

        for i = 1, 25 do 
            local Position = GetCharacterPos(true)
            if (typeof(Position) ~= "CFrame") then 
                break
            end
            
            AbilityServer:FireServer({
                ["CLASS_REQUIREMENT"] = "Class_Technician",
                ["FUNC_NAME"] = "RepSentryBuild",
                ["Run"] = true,
                ["Pos"] = (Position * CFrame.new(
                    math.random(-25, 25),
                    0, 
                    math.random(-25, 25)
                ))
            })
        end
    end);
    [Enum.KeyCode.KeypadTwo] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

        for i = 1, 25 do 
            local Position = GetCharacterPos(false)
            if (typeof(Position) ~= "Vector3") then 
                break
            end
            
            AbilityServer:FireServer({
                ["CLASS_REQUIREMENT"] = "Class_Technician",
                ["FUNC_NAME"] = "RepEMPMine",
                ["MinePos"] = (Position + Vector3.new(
                    math.random(-25, 25),
                    0, 
                    math.random(-25, 25)
                ))
            })
        end
    end);
    
    --// || medic ||
    [Enum.KeyCode.KeypadThree] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

        for i = 1, 25 do 
            local Position = GetCharacterPos(false)
            if (typeof(Position) ~= "Vector3") then 
                break
            end
            
            AbilityServer:FireServer({
                ["CLASS_REQUIREMENT"] = "Class_Medic",
                ["FUNC_NAME"] = "RepMedicMine",
                ["MinePos"] = (Position + Vector3.new(
                    math.random(-25, 25),
                    0, 
                    math.random(-25, 25)
                ))
            })
        end
    end);

    --// || zombie stuff ||
    [Enum.KeyCode.Z] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

        for _, NPC in pairs(NPCs:GetChildren()) do 
            if not LocalPlayer.Character then 
                break
            end
            local Character = LocalPlayer.Character
            if not NPC or not NPC:IsA("Model") then 
                continue
            end
            local PrimaryPart = NPC.PrimaryPart or NPC:FindFirstChild("HumanoidRootPart")
            if not PrimaryPart then 
                continue
            end
            local Humanoid = NPC:FindFirstChildWhichIsA("Humanoid")
            if not Humanoid then 
                continue
            end

            local Position = PrimaryPart and PrimaryPart.Position or Vector3.zero
            DamageEvent:FireServer(
                Humanoid,
                Character,
                GunSettings:FindFirstChild("god47") or GunSettings:WaitForChild("Deagle"),
                Position,
                PrimaryPart,
                Position,
                true,
                false --// if hit smoker tongue, then true if not false? assuming based on the code
            )
        end
    end);
}

getgenv()["__MainInputBegin"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if not Process then
        local BindFunction = BindFunctions[Key.KeyCode]

        if (type(BindFunction) == "function") then
			task.spawn(BindFunction, "Begin")
        end
    end
end)
getgenv()["__MainInputEnd"] = UserInputService.InputEnded:Connect(function(Key, Process)
    if not Process then
        local BindFunction = BindFunctions[Key.KeyCode]

        if (type(BindFunction) == "function") then
			task.spawn(BindFunction, "End")
        end
    end
end)
