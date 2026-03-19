-- Visuals module
local VisualsModule = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

function VisualsModule:Init(Settings, Utils)
    local ESP = {Objects = {}}
    
    function ESP:Create(Player)
        if self.Objects[Player] then return end
        local Data = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Health = Drawing.new("Line"),
            Dist = Drawing.new("Text"),
            Tracer = Drawing.new("Line")
        }
        self.Objects[Player] = Data
    end

    function ESP:Clear(Player)
        local Data = self.Objects[Player]
        if Data then
            for _, obj in pairs(Data) do pcall(function() obj.Visible = false end) end
        end
    end

    RunService.RenderStepped:Connect(function()
        if Settings.Visuals.Enabled then
            local AllPlayers = Players:GetPlayers()
            for i = 1, #AllPlayers do
                local Plr = AllPlayers[i]
                if Plr ~= LocalPlayer and Utils:IsAlive(Plr) then
                    local TeamCheck = not Settings.Visuals.TeamCheck or (Plr.Team ~= LocalPlayer.Team)
                    if TeamCheck then
                        local Char = Plr.Character
                        local Root = Char:FindFirstChild("HumanoidRootPart")
                        if Root then
                            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                            local Data = self.Objects[Plr]
                            if not Data then self:Create(Plr) Data = self.Objects[Plr] end
                            
                            if OnScreen then
                                local Top = Camera:WorldToViewportPoint(Char.Head.Position + Vector3.new(0, 0.5, 0))
                                local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                                local Height = Bottom.Y - Top.Y
                                local Width = Height / 1.5

                                if Settings.Visuals.Boxes then
                                    Data.Box.Visible = true
                                    Data.Box.Size = Vector2.new(Width, Height)
                                    Data.Box.Position = Vector2.new(Pos.X - Width/2, Top.Y)
                                    Data.Box.Color = Color3.fromRGB(255,255,255)
                                    Data.Box.Thickness = 1
                                else Data.Box.Visible = false end

                                if Settings.Visuals.Names then
                                    Data.Name.Visible = true
                                    Data.Name.Text = Plr.Name
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
                                    Data.Health.Thickness = 2
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
                                    Data.Tracer.Color = Color3.fromRGB(255,255,255)
                                else Data.Tracer.Visible = false end
                            else self:Clear(Plr) end
                        end
                    else self:Clear(Plr) end
                else self:Clear(Plr) end
            end
        else
            for Plr, _ in pairs(self.Objects) do self:Clear(Plr) end
        end
        
        -- FullBright
        if Settings.Visuals.FullBright then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").ClockTime = 14
        end
    end)
    
    self.ESPObjects = self.Objects
end

function VisualsModule:Cleanup()
    for _, Data in pairs(self.ESPObjects) do
        for _, obj in pairs(Data) do obj:Remove() end
    end
end

return VisualsModule
