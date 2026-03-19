-- Settings module
local Settings = {
    Combat = {
        AimbotEnabled = false,
        AimbotSmoothness = 0.5,
        AimbotFOV = 100,
        ShowFOV = false,
        FlickBot = false,
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
    },
    UI = {
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift
    }
}

return Settings
