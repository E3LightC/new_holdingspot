local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local function GetInstance(InstanceName:string|number?, Parent:Instance, Timeout:number?)
    if typeof(Parent) == "Instance" and typeof(InstanceName) == "string" or typeof(InstanceName) == "number" then
        if typeof(Timeout) ~= "number" then
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
    if typeof(FromFloorAndItems) ~= "boolean" then
        FromFloorAndItems = false
    end

    local ItemFound
    
    if typeof(ItemName) == "string" then
        if not FromFloorAndItems then
            for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
                    ItemFound = Item
                end
            end
        elseif FromFloorAndItems then
            for _, Item:Instance in pairs(Floor:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
                    ItemFound = Item
                end
            end

            for _, Item:Instance in pairs(Items:GetDescendants()) do 
                if Item and Item:IsA("Model") and (Item.Name == ItemName) and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
                    ItemFound = Item
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

local function StoreItem(Item:Model):boolean
    if typeof(Item) == "Instance" and Item:IsA("Model") and typeof(Item:GetAttribute("LastPosition")) == "Vector3" then
        local FoundRemote:boolean, ActionRemote:RemoteFunction = GetCharacterActionRemote()

        if FoundRemote and typeof(ActionRemote) == "Instance" then 
            local ItemName = ((Item and Item.Name) or "Unknown")
            local Response
            
            if (ItemName ~= "Unknown") then 
                Response = ActionRemote:InvokeServer(
                    "Store",
                    {
                        ["Model"] = Item;
                    }
                )
            end

            if not Response then 
                print(("[FAIL # StoreItem]: Failed to store item \"%s\"."):format(ItemName))
            elseif Response then
                print(("[INFO # StoreItem]: Successfully stored item \"%s\"."):format(ItemName))
            end

            return Response
        else
            if typeof(ActionRemote) ~= "Instance" then
                print("[FAIL # StoreItem]: \"ActionRemote\" variable is invalid.")
            end
        end
    else
        print("[FAIL # StoreItem]: Invalid \"Item\" parameter.")
    end

    return false
end
