local suc, err = pcall(function()
    return game:GetService("Players")
end)

if not suc then
    repeat
        task.wait(0.1)
        suc, err = pcall(function()
            return game:GetService("Players")
        end)
    until suc
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart", 5)

while not LocalPlayer.Character do
    task.wait(0.1)
end

-- ============================================
-- LIMPEZA ANTI-DUPLICAÇÃO
-- ============================================
pcall(function()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name:match("CAFUXZ1") then
            obj:Destroy()
        end
    end
end)

pcall(function()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:match("CAFUXZ1") then
            obj:Destroy()
        end
    end
end)

-- ============================================
-- CONFIGURAÇÕES v16.3 (SEM MAGNET - DOUBLE TOUCH CORRIGIDO)
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
    autoSecondTouch = true,  -- DOUBLE TOUCH (apenas toca 2x, sem puxar)
    scanCooldown = 1.0,
    
    -- CONTROLE DE AUTO ESCANEAMENTO
    autoScanEnabled = true,
    scanInterval = 0.5,
    maxBallsCached = 10,
    
    -- Reach Bypass System (SEM MAGNET - REMOVIDO)
    reachBypass = {
        enabled = true,
        baseRange = 12,
        extendedRange = 25,
        -- REMOVIDO: magneticRange e todo sistema de magnetismo
        multiTouchEnabled = true,
        touchChainCount = 5,
        touchChainDelay = 0.02,
        -- REMOVIDO: magnetEnabled, magnetStrength, magnetDuration
        doubleTouchDelay = 0.03,  -- NOVO: delay entre toque 1 e 2
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
    
    -- Anti Lag
    antiLag = {
        enabled = false,
        textures = true,
        visualEffects = true,
        parts = true,
        particles = true,
        sky = true,
        fullBright = false
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
-- REACH BYPASS SYSTEM (SEM MAGNET - DOUBLE TOUCH CORRIGIDO)
-- ============================================
local ReachBypass = {
    ActiveConnections = {},
    BallsCache = {},
    LastCacheUpdate = 0,
    TouchDebounce = {},
    -- REMOVIDO: ActiveMagnets = {},
    
    -- Bypass System
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
    
    -- Single Touch
    SingleTouch = function(self, ball, part, touchType)
        touchType = touchType or 0
        pcall(function()
            firetouchinterest(ball, part, touchType)
        end)
    end,
    
    -- DOUBLE TOUCH CORRIGIDO (apenas toca 2x, sem puxar)
    DoubleTouch = function(self, ball, parts)
        -- Primeiro toque
        for _, part in ipairs(parts) do
            self:SingleTouch(ball, part, 0)
        end
        
        -- Delay configurável entre toques
        local delay = CONFIG.reachBypass.doubleTouchDelay
        if PingSystem.AveragePing > 100 then
            delay = delay * 1.5  -- Aumenta delay em pings altos
        end
        
        task.wait(delay)
        
        -- Segundo toque (release)
        for _, part in ipairs(parts) do
            self:SingleTouch(ball, part, 1)
        end
    end,
    
    -- Multi-Touch Chain (SEM EMPURRÃO - só toca)
    MultiTouchChain = function(self, ball, parts, priority)
        if not CONFIG.reachBypass.multiTouchEnabled then
            -- Double touch simples
            self:DoubleTouch(ball, parts)
            return
        end
        
        local chainCount = CONFIG.reachBypass.touchChainCount
        local baseDelay = CONFIG.reachBypass.touchChainDelay
        
        -- Ajusta em pings altos
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
                
                -- Cada chain faz double touch
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
                
                -- REMOVIDO: Não tem mais empurrão (pushForce)
                -- Só toca, não puxa a bola
            end)
        end
    end,
    
    -- REMOVIDO: ApplyMagnet function completamente removida
    
    -- Get Balls
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
    
    -- Process Balls (SEM MAGNET)
    Process = function(self)
        if not CONFIG.reachBypass.enabled then return end
        if not HRP or not HRP.Parent then return end
        
        local now = tick()
        if CONFIG.reachBypass.scanRate > 0 and now - (self.LastScan or 0) < CONFIG.reachBypass.scanRate then
            return
        end
        self.LastScan = now
        
        -- Atualiza bypass
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
                
                -- REMOVIDO: Não tem mais magnet range
                
                -- EXTENDED RANGE: Multi-touch chain
                if dist <= effectiveExtended then
                    processed = processed + 1
                    self:MultiTouchChain(ball, parts, priority)
                end
                
                -- BASE RANGE
                if dist <= effectiveBase and processed == 0 then
                    processed = processed + 1
                    self:MultiTouchChain(ball, parts, "high")
                end
            end
        end
    end,
    
    -- Init
    Init = function(self)
        table.insert(self.ActiveConnections, LocalPlayer.CharacterAdded:Connect(function(char)
            Character = char
            HRP = char:WaitForChild("HumanoidRootPart")
        end))
        
        table.insert(self.ActiveConnections, RunService.Heartbeat:Connect(function()
            self:Process()
        end))
        
        print("✅ Reach Bypass v16.0 (SEM MAGNET - Double Touch Corrigido)")
        print("   Base:", CONFIG.reachBypass.baseRange)
        print("   Extended:", CONFIG.reachBypass.extendedRange)
        print("   Double Touch: ATIVO (sem puxar bola)")
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
local antiLagActive = false
local originalStates = {}
local antiLagConnection = nil
local currentSkybox = nil
local originalSkybox = nil
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
        versionBadge.Size = UDim2.new(0, 200, 0, 30)
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
        version.Text = "v16.3 DOUBLE TOUCH"
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
        updatesText.Text = "CORREÇÕES v16.3:\n\n" ..
                           "• MAGNET BALL REMOVIDO\n" ..
                           "• Double Touch funciona corretamente\n" ..
                           "• Só toca 2x na bola (não puxa mais)\n" ..
                           "• Multi-Touch Chain sem empurrão\n" ..
                           "• Sistema de Ping Adaptativo\n" ..
                           "• Controle de Auto Scan (Anti-Lag)"
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
-- ANTI-LAG SYSTEM v2.0 (Enhanced Resolution)
-- ============================================
local AntiLagSystem = {
    Active = false,
    ResolutionEnabled = false,
    OriginalStates = {},
    Connection = nil,
    CameraConnection = nil,
    CurrentResolution = 0.65,
    MinResolution = 0.3,
    MaxResolution = 1.0,
    
    -- Salva estado original
    SaveState = function(self, obj, property, value)
        if not obj or typeof(obj) ~= "Instance" then return end
        if not self.OriginalStates[obj] then self.OriginalStates[obj] = {} end
        if self.OriginalStates[obj][property] == nil then
            self.OriginalStates[obj][property] = value
        end
    end,
    
    -- Limpa texturas e otimiza materiais (metodo agressivo)
    CleanMap = function(self)
        local count = 0
        local batchSize = 100
        local descendants = game.Workspace:GetDescendants()
        
        local function processBatch(startIdx)
            local endIdx = math.min(startIdx + batchSize - 1, #descendants)
            
            for i = startIdx, endIdx do
                local obj = descendants[i]
                if not obj then continue end
                
                pcall(function()
                    -- Remove Decals e Textures
                    if obj:IsA("Decal") or obj:IsA("Texture") then
                        self:SaveState(obj, "Parent", obj.Parent)
                        obj:Destroy()
                        count = count + 1
                    
                    -- Otimiza Partes
                    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                        self:SaveState(obj, "Material", obj.Material)
                        self:SaveState(obj, "Reflectance", obj.Reflectance)
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Reflectance = 0
                        
                        -- Remove texturas de MeshParts
                        if obj:IsA("MeshPart") and obj.TextureID ~= "" then
                            self:SaveState(obj, "TextureID", obj.TextureID)
                            obj.TextureID = ""
                        end
                        count = count + 1
                    end
                    
                    -- Desativa Particles e Trails
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
                addLog("Anti-Lag: " .. count .. " objetos otimizados", "success")
                notifySuccess("Anti-Lag", count .. " objetos otimizados!", 3)
            end
        end
        
        processBatch(1)
    end,
    
    -- Sistema de Resolucao Dinamica (Camera Trick)
    EnableResolution = function(self, scale)
        if self.ResolutionEnabled then return end
        
        self.CurrentResolution = math.clamp(scale or 0.65, self.MinResolution, self.MaxResolution)
        self.ResolutionEnabled = true
        
        local Camera = workspace.CurrentCamera
        
        self.CameraConnection = RunService.RenderStepped:Connect(function()
            if not self.ResolutionEnabled then return end
            -- Aplica matriz de escala na CFrame da camera para reduzir resolucao
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, self.CurrentResolution, 0, 0, 0, 1)
        end)
        
        notifySuccess("Resolucao", "Modo performance ativado: " .. math.floor(self.CurrentResolution * 100) .. "%", 3)
        addLog("Resolucao reduzida para " .. self.CurrentResolution, "success")
    end,
    
    DisableResolution = function(self)
        if not self.ResolutionEnabled then return end
        
        self.ResolutionEnabled = false
        
        if self.CameraConnection then
            pcall(function()
                self.CameraConnection:Disconnect()
            end)
            self.CameraConnection = nil
        end
        
        notifyWarning("Resolucao", "Modo performance desativado", 2)
        addLog("Resolucao restaurada", "warning")
    end,
    
    -- Ativa Anti-Lag completo
    Enable = function(self, resolutionScale)
        if self.Active then 
            notifyWarning("Anti-Lag", "Ja esta ativado!", 2)
            return 
        end
        
        self.Active = true
        
        -- Limpa mapa
        task.spawn(function()
            self:CleanMap()
        end)
        
        -- Ativa resolucao se solicitado
        if resolutionScale then
            self:EnableResolution(resolutionScale)
        end
        
        -- Monitora novos objetos
        self.Connection = game.DescendantAdded:Connect(function(obj)
            if not self.Active then return end
            task.wait(0.05)
            
            pcall(function()
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    if obj:IsA("MeshPart") then
                        obj.TextureID = ""
                    end
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end)
        end)
        
        CONFIG.antiLag.enabled = true
    end,
    
    -- Desativa Anti-Lag e restaura tudo
    Disable = function(self)
        if not self.Active then return end
        
        self.Active = false
        CONFIG.antiLag.enabled = false
        
        -- Desativa resolucao
        self:DisableResolution()
        
        -- Desconecta monitor
        if self.Connection then
            pcall(function()
                self.Connection:Disconnect()
            end)
            self.Connection = nil
        end
        
        -- Restaura estados originais em batch
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
                    notifyWarning("Anti-Lag", "Tudo restaurado!", 3)
                    addLog("Anti-Lag desativado", "warning")
                end
            end
            
            if #states > 0 then
                restoreBatch(1)
            else
                notifyWarning("Anti-Lag", "Desativado!", 2)
            end
        end)
    end,
    
    -- Atualiza escala de resolucao em tempo real
    SetResolution = function(self, newScale)
        if not self.ResolutionEnabled then
            notifyWarning("Resolucao", "Ative o Anti-Lag primeiro!", 2)
            return
        end
        
        self.CurrentResolution = math.clamp(newScale, self.MinResolution, self.MaxResolution)
        notifySuccess("Resolucao", "Ajustada para " .. math.floor(self.CurrentResolution * 100) .. "%", 2)
        addLog("Resolucao alterada: " .. self.CurrentResolution, "info")
    end,
    
    Toggle = function(self)
        if self.Active then
            self:Disable()
        else
            self:Enable(self.CurrentResolution)
        end
        return self.Active
    end
}

-- Substitui as funcoes antigas de Anti-Lag
applyAntiLag = function(resolutionScale)
    AntiLagSystem:Enable(resolutionScale)
end

disableAntiLag = function()
    AntiLagSystem:Disable()
end

-- Retorna o sistema para acesso global
getgenv().AntiLagSystem = AntiLagSystem





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
        notifyError("❌ Morph", "User ID não encontrado!", 3) 
        return 
    end
    
    if userId == LocalPlayer.UserId then 
        notifyWarning("⚠️ Morph", "Não pode morphar em si mesmo!", 3) 
        return 
    end
    
    local character = LocalPlayer.Character
    if not character then
        notifyError("❌ Morph", "Character não encontrado!", 3)
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        notifyError("❌ Morph", "Humanoid não encontrado!", 3) 
        return 
    end

    local desc
    local success = pcall(function()
        desc = Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success or not desc then 
        notifyError("❌ Morph", "Falha ao carregar avatar!", 3) 
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
    notifyMorph("✨ Transformação Completa", "Você agora é: " .. tostring(targetName), 3)
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
        notifySky("☁️ Skybox Alterado", "Céu atualizado com sucesso!", 3)
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
            notifySky("☁️ Skybox", "Céu original restaurado!", 3)
        end
    end)
end

-- ============================================
-- TOTE SYSTEM v3.0 (CORRIGIDO - SEM MAGNET)
-- ============================================
local ToteSystem = {
    Active = false,
    Visualizer = nil,
    PredictionPoints = {},
    CurrentBall = nil,
    LastKick = 0,
    
    Init = function(self)
        -- Input handler para tecla T
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == CONFIG.tote.keybind and CONFIG.tote.enabled then
                self:Activate()
            end
        end)
        
        print("✅ Tote System v3.0 Inicializado (Sem Magnet)")
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
        
        -- Direção base (para frente do player)
        local baseDirection = playerLook
        
        -- Cálculo de curva lateral (sem magnet - só aplica força inicial)
        local curveDirection = CONFIG.tote.curveDirection
        local curveAmount = CONFIG.tote.curveAmount / 100
        
        local lateralVector = Vector3.new(-baseDirection.Z, 0, baseDirection.X) -- perpendicular
        local curveVector = Vector3.new()
        
        if curveDirection == "Left" then
            curveVector = -lateralVector * curveAmount
        elseif curveDirection == "Right" then
            curveVector = lateralVector * curveAmount
        elseif curveDirection == "Auto" then
            -- Auto detecta baseado na posição do gol ou alvo
            if targetPos then
                local toTarget = (targetPos - ballPos).Unit
                local cross = baseDirection:Cross(toTarget)
                curveVector = lateralVector * math.sign(cross.Y) * curveAmount * 0.5
            end
        end
        
        -- Altura
        local height = CONFIG.tote.height / 10
        
        -- Power base
        local power = CONFIG.tote.power
        
        -- Compensação de gravidade
        local gravityComp = 0
        if CONFIG.tote.gravityCompensation then
            gravityComp = math.sqrt(2 * workspace.Gravity * height) * 0.1
        end
        
        -- Velocidade final (sem atrair a bola - só direção)
        local finalVelocity = (baseDirection + curveVector).Unit * power + Vector3.new(0, height + gravityComp, 0)
        
        -- Spin/Magnus effect (opcional, sem puxar)
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
        -- Simulação simples de onde a bola vai cair
        local g = workspace.Gravity
        local vy = velocity.Y
        local vx = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        
        -- Tempo até atingir altura máxima e cair
        local timeToPeak = vy / g
        local totalTime = timeToPeak * 2
        
        -- Distância horizontal
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
        
        -- Criar pontos de predição
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
        
        -- Linha conectando pontos
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
        self.PredictionPoints = points
        
        -- Auto remove após 2 segundos
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
            self.PredictionPoints = {}
        end
    end,
    
    Activate = function(self)
        local now = tick()
        if now - self.LastKick < CONFIG.tote.debounce then
            notifyWarning("⏳ Tote", "Aguarde o cooldown!", 1)
            return
        end
        
        if not CONFIG.tote.enabled then
            notifyWarning("⚠️ Tote", "Sistema desativado!", 2)
            return
        end
        
        local ball = self:GetBall()
        if not ball then
            notifyError("❌ Tote", "Nenhuma bola próxima encontrada!", 2)
            return
        end
        
        -- Verifica se pode aplicar física
        if ball.Anchored then
            notifyError("❌ Tote", "Bola está travada!", 2)
            return
        end
        
        self.LastKick = now
        STATS.toteKicks = STATS.toteKicks + 1
        
        -- Calcula trajetória (sem magnet - só direção)
        local trajectory = self:CalculateTrajectory(ball, nil)
        
        -- Aplica velocidade (se network owner permitir)
        pcall(function()
            -- Tenta setar network owner
            ball:SetNetworkOwner(nil)
            
            -- Aplica velocidade de chute
            ball.AssemblyLinearVelocity = trajectory.velocity
            
            -- Aplica spin (BodyAngularVelocity) - opcional
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
                
                game:GetService("Debris"):AddItem(bav, 0.5)
            end
            
            -- Força de Magnus (curva) - BodyForce opcional
            if CONFIG.tote.magnusForce > 0 and trajectory.magnusForce.Magnitude > 0.01 then
                local bf = Instance.new("BodyForce")
                bf.Force = trajectory.magnusForce * ball.AssemblyMass * workspace.Gravity
                bf.Parent = ball
                
                game:GetService("Debris"):AddItem(bf, 0.3)
            end
        end)
        
        -- Visualizador
        self:CreateVisualizer(trajectory)
        
        notifyTote("🎯 Tote Ativado!", "Power: " .. CONFIG.tote.power .. " | Curve: " .. CONFIG.tote.curveDirection, 2)
        addLog("Tote kick: " .. CONFIG.tote.power .. " power", "tote")
    end,
    
    Toggle = function(self)
        CONFIG.tote.enabled = not CONFIG.tote.enabled
        if CONFIG.tote.enabled then
            notifyTote("🎯 Tote System", "Ativado! Pressione [T] para chutar", 3)
        else
            notifyWarning("⚠️ Tote System", "Desativado!", 2)
            self:ClearVisualizer()
        end
        return CONFIG.tote.enabled
    end
}

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
    
    -- Limpa bolas antigas
    for i = #balls, 1, -1 do
        local ball = balls[i]
        if not ball or not ball.Parent then
            table.remove(balls, i)
        end
    end
    
    -- Scan por novas bolas
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

local function createReachSphere()
    if reachSphere then
        pcall(function() reachSphere:Destroy() end)
    end
    
    if not CONFIG.showReachSphere then return end
    
    reachSphere = Instance.new("Part")
    reachSphere.Name = "CAFUXZ1_ReachSphere"
    reachSphere.Shape = Enum.PartType.Ball
    reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
    reachSphere.Anchored = true
    reachSphere.CanCollide = false
    reachSphere.Transparency = 0.9
    reachSphere.Material = Enum.Material.ForceField
    reachSphere.Color = CONFIG.customColors.primary
    reachSphere.Parent = Workspace
    
    -- Atualiza posição
    task.spawn(function()
        while reachSphere and reachSphere.Parent do
            pcall(function()
                if HRP and HRP.Parent then
                    reachSphere.Position = HRP.Position
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function createArthurSphere()
    if arthurSphere then
        pcall(function() arthurSphere:Destroy() end)
    end
    
    arthurSphere = Instance.new("Part")
    arthurSphere.Name = "CAFUXZ1_ArthurSphere"
    arthurSphere.Shape = Enum.PartType.Ball
    arthurSphere.Size = Vector3.new(CONFIG.arthurSphere.reach * 2, CONFIG.arthurSphere.reach * 2, CONFIG.arthurSphere.reach * 2)
    arthurSphere.Anchored = true
    arthurSphere.CanCollide = false
    arthurSphere.Transparency = CONFIG.arthurSphere.transparency
    arthurSphere.Material = CONFIG.arthurSphere.material
    arthurSphere.Color = CONFIG.arthurSphere.color
    arthurSphere.Parent = Workspace
    
    -- Efeito de pulso
    task.spawn(function()
        local baseSize = CONFIG.arthurSphere.reach * 2
        while arthurSphere and arthurSphere.Parent do
            local pulse = math.sin(tick() * CONFIG.arthurSphere.pulseSpeed) * 0.5 + 0.5
            pcall(function()
                arthurSphere.Size = Vector3.new(baseSize + pulse * 2, baseSize + pulse * 2, baseSize + pulse * 2)
                if HRP and HRP.Parent then
                    arthurSphere.Position = HRP.Position
                end
            end)
            task.wait(0.05)
        end
    end)
end

-- ============================================
-- AUTO TOUCH SIMPLIFICADO (SEM MAGNET)
-- ============================================
local function autoTouch()
    if not CONFIG.autoTouch then return end
    
    local now = tick()
    if now - lastTouch < CONFIG.scanCooldown then return end
    
    local hrpPos = HRP and HRP.Position
    if not hrpPos then return end
    
    local parts = {}
    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    
    local touched = 0
    
    for _, ball in ipairs(balls) do
        if ball and ball.Parent and ball.Position then
            local dist = (ball.Position - hrpPos).Magnitude
            
            if dist <= CONFIG.reach then
                local debounceKey = ball:GetFullName()
                
                if not touchDebounce[debounceKey] or (now - touchDebounce[debounceKey]) > 0.5 then
                    touchDebounce[debounceKey] = now
                    
                    -- Double touch sem puxar (igual ReachBypass)
                    for _, part in ipairs(parts) do
                        firetouchinterest(ball, part, 0)
                    end
                    
                    task.wait(0.03)
                    
                    for _, part in ipairs(parts) do
                        firetouchinterest(ball, part, 1)
                    end
                    
                    touched = touched + 1
                    STATS.totalTouches = STATS.totalTouches + 1
                    
                    if CONFIG.fullBodyTouch then
                        -- Touch adicional em partes específicas se necessário
                        task.wait(0.02)
                        for _, part in ipairs(parts) do
                            firetouchinterest(ball, part, 0)
                            task.wait(0.01)
                            firetouchinterest(ball, part, 1)
                        end
                    end
                end
            end
        end
    end
    
    if touched > 0 then
        lastTouch = now
        STATS.ballsTouched = STATS.ballsTouched + touched
    end
end

-- ============================================
-- GUI SYSTEM (WINDUI STYLE)
-- ============================================
local function createMainGUI()
    -- ScreenGui principal
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "CAFUXZ1_Hub_v16"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = CoreGui
    
    -- Frame principal
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)
    mainFrame.Position = UDim2.new(0.5, -CONFIG.width/2, 0.5, -CONFIG.height/2)
    mainFrame.BackgroundColor3 = CONFIG.customColors.bgDark
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui
    
    -- Cantos arredondados
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    -- Stroke principal
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = CONFIG.customColors.primary
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.6
    mainStroke.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = CONFIG.customColors.bgCard
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 0, 30)
    titleLabel.Position = UDim2.new(0, 20, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "CAFUXZ1 Hub"
    titleLabel.TextColor3 = CONFIG.customColors.textPrimary
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Versão
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 150, 0, 20)
    versionLabel.Position = UDim2.new(0, 20, 0, 38)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v16.3 DOUBLE TOUCH"
    versionLabel.TextColor3 = CONFIG.customColors.bypass
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = header
    
    -- Botões de controle (minimizar/fechar)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 80, 0, 30)
    controlsFrame.Position = UDim2.new(1, -90, 0, 15)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = header
    
    -- Botão minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 35, 0, 30)
    minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
    minimizeBtn.BackgroundColor3 = CONFIG.customColors.warning
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = controlsFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 30)
    closeBtn.Position = UDim2.new(0, 45, 0, 0)
    closeBtn.BackgroundColor3 = CONFIG.customColors.danger
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = controlsFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, CONFIG.sidebarWidth, 1, -60)
    sidebar.Position = UDim2.new(0, 0, 0, 60)
    sidebar.BackgroundColor3 = CONFIG.customColors.bgCard
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 0)
    sidebarCorner.Parent = sidebar
    
    -- Conteúdo principal (tabs)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -CONFIG.sidebarWidth - 20, 1, -80)
    contentFrame.Position = UDim2.new(0, CONFIG.sidebarWidth + 10, 0, 70)
    contentFrame.BackgroundColor3 = CONFIG.customColors.bgGlass
    contentFrame.BackgroundTransparency = 0.5
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 12)
    contentCorner.Parent = contentFrame
    
    -- Criar botões da sidebar
    local tabs = {
        { name = "reach", icon = "⚡", label = "Reach" },
        { name = "tote", icon = "🎯", label = "Tote" },
        { name = "visual", icon = "👁️", label = "Visual" },
        { name = "morph", icon = "✨", label = "Morph" },
        { name = "sky", icon = "☁️", label = "Skybox" },
        { name = "stats", icon = "📊", label = "Stats" },
        { name = "logs", icon = "📜", label = "Logs" }
    }
    
    local tabButtons = {}
    local tabContents = {}
    
    for i, tab in ipairs(tabs) do
        -- Botão do tab
        local btn = Instance.new("TextButton")
        btn.Name = tab.name .. "Btn"
        btn.Size = UDim2.new(0.9, 0, 0, 45)
        btn.Position = UDim2.new(0.05, 0, 0, 10 + (i-1) * 55)
        btn.BackgroundColor3 = (i == 1) and CONFIG.customColors.primary or CONFIG.customColors.bgElevated
        btn.Text = tab.icon .. " " .. tab.label
        btn.TextColor3 = CONFIG.customColors.textPrimary
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        tabButtons[tab.name] = btn
        
        -- Conteúdo do tab
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tab.name .. "Content"
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = CONFIG.customColors.primary
        tabContent.Visible = (i == 1)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Parent = contentFrame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 10)
        listLayout.Parent = tabContent
        
        tabContents[tab.name] = tabContent
        
        -- Click handler
        btn.MouseButton1Click:Connect(function()
            currentTab = tab.name
            
            -- Atualiza visual dos botões
            for name, button in pairs(tabButtons) do
                button.BackgroundColor3 = (name == tab.name) and CONFIG.customColors.primary or CONFIG.customColors.bgElevated
            end
            
            -- Mostra conteúdo correto
            for name, content in pairs(tabContents) do
                content.Visible = (name == tab.name)
            end
        end)
    end
    
    -- ============================================
    -- TAB: REACH (Conteúdo)
    -- ============================================
    local reachContent = tabContents.reach
    
    -- Título da seção
    local reachTitle = Instance.new("TextLabel")
    reachTitle.Size = UDim2.new(1, 0, 0, 30)
    reachTitle.BackgroundTransparency = 1
    reachTitle.Text = "⚡ REACH SYSTEM"
    reachTitle.TextColor3 = CONFIG.customColors.primary
    reachTitle.TextSize = 18
    reachTitle.Font = Enum.Font.GothamBold
    reachTitle.TextXAlignment = Enum.TextXAlignment.Left
    reachTitle.Parent = reachContent
    
    -- Toggle Reach Bypass
    createToggle(reachContent, "Reach Bypass", CONFIG.reachBypass.enabled, function(val)
        CONFIG.reachBypass.enabled = val
        if val then
            notifyBypass("⚔️ Reach Bypass", "Ativado! Double Touch sem magnet.", 2)
        else
            notifyWarning("⚠️ Reach Bypass", "Desativado!", 2)
        end
    end)
    
    -- Toggle Auto Touch
    createToggle(reachContent, "Auto Touch", CONFIG.autoTouch, function(val)
        CONFIG.autoTouch = val
    end)
    
    -- Toggle Show Sphere
    createToggle(reachContent, "Mostrar Esfera", CONFIG.showReachSphere, function(val)
        CONFIG.showReachSphere = val
        if val then
            createReachSphere()
        elseif reachSphere then
            reachSphere:Destroy()
            reachSphere = nil
        end
    end)
    
    -- Slider Reach Distance
    createSlider(reachContent, "Alcance", 5, 50, CONFIG.reach, function(val)
        CONFIG.reach = val
        if reachSphere then
            reachSphere.Size = Vector3.new(val * 2, val * 2, val * 2)
        end
    end)
    
    -- Slider Double Touch Delay
    createSlider(reachContent, "Delay Double Touch", 0.01, 0.1, CONFIG.reachBypass.doubleTouchDelay, function(val)
        CONFIG.reachBypass.doubleTouchDelay = val
    end)
    
    -- Info Bypass
    local bypassInfo = Instance.new("TextLabel")
    bypassInfo.Size = UDim2.new(1, 0, 0, 60)
    bypassInfo.BackgroundTransparency = 1
    bypassInfo.Text = "🛡️ SISTEMA ATUAL:\n• Sem Magnet (não puxa bola)\n• Double Touch puro\n• Multi-Touch Chain"
    bypassInfo.TextColor3 = CONFIG.customColors.textSecondary
    bypassInfo.TextSize = 12
    bypassInfo.Font = Enum.Font.Gotham
    bypassInfo.TextWrapped = true
    bypassInfo.TextXAlignment = Enum.TextXAlignment.Left
    bypassInfo.Parent = reachContent
    
    -- ============================================
    -- TAB: TOTE (Conteúdo)
    -- ============================================
    local toteContent = tabContents.tote
    
    local toteTitle = Instance.new("TextLabel")
    toteTitle.Size = UDim2.new(1, 0, 0, 30)
    toteTitle.BackgroundTransparency = 1
    toteTitle.Text = "🎯 TOTE SYSTEM"
    toteTitle.TextColor3 = CONFIG.customColors.tote
    toteTitle.TextSize = 18
    toteTitle.Font = Enum.Font.GothamBold
    toteTitle.TextXAlignment = Enum.TextXAlignment.Left
    toteTitle.Parent = toteContent
    
    -- Toggle Tote
    createToggle(toteContent, "Ativar Tote", CONFIG.tote.enabled, function(val)
        CONFIG.tote.enabled = val
        ToteSystem:Toggle()
    end)
    
    -- Slider Power
    createSlider(toteContent, "Power", 10, 100, CONFIG.tote.power, function(val)
        CONFIG.tote.power = val
    end)
    
    -- Slider Curve
    createSlider(toteContent, "Curve Amount", 0, 100, CONFIG.tote.curveAmount, function(val)
        CONFIG.tote.curveAmount = val
    end)
    
    -- Slider Height
    createSlider(toteContent, "Height", 0, 50, CONFIG.tote.height, function(val)
        CONFIG.tote.height = val
    end)
    
    -- Dropdown Curve Direction
    createDropdown(toteContent, "Curve Direction", {"Auto", "Left", "Right"}, CONFIG.tote.curveDirection, function(val)
        CONFIG.tote.curveDirection = val
    end)
    
    -- Toggle Visualizer
    createToggle(toteContent, "Visualizador", CONFIG.tote.visualizer, function(val)
        CONFIG.tote.visualizer = val
    end)
    
    -- Keybind info
    local keybindInfo = Instance.new("TextLabel")
    keybindInfo.Size = UDim2.new(1, 0, 0, 30)
    keybindInfo.BackgroundTransparency = 1
    keybindInfo.Text = "⌨️ Keybind: [T] para chutar"
    keybindInfo.TextColor3 = CONFIG.customColors.textMuted
    keybindInfo.TextSize = 12
    keybindInfo.Font = Enum.Font.Gotham
    keybindInfo.Parent = toteContent
    

        -- ============================================
    -- TAB: VISUAL (Conteúdo Atualizado)
    -- ============================================
    local visualContent = tabContents.visual
    
    local visualTitle = Instance.new("TextLabel")
    visualTitle.Size = UDim2.new(1, 0, 0, 30)
    visualTitle.BackgroundTransparency = 1
    visualTitle.Text = "VISUAL SETTINGS"
    visualTitle.TextColor3 = CONFIG.customColors.accent
    visualTitle.TextSize = 18
    visualTitle.Font = Enum.Font.GothamBold
    visualTitle.TextXAlignment = Enum.TextXAlignment.Left
    visualTitle.Parent = visualContent
    
    -- Toggle Anti Lag (agora ativa com resolução)
    createToggle(visualContent, "Anti-Lag + Resolucao", CONFIG.antiLag.enabled, function(val)
        CONFIG.antiLag.enabled = val
        if val then
            AntiLagSystem:Enable(AntiLagSystem.CurrentResolution)
        else
            AntiLagSystem:Disable()
        end
    end)
    
    -- Slider Resolução (0.3 = mais FPS/tela esticada, 1.0 = normal)
    createSlider(visualContent, "Escala Resolucao (FPS)", 30, 100, AntiLagSystem.CurrentResolution * 100, function(val)
        local scale = val / 100
        AntiLagSystem:SetResolution(scale)
    end)
    
    -- Info sobre resolução
    local resInfo = Instance.new("TextLabel")
    resInfo.Size = UDim2.new(1, 0, 0, 40)
    resInfo.BackgroundTransparency = 1
    resInfo.Text = "Dica: Valores menores = mais FPS, imagem mais esticada\\nRecomendado: 50-65% para balanceamento"
    resInfo.TextColor3 = CONFIG.customColors.textMuted
    resInfo.TextSize = 11
    resInfo.Font = Enum.Font.Gotham
    resInfo.TextWrapped = true
    resInfo.Parent = visualContent
    
    -- Toggle Ping Monitor
    createToggle(visualContent, "Monitor de Ping", CONFIG.pingOptimization.showPingMonitor, function(val)
        CONFIG.pingOptimization.showPingMonitor = val
    end)
    
    -- Toggle Arthur Sphere
    createToggle(visualContent, "Arthur Sphere", false, function(val)
        if val then
            createArthurSphere()
        elseif arthurSphere then
            arthurSphere:Destroy()
            arthurSphere = nil
        end
    end)

    
    -- ============================================
    -- TAB: MORPH (Conteúdo)
    -- ============================================
    local morphContent = tabContents.morph
    
    local morphTitle = Instance.new("TextLabel")
    morphTitle.Size = UDim2.new(1, 0, 0, 30)
    morphTitle.BackgroundTransparency = 1
    morphTitle.Text = "✨ MORPH SYSTEM"
    morphTitle.TextColor3 = CONFIG.customColors.secondary
    morphTitle.TextSize = 18
    morphTitle.Font = Enum.Font.GothamBold
    morphTitle.TextXAlignment = Enum.TextXAlignment.Left
    morphTitle.Parent = morphContent
    
    -- Input para username
    local morphInput = Instance.new("TextBox")
    morphInput.Size = UDim2.new(1, 0, 0, 40)
    morphInput.BackgroundColor3 = CONFIG.customColors.bgElevated
    morphInput.Text = "Username..."
    morphInput.TextColor3 = CONFIG.customColors.textSecondary
    morphInput.TextSize = 14
    morphInput.Font = Enum.Font.Gotham
    morphInput.ClearTextOnFocus = true
    morphInput.Parent = morphContent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = morphInput
    
    -- Botão Apply
    local morphBtn = Instance.new("TextButton")
    morphBtn.Size = UDim2.new(1, 0, 0, 40)
    morphBtn.Position = UDim2.new(0, 0, 0, 50)
    morphBtn.BackgroundColor3 = CONFIG.customColors.secondary
    morphBtn.Text = "🔄 Aplicar Morph"
    morphBtn.TextColor3 = Color3.new(1, 1, 1)
    morphBtn.TextSize = 14
    morphBtn.Font = Enum.Font.GothamBold
    morphBtn.Parent = morphContent
    
    local morphBtnCorner = Instance.new("UICorner")
    morphBtnCorner.CornerRadius = UDim.new(0, 8)
    morphBtnCorner.Parent = morphBtn
    
    morphBtn.MouseButton1Click:Connect(function()
        local username = morphInput.Text
        if username and username ~= "" and username ~= "Username..." then
            pcall(function()
                local userId = Players:GetUserIdFromNameAsync(username)
                morphToUser(userId, username)
            end)
        end
    end)
    
    -- Presets
    local presetsLabel = Instance.new("TextLabel")
    presetsLabel.Size = UDim2.new(1, 0, 0, 25)
    presetsLabel.Position = UDim2.new(0, 0, 0, 100)
    presetsLabel.BackgroundTransparency = 1
    presetsLabel.Text = "Presets:"
    presetsLabel.TextColor3 = CONFIG.customColors.textMuted
    presetsLabel.TextSize = 12
    presetsLabel.Font = Enum.Font.Gotham
    presetsLabel.TextXAlignment = Enum.TextXAlignment.Left
    presetsLabel.Parent = morphContent
    
    for i, preset in ipairs(PRESET_MORPHS) do
        local presetBtn = Instance.new("TextButton")
        presetBtn.Size = UDim2.new(1, 0, 0, 35)
        presetBtn.Position = UDim2.new(0, 0, 0, 125 + (i-1) * 40)
        presetBtn.BackgroundColor3 = CONFIG.customColors.bgElevated
        presetBtn.Text = preset.displayName
        presetBtn.TextColor3 = CONFIG.customColors.textPrimary
        presetBtn.TextSize = 12
        presetBtn.Font = Enum.Font.Gotham
        presetBtn.Parent = morphContent
        
        local presetCorner = Instance.new("UICorner")
        presetCorner.CornerRadius = UDim.new(0, 6)
        presetCorner.Parent = presetBtn
        
        presetBtn.MouseButton1Click:Connect(function()
            if preset.userId then
                morphToUser(preset.userId, preset.displayName)
            else
                notifyError("❌ Erro", "User ID não carregado ainda!", 2)
            end
        end)
    end
    
    -- ============================================
    -- TAB: SKYBOX (Conteúdo)
    -- ============================================
    local skyContent = tabContents.sky
    
    local skyTitle = Instance.new("TextLabel")
    skyTitle.Size = UDim2.new(1, 0, 0, 30)
    skyTitle.BackgroundTransparency = 1
    skyTitle.Text = "☁️ SKYBOX SYSTEM"
    skyTitle.TextColor3 = CONFIG.customColors.accent
    skyTitle.TextSize = 18
    skyTitle.Font = Enum.Font.GothamBold
    skyTitle.TextXAlignment = Enum.TextXAlignment.Left
    skyTitle.Parent = skyContent
    
    -- Botão Restore Original
    local restoreSkyBtn = Instance.new("TextButton")
    restoreSkyBtn.Size = UDim2.new(1, 0, 0, 35)
    restoreSkyBtn.BackgroundColor3 = CONFIG.customColors.danger
    restoreSkyBtn.Text = "↩️ Restaurar Original"
    restoreSkyBtn.TextColor3 = Color3.new(1, 1, 1)
    restoreSkyBtn.TextSize = 14
    restoreSkyBtn.Font = Enum.Font.GothamBold
    restoreSkyBtn.Parent = skyContent
    
    local restoreCorner = Instance.new("UICorner")
    restoreCorner.CornerRadius = UDim.new(0, 8)
    restoreCorner.Parent = restoreSkyBtn
    
    restoreSkyBtn.MouseButton1Click:Connect(function()
        restoreOriginalSky()
    end)
    
    -- Categorias
    local categories = {"Space/Cosmic", "Atmospheric", "Custom"}
    local catColors = {Color3.fromRGB(100, 100, 255), Color3.fromRGB(100, 255, 100), Color3.fromRGB(255, 100, 100)}
    
    local yOffset = 45
    for catIdx, category in ipairs(categories) do
        local catLabel = Instance.new("TextLabel")
        catLabel.Size = UDim2.new(1, 0, 0, 25)
        catLabel.Position = UDim2.new(0, 0, 0, yOffset)
        catLabel.BackgroundTransparency = 1
        catLabel.Text = category
        catLabel.TextColor3 = catColors[catIdx]
        catLabel.TextSize = 14
        catLabel.Font = Enum.Font.GothamBold
        catLabel.TextXAlignment = Enum.TextXAlignment.Left
        catLabel.Parent = skyContent
        
        yOffset = yOffset + 30
        
        for _, sky in ipairs(SkyboxDatabase) do
            if tonumber(sky.category) == catIdx then
                local skyBtn = Instance.new("TextButton")
                skyBtn.Size = UDim2.new(1, 0, 0, 30)
                skyBtn.Position = UDim2.new(0, 0, 0, yOffset)
                skyBtn.BackgroundColor3 = CONFIG.customColors.bgElevated
                skyBtn.Text = sky.name
                skyBtn.TextColor3 = CONFIG.customColors.textSecondary
                skyBtn.TextSize = 12
                skyBtn.Font = Enum.Font.Gotham
                skyBtn.Parent = skyContent
                
                local skyCorner = Instance.new("UICorner")
                skyCorner.CornerRadius = UDim.new(0, 6)
                skyCorner.Parent = skyBtn
                
                skyBtn.MouseButton1Click:Connect(function()
                    applySkybox(sky.id)
                end)
                
                yOffset = yOffset + 35
            end
        end
        
        yOffset = yOffset + 10
    end
    
    -- ============================================
    -- TAB: STATS (Conteúdo)
    -- ============================================
    local statsContent = tabContents.stats
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, 0, 0, 30)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "📊 ESTATÍSTICAS"
    statsTitle.TextColor3 = CONFIG.customColors.success
    statsTitle.TextSize = 18
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Parent = statsContent
    
    -- Labels de stats
    local statLabels = {}
    local statNames = {
        { key = "totalTouches", label = "Total Touches" },
        { key = "ballsTouched", label = "Bolas Tocadas" },
        { key = "toteKicks", label = "Chutes Tote" },
        { key = "morphsDone", label = "Morphs Realizados" },
        { key = "antiLagItems", label = "Itens Anti-Lag" },
        { key = "avgPing", label = "Ping Médio (ms)" },
        { key = "fps", label = "FPS Atual" },
        { key = "ballsInCache", label = "Bolas em Cache" }
    }
    
    for i, stat in ipairs(statNames) do
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(1, 0, 0, 35)
        statFrame.Position = UDim2.new(0, 0, 0, 35 + (i-1) * 40)
        statFrame.BackgroundColor3 = CONFIG.customColors.bgElevated
        statFrame.BorderSizePixel = 0
        statFrame.Parent = statsContent
        
        local statCorner = Instance.new("UICorner")
        statCorner.CornerRadius = UDim.new(0, 6)
        statCorner.Parent = statFrame
        
        local statLabel = Instance.new("TextLabel")
        statLabel.Size = UDim2.new(0.6, 0, 1, 0)
        statLabel.Position = UDim2.new(0, 10, 0, 0)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = stat.label .. ":"
        statLabel.TextColor3 = CONFIG.customColors.textSecondary
        statLabel.TextSize = 13
        statLabel.Font = Enum.Font.Gotham
        statLabel.TextXAlignment = Enum.TextXAlignment.Left
        statLabel.Parent = statFrame
        
        local statValue = Instance.new("TextLabel")
        statValue.Size = UDim2.new(0.4, -10, 1, 0)
        statValue.Position = UDim2.new(0.6, 0, 0, 0)
        statValue.BackgroundTransparency = 1
        statValue.Text = "0"
        statValue.TextColor3 = CONFIG.customColors.primary
        statValue.TextSize = 14
        statValue.Font = Enum.Font.GothamBold
        statValue.TextXAlignment = Enum.TextXAlignment.Right
        statValue.Parent = statFrame
        
        statLabels[stat.key] = statValue
    end
    
    -- Atualizador de stats
    task.spawn(function()
        while mainGui and mainGui.Parent do
            for key, label in pairs(statLabels) do
                pcall(function()
                    label.Text = tostring(STATS[key] or 0)
                end)
            end
            task.wait(1)
        end
    end)
    
    -- ============================================
    -- TAB: LOGS (Conteúdo)
    -- ============================================
    local logsContent = tabContents.logs
    
    local logsTitle = Instance.new("TextLabel")
    logsTitle.Size = UDim2.new(1, 0, 0, 30)
    logsTitle.BackgroundTransparency = 1
    logsTitle.Text = "📜 LOGS"
    logsTitle.TextColor3 = CONFIG.customColors.info
    logsTitle.TextSize = 18
    logsTitle.Font = Enum.Font.GothamBold
    logsTitle.TextXAlignment = Enum.TextXAlignment.Left
    logsTitle.Parent = logsContent
    
    -- Container de logs
    local logsContainer = Instance.new("ScrollingFrame")
    logsContainer.Size = UDim2.new(1, 0, 1, -35)
    logsContainer.Position = UDim2.new(0, 0, 0, 35)
    logsContainer.BackgroundTransparency = 1
    logsContainer.BorderSizePixel = 0
    logsContainer.ScrollBarThickness = 4
    logsContainer.ScrollBarImageColor3 = CONFIG.customColors.info
    logsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logsContainer.Parent = logsContent
    
    local logsListLayout = Instance.new("UIListLayout")
    logsListLayout.Padding = UDim.new(0, 5)
    logsListLayout.Parent = logsContainer
    
    -- Atualizador de logs
    task.spawn(function()
        while mainGui and mainGui.Parent do
            -- Limpa logs antigos
            for _, child in ipairs(logsContainer:GetChildren()) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
            
            -- Adiciona logs novos
            for _, log in ipairs(LOGS) do
                local logLabel = Instance.new("TextLabel")
                logLabel.Size = UDim2.new(1, -10, 0, 25)
                logLabel.BackgroundTransparency = 1
                logLabel.Text = "[" .. log.time .. "] " .. log.message
                logLabel.TextColor3 = (log.type == "error" and CONFIG.customColors.danger) or 
                                      (log.type == "success" and CONFIG.customColors.success) or 
                                      (log.type == "tote" and CONFIG.customColors.tote) or 
                                      CONFIG.customColors.textSecondary
                logLabel.TextSize = 11
                logLabel.Font = Enum.Font.Gotham
                logLabel.TextXAlignment = Enum.TextXAlignment.Left
                logLabel.TextWrapped = true
                logLabel.Parent = logsContainer
            end
            
            task.wait(0.5)
        end
    end)
    
    -- ============================================
    -- HANDLERS DOS BOTÕES DE CONTROLE
    -- ============================================
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tween(mainFrame, {Size = UDim2.new(0, CONFIG.width, 0, 60)}, 0.3)
            contentFrame.Visible = false
            sidebar.Visible = false
            minimizeBtn.Text = "+"
        else
            tween(mainFrame, {Size = UDim2.new(0, CONFIG.width, 0, CONFIG.height)}, 0.3)
            contentFrame.Visible = true
            sidebar.Visible = true
            minimizeBtn.Text = "−"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        isClosed = true
        tween(mainFrame, {Position = UDim2.new(0.5, -CONFIG.width/2, 1, 0)}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In, function()
            if mainGui then
                mainGui:Destroy()
                mainGui = nil
            end
            -- Cria ícone flutuante
            createFloatingIcon()
        end)
    end)
    
    -- Draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Animação de entrada
    mainFrame.Position = UDim2.new(0.5, -CONFIG.width/2, 1, 0)
    tween(mainFrame, {Position = UDim2.new(0.5, -CONFIG.width/2, 0.5, -CONFIG.height/2)}, 0.6, Enum.EasingStyle.Back)
    
    addLog("GUI Carregada - v16.3", "success")
end

-- Helper functions para criar elementos da UI
function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.customColors.textPrimary
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 26)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -13)
    toggleBtn.BackgroundColor3 = default and CONFIG.customColors.success or CONFIG.customColors.danger
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 13)
    toggleCorner.Parent = toggleBtn
    
    local enabled = default
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggleBtn.BackgroundColor3 = enabled and CONFIG.customColors.success or CONFIG.customColors.danger
        toggleBtn.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
    
    return frame
end

function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.customColors.textPrimary
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = CONFIG.customColors.primary
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 35)
    track.BackgroundColor3 = CONFIG.customColors.bgElevated
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.customColors.primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = CONFIG.customColors.textPrimary
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Interação
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * pos
        
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        valueLabel.Text = string.format("%.2f", value)
        
        callback(value)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return frame
end

function createDropdown(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.customColors.textPrimary
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, 0, 0, 35)
    dropdownBtn.Position = UDim2.new(0, 0, 0, 25)
    dropdownBtn.BackgroundColor3 = CONFIG.customColors.bgElevated
    dropdownBtn.Text = default
    dropdownBtn.TextColor3 = CONFIG.customColors.textPrimary
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.Parent = frame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdownBtn
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -35, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = CONFIG.customColors.textMuted
    arrow.TextSize = 12
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = dropdownBtn
    
    local expanded = false
    local optionsFrame = nil
    
    dropdownBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        arrow.Text = expanded and "▲" or "▼"
        
        if expanded then
            optionsFrame = Instance.new("Frame")
            optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
            optionsFrame.Position = UDim2.new(0, 0, 1, 5)
            optionsFrame.BackgroundColor3 = CONFIG.customColors.bgElevated
            optionsFrame.BorderSizePixel = 0
            optionsFrame.ZIndex = 10
            optionsFrame.Parent = dropdownBtn
            
            local optionsCorner = Instance.new("UICorner")
            optionsCorner.CornerRadius = UDim.new(0, 8)
            optionsCorner.Parent = optionsFrame
            
            for i, option in ipairs(options) do
                local optionBtn = Instance.new("TextButton")
                optionBtn.Size = UDim2.new(1, 0, 0, 30)
                optionBtn.Position = UDim2.new(0, 0, 0, (i-1) * 30)
                optionBtn.BackgroundTransparency = 1
                optionBtn.Text = option
                optionBtn.TextColor3 = CONFIG.customColors.textSecondary
                optionBtn.TextSize = 13
                optionBtn.Font = Enum.Font.Gotham
                optionBtn.ZIndex = 11
                optionBtn.Parent = optionsFrame
                
                optionBtn.MouseButton1Click:Connect(function()
                    dropdownBtn.Text = option
                    callback(option)
                    expanded = false
                    arrow.Text = "▼"
                    if optionsFrame then
                        optionsFrame:Destroy()
                        optionsFrame = nil
                    end
                end)
                
                optionBtn.MouseEnter:Connect(function()
                    optionBtn.BackgroundColor3 = CONFIG.customColors.bgGlass
                    optionBtn.BackgroundTransparency = 0.5
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    optionBtn.BackgroundTransparency = 1
                end)
            end
        else
            if optionsFrame then
                optionsFrame:Destroy()
                optionsFrame = nil
            end
        end
    end)
    
    return frame
end

function createFloatingIcon()
    if iconGui then
        pcall(function() iconGui:Destroy() end)
    end
    
    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CAFUXZ1_Icon"
    iconGui.ResetOnSpawn = false
    iconGui.Parent = CoreGui
    
    local iconButton = Instance.new("TextButton")
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
            tween(iconButton, {Position = UDim2.new(1, -70, 0.5, -30)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            task.wait(1)
            tween(iconButton, {Position = UDim2.new(1, -70, 0.5, -20)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            task.wait(1)
        end
    end)
    
    iconButton.MouseButton1Click:Connect(function()
        isClosed = false
        iconGui:Destroy()
        iconGui = nil
        createMainGUI()
    end)
end

-- ============================================
-- MAIN LOOP
-- ============================================
local function mainLoop()
    if loopRunning then return end
    loopRunning = true
    
    PingSystem:Init()
    ReachBypass:Init()
    ToteSystem:Init()
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        PingSystem:Update()
        updateBalls()
        autoTouch()
        
        -- Atualiza esferas visuais
        if reachSphere and HRP and HRP.Parent then
            pcall(function()
                reachSphere.Position = HRP.Position
            end)
        end
        
        if arthurSphere and HRP and HRP.Parent then
            pcall(function()
                arthurSphere.Position = HRP.Position
            end)
        end
    end)
    
    -- Cria GUI após intro
    task.delay(12, function()
        if not isClosed and not mainGui then
            createMainGUI()
        end
    end)
    
    addLog("Sistema iniciado - v16.3 DOUBLE TOUCH", "success")
    notifySuccess("✅ CAFUXZ1 Hub", "v16.3 DOUBLE TOUCH carregado!", 3)
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
createIntro()
mainLoop()

-- Cleanup ao respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HRP = newChar:WaitForChild("HumanoidRootPart", 5)
    
    -- Recria esferas se necessário
    if CONFIG.showReachSphere and not reachSphere then
        createReachSphere()
    end
end)

print([[
    ╔══════════════════════════════════════════╗
    ║         CAFUXZ1 Hub v16.3                ║
    ║      DOUBLE TOUCH - NO MAGNET            ║
    ╚══════════════════════════════════════════╝
    
    ✓ Reach Bypass (Sem Magnet)
    ✓ Double Touch Corrigido
    ✓ Tote System v3.0
    ✓ Ping Optimization
    ✓ Anti-Lag System
    
    Comandos:
    - [T] = Ativar Tote
]])
