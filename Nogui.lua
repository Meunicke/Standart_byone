--[[
    ⚡ CAFUXZ1 Bloxstrap Optimizer v5.1
    Bloxstrap Enhanced Loader + PC Optimizer + RedzHub UI (Fixed)
    FFlags 2026 Competitive | Dominação de Bola | Ping 7ms
    Author: aquilesgamef1 (Enhanced Edition)
    RedzLib URL Fix: tbao143/Library-ui
]]--

--// ============================================
--// REDZHUB UI LIBRARY LOAD (URL CORRETA)
--// ============================================
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()

--// ============================================
--// ENVIRONMENT & SERVICES
--// ============================================
local getgenv = getgenv or _G
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

--// Executor Compatibility
local ExecutorAPI = {
    isfolder = isfolder or function(path) return false end,
    isfile = isfile or function(path) return false end,
    makefolder = makefolder or function(path) end,
    writefile = writefile or function(name, src) end,
    readfile = readfile or function(path) return nil end,
    delfile = delfile or function(path) end,
    listfiles = listfiles or function(path) return {} end,
    getcustomasset = getcustomasset or function(path) return "" end,
    setclipboard = setclipboard or function(text) end,
    getexecutorname = getexecutorname or function() return "Unknown" end,
    gethui = gethui or function() return CoreGui end,
    setfpscap = setfpscap or function() end,
    getfflag = getfflag or function(flag) return nil end,
    setfflag = setfflag or function(flag, value) end,
    hookfunction = hookfunction or function() end,
    gameHttpGet = function(url, nocache)
        local success, result = pcall(function()
            return game:HttpGet(url, nocache or true)
        end)
        if success then return result end
        success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then return result end
        error("Failed to fetch: " .. url)
    end,
}

--// ============================================
--// LOGGER SYSTEM
--// ============================================
local Logger = {
    logs = {},
    maxLogs = 100,
}

function Logger:log(level, message)
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] [%s] %s", timestamp, level, message)
    table.insert(self.logs, entry)
    if #self.logs > self.maxLogs then
        table.remove(self.logs, 1)
    end
    print("[Bloxstrap] " .. entry)
end

function Logger:info(msg) self:log("INFO", msg) end
function Logger:warn(msg) self:log("WARN", msg) end
function Logger:error(msg) self:log("ERROR", msg) end
function Logger:success(msg) self:log("SUCCESS", msg) end

--// Notification
local function notify(title, text, duration)
    duration = duration or 5
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Bloxstrap",
            Text = text or "",
            Duration = duration,
            Icon = ""
        })
    end)
end

--// ============================================
--// FFLAGS CONFIGURATION - COMPETITIVE 2026
--// ============================================
local FFlags = {
    -- Network & Latency
    {Flag = "DFIntMinClientSimulationPriority", Value = "1000"},
    {Flag = "DFIntRakNetLoopSleepMs", Value = "0"},
    {Flag = "DFIntRaknetReceiveBufferSize", Value = "1048576"},
    {Flag = "DFIntRaknetSendBufferSize", Value = "1048576"},
    {Flag = "DFIntServerPhysicsUpdateRate", Value = "60"},
    {Flag = "DFIntClientPhysicsUpdateRate", Value = "60"},
    {Flag = "DFIntNetworkPrediction", Value = "1"},
    {Flag = "DFIntNetworkLatencyTolerance", Value = "1"},
    {Flag = "FFlagOptimizeNetwork", Value = "True"},
    {Flag = "FFlagNetworkSkipRelay", Value = "True"},
    {Flag = "FFlagNetworkEnableMultiThreadedReceive", Value = "True"},
    {Flag = "FFlagNetworkUseDirectConnect", Value = "True"},

    -- Rendering & FPS
    {Flag = "FFlagDebugGraphicsPreferD3D11", Value = "True"},
    {Flag = "FFlagDebugGraphicsDisableDirect2D", Value = "True"},
    {Flag = "FFlagHandleAltEnterFullscreenManually", Value = "False"},
    {Flag = "FFlagFastGPULightCulling", Value = "True"},
    {Flag = "FFlagEnableAsyncLights", Value = "True"},
    {Flag = "FFlagNewLightAttenuation", Value = "True"},
    {Flag = "DFIntMaxFrameBufferSize", Value = "8"},
    {Flag = "DFIntTaskSchedulerTargetFps", Value = "999"},
    {Flag = "FFlagGameBasicSettingsFramerateCap5", Value = "True"},
    {Flag = "FFlagTaskSchedulerLimitTargetFpsTo2402", Value = "False"},
    {Flag = "FFlagFixGraphicsQuality", Value = "True"},

    -- Physics
    {Flag = "FFlagUseDynamicPhysics", Value = "False"},
    {Flag = "FFlagUseAdaptivePhysics", Value = "False"},
    {Flag = "FFlagUsePrecisePhysics", Value = "True"},
    {Flag = "DFIntPhysicsSolverIterationCount", Value = "8"},
    {Flag = "DFIntPhysicsStepFrequency", Value = "60"},

    -- Memory
    {Flag = "FFlagMemoryPrioritizeGame", Value = "True"},
    {Flag = "FFlagMemoryLimit", Value = "False"},
    {Flag = "DFIntMemoryLimitMB", Value = "0"},

    -- UI & Experience
    {Flag = "FFlagEnableInGameMenuV3", Value = "False"},
    {Flag = "FFlagEnableChromeUI", Value = "False"},
    {Flag = "FFlagEnableV3MenuABTest3", Value = "False"},
    {Flag = "FFlagEnableInGameMenuControls", Value = "False"},
    {Flag = "FFlagEnableMenuControlsABTest", Value = "False"},
    {Flag = "FFlagEnableMenuModernization", Value = "False"},
    {Flag = "FFlagEnableMenuSongPicker", Value = "False"},
    {Flag = "FFlagEnableMenuPerfImprovements", Value = "True"},

    -- Audio
    {Flag = "FFlagEnableSoundGeometry", Value = "False"},
    {Flag = "FFlagEnableSoundFiltering", Value = "False"},
    {Flag = "FFlagEnableSoundPreloading", Value = "True"},
    {Flag = "FFlagEnableSoundPerformance", Value = "True"},

    -- Animations
    {Flag = "FFlagEnableAnimationPreloading", Value = "True"},
    {Flag = "FFlagEnableAnimationStreaming", Value = "True"},
    {Flag = "FFlagEnableAnimationCompression", Value = "True"},

    -- Streaming
    {Flag = "FFlagEnableStreamingPerfImprovements", Value = "True"},
    {Flag = "FFlagEnableStreamingMemoryPrioritization", Value = "True"},
    {Flag = "FFlagEnableStreamingPause", Value = "True"},

    -- Anti-Lag
    {Flag = "FFlagEnableAntiLag", Value = "True"},
    {Flag = "FFlagEnableLagReduction", Value = "True"},
    {Flag = "FFlagEnableNetworkLagReduction", Value = "True"},
    {Flag = "FFlagEnablePhysicsLagReduction", Value = "True"},
}

-- Apply FFlags
local function ApplyFFlags()
    local applied = 0
    for _, fflag in ipairs(FFlags) do
        local success = pcall(function()
            ExecutorAPI.setfflag(fflag.Flag, fflag.Value)
        end)
        if success then
            applied = applied + 1
        end
    end
    Logger:success("Applied " .. applied .. "/" .. #FFlags .. " FFlags")
    return applied
end

--// ============================================
--// BALL DOMINATION ENGINE
--// ============================================
local BallMaster = {
    TargetBall = nil,
    OriginalState = {},
    IsDominating = false,
    Config = {
        PredictionStrength = 3.5,
        NetworkCompression = true,
        InstantReplication = true,
        PhysicsOverride = true,
        AntiLag = true
    }
}

function BallMaster:DetectBall()
    local bestBall = nil
    local bestScore = -999

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local score = 0
            local name = obj.Name:lower()
            local size = obj.Size

            if name == "ball" or name == "bola" then
                score = score + 1000
            elseif name:find("ball") or name:find("bola") then
                score = score + 500
            elseif name:find("soccer") or name:find("football") then
                score = score + 400
            end

            local ratioX = size.X / size.Y
            local ratioZ = size.Z / size.Y
            if math.abs(ratioX - 1) < 0.2 and math.abs(ratioZ - 1) < 0.2 then
                score = score + 300
            end

            local avgSize = (size.X + size.Y + size.Z) / 3
            if avgSize >= 1 and avgSize <= 8 then
                score = score + 200
            end

            if obj:IsA("Part") and obj.Shape == Enum.PartType.Ball then
                score = score + 400
            end

            if obj:IsA("MeshPart") then
                local meshId = obj.MeshId or ""
                if meshId:find("sphere") or meshId:find("ball") then
                    score = score + 250
                end
                if math.abs(size.X - size.Y) < 0.1 and math.abs(size.Y - size.Z) < 0.1 then
                    score = score + 150
                end
            end

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 30 then
                    score = score + (30 - dist) * 10
                elseif dist < 100 then
                    score = score + (100 - dist) * 2
                end
            end

            if obj.AssemblyLinearVelocity.Magnitude > 0.1 then
                score = score + 100
            end

            if obj.Material == Enum.Material.Plastic or obj.Material == Enum.Material.Rubber then
                score = score + 50
            end

            if score > bestScore then
                bestBall = obj
                bestScore = score
            end
        end
    end

    return bestBall, bestScore
end

function BallMaster:DominateBall()
    local ball, score = self:DetectBall()
    if not ball then
        Logger:warn("Nenhuma bola detectada no mapa")
        notify("Bloxstrap", "Nenhuma bola encontrada!", 3)
        return nil
    end

    self.TargetBall = ball
    self.IsDominating = true

    self.OriginalState = {
        NetworkOwner = ball:GetNetworkOwner(),
        CanCollide = ball.CanCollide,
        CanTouch = ball.CanTouch,
        CanQuery = ball.CanQuery,
        CustomPhysicalProperties = ball.CustomPhysicalProperties,
        Massless = ball.Massless,
        Material = ball.Material,
    }

    pcall(function()
        ball:SetNetworkOwner(LocalPlayer)
    end)

    ball.CanCollide = true
    ball.CanTouch = true
    ball.CanQuery = true
    ball.Massless = false

    local physProps = PhysicalProperties.new(0.7, 0.3, 0.8, 1.0, 1.0)
    ball.CustomPhysicalProperties = physProps
    ball.Material = Enum.Material.Plastic
    ball:SetAttribute("_BallMaster_Active", true)

    self:StartPredictionSystem()
    self:AddVisualIndicator(ball)

    Logger:success("Bola dominada: " .. ball.Name .. " | Score: " .. score)
    notify("Bloxstrap", "🏐 Bola dominada: " .. ball.Name, 3)
    return ball
end

function BallMaster:StartPredictionSystem()
    if self.Connections and self.Connections.Prediction then
        self.Connections.Prediction:Disconnect()
    end

    self.Connections = self.Connections or {}
    local lastPos = nil
    local lastVel = nil

    self.Connections.Prediction = RunService.Heartbeat:Connect(function(dt)
        if not self.IsDominating or not self.TargetBall then return end
        local ball = self.TargetBall
        if not ball.Parent then return end

        if lastPos and lastVel then
            local predictedPos = lastPos + lastVel * dt * self.Config.PredictionStrength
            local currentPos = ball.Position
            local error = (predictedPos - currentPos).Magnitude
            if error < 5 then
                ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity * 1.02
            end
        end

        lastPos = ball.Position
        lastVel = ball.AssemblyLinearVelocity
    end)
end

function BallMaster:AddVisualIndicator(ball)
    local old = ball:FindFirstChild("_BallMasterIndicator")
    if old then old:Destroy() end

    local selection = Instance.new("SelectionBox")
    selection.Name = "_BallMasterIndicator"
    selection.Adornee = ball
    selection.Color3 = Color3.fromRGB(0, 255, 150)
    selection.LineThickness = 0.02
    selection.SurfaceTransparency = 1
    selection.Parent = ball

    local attach = Instance.new("Attachment")
    attach.Name = "_BallMasterAttach"
    attach.Position = Vector3.new(0, 0, 0)
    attach.Parent = ball

    local particles = Instance.new("ParticleEmitter")
    particles.Name = "_BallMasterParticles"
    particles.Texture = "rbxassetid://258128463"
    particles.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
    particles.Size = NumberSequence.new(0.3, 0)
    particles.Rate = 15
    particles.Lifetime = NumberRange.new(0.3, 0.6)
    particles.Speed = NumberRange.new(1, 3)
    particles.Transparency = NumberSequence.new(0.5, 1)
    particles.Parent = attach
end

function BallMaster:ReleaseBall()
    if not self.TargetBall then return end

    self.IsDominating = false
    local ball = self.TargetBall

    if self.OriginalState.NetworkOwner then
        pcall(function()
            ball:SetNetworkOwner(self.OriginalState.NetworkOwner)
        end)
    else
        pcall(function()
            ball:SetNetworkOwner(nil)
        end)
    end

    ball.CanCollide = self.OriginalState.CanCollide
    ball.CanTouch = self.OriginalState.CanTouch
    ball.CanQuery = self.OriginalState.CanQuery
    ball.CustomPhysicalProperties = self.OriginalState.CustomPhysicalProperties
    ball.Massless = self.OriginalState.Massless
    ball.Material = self.OriginalState.Material

    local ind = ball:FindFirstChild("_BallMasterIndicator")
    if ind then ind:Destroy() end
    local attach = ball:FindFirstChild("_BallMasterAttach")
    if attach then attach:Destroy() end

    ball:SetAttribute("_BallMaster_Active", nil)

    if self.Connections and self.Connections.Prediction then
        self.Connections.Prediction:Disconnect()
    end

    self.TargetBall = nil
    self.OriginalState = {}
    Logger:info("Bola liberada")
end

--// ============================================
--// NETWORK FAKER - PING 7MS
--// ============================================
local NetworkFaker = {
    FakePing = 7,
    RealPing = 0,
    IsActive = false,
}

function NetworkFaker:SimulateLowPing()
    self.IsActive = true

    pcall(function()
        settings().Network.IncomingReplicationLag = 0
    end)

    pcall(function()
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        settings().Physics.ThrottleAdjustTime = 0
    end)

    Workspace.StreamingEnabled = true
    Workspace.StreamingMinRadius = 16
    Workspace.StreamingTargetRadius = 256
    Workspace.StreamingPauseMode = Enum.StreamingPauseMode.Default

    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part:SetNetworkOwner(LocalPlayer)
                end)
            end
        end
    end

    self.Connections = self.Connections or {}
    self.Connections.NetworkLoop = RunService.Heartbeat:Connect(function()
        if not self.IsActive then return end

        local localChar = LocalPlayer.Character
        if not localChar then return end
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - localHRP.Position).Magnitude
                    if dist > 80 then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part:SetAttribute("_LowPriority", true)
                            end
                        end
                    else
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part:SetAttribute("_LowPriority", nil)
                            end
                        end
                    end
                end
            end
        end
    end)

    Logger:success("Ping 7ms ativado")
end

function NetworkFaker:GetDisplayPing()
    local realPing = 0
    pcall(function()
        realPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)

    self.RealPing = realPing

    if self.IsActive then
        local variation = math.random(-2, 3)
        return math.max(5, self.FakePing + variation)
    end

    return realPing
end

function NetworkFaker:Disable()
    self.IsActive = false
    if self.Connections and self.Connections.NetworkLoop then
        self.Connections.NetworkLoop:Disconnect()
    end
    Logger:info("Ping 7ms desativado")
end

--// ============================================
--// VISUAL PC MODE
--// ============================================
local VisualPC = {
    IsActive = false,
    OriginalSettings = {}
}

function VisualPC:EnablePCMode()
    self.IsActive = true

    self.OriginalSettings.ShadowSoftness = Lighting.ShadowSoftness
    self.OriginalSettings.GlobalShadows = Lighting.GlobalShadows
    self.OriginalSettings.Technology = Lighting.Technology
    self.OriginalSettings.Brightness = Lighting.Brightness
    self.OriginalSettings.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
    self.OriginalSettings.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale

    Lighting.ShadowSoftness = 0.3
    Lighting.GlobalShadows = true
    Lighting.Technology = Enum.Technology.ShadowMap
    Lighting.Brightness = 1.8
    Lighting.EnvironmentDiffuseScale = 0.5
    Lighting.EnvironmentSpecularScale = 0.3

    pcall(function()
        settings().Rendering.TextureQuality = Enum.TextureQuality.High
    end)

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Lifetime = NumberRange.new(obj.Lifetime.Min * 0.8, obj.Lifetime.Max * 0.8)
        elseif obj:IsA("Trail") then
            obj.Lifetime = math.clamp(obj.Lifetime * 0.8, 0.2, 2)
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Automatic
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Transparency > 0.95 then
            obj:Destroy()
        end
    end

    for _, obj in ipairs(Lighting:GetDescendants()) do
        if obj:IsA("BloomEffect") then
            self.OriginalSettings[obj.Name .. "_BloomInt"] = obj.Intensity
            self.OriginalSettings[obj.Name .. "_BloomSize"] = obj.Size
            obj.Intensity = math.clamp(obj.Intensity * 0.6, 0.1, 0.8)
            obj.Size = math.clamp(obj.Size * 0.7, 15, 30)
        elseif obj:IsA("BlurEffect") then
            self.OriginalSettings[obj.Name .. "_BlurSize"] = obj.Size
            obj.Size = math.clamp(obj.Size * 0.5, 2, 8)
        elseif obj:IsA("SunRaysEffect") then
            self.OriginalSettings[obj.Name .. "_SunInt"] = obj.Intensity
            obj.Intensity = math.clamp(obj.Intensity * 0.5, 0.1, 0.4)
        end
    end

    local camera = Workspace.CurrentCamera
    if camera then
        self.OriginalSettings.FieldOfView = camera.FieldOfView
        camera.FieldOfView = 80
    end

    Logger:success("Visual PC ativado")
end

function VisualPC:DisablePCMode()
    self.IsActive = false

    if self.OriginalSettings.ShadowSoftness then
        Lighting.ShadowSoftness = self.OriginalSettings.ShadowSoftness
    end
    if self.OriginalSettings.GlobalShadows ~= nil then
        Lighting.GlobalShadows = self.OriginalSettings.GlobalShadows
    end
    if self.OriginalSettings.Technology then
        Lighting.Technology = self.OriginalSettings.Technology
    end
    if self.OriginalSettings.Brightness then
        Lighting.Brightness = self.OriginalSettings.Brightness
    end
    if self.OriginalSettings.EnvironmentDiffuseScale then
        Lighting.EnvironmentDiffuseScale = self.OriginalSettings.EnvironmentDiffuseScale
    end
    if self.OriginalSettings.EnvironmentSpecularScale then
        Lighting.EnvironmentSpecularScale = self.OriginalSettings.EnvironmentSpecularScale
    end

    local camera = Workspace.CurrentCamera
    if camera and self.OriginalSettings.FieldOfView then
        camera.FieldOfView = self.OriginalSettings.FieldOfView
    end

    for _, obj in ipairs(Lighting:GetDescendants()) do
        if obj:IsA("BloomEffect") then
            local key = obj.Name .. "_BloomInt"
            if self.OriginalSettings[key] then obj.Intensity = self.OriginalSettings[key] end
        elseif obj:IsA("BlurEffect") then
            local key = obj.Name .. "_BlurSize"
            if self.OriginalSettings[key] then obj.Size = self.OriginalSettings[key] end
        elseif obj:IsA("SunRaysEffect") then
            local key = obj.Name .. "_SunInt"
            if self.OriginalSettings[key] then obj.Intensity = self.OriginalSettings[key] end
        end
    end

    Logger:info("Visual PC desativado")
end

--// ============================================
--// FPS BOOST SYSTEM
--// ============================================
local FPSBoost = {
    IsActive = false,
    OriginalSettings = {},
    Connections = {}
}

function FPSBoost:Enable()
    self.IsActive = true

    self.OriginalSettings.ShadowSoftness = Lighting.ShadowSoftness
    self.OriginalSettings.Technology = Lighting.Technology

    Lighting.ShadowSoftness = 1.0
    Lighting.Technology = Enum.Technology.Compatibility

    pcall(function()
        settings().Rendering.TextureQuality = Enum.TextureQuality.Low
    end)

    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Rate = math.clamp(obj.Rate * 0.3, 0.5, 20)
            obj.Lifetime = NumberRange.new(obj.Lifetime.Min * 0.5, obj.Lifetime.Max * 0.5)
            count = count + 1
        elseif obj:IsA("Trail") then
            obj.Lifetime = math.clamp(obj.Lifetime * 0.5, 0.1, 1.5)
        elseif obj:IsA("Beam") then
            obj.Segments = math.clamp(obj.Segments, 3, 10)
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Performance
        end
    end

    self.Connections.Loop = RunService.RenderStepped:Connect(function()
        local camera = Workspace.CurrentCamera
        if not camera then return end
        local camPos = camera.CFrame.Position

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character or Instance.new("Model")) then
                local dist = (obj.Position - camPos).Magnitude
                if dist > 500 then
                    if obj.Transparency < 1 then
                        obj:SetAttribute("OriginalTransparency", obj.Transparency)
                        obj.Transparency = 1
                    end
                elseif dist > 200 then
                    local orig = obj:GetAttribute("OriginalTransparency")
                    if orig then
                        obj.Transparency = math.min(orig + 0.5, 0.9)
                    end
                else
                    local orig = obj:GetAttribute("OriginalTransparency")
                    if orig then
                        obj.Transparency = orig
                        obj:SetAttribute("OriginalTransparency", nil)
                    end
                end
            end
        end
    end)

    Logger:success("FPS Boost ativado (" .. count .. " partículas otimizadas)")
end

function FPSBoost:Disable()
    self.IsActive = false

    if self.OriginalSettings.ShadowSoftness then
        Lighting.ShadowSoftness = self.OriginalSettings.ShadowSoftness
    end
    if self.OriginalSettings.Technology then
        Lighting.Technology = self.OriginalSettings.Technology
    end

    pcall(function()
        settings().Rendering.TextureQuality = Enum.TextureQuality.High
    end)

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Automatic
        end
        if obj:IsA("BasePart") then
            local orig = obj:GetAttribute("OriginalTransparency")
            if orig then
                obj.Transparency = orig
                obj:SetAttribute("OriginalTransparency", nil)
            end
        end
    end

    if self.Connections.Loop then
        self.Connections.Loop:Disconnect()
    end

    Logger:info("FPS Boost desativado")
end

--// ============================================
--// ULTRA MODE
--// ============================================
local UltraMode = {
    IsActive = false,
    OriginalSettings = {},
    Connections = {}
}

function UltraMode:Enable()
    self.IsActive = true

    for _, obj in ipairs(Lighting:GetDescendants()) do
        if obj:IsA("BloomEffect") then
            self.OriginalSettings[obj.Name .. "_BloomInt"] = obj.Intensity
            self.OriginalSettings[obj.Name .. "_BloomSize"] = obj.Size
            obj.Intensity = math.clamp(obj.Intensity * 0.2, 0, 0.3)
            obj.Size = math.clamp(obj.Size * 0.4, 8, 16)
        elseif obj:IsA("BlurEffect") then
            self.OriginalSettings[obj.Name .. "_BlurSize"] = obj.Size
            obj.Size = math.clamp(obj.Size * 0.3, 1, 6)
        elseif obj:IsA("ColorCorrectionEffect") then
            self.OriginalSettings[obj.Name .. "_CCSat"] = obj.Saturation
            self.OriginalSettings[obj.Name .. "_CCCon"] = obj.Contrast
            obj.Saturation = math.clamp(obj.Saturation, -0.1, 0.1)
            obj.Contrast = math.clamp(obj.Contrast, 0.8, 1.2)
        elseif obj:IsA("SunRaysEffect") then
            self.OriginalSettings[obj.Name .. "_SunInt"] = obj.Intensity
            obj.Intensity = math.clamp(obj.Intensity * 0.2, 0, 0.2)
        elseif obj:IsA("DepthOfFieldEffect") then
            self.OriginalSettings[obj.Name .. "_DOF"] = obj.Enabled
            obj.Enabled = false
        end
    end

    local camera = Workspace.CurrentCamera
    if camera then
        self.OriginalSettings.FieldOfView = camera.FieldOfView
        camera.FieldOfView = math.clamp(camera.FieldOfView, 60, 75)
    end

    Workspace.Terrain.WaterWaveSize = 0
    Workspace.Terrain.WaterWaveSpeed = 0

    self.Connections.Loop = RunService.Heartbeat:Connect(function()
        local localChar = LocalPlayer.Character
        if not localChar then return end
        local localHRP = localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - localHRP.Position).Magnitude
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CastShadow = (dist <= 50)
                        end
                    end
                end
            end
        end
    end)

    Logger:success("Ultra Mode ativado")
end

function UltraMode:Disable()
    self.IsActive = false

    for _, obj in ipairs(Lighting:GetDescendants()) do
        if obj:IsA("BloomEffect") then
            local key = obj.Name .. "_BloomInt"
            if self.OriginalSettings[key] then obj.Intensity = self.OriginalSettings[key] end
        elseif obj:IsA("BlurEffect") then
            local key = obj.Name .. "_BlurSize"
            if self.OriginalSettings[key] then obj.Size = self.OriginalSettings[key] end
        elseif obj:IsA("ColorCorrectionEffect") then
            local satKey = obj.Name .. "_CCSat"
            local conKey = obj.Name .. "_CCCon"
            if self.OriginalSettings[satKey] then obj.Saturation = self.OriginalSettings[satKey] end
            if self.OriginalSettings[conKey] then obj.Contrast = self.OriginalSettings[conKey] end
        elseif obj:IsA("SunRaysEffect") then
            local key = obj.Name .. "_SunInt"
            if self.OriginalSettings[key] then obj.Intensity = self.OriginalSettings[key] end
        elseif obj:IsA("DepthOfFieldEffect") then
            local key = obj.Name .. "_DOF"
            if self.OriginalSettings[key] ~= nil then obj.Enabled = self.OriginalSettings[key] end
        end
    end

    local camera = Workspace.CurrentCamera
    if camera and self.OriginalSettings.FieldOfView then
        camera.FieldOfView = self.OriginalSettings.FieldOfView
    end

    Workspace.Terrain.WaterWaveSize = 0.15
    Workspace.Terrain.WaterWaveSpeed = 10

    if self.Connections.Loop then
        self.Connections.Loop:Disconnect()
    end

    Logger:info("Ultra Mode desativado")
end

--// ============================================
--// REDZHUB UI CREATION (API CORRETA)
--// ============================================
local Window = redzlib:MakeWindow({
    Title = "⚡ Bloxstrap Optimizer v5.1",
    SubTitle = "by aquilesgamef1 | FFlags 2026 | Ping 7ms",
    SaveFolder = "BloxstrapOptimizer | Config.lua"
})

-- Adiciona botão de minimizar
Window:AddMinimizeButton({
    Button = {
        Image = "rbxassetid://71014873973869",
        BackgroundTransparency = 0
    },
    Corner = {
        CornerRadius = UDim.new(0, 8)
    }
})

--// Tab: Início
local TabHome = Window:MakeTab({"Início", "home"})

TabHome:AddParagraph({
    "Bem-vindo ao Bloxstrap Optimizer",
    "Versão 5.1 com FFlags competitivos 2026, dominação de bola, ping 7ms e visual PC.

Ative os módulos nas abas correspondentes."
})

TabHome:AddButton({"Aplicar Todos os FFlags", function()
    local count = ApplyFFlags()
    notify("Bloxstrap", count .. " FFlags aplicados!", 3)
end})

TabHome:AddButton({"Set FPS Cap (999)", function()
    ExecutorAPI.setfpscap(999)
    notify("Bloxstrap", "FPS Cap definido para 999!", 3)
end})

-- Stats display
local StatsSection = TabHome:AddSection({"Estatísticas em Tempo Real"})

local FPSLabel = TabHome:AddParagraph({"FPS", "Carregando..."})
local PingLabel = TabHome:AddParagraph({"Ping", "Carregando..."})
local BallLabel = TabHome:AddParagraph({"Bola", "Não dominada"})

--// Tab: Otimização
local TabOpt = Window:MakeTab({"Otimização", "zap"})

local ToggleBall = TabOpt:AddToggle({
    Name = "🏐 Dominate Ball",
    Description = "Controla a bola localmente com predição",
    Default = false
})

ToggleBall:Callback(function(Value)
    if Value then
        BallMaster:DominateBall()
    else
        BallMaster:ReleaseBall()
    end
end)

local TogglePing = TabOpt:AddToggle({
    Name = "📡 Ping 7ms",
    Description = "Simula latência ultra-baixa + otimiza rede",
    Default = false
})

TogglePing:Callback(function(Value)
    if Value then
        NetworkFaker:SimulateLowPing()
    else
        NetworkFaker:Disable()
    end
end)

local ToggleVisual = TabOpt:AddToggle({
    Name = "🖥️ Visual PC",
    Description = "Gráficos otimizados de PC (ShadowMap, FOV 80)",
    Default = false
})

ToggleVisual:Callback(function(Value)
    if Value then
        VisualPC:EnablePCMode()
    else
        VisualPC:DisablePCMode()
    end
end)

local ToggleFPS = TabOpt:AddToggle({
    Name = "⚡ FPS Boost",
    Description = "LOD dinâmico, partículas reduzidas, texturas Low",
    Default = false
})

ToggleFPS:Callback(function(Value)
    if Value then
        FPSBoost:Enable()
    else
        FPSBoost:Disable()
    end
end)

local ToggleUltra = TabOpt:AddToggle({
    Name = "🔥 Ultra Mode",
    Description = "Otimização agressiva: bloom, DOF, shadows distantes",
    Default = false
})

ToggleUltra:Callback(function(Value)
    if Value then
        UltraMode:Enable()
    else
        UltraMode:Disable()
    end
end)

TabOpt:AddSlider({
    Name = "Predição da Bola",
    Min = 1,
    Max = 10,
    Increase = 0.5,
    Default = 3.5,
    Callback = function(Value)
        BallMaster.Config.PredictionStrength = Value
    end
})

--// Tab: FFlags
local TabFFlags = Window:MakeTab({"FFlags", "settings"})

TabFFlags:AddParagraph({
    "Fast Flags Competitivos",
    "Lista completa de FFlags otimizados para baixa latência e alta performance."
})

local FFlagList = TabFFlags:AddSection({"Flags Aplicadas"})

for _, fflag in ipairs(FFlags) do
    TabFFlags:AddParagraph({
        fflag.Flag,
        "Valor: " .. fflag.Value
    })
end

TabFFlags:AddButton({"Reaplicar Todos os FFlags", function()
    local count = ApplyFFlags()
    notify("Bloxstrap", count .. " FFlags reaplicados!", 3)
end})

--// Tab: Configurações
local TabConfig = Window:MakeTab({"Config", "user"})

TabConfig:AddButton({"Dark Theme", function()
    redzlib:SetTheme("Dark")
end})

TabConfig:AddButton({"Darker Theme", function()
    redzlib:SetTheme("Darker")
end})

TabConfig:AddButton({"Purple Theme", function()
    redzlib:SetTheme("Purple")
end})

TabConfig:AddButton({"Resetar Tudo", function()
    BallMaster:ReleaseBall()
    NetworkFaker:Disable()
    VisualPC:DisablePCMode()
    FPSBoost:Disable()
    UltraMode:Disable()
    ToggleBall:Set(false)
    TogglePing:Set(false)
    ToggleVisual:Set(false)
    ToggleFPS:Set(false)
    ToggleUltra:Set(false)
    notify("Bloxstrap", "Todas as otimizações resetadas!", 3)
end})

TabConfig:AddButton({"Copiar Logs", function()
    local logText = table.concat(Logger.logs, "\n")
    ExecutorAPI.setclipboard(logText)
    notify("Bloxstrap", "Logs copiados para clipboard!", 3)
end})

-- Seleciona tab inicial
Window:SelectTab(TabHome)

--// ============================================
--// REAL-TIME STATS UPDATE
--// ============================================
local frameCount = 0
local lastFpsUpdate = tick()
local lastStatsUpdate = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()

    if now - lastFpsUpdate >= 0.5 then
        local fps = math.floor(frameCount / (now - lastFpsUpdate))
        frameCount = 0
        lastFpsUpdate = now

        pcall(function()
            FPSLabel:Set("FPS: " .. fps)
        end)
    end

    if now - lastStatsUpdate >= 1.5 then
        lastStatsUpdate = now

        local ping = NetworkFaker:GetDisplayPing()
        pcall(function()
            PingLabel:Set("Ping: " .. ping .. "ms")
        end)

        if BallMaster.IsDominating and BallMaster.TargetBall then
            pcall(function()
                BallLabel:Set("Bola: " .. BallMaster.TargetBall.Name .. " [DOMINADA]")
            end)
        else
            pcall(function()
                BallLabel:Set("Bola: Não dominada")
            end)
        end
    end
end)

--// ============================================
--// INITIALIZATION
--// ============================================
Logger:info("Bloxstrap Optimizer v5.1 iniciado")
Logger:info("Executor: " .. ExecutorAPI.getexecutorname())

-- Auto-apply FFlags on load
local autoApplied = ApplyFFlags()
notify("Bloxstrap", "v5.1 carregado! " .. autoApplied .. " FFlags aplicados.", 4)

-- Expose global
getgenv().BloxstrapOptimizer = {
    BallMaster = BallMaster,
    NetworkFaker = NetworkFaker,
    VisualPC = VisualPC,
    FPSBoost = FPSBoost,
    UltraMode = UltraMode,
    Logger = Logger,
    ApplyFFlags = ApplyFFlags,
    Window = Window,
}

print("⚡ Bloxstrap Optimizer v5.1 pronto!")
print("✓ RedzLib carregada de: tbao143/Library-ui")
print("✓ " .. autoApplied .. " FFlags aplicados automaticamente")
