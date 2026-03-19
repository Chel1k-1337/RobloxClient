-- Combat module
local CombatModule = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

function CombatModule:Init(Settings, Utils)
    local FOVDrawing = Drawing.new("Circle")
    FOVDrawing.Thickness = 1
    FOVDrawing.Color = Color3.fromRGB(255, 255, 255)
    FOVDrawing.Filled = false
    FOVDrawing.Transparency = 1

    RunService.RenderStepped:Connect(function()
        -- FOV
        FOVDrawing.Visible = Settings.Combat.ShowFOV
        FOVDrawing.Radius = Settings.Combat.AimbotFOV
        FOVDrawing.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

        -- Aimbot / FlickBot
        if Settings.Combat.AimbotEnabled or Settings.Combat.FlickBot then
            local TargetCharacter = Utils:GetClosestTarget(Settings)
            if TargetCharacter then
                local Part = Utils:GetPart(TargetCharacter, Settings.Combat.TargetPart)
                if Part then
                    if Settings.Combat.FlickBot then
                        -- Snap suddenly when within a certain trigger range
                        local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                        local ScreenPos = Vector2.new(Vector.X, Vector.Y)
                        local MousePos = Vector2.new(Mouse.X, Mouse.Y)
                        if (ScreenPos - MousePos).Magnitude < 50 then -- Trigger flick when close
                             Camera.CFrame = CFrame.new(Camera.CFrame.Position, Part.Position)
                        end
                    else
                        -- Smooth Lerp
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Part.Position), Settings.Combat.AimbotSmoothness / 5)
                    end
                end
            end
        end

        -- Triggerbot
        if Settings.Combat.Triggerbot then
            local Target = Mouse.Target
            if Target and Target.Parent then
                local Player = Players:GetPlayerFromCharacter(Target.Parent)
                if Player and Player ~= Players.LocalPlayer and Utils:IsAlive(Player) then
                    local TeamCheck = not Settings.Combat.TeamCheck or (Player.Team ~= Players.LocalPlayer.Team)
                    if TeamCheck then
                        if mouse1click then mouse1click() end
                    end
                end
            end
        end

        -- Hitbox Expander / Reset
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and Utils:IsAlive(player) then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if Settings.Combat.HitboxExpander then
                        hrp.Size = Vector3.new(Settings.Combat.HitboxSize, Settings.Combat.HitboxSize, Settings.Combat.HitboxSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                    else
                        -- Reset to default
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                        hrp.CanCollide = true
                    end
                end
            end
        end
    end)
    
    self.FOVDrawing = FOVDrawing
end

function CombatModule:Cleanup()
    if self.FOVDrawing then self.FOVDrawing:Remove() end
end

return CombatModule
