--[[
	@Author: Jibran
	@Description: Enables dragging/Dropping on GuiObjects. Supports both mouse and touch.
--]]

-- Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local DraggableUI = {}
DraggableUI.__index = DraggableUI

local IsDragging = false
-- Sets up a new draggable object
function DraggableUI.new(Object, draggingFrame, cutoutsFrame, gameInProgress)
	local self = {}
	self.Object = Object
	self.DragStarted = nil
	self.DragEnded = nil
	self.Dragged = nil
	self.Dragging = false
	self._gameInProgress = gameInProgress
	self.DraggingFrame = if draggingFrame then draggingFrame else Object.Parent.Parent
	self.CutoutsFrame = cutoutsFrame
	self.Object.Destroying:Connect(function()
		self:Disable()
	end)
	setmetatable(self, DraggableUI)
	self:Enable()
	return self
end

-- Enables dragging
function DraggableUI:Enable()
	local object = nil
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	local preparingToDrag = false
	local screen_size = nil
	local cutouts = self.CutoutsFrame

	-- Updates the element
	local function update(input)
		local delta = input.Position
		local newPosition = UDim2.fromScale(delta.X / screen_size.X, delta.Y / screen_size.Y)
		object.Position = newPosition

		local guiObjects =
			game.Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
		local currentCutout = updateCutouts(guiObjects)

		return newPosition, currentCutout
	end

	function updateCutouts(cutoutTable)
		local updatedCutouts = {}
		local currentCutout = ""
		for _, item in cutoutTable do
			if item.Parent == cutouts then
				table.insert(updatedCutouts, item)
			end
		end
		if #updatedCutouts > 1 then
			for index, cutout in pairs(updatedCutouts) do
				if cutout.ZIndex == 3 then
					currentCutout = cutout
					break
				end
			end
		elseif #updatedCutouts == 1 then
			currentCutout = updatedCutouts[1]
		end

		for _, cutout in pairs(cutouts:GetChildren()) do
			if currentCutout == cutout then
				cutout.ImageTransparency = 0.8
			else
				cutout.ImageTransparency = 1
			end
		end

		return currentCutout
	end

	local function updateEnd(currentCutout)
		object:Destroy()
		if currentCutout and currentCutout.Name then
			Knit.GetController("PuzzleController"):DroppedItem(self.Object, currentCutout)
		end
		updateCutouts({})
	end

	self.InputBegan = self.Object.InputBegan:Connect(function(input)
		if not self._gameInProgress:get() then
			return
		end
		if IsDragging then
			return
		end
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			preparingToDrag = true
			IsDragging = true
			object = self.Object:Clone()
			object.Parent = self.DraggingFrame
			local sizeX = object.Size.X.Scale / 2
			local sizeY = object.Size.Y.Scale / 2
			object.Size = UDim2.fromScale(sizeX, sizeY)
			screen_size = workspace.CurrentCamera.ViewportSize
			object.Position = UDim2.fromScale(0.5, 2)

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and (self.Dragging or preparingToDrag) then
					self.Dragging = false
					connection:Disconnect()
					updateEnd(self.currentCutout)

					if self.DragEnded and not preparingToDrag then
						self.DragEnded()
					end
					preparingToDrag = false
					IsDragging = false
				end
			end)
		end
	end)

	self.InputChanged = self.Object.InputChanged:Connect(function(input)
		if not self._gameInProgress:get() then
			return
		end
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)

	self.InputChanged2 = UserInputService.InputChanged:Connect(function(input)
		if not self._gameInProgress:get() then
			return
		end
		if preparingToDrag then
			preparingToDrag = false

			if self.DragStarted then
				self.DragStarted()
			end

			self.Dragging = true
			dragStart = input.Position
			startPos = object.Position
		end

		if input == dragInput and self.Dragging then
			local newPosition, cutout = update(input)
			self.currentCutout = cutout

			if self.Dragged then
				self.Dragged(newPosition)
			end
		end
	end)
end

-- Disables dragging
function DraggableUI:Disable()
	self.InputBegan:Disconnect()
	self.InputChanged:Disconnect()
	self.InputChanged2:Disconnect()

	if self.Dragging then
		self.Dragging = false

		if self.DragEnded then
			self.DragEnded()
		end
	end
end

return DraggableUI
