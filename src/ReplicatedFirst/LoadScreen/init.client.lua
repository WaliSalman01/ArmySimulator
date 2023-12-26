--if true then return end -- disable for now
local ReplicatedFirst = game:GetService("ReplicatedFirst")
ReplicatedFirst:RemoveDefaultLoadingScreen()
local LoadingScreen = ReplicatedFirst:WaitForChild("LoadingScreen")
LoadingScreen.IgnoreGuiInset = true
task.spawn(function()
	task.wait()
	pcall(function()
		local starterGui = game:GetService("StarterGui")
		starterGui:SetCore("TopbarEnabled", false)
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			-- Disable reset character
			--[[
			repeat 
				local success = pcall(function() 
					starterGui:SetCore("ResetButtonCallback", false)
				end)
				task.wait(1)
			until success
			]]--
	end)
end)

local HINT_LIST = {
	"Find Stitches and explore the world of Max Mara.",
	"Create clothes at the Atelier building.",
	"Don't forget to create your Daemon at PsychicWunderKammer.",
	"Daemons can grant you special powers like double jump!",
    "Unlock new clothing colors in Color Parkour!"
}

local function GenerateHint(hint: string)
	return HINT_LIST[math.random(1, #HINT_LIST)]
end

local function ProcessLoadingScreen()
	LoadingScreen.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	LoadingScreen.TipsFrame.TextLabel.Font = Enum.Font.Merriweather
	LoadingScreen.TipsFrame.TextLabel.Text = GenerateHint()
end

ProcessLoadingScreen()
local ContentProvider: ContentProvider = game:GetService("ContentProvider")
local spr = require(script:WaitForChild("spr"))

task.wait(3)

local function getAssets(root: Instance): { Instance }
	local res = {}

	for _, obj in root:GetDescendants() do
		if obj:IsA("ImageLabel") or obj:IsA("Sound") or obj:IsA("MeshPart") then
			table.insert(res, obj)
		end
	end

	return res
end

local function calculatePercentage(number: number, base: number)
	return (number / base)
end

local function preloadAssets(assets: { Instance }, baseValue: number)
	local totalContent = #assets
	local i = 1
	local callback = function()
		i += 1
		spr.target(LoadingScreen.LoadBar.ProgressFrame.Frame, 0.75, 1, {
			Size = UDim2.fromScale(
				baseValue
					+ math.clamp(baseValue + (calculatePercentage(i, totalContent) / 2), baseValue, baseValue + 0.5),
				1
			),
		})
	end
	ContentProvider:PreloadAsync(assets, callback)
	spr.stop(LoadingScreen.LoadBar.ProgressFrame.Frame)
end

preloadAssets(getAssets(game:GetService("ReplicatedStorage")), 0)
preloadAssets(getAssets(workspace), 0.5)
if not game:IsLoaded() then
	game.Loaded:Wait()
end

if LoadingScreen then
	LoadingScreen:Destroy()
	workspace:SetAttribute("Loaded", true)
end

task.spawn(function()
	task.wait()
	pcall(function()
		local starterGui = game:GetService("StarterGui")
		-- Enable top bar
		starterGui:SetCore("TopbarEnabled", true)
		-- Renable chat
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end)
end)