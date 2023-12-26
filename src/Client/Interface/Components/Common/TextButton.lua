--[[
    TextButton.lua
    Author(s): Jibran

    Description: Sample Text Button Template with Fusion
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
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

-- creating template text button based on props
return function(props)
	return New "TextButton" {
		Name = props.Name,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 0,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		Text = props.Text,
		TextSize = props.TextSize or 28,
		TextScaled = true,
		Font = props.Font,
		FontFace = props.FontFace,
		Visible = props.Visible, 
		TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
		[Children] = {
			Contraintutils:CreateCorner(props),
			Contraintutils:CreatePadding(props),
			Contraintutils:CreateTextSizeConstraint(props),
			Contraintutils:CreateAspectRatioConstraint(props)
		},
		[OnEvent "Activated"] = props.callback,
	}
end