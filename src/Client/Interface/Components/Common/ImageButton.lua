--[[
    ImageButton.lua
    Author(s): Jibran

    Description: Sample Image Button Template with Fusion
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local Maid = require(Packages.Maid)

-- Modules
local Interface = StarterPlayerScripts.Interface
local Components = Interface.Components
local Utility = Components.Utility
local Contraintutils = require(Utility.ContraintUtils)

--- Constant Declarations
local New = Fusion.New
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children
local Cleanup = Fusion.Cleanup
local Computed = Fusion.Computed
local Value = Fusion.Value
local Spring = Fusion.Spring
-- Vars
local Rollovers = {}
local ScaleFactor = 1.2

local function Lerp(a, b, t)
	local lerp = a + (b - a) * t
	return lerp
end

-- processing input on pressed or hold
local function ProcessDownInput(props)
	if props.HoldDuration then
		if props.HoldLock:get() then
			return
		end
		props.HoldLock:set(true)
		if props.StartCallback then
			props.StartCallback(props)
		end
		local initialValue = props.HoldValue:get()
		for index = 0, props.HoldDuration, 0.01 do
			task.wait(0.01)
			props.HoldValue:set(Lerp(initialValue, 0, index / props.HoldDuration))
			if not props.HoldLock:get() then
				props.HoldValue:set(1)
				return
			end
		end
		if props.Callback then
			props.Callback(props)
		end
	else
		if props.Callback then
			props.Callback(props)
		end
	end
end

-- processing input on pressed up or hold up
local function ProcessUpInput(props)
	if props.HoldDuration then
		if props.HoldLock:get() then
			props.HoldLock:set(false)
			props.HoldValue:set(1)
			if props.CancelCallback then
				props.CancelCallback(props)
			end
		end
	end
end

-- creating template text button based on props
return function(props)
	-- setting keyboard bindings for buttons that need it
	local buttonMaid = Maid.new()
	if props.KeyCode then
		buttonMaid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == props.KeyCode then
					ProcessDownInput(props)
				end
			end
		end))

		buttonMaid:Add(UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == props.KeyCode then
					ProcessUpInput(props)
				end
			end
		end))
	end

	-- Check for rollover, if so add scaling
	if props.rollover and not props.customrollover then
		props.Rand = math.random(0, 99999)
		Rollovers[props.Name..tostring(props.Rand)] = Value(0)
	end

	return New "ImageButton"{
		Name = props.Name,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = Spring(Computed(function()
			if not Rollovers[props.Name..tostring(props.Rand)] then return props.Size end
			if Rollovers[props.Name..tostring(props.Rand)]:get() == 1 then
				return UDim2.new(props.Size.X.Scale * ScaleFactor, 
				props.Size.X.Offset * ScaleFactor, 
				props.Size.Y.Scale * ScaleFactor, 
				props.Size.Y.Offset * ScaleFactor
			)
			else
				return props.Size
			end
		end), 100),
		LayoutOrder = props.LayoutOrder or 0,
		ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
		Image = props.Image or "",
		ZIndex = props.ZIndex or 5,
		HoverImage = props.HoverImage or "",
		PressedImage = props.PressedImage or "",
		ImageTransparency = props.ImageTransparency or 0,
		Visible = props.Visible,
		Rotation = props.Rotation or 0,
		ScaleType = props.ScaleType or Enum.ScaleType.Stretch,
		[OnEvent "Activated"] = props.callback,
		[OnEvent "MouseEnter"] = function()
			if not props.rollover then return end
			if not props.customrollover then
				Rollovers[props.Name..tostring(props.Rand)]:set(1)
			end
			props.rollover()
		end,
		[OnEvent "MouseLeave"] =  function()
			if not props.rollout then return end
			if not props.customrollover then
				Rollovers[props.Name..tostring(props.Rand)]:set(0)
			end
			props.rollout()
		end,
		[Children] = {
			props.Children,
		},
	}
end
