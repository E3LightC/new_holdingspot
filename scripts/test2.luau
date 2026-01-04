local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local Character = LocalPlayer.Character
local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

do
	local oldhmmi
	local oldhmmnc
	local oldKickFunction
	if hookfunction then
	    oldKickFunction = hookfunction(LocalPlayer.Kick, function() end)
	end
	oldhmmi = hookmetamethod(game, "__index", function(self, method)
	    if self == LocalPlayer and method:lower() == "kick" then
	        return error("Expected ':' not '.' calling member function Kick", 2)
	    end
	    return oldhmmi(self, method)
	end)
	oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
	    if self == LocalPlayer and getnamecallmethod():lower() == "kick" then
	        return
	    end
	    return oldhmmnc(self, ...)
	end)
end

local SanstaPlaceId:number = 78920688240321
if (game.PlaceId ~= SanstaPlaceId) then
	TeleportService:Teleport(SanstaPlaceId)
	return
end

local InteractPartPos:CFrame = CFrame.new(9, 6, 128)
local FightPartPos:CFrame = CFrame.new(-4.2, 2.5, 120)
local AFKPos:CFrame = CFrame.new(-46, 3, 544)
local SanstaOffset:CFrame = CFrame.new(0, 0, -2)

local SanstaModel:Model = Workspace:WaitForChild("Sansta")
local SanstaHumanoid:Humanoid = SanstaModel:WaitForChild("Humanoid")
local SanstaPrimary:Part = SanstaModel.PrimaryPart
SanstaPrimary.Anchored = true
local AttackScript:Script = SanstaModel:WaitForChild("Attack")

for _ = 1, 10 do PrimaryPart.CFrame = InteractPartPos task.wait(0.05) end
task.wait(0.25)
for _ = 1, 10 do PrimaryPart.CFrame = FightPartPos task.wait(0.05) end
task.wait()

repeat
	task.wait()
until AttackScript.Enabled

local Knife = Backpack:WaitForChild("Anti-Jolly Knife")
local KnifeScript = Knife:WaitForChild("LocalScript")
local RemoteEvent = Knife:WaitForChild("RemoteEvent")
Knife.Parent = Character
--KnifeScript.Enabled = false

Knife.Activated:Connect(function()
    RemoteEvent:FireServer("Start")
	task.wait(0.25)
    RemoteEvent:FireServer("Stop")
end)

repeat
	Knife:Activate()
	PrimaryPart.CFrame = AFKPos
	SanstaPrimary.CFrame = (PrimaryPart.CFrame * SanstaOffset)
	task.wait()
until (SanstaHumanoid.Health <= 50)

local function GetTrueKnife():(Tool)
	local TrueKnife:Tool = Character:FindFirstChild("True Knife") or Backpack:FindFirstChild("True Knife")

	repeat
		for _, FightShard in pairs(Workspace:GetChildren()) do 
			if (FightShard.Name == "FightShard") then
				FightShard.CFrame = PrimaryPart.CFrame
				task.wait()
			end
		end

		TrueKnife = Character:FindFirstChild("True Knife") or Backpack:FindFirstChild("True Knife")
		if TrueKnife then
			break
		end

		task.wait()
	until TrueKnife
	
	return TrueKnife
end

repeat
	SanstaPrimary.Anchored = true
	PrimaryPart.CFrame = AFKPos
	SanstaPrimary.CFrame = (PrimaryPart.CFrame * SanstaOffset)

	local TrueKnife = GetTrueKnife()
	TrueKnife.Parent = Character
	
	repeat
		if TrueKnife then
			TrueKnife:Activate()
		end
		task.wait()
	until not TrueKnife or not TrueKnife.Parent

	task.wait(0.1)
until not SanstaHumanoid or (SanstaHumanoid.Health <= 0)

task.wait(7)

local SanstaSoul = Workspace:WaitForChild("SanstaSoul")
for _ = 1, 15 do 
	PrimaryPart.CFrame = SanstaSoul.CFrame
	task.wait(0.1)
end
