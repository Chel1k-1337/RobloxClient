-- GUI module using Fluent
local GUIModule = {}
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

function GUIModule:Init(Settings)
    local Window = Fluent:CreateWindow({
        Title = "Flick | Kronex Ultra",
        SubTitle = "v2.6",
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
        end
    })

    Window:SelectTab(1)

    Fluent:Notify({
        Title = "Kronex Ultra",
        Content = "Cheat modules loaded successfully!",
        Duration = 5
    })
    
    self.Window = Window
end

return GUIModule
