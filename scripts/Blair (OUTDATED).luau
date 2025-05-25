--// @_x4yz
--// currently just outputs stuff to developer console (f9, /console)
--// likely outdated

local Map = workspace:FindFirstChild("Map") or workspace:WaitForChild("Map", math.huge)
local function GetMapObject(Name:string):Instance?
    if typeof(Name) == "string" then
        return Map:FindFirstChild(Name) or Map:WaitForChild(Name, math.huge)
    end

    return false
end

local Zones = GetMapObject("Zones")
local Orbs = GetMapObject("Orbs")
local Prints = GetMapObject("Prints")

local function GetZones()
    local Table = {}
    
    for _, Zone in pairs(Zones:GetChildren()) do 
        if Zone and Zone:IsA("BasePart") then 
            table.insert(Table, Zone)
        end
    end

    return Table
end
local function GetZoneTemp(ZoneArg:BasePart)
    if ZoneArg and ZoneArg:IsA("BasePart") and ZoneArg:IsDescendantOf(Zones) then 
        local TemperatureValue:NumberValue

        for _, NumValue in pairs(ZoneArg:GetChildren()) do 
            if NumValue and NumValue:IsA("NumberValue") and (string.find(NumValue.Name, "Temperature")) then
                TemperatureValue = NumValue
                break
            end
        end

        return true, TemperatureValue
    end

    return false
end

local function Analyze()
    local ZonesTable:{any} = GetZones()
    local Temps:{any} = {}

    local OrbsExist = false
    local PrintsExist = false

    local MainString:string = tostring([[

            [][][][][][][][][][][][][][][][][][]

            [Orbs Exist]: %s
            [Fingerprints Exist]: %s
            [Lowest Temperature]: %s 
                -/ [Zone]: %s

            [][][][][][][][][][][][][][][][][][]
    ]])

    for _, Zone:BasePart in pairs(ZonesTable) do 
        if Zone and Zone:IsA("BasePart") then
            local Success:boolean, Temp:NumberValue = GetZoneTemp(Zone)

            if Success and Temp and Temp:IsA("NumberValue") then 
                table.insert(Temps, Temp)
            end
        end
    end

    if #Temps >= 1 then
        table.sort(Temps, function(Temperature1:NumberValue, Temperature2:NumberValue)
            return Temperature1.Value < Temperature2.Value
        end)
    else
        Temps[1] = "Unknown"
    end

    if #Orbs:GetChildren() >= 1 then 
        OrbsExist = true
    end
    if #Prints:GetChildren() >= 1 then
        PrintsExist = true
    end

    local StringToOutput:string = MainString:format(
        tostring(OrbsExist),
        tostring(PrintsExist),
        (function()
            if Temps[1] == "Unknown" or not Temps[1] then 
                return "Unknown"
            else
                return Temps[1].Value
            end
        end)(),
        (function()
            if Temps[1] == "Unknown" or not Temps[1] then 
                return "Unknown"
            else
                task.spawn(function()
                    Temps[1].Parent.Transparency = 0
                    
                    local Highlight = Instance.new("Highlight")
                    Highlight.Parent = Temps[1].Parent

                    task.wait(1)
                    Temps[1].Parent.Transparency = 0.5
                    Highlight:Destroy()
                end)
                return Temps[1].Parent.Name
            end
        end)()
    )
    
    warn(StringToOutput)
end

task.spawn(Analyze)
