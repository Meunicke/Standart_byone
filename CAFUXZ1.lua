
-- ============================================
-- CAFUXZ1 Hub v16.4 - EXPLOIT VERSION (FIXED)
-- ============================================

-- 1. Verificação de Ambiente
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- 2. Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- 3. Variáveis do Jogador (Safe Check)
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Função para pegar o Character de forma segura
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local Character = GetCharacter()
local Humanoid = Character:WaitForChild("Humanoid", 10)
local HRP = Character:WaitForChild("HumanoidRootPart", 10)

-- 4. Limpeza Anti-Duplicação (Melhorada)
local function Cleanup()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name:find("CAFUXZ1") or obj.Name:find("TCS_BallSystem") then
            obj:Destroy()
        end
    end
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:find("CAFUXZ1") then
            obj:Destroy()
        end
    end
end

pcall(Cleanup)

-- ============================================
-- CONFIGURAÇÕES v16.4 (COM SISTEMA DE BOLA @TCS NOVIDADES)
-- ============================================
local CONFIG = {
    width = 650,
    height = 500,
    sidebarWidth = 100,
    
    -- Reach System
    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.0,
        
    -- CONTROLE DE AUTO ESCANEAMENTO
    autoScanEnabled = true,
    scanInterval = 0.5,
    maxBallsCached = 10,
    
    -- Reach Bypass System
    reachBypass = {
        enabled = true,
        baseRange = 12,
        extendedRange = 25,
        multiTouchEnabled = true,
        touchChainCount = 5,
        touchChainDelay = 0.02,
        doubleTouchDelay = 0.03,
        jitterAmount = 0.5,
        timingRandomization = true,
        maxBallsPerFrame = 3,
        scanRate = 0,
    },
    
    -- Arthur Sphere
    arthurSphere = {
        reach = 12,
        color = Color3.fromRGB(0, 255, 255),
        transparency = 0.7,
        material = Enum.Material.ForceField,
        pulseSpeed = 2
    },
    
    -- TOTE SYSTEM v3.0
    tote = {
        enabled = false,
        power = 50,
        curveAmount = 30,
        curveDirection = "Auto",
        height = 15,
        spinRate = 8,
        magnusForce = 0.15,
        autoAim = false,
        prediction = true,
        visualizer = true,
        keybind = Enum.KeyCode.T,
        debounce = 0.3,
        lastKick = 0,
        gravityCompensation = true,
        airResistance = 0.98
    },
    
    -- Anti Lag (Separado)
    antiLag = {
        texturesEnabled = false,
        resolutionEnabled = false,
        resolutionScale = 0.65,
        minResolution = 0.3,
        maxResolution = 1.0
    },
    
    -- PING OPTIMIZATION SYSTEM
    pingOptimization = {
        enabled = true,
        adaptiveTiming = true,
        smartPriority = true,
        pingBufferMultiplier = 1.5,
        highPingThreshold = 150,
        criticalPingThreshold = 250,
        dynamicFPS = true,
        compensationRange = 0.15,
        showPingMonitor = true
    },
    
    -- Ball Color System (by @TCS NOVIDADES)
    ballColor = {
        enabled = true,
        selectedColor = Color3.fromRGB(255, 0, 0),
        snowEnabled = false
    },
    
    -- Cores
    customColors = {
        primary = Color3.fromRGB(99, 102, 241),
        secondary = Color3.fromRGB(139, 92, 246),
        accent = Color3.fromRGB(14, 165, 233),
        success = Color3.fromRGB(34, 197, 94),
        danger = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11),
        info = Color3.fromRGB(59, 130, 246),
        tote = Color3.fromRGB(255, 0, 128),
        ping = Color3.fromRGB(0, 255, 200),
        bypass = Color3.fromRGB(255, 100, 50),
        ball = Color3.fromRGB(255, 100, 100),
        
        bgDark = Color3.fromRGB(8, 8, 16),
        bgCard = Color3.fromRGB(20, 20, 35),
        bgElevated = Color3.fromRGB(35, 35, 55),
        bgGlass = Color3.fromRGB(15, 15, 28),
        
        textPrimary = Color3.fromRGB(252, 252, 255),
        textSecondary = Color3.fromRGB(180, 190, 220),
        textMuted = Color3.fromRGB(140, 150, 180),
    },
    
    ballNames = { 
        "TPS", "TCS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Ball", "Soccer", "Football", "Basketball", "Baseball", 
        "BallTemplate", "GameBall", "Hitbox", "TouchPart", "GoalBall",
        "Physics", "Interaction", "Trigger", "Touch", "Hit", "Box",
        "bola", "Bola", "BALL", "SOCCER", "FOOTBALL", "SoccerBall",
        "tote", "Tote", "CurveBall", "ShotBall"
    }
}

-- ============================================
-- ESTATÍSTICAS
-- ============================================
local STATS = {
    totalTouches = 0,
    ballsTouched = 0,
    sessionStart = tick(),
    skillsActivated = 0,
    antiLagItems = 0,
    morphsDone = 0,
    toteKicks = 0,
    toteGoals = 0,
    avgPing = 0,
    currentPing = 0,
    fps = 60,
    ballsInCache = 0,
    lastScanTime = 0
}

local LOGS = {}
local MAX_LOGS = 50

local function addLog(message, type)
    type = type or "info"
    table.insert(LOGS, 1, {
        message = tostring(message),
        type = tostring(type),
        time = os.date("%H:%M:%S"),
        timestamp = tick()
    })
    if #LOGS > MAX_LOGS then table.remove(LOGS) end
end

-- ============================================
-- PING SYSTEM AVANÇADO
-- ============================================
local PingSystem = {
    History = {},
    CurrentPing = 0,
    AveragePing = 0,
    PingTrend = "stable",
    LastPingUpdate = 0,
    DesyncCompensation = 0,
    SafetyBuffer = 0,
    FPS = 60,
    FrameTime = 0,
    
    Init = function(self)
        RunService.Heartbeat:Connect(function(deltaTime)
            self.FrameTime = deltaTime
            self.FPS = math.floor(1 / deltaTime)
            STATS.fps = self.FPS
        end)
    end,
    
    Update = function(self)
        local now = tick()
        if now - self.LastPingUpdate < 0.1 then return end
        self.LastPingUpdate = now
        
        local success, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        
        if success and ping then
            self.CurrentPing = ping
            STATS.currentPing = ping
            
            table.insert(self.History, 1, ping)
            if #self.History > 10 then table.remove(self.History) end
            
            local sum = 0
            for _, p in ipairs(self.History) do
                sum = sum + p
            end
            local newAverage = sum / #self.History
            
            if newAverage > self.AveragePing * 1.2 then
                self.PingTrend = "rising"
            elseif newAverage < self.AveragePing * 0.8 then
                self.PingTrend = "falling"
            elseif math.abs(ping - self.AveragePing) > self.AveragePing * 0.5 then
                self.PingTrend = "spike"
            else
                self.PingTrend = "stable"
            end
            
            self.AveragePing = newAverage
            STATS.avgPing = math.floor(newAverage)
            
            self.DesyncCompensation = (self.AveragePing / 1000) * 0.5
            
            local multiplier = CONFIG.pingOptimization.pingBufferMultiplier
            if self.PingTrend == "spike" or self.PingTrend == "rising" then
                multiplier = multiplier * 1.3
            end
            self.SafetyBuffer = (self.AveragePing / 1000) * multiplier
            
        end
    end,
    
    GetAdaptiveDelay = function(self, baseDelay)
        if not CONFIG.pingOptimization.adaptiveTiming then return baseDelay end
        local pingFactor = math.clamp(self.AveragePing / 100, 0.5, 2.0)
        return baseDelay * pingFactor
    end,
    
    IsHighLoad = function(self)
        return self.AveragePing > CONFIG.pingOptimization.highPingThreshold or self.FPS < 30
    end,
    
    IsCritical = function(self)
        return self.AveragePing > CONFIG.pingOptimization.criticalPingThreshold or self.FPS < 20
    end,
    
    GetOptimizedJitter = function(self)
        local jitterMultiplier = 1.0
        if self.PingTrend == "spike" then
            jitterMultiplier = 0.5
        end
        
        local baseJitter = self.DesyncCompensation * jitterMultiplier
        
        return Vector3.new(
            math.random(-10, 10) * baseJitter,
            math.random(-5, 5) * baseJitter,
            math.random(-10, 10) * baseJitter
        )
    end,
    
    GetEffectiveRange = function(self, baseRange)
        if not CONFIG.pingOptimization.enabled then return baseRange end
        local compensation = math.clamp(self.AveragePing / 1000, 0, CONFIG.pingOptimization.compensationRange)
        return baseRange * (1 + compensation)
    end,
    
    GetStatusVisuals = function(self)
        if self.PingTrend == "spike" then
            return "⚠️", Color3.fromRGB(255, 50, 50)
        elseif self.PingTrend == "rising" then
            return "↑", Color3.fromRGB(255, 200, 50)
        elseif self.PingTrend == "falling" then
            return "↓", Color3.fromRGB(100, 255, 100)
        else
            return "●", Color3.fromRGB(100, 200, 255)
        end
    end
}

-- ============================================
-- REACH BYPASS SYSTEM
-- ============================================
local ReachBypass = {
    ActiveConnections = {},
    BallsCache = {},
    LastCacheUpdate = 0,
    TouchDebounce = {},
    
    Bypass = {
        PingHistory = {},
        Desync = 0,
        
        Update = function(self)
            local success, ping = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if success and ping then
                table.insert(self.PingHistory, ping)
                if #self.PingHistory > 5 then table.remove(self.PingHistory, 1) end
                
                local avg = 0
                for _, p in ipairs(self.PingHistory) do avg = avg + p end
                self.Desync = (avg / #self.PingHistory) / 1000
            end
        end,
        
        GetJitter = function(self)
            if not CONFIG.reachBypass.enabled then return Vector3.new() end
            return Vector3.new(
                math.random(-10, 10) * self.Desync * CONFIG.reachBypass.jitterAmount,
                math.random(-5, 5) * self.Desync * CONFIG.reachBypass.jitterAmount,
                math.random(-10, 10) * self.Desync * CONFIG.reachBypass.jitterAmount
            )
        end,
        
        RandomizeTiming = function(self, baseDelay)
            if not CONFIG.reachBypass.enabled or not CONFIG.reachBypass.timingRandomization then
                return baseDelay
            end
            return baseDelay + (math.random(-5, 5) / 1000)
        end
    },
    
    SingleTouch = function(self, ball, part, touchType)
        touchType = touchType or 0
        pcall(function()
            firetouchinterest(ball, part, touchType)
        end)
    end,
    
    DoubleTouch = function(self, ball, parts)
        for _, part in ipairs(parts) do
            self:SingleTouch(ball, part, 0)
        end
        
        local delay = CONFIG.reachBypass.doubleTouchDelay
        if PingSystem.AveragePing > 100 then
            delay = delay * 1.5
        end
        
        task.wait(delay)
        
        for _, part in ipairs(parts) do
            self:SingleTouch(ball, part, 1)
        end
    end,
    
    MultiTouchChain = function(self, ball, parts, priority)
        if not CONFIG.reachBypass.multiTouchEnabled then
            self:DoubleTouch(ball, parts)
            return
        end
        
        local chainCount = CONFIG.reachBypass.touchChainCount
        local baseDelay = CONFIG.reachBypass.touchChainDelay
        
        if PingSystem:IsCritical() then
            chainCount = math.max(2, chainCount - 2)
            baseDelay = baseDelay * 1.5
        elseif PingSystem:IsHighLoad() or priority == "high" then
            chainCount = math.max(3, chainCount - 1)
        end
        
        baseDelay = PingSystem:GetAdaptiveDelay(baseDelay)
        
        for i = 1, chainCount do
            local delay = baseDelay * (i-1)
            
            if PingSystem.PingTrend == "spike" then
                delay = delay + PingSystem.SafetyBuffer
            end
            
            task.delay(delay, function()
                if not ball or not ball.Parent then return end
                
                for _, part in ipairs(parts) do
                    self:SingleTouch(ball, part, 0)
                    
                    local releaseDelay = 0.005
                    if PingSystem.AveragePing > 100 then
                        releaseDelay = 0.008
                    end
                    
                    task.delay(releaseDelay, function()
                        self:SingleTouch(ball, part, 1)
                    end)
                end
            end)
        end
    end,
    
    GetBalls = function(self)
        local now = tick()
        
        if not CONFIG.autoScanEnabled then
            return self.BallsCache
        end
        
        local scanInterval = CONFIG.scanInterval
        if PingSystem:IsHighLoad() then
            scanInterval = scanInterval * 2
        end
        
        if now - self.LastCacheUpdate > scanInterval then
            for i = #self.BallsCache, 1, -1 do
                self.BallsCache[i] = nil
            end
            
            local searchLimit = math.huge
            if PingSystem:IsCritical() then
                searchLimit = 100
            end
            
            local count = 0
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if count >= searchLimit then break end
                    
                    if obj:IsA("BasePart") and not obj.Anchored then
                        local name = obj.Name:lower()
                        if name:find("ball") or name:find("bola") or name:find("soccer") or 
                           name:find("tps") or name:find("tcs") or name:find("football") then
                            if obj.Size.Magnitude < 50 then
                                table.insert(self.BallsCache, obj)
                                count = count + 1
                                
                                if #self.BallsCache >= CONFIG.maxBallsCached then
                                    break
                                end
                            end
                        end
                    end
                    count = count + 1
                end
            end)
            
            self.LastCacheUpdate = now
            STATS.ballsInCache = #self.BallsCache
            STATS.lastScanTime = now
        end
        
        return self.BallsCache
    end,
    
    Process = function(self)
        if not CONFIG.reachBypass.enabled then return end
        if not HRP or not HRP.Parent then return end
        
        local now = tick()
        if CONFIG.reachBypass.scanRate > 0 and now - (self.LastScan or 0) < CONFIG.reachBypass.scanRate then
            return
        end
        self.LastScan = now
        
        self.Bypass:Update()
        
        local hrpPos = HRP.Position
        local parts = {}
        for _, part in ipairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                table.insert(parts, part)
            end
        end
        
        local balls = self:GetBalls()
        local processed = 0
        
        if CONFIG.pingOptimization.smartPriority and #balls > 1 then
            table.sort(balls, function(a, b)
                if not a or not b then return false end
                local distA = (a.Position - hrpPos).Magnitude
                local distB = (b.Position - hrpPos).Magnitude
                return distA < distB
            end)
        end
        
        for _, ball in ipairs(balls) do
            if processed >= CONFIG.reachBypass.maxBallsPerFrame then break end
            
            if ball and ball.Position then
                local dist = (ball.Position - hrpPos).Magnitude
                local jitter = self.Bypass:GetJitter()
                local effectivePos = ball.Position + jitter
                
                local effectiveExtended = PingSystem:GetEffectiveRange(CONFIG.reachBypass.extendedRange)
                local effectiveBase = PingSystem:GetEffectiveRange(CONFIG.reachBypass.baseRange)
                
                local priority = "normal"
                if dist < effectiveBase * 1.5 then
                    priority = "high"
                end
                
                if dist <= effectiveExtended then
                    processed = processed + 1
                    self:MultiTouchChain(ball, parts, priority)
                end
                
                if dist <= effectiveBase and processed == 0 then
                    processed = processed + 1
                    self:MultiTouchChain(ball, parts, "high")
                end
            end
        end
    end,
    
    Init = function(self)
        table.insert(self.ActiveConnections, LocalPlayer.CharacterAdded:Connect(function(char)
            Character = char
            HRP = char:WaitForChild("HumanoidRootPart", 5)
        end))
        
        table.insert(self.ActiveConnections, RunService.Heartbeat:Connect(function()
            self:Process()
        end))
        
        print("✅ Reach Bypass v16.0 (Double Touch)")
    end,
    
    Toggle = function(self)
        CONFIG.reachBypass.enabled = not CONFIG.reachBypass.enabled
        return CONFIG.reachBypass.enabled
    end,
    
    Destroy = function(self)
        for _, conn in ipairs(self.ActiveConnections) do
            conn:Disconnect()
        end
        CONFIG.reachBypass.enabled = false
    end
}

-- ============================================
-- ANTI-LAG SYSTEM v3.0 (Separado)
-- ============================================
local AntiLagSystem = {
    TexturesActive = false,
    ResolutionActive = false,
    OriginalStates = {},
    TextureConnection = nil,
    CameraConnection = nil,
    CurrentResolution = 0.65,
    MinResolution = 0.3,
    MaxResolution = 1.0,
    
    SaveState = function(self, obj, property, value)
        if not obj or typeof(obj) ~= "Instance" then return end
        if not self.OriginalStates[obj] then self.OriginalStates[obj] = {} end
        if self.OriginalStates[obj][property] == nil then
            self.OriginalStates[obj][property] = value
        end
    end,
    
    EnableTextures = function(self)
        if self.TexturesActive then 
            notifyWarning("Texturas", "Ja esta otimizado!", 2)
            return 
        end
        
        self.TexturesActive = true
        local count = 0
        local batchSize = 100
        local descendants = game.Workspace:GetDescendants()
        
        local function processBatch(startIdx)
            local endIdx = math.min(startIdx + batchSize - 1, #descendants)
            
            for i = startIdx, endIdx do
                local obj = descendants[i]
                if not obj then continue end
                
                pcall(function()
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        self:SaveState(obj, "Parent", obj.Parent)
                        obj:Destroy()
                        count = count + 1
                    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                        self:SaveState(obj, "Material", obj.Material)
                        self:SaveState(obj, "Reflectance", obj.Reflectance)
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Reflectance = 0
                        
                        if obj:IsA("MeshPart") and obj.TextureID ~= "" then
                            self:SaveState(obj, "TextureID", obj.TextureID)
                            obj.TextureID = ""
                        end
                        count = count + 1
                    end
                    
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or 
                       obj:IsA("Fire") or obj:IsA("Sparkles") then
                        self:SaveState(obj, "Enabled", obj.Enabled)
                        obj.Enabled = false
                        count = count + 1
                    end
                end)
            end
            
            if endIdx < #descendants then
                task.wait()
                processBatch(endIdx + 1)
            else
                notifySuccess("Texturas", count .. " objetos otimizados!", 3)
                addLog("Texturas otimizadas: " .. count, "success")
                STATS.antiLagItems = count
            end
        end
        
        processBatch(1)
        
        self.TextureConnection = game.DescendantAdded:Connect(function(obj)
            if not self.TexturesActive then return end
            task.wait(0.05)
            
            pcall(function()
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    if obj:IsA("MeshPart") then obj.TextureID = "" end
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end)
        end)
        
        CONFIG.antiLag.texturesEnabled = true
    end,
    
    DisableTextures = function(self)
        if not self.TexturesActive then return end
        self.TexturesActive = false
        CONFIG.antiLag.texturesEnabled = false
        
        if self.TextureConnection then
            pcall(function() self.TextureConnection:Disconnect() end)
            self.TextureConnection = nil
        end
        
        task.spawn(function()
            local states = {}
            for obj, props in pairs(self.OriginalStates) do
                if obj and typeof(obj) == "Instance" and obj.Parent then
                    table.insert(states, {obj = obj, props = props})
                end
            end
            
            local batchSize = 100
            local function restoreBatch(startIdx)
                local endIdx = math.min(startIdx + batchSize - 1, #states)
                
                for i = startIdx, endIdx do
                    local data = states[i]
                    local obj = data.obj
                    if obj and obj.Parent then
                        for prop, value in pairs(data.props) do
                            pcall(function()
                                if prop == "Parent" then
                                    if value then obj.Parent = value end
                                elseif prop == "Enabled" then
                                    obj.Enabled = value
                                elseif prop == "Material" then
                                    obj.Material = value
                                elseif prop == "Reflectance" then
                                    obj.Reflectance = value
                                elseif prop == "TextureID" then
                                    obj.TextureID = value
                                end
                            end)
                        end
                    end
                end
                
                if endIdx < #states then
                    task.wait()
                    restoreBatch(endIdx + 1)
                else
                    self.OriginalStates = {}
                    STATS.antiLagItems = 0
                    notifyWarning("Texturas", "Restauradas!", 3)
                    addLog("Texturas restauradas", "warning")
                end
            end
            
            if #states > 0 then restoreBatch(1) end
        end)
    end,
    
    ToggleTextures = function(self)
        if self.TexturesActive then
            self:DisableTextures()
        else
            self:EnableTextures()
        end
        return self.TexturesActive
    end,
    
    EnableResolution = function(self, scale)
        if self.ResolutionActive then 
            self:SetResolution(scale)
            return 
        end
        
        self.CurrentResolution = math.clamp(scale or 0.65, self.MinResolution, self.MaxResolution)
        self.ResolutionActive = true
        CONFIG.antiLag.resolutionEnabled = true
        
        local Camera = workspace.CurrentCamera
        
        self.CameraConnection = RunService.RenderStepped:Connect(function()
            if not self.ResolutionActive then return end
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, self.CurrentResolution, 0, 0, 0, 1)
        end)
        
        notifySuccess("Tela Esticada", "Ativada: " .. math.floor(self.CurrentResolution * 100) .. "%", 3)
        addLog("Resolucao: " .. self.CurrentResolution, "success")
    end,
    
    DisableResolution = function(self)
        if not self.ResolutionActive then return end
        self.ResolutionActive = false
        CONFIG.antiLag.resolutionEnabled = false
        
        if self.CameraConnection then
            pcall(function() self.CameraConnection:Disconnect() end)
            self.CameraConnection = nil
        end
        
        notifyWarning("Tela Esticada", "Desativada", 2)
        addLog("Resolucao normal", "warning")
    end,
    
    SetResolution = function(self, newScale)
        self.CurrentResolution = math.clamp(newScale, self.MinResolution, self.MaxResolution)
        CONFIG.antiLag.resolutionScale = self.CurrentResolution
        notifySuccess("Resolucao", "Ajustada: " .. math.floor(self.CurrentResolution * 100) .. "%", 2)
    end,
    
    ToggleResolution = function(self)
        if self.ResolutionActive then
            self:DisableResolution()
        else
            self:EnableResolution(self.CurrentResolution)
        end
        return self.ResolutionActive
    end
}

-- ============================================
-- BALL COLOR SYSTEM by @TCS NOVIDADES
-- Integrado ao CAFUXZ1 Hub v16.4
-- Sistema de deteccao e coloracao de bola
-- ============================================
local BallColorSystem = {
    Active = false,
    SnowData = {},
    SnowActive = false,
    SelectedColor = Color3.fromRGB(255, 0, 0),
    
    -- Verifica se eh personagem (para ignorar)
    IsCharacter = function(self, obj)
        local model = obj:FindFirstAncestorOfClass("Model")
        return model and model:FindFirstChildOfClass("Humanoid")
    end,
    
    -- Detecta se eh uma bola
    IsBall = function(self, part)
        if not part:IsA("BasePart") then return false end
        if self:IsCharacter(part) then return false end
        
        local s = part.Size
        if s.X < 1 or s.X > 6 then return false end
        
        local diff = math.abs(s.X - s.Y) + math.abs(s.Y - s.Z)
        if diff > 1 then return false end
        
        return true
    end,
    
    -- Aplica cor na bola
    ApplyColor = function(self, part)
        if part:IsA("MeshPart") then
            part.TextureID = ""
        end
        
        for _, m in ipairs(part:GetChildren()) do
            if m:IsA("SpecialMesh") then
                m.TextureId = ""
            end
        end
        
        for _, d in ipairs(part:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then
                d:Destroy()
            end
        end
        
        part.Reflectance = 0
        part.Color = self.SelectedColor
        part.Material = Enum.Material.SmoothPlastic
    end,
    
    -- Toggle sistema de cor
    Toggle = function(self, enabled)
        self.Active = enabled
        if enabled then
            notifySuccess("Ball Color", "Sistema ativado - by @TCS NOVIDADES", 3)
            addLog("Ball Color ativado (@TCS NOVIDADES)", "success")
        else
            notifyWarning("Ball Color", "Desativado", 2)
        end
    end,
    
    -- Seta cor
    SetColor = function(self, color)
        self.SelectedColor = color
        CONFIG.ballColor.selectedColor = color
    end,
    
    -- Toggle neve
    ToggleSnow = function(self)
        if self.SnowActive then
            -- Desativa neve
            for part, data in pairs(self.SnowData) do
                if part and part.Parent then
                    part.Material = data.Material
                    part.Color = data.Color
                end
            end
            self.SnowData = {}
            self.SnowActive = false
            CONFIG.ballColor.snowEnabled = false
            notifyWarning("Neve", "Desativada", 2)
        else
            -- Ativa neve
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not self:IsCharacter(v) then
                    self.SnowData[v] = {Material = v.Material, Color = v.Color}
                    v.Material = Enum.Material.Snow
                    v.Color = Color3.fromRGB(240, 240, 240)
                end
            end
            self.SnowActive = true
            CONFIG.ballColor.snowEnabled = true
            notifySuccess("Neve", "Ativada! Mapa coberto de neve", 3)
        end
    end,
    
    -- Loop principal
    Update = function(self)
        if not self.Active then return end
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if self:IsBall(v) then
                pcall(function()
                    self:ApplyColor(v)
                end)
            end
        end
    end,
    
    Init = function(self)
        RunService.RenderStepped:Connect(function()
            self:Update()
        end)
        print("✅ Ball Color System by @TCS NOVIDADES inicializado")
    end
}

-- ============================================
-- TOTE SYSTEM v3.0
-- ============================================
local ToteSystem = {
    Active = false,
    Visualizer = nil,
    PredictionPoints = {},
    CurrentBall = nil,
    LastKick = 0,
    
    Init = function(self)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == CONFIG.tote.keybind and CONFIG.tote.enabled then
                self:Activate()
            end
        end)
        
        print("✅ Tote System v3.0 Inicializado")
    end,
    
    GetBall = function(self)
        local hrpPos = HRP and HRP.Position
        if not hrpPos then return nil end
        
        local closestBall = nil
        local closestDist = math.huge
        
        for _, ball in ipairs(ReachBypass:GetBalls()) do
            if ball and ball.Parent then
                local dist = (ball.Position - hrpPos).Magnitude
                if dist < closestDist and dist < 20 then
                    closestDist = dist
                    closestBall = ball
                end
            end
        end
        
        return closestBall
    end,
    
    CalculateTrajectory = function(self, ball, targetPos)
        if not ball then return nil end
        
        local ballPos = ball.Position
        local ballVel = ball.AssemblyLinearVelocity or Vector3.new()
        local playerPos = HRP.Position
        local playerLook = HRP.CFrame.LookVector
        
        local baseDirection = playerLook
        
        local curveDirection = CONFIG.tote.curveDirection
        local curveAmount = CONFIG.tote.curveAmount / 100
        
        local lateralVector = Vector3.new(-baseDirection.Z, 0, baseDirection.X)
        local curveVector = Vector3.new()
        
        if curveDirection == "Left" then
            curveVector = -lateralVector * curveAmount
        elseif curveDirection == "Right" then
            curveVector = lateralVector * curveAmount
        elseif curveDirection == "Auto" then
            if targetPos then
                local toTarget = (targetPos - ballPos).Unit
                local cross = baseDirection:Cross(toTarget)
                curveVector = lateralVector * math.sign(cross.Y) * curveAmount * 0.5
            end
        end
        
        local height = CONFIG.tote.height / 10
        local power = CONFIG.tote.power
        
        local gravityComp = 0
        if CONFIG.tote.gravityCompensation then
            gravityComp = math.sqrt(2 * workspace.Gravity * height) * 0.1
        end
        
        local finalVelocity = (baseDirection + curveVector).Unit * power + Vector3.new(0, height + gravityComp, 0)
        local spinAxis = Vector3.new(0, curveAmount * CONFIG.tote.spinRate, 0)
        
        return {
            velocity = finalVelocity,
            spin = spinAxis,
            magnusForce = curveVector * CONFIG.tote.magnusForce,
            startPos = ballPos,
            predictedLanding = self:PredictLanding(ballPos, finalVelocity)
        }
    end,
    
    PredictLanding = function(self, startPos, velocity)
        local g = workspace.Gravity
        local vy = velocity.Y
        local vx = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        
        local timeToPeak = vy / g
        local totalTime = timeToPeak * 2
        local horizontalDir = Vector3.new(velocity.X, 0, velocity.Z).Unit
        local distance = vx * totalTime
        
        return startPos + horizontalDir * distance
    end,
    
    CreateVisualizer = function(self, trajectory)
        if not CONFIG.tote.visualizer then return end
        
        self:ClearVisualizer()
        
        local points = {}
        local startPos = trajectory.startPos
        local vel = trajectory.velocity
        local g = Vector3.new(0, -workspace.Gravity, 0)
        
        for i = 0, 20 do
            local t = i * 0.1
            local pos = startPos + vel * t + 0.5 * g * t * t
            
            local point = Instance.new("Part")
            point.Shape = Enum.PartType.Ball
            point.Size = Vector3.new(0.5, 0.5, 0.5)
            point.Position = pos
            point.Anchored = true
            point.CanCollide = false
            point.Material = Enum.Material.Neon
            point.Color = CONFIG.customColors.tote
            point.Transparency = 0.3
            point.Parent = Workspace
            
            table.insert(points, point)
        end
        
        for i = 1, #points - 1 do
            local beam = Instance.new("Beam")
            beam.Width0 = 0.2
            beam.Width1 = 0.2
            beam.Color = ColorSequence.new(CONFIG.customColors.tote)
            beam.Transparency = NumberSequence.new(0.5)
            beam.Attachment0 = Instance.new("Attachment", points[i])
            beam.Attachment1 = Instance.new("Attachment", points[i + 1])
            beam.Parent = points[i]
        end
        
        self.Visualizer = points
        
        task.delay(2, function()
            self:ClearVisualizer()
        end)
    end,
    
    ClearVisualizer = function(self)
        if self.Visualizer then
            for _, point in ipairs(self.Visualizer) do
                if point then
                    pcall(function() point:Destroy() end)
                end
            end
            self.Visualizer = nil
        end
    end,
    
    Activate = function(self)
        local now = tick()
        if now - self.LastKick < CONFIG.tote.debounce then
            notifyWarning("Tote", "Aguarde o cooldown!", 1)
            return
        end
        
        if not CONFIG.tote.enabled then
            notifyWarning("Tote", "Sistema desativado!", 2)
            return
        end
        
        local ball = self:GetBall()
        if not ball then
            notifyError("Tote", "Nenhuma bola proxima!", 2)
            return
        end
        
        if ball.Anchored then
            notifyError("Tote", "Bola esta travada!", 2)
            return
        end
        
        self.LastKick = now
        STATS.toteKicks = STATS.toteKicks + 1
        
        local trajectory = self:CalculateTrajectory(ball, nil)
        
        pcall(function()
            ball:SetNetworkOwner(nil)
            ball.AssemblyLinearVelocity = trajectory.velocity
            
            if CONFIG.tote.spinRate > 0 then
                local existingBAV = ball:FindFirstChildOfClass("BodyAngularVelocity")
                if existingBAV then
                    existingBAV:Destroy()
                end
                
                local bav = Instance.new("BodyAngularVelocity")
                bav.AngularVelocity = trajectory.spin
                bav.MaxTorque = Vector3.new(0, 1e5, 0)
                bav.P = 1e4
                bav.Parent = ball
                
                Debris:AddItem(bav, 0.5)
            end
            
            if CONFIG.tote.magnusForce > 0 and trajectory.magnusForce.Magnitude > 0.01 then
                local bf = Instance.new("BodyForce")
                bf.Force = trajectory.magnusForce * ball.AssemblyMass * workspace.Gravity
                bf.Parent = ball
                
                Debris:AddItem(bf, 0.3)
            end
        end)
        
        self:CreateVisualizer(trajectory)
        
        notifyTote("Tote Ativado!", "Power: " .. CONFIG.tote.power .. " | Curve: " .. CONFIG.tote.curveDirection, 2)
        addLog("Tote kick: " .. CONFIG.tote.power .. " power", "tote")
    end,
    
    Toggle = function(self)
        CONFIG.tote.enabled = not CONFIG.tote.enabled
        if CONFIG.tote.enabled then
            notifyTote("Tote System", "Ativado! Pressione [T] para chutar", 3)
        else
            notifyWarning("Tote System", "Desativado!", 2)
            self:ClearVisualizer()
        end
        return CONFIG.tote.enabled
    end
}

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================
local balls = {}
local ballConnections = {}
local reachSphere = nil
local arthurSphere = nil
local touchDebounce = {}
local lastBallUpdate = 0
local lastTouch = 0
local isMinimized = false
local isClosed = false
local mainGui = nil
local mainFrame = nil
local iconGui = nil
local introGui = nil
local currentTab = "reach"
local autoSkills = true
local lastSkillActivation = 0
local skillCooldown = 0.5
local activatedSkills = {}
local loopRunning = false
local heartbeatConnection = nil
local lastSkillCheck = 0
local skillCheckInterval = 0.1
local lastStatsUpdate = 0
local statsUpdateInterval = 1

local toteActive = false
local toteVisualizer = nil
local totePredictionPoints = {}
local currentBall = nil

local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch", "Sprint", "Jump",
    "Chute", "Passe", "Drible", "Controle", "Defender", "Save",
    "Tote", "Curva", "Spin", "Finesse"
}

-- ============================================
-- SISTEMA DE NOTIFICAÇÕES
-- ============================================
local NOTIF_CONFIG = {
    duration = 3,
    maxNotifications = 5,
    position = "right",
    offset = { x = 20, y = 100 },
    animationSpeed = 0.5,
    soundEnabled = false
}

local activeNotifications = {}
local notifCounter = 0

function advancedNotify(title, text, notifType, duration)
    duration = duration or NOTIF_CONFIG.duration
    notifType = notifType or "info"
    
    local styles = {
        success = {
            color = CONFIG.customColors.success,
            icon = "✅",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 197, 94)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 120, 60))
            })
        },
        warning = {
            color = CONFIG.customColors.warning,
            icon = "⚠️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 158, 11)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 100, 10))
            })
        },
        error = {
            color = CONFIG.customColors.danger,
            icon = "❌",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 68, 68)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 30, 30))
            })
        },
        info = {
            color = CONFIG.customColors.info,
            icon = "ℹ️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 130, 246)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 80, 180))
            })
        },
        tote = {
            color = CONFIG.customColors.tote,
            icon = "🎯",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 90))
            })
        },
        morph = {
            color = CONFIG.customColors.secondary,
            icon = "✨",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 92, 246)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 60, 180))
            })
        },
        sky = {
            color = CONFIG.customColors.accent,
            icon = "☁️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 165, 233)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 120, 180))
            })
        },
        block = {
            color = Color3.fromRGB(255, 140, 0),
            icon = "🛡️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 0))
            })
        },
        ping = {
            color = CONFIG.customColors.ping,
            icon = "📶",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 140))
            })
        },
        bypass = {
            color = CONFIG.customColors.bypass,
            icon = "⚔️",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 80, 40))
            })
        },
        ball = {
            color = CONFIG.customColors.ball,
            icon = "⚽",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 80, 80))
            })
        }
    }
    
    local style = styles[notifType] or styles.info
    
    notifCounter = notifCounter + 1
    local notifId = "CAFUXZ1_Notif_" .. notifCounter .. "_" .. tick()
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = notifId
    notifGui.ResetOnSpawn = false
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 90)
    frame.Position = UDim2.new(1, 60, 0.85, 0)
    frame.BackgroundColor3 = CONFIG.customColors.bgCard
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = notifGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = style.color
    stroke.Thickness = 2.5
    stroke.Transparency = 0.4
    stroke.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = style.gradient
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    gradient.Parent = frame
    
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, 55, 0, 55)
    iconContainer.Position = UDim2.new(0, 12, 0, 17)
    iconContainer.BackgroundColor3 = style.color
    iconContainer.BackgroundTransparency = 0.2
    iconContainer.BorderSizePixel = 0
    iconContainer.Parent = frame
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 12)
    iconCorner.Parent = iconContainer
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = style.icon
    icon.TextSize = 32
    icon.Font = Enum.Font.GothamBold
    icon.Parent = iconContainer
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 28)
    titleLabel.Position = UDim2.new(0, 75, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = style.color
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -80, 0, 45)
    textLabel.Position = UDim2.new(0, 75, 0, 38)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = CONFIG.customColors.textSecondary
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = frame
    
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Size = UDim2.new(1, 0, 0, 4)
    progressBarBg.Position = UDim2.new(0, 0, 1, -4)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    progressBarBg.BorderSizePixel = 0
    progressBarBg.Parent = frame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = style.color
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBg
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBarBg
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.5, 0, 2, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.5, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891979"
    glow.ImageColor3 = style.color
    glow.ImageTransparency = 0.9
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 118, 118)
    glow.Parent = frame
    
    local function tweenNotif(obj, props, time, style, dir, callback)
        if not obj or not obj.Parent then return nil end
        local info = TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
        local t = TweenService:Create(obj, info, props)
        if callback and typeof(callback) == "function" then
            t.Completed:Connect(callback)
        end
        t:Play()
        return t
    end
    
    local yOffset = 0
    for _, existingNotif in ipairs(activeNotifications) do
        if existingNotif and existingNotif.Parent then
            yOffset = yOffset - 100
        end
    end
    
    tweenNotif(frame, {
        Position = UDim2.new(1, -360, 0.85, yOffset)
    }, 0.6, Enum.EasingStyle.Back)
    
    tweenNotif(iconContainer, {Size = UDim2.new(0, 58, 0, 58), Position = UDim2.new(0, 10.5, 0, 15.5)}, 0.3)
    task.delay(0.15, function()
        tweenNotif(iconContainer, {Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0, 12, 0, 17)}, 0.2)
    end)
    
    tweenNotif(progressBar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    
    table.insert(activeNotifications, 1, notifGui)
    
    while #activeNotifications > NOTIF_CONFIG.maxNotifications do
        local old = table.remove(activeNotifications)
        if old and old.Parent then
            old:Destroy()
        end
    end
    
    task.delay(duration, function()
        tweenNotif(frame, {
            Position = UDim2.new(1, 60, 0.85, yOffset),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In, function()
            for i, notif in ipairs(activeNotifications) do
                if notif == notifGui then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            notifGui:Destroy()
        end)
    end)
    
    return notifGui
end

-- Funções helper
local function notify(title, text, duration)
    advancedNotify(title, text, "info", duration or 3)
end

local function notifySuccess(title, text, duration)
    advancedNotify(title, text, "success", duration or 3)
end

local function notifyError(title, text, duration)
    advancedNotify(title, text, "error", duration or 3)
end

local function notifyWarning(title, text, duration)
    advancedNotify(title, text, "warning", duration or 3)
end

local function notifyTote(title, text, duration)
    advancedNotify(title, text, "tote", duration or 3)
end

local function notifyMorph(title, text, duration)
    advancedNotify(title, text, "morph", duration or 3)
end

local function notifySky(title, text, duration)
    advancedNotify(title, text, "sky", duration or 3)
end

local function notifyPing(title, text, duration)
    advancedNotify(title, text, "ping", duration or 3)
end

local function notifyBypass(title, text, duration)
    advancedNotify(title, text, "bypass", duration or 3)
end

local function notifyBall(title, text, duration)
    advancedNotify(title, text, "ball", duration or 3)
end

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================
local function tween(obj, props, time, style, dir, callback)
    if not obj or not obj.Parent then return nil end
    time = tonumber(time) or 0.35
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    
    local success, result = pcall(function()
        local info = TweenInfo.new(time, style, dir)
        local t = TweenService:Create(obj, info, props)
        if callback and typeof(callback) == "function" then
            t.Completed:Connect(callback)
        end
        t:Play()
        return t
    end)
    
    return success and result or nil
end

-- ============================================
-- INTRO ANIMADA
-- ============================================
local function createIntro()
    local success = pcall(function()
        introGui = Instance.new("ScreenGui")
        introGui.Name = "CAFUXZ1_Intro_v16"
        introGui.ResetOnSpawn = false
        introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        introGui.Parent = CoreGui
        
        local bg = Instance.new("Frame")
        bg.Name = "Background"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = CONFIG.customColors.bgDark
        bg.BorderSizePixel = 0
        bg.Parent = introGui
        
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(0, 550, 0, 450)
        container.Position = UDim2.new(0.5, -275, 0.5, -225)
        container.BackgroundTransparency = 1
        container.Parent = bg
        
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 1, 0)
        card.BackgroundColor3 = CONFIG.customColors.bgGlass
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel = 0
        card.Parent = container
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 20)
        cardCorner.Parent = card
        
        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = CONFIG.customColors.primary
        cardStroke.Thickness = 2
        cardStroke.Transparency = 0.6
        cardStroke.Parent = card
        
        local iconContainer = Instance.new("Frame")
        iconContainer.Size = UDim2.new(0, 120, 0, 120)
        iconContainer.Position = UDim2.new(0.5, -60, 0, 40)
        iconContainer.BackgroundTransparency = 1
        iconContainer.Parent = card
        
        local iconGlow = Instance.new("Frame")
        iconGlow.Size = UDim2.new(1.4, 0, 1.4, 0)
        iconGlow.Position = UDim2.new(-0.2, 0, -0.2, 0)
        iconGlow.BackgroundColor3 = CONFIG.customColors.primary
        iconGlow.BackgroundTransparency = 0.9
        iconGlow.BorderSizePixel = 0
        iconGlow.Parent = iconContainer
        
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(1, 0)
        glowCorner.Parent = iconGlow
        
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "⚡"
        icon.TextColor3 = CONFIG.customColors.primary
        icon.TextSize = 70
        icon.Font = Enum.Font.GothamBold
        icon.Parent = iconContainer
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 170)
        title.BackgroundTransparency = 1
        title.Text = "CAFUXZ1 Hub"
        title.TextColor3 = CONFIG.customColors.textPrimary
        title.TextSize = 42
        title.Font = Enum.Font.GothamBold
        title.Parent = card
        
        local versionBadge = Instance.new("Frame")
        versionBadge.Size = UDim2.new(0, 220, 0, 30)
        versionBadge.Position = UDim2.new(0.5, -100, 0, 225)
        versionBadge.BackgroundColor3 = CONFIG.customColors.bypass
        versionBadge.BackgroundTransparency = 0.2
        versionBadge.BorderSizePixel = 0
        versionBadge.Parent = card
        
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 15)
        badgeCorner.Parent = versionBadge
        
        local version = Instance.new("TextLabel")
        version.Size = UDim2.new(1, 0, 1, 0)
        version.BackgroundTransparency = 1
        version.Text = "v16.4 + @TCS NOVIDADES"
        version.TextColor3 = Color3.new(1, 1, 1)
        version.TextSize = 14
        version.Font = Enum.Font.GothamBold
        version.Parent = versionBadge
        
        local line = Instance.new("Frame")
        line.Name = "Line"
        line.Size = UDim2.new(0, 0, 0, 2)
        line.Position = UDim2.new(0.5, 0, 0, 270)
        line.BackgroundColor3 = CONFIG.customColors.primary
        line.BorderSizePixel = 0
        line.Parent = card
        
        local updatesText = Instance.new("TextLabel")
        updatesText.Name = "Updates"
        updatesText.Size = UDim2.new(1, -60, 0, 150)
        updatesText.Position = UDim2.new(0, 30, 0, 290)
        updatesText.BackgroundTransparency = 1
        updatesText.Text = "NOVIDADES v16.4:\n\n" ..
                           "• Sistema de Cor de Bola by @TCS NOVIDADES\n" ..
                           "• Anti-Lag separado (Textura/Resolucao)\n" ..
                           "• Double Touch otimizado\n" ..
                           "• Ping Adaptativo\n" ..
                           "• Neve no mapa"
        updatesText.TextColor3 = CONFIG.customColors.textSecondary
        updatesText.TextSize = 15
        updatesText.Font = Enum.Font.Gotham
        updatesText.TextWrapped = true
        updatesText.TextYAlignment = Enum.TextYAlignment.Top
        updatesText.Parent = card
        
        local enterBtn = Instance.new("TextButton")
        enterBtn.Name = "EnterBtn"
        enterBtn.Size = UDim2.new(0, 220, 0, 50)
        enterBtn.Position = UDim2.new(0.5, -110, 1, -70)
        enterBtn.BackgroundColor3 = CONFIG.customColors.primary
        enterBtn.Text = "ENTRAR NO HUB"
        enterBtn.TextColor3 = Color3.new(1, 1, 1)
        enterBtn.TextSize = 18
        enterBtn.Font = Enum.Font.GothamBold
        enterBtn.Parent = card
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = enterBtn
        
        task.spawn(function()
            task.wait(0.3)
            
            iconContainer.Position = UDim2.new(0.5, -60, 0, -150)
            tween(iconContainer, {Position = UDim2.new(0.5, -60, 0, 40)}, 0.8, Enum.EasingStyle.Back)
            
            task.wait(0.2)
            title.TextTransparency = 1
            tween(title, {TextTransparency = 0}, 0.6)
            
            task.wait(0.1)
            tween(versionBadge, {BackgroundTransparency = 0.2}, 0.5)
            
            task.wait(0.2)
            tween(line, {Size = UDim2.new(0.7, 0, 0, 2)}, 0.7, Enum.EasingStyle.Quint)
            
            task.wait(0.3)
            updatesText.TextTransparency = 1
            tween(updatesText, {TextTransparency = 0}, 0.6)
            
            task.wait(0.2)
            enterBtn.BackgroundTransparency = 1
            enterBtn.TextTransparency = 1
            tween(enterBtn, {BackgroundTransparency = 0.2, TextTransparency = 0}, 0.5)
        end)
        
        local function closeIntro()
            pcall(function()
                tween(card, {Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                tween(bg, {BackgroundTransparency = 1}, 0.4)
                task.wait(0.5)
                if introGui then
                    introGui:Destroy()
                    introGui = nil
                end
            end)
        end
        
        enterBtn.MouseButton1Click:Connect(closeIntro)
        task.delay(12, function()
            if introGui and introGui.Parent then 
                closeIntro() 
            end
        end)
    end)
    
    if not success then
        introGui = nil
    end
end

-- ============================================
-- MORPH SYSTEM
-- ============================================
local PRESET_MORPHS = {
    { name = "Miguelcalebegamer202", userId = nil, displayName = "Miguelcalebegamer202" },
    { name = "Tottxii", userId = nil, displayName = "Tottxii" },
    { name = "Feliou23", userId = nil, displayName = "Feliou23 (cb)" },
    { name = "venxcore", userId = nil, displayName = "venxcore (cb)" },
    { name = "AlissonGkBe", userId = nil, displayName = "AlissonGkBe (extra,gk)" }
}

task.spawn(function()
    for _, preset in ipairs(PRESET_MORPHS) do
        if not preset.userId then
            pcall(function()
                preset.userId = Players:GetUserIdFromNameAsync(preset.name)
            end)
        end
        task.wait(0.1)
    end
end)

local function morphToUser(userId, targetName)
    if not userId then 
        notifyError("Morph", "User ID nao encontrado!", 3) 
        return 
    end
    
    if userId == LocalPlayer.UserId then 
        notifyWarning("Morph", "Nao pode morphar em si mesmo!", 3) 
        return 
    end
    
    local character = LocalPlayer.Character
    if not character then
        notifyError("Morph", "Character nao encontrado!", 3)
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        notifyError("Morph", "Humanoid nao encontrado!", 3) 
        return 
    end

    local desc
    local success = pcall(function()
        desc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success or not desc then 
        notifyError("Morph", "Falha ao carregar avatar!", 3) 
        return 
    end

    pcall(function()
        for _, obj in ipairs(character:GetChildren()) do
            if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") or obj:IsA("BodyColors") then
                obj:Destroy()
            end
        end
        
        local head = character:FindFirstChild("Head")
        if head then
            for _, decal in ipairs(head:GetChildren()) do
                if decal:IsA("Decal") then 
                    decal:Destroy() 
                end
            end
        end

        humanoid:ApplyDescriptionClientServer(desc)
    end)
    
    STATS.morphsDone = STATS.morphsDone + 1
    notifyMorph("Transformacao Completa", "Voce agora e: " .. tostring(targetName), 3)
    addLog("Morph: " .. tostring(targetName), "success")
end

-- ============================================
-- SKYBOX SYSTEM
-- ============================================
local SkyboxDatabase = {
    { id = 14828385099, name = "Night Sky With Moon HD", category = "1" },
    { id = 109488540432307, name = "Cosmic Sky A", category = "1" },
    { id = 109844440994380, name = "Cosmic Sky B", category = "1" },
    { id = 277098164, name = "Night/Space Classic", category = "1" },
    { id = 6681543281, name = "Deep Space", category = "1" },
    { id = 77407612452946, name = "Galaxy Nebula", category = "1" },
    { id = 2900944368, name = "Space/Sci-Fi Sky", category = "2" },
    { id = 290982885, name = "Atmospheric Sky", category = "2" },
    { id = 295604372, name = "Cloudy/Weather Sky", category = "2" },
    { id = 17124418086, name = "Custom Sky A", category = "3" },
    { id = 17480150596, name = "Custom Sky B", category = "3" },
    { id = 16553683517, name = "Custom Sky C", category = "3" },
    { id = 264910951, name = "Sunset Sky", category = "3" },
    { id = 149397684, name = "Starry Night", category = "3" },
    { id = 166650228, name = "Cloudy Day", category = "2" },
    { id = 258811038, name = "Dark Space", category = "1" }
}

local currentSkybox = nil
local originalSkybox = nil

local function applySkybox(skyId)
    pcall(function()
        if not originalSkybox then
            originalSkybox = Lighting:FindFirstChildOfClass("Sky")
            if originalSkybox then
                originalSkybox = originalSkybox:Clone()
            end
        end
        
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then
                obj:Destroy()
            end
        end
        
        local newSky = Instance.new("Sky")
        newSky.SkyboxBk = "rbxassetid://" .. skyId
        newSky.SkyboxDn = "rbxassetid://" .. skyId
        newSky.SkyboxFt = "rbxassetid://" .. skyId
        newSky.SkyboxLf = "rbxassetid://" .. skyId
        newSky.SkyboxRt = "rbxassetid://" .. skyId
        newSky.SkyboxUp = "rbxassetid://" .. skyId
        newSky.Parent = Lighting
        
        currentSkybox = skyId
        notifySky("Skybox Alterado", "Ceu atualizado com sucesso!", 3)
    end)
end

local function restoreOriginalSky()
    pcall(function()
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then
                obj:Destroy()
            end
        end
        
        if originalSkybox then
            originalSkybox.Parent = Lighting
            currentSkybox = nil
            notifySky("Skybox", "Ceu original restaurado!", 3)
        end
    end)
end

-- ============================================
-- SISTEMA DE BOLAS (REACH SIMPLIFICADO)
-- ============================================
local function updateBalls()
    if not CONFIG.autoScanEnabled then return end
    
    local now = tick()
    if now - lastBallUpdate < CONFIG.scanInterval then return end
    lastBallUpdate = now
    
    local hrpPos = HRP and HRP.Position
    if not hrpPos then return end
    
    for i = #balls, 1, -1 do
        local ball = balls[i]
        if not ball or not ball.Parent then
            table.remove(balls, i)
        end
    end
    
    local searchCount = 0
    local maxSearch = PingSystem:IsCritical() and 50 or math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        searchCount = searchCount + 1
        if searchCount > maxSearch then break end
        
        if obj:IsA("BasePart") and not obj.Anchored then
            local name = obj.Name:lower()
            local isBall = false
            
            for _, ballName in ipairs(CONFIG.ballNames) do
                if name:find(ballName:lower()) then
                    isBall = true
                    break
                           end
            
            if isBall and obj.Size.Magnitude < 50 then
                local alreadyTracked = false
                for _, tracked in ipairs(balls) do
                    if tracked == obj then
                        alreadyTracked = true
                        break
                    end
                end
                
                if not alreadyTracked then
                    table.insert(balls, obj)
                end
            end
        end
    end
end

-- ============================================
-- SISTEMA DE TOUCH/REACH
-- ============================================
local function autoTouchBall(ball)
    if not ball or not ball.Parent then return end
    if not HRP or not HRP.Parent then return end
    
    local now = tick()
    local debounceKey = ball:GetFullName()
    
    if touchDebounce[debounceKey] and (now - touchDebounce[debounceKey]) < CONFIG.scanCooldown then
        return
    end
    
    local ballPos = ball.Position
    local hrpPos = HRP.Position
    local dist = (ballPos - hrpPos).Magnitude
    
    local effectiveReach = PingSystem:GetEffectiveRange(CONFIG.reach)
    
    if dist <= effectiveReach then
        touchDebounce[debounceKey] = now
        
        local parts = {}
        if CONFIG.fullBodyTouch then
            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
        else
            table.insert(parts, HRP)
        end
        
        for _, part in ipairs(parts) do
            pcall(function()
                firetouchinterest(ball, part, 0)
                task.wait(0.01)
                firetouchinterest(ball, part, 1)
            end)
        end
        
        STATS.totalTouches = STATS.totalTouches + 1
        STATS.ballsTouched = STATS.ballsTouched + 1
    end
end

-- ============================================
-- ESPHERA DE ALCANCE (VISUAL)
-- ============================================
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
        return
    end
    
    if not HRP or not HRP.Parent then return end
    
    if not reachSphere then
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CAFUXZ1_ReachSphere"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.customColors.primary
        reachSphere.Transparency = 0.9
        reachSphere.Parent = Workspace
    end
    
    local effectiveReach = PingSystem:GetEffectiveRange(CONFIG.reach)
    reachSphere.Size = Vector3.new(effectiveReach * 2, effectiveReach * 2, effectiveReach * 2)
    reachSphere.Position = HRP.Position
end

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
local function mainLoop()
    if loopRunning then return end
    loopRunning = true
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isClosed then return end
        
        PingSystem:Update()
        updateBalls()
        updateReachSphere()
        
        if CONFIG.autoTouch then
            for _, ball in ipairs(balls) do
                autoTouchBall(ball)
            end
        end
        
        ReachBypass:Process()
        BallColorSystem:Update()
        
        -- Atualiza estatísticas
        local now = tick()
        if now - lastStatsUpdate >= statsUpdateInterval then
            lastStatsUpdate = now
        end
    end)
end

-- ============================================
-- FUNÇÃO ÍCONE FLUTUANTE (DEFINIDA ANTES DE USAR)
-- ============================================
local function createFloatingIcon()
    if iconGui then
        pcall(function() iconGui:Destroy() end)
    end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CAFUXZ1_Icon"
    iconGui.ResetOnSpawn = false
    iconGui.Parent = CoreGui
    
    local iconButton = Instance.new("TextButton")
    iconButton.Name = "IconButton"
    iconButton.Size = UDim2.new(0, 50, 0, 50)
    iconButton.Position = UDim2.new(1, -70, 0.5, -25)
    iconButton.BackgroundColor3 = CONFIG.customColors.primary
    iconButton.Text = "⚡"
    iconButton.TextColor3 = Color3.new(1, 1, 1)
    iconButton.TextSize = 28
    iconButton.Font = Enum.Font.GothamBold
    iconButton.Parent = iconGui
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconButton
    
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = CONFIG.customColors.textPrimary
    iconStroke.Thickness = 2
    iconStroke.Parent = iconButton
    
    -- Animação flutuante
    task.spawn(function()
        while iconGui and iconGui.Parent do
            local success = pcall(function()
                tween(iconButton, {Position = UDim2.new(1, -70, 0.5, -30)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            end)
            if not success then break end
            task.wait(1)
            
            success = pcall(function()
                tween(iconButton, {Position = UDim2.new(1, -70, 0.5, -20)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            end)
            if not success then break end
            task.wait(1)
        end
    end)
    
    -- Sistema de arrastar o ícone
    local iconDragging = false
    local iconDragStart = nil
    local iconStartPos = nil
    local hasMoved = false
    
    iconButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = true
            hasMoved = false
            iconDragStart = input.Position
            iconStartPos = iconButton.Position
        end
    end)
    
    local inputChangedConn
    inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - iconDragStart
            if delta.Magnitude > 3 then
                hasMoved = true
            end
            pcall(function()
                iconButton.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
            end)
        end
    end)
    
    local inputEndedConn
    inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = false
        end
    end)
    
    -- Clique para abrir o Hub
    iconButton.MouseButton1Click:Connect(function()
        -- Verifica se não estava arrastando (distância pequena = clique, não drag)
        if not hasMoved then
            isClosed = false
            pcall(function()
                if inputChangedConn then inputChangedConn:Disconnect() end
                if inputEndedConn then inputEndedConn:Disconnect() end
                iconGui:Destroy()
            end)
            iconGui = nil
            createMainGUI()
        end
    end)
end

-- ============================================
-- CRIAÇÃO DA INTERFACE GUI (WINDUI STYLE)
-- ============================================
local contentFrame = nil
local sidebar = nil

local function createMainGUI()
    if mainGui then
        pcall(function() mainGui:Destroy() end)
    end
    
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CAFUXZ1_Hub_v16"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = CoreGui
    
    -- Frame Principal
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)
    mainFrame.Position = UDim2.new(0.5, -CONFIG.width/2, 0.5, -CONFIG.height/2)
    mainFrame.BackgroundColor3 = CONFIG.customColors.bgDark
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = mainGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = CONFIG.customColors.primary
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.5
    mainStroke.Parent = mainFrame
    
    -- Header/Title Bar
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = CONFIG.customColors.bgCard
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ CAFUXZ1 Hub"
    titleLabel.TextColor3 = CONFIG.customColors.textPrimary
    titleLabel.TextSize = 22
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 100, 0, 20)
    versionLabel.Position = UDim2.new(0, 20, 0.6, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v16.4"
    versionLabel.TextColor3 = CONFIG.customColors.textMuted
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = header
    
    -- Botão Fechar (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
    closeBtn.BackgroundColor3 = CONFIG.customColors.danger
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        isClosed = true
        pcall(function() mainGui:Destroy() end)
        mainGui = nil
        createFloatingIcon()
    end)
    
    -- Botão Minimizar (−) com SISTEMA DE DUPLO CLIQUE
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -85, 0.5, -17.5)
    minimizeBtn.BackgroundColor3 = CONFIG.customColors.warning
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 22
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeBtn
    
    -- SISTEMA DE DUPLO CLIQUE NO MINIMIZAR
    local lastClickTime = 0
    minimizeBtn.MouseButton1Click:Connect(function()
        local currentTime = tick()
        if currentTime - lastClickTime < 0.3 then -- Duplo clique (menos de 0.3s)
            isMinimized = not isMinimized
            if isMinimized then
                pcall(function()
                    tween(mainFrame, {Size = UDim2.new(0, CONFIG.width, 0, 50)}, 0.3)
                    if contentFrame then contentFrame.Visible = false end
                    if sidebar then sidebar.Visible = false end
                    minimizeBtn.Text = "+"
                end)
            else
                pcall(function()
                    tween(mainFrame, {Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)}, 0.3)
                    if contentFrame then contentFrame.Visible = true end
                    if sidebar then sidebar.Visible = true end
                    minimizeBtn.Text = "−"
                end)
            end
        end
        lastClickTime = currentTime
    end)
    
    -- Sidebar (Menu Lateral)
    sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, CONFIG.sidebarWidth, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = CONFIG.customColors.bgCard
    sidebar.BackgroundTransparency = 0.5
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 0)
    sidebarCorner.Parent = sidebar
    
    -- Content Frame
    contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -CONFIG.sidebarWidth, 1, -50)
    contentFrame.Position = UDim2.new(0, CONFIG.sidebarWidth, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Criar botões do menu lateral
    local tabs = {
        {name = "reach", icon = "🎯", label = "Reach"},
        {name = "tote", icon = "⚽", label = "Tote"},
        {name = "antilag", icon = "🚀", label = "Anti-Lag"},
        {name = "ball", icon = "🔴", label = "Ball Color"},
        {name = "morph", icon = "👤", label = "Morph"},
        {name = "sky", icon = "☁️", label = "Skybox"},
        {name = "stats", icon = "📊", label = "Stats"},
        {name = "logs", icon = "📝", label = "Logs"}
    }
    
    local tabButtons = {}
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.name .. "Btn"
        btn.Size = UDim2.new(1, -10, 0, 45)
        btn.Position = UDim2.new(0, 5, 0, 10 + (i-1) * 55)
        btn.BackgroundColor3 = currentTab == tab.name and CONFIG.customColors.primary or CONFIG.customColors.bgElevated
        btn.Text = tab.icon .. " " .. tab.label
        btn.TextColor3 = currentTab == tab.name and Color3.new(1,1,1) or CONFIG.customColors.textSecondary
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            currentTab = tab.name
            for _, b in ipairs(tabButtons) do
                b.BackgroundColor3 = CONFIG.customColors.bgElevated
                b.TextColor3 = CONFIG.customColors.textSecondary
            end
            btn.BackgroundColor3 = CONFIG.customColors.primary
            btn.TextColor3 = Color3.new(1,1,1)
            updateContent()
        end)
        
        table.insert(tabButtons, btn)
    end
    
    -- Função para atualizar conteúdo baseado na aba
    function updateContent()
        for _, child in ipairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        
        if currentTab == "reach" then
            createReachTab()
        elseif currentTab == "tote" then
            createToteTab()
        elseif currentTab == "antilag" then
            createAntiLagTab()
        elseif currentTab == "ball" then
            createBallColorTab()
        elseif currentTab == "morph" then
            createMorphTab()
        elseif currentTab == "sky" then
            createSkyboxTab()
        elseif currentTab == "stats" then
            createStatsTab()
        elseif currentTab == "logs" then
            createLogsTab()
        end
    end
    
    -- Criar abas (funções serão definidas abaixo)
    function createReachTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 15)
        layout.Parent = scroll
        
        -- Reach Distance Slider
        createSlider(scroll, "Reach Distance", 5, 50, CONFIG.reach, function(val)
            CONFIG.reach = val
        end)
        
        -- Show Sphere Toggle
        createToggle(scroll, "Mostrar Esfera", CONFIG.showReachSphere, function(val)
            CONFIG.showReachSphere = val
        end)
        
        -- Auto Touch Toggle
        createToggle(scroll, "Auto Touch", CONFIG.autoTouch, function(val)
            CONFIG.autoTouch = val
        end)
        
        -- Full Body Touch Toggle
        createToggle(scroll, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
            CONFIG.fullBodyTouch = val
        end)
        
        -- Reach Bypass Toggle
        createToggle(scroll, "Reach Bypass (Double Touch)", CONFIG.reachBypass.enabled, function(val)
            CONFIG.reachBypass.enabled = val
            if val then
                notifyBypass("Reach Bypass", "Sistema ativado!", 2)
            else
                notifyWarning("Reach Bypass", "Desativado", 2)
            end
        end)
        
        -- Ping Optimization Toggle
        createToggle(scroll, "Otimização de Ping", CONFIG.pingOptimization.enabled, function(val)
            CONFIG.pingOptimization.enabled = val
        end)
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    function createToteTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 15)
        layout.Parent = scroll
        
        -- Enable Toggle
        createToggle(scroll, "Ativar Tote System", CONFIG.tote.enabled, function(val)
            ToteSystem:Toggle()
        end)
        
        -- Power Slider
        createSlider(scroll, "Power", 10, 100, CONFIG.tote.power, function(val)
            CONFIG.tote.power = val
        end)
        
        -- Curve Amount Slider
        createSlider(scroll, "Curve Amount", 0, 100, CONFIG.tote.curveAmount, function(val)
            CONFIG.tote.curveAmount = val
        end)
        
        -- Height Slider
        createSlider(scroll, "Height", 5, 50, CONFIG.tote.height, function(val)
            CONFIG.tote.height = val
        end)
        
        -- Visualizer Toggle
        createToggle(scroll, "Visualizador de Trajetória", CONFIG.tote.visualizer, function(val)
            CONFIG.tote.visualizer = val
        end)
        
        -- Auto Aim Toggle
        createToggle(scroll, "Auto Aim", CONFIG.tote.autoAim, function(val)
            CONFIG.tote.autoAim = val
        end)
        
        -- Keybind Info
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, 0, 0, 30)
        info.BackgroundTransparency = 1
        info.Text = "Tecla: [T] para chutar"
        info.TextColor3 = CONFIG.customColors.tote
        info.TextSize = 14
        info.Font = Enum.Font.GothamBold
        info.Parent = scroll
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    function createAntiLagTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 15)
        layout.Parent = scroll
        
        -- Textures Toggle
        createToggle(scroll, "Remover Texturas", AntiLagSystem.TexturesActive, function(val)
            AntiLagSystem:ToggleTextures()
        end)
        
        -- Resolution Toggle
        createToggle(scroll, "Tela Esticada", AntiLagSystem.ResolutionActive, function(val)
            AntiLagSystem:ToggleResolution()
        end)
        
        -- Resolution Scale Slider
        createSlider(scroll, "Escala de Resolução", 30, 100, CONFIG.antiLag.resolutionScale * 100, function(val)
            AntiLagSystem:SetResolution(val / 100)
        end)
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    function createBallColorTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 15)
        layout.Parent = scroll
        
        -- Enable Toggle
        createToggle(scroll, "Ativar Coloração", BallColorSystem.Active, function(val)
            BallColorSystem:Toggle(val)
        end)
        
        -- Snow Toggle
        createToggle(scroll, "Modo Neve (Mapa Inteiro)", BallColorSystem.SnowActive, function(val)
            BallColorSystem:ToggleSnow()
        end)
        
        -- Color Picker (simplificado - botões de cor)
        local colorLabel = Instance.new("TextLabel")
        colorLabel.Size = UDim2.new(1, 0, 0, 25)
        colorLabel.BackgroundTransparency = 1
        colorLabel.Text = "Selecionar Cor:"
        colorLabel.TextColor3 = CONFIG.customColors.textPrimary
        colorLabel.TextSize = 14
        colorLabel.Font = Enum.Font.GothamBold
        colorLabel.Parent = scroll
        
        local colorGrid = Instance.new("Frame")
        colorGrid.Size = UDim2.new(1, 0, 0, 80)
        colorGrid.BackgroundTransparency = 1
        colorGrid.Parent = scroll
        
        local colors = {
            Color3.fromRGB(255, 0, 0),    -- Vermelho
            Color3.fromRGB(0, 255, 0),    -- Verde
            Color3.fromRGB(0, 0, 255),    -- Azul
            Color3.fromRGB(255, 255, 0),  -- Amarelo
            Color3.fromRGB(255, 0, 255),  -- Magenta
            Color3.fromRGB(0, 255, 255),  -- Ciano
            Color3.fromRGB(255, 255, 255),-- Branco
            Color3.fromRGB(0, 0, 0)       -- Preto
        }
        
        for i, color in ipairs(colors) do
            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 35, 0, 35)
            colorBtn.Position = UDim2.new(0, ((i-1) % 4) * 45, 0, math.floor((i-1) / 4) * 45)
            colorBtn.BackgroundColor3 = color
            colorBtn.Text = ""
            colorBtn.Parent = colorGrid
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = colorBtn
            
            colorBtn.MouseButton1Click:Connect(function()
                BallColorSystem:SetColor(color)
                notifyBall("Cor Alterada", "Nova cor aplicada!", 2)
            end)
        end
        
        -- Credit TCS
        local credit = Instance.new("TextLabel")
        credit.Size = UDim2.new(1, 0, 0, 30)
        credit.BackgroundTransparency = 1
        credit.Text = "by @TCS NOVIDADES"
        credit.TextColor3 = CONFIG.customColors.ball
        credit.TextSize = 12
        credit.Font = Enum.Font.Gotham
        credit.Parent = scroll
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    function createMorphTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = scroll
        
        -- Username Input
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(1, 0, 0, 70)
        inputFrame.BackgroundColor3 = CONFIG.customColors.bgElevated
        inputFrame.BorderSizePixel = 0
        inputFrame.Parent = scroll
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 10)
        inputCorner.Parent = inputFrame
        
        local inputLabel = Instance.new("TextLabel")
        inputLabel.Size = UDim2.new(1, -20, 0, 25)
        inputLabel.Position = UDim2.new(0, 10, 0, 5)
        inputLabel.BackgroundTransparency = 1
        inputLabel.Text = "Username para Morph:"
        inputLabel.TextColor3 = CONFIG.customColors.textPrimary
        inputLabel.TextSize = 14
        inputLabel.Font = Enum.Font.GothamBold
        inputLabel.Parent = inputFrame
        
        local usernameBox = Instance.new("TextBox")
        usernameBox.Size = UDim2.new(1, -20, 0, 30)
        usernameBox.Position = UDim2.new(0, 10, 0, 35)
        usernameBox.BackgroundColor3 = CONFIG.customColors.bgCard
        usernameBox.Text = ""
        usernameBox.PlaceholderText = "Digite o username..."
        usernameBox.TextColor3 = CONFIG.customColors.textPrimary
        usernameBox.TextSize = 14
        usernameBox.Font = Enum.Font.Gotham
        usernameBox.Parent = inputFrame
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 6)
        boxCorner.Parent = usernameBox
        
        -- Morph Button
        local morphBtn = Instance.new("TextButton")
        morphBtn.Size = UDim2.new(1, 0, 0, 40)
        morphBtn.BackgroundColor3 = CONFIG.customColors.secondary
        morphBtn.Text = "🔄 Aplicar Morph"
        morphBtn.TextColor3 = Color3.new(1, 1, 1)
        morphBtn.TextSize = 16
        morphBtn.Font = Enum.Font.GothamBold
        morphBtn.Parent = scroll
        
        local morphCorner = Instance.new("UICorner")
        morphCorner.CornerRadius = UDim.new(0, 10)
        morphCorner.Parent = morphBtn
        
        morphBtn.MouseButton1Click:Connect(function()
            local username = usernameBox.Text
            if username and username ~= "" then
                local userId = nil
                pcall(function()
                    userId = Players:GetUserIdFromNameAsync(username)
                end)
                if userId then
                    morphToUser(userId, username)
                else
                    notifyError("Morph", "Username não encontrado!", 3)
                end
            end
        end)
        
        -- Presets Label
        local presetLabel = Instance.new("TextLabel")
        presetLabel.Size = UDim2.new(1, 0, 0, 25)
        presetLabel.BackgroundTransparency = 1
        presetLabel.Text = "Presets:"
        presetLabel.TextColor3 = CONFIG.customColors.textPrimary
        presetLabel.TextSize = 14
        presetLabel.Font = Enum.Font.GothamBold
        presetLabel.Parent = scroll
        
        -- Preset Buttons
        for _, preset in ipairs(PRESET_MORPHS) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundColor3 = CONFIG.customColors.bgElevated
            btn.Text = preset.displayName
            btn.TextColor3 = CONFIG.customColors.textSecondary
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.Parent = scroll
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                if preset.userId then
                    morphToUser(preset.userId, preset.displayName)
                else
                    notifyError("Morph", "ID não carregado ainda, tente novamente!", 2)
                end
            end)
        end
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    function createSkyboxTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = scroll
        
        -- Restore Button
        local restoreBtn = Instance.new("TextButton")
        restoreBtn.Size = UDim2.new(1, 0, 0, 40)
        restoreBtn.BackgroundColor3 = CONFIG.customColors.warning
        restoreBtn.Text = "🔄 Restaurar Céu Original"
        restoreBtn.TextColor3 = Color3.new(1, 1, 1)
        restoreBtn.TextSize = 16
        restoreBtn.Font = Enum.Font.GothamBold
        restoreBtn.Parent = scroll
        
        local restoreCorner = Instance.new("UICorner")
        restoreCorner.CornerRadius = UDim.new(0, 10)
        restoreCorner.Parent = restoreBtn
        
        restoreBtn.MouseButton1Click:Connect(function()
            restoreOriginalSky()
        end)
        
        -- Categorias
        local categories = {
            ["1"] = "🌌 Espaço/Cosmos",
            ["2"] = "☁️ Atmosférico",
            ["3"] = "🎨 Custom/Artístico"
        }
        
        for catId, catName in pairs(categories) do
            local catLabel = Instance.new("TextLabel")
            catLabel.Size = UDim2.new(1, 0, 0, 30)
            catLabel.BackgroundTransparency = 1
            catLabel.Text = catName
            catLabel.TextColor3 = CONFIG.customColors.accent
            catLabel.TextSize = 16
            catLabel.Font = Enum.Font.GothamBold
            catLabel.Parent = scroll
            
            for _, sky in ipairs(SkyboxDatabase) do
                if sky.category == catId then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 35)
                    btn.BackgroundColor3 = CONFIG.customColors.bgElevated
                    btn.Text = sky.name
                    btn.TextColor3 = CONFIG.customColors.textSecondary
                    btn.TextSize = 12
                    btn.Font = Enum.Font.Gotham
                    btn.Parent = scroll
                    
                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 8)
                    btnCorner.Parent = btn
                    
                    btn.MouseButton1Click:Connect(function()
                        applySkybox(sky.id)
                    end)
                end
            end
        end
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    function createStatsTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = scroll
        
        local statsData = {
            {"⏱️ Tempo de Sessão", function() return formatTime(tick() - STATS.sessionStart) end},
            {"👆 Total Touches", function() return tostring(STATS.totalTouches) end},
            {"⚽ Bolas Tocadas", function() return tostring(STATS.ballsTouched) end},
            {"🎯 Tote Kicks", function() return tostring(STATS.toteKicks) end},
            {"🚀 Anti-Lag Items", function() return tostring(STATS.antiLagItems) end},
            {"👤 Morphs Feitos", function() return tostring(STATS.morphsDone) end},
            {"📶 Ping Médio", function() return tostring(STATS.avgPing) .. " ms" end},
            {"🎮 FPS", function() return tostring(STATS.fps) end},
            {"⚡ Bolas em Cache", function() return tostring(STATS.ballsInCache) end}
        }
        
        for _, stat in ipairs(statsData) do
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundColor3 = CONFIG.customColors.bgElevated
            frame.BorderSizePixel = 0
            frame.Parent = scroll
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, -10, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = stat[1]
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local value = Instance.new("TextLabel")
            value.Size = UDim2.new(0.4, -10, 1, 0)
            value.Position = UDim2.new(0.6, 0, 0, 0)
            value.BackgroundTransparency = 1
            value.Text = stat[2]()
            value.TextColor3 = CONFIG.customColors.primary
            value.TextSize = 16
            value.Font = Enum.Font.GothamBold
            value.TextXAlignment = Enum.TextXAlignment.Right
            value.Parent = frame
            
            -- Atualizar valor
            task.spawn(function()
                while frame and frame.Parent do
                    task.wait(1)
                    if value and value.Parent then
                        value.Text = stat[2]()
                    end
                end
            end)
        end
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    
    function createLogsTab()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 6
        scroll.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = scroll
        
        local function updateLogs()
            for _, child in ipairs(scroll:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            for _, log in ipairs(LOGS) do
                local logFrame = Instance.new("Frame")
                logFrame.Size = UDim2.new(1, 0, 0, 40)
                logFrame.BackgroundColor3 = CONFIG.customColors.bgElevated
                logFrame.BorderSizePixel = 0
                logFrame.Parent = scroll
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = logFrame
                
                local typeColors = {
                    info = CONFIG.customColors.info,
                    success = CONFIG.customColors.success,
                    warning = CONFIG.customColors.warning,
                    error = CONFIG.customColors.danger,
                    tote = CONFIG.customColors.tote
                }
                
                local indicator = Instance.new("Frame")
                indicator.Size = UDim2.new(0, 4, 1, -10)
                indicator.Position = UDim2.new(0, 5, 0, 5)
                indicator.BackgroundColor3 = typeColors[log.type] or CONFIG.customColors.info
                indicator.BorderSizePixel = 0
                indicator.Parent = logFrame
                
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(0, 2)
                indicatorCorner.Parent = indicator
                
                local timeLabel = Instance.new("TextLabel")
                timeLabel.Size = UDim2.new(0, 50, 0, 20)
                timeLabel.Position = UDim2.new(0, 15, 0, 5)
                timeLabel.BackgroundTransparency = 1
                timeLabel.Text = log.time
                timeLabel.TextColor3 = CONFIG.customColors.textMuted
                timeLabel.TextSize = 11
                timeLabel.Font = Enum.Font.Gotham
                timeLabel.Parent = logFrame
                
                local msgLabel = Instance.new("TextLabel")
                msgLabel.Size = UDim2.new(1, -20, 0, 20)
                msgLabel.Position = UDim2.new(0, 15, 0, 20)
                msgLabel.BackgroundTransparency = 1
                msgLabel.Text = log.message
                msgLabel.TextColor3 = CONFIG.customColors.textPrimary
                msgLabel.TextSize = 12
                msgLabel.Font = Enum.Font.Gotham
                msgLabel.TextXAlignment = Enum.TextXAlignment.Left
                msgLabel.Parent = logFrame
            end
            
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end
        
        updateLogs()
        
        -- Atualizar a cada 2 segundos
        task.spawn(function()
            while scroll and scroll.Parent do
                task.wait(2)
                if scroll and scroll.Parent then
                    updateLogs()
                end
            end
        end)
    end
    
    -- Helper functions para criar elementos UI
    function createToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = CONFIG.customColors.bgElevated
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = CONFIG.customColors.textPrimary
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 50, 0, 26)
        toggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
        toggleBtn.BackgroundColor3 = default and CONFIG.customColors.success or CONFIG.customColors.danger
        toggleBtn.Text = default and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 13)
        toggleCorner.Parent = toggleBtn
        
        local state = default
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            toggleBtn.BackgroundColor3 = state and CONFIG.customColors.success or CONFIG.customColors.danger
            toggleBtn.Text = state and "ON" or "OFF"
            callback(state)
        end)
    end
    
    function createSlider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 70)
        frame.BackgroundColor3 = CONFIG.customColors.bgElevated
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 25)
        label.Position = UDim2.new(0, 15, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = CONFIG.customColors.textPrimary
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -30, 0, 8)
        sliderBg.Position = UDim2.new(0, 15, 0, 45)
        sliderBg.BackgroundColor3 = CONFIG.customColors.bgCard
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = frame
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 4)
        bgCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = CONFIG.customColors.primary
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 4)
        fillCorner.Parent = sliderFill
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        knob.BackgroundColor3 = CONFIG.customColors.textPrimary
        knob.BorderSizePixel = 0
        knob.Parent = sliderBg
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        
        local dragging = false
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (pos * (max - min)))
            
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -8, 0.5, -8)
            label.Text = text .. ": " .. value
            
            callback(value)
        end
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)
        
        local inputChangedConn = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        
        local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        -- Cleanup connections when frame is destroyed
        frame.Destroying:Connect(function()
            pcall(function()
                inputChangedConn:Disconnect()
                inputEndedConn:Disconnect()
            end)
        end)
    end
    
    function formatTime(seconds)
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", mins, secs)
    end
    
    -- Inicializar com a primeira aba
    updateContent()
    
    -- Animação de entrada
    mainFrame.Position = UDim2.new(0.5, -CONFIG.width/2, 1, 0)
    tween(mainFrame, {Position = UDim2.new(0.5, -CONFIG.width/2, 0.5, -CONFIG.height/2)}, 0.5, Enum.EasingStyle.Back)
    
    notifySuccess("CAFUXZ1 Hub", "Interface carregada com sucesso!", 3)
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
local function initialize()
    PingSystem:Init()
    ReachBypass:Init()
    BallColorSystem:Init()
    ToteSystem:Init()
    
    createIntro()
    
    task.delay(12, function()
        if not mainGui or not mainGui.Parent then
            createFloatingIcon()
        end
    end)
    
    mainLoop()
    
    print("✅ CAFUXZ1 Hub v16.4 Inicializado com sucesso!")
    print("✅ Sistemas ativos: Reach, Tote, Anti-Lag, Ball Color, Morph, Skybox")
end

-- Proteção contra erros
local success, errorMsg = pcall(initialize)
if not success then
    warn("❌ Erro na inicialização: " .. tostring(errorMsg))
    -- Tentar criar interface básica mesmo com erro
    pcall(createFloatingIcon)
end

