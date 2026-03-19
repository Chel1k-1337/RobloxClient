--[[
    Kronex Ultimate Edition | Flick All-In-One
    Version: 7.5 (FINAL FIXED SMOOTH)
    Status: Undetected
]]

-- // Environment Setup
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // Drawing Setup
local FOVDrawing = Drawing.new("Circle")
FOVDrawing.Thickness = 1.5
FOVDrawing.Color = Color3.fromRGB(240, 240, 240)
FOVDrawing.NumSides = 100
FOVDrawing.Filled = false
FOVDrawing.Transparency = 1
FOVDrawing.Visible = false

-- // Settings Management
local Settings = {
    Combat = {
        AimbotEnabled = false,
        AimbotSmoothness = 0.5,
        AimbotFOV = 150,
        ShowFOV = false,
        TeamCheck = true,
        TargetPart = "Head"
    },
    Visuals = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Tracers = false,
        TeamCheck = true
    },
    Movement = {
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false
    }
}

-- // Utility Functions
local Utils = {}
function Utils:IsAlive(Plr)
    return Plr and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") and Plr.Character.Humanoid.Health > 0
end

function Utils:GetClosestTarget()
    local BestTarget = nil
    local MaxDist = Settings.Combat.AimbotFOV
    local MousePos = UserInputService:GetMouseLocation()
    
    for _, Plr in pairs(Players:GetPlayers()) do
        if Plr ~= LocalPlayer and Utils:IsAlive(Plr) then
            if not Settings.Combat.TeamCheck or (Plr.Team ~= LocalPlayer.Team) then
                local Part = Plr.Character:FindFirstChild(Settings.Combat.TargetPart)
                if Part then
                    local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local Dist = (MousePos - Vector2.new(Vector.X, Vector.Y)).Magnitude
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

-- // ESP System
local ESP = {Objects = {}}
function ESP:Create(Player)
    if self.Objects[Player] then return end
    self.Objects[Player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        HealthBg = Drawing.new("Line"),
        Tracer = Drawing.new("Line")
    }
    local obj = self.Objects[Player]
    obj.Box.Thickness = 1
    obj.Name.Size = 14
    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Health.Thickness = 2
    obj.HealthBg.Thickness = 2
    obj.HealthBg.Color = Color3.fromRGB(0, 0, 0)
end

function ESP:Clear(Player)
    local Data = self.Objects[Player]
    if Data then
        for _, obj in pairs(Data) do pcall(function() obj.Visible = false end) end
    end
end

-- // Main Update Loop
RunService.RenderStepped:Connect(function()
    local MousePos = UserInputService:GetMouseLocation()
    
    -- FOV Update
    FOVDrawing.Visible = Settings.Combat.ShowFOV
    FOVDrawing.Radius = Settings.Combat.AimbotFOV
    FOVDrawing.Position = MousePos

    -- Aimbot (SMOOTH MOUSE)
    if Settings.Combat.AimbotEnabled then
        local TargetChar = Utils:GetClosestTarget()
        if TargetChar then
            local Part = TargetChar:FindFirstChild(Settings.Combat.TargetPart)
            if Part then
                local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                if OnScreen then
                    local ScreenPos = Vector2.new(Vector.X, Vector.Y)
                    local Delta = (ScreenPos - MousePos)
                    local Smooth = (11 - Settings.Combat.AimbotSmoothness * 10) -- Adjust for better feel
                    if mousemoverel then
                        mousemoverel(Delta.X / Smooth, Delta.Y / Smooth)
                    end
                end
            end
        end
    end

    -- Visuals ESP & Hitboxes
    for _, Plr in pairs(Players:GetPlayers()) do
        if Plr ~= LocalPlayer and Utils:IsAlive(Plr) then
            local Char = Plr.Character
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            
            if Root and Hum then
                local Data = ESP.Objects[Plr]
                if Settings.Visuals.Enabled then
                    if not Data then ESP:Create(Plr) Data = ESP.Objects[Plr] end
                    local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    
                    if OnScreen then
                        local Head = Char:FindFirstChild("Head") or Root
                        local HeadPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                        local LegPos = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                        local Height = math.abs(HeadPos.Y - LegPos.Y)
                        local Width = Height / 1.5
                        local TopLeft = Vector2.new(Pos.X - Width/2, HeadPos.Y)

                        if Settings.Visuals.Boxes then
                            Data.Box.Visible = true
                            Data.Box.Size = Vector2.new(Width, Height)
                            Data.Box.Position = TopLeft
                            Data.Box.Color = Color3.fromRGB(255, 255, 255)
                        else Data.Box.Visible = false end

                        if Settings.Visuals.Names then
                            Data.Name.Visible = true
                            Data.Name.Text = Plr.DisplayName or Plr.Name
                            Data.Name.Position = Vector2.new(Pos.X, TopLeft.Y - 16)
                        else Data.Name.Visible = false end

                        if Settings.Visuals.Health then
                            local HPPercent = Hum.Health / Hum.MaxHealth
                            Data.HealthBg.Visible = true
                            Data.HealthBg.From = Vector2.new(TopLeft.X - 5, TopLeft.Y + Height)
                            Data.HealthBg.To = Vector2.new(TopLeft.X - 5, TopLeft.Y)
                            
                            Data.Health.Visible = true
                            Data.Health.From = Vector2.new(TopLeft.X - 5, TopLeft.Y + Height)
                            Data.Health.To = Vector2.new(TopLeft.X - 5, TopLeft.Y + Height - (Height * HPPercent))
                            Data.Health.Color = Color3.fromHSV(HPPercent * 0.3, 1, 1)
                        else Data.Health.Visible = false; Data.HealthBg.Visible = false end

                        if Settings.Visuals.Tracers then
                            Data.Tracer.Visible = true
                            Data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            Data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
                            Data.Tracer.Color = Color3.fromRGB(255, 255, 255)
                        else Data.Tracer.Visible = false end
                    else ESP:Clear(Plr) end
                else ESP:Clear(Plr) end
            end
        else ESP:Clear(Plr) end
    end

    -- Movement Loop
    if Utils:IsAlive(LocalPlayer) then
        local Hum = LocalPlayer.Character.Humanoid
        Hum.WalkSpeed = Settings.Movement.WalkSpeed
        Hum.JumpPower = Settings.Movement.JumpPower
        if Settings.Movement.InfiniteJump then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- // UI (Fluent)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Kronex Ultimate",
    SubTitle = "v7.5 Final Fix",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" })
}

-- COMBAT TAB
Tabs.Combat:AddToggle("AimEn", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) Settings.Combat.AimbotEnabled = v end)
Tabs.Combat:AddToggle("FovSh", {Title = "Show FOV Circle", Default = false}):OnChanged(function(v) Settings.Combat.ShowFOV = v end)
Tabs.Combat:AddSlider("AimSm", {Title = "Aim Smoothness", Min = 0.1, Max = 1, Default = 0.5, Rounding = 2}):OnChanged(function(v) Settings.Combat.AimbotSmoothness = v end)
Tabs.Combat:AddSlider("AimFov", {Title = "Aim FOV Size", Min = 10, Max = 800, Default = 150}):OnChanged(function(v) Settings.Combat.AimbotFOV = v end)

-- VISUALS TAB
Tabs.Visuals:AddToggle("ESPen", {Title = "Enable Visuals", Default = false}):OnChanged(function(v) Settings.Visuals.Enabled = v end)
Tabs.Visuals:AddToggle("EspBox", {Title = "2D Boxes", Default = true}):OnChanged(function(v) Settings.Visuals.Boxes = v end)
Tabs.Visuals:AddToggle("EspName", {Title = "Player Names", Default = true}):OnChanged(function(v) Settings.Visuals.Names = v end)
Tabs.Visuals:AddToggle("EspHealth", {Title = "Health Bars", Default = true}):OnChanged(function(v) Settings.Visuals.Health = v end)
Tabs.Visuals:AddToggle("EspTrace", {Title = "Tracers", Default = false}):OnChanged(function(v) Settings.Visuals.Tracers = v end)

-- MOVEMENT TAB
Tabs.Movement:AddSlider("WS", {Title = "WalkSpeed", Min = 16, Max = 100, Default = 16}):OnChanged(function(v) Settings.Movement.WalkSpeed = v end)
Tabs.Movement:AddSlider("JP", {Title = "JumpPower", Min = 50, Max = 250, Default = 50}):OnChanged(function(v) Settings.Movement.JumpPower = v end)
Tabs.Movement:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) Settings.Movement.InfiniteJump = v end)

Window:SelectTab(1)
Fluent:Notify({Title = "Kronex", Content = "Script Fixed & Loaded!", Duration = 5})