--[[
    ScreenEffect.lua
    Author(s): Justin (Synnull)

    Description: Frame to hold and display any effects (ie confetti)
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Players = game:GetService("Players")

-- Player
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player.PlayerGui

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

-- Modules      
local Modules = StarterPlayerScripts.Modules
local Confetti = require(Modules.Confetti)

-- Constant Declarations
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value

-- module class table
local ScreenEffectsDisplay = {}

-- Sync up Checkpoint attribute

local checkpointReached = New "BindableEvent" {}

-- Initializing match display UI in player GUI
function ScreenEffectsDisplay:Initialize()
	self._userInterfaceController = Knit.GetController("UserInterfaceController")

	Knit.GetService("ObbyService").HitCheckPointSignal:Connect(function(level:string, checkpoint:string)
		checkpointReached:Fire()
		self._userInterfaceController:RenderText("ScreenEffects", "RenderText", "CHECKPOINT!")
	end)
	self._currentUI = self:CreateUI()
	self._currentUI.Parent = PlayerGui
end

-- Creating UI from props defined
function ScreenEffectsDisplay:CreateUI()
	return New "ScreenGui" {
		Name = "ScreenEffects",
		Enabled = true,
		ResetOnSpawn = false,
		[Children] = {
			New "Frame" {
				Name = "MainFrame",
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ClipsDescendants = true,

			},
            Confetti {
                Event = checkpointReached.Event
            },
			New "Frame" {
				Name = "RenderText",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0.3, 0.2),
				Size = UDim2.fromScale(.4, .3),
				ClipsDescendants = true,
			},
		},
	}
end

return ScreenEffectsDisplay