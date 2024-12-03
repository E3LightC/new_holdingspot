local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local MaxAttemptsToPickup = 5
local TeleportOffset = Vector3.new(0, 2.5, 0)

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

local GameObjects:Folder = GetInstance("GameObjects", Workspace)
local Physical:Folder = GetInstance("Physical", GameObjects)
local Items:Folder = GetInstance("Items", Physical)
local Map:Folder = GetInstance("Map", Physical)
local Floor:Folder = GetInstance("Floor", Map)

local function GetItem(ItemName:string, FromFloorAndItems:boolean?)
    if type(FromFloorAndItems) ~= "boolean" then
        FromFloorAndItems = false
    end

    local ItemFound = nil
    
    if type(ItemName) == "string" then
        if not FromFloorAndItems then
            for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and Item.PrimaryPart and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" then
                    ItemFound = Item
                    break
                end
            end
            
            if (ItemFound == nil) then
                for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" then
                        ItemFound = Item
                        break
                    end
                end
            end
        elseif FromFloorAndItems then
            for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and Item.PrimaryPart and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" then
                    ItemFound = Item
                    break
                end
            end

            if (ItemFound == nil) then
                for _, Item:Instance in pairs(Items:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and Item.PrimaryPart and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" then
                        ItemFound = Item
                        break
                    end
                end
            end

            if (ItemFound == nil) then
                for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                    if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" then
                        ItemFound = Item
                        break
                    end
                end

                if (ItemFound == nil) then
                    for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                        if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" then
                            ItemFound = Item
                            break
                        end
                    end
                end
            end
        end
    end

    print(
        ((ItemFound ~= nil) and ("[INFO # GetItem]: Successfully found item \"%s\"."):format(ItemName))
            or
        (("[FAIL # GetItem]: Failed to find item \"%s\"."):format(ItemName)) 
    )

    return (ItemFound ~= nil), ItemFound
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
    if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" and typeof(Item:GetAttribute("AlreadyTeleported")) ~= "boolean" then
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
            task.wait(0.4)
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

            task.wait(0.1)

            Response, ActionRemote = HandleItem(Item)
            if Response then
                break
            end

            TimesAttempted += 1
        until (TimesAttempted >= MaxAttemptsToPickup) or Response

        for _ = 1, 3 do
            CharacterPrimaryPart.CFrame = _G["__OldPos"]
            CharacterPrimaryPart.AssemblyLinearVelocity = Vector3.new()
            task.wait(0.05)
        end

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

                task.wait(0.05)
            end
        end

        _G["__OldPos"] = nil

        return true
    else
        print("[FAIL # HandleItemWithTeleport]: Invalid \"Item\" parameter.")
    end

    return false
end

local founditem, item = GetItem("TV")
if founditem then
    HandleItemWithTeleport(item)
end
