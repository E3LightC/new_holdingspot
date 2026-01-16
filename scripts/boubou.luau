--// @_x4yz
--// https://www.roblox.com/games/16905845666/Eat-The-Universe-Simulator

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local function DoRebirth()
	local boubou = 0

	while true do 
		for _, v in pairs(workspace.GameSystems.Eatables:GetChildren()) do 
			if not v then
				break
			end
			
			task.spawn(pcall, function()
				ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("SpaceService"):WaitForChild("RF"):WaitForChild("Encounter"):InvokeServer(v)
			end)
			boubou += 1 

			local Mass = LocalPlayer:GetAttribute("TotalMass") or 0

			if ((boubou % 5) == 0) then 
				boubou = 0 
				task.wait()
			end
			if (Mass >= 100000) then 
				task.spawn(pcall, function()
					ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PlayerService"):WaitForChild("RF"):WaitForChild("Rebirth"):InvokeServer()
				end)
				break
			end
		end

		task.wait()
	end
end

while not shared.e do 
	DoRebirth()
	task.wait(0.05)
end
