--[[
    Flick | Kronex Ultimate Edition
    Version: 3.1 (Cloud & Local)
    Status: Undetected
]]

local BaseURL = "https://raw.githubusercontent.com/Chel1k-1337/RobloxClient/main/"

-- Advanced Module Loader
local function LoadModule(Path)
    -- 1. Try Local File first
    local Success, Content = pcall(function() return readfile(Path) end)
    
    if not Success or not Content then
        -- 2. Try Local File without 'KronexClient/' prefix
        local NoPrefix = Path:gsub("KronexClient/", "")
        Success, Content = pcall(function() return readfile(NoPrefix) end)
    end
    
    if Success and Content then
        print("Loaded local module: " .. Path)
        return loadstring(Content)()
    else
        -- 3. Fallback to GitHub (Cloud Mode)
        print("Local module not found, fetching from GitHub: " .. Path)
        local RemotePath = Path:gsub("KronexClient/", "")
        local CloudContent = game:HttpGet(BaseURL .. RemotePath)
        
        if CloudContent and #CloudContent > 5 then
            return loadstring(CloudContent)()
        else
            error("CRITICAL: Module not found locally or on GitHub: " .. Path)
        end
    end
end

-- Load Config & Utils
local Settings = LoadModule("KronexClient/settings.lua")
local Utils = LoadModule("KronexClient/utils.lua")

-- Load Features
local Combat = LoadModule("KronexClient/modules/combat.lua")
local Visuals = LoadModule("KronexClient/modules/visuals.lua")
local Movement = LoadModule("KronexClient/modules/movement.lua")
local GUI = LoadModule("KronexClient/gui.lua")

-- Initialize
Combat:Init(Settings, Utils)
Visuals:Init(Settings, Utils)
Movement:Init(Settings, Utils)
GUI:Init(Settings)

print("Kronex Ultra v3.1 Loaded Successfully!")
