--// @_x4yz
--// https://www.roblox.com/games/443406476/Project-Lazarus-ZOMBIES

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Baddies = Workspace:WaitForChild("Baddies")
local UpdateDamageKey = ReplicatedStorage:WaitForChild("UpdateDamageKey")

local NaN = (0/0)
local PointCooldownTime = 0.025
local MaxWaitedTimePerZomb = 0.03

local Flags = {
    "AC Tamper",
    "MemCheck",
    "ZombieBox",
    "ESP",
    "W1",
    "W2",
    "W3"
}

if getgenv()["__MainInputBegin"] then
    getgenv()["__MainInputBegin"]:Disconnect()
    getgenv()["__MainInputBegin"] = nil
end
if getgenv()["__MainInputEnd"] then
    getgenv()["__MainInputEnd"]:Disconnect()
    getgenv()["__MainInputEnd"] = nil
end
if getgenv()["__WorkspaceDescendantAdded"] then
    getgenv()["__WorkspaceDescendantAdded"]:Disconnect()
    getgenv()["__WorkspaceDescendantAdded"] = nil
end
if not getgenv().MysteryBoxHighlight then
    getgenv().MysteryBoxHighlight = Instance.new("BoxHandleAdornment")
    getgenv().MysteryBoxHighlight.Name = "__MysteryBoxHighlight"
    getgenv().MysteryBoxHighlight.Adornee = PrimaryPart
    getgenv().MysteryBoxHighlight.AlwaysOnTop = true
    getgenv().MysteryBoxHighlight.ZIndex = 8
    getgenv().MysteryBoxHighlight.Transparency = 0.6
end
if not getgenv().MysteryBoxBillboard then
    getgenv().MysteryBoxBillboard = Instance.new("BillboardGui")
    getgenv().MysteryBoxBillboard.Name = "__EspLabel"
    getgenv().MysteryBoxBillboard.Adornee = PrimaryPart
    getgenv().MysteryBoxBillboard.Size = UDim2.new(0, 100, 0, 40)
    getgenv().MysteryBoxBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
    getgenv().MysteryBoxBillboard.AlwaysOnTop = true

    getgenv().MysteryBoxLabel = Instance.new("TextLabel")
    getgenv().MysteryBoxLabel.Size = UDim2.new(1, 0, 1, 0)
    getgenv().MysteryBoxLabel.BackgroundTransparency = 1
    getgenv().MysteryBoxLabel.Text = "Mystery Box"
    getgenv().MysteryBoxLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
    getgenv().MysteryBoxLabel.TextStrokeTransparency = 0.5
    getgenv().MysteryBoxLabel.TextScaled = true
    getgenv().MysteryBoxLabel.Font = Enum.Font.SourceSansBold
end
getgenv().IsLoopKillEnabled = false
getgenv().PointCooldown = false
getgenv().PointBegin = false

hookfunction(gcinfo, function()
	return math.random(1550, 1650)
end)

if (type(getgenv()["DamageKey"] ) ~= "number") then
    getgenv()["DamageKey"]  = -1

    local OldNameCall
    OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
        local Parameters = {...}
        local Method = getnamecallmethod()

        if not checkcaller() and (typeof(Self) == "Instance") then
            if (Method == "InvokeServer") then
                if (Self.Name == "UpdateDamageKey") and (type(Parameters[1]) == "number") then
                    getgenv()["DamageKey"] = Parameters[1]
                end
            elseif (Method == "FireServer") then
                if (Self.Name == "Damage") then
                    local DamageData = Parameters[1]
                    local DamageKeyFromLocal = Parameters[2]

                    if (type(DamageData) == "table") and DamageData["Damage"] and (type(DamageKeyFromLocal) == "number") then
                        getgenv()["DamageKey"] = DamageKeyFromLocal

                        local DamageMultiplier = getgenv()["DamageMulti"]
                        DamageData["Damage"] = ((type(DamageMultiplier) == "number") and (DamageData["Damage"] * DamageMultiplier)) or DamageData["Damage"]

                        Self["FireServer"](Self, DamageData, getgenv()["DamageKey"])
                        return nil
                    end
                elseif (Self.Name == "SendData") then
                    if table.find(Flags, tostring(Parameters[1])) then
                        return nil
                    end
                end 
            end
        end

        return OldNameCall(Self, ...) 
    end)
end

local function AttemptToDamage(DamageRemote:RemoteEvent, BodyPart:BasePart, WeaponName:string?, Damage:number?, TimesToFire:number?, UseCustomParams:boolean?, CustomParams:{}?)
    if (typeof(DamageRemote) ~= "Instance") or not (DamageRemote.Name == "Damage") then
        return
    end
    
    if UseCustomParams then
        if (type(CustomParams) ~= "table") then
            return
        end

        if (type(TimesToFire) == "number") and (TimesToFire == TimesToFire) and (math.abs(TimesToFire) ~= math.huge) then
            for _ = 1, TimesToFire do 
                DamageRemote:FireServer(unpack(CustomParams))
            end

            return
        end
        
        DamageRemote:FireServer(unpack(CustomParams))
        return
    end

    if (type(getgenv()["DamageKey"] ) ~= "number") or (getgenv()["DamageKey"]  == -1) then
        return
    end
    if (typeof(BodyPart) ~= "Instance") or not BodyPart:IsA("BasePart") then
        return
    end
    
    local DamageData = {
        Damage = ((type(Damage) == "number" and Damage) or 0);
        WeaponName = ((type(WeaponName) == "string" and WeaponName) or "Knife");
        Force = 0;
        GibPower = 0;
        BodyPart = BodyPart;
    }

    if (type(TimesToFire) == "number") and (TimesToFire == TimesToFire) and (math.abs(TimesToFire) ~= math.huge) then
        for _ = 1, TimesToFire do 
            if not DamageRemote or not DamageRemote.Parent then
                break
            end
            DamageRemote:FireServer(DamageData, getgenv()["DamageKey"])
        end
        
        return
    end

    DamageRemote:FireServer(DamageData, getgenv()["DamageKey"])
end

local BindFunctions = {
    [Enum.KeyCode.KeypadOne] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end
        getgenv().IsLoopKillEnabled = not getgenv().IsLoopKillEnabled

        if getgenv().IsLoopKillEnabled then
            local NewRandom = Random.new()
            repeat
                local ZombChildren = Baddies:GetChildren()
                if (#ZombChildren == 0) then
                    repeat
                        ZombChildren = Baddies:GetChildren()
                        task.wait()
                    until (#ZombChildren ~= 0)
                end

                local Zombie = ZombChildren[NewRandom:NextInteger(1, #ZombChildren)]
                local LocalPlayer_Character = LocalPlayer.Character

                if Zombie and LocalPlayer_Character then
                    local WeaponModel = LocalPlayer_Character:FindFirstChild("WeaponModel")
                    local WeaponName = (WeaponModel and WeaponModel:IsA("Model") and WeaponModel:GetAttribute("WeaponName"))

                    local BodyPart = Zombie:FindFirstChild("HeadBox") or Zombie.PrimaryPart
                    local Humanoid = Zombie:FindFirstChildWhichIsA("Humanoid")
                    local DamageRemote = Humanoid and Humanoid:FindFirstChild("Damage")

                    if DamageRemote and BodyPart then
                        if not getgenv().IsLoopKillEnabled then
                            break
                        end
                        task.spawn(AttemptToDamage, DamageRemote, BodyPart, WeaponName, NaN)

                        local WaitedTime = 0
                        repeat
                            WaitedTime += task.wait()
                        until (WaitedTime >= MaxWaitedTimePerZomb) or (Zombie.Parent ~= Baddies) or not getgenv().IsLoopKillEnabled
                    end
                end

                if not getgenv().IsLoopKillEnabled then
                    break
                end
                task.wait()
            until not getgenv().IsLoopKillEnabled
        end
    end);
    [Enum.KeyCode.Z] = (function(Status:string)
		if (Status == "Begin") then
			getgenv().PointBegin = true
			repeat
				if getgenv().PointCooldown then
					task.wait()
					continue
				end
				getgenv().PointCooldown = true

				local Zombie = Baddies:FindFirstChild("Zombie")
				local LocalPlayer_Character = LocalPlayer.Character

				if Zombie and LocalPlayer_Character then
					local WeaponModel = LocalPlayer_Character:FindFirstChild("WeaponModel")
					local WeaponName = (WeaponModel and WeaponModel:IsA("Model") and WeaponModel:GetAttribute("WeaponName"))

					local BodyPart = Zombie:FindFirstChild("HeadBox") or Zombie.PrimaryPart
					local Humanoid = Zombie:FindFirstChildWhichIsA("Humanoid")
					local DamageRemote = Humanoid and Humanoid:FindFirstChild("Damage")

					if DamageRemote and BodyPart then
						task.spawn(AttemptToDamage, DamageRemote, BodyPart, WeaponName, nil, 5)
					end
				end

				task.wait(PointCooldownTime)
				getgenv().PointCooldown = false
			until not getgenv().PointBegin
		elseif (Status == "End") then
			getgenv().PointBegin = false
		end
    end);
    [Enum.KeyCode.E] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

        local MouseTarget = Mouse.Target
        local Zombie = MouseTarget and MouseTarget.Parent and MouseTarget:FindFirstAncestor("Zombie")
        if not Zombie then
            return
        end
        local LocalPlayer_Character = LocalPlayer.Character

        if Zombie and LocalPlayer_Character then
            local WeaponModel = LocalPlayer_Character:FindFirstChild("WeaponModel")
            local WeaponName = (WeaponModel and WeaponModel:IsA("Model") and WeaponModel:GetAttribute("WeaponName"))

            local BodyPart = Zombie:FindFirstChild("HeadBox") or Zombie.PrimaryPart
            local Humanoid = Zombie:FindFirstChildWhichIsA("Humanoid")
            local DamageRemote = Humanoid and Humanoid:FindFirstChild("Damage")

            if DamageRemote and BodyPart then
                task.spawn(AttemptToDamage, DamageRemote, BodyPart, WeaponName, NaN)
            end
        end
    end);
    [Enum.KeyCode.T] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

		local LocalPlayer_Character = LocalPlayer.Character
		if not LocalPlayer_Character then
			return
		end
		local ServerScript = LocalPlayer_Character:FindFirstChild("ServerScript")
		if not ServerScript then
			return
		end
		local WeaponImpact = ServerScript:FindFirstChild("WeaponImpact")
		if not WeaponImpact or not WeaponImpact:IsA("RemoteEvent") then
			return
		end

        local MouseHitPosition = Mouse.Hit.Position
		local Params = {
			"Absolute Zero",
			MouseHitPosition
		}
		
		for _ = 1, 3 do 
			WeaponImpact:FireServer(unpack(Params))
		end
    end);
    [Enum.KeyCode.KeypadTwo] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

		local CurrentlyEquipped = getrenv()["_G"]["Equipped"]

		if (type(CurrentlyEquipped) == "table") then
			if (type(CurrentlyEquipped["Ammo"]) == "number") and (type(CurrentlyEquipped["MaxAmmo"]) == "number") and (type(CurrentlyEquipped["MagSize"]) == "number") then
				CurrentlyEquipped["MagSize"] = math.huge
				CurrentlyEquipped["Ammo"] = math.huge
				CurrentlyEquipped["MaxAmmo"] = math.huge
			end

			if (type(CurrentlyEquipped["FireTime"]) == "number") then
				CurrentlyEquipped["FireTime"] = 0.025
			end
			
			if (type(CurrentlyEquipped["Spread"]) == "table") then
				CurrentlyEquipped["Spread"]["Min"] = 0
				CurrentlyEquipped["Spread"]["Max"] = 0
			end

			if (type(CurrentlyEquipped["ViewKick"]) == "table") and (type(CurrentlyEquipped["ViewKick"]["Yaw"]) == "table") and (type(CurrentlyEquipped["ViewKick"]["Pitch"]) == "table") then
				CurrentlyEquipped["ViewKick"]["Yaw"]["Min"] = 0
				CurrentlyEquipped["ViewKick"]["Yaw"]["Max"] = 0
				CurrentlyEquipped["ViewKick"]["Pitch"]["Min"] = 0
				CurrentlyEquipped["ViewKick"]["Pitch"]["Max"] = 0
			end
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
getgenv()["__WorkspaceDescendantAdded"] = Workspace.DescendantAdded:Connect(function(Model)
    if Model and Model:IsA("Model") and (Model.Name == "MysteryBox") then
        repeat
            task.wait()
        until not Model or Model.PrimaryPart

        local PrimaryPart = Model and Model.PrimaryPart
        if PrimaryPart then
            getgenv().MysteryBoxHighlight.Parent = Model
            getgenv().MysteryBoxHighlight.Adornee = Model
            getgenv().MysteryBoxHighlight.Size = Vector3.new(8.4, 5.5, 5.2)
            getgenv().MysteryBoxHighlight.Color3 = Color3.fromRGB(255, 165, 0)

            getgenv().MysteryBoxBillboard.Parent = PrimaryPart
            getgenv().MysteryBoxLabel.Parent = getgenv().MysteryBoxBillboard

            Model:GetPropertyChangedSignal("Parent"):Connect(function()
                getgenv().MysteryBoxHighlight.Parent = nil
                getgenv().MysteryBoxBillboard.Parent = nil
                getgenv().MysteryBoxLabel.Parent = nil
            end)
        end
    end
end)
for _, Model in pairs(Workspace:GetDescendants()) do 
    if Model and Model:IsA("Model") and (Model.Name == "MysteryBox") then
        repeat
            task.wait()
        until not Model or Model.PrimaryPart

        local PrimaryPart = Model and Model.PrimaryPart
        if PrimaryPart then
            getgenv().MysteryBoxHighlight.Parent = Model
            getgenv().MysteryBoxHighlight.Adornee = Model
            getgenv().MysteryBoxHighlight.Size = Vector3.new(8.4, 5.5, 5.2)
            getgenv().MysteryBoxHighlight.Color3 = Color3.fromRGB(255, 165, 0)

            getgenv().MysteryBoxBillboard.Parent = PrimaryPart
            getgenv().MysteryBoxLabel.Parent = getgenv().MysteryBoxBillboard

            Model:GetPropertyChangedSignal("Parent"):Connect(function()
                getgenv().MysteryBoxHighlight.Parent = nil
                getgenv().MysteryBoxBillboard.Parent = nil
                getgenv().MysteryBoxLabel.Parent = nil
            end)
        end

        break
    end
end
