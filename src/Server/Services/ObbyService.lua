--[[
    ObbyService.lua
    Author: Justin (synnull)

    Description: Manage the server side for the obby minigame 
]]

-- Services
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Packages = ReplicatedStorage.Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local ObbyData = require(ReplicatedStorage.ReplicatedData.ObbyData)

-- Folder
local Obbies: Folder = workspace:WaitForChild("Obbies")

-- Vars
local ToolsToRemove = { "SpeedCoil" }

local ObbyService = Knit.CreateService {
    Name = "ObbyService";
    Client = {
        HitCheckPointSignal = Knit.CreateSignal(),
        DataFoundSignal = Knit.CreateSignal(),
        HitFinishSignal = Knit.CreateSignal(),
    };
}

function ObbyService:KnitStart()
    self:SetUpCheckPoints()
end


function ObbyService:KnitInit()
    -- Services
    self._playerService = Knit.GetService("PlayerService")
    self._teleportService = Knit.GetService("TeleportService")
    self._stitchesService = Knit.GetService("StitchesService")
    self._inventoryService = Knit.GetService("InventoryService")

    -- Pull player data
    self._playerData = {}
    Players.PlayerAdded:Connect(function(player)
        self:UpdateData(player)
    end)
    -- Catch for any players joining before PlayerAdded signal gets set
	task.delay(4, function()
		for _, player in ipairs(Players:GetPlayers()) do
            self:UpdateData(player)
		end
	end)
end

function ObbyService:UpdateData(player: Player)
    local playerContainer = self._playerService:GetContainer(player, true)
    if not playerContainer then
        self._playerData[player] = {}
    else
        self._playerData[player] = playerContainer.Profile.Data.ObbyCheckPoints
    end
    print( self._playerData[player])
    -- Send to client to prepare any local effects per checkpoint
    --self.Client.DataFoundSignal:Fire(player, self._playerData[player])
end

function ObbyService:AddDebounceTag(player: Player, toggle:boolean)
    CollectionService:AddTag(player, "ObbyDebounce")
    task.spawn(function()
        task.wait(1)
        if not player then return end
        CollectionService:RemoveTag(player, "ObbyDebounce")
    end)
end

-- Sets up checkpoints and finish
function ObbyService:SetUpCheckPoints()
    for _, obby in Obbies:GetChildren() do
        local checkpoints = obby:FindFirstChild("Checkpoints")
        if not checkpoints then continue end

        -- Checkpoint
        for _, checkpoint:Part in checkpoints:GetChildren() do
            checkpoint.PrimaryPart.Touched:Connect(function(otherPart)
                local player = Players:GetPlayerFromCharacter(otherPart.Parent)
                if not player or CollectionService:HasTag(player, "ObbyDebounce") then return end
                self:HitCheckPoint(player, checkpoint)
            end)
        end

        local finish:Part = obby:FindFirstChild("Finish")
        if not finish then continue end
        finish.Touched:Connect(function(otherPart)
            local player = Players:GetPlayerFromCharacter(otherPart.Parent)
            if not player or CollectionService:HasTag(player, "ObbyDebounce") then return end
            self:HitFinish(player, finish)
        end)
    end
end

function ObbyService:RemoveTools(player:Player)
    local function destroyTool(tool:Tool)
        print(tool.Name)
        if tool.Name == "SpeedCoil" then
            player.Character.Humanoid.WalkSpeed = 16
        end
        tool:Destroy()
    end

    for _, toolName:string in ToolsToRemove do
        local tool = player.Character:FindFirstChild(toolName)
        if tool then
            destroyTool(tool)
        end
        tool = player.Backpack:FindFirstChild(toolName)
        if tool then
            destroyTool(tool)
        end
    end
end

function ObbyService:HitCheckPoint(player: Player, checkpointPart: Part)
    -- Remove any section tools
    self:RemoveTools(player)

    local level:string = checkpointPart.Parent.Parent.Name
    local checkpoint:number = tonumber(checkpointPart.Name)
    if not self._playerData[player][level] then self._playerData[player][level] = {Completions = 0, CheckPoint = 0} end

    -- Make sure new check point is higher than the last one
    if self._playerData[player][level].CheckPoint < checkpoint then
        self:AddDebounceTag(player, true)
        --print(player.Name .. " got to checkpoint " .. checkpoint .. " in " .. level)
        -- Fire to player for any screen effects
        self.Client.HitCheckPointSignal:Fire(player, level, checkpointPart.Name)
        -- Set new check point in data
        self._playerData[player][level].CheckPoint = checkpoint
        -- Save to player container
        local playerContainer = self._playerService:GetContainer(player, true)
        if not playerContainer then return end
        playerContainer.Replica:Write("HitCheckPoint", level, checkpoint)
    end
end

function ObbyService:RewardPlayer(player: Player, level: string)
    local rewardData:{} = ObbyData[level].Rewards
    if not rewardData then return end

    for _, color in rewardData.Colors do
        self._inventoryService:AddColor(player, color)
    end
    local stitches = rewardData.Stitches
    if stitches then
        self._stitchesService:AddStitches(player, stitches)
    end
    local playerContainer = self._playerService:GetContainer(player, true)
    --print(playerContainer.Replica.Data)
end

function ObbyService:SetObbyCompletionTime(player: Player, level:string, newTime:number)
    local playerContainer = self._playerService:GetContainer(player, true)
    if not playerContainer then return end
    playerContainer.Replica:Write("SetCompletionTime", level, newTime)
end

function ObbyService:SetObbyCheckPointTime(player: Player, level:string, checkPoint:number, newTime:number)
    local playerContainer = self._playerService:GetContainer(player, true)
    if not playerContainer then return end
    playerContainer.Replica:Write("SetCheckPointTime", level, checkPoint, newTime)
end


function ObbyService:HitFinish(player: Player, finishPart: Part)
    -- Debounce
    self:AddDebounceTag(player, true)

    -- Remove any section tools
    self:RemoveTools(player)
    
    local level:string = finishPart.Parent.Name
    print(player.Name .. " finished Obby:  " .. level)
    -- Set Completion
    self._playerData[player][level].Completions += 1
     -- Fire to player
     self.Client.HitFinishSignal:Fire(player, level)
    -- Reset Checkpoint
    self._playerData[player][level].CheckPoint = 0
    -- Give player reward
    self:RewardPlayer(player, level)
    -- Teleport player back to obby lobby
    self:TeleportToLobby(player)
    -- Write completion value
    local playerContainer = self._playerService:GetContainer(player, true)
    if not playerContainer then return end
    playerContainer.Replica:Write("HitFinish", level, self._playerData[player][level].Completions)
end

function ObbyService:GetPlayerObbyData(player: Player)
    -- Player Container 
    local PlayerContainer = self._playerService:GetContainer(player, true)

    return PlayerContainer.Profile.Data.ObbyCheckPoints
end


function ObbyService:TeleportToLobby(player:Player)
    self._teleportService:AttemptTeleport(player, Obbies:FindFirstChild("ObbyLobby"), Vector3.new(0, 5, 0))
end

function ObbyService:Respawn(player: Player, level: string)
    if not player and not level then return end

    if level == "Lobby" then
        local character = player.Character
        if not character then return end
        local hrp:Part = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local offset = Vector3.new(0, 10, 0)
        hrp:PivotTo(CFrame.new(Obbies.ObbyLobby.CFrame.Position + offset))
        return
    end
    -- Get the current obby
    local obby:Folder = Obbies:FindFirstChild(level)
    -- Find our respawn part
    local respawnPart:Part = self._playerData[player] and obby.Checkpoints:FindFirstChild(self._playerData[player][level].CheckPoint) or obby:FindFirstChild("Start")

    -- Offset
    local offset = Vector3.new(0, 10, 0)
    local character = player.Character
    if not character then return end
    local hrp:Part = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp:PivotTo(CFrame.new(respawnPart.PrimaryPart.CFrame.Position + offset))
    return respawnPart.Name
end

-- Client side
function ObbyService.Client:Respawn(player: Player, obby: Folder)
    return self.Server:Respawn(player, obby)
end

function ObbyService.Client:TeleportToLobby(player: Player)
    return self.Server:TeleportToLobby(player)
end

function ObbyService.Client:SetObbyCompletionTime(player: Player, level:string, newTime:number)
    return self.Server:SetObbyCompletionTime(player, level, newTime)
end

function ObbyService.Client:SetObbyCheckPointTime(player: Player, level:string, checkPoint:number, newTime:number)
    return self.Server:SetObbyCheckPointTime(player, level, checkPoint, newTime)
end

function ObbyService.Client:GetPlayerObbyData(player: Player)
    return self.Server:GetPlayerObbyData(player)
end
return ObbyService