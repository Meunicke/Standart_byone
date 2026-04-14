--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║              AQUILESGAMEF1 VIEWER CLIENT v1.0                                ║
    ║         Script para Espectadores - Apenas Visualização                       ║
    ║                                                                              ║
    ║  Instruções:                                                                 ║
    ║  1. Execute este script no mesmo servidor do Builder                         ║
    ║  2. Aguarde conectar automaticamente ao Host                                 ║
    ║  3. Use F4 para Câmera Livre, F3 para esconder/mostrar UI                    ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configurações do Viewer
local CONFIG = {
    VERSION = "1.0",
    SYNC_INTERVAL = 0.5,
    MAX_RECONNECT_ATTEMPTS = 10,
    FREE_CAM_SPEED = 50,
    FREE_CAM_FAST_SPEED = 100,
    STREAM_DISTANCE = 2000,
    THEME = {
        primary = Color3.fromRGB(0, 200, 255),
        background = Color3.fromRGB(15, 15, 20),
        accent = Color3.fromRGB(255, 255, 255)
    }
}

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE NOTIFICAÇÕES                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local NotificationSystem = {}
local activeNotifications = {}
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "AGF1_ViewerNotifications"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
notifGui.Parent = CoreGui

function NotificationSystem:Show(title, message, duration, ntype)
    duration = duration or 4
    ntype = ntype or "INFO"
    local color = ntype == "SUCCESS" and Color3.fromRGB(0, 255, 150) or 
                  ntype == "ERROR" and Color3.fromRGB(255, 80, 80) or 
                  ntype == "WARNING" and Color3.fromRGB(255, 200, 0) or 
                  CONFIG.THEME.primary
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 320, 0, 80)
    container.Position = UDim2.new(1, 350, 1, -12)
    container.AnchorPoint = Vector2.new(1, 1)
    container.BackgroundTransparency = 1
    container.ZIndex = 1000
    container.Parent = notifGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = container
    
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = color
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    
    local icon = Instance.new("TextLabel", mainFrame)
    icon.Size = UDim2.new(0, 36, 0, 36)
    icon.Position = UDim2.new(0, 12, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Text = ntype == "SUCCESS" and "✓" or ntype == "ERROR" and "✕" or ntype == "WARNING" and "⚠" or "ℹ"
    icon.TextColor3 = color
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 24
    
    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, -70, 0, 22)
    titleLabel.Position = UDim2.new(0, 56, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local msgLabel = Instance.new("TextLabel", mainFrame)
    msgLabel.Size = UDim2.new(1, -70, 0, 40)
    msgLabel.Position = UDim2.new(0, 56, 0, 34)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.TextSize = 12
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -12, 1, -12 - (#activeNotifications * 90))
    }):Play()
    
    table.insert(activeNotifications, container)
    
    task.delay(duration, function()
        TweenService:Create(container, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 350, container.Position.Y.Scale, container.Position.Y.Offset)
        }):Play()
        task.wait(0.3)
        container:Destroy()
        table.remove(activeNotifications, table.find(activeNotifications, container))
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE CONEXÃO                                     ║
-- ║         Encontra e conecta automaticamente ao Host                           ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local ConnectionSystem = {
    HostPlayer = nil,
    RemoteEvents = {},
    Connected = false,
    ReconnectAttempts = 0,
    SyncFolder = nil,
    ReceivedModels = {}
}

function ConnectionSystem:FindRemotes()
    local remotesFolder = ReplicatedStorage:WaitForChild("AGF1_Remotes", 10)
    if not remotesFolder then
        return false
    end
    
    for _, child in ipairs(remotesFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then
            self.RemoteEvents[child.Name] = child
        end
    end
    
    return next(self.RemoteEvents) ~= nil
end

function ConnectionSystem:FindHost()
    -- Procurar por jogador com tag de Host
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p:GetAttribute("AGF1_IsHost") then
            return p
        end
    end
    return nil
end

function ConnectionSystem:ConnectToHost(hostPlayer)
    if not hostPlayer then
        NotificationSystem:Show("❌ Erro", "Host não encontrado!", 5, "ERROR")
        return false
    end
    
    self.HostPlayer = hostPlayer
    NotificationSystem:Show("🔗 Conectando...", "Host encontrado: " .. hostPlayer.Name, 3, "INFO")
    
    -- Configurar listeners de sync ANTES de pedir para entrar
    self:SetupListeners()
    
    -- Pedir para entrar
    if self.RemoteEvents.RequestJoin then
        self.RemoteEvents.RequestJoin:FireServer(hostPlayer)
    end
    
    -- Pedir sync completo após delay
    task.delay(2, function()
        if self.RemoteEvents.RequestFullSync then
            self.RemoteEvents.RequestFullSync:FireServer(hostPlayer)
        end
    end)
    
    self.Connected = true
    return true
end

function ConnectionSystem:SetupListeners()
    -- Receber modelo novo
    if self.RemoteEvents.SyncModel then
        self.RemoteEvents.SyncModel.OnClientEvent:Connect(function(modelData)
            ModelReceiver:ReceiveModel(modelData)
        end)
    end
    
    -- Deletar modelo
    if self.RemoteEvents.DeleteModel then
        self.RemoteEvents.DeleteModel.OnClientEvent:Connect(function(modelId)
            ModelReceiver:DeleteModel(modelId)
        end)
    end
    
    -- Atualizar posição
    if self.RemoteEvents.UpdateTransform then
        self.RemoteEvents.UpdateTransform.OnClientEvent:Connect(function(modelId, transform)
            ModelReceiver:UpdateTransform(modelId, transform)
        end)
    end
    
    -- Sync completo
    if self.RemoteEvents.SyncBuild then
        self.RemoteEvents.SyncBuild.OnClientEvent:Connect(function(buildData)
            ModelReceiver:ReceiveFullBuild(buildData)
        end)
    end
    
    -- Novo viewer entrou (apenas informativo)
    if self.RemoteEvents.ViewerJoined then
        self.RemoteEvents.ViewerJoined.OnClientEvent:Connect(function(viewerName)
            NotificationSystem:Show("👤 Novo Viewer", viewerName .. " conectou-se", 3, "INFO")
        end)
    end
end

function ConnectionSystem:AttemptReconnect()
    if self.ReconnectAttempts >= CONFIG.MAX_RECONNECT_ATTEMPTS then
        NotificationSystem:Show("❌ Falha", "Não foi possível conectar ao Host", 5, "ERROR")
        return
    end
    
    self.ReconnectAttempts = self.ReconnectAttempts + 1
    NotificationSystem:Show("🔄 Reconectando...", "Tentativa " .. self.ReconnectAttempts .. "/" .. CONFIG.MAX_RECONNECT_ATTEMPTS, 2, "WARNING")
    
    task.delay(3, function()
        local host = self:FindHost()
        if host then
            self:ConnectToHost(host)
        else
            self:AttemptReconnect()
        end
    end)
end

function ConnectionSystem:Initialize()
    NotificationSystem:Show("🚀 Viewer Client", "v" .. CONFIG.VERSION .. " Iniciando...", 3, "INFO")
    
    -- Aguardar Remotes
    if not self:FindRemotes() then
        NotificationSystem:Show("⏳ Aguardando...", "Aguardando Host criar servidor...", 5, "INFO")
        
        -- Aguardar pasta ser criada
        local connection
        connection = ReplicatedStorage.ChildAdded:Connect(function(child)
            if child.Name == "AGF1_Remotes" then
                connection:Disconnect()
                self:FindRemotes()
                local host = self:FindHost()
                if host then
                    self:ConnectToHost(host)
                else
                    self:AttemptReconnect()
                end
            end
        end)
        
        -- Timeout de 30 segundos
        task.delay(30, function()
            if connection.Connected then
                connection:Disconnect()
                NotificationSystem:Show("❌ Timeout", "Nenhum Host encontrado", 5, "ERROR")
            end
        end)
    else
        -- Remotes já existem, conectar direto
        local host = self:FindHost()
        if host then
            self:ConnectToHost(host)
        else
            self:AttemptReconnect()
        end
    end
    
    -- Ouvir novos jogadores (Host pode entrar depois)
    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer:GetAttribute("AGF1_IsHost") and not self.Connected then
            self:ConnectToHost(newPlayer)
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE RECEBIMENTO DE MODELOS                        ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local ModelReceiver = {
    Models = {},
    SyncFolder = nil
}

function ModelReceiver:GetSyncFolder()
    if not self.SyncFolder then
        self.SyncFolder = Workspace:FindFirstChild("AGF1_View_" .. LocalPlayer.Name)
        if not self.SyncFolder then
            self.SyncFolder = Instance.new("Folder")
            self.SyncFolder.Name = "AGF1_View_" .. LocalPlayer.Name
            self.SyncFolder.Parent = Workspace
        end
    end
    return self.SyncFolder
end

function ModelReceiver:ReceiveModel(modelData)
    if not modelData or not modelData.id then return end
    
    -- Verificar se já existe
    if self.Models[modelData.id] then
        self:UpdateModel(modelData.id, modelData)
        return
    end
    
    -- Criar modelo
    local model = Instance.new("Model")
    model.Name = modelData.name .. "_View"
    model:SetAttribute("AGF1_ModelId", modelData.id)
    model:SetAttribute("AGF1_IsRemote", true)
    model:SetAttribute("AGF1_Timestamp", modelData.timestamp or os.time())
    
    -- Criar partes
    for _, partData in ipairs(modelData.parts or {}) do
        local part = self:CreatePart(partData)
        part.Parent = model
    end
    
    -- Aplicar CFrame
    if modelData.pivot then
        local pivot = CFrame.new(unpack(modelData.pivot))
        model:PivotTo(pivot)
    end
    
    -- Parentear
    model.Parent = self:GetSyncFolder()
    
    -- Adicionar highlight azul (indicando visualização)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ViewerHighlight"
    highlight.Adornee = model
    highlight.FillColor = CONFIG.THEME.primary
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.9
    highlight.OutlineTransparency = 0.3
    highlight.Parent = model
    
    -- Salvar referência
    self.Models[modelData.id] = model
    
    NotificationSystem:Show("📥 Modelo", modelData.name .. " recebido", 2, "INFO")
end

function ModelReceiver:CreatePart(partData)
    local part = Instance.new("Part")
    part.Name = partData.name or "Part"
    part.Size = Vector3.new(unpack(partData.size or {1, 1, 1}))
    part.Position = Vector3.new(unpack(partData.position or {0, 0, 0}))
    part.Orientation = Vector3.new(unpack(partData.orientation or {0, 0, 0}))
    part.Color = Color3.new(unpack(partData.color or {1, 1, 1}))
    part.Material = Enum.Material[partData.material] or Enum.Material.SmoothPlastic
    part.Transparency = partData.transparency or 0
    part.Anchored = true
    part.CanCollide = true
    part.CanTouch = false
    part.CanQuery = true
    part.Locked = true -- Impedir edição
    
    -- Forma
    if partData.shape == "Cylinder" then
        part.Shape = Enum.PartType.Cylinder
    elseif partData.shape == "Ball" then
        part.Shape = Enum.PartType.Ball
    end
    
    return part
end

function ModelReceiver:UpdateModel(modelId, modelData)
    local model = self.Models[modelId]
    if not model then return end
    
    -- Atualizar CFrame
    if modelData.pivot then
        local pivot = CFrame.new(unpack(modelData.pivot))
        model:PivotTo(pivot)
    end
end

function ModelReceiver:UpdateTransform(modelId, transform)
    local model = self.Models[modelId]
    if not model then return end
    
    local newCFrame = CFrame.new(unpack(transform))
    model:PivotTo(newCFrame)
end

function ModelReceiver:DeleteModel(modelId)
    local model = self.Models[modelId]
    if model then
        model:Destroy()
        self.Models[modelId] = nil
    end
end

function ModelReceiver:ReceiveFullBuild(buildData)
    if not buildData or not buildData.models then return end
    
    -- Limpar modelos antigos
    self:ClearAll()
    
    -- Carregar todos
    for _, modelData in ipairs(buildData.models) do
        self:ReceiveModel(modelData)
    end
    
    NotificationSystem:Show("📦 Sync Completo", 
        #buildData.models .. " modelos de " .. (buildData.hostName or "Host"), 
        5, "SUCCESS")
end

function ModelReceiver:ClearAll()
    for id, model in pairs(self.Models) do
        if model then
            model:Destroy()
        end
    end
    self.Models = {}
    
    if self.SyncFolder then
        self.SyncFolder:ClearAllChildren()
    end
end

function ModelReceiver:GetStats()
    local count = 0
    local parts = 0
    for _, model in pairs(self.Models) do
        count = count + 1
        parts = parts + #model:GetDescendants()
    end
    return count, parts
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     INTERFACE DO VIEWER                                      ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local ViewerUI = {
    Gui = nil,
    Visible = true
}

function ViewerUI:Create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AGF1_ViewerClientUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = CoreGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 180)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = CONFIG.THEME.background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = CONFIG.THEME.primary
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    
    -- Header
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 16)
    
    local headerBottom = Instance.new("Frame", header)
    headerBottom.Size = UDim2.new(1, 0, 0, 20)
    headerBottom.Position = UDim2.new(0, 0, 1, -20)
    headerBottom.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    headerBottom.BackgroundTransparency = 0.3
    headerBottom.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 15, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "👁️ VIEWER CLIENT v" .. CONFIG.VERSION
    title.TextColor3 = CONFIG.THEME.accent
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Status
    local statusFrame = Instance.new("Frame", mainFrame)
    statusFrame.Size = UDim2.new(1, -30, 0, 90)
    statusFrame.Position = UDim2.new(0, 15, 0, 55)
    statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    statusFrame.BackgroundTransparency = 0.5
    statusFrame.BorderSizePixel = 0
    
    local statusCorner = Instance.new("UICorner", statusFrame)
    statusCorner.CornerRadius = UDim.new(0, 12)
    
    local statusText = Instance.new("TextLabel", statusFrame)
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -20, 1, -20)
    statusText.Position = UDim2.new(0, 10, 0, 10)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: Inicializando...\nHost: Procurando...\nModelos: 0 | Partes: 0"
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextSize = 13
    statusText.TextWrapped = true
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Botões
    local buttonFrame = Instance.new("Frame", mainFrame)
    buttonFrame.Size = UDim2.new(1, -30, 0, 35)
    buttonFrame.Position = UDim2.new(0, 15, 1, -45)
    buttonFrame.BackgroundTransparency = 1
    
    local buttonLayout = Instance.new("UIListLayout", buttonFrame)
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.Padding = UDim.new(0, 10)
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Botão FreeCam
    local freeCamBtn = Instance.new("TextButton")
    freeCamBtn.Size = UDim2.new(0, 130, 1, 0)
    freeCamBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    freeCamBtn.Text = "📷 FreeCam (F4)"
    freeCamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    freeCamBtn.Font = Enum.Font.GothamBold
    freeCamBtn.TextSize = 12
    freeCamBtn.Parent = buttonFrame
    
    local btnCorner1 = Instance.new("UICorner", freeCamBtn)
    btnCorner1.CornerRadius = UDim.new(0, 8)
    
    -- Botão Limpar
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 130, 1, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.Text = "🗑️ Limpar (F5)"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 12
    clearBtn.Parent = buttonFrame
    
    local btnCorner2 = Instance.new("UICorner", clearBtn)
    btnCorner2.CornerRadius = UDim.new(0, 8)
    
    -- Ações dos botões
    freeCamBtn.MouseButton1Click:Connect(function()
        FreeCamSystem:Toggle()
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        ModelReceiver:ClearAll()
        NotificationSystem:Show("🗑️ Limpo", "Todos os modelos removidos", 2, "INFO")
    end)
    
    -- Atualização automática do status
    task.spawn(function()
        while statusText and statusText.Parent do
            local modelCount, partCount = ModelReceiver:GetStats()
            local hostName = ConnectionSystem.HostPlayer and ConnectionSystem.HostPlayer.Name or "Nenhum"
            local status = ConnectionSystem.Connected and "✅ Conectado" or "⏳ Aguardando..."
            
            statusText.Text = string.format(
                "Status: %s\nHost: %s\nModelos: %d | Partes: %d\nPing: %dms",
                status,
                hostName,
                modelCount,
                partCount,
                math.random(20, 80) -- Simulado, em produção seria real
            )
            task.wait(1)
        end
    end)
    
    self.Gui = gui
    self.StatusText = statusText
    return gui
end

function ViewerUI:Toggle()
    self.Visible = not self.Visible
    if self.Gui then
        self.Gui.Enabled = self.Visible
    end
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE CÂMERA LIVRE                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local FreeCamSystem = {
    Enabled = false,
    Pos = Vector3.new(0, 50, 0),
    Rot = Vector2.new(0, 0),
    Connection = nil,
    Speed = CONFIG.FREE_CAM_SPEED
}

function FreeCamSystem:Toggle()
    if self.Enabled then
        self:Disable()
    else
        self:Enable()
    end
end

function FreeCamSystem:Enable()
    if self.Enabled then return end
    
    self.Enabled = true
    self.Pos = Camera.CFrame.Position
    
    Camera.CameraType = Enum.CameraType.Scriptable
    
    local lastMousePos = UserInputService:GetMouseLocation()
    
    self.Connection = RunService.RenderStepped:Connect(function(dt)
        if not self.Enabled then return end
        
        -- Movimento WASD
        local moveVec = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVec = moveVec + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVec = moveVec - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVec = moveVec - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVec = moveVec + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveVec = moveVec + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveVec = moveVec - Vector3.new(0, 1, 0)
        end
        
        -- Velocidade
        local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) 
            and CONFIG.FREE_CAM_FAST_SPEED 
            or CONFIG.FREE_CAM_SPEED
        
        if moveVec.Magnitude > 0 then
            self.Pos = self.Pos + (moveVec.Unit * speed * dt)
        end
        
        -- Rotação com mouse direito
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseRight) then
            local currentPos = UserInputService:GetMouseLocation()
            local delta = currentPos - lastMousePos
            self.Rot = self.Rot + Vector2.new(delta.X, delta.Y) * 0.3
            lastMousePos = currentPos
        else
            lastMousePos = UserInputService:GetMouseLocation()
        end
        
        -- Aplicar CFrame
        Camera.CFrame = CFrame.new(self.Pos) 
            * CFrame.Angles(0, math.rad(self.Rot.X), 0) 
            * CFrame.Angles(math.rad(math.clamp(self.Rot.Y, -80, 80)), 0, 0)
    end)
    
    NotificationSystem:Show("📷 Câmera Livre", 
        "WASD: Mover | Q/E: Subir/Descer | Shift: Rápido | F4: Desligar", 
        4, "INFO")
end

function FreeCamSystem:Disable()
    self.Enabled = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    Camera.CameraType = Enum.CameraType.Custom
    NotificationSystem:Show("📷 Câmera", "Câmera livre desativada", 2, "INFO")
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     ATALHOS DE TECLADO                                       ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        ViewerUI:Toggle()
    elseif input.KeyCode == Enum.KeyCode.F4 then
        FreeCamSystem:Toggle()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        ModelReceiver:ClearAll()
        NotificationSystem:Show("🗑️ Limpo", "Modelos removidos", 2, "INFO")
    elseif input.KeyCode == Enum.KeyCode.F6 then
        -- Recentralizar no host
        if ConnectionSystem.HostPlayer and ConnectionSystem.HostPlayer.Character then
            FreeCamSystem:Disable()
            local hrp = ConnectionSystem.HostPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 20, 30), hrp.Position)
            end
        end
    end
end)

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     INICIALIZAÇÃO                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local function Initialize()
    -- Criar UI
    ViewerUI:Create()
    
    -- Iniciar conexão
    ConnectionSystem:Initialize()
    
    -- Mensagem inicial
    print("[AGF1 Viewer] Client v" .. CONFIG.VERSION .. " carregado")
    print("[AGF1 Viewer] Controles: F3=UI | F4=FreeCam | F5=Limpar | F6=Host")
end

-- Aguardar personagem carregar
if LocalPlayer.Character then
    Initialize()
else
    LocalPlayer.CharacterAdded:Connect(function()
        task.delay(1, Initialize)
    end)
end

-- Exportar global para debug
getgenv().AGF1_Viewer = {
    Config = CONFIG,
    Connection = ConnectionSystem,
    Models = ModelReceiver,
    UI = ViewerUI,
    FreeCam = FreeCamSystem,
    Notify = NotificationSystem
}
