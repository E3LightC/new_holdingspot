local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")
local GuiService = game:GetService("GuiService")

local Channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui

local Character = LocalPlayer.Character
local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

local ShopPos:CFrame = CFrame.new(-996, 5, 90)

local MapFolder = Workspace:WaitForChild("Map folder")
local SellerFolder = MapFolder:WaitForChild("Seller")
local LilTroll = SellerFolder:WaitForChild("Liltroll")
local LilTrollInteract = LilTroll:WaitForChild("PromptInteract")
local TrollPrompt:ProximityPrompt = LilTrollInteract:WaitForChild("ProximityPrompt")
local ChestFolder = Workspace:WaitForChild("ChestFolderThing")

local KilledTimes:number = 0

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
		if 
			(v.Name == "Dark Chest") 
			or (v.Name == "Light Chest")
			or (v.Name == "Chest")
			or (v.Name == "Radioactive Chest")
			or (v.Name == "Fish Chest")
		then
			Count += 1
			v.Parent = Character
			v:Activate()

			if (Count >= 15) then
				task.wait()
			end
		end
	end
end

local function OpenShop()
	PrimaryPart.CFrame = ShopPos
	task.wait(0.25)

	local ShopGui = PlayerGui:FindFirstChild("Shopguis")
	if ShopGui then 
		return ShopGui
	end

	repeat
		replicatesignal(TrollPrompt.TriggeredActionReplicated, LocalPlayer)
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
	local MainFrame = ShopGui:WaitForChild("MainsFrame")
	local ItemSelections = MainFrame:WaitForChild("ItemSelections")
	local MainShop = ItemSelections:WaitForChild("MainShop")
	local ScrollingFrame = ItemSelections:WaitForChild("ScrollingFrame")
	task.wait(2)
	local BuyButton = MainShop:WaitForChild("Buy")
	local ChestButton = ScrollingFrame:WaitForChild("Dark Chest")
	print("hey im buying ok? [game]: ok")

	for _ = 1, 3 do 
		replicatesignal(ChestButton.MouseButton1Down, 50, 50)
		task.wait()
	end

	MainShop:WaitForChild("DisabledWord"):WaitForChild("RemoteEvent"):FireServer(175)

	repeat
		replicatesignal(ChestButton.MouseButton1Down, 50, 50)
		task.wait()
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
		local Nightmare = workspace["Map Boss"]["Nightmare Boss Map"]:FindFirstChild("Nightmare")
		
		if not Nightmare then
			local Shard = GetShard()
			if not Shard then
				return
			end
			Shard.Parent = Character
			Shard:Activate()

			Nightmare = workspace["Map Boss"]["Nightmare Boss Map"]:WaitForChild("Nightmare")
		end

		local NightmarePrimary = Nightmare.PrimaryPart or Nightmare:WaitForChild("HumanoidRootPart")
		local Humanoid = Nightmare:WaitForChild("Humanoid")

		task.wait(0.1)
		repeat
			PrimaryPart.CFrame = NightmarePrimary.CFrame
			if Nightmare and Nightmare.Parent then
				if not Humanoid or not NightmarePrimary then 
					break
				end
				if isnetworkowner(NightmarePrimary) then
					Humanoid.Health = 0
				else 
					setsimulationradius(1024)
					task.wait()
					setsimulationradius(math.huge)
				end
			end

			task.wait(0.05)
		until not Nightmare or not Nightmare.Parent or not Humanoid or (Humanoid.Health <= 0) or not NightmarePrimary

		KilledTimes += 1
		task.wait(2)

		for _, Chest in pairs(Workspace:GetChildren()) do 
			if not Chest then
				continue
			end
			if (Chest.Name == "DarkChest_Spawn") or (Chest.Name == "VoidChest_p") then
				local Handle = Chest:IsA("Model") and Chest.PrimaryPart or Chest
				if not Handle then
					continue
				end
				local ChestPrompt = Handle:FindFirstChild("ProximityPrompt")
				if not ChestPrompt then
					continue
				end

				PrimaryPart.CFrame = Handle.CFrame
				task.wait(0.125)
				repeat
					if not ChestPrompt or not ChestPrompt.Parent or not Handle or not Handle then
						break
					end

					PrimaryPart.CFrame = Handle.CFrame
					fireproximityprompt(ChestPrompt)
					task.wait(0.05)
				until not ChestPrompt or not Handle or not Handle.CFrame
			end
		end

		if (KilledTimes < 3) then 
			continue
		end
		KilledTimes = 0
		for _, Chest in pairs(ChestFolder:GetChildren()) do 
			if not Chest or not Chest:IsA("Model") or (Chest.Name == "__BadChest") then 
				continue
			end
			local Handle = Chest.PrimaryPart or Chest:FindFirstChild("Handle")
			if not Handle then
				continue
			end
			local ChestPrompt = Handle:FindFirstChild("ProximityPrompt")
			if not ChestPrompt then
				continue
			end
			if Handle.Anchored then
				Chest.Name = "__BadChest"
				continue
			end
			repeat
				if not Chest or not Chest.Parent or not Handle or not ChestPrompt then
					break
				end
				ChestPrompt.HoldDuration = 0
				PrimaryPart.CFrame = Handle.CFrame
				fireproximityprompt(ChestPrompt)
				task.wait(0.05)
			until not Chest or not Chest.Parent
		end
		task.wait()
	end
end)
coroutine.resume(shared.epic)
