--[[
    DataWriteLib.lua
    Author: Aaron Jay (seyai)
    Description: Write libs to safely mutate data for player profile through defined
    methods as opposed to direct manipulations. These methods also automatically propogate
    to the client via ReplicaService, and can be listened to using DataController

]]
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Shared = game.ReplicatedStorage.Shared
local ShopData = require(Shared.ShopData)

local DEBUG_TAG = "[" .. script.Name .. "]"

-- verify these on the server and stuff
local DataWriteLib = {
	IncrementStitches = function(replica, amount)
		replica:IncrementValue({ "Stitches" }, amount)
	end,

	AddItemToInv = function(replica, itemid, amt)
		local existing = replica.Data.Inventory[itemid]
		if existing then
			replica:IncrementValue({ "Inventory", itemid }, amt)
		else
			replica:SetValue("Inventory", itemid, amt) -- // create new entry
		end
	end,

	AddColorToInv = function(replica, colorPalette, colorData)
		local existing = replica.Data.Inventory.Colors[colorPalette]
		if not existing then
			replica:SetValue({ "Inventory", "Colors", colorPalette }, colorData) -- // create new entry
			if RunService:IsClient() then Knit.GetController("InventoryController"):InventoryChanged(replica.Data.Inventory, "Colors") end
		end
	end,

	AddTeddyToInv = function(replica, teddyIndex)
		local existing = replica.Data.Inventory.Teddies[teddyIndex]
		if existing == 0 then
			replica:SetValue({ "Inventory", "Teddies", teddyIndex}, 1) -- // create new entry
			if RunService:IsClient() then Knit.GetController("InventoryController"):InventoryChanged(replica.Data.Inventory, "Teddies") end
		end
	end,
	-- this expects a positive number for amount
	RemoveItemFromInv = function(replica, itemid, amt)
		local existing = replica.Data.Inventory[itemid]
		if existing then
			replica:IncrementValue({ "Inventory", itemid }, -amt)
		end
	end,

	PurchaseItem = function(replica, shopid, itemamt)
		--// get price info from ShopInfo module
		local shopInfo = ShopData:Get(shopid)
		if shopInfo then
			local clampedAmt = math.clamp(itemamt, 1, 100)
			local integerAmt = math.floor(clampedAmt) or 1
			local price = shopInfo.Price * integerAmt

			if replica.Data.Stitches >= price then
				replica:Write("IncrementStitches", -price)
				--// get item data to insert (if unique, more work required. generic, just insert item id w/ amount increment)
				replica:Write("AddItemToInv", shopid, itemamt)
				print("Added item to inventory: " .. shopid)
				print(replica.Data.Stitches)
				return true
			else
				warn("Not enough Stitches, missing " .. tostring(price - replica.Data.Stitches))
			end
		end
		return false
	end,

	-- Unlock zone
	UnlockZone = function(replica, zoneName: string)
		-- Get zones already unlocked
		local unlockedZones: {} = replica.Data.UnlockedZones
		-- Verify unlocked zone isn't already in list
		if unlockedZones and not table.find(unlockedZones, zoneName) then
			-- Set array
			replica:ArrayInsert("UnlockedZones", zoneName)
		end
	end,

	-- Obby Checkpoint
	HitCheckPoint = function(replica, level: string, checkpoint: number)
		-- Get checkpoint data
		local lastCheckpoint = replica.Data.ObbyCheckPoints[level].CheckPoint
		local index = table.find(replica.Data.ObbyCheckPoints, level)
		if lastCheckpoint < checkpoint then
			replica:SetValue("ObbyCheckPoints." .. level .. ".CheckPoint", checkpoint)
		end
	end,
	-- Obby Finish
	HitFinish = function(replica, level: string, newCompletionRecord: number)
		replica:SetValue("ObbyCheckPoints." .. level .. ".Completions", newCompletionRecord)
		replica:SetValue("ObbyCheckPoints." .. level .. ".CheckPoint", 0)
	end,
	-- Obby Completion time
	SetCompletionTime = function(replica, level: string, newTime: number)
		local bestTime = replica.Data.ObbyCheckPoints[level].BestTime
		if bestTime == 0 or bestTime > newTime then
			replica:SetValue("ObbyCheckPoints." .. level .. ".BestTime", newTime)
			if RunService:IsClient() then Knit.GetController("InventoryController"):RecordsChanged(replica.Data.ObbyCheckPoints, "Obby") end
		end
	end,
	SetAtelierCompletionTime = function(replica, level: number, newTime: number)
		local bestTime = replica.Data.AtelierTimes[level]
		if bestTime == 0 or bestTime > newTime then
			replica:SetValue("AtelierTimes", level , newTime)
			if RunService:IsClient() then Knit.GetController("InventoryController"):RecordsChanged(replica.Data.AtelierTimes, "Atelier") end
			print(replica.Data)
		end
	end,
	-- Update Pets Configuration
	UpdatePetsConfig = function(replica, petsData: table) 
        replica:SetValue("PetsConfiguration", petsData)
    end,
  
    -- Obby Checkpoint time
    SetCheckPointTime = function(replica, level:string, checkPoint:number, newTime:number)
        local bestTime = replica.Data.ObbyCheckPoints[level].CheckPointTimes[checkPoint]
        if not bestTime or bestTime > newTime then
            replica:SetValue({"ObbyCheckPoints", level, "CheckPointTimes", checkPoint}, newTime)
        end
    end,
}

return DataWriteLib
