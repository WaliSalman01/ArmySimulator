local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Parent: PlayerScripts = script.Parent
local LocalPlayer = game.Players.LocalPlayer
-- set camera
-- workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

require(game:GetService("ReplicatedStorage").ReplicatedTweening)

local Player = game.Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local BridgeNet = require(Packages.BridgeNet2)

-- Constants
local START_TIME: number = workspace:GetServerTimeNow()

Knit.AddControllersDeep(PlayerScripts:WaitForChild("Controllers"))
-- load interfaces
-- Knit.AddControllers(PlayerScripts.Controllers:WaitForChild("Interface"))
Knit.Start({ ServicePromises = false }):catch(warn):finally(function()
    -- Initialize Components
    for _, component: ModuleScript? in ipairs( Parent:WaitForChild("Components"):GetChildren() ) do
        if not component:IsA("ModuleScript") then continue end
        require(component)
    end

    -- Display how long it took to load the client
    local msTimeDifference: number = math.round((workspace:GetServerTimeNow() - START_TIME) * 1000)
    print(`✅ Client has loaded! Took ~{msTimeDifference}ms`)
end)