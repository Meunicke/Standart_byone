--// aquilesgamef1 Viewer Client v1.0
--// Script standalone para espectadores
--// Compatível com aquilesgamef1 Hub v4.2+

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

--// SAFE INITIALIZATION
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)

--// REMOTES SETUP (Mesmos nomes do Hub)
local Remotes = ReplicatedStorage:WaitForChild("AGF1_Remotes", 10)
if not Remotes then
    -- Criar se não existir (caso execute antes do Host)
    Remotes = Instance.new("Folder")
    Remotes.Name = "AGF1_Remotes"
    Remotes.Parent = ReplicatedStorage
end

local function GetRemote(name, className)
    className = className or "RemoteEvent"
    local remote = Remotes:FindFirstChild(name)
    if not remote then
        remote = Instance.new(className)
        remote.Name = name
        remote.Parent = Remotes
    end
    return remote
end

local HostAnnounceRemote = GetRemote("HostAnnounce", "RemoteEvent")
local ViewerJoinRemote = GetRemote("ViewerJoin", "RemoteEvent")
local ViewerLeaveRemote = GetRemote("ViewerLeave", "RemoteEvent")
local SyncModelRemote = GetRemote("SyncModel", "RemoteEvent")
local RequestModelRemote = GetRemote("RequestModel", "RemoteEvent")

--// VIEWER STATE
local Viewer = {
    Connected = false,
    HostPlayer = nil,
    FreeCam = false,
    Camera = Workspace.CurrentCamera,
    FreeCamCFrame = CFrame.new(),
    Movement = Vector3.new(),
    Speed = 50,
    ShiftSpeed = 100,
    Sensitivity = 0.3,
    ReceivedParts = 0,
    LastSync = 0
}

--// UTILITY
local function CreateInstance(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

local function Notify(title, text, duration)
    duration = duration or 3
    local screenGui = PlayerGui:FindFirstChild("AGF1_Viewer_GUI")
    if not screenGui then return end
    
    local notif = CreateInstance("Frame", {
        Size = UDim2.new(0, 320, 0, 70),
        Position = UDim2.new(1, 20, 1, -90),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        BorderSizePixel = 0,
        Parent = screenGui
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notif})
    CreateInstance("UIStroke", {Color = Color3.fromRGB(0, 170, 255), Thickness = 1, Parent = notif})
    
    local tTitle = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(0, 170, 255),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    local tText = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 28),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -340, 1, -90)
    }):Play()
    
    task.delay(duration, function()
        local tween = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 1, -90)
        })
        tween:Play()
        tween.Completed:Connect(function() notif:Destroy() end)
    end)
end

--// DESERIALIZE (Mesma função do Hub para compatibilidade)
local function DeserializeModel(data, parent)
    if not data or not data.ClassName then return nil end
    
    local obj
    pcall(function()
        if data.ClassName == "Model" then
            obj = Instance.new("Model")
            obj.Name = data.Name or "Model"
            obj.Parent = parent
        elseif data.ClassName == "Part" or data.ClassName == "WedgePart" or data.ClassName == "CornerWedgePart" or data.ClassName == "UnionOperation" then
            obj = Instance.new(data.ClassName)
            obj.Name = data.Name or "Part"
            if data.Properties then
                local p = data.Properties
                if p.Size then obj.Size = Vector3.new(unpack(p.Size)) end
                if p.Position then obj.Position = Vector3.new(unpack(p.Position)) end
                if p.Rotation then obj.Rotation = Vector3.new(unpack(p.Rotation)) end
                if p.Color then obj.Color = Color3.new(unpack(p.Color)) end
                if p.Material then 
                    pcall(function() obj.Material = Enum.Material[p.Material] end)
                end
                if p.Transparency ~= nil then obj.Transparency = p.Transparency end
                if p.Reflectance ~= nil then obj.Reflectance = p.Reflectance end
                if p.CanCollide ~= nil then obj.CanCollide = p.CanCollide end
                if p.Anchored ~= nil then obj.Anchored = p.Anchored end
            end
            obj.Parent = parent
        elseif data.ClassName == "VehicleSeat" or data.ClassName == "Seat" then
            obj = Instance.new(data.ClassName)
            obj.Name = data.Name or "Seat"
            if data.Properties then
                local p = data.Properties
                if p.Position then obj.Position = Vector3.new(unpack(p.Position)) end
                if p.Rotation then obj.Rotation = Vector3.new(unpack(p.Rotation)) end
            end
            obj.Parent = parent
        end
        
        if obj and data.Children then
            for _, childData in ipairs(data.Children) do
                DeserializeModel(childData, obj)
            end
        end
    end)
    
    return obj
end

--// CLEAR WORKSPACE (Preserva personagem e terreno)
local function ClearBuild()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name ~= "Terrain" and obj.Name ~= "CameraLocation" then
            if not obj:IsDescendantOf(LocalPlayer.Character) then
                pcall(function() obj:Destroy() end)
            end
        elseif obj:IsA("Model") and obj.Name ~= LocalPlayer.Name then
            if not obj:IsDescendantOf(LocalPlayer.Character) then
                pcall(function() obj:Destroy() end)
            end
        elseif obj:IsA("Folder") and obj.Name ~= "AGF1_Viewer_Preserve" then
            if not obj:IsDescendantOf(LocalPlayer.Character) then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

--// FREE CAMERA SYSTEM
local FreeCamActive = false
local FreeCamConnection = nil

local function StartFreeCam()
    if FreeCamActive then return end
    FreeCamActive = true
    Viewer.FreeCam = true
    
    local camera = Workspace.CurrentCamera
    Viewer.FreeCamCFrame = camera.CFrame
    
    local input = {}
    local velocity = Vector3.new()
    local rotation = Vector2.new()
    
    -- Desabilitar controles normais
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    
    -- Esconder personagem se existir
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
            end
        end
    end
    
    FreeCamConnection = RunService.RenderStepped:Connect(function(dt)
        local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Viewer.ShiftSpeed or Viewer.Speed
        
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move + Vector3.new(0, -1, 0) end
        
        if move.Magnitude > 0 then
            move = move.Unit
        end
        
        velocity = velocity:Lerp(move * speed, math.clamp(dt * 10, 0, 1))
        Viewer.FreeCamCFrame = Viewer.FreeCamCFrame * CFrame.new(velocity * dt)
        
        -- Aplicar rotação
        local mouseDelta = UserInputService:GetMouseDelta()
        rotation = rotation + Vector2.new(mouseDelta.X, mouseDelta.Y) * Viewer.Sensitivity
        
        Viewer.FreeCamCFrame = CFrame.new(Viewer.FreeCamCFrame.Position) 
            * CFrame.Angles(0, math.rad(-rotation.X), 0) 
            * CFrame.Angles(math.rad(-rotation.Y), 0, 0)
        
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = Viewer.FreeCamCFrame
    end)
    
    Notify("FreeCam", "Modo espectador ativado\nWASD para mover | Q/E para subir/descer | Shift para velocidade", 4)
end

local function StopFreeCam()
    if not FreeCamActive then return end
    FreeCamActive = false
    Viewer.FreeCam = false
    
    if FreeCamConnection then
        FreeCamConnection:Disconnect()
        FreeCamConnection = nil
    end
    
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            Workspace.CurrentCamera.CameraSubject = humanoid
        end
        
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
    
    Notify("FreeCam", "Modo espectador desativado", 2)
end

--// GUI DO VIEWER
local ScreenGui = CreateInstance("ScreenGui", {
    Name = "AGF1_Viewer_GUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui
})

local MainFrame = CreateInstance("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 350, 0, 200),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0,
    Parent = ScreenGui
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
CreateInstance("UIStroke", {Color = Color3.fromRGB(0, 170, 255), Thickness = 1, Parent = MainFrame})

local TitleBar = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    BorderSizePixel = 0,
    Parent = MainFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TitleBar})

local TitleText = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "AGF1 Viewer v1.0",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

local StatusIndicator = CreateInstance("Frame", {
    Size = UDim2.new(0, 12, 0, 12),
    Position = UDim2.new(1, -60, 0, 11),
    BackgroundColor3 = Color3.fromRGB(255, 50, 50),
    BorderSizePixel = 0,
    Parent = TitleBar
})
CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0), Parent = StatusIndicator})

local StatusText = CreateInstance("TextLabel", {
    Size = UDim2.new(0, 40, 0, 20),
    Position = UDim2.new(1, -45, 0, 7),
    BackgroundTransparency = 1,
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 100, 100),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})

local CloseBtn = CreateInstance("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -32, 0, 3),
    BackgroundColor3 = Color3.fromRGB(255, 70, 70),
    Text = "X",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseBtn})

local Content = CreateInstance("Frame", {
    Size = UDim2.new(1, -20, 1, -50),
    Position = UDim2.new(0, 10, 0, 42),
    BackgroundTransparency = 1,
    Parent = MainFrame
})

local HostLabel = CreateInstance("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "Host: Procurando...",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 13,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Content
})

local PartsLabel = CreateInstance("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "Parts: 0",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Content
})

local SyncLabel = CreateInstance("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundTransparency = 1,
    Text = "Ultimo Sync: Nunca",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Content
})

local FreeCamBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.new(0, 0, 0, 72),
    BackgroundColor3 = Color3.fromRGB(0, 100, 200),
    Text = "Ativar FreeCam",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = Content
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = FreeCamBtn})

local DisconnectBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.new(0, 0, 0, 110),
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    Text = "Desconectar",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = Content
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DisconnectBtn})

local MinimizeBtn = CreateInstance("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -65, 0, 2),
    BackgroundTransparency = 1,
    Text = "-",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})

--// DRAG SYSTEM
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--// CONNECTION LOGIC
local function SetConnected(connected, hostName)
    Viewer.Connected = connected
    if connected then
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        StatusText.Text = "ON"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        HostLabel.Text = "Host: " .. (hostName or "Conectado")
        Notify("Conectado", "Visualizando build de: " .. (hostName or "Host"), 3)
    else
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        StatusText.Text = "OFF"
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        HostLabel.Text = "Host: Desconectado"
        Viewer.HostPlayer = nil
    end
end

local function ConnectToHost(hostPlayer)
    if Viewer.Connected then return end
    
    Viewer.HostPlayer = hostPlayer
    SetConnected(true, hostPlayer.Name)
    
    -- Notificar Host que viewer entrou
    ViewerJoinRemote:FireServer(hostPlayer)
    
    -- Solicitar build atual
    task.delay(1, function()
        if Viewer.Connected and Viewer.HostPlayer then
            RequestModelRemote:FireServer(Viewer.HostPlayer)
        end
    end)
end

local function Disconnect()
    if not Viewer.Connected then return end
    
    if Viewer.HostPlayer then
        ViewerLeaveRemote:FireServer(Viewer.HostPlayer)
    end
    
    SetConnected(false)
    ClearBuild()
    StopFreeCam()
    Notify("Desconectado", "Sessão de visualização encerrada", 3)
end

--// REMOTE EVENT HANDLERS

-- Host anunciando disponibilidade
HostAnnounceRemote.OnClientEvent:Connect(function(player, message)
    if player == LocalPlayer then return end
    if message == "HOST_ANNOUNCE" and not Viewer.Connected then
        -- Auto-conectar ao primeiro Host encontrado
        ConnectToHost(player)
    end
end)

-- Recebendo sync de modelos
SyncModelRemote.OnClientEvent:Connect(function(player, modelData)
    if not Viewer.Connected then return end
    if Viewer.HostPlayer and player ~= Viewer.HostPlayer then return end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(modelData)
    end)
    
    if success and data then
        ClearBuild()
        local count = 0
        
        if typeof(data) == "table" then
            for _, partData in ipairs(data) do
                local obj = DeserializeModel(partData, Workspace)
                if obj then
                    count = count + 1
                end
            end
        end
        
        Viewer.ReceivedParts = count
        Viewer.LastSync = tick()
        PartsLabel.Text = "Parts: " .. count
        SyncLabel.Text = "Ultimo Sync: " .. os.date("%H:%M:%S")
        
        Notify("Sync", "Build atualizado: " .. count .. " partes recebidas", 2)
    end
end)

--// BUTTON HANDLERS
FreeCamBtn.MouseButton1Click:Connect(function()
    if FreeCamActive then
        StopFreeCam()
        FreeCamBtn.Text = "Ativar FreeCam"
        FreeCamBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    else
        StartFreeCam()
        FreeCamBtn.Text = "Desativar FreeCam"
        FreeCamBtn.BackgroundColor33 = Color3.fromRGB(200, 100, 0)
    end
end)

DisconnectBtn.MouseButton1Click:Connect(Disconnect)

CloseBtn.MouseButton1Click:Connect(function()
    Disconnect()
    ScreenGui:Destroy()
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 350, 0, 35) or UDim2.new(0, 350, 0, 200)
end)

--// TECLAS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F4 then
        if FreeCamActive then
            StopFreeCam()
            FreeCamBtn.Text = "Ativar FreeCam"
            FreeCamBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        else
            StartFreeCam()
            FreeCamBtn.Text = "Desativar FreeCam"
            FreeCamBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--// AUTO-DISCOVERY LOOP
task.spawn(function()
    while true do
        task.wait(3)
        
        -- Se não estiver conectado, procurar Host
        if not Viewer.Connected then
            -- Verificar se há algum host na sessão
            -- O Host deve ter anunciado via HostAnnounceRemote
            -- Se nada acontecer em 10s, tentar broadcast
            if tick() % 10 < 3 then
                -- Enviar pedido de descoberta
                ViewerJoinRemote:FireServer("DISCOVER_HOSTS")
            end
        end
        
        -- Atualizar UI
        if Viewer.Connected and Viewer.LastSync > 0 then
            local elapsed = math.floor(tick() - Viewer.LastSync)
            SyncLabel.Text = "Ultimo Sync: " .. elapsed .. "s atrás"
        end
    end
end)

--// INIT
task.delay(1, function()
    Notify("Viewer Client", "Procurando Host... Aguarde o builder iniciar o Host Mode.", 4)
    
    -- Tentar encontrar host já existente
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Não podemos ver atributos, mas podemos esperar anúncio
            break
        end
    end
end)

print("[AGF1 Viewer] Client v1.0 carregado | Aguardando Host...")
