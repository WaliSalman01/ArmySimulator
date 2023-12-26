local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ids = { 3871689401480867 }
local achievements = {}
for i = 1, 15, 1 do
    if ids[i] == nil then
        achievements[i] = { Name = "NotFound", Description = "NotFound", Obtained = false}
        continue
    end
    -- Fetch Badge information
    local success, result = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, ids[i])
    print(success, result)

    -- Output the information
    if success then
        achievements[i] = { Name = result.Name, Description = result.Description, Obtained = false}
        if not RunService:IsClient() then continue end
        local success, hasBadge = pcall(function()
			return BadgeService:UserHasBadgeAsync(Players.LocalPlayer.UserId, ids[i])
		end)
        if success and hasBadge then
            achievements[i].Obtained = true
        end
    else
        achievements[i] = { Name = "NotFound", Description = "NotFound", Obtained = false}
    end
end

return achievements