-- JOTA HUB V15.0 - MELHORADO
-- UI WindUI Style, Verde Escuro, Minimizável, Ícone Arrastável
-- Anti-nil value, sem geração de arquivos

-- SERVICES
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local CONFIG = {
    reach = 10,
    magnetStrength = 0,
    showReachSphere = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ", "SAML" },
    theme = {
        primary = Color3.fromRGB(0, 100, 0),      -- Verde escuro
        secondary = Color3.fromRGB(0, 150, 0),    -- Verde médio
        accent = Color3.fromRGB(50, 205, 50),     -- Verde lima
        dark = Color3.fromRGB(10, 30, 10),        -- Verde muito escuro
        darker = Color3.fromRGB(5, 15, 5),        -- Quase preto verde
        text = Color3.fromRGB(240, 255, 240),     -- Texto branco esverdeado
        textDark = Color3.fromRGB(180, 200, 180), -- Texto secundário
    }
}

-- VARIÁVEIS
local balls = {}
local lastRefresh = 0
local reachSphere
local mainGui, mainFrame, minimizeIcon
local isMinimized = false
local isClosed = false

-- BALL SET
local BALL_NAME_SET = {}
for _, n in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[n] = true
end

-- NOTIFY
local function notify(txt, t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "JOTA HUB V15",
            Text = txt,
            Duration = t or 2
        })
    end)
end

-- CRIAR SOMBRA
local function createShadow(parent, offset)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, offset or 4)
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = parent
    return shadow
end

-- CRIAR UICORNER
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 8)
    corner.Parent = parent
    return corner
end

-- CRIAR STROKE
local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.theme.accent
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.7
    stroke.Parent = parent
    return stroke
end

-- REFRESH BALLS (Anti-nil)
local function refreshBalls(force)
    if not force and tick() - lastRefresh < CONFIG.scanCooldown then return end
    lastRefresh = tick()
    table.clear(balls)

    local success = pcall(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v and v:IsA("BasePart") and BALL_NAME_SET[v.Name] then
                table.insert(balls, v)
            end
        end
    end)
    
    if not success then
        warn("Erro ao atualizar bolas")
    end
end

-- PARTES DO CORPO (Anti-nil)
local function getValidParts(char)
    local parts = {}
    if not char then return parts end
    
    pcall(function()
        for _, v in ipairs(char:GetChildren()) do
            if v and v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                table.insert(parts, v)
            end
        end
    end)
    
    return parts
end

-- REACH SPHERE
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then 
            pcall(function() reachSphere:Destroy() end)
            reachSphere = nil 
        end
        return
    end

    if not reachSphere then
        pcall(function()
            reachSphere = Instance.new("Part")
            reachSphere.Name = "JOTAReachSphere"
            reachSphere.Shape = Enum.PartType.Ball
            reachSphere.Anchored = true
            reachSphere.CanCollide = false
            reachSphere.Transparency = 0.85
            reachSphere.Material = Enum.Material.ForceField
            reachSphere.Color = CONFIG.theme.accent
            reachSphere.Parent = Workspace
        end)
    end

    pcall(function()
        if reachSphere then
            reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
        end
    end)
end

-- ATUALIZAR POSIÇÃO DA SPHERE
RunService.RenderStepped:Connect(function()
    pcall(function()
        if reachSphere and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                reachSphere.Position = hrp.Position
            end
        end
    end)
end)

-- SISTEMA DE DRAG
local function makeDraggable(frame, button)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- CRIAR BOTÃO TOGGLE
local function createToggleButton(parent, text, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = CONFIG.theme.dark
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = CONFIG.theme.text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = false
    btn.Parent = parent
    createCorner(btn, UDim.new(0, 6))
    createStroke(btn, CONFIG.theme.accent, 1)
    
    local enabled = defaultState or false
    
    local function updateState()
        if enabled then
            btn.BackgroundColor3 = CONFIG.theme.accent
            btn.TextColor3 = CONFIG.theme.darker
        else
            btn.BackgroundColor3 = CONFIG.theme.dark
            btn.TextColor3 = CONFIG.theme.text
        end
    end
    
    -- Estado inicial
    updateState()
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateState()
        if callback then callback(enabled) end
    end)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = enabled and CONFIG.theme.secondary or CONFIG.theme.secondary}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        updateState()
    end)
    
    return btn
end

-- CRIAR BOTÃO DE CONTROLE (+/-)
local function createControlButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "ControlButton"
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.BackgroundColor3 = CONFIG.theme.secondary
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = CONFIG.theme.text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = parent
    createCorner(btn, UDim.new(0, 8))
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.theme.accent}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.theme.secondary}):Play()
    end)
    
    return btn
end

-- BUILD GUI PRINCIPAL
local function buildMainGUI()
    if mainGui then return end

    -- ScreenGui principal
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "JOTAHUBV15"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = playerGui

    -- Frame principal
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = CONFIG.theme.darker
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui
    createCorner(mainFrame, UDim.new(0, 12))
    createShadow(mainFrame, 6)
    createStroke(mainFrame, CONFIG.theme.primary, 2)

    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = CONFIG.theme.primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    createCorner(titleBar, UDim.new(0, 12))

    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ JOTA HUB V15"
    title.TextColor3 = CONFIG.theme.text
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Botão minimizar
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeBtn"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -70, 0.5, 0)
    minBtn.AnchorPoint = Vector2.new(0, 0.5)
    minBtn.BackgroundColor3 = CONFIG.theme.secondary
    minBtn.BorderSizePixel = 0
    minBtn.Text = "−"
    minBtn.TextColor3 = CONFIG.theme.text
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar
    createCorner(minBtn, UDim.new(0, 6))

    minBtn.MouseEnter:Connect(function()
        TweenService:Create(minBtn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.theme.accent}):Play()
    end)
    
    minBtn.MouseLeave:Connect(function()
        TweenService:Create(minBtn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.theme.secondary}):Play()
    end)

    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CONFIG.theme.text
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    createCorner(closeBtn, UDim.new(0, 6))

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180, 30, 30)}):Play()
    end)

    -- Container de conteúdo
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = content

    -- SEÇÃO: REACH
    local reachSection = Instance.new("Frame")
    reachSection.Name = "ReachSection"
    reachSection.Size = UDim2.new(1, 0, 0, 100)
    reachSection.BackgroundColor3 = CONFIG.theme.dark
    reachSection.BorderSizePixel = 0
    reachSection.Parent = content
    createCorner(reachSection, UDim.new(0, 8))
    createStroke(reachSection, CONFIG.theme.primary, 1)

    local reachTitle = Instance.new("TextLabel")
    reachTitle.Name = "ReachTitle"
    reachTitle.Size = UDim2.new(1, 0, 0, 25)
    reachTitle.Position = UDim2.new(0, 0, 0, 5)
    reachTitle.BackgroundTransparency = 1
    reachTitle.Text = "🎯 REACH CONTROL"
    reachTitle.TextColor3 = CONFIG.theme.accent
    reachTitle.TextScaled = true
    reachTitle.Font = Enum.Font.GothamBold
    reachTitle.Parent = reachSection

    local reachValue = Instance.new("TextLabel")
    reachValue.Name = "ReachValue"
    reachValue.Size = UDim2.new(1, 0, 0, 30)
    reachValue.Position = UDim2.new(0, 0, 0, 30)
    reachValue.BackgroundTransparency = 1
    reachValue.Text = tostring(CONFIG.reach)
    reachValue.TextColor3 = CONFIG.theme.text
    reachValue.TextScaled = true
    reachValue.Font = Enum.Font.GothamBold
    reachValue.Parent = reachSection

    local btnContainer = Instance.new("Frame")
    btnContainer.Name = "BtnContainer"
    btnContainer.Size = UDim2.new(1, 0, 0, 40)
    btnContainer.Position = UDim2.new(0, 0, 0, 60)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = reachSection

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    btnLayout.Padding = UDim.new(0, 20)
    btnLayout.Parent = btnContainer

    -- Botão -
    local minusBtn = createControlButton(btnContainer, "−", function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        reachValue.Text = tostring(CONFIG.reach)
        updateReachSphere()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    -- Botão +
    local plusBtn = createControlButton(btnContainer, "+", function()
        CONFIG.reach = CONFIG.reach + 1
        reachValue.Text = tostring(CONFIG.reach)
        updateReachSphere()
        notify("Reach: " .. CONFIG.reach, 1)
    end)

    -- SEÇÃO: TOGGLES
    local toggleSection = Instance.new("Frame")
    toggleSection.Name = "ToggleSection"
    toggleSection.Size = UDim2.new(1, 0, 0, 140)
    toggleSection.BackgroundColor3 = CONFIG.theme.dark
    toggleSection.BorderSizePixel = 0
    toggleSection.Parent = content
    createCorner(toggleSection, UDim.new(0, 8))
    createStroke(toggleSection, CONFIG.theme.primary, 1)

    local toggleTitle = Instance.new("TextLabel")
    toggleTitle.Name = "ToggleTitle"
    toggleTitle.Size = UDim2.new(1, 0, 0, 25)
    toggleTitle.Position = UDim2.new(0, 0, 0, 5)
    toggleTitle.BackgroundTransparency = 1
    toggleTitle.Text = "⚙️ SETTINGS"
    toggleTitle.TextColor3 = CONFIG.theme.accent
    toggleTitle.TextScaled = true
    toggleTitle.Font = Enum.Font.GothamBold
    toggleTitle.Parent = toggleSection

    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(1, -20, 1, -35)
    toggleContainer.Position = UDim2.new(0, 10, 0, 30)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = toggleSection

    local toggleLayout = Instance.new("UIListLayout")
    toggleLayout.Padding = UDim.new(0, 8)
    toggleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    toggleLayout.Parent = toggleContainer

    -- Toggle Auto Touch
    createToggleButton(toggleContainer, "🤚 Auto Touch", true, function(enabled)
        CONFIG.autoSecondTouch = enabled
        notify("Auto Touch: " .. (enabled and "ON" or "OFF"), 1)
    end)

    -- Toggle Show Reach
    createToggleButton(toggleContainer, "👁️ Show Reach Sphere", true, function(enabled)
        CONFIG.showReachSphere = enabled
        updateReachSphere()
        notify("Reach Sphere: " .. (enabled and "ON" or "OFF"), 1)
    end)

    -- STATUS
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "✅ System Online | SAML Ready"
    statusLabel.TextColor3 = CONFIG.theme.textDark
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = content

    -- FUNÇÃO MINIMIZAR
    local function minimizeHub()
        isMinimized = true
        
        -- Animar saída
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, -0.5, 0)}):Play()
        
        task.delay(0.3, function()
            mainFrame.Visible = false
            createMinimizeIcon()
        end)
        
        notify("Hub Minimized", 1)
    end

    -- FUNÇÃO FECHAR
    local function closeHub()
        isClosed = true
        
        -- Animar saída
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(mainFrame.Position.X.Scale + 0.1, 0, mainFrame.Position.Y.Scale + 0.1, 0)}):Play()
        
        task.delay(0.3, function()
            mainFrame.Visible = false
            updateReachSphere()
            createMinimizeIcon()
        end)
        
        notify("Hub Closed - Reach Active", 2)
    end

    -- FUNÇÃO RESTAURAR
    local function restoreHub()
        isMinimized = false
        isClosed = false
        mainFrame.Visible = true
        
        -- Animar entrada
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), 
            {Position = UDim2.new(0.02, 0, 0.1, 0), Size = UDim2.new(0, 280, 0, 380)}):Play()
        
        -- Remover ícone
        if minimizeIcon then
            TweenService:Create(minimizeIcon, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.delay(0.2, function()
                pcall(function() minimizeIcon:Destroy() end)
                minimizeIcon = nil
            end)
        end
        
        notify("Hub Restored", 1)
    end

    -- CRIAR ÍCONE FLUTUANTE
    function createMinimizeIcon()
        if minimizeIcon then return end
        
        minimizeIcon = Instance.new("Frame")
        minimizeIcon.Name = "MinimizeIcon"
        minimizeIcon.Size = UDim2.new(0, 50, 0, 50)
        minimizeIcon.Position = UDim2.new(0.9, 0, 0.9, 0)
        minimizeIcon.BackgroundColor3 = CONFIG.theme.primary
        minimizeIcon.BorderSizePixel = 0
        minimizeIcon.Parent = mainGui
        createCorner(minimizeIcon, UDim.new(1, 0))
        createShadow(minimizeIcon, 4)
        createStroke(minimizeIcon, CONFIG.theme.accent, 2)

        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "⚡"
        icon.TextColor3 = CONFIG.theme.text
        icon.TextScaled = true
        icon.Font = Enum.Font.GothamBold
        icon.Parent = minimizeIcon

        local btn = Instance.new("TextButton")
        btn.Name = "ClickArea"
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = minimizeIcon

        -- Efeito hover
        btn.MouseEnter:Connect(function()
            TweenService:Create(minimizeIcon, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.theme.accent, Size = UDim2.new(0, 55, 0, 55)}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(minimizeIcon, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.theme.primary, Size = UDim2.new(0, 50, 0, 50)}):Play()
        end)

        -- Click para restaurar
        btn.MouseButton1Click:Connect(restoreHub)

        -- Sistema de drag para o ícone
        makeDraggable(minimizeIcon, minimizeIcon)
        
        -- Animação de entrada
        minimizeIcon.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(minimizeIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back), 
            {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end

    -- Conectar botões
    minBtn.MouseButton1Click:Connect(minimizeHub)
    closeBtn.MouseButton1Click:Connect(closeHub)

    -- Tornar arrastável
    makeDraggable(mainFrame, titleBar)
end

-- AUTO TOUCH (Anti-nil)
local function processTouch()
    if not CONFIG.autoSecondTouch then return end
    
    local char = player.Character
    if not char then return end

    local parts = getValidParts(char)
    if #parts == 0 then return end

    for _, ball in ipairs(balls) do
        if ball and ball.Parent then
            local ballPos = ball.Position
            
            for _, part in ipairs(parts) do
                if part and part.Parent then
                    local distance = (ballPos - part.Position).Magnitude
                    if distance <= CONFIG.reach then
                        pcall(function()
                            firetouchinterest(ball, part, 0)
                            firetouchinterest(ball, part, 1)
                        end)
                    end
                end
            end
        end
    end
end

-- LOOPS
RunService.RenderStepped:Connect(function()
    pcall(processTouch)
end)

task.spawn(function()
    while true do
        pcall(function() refreshBalls(false) end)
        task.wait(CONFIG.scanCooldown)
    end
end)

-- INIT
local function init()
    local success, err = pcall(function()
        buildMainGUI()
        updateReachSphere()
        refreshBalls(true)
    end)
    
    if success then
        notify("✅ JOTA HUB V15 ONLINE", 3)
        print("JOTA HUB V15 - Loaded Successfully")
        print("Balls supported: " .. table.concat(CONFIG.ballNames, ", "))
    else
        warn("JOTA HUB V15 - Init Error: " .. tostring(err))
        notify("❌ Error loading Hub", 3)
    end
end

-- Aguardar personagem
if player.Character then
    init()
else
    player.CharacterAdded:Connect(init)
end

print("JOTA HUB V15 Script Loaded")
