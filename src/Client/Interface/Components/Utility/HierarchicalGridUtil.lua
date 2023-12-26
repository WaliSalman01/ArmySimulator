--[[
    HierarchicalGridUtil.lua
    Author(s): Jibran

    Description: Hierarchical Grid Layout System
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages: Folder = ReplicatedStorage.Packages

-- Class
local HierarchicalGridUtil = {}
HierarchicalGridUtil.__index = HierarchicalGridUtil
HierarchicalGridUtil.ClassName = "HierarchicalGridUtil"

-- Public Constructors
function HierarchicalGridUtil.new(gridLength, gridHeight)
	local self = setmetatable({}, HierarchicalGridUtil)

	self._gridHeight = gridHeight
	self._gridLength = gridLength
	self.paddingMargin = 0.2
	self.cellsMargin = 1 - self.paddingMargin
	self.paddingHorizontal = self.paddingMargin / self._gridLength
	self.paddingVertical = self.paddingMargin / self._gridHeight
	self.cellSizeHorizontal = self.cellsMargin / self._gridLength
	self.cellSizeVertical = self.cellsMargin / self._gridHeight
	self._grid = self:GetGridTemplate()

	return self
end

-- creating Empty Grid Template for Grid Locations
function HierarchicalGridUtil:GetGridTemplate()
	local gridTemplate = {}
	for row = 1, self._gridHeight do
		gridTemplate[row] = {}
		for column = 1, self._gridLength do
			gridTemplate[row][column] = false
		end
	end

	return gridTemplate
end

-- reset grid values
function HierarchicalGridUtil:ResetGrid()
	for row = 1, self._gridHeight do
		for column = 1, self._gridLength do
			self._grid[row][column] = false
		end
	end
end

-- Checking for grid point with given StorageLoad
function HierarchicalGridUtil:GetAvailableGridPoint(storageLoad, objectName)
	local gridPointExits, pointX, pointY = self:CheckIfAlreadyExists(objectName)

	if gridPointExits then
		return pointX, pointY
	end

	for row = 1, self._gridHeight do
		for column = 1, self._gridLength do
			if self._grid[row][column] == false then
				if self:IsGridPointAvailable(storageLoad, row, column) then
					return row, column
				end
			end
		end
	end
	return false
end

-- checks if the rendered object exists in grid
function HierarchicalGridUtil:CheckIfAlreadyExists(objectName)
	for row = 1, self._gridHeight do
		for column = 1, self._gridLength do
			if self._grid[row][column] == objectName then
				return true, row, column
			end
		end
	end
	return false
end

-- remove from grid if count is 0
function HierarchicalGridUtil:RemoveFromGrid(objectName)
	for row = 1, self._gridHeight do
		for column = 1, self._gridLength do
			if self._grid[row][column] == objectName then
				self._grid[row][column] = false
			end
		end
	end
end

-- Calculating cell size based on storage load
function HierarchicalGridUtil:GetCellSize(storageLoad)
	local sizeX = storageLoad.x * (self.cellSizeHorizontal + self.paddingHorizontal)
	local sizeY = storageLoad.y * (self.cellSizeVertical + self.paddingVertical)

	return sizeX, sizeY
end

-- getting position on UI for available grid
function HierarchicalGridUtil:GetCellPosition(gridPointX, gridPointY)
	local positionX = (gridPointY - 1) * (self.cellSizeHorizontal + self.paddingHorizontal)
	local positionY = (gridPointX - 1) * (self.cellSizeVertical + self.paddingVertical)
	return positionX, positionY
end

-- marking cells used as true
function HierarchicalGridUtil:FillCellPosition(gridPointX, gridPointY, storageLoad, objectName)
	for row = gridPointX, gridPointX + storageLoad.y - 1 do
		for column = gridPointY, gridPointY + storageLoad.x - 1 do
			self._grid[row][column] = objectName
		end
	end
end

--Checking if GridPoint being traversed can handle StorageLoad
function HierarchicalGridUtil:IsGridPointAvailable(storageLoad, row, column)
	local width = storageLoad.x - 1
	local height = storageLoad.y - 1

	--checking if space goes over limit of grid
	if row + height > self._gridHeight or column + width > self._gridLength then
		return false
	end

	--checking space available in row
	for rowIndex = row, row + height do
		if self._grid[rowIndex][column] ~= false then
			return false
		end
	end

	--checking space available in column
	for columnIndex = column, column + width do
		if self._grid[row][columnIndex] ~= false then
			return false
		end
	end

	return true
end

return HierarchicalGridUtil
