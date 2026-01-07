local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")

local Channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui

local Character = LocalPlayer.Character
local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

local ShopPos:CFrame = CFrame.new(-996, 5, 90)

local ProximityPrompt:ProximityPrompt = Workspace["Map folder"].Seller.Liltroll.PromptInteract.ProximityPrompt

if shared.epic then
	coroutine.close(shared.epic)
	shared.epic = nil
end

local function OpenAll()
	local Count = 0
	for _, v in pairs(Backpack:GetChildren()) do 
		if not v then
			continue
		end
		if (v.Name == "Dark Chest") then
			Count += 1
			v.Parent = Character
			v:Activate()

			if (Count >= 12) then
				task.wait()
			end
		end
	end
end

local function OpenShop()
	PrimaryPart.CFrame = ShopPos
	task.wait(0.25)

	local ShopGui
	repeat
		replicatesignal(ProximityPrompt.TriggeredActionReplicated, LocalPlayer)
		task.wait(0.1)
		ShopGui = PlayerGui:FindFirstChild("Shopguis")
	until ShopGui

	return ShopGui
end

local function GetShard()
	local Shard = Backpack:FindFirstChild("NightmareShard")
	if Shard then
		return Shard
	end

	local ShopGui = OpenShop()
	task.wait(2)
	
	local BuyButton = ShopGui.MainsFrame.ItemSelections.MainShop.Buy
	local DarkChestButton = ShopGui.MainsFrame.ItemSelections.ScrollingFrame["Dark Chest"]
	print("hey im buying ok? [game]: ok")

	for _ = 1, 3 do 
		replicatesignal(DarkChestButton.MouseButton1Down, 50, 50)
		task.wait()
	end

	LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Shopguis"):WaitForChild("MainsFrame"):WaitForChild("ItemSelections"):WaitForChild("MainShop"):WaitForChild("DisabledWord"):WaitForChild("RemoteEvent"):FireServer(150)

	repeat
		replicatesignal(BuyButton.MouseButton1Down, 50, 50)
		task.wait(3)
		OpenAll()
		task.wait(3)
		Channel:SendAsync(";delitems")

		Shard = Backpack:FindFirstChild("NightmareShard")
		if Shard then
			ShopGui.MainsFrame.ButtonSelections.Destroys:FireServer()
			Character:WaitForChild("Camera"):WaitForChild("Destroyeds"):FireServer()
			return Shard
		end

		task.wait(1.5)
	until Shard

	return Shard
end

shared.epic = coroutine.create(function()
	while true do
		local Shard = GetShard()
		if Shard then
			Shard.Parent = Character
			Shard:Activate()

			local Fist = Character:WaitForChild("Clenching Fist", 3) or Backpack:WaitForChild("Clenching Fist", 3)
			local Determination = Character:WaitForChild("Determination", 3) or Backpack:WaitForChild("Determination", 3)
			local Remote = Fist:WaitForChild("GrabAnimation"):WaitForChild("Start")

			local Nightmare = workspace["Map Boss"]["Nightmare Boss Map"]:WaitForChild("Nightmare")
			local Humanoid = Nightmare:WaitForChild("Humanoid")

			Remote:FireServer()
			task.wait(2)
			repeat
				if Determination and Determination.Parent ~= Character then
					Determination.Parent = Character
				end
				Determination:Activate()
				Remote:FireServer()
				PrimaryPart.CFrame = Nightmare.PrimaryPart.CFrame
				task.wait(0.2)
			until not Nightmare or not Nightmare.Parent or not Humanoid or (Humanoid.Health <= 0)

			task.wait(0.5)

			for _, Chest in pairs(Workspace:GetChildren()) do 
				if not Chest then
					continue
				end
				if (Chest.Name == "DarkChest_Spawn") or (Chest.Name == "VoidChest_p") then
					local Handle = Chest:IsA("Model") and Chest.PrimaryPart or Chest
					if not Handle then
						continue
					end
					local Prox = Handle:FindFirstChild("ProximityPrompt")
					if not Prox then
						continue
					end

					PrimaryPart.CFrame = Handle.CFrame
					task.wait(0.125)
					replicatesignal(Prox.TriggeredActionReplicated, LocalPlayer)
					task.wait()
				end
			end
		end
		task.wait()
	end
end)
coroutine.resume(shared.epic)
