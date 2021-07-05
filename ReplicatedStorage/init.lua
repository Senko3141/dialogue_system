-- Dialogue Framework
--[[
	TODO: all done
]]

local DialogueFramework = {}
DialogueFramework.__index = DialogueFramework

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Info = require(script:WaitForChild("Info"))
local DialogueUI = script:WaitForChild("Dialogue")
local Config = require(script:WaitForChild("Configuration"))
local Signal = require(script:WaitForChild("Signal"))

function DialogueFramework.new(name)
	if name == nil then return end	
	if Info[name] == nil then return end
	
	local self = setmetatable({}, DialogueFramework)
	self._player = game:GetService("Players").LocalPlayer
	self._name = name
	self._info = Info[name]
	self._stringOn = 1
	self._agreed = false
	
	local uiClone = DialogueUI:Clone()
	self._ui = uiClone

	uiClone.Parent = self._player.PlayerGui
	
	self.Finished = Signal.new()
	
	-- Functions
	self._initResponses = function(self)
		local currentUI = self._ui
		local dialogueInfo = self._info
		
		local currentScope = dialogueInfo[self._stringOn]
		local responses = currentScope.responses
		
		currentUI.Root:TweenPosition(UDim2.new(0.5,0,0.85,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		wait(.2)
		
		currentUI.Root.Responses:TweenPosition(UDim2.new(0.178,0,1.1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		
		for num,response in pairs(responses) do
			currentUI.Root.Responses[tostring(num)].Text = response
		end
		
		-- Init Yes or No
		local yesConnection = nil
		local noConnection = nil
		
		yesConnection = currentUI.Root.Responses["1"].MouseButton1Click:Connect(function()
			yesConnection:Disconnect(); yesConnection = nil;
			noConnection:Disconnect(); noConnection = nil;
			
			self._stringOn += 1
			self:_update()
		end)
		noConnection = currentUI.Root.Responses["2"].MouseButton1Click:Connect(function()
			yesConnection:Disconnect(); yesConnection = nil;
			noConnection:Disconnect(); noConnection = nil;
			
			currentUI.Root.Responses:TweenPosition(UDim2.new(0.178,0,1.8,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			currentUI.Root:TweenPosition(UDim2.new(0.5,0,0.9,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			currentUI.Root.Dialogue.Label.Text = ""
			
			self._agreed = true
			
			-- Destroy
			wait(.5)
			local finalTween = TweenService:Create(currentUI.Root.Dialogue, TweenInfo.new(0.1), {
				BackgroundTransparency = 1
			})
			finalTween:Play()
			finalTween.Completed:Connect(function()
				self._ui:Destroy()
				self._ui = nil

				self:Destroy()
			end)
		end)
	end
	self._update = function(self)
		local currentUI = self._ui
		local dialogueInfo = self._info
		
		if self._stringOn == #dialogueInfo+1 then
			-- finished dialogue			
			currentUI.Root.Responses:TweenPosition(UDim2.new(0.178,0,1.8,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			currentUI.Root:TweenPosition(UDim2.new(0.5,0,0.9,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			currentUI.Root.Dialogue.Label.Text = ""
			
			self._agreed = true
			
			delay(.3, function()
				-- Destroy
				local finalTween = TweenService:Create(currentUI.Root.Dialogue, TweenInfo.new(0.1), {
					BackgroundTransparency = 1
				})
				finalTween:Play()
				finalTween.Completed:Connect(function()
					self._ui:Destroy()
					self._ui = nil

					self:Destroy()
				end)
			end)
			return
		end
		
		local currentScope = dialogueInfo[self._stringOn]
		local text = currentScope.text
		
		-- Setting preqs.
		currentUI.Root.Dialogue.Label.MaxVisibleGraphemes = 0
		currentUI.Root.Dialogue.Label.Text = text
		currentUI.Root.Responses["1"].Text = ""
		currentUI.Root.Responses["2"].Text = ""
		
		local typeConnection;
		local timePassed = 0
		local maxTime = Config.WRITER_INTERVAL * string.len(text)
		
		typeConnection = RunService.RenderStepped:Connect(function(dt)
			if timePassed >= maxTime then
				currentUI.Root.Dialogue.Label.MaxVisibleGraphemes = -1
				
				typeConnection:Disconnect()
				typeConnection = nil
				
				-- Init Responses
				self:_initResponses()
			else
				timePassed += dt
				currentUI.Root.Dialogue.Label.MaxVisibleGraphemes = (timePassed/maxTime)*string.len(text)
			end
		end)
	end
	
	local TweenIn = TweenService:Create(uiClone.Root.Dialogue, TweenInfo.new(0.1), {
		BackgroundTransparency = 0
	})
	TweenIn:Play()
	TweenIn.Completed:Connect(function()
		-- Initing first dialogue.
		self:_update()
	end)
	
	return self
end
function DialogueFramework:Destroy()
	self.Finished:Fire(self._agreed)
	
	self.Finished:Destroy()
	self.Finished = nil
	setmetatable(self, nil)
end


return DialogueFramework
