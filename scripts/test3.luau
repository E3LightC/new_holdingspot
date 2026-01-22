local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")

local Channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack

local Character = LocalPlayer.Character
local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

local function OpenAll(ItemName:string)
	local Count = 0
	for _, v in pairs(Backpack:GetChildren()) do 
		if not v then
			continue
		end
		if (ItemName and (v.Name == ItemName)) or (not ItemName and
			((v.Name == "Dark Chest") 
			or (v.Name == "Light Chest")
			or (v.Name == "Chest")
			or (v.Name == "Radioactive Chest")
			or (v.Name == "Fish Chest")
			or (v.Name == "Gift")))
		then
			Count += 1
			v.Parent = Character
			v:Activate()
			if (v.Name == "Christmas Gift") then
				v.Parent = Backpack
			end
			if (Count >= 0) then
				task.wait()
			end
		end
	end
end

--while shared.f == nil do 
	OpenAll("Christmas Gift")
	task.wait(3)
	for _, Chest in pairs(Workspace:GetChildren()) do 
		if not Chest or not Chest:IsA("Part") or (Chest.Name ~= "Gift_p") then 
			continue
		end
		local ChestPrompt = Chest:FindFirstChild("ProximityPrompt")
		if not ChestPrompt then
			continue
		end
		local Tries = 0
		repeat
			if shared.Breakt then 
				break
			end
			if not Chest or not Chest.Parent or not ChestPrompt then
				break
			end
			ChestPrompt.HoldDuration = 0
			PrimaryPart.CFrame = Chest.CFrame
			fireproximityprompt(ChestPrompt)
			Tries += 1
			task.wait(0.05)
			if (Tries >= 20) then
				break
			end
		until not Chest or not Chest.Parent
	end
	task.wait(1)
	OpenAll("Gift")
	task.wait(1.5)
	OpenAll()
	Channel:SendAsync(";delitems")

--	task.wait(15)
--end
