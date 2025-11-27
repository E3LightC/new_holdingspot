--// @_x4yz
--// https://www.roblox.com/games/18968763874/A-Niche-Barista-Game

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack

local BrewersFolder = Workspace:WaitForChild("Brewers")
local aaaaaaa

local function GetPromptData(PrimaryPart:BasePart?)
    if not PrimaryPart or not PrimaryPart:IsA("BasePart") then
        return
    end
    
    local Attachment = PrimaryPart:FindFirstChild("Attachment")
    if not Attachment then
        return
    end
    local Prompt = Attachment:FindFirstChild("ProximityPrompt")
    if not Prompt then
        return
    end
    
    return {
        ["Attachment"] = Attachment;
        ["Prompt"] = Prompt;
    }
end

local function FetchBrewers():(
    {
        {
            ["Attachment"]:Attachment;
            ["Prompt"]:ProximityPrompt;
        }
    }
)
    local Brewers = {}

    for _, Brewer:Model in pairs(Brewers:GetChildren()) do 
        if not Brewer or not Brewer:IsA("Model") then
            continue
        end

        local BrewValue = Brewer:FindFirstChild("Brew")
        if BrewValue then
            local Primary = Brewer:FindFirstChild("Primary")
            if not Primary then
                continue
            end
            local Data = GetPromptData(Primary)
            if (type(Data) ~= "table") then
                continue
            end

            Brewers[BrewValue.Value] = Data
            continue
        elseif not BrewValue then
            local Primary = Brewer:FindFirstChild("Primary")
            if Primary then
                local Data = GetPromptData(Primary)
                if (type(Data) ~= "table") then
                    continue
                end

                Brewers["Carbonator"] = Data
            elseif not Primary then
                local FoamPrimary = Brewer:FindFirstChild("FoamPrimary")
                local MilkPrimary = Brewer:FindFirstChild("MilkPrimary")
                local WaterPrimary = Brewer:FindFirstChild("WaterPrimary")

                local FoamData = GetPromptData(FoamPrimary)
                local MilkData = GetPromptData(MilkPrimary)
                local WaterData = GetPromptData(WaterPrimary)

                if (type(FoamData) == "table") then
                    Brewers["Foam"] = FoamData
                end
                if (type(MilkData) == "table") then
                    Brewers["Milk"] = MilkData
                end
                if (type(WaterData) == "table") then
                    Brewers["Water"] = WaterData
                end
            end
        end
    end
end

local function GetActiveCustomers(
    IncludeCustomersBeingServed:boolean?
):({
    {
        ["Name"]:string;
        ["Customer"]:Model;
        ["Order"]:{StringValue};
    }
})
    if (type(IncludeCustomersBeingServed) ~= "boolean") then
        IncludeCustomersBeingServed = false
    end

    local Customers = {}

    for _, Customer:Model in pairs(Workspace:GetChildren()) do 
        if not Customer or not Customer:IsA("Model") then
            continue
        end
        if (Customer.Name ~= "OrderCar") then
            if not Customer:FindFirstChild("Customer") then
                continue
            end
        end
        
        local ServingValue = Customer:FindFirstChild("Serving")
        if not ServingValue or not ServingValue:IsA("StringValue") then
            continue
        end
        if not IncludeCustomersBeingServed then
            if (ServingValue.Value ~= "") and (ServingValue.Value ~= LocalPlayer.Name) then
                --// Already being served by someone else.
                continue
            end
        end
        
        local Order1 = Customer:FindFirstChild("order1")
        local Order2 = Customer:FindFirstChild("order2")
        local Order3 = Customer:FindFirstChild("order3")

        if not Order1 
            or not Order2 
            or not Order3 
            or not Order1:IsA("StringValue")
            or not Order2:IsA("StringValue")
            or not Order3:IsA("StringValue")
        then
            continue
        end

        local Order = {
            Order1.Value;
            Order2.Value;
            Order3.Value;
        }
        local CustomerData = {
            ["Name"] = Customer.Name;
            ["Customer"] = Customer;
            ["Order"] = Order;
        }
        
        table.insert(Customers, CustomerData)
        task.wait()
    end

    return Customers
end

local CupGiverModel = Workspace:WaitForChild("CupGiver")
local CupGiverPrimary = CupGiverModel:WaitForChild("Primary")

local CupGiver = GetPromptData(CupGiverPrimary)
local Brewers = FetchBrewers()
