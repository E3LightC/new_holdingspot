local cloneref = getfenv().cloneref or (function(Object:any?)
	return Object
end)
local sethiddenproperty = getfenv().sethiddenproperty
local replicatesignal = getfenv().replicatesignal
local isnetworkowner = getfenv().isnetworkowner or (function():(boolean) 
	return (math.random(1, 3) == 2) 
end)

local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local TextChatService = cloneref( game:GetService("TextChatService"))
local GuiService = cloneref(game:GetService("GuiService"))
local VirtualInputManager
pcall(function()
	VirtualInputManager = cloneref(Instance.new("VirtualInputManager"))
end)
if not VirtualInputManager then
	VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
end

local ShopPos:CFrame = CFrame.new(-996, 5, 90)
local KilledTimes:number = 0
local UseGuiService:boolean = false
if not UseGuiService then
	UseGuiService = ((type(replicatesignal) ~= "function") and true)
	warn(`Automatically set 'UseGuiService' to 'true' as the current environment doesn't support 'replicatesignal'.`)
end

local TextChannels = TextChatService:WaitForChild("TextChannels")
local RBXGeneral = TextChannels:WaitForChild("RBXGeneral")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui

local Character = LocalPlayer.Character
local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

local MapFolder = Workspace:WaitForChild("Map folder")
local ChestFolder = Workspace:WaitForChild("ChestFolderThing")
local MapBosses = Workspace:WaitForChild("Map Boss")

local SellerFolder = MapFolder:WaitForChild("Seller")
local LilTroll = SellerFolder:WaitForChild("Liltroll")
local LilTrollInteract = LilTroll:WaitForChild("PromptInteract")
local TrollPrompt:ProximityPrompt = LilTrollInteract:WaitForChild("ProximityPrompt")

local BossMap = MapBosses:WaitForChild("Nightmare Boss Map")

if (type(shared.MainAutoLoop) == "thread") then
	task.spawn(pcall, 
		coroutine.close, shared.MainAutoLoop
	)
	shared.MainAutoLoop = nil
end

local fireproximityprompt = getfenv().fireproximityprompt or function(
	ProximityPrompt:ProximityPrompt, 
	Amount:number, 
	Skip:boolean?
):()
	if (typeof(ProximityPrompt) ~= "Instance") or not ProximityPrompt:IsA("ProximityPrompt") then
		return
	end
	if (type(Amount) ~= "number") then
		Amount = 1
	end
	if (Amount ~= Amount) or (math.abs(Amount) == math.huge) then
		Amount = 1
	end

    local OldHoldDuration = ProximityPrompt.HoldDuration
    if Skip then
        ProximityPrompt.HoldDuration = 0
    end

    for i = 1, Amount do
        ProximityPrompt:InputHoldBegin()
        if Skip then
            local RunService = game:GetService("RunService")
            local Start = os.clock()
            repeat
                RunService.Heartbeat:Wait(0.1)
            until ((os.clock() - Start) > OldHoldDuration)
        end
        ProximityPrompt:InputHoldEnd()
    end
    ProximityPrompt.HoldDuration = OldHoldDuration
end
local setsimulationradius = getfenv().setsimulationradius or (function(
	Radius:number
):()
	if (type(Radius) ~= "number") then
		Radius = 1024
	end
	local CanUseSHP = (type(sethiddenproperty) == "function")

	pcall(function()
		if CanUseSHP then
			sethiddenproperty(LocalPlayer, "SimulationRadius", Radius)
		else
			LocalPlayer.SimulationRadius = Radius
		end
	end)
end)

local function OpenAll(
	List:{string}?
):()
	local UseList:boolean = ((type(List) == "table") and (#List > 0))
	local Count:number = 0
	for _, Item in pairs(Backpack:GetChildren()) do 
		if not Item or not Item.Parent then
			continue
		end
		if (
			not UseList and (
				(Item.Name == "Dark Chest") 
				or (Item.Name == "Light Chest")
				or (Item.Name == "Chest")
				or (Item.Name == "Radioactive Chest")
				or (Item.Name == "Fish Chest")
			)
		) or (
			UseList and table.find((List or {}), Item.Name)
		)
		then
			Count += 1
			Item.Parent = Character
			Item:Activate()

			if (Count >= 15) then
				task.wait()
				Count = 0
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
		fireproximityprompt(TrollPrompt)
		task.wait(0.1)
		ShopGui = PlayerGui:FindFirstChild("Shopguis")
	until ShopGui

	return ShopGui
end

local function AttemptButtonActivation(
	Button:GuiButton, 
	ButtonSignal:RBXScriptSignal, 
	...:any?
):()
	if (typeof(Button) ~= "Instance") or not Button:IsA("GuiButton") or not Button:IsDescendantOf(game) then
		return
	end
	if (typeof(ButtonSignal) ~= "RBXScriptSignal") then
		return
	end
	if UseGuiService then
		pcall(function()
			GuiService.SelectedObject = Button
		end)
		if (GuiService.SelectedObject == Button) then
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
		end
	elseif not UseGuiService then
		replicatesignal(ButtonSignal, ...)
	end
end

local function GetShard()
	local Shard = Backpack:FindFirstChild("NightmareShard")
	if Shard then
		return Shard
	end

	local ShopGui = OpenShop()
	local MainFrame = ShopGui:WaitForChild("MainsFrame")

	local ItemSelections = MainFrame:WaitForChild("ItemSelections")
	local SellSelections = MainFrame:WaitForChild("SellSelections")
	local ButtonSelections = MainFrame:WaitForChild("ButtonSelections")
	
	local BuyMainShop = ItemSelections:WaitForChild("MainShop")
	local BuyScrollingFrame = ItemSelections:WaitForChild("ScrollingFrame")
	local SellMainShop = SellSelections:WaitForChild("MainShop")
	local SellScrollingFrame = SellSelections:WaitForChild("ScrollingFrame")

	local BuyButton = BuyMainShop:WaitForChild("Buy")
	local ChestButton = BuyScrollingFrame:WaitForChild("Dark Chest")
	local SellButton = SellMainShop:WaitForChild("Sell")
	local ItemButton = SellScrollingFrame:WaitForChild("Symbiote")

	local SetBuyAmount = BuyMainShop:WaitForChild("DisabledWord"):WaitForChild("RemoteEvent")
	local SetSellAmount = SellMainShop:WaitForChild("DisabledWord"):WaitForChild("RemoteEvent")

	for _ = 1, 3 do 
		AttemptButtonActivation(ChestButton, ChestButton.MouseButton1Down, 0, 0)
		AttemptButtonActivation(ItemButton, ItemButton.MouseButton1Down, 0, 0)
		task.wait()
	end

	SetBuyAmount:FireServer(225)
	SetSellAmount:FireServer(25)

	repeat
		AttemptButtonActivation(ChestButton, ChestButton.MouseButton1Down, 0, 0)
		task.wait()
		AttemptButtonActivation(BuyButton, BuyButton.MouseButton1Down, 0, 0)
		task.wait(3)
		OpenAll()
		task.wait(3)
		RBXGeneral:SendAsync(";delitems")
		AttemptButtonActivation(SellButton, SellButton.MouseButton1Down, 0, 0)
		task.wait()

		Shard = Backpack:FindFirstChild("NightmareShard")
		if Shard then
			ButtonSelections:WaitForChild("Destroys"):FireServer()
			Character:WaitForChild("Camera"):WaitForChild("Destroyeds"):FireServer()
			return Shard
		end

		task.wait(1.5)
	until Shard
	return Shard
end

shared.MainAutoLoop = coroutine.create(function()
	while true do
		local Nightmare = BossMap:FindFirstChild("Nightmare")
		if not Nightmare then
			local Shard = GetShard()
			if not Shard then
				return
			end
			Shard.Parent = Character
			Shard:Activate()

			Nightmare = BossMap:WaitForChild("Nightmare", 5)
			if not Nightmare then
				continue
			end
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
					if not ChestPrompt or not ChestPrompt.Parent or not Handle or not Handle.Parent then
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
			if not Chest then
				continue
			end
			if not Chest:IsA("Model") and not Chest:IsA("BasePart") then
				continue
			end
			local Handle = (Chest:IsA("Model") and (Chest.PrimaryPart or Chest:FindFirstChild("Handle")))
				or (Chest:IsA("BasePart") and Chest)
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
				if not ChestPrompt 
					or not ChestPrompt.Parent 
					or not Handle 
					or not Handle.Parent 
				then
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
coroutine.resume(shared.MainAutoLoop)
