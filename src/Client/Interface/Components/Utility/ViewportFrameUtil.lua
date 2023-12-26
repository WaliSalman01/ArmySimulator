--[[
    ViewportFrameUtil.lua
    Author(s): Jibran

    Description: ViewportFrameSetup Utility
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)

-- Constant Declarations
local New = Fusion.New

-- Modules
local Interface = StarterPlayerScripts.Interface
local Components = Interface.Components
local Common = Components.Common
local Utility = Components.Utility
local ViewportFrame = require(Common.ViewportFrame)
local ViewportModelUtil = require(Utility.ViewportModelUtil)

local ViewportFrameUtil = {}

-- setting viewportModel inside a new viewport frame
function ViewportFrameUtil:SetupViewportModel(dataTable)
	if not dataTable.ModelReference then return end

	local viewportModel = dataTable.ModelReference:Clone()
	viewportModel:MoveTo(Vector3.new(0,0,0))

	local viewportFrameProps = {
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 0.5,
		Children = {
			viewportModel
		},
	}

	local viewportFrame = ViewportFrame(viewportFrameProps)
	AlignModelUsingUtil(viewportFrame, viewportModel)
	
	return viewportFrame
end

-- using ViewportModel util to align model precisely in viewportFrame
function AlignModelUsingUtil(viewportFrame, viewportModel)
	local viewportModelUtil = ViewportModelUtil.new(viewportFrame, viewportFrame.Camera)
	local cFrame, size = viewportModel:GetBoundingBox()
	viewportModelUtil:SetModel(viewportModel)

	local orientation = CFrame.new()
	local distance = viewportModelUtil:GetFitDistance(cFrame.Position)
	viewportFrame.Camera.CFrame = CFrame.new(cFrame.Position) * orientation * CFrame.new(0, 0, distance)
end

return ViewportFrameUtil