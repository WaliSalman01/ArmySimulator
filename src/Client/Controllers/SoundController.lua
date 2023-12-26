-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService: SoundService = game:GetService("SoundService")
local TweenService: TweenService = game:GetService("TweenService")

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Shared
local Shared: Folder = ReplicatedStorage.Shared
local ZonePlus = require(Shared.Zone)

-- 
local SoundController = Knit.CreateController {
    Name = script.Name
}

-- Gets Sound in Sound Service
local function GetSound(SoundName: string)
    return SoundService:FindFirstChild(SoundName, true)
end

-- 
function SoundController:PlaySound(SoundName: string, FadeInTime: number)
    -- Find Sound 
    local SoundToPlay: Sound = GetSound(SoundName)

    if not SoundToPlay then 
        warn("Cannot find Sound: " .. SoundName) 
        return 
    end 
    if self._tweens[SoundName.."Play"] then self._tweens[SoundName.."Play"]:Cancel() return end
    -- 
    local VolumeGoal: number = self._originalVolumes[SoundName]

    -- Play Sound with Fade In 
    SoundToPlay.Volume = 0 
    SoundToPlay.TimePosition = self._timePositions[SoundName]
    self._timePositions[SoundName] = 0
    SoundToPlay:Play()
    local tween:Tween = TweenService:Create(SoundToPlay, TweenInfo.new(FadeInTime or 0.001, Enum.EasingStyle.Linear), {Volume = VolumeGoal})
    self._tweens[SoundName.."Play"] = tween
    tween.Completed:Connect(function()
        table.remove(self._tweens, table.find(self._tweens, tween))
        self._tweens[SoundName.."Play"] = nil
    end)
    tween:Play()
end

function SoundController:PlaySoundEffect(SoundName: string)
    -- Find Sound 
    local SoundToPlay: Sound = GetSound(SoundName)

    if not SoundToPlay then 
        warn("Cannot find Sound: " .. SoundName) 
        return 
    end 
    -- Play Sound
    SoundToPlay:Play()
end

function SoundController:StopSoundEffect(SoundName: string)
    -- Find Sound 
    local SoundToPlay: Sound = GetSound(SoundName)

    if not SoundToPlay then 
        warn("Cannot find Sound: " .. SoundName) 
        return 
    end 
    -- Stop Sound
    SoundToPlay:Stop()
end

function SoundController:StopSound(SoundName: string, FadeOutTime: number)
    -- Find Sound 
    local SoundToStop: Sound = GetSound(SoundName)

    if not SoundToStop then 
        warn("Cannot find Sound: " .. SoundName) 
        return 
    end 
    if self._tweens[SoundName.."Stop"] then self._tweens[SoundName.."Stop"]:Cancel() return end

    -- Save Orig Volume 
    local OrigVolume: number = self._originalVolumes[SoundToStop]

    -- 
    local tween:Tween = TweenService:Create(SoundToStop, TweenInfo.new(FadeOutTime or 0.001, Enum.EasingStyle.Linear), {Volume = 1})
    tween.Completed:Connect(function()
        table.remove(self._tweens, table.find(self._tweens, tween))
        self._tweens[SoundName.."Stop"] = nil
    end)
    tween:Play()
    task.delay(FadeOutTime or 0.001, function()
        SoundToStop:Stop()
        SoundToStop.Volume = OrigVolume
    end) 
end
-- 
function SoundController:PauseSound(SoundName: string)
    -- Find Sound 
    local SoundToStop: Sound = GetSound(SoundName)

    if not SoundToStop then 
        warn("Cannot find Sound: " .. SoundName)
        return 
    end 

    SoundToStop:Pause()
    self._timePositions[SoundName] = SoundToStop.TimePosition
end

-- 
function SoundController:ChangeVolume(SoundName: string, VolumeSelected: number, FadeTime: number)
     -- Find Sound 
     local Sound: Sound = GetSound(SoundName)

     if not Sound then 
         warn("Cannot find Sound: " .. SoundName)
         return
     end

     TweenService:Create(Sound, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), {Volume = VolumeSelected}):Play()
end

--
function SoundController:KnitInit()

end

function SoundController:KnitStart()
    -- Vars
    self._tweens = {}
    self._originalVolumes = {}
    self._timePositions = {}

    -- Initialize volumes & positions
    for _, sound in ipairs(SoundService:GetChildren()) do
        self._originalVolumes[sound.Name] = sound.Volume
        self._timePositions[sound.Name] = sound.TimePosition
    end

    -- Initialize Music Zones
    for _, soundZone: Folder in workspace.SoundZones:GetChildren() do
        local MusicZone = ZonePlus.new(soundZone)

        MusicZone.localPlayerEntered:Connect(function()
            self:PauseSound("Main")
            self:PlaySound(soundZone:GetAttribute("Sound"), 1)
        end)

        MusicZone.localPlayerExited:Connect(function()
            self:PauseSound(soundZone:GetAttribute("Sound"), .5)
            self:PlaySound("Main", 1)
        end)
    end
    -- Start main sound
    self:PlaySound("Main", 1)
end

return SoundController