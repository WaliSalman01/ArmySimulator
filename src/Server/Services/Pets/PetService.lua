--[[
    PetService.lua
    Author: Jibran

    Description: Manage pet system
]]
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Assets
local PetsFolder = ServerStorage.Assets.Pets

-- Folders
local SpawnedPetsFolder = Instance.new("Folder")
SpawnedPetsFolder.Parent = workspace
SpawnedPetsFolder.Name = "SpawnedPets"

local PetService = Knit.CreateService({
	Name = "PetService",
	Client = {
		PetSpawned = Knit.CreateSignal(),
		DataFoundSignal = Knit.CreateSignal(),
	},
	_spawnedPets = {},
})

-- Constants
local MAX_PETS_EQUIPPED = 1

function PetService:Spawnpet(player, petName)
	local petModel = PetsFolder:FindFirstChild(petName)
	local currentPets = 0
	if self._spawnedPets[player.UserId] then
		for _, pet in pairs(self._spawnedPets[player.UserId]) do
			task.spawn(function()
				currentPets += 1
			end)
		end
	end

	if petModel and currentPets < MAX_PETS_EQUIPPED then
		petModel = petModel:Clone()
		petModel:SetAttribute("Player", player.Name)
		petModel:SetAttribute("Position", currentPets + 1)
		petModel.Parent = SpawnedPetsFolder
		petModel.HumanoidRootPart.CFrame = player.Character:WaitForChild("HumanoidRootPart").CFrame

		for _, descendant in petModel:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = "Pets"
			end
		end

		if not self._spawnedPets[player.UserId] then
			self._spawnedPets[player.UserId] = {}
		end

		self._spawnedPets[player.UserId] = petModel

		task.spawn(function()
			self.Client.PetSpawned:FireAll(self._spawnedPets)
		end)

		return petModel
	end

	return nil
end

function PetService:RespawnCustomPet(player)
	self:Despawn(player)
	local petParts = self._petsData[player]["Config"]
	local petModel = self:Spawnpet(player, "Default")
	self:SetNewPart("Body", petParts["Body"], petModel)
	self:SetNewPart("Head", petParts["Head"], petModel)
	self:SetNewPart("Tail", petParts["Tail"], petModel)
	self:SetNewPart("Back", petParts["Back"], petModel)
end

function PetService:UpdateConfig(player, config)
	self._petsData[player]["Config"] = config
	for partName, petName in pairs(config) do
		if petName == "Default" then
			self._petsData[player]["PetEnabled"] = false
			return
		end
	end
	self._petsData[player]["PetEnabled"] = true
end

function PetService:UpdateCutscene(player, value)
	self._petsData[player]["CutscenePlayed"] = value
	self:UpdatePetsData(player)
end

function PetService:UpdateHyperStitches(player, value)
	self._petsData[player]["HyperStitches"] = value
	self:UpdatePetsData(player)
end

function PetService:UpdateTimeStretch(player, value)
	self._petsData[player]["TimeStretch"] = value
	self:UpdatePetsData(player)
end

function PetService:SetNewPart(partName, pet, petModel)
	local newModel = PetsFolder[pet]
	local newPart = newModel[partName]:Clone()
	local motor6D = newPart:FindFirstChildOfClass("Motor6D")
	petModel[partName]:Destroy()
	newPart.Parent = petModel
	if partName == "Body" then
		motor6D.Part0 = petModel.RootPart
	else
		motor6D.Part0 = petModel.Body
	end
end

function PetService:Despawn(player)
	if self._spawnedPets[player.UserId] then
		self._spawnedPets[player.UserId]:Destroy()
		self._spawnedPets[player.UserId] = nil
	end
end

function PetService:DespawnAll(player)
	if self._spawnedPets[player.UserId] then
		for _, petModel in pairs(self._spawnedPets[player]) do
			if petModel then
				petModel:Destroy()
			end
		end
		self._spawnedPets[player] = nil
	end
end

function PetService:UpdatePetsData(player)
	local playerContainer = self._playerService:GetContainer(player, true)
	if not playerContainer then
		return
	end
	playerContainer.Replica:Write("UpdatePetsConfig", self._petsData[player])
	self.Client.DataFoundSignal:Fire(player, self._petsData[player])
end

function PetService:UpdateData(player: Player)
	local playerContainer = self._playerService:GetContainer(player, true)
	if not playerContainer then
		self._petsData[player] = {}
	else
		self._petsData[player] = playerContainer.Profile.Data.PetsConfiguration
	end
	print(self._petsData[player])
	-- Send to client to prepare any local effects per checkpoint
	self.Client.PetSpawned:Fire(player, self._spawnedPets)
	self.Client.DataFoundSignal:Fire(player, self._petsData[player])
end

function PetService:GetPlayerPetsConfig(player: Player)
	-- Player Container
	local PlayerContainer = self._playerService:GetContainer(player, true)

	return PlayerContainer.Profile.Data.PetsConfiguration
end

function PetService:KnitStart()
	self._petsData = {}

	-- Pull player data
	Players.PlayerAdded:Connect(function(player)
		self:UpdateData(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:Despawn(player)
	end)

	-- Catch for any players joining before PlayerAdded signal gets set
	task.delay(4, function()
		for _, player in ipairs(Players:GetPlayers()) do
			self:UpdateData(player)
		end
	end)
end

function PetService:KnitInit()
	-- Services
	self._playerService = Knit.GetService("PlayerService")
end

-- Getters
function PetService:IsTimeStretch(player: Player)
	return self._petsData[player]["TimeStretch"]
end

function PetService:IsHyperStitches(player: Player)
	return self._petsData[player]["HyperStitches"]
end

-- Client Functions
function PetService.Client:Spawn(player: Player, petName)
	return PetService:Spawnpet(player, petName)
end

function PetService.Client:RespawnCustomPet(player: Player, petParts: table)
	return PetService:RespawnCustomPet(player, petParts)
end

function PetService.Client:UpdatePetsData(player: Player)
	return PetService:UpdatePetsData(player)
end

function PetService.Client:UpdateConfig(player: Player, config: table)
	return PetService:UpdateConfig(player, config)
end

function PetService.Client:UpdateCutscene(player: Player, value: boolean)
	return PetService:UpdateCutscene(player, value)
end

function PetService.Client:UpdateHyperStitches(player: Player, value: boolean)
	return PetService:UpdateHyperStitches(player, value)
end

function PetService.Client:UpdateTimeStretch(player: Player, value: boolean)
	return PetService:UpdateTimeStretch(player, value)
end

function PetService.Client:Despawn(player)
	return PetService:Despawn(player)
end

return PetService
