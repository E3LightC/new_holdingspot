local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer:Player = Players.LocalPlayer
local Backpack:Backpack = LocalPlayer.Backpack

local Rayfield = loadstring(
    tostring(game:HttpGet('https://sirius.menu/rayfield'))
)()

local MaxAttemptsToPickup = 5
local TeleportOffset:Vector3 = Vector3.new(0, 2.5, 0)

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

if not _G["AttributeTable"] then
    _G["AttributeTable"] = {}
end

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
local FloorOrGround:Folder = GetInstance("Floor", Map, 1) or GetInstance("Ground", Map, 1)

local function GetCharacterSystemRemote(RemoteName:string):(boolean, any)
    if type(RemoteName) ~= "string" then
        return false, nil
    end

    if LocalPlayer.Character then 
        local Character:Model = LocalPlayer.Character
        local System = GetInstance("System", Character, 3)

        if not System then
            print("[FAIL # GetCharacterActionRemote]: The LocalPlayer's character doesn't contain a \"System\" instance.")
            return false, nil
        end
        
        local ActionRemote:RemoteFunction = GetInstance(RemoteName, System, 3)
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
        local ItemPosition = (Item:GetPivot().Position or Vector3.new())
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
            return false
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
            for _, Item:Instance in pairs(FloorOrGround:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and Item.PrimaryPart and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                    ItemFound = Item
                    break
                end
            end
            
            if (ItemFound == nil) then
                for _, Item:Instance in pairs(FloorOrGround:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                        ItemFound = Item
                        break
                    end

                    task.wait()
                end
            end
        elseif FromFloorAndItems then
            for _, Item:Instance in pairs(FloorOrGround:GetDescendants()) do 
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
                for _, Item:Instance in pairs(FloorOrGround:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                        ItemFound = Item
                        break
                    end

                    task.wait()
                end

                if (ItemFound == nil) then
                    for _, Item:Instance in pairs(FloorOrGround:GetDescendants()) do 
                        if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
                            ItemFound = Item
                            break
                        end

                        task.wait()
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
            Title = "Fail";
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

    for _, Item in pairs(FloorOrGround:GetDescendants()) do 
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

local function HandleItem(Item):boolean
    if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
        local FoundRemote, ActionRemote:RemoteFunction = GetCharacterSystemRemote("Action")

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

                IsNormalItem = nil
                ItemName = nil
                FoundRemote = nil

                return Response
            elseif IsNormalItem then
                if not Response then
                    print(("[FAIL # HandleItem]: Failed to pickup item \"%s\"."):format(ItemName))
                elseif Response then
                    print(("[FAIL # HandleItem]: Successfully to picked up item \"%s\"."):format(ItemName))
                    Item:SetAttribute("AlreadyTeleported", true)
                    table.insert(_G["AttributeTable"], Item)
                end

                IsNormalItem = nil
                ItemName = nil
                FoundRemote = nil

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
        local Character = LocalPlayer.Character
        if not Character then
            print("[FAIL # HandleItemWithTeleport]: The LocalPlayer's character doesn't exist.")
            return false
        end

        local CharacterPrimaryPart = Character.PrimaryPart
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
        
        local ItemLastPosition = Item:GetPivot().Position
        local ItemPrimaryPart = Item.PrimaryPart

        if ItemPrimaryPart then
            local ItemPosition = ItemPrimaryPart.Position
            CharacterPrimaryPart.CFrame = (CFrame.new(ItemPosition.X, ItemPosition.Y, ItemPosition.Z) + TeleportOffset)
            ItemPosition = nil
        elseif not ItemPrimaryPart then
            CharacterPrimaryPart.CFrame = (CFrame.new(ItemLastPosition) + TeleportOffset)
        end

        if not ItemPrimaryPart then
            task.wait(0.5)
        elseif ItemPrimaryPart then
            task.wait(0.025)
        end

        local TimesAttempted = 0
        local Response = false
        local ActionRemote
        repeat
            if ItemPrimaryPart then
                local ItemPosition = ItemPrimaryPart.Position
                CharacterPrimaryPart.CFrame = (CFrame.new(ItemPosition.X, ItemPosition.Y, ItemPosition.Z) + TeleportOffset)
                ItemPosition = nil
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
            task.wait(0.025)
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

        CharacterPrimaryPart = nil
        Response = nil
        IsNormalItem = nil
        ActionRemote = nil
        TimesAttempted = nil
        Character = nil
        ItemName = nil
        ItemLastPosition = nil
        _G["__OldPos"] = nil

        return true
    else
        print("[FAIL # HandleItemWithTeleport]: Invalid \"Item\" parameter.")
    end

    return false
end

local function TeleportToItem(Item:Model):(boolean)
    if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" and IsItemSafe(Item) then
        local Character = LocalPlayer.Character
        if not Character then
            print("[FAIL # TeleportToItem]: The LocalPlayer's character doesn't exist.")
            return false
        end

        local CharacterPrimaryPart = Character.PrimaryPart
        if not CharacterPrimaryPart then
            print("[FAIL # TeleportToItem]: The character's \"PrimaryPart\" doesn't exist?")
            return false
        end
        
        if not _G["__OldPos"] then
            _G["__OldPos"] = CharacterPrimaryPart.CFrame
        elseif _G["__OldPos"] then
            print("[FAIL # TeleportToItem]: Teleport already happening, please wait.")
            return false
        end

        local ItemLastPosition = Item:GetPivot().Position
        local ItemPrimaryPart = Item.PrimaryPart

        if ItemPrimaryPart then
            local ItemPosition = ItemPrimaryPart.Position
            CharacterPrimaryPart.CFrame = (CFrame.new(ItemPosition) + TeleportOffset)
            ItemPosition = nil
        elseif not ItemPrimaryPart then
            CharacterPrimaryPart.CFrame = (CFrame.new(ItemLastPosition) + TeleportOffset)
        end

        CharacterPrimaryPart.Anchored = true
        if not ItemPrimaryPart then
            task.wait(0.4)
        elseif ItemPrimaryPart then
            task.wait(0.15)
        end
        CharacterPrimaryPart.Anchored = false

        Character = nil
        CharacterPrimaryPart = nil
        ItemLastPosition = nil
        ItemPrimaryPart = nil
        _G["__OldPos"] = nil

        return true
    else
        print("[FAIL # TeleportToItem]: Invalid \"Item\" parameter.")
    end

    return false
end

local Window = Rayfield:CreateWindow({
   Name = "Roblox - 3008 - @_x4yz";
   Icon = "moon-star";
   LoadingTitle = "3008 Script - Rayfield UI";
   LoadingSubtitle = "         By @_x4yz";
   Theme = "Amber Glow";

   DisableRayfieldPrompts = false;
   DisableBuildWarnings = false;

   ConfigurationSaving = {
      Enabled = true;
      FolderName = nil;
      FileName = "3008Hub";
   };

   KeySystem = false;
})

local MainTab = Window:CreateTab("Main", 4483362458)
do 
    MainTab:CreateSection("General")
    MainTab:CreateKeybind({
        Name = "Remove Teleport Attributes";
        CurrentKeybind = "KeypadOne";
        HoldToInteract = false;
        Flag = "RemoveTeleportAttributesFlag"; -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Keybind)
            if Keybind then
                if _G["AttributeTable"] ~= {} then
                    for i, Item in pairs(_G["AttributeTable"]) do 
                        if typeof(Item) == "Instance" and Item:IsA("Model") and Item.Parent then
                            Item:SetAttribute("AlreadyTeleported", nil)
                        end
                    end
                    
                    _G["AttributeTable"] = {}
                end
            end
        end;
    })
    MainTab:CreateButton({
        Name = "God Mode (Infinite Health, Energy, and Hunger) (No turning back)";
        Callback = function()
            if LocalPlayer.Character then 
                local FoundRemote, EventRemote:RemoteEvent = GetCharacterSystemRemote("Event")

                if FoundRemote and typeof(EventRemote) == "Instance" then
                    local Arguments = {
                        [1] = "FallDamage",
                        [2] = {
                            ["Sliding"] = false,
                            ["OriginalDamage"] = 0/0,
                            ["Range"] = 0,
                            ["Softened"] = false,
                            ["Broken"] = false,
                            ["Model"] = LocalPlayer.Character,
                            ["Sound"] = "medium",
                            ["Damage"] = 0/0
                        }
                    }

                    for _ = 1, 3 do 
                        EventRemote:FireServer(unpack(Arguments))
                        task.wait()
                    end
                end

                FoundRemote = nil
            end
        end;
    })
    MainTab:CreateButton({
        Name = "Infinite Energy";
        Callback = function()
            if LocalPlayer.Character then 
                local FoundRemote, EventRemote:RemoteEvent = GetCharacterSystemRemote("Event")

                if FoundRemote and typeof(EventRemote) == "Instance" then
                    local Arguments = {
                        [1] = "DecreaseStat";
                        [2] = {
                            ["Stats"] = {
                                ["Energy"] = 0/0;
                            };
                        };
                    }

                    for _ = 1, 3 do 
                        EventRemote:FireServer(unpack(Arguments))
                        task.wait()
                    end
                end

                FoundRemote = nil
            end
        end;
    })
    MainTab:CreateButton({
        Name = "Infinite Hunger";
        Callback = function()
            if LocalPlayer.Character then 
                local FoundRemote, EventRemote:RemoteEvent = GetCharacterSystemRemote("Event")

                if FoundRemote and typeof(EventRemote) == "Instance" then
                    local Arguments = {
                        [1] = "DecreaseStat";
                        [2] = {
                            ["Stats"] = {
                                ["Hunger"] = 0/0;
                            };
                        };
                    }

                    for _ = 1, 3 do 
                        EventRemote:FireServer(unpack(Arguments))
                        task.wait()
                    end
                end

                FoundRemote = nil
            end
        end;
    })

    MainTab:CreateSection("Storable Items")
    MainTab:CreateDropdown({
        Name = "Selected Item";
        Options = table.clone(StorableItems);
        CurrentOption = {tostring(SelectedStorableItem)};
        MultipleOptions = false;
        Flag = "StorableItemDropdown";
        Callback = function(Options)
            if table.find(StorableItems, tostring(Options[1])) then
                SelectedStorableItem = tostring(Options[1])
            end

            Options = nil
        end
    })
    MainTab:CreateButton({
        Name = "Store Item";
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
                local FoundItem, Item = GetItem(SelectedStorableItem, false)

                if FoundItem then
                    local Success, Error = pcall(HandleItemWithTeleport, Item)
                    if not Success then
                        warn(Error)
                    end

                    Success = nil
                    Error = nil
                end

                FoundItem = nil
                Item = nil
            end
        end;
    })
    MainTab:CreateButton({
        Name = "Teleport To Item";
        Callback = function()
            local FoundItem:boolean, Item:Model = GetItem(SelectedStorableItem, false)
            
            if FoundItem then
                local HandleItemSuccess = false
                local Success, Error = pcall(function()
                    HandleItemSuccess = TeleportToItem(Item)
                end)

                if not Success then
                    warn(Error)
                end

                if not HandleItemSuccess then
                    Rayfield:Notify({
                        Title = "Fail";
                        Content = ("Failed to teleport to item.");
                        Duration = 6;
                        Image = 4483362458;
                    })
                end

                HandleItemSuccess = nil
                Success = nil 
                Error = nil
            end
        end;
    })

    MainTab:CreateSection("General Object Features")
    local ObjectDropdown 
    ObjectDropdown = MainTab:CreateDropdown({
        Name = "Selected Object";
        Options = GetItems(true);
        CurrentOption = {tostring(SelectedObject)};
        MultipleOptions = false;
        Flag = "PickupObjectFlag";
        Callback = function(Options)
            local ObjectNames = GetItems(true)
            if table.find(ObjectNames, tostring(Options[1])) then
                SelectedObject = tostring(Options[1])
            end

            ObjectNames = nil
            Options = nil
            ObjectDropdown.Options = GetItems(true)
        end
    })
    MainTab:CreateButton({
        Name = "Teleport Object";
        Callback = function()
            local FoundItem:boolean, Item:Model = GetItem(SelectedObject, false)
            
            if FoundItem then
                local HandleItemSuccess = false
                local Success, Error = pcall(function()
                    HandleItemSuccess = HandleItemWithTeleport(Item)
                end)

                if not Success then
                    warn(Error)
                end

                if not HandleItemSuccess then
                    Rayfield:Notify({
                        Title = "Fail";
                        Content = ("Failed to store/pickup object.");
                        Duration = 6;
                        Image = 4483362458;
                    })
                end

                HandleItemSuccess = nil
                Success = nil 
                Error = nil
            end
        end;
    })
    MainTab:CreateButton({
        Name = "Teleport To Object";
        Callback = function()
            local FoundItem:boolean, Item:Model = GetItem(SelectedObject, false)
            
            if FoundItem then
                local HandleItemSuccess = false
                local Success, Error = pcall(function()
                    HandleItemSuccess = TeleportToItem(Item)
                end)

                if not Success then
                    warn(Error)
                end

                if not HandleItemSuccess then
                    Rayfield:Notify({
                        Title = "Fail";
                        Content = ("Failed to teleport to item.");
                        Duration = 6;
                        Image = 4483362458;
                    })
                end

                HandleItemSuccess = nil
                Success = nil 
                Error = nil
            end
        end;
    })

    MainTab:CreateSection("Toggles")
    MainTab:CreateToggle({
        Name = "Toggle Fall Damage";
        CurrentValue = ( ((_G["FallDamageEnabled"] == nil) and false) or _G["FallDamageEnabled"] );
        Flag = "FallDamageFlag";
        Callback = function(Value)
            _G["FallDamageEnabled"] = Value
            Value = nil
            local Character = LocalPlayer.Character

            if Character then
                local FallDamageScript = GetInstance("FallDamage", Character, 3)

                if FallDamageScript then
                    FallDamageScript.Enabled = not _G["FallDamageEnabled"]
                    FallDamageScript.Disabled = _G["FallDamageEnabled"]
                end
                FallDamageScript = nil
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
        Flag = "SafeCheckEnabledFlag";
        Callback = function(Value): ()
            CheckEnabled = Value
            Value = nil
        end;
    })
    SettingsTab:CreateToggle({
        Name = "Check For Employees";
        CurrentValue = CheckForEmployees;
        Flag = "CheckForEmployeesFlag";
        Callback = function(Value)
            CheckForEmployees = Value
            Value = nil
        end;
    })
    SettingsTab:CreateSlider({
        Name = "Check Radius";
        Range = {0, 500};
        Increment = 10;
        Suffix = "Stud(s)";
        CurrentValue = RadiusToCheck;
        Flag = "CheckRadiusFlag";
        Callback = function(Value)
            RadiusToCheck = Value
            Value = nil
        end;
    })
    SettingsTab:CreateSlider({
        Name = "Max Parts To Fetch";
        Range = {50, 250};
        Increment = 10;
        Suffix = "Part(s)";
        CurrentValue = MaxPartsForCheck;
        Flag = "MaxPartsToFetchFlag";
        Callback = function(Value)
            MaxPartsForCheck = Value
            Value = nil
        end;
    })

    SettingsTab:CreateSection("Pickup Settings")
    SettingsTab:CreateSlider({
        Name = "Max Attempts for Pickup";
        Range = {1, 15};
        Increment = 1;
        Suffix = "";
        CurrentValue = MaxAttemptsToPickup;
        Flag = "MaxPickupAttemptsFlag";
        Callback = function(Value)
            MaxAttemptsToPickup = Value
            Value = nil
        end;
    })
end

if _G["FallDamageDisabler"] then
    _G["FallDamageDisabler"]:Disconnect()
end
_G["FallDamageDisabler"] = LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    if NewCharacter then
        if _G["FallDamageEnabled"] == nil then
            _G["FallDamageEnabled"] = false
        end

        local FallDamageScript = GetInstance("FallDamage", NewCharacter, 5)

        if FallDamageScript then
            FallDamageScript.Enabled = not _G["FallDamageEnabled"]
            FallDamageScript.Disabled = _G["FallDamageEnabled"]
        end
        
        FallDamageScript = nil
    end
end)
