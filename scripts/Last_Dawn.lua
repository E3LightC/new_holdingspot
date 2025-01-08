--// @_x4yz
--// outdated

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Backpack:Backpack = Player.Backpack
local UserInputService = game:GetService("UserInputService")

local ActiveZombies = workspace:FindFirstChild("ActiveZombies") or workspace:WaitForChild("ActiveZombies", math.huge)

if _G["__KillBind"] ~= nil then 
    _G["__KillBind"]:Disconnect()
    _G["__KillBind"] = nil
end
if _G["__BuildBind"] ~= nil then 
    _G["__BuildBind"]:Disconnect()
    _G["__BuildBind"] = nil
end

local AllowedWeapons = {
    ["Saber"] = "ffffff";
    ["Officer's Sabre"] = "ffffff";
    ["Axe"] = "ffffff";
}

local BuildFormationDistanceFront = -8
local BuildFormationDistanceBack = 8
local BuildFormations = {
    --// Short Wall Front
    [1] = {
        CFrame.new(-14, 0, BuildFormationDistanceFront);
        CFrame.new(-7, 0, BuildFormationDistanceFront);
        CFrame.new(0, 0, BuildFormationDistanceFront);
        CFrame.new(7, 0, BuildFormationDistanceFront);
        CFrame.new(14, 0, BuildFormationDistanceFront);
    };

    --// Tall Wall Front
    [2] = {
        CFrame.new(-14, 0, BuildFormationDistanceFront);
        CFrame.new(-7, 0, BuildFormationDistanceFront);
        CFrame.new(0, 0, BuildFormationDistanceFront);
        CFrame.new(7, 0, BuildFormationDistanceFront);
        CFrame.new(14, 0, BuildFormationDistanceFront);

        CFrame.new(-14, 3.3, BuildFormationDistanceFront);
        CFrame.new(-7, 3.3, BuildFormationDistanceFront);
        CFrame.new(0, 3.3, BuildFormationDistanceFront);
        CFrame.new(7, 3.3, BuildFormationDistanceFront);
        CFrame.new(14, 3.3, BuildFormationDistanceFront);
    };

    --// Short Wall Back
    [3] = {
        [1] = CFrame.new(-14, 0, BuildFormationDistanceBack);
        [2] = CFrame.new(-7, 0, BuildFormationDistanceBack);
        [3] = CFrame.new(0, 0, BuildFormationDistanceBack);
        [4] = CFrame.new(7, 0, BuildFormationDistanceBack);
        [5] = CFrame.new(14, 0, BuildFormationDistanceBack);
    };

    --// Tall Wall Back
    [4] = {
        CFrame.new(-14, 0, BuildFormationDistanceBack);
        CFrame.new(-7, 0, BuildFormationDistanceBack);
        CFrame.new(0, 0, BuildFormationDistanceBack);
        CFrame.new(7, 0, BuildFormationDistanceBack);
        CFrame.new(14, 0, BuildFormationDistanceBack);

        CFrame.new(-14, 3.3, BuildFormationDistanceBack);
        CFrame.new(-7, 3.3, BuildFormationDistanceBack);
        CFrame.new(0, 3.3, BuildFormationDistanceBack);
        CFrame.new(7, 3.3, BuildFormationDistanceBack);
        CFrame.new(14, 3.3, BuildFormationDistanceBack);
    };

    --// Rounded Wall Front
    [5] = {
        [1] = CFrame.new(-11, 0, (BuildFormationDistanceFront + 9)) * CFrame.Angles(0, math.rad(65), 0);
        [2] = CFrame.new(-7, 0, (BuildFormationDistanceFront + 3)) * CFrame.Angles(0, math.rad(32.5), 0);
        [3] = CFrame.new(0, 0, BuildFormationDistanceFront) * CFrame.Angles(0, 0, 0);
        [4] = CFrame.new(7, 0, (BuildFormationDistanceFront + 3)) * CFrame.Angles(0, math.rad(-32.5), 0);
        [5] = CFrame.new(11, 0, (BuildFormationDistanceFront + 9)) * CFrame.Angles(0, math.rad(-65), 0);
    };
}
local BuildRotations = {
    ["Barricade"] = CFrame.Angles(0, math.rad(0), 0);
    ["Stakes"] = CFrame.Angles(0, math.rad(180), 0);
    ["Crate"] = CFrame.Angles(0, math.rad(90), 0);
}

local SelectedFormation = 5
local SelectedStructure = "Crate"

local KillKey = Enum.KeyCode.Q
local BuildKey = Enum.KeyCode.E
local SwitchStructureKey = Enum.KeyCode.N
local SwitchFormationKey = Enum.KeyCode.M

local PackString:typeof(string.pack) = string.pack
local UnpackTable:typeof(table.unpack) = table.unpack

local function GetWeapon()
    local Character = Player.Character

    if Character then 
        if Character:FindFirstChildWhichIsA("Tool") then 
            for _, v in pairs(Character:GetChildren()) do 
                if typeof(v) == "Instance" and v:IsA("Tool") and typeof(AllowedWeapons[v.Name]) == "string" then
                    return true, v, tostring(AllowedWeapons[v.Name])
                end
            end
        end

        if Backpack:FindFirstChildWhichIsA("Tool") then 
            for _, v in pairs(Backpack:GetChildren()) do 
                if typeof(v) == "Instance" and v:IsA("Tool") and typeof(AllowedWeapons[v.Name]) == "string" then
                    return true, v, tostring(AllowedWeapons[v.Name])
                end
            end
        end
    elseif not Character then
        warn("[FAIL # GetWeapon]: The player's character doesn't exist?")

        return false
    end

    return false
end

local function PackData(DataToPack:{}, FormatString:string): (boolean, string)
    if typeof(DataToPack) == "table" and typeof(FormatString) == "string" then 
        return true, PackString(FormatString, UnpackTable(DataToPack))
    else
        if typeof(DataToPack) ~= "table" then
            warn("[FAIL # PackData]: \"BasePart\" is not a table?")

            return false, ""
        end
        if typeof(FormatString) ~= "string" then
            warn("[FAIL # PackData]: \"FormatString\" is not a string?")

            return false, ""
        end
    end

    return false, ""
end

local function SortFunc(Table:{[any]: any}, Func:typeof(function(...) end))
	if Table ~= nil and Func ~= nil then 
		if typeof(Table) ~= "table" then 
			warn("[FAIL # SortFunc]: \"Table\" is not a table.")

			return
		end

		if typeof(Func) ~= "function" then 
			warn("[FAIL # SortFunc]: \"Func\" is not a function.")

			return
		end

		for i, v in pairs(Table) do
            task.spawn(Func, i, v)
		end
    else
        if Table == nil then 
            warn("[FAIL # SortFunc]: \"Table\" is equal to nil.")

            return
        end
        if Func == nil then 
            warn("[FAIL # SortFunc]: \"Func\" is equal to nil.")

            return
        end
	end

	return
end

_G["__KillBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if Key.KeyCode == KillKey and not Process then 
        local FoundWeapon:boolean, Weapon:Tool, FormatStringToUse:string = GetWeapon()

        if FoundWeapon and typeof(Weapon) == "Instance" and Weapon:IsA("Tool") then 
            local Events = Weapon:FindFirstChild("Events")

            if Events and Events:FindFirstChild("BlockInvoke") then
                local BlockInvoke = Events:FindFirstChild("BlockInvoke")

                SortFunc(ActiveZombies:GetChildren(), function(Key, ZombieModel)
                    if typeof(ZombieModel) == "Instance" and ZombieModel:IsA("Model") then 
                        local Humanoid = ZombieModel:FindFirstChildWhichIsA("Humanoid")
                        local PrimaryPart = ZombieModel.PrimaryPart or ZombieModel:FindFirstChild("HumanoidRootPart") or ZombieModel:FindFirstChild("Head")

                        if Humanoid and Humanoid.Health > 0 and PrimaryPart and PrimaryPart:IsA("BasePart") then 
                            local PrimaryPartPosition = PrimaryPart.Position or Vector3.new()
                            local Success:boolean, PackedData:string = PackData({
                                [1] = PrimaryPartPosition.X;
                                [2] = PrimaryPartPosition.Y;
                                [3] = PrimaryPartPosition.Z;
                                [4] = 0;
                                [5] = 3;
                                [6] = 0;
                                [7] = 25;
                            }, FormatStringToUse)

                            --print(Success, PackedData)

                            if Success and typeof(PackedData) == "string" and #PackedData > 0 then 
                                task.spawn(function()
                                    BlockInvoke:InvokeServer(FormatStringToUse, PackedData, Humanoid)
                                end)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

_G["__BuildBind"] = UserInputService.InputBegan:Connect(function(Key, Process)
    if Key.KeyCode == BuildKey and not Process then 
        local Character = Player.Character

        if Character and Character.PrimaryPart then 
            local PrimaryPart = Character.PrimaryPart
            local MainCFrame = PrimaryPart.CFrame
            local Hammer = Character:FindFirstChild("Hammer") or Backpack:FindFirstChild("Hammer")
            
            if Hammer and Hammer:IsA("Tool") and typeof(SelectedFormation) == "number" then
                local Remotes = Hammer:FindFirstChild("Remotes")

                if Remotes and Remotes:FindFirstChild("Place") and Remotes:FindFirstChild("Build") then 
                    local Place:RemoteEvent = Remotes:FindFirstChild("Place")
                    local Build:RemoteEvent = Remotes:FindFirstChild("Build")

                    for _, Offset in pairs(BuildFormations[SelectedFormation]) do
                        if typeof(Offset) == "CFrame" then 
                            local Rotation:CFrame = BuildRotations[SelectedStructure] or CFrame.Angles(0, 0, 0)

                            Place:FireServer( 
                                ((MainCFrame * Offset) * Rotation),
                                SelectedStructure
                            )

                            local BuildFound
                            local Connection 
                            Connection = workspace.ChildAdded:Connect(function(NewChild)
                                if NewChild.Name == SelectedStructure then 
                                    BuildFound = NewChild
                                    Connection:Disconnect()
                                end
                            end)

                            repeat
                                task.wait()
                            until BuildFound ~= nil

                            for Loop = 1, 9 do 
                                Build:FireServer(BuildFound)

                                task.wait(0.05)
                            end
                        end

                        task.wait()
                    end
                end
            end
        end
    elseif Key.KeyCode == SwitchStructureKey and not Process then 
        if SelectedStructure == "Barricade" then 
            SelectedStructure = "Stakes"
        elseif SelectedStructure == "Stakes" then 
            SelectedStructure = "Crate"
        elseif SelectedStructure == "Crate" then 
            SelectedStructure = "Barricade"
        end

        print("[INFO # __BuildBind]: SelectedStructure = "..tostring(SelectedStructure)..".")
    elseif Key.KeyCode == SwitchFormationKey and not Process then 
        local MaxFormations = #BuildFormations
        
        if SelectedFormation < MaxFormations then 
            SelectedFormation += 1
        elseif SelectedFormation >= MaxFormations then 
            SelectedFormation = 1
        end

        print("[INFO # __BuildBind]: SelectedFormation = "..tostring(SelectedFormation)..".")
    end
end)
