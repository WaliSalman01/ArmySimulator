--[[
    IntroController.lua
    Author: Justin (synnull)
    
    Intro state for game (after loading screen). Camera will show scenes of game
]]
local LocalPlayer = game.Players.LocalPlayer
local PlayerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Streamable = require(Packages.Streamable).Streamable

-- Vars
local CameraTracks: Folder = workspace.CameraTracks
local CAMTRACK_TWEENINFO: TweenInfo = TweenInfo.new(9, Enum.EasingStyle.Sine)

local IntroController = Knit.CreateController { Name = "IntroController" }



-- Starts Intro
function IntroController:StartIntro()
	-- UI
	--local Intro_UI: ScreenGui = self.IntroUI
	--local BackgroundFrame: Frame = Intro_UI.Background

	-- Hide Other Uis
	--UIController:ToggleExcept(false, "IntroUI")
    local partStreamable = Streamable.new(CameraTracks, "Scene1")
	partStreamable:Observe(function(part, trove)
		-- Start Camera Track and Fade out for Background
        self._cameraController:Blur(5)
	    self._cameraController:StartCameraTrack(CameraTracks.Scene1, CAMTRACK_TWEENINFO)
        self._userInterfaceController:DisableOtherUIs("Intro")
		partStreamable:Destroy()
	end)


	-- Fade In and Out To Proceed To Scene Cam Tracks
	--task.wait(8)
	--TweenService:Create(BackgroundFrame, BGFADE_TWEENINFO, { BackgroundTransparency = 0 }):Play()
	--task.wait(BGFADE_TWEENINFO.Time)

	-- Start Camera Scenes
	self:LoopThroughScenes()
end

function IntroController:LoopThroughScenes()
    -- Start Looping
	while not self.StartPlay do
		for _, scene in CameraTracks:GetChildren() do
			self._cameraController:StartCameraTrack(scene, CAMTRACK_TWEENINFO, true)

			-- Stop Track Loop
			if self.StartPlay then
				break
			end
		end
		task.wait()
	end
end

function IntroController:Play()
    self.StartPlay = true
    self._cameraController:Blur(0)
    self._cameraController:StopCameraTrack()
    self._cameraController:SetToDefault()
	self._userInterfaceController:EnableUIs()
end

function IntroController:KnitStart()
    --if true then self.UI:Destroy() return end
    -- Controllers
    self._cameraController = Knit.GetController("CameraController")
    self._userInterfaceController = Knit.GetController("UserInterfaceController")

    -- Start Intro
	task.spawn(function()
		self:StartIntro()
	end)
end


function IntroController:KnitInit()

end


return IntroController