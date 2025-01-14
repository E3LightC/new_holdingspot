--// @_x4yz
--// https://www.roblox.com/games/16526868524/Contagious-Revival

local ReplicatedStorage = game:GetService("ReplicatedStorage")

_G["HitDamageMultiplier"] = 100 --// im assuming this is a multiplier of sorts as it is based on the swing charge ( ( max damage x multiplier/swing charge) ?)
_G["MainSound"] = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Combat").PipeHitAlternate --// hit sound
_G["MainSoundSpeed"] = 1 --// speed of the sound ↑↑↑
_G["FootstepMaterial"] = Enum.Material.DiamondPlate --// floor walking sound

--// hook stuff
local OldNameCall = nil
OldNameCall = hookmetamethod(game, "__namecall", function(Remote, ...)
    local Args = {...}
    local NamecallMethod = getnamecallmethod()

    if not checkcaller() and NamecallMethod == "FireServer" then
        if Args[2] == "Hit" then 
            Args[3] = _G["HitDamageMultiplier"] or Args[3]

            return OldNameCall(Remote, unpack(Args))
        elseif Args[2] == "PlaySound" then 
            Args[6]["Sound"] = _G["MainSound"] or Args[6]["Sound"]
            Args[6]["Speed"] = _G["MainSoundSpeed"] or Args[6]["Speed"]

            return OldNameCall(Remote, unpack(Args))
        elseif Args[2] == "Footstep" then 
            Args[3]["Material"] = _G["FootstepMaterial"] or Args[3]["Material"]

            return OldNameCall(Remote, unpack(Args))
        end
    end

    return OldNameCall(Remote, ...)
end)
