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

-- ============================================
-- SERVIÇOS
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
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
-- CONFIGURAÇÕES v18.5 UNIFIED
-- ============================================
local CONFIG = {
    width = 680,
    height = 520,
    sidebarWidth = 110,

    reach = 15,
    showReachSphere = true,
    autoTouch = true,
    fullBodyTouch = true,
    autoSecondTouch = true,
    scanCooldown = 1.0,

    arthurSphere = {
        reach = 12,
        color = Color3.fromRGB(0, 255, 255),
        transparency = 0.7,
        material = Enum.Material.ForceField,
        pulseSpeed = 2
    },

    ballSystem = {
        enabled = true,
        color = Color3.fromRGB(255, 0, 0),
        material = Enum.Material.SmoothPlastic,
        reflectance = 0,
        removeTextures = true,
        snowEnabled = false,
        originalMaterials = {},
        -- SelectedBall Config
        selectionRange = 20,
        highlightColor = Color3.fromRGB(255, 255, 0),
        highlightTransparency = 0.3,
        trailEnabled = true,
        ballESP = true,
        espRange = 50
    },

    screenStretch = {
        enabled = false,
        scale = 0.65,
        removeTextures = true,
        optimizeMaterials = true,
        disableParticles = true,
        originalResolution = nil,
        cameraConnection = nil
    },

    antiLag = {
        enabled = false,
        textures = true,
        visualEffects = true,
        parts = true,
        particles = true,
        sky = true,
        fullBright = false
    },

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

    customColors = {
        primary = Color3.fromRGB(99, 102, 241),
        secondary = Color3.fromRGB(139, 92, 246),
        accent = Color3.fromRGB(14, 165, 233),
        success = Color3.fromRGB(34, 197, 94),
        danger = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11),
        info = Color3.fromRGB(59, 130, 246),
        ball = Color3.fromRGB(255, 200, 50),
        stretch = Color3.fromRGB(255, 215, 0),
        ping = Color3.fromRGB(0, 255, 200),

        bgDark = Color3.fromRGB(8, 8, 16),
        bgCard = Color3.fromRGB(20, 20, 35),
        bgElevated = Color3.fromRGB(35, 35, 55),
        bgGlass = Color3.fromRGB(15, 15, 28),

        textPrimary = Color3.fromRGB(252, 252, 255),
        textSecondary = Color3.fromRGB(180, 190, 220),
        textMuted = Color3.fromRGB(140, 150, 180),
    },

    ballNames = {
        "Ball", "SoccerBall", "Soccer", "Football", "Bola", "bola",
        "TPS", "TCS", "GameBall", "Hitbox", "HitBox",
        "BallTemplate", "PhysicsBall", "SportsBall",
        "GoalBall", "MatchBall", "PlayerBall",
        "BallPhysics", "BallControl", "DribbleBall",
        "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ",
        "Basketball", "Baseball", "Interaction", "Trigger", "Touch"
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
    avgPing = 0,
    currentPing = 0,
    fps = 60,
    ballsColored = 0,
    stretchBoost = 0,
    selectedBallName = "Nenhuma"
}

local LOGS = {}
local MAX_LOGS = 50

local function addLog(message, typeLog)
    typeLog = typeLog or "info"
    table.insert(LOGS, 1, {
        message = tostring(message),
        type = tostring(typeLog),
        time = os.date("%H:%M:%S"),
        timestamp = tick()
    })
    if #LOGS > MAX_LOGS then
        table.remove(LOGS)
    end
end

-- ============================================
-- PING SYSTEM
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
            self.FPS = math.floor(1 / math.max(deltaTime, 0.001))
            STATS.fps = self.FPS
        end)
    end,

    Update = function(self)
        local now = tick()
        if now - self.LastPingUpdate < 0.1 then
            return
        end
        self.LastPingUpdate = now

        local success, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)

        if success and ping then
            self.CurrentPing = ping
            STATS.currentPing = ping

            table.insert(self.History, 1, ping)
            if #self.History > 10 then
                table.remove(self.History)
            end

            local sum = 0
            for _, p in ipairs(self.History) do
                sum = sum + p
            end

            local newAverage = sum / #self.History

            if self.AveragePing > 0 then
                if newAverage > self.AveragePing * 1.2 then
                    self.PingTrend = "rising"
                elseif newAverage < self.AveragePing * 0.8 then
                    self.PingTrend = "falling"
                elseif math.abs(ping - self.AveragePing) > self.AveragePing * 0.5 then
                    self.PingTrend = "spike"
                else
                    self.PingTrend = "stable"
                end
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
        if not CONFIG.pingOptimization.adaptiveTiming then
            return baseDelay
        end
        local pingFactor = math.clamp(self.AveragePing / 100, 0.5, 2.0)
        return baseDelay * pingFactor
    end,

    IsHighLoad = function(self)
        return self.AveragePing > CONFIG.pingOptimization.highPingThreshold or self.FPS < 30
    end,

    IsCritical = function(self)
        return self.AveragePing > CONFIG.pingOptimization.criticalPingThreshold or self.FPS < 20
    end,

    GetEffectiveRange = function(self, baseRange)
        if not CONFIG.pingOptimization.enabled then
            return baseRange
        end
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
-- VARIÁVEIS GLOBAIS
-- ============================================
local balls = {}
local validBalls = {}
local selectedBall = nil
local previousBall = nil
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

local ballSystemActive = true
local snowActive = false
local snowData = {}
local processedBalls = {}

local Camera = Workspace.CurrentCamera
local stretchActive = false
local stretchConnection = nil

local viewportLoopRunning = false
local TAB_ORDER = {}

local skillButtonNames = {
    "Shoot", "Pass", "Long", "Tackle", "Dribble", "GK", "Throw",
    "Control", "Left", "Right", "High", "Low", "Rainbow",
    "Chip", "Heel", "Volley", "Back Right", "Back Left",
    "Carry", "Fake Shot", "Drag Back", "Header", "Bicycle",
    "Shot", "Slide", "Goalkeeper", "Catch", "Punch",
    "Short Pass", "Through Ball", "Cross", "Curve",
    "Power Shot", "Precision", "First Touch", "Sprint", "Jump",
    "Chute", "Passe", "Drible", "Controle", "Defender", "Save",
    "Curva", "Spin", "Finesse"
}

-- ============================================
-- BALL SYSTEM (SelectedBall + Detecção Avançada)
-- ============================================
local BallSystem = {
    SelectionGUI = nil,
    Highlight = nil,
    TrailAttachment = nil,
    InfoLabel = nil,
    
    IsValidBall = function(self, part)
        if not part or not part:IsA("BasePart") then return false end
        
        -- Verificar nome
        for _, ballName in ipairs(CONFIG.ballNames) do
            if part.Name:lower():find(ballName:lower()) then
                return true
            end
        end
        
        -- Verificação por forma esférica
        local size = part.Size
        local tolerance = 0.2
        local isSpherical = math.abs(size.X - size.Y) < tolerance 
                          and math.abs(size.Y - size.Z) < tolerance
                          and math.abs(size.X - size.Z) < tolerance
        
        local avgSize = (size.X + size.Y + size.Z) / 3
        if avgSize < 1 or avgSize > 10 then
            return false
        end
        
        return isSpherical
    end,
    
    CreateBallGUI = function(self)
        if self.SelectionGUI then return end
        
        local gui = Instance.new("BillboardGui")
        gui.Name = "CAFUXZ1_BallInfo"
        gui.Size = UDim2.new(0, 200, 0, 100)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = CONFIG.customColors.bgCard
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = gui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = CONFIG.customColors.ball
        stroke.Thickness = 2
        stroke.Parent = frame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -10, 0, 25)
        title.Position = UDim2.new(0, 5, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "⚽ BOLA SELECIONADA"
        title.TextColor3 = CONFIG.customColors.ball
        title.TextSize = 14
        title.Font = Enum.Font.GothamBold
        title.Parent = frame
        
        local info = Instance.new("TextLabel")
        info.Name = "InfoLabel"
        info.Size = UDim2.new(1, -10, 0, 60)
        info.Position = UDim2.new(0, 5, 0, 30)
        info.BackgroundTransparency = 1
        info.Text = "Distância: --m\nVelocidade: --"
        info.TextColor3 = CONFIG.customColors.textPrimary
        info.TextSize = 12
        info.Font = Enum.Font.Gotham
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Parent = frame
        
        self.SelectionGUI = gui
        self.InfoLabel = info
    end,
    
    UpdateBallGUI = function(self)
        if not CONFIG.ballSystem.ballESP or not selectedBall then
            if self.SelectionGUI and self.SelectionGUI.Parent then
                self.SelectionGUI.Enabled = false
            end
            return
        end
        
        self:CreateBallGUI()
        
        if not self.SelectionGUI.Parent then
            self.SelectionGUI.Parent = selectedBall
            self.SelectionGUI.Enabled = true
        elseif self.SelectionGUI.Parent ~= selectedBall then
            self.SelectionGUI.Parent = selectedBall
        end
        
        local dist = 0
        local velocity = Vector3.new(0, 0, 0)
        
        if HRP and HRP.Parent then
            dist = (selectedBall.Position - HRP.Position).Magnitude
        end
        
        if selectedBall:IsA("BasePart") then
            velocity = selectedBall.Velocity
        end
        
        local speed = math.floor(velocity.Magnitude * 100) / 100
        
        self.InfoLabel.Text = string.format(
            "📏 Distância: %.1fm\n⚡ Velocidade: %.1f\n📛 Nome: %s",
            dist, speed, selectedBall.Name
        )
    end,
    
    HighlightBall = function(self, ball)
        if self.Highlight and self.Highlight.Parent then
            self.Highlight:Destroy()
        end
        
        if not ball then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "CAFUXZ1_BallHighlight"
        highlight.Adornee = ball
        highlight.FillColor = CONFIG.ballSystem.highlightColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = CONFIG.ballSystem.highlightTransparency
        highlight.OutlineTransparency = 0
        highlight.Parent = ball
        
        self.Highlight = highlight
        
        if CONFIG.ballSystem.trailEnabled then
            self:CreateTrail(ball)
        end
    end,
    
    CreateTrail = function(self, ball)
        if self.TrailAttachment then
            self.TrailAttachment:Destroy()
        end
        
        local attachment = Instance.new("Attachment")
        attachment.Name = "CAFUXZ1_Trail"
        attachment.Position = Vector3.new(0, 0, 0)
        attachment.Parent = ball
        
        local trail = Instance.new("Trail")
        trail.Color = ColorSequence.new(CONFIG.ballSystem.highlightColor)
        trail.Transparency = NumberSequence.new(0.5)
        trail.Lifetime = 0.5
        trail.WidthScale = NumberSequence.new(0.2)
        trail.Parent = attachment
        
        local attachment2 = Instance.new("Attachment")
        attachment2.Position = Vector3.new(0, 0.1, 0)
        attachment2.Parent = ball
        
        trail.Attachment0 = attachment
        trail.Attachment1 = attachment2
        
        self.TrailAttachment = attachment
    end,
    
    SelectBall = function(self)
        if not HRP or not HRP.Parent then return end
        
        local hrpPos = HRP.Position
        local closestBall = nil
        local closestDist = CONFIG.ballSystem.selectionRange
        
        for _, ball in ipairs(validBalls) do
            if ball and ball.Parent then
                local dist = (ball.Position - hrpPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestBall = ball
                end
            end
        end
        
        -- Se não achou próxima, pegar a mais próxima do alcance total
        if not closestBall then
            closestDist = math.huge
            for _, ball in ipairs(validBalls) do
                if ball and ball.Parent then
                    local dist = (ball.Position - hrpPos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestBall = ball
                    end
                end
            end
        end
        
        if closestBall ~= selectedBall then
            previousBall = selectedBall
            selectedBall = closestBall
            
            if selectedBall then
                self:HighlightBall(selectedBall)
                STATS.selectedBallName = selectedBall.Name
                addLog("Bola selecionada: " .. selectedBall.Name, "info")
            else
                if self.Highlight then
                    self.Highlight:Destroy()
                end
                if self.SelectionGUI then
                    self.SelectionGUI.Enabled = false
                end
                STATS.selectedBallName = "Nenhuma"
            end
        end
    end,
    
    ScanBalls = function(self)
        -- Limpar listas
        for i = #balls, 1, -1 do
            balls[i] = nil
        end
        for i = #validBalls, 1, -1 do
            validBalls[i] = nil
        end
        
        local hrpPos = HRP and HRP.Position or Vector3.new(0, 0, 0)
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                -- Verificação de distância otimizada
                if (obj.Position - hrpPos).Magnitude < CONFIG.ballSystem.espRange then
                    if self:IsValidBall(obj) then
                        table.insert(balls, obj)
                        -- Verificar se está no alcance de interação
                        if (obj.Position - hrpPos).Magnitude <= CONFIG.reach * 1.5 then
                            table.insert(validBalls, obj)
                        end
                    end
                end
            end
        end
        
        self:SelectBall()
    end,
    
    TouchSelectedBall = function(self)
        if not CONFIG.autoTouch then return false end
        if not selectedBall or not selectedBall.Parent then return false end
        if not HRP or not HRP.Parent then return false end
        
        local dist = (selectedBall.Position - HRP.Position).Magnitude
        if dist <= CONFIG.reach then
            if CONFIG.fullBodyTouch then
                for _, part in ipairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            firetouchinterest(selectedBall, part, 0)
                            task.wait(0.01)
                            firetouchinterest(selectedBall, part, 1)
                            
                            if CONFIG.autoSecondTouch then
                                task.wait(0.03)
                                firetouchinterest(selectedBall, part, 0)
                                firetouchinterest(selectedBall, part, 1)
                            end
                        end)
                    end
                end
            else
                pcall(function()
                    firetouchinterest(selectedBall, HRP, 0)
                    task.wait(0.01)
                    firetouchinterest(selectedBall, HRP, 1)
                    
                    if CONFIG.autoSecondTouch then
                        task.wait(0.03)
                        firetouchinterest(selectedBall, HRP, 0)
                        firetouchinterest(selectedBall, HRP, 1)
                    end
                end)
            end
            STATS.totalTouches = STATS.totalTouches + 1
            return true
        end
        return false
    end,
    
    TouchOtherBalls = function(self)
        if not CONFIG.autoTouch then return end
        if not HRP or not HRP.Parent then return end
        
        local hrpPos = HRP.Position
        
        for _, ball in ipairs(validBalls) do
            if ball and ball.Parent and ball ~= selectedBall then
                local dist = (ball.Position - hrpPos).Magnitude
                if dist <= CONFIG.reach then
                    pcall(function()
                        firetouchinterest(ball, HRP, 0)
                        task.wait(0.01)
                        firetouchinterest(ball, HRP, 1)
                    end)
                    STATS.totalTouches = STATS.totalTouches + 1
                end
            end
        end
    end
}

-- ============================================
-- SISTEMA DE NOTIFICAÇÕES
-- ============================================
local NOTIF_CONFIG = {
    duration = 3,
    maxNotifications = 5,
    position = "right",
    offset = {x = 20, y = 100},
    animationSpeed = 0.5,
    soundEnabled = false
}

local activeNotifications = {}
local notifCounter = 0

local function tween(obj, props, time, style, dir, callback)
    if not obj or not obj.Parent then
        return nil
    end

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
        ball = {
            color = CONFIG.customColors.ball,
            icon = "⚽",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 150, 30))
            })
        },
        stretch = {
            color = CONFIG.customColors.stretch,
            icon = "📐",
            gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 170, 0))
            })
        }
    }

    local style = styles[notifType] or styles.info

    notifCounter = notifCounter + 1
    local notifId = "CAFUXZ1_Notif_" .. notifCounter .. "_" .. tostring(tick())

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = notifId
    notifGui.ResetOnSpawn = false
    notifGui.IgnoreGuiInset = true
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

    local yOffset = 0
    for _, existingNotif in ipairs(activeNotifications) do
        if existingNotif and existingNotif.Parent then
            yOffset = yOffset - 100
        end
    end

    tween(frame, {Position = UDim2.new(1, -360, 0.85, yOffset)}, 0.6, Enum.EasingStyle.Back)
    tween(progressBar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)

    table.insert(activeNotifications, 1, notifGui)

    while #activeNotifications > NOTIF_CONFIG.maxNotifications do
        local old = table.remove(activeNotifications)
        if old and old.Parent then
            old:Destroy()
        end
    end

    task.delay(duration, function()
        tween(frame, {
            Position = UDim2.new(1, 60, 0.85, yOffset),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In, function()
            for i,
            notif in ipairs(activeNotifications) do
                if notif == notifGui then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            if notifGui and notifGui.Parent then
                notifGui:Destroy()
            end
        end)
    end)

    return notifGui
end

local function notify(title, text, duration) advancedNotify(title, text, "info", duration or 3) end
local function notifySuccess(title, text, duration) advancedNotify(title, text, "success", duration or 3) end
local function notifyError(title, text, duration) advancedNotify(title, text, "error", duration or 3) end
local function notifyWarning(title, text, duration) advancedNotify(title, text, "warning", duration or 3) end
local function notifyBall(title, text, duration) advancedNotify(title, text, "ball", duration or 3) end
local function notifyStretch(title, text, duration) advancedNotify(title, text, "stretch", duration or 3) end

-- ============================================
-- RESPONSIVIDADE DE TELA
-- ============================================
local function getViewportSize()
    local cam = Workspace.CurrentCamera
    if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
        return cam.ViewportSize
    end
    return Vector2.new(1366, 768)
end

local function getResponsiveMetrics()
    local vp = getViewportSize()

    local width = math.floor(math.clamp(vp.X * 0.42, 540, CONFIG.width))
    local height = math.floor(math.clamp(vp.Y * 0.68, 400, CONFIG.height))

    if vp.X < 700 then
        width = math.floor(vp.X * 0.94)
    end

    if vp.Y < 560 then
        height = math.floor(vp.Y * 0.88)
    end

    width = math.min(width, vp.X - 12)
    height = math.min(height, vp.Y - 12)

    local sidebarWidth = math.floor(math.clamp(width * 0.16, 88, 110))

    local totalTabs = math.max(#TAB_ORDER, 8)
    local topStart = 100
    local bottomPadding = 12
    local availableHeight = math.max(260, height - topStart - bottomPadding)
    local gap = 6
    local tabHeight = math.floor(math.clamp((availableHeight - ((totalTabs - 1) * gap)) / totalTabs, 28, 40))

    local titleSize = width < 580 and 22 or 26
    local tabTextSize = width < 580 and 10 or 12
    local pingWidth = width < 580 and 100 or 130
    local pingTextSize = width < 580 and 11 or 13

    return {
        width = width,
        height = height,
        sidebarWidth = sidebarWidth,
        tabHeight = tabHeight,
        gap = gap,
        titleSize = titleSize,
        tabTextSize = tabTextSize,
        pingWidth = pingWidth,
        pingTextSize = pingTextSize
    }
end

local function applyResponsiveLayout()
    if not mainFrame or not mainFrame.Parent then
        return
    end

    local metrics = getResponsiveMetrics()

    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.Size = UDim2.fromOffset(metrics.width, metrics.height)

    local sidebar = mainFrame:FindFirstChild("Sidebar")
    local header = mainFrame:FindFirstChild("Header")

    if sidebar then
        sidebar.Size = UDim2.new(0, metrics.sidebarWidth, 1, 0)
    end

    if header then
        header.Position = UDim2.new(0, metrics.sidebarWidth, 0, 5)
        header.Size = UDim2.new(1, -metrics.sidebarWidth, 0, 60)

        local headerTitle = header:FindFirstChild("HeaderTitle")
        if headerTitle then
            headerTitle.TextSize = metrics.titleSize
        end

        local pingMonitor = header:FindFirstChild("PingMonitor")
        if pingMonitor then
            pingMonitor.Size = UDim2.new(0, metrics.pingWidth, 0, 30)
            pingMonitor.Position = UDim2.new(1, -(metrics.pingWidth + 20), 0, 15)
            pingMonitor.TextSize = metrics.pingTextSize
        end

        local minimizeBtn = header:FindFirstChild("MinimizeBtn")
        if minimizeBtn then
            minimizeBtn.Position = UDim2.new(1, -100, 0, 9)
        end

        local closeBtn = header:FindFirstChild("CloseBtn")
        if closeBtn then
            closeBtn.Position = UDim2.new(1, -50, 0, 9)
        end
    end

    if sidebar then
        local tabIndex = 0
        for _, obj in ipairs(sidebar:GetChildren()) do
            if obj:IsA("TextButton") and obj.Name:match("Btn$") then
                obj.Size = UDim2.new(0.9, 0, 0, metrics.tabHeight)
                obj.Position = UDim2.new(0.05, 0, 0, 100 + tabIndex * (metrics.tabHeight + metrics.gap))
                obj.TextSize = metrics.tabTextSize
                tabIndex = tabIndex + 1
            end
        end
    end

    for _, obj in ipairs(mainFrame:GetChildren()) do
        if obj:IsA("ScrollingFrame") and obj.Name:match("Content$") then
            obj.Position = UDim2.new(0, metrics.sidebarWidth + 10, 0, 70)
            obj.Size = UDim2.new(1, -(metrics.sidebarWidth + 20), 1, -80)
            obj.AutomaticCanvasSize = Enum.AutomaticSize.Y
            obj.CanvasSize = UDim2.new(0, 0, 0, 0)
        end
    end
end

local function startResponsiveLoop()
    if viewportLoopRunning then
        return
    end

    viewportLoopRunning = true
    task.spawn(function()
        while mainGui and mainGui.Parent do
            pcall(applyResponsiveLayout)
            task.wait(0.5)
        end
        viewportLoopRunning = false
    end)
end

-- ============================================
-- SCREEN STRETCH
-- ============================================
local function limparMapaStretch()
    local count = 0
    for _, objeto in pairs(Workspace:GetDescendants()) do
        if CONFIG.screenStretch.removeTextures then
            if objeto:IsA("Decal") or objeto:IsA("Texture") then
                objeto:Destroy()
                count = count + 1
            end
        end

        if CONFIG.screenStretch.optimizeMaterials then
            if objeto:IsA("BasePart") or objeto:IsA("MeshPart") or objeto:IsA("UnionOperation") then
                pcall(function()
                    objeto.Material = Enum.Material.SmoothPlastic
                    objeto.Reflectance = 0
                    if objeto:IsA("MeshPart") then
                        objeto.TextureID = ""
                    end
                end)
            end
        end

        if CONFIG.screenStretch.disableParticles then
            if objeto:IsA("ParticleEmitter") or objeto:IsA("Trail") or objeto:IsA("Smoke") then
                objeto.Enabled = false
            end
        end
    end
    return count
end

local function toggleScreenStretch(enabled)
    CONFIG.screenStretch.enabled = enabled
    stretchActive = enabled

    if enabled then
        local removedCount = limparMapaStretch()

        if not stretchConnection then
            stretchConnection = RunService.RenderStepped:Connect(function()
                if CONFIG.screenStretch.enabled and Camera then
                    local scale = CONFIG.screenStretch.scale
                    Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, scale, 0, 0, 0, 1)
                end
            end)
        end

        STATS.stretchBoost = math.floor((1 / CONFIG.screenStretch.scale) * 100)
        notifyStretch("📐 Stretch Ativado", "FPS Boost: +" .. STATS.stretchBoost .. "% | Texturas removidas: " .. removedCount, 4)
        addLog("Screen Stretch ATIVADO - Scale: " .. CONFIG.screenStretch.scale, "success")
    else
        if stretchConnection then
            stretchConnection:Disconnect()
            stretchConnection = nil
        end
        STATS.stretchBoost = 0
        notifyStretch("📐 Stretch Desativado", "Resolução normal restaurada", 3)
        addLog("Screen Stretch DESATIVADO", "warning")
    end
end

local function updateStretchScale(newScale)
    CONFIG.screenStretch.scale = newScale / 100
    if stretchActive then
        notifyStretch("📐 Escala Ajustada", "Nova escala: " .. newScale .. "% (FPS x" .. math.floor(1 / CONFIG.screenStretch.scale) .. ")", 2)
    end
end

-- ============================================
-- ANTI LAG
-- ============================================
local function saveOriginalState(obj, property, value)
    if not obj or typeof(obj) ~= "Instance" then
        return
    end
    if not originalStates[obj] then
        originalStates[obj] = {}
    end
    if originalStates[obj][property] == nil then
        originalStates[obj][property] = value
    end
end

local function applyAntiLag()
    if antiLagActive then
        return
    end
    antiLagActive = true

    local batchSize = 150
    local Stuff = {}

    local function processBatch(descendants, startIdx)
        local endIdx = math.min(startIdx + batchSize - 1, #descendants)

        for i = startIdx, endIdx do
            local v = descendants[i]
            if not v then
                continue
            end

            pcall(function()
                if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart")) then
                    saveOriginalState(v, "Material", v.Material)
                    v.Material = Enum.Material.SmoothPlastic
                    table.insert(Stuff, v)
                end

                if CONFIG.antiLag.particles and (v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire")) then
                    saveOriginalState(v, "Enabled", v.Enabled)
                    v.Enabled = false
                    table.insert(Stuff, v)
                end

                if CONFIG.antiLag.visualEffects and (v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect")) then
                    saveOriginalState(v, "Enabled", v.Enabled)
                    v.Enabled = false
                    table.insert(Stuff, v)
                end

                if CONFIG.antiLag.textures and (v:IsA("Decal") or v:IsA("Texture")) then
                    saveOriginalState(v, "Texture", v.Texture)
                    v.Texture = ""
                    table.insert(Stuff, v)
                end

                if CONFIG.antiLag.sky and v:IsA("Sky") then
                    saveOriginalState(v, "Parent", v.Parent)
                    v.Parent = nil
                    table.insert(Stuff, v)
                end
            end)
        end

        if endIdx < #descendants then
            task.wait()
            processBatch(descendants, endIdx + 1)
        else
            STATS.antiLagItems = #Stuff
            addLog("Anti Lag ATIVADO - " .. #Stuff .. " itens", "success")
            notifySuccess("🚀 Anti-Lag", #Stuff .. " objetos otimizados com sucesso!", 3)
        end
    end

    local allDescendants = game:GetDescendants()
    processBatch(allDescendants, 1)

    antiLagConnection = game.DescendantAdded:Connect(function(v)
        if not antiLagActive then
            return
        end
        task.wait(0.1)
        pcall(function()
            if CONFIG.antiLag.parts and (v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart")) then
                saveOriginalState(v, "Material", v.Material)
                v.Material = Enum.Material.SmoothPlastic
            end
        end)
    end)
end

local function disableAntiLag()
    if not antiLagActive then
        return
    end
    antiLagActive = false

    if antiLagConnection then
        pcall(function()
            antiLagConnection:Disconnect()
        end)
        antiLagConnection = nil
    end

    local states = {}
    for obj, props in pairs(originalStates) do
        if obj and typeof(obj) == "Instance" then
            table.insert(states, {obj = obj, props = props})
        end
    end

    local batchSize = 150
    local function restoreBatch(startIdx)
        local endIdx = math.min(startIdx + batchSize - 1, #states)

        for i = startIdx, endIdx do
            local data = states[i]
            local obj = data.obj
            if obj and (obj.Parent or data.props.Parent ~= nil) then
                for prop, value in pairs(data.props) do
                    pcall(function()
                        if prop == "Parent" then
                            obj.Parent = value
                        else
                            obj[prop] = value
                        end
                    end)
                end
            end
        end

        if endIdx < #states then
            task.wait()
            restoreBatch(endIdx + 1)
        else
            originalStates = {}
            STATS.antiLagItems = 0
            addLog("Anti Lag DESATIVADO", "warning")
            notifyWarning("⚠️ Anti-Lag", "Otimização desativada!", 3)
        end
    end

    if #states > 0 then
        restoreBatch(1)
    else
        originalStates = {}
        STATS.antiLagItems = 0
    end
end

-- ============================================
-- MORPH SYSTEM
-- ============================================
local PRESET_MORPHS = {
    {name = "Miguelcalebegamer202", userId = nil, displayName = "Miguelcalebegamer202"},
    {name = "Tottxii", userId = nil, displayName = "Tottxii"},
    {name = "Feliou23", userId = nil, displayName = "Feliou23 (cb)"},
    {name = "venxcore", userId = nil, displayName = "venxcore (cb)"},
    {name = "AlissonGkBe", userId = nil, displayName = "AlissonGkBe (extra,gk)"}
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
    notifySuccess("✨ Transformação Completa", "Você agora é: " .. tostring(targetName), 3)
    addLog("Morph: " .. tostring(targetName), "success")
end

-- ============================================
-- SKYBOX SYSTEM
-- ============================================
local SkyboxDatabase = {
    {id = 14828385099, name = "Night Sky With Moon HD", category = "Cosmos"},
    {id = 109488540432307, name = "Cosmic Sky A", category = "Cosmos"},
    {id = 109844440994380, name = "Cosmic Sky B", category = "Cosmos"},
    {id = 277098164, name = "Night/Space Classic", category = "Cosmos"},
    {id = 6681543281, name = "Deep Space", category = "Cosmos"},
    {id = 77407612452946, name = "Galaxy Nebula", category = "Cosmos"},
    {id = 2900944368, name = "Space/Sci-Fi Sky", category = "Atmosfera"},
    {id = 290982885, name = "Atmospheric Sky", category = "Atmosfera"},
    {id = 295604372, name = "Cloudy/Weather Sky", category = "Atmosfera"},
    {id = 17124418086, name = "Custom Sky A", category = "Custom"},
    {id = 17480150596, name = "Custom Sky B", category = "Custom"},
    {id = 16553683517, name = "Custom Sky C", category = "Custom"},
    {id = 264910951, name = "Vintage/Retro Sky", category = "Custom"},
    {id = 119314959302386, name = "Special Effect Sky", category = "Especial"},
}

local function ClearSkies()
    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then
                child:Destroy()
            end
        end
    end)
end

local function saveOriginalSkybox()
    if not originalSkybox then
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then
                originalSkybox = child:Clone()
                break
            end
        end
    end
end

local function ApplySkybox(assetId, skyName)
    if not assetId or assetId == 0 then
        return false
    end

    ClearSkies()

    local success = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        if objects and #objects > 0 then
            local source = objects[1]
            if source:IsA("Sky") then
                local sky = source:Clone()
                sky.Name = "CAFUXZ1_Sky_" .. tostring(assetId)
                sky.Parent = Lighting
                return true
            end

            if source:IsA("Model") or source:IsA("Folder") then
                for _, child in ipairs(source:GetDescendants()) do
                    if child:IsA("Sky") then
                        local sky = child:Clone()
                        sky.Name = "CAFUXZ1_Sky_" .. tostring(assetId)
                        sky.Parent = Lighting
                        source:Destroy()
                        return true
                    end
                end
                source:Destroy()
            end
        end
        return false
    end)

    if success then
        currentSkybox = assetId
        notify("☁️ Skybox Alterado", "Novo céu aplicado: " .. tostring(skyName), 2)
        addLog("Skybox aplicado: " .. tostring(skyName), "success")
        return true
    end

    success = pcall(function()
        local sky = Instance.new("Sky")
        sky.Name = "CAFUXZ1_Sky_Generic_" .. tostring(assetId)
        local url = "rbxassetid://" .. tostring(assetId)
        sky.SkyboxBk = url
        sky.SkyboxDn = url
        sky.SkyboxFt = url
        sky.SkyboxLf = url
        sky.SkyboxRt = url
        sky.SkyboxUp = url
        sky.Parent = Lighting
        return true
    end)

    if success then
        currentSkybox = assetId
        notify("☁️ Skybox Genérico", "Céu aplicado com sucesso!", 2)
        addLog("Skybox genérico aplicado", "success")
    end

    return success
end

local function restoreOriginalSkybox()
    ClearSkies()
    if originalSkybox and typeof(originalSkybox) == "Instance" then
        pcall(function()
            originalSkybox.Parent = Lighting
        end)
        originalSkybox = nil
    end
    currentSkybox = nil
    notify("ℹ️ Skybox", "Céu original restaurado", 2)
    addLog("Skybox restaurado", "info")
end

-- ============================================
-- BALL COLOR SYSTEM
-- ============================================
local function ehPersonagem(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid")
end

local function aplicarCorBola(p)
    if not p or not p.Parent then
        return
    end

    pcall(function()
        if p:IsA("MeshPart") then
            p.TextureID = ""
        end

        for _, m in ipairs(p:GetChildren()) do
            if m:IsA("SpecialMesh") then
                m.TextureId = ""
            end
        end

        if CONFIG.ballSystem.removeTextures then
            for _, d in ipairs(p:GetDescendants()) do
                if d:IsA("Decal") or d:IsA("Texture") then
                    d:Destroy()
                end
            end
        end

        p.Reflectance = CONFIG.ballSystem.reflectance
        p.Color = CONFIG.ballSystem.color
        p.Material = CONFIG.ballSystem.material

        processedBalls[p] = true
    end)
end

local function toggleSnow(enabled)
    if enabled then
        if next(snowData) then
            return
        end

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not ehPersonagem(v) and not BallSystem:IsValidBall(v) then
                snowData[v] = {Material = v.Material, Color = v.Color}
                v.Material = Enum.Material.Snow
                v.Color = Color3.fromRGB(240, 240, 240)
            end
        end

        snowActive = true
        notifyBall("❄️ Neve Ativada", "Mapa coberto de neve!", 3)
        addLog("Neve ativada", "success")
    else
        if not next(snowData) then
            return
        end

        for part, data in pairs(snowData) do
            if part and part.Parent then
                part.Material = data.Material
                part.Color = data.Color
            end
        end
        snowData = {}

        snowActive = false
        notifyBall("🌨️ Neve Desativada", "Mapa restaurado!", 3)
        addLog("Neve desativada", "warning")
    end
end

task.spawn(function()
    while true do
        if CONFIG.ballSystem.enabled then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if BallSystem:IsValidBall(v) and not processedBalls[v] then
                        aplicarCorBola(v)
                        STATS.ballsColored = STATS.ballsColored + 1
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        processedBalls = {}
    end
end)

-- ============================================
-- REACH SYSTEM
-- ============================================
local function updateCharacter()
    local newChar = LocalPlayer.Character
    if newChar then
        Character = newChar
        local newHRP = newChar:FindFirstChild("HumanoidRootPart")
        if newHRP then
            HRP = newHRP
        end
    end
end

local function createReachSphere()
    if reachSphere and reachSphere.Parent then
        return
    end

    pcall(function()
        reachSphere = Instance.new("Part")
        reachSphere.Name = "CAFUXZ1_ReachSphere_v185"
        reachSphere.Shape = Enum.PartType.Ball
        reachSphere.Anchored = true
        reachSphere.CanCollide = false
        reachSphere.Transparency = 0.88
        reachSphere.Material = Enum.Material.ForceField
        reachSphere.Color = CONFIG.customColors.primary
        reachSphere.Parent = Workspace
    end)
end

local function destroyReachSphere()
    if reachSphere then
        pcall(function()
            reachSphere:Destroy()
        end)
        reachSphere = nil
    end
end

local function createArthurSphere()
    if arthurSphere and arthurSphere.Parent then
        return
    end

    pcall(function()
        arthurSphere = Instance.new("Part")
        arthurSphere.Name = "CAFUXZ1_ArthurSphere_v185"
        arthurSphere.Shape = Enum.PartType.Ball
        arthurSphere.Anchored = true
        arthurSphere.CanCollide = false
        arthurSphere.Material = CONFIG.arthurSphere.material
        arthurSphere.Transparency = 1
        arthurSphere.Color = CONFIG.arthurSphere.color
        arthurSphere.Parent = Workspace
    end)
end

local function destroyArthurSphere()
    if arthurSphere then
        pcall(function()
            arthurSphere:Destroy()
        end)
        arthurSphere = nil
    end
end

local function updateBothSpheres()
    if not CONFIG.showReachSphere then
        destroyReachSphere()
        destroyArthurSphere()
        return
    end

    createReachSphere()
    createArthurSphere()

    if reachSphere and HRP and HRP.Parent then
        pcall(function()
            reachSphere.Position = HRP.Position
            local effectiveRange = PingSystem:GetEffectiveRange(CONFIG.reach)
            reachSphere.Size = Vector3.new(effectiveRange * 2, effectiveRange * 2, effectiveRange * 2)
            reachSphere.Color = CONFIG.customColors.primary
        end)
    end

    if arthurSphere and HRP and HRP.Parent then
        pcall(function()
            arthurSphere.Position = HRP.Position
            local effectiveRange = PingSystem:GetEffectiveRange(CONFIG.arthurSphere.reach)
            arthurSphere.Size = Vector3.new(effectiveRange * 2, effectiveRange * 2, effectiveRange * 2)
            arthurSphere.Color = CONFIG.arthurSphere.color
            
            local shouldShow = CONFIG.autoSecondTouch
            if shouldShow then
                local pulse = (math.sin(tick() * CONFIG.arthurSphere.pulseSpeed) + 1) / 2
                arthurSphere.Transparency = CONFIG.arthurSphere.transparency + (pulse * 0.1)
            else
                arthurSphere.Transparency = 1
            end
        end)
    end
end

local function destroyBothSpheres()
    destroyReachSphere()
    destroyArthurSphere()
end

local function setSpheresVisible(visible)
    CONFIG.showReachSphere = visible
    if not visible then
        destroyBothSpheres()
    else
        updateBothSpheres()
    end
    addLog("Esferas " .. (visible and "VISÍVEIS" or "OCULTAS"), "info")
end

-- ============================================
-- AUTO SKILLS
-- ============================================
local cachedSkillButtons = nil
local lastSkillCache = 0

local function findSkillButtons()
    local buttons = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        return buttons
    end

    pcall(function()
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and not gui.Name:match("CAFUXZ1") then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        for _, skillName in ipairs(skillButtonNames) do
                            local textOk = obj:IsA("TextButton") and obj.Text == skillName
                            if obj.Name == skillName or textOk then
                                table.insert(buttons, obj)
                                break
                            end
                        end
                    end
                end
            end
        end
    end)

    return buttons
end

local function activateSkillButton(button)
    if not button or not button.Parent then
        return
    end

    local key = tostring(button)
    if activatedSkills[key] and tick() - activatedSkills[key] < skillCooldown then
        return
    end
    activatedSkills[key] = tick()

    pcall(function()
        if button:IsA("GuiButton") then
            if button.MouseButton1Click then
                button.MouseButton1Click:Fire()
            end
            if button.Activated then
                button.Activated:Fire()
            end
            local oldColor = button.BackgroundColor3
            button.BackgroundColor3 = CONFIG.customColors.accent
            task.wait(0.1)
            if button and button.Parent then
                button.BackgroundColor3 = oldColor
            end
        end
    end)
end

local function processAutoSkills()
    if not autoSkills then
        return
    end

    local now = tick()
    if now - lastSkillCheck < skillCheckInterval then
        return
    end
    lastSkillCheck = now

    if now - lastSkillActivation < skillCooldown then
        return
    end

    if not cachedSkillButtons or now - lastSkillCache > 5 then
        cachedSkillButtons = findSkillButtons()
        lastSkillCache = now
    end

    if not HRP or not HRP.Parent then
        return
    end

    local hrpPos = HRP.Position
    local ballInRange = false

    for _, ball in ipairs(validBalls) do
        if ball and ball.Parent then
            local success, dist = pcall(function()
                return (ball.Position - hrpPos).Magnitude
            end)
            if success and dist and dist <= PingSystem:GetEffectiveRange(CONFIG.reach) then
                ballInRange = true
                break
            end
        end
    end

    if not ballInRange then
        return
    end

    lastSkillActivation = now

    local mainSkills = {"Shoot", "Pass", "Dribble", "Control", "Curva", "Spin", "Finesse"}
    for _, button in ipairs(cachedSkillButtons) do
        for _, mainSkill in ipairs(mainSkills) do
            local textOk = button:IsA("TextButton") and button.Text == mainSkill
            if button.Name == mainSkill or textOk then
                activateSkillButton(button)
                STATS.skillsActivated = STATS.skillsActivated + 1
                return
            end
        end
    end
end

-- ============================================
-- INTERFACE RESPONSIVA v18.5
-- ============================================
local function createWindUI()
    local success, uiError = pcall(function()
        local existing = CoreGui:FindFirstChild("CAFUXZ1_Hub_v185")
        if existing then
            existing:Destroy()
        end

        isClosed = false

        local metrics = getResponsiveMetrics()

        mainGui = Instance.new("ScreenGui")
        mainGui.Name = "CAFUXZ1_Hub_v185"
        mainGui.ResetOnSpawn = false
        mainGui.IgnoreGuiInset = true
        mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainGui.Parent = CoreGui

        mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.fromOffset(metrics.width, metrics.height)
        mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        mainFrame.Position = UDim2.fromScale(0.5, 0.5)
        mainFrame.BackgroundColor3 = CONFIG.customColors.bgGlass
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.BorderSizePixel = 0
        mainFrame.ClipsDescendants = true
        mainFrame.Parent = mainGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 20)
        corner.Parent = mainFrame

        local stroke = Instance.new("UIStroke")
        stroke.Color = CONFIG.customColors.primary
        stroke.Thickness = 3
        stroke.Transparency = 0.3
        stroke.Parent = mainFrame

        local sidebar = Instance.new("Frame")
        sidebar.Name = "Sidebar"
        sidebar.Size = UDim2.new(0, metrics.sidebarWidth, 1, 0)
        sidebar.BackgroundColor3 = CONFIG.customColors.bgCard
        sidebar.BackgroundTransparency = 0.15
        sidebar.BorderSizePixel = 0
        sidebar.Parent = mainFrame

        local sidebarCorner = Instance.new("UICorner")
        sidebarCorner.CornerRadius = UDim.new(0, 20)
        sidebarCorner.Parent = sidebar

        local logoContainer = Instance.new("Frame")
        logoContainer.Size = UDim2.new(1, 0, 0, 90)
        logoContainer.BackgroundTransparency = 1
        logoContainer.Parent = sidebar

        local logoIcon = Instance.new("TextLabel")
        logoIcon.Size = UDim2.new(1, 0, 0, 60)
        logoIcon.Position = UDim2.new(0, 0, 0, 10)
        logoIcon.BackgroundTransparency = 1
        logoIcon.Text = "⚡"
        logoIcon.TextColor3 = CONFIG.customColors.primary
        logoIcon.TextSize = 40
        logoIcon.Font = Enum.Font.GothamBlack
        logoIcon.Parent = logoContainer

        local logoText = Instance.new("TextLabel")
        logoText.Size = UDim2.new(1, 0, 0, 25)
        logoText.Position = UDim2.new(0, 0, 0, 65)
        logoText.BackgroundTransparency = 1
        logoText.Text = "v18.5"
        logoText.TextColor3 = CONFIG.customColors.ball
        logoText.TextSize = 13
        logoText.Font = Enum.Font.GothamBold
        logoText.Parent = logoContainer

        local tabs = {
            {name = "reach", icon = "⚽", label = "Reach"},
            {name = "ball", icon = "🎯", label = "Ball"},
            {name = "stretch", icon = "📐", label = "Stretch"},
            {name = "visual", icon = "👁️", label = "Visual"},
            {name = "char", icon = "👤", label = "Char"},
            {name = "sky", icon = "☁️", label = "Sky"},
            {name = "config", icon = "⚙️", label = "Config"},
            {name = "stats", icon = "📊", label = "Stats"}
        }

        TAB_ORDER = tabs

        local tabButtons = {}
        local contentFrames = {}

        for i, tab in ipairs(tabs) do
            local btn = Instance.new("TextButton")
            btn.Name = tab.name .. "Btn"
            btn.Size = UDim2.new(0.9, 0, 0, metrics.tabHeight)
            btn.Position = UDim2.new(0.05, 0, 0, 100 + (i - 1) * (metrics.tabHeight + metrics.gap))
            btn.BackgroundColor3 = CONFIG.customColors.bgElevated
            btn.BackgroundTransparency = 0.7
            btn.Text = tab.icon .. " " .. tab.label
            btn.TextColor3 = CONFIG.customColors.textSecondary
            btn.TextSize = metrics.tabTextSize
            btn.Font = Enum.Font.GothamBold
            btn.Parent = sidebar

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 12)
            btnCorner.Parent = btn

            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.Size = UDim2.new(0, 4, 0.5, 0)
            indicator.Position = UDim2.new(0, 0, 0.25, 0)
            indicator.BackgroundColor3 = tab.name == "ball" and CONFIG.customColors.ball or CONFIG.customColors.primary
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = btn

            tabButtons[tab.name] = btn

            local content = Instance.new("ScrollingFrame")
            content.Name = tab.name .. "Content"
            content.Size = UDim2.new(1, -(metrics.sidebarWidth + 20), 1, -80)
            content.Position = UDim2.new(0, metrics.sidebarWidth + 10, 0, 70)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.ScrollBarThickness = 6
            content.ScrollBarImageColor3 = CONFIG.customColors.primary
            content.Visible = false
            content.AutomaticCanvasSize = Enum.AutomaticSize.Y
            content.CanvasSize = UDim2.new(0, 0, 0, 0)
            content.Parent = mainFrame

            local pad = Instance.new("UIPadding")
            pad.PaddingBottom = UDim.new(0, 16)
            pad.PaddingTop = UDim.new(0, 4)
            pad.PaddingLeft = UDim.new(0, 4)
            pad.PaddingRight = UDim.new(0, 4)
            pad.Parent = content

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 12)
            layout.Parent = content

            contentFrames[tab.name] = content
        end

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, -(metrics.sidebarWidth), 0, 60)
        header.Position = UDim2.new(0, metrics.sidebarWidth, 0, 5)
        header.BackgroundTransparency = 1
        header.Parent = mainFrame

        local headerTitle = Instance.new("TextLabel")
        headerTitle.Name = "HeaderTitle"
        headerTitle.Size = UDim2.new(0.5, 0, 1, 0)
        headerTitle.Position = UDim2.new(0, 20, 0, 0)
        headerTitle.BackgroundTransparency = 1
        headerTitle.Text = "CAFUXZ1 Hub"
        headerTitle.TextColor3 = CONFIG.customColors.textPrimary
        headerTitle.TextSize = metrics.titleSize
        headerTitle.Font = Enum.Font.GothamBlack
        headerTitle.TextXAlignment = Enum.TextXAlignment.Left
        headerTitle.Parent = header

        local pingMonitor = Instance.new("TextLabel")
        pingMonitor.Name = "PingMonitor"
        pingMonitor.Size = UDim2.new(0, metrics.pingWidth, 0, 30)
        pingMonitor.Position = UDim2.new(1, -(metrics.pingWidth + 20), 0, 15)
        pingMonitor.BackgroundColor3 = CONFIG.customColors.bgElevated
        pingMonitor.BackgroundTransparency = 0.4
        pingMonitor.Text = "📶 -- ms"
        pingMonitor.TextColor3 = CONFIG.customColors.ping
        pingMonitor.TextSize = metrics.pingTextSize
        pingMonitor.Font = Enum.Font.GothamBold
        pingMonitor.Parent = header

        local pingCorner = Instance.new("UICorner")
        pingCorner.CornerRadius = UDim.new(0, 10)
        pingCorner.Parent = pingMonitor

        task.spawn(function()
            while mainGui and mainGui.Parent do
                local iconPing, colorPing = PingSystem:GetStatusVisuals()
                pingMonitor.Text = iconPing .. " " .. tostring(math.floor(PingSystem.AveragePing)) .. " ms"
                pingMonitor.TextColor3 = colorPing
                task.wait(0.5)
            end
        end)

        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Name = "MinimizeBtn"
        minimizeBtn.Size = UDim2.new(0, 42, 0, 42)
        minimizeBtn.Position = UDim2.new(1, -100, 0, 9)
        minimizeBtn.BackgroundColor3 = CONFIG.customColors.warning
        minimizeBtn.Text = "−"
        minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
        minimizeBtn.TextSize = 28
        minimizeBtn.Font = Enum.Font.GothamBold
        minimizeBtn.Parent = header

        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 12)
        minCorner.Parent = minimizeBtn

        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseBtn"
        closeBtn.Size = UDim2.new(0, 42, 0, 42)
        closeBtn.Position = UDim2.new(1, -50, 0, 9)
        closeBtn.BackgroundColor3 = CONFIG.customColors.danger
        closeBtn.Text = "×"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 28
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = header

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 12)
        closeCorner.Parent = closeBtn

        -- =========================
        -- HELPERS DE UI
        -- =========================
        local function createSection(parent, title, accentColor)
            accentColor = accentColor or CONFIG.customColors.primary

            local section = Instance.new("Frame")
            section.Size = UDim2.new(0.96, 0, 0, 0)
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.BackgroundColor3 = CONFIG.customColors.bgCard
            section.BackgroundTransparency = 0.25
            section.BorderSizePixel = 0
            section.Parent = parent

            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 14)
            sectionCorner.Parent = section

            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Color = accentColor
            sectionStroke.Thickness = 1.5
            sectionStroke.Transparency = 0.6
            sectionStroke.Parent = section

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, -20, 0, 35)
            sectionTitle.Position = UDim2.new(0, 10, 0, 10)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = "◆ " .. tostring(title)
            sectionTitle.TextColor3 = accentColor
            sectionTitle.TextSize = 16
            sectionTitle.Font = Enum.Font.GothamBlack
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = section

            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, -20, 0, 0)
            sectionContent.Position = UDim2.new(0, 10, 0, 45)
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.BackgroundTransparency = 1
            sectionContent.BorderSizePixel = 0
            sectionContent.Parent = section

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Padding = UDim.new(0, 10)
            sectionLayout.Parent = sectionContent

            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingBottom = UDim.new(0, 12)
            sectionPadding.Parent = sectionContent

            return section, sectionContent
        end

        local function createInfoBox(parent, text, color, textSize)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(1, 0, 0, 0)
            box.AutomaticSize = Enum.AutomaticSize.Y
            box.BackgroundColor3 = CONFIG.customColors.bgElevated
            box.BackgroundTransparency = 0.35
            box.BorderSizePixel = 0
            box.Parent = parent

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 12)
            boxCorner.Parent = box

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -18, 0, 0)
            label.Position = UDim2.new(0, 9, 0, 8)
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = color or CONFIG.customColors.textSecondary
            label.TextSize = textSize or 13
            label.Font = Enum.Font.Gotham
            label.TextWrapped = true
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.Parent = box

            return box
        end

        local function createButton(parent, text, color, callback, icon)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 48)
            btn.BackgroundColor3 = color or CONFIG.customColors.primary
            btn.Text = (icon or "") .. " " .. tostring(text)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 15
            btn.Font = Enum.Font.GothamBold
            btn.Parent = parent

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 12)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)

            return btn
        end

        local function createToggle(parent, text, default, callback, accent)
            accent = accent or CONFIG.customColors.success

            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 45)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = parent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.65, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = tostring(text)
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 65, 0, 34)
            toggleBtn.Position = UDim2.new(1, -65, 0.5, -17)
            toggleBtn.BackgroundColor3 = default and accent or CONFIG.customColors.bgElevated
            toggleBtn.Text = default and "ON" or "OFF"
            toggleBtn.TextColor3 = Color3.new(1, 1, 1)
            toggleBtn.TextSize = 14
            toggleBtn.Font = Enum.Font.GothamBold
            toggleBtn.Parent = toggleFrame

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 17)
            toggleCorner.Parent = toggleBtn

            local enabled = default

            toggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                toggleBtn.BackgroundColor3 = enabled and accent or CONFIG.customColors.bgElevated
                toggleBtn.Text = enabled and "ON" or "OFF"
                if callback then
                    callback(enabled)
                end
            end)

            return toggleFrame, toggleBtn
        end

        local function createSlider(parent, labelText, min, max, default, callback, accent)
            accent = accent or CONFIG.customColors.primary

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 65)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 0, 22)
            label.BackgroundTransparency = 1
            label.Text = tostring(labelText)
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.3, 0, 0, 22)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = accent
            valueLabel.TextSize = 16
            valueLabel.Font = Enum.Font.GothamBlack
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = frame

            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, 0, 0, 10)
            sliderBg.Position = UDim2.new(0, 0, 0, 32)
            sliderBg.BackgroundColor3 = CONFIG.customColors.bgElevated
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = frame

            local sliderBgCorner = Instance.new("UICorner")
            sliderBgCorner.CornerRadius = UDim.new(0, 5)
            sliderBgCorner.Parent = sliderBg

            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBg

            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(0, 5)
            sliderFillCorner.Parent = sliderFill

            local dragging = false

            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (pos * (max - min)))

                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = tostring(value)

                if callback then
                    callback(value)
                end
            end

            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return frame
        end

        local function createCycleDropdown(parent, labelText, options, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 22)
            label.BackgroundTransparency = 1
            label.Text = tostring(labelText)
            label.TextColor3 = CONFIG.customColors.textSecondary
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local index = 1
            for i, option in ipairs(options) do
                if option == default then
                    index = i
                    break
                end
            end

            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(1, 0, 0, 42)
            dropdown.Position = UDim2.new(0, 0, 0, 28)
            dropdown.BackgroundColor3 = CONFIG.customColors.bgElevated
            dropdown.Text = tostring(options[index]) .. "  ▼"
            dropdown.TextColor3 = CONFIG.customColors.textPrimary
            dropdown.TextSize = 14
            dropdown.Font = Enum.Font.GothamBold
            dropdown.Parent = frame

            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 10)
            dropdownCorner.Parent = dropdown

            dropdown.MouseButton1Click:Connect(function()
                index = index + 1
                if index > #options then
                    index = 1
                end
                dropdown.Text = tostring(options[index]) .. "  ▼"
                if callback then
                    callback(options[index])
                end
            end)

            return frame
        end

        local function createTextInput(parent, placeholder)
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(1, 0, 0, 45)
            input.BackgroundColor3 = CONFIG.customColors.bgElevated
            input.Text = ""
            input.PlaceholderText = placeholder or "Digite aqui..."
            input.PlaceholderColor3 = CONFIG.customColors.textMuted
            input.TextColor3 = CONFIG.customColors.textPrimary
            input.TextSize = 14
            input.Font = Enum.Font.Gotham
            input.ClearTextOnFocus = false
            input.Parent = parent

            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 12)
            inputCorner.Parent = input

            return input
        end

        -- =========================
        -- ABA REACH
        -- =========================
        local reachSection, reachContent = createSection(contentFrames.reach, "Configurações de Reach", CONFIG.customColors.primary)

        createToggle(reachContent, "Auto Touch", CONFIG.autoTouch, function(val)
            CONFIG.autoTouch = val
            notify(val and "✅ Auto Touch ON" or "⚠️ Auto Touch OFF", val and "Sistema de toque automático ativado!" or "Toque automático desativado.", 2)
        end)

        createToggle(reachContent, "Full Body Touch", CONFIG.fullBodyTouch, function(val)
            CONFIG.fullBodyTouch = val
        end)

        createToggle(reachContent, "Double Touch (Arthur)", CONFIG.autoSecondTouch, function(val)
            CONFIG.autoSecondTouch = val
            updateBothSpheres()
        end, CONFIG.arthurSphere.color)

        createToggle(reachContent, "Mostrar Esferas", CONFIG.showReachSphere, function(val)
            setSpheresVisible(val)
        end)

        createToggle(reachContent, "Auto Skills", autoSkills, function(val)
            autoSkills = val
        end)

        createSlider(reachContent, "Alcance Principal", 5, 100, CONFIG.reach, function(val)
            CONFIG.reach = val
        end)

        createSlider(reachContent, "Alcance Arthur", 1, 150, CONFIG.arthurSphere.reach, function(val)
            CONFIG.arthurSphere.reach = val
        end, CONFIG.arthurSphere.color)

        createInfoBox(reachContent, "Use valores médios para ficar mais estável. Alcance exagerado pode deixar o comportamento estranho em alguns jogos.", CONFIG.customColors.textMuted, 12)

        -- =========================
        -- ABA BALL (SelectedBall + Color)
        -- =========================
        local ballSection, ballContent = createSection(contentFrames.ball, "SelectedBall System", CONFIG.customColors.ball)

        createToggle(ballContent, "Auto Touch Prioritário", true, function(val)
            CONFIG.autoTouch = val
        end, CONFIG.customColors.ball)

        createToggle(ballContent, "Mostrar Info da Bola (ESP)", true, function(val)
            CONFIG.ballSystem.ballESP = val
            if not val and BallSystem.SelectionGUI then
                BallSystem.SelectionGUI.Enabled = false
            end
        end, CONFIG.customColors.ball)

        createToggle(ballContent, "Highlight na Bola", true, function(val)
            if not val and BallSystem.Highlight then
                BallSystem.Highlight:Destroy()
            end
        end, CONFIG.customColors.ball)

        createToggle(ballContent, "Trail/Rastro", true, function(val)
            CONFIG.ballSystem.trailEnabled = val
        end, CONFIG.customColors.ball)

        createSlider(ballContent, "Range de Seleção", 5, 100, CONFIG.ballSystem.selectionRange, function(val)
            CONFIG.ballSystem.selectionRange = val
        end, CONFIG.customColors.ball)

        createSlider(ballContent, "Range ESP", 20, 200, CONFIG.ballSystem.espRange, function(val)
            CONFIG.ballSystem.espRange = val
        end, CONFIG.customColors.ball)

        -- Ball Color Section
        local colorSection, colorContent = createSection(contentFrames.ball, "Ball Color System", CONFIG.customColors.ball)

        createToggle(colorContent, "Ativar Coloração", CONFIG.ballSystem.enabled, function(val)
            CONFIG.ballSystem.enabled = val
            ballSystemActive = val
            if val then
                processedBalls = {}
            end
        end, CONFIG.customColors.ball)

        createToggle(colorContent, "Remover Texturas", CONFIG.ballSystem.removeTextures, function(val)
            CONFIG.ballSystem.removeTextures = val
            processedBalls = {}
        end)

        local colorPresets = {
            {name = "🔴 Vermelho", color = Color3.fromRGB(255, 0, 0)},
            {name = "🔵 Azul", color = Color3.fromRGB(0, 0, 255)},
            {name = "🟢 Verde", color = Color3.fromRGB(0, 255, 0)},
            {name = "🟡 Amarelo", color = Color3.fromRGB(255, 255, 0)},
            {name = "🟣 Roxo", color = Color3.fromRGB(128, 0, 128)},
            {name = "🟠 Laranja", color = Color3.fromRGB(255, 165, 0)},
            {name = "⚪ Branco", color = Color3.fromRGB(255, 255, 255)},
            {name = "⚫ Preto", color = Color3.fromRGB(0, 0, 0)},
        }

        for _, preset in ipairs(colorPresets) do
            createButton(colorContent, preset.name, preset.color, function()
                CONFIG.ballSystem.color = preset.color
                processedBalls = {}
                notifyBall("🎨 Cor Alterada", "Nova cor aplicada: " .. preset.name, 2)
            end)
        end

        createButton(colorContent, "Toggle Neve", Color3.fromRGB(220, 220, 255), function()
            snowActive = not snowActive
            toggleSnow(snowActive)
        end, "❄️")

        -- =========================
        -- ABA STRETCH
        -- =========================
        local stretchSection, stretchContent = createSection(contentFrames.stretch, "Screen Stretch System", CONFIG.customColors.stretch)

        createToggle(stretchContent, "Ativar Stretch", CONFIG.screenStretch.enabled, function(val)
            toggleScreenStretch(val)
        end, CONFIG.customColors.stretch)

        createToggle(stretchContent, "Remover Texturas", CONFIG.screenStretch.removeTextures, function(val)
            CONFIG.screenStretch.removeTextures = val
        end, CONFIG.customColors.stretch)

        createToggle(stretchContent, "Otimizar Materiais", CONFIG.screenStretch.optimizeMaterials, function(val)
            CONFIG.screenStretch.optimizeMaterials = val
        end, CONFIG.customColors.stretch)

        createToggle(stretchContent, "Desativar Partículas", CONFIG.screenStretch.disableParticles, function(val)
            CONFIG.screenStretch.disableParticles = val
        end, CONFIG.customColors.stretch)

        createSlider(stretchContent, "Escala de Resolução", 30, 100, math.floor(CONFIG.screenStretch.scale * 100), function(val)
            updateStretchScale(val)
        end, CONFIG.customColors.stretch)

        local stretchPresets = {
            {name = "Ultra FPS (40%)", scale = 40},
            {name = "Alto FPS (55%)", scale = 55},
            {name = "Padrão (65%)", scale = 65},
            {name = "Qualidade (85%)", scale = 85},
        }

        for _, preset in ipairs(stretchPresets) do
            createButton(stretchContent, preset.name, CONFIG.customColors.stretch, function()
                CONFIG.screenStretch.scale = preset.scale / 100
                if stretchActive then
                    notifyStretch("📐 Preset Aplicado", preset.name .. " ativado!", 3)
                else
                    notifyStretch("⚠️ Atenção", "Ative o Stretch primeiro!", 3)
                end
            end)
        end

        createInfoBox(stretchContent, "Quanto menor a escala, mais FPS. Em telas pequenas ele continua visível, mas o desempenho tende a melhorar bastante.", CONFIG.customColors.textMuted, 12)

        -- =========================
        -- ABA VISUAL
        -- =========================
        local visualSection, visualContent = createSection(contentFrames.visual, "Anti-Lag & Visual", CONFIG.customColors.accent)

        createToggle(visualContent, "Ativar Anti-Lag", CONFIG.antiLag.enabled, function(val)
            CONFIG.antiLag.enabled = val
            if val then
                applyAntiLag()
            else
                disableAntiLag()
            end
        end, CONFIG.customColors.success)

        createToggle(visualContent, "Full Bright", CONFIG.antiLag.fullBright, function(val)
            CONFIG.antiLag.fullBright = val
            if val then
                Lighting.Brightness = 10
                Lighting.GlobalShadows = false
            else
                Lighting.Brightness = 2
                Lighting.GlobalShadows = true
            end
        end, CONFIG.customColors.warning)

        createToggle(visualContent, "Ping Optimization", CONFIG.pingOptimization.enabled, function(val)
            CONFIG.pingOptimization.enabled = val
        end, CONFIG.customColors.ping)

        createInfoBox(visualContent, "Anti-Lag tenta simplificar partes, partículas, texturas e efeitos. Em alguns mapas a aparência pode mudar bastante.", CONFIG.customColors.textMuted, 12)

        -- =========================
        -- ABA CHAR
        -- =========================
        local charSection, charContent = createSection(contentFrames.char, "Morph Avatar", CONFIG.customColors.secondary)

        local usernameInput = createTextInput(charContent, "Digite o username...")

        createButton(charContent, "Aplicar Morph", CONFIG.customColors.primary, function()
            local username = usernameInput.Text
            if username and username ~= "" then
                task.spawn(function()
                    local userId
                    local successUser = pcall(function()
                        userId = Players:GetUserIdFromNameAsync(username)
                    end)

                    if successUser and userId then
                        morphToUser(userId, username)
                    else
                        notifyError("❌ Erro", "Usuário não encontrado!", 3)
                    end
                end)
            else
                notifyWarning("⚠️ Morph", "Digite um username primeiro.", 2)
            end
        end, "👤")

        for _, preset in ipairs(PRESET_MORPHS) do
            createButton(charContent, preset.displayName, CONFIG.customColors.bgElevated, function()
                if preset.userId then
                    morphToUser(preset.userId, preset.displayName)
                else
                    notifyWarning("⚠️ Morph", "Preset ainda carregando...", 2)
                end
            end, "✨")
        end

        -- =========================
        -- ABA SKY
        -- =========================
        local skyCategories = {}
        for _, sky in ipairs(SkyboxDatabase) do
            skyCategories[sky.category] = skyCategories[sky.category] or {}
            table.insert(skyCategories[sky.category], sky)
        end

        local catColors = {
            Cosmos = Color3.fromRGB(0, 120, 255),
            Atmosfera = Color3.fromRGB(0, 200, 100),
            Custom = Color3.fromRGB(255, 170, 0),
            Especial = Color3.fromRGB(180, 0, 220)
        }

        for categoryName, items in pairs(skyCategories) do
            local skySection, skyContent = createSection(contentFrames.sky, "Skybox - " .. categoryName, catColors[categoryName] or CONFIG.customColors.accent)
            for _, sky in ipairs(items) do
                createButton(skyContent, sky.name, catColors[categoryName] or CONFIG.customColors.accent, function()
                    saveOriginalSkybox()
                    ApplySkybox(sky.id, sky.name)
                end, "☁️")
            end
        end

        local skyControlSection, skyControlContent = createSection(contentFrames.sky, "Controles", CONFIG.customColors.danger)
        createButton(skyControlContent, "Resetar Skybox", CONFIG.customColors.danger, function()
            restoreOriginalSkybox()
        end, "↩️")

        -- =========================
        -- ABA CONFIG
        -- =========================
        local configSection, configContent = createSection(contentFrames.config, "Configurações Gerais", CONFIG.customColors.primary)

        createSlider(configContent, "Reach Scan Cooldown x10", 1, 30, math.floor(CONFIG.scanCooldown * 10), function(val)
            CONFIG.scanCooldown = val / 10
        end, CONFIG.customColors.primary)

        createSlider(configContent, "Ping Buffer x10", 5, 30, math.floor(CONFIG.pingOptimization.pingBufferMultiplier * 10), function(val)
            CONFIG.pingOptimization.pingBufferMultiplier = val / 10
        end, CONFIG.customColors.ping)

        createSlider(configContent, "Cor Primária (R)", 0, 255, math.floor(CONFIG.customColors.primary.R * 255), function(val)
            CONFIG.customColors.primary = Color3.fromRGB(val, math.floor(CONFIG.customColors.primary.G * 255), math.floor(CONFIG.customColors.primary.B * 255))
        end, CONFIG.customColors.primary)

        createButton(configContent, "Resetar Configurações", CONFIG.customColors.warning, function()
            CONFIG.reach = 15
            CONFIG.arthurSphere.reach = 12
            CONFIG.screenStretch.scale = 0.65
            CONFIG.scanCooldown = 1.0
            CONFIG.pingOptimization.pingBufferMultiplier = 1.5
            notifySuccess("🔄 Reset", "Configurações padrão restauradas!", 3)
        end, "🔄")

        -- =========================
        -- ABA STATS
        -- =========================
        local statsLabels = {}
        local statsSection, statsContent = createSection(contentFrames.stats, "Estatísticas", CONFIG.customColors.info)

        local statItems = {
            {k = "totalTouches", l = "Total de Toques", icon = "👆"},
            {k = "ballsTouched", l = "Bolas Tocadas", icon = "⚽"},
            {k = "skillsActivated", l = "Skills Ativadas", icon = "⚡"},
            {k = "morphsDone", l = "Morphs Realizados", icon = "👤"},
            {k = "antiLagItems", l = "Itens Otimizados", icon = "🚀"},
            {k = "ballsColored", l = "Bolas Coloridas", icon = "🎨"},
            {k = "stretchBoost", l = "Boost Stretch", icon = "📐"},
            {k = "avgPing", l = "Ping Médio", icon = "📶"},
            {k = "fps", l = "FPS Atual", icon = "🎮"},
            {k = "selectedBallName", l = "Bola Selecionada", icon = "🎯"}
        }

        for _, item in ipairs(statItems) do
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 50)
            f.BackgroundColor3 = CONFIG.customColors.bgElevated
            f.BackgroundTransparency = 0.5
            f.BorderSizePixel = 0
            f.Parent = statsContent

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(0, 12)
            fCorner.Parent = f

            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 40, 1, 0)
            icon.BackgroundTransparency = 1
            icon.Text = item.icon
            icon.TextSize = 24
            icon.Font = Enum.Font.Gotham
            icon.Parent = f

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.5, 0, 1, 0)
            lbl.Position = UDim2.new(0, 45, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = item.l
            lbl.TextColor3 = CONFIG.customColors.textSecondary
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = f

            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(0.4, 0, 1, 0)
            val.Position = UDim2.new(0.6, 0, 0, 0)
            val.BackgroundTransparency = 1
            val.Text = "0"
            val.TextColor3 = CONFIG.customColors.primary
            val.TextSize = 18
            val.Font = Enum.Font.GothamBlack
            val.TextXAlignment = Enum.TextXAlignment.Right
            val.Parent = f

            statsLabels[item.k] = val
        end

        local logsSection, logsContent = createSection(contentFrames.stats, "Logs Recentes", CONFIG.customColors.secondary)
        local logsLabel = Instance.new("TextLabel")
        logsLabel.Size = UDim2.new(1, 0, 0, 0)
        logsLabel.AutomaticSize = Enum.AutomaticSize.Y
        logsLabel.BackgroundTransparency = 1
        logsLabel.Text = "Sem logs ainda."
        logsLabel.TextColor3 = CONFIG.customColors.textSecondary
        logsLabel.TextSize = 12
        logsLabel.Font = Enum.Font.Gotham
        logsLabel.TextWrapped = true
        logsLabel.TextXAlignment = Enum.TextXAlignment.Left
        logsLabel.TextYAlignment = Enum.TextYAlignment.Top
        logsLabel.Parent = logsContent

        task.spawn(function()
            while mainGui and mainGui.Parent do
                local now = tick()
                if now - lastStatsUpdate >= statsUpdateInterval then
                    lastStatsUpdate = now

                    for k, lbl in pairs(statsLabels) do
                        pcall(function()
                            lbl.Text = tostring(STATS[k] or 0)
                        end)
                    end

                    local textLogs = ""
                    for i = 1, math.min(8, #LOGS) do
                        local entry = LOGS[i]
                        if entry then
                                                        textLogs = textLogs .. "[" .. entry.time .. "] " .. entry.message .. "\n"
                        end
                    end
                    if textLogs == "" then
                        textLogs = "Sem logs ainda."
                    end
                    logsLabel.Text = textLogs
                end
                task.wait(0.1)
            end
        end)

        -- =========================
        -- NAVEGAÇÃO
        -- =========================
        local function switchTab(tabName)
            currentTab = tabName

            for name, btn in pairs(tabButtons) do
                local indicator = btn:FindFirstChild("Indicator")
                if name == tabName then
                    btn.TextColor3 = CONFIG.customColors.textPrimary
                    btn.BackgroundTransparency = 0.25
                    if indicator then
                        indicator.Visible = true
                    end
                else
                    btn.TextColor3 = CONFIG.customColors.textSecondary
                    btn.BackgroundTransparency = 0.7
                    if indicator then
                        indicator.Visible = false
                    end
                end
            end

            for name, frame in pairs(contentFrames) do
                frame.Visible = (name == tabName)
            end
        end

        for name, btn in pairs(tabButtons) do
            btn.MouseButton1Click:Connect(function()
                switchTab(name)
            end)
        end

        local function minimizeUI()
            isMinimized = true

            if mainFrame then
                mainFrame.Visible = false
            end
            if mainGui then
                mainGui.Enabled = false
            end

            local oldIcon = CoreGui:FindFirstChild("CAFUXZ1_FloatingIcon")
            if not oldIcon then
                if _G.createFloatingIcon then
                    _G.createFloatingIcon()
                end
            else
                oldIcon.Enabled = true
            end

            notify("🔄 Minimizado", "Clique no ícone ⚡ para restaurar.", 2)
        end

        minimizeBtn.MouseButton1Click:Connect(minimizeUI)
        closeBtn.MouseButton1Click:Connect(minimizeUI)

        switchTab("reach")
        applyResponsiveLayout()
        startResponsiveLoop()

        notifySuccess("🎉 CAFUXZ1 Hub v18.5", "Interface com SelectedBall carregada!", 4)
    end)

    if not success then
        warn("Erro ao criar UI:", uiError)
        notifyError("❌ Erro", "Falha ao criar interface!", 5)
    end
end

-- ============================================
-- ÍCONE FLUTUANTE RESPONSIVO
-- ============================================
_G.createFloatingIcon = function()
    pcall(function()
        local oldIcon = CoreGui:FindFirstChild("CAFUXZ1_FloatingIcon")
        if oldIcon then
            oldIcon:Destroy()
        end
    end)

    local vp = getViewportSize()
    local iconSize = vp.X < 700 and 50 or 55
    local iconTextSize = vp.X < 700 and 28 or 32

    iconGui = Instance.new("ScreenGui")
    iconGui.Name = "CAFUXZ1_FloatingIcon"
    iconGui.ResetOnSpawn = false
    iconGui.IgnoreGuiInset = true
    iconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    iconGui.Parent = CoreGui

    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconFrame.Position = UDim2.new(0, 20, 0.5, -(iconSize / 2))
    iconFrame.BackgroundColor3 = CONFIG.customColors.bgCard
    iconFrame.BackgroundTransparency = 0.1
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = iconGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = iconFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.customColors.primary
    stroke.Thickness = 2.5
    stroke.Transparency = 0.3
    stroke.Parent = iconFrame

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "⚡"
    iconLabel.TextColor3 = CONFIG.customColors.primary
    iconLabel.TextSize = iconTextSize
    iconLabel.Font = Enum.Font.GothamBlack
    iconLabel.Parent = iconFrame

    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.8, 0, 1.8, 0)
    glow.Position = UDim2.new(-0.4, 0, -0.4, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891979"
    glow.ImageColor3 = CONFIG.customColors.primary
    glow.ImageTransparency = 0.85
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 118, 118)
    glow.Parent = iconFrame

    task.spawn(function()
        while iconGui and iconGui.Parent do
            pcall(function()
                local tween1 = TweenService:Create(iconFrame, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Size = UDim2.new(0, iconSize + 5, 0, iconSize + 5)
                })
                local tween2 = TweenService:Create(iconFrame, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Size = UDim2.new(0, iconSize, 0, iconSize)
                })
                tween1:Play()
                task.wait(0.8)
                tween2:Play()
                task.wait(0.8)
            end)
        end
    end)

    local dragging = false
    local dragStart = nil
    local startPos = nil

    iconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = iconFrame.Position
            TweenService:Create(iconFrame, TweenInfo.new(0.15), {
                Size = UDim2.new(0, iconSize - 5, 0, iconSize - 5)
            }):Play()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            iconFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                TweenService:Create(iconFrame, TweenInfo.new(0.15), {
                    Size = UDim2.new(0, iconSize, 0, iconSize)
                }):Play()

                local delta = (input.Position - dragStart).Magnitude
                if delta < 5 then
                    pcall(function()
                        if mainGui and mainGui.Parent then
                            isMinimized = false
                            mainGui.Enabled = true
                            if mainFrame then
                                mainFrame.Visible = true
                            end
                            iconGui.Enabled = false
                            notify("🎮 Interface Restaurada", "CAFUXZ1 Hub v18.5 aberto!", 2)
                        else
                            createWindUI()
                            iconGui.Enabled = false
                        end
                    end)
                end
            end
        end
    end)

    iconFrame.MouseEnter:Connect(function()
        TweenService:Create(iconFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 3.5}):Play()
    end)

    iconFrame.MouseLeave:Connect(function()
        TweenService:Create(iconFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness         = 2.5}):Play()
    end)

    return iconGui
end

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
local function mainLoop()
    if loopRunning then
        return
    end
    loopRunning = true

    PingSystem:Init()

    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isClosed then
            return
        end

        PingSystem:Update()

        pcall(updateCharacter)
        pcall(updateBothSpheres)

        -- Ball System: Scan, Select, Update GUI, Touch
        pcall(function()
            BallSystem:ScanBalls()
            BallSystem:SelectBall()
            BallSystem:UpdateBallGUI()
            
            -- Touch prioritário na SelectedBall
            if not BallSystem:TouchSelectedBall() then
                -- Fallback para outras bolas
                BallSystem:TouchOtherBalls()
            end
        end)

        if HRP and HRP.Parent then
            pcall(processAutoSkills)
        else
            pcall(destroyBothSpheres)
        end
    end)

    addLog("Sistema Reach + SelectedBall iniciado", "success")
    notifySuccess("⚡ Sistema Ativo", "CAFUXZ1 Hub v18.5 rodando!", 3)
end

-- ============================================
-- ATALHOS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F1 then
        CONFIG.autoTouch = not CONFIG.autoTouch
        notify(
            CONFIG.autoTouch and "✅ Auto Touch ON" or "⚠️ Auto Touch OFF",
            CONFIG.autoTouch and "Toque automático ativado!" or "Toque automático desativado.",
            2
        )

    elseif input.KeyCode == Enum.KeyCode.F2 then
        setSpheresVisible(not CONFIG.showReachSphere)

    elseif input.KeyCode == Enum.KeyCode.F3 then
        CONFIG.autoSecondTouch = not CONFIG.autoSecondTouch
        pcall(updateBothSpheres)

    elseif input.KeyCode == Enum.KeyCode.F4 then
        CONFIG.antiLag.enabled = not CONFIG.antiLag.enabled
        if CONFIG.antiLag.enabled then
            applyAntiLag()
        else
            disableAntiLag()
        end

    elseif input.KeyCode == Enum.KeyCode.F5 then
        CONFIG.pingOptimization.enabled = not CONFIG.pingOptimization.enabled
        notify(
            CONFIG.pingOptimization.enabled and "📶 Ping Optimization ON" or "📶 Ping Optimization OFF",
            CONFIG.pingOptimization.enabled and "Sistema adaptativo de ping ativado!" or "Otimização de ping desativada.",
            3
        )

    elseif input.KeyCode == Enum.KeyCode.F6 then
        CONFIG.ballSystem.enabled = not CONFIG.ballSystem.enabled
        ballSystemActive = CONFIG.ballSystem.enabled
        if CONFIG.ballSystem.enabled then
            processedBalls = {}
            notifyBall("⚽ Ball System ON", "Coloração automática ativada!", 3)
        else
            notifyBall("⚠️ Ball System OFF", "Coloração desativada.", 3)
        end

    elseif input.KeyCode == Enum.KeyCode.F7 then
        snowActive = not snowActive
        toggleSnow(snowActive)

    elseif input.KeyCode == Enum.KeyCode.F8 then
        toggleScreenStretch(not CONFIG.screenStretch.enabled)

    elseif input.KeyCode == Enum.KeyCode.Insert then
        pcall(function()
            local localIconGui = CoreGui:FindFirstChild("CAFUXZ1_FloatingIcon")

            if mainGui and mainGui.Parent and mainGui.Enabled and not isMinimized then
                isMinimized = true
                if mainFrame then
                    mainFrame.Visible = false
                end
                mainGui.Enabled = false

                if localIconGui then
                    localIconGui.Enabled = true
                else
                    _G.createFloatingIcon()
                end

                notify("🔄 Minimizado", "Clique no ícone ⚡ para restaurar.", 2)
            else
                if mainGui and mainGui.Parent then
                    isMinimized = false
                    mainGui.Enabled = true
                    if mainFrame then
                        mainFrame.Visible = true
                    end
                    applyResponsiveLayout()
                else
                    createWindUI()
                end

                if localIconGui then
                    localIconGui.Enabled = false
                end
            end
        end)
    end
end)

-- ============================================
-- EVENTOS DO JOGADOR
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    addLog("Character respawnado", "info")

    Character = newChar
    HRP = nil

    pcall(destroyBothSpheres)

    task.spawn(function()
        local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)
        if newHRP then
            HRP = newHRP
            addLog("HRP reconectado", "success")
        end
    end)

    task.delay(1, function()
        if CONFIG.antiLag.enabled then
            applyAntiLag()
        end
        if CONFIG.screenStretch.enabled then
            limparMapaStretch()
        end
    end)
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
task.spawn(function()
    task.wait(0.5)
    pcall(createWindUI)
    task.wait(0.2)
    pcall(mainLoop)
    task.wait(0.5)
    pcall(_G.createFloatingIcon)

    local icon = CoreGui:FindFirstChild("CAFUXZ1_FloatingIcon")
    if icon then
        icon.Enabled = false
    end
end)

print("========================================")
print("CAFUXZ1 Hub v18.5 - UNIFIED")
print("========================================")
print("🎮 Features:")
print("   ✅ SelectedBall System (detecção avançada)")
print("   ✅ Ball ESP + Highlight + Trail")
print("   ✅ Auto Touch Prioritário na bola selecionada")
print("   ✅ Screen Stretch (FPS Boost)")
print("   ✅ Anti-Lag System")
print("   ✅ Ping Optimization")
print("   ✅ Ball Color System")
print("   ✅ Morph System")
print("   ✅ Skybox Changer")
print("   ❌ Tote Removido")
print("")
print("🎮 Atalhos:")
print("   Insert = Abrir/Fechar Interface")
print("   F1 = Auto Touch")
print("   F2 = Mostrar/Esconder esferas")
print("   F3 = Double Touch Arthur")
print("   F4 = Anti-Lag")
print("   F5 = Ping Optimization")
print("   F6 = Ball System")
print("   F7 = Neve")
print("   F8 = Stretch")
print("========================================")

