-- Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Modules
local Modules = StarterPlayerScripts.Modules
local BridgeNet = require(Packages.BridgeNet2)

-- Vars
local Player = Knit.Player
local StitchModel:Model = ReplicatedStorage.Assets:FindFirstChild("Stitch")
local Offset:Vector3 = Vector3.new(2, -3, 0)
local SPIN_SPEED = 30
local StitchCollectBB:BillboardGui = ReplicatedStorage.Assets.UI:FindFirstChild("StitchCollect")
local VFX:Model = ReplicatedStorage.Assets.Particles:FindFirstChild("ThreadParticle")

-- Create Controller
local StitchesController = Knit.CreateController({
	Name = script.Name,
})


function StitchesController:KnitStart()
    -- Services
    self._stitchesService = Knit.GetService("StitchesService")
    self._soundController = Knit.GetController("SoundController")

    -- Bridge
    self._clientBridge = BridgeNet.ReferenceBridge("Stitches")

    -- Vars
    self._stitchUpdates = {}
    -- Connect to bridge
    self._clientBridge:Connect(function(spawnData)
       for _, stitchSpawnData in spawnData do
            local newStitch:Model = StitchModel:Clone()
            newStitch:PivotTo(CFrame.new(stitchSpawnData.Position + Offset) * CFrame.Angles(math.rad(90), 0, 0))
            newStitch.Parent = workspace.StitchSpawns
            -- Make the stitch spin
            self._stitchUpdates[stitchSpawnData.GUID] = RunService.Heartbeat:Connect(function(dt)
                newStitch.PrimaryPart.CFrame = newStitch.PrimaryPart.CFrame * CFrame.Angles(0,0,math.rad(SPIN_SPEED * dt))
            end)
            newStitch.PrimaryPart.Touched:Connect(function(otherPart)
                local player:Player = Players:GetPlayerFromCharacter(otherPart.Parent)
                if not player then return end
                self._stitchesService:AttemptStitchCollect(stitchSpawnData.GUID, stitchSpawnData.Position)
                self._stitchUpdates[stitchSpawnData.GUID]:Disconnect()
                newStitch:Destroy()
                self._soundController:PlaySoundEffect("CollectStitch")
                if VFX then
                    local newVFX = VFX:Clone()
                    newVFX:PivotTo(player.Character:GetPivot())
                    newVFX.Parent = workspace
                    task.delay(.1, function()
                        newVFX.Core.Attachment.Sparkles.Enabled = false
                        Debris:AddItem(newVFX, newVFX.Core.Attachment.Sparkles.Lifetime.Max)
                    end)
                end
                --self._stitchesService:CheckForBadge()
            end)
       end
    end)

    -- Grab our stitch count
    self._mainUI.StitchCount:set(self._stitchesService:GetStitches())
    -- Connect to stitch collect signal
    self._stitchesService.StitchCollected:Connect(function(stitchCount:number)
        self._mainUI.StitchCount:set(stitchCount)
        
        -- Add some UI feedback
        if not StitchCollectBB then return end
        local newStitchCollectBB = StitchCollectBB:Clone()
        newStitchCollectBB.Parent = Player.Character.Head
        newStitchCollectBB.StudsOffset = Vector3.new(math.random(-4, 4), math.random(2, 4), 0)
        local tween = TweenService:Create(newStitchCollectBB.TextLabel, TweenInfo.new(1), {TextTransparency = 1})
        tween.Completed:Connect(function()
            newStitchCollectBB:Destroy()
        end)
        tween:Play()
    end)

end

function StitchesController:KnitInit()
end

return StitchesController