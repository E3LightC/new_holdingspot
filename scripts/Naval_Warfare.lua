-- @_x4yz
-- press L to change the target type (Planes or Players).

-- works with AA guns on battleships, islands, carriers.
-- also works with the "Large Bomber" plane.

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RStorage = game:GetService("ReplicatedStorage")
local PlayerInput = game:GetService("UserInputService")

_G.EnableDebug = false

if ShootAtType == nil then 
	getgenv().ShootAtType = "Planes"
end
if _G.TypeChanger then 
	_G.TypeChanger:Disconnect()
end

_G.TypeChanger = PlayerInput.InputBegan:Connect(function(Key, Process)
	if Key.KeyCode == Enum.KeyCode.L and not Process then 		
		if ShootAtType == "Planes" then 
			ShootAtType = "Players"
		elseif ShootAtType == "Players" then 
			ShootAtType = "Planes"
		end
		print("[TARGET SELECTION TYPE]: "..ShootAtType)
	end
end)

local GameEvent = RStorage:WaitForChild("Event")

local function FetchClosest()
	if Player.Character and Player.Character.PrimaryPart then
		local PlayerTeam = tostring(Player.Team.Name)
		
		if ShootAtType == "Planes" then 
			local ClosestPlane --Instance
			local Magnitude = math.huge
			for _, v in pairs(workspace:GetChildren()) do 
				if v.Name == "Bomber" or v.Name == "Torpedo Bomber" or v.Name == "Large Bomber" and v:FindFirstChild("Seat") and Player.Character.PrimaryPart then
					local Plane = v
					local OwnerTeam = Plane:WaitForChild("Team", 2)
					
					if OwnerTeam ~= nil and OwnerTeam:IsA("StringValue") then
						if OwnerTeam.Value ~= PlayerTeam and Plane.Seat.Position.Y > -20 then 
							local Distance = (Vector3.new(Player.Character.PrimaryPart.Position.X, 10, Player.Character.PrimaryPart.Position.Z) - Vector3.new(Plane.Seat.Position.X, 10, Plane.Seat.Position.Z)).Magnitude
							if Distance < Magnitude then 
								Magnitude = Distance
								ClosestPlane = Plane
							end
						end
					end
				end
			end
			if ClosestPlane ~= nil then 
				return ClosestPlane:WaitForChild("MainBody", 2)
			elseif ClosestPlane == nil then 
				return false
			end
		elseif ShootAtType == "Players" then 
			local ClosestPlayer --Instance
			local Magnitude = math.huge
			for _, v in pairs(Players:GetPlayers()) do 
				if Player.Character and Player.Character.PrimaryPart and v.Character and v.Character.PrimaryPart then
					local Target = v
					local Char = Target.Character
					local OwnerTeam = tostring(Target.Team.Name)
					
					if OwnerTeam ~= nil then
						if OwnerTeam ~= PlayerTeam and Char.PrimaryPart.Position.Y > -250 then 
							local Distance = (Vector3.new(Player.Character.PrimaryPart.Position.X, 10, Player.Character.PrimaryPart.Position.Z) - Vector3.new(Char.PrimaryPart.Position.X, 10, Char.PrimaryPart.Position.Z)).Magnitude
							if Distance < Magnitude then 
								Magnitude = Distance
								ClosestPlayer = Char
							end
						end
					end
				end
			end
			if ClosestPlayer ~= nil then 
				return ClosestPlayer.PrimaryPart or ClosestPlayer:WaitForChild("Torso", 2)
			elseif ClosestPlayer == nil then 
				return false
			end
		end
	end
	return nil
end

_G.IsShooting = false
local MT = getrawmetatable(game)
local Old = MT.__namecall
setreadonly(MT, false)
MT.__namecall = newcclosure(function(Remote, ...) 
    local Args = {...}
    local Method = getnamecallmethod()
    if Remote.Name == "Event" and Method == "FireServer" then
        if Args[1] ~= nil and Args[1] == "shoot" and Args[2][1] ~= nil and typeof(Args[2][1]) == "boolean" and Args[2][1] == true then 
			_G.IsShooting = true
			print("[INFO]: Shooting.")
			coroutine.resume(coroutine.create(function()
				while _G.IsShooting == true do 
					local Closest = FetchClosest()
					if Closest == false or Closest == nil then
						GameEvent[Method](Remote, unpack(Args))
						print("[ERROR]: Failed, target not found.")
						task.wait(1)
					elseif Closest ~= nil then 
						if ShootAtType == "Planes" then 
							GameEvent[Method]( Remote, "aim", {[1] = Closest.Position + (Closest.Velocity * (Player:GetNetworkPing() / 100 * 23.2) ) } )
							if _G.EnableDebug then
								print("[DEBUG]: plane target")
							end
						elseif ShootAtType == "Players" then 
							GameEvent[Method]( Remote, "aim", {[1] = Closest.Position + (Closest.Velocity * (Player:GetNetworkPing() / 100 * 0.21) ) } )
							if _G.EnableDebug then
								print("[DEBUG]: player target")
							end
						end
						task.wait(0.1)
					end
				end
			end))
		elseif Args[1] ~= nil and Args[1] == "shoot" and Args[2][1] ~= nil and typeof(Args[2][1]) == "boolean" and Args[2][1] == false then
			_G.IsShooting = false		
			print("[INFO]: Stopped shooting.")
			return GameEvent[Method](Remote, "shoot", {[1] = false})
		elseif Args[1] ~= nil and Args[1] == "fire" then
			coroutine.resume(coroutine.create(function()
				local Missile
				local Connection 
				Connection = workspace.ChildAdded:Connect(function(Child)
					if Child.Name == "Missile" then 
						local Script = Child:WaitForChild("MissileScript", 2)
						
						if Script ~= nil then 
							local Owner = Script:FindFirstChild("Owner")
							
							if Owner and Owner:IsA("StringValue") and Owner.Value == tostring(Player.Name) then 
								Missile = Child
								Connection:Disconnect()
							end
						end
					end
				end)
				GameEvent[Method]( Remote, "fire" ) 
				
				local Count = 0
				repeat wait(1) Count += 1 until Missile ~= nil or Count == 5
				
				if Missile ~= nil then 
					print("[INFO]: Missile found.")
					local Closest = FetchClosest()
					if Closest ~= nil then 
						print("[INFO]: Found missile target.")
						repeat
							task.wait()
							Missile.CFrame = Closest.CFrame
							task.wait()
						until Missile == nil or Closest == nil or Closest.Parent == nil or Missile.Parent == nil
					end
				end
			end))
			return
		end
    end
    return Old(Remote, ...)
end)
setreadonly(MT, true)
