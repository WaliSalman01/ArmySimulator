--[[
    SitchesService.lua
    Author: Justin (synnull)

    Description: Manage player stitches (currency)
]]
-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Utils = require(ReplicatedStorage.Shared.Utils)
local BridgeNet = require(Packages.BridgeNet2)
local BadgeData = require(ReplicatedStorage.ReplicatedData.Badges)

-- Vars
local RESPAWN_TIME: number = 30 -- Stitch respawn time
local GLOBAL_STITCH_UPDATE_TICK: number = 15 -- How long between updates
local HYPER_STITCH_MULTIPLIER = 2
local Leaderboards: Folder = workspace:FindFirstChild("Leaderboards")

local StitchesService = Knit.CreateService({
	Name = "StitchesService",
	Client = {
		StitchCollected = Knit.CreateSignal(),
	},
})

-- Server sided Stitch increment
function StitchesService:AddStitches(player: Player, amount: number)
	if not player or not amount then
		return
	end
	local container = self._playerService:GetContainer(player)
	local updatedAmount = amount
	if self._petService:IsHyperStitches(player) then
		updatedAmount *= HYPER_STITCH_MULTIPLIER
	end
	if container then
		container.Replica:Write("IncrementStitches", updatedAmount)
		-- Add to our global count to be added on next loop
		self._stitchesToAddToGlobalCount += updatedAmount
		-- Add to queue to be added on next server tick
		self._playerCollectedStitches[player] += 1
		-- Fire to player to update their hud
		self.Client.StitchCollected:Fire(player, container.Replica.Data.Stitches)
	end
end

-- Returns player Stitch count
function StitchesService:GetStitches(player: Player)
	if not player then
		return
	end

	local container = self._playerService:GetContainer(player, true)
	return container.Replica.Data.Stitches or 0
end

function StitchesService:KnitStart()
	-- Vars
	self._guids = {}
	self._stitchesToAddToGlobalCount = 0

	-- Spawn stitches when player joins
	Players.PlayerAdded:Connect(function(player: Player)
		self:SetupStitchSpawns(player)
		self._playerCollectedStitches[player] = 0
	end)
	-- Catch players before PlayerAdded is set
	task.delay(4, function()
		for _, player in ipairs(Players:GetPlayers()) do
			self:SetupStitchSpawns(player)
			self._playerCollectedStitches[player] = 0
		end
	end)

	-- Pull global stitch count
	self._gDataStore = DataStoreService:GetGlobalDataStore()
	self._globalStitchCount = self._gDataStore:GetAsync("GlobalStitches")
	self:UpdateGlobalStitchCount()
	-- Pull global player stiches
	self._gLeaderDataStore = DataStoreService:GetOrderedDataStore("Leaderboard")
	self:UpdateGlobalPlayerStitchCount()

	-- Update global value periodically
	task.spawn(function()
		while task.wait(GLOBAL_STITCH_UPDATE_TICK) do
			-- Update global player leaders

			self:UpdateGlobalPlayerStitchCount()
			-- If we have any queued stitches, add to global
			if self._stitchesToAddToGlobalCount == 0 then
				continue
			end
			self:UpdateGlobalStitchCount()
		end
	end)
end

-- Updates the singular global value of all stitches collected
function StitchesService:UpdateGlobalStitchCount()
	self._gDataStore:IncrementAsync("GlobalStitches", self._stitchesToAddToGlobalCount)
	self._globalStitchCount = self._gDataStore:GetAsync("GlobalStitches")
	--print("New global count: " .. self._globalStitchCount)
	self._stitchesToAddToGlobalCount = 0
	self:UpdateGlobalLeaderBoard()
end

function StitchesService:CheckForCollectedStitches()
	for player, stitches in self._playerCollectedStitches do
		if stitches <= 0 then
			continue
		end
		-- Add to leaderboard store (pcall to be safe)
		task.spawn(function()
			pcall(function()
				self._gLeaderDataStore:IncrementAsync(player.UserId, stitches)
			end)
		end)
	end
end

-- Check for collect x Stitches badges
function StitchesService:CheckForBadge(player: Player)
	for stitchRequirement, badgeID in BadgeData.CollectStitches do
		if self:GetStitches(player) >= stitchRequirement then
			self._badgeAwardingService:AwardBadge(player, badgeID)
		end
	end
end

-- Updates player leaderboard
function StitchesService:UpdateGlobalPlayerStitchCount()
	-- Check if there are any stitches collected since last tick
	self:CheckForCollectedStitches()
	-- Player leaderboard setup
	local smallestFirst = false
	local numberToShow = 10
	local pages = self._gLeaderDataStore:GetSortedAsync(smallestFirst, numberToShow)
	--Get data
	local topTen = pages:GetCurrentPage()
	for rank, data in ipairs(topTen) do
		local name = data.key
		local points = data.value
		--print(name .. " is ranked #" .. rank .. " with " .. points .. "points")
	end
	self:UpdateGlobalPlayerLeaderBoard(topTen)
end

-- Updates the visual player leaderboard in-game
function StitchesService:UpdateGlobalPlayerLeaderBoard(topTen: {})
	for _, leaderboard: Model in Leaderboards:GetChildren() do
		if leaderboard:HasTag("GlobalPlayerLeaderboard") then
			local surfaceGui: SurfaceGui = leaderboard.PrimaryPart:FindFirstChildWhichIsA("SurfaceGui")
			if not surfaceGui then
				continue
			end
			local playersFrame: Frame = surfaceGui.Frame:FindFirstChild("Players")
			if not playersFrame then
				return
			end
			local playerFrameVerticalSize = 1 / 10

			for rank, data in ipairs(topTen) do
				local name = data.key
				local points = data.value
				--print(name .. " is ranked #" .. rank .. " with " .. points .. "points")

				local playerName: string = nil
				local success, err = pcall(function()
					playerName = Players:GetNameFromUserIdAsync(data.key)
				end)
				if not playerName then
					continue
				end
				Players:GetNameFromUserIdAsync(data.key)
				local playerFrame: Frame = playersFrame:FindFirstChild(tostring(rank))
				playerFrame.Stitches.Text = tostring(points)
				if playerFrame.Player.Text == playerName then
					--print("player in same place, no need to update image or name")
					continue
				end
				playerFrame.Player.Text = playerName
				playerFrame.ImageLabel.Image =
					Players:GetUserThumbnailAsync(data.key, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
				playerFrame.Visible = true
				playerFrame.LayoutOrder = rank
			end
			-- Make sure list is ordered
			--local uiListLayout:UIListLayout = playersFrame:FindFirstChild("UIListLayout")
			--6uiListLayout.SortOrder = Enum.SortOrder.Name
		end
	end
end

-- Updates the visual stitch leaderboard in-game
function StitchesService:UpdateGlobalLeaderBoard()
	for _, leaderboard: Model in Leaderboards:GetChildren() do
		if leaderboard:HasTag("GlobalLeaderboard") then
			local surfaceGui: SurfaceGui = leaderboard.PrimaryPart:FindFirstChildWhichIsA("SurfaceGui")
			if not surfaceGui then
				continue
			end
			surfaceGui.Frame:FindFirstChild("StitchCount").Text = self._globalStitchCount
		end
	end
end

-- Creates spawn data (guid & position) to be sent to client
function StitchesService:CreateStitchSpawnData(position: Vector3): {}
	local newStitchSpawnData = {}
	-- Make a guid and store to check later
	local guid: string = Utils.generateGUID()
	table.insert(self._guids, guid)
	newStitchSpawnData.GUID = guid
	newStitchSpawnData.Position = position
	return newStitchSpawnData
end

function StitchesService:SetupStitchSpawns(player: Player)
	local spawnData = {}
	-- Loop through our spawns and create data to send to client
	for _, spawn in workspace.StitchSpawns:GetChildren() do
		local stitchSpawnData = self:CreateStitchSpawnData(spawn.CFrame.Position)
		table.insert(spawnData, stitchSpawnData)
	end
	self._serverBridge:Fire(player, spawnData)
end

function StitchesService:AttemptStitchCollect(player: Player, guid: string, position: Vector3): boolean
	if table.find(self._guids, guid) then
		-- Valid guid found, add stich to player
		self:AddStitches(player, 1)
		-- Remove guid from table to prevent spam
		table.remove(self._guids, table.find(self._guids, guid))
		-- Respawn a stitch after RESPAWN_TIME has passed
		task.delay(RESPAWN_TIME, function()
			local newSpawnData = self:CreateStitchSpawnData(position)
			self._serverBridge:Fire(player, { newSpawnData })
		end)
		return true
	end
end
function StitchesService:KnitInit()
	-- Services
	self._playerService = Knit.GetService("PlayerService")
	self._badgeAwardingService = Knit.GetService("BadgeAwardingService")
	self._petService = Knit.GetService("PetService")

	-- Bridge
	self._serverBridge = BridgeNet.ReferenceBridge("Stitches")
	-- Vars
	self._playerCollectedStitches = {}
end

-- Client side
function StitchesService.Client:GetStitches(player: Player)
	return self.Server:GetStitches(player)
end
function StitchesService.Client:AttemptStitchCollect(player: Player, guid: string, position: Vector3)
	return self.Server:AttemptStitchCollect(player, guid, position)
end
function StitchesService.Client:CheckForBadge(player: Player)
	return self.Server:CheckForBadge(player)
end
return StitchesService
