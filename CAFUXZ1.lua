--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║   ██████╗ █████╗ ███████╗██╗   ██╗██╗  ██╗███████╗██╗        ║
    ║  ██╔════╝██╔══██╗██╔════╝██║   ██║╚██╗██╔╝██╔════╝██║        ║
    ║  ██║     ███████║█████╗  ██║   ██║ ╚███╔╝ █████╗  ██║        ║
    ║  ██║     ██╔══██║██╔══╝  ██║   ██║ ██╔██╗ ██╔══╝  ██║        ║
    ║  ╚██████╗██║  ██║██║     ╚██████╔╝██╔╝ ██╗██║     ███████╗   ║
    ║   ╚═════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝   ║
    ║                                                              ║
    ║                    PREMIUM LOADER v2.0                       ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================
-- CONFIGURAÇÕES DO LOADER
-- ============================================
local CONFIG = {
    -- Cores do tema
    colors = {
        primary = Color3.fromRGB(147, 51, 234),      -- Roxo neon
        secondary = Color3.fromRGB(236, 72, 153),    -- Rosa
        accent = Color3.fromRGB(59, 130, 246),       -- Azul
        success = Color3.fromRGB(34, 197, 94),       -- Verde
        danger = Color3.fromRGB(239, 68, 68),        -- Vermelho
        warning = Color3.fromRGB(245, 158, 11),      -- Laranja
        
        bgDark = Color3.fromRGB(10, 10, 20),
        bgCard = Color3.fromRGB(20, 20, 35),
        bgElevated = Color3.fromRGB(30, 30, 50),
        bgGlass = Color3.fromRGB(15, 15, 28, 0.9),
        
        textPrimary = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(180, 180, 200),
        textMuted = Color3.fromRGB(120, 120, 140),
        
        gradientStart = Color3.fromRGB(147, 51, 234),
        gradientEnd = Color3.fromRGB(236, 72, 153)
    },
    
    -- Configurações da key
    validKeys = {
        "CAFUXZ1-PREMIUM-2024",
        "CAFUXZ1-FREE-ACCESS",
        "BYONE-LOADER-V2",
        "PREMIUM-USER-KEY",
        "BETA-TESTER-2024"
    },
    
    -- URLs
    scriptUrl = "https://raw.githubusercontent.com/Meunicke/Standart_byone/refs/heads/main/CAFUXZ2.lua",
    discordUrl = "https://discord.gg/cafuxz1",
    
    -- Animações
    animationSpeed = 0.5,
    particleCount = 50
}

-- ============================================
-- LIMPEZA
-- ============================================
pcall(function()
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj.Name:match("CAFUXZ1_Loader") or obj.Name:match("CAFUXZ1_Particles") then
            obj:Destroy()
        end
    end
end)

-- ============================================
-- SISTEMA DE PARTÍCULAS (BACKGROUND)
-- ============================================
local function createParticleSystem()
    local particleGui = Instance.new("ScreenGui")
    particleGui.Name = "CAFUXZ1_Particles"
    particleGui.ResetOnSpawn = false
    particleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    particleGui.Parent = CoreGui
    
    local particles = {}
    
    for i = 1, CONFIG.particleCount do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = CONFIG.colors.primary
        particle.BackgroundTransparency = math.random(30, 70) / 100
        particle.BorderSizePixel = 0
        particle.Parent = particleGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle
        
        table.insert(particles, {
            obj = particle,
            speed = math.random(5, 15) / 100,
            direction = Vector2.new(math.random(-1, 1), math.random(-1, 1)).Unit
        })
    end
    
    -- Animação das partículas
    RunService.RenderStepped:Connect(function()
        for _, p in ipairs(particles) do
            if p.obj and p.obj.Parent then
                local currentPos = p.obj.Position
                local newX = currentPos.X.Scale + (p.direction.X * p.speed * 0.1)
                local newY = currentPos.Y.Scale + (p.direction.Y * p.speed * 0.1)
                
                -- Bounce nas bordas
                if newX < 0 or newX > 1 then
                    p.direction = Vector2.new(-p.direction.X, p.direction.Y)
                    newX = math.clamp(newX, 0, 1)
                end
                if newY < 0 or newY > 1 then
                    p.direction = Vector2.new(p.direction.X, -p.direction.Y)
                    newY = math.clamp(newY, 0, 1)
                end
                
                p.obj.Position = UDim2.new(newX, 0, newY, 0)
            end
        end
    end)
    
    return particleGui
end

-- ============================================
-- EFEITO DE BLUR NO FUNDO
-- ============================================
local function createBlurEffect()
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    
    TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
    
    return blur
end

-- ============================================
-- NOTIFICAÇÕES ESTILIZADAS
-- ============================================
local function showNotification(title, message, notifType, duration)
    duration = duration or 3
    notifType = notifType or "info"
    
    local colors = {
        success = CONFIG.colors.success,
        error = CONFIG.colors.danger,
        warning = CONFIG.colors.warning,
        info = CONFIG.colors.accent
    }
    
    local color = colors[notifType] or colors.info
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "CAFUXZ1_Notification_" .. tick()
    notifGui.ResetOnSpawn = false
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifGui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 80)
    frame.Position = UDim2.new(1, 50, 0.9, 0)
    frame.BackgroundColor3 = CONFIG.colors.bgCard
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = notifGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    -- Ícone
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 50, 0, 50)
    iconLabel.Position = UDim2.new(0, 15, 0, 15)
    iconLabel.BackgroundColor3 = color
    iconLabel.BackgroundTransparency = 0.8
    iconLabel.Text = notifType == "success" and "✓" or notifType == "error" and "✕" or "!"
    iconLabel.TextColor3 = color
    iconLabel.TextSize = 28
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = frame
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 12)
    iconCorner.Parent = iconLabel
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 25)
    titleLabel.Position = UDim2.new(0, 75, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = color
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    -- Mensagem
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -80, 0, 40)
    msgLabel.Position = UDim2.new(0, 75, 0, 35)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = CONFIG.colors.textSecondary
    msgLabel.TextSize = 13
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = frame
    
    -- Barra de progresso
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = color
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBar
    
    -- Animações
    TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -340, 0.9, 0)
    }):Play()
    
    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()
    
    -- Remover após duração
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, 0.9, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.4)
        notifGui:Destroy()
    end)
end

-- ============================================
-- INTERFACE PRINCIPAL DO LOADER
-- ============================================
local function createLoaderInterface()
    local blur = createBlurEffect()
    local particleSystem = createParticleSystem()
    
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "CAFUXZ1_Loader"
    loaderGui.ResetOnSpawn = false
    loaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loaderGui.Parent = CoreGui
    
    -- Frame principal (inicialmente invisível para animação)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 0)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, 0)
    mainFrame.BackgroundColor3 = CONFIG.colors.bgGlass
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = loaderGui
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = mainFrame
    
    -- Borda gradiente
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.colors.primary
    stroke.Thickness = 2
    stroke.Transparency = 0.6
    stroke.Parent = mainFrame
    
    -- Gradient no fundo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.colors.gradientStart),
        ColorSequenceKeypoint.new(1, CONFIG.colors.gradientEnd)
    })
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    })
    gradient.Parent = mainFrame
    
    -- Container de conteúdo
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- ============================================
    -- TELA 1: LOADING INICIAL
    -- ============================================
    local loadingScreen = Instance.new("Frame")
    loadingScreen.Name = "LoadingScreen"
    loadingScreen.Size = UDim2.new(1, 0, 1, 0)
    loadingScreen.BackgroundTransparency = 1
    loadingScreen.Parent = contentFrame
    
    -- Logo animado
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 120, 0, 120)
    logoContainer.Position = UDim2.new(0.5, -60, 0, 80)
    logoContainer.BackgroundTransparency = 1
    logoContainer.Parent = loadingScreen
    
    local logoGlow = Instance.new("ImageLabel")
    logoGlow.Size = UDim2.new(2, 0, 2, 0)
    logoGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    logoGlow.BackgroundTransparency = 1
    logoGlow.Image = "rbxassetid://4996891979"
    logoGlow.ImageColor3 = CONFIG.colors.primary
    logoGlow.ImageTransparency = 0.7
    logoGlow.Parent = logoContainer
    
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "⚡"
    logoText.TextColor3 = CONFIG.colors.primary
    logoText.TextSize = 80
    logoText.Font = Enum.Font.GothamBlack
    logoText.Parent = logoContainer
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 220)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "CAFUXZ1"
    titleLabel.TextColor3 = CONFIG.colors.textPrimary
    titleLabel.TextSize = 42
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.Parent = loadingScreen
    
    -- Subtítulo
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, 0, 0, 25)
    subtitleLabel.Position = UDim2.new(0, 0, 0, 265)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "PREMIUM LOADER"
    subtitleLabel.TextColor3 = CONFIG.colors.secondary
    subtitleLabel.TextSize = 18
    subtitleLabel.Font = Enum.Font.GothamBold
    subtitleLabel.Parent = loadingScreen
    
    -- Barra de loading
    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.Size = UDim2.new(0, 300, 0, 8)
    loadingBarBg.Position = UDim2.new(0.5, -150, 0, 330)
    loadingBarBg.BackgroundColor3 = CONFIG.colors.bgElevated
    loadingBarBg.BorderSizePixel = 0
    loadingBarBg.Parent = loadingScreen
    
    local loadingBarBgCorner = Instance.new("UICorner")
    loadingBarBgCorner.CornerRadius = UDim.new(1, 0)
    loadingBarBgCorner.Parent = loadingBarBg
    
    local loadingBarFill = Instance.new("Frame")
    loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    loadingBarFill.BackgroundColor3 = CONFIG.colors.primary
    loadingBarFill.BorderSizePixel = 0
    loadingBarFill.Parent = loadingBarBg
    
    local loadingBarFillCorner = Instance.new("UICorner")
    loadingBarFillCorner.CornerRadius = UDim.new(1, 0)
    loadingBarFillCorner.Parent = loadingBarFill
    
    -- Texto de status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 350)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Inicializando sistema..."
    statusLabel.TextColor3 = CONFIG.colors.textMuted
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = loadingScreen
    
    -- Versão
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 100, 0, 20)
    versionLabel.Position = UDim2.new(1, -110, 1, -30)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v2.0.0"
    versionLabel.TextColor3 = CONFIG.colors.textMuted
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Parent = loadingScreen
    
    -- ============================================
    -- TELA 2: KEY SYSTEM
    -- ============================================
    local keyScreen = Instance.new("Frame")
    keyScreen.Name = "KeyScreen"
    keyScreen.Size = UDim2.new(1, 0, 1, 0)
    keyScreen.BackgroundTransparency = 1
    keyScreen.Visible = false
    keyScreen.Parent = contentFrame
    
    -- Título da key
    local keyTitle = Instance.new("TextLabel")
    keyTitle.Size = UDim2.new(1, 0, 0, 35)
    keyTitle.Position = UDim2.new(0, 0, 0, 40)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "🔐 KEY SYSTEM"
    keyTitle.TextColor3 = CONFIG.colors.primary
    keyTitle.TextSize = 28
    keyTitle.Font = Enum.Font.GothamBlack
    keyTitle.Parent = keyScreen
    
    -- Subtítulo
    local keySubtitle = Instance.new("TextLabel")
    keySubtitle.Size = UDim2.new(1, 0, 0, 20)
    keySubtitle.Position = UDim2.new(0, 0, 0, 80)
    keySubtitle.BackgroundTransparency = 1
    keySubtitle.Text = "Insira sua chave de acesso premium"
    keySubtitle.TextColor3 = CONFIG.colors.textSecondary
    keySubtitle.TextSize = 14
    keySubtitle.Font = Enum.Font.Gotham
    keySubtitle.Parent = keyScreen
    
    -- Container do input
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(0, 400, 0, 55)
    inputContainer.Position = UDim2.new(0.5, -200, 0, 130)
    inputContainer.BackgroundColor3 = CONFIG.colors.bgElevated
    inputContainer.BackgroundTransparency = 0.5
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = keyScreen
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 16)
    inputCorner.Parent = inputContainer
    
    -- Input de texto
    local keyInput = Instance.new("TextBox")
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(1, -30, 1, 0)
    keyInput.Position = UDim2.new(0, 15, 0, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.Text = ""
    keyInput.PlaceholderText = "Digite sua key aqui..."
    keyInput.PlaceholderColor3 = CONFIG.colors.textMuted
    keyInput.TextColor3 = CONFIG.colors.textPrimary
    keyInput.TextSize = 16
    keyInput.Font = Enum.Font.GothamBold
    keyInput.ClearTextOnFocus = false
    keyInput.Parent = inputContainer
    
    -- Ícone de key
    local keyIcon = Instance.new("TextLabel")
    keyIcon.Size = UDim2.new(0, 30, 0, 30)
    keyIcon.Position = UDim2.new(1, -40, 0.5, -15)
    keyIcon.BackgroundTransparency = 1
    keyIcon.Text = "🔑"
    keyIcon.TextSize = 20
    keyIcon.Parent = inputContainer
    
    -- Botão de verificar
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(0, 400, 0, 50)
    verifyBtn.Position = UDim2.new(0.5, -200, 0, 200)
    verifyBtn.BackgroundColor3 = CONFIG.colors.primary
    verifyBtn.Text = "VERIFICAR KEY"
    verifyBtn.TextColor3 = Color3.new(1, 1, 1)
    verifyBtn.TextSize = 16
    verifyBtn.Font = Enum.Font.GothamBlack
    verifyBtn.Parent = keyScreen
    
    local verifyCorner = Instance.new("UICorner")
    verifyCorner.CornerRadius = UDim.new(0, 14)
    verifyCorner.Parent = verifyBtn
    
    -- Gradient no botão
    local verifyGradient = Instance.new("UIGradient")
    verifyGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.colors.gradientStart),
        ColorSequenceKeypoint.new(1, CONFIG.colors.gradientEnd)
    })
    verifyGradient.Rotation = 90
    verifyGradient.Parent = verifyBtn
    
    -- Botão de copiar link do Discord
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 400, 0, 45)
    discordBtn.Position = UDim2.new(0.5, -200, 0, 265)
    discordBtn.BackgroundColor3 = CONFIG.colors.bgElevated
    discordBtn.Text = "📋 Copiar Link do Discord"
    discordBtn.TextColor3 = CONFIG.colors.textSecondary
    discordBtn.TextSize = 14
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.Parent = keyScreen
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 12)
    discordCorner.Parent = discordBtn
    
    -- Informações
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -60, 0, 60)
    infoLabel.Position = UDim2.new(0, 30, 0, 330)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "💡 Dica: Entre no nosso Discord para obter uma key gratuita!\nAs keys são válidas por 24 horas."
    infoLabel.TextColor3 = CONFIG.colors.textMuted
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.Parent = keyScreen
    
    -- Status da verificação
    local verifyStatus = Instance.new("TextLabel")
    verifyStatus.Size = UDim2.new(1, 0, 0, 20)
    verifyStatus.Position = UDim2.new(0, 0, 0, 400)
    verifyStatus.BackgroundTransparency = 1
    verifyStatus.Text = ""
    verifyStatus.TextColor3 = CONFIG.colors.danger
    verifyStatus.TextSize = 13
    verifyStatus.Font = Enum.Font.GothamBold
    verifyStatus.Parent = keyScreen
    
    -- ============================================
    -- TELA 3: EXECUTANDO SCRIPT
    -- ============================================
    local executeScreen = Instance.new("Frame")
    executeScreen.Name = "ExecuteScreen"
    executeScreen.Size = UDim2.new(1, 0, 1, 0)
    executeScreen.BackgroundTransparency = 1
    executeScreen.Visible = false
    executeScreen.Parent = contentFrame
    
    -- Ícone de sucesso
    local successIcon = Instance.new("TextLabel")
    successIcon.Size = UDim2.new(0, 100, 0, 100)
    successIcon.Position = UDim2.new(0.5, -50, 0, 100)
    successIcon.BackgroundTransparency = 1
    successIcon.Text = "✓"
    successIcon.TextColor3 = CONFIG.colors.success
    successIcon.TextSize = 100
    successIcon.Font = Enum.Font.GothamBlack
    successIcon.Parent = executeScreen
    
    -- Círculo ao redor
    local successCircle = Instance.new("Frame")
    successCircle.Size = UDim2.new(0, 120, 0, 120)
    successCircle.Position = UDim2.new(0.5, -60, 0, 90)
    successCircle.BackgroundTransparency = 1
    successCircle.BorderSizePixel = 0
    successCircle.Parent = executeScreen
    
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Color = CONFIG.colors.success
    circleStroke.Thickness = 4
    circleStroke.Parent = successCircle
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = successCircle
    
    -- Título de sucesso
    local successTitle = Instance.new("TextLabel")
    successTitle.Size = UDim2.new(1, 0, 0, 35)
    successTitle.Position = UDim2.new(0, 0, 0, 240)
    successTitle.BackgroundTransparency = 1
    successTitle.Text = "KEY VÁLIDA!"
    successTitle.TextColor3 = CONFIG.colors.success
    successTitle.TextSize = 32
    successTitle.Font = Enum.Font.GothamBlack
    successTitle.Parent = executeScreen
    
    -- Mensagem
    local successMsg = Instance.new("TextLabel")
    successMsg.Size = UDim2.new(1, 0, 0, 50)
    successMsg.Position = UDim2.new(0, 0, 0, 285)
    successMsg.BackgroundTransparency = 1
    successMsg.Text = "Carregando CAFUXZ1 Hub...\nAguarde alguns segundos."
    successMsg.TextColor3 = CONFIG.colors.textSecondary
    successMsg.TextSize = 14
    successMsg.Font = Enum.Font.Gotham
    successMsg.TextWrapped = true
    successMsg.Parent = executeScreen
    
    -- Barra de progresso circular (simplificada)
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(0, 300, 0, 6)
    progressContainer.Position = UDim2.new(0.5, -150, 0, 360)
    progressContainer.BackgroundColor3 = CONFIG.colors.bgElevated
    progressContainer.BorderSizePixel = 0
    progressContainer.Parent = executeScreen
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressContainer
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = CONFIG.colors.success
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressContainer
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(1, 0)
    progressFillCorner.Parent = progressFill
    
    -- ============================================
    -- ANIMAÇÕES E FUNCIONALIDADE
    -- ============================================
    
    -- Animação de entrada do loader
    TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 500, 0, 450),
        Position = UDim2.new(0.5, -250, 0.5, -225),
        BackgroundTransparency = 0.1
    }):Play()
    
    -- Animação do logo pulsando
    task.spawn(function()
        while loadingScreen.Parent do
            TweenService:Create(logoContainer, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Rotation = 5
            }):Play()
            task.wait(1)
            TweenService:Create(logoContainer, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Rotation = -5
            }):Play()
            task.wait(1)
        end
    end)
    
    -- Animação do glow
    task.spawn(function()
        while loadingScreen.Parent do
            TweenService:Create(logoGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.4,
                Size = UDim2.new(2.5, 0, 2.5, 0)
            }):Play()
            task.wait(2)
            TweenService:Create(logoGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.7,
                Size = UDim2.new(2, 0, 2, 0)
            }):Play()
            task.wait(2)
        end
    end)
    
    -- Simulação de loading
    local loadingSteps = {
        {progress = 0.2, text = "Conectando aos servidores...", delay = 0.5},
        {progress = 0.4, text = "Verificando atualizações...", delay = 0.6},
        {progress = 0.6, text = "Carregando recursos...", delay = 0.5},
        {progress = 0.8, text = "Preparando interface...", delay = 0.4},
        {progress = 1.0, text = "Pronto!", delay = 0.3}
    }
    
    task.spawn(function()
        for _, step in ipairs(loadingSteps) do
            TweenService:Create(loadingBarFill, TweenInfo.new(0.4), {
                Size = UDim2.new(step.progress, 0, 1, 0)
            }):Play()
            statusLabel.Text = step.text
            task.wait(step.delay)
        end
        
        -- Transição para tela de key
        TweenService:Create(loadingScreen, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
        
        for _, child in ipairs(loadingScreen:GetChildren()) do
            if child:IsA("GuiObject") then
                TweenService:Create(child, TweenInfo.new(0.3), {
                    TextTransparency = 1,
                    BackgroundTransparency = 1,
                    ImageTransparency = 1
                }):Play()
            end
        end
        
        task.wait(0.5)
        loadingScreen.Visible = false
        keyScreen.Visible = true
        
        -- Animação de entrada da key screen
        keyScreen.Position = UDim2.new(0, 0, 0, 50)
        TweenService:Create(keyScreen, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end)
    
    -- Função de verificação de key
    local function verifyKey()
        local inputKey = keyInput.Text:gsub("%s+", "") -- Remove espaços
        
        if inputKey == "" then
            verifyStatus.Text = "❌ Por favor, insira uma key!"
            verifyStatus.TextColor3 = CONFIG.colors.danger
            
            -- Shake effect no input
            TweenService:Create(inputContainer, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -210, 0, 130)}):Play()
            task.wait(0.1)
            TweenService:Create(inputContainer, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -190, 0, 130)}):Play()
            task.wait(0.1)
            TweenService:Create(inputContainer, TweenInfo.new(0.1), {Position = UDim2.new(0.5, -200, 0, 130)}):Play()
            return
        end
        
        -- Verifica se a key está na lista
        local isValid = false
        for _, validKey in ipairs(CONFIG.validKeys) do
            if inputKey:upper() == validKey:upper() then
                isValid = true
                break
            end
        end
        
        if isValid then
            verifyStatus.Text = "✓ Key válida! Redirecionando..."
            verifyStatus.TextColor3 = CONFIG.colors.success
            
            -- Efeito de sucesso no botão
            TweenService:Create(verifyBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = CONFIG.colors.success
            }):Play()
            
            task.wait(0.5)
            
            -- Transição para tela de execução
            keyScreen.Visible = false
            executeScreen.Visible = true
            
            -- Animação do círculo de sucesso
            successCircle.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(successCircle, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 120, 0, 120)
            }):Play()
            
            -- Animação da barra de progresso
            TweenService:Create(progressFill, TweenInfo.new(3, Enum.EasingStyle.Linear), {
                Size = UDim2.new(1, 0, 1, 0)
            }):Play()
            
            -- Executa o script após delay
            task.delay(3, function()
                -- Fade out total
                TweenService:Create(mainFrame, TweenInfo.new(0.5), {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 450, 0, 400)
                }):Play()
                
                TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
                
                task.wait(0.5)
                
                -- Limpa tudo
                loaderGui:Destroy()
                particleSystem:Destroy()
                blur:Destroy()
                
                -- Executa o script principal
                showNotification("✓ Sucesso", "CAFUXZ1 Hub carregado!", "success", 3)
                
                task.wait(0.5)
                
                -- LOADSTRING DO SCRIPT PRINCIPAL
                local success, err = pcall(function()
                    loadstring(game:HttpGet(CONFIG.scriptUrl))()
                end)
                
                if not success then
                    showNotification("✕ Erro", "Falha ao carregar: " .. tostring(err):sub(1, 50), "error", 5)
                end
            end)
            
        else
            verifyStatus.Text = "❌ Key inválida! Tente novamente."
            verifyStatus.TextColor3 = CONFIG.colors.danger
            
            -- Efeito de erro
            TweenService:Create(inputContainer, TweenInfo.new(0.2), {
                BackgroundColor3 = CONFIG.colors.danger
            }):Play()
            
            task.wait(0.2)
            
            TweenService:Create(inputContainer, TweenInfo.new(0.3), {
                BackgroundColor3 = CONFIG.colors.bgElevated
            }):Play()
        end
    end
    
    verifyBtn.MouseButton1Click:Connect(verifyKey)
    
    -- Enter para verificar
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyKey()
        end
    end)
    
    -- Botão do Discord
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard(CONFIG.discordUrl)
        showNotification("✓ Copiado", "Link do Discord copiado!", "success", 2)
        
        -- Efeito visual
        discordBtn.Text = "✓ Link Copiado!"
        TweenService:Create(discordBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.colors.success
        }):Play()
        
        task.wait(2)
        
        discordBtn.Text = "📋 Copiar Link do Discord"
        TweenService:Create(discordBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.colors.bgElevated
        }):Play()
    end)
    
    -- Hover effects nos botões
    verifyBtn.MouseEnter:Connect(function()
        TweenService:Create(verifyBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 410, 0, 52)}):Play()
    end)
    
    verifyBtn.MouseLeave:Connect(function()
        TweenService:Create(verifyBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 400, 0, 50)}):Play()
    end)
    
    discordBtn.MouseEnter:Connect(function()
        TweenService:Create(discordBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        }):Play()
    end)
    
    discordBtn.MouseLeave:Connect(function()
        TweenService:Create(discordBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.colors.bgElevated
        }):Play()
    end)
    
    -- Fechar com ESC (opcional)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
            -- Minimiza/mostra
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
end

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
task.spawn(function()
    -- Pequeno delay para garantir que tudo carregou
    task.wait(0.3)
    createLoaderInterface()
end)

print([[
    ╔══════════════════════════════════════════════════════════════╗
    ║           CAFUXZ1 PREMIUM LOADER v2.0 INICIADO               ║
    ║                                                              ║
    ║  Status: Aguardando verificação de key...                    ║
    ║  Discord: https://discord.gg/cafuxz1                         ║
    ╚══════════════════════════════════════════════════════════════╝
]])

