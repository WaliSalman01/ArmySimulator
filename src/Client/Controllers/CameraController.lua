-- Services
local Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

-- Packages
local Packages: Folder = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

-- Vars
local Player = Knit.Player
local TRANSITION_TIME = 0.5

-- Create Controller
local CameraController = Knit.CreateController({
	Name = script.Name,
})

function CameraController:Fade(transparency: number)
	if not self.UI then
		return
	end
	local tweenOut = TweenService:Create(
		self.UI.MainFrame,
		TweenInfo.new(TRANSITION_TIME),
		{ BackgroundTransparency = transparency }
	)
	tweenOut:Play()
	tweenOut.Completed:Wait()
end

function CameraController:Blur(amount: number)
	local blur: BlurEffect = Lighting:FindFirstChild("Blur")
	if not blur then
		blur = Instance.new("BlurEffect", Lighting)
	end
	blur.Size = amount
	blur.Enabled = amount > 0 and true or false
end

function CameraController:MoveToPart(part: BasePart, offset: CFrameValue)
	self:Fade(0)
	-- Character
	local Player: Player = Knit.Player

	if not Player.Character then
		return
	end

	-- Camera
	local Camera: Camera = workspace.CurrentCamera

	-- Set Camera
	Camera.CameraType = Enum.CameraType.Scriptable
	-- Set Camera Cframe to part with value multiplier
	Camera.CFrame = part.CFrame
	if offset then
		Camera.CFrame *= offset
	end

	self:Fade(1)
end

-- Sets Camera Back to Default
function CameraController:SetToDefault()
	-- Character
	local Player: Player = Knit.Player

	if not Player.Character then
		return
	else
		Player.Character.HumanoidRootPart.Anchored = false
	end

	local Humanoid = Player.Character:WaitForChild("Humanoid")
	-- Camera
	local Camera: Camera = workspace.CurrentCamera

	-- Set to Default
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Humanoid
end

-- Starts Camera Track (CameraTracks = Folder Containing Parts Acting as Nodes for Camera to Go Into)
function CameraController:StartCameraTrack(
	CameraTracks: Folder,
	TweenInfo: TweenInfo,
	Yield: boolean,
	SetDefault: boolean
)
	-- Camera
	local Camera: Camera = workspace.CurrentCamera

	-- Restricting Player Movement
	if Player.Character then
		Player.Character.HumanoidRootPart.Anchored = true
	end

	-- Set Camera
	Camera.CameraType = Enum.CameraType.Scriptable

	-- Set Camera Cframe to First Node
	Camera.CFrame = CameraTracks["1"].CFrame

	-- Runs Camera Movement
	local function Process(Node: BasePart)
		-- Start Camera Movement
		self.CurrentTrackNodeTween = TweenService:Create(Camera, TweenInfo, { CFrame = Node.CFrame })
		self.CurrentTrackNodeTween:Play()

		task.wait(TweenInfo.Time - 1)
	end

	-- Loops Thru All the Nodes to Process
	local function RunLoop()
		local sortedTracks = CameraTracks:GetChildren()
		table.sort(sortedTracks, function(a, b)
			return tonumber(a.Name) < tonumber(b.Name)
		end)
		for _, node: BasePart in sortedTracks do
			-- Not Include First Node
			if node.Name == "1" then
				continue
			end

			-- Stops Camera Track
			if self.ForceStopTrack then
				break
			end

			Process(node)
		end

		self.ForceStopTrack = false

		if SetDefault then
			self:SetToDefault()
		end
	end

	if Yield then
		RunLoop()
	else
		task.spawn(RunLoop)
	end
end

-- Stops Camera Track
function CameraController:StopCameraTrack()
	-- UnRestricting Player Movement
	if Player.Character then
		Player.Character.HumanoidRootPart.Anchored = false
	end

	-- Check if There is Actually a Track Running
	if not self.CurrentTrackNodeTween then
		return
	end

	--
	self.ForceStopTrack = true
	self.CurrentTrackNodeTween:Cancel()
end

function CameraController:TweenCameraToCFrame(cFrame: CFrame, tweenInfo: TweenInfo, yield: boolean)
	-- Camera
	local Camera: Camera = workspace.CurrentCamera

	-- Set Camera
	Camera.CameraType = Enum.CameraType.Scriptable

	-- Start Camera Movement
	local cameraTween: Tween = TweenService:Create(Camera, tweenInfo, { CFrame = cFrame })
	cameraTween:Play()

	return yield == true and task.wait(tweenInfo.Time) or nil
end

-- Knit Initialization
function CameraController:KnitInit()
	-- Camera
	local Camera: Camera = workspace.CurrentCamera

	-- Set
	self.ForceStopTrack = false
end

function CameraController:KnitStart() end

return CameraController
