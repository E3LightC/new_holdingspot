local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local getgenv = getfenv().getgenv or (function()
	return _G
end)
local StringPack:(
    Format:string,
    ...any
) -> (string) = string.pack
local UnpackTable:(
	List:{any},
	FirstIndex:number?,
	LastIndex:number?
) -> (...any) = unpack
local MathAbs = math.abs
local EmptyVector:Vector3 = Vector3.zero

if getgenv()["__MainInputBegin"] then
    getgenv()["__MainInputBegin"]:Disconnect()
    getgenv()["__MainInputBegin"] = nil
end
if getgenv()["__MainInputEnd"] then
    getgenv()["__MainInputEnd"]:Disconnect()
    getgenv()["__MainInputEnd"] = nil
end
getgenv()["ProjectileDamageLoop"] = false
getgenv()["KillAuraActive"] = false

local function WaitForChildWhichIsA(
    Parent:Instance, 
    ClassName:string, 
    Name:string?, 
    TimeOut:number?
):(Instance|nil)
	if (typeof(Parent) == "Instance") and (type(ClassName) == "string") then
		local InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
		if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
			return InstanceToReturn
		end

		local UseTimeOut = (type(TimeOut) == "number")
		local EndedEarly:boolean = false
		local TimeOutWasReached:boolean = false

		if not UseTimeOut then
			repeat
				if not Parent or not Parent.Parent then
					EndedEarly = true
					break
				end
                InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end

                task.wait()
				InstanceToReturn = Parent and Parent:FindFirstChildWhichIsA(ClassName)
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end
			until ((typeof(InstanceToReturn) == "Instance") or EndedEarly or not Parent or not Parent.Parent)
		else
			local AbsTimeOut:number = MathAbs(TimeOut or 1)
			local StartTime:number = os.clock()

			repeat
				if ((os.clock() - StartTime) >= AbsTimeOut) then
					TimeOutWasReached = true
					EndedEarly = true
					break
				end
				if not Parent or not Parent.Parent then
					EndedEarly = true
					break
				end
                InstanceToReturn = Parent:FindFirstChildWhichIsA(ClassName)
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end

                task.wait()
				InstanceToReturn = Parent and Parent:FindFirstChildWhichIsA(ClassName)
				if (type(Name) == "string") and InstanceToReturn and (InstanceToReturn.Name == Name) or InstanceToReturn then
					return InstanceToReturn
				end
			until ((typeof(InstanceToReturn) == "Instance") or EndedEarly or (os.clock() - StartTime) >= AbsTimeOut)
		end

		if EndedEarly then
			local StringToOutput:string = ("[INFO # WaitForChildWhichIsA]: Loop was ended early due to %s")

			if UseTimeOut then
				if TimeOutWasReached then
					StringToOutput = StringToOutput:format("the time out being reached.")
				elseif not TimeOutWasReached then
					StringToOutput = StringToOutput:format(`the "Parent" property of the "Parent" parameter being invalid.`)
				end
			else
				StringToOutput = StringToOutput:format(`the "Parent" property of the "Parent" parameter being invalid.`)
			end

			print(StringToOutput)
		end

		return InstanceToReturn
	else
		if (typeof(Parent) ~= "Instance") then
			warn(`[FAIL # WaitForChildWhichIsA]: "Parent" parameter is not an Instance.  ||| Current script line: {debug.info(1, "l")}`)
			return nil
		end
		if (type(ClassName) ~= "string") then
			warn(`[FAIL # WaitForChildWhichIsA]: "ClassName" parameter is not a string.  ||| Current script line: {debug.info(1, "l")}`)
			return nil
		end
	end

	return nil
end

local LocalPlayer:Player = Players.LocalPlayer
local Backpack:Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))

local ActiveZombies:Folder = Workspace:FindFirstChild("ActiveZombies") or Workspace:WaitForChild("ActiveZombies", math.huge)

local ReplicatedEvents:Folder = ReplicatedStorage:WaitForChild("ReplicatedEvents")
local ProjectileDamage:RemoteEvent = ReplicatedEvents:WaitForChild("ProjectileDamage")

local KillAuraRange:number = 15

--[=[
    Description:
    Iterates over all key-value pairs in a given table and applies a provided function to each pair.
    The iteration can be performed either instantly by spawning new tasks for each call (asynchronous),
    or sequentially (synchronously), based on the optional `Instant` parameter.

    Parameters:
    - `Table: {[any]: any}`:
        - The table to iterate over.
        - Must be a valid Lua table; otherwise, the function warns and returns early.
    - `Function: function`:
        - The function to call for each key-value pair.
        - The function is invoked with two parameters: the key and the value.
        - The function must be valid; otherwise, it warns and returns early.
    - `Instant: boolean?` (optional):
        - Defaults to `true`.
        - If `true`, each call to `Function` is spawned as a separate task asynchronously using `task.spawn`.
        - If `false`, the function is called synchronously for each pair, blocking until each call completes.

    Behavior:
    - Validates inputs and reports issues with client subtitles and console warnings.
    - If `Instant` is `true`, uses `task.spawn` to run each function call concurrently, which can improve performance for independent operations.
    - If `Instant` is `false`, runs the function calls one-by-one in the main thread.

    Returns:
    - None (returns `nil` explicitly).

    Usage Example:
    ```lua
    local SampleTable = {a = 1, b = 2, c = 3}
    
    --// Synchronous iteration
    IterateWithFunction(SampleTable, function(Key, Value)
        print(Key, Value)
    end, false)
    
    --// Asynchronous iteration
    IterateWithFunction(SampleTable, function(Key, Value)
        print(Key, Value)
    end) --// Instant defaults to true
    ```

    Notes:
    - This function can be useful for running operations on many items concurrently to improve responsiveness.
    - Be cautious with side-effects or shared state when using asynchronous iteration.
    - Input validation helps prevent silent failures and aids debugging.
]=]
local function IterateWithFunction(
    Table:{[any]:any}, 
    Function:((any, any) -> (any)), 
    Instant:boolean?
):()
	if (type(Instant) ~= "boolean") then
		Instant = true
	end
	if (type(Table) ~= "table") then 
		warn(`[FAIL # IterateWithFunction]: "Table" is not a table.  ||| Current script line: {debug.info(1, "l")}`)
		return
	end
	if (type(Function) ~= "function") then 
		warn(`[FAIL # IterateWithFunction]: "Function" is not a function.  ||| Current script line: {debug.info(1, "l")}`)
		return
	end

	if Instant then 
		for Index:any, Key:any in pairs(Table) do
			task.spawn(Function, Index, Key)
		end
	else
		for Index:any, Key:any in pairs(Table) do
			Function(Index, Key)
		end
	end

	return
end

local function PackData(
    DataToPack:{any}, 
    FormatString:string
):(boolean, string)
    if (type(DataToPack) ~= "table") then
        warn(`[FAIL # PackData]: \"BasePart\" is not a table?  ||| Current script line: {debug.info(1, "l")}`)
        return false, ""
    end
    if (type(FormatString) ~= "string") then
        warn(`[FAIL # PackData]: \"FormatString\" is not a string?  ||| Current script line: {debug.info(1, "l")}`)
        return false, ""
    end

    return true, StringPack(FormatString, UnpackTable(DataToPack))
end

local function GetWeapon(
    CheckBackpack:boolean?
):(Tool|false?, RemoteFunction|false?)
    local Character:Model = LocalPlayer.Character
    Backpack = (LocalPlayer:FindFirstChildWhichIsA("Backpack") or WaitForChildWhichIsA(LocalPlayer, "Backpack"))

    if (type(CheckBackpack) ~= "boolean") then
        CheckBackpack = true
    end
    
    if Character then
        for _, Tool:Tool in pairs(Character:GetChildren()) do
            if not Tool or not Tool:IsA("Tool") then
                continue
            end
            local Events:Folder = Tool:FindFirstChild("Events")
            if not Events then
                continue
            end

            local BlockInvoke:RemoteFunction = Events:FindFirstChild("BlockInvoke")
            if not BlockInvoke then
                continue
            end

            return Tool, BlockInvoke
        end
    end

    if CheckBackpack then
        for _, Tool:Tool in pairs(Backpack:GetChildren()) do
            if not Tool or not Tool:IsA("Tool") then
                continue
            end
            local Events:Folder = Tool:FindFirstChild("Events")
            if not Events then
                continue
            end

            local BlockInvoke:RemoteFunction = Events:FindFirstChild("BlockInvoke")
            if not BlockInvoke then
                continue
            end

            return Tool, BlockInvoke
        end
    end

    return false, false
end

local BindFunctions = {
    [Enum.KeyCode.Z] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end

        local Character:Model = LocalPlayer.Character
        if not Character or not Character.PrimaryPart then
            task.wait(0.05)
            return
        end

        local Weapon:Tool|false?, BlockInvoke:RemoteFunction|false? = GetWeapon(true)
        if not Weapon 
            or (typeof(Weapon) ~= "Instance") 
            or not Weapon:IsA("Tool") 
        then
            return
        end
        if not BlockInvoke 
            or (typeof(BlockInvoke) ~= "Instance") 
            or not BlockInvoke:IsA("RemoteFunction") 
        then
            return
        end

        IterateWithFunction(ActiveZombies:GetChildren(), function(_, ZombieModel:Model)
            if not ZombieModel or not ZombieModel:FindFirstChildWhichIsA("Humanoid") then
                return
            end
            
            local Humanoid:Humanoid = ZombieModel:FindFirstChildWhichIsA("Humanoid")
            if (Humanoid.Health <= 0) then
                return
            end

            local PrimaryPart:BasePart = ZombieModel.PrimaryPart 
                or ZombieModel:FindFirstChild("HumanoidRootPart") 
                or ZombieModel:FindFirstChildWhichIsA("BasePart")
            if not PrimaryPart or not PrimaryPart:IsA("BasePart") then
                return
            end

            local PrimaryPartPosition:Vector3 = PrimaryPart.Position or EmptyVector
            local Success:boolean, PackedData:string = PackData({
                [1] = 0;
                [2] = 0;
                [3] = 0;
                [4] = 0;
                [5] = 0;
                [6] = 0;
                [7] = 0;
            }, "ffffff")

            if Success and (type(PackedData) == "string") and (#PackedData > 0) then 
                BlockInvoke:InvokeServer("ffffff", PackedData, Humanoid)
            end
        end, true)
    end);
    [Enum.KeyCode.C] = (function(Status:string)
		if (Status ~= "Begin") then
			return
		end
        
        getgenv()["ProjectileDamageLoop"] = not getgenv()["ProjectileDamageLoop"]
        print(`[INFO # ProjectDamage Bind]: Loop is now {getgenv()["ProjectileDamageLoop"] and "active" or "inactive"}.`)

        if getgenv()["ProjectileDamageLoop"] then
            while getgenv()["ProjectileDamageLoop"] do
                local Character:Model = LocalPlayer.Character
                if not Character or not Character.PrimaryPart then
                    task.wait(0.05)
                    continue
                end

                IterateWithFunction(ActiveZombies:GetChildren(), function(_, ZombieModel:Model)
                    if not ZombieModel or not ZombieModel:FindFirstChildWhichIsA("Humanoid") then
                        return
                    end
                    if not ZombieModel:FindFirstChild("Parried") then
                        return
                    end
                    
                    local Humanoid:Humanoid = ZombieModel:FindFirstChildWhichIsA("Humanoid")
                    if (Humanoid.Health <= 0) then
                        return
                    end

                    local PrimaryPart:BasePart = ZombieModel.PrimaryPart 
                        or ZombieModel:FindFirstChild("HumanoidRootPart") 
                        or ZombieModel:FindFirstChildWhichIsA("BasePart")
                    if not PrimaryPart or not PrimaryPart:IsA("BasePart") then
                        return
                    end

                    local PrimaryPartPosition:Vector3 = PrimaryPart.Position or EmptyVector
                    local Success:boolean, PackedData:string = PackData({
                        [1] = 0;
                        [2] = 0;
                        [3] = 0;
                        [4] = 0;
                        [5] = 0;
                        [6] = 0;
                        [7] = 500; --// Damage, can go negative, which, yes, does mean it can heal zombies.
                        [8] = 0;
                        [9] = 1;
                    }, "fffffffff")

                    if Success and (type(PackedData) == "string") and (#PackedData > 0) then 
                        ProjectileDamage:FireServer(
                            "fffffffff",
                            PackedData,
                            Humanoid,
                            0
                        )
                        task.wait()
                    end
                end, false)

                task.wait(0.025)
            end
        end
    end);
    [Enum.KeyCode.V] = (function(Status:string)
        if (Status ~= "Begin") then
            return
        end

        getgenv()["KillAuraActive"] = not getgenv()["KillAuraActive"]
        print(`[INFO # KillAura]: Kill aura is now {getgenv()["KillAuraActive"] and "active" or "inactive"}.`)

        while getgenv()["KillAuraActive"] do
            local Character:Model = LocalPlayer.Character
            if not Character or not Character.PrimaryPart then
                task.wait(0.05)
                continue
            end

            local RootPosition:Vector3 = Character.PrimaryPart.Position

            IterateWithFunction(ActiveZombies:GetChildren(), function(_, ZombieModel:Model)
                if not ZombieModel or not ZombieModel:FindFirstChildWhichIsA("Humanoid") then
                    return
                end
                local Humanoid:Humanoid = ZombieModel:FindFirstChildWhichIsA("Humanoid")
                if (Humanoid.Health <= 0) then
                    return
                end

                local PrimaryPart:BasePart = ZombieModel.PrimaryPart 
                    or ZombieModel:FindFirstChild("HumanoidRootPart") 
                    or ZombieModel:FindFirstChildWhichIsA("BasePart")
                if not PrimaryPart then
                    return
                end

                if (type(KillAuraRange) ~= "number") then
                    KillAuraRange = 15
                end
                if ((RootPosition - PrimaryPart.Position).Magnitude > KillAuraRange) then
                    return
                end

                local Success:boolean, PackedData:string = PackData({
                    [1] = 0;
                    [2] = 0;
                    [3] = 0;
                    [4] = 0;
                    [5] = 0;
                    [6] = 0;
                    [7] = 500; --// Damage, can go negative, which, yes, does mean it can heal zombies.
                    [8] = 0;
                    [9] = 1;
                }, "fffffffff")

                if Success and (type(PackedData) == "string") and (#PackedData > 0) then
                    ProjectileDamage:FireServer("fffffffff", PackedData, Humanoid, 0)
                end
            end, false)

            task.wait(0.025)
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
