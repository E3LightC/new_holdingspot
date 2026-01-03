local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

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

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AxeRemote = Remotes:WaitForChild("Axe")

local LocalPlayer = Players.LocalPlayer

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
	print("killing", Enemy.Name)
end

shared.Loop = coroutine.create(function()
	while true do 
		task.spawn(KillEnemy, nil, Workspace)
		task.spawn(KillEnemy, nil, Workspace)
		task.wait(0.25)

		local Portal = Workspace:FindFirstChild("Portal")
		if Portal and (Portal.Transparency == 0) then
			print("Teleporting to holding place main")
			TeleportService:Teleport(79147397944745)
			break
		end
	end
end)
coroutine.resume(shared.Loop)
