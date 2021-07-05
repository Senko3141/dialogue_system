-- Dialogue Client

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local DialogueFramework = require(ReplicatedStorage:WaitForChild("DialogueFramework"))

ProximityPromptService.PromptTriggered:Connect(function(obj, plr)
	local Dialogue = DialogueFramework.new(obj:GetAttribute("Name"))
	
	Dialogue.Finished:Connect(function(response)
		if response then
			-- Accepted
			print"finished dialogue; agreed to final"
			Dialogue = nil
		end
	end)
end)
