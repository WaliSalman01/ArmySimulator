--[[
    PetCustomization.lua
    Author(s): Jibran

    Description: Pet System UIs
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

-- Shared
local Shared = ReplicatedStorage.Shared
local PetsData = require(Shared.PetsData)

-- Modules
local Interface = StarterPlayerScripts.Interface
local Components = Interface.Components
local Common = Components.Common
local TextButton = require(Common.TextButton)
local TextLabel = require(Common.TextLabel)
local ImageButton = require(Common.ImageButton)

-- Fusion Constant Declarations
local New = Fusion.New
local Children = Fusion.Children
local ForPairs = Fusion.ForPairs
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer
local Spring = Fusion.Spring

-- Variables
local defaultParts = {
	Head = "Default",
	Body = "Default",
	Tail = "Default",
	Soul = "Default",
	Back = "Default",
}

-- module class table
local Puzzle = {}

-- Initializing match display UI in player GUI
function Puzzle:Initialize()
	-- Knit Controllers
	self._PetCustomizationController = Knit.GetController("PetsCustomizationController")

	-- Initialize Fusion Values
	self._petParts = Value(defaultParts)
	self._customizationEnabled = Value(false)
	self._selectionEnabled = Value(false)
	self._soulEnabled = Value(false)
	self._currentPet = Value("Default")
	--self._currentSoul = Value("Default")

	local partsObserver = Observer(self._petParts)
	local disconnect = partsObserver:onChange(function() end)

	local currentUI = self:CreateUI(self._currentPuzzleItems)
	currentUI.Parent = PlayerGui

	self._PetCustomizationController._petCustomizationUI = self
end

-- Creating UI from props defined
function Puzzle:CreateUI()
	-- GUIObjectProps
	local headLabelProps = {
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = Spring(Computed(function()
			local parts = self._petParts:get()
			return PetsData[parts.Head].doorId
		end)),
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.8),
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 1,
		TextScaled = true,
		BackgroundTransparency = 1,
	}

	local backLabelProps = {
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = Spring(Computed(function()
			local parts = self._petParts:get()
			return PetsData[parts.Back].doorId
		end)),
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.8),
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 2,
		TextScaled = true,
		BackgroundTransparency = 1,
	}

	local bodyLabelProps = {
		Position = UDim2.fromScale(0.25, 0.5),
		AnchorPoint = Vector2.new(0.25, 0.5),
		Text = Spring(Computed(function()
			local parts = self._petParts:get()
			return PetsData[parts.Body].doorId
		end)),
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.8),
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 3,
		TextScaled = true,
		BackgroundTransparency = 1,
	}

	local tailLabelProps = {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = Spring(Computed(function()
			local parts = self._petParts:get()
			return PetsData[parts.Tail].doorId
		end)),
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.8),
		Font = Enum.Font.SourceSansBold,
		TextScaled = true,
		LayoutOrder = 4,
		BackgroundTransparency = 1,
	}

	local soulLabelProps = {
		Position = UDim2.fromScale(0.75, 0.5),
		AnchorPoint = Vector2.new(0.75, 0.5),
		Text = Spring(Computed(function()
			local parts = self._petParts:get()
			return PetsData[parts.Soul].doorId
		end)),
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.8),
		Font = Enum.Font.SourceSansBold,
		TextScaled = true,
		LayoutOrder = 5,
		BackgroundTransparency = 1,
	}

	local headTitleLabelProps = {
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = "Head",
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.5),
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 1,
		TextScaled = true,
		BackgroundTransparency = 1,
	}

	local backTitleLabelProps = {
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = "Back",
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.5),
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 2,
		TextScaled = true,
		BackgroundTransparency = 1,
	}

	local bodyTitleLabelProps = {
		Position = UDim2.fromScale(0.25, 0.5),
		AnchorPoint = Vector2.new(0.25, 0.5),
		Text = "Body",
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.5),
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 3,
		TextScaled = true,
		BackgroundTransparency = 1,
	}

	local tailTitleLabelProps = {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "Tail",
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.5),
		Font = Enum.Font.SourceSansBold,
		TextScaled = true,
		LayoutOrder = 4,
		BackgroundTransparency = 1,
	}

	local soulTitleLabelProps = {
		Position = UDim2.fromScale(0.75, 0.5),
		AnchorPoint = Vector2.new(0.75, 0.5),
		Text = "Soul",
		TextColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(0.15, 0.5),
		Font = Enum.Font.SourceSansBold,
		TextScaled = true,
		LayoutOrder = 5,
		BackgroundTransparency = 1,
	}

	local selectHeaderProps = {
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Text = Spring(Computed(function()
			return "Select a body part for your daimon from " .. self._currentPet:get()
		end)),
		Size = UDim2.fromScale(0.8, 0.2),
		Font = Enum.Font.SourceSansBold,
		TextColor3 = Color3.new(0, 0, 0),
		TextScaled = true,
		LayoutOrder = 0,
		BackgroundTransparency = 1,
	}

	local soulHeaderProps = {
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Text = Spring(Computed(function()
			if PetsData[self._currentPet:get()] then
				return PetsData[self._currentPet:get()].powerUpTitle
			else
				return ""
			end
		end)),
		TextColor3 = Color3.new(0, 0, 0),
		TextScaled = true,
		Size = UDim2.fromScale(0.7, 0.1),
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 2,
		BackgroundTransparency = 1,
	}

	local soulDescriptionProps = {
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Text = Spring(Computed(function()
			if PetsData[self._currentPet:get()] then
				return PetsData[self._currentPet:get()].powerUpDescription
			else
				return ""
			end
		end)),
		Size = UDim2.fromScale(0.8, 0.1),
		Font = Enum.Font.SourceSansSemibold,
		TextScaled = true,
		LayoutOrder = 3,
		TextColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
	}

	local headButtonLabelProps = {
		Name = "Head",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "HEAD",
		Size = UDim2.fromScale(0.8, 0.35),
		Font = Enum.Font.SourceSansBold,
		BackgroundTransparency = 1,
		TextScaled = true,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 6,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	local headButtonProps = {
		Name = "Head",
		Position = UDim2.fromScale(0.7, 0.8),
		AnchorPoint = Vector2.new(0.7, 0.8),
		Size = UDim2.fromScale(0.6, 0.13),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = "rbxassetid://15435791085",
		HoverImage = "rbxassetid://15310099021",
		ZIndex = 5,
		LayoutOrder = 1,
		callback = function()
			self._PetCustomizationController:UpdatePart("Head")
		end,
		Children = {
			TextLabel(headButtonLabelProps),
		},
	}

	local backButtonLabelProps = {
		Name = "Back",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "BACK",
		Size = UDim2.fromScale(0.8, 0.35),
		Font = Enum.Font.SourceSansBold,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(0, 0, 0),
		TextScaled = true,
		ZIndex = 6,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	local backButtonProps = {
		Name = "Back",
		Position = UDim2.fromScale(0.7, 0.8),
		AnchorPoint = Vector2.new(0.7, 0.8),
		Size = UDim2.fromScale(0.6, 0.13),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = "rbxassetid://15435791085",
		HoverImage = "rbxassetid://15310099021",
		ZIndex = 5,
		LayoutOrder = 2,
		callback = function()
			self._PetCustomizationController:UpdatePart("Back")
		end,
		Children = {
			TextLabel(backButtonLabelProps),
		},
	}

	local tailButtonLabelProps = {
		Name = "Tail",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "TAIL",
		Size = UDim2.fromScale(0.8, 0.35),
		Font = Enum.Font.SourceSansBold,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(0, 0, 0),
		TextScaled = true,
		ZIndex = 6,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	local tailButtonProps = {
		Name = "Tail",
		Position = UDim2.fromScale(0.7, 0.8),
		AnchorPoint = Vector2.new(0.7, 0.8),
		Size = UDim2.fromScale(0.6, 0.13),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = "rbxassetid://15435791085",
		HoverImage = "rbxassetid://15310099021",
		ZIndex = 5,
		LayoutOrder = 4,
		callback = function()
			self._PetCustomizationController:UpdatePart("Tail")
		end,
		Children = {
			TextLabel(tailButtonLabelProps),
		},
	}

	local bodyButtonLabelProps = {
		Name = "BodyLabel",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "BODY",
		Size = UDim2.fromScale(0.8, 0.35),
		Font = Enum.Font.SourceSansBold,
		BackgroundTransparency = 1,
		TextScaled = true,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 6,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	local bodyButtonProps = {
		Name = "Body",
		Position = UDim2.fromScale(0.7, 0.8),
		AnchorPoint = Vector2.new(0.7, 0.8),
		Size = UDim2.fromScale(0.6, 0.13),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = "rbxassetid://15435791085",
		HoverImage = "rbxassetid://15310099021",
		ZIndex = 5,
		LayoutOrder = 2,
		callback = function()
			self._PetCustomizationController:UpdatePart("Body")
		end,
		Children = {
			TextLabel(bodyButtonLabelProps),
		},
	}

	local confirmButtonProps = {
		Name = "Confirm",
		Position = UDim2.fromScale(0.7, 0.8),
		AnchorPoint = Vector2.new(0.7, 0.8),
		Size = UDim2.fromScale(0.1, 0.1),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = "rbxassetid://15367714195",
		HoverImage = "rbxassetid://15435880729",
		ZIndex = 5,
		LayoutOrder = 6,
		callback = function()
			self._PetCustomizationController:ConfirmedSelection()
		end,
	}

	local confirmSoulButtonProps = {
		Name = "Confirm",
		Position = UDim2.fromScale(0.7, 0.8),
		AnchorPoint = Vector2.new(0.7, 0.8),
		Size = UDim2.fromScale(0.2, 1),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = "rbxassetid://15367714195",
		HoverImage = "rbxassetid://15435880729",
		ZIndex = 5,
		LayoutOrder = 1,
		callback = function()
			self._PetCustomizationController:UpdatePart("Soul")
			self._PetCustomizationController:ConfirmedSelection(true)
		end,
	}

	local cancelSoulButtonProps = {
		Name = "Cancel",
		Position = UDim2.fromScale(0.7, 0.8),
		AnchorPoint = Vector2.new(0.7, 0.8),
		Size = UDim2.fromScale(0.2, 1),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = "rbxassetid://15447179115",
		HoverImage = "rbxassetid://15447179742",
		ZIndex = 5,
		LayoutOrder = 2,
		callback = function()
			self._PetCustomizationController:CancelSelection()
		end,
	}

	-- Creating GUI with elements
	return New("ScreenGui")({
		Name = "PetCustomization",
		Enabled = true,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		[Children] = {
			New("Frame")({
				Name = "CurrentPartsFrame",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = Spring(Computed(function()
					if self._customizationEnabled:get() then
						return UDim2.fromScale(0.5, 1)
					else
						return UDim2.fromScale(0.5, 2)
					end
				end)),
				Size = UDim2.fromScale(0.3, 0.2),
				[Children] = {
					New("ImageLabel")({
						Name = "BG",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						ScaleType = Enum.ScaleType.Stretch,
						LayoutOrder = 0,
						BackgroundTransparency = 1,
						Image = "rbxassetid://15561541866",
					}),
					New("UIAspectRatioConstraint")({
						AspectRatio = 5,
					}),

					New("Frame")({
						Name = "ElementsBottom",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.fromScale(1, 0.7),
						[Children] = {
							New("UIListLayout")({
								Padding = UDim.new(0.05, 0),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							TextLabel(headLabelProps),
							TextLabel(tailLabelProps),
							TextLabel(bodyLabelProps),
							TextLabel(backLabelProps),
							TextLabel(soulLabelProps),
						},
					}),

					New("Frame")({
						Name = "ElementsTop",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.fromScale(1, 0.4),
						[Children] = {
							New("UIListLayout")({
								Padding = UDim.new(0.05, 0),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							TextLabel(headTitleLabelProps),
							TextLabel(tailTitleLabelProps),
							TextLabel(bodyTitleLabelProps),
							TextLabel(backTitleLabelProps),
							TextLabel(soulTitleLabelProps),
						},
					}),
				},
			}),
			New("Frame")({
				Name = "SelectPartsFrame",
				BackgroundTransparency = 0.6,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0.8, 0),
				Position = Spring(Computed(function()
					if self._selectionEnabled:get() then
						return UDim2.fromScale(0.8, 0)
					else
						return UDim2.fromScale(0.8, -1)
					end
				end)),
				Size = UDim2.fromScale(0.3, 0.5),
				[Children] = {
					New("UICorner")({
						CornerRadius = UDim.new(0, 20),
					}),
					New("UIAspectRatioConstraint")({
						AspectRatio = 1,
					}),
					New("ImageLabel")({
						AnchorPoint = Vector2.new(0.5, 0.1),
						Position = UDim2.fromScale(0.5, 0.1),
						Size = UDim2.fromScale(0.8, 0.004),
						ScaleType = Enum.ScaleType.Fit,
						LayoutOrder = 0,
						BackgroundTransparency = 1,
						Image = "rbxassetid://15367692321",
					}),

					New("Frame")({
						Name = "Buttons",
						Size = UDim2.fromScale(1, 0.8),
						Position = UDim2.fromScale(0.5, 0.8),
						AnchorPoint = Vector2.new(0.5, 0.8),
						BackgroundTransparency = 1,
						[Children] = {
							New("UIListLayout")({
								Padding = UDim.new(0.05, 0),
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),

							TextLabel(selectHeaderProps),
							ImageButton(headButtonProps),
							ImageButton(bodyButtonProps),
							ImageButton(tailButtonProps),
							ImageButton(backButtonProps),
							--	ImageButton(confirmButtonProps),
						},
					}),
				},
			}),
			New("Frame")({
				Name = "SoulFrame",
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = Spring(Computed(function()
					if self._soulEnabled:get() then
						return UDim2.fromScale(0.5, 0.5)
					else
						return UDim2.fromScale(0.5, -1)
					end
				end)),
				Size = UDim2.fromScale(0.2, 0.6),
				[Children] = {
					New("UICorner")({
						CornerRadius = UDim.new(0, 20),
					}),
					New("Frame")({
						Name = "Elements",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),

						[Children] = {
							New("UIListLayout")({
								Padding = UDim.new(0.05, 0),
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							New("ImageLabel")({
								Name = "PowerupIcon",
								Position = UDim2.fromScale(0.5, 0.1),
								AnchorPoint = Vector2.new(0.5, 0.1),
								Size = UDim2.fromScale(0.4, 0.3),
								ScaleType = Enum.ScaleType.Fit,
								ZIndex = 3,
								ImageColor3 = Color3.fromRGB(0, 0, 0),
								LayoutOrder = 1,
								Image = Computed(function()
									if PetsData[self._currentPet:get()] then
										return PetsData[self._currentPet:get()].powerupIcon
									else
										return ""
									end
								end),
								BackgroundTransparency = 1,
							}),
							TextLabel(soulHeaderProps),
							TextLabel(soulDescriptionProps),
							New("Frame")({
								Name = "Buttons",
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 0.15),
								LayoutOrder = 4,
								[Children] = {
									New("UIListLayout")({
										Padding = UDim.new(0.05, 0),
										FillDirection = Enum.FillDirection.Horizontal,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
										VerticalAlignment = Enum.VerticalAlignment.Center,
										SortOrder = Enum.SortOrder.LayoutOrder,
									}),
									ImageButton(cancelSoulButtonProps),
									ImageButton(confirmSoulButtonProps),
								},
							}),
						},
					}),

					New("ImageLabel")({
						Image = "rbxassetid://15367859582",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
					}),
					New("UIAspectRatioConstraint")({
						AspectRatio = 1,
					}),
				},
			}),
		},
	})
end

return Puzzle
