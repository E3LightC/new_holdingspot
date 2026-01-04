--// @_x4yz
--// https://www.roblox.com/games/18968763874/A-Niche-Barista-Game

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack

local BrewersFolder = Workspace:WaitForChild("Brewers")
local FlavoursFolder = Workspace:WaitForChild("Flavours")
local CustomerNPCs = Workspace:WaitForChild("CustomerNPCs")

local function GetPromptData(
	PrimaryPart:BasePart?
):(
	{
		["Attachment"]:Attachment;
		["Prompt"]:ProximityPrompt;
	}
)
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

    for _, Brewer:Model in pairs(BrewersFolder:GetChildren()) do 
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

	return Brewers
end

local function FetchAdders():(
    {
        {
            ["Attachment"]:Attachment;
            ["Prompt"]:ProximityPrompt;
        }
    }
)
	local Adders = {}

	for _, Adder in pairs(Workspace:GetChildren()) do 
        if not Adder or not Adder:IsA("Model") then
            continue
        end
		if (Adder.Name ~= "Adder") then
			continue
		end
		
		local IsType1 = Adder:FindFirstChild("Label") and true or false
		local IsType2 = Adder:FindFirstChild("IceCubeMeshes") and true or false
		local IsType3 = Adder:FindFirstChild("TeaBag") and true or false
		local IsType4 = Adder:FindFirstChild("Chai") and true or false
		local IsType5 = Adder:FindFirstChild("Marshmellow") and true or false
		local IsType6 = Adder:FindFirstChild("Cookie") and true or false

		if IsType1 then
			local Primary = Adder.PrimaryPart or Adder:FindFirstChild("Primary")
			if not Primary then
				continue
			end
			local Filling = Adder:FindFirstChild("Filling")
			if not Filling then
				continue
			end

			local Data = GetPromptData(Primary)
            if (type(Data) ~= "table") then
                continue
            end

			local AdderName = (
				((Filling.Color == Color3.fromRGB(89, 177, 78)) and "Matcha")
				or ((Filling.Color == Color3.fromRGB(35, 35, 35)) and "Boba")
				or ((Filling.Color == Color3.fromRGB(216, 137, 85)) and "Honey")
				or ((Filling.Color == Color3.fromRGB(208, 200, 185)) and "Cream")
			) or ""
			if (AdderName == "") then
				continue
			end

            Adders[AdderName] = Data
			continue
		end

		if IsType2 then
			local IceCubes = Adder:FindFirstChild("IceCubes")
			local Lemons = Adder:FindFirstChild("Lemons")
			if not IceCubes or not Lemons then
				continue
			end

			local IceCubesData = GetPromptData(IceCubes)
			local LemonsData = GetPromptData(Lemons)
            if (type(IceCubesData) ~= "table") then
                continue
            end
            if (type(LemonsData) ~= "table") then
                continue
            end

			Adders["IceCubes"] = IceCubesData
			Adders["Lemons"] = LemonsData
			continue
		end

		if IsType4 then
			local Chai = Adder:FindFirstChild("Chai")
			local Chocolate = Adder:FindFirstChild("Chocolate")
			local Cinnamon = Adder:FindFirstChild("Cinnamon")
			if not Chai or not Chocolate or not Cinnamon then
				continue
			end

			local ChaiData = GetPromptData(Chai)
			local ChocolateData = GetPromptData(Chocolate)
			local CinnamonData = GetPromptData(Cinnamon)
            if (type(ChaiData) ~= "table") then
                continue
            end
            if (type(ChocolateData) ~= "table") then
                continue
            end
            if (type(CinnamonData) ~= "table") then
                continue
            end

			Adders["Chai"] = ChaiData
			Adders["Chocolate"] = ChocolateData
			Adders["Cinnamon"] = CinnamonData
			continue
		end

		if IsType3 or IsType5 or IsType6 then
			local Primary = Adder.PrimaryPart or Adder:FindFirstChild("Primary")
			if not Primary then
				continue
			end

			local Data = GetPromptData(Primary)
            if (type(Data) ~= "table") then
                continue
            end

			local Name = (
				(IsType3 and "TeaBag")
				or (IsType5 and "Marshmellow")
				or (IsType6 and "Cookie")
			)
			Adders[Name] = Data
			continue
		end
	end

	return Adders
end

local function FetchFlavours():(
    {
        {
            ["Attachment"]:Attachment;
            ["Prompt"]:ProximityPrompt;
        }
    }
)
	local Flavours = {}

    for _, Pump:Model in pairs(FlavoursFolder:GetChildren()) do 
        if not Pump or not Pump:IsA("Model") then
            continue
        end

        local FlavourValue = Pump:FindFirstChild("Flavour")
        local Primary = Pump:FindFirstChild("Primary")
        if not Primary then
            continue
        end
        local Data = GetPromptData(Primary)
        if (type(Data) ~= "table") then
            continue
        end

		local Name = (FlavourValue and FlavourValue.Value) or ((Pump.Name == "CandyCaneFlavour") and "CandyCane")
        Flavours[Name] = Data
        continue
    end

	return Flavours
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
	local CustomerTable = CustomerNPCs:GetChildren()
	if Workspace:FindFirstChild("OrderCar") then
		table.insert(CustomerTable, Workspace:WaitForChild("OrderCar", 0.5))
	end

    for _, Customer:Model in pairs(CustomerTable) do 
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
local Adders = FetchAdders()
local Flavours = FetchFlavours()
