local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer:Player = Players.LocalPlayer
local Backpack:Backpack = LocalPlayer.Backpack

local Rayfield = loadstring(
    tostring(game:HttpGet('https://sirius.menu/rayfield'))
)()

local MaxAttemptsToPickup = 5
local TeleportOffset = Vector3.new(0, 2.5, 0)

local CheckEnabled:boolean = true
local MaxPartsForCheck:number = 150
local RadiusToCheck:number = 250
local CheckForEmployees:boolean = true

local StorableItems = {
	"Water";
	"Medkit";
	"Burger Car";
	"Jeff";
	"2 Litre Dr. Bob";
	"Apple";
	"Banana";
	"Beans";
	"Bloxy Soda";
	"Burger";
	"Cake";
	"Candy Corn";
	"Chips";
	"Chocolate";
	"Cookie";
	"Dr. Bob Soda";
	"Fish Crackers";
	"Glass Shard";
	"Hotdog";
	"Ice Cream";
	"Lemon";
	"Lemon Slice";
	"Meatballs";
	"Pizza";
	"Striped Donut";
}
local SelectedStorableItem = "Medkit"
local SelectedObject = "GameCube"

local function GetInstance(InstanceName:string|number?, Parent:Instance, Timeout:number?)
    if typeof(Parent) == "Instance" and type(InstanceName) == "string" or type(InstanceName) == "number" then
        if type(Timeout) ~= "number" then
            return Parent:FindFirstChild(tostring(InstanceName)) or Parent:WaitForChild(tostring(InstanceName))
        else
            return Parent:FindFirstChild(tostring(InstanceName)) or Parent:WaitForChild(tostring(InstanceName), (tonumber(Timeout) or 3))
        end
    end

    return
end

local GameObjects:Folder = GetInstance("GameObjects", Workspace)
local Physical:Folder = GetInstance("Physical", GameObjects)
local Items:Folder = GetInstance("Items", Physical)
local Map:Folder = GetInstance("Map", Physical)
local Employees:Folder = GetInstance("Employees", Physical)
local Floor:Folder = GetInstance("Floor", Map)

local function GetCharacterActionRemote():(boolean, any)
    if LocalPlayer.Character then 
        local Character:Model = LocalPlayer.Character
        local System = GetInstance("System", Character, 3)

        if not System then
            print("[FAIL # GetCharacterActionRemote]: The LocalPlayer's character doesn't contain a \"System\" instance.")
            return false, nil
        end
        
        local ActionRemote:RemoteFunction = GetInstance("Action", System, 3)
        if ActionRemote == nil then
            print("[FAIL # GetCharacterActionRemote]: Failed to find \"ActionRemote\" in the Character's \"System\" instance.")
        end

        return (ActionRemote ~= nil), ActionRemote
    else
        print("[FAIL # GetCharacterActionRemote]: The LocalPlayer's character doesn't exist.")
    end

    return false, nil
end

local function IsItemSafe(Item:Model):boolean
    if not CheckEnabled then
        return true
    end

    if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
        local ItemPosition = (Item:GetAttribute("LastPosition") or Vector3.new())
        local ItemPrimaryPart = Item.PrimaryPart

        if ItemPrimaryPart then
            ItemPosition = ItemPrimaryPart.Position
        end

        local NewOverlapParams = OverlapParams.new()
        NewOverlapParams.FilterType = Enum.RaycastFilterType.Exclude
        NewOverlapParams.MaxParts = MaxPartsForCheck

        if not CheckForEmployees then
            NewOverlapParams.FilterDescendantsInstances = {
                Items;
                Map;
                Employees;
            }
        elseif CheckForEmployees then
            NewOverlapParams.FilterDescendantsInstances = {
                Items;
                Map;
            }
        end

        local Parts = Workspace:GetPartBoundsInRadius(ItemPosition, RadiusToCheck, NewOverlapParams)

        NewOverlapParams = nil
        ItemPosition = nil
        ItemPrimaryPart = nil

        if (#Parts >= 1) then
            Parts = nil
        elseif (#Parts == 0) then
            Parts = nil
            return true
        end
    else
        print("[FAIL # HandleItem]: Invalid \"Item\" parameter.")
    end

    return false
end

local function GetItem(ItemName:string, FromFloorAndItems:boolean?)
    if type(FromFloorAndItems) ~= "boolean" then
        FromFloorAndItems = false
    end

    local ItemFound = nil
    
    if type(ItemName) == "string" then
        if not FromFloorAndItems then
            for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and Item.PrimaryPart and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                    ItemFound = Item
                    break
                end
            end
            
            if (ItemFound == nil) then
                for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                        ItemFound = Item
                        break
                    end
                end
            end
        elseif FromFloorAndItems then
            for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and Item.PrimaryPart and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                    ItemFound = Item
                    break
                end
            end

            if (ItemFound == nil) then
                for _, Item:Instance in pairs(Items:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and Item.PrimaryPart and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                        ItemFound = Item
                        break
                    end
                end
            end

            if (ItemFound == nil) then
                for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                        ItemFound = Item
                        break
                    end
                end

                if (ItemFound == nil) then
                    for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                        if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                            ItemFound = Item
                            break
                        end
                    end
                end
            end
        end
    elseif type(ItemName) ~= "string" then
        print("[FAIL # GetItem]: Invalid \"ItemName\" parameter.")
        return false
    end

    print(
        ((ItemFound ~= nil) and ("[INFO # GetItem]: Successfully found item \"%s\"."):format(ItemName))
            or
        (("[FAIL # GetItem]: Failed to find item \"%s\"."):format(ItemName)) 
    )

    if (ItemFound == nil) then 
        Rayfield:Notify({
            Title = "GetItem Fail";
            Content = (("Failed to find any item named \"%s\" that matched criteria."):format(ItemName));
            Duration = 6;
            Image = 4483362458;
        })
    end

    return (ItemFound ~= nil), ItemFound
end

local function GetItems(FromFloorAndItems:boolean)
    if type(FromFloorAndItems) ~= "boolean" then
        FromFloorAndItems = false
    end
    local Table = {}

    for _, Item in pairs(Floor:GetDescendants()) do 
        if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
            if not table.find(Table, Item.Name) and not table.find(StorableItems, Item.Name) then
                table.insert(Table, Item.Name)
            end
        end
    end
    if FromFloorAndItems then
        for _, Item in pairs(Items:GetDescendants()) do 
            if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
                if not table.find(Table, Item.Name) and not table.find(StorableItems, Item.Name) then
                    table.insert(Table, Item.Name)
                end
            end
        end
    end

    return Table
end

local function HandleItem(Item:Model):boolean
    if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
        local FoundRemote:boolean, ActionRemote:RemoteFunction = GetCharacterActionRemote()

        if FoundRemote and typeof(ActionRemote) == "Instance" then 
            local ItemName = ((Item and Item.Name) or "Unknown")
            local IsNormalItem = false

            if not table.find(StorableItems, ItemName) then
                print("[FAIL # HandleItem]: Invalid item to store.")
                IsNormalItem = true
            end

            local Response
            
            if (ItemName ~= "Unknown") then 
                if not IsNormalItem then
                    Response = ActionRemote:InvokeServer(
                        "Store",
                        {
                            ["Model"] = Item;
                        }
                    )
                elseif IsNormalItem then
                    Response = ActionRemote:InvokeServer(
                        "Pickup",
                        {
                            ["Model"] = Item;
                        }
                    )
                end
            end

            if not IsNormalItem then
                if not Response then 
                    print(("[FAIL # HandleItem]: Failed to store item \"%s\"."):format(ItemName))
                elseif Response then
                    print(("[INFO # HandleItem]: Successfully stored item \"%s\"."):format(ItemName))
                end

                return Response
            elseif IsNormalItem then
                if not Response then
                    print(("[FAIL # HandleItem]: Failed to pickup item \"%s\"."):format(ItemName))
                elseif Response then
                    print(("[FAIL # HandleItem]: Successfully to picked up item \"%s\"."):format(ItemName))
                    Item:SetAttribute("AlreadyTeleported", true)

                    task.spawn(function()
                        task.wait(15)
                        Item:SetAttribute("AlreadyTeleported", nil)
                    end)
                end

                return Response, ActionRemote
            end
        else
            if typeof(ActionRemote) ~= "Instance" then
                print("[FAIL # HandleItem]: \"ActionRemote\" variable is invalid.")
            end
        end
    else
        print("[FAIL # HandleItem]: Invalid \"Item\" parameter.")
    end

    return false
end

local function HandleItemWithTeleport(Item:Model):(boolean)
    if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
        local ItemLastPosition:Vector3 = Item:GetAttribute("LastPosition")

        local Character = LocalPlayer.Character
        if not Character then
            print("[FAIL # HandleItemWithTeleport]: The LocalPlayer's character doesn't exist.")
            return false
        end

        local CharacterPrimaryPart:BasePart = Character.PrimaryPart
        if not CharacterPrimaryPart then
            print("[FAIL # HandleItemWithTeleport]: The character's \"PrimaryPart\" doesn't exist?")
            return false
        end
        
        if not _G["__OldPos"] then
            _G["__OldPos"] = CharacterPrimaryPart.CFrame
        elseif _G["__OldPos"] then
            print("[FAIL # HandleItemWithTeleport]: Teleport already happening, please wait.")
            return false
        end

        local ItemName = ((Item and Item.Name) or "Unknown")
        local IsNormalItem = false
        
        if not table.find(StorableItems, ItemName) then
            IsNormalItem = true
        end

        local ItemPrimaryPart:BasePart = Item.PrimaryPart
        if ItemPrimaryPart then
            local ItemPosition:Vector3 = ItemPrimaryPart.Position
            CharacterPrimaryPart.CFrame = (CFrame.new(ItemPosition.X, ItemPosition.Y, ItemPosition.Z) + TeleportOffset)
        elseif not ItemPrimaryPart then
            CharacterPrimaryPart.CFrame = (CFrame.new(ItemLastPosition) + TeleportOffset)
        end

        if not ItemPrimaryPart then
            task.wait(0.5)
        elseif ItemPrimaryPart then
            task.wait(0.025)
        end

        local TimesAttempted:number = 0
        local Response = false
        local ActionRemote:RemoteFunction
        repeat
            if ItemPrimaryPart then
                local ItemPosition = ItemPrimaryPart.Position
                CharacterPrimaryPart.CFrame = (CFrame.new(ItemPosition.X, ItemPosition.Y, ItemPosition.Z) + TeleportOffset)
            elseif not ItemPrimaryPart then
                CharacterPrimaryPart.CFrame = (CFrame.new(ItemLastPosition) + TeleportOffset)
            end
            CharacterPrimaryPart.AssemblyLinearVelocity = Vector3.new()

            task.wait(0.1)
            CharacterPrimaryPart.Anchored = true

            Response, ActionRemote = HandleItem(Item)
            if Response then
                break
            end

            TimesAttempted += 1
        until (TimesAttempted >= MaxAttemptsToPickup) or Response

        for _ = 1, 3 do
            CharacterPrimaryPart.Anchored = false
            CharacterPrimaryPart.CFrame = (_G["__OldPos"] - Vector3.new(0, 1, 0))
            CharacterPrimaryPart.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.05)
        end
        CharacterPrimaryPart.Anchored = true

        if Response and IsNormalItem and ActionRemote then
            for _ = 1, 3 do 
                Response = ActionRemote:InvokeServer(
                    "Drop",
                    {
                        ["EndCFrame"] = (_G["__OldPos"] + (TeleportOffset + Vector3.new(0, 3, 0))),
                        ["CameraCFrame"] = Workspace.CurrentCamera.CFrame.LookVector,
                        ["ThrowPower"] = 0
                    }
                )

                if Response then
                    break
                end

                task.wait(0.025)
            end
        end

        CharacterPrimaryPart.AssemblyLinearVelocity = Vector3.new()
        task.wait(0.025)
        CharacterPrimaryPart.Anchored = false
        _G["__OldPos"] = nil

        return true
    else
        print("[FAIL # HandleItemWithTeleport]: Invalid \"Item\" parameter.")
    end

    return false
end

--[[
local founditem, item = GetItem("Medkit", false)
if founditem then
    HandleItemWithTeleport(item)
end
]]

local Window = Rayfield:CreateWindow({
   Name = "Roblox - 3008";
   Icon = "moon-star"; -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "3008 Script - Rayfield UI";
   LoadingSubtitle = "         By @_x4yz";
   Theme = "Amber Glow"; -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false;
   DisableBuildWarnings = false; -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true;
      FolderName = nil; -- Create a custom folder for your hub/game
      FileName = "3008Hub";
   };

   KeySystem = false; -- Set this to true to use our key system
})

local MainTab = Window:CreateTab("Main", 4483362458)
do 
    MainTab:CreateSection("Storable Items")
    MainTab:CreateDropdown({
        Name = "Selected Item";
        Options = table.clone(StorableItems);
        CurrentOption = {tostring(SelectedStorableItem)};
        MultipleOptions = false;
        Flag = "StorableItemDropdown"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Options)
            if table.find(StorableItems, tostring(Options[1])) then
                SelectedStorableItem = tostring(Options[1])
            end
        end
    })
    MainTab:CreateButton({
        Name = "Attempt to store selected item";
        Callback = function()
            if (#Backpack:GetChildren() >= 16) then
                Rayfield:Notify({
                    Title = "Fail";
                    Content = ("Backpack is at full capacity.");
                    Duration = 6;
                    Image = 4483362458;
                })

                return
            end

            if table.find(StorableItems, SelectedStorableItem) then
                local FoundItem:boolean, Item:Model = GetItem(SelectedStorableItem, false)

                if FoundItem then
                    local Success, Error = pcall(HandleItemWithTeleport, Item)
                    if not Success then
                        warn(Error)
                    end
                end
            end
        end;
    })

    MainTab:CreateSection("Non-Storable Items")
    local ObjectDropdown 
    ObjectDropdown = MainTab:CreateDropdown({
        Name = "Selected Object";
        Options = GetItems(false);
        CurrentOption = {tostring(SelectedObject)};
        MultipleOptions = false;
        Flag = "PickupObjectFlag"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Options:{string})
            local ObjectNames = GetItems(false)
            print(#ObjectNames)
            if table.find(ObjectNames, tostring(Options[1])) then
                SelectedObject = tostring(Options[1])
            end

            ObjectDropdown.Options = GetItems(false)
        end
    })
    MainTab:CreateButton({
        Name = "Attempt to pick up selected object";
        Callback = function()
            local FoundItem:boolean, Item:Model = GetItem(SelectedObject, false)
            
            if FoundItem then
                local Success, Error = pcall(HandleItemWithTeleport, Item)
                if not Success then
                    warn(Error)
                end
            end
        end;
    })
end

local SettingsTab = Window:CreateTab("Settings", 4483362458)
do 
    SettingsTab:CreateSection("Safe Check Settings")
    SettingsTab:CreateToggle({
        Name = "Safe Check Enabled";
        CurrentValue = CheckEnabled;
        Flag = "SafeCheckEnabledFlag"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value:boolean)
            CheckEnabled = Value
        end;
    })
    SettingsTab:CreateToggle({
        Name = "Check for Employees";
        CurrentValue = CheckForEmployees;
        Flag = "CheckForEmployeesFlag"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value:boolean)
            CheckForEmployees = Value
        end;
    })
    SettingsTab:CreateSlider({
        Name = "Check Radius";
        Range = {0, 500};
        Increment = 10;
        Suffix = "Stud(s)";
        CurrentValue = RadiusToCheck;
        Flag = "CheckRadiusFlag"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value:number)
            RadiusToCheck = Value
        end;
    })
    SettingsTab:CreateSlider({
        Name = "Max Parts To Fetch";
        Range = {50, 250};
        Increment = 10;
        Suffix = "Part(s)";
        CurrentValue = MaxPartsForCheck;
        Flag = "MaxPartsToFetchFlag"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value:number)
            MaxPartsForCheck = Value
        end;
    })

    SettingsTab:CreateSection("Pickup Settings")
    SettingsTab:CreateSlider({
        Name = "Max Attempts for Pickup";
        Range = {1, 15};
        Increment = 1;
        Suffix = "";
        CurrentValue = MaxAttemptsToPickup;
        Flag = "MaxPickupAttemptsFlag"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value:number)
            MaxAttemptsToPickup = Value
        end;
    })
end
