--[[
    ContraintUtils.lua
    Author(s): Jibran

    Description: General Contraints for UI in Fusion
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)

-- Constant Declarations
local New = Fusion.New

local ContraintUtils = {}

-- creating UI corner Element
function ContraintUtils:CreateCorner(props)
	if props.CornerRadius then
		return New "UICorner" {
			CornerRadius = props.CornerRadius,
		}
	end
end

-- creating UI padding Element
function ContraintUtils:CreatePadding(props)
	if props.PaddingBottom or props.PaddingLeft or props.PaddingRight or props.PaddingTop then
		return New "UIPadding" {
			PaddingBottom = props.PaddingBottom or UDim.new(0, 0),
			PaddingLeft = props.PaddingLeft or UDim.new(0, 0),
			PaddingTop = props.PaddingTop or UDim.new(0, 0),
			PaddingRight = props.PaddingRight or UDim.new(0, 0),
		}
	end
end

function ContraintUtils:CreateAspectRatioConstraint(props)
	if props.AspectRatio then
		return New "UIAspectRatioConstraint" {
			AspectRatio = props.AspectRatio
		}
	end
end

-- creating UI Text Size Constraint Element
function ContraintUtils:CreateTextSizeConstraint(props)
	if props.MinTextSize or props.MaxTextSize then
		return New "UITextSizeConstraint" {
			MaxTextSize = props.MaxTextSize or 100,
			MinTextSize = props.MinTextSize or 1,
		}
	end
end

return ContraintUtils