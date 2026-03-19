--[[
    Kronex Ultimate Edition | Flick All-In-One
    Version: 4.0 (SINGLE FILE)
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

-- // Settings Management
local Settings = {
    Combat = {
        AimbotEnabled = false,
        FlickBot = false,
        AimbotSmoothness = 0.5,
        AimbotFOV = 100,
        ShowFOV = false,
        TeamCheck = true,
        TargetPart = "Head",
        VisibleCheck = true,
        HitboxExpander = false,
        HitboxSize = 2,
        Triggerbot = false,
        TriggerDelay = 50
    },
    Visuals = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,
        TeamCheck = true,
        FullBright = false
    },
    Movement = {
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false,
        Fly = false,
        FlySpeed = 50
    }
}

-- // Utility Functions
local Utils = {}

function Utils:IsAlive(Plr)
    return Plr and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") and Plr.Character.Humanoid.Health > 0
end

function Utils:GetPart(Char, PartName)
    return Char and Char:FindFirstChild(PartName or "Head")
end

function Utils:GetClosestTarget()
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

-- // Combat & Visuals Setup
local FOVDrawing = Drawing.new("Circle")
FOVDrawing.Thickness = 1
FOVDrawing.Color = Color3.fromRGB(255, 255, 255)
FOVDrawing.Filled = false
FOVDrawing.Transparency = 1

local ESP = {Objects = {}}
function ESP:Create(Player)
    if self.Objects[Player] then return end
    self.Objects[Player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        Dist = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
end

function ESP:Clear(Player)
    local Data = self.Objects[Player]
    if Data then
        for _, obj in pairs(Data) do pcall(function() obj.Visible = false end) end
    end
end

-- // Main Update Loop
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVDrawing.Visible = Settings.Combat.ShowFOV
    FOVDrawing.Radius = Settings.Combat.AimbotFOV
    FOVDrawing.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    -- Aimbot / FlickBot
    if Settings.Combat.AimbotEnabled or Settings.Combat.FlickBot then
        local TargetCharacter = Utils:GetClosestTarget()
        if TargetCharacter then
            local Part = Utils:GetPart(TargetCharacter, Settings.Combat.TargetPart)
            if Part then
                if Settings.Combat.FlickBot then
                    local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    local ScreenPos = Vector2.new(Vector.X, Vector.Y)
                    local MousePos = Vector2.new(Mouse.X, Mouse.Y)
                    if (ScreenPos - MousePos).Magnitude < 50 then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Part.Position)
                    end
                else
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
            if Player and Player ~= LocalPlayer and Utils:IsAlive(Player) then
                if not Settings.Combat.TeamCheck or (Player.Team ~= LocalPlayer.Team) then
                    if mouse1click then mouse1click() end
                end
            end
        end
    end

    -- Hitbox & ESP Logic
    if Settings.Visuals.Enabled or Settings.Combat.HitboxExpander then
        for _, Plr in pairs(Players:GetPlayers()) do
            if Plr ~= LocalPlayer and Utils:IsAlive(Plr) then
                local Char = Plr.Character
                local Root = Char:FindFirstChild("HumanoidRootPart")
                
                -- Hitboxes
                if Root then
                    if Settings.Combat.HitboxExpander then
                        Root.Size = Vector3.new(Settings.Combat.HitboxSize, Settings.Combat.HitboxSize, Settings.Combat.HitboxSize)
                        Root.Transparency = 0.7
                        Root.CanCollide = false
                    else
                        Root.Size = Vector3.new(2, 2, 1)
                        Root.Transparency = 1
                        Root.CanCollide = true
                    end

                    -- ESP
                    if Settings.Visuals.Enabled then
                        local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                        local Data = ESP.Objects[Plr]
                        if not Data then ESP:Create(Plr) Data = ESP.Objects[Plr] end
                        
                        if OnScreen then
                            local Top = Camera:WorldToViewportPoint(Char.Head.Position + Vector3.new(0, 0.5, 0))
                            local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                            local Height = Bottom.Y - Top.Y
                            local Width = Height / 1.5

                            if Settings.Visuals.Boxes then
                                Data.Box.Visible = true
                                Data.Box.Size = Vector2.new(Width, Height)
                                Data.Box.Position = Vector2.new(Pos.X - Width/2, Top.Y)
                            else Data.Box.Visible = false end

                            if Settings.Visuals.Names then
                                Data.Name.Visible = true
                                Data.Name.Text = Plr.DisplayName or Plr.Name
                                Data.Name.Position = Vector2.new(Pos.X, Top.Y - 15)
                                Data.Name.Center = true
                                Data.Name.Outline = true
                            else Data.Name.Visible = false end

                            if Settings.Visuals.Health then
                                local H = Char.Humanoid.Health / Char.Humanoid.MaxHealth
                                Data.Health.Visible = true
                                Data.Health.From = Vector2.new(Pos.X - Width/2 - 5, Bottom.Y)
                                Data.Health.To = Vector2.new(Pos.X - Width/2 - 5, Bottom.Y - (Height * H))
                                Data.Health.Color = Color3.fromHSV(H * 0.3, 1, 1)
                            else Data.Health.Visible = false end

                            if Settings.Visuals.Distance then
                                Data.Dist.Visible = true
                                local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if MyRoot then
                                    Data.Dist.Text = math.floor((Root.Position - MyRoot.Position).Magnitude) .. "m"
                                end
                                Data.Dist.Position = Vector2.new(Pos.X, Bottom.Y + 5)
                                Data.Dist.Center = true
                                Data.Dist.Outline = true
                            else Data.Dist.Visible = false end

                            if Settings.Visuals.Tracers then
                                Data.Tracer.Visible = true
                                Data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                                Data.Tracer.To = Vector2.new(Pos.X, Pos.Y)
                            else Data.Tracer.Visible = false end
                        else ESP:Clear(Plr) end
                    else ESP:Clear(Plr) end
                end
            else
                ESP:Clear(Plr)
            end
        end
    else
        for Plr, _ in pairs(ESP.Objects) do ESP:Clear(Plr) end
    end

    -- Movement
    if Utils:IsAlive(LocalPlayer) then
        local Humanoid = LocalPlayer.Character.Humanoid
        Humanoid.WalkSpeed = Settings.Movement.WalkSpeed
        Humanoid.JumpPower = Settings.Movement.JumpPower
        
        if Settings.Movement.InfiniteJump then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        
        if Settings.Movement.Fly then
            local HRP = LocalPlayer.Character.HumanoidRootPart
            local Dir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - Camera.CFrame.RightVector end
            HRP.Velocity = Dir * Settings.Movement.FlySpeed
        end
    end

    -- FullBright
    if Settings.Visuals.FullBright then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 14
    end
end)

-- // UI Module Initialization
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Kronex Ultimate | Flick",
    SubTitle = "v4.0 (AIO)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Combat Tab
Tabs.Combat:AddToggle("AimEn", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) Settings.Combat.AimbotEnabled = v end)
Tabs.Combat:AddToggle("FlickEn", {Title = "Flick Mode", Default = false}):OnChanged(function(v) Settings.Combat.FlickBot = v end)
Tabs.Combat:AddSlider("AimSm", {Title = "Smoothing", Min = 0.1, Max = 1, Default = 0.5, Rounding = 2}):OnChanged(function(v) Settings.Combat.AimbotSmoothness = v end)
Tabs.Combat:AddSlider("AimColorFOV", {Title = "FOV Size", Min = 10, Max = 800, Default = 100}):OnChanged(function(v) Settings.Combat.AimbotFOV = v end)
Tabs.Combat:AddToggle("AimFOVSh", {Title = "Show FOV", Default = false}):OnChanged(function(v) Settings.Combat.ShowFOV = v end)
Tabs.Combat:AddToggle("AimTeam", {Title = "Team Check", Default = true}):OnChanged(function(v) Settings.Combat.TeamCheck = v end)
Tabs.Combat:AddToggle("TrigEn", {Title = "Enable Triggerbot", Default = false}):OnChanged(function(v) Settings.Combat.Triggerbot = v end)
Tabs.Combat:AddToggle("HitEn", {Title = "Hitbox Expander", Default = false}):OnChanged(function(v) Settings.Combat.HitboxExpander = v end)
Tabs.Combat:AddSlider("HitSz", {Title = "Hitbox Size", Min = 2, Max = 15, Default = 2}):OnChanged(function(v) Settings.Combat.HitboxSize = v end)

-- Visuals Tab
Tabs.Visuals:AddToggle("ESPen", {Title = "Enable ESP", Default = false}):OnChanged(function(v) Settings.Visuals.Enabled = v end)
Tabs.Visuals:AddToggle("ESPBox", {Title = "Boxes", Default = true}):OnChanged(function(v) Settings.Visuals.Boxes = v end)
Tabs.Visuals:AddToggle("ESPName", {Title = "Names", Default = true}):OnChanged(function(v) Settings.Visuals.Names = v end)
Tabs.Visuals:AddToggle("ESPHealth", {Title = "Health Bar", Default = true}):OnChanged(function(v) Settings.Visuals.Health = v end)
Tabs.Visuals:AddToggle("ESPDist", {Title = "Distance", Default = true}):OnChanged(function(v) Settings.Visuals.Distance = v end)
Tabs.Visuals:AddToggle("ESPTra", {Title = "Tracers", Default = false}):OnChanged(function(v) Settings.Visuals.Tracers = v end)
Tabs.Visuals:AddToggle("FullBr", {Title = "Full Bright", Default = false}):OnChanged(function(v) Settings.Visuals.FullBright = v end)

-- Movement Tab
Tabs.Movement:AddSlider("WS", {Title = "WalkSpeed", Min = 16, Max = 100, Default = 16}):OnChanged(function(v) Settings.Movement.WalkSpeed = v end)
Tabs.Movement:AddSlider("JP", {Title = "JumpPower", Min = 50, Max = 250, Default = 50}):OnChanged(function(v) Settings.Movement.JumpPower = v end)
Tabs.Movement:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) Settings.Movement.InfiniteJump = v end)
Tabs.Movement:AddToggle("Fly", {Title = "Fly", Default = false}):OnChanged(function(v) Settings.Movement.Fly = v end)
Tabs.Movement:AddSlider("FlySp", {Title = "Fly Speed", Min = 10, Max = 200, Default = 50}):OnChanged(function(v) Settings.Movement.FlySpeed = v end)

-- Settings Tab
Tabs.Settings:AddButton({
    Title = "Destroy UI",
    Callback = function() 
        Window:Destroy() 
        FOVDrawing:Remove()
        for _, Data in pairs(ESP.Objects) do
            for _, obj in pairs(Data) do obj:Remove() end
        end
    end
})

Window:SelectTab(1)
Fluent:Notify({Title = "Kronex Ultimate", Content = "Script loaded successfully!", Duration = 5})
