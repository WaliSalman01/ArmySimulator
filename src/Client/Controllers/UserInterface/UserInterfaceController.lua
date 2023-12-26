--[[
    UserInterfaceController.lua
    Author(s): Jibran

    Description: Controls UserInterface loading and usage.
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Modules
local Interface = StarterPlayerScripts.Interface
local Displays = Interface.Displays

-- Player]
local Player = Knit.Player

-- Values
local ScreenGuis = {
	"MainHud",
	"PetCustomization",
	"Puzzle",
	"Intro",
}

-- Knit
local UserInterfaceController = Knit.CreateController({
	Name = "UserInterfaceController",
})

-- Knit Startup
function UserInterfaceController:KnitInit()
	-- Load UI
	for _, ui: ModuleScript in ipairs(Displays:GetDescendants()) do
		if ui:IsA("ModuleScript") then
			local uiModule = require(ui)
			uiModule:Initialize()
		end
	end
end

function UserInterfaceController:DisableOtherUIs(currentUI: string)
	local playerGui = Player.PlayerGui
	for _, ui in pairs(ScreenGuis) do
		if currentUI ~= ui then
			playerGui[ui].Enabled = false
		end
	end
end

function UserInterfaceController:ToggleUI(UItoEnable: string, toggle:boolean)
	local ui = Player.PlayerGui:FindFirstChild(UItoEnable)
	if ui then
		ui.Enabled = toggle
	end
end

function UserInterfaceController:RemoveUI(UItoRemove: string)
	local playerGui = Player.PlayerGui
	for _, ui in pairs(ScreenGuis) do
		if UItoRemove == ui then
			playerGui[ui]:Destroy()
			table.remove(ScreenGuis, table.find(ScreenGuis, UItoRemove))
		end
	end
end

function UserInterfaceController:EnableUIs()
	local playerGui = Player.PlayerGui
	for _, ui in pairs(ScreenGuis) do
		playerGui[ui].Enabled = true
	end
end


function UserInterfaceController:RenderText(gui:string, frame:string, Text:string)
	local LABEL_SIZE = UDim2.new(1 / string.len(Text), 0, 1, 0) -- The size of each letter
	local LABEL_OFFSET = UDim2.new(0, 0, -1 / 5, 0) -- The offset the letter has from where it will end up. We spawn it slightly higher so we can animate it downwards
	local LABEL_FLOAT_TIME_SECONDS = 1 / 20 -- The time the label will be floating into its position
	local LABEL_TWEENINFO = TweenInfo.new(LABEL_FLOAT_TIME_SECONDS) -- The tweeninfo for constructing the tween later in the code
	local CHARACTERS_PER_SECOND = 20 -- How many characters appear each second
	local TEXT_SIZE = 40 -- Text size
	
	local ui = Player.PlayerGui:FindFirstChild(gui)
	if not ui then print("ui not found") return end
	local frame = ui:FindFirstChild(frame)
	if not frame then print("frame not found") return end
	local X = 0
	local Y = 0 
	-- Iterate over every letter
	for Char in Text:gmatch(".") do
		-- Create a text label for each letter
		local Label:TextLabel = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Text = Char 
		Label.Size = LABEL_SIZE 
		Label.Position = UDim2.new(X * LABEL_SIZE.X.Scale, 0, Y * LABEL_SIZE.Y.Scale, 0) + LABEL_OFFSET -- set the position to be its goal position + offset position
		Label.Parent = frame
		Label.TextSize = TEXT_SIZE
		Label.FontFace = Font.new("rbxasset://fonts/families/Merriweather.json", Enum.FontWeight.Bold)
		Label.TextColor3 =  Color3.new(0.827450, 0.674509, 0.349019)
		Label.TextStrokeColor3 = Color3.new(0, 0, 0)
		Label.TextStrokeTransparency = 0
		local Tween = TweenService:Create(Label, LABEL_TWEENINFO, {
			Position = Label.Position - LABEL_OFFSET
		})
		-- When tween in done, tween out
		Tween.Completed:Connect(function()
			task.wait(1)
			local TweenOut:Tween = TweenService:Create(Label, LABEL_TWEENINFO, { Position = Label.Position - LABEL_OFFSET})
			TweenOut.Completed:Connect(function()
				-- Done tweening out, destroy
				Label:Destroy()
			end)
			TweenOut:Play()
		end)
		Tween:Play()
		-- Update the x position
		X = X + 1
		-- Wait
		task.wait(1 / CHARACTERS_PER_SECOND)
	end
end
function UserInterfaceController:KnitStart() end

return UserInterfaceController
