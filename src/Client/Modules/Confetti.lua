--[[
	A 'confetti cannon' which fires confetti particles in response to an event.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Packages: Folder = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Cleanup = Fusion.Cleanup

local Value = Fusion.Value
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Interface = PlayerScripts.Interface
local Components = Interface.Components
local Common = Components.Common
local ImageLabel = require(Common.ImageLabel)

-- firing constants
local FUZZ = 0.2
local FORCE = 30
local FORCE_FUZZ = 30
local AMOUNT = 20
-- physics constants
local DRAG = 0.95
local GRAVITY = 0.4
local ROTATE_SPEED = 1

local function Confetti(props)
	local cleanupTasks = {}
	
	local random = Random.new()
	-- we save particles into the keys of this table, not the values
	-- this means each particle is it's own unique, stable key
	local particleSet = Value({})
	
	local function fireConfetti(amount, origin, direction)
		local newParticleSet = particleSet:get()
		
		for _=1, amount do
			local velocity = direction.Unit
			velocity += Vector2.new(random:NextNumber(-FUZZ, FUZZ), random:NextNumber(-FUZZ, FUZZ))
			velocity = velocity.Unit * (FORCE + random:NextNumber(-FORCE_FUZZ, FORCE_FUZZ))
			
			newParticleSet[{
				-- generate a unique id for every particle
				id = HttpService:GenerateGUID(),
				-- store vars used by UI in state objects
				x = Value(origin.X),
				y = Value(origin.Y),
				rotation = Value(random:NextInteger(0, 360)),
				life = Value(5 + random:NextNumber(0, 2)),
				
				-- physics vars
				velocityX = velocity.X,
				velocityY = velocity.Y
			}] = true
		end
		
		particleSet:set(newParticleSet)
	end
	
	-- declare confetti stage ahead of time so we can get screen dimensions
	local stage: Frame
	table.insert(cleanupTasks,
		props.Event:Connect(function()
			local amount = AMOUNT
			-- Left Side
			fireConfetti(amount, stage.AbsoluteSize * Vector2.new(0, 1), Vector2.new(1, -1))
			fireConfetti(amount, stage.AbsoluteSize * Vector2.new(0, .5), Vector2.new(1, -1))
			-- Right Side
			fireConfetti(amount, stage.AbsoluteSize * Vector2.new(1, .5), Vector2.new(-1, -1))
			fireConfetti(amount, stage.AbsoluteSize * Vector2.new(1, 1), Vector2.new(-1, -1))
			
		end)
	)
	
	-- simulate particles on render step
	-- TODO: how should this be made framerate-independent?
	table.insert(cleanupTasks,
		RunService.RenderStepped:Connect(function(deltaTime)
			local newParticleSet = particleSet:get()
			
			for particle in pairs(newParticleSet) do
				local newLife = particle.life:get() - deltaTime
				if newLife <= 0 then
					newParticleSet[particle] = nil
					continue
				else
					particle.life:set(newLife)
				end
				
				particle.x:set(particle.x:get() + particle.velocityX)
				particle.y:set(particle.y:get() + particle.velocityY)
				particle.velocityX *= DRAG
				particle.velocityY *= DRAG
				particle.velocityY += GRAVITY
				
				particle.rotation:set(particle.rotation:get() + ROTATE_SPEED)
			end
			
			particleSet:set(newParticleSet)
		end)
	)
	
	stage = New "Frame" {
		Name = "ConfettiStage",
		
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = -100,
		
		[Cleanup] = cleanupTasks,
		
		[Children] = ForPairs(particleSet, function(particle)
			local confettiLength = math.random(1, 2) * .1
			local confettiWidth = confettiLength
			local confettiColour = Color3.fromHSV(random:NextNumber(), 0.8, 1)
			local particleImageProps = {
				Name = "ParticleImage",
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
				BackgroundTransparency = 1,
				Image = "rbxassetid://5946093983",
				ImageColor3 = Color3.new(0.960784, 0.8, 0.458823),
				ZIndex = 2,
			}
			return particle.id, New "Frame" {
				Name = "Confetti",
				
				Position = Computed(function()
					return UDim2.fromOffset(particle.x:get(), particle.y:get())
				end),
				
				Size = UDim2.fromScale(.02, .04),
				Rotation = particle.rotation,
				BackgroundTransparency = 1,
				--BackgroundColor3 = confettiColour,
				[Children] = {
					ImageLabel(particleImageProps)
				}

			}
		end, Fusion.cleanup)
	}
	
	return stage
end

return Confetti