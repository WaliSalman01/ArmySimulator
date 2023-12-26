--[[
    TextButton.lua
    Author(s): Jibran

    Description: Sample Text Label Template with Fusion
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

-- creating template text label based on props
return function(props)
	return New "TextLabel" {
		Name = props.Name,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 0,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder,
		Text = props.Text,
		TextSize = props.TextSize or 28,
		TextScaled = props.TextScaled,
		TextWrapped = props.TextWrapped,
		Font = props.Font,
		FontFace = props.FontFace,
		ZIndex = props.ZIndex,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
		TextStrokeColor3 = props.TextStrokeColor3 or Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = props.TextStrokeTransparency or 1,
		TextTransparency = props.TextTransparency or 0,
		[Children] = {
			Contraintutils:CreateCorner(props),
			Contraintutils:CreatePadding(props),
			Contraintutils:CreateTextSizeConstraint(props),
			Contraintutils:CreateAspectRatioConstraint(props)
		},
		Visible = props.Visible,
		[Children] = {
			props.Children,
		},
	}
end