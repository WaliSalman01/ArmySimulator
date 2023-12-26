-- create collision groups here
game:GetService("PhysicsService"):CreateCollisionGroup("Players")
game:GetService("PhysicsService"):CreateCollisionGroup("Pets")

game:GetService("PhysicsService"):CollisionGroupSetCollidable("Players", "Players", false)
game:GetService("PhysicsService"):CollisionGroupSetCollidable("Players", "Pets", false)
game:GetService("PhysicsService"):CollisionGroupSetCollidable("Pets", "Pets", false)



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local ReplicatedTweenign = require(game:GetService("ReplicatedStorage").ReplicatedTweening)
local BridgeNet = require(Packages.BridgeNet2)

-- Constants
local START_TIME: number = workspace:GetServerTimeNow()

Knit.AddServicesDeep(ServerStorage:WaitForChild("Services"))
Knit.Start():catch(warn):finally(function()
    -- Initialize Components
    for _, component: ModuleScript? in ipairs( ServerStorage:WaitForChild("Components"):GetChildren() ) do
        if not component:IsA("ModuleScript") then continue end
        require(component)
    end

    -- Display how long it took to load the server
    local msTimeDifference: number = math.round((workspace:GetServerTimeNow() - START_TIME) * 1000)
    print(`✅ Server has loaded! Took ~{msTimeDifference}ms`)
end)