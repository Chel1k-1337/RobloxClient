--[[
    Flick | Kronex Ultimate Edition
    Version: 3.0 (MODULAR)
    Status: Undetected
]]

-- Load Settings
local function LoadModule(Path)
    -- Try with prefix first
    local Success, Content = pcall(function() return readfile(Path) end)
    if not Success or not Content then
        -- Try without prefix
        local NoPrefix = Path:gsub("KronexClient/", "")
        Success, Content = pcall(function() return readfile(NoPrefix) end)
    end
    
    if Success and Content then
        return loadstring(Content)()
    else
        error("Module not found: " .. Path .. ". Ensure files are in 'workspace/KronexClient' or 'workspace/'")
    end
end

local Settings = LoadModule("KronexClient/settings.lua")
local Utils = LoadModule("KronexClient/utils.lua")

-- Load Modules
local Combat = LoadModule("KronexClient/modules/combat.lua")
local Visuals = LoadModule("KronexClient/modules/visuals.lua")
local Movement = LoadModule("KronexClient/modules/movement.lua")
local GUI = LoadModule("KronexClient/gui.lua")

-- Init Modules
Combat:Init(Settings, Utils)
Visuals:Init(Settings, Utils)
Movement:Init(Settings, Utils)
GUI:Init(Settings)

print("Kronex Ultra v3.0 Loaded!")
