-- Utility functions for Flick cheat
local Utils = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function Utils:IsAlive(Plr)
    return Plr and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") and Plr.Character.Humanoid.Health > 0
end

function Utils:GetPart(Char, PartName)
    return Char and Char:FindFirstChild(PartName or "Head")
end

function Utils:GetTeam(Plr)
    return Plr.Team
end

function Utils:GetClosestTarget(Settings)
    local BestTarget = nil
    local MaxDist = Settings.Combat.AimbotFOV
    
    local AllPlayers = Players:GetPlayers()
    for i = 1, #AllPlayers do
        local Plr = AllPlayers[i]
        if Plr ~= LocalPlayer and Utils:IsAlive(Plr) then
            local TeamCheck = not Settings.Combat.TeamCheck or (Plr.Team ~= LocalPlayer.Team)
            if TeamCheck then
                local Part = Utils:GetPart(Plr.Character, Settings.Combat.TargetPart)
                if Part then
                    local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
                        if Dist < MaxDist then
                            MaxDist = Dist
                            BestTarget = Plr.Character
                        end
                    end
                end
            end
        end
    end
    return BestTarget
end

return Utils
