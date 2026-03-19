-- Movement module
local MovementModule = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

function MovementModule:Init(Settings, Utils)
    RunService.RenderStepped:Connect(function()
        if Utils:IsAlive(LocalPlayer) then
            local Humanoid = LocalPlayer.Character.Humanoid
            
            -- WalkSpeed
            if Settings.Movement.WalkSpeed ~= 16 then
                Humanoid.WalkSpeed = Settings.Movement.WalkSpeed
            end
            
            -- JumpPower
            if Settings.Movement.JumpPower ~= 50 then
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = Settings.Movement.JumpPower
            end
            
            -- Infinite Jump
            if Settings.Movement.InfiniteJump then
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            
            -- Simple Fly
            if Settings.Movement.Fly then
                local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if HRP then
                    local Camera = workspace.CurrentCamera
                    local Dir = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Dir = Dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Dir = Dir - Vector3.new(0, 1, 0) end
                    
                    HRP.Velocity = Dir * Settings.Movement.FlySpeed
                end
            end
        end
    end)
end

return MovementModule
