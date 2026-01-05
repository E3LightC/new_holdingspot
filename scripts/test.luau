local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/E3LightC/new_holdingspot/refs/heads/main/scripts/test.luau'))()")
if (game.PlaceId == 79147397944745) then
	print("Teleport to nullverse")
	TeleportService:Teleport(72294458653015)
	return
else
	local Portal = Workspace:FindFirstChild("Portal")
	if Portal and (Portal.Transparency == 0) then
		print("teleport to holding place")
		TeleportService:Teleport(79147397944745)
		return
	end
end

local Chests = Workspace:WaitForChild("chests")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AxeRemote = Remotes:WaitForChild("Axe")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack

if shared.Loop then
	coroutine.close(shared.Loop)
	shared.Loop = nil
end

local function GetEnemy(
	EnemyLocation:Instance?
):(Model?, Humanoid?)
	local MapFolder = Workspace:FindFirstChild("Map")
	local Table = (EnemyLocation and EnemyLocation:GetChildren()) or Workspace:GetDescendants()

	for _, NPC:Model? in pairs(Table) do 
		if not NPC then
			continue
		end
		if MapFolder and NPC:IsDescendantOf(MapFolder) then
			continue
		end
		if not NPC:IsA("Model") then
			continue
		end

		local Humanoid = NPC:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid or (Humanoid.Health <= 0) or (math.abs(Humanoid.Health) == math.huge) then
			task.wait()
			continue
		end
		if Humanoid:FindFirstChildWhichIsA("ForceField") then
			task.wait()
			continue
		end
		if Players:GetPlayerFromCharacter(NPC) then
			task.wait()
			continue
		end

		return NPC, Humanoid
	end
end

local function KillEnemy(
	EnemyParam:Model?,
	EnemyLocation:Instance?
):(boolean)
	local Enemy:Model?, Humanoid:Humanoid?|true? = nil, nil
	if not EnemyParam then
		Enemy, Humanoid = GetEnemy(EnemyLocation)
	elseif EnemyParam then
		Enemy = EnemyParam
		Humanoid = true
	end
	
	if not Enemy or not Humanoid then
		return false
	end

	AxeRemote:FireServer({
		hb = {Enemy};
		action = "hit";
		combo = 1;
		c = LocalPlayer.Character;
		damage = (((type(Humanoid) == "Instance") and Humanoid:IsA("Humanoid")) 
			and (Humanoid.MaxHealth + 10000)
		) or math.huge
	})
end

shared.PlayerJoined = Players.PlayerAdded:Connect(function(NewPlayer)
	if (LocalPlayer == NewPlayer) then
		return
	end

	local Character = NewPlayer.Character or NewPlayer.CharacterAdded:Wait()
	if Character then
		task.spawn(KillEnemy, Character, nil)

		repeat
			Character = NewPlayer.Character or NewPlayer.CharacterAdded:Wait()
			if Character.Parent then
				task.spawn(KillEnemy, Character, nil)
			end
			task.wait(0.1)
		until not NewPlayer
	end
end)

shared.Loop = coroutine.create(function()
	while true do 
		task.spawn(KillEnemy, nil, Workspace)
		task.spawn(KillEnemy, nil, Workspace)
		task.wait(0.1)

		local Portal = Workspace:FindFirstChild("Portal")
		if Portal and (Portal.Transparency == 0) then
			local Character = LocalPlayer.Character
			local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

			for _, Chest in pairs(Chests:GetChildren()) do 
				if not Chest or Chest:IsA("Tool") then
					continue
				end
				local Prompt = Chest and Chest:FindFirstChild("ProximityPrompt")
				if not Prompt then
					continue
				end

				PrimaryPart.CFrame = CFrame.new(Chest.Position)
				task.wait(0.1)
				replicatesignal(Prompt.TriggeredActionReplicated, LocalPlayer)
			end

			for _, Tool in pairs(Backpack:GetChildren()) do 
				if not Tool or not Tool:IsA("Tool") then
					continue
				end
				Tool.Parent = Character
				Tool:Activate()
				
				task.wait()
			end

			task.wait(6)

			print("Teleporting to holding place main")
			TeleportService:Teleport(79147397944745)
			break
		end
	end
end)
coroutine.resume(shared.Loop)
