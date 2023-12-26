-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Component = require(Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Components
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local TeddyComponent = require(StarterPlayerScripts.Components.Teddy)

-- Initializing Component
local Dialogue = Component.new({
	Tag = "Dialogue",
})

-- Runtime function | Runs prior to :Start()
function Dialogue:Construct()
	local prompt = Instance.new("ProximityPrompt")
	prompt.Parent = self.Instance
	self.dialogueName = self.Instance:GetAttribute("DialogueName")
	self.teddyIndex = self.Instance:GetAttribute("TeddyIndex")
end

-- Runtime function | Runs following :Construct()
function Dialogue:Start()
	-- Our prompt to switch part
	local prompt = self.Instance:WaitForChild("ProximityPrompt", 3)
	prompt.Triggered:Connect(function()
		Knit.GetController("DialogueController"):StartDialogue(self.dialogueName)
		if not self.teddyIndex then return end
		Knit.GetService("InventoryService"):AddTeddy(self.Instance.Name, self.teddyIndex)
		local teddyComponent = self:GetComponent(TeddyComponent)
		if teddyComponent then
			teddyComponent:RemoveGUI()
		end
	end)
	Knit.GetController("DialogueController")._dialogueInProgress:Connect(function(inProgress)
		if inProgress then
			prompt.Enabled = false
		else
			prompt.Enabled = true
		end
	end)
end

-- Runs when tag is disconnected from object
function Dialogue:Stop() end

return Dialogue
