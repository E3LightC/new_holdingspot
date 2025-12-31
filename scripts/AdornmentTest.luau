local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local BoxColor:Color3 = Color3.fromRGB(0, 255, 255)
local BoxSize:Vector3 = Vector3.new(4, 5, 1)
local AlwaysOnTopBind:Enum.KeyCode = Enum.KeyCode.Z

local LocalPlayer = Players.LocalPlayer

if (type(shared.ActiveBoxes) ~= "table") then
	shared.ActiveBoxes = {}
end

local OldConnection = shared.ToggleAlwaysOnTop
if OldConnection then
	OldConnection:Disconnect()
	OldConnection = nil
	shared.ToggleAlwaysOnTop = nil
end

local function CreateInstance(
    Class:string, 
    Properties:{[string]:any?}
):(Instance, false?)
    if (type(Class) ~= "string") then
        return false
    end

    local UseProperties = (type(Properties) == "table")
    local Success, NewInstance = pcall(function()
        return Instance.new(Class)
    end)
    if not Success 
		or not NewInstance 
	then
        return false
    end

    if not UseProperties then
		return NewInstance
    end

    local ParentPropertyToSet:Instance
    for Property:string, Value:any? in pairs(Properties) do 
        if (Property ~= "Parent") then
            task.spawn(pcall, function()
                NewInstance[Property] = Value
            end)
        elseif (Property == "Parent") 
			and (typeof(Value) == "Instance") 
		then
            ParentPropertyToSet = Value
        end
    end

    if ParentPropertyToSet then
        NewInstance.Parent = ParentPropertyToSet
    end
    return NewInstance
end

local function ApplyBoxOnCharacter(
	Character:Model
):(boolean)
	if (typeof(Character) ~= "Instance") or not Character:IsA("Model") then
		return false
	end
	
	local OldBoxAdorn = Character:FindFirstChild("__BoxAdorn") 
	if not OldBoxAdorn then
		OldBoxAdorn = CreateInstance("BoxHandleAdornment", {
			Color3 = BoxColor;
			Size = BoxSize;
			ZIndex = 10;
			Transparency = 0.5;
			Adornee = Character:FindFirstChild("HumanoidRootPart");
			Name = "__BoxAdorn";
			AlwaysOnTop = shared.AlwaysOnTopToggled
		})
		OldBoxAdorn.Parent = Character
	elseif OldBoxAdorn then
		OldBoxAdorn.Color3 = BoxColor
		OldBoxAdorn.Size = BoxSize
		OldBoxAdorn.ZIndex = 10
		OldBoxAdorn.Transparency = 0.5
		OldBoxAdorn.Adornee = Character:FindFirstChild("HumanoidRootPart")
		OldBoxAdorn.Name = "__BoxAdorn"
		OldBoxAdorn.AlwaysOnTop = shared.AlwaysOnTopToggled
	end

	return true
end

local function OnPlayerAdded(
	Player:Player
):()
	if (typeof(Player) ~= "Instance") or not Player:IsA("Player") then
		return
	end
	if Player.Character then
		ApplyBoxOnCharacter(Player.Character)
	end
	Player.CharacterAdded:Connect(ApplyBoxOnCharacter)
end

for _, Player in pairs(Players:GetPlayers()) do
	if (Player == LocalPlayer) then
		continue
	end
	OnPlayerAdded(Player)
end
Players.PlayerAdded:Connect(OnPlayerAdded)

shared.ToggleAlwaysOnTop = UserInputService.InputBegan:Connect(function(Key, Process)
	if Process then
		return
	end
	if (Key.KeyCode ~= AlwaysOnTopBind) then
		return
	end

	shared.AlwaysOnTopToggled = not shared.AlwaysOnTopToggled
	for _, Adornment:BoxHandleAdornment in pairs(shared.ActiveBoxes) do 
		if (typeof(Adornment) ~= "Instance") or not Adornment:IsA("BoxHandleAdornment") then
			continue
		end
		Adornment.AlwaysOnTop = shared.AlwaysOnTopToggled
	end
end)
