--[[
    ImageButton.lua
    Author(s): Jibran

    Description: Sample Image Button Template with Fusion
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)

-- Modules
local Interface = StarterPlayerScripts.Interface
local Components = Interface.Components
local Utility = Components.Utility
local Contraintutils = require(Utility.ContraintUtils)

--- Constant Declarations
local New = Fusion.New
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

-- creating template viewport Frame based on props
return function(props)
	local viewPortCamera = Instance.new("Camera")
	viewPortCamera.CFrame = CFrame.new()
	return New "ViewportFrame"{
		Name = props.Name,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder or 0,
		CurrentCamera = viewPortCamera,
		[OnEvent"Activated"] = props.callback,

		[Children] = {
			Contraintutils:CreateAspectRatioConstraint(props),
			props.Children,
			viewPortCamera,
			New("UICorner")({
				CornerRadius = UDim.new(.1, 0),
			}),
		}

	}
end
