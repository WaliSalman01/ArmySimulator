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

-- Modules
local Interface = StarterPlayerScripts.Interface
local Components = Interface.Components
local Utility = Components.Utility
local Contraintutils = require(Utility.ContraintUtils)

--- Constant Declarations
local New = Fusion.New
local Children = Fusion.Children

-- creating template text button based on props
return function(props)
	return New "ImageLabel"{
		Name = props.Name,
		BackgroundColor3 = props.BackgroundColor3 or Color3.new(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder or 0,
		ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
		Image = props.Image or "",
		ZIndex = props.ZIndex or 5,
		ImageTransparency = props.ImageTransparency or 0,
		Rotation = props.Rotation or 0,
		Visible = props.Visible or true,
		[Children] = {
			Contraintutils:CreateAspectRatioConstraint(props),
			Contraintutils:CreateCorner(props),
			props.Children,
		},
	}
end
