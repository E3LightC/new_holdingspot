--// @_x4yz
--// press L to change the target type (Planes or Players).

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

_G.ShootAtType = "Planes"
_G.IsShooting = false
if _G.TypeChanger then 
	_G.TypeChanger:Disconnect()
end

local GameEvent = ReplicatedStorage:WaitForChild("Event")
local OldNameCall = nil

local function FetchClosest():BasePart|boolean?
    local LocalPlayer_Character = LocalPlayer.Character
    local LocalPlayer_Team = LocalPlayer.Team
	if LocalPlayer_Character and LocalPlayer_Team and LocalPlayer_Character.PrimaryPart then
        local PrimaryPart:BasePart = LocalPlayer_Character.PrimaryPart
		local PlayerTeam:string = tostring(LocalPlayer_Team.Name)
		
		if (_G.ShootAtType == "Planes") then 
            local SeatToReturn:BasePart
			local Magnitude:number = math.huge

			for _, PlaneModel in pairs(Workspace:GetChildren()) do 
				if (PlaneModel.Name == "Bomber") or (PlaneModel.Name == "Torpedo Bomber") or (PlaneModel.Name == "Large Bomber") and PlaneModel:FindFirstChild("Seat") and PrimaryPart then
					local Plane:Model = PlaneModel
					local OwnerTeam = Plane:WaitForChild("Team", 2)
                    local Seat = Plane:WaitForChild("Seat", 2)
					
					if OwnerTeam and Seat and OwnerTeam:IsA("StringValue") then
						if (OwnerTeam.Value ~= PlayerTeam) and (Seat.Position.Y > -20) then 
							local Distance = (Vector3.new(PrimaryPart.Position.X, 10, PrimaryPart.Position.Z) - Vector3.new(Seat.Position.X, 10, Seat.Position.Z)).Magnitude
							if (Distance < Magnitude) then 
								Magnitude = Distance
                                SeatToReturn = Seat
							end
						end
					end
				end
			end

			if (typeof(SeatToReturn) == "Instance") and SeatToReturn:IsA("Seat") then 
				return SeatToReturn
			else
				return false
			end
		elseif _G.ShootAtType == "Players" then 
            local PartToReturn:BasePart
			local Magnitude:number = math.huge

			for _, v in pairs(Players:GetPlayers()) do 
                local OtherPlayer_Character = v.Character
                local OtherPlayer_Team = v.Team

				if LocalPlayer_Character and PrimaryPart and OtherPlayer_Character and OtherPlayer_Team and OtherPlayer_Character.PrimaryPart then
                    local OtherPlayer_PrimaryPart:BasePart = OtherPlayer_Character.PrimaryPart
					local OwnerTeam:string = tostring(OtherPlayer_Team.Name)
					
					if OwnerTeam and (OwnerTeam ~= PlayerTeam) and (OtherPlayer_PrimaryPart.Position.Y > -250) then 
						local Distance = (Vector3.new(PrimaryPart.Position.X, 10, PrimaryPart.Position.Z) - Vector3.new(OtherPlayer_PrimaryPart.Position.X, 10, OtherPlayer_PrimaryPart.Position.Z)).Magnitude
						if Distance < Magnitude then 
							Magnitude = Distance
                            PartToReturn = OtherPlayer_PrimaryPart
						end
					end
				end
			end

			if PartToReturn then 
				return PartToReturn
			else
				return false
			end
		end
	end

	return false
end

_G.TypeChanger = UserInputService.InputBegan:Connect(function(Key, Process)
	if (Key.KeyCode == Enum.KeyCode.L) and not Process then 		
		if (_G.ShootAtType == "Planes") then 
			_G.ShootAtType = "Players"
		elseif (_G.ShootAtType == "Players") then 
			_G.ShootAtType = "Planes"
		end
		print(`[TARGET SELECTION TYPE]: {_G.ShootAtType}`)
	end
end)

OldNameCall = hookmetamethod(game, "__namecall", function(Remote, ...)
	local Arguments:{any} = {...}
	local NamecallMethod:string = getnamecallmethod()

	if not checkcaller() then
        if NamecallMethod == "FireServer" then
            if (Arguments[1] == "shoot") or (Arguments[1] == "bomb") and (type(Arguments[2][1]) == "boolean") and Arguments[2][1] then
                _G.IsShooting = true
                print("[INFO]: Shooting.")

                coroutine.resume(coroutine.create(function()
                    while _G.IsShooting do 
                        local Closest:(BasePart | boolean?) = FetchClosest()

                        if (type(Closest) == "boolean") or not Closest then
                            GameEvent[NamecallMethod](Remote, unpack(Arguments))
                            --//print("[ERROR]: Failed, target not found.")
                            task.wait()
                        end

                        if (typeof(Closest) == "Instance") and Closest:IsA("BasePart") then 
                            if (_G.ShootAtType == "Planes") then 
                                GameEvent[NamecallMethod](Remote, 
                                    "aim",
                                    {
                                        [1] = ((Closest.Position + Vector3.new(0, 2, 0)) + (Closest.AssemblyLinearVelocity * ((LocalPlayer:GetNetworkPing() / 100) * 23.2)))
                                    }
                                )
                            elseif (_G.ShootAtType == "Players") then 
                                GameEvent[NamecallMethod](Remote, 
                                    "aim",
                                    {
                                        [1] = (Closest.Position + (Closest.AssemblyLinearVelocity * ((LocalPlayer:GetNetworkPing() / 100) * 0.21)))
                                    }
                                )
                            end

                            task.wait()
                        end
                    end
                end))
            elseif (Arguments[1] == "shoot") or (Arguments[1] == "bomb") and (type(Arguments[2][1]) == "boolean") and not Arguments[2][1] then
                _G.IsShooting = false		
                print("[INFO]: Stopped shooting.")

                return GameEvent[NamecallMethod](Remote, "shoot", {[1] = false})
            elseif (Arguments[1] == "fire") then
                coroutine.resume(coroutine.create(function()
                    local Missile:Instance
                    local Connection:RBXScriptConnection
                    Connection = workspace.ChildAdded:Connect(function(Child)
                        if Child.Name == "Missile" then 
                            local Script = Child:WaitForChild("MissileScript", 2)
                            
                            if Script ~= nil then 
                                local Owner = Script:FindFirstChild("Owner")
                                
                                if Owner and Owner:IsA("StringValue") and (Owner.Value == tostring(LocalPlayer.Name)) then 
                                    Missile = Child
                                    Connection:Disconnect()
                                end
                            end
                        end
                    end)
                    GameEvent[NamecallMethod](Remote, "fire") 
                    
                    local Count = 0
                    repeat 
                        task.wait(1)
                        Count += 1
                    until (typeof(Missile) == "Instance") or (Count >= 3)
                    
                    if (typeof(Missile) == "Instance") then 
                        print("[INFO]: Missile found.")
                        local Closest = FetchClosest()
                        
                        if (typeof(Closest) == "Instance") then 
                            print("[INFO]: Found missile target.")
                            repeat
                                task.wait()
                                Missile.CFrame = Closest.CFrame
                            until not Missile or not Closest or not Closest.Parent or not Missile.Parent
                        else
                            print("[INFO]: Didn't find missile target.")
                        end
                    end
                end))

                return
            end
        end
	end

	return OldNameCall(Remote, ...)
end)
