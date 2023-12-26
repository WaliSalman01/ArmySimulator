--[[
    InventoryService.lua
    Author: Justin (synnull)

    Description: Manage player's inventory (colors, bears)
]]

-- Services
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Modules = ServerStorage:WaitForChild("Modules")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Replicated Data
local ColorData = require(ReplicatedStorage.ReplicatedData.Colors)
local TeddyData = require(ReplicatedStorage.ReplicatedData.Teddies)

local InventoryService = Knit.CreateService {
    Name = script.Name,
    Client = {
        InventoryChanged = Knit.CreateSignal()
    };
}

function InventoryService:GetInventory(player: Player): {}
    if not player then return end

    -- Get MatchDataReplica
    local playerDataReplica: {} = self._playerService:GetContainer(player, true)
    local playerData: {} = if playerDataReplica then playerDataReplica.Profile.Data else nil
    if not playerData then return end

    return playerData.Inventory :: {}
end


function InventoryService:HasTeddy(player: Player, teddyIndex:number): boolean
    if not player or not teddyIndex then return end

    -- Get MatchDataReplica
    local playerDataReplica: {} = self._playerService:GetContainer(player, true)
    local playerData: {} = if playerDataReplica then playerDataReplica.Profile.Data else nil
    if not playerData then return end
    return playerData.Inventory.Teddies[teddyIndex] == 1 and true or false :: boolean
end

function InventoryService:AddColor(player: Player, colorPalette: string): boolean
    if not ( player and colorPalette ) then return end

    -- Check if the color exists
    local colorData: {} = ColorData[colorPalette]
    if not colorData then return end

    -- Get MatchDataReplica
    local container: {} = self._playerService:GetContainer(player, true)
    if container then
        container.Replica:Write("AddColorToInv", colorPalette, colorData)
        --self.Client.InventoryChanged:Fire(player)
    end

    return true
end

function InventoryService:AddTeddy(player: Player, teddyName: string, teddyIndex:number): boolean
    if not ( player and teddyName and teddyIndex ) then return end
    -- Server check
    local teddy = workspace.TalkingTeddies:FindFirstChild(teddyName)
    if not teddy then return end
    if teddy:GetAttribute("TeddyIndex") ~= teddyIndex then return end

    -- Check for teddy data
    local teddyData: {} = TeddyData[teddyIndex]
    if not teddyData then return end

    -- Get MatchDataReplica
    local container: {} = self._playerService:GetContainer(player, true)
    if container then
        container.Replica:Write("AddTeddyToInv", teddyIndex)
        --self.Client.InventoryChanged:Fire(player)
    end

    return true
end

function InventoryService:SetAtelierCompletionTime(player: Player, level:number, newTime:number)
    local playerContainer = self._playerService:GetContainer(player, true)
    if not playerContainer then return end
    playerContainer.Replica:Write("SetAtelierCompletionTime", level, newTime)
end

function InventoryService:KnitStart()
    -- Services
    self._playerService = Knit.GetService("PlayerService")
end

function InventoryService:KnitInit()
end

-- Client
function InventoryService.Client:GetInventory(player: Player): {}
    return self.Server:GetInventory(player) :: {}
end

function InventoryService.Client:AddColor(player: Player, colorPalette: string): boolean
    return self.Server:AddColor(player, colorPalette) :: boolean
end

function InventoryService.Client:AddTeddy(player: Player, teddyName: string, teddyIndex:number): boolean
    return self.Server:AddTeddy(player, teddyName, teddyIndex) :: boolean
end

function InventoryService.Client:HasTeddy(player: Player, teddyIndex: number): boolean
    return self.Server:HasTeddy(player, teddyIndex) :: boolean
end

function InventoryService.Client:SetAtelierCompletionTime(player: Player, level:number, newTime:number)
    return self.Server:SetAtelierCompletionTime(player, level, newTime)
end


return InventoryService