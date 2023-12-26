--[[
    InventoryController.lua
    Author(s): Justin (synnull)
    10/17/23

    Description: Manages client side inventory
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- player
local Player = Knit.Player

-- Knit
local InventoryController = Knit.CreateController({
	Name = "InventoryController",
})

-- Public
function InventoryController:GetInventory(): {}
	local inventoryData: {} = self._inventoryService:GetInventory()
	return if inventoryData then inventoryData else nil
end


function InventoryController:ToggleInventory(status: boolean, tab:string)
	if not status then
		status = not self.InventoryOpen:get()
	end
	self.InventoryOpen:set(status)
	if tab then
		self._inventoryUI._currentTab:set(tab)
	end
	self.RecordsOpen:set(false)
	self.EditorOpen:set(false)
	self.MapOpen:set(false)
	self._cameraController:Blur(status == true and 15 or 0)
	self._mainUI:ToggleMainButtons(not status)
end

function InventoryController:ToggleRecords(status: boolean)
	if not status then
		status = not self.RecordsOpen:get()
	end
	self.RecordsOpen:set(status)
	self.InventoryOpen:set(false)
	self.EditorOpen:set(false)
	self.MapOpen:set(false)
	self._cameraController:Blur(status == true and 15 or 0)
	self._mainUI:ToggleMainButtons(not status)
end

function InventoryController:ToggleMap(status: boolean)
	if not status then
		status = not self.MapOpen:get()
	end
	self.MapOpen:set(status)
	self.RecordsOpen:set(false)
	self.InventoryOpen:set(false)
	self.EditorOpen:set(false)
	self._cameraController:Blur(status == true and 15 or 0)
	self._mainUI:ToggleMainButtons(not status)
end

function InventoryController:ToggleEditor(status: boolean, wearableName:string)
	if not status then
		status = not self.EditorOpen:get()
	end
	self.Wearable:set(wearableName)
	self.EditorOpen:set(status)
	self.InventoryOpen:set(false)
	self.RecordsOpen:set(false)
	self.MapOpen:set(false)
	self._cameraController:Blur(status == true and 15 or 0)
	self._mainUI:ToggleMainButtons(not status)
end

function InventoryController:InventoryChanged(data, type:string)
	-- Get latest inventory
	local inventory: {} = data or self:GetInventory()
	if not inventory then
		return
	end
	-- Update the ui here
	self._inventoryUI._currentInventoryItems:set(inventory)
	self._editorUI._currentColors:set(inventory.Colors)
	-- Turn on notification
	self._mainUI:ToggleNotification("Inventory")
	self._inventoryUI:ToggleNotification("Tab"..type)
end

function InventoryController:RecordsChanged(data, type:string)
	if not data then return end
	-- Send data to ui to update
	if type == "Obby" then
		self._recordsUI._currentObbyRecords:set(data)
	end
	-- Turn on notification
	self._mainUI:ToggleNotification("Records")
end
-- Knit Startup
function InventoryController:KnitInit()
	-- Controllers
	self._cameraController = Knit.GetController("CameraController")
    -- Services
    self._inventoryService = Knit.GetService("InventoryService")
end

function InventoryController:KnitStart()
	-- Listeners

	self._inventoryService.InventoryChanged:Connect(function()
		self:InventoryChanged()
	end)
end


return InventoryController