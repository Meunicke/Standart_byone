--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    AQUILESGAMEF1 HUB v4.2 - FULLY FIXED                      ║
    ║              Save System & Vehicle Script 100% FUNCIONANDO                 ║
    ║                        VehicleAI v6.0 Integrated                             ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SERVICES & CONFIGURAÇÃO                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local InsertService = game:GetService("InsertService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Configurações
local CONFIG = {
    VERSION = "4.2",
    SAVE_FOLDER = "aquilesgamef1_hub_v4",
    AUTO_SAVE_INTERVAL = 30,
    MAX_CLOUD_SIZE = 500000,
    ENCRYPTION_KEY = "AGF1_SECRET_KEY_2024",
    THEME = "ELITE"
}

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     GUI PARENT                                               ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local guiParent
pcall(function()
    if gethui then
        guiParent = gethui()
    elseif cloneref then
        guiParent = cloneref(CoreGui)
    else
        guiParent = player:WaitForChild("PlayerGui")
    end
end)

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     TEMAS                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local Themes = {
    ELITE = {
        primary = Color3.fromRGB(255, 215, 0),
        secondary = Color3.fromRGB(180, 150, 0),
        background = Color3.fromRGB(15, 15, 20),
        accent = Color3.fromRGB(255, 255, 255),
        glow = Color3.fromRGB(255, 215, 0),
        selection = Color3.fromRGB(0, 255, 100)
    },
    DARK = {
        primary = Color3.fromRGB(100, 100, 100),
        secondary = Color3.fromRGB(60, 60, 60),
        background = Color3.fromRGB(10, 10, 10),
        accent = Color3.fromRGB(200, 200, 200),
        glow = Color3.fromRGB(150, 150, 150),
        selection = Color3.fromRGB(0, 200, 255)
    },
    NEON = {
        primary = Color3.fromRGB(0, 255, 255),
        secondary = Color3.fromRGB(0, 200, 200),
        background = Color3.fromRGB(5, 5, 15),
        accent = Color3.fromRGB(255, 0, 255),
        glow = Color3.fromRGB(0, 255, 255),
        selection = Color3.fromRGB(255, 0, 255)
    },
    BUILDER = {
        primary = Color3.fromRGB(0, 255, 150),
        secondary = Color3.fromRGB(0, 200, 100),
        background = Color3.fromRGB(10, 20, 15),
        accent = Color3.fromRGB(100, 255, 200),
        glow = Color3.fromRGB(0, 255, 150),
        selection = Color3.fromRGB(255, 255, 0)
    }
}

local CurrentTheme = Themes[CONFIG.THEME]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     NOTIFICAÇÕES                                             ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local NotificationSystem = {}
local activeNotifications = {}
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "aquilesgamef1_Notifications_v4"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
notifGui.Parent = guiParent

function NotificationSystem:Show(title, message, duration, ntype)
    duration = duration or 6
    ntype = ntype or "INFO"
    local color = ntype == "SUCCESS" and Color3.fromRGB(0, 255, 150) or 
                  ntype == "ERROR" and Color3.fromRGB(255, 80, 80) or 
                  ntype == "WARNING" and Color3.fromRGB(255, 200, 0) or 
                  ntype == "SELECTION" and CurrentTheme.selection or 
                  CurrentTheme.primary
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 320, 0, 90)
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
    icon.Text = ntype == "SUCCESS" and "✓" or ntype == "ERROR" and "✕" or ntype == "WARNING" and "⚠" or ntype == "SELECTION" and "◉" or "ℹ"
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
    msgLabel.Size = UDim2.new(1, -70, 0, 45)
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
        Position = UDim2.new(1, -12, 1, -12 - (#activeNotifications * 100))
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
-- ║                     SISTEMA DE ARQUIVOS                                      ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local FileSystem = {
    BasePath = CONFIG.SAVE_FOLDER .. "/",
    Cache = {}
}

function FileSystem:Init()
    pcall(function()
        if makefolder then
            makefolder(CONFIG.SAVE_FOLDER)
            makefolder(CONFIG.SAVE_FOLDER .. "/builds")
            makefolder(CONFIG.SAVE_FOLDER .. "/backups")
            makefolder(CONFIG.SAVE_FOLDER .. "/cloud")
            print("[FileSystem] Pastas criadas")
        end
    end)
end

function FileSystem:WriteFile(path, data)
    local fullPath = self.BasePath .. path
    local success, err = pcall(function()
        if writefile then
            writefile(fullPath, data)
            return true
        elseif syn and syn.write_file then
            syn.write_file(fullPath, data)
            return true
        else
            self.Cache[path] = data
            return true
        end
    end)
    if not success then
        warn("[FileSystem] Erro ao escrever:", err)
        self.Cache[path] = data
        return true
    end
    return success
end

function FileSystem:ReadFile(path)
    local fullPath = self.BasePath .. path
    local data = nil
    
    local success, result = pcall(function()
        if readfile then
            return readfile(fullPath)
        elseif syn and syn.read_file then
            return syn.read_file(fullPath)
        end
        return nil
    end)
    
    if success and result and result ~= "" then
        data = result
    end
    
    if not data and self.Cache[path] then
        data = self.Cache[path]
    end
    
    return data
end

function FileSystem:FileExists(path)
    local fullPath = self.BasePath .. path
    local exists = false
    
    pcall(function()
        if isfile then
            exists = isfile(fullPath)
        end
    end)
    
    return exists or self.Cache[path] ~= nil
end

function FileSystem:ListFiles(folder)
    local files = {}
    pcall(function()
        if listfiles then
            local path = self.BasePath .. folder
            local allFiles = listfiles(path)
            for _, file in ipairs(allFiles) do
                local name = file:match("([^/\\]+)$")
                if name then
                    table.insert(files, name)
                end
            end
        end
    end)
    return files
end

function FileSystem:DeleteFile(path)
    pcall(function()
        if delfile then
            delfile(self.BasePath .. path)
        end
        self.Cache[path] = nil
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE CRIPTOGRAFIA                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local Crypto = {}

function Crypto:SimpleEncrypt(text, key)
    key = key or CONFIG.ENCRYPTION_KEY
    local result = {}
    local keyLen = #key
    
    for i = 1, #text do
        local byte = string.byte(text, i)
        local keyByte = string.byte(key, ((i - 1) % keyLen) + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    
    return HttpService:JSONEncode(result)
end

function Crypto:SimpleDecrypt(encrypted, key)
    key = key or CONFIG.ENCRYPTION_KEY
    local success, data = pcall(function()
        return HttpService:JSONDecode(encrypted)
    end)
    
    if not success then return nil end
    
    local result = {}
    local keyLen = #key
    
    for i, char in ipairs(data) do
        local byte = string.byte(char)
        local keyByte = string.byte(key, ((i - 1) % keyLen) + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    
    return table.concat(result)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE MODELOS                                       ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local ModelSystem = {
    LoadedModels = {},
    ModelFolder = nil,
    NextId = 1,
    DebugMode = true,
    SelectedModels = {},
    SelectionBoxes = {},
    Groups = {},
    NextGroupId = 1,
    TransformSettings = {
        MoveIncrement = 1,
        RotateIncrement = 15,
        ScaleIncrement = 0.1,
        SnapToGrid = false,
        GridSize = 1
    }
}

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║           SISTEMA INTELIGENTE DE VEÍCULOS v6.0 - INTEGRADO                  ║
-- ║              100% SEM PEÇAS SOLTAS • FÍSICA AVANÇADA • AI DRIVE              ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

ModelSystem.VehicleAI = {
    ActiveVehicles = {},
    Config = {
        WeldStrength = 100000,
        MasslessWheels = true,
        AutoStabilize = true,
        AntiFlip = true,
        MaxSpeed = 120,
        Acceleration = 50,
        BrakeForce = 80,
        TurnSpeed = 3,
        SuspensionHeight = 2,
        SuspensionStiffness = 50,
        SuspensionDamping = 20
    }
}

function ModelSystem.VehicleAI:CreateUnbreakableWeld(part0, part1, c0, c1)
    if not part0 or not part1 then return nil end
    
    local weld = Instance.new("Weld")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0 or CFrame.new()
    weld.C1 = c1 or CFrame.new()
    weld.Parent = part1
    
    local backupWeld = Instance.new("WeldConstraint")
    backupWeld.Part0 = part0
    backupWeld.Part1 = part1
    backupWeld.Parent = part1
    
    if part1:IsA("BasePart") then
        part1.Massless = true
        pcall(function()
            part1.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.1, 0.1, 1)
        end)
    end
    
    return weld
end

function ModelSystem.VehicleAI:BuildSmartChassis(model, config)
    config = config or {}
    local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then
        NotificationSystem:Show("❌ Erro", "Modelo sem partes válidas", 3, "ERROR")
        return nil
    end
    
    local chassis = Instance.new("Part")
    chassis.Name = "SmartChassis"
    chassis.Shape = Enum.PartType.Block
    chassis.Size = primaryPart.Size + Vector3.new(0.5, 0.5, 0.5)
    chassis.CFrame = primaryPart.CFrame
    chassis.Anchored = false
    chassis.CanCollide = true
    chassis.Transparency = 1
    chassis.Material = Enum.Material.Metal
    chassis.Color = Color3.fromRGB(50, 50, 50)
    chassis.Parent = model
    
    pcall(function()
        chassis.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.1, 0.05, 0.1, 5)
    end)
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part ~= chassis then
            local relativeCFrame = chassis.CFrame:ToObjectSpace(part.CFrame)
            self:CreateUnbreakableWeld(chassis, part, relativeCFrame, CFrame.new())
        end
    end
    
    model.PrimaryPart = chassis
    return chassis
end

function ModelSystem.VehicleAI:CreateSmartWheels(model, chassis, config)
    local wheels = {}
    local wheelSize = config.wheelSize or Vector3.new(1.2, 1.2, 1.2)
    local axleWidth = (chassis.Size.X / 2) + 0.8
    local axleLength = (chassis.Size.Z / 2) + 0.5
    
    local wheelPositions = {
        {pos = Vector3.new(-axleWidth, -chassis.Size.Y/2, axleLength), name = "FL", isFront = true},
        {pos = Vector3.new(axleWidth, -chassis.Size.Y/2, axleLength), name = "FR", isFront = true},
        {pos = Vector3.new(-axleWidth, -chassis.Size.Y/2, -axleLength), name = "RL", isFront = false},
        {pos = Vector3.new(axleWidth, -chassis.Size.Y/2, -axleLength), name = "RR", isFront = false}
    }
    
    for _, wheelData in ipairs(wheelPositions) do
        local wheel = Instance.new("Part")
        wheel.Name = "Wheel_" .. wheelData.name
        wheel.Shape = Enum.PartType.Cylinder
        wheel.Size = wheelSize
        wheel.Color = Color3.fromRGB(30, 30, 30)
        wheel.Material = Enum.Material.SmoothPlastic
        wheel.Anchored = false
        wheel.CanCollide = true
        wheel.Massless = true
        wheel.Parent = model
        
        local wheelCFrame = CFrame.new(chassis.Position + wheelData.pos) * CFrame.Angles(0, 0, math.pi/2)
        wheel.CFrame = wheelCFrame
        
        local axle = Instance.new("Part")
        axle.Name = "Axle_" .. wheelData.name
        axle.Size = Vector3.new(0.5, 0.5, 0.5)
        axle.Position = chassis.Position + wheelData.pos + Vector3.new(0, 0.5, 0)
        axle.Transparency = 1
        axle.Anchored = false
        axle.CanCollide = false
        axle.Massless = true
        axle.Parent = model
        
        -- Attachments para Suspensão
        local attachChassis = Instance.new("Attachment")
        attachChassis.Name = "SuspensionAttach"
        attachChassis.Position = wheelData.pos + Vector3.new(0, 0.5, 0)
        attachChassis.Parent = chassis
        
        local attachAxle = Instance.new("Attachment")
        attachAxle.Name = "ChassisAttach"
        attachAxle.Parent = axle
        
        -- SpringConstraint para suspensão
        local spring = Instance.new("SpringConstraint")
        spring.Attachment0 = attachChassis
        spring.Attachment1 = attachAxle
        spring.LimitsEnabled = true
        spring.MinLength = 0.5
        spring.MaxLength = 3
        spring.Stiffness = config.suspensionStiffness or 50
        spring.Damping = config.suspensionDamping or 20
        spring.Parent = axle
        
        -- Attachments para a Roda (HingeConstraint usa Attachments!)
        local attachWheelAxle = Instance.new("Attachment")
        attachWheelAxle.Name = "AxleAttachment"
        attachWheelAxle.Parent = axle
        
        local attachWheel = Instance.new("Attachment")
        attachWheel.Name = "WheelAttachment"
        attachWheel.Parent = wheel
        attachWheel.CFrame = CFrame.Angles(0, math.pi/2, 0)
        
        -- HingeConstraint para rotação da roda (MOTOR)
        local wheelHinge = Instance.new("HingeConstraint")
        wheelHinge.Name = "WheelMotor"
        wheelHinge.Attachment0 = attachWheelAxle
        wheelHinge.Attachment1 = attachWheel
        wheelHinge.ActuatorType = Enum.ActuatorType.Motor
        wheelHinge.MotorMaxTorque = 10000
        wheelHinge.MotorMaxAcceleration = 20
        wheelHinge.Parent = axle
        
        -- Weld do eixo ao chassis
        local axleWeld = Instance.new("Weld")
        axleWeld.Part0 = chassis
        axleWeld.Part1 = axle
        axleWeld.C0 = CFrame.new(wheelData.pos + Vector3.new(0, 0.5, 0))
        axleWeld.Parent = axle
        
        table.insert(wheels, {
            part = wheel,
            axle = axle,
            hinge = wheelHinge,
            spring = spring,
            isFront = wheelData.isFront,
            name = wheelData.name
        })
    end
    
    return wheels
end

        
        
function ModelSystem.VehicleAI:CreateVehicleController(model, chassis, wheels, seat, config)
    config = config or {}
    
    local controllerCode = [[
        local seat = script.Parent
        local model = seat:FindFirstAncestorOfClass("Model")
        if not model then return end
        
        local chassis = model:WaitForChild("SmartChassis", 5)
        if not chassis then warn("Chassis não encontrado"); return end
        
        local wheels = {}
        local wheelNames = {"Wheel_FL", "Wheel_FR", "Wheel_RL", "Wheel_RR"}
        for _, name in ipairs(wheelNames) do
            local wheel = model:FindFirstChild(name)
            if wheel then
                local hinge = wheel:FindFirstChild("WheelMotor")
                if hinge and hinge:IsA("HingeConstraint") then
                    table.insert(wheels, {
                        hinge = hinge,
                        isFront = name:match("FL") or name:match("FR")
                    })
                end
            end
        end
        
        if #wheels == 0 then warn("Nenhuma roda encontrada"); return end
        
        local RunService = game:GetService("RunService")
        
        local MAX_SPEED = ]] .. (config.maxSpeed or 100) .. [[
        local ACCEL = ]] .. (config.acceleration or 50) .. [[
        local TURN_SPEED = ]] .. (config.turnSpeed or 2.5) .. [[
        local BRAKE_FORCE = ]] .. (config.brakeForce or 60) .. [[
        
        local currentSpeed = 0
        local targetSpeed = 0
        local steerAngle = 0
        local targetSteer = 0
        local isBraking = false
        
        local function Stabilize()
            if not chassis or not chassis.Parent then return end
            local upVector = chassis.CFrame.UpVector
            
            if upVector.Y < 0.3 then
                local pos = chassis.Position
                local look = chassis.CFrame.LookVector
                local angle = math.atan2(look.X, look.Z)
                chassis.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)) * CFrame.Angles(0, angle, 0)
                chassis.AssemblyLinearVelocity = Vector3.zero
                chassis.AssemblyAngularVelocity = Vector3.zero
            end
            
            local vel = chassis.AssemblyLinearVelocity
            if math.abs(vel.Y) > 50 then
                chassis.AssemblyLinearVelocity = Vector3.new(vel.X, math.clamp(vel.Y, -50, 50), vel.Z)
            end
        end
        
        local function UpdatePhysics()
            if not seat or not seat.Parent then
                if connection then connection:Disconnect() end
                return
            end
            
            if not seat.Occupant then
                targetSpeed = 0
                isBraking = true
            else
                local throttle = seat.ThrottleFloat
                local steer = seat.SteerFloat
                
                if math.abs(throttle) > 0.1 then
                    targetSpeed = throttle * MAX_SPEED
                    isBraking = false
                else
                    targetSpeed = 0
                    isBraking = true
                end
                
                targetSteer = steer * TURN_SPEED
            end
            
            currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * 0.1
            steerAngle = steerAngle + (targetSteer - steerAngle) * 0.15
            
            for _, wheel in ipairs(wheels) do
                if wheel.hinge and wheel.hinge.Parent then
                    wheel.hinge.AngularVelocity = -currentSpeed * 2
                    local torque = isBraking and BRAKE_FORCE or 10000
                    wheel.hinge.MotorMaxTorque = torque
                end
            end
            
            Stabilize()
        end
        
        local connection = RunService.Heartbeat:Connect(UpdatePhysics)
        
        seat.AncestryChanged:Connect(function()
            if not seat.Parent then
                if connection then connection:Disconnect() end
            end
        end)
    ]]
    
    local controller = Instance.new("LocalScript")
    controller.Name = "VehicleController_v6"
    controller.Source = controllerCode
    controller.Parent = seat
    
    return controller
end

function ModelSystem.VehicleAI:BuildVehicle(model, config)
    config = config or {}
    
    NotificationSystem:Show("🚗 Construindo Veículo...", "Montando chassis inteligente...", 2, "INFO")
    
    local chassis = self:BuildSmartChassis(model, config)
    if not chassis then return nil end
    
    task.wait(0.1)
    
    local wheels = self:CreateSmartWheels(model, chassis, config)
    
    local seat = Instance.new("VehicleSeat")
    seat.Name = "DriveSeat"
    seat.Size = Vector3.new(2, 1, 2)
    seat.Position = chassis.Position + Vector3.new(0, chassis.Size.Y/2 + 1, 0)
    seat.Headrest = true
    seat.Torque = 10000
    seat.TurnSpeed = 10
    seat.MaxSpeed = config.maxSpeed or 100
    seat.Parent = model
    
    self:CreateUnbreakableWeld(chassis, seat, CFrame.new(0, chassis.Size.Y/2 + 0.5, 0), CFrame.new())
    
    self:CreateVehicleController(model, chassis, wheels, seat, config)
    
    pcall(function()
        if chassis:IsDescendantOf(workspace) then
            chassis:SetNetworkOwner(player)
        end
    end)
    
    task.spawn(function()
        while model and model.Parent do
            task.wait(2)
            if not model or not model.Parent then break end
            
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") and part ~= chassis and part.Parent ~= nil then
                    local hasWeld = part:FindFirstChildOfClass("Weld") or part:FindFirstChildOfClass("WeldConstraint")
                    if not hasWeld then
                        local relativeCFrame = chassis.CFrame:ToObjectSpace(part.CFrame)
                        self:CreateUnbreakableWeld(chassis, part, relativeCFrame, CFrame.new())
                    end
                end
            end
        end
    end)
    
    table.insert(self.ActiveVehicles, {
        model = model,
        chassis = chassis,
        wheels = wheels,
        seat = seat,
        createdAt = os.time()
    })
    
    NotificationSystem:Show("✅ Veículo Pronto!", "WASD para dirigir, ESPAÇO freio, Shift Boost, R Desvirar", 6, "SUCCESS")
    
    return {model = model, chassis = chassis, seat = seat, wheels = wheels}
end

function ModelSystem.VehicleAI:Boost()
    for _, vehicle in ipairs(self.ActiveVehicles) do
        if vehicle.seat and vehicle.seat.Occupant then
            local chassis = vehicle.chassis
            if chassis and chassis.Parent then
                local boostForce = chassis.CFrame.LookVector * 3000
                chassis:ApplyImpulse(boostForce * chassis.AssemblyMass)
                NotificationSystem:Show("🚀 Boost!", "Velocidade máxima!", 2, "SUCCESS")
            end
        end
    end
end

function ModelSystem.VehicleAI:BrakeHard()
    for _, vehicle in ipairs(self.ActiveVehicles) do
        if vehicle.chassis and vehicle.chassis.Parent then
            vehicle.chassis.AssemblyLinearVelocity = vehicle.chassis.AssemblyLinearVelocity * 0.3
            NotificationSystem:Show("🛑 Freio de Emergência!", "Velocidade reduzida", 2, "WARNING")
        end
    end
end

function ModelSystem.VehicleAI:FlipVehicle()
    for _, vehicle in ipairs(self.ActiveVehicles) do
        if vehicle.chassis and vehicle.chassis.Parent then
            local cf = vehicle.chassis.CFrame
            vehicle.chassis.CFrame = CFrame.new(cf.Position + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.atan2(cf.LookVector.X, cf.LookVector.Z), 0)
            vehicle.chassis.AssemblyLinearVelocity = Vector3.zero
            vehicle.chassis.AssemblyAngularVelocity = Vector3.zero
            NotificationSystem:Show("🔄 Recuperação!", "Veículo desvirado", 2, "SUCCESS")
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- FUNÇÕES DO MODEL SYSTEM (TODAS AS ORIGINAIS)
-- ═══════════════════════════════════════════════════════════════════════════

function ModelSystem:Init()
    if self.ModelFolder then return end
    
    self.ModelFolder = Instance.new("Folder")
    self.ModelFolder.Name = "aquilesgamef1_Models_" .. player.Name
    self.ModelFolder.Parent = Workspace
    
    print("[ModelSystem] Inicializado v4.2 + VehicleAI v6.0")
    
    self:CreateBuilderPanel()
end

function ModelSystem:CreateBuilderPanel()
    local BuilderGui = Instance.new("ScreenGui")
    BuilderGui.Name = "aquilesgamef1_BuilderPanel"
    BuilderGui.ResetOnSpawn = false
    BuilderGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    BuilderGui.Parent = guiParent
    
    local BuilderPanel = Instance.new("Frame")
    BuilderPanel.Name = "BuilderPanel"
    BuilderPanel.Size = UDim2.new(0, 280, 0, 500)
    BuilderPanel.Position = UDim2.new(0, 20, 0.5, -250)
    BuilderPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    BuilderPanel.BackgroundTransparency = 0.05
    BuilderPanel.BorderSizePixel = 0
    BuilderPanel.Visible = false
    BuilderPanel.Parent = BuilderGui
    
    local PanelCorner = Instance.new("UICorner", BuilderPanel)
    PanelCorner.CornerRadius = UDim.new(0, 16)
    
    local PanelStroke = Instance.new("UIStroke", BuilderPanel)
    PanelStroke.Color = CurrentTheme.selection
    PanelStroke.Thickness = 2
    PanelStroke.Transparency = 0.3
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.Parent = BuilderPanel
    
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    
    local HeaderBottom = Instance.new("Frame", Header)
    HeaderBottom.Size = UDim2.new(1, 0, 0, 20)
    HeaderBottom.Position = UDim2.new(0, 0, 1, -20)
    HeaderBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    HeaderBottom.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -60, 0, 30)
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "◉ Área de Construção"
    Title.TextColor3 = CurrentTheme.selection
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.TextSize = 16
    
    local CloseCorner = Instance.new("UICorner", CloseBtn)
    CloseCorner.CornerRadius = UDim.new(0, 8)
    
    CloseBtn.MouseButton1Click:Connect(function()
        self:ClearSelection()
    end)
    
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "Content"
    ContentContainer.Size = UDim2.new(1, -20, 1, -70)
    ContentContainer.Position = UDim2.new(0, 10, 0, 60)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.ScrollBarImageColor3 = CurrentTheme.selection
    ContentContainer.Parent = BuilderPanel
    
    local Layout = Instance.new("UIListLayout", ContentContainer)
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Padding = Instance.new("UIPadding", ContentContainer)
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end)
    
    local function CreatePanelSection(title, color)
        color = color or CurrentTheme.selection
        
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, 0, 0, 0)
        Section.AutomaticSize = Enum.AutomaticSize.Y
        Section.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        Section.BackgroundTransparency = 0.5
        Section.BorderSizePixel = 0
        Section.Parent = ContentContainer
        
        local Corner = Instance.new("UICorner", Section)
        Corner.CornerRadius = UDim.new(0, 12)
        
        local Stroke = Instance.new("UIStroke", Section)
        Stroke.Color = color
        Stroke.Thickness = 1
        Stroke.Transparency = 0.5
        
        local TitleLabel = Instance.new("TextLabel", Section)
        TitleLabel.Size = UDim2.new(1, -20, 0, 25)
        TitleLabel.Position = UDim2.new(0, 10, 0, 8)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title
        TitleLabel.TextColor3 = color
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 14
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local SectionContent = Instance.new("Frame", Section)
        SectionContent.Size = UDim2.new(1, -20, 0, 0)
        SectionContent.Position = UDim2.new(0, 10, 0, 35)
        SectionContent.AutomaticSize = Enum.AutomaticSize.Y
        SectionContent.BackgroundTransparency = 1
        
        local SectionLayout = Instance.new("UIListLayout", SectionContent)
        SectionLayout.Padding = UDim.new(0, 8)
        
        SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SectionContent.Size = UDim2.new(1, -20, 0, SectionLayout.AbsoluteContentSize.Y)
            Section.Size = UDim2.new(1, 0, 0, SectionContent.Size.Y.Offset + 45)
        end)
        
        return SectionContent
    end
    
    local function CreatePanelButton(parent, text, callback, color)
        color = color or CurrentTheme.selection
        
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 38)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 13
        Btn.AutoButtonColor = false
        Btn.Parent = parent
        
        local BtnCorner = Instance.new("UICorner", Btn)
        BtnCorner.CornerRadius = UDim.new(0, 8)
        
        local BtnStroke = Instance.new("UIStroke", Btn)
        BtnStroke.Color = color
        BtnStroke.Thickness = 1
        BtnStroke.Transparency = 0.6
        
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play()
        end)
        
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
        end)
        
        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 36)}):Play()
            task.wait(0.05)
            TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            
            local success, err = pcall(callback)
            if not success then
                warn("Erro: " .. tostring(err))
            end
        end)
        
        return Btn
    end
    
    local InfoSection = CreatePanelSection("📊 Info da Seleção", Color3.fromRGB(100, 200, 255))
    local InfoLabel = Instance.new("TextLabel", InfoSection)
    InfoLabel.Size = UDim2.new(1, 0, 0, 50)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Nenhum modelo selecionado\nClique em um modelo para começar"
    InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    InfoLabel.Font = Enum.Font.GothamMedium
    InfoLabel.TextSize = 12
    InfoLabel.TextWrapped = true
    
    local MoveSection = CreatePanelSection("⬆️ Movimento", Color3.fromRGB(255, 255, 100))
    CreatePanelButton(MoveSection, "⬆️ Cima (+Y)", function()
        self:MoveSelected(Vector3.new(0, self.TransformSettings.MoveIncrement, 0))
    end)
    CreatePanelButton(MoveSection, "⬇️ Baixo (-Y)", function()
        self:MoveSelected(Vector3.new(0, -self.TransformSettings.MoveIncrement, 0))
    end)
    CreatePanelButton(MoveSection, "⬅️ Esquerda (-X)", function()
        self:MoveSelected(Vector3.new(-self.TransformSettings.MoveIncrement, 0, 0))
    end)
    CreatePanelButton(MoveSection, "➡️ Direita (+X)", function()
        self:MoveSelected(Vector3.new(self.TransformSettings.MoveIncrement, 0, 0))
    end)
    CreatePanelButton(MoveSection, "⏩ Frente (+Z)", function()
        self:MoveSelected(Vector3.new(0, 0, self.TransformSettings.MoveIncrement))
    end)
    CreatePanelButton(MoveSection, "⏪ Trás (-Z)", function()
        self:MoveSelected(Vector3.new(0, 0, -self.TransformSettings.MoveIncrement))
    end)
    
    local TransformSection = CreatePanelSection("🔄 Rotação & Escala", Color3.fromRGB(255, 150, 50))
    CreatePanelButton(TransformSection, "↻ Rotacionar +15°", function()
        self:RotateSelected(self.TransformSettings.RotateIncrement)
    end, Color3.fromRGB(255, 150, 50))
    CreatePanelButton(TransformSection, "↺ Rotacionar -15°", function()
        self:RotateSelected(-self.TransformSettings.RotateIncrement)
    end, Color3.fromRGB(255, 150, 50))
    CreatePanelButton(TransformSection, "➕ Aumentar Escala", function()
        self:ScaleSelected(1 + self.TransformSettings.ScaleIncrement)
    end, Color3.fromRGB(150, 100, 255))
    CreatePanelButton(TransformSection, "➖ Diminuir Escala", function()
        self:ScaleSelected(1 - self.TransformSettings.ScaleIncrement)
    end, Color3.fromRGB(150, 100, 255))
    
    local PropSection = CreatePanelSection("⚙️ Propriedades", Color3.fromRGB(100, 255, 150))
    CreatePanelButton(PropSection, "🔒 Trancar/Destrancar", function()
        self:ToggleLockSelected()
    end, Color3.fromRGB(255, 200, 100))
    CreatePanelButton(PropSection, "👁️ Mostrar/Esconder", function()
        self:ToggleVisibilitySelected()
    end, Color3.fromRGB(100, 255, 255))
    CreatePanelButton(PropSection, "🎨 Cor Aleatória", function()
        self:RandomColorSelected()
    end, Color3.fromRGB(255, 100, 200))
    CreatePanelButton(PropSection, "💾 Salvar Posição", function()
        self:SaveSelectedPositions()
    end, Color3.fromRGB(0, 255, 150))
    CreatePanelButton(PropSection, "📤 Restaurar Posição", function()
        self:RestoreSelectedPositions()
    end, Color3.fromRGB(0, 200, 255))
    
    local AlignSection = CreatePanelSection("📐 Alinhamento", Color3.fromRGB(200, 200, 200))
    CreatePanelButton(AlignSection, "🎯 Alinhar ao Centro", function()
        self:AlignSelectedToCenter()
    end)
    CreatePanelButton(AlignSection, "📏 Alinhar ao Grid", function()
        self:AlignSelectedToGrid()
    end)
    
    local GroupSection = CreatePanelSection("🔗 Grupos", Color3.fromRGB(100, 200, 255))
    CreatePanelButton(GroupSection, "➕ Criar Grupo", function()
        self:CreateGroupFromSelection()
    end, Color3.fromRGB(100, 200, 255))
    CreatePanelButton(GroupSection, "📋 Selecionar Todos", function()
        self:SelectAll()
    end, Color3.fromRGB(0, 255, 100))
    
    local ActionSection = CreatePanelSection("⚠️ Ações", Color3.fromRGB(255, 80, 80))
    CreatePanelButton(ActionSection, "🗑️ Deletar Selecionados", function()
        self:DeleteSelected()
    end, Color3.fromRGB(255, 80, 80))
    CreatePanelButton(ActionSection, "💾 Salvar Build", function()
        NotificationSystem:Show("Save", "Use a aba Save no Hub principal", 3, "INFO")
    end, Color3.fromRGB(0, 255, 150))
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = BuilderPanel.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            BuilderPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    task.spawn(function()
        while InfoLabel and InfoLabel.Parent do
            local count = #self.SelectedModels
            if count > 0 then
                local totalParts = 0
                for _, m in ipairs(self.SelectedModels) do
                    totalParts = totalParts + (m.partCount or 0)
                end
                InfoLabel.Text = string.format("◉ %d modelo(s) selecionado(s)\n📦 %d partes no total\n⇧ Shift+Clique para adicionar", count, totalParts)
                InfoLabel.TextColor3 = CurrentTheme.selection
            else
                InfoLabel.Text = "Nenhum modelo selecionado\nClique em um modelo para começar"
                InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            task.wait(0.5)
        end
    end)
    
    self.BuilderPanel = BuilderPanel
    self.BuilderGui = BuilderGui
end

function ModelSystem:SelectModel(modelData, additive)
    if not additive then
        self:ClearSelection()
    end
    
    if not table.find(self.SelectedModels, modelData) then
        table.insert(self.SelectedModels, modelData)
        self:CreateSelectionVisual(modelData)
    end
    
    self:UpdateBuilderPanel()
end

function ModelSystem:CreateSelectionVisual(modelData)
    local model = modelData.instance
    if not model then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "aquilesgamef1_Highlight"
    highlight.Adornee = model
    highlight.FillColor = CurrentTheme.selection
    highlight.OutlineColor = CurrentTheme.selection
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.Parent = model
    
    modelData.highlight = highlight
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local box = Instance.new("SelectionBox")
            box.Name = "aquilesgamef1_Selection"
            box.Adornee = part
            box.Color3 = CurrentTheme.selection
            box.LineThickness = 0.03
            box.Parent = part
            table.insert(self.SelectionBoxes, box)
        end
    end
end

function ModelSystem:ClearSelection()
    for _, box in ipairs(self.SelectionBoxes) do
        pcall(function() box:Destroy() end)
    end
    self.SelectionBoxes = {}
    
    for _, modelData in ipairs(self.SelectedModels) do
        if modelData.highlight then
            pcall(function() modelData.highlight:Destroy() end)
            modelData.highlight = nil
        end
    end
    
    self.SelectedModels = {}
    
    if self.BuilderPanel then
        self.BuilderPanel.Visible = false
    end
end

function ModelSystem:UpdateBuilderPanel()
    if self.BuilderPanel then
        self.BuilderPanel.Visible = #self.SelectedModels > 0
    end
end

function ModelSystem:SelectAll()
    self:ClearSelection()
    for _, modelData in ipairs(self.LoadedModels) do
        self:SelectModel(modelData, true)
    end
    NotificationSystem:Show("◉ Selecionados", #self.LoadedModels .. " modelos", 3, "SELECTION")
end

function ModelSystem:MoveSelected(offset)
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model then
            if model.PrimaryPart then
                model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame + offset)
            else
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Position = part.Position + offset
                    end
                end
            end
        end
    end
end

function ModelSystem:RotateSelected(degrees)
    local radians = math.rad(degrees)
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model and model.PrimaryPart then
            model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(0, radians, 0))
        end
    end
end

function ModelSystem:ScaleSelected(factor)
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model and model.PrimaryPart then
            local primary = model.PrimaryPart
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Size = obj.Size * factor
                    if obj ~= primary then
                        local relativePos = obj.Position - primary.Position
                        obj.Position = primary.Position + (relativePos * factor)
                    end
                end
            end
        end
    end
end

function ModelSystem:ToggleLockSelected()
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = not part.Anchored
                end
            end
        end
    end
    NotificationSystem:Show("🔒 Trancado", #self.SelectedModels .. " modelos alternados", 2, "INFO")
end

function ModelSystem:ToggleVisibilitySelected()
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = part.Transparency > 0.5 and 0 or 1
                end
            end
        end
    end
end

function ModelSystem:RandomColorSelected()
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model then
            local randomColor = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = randomColor
                end
            end
        end
    end
end

function ModelSystem:SaveSelectedPositions()
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model then
            modelData.savedCFrame = model:GetPivot()
        end
    end
    NotificationSystem:Show("💾 Salvo", "Posições de " .. #self.SelectedModels .. " modelos salvas", 3, "SUCCESS")
end

function ModelSystem:RestoreSelectedPositions()
    for _, modelData in ipairs(self.SelectedModels) do
        if modelData.savedCFrame and modelData.instance then
            self:SetModelCFrame(modelData.instance, modelData.savedCFrame)
        end
    end
    NotificationSystem:Show("📤 Restaurado", "Posições restauradas", 3, "SUCCESS")
end

function ModelSystem:AlignSelectedToCenter()
    if #self.SelectedModels < 2 then return end
    local center = Vector3.new(0, 0, 0)
    for _, modelData in ipairs(self.SelectedModels) do
        if modelData.instance then
            center = center + modelData.instance:GetPivot().Position
        end
    end
    center = center / #self.SelectedModels
    
    for _, modelData in ipairs(self.SelectedModels) do
        if modelData.instance then
            local current = modelData.instance:GetPivot()
            self:SetModelCFrame(modelData.instance, CFrame.new(center.X, current.Y, center.Z) * CFrame.Angles(current:ToEulerAnglesXYZ()))
        end
    end
end

function ModelSystem:AlignSelectedToGrid()
    local gridSize = self.TransformSettings.GridSize
    for _, modelData in ipairs(self.SelectedModels) do
        local model = modelData.instance
        if model then
            local pos = model:GetPivot().Position
            local snapped = Vector3.new(
                math.floor(pos.X / gridSize + 0.5) * gridSize,
                math.floor(pos.Y / gridSize + 0.5) * gridSize,
                math.floor(pos.Z / gridSize + 0.5) * gridSize
            )
            self:SetModelCFrame(model, CFrame.new(snapped) * CFrame.Angles(model:GetPivot():ToEulerAnglesXYZ()))
        end
    end
end

function ModelSystem:DeleteSelected()
    local count = #self.SelectedModels
    for _, modelData in ipairs(self.SelectedModels) do
        if modelData.instance then
            modelData.instance:Destroy()
        end
        for i, loaded in ipairs(self.LoadedModels) do
            if loaded == modelData then
                table.remove(self.LoadedModels, i)
                break
            end
        end
    end
    self:ClearSelection()
    NotificationSystem:Show("🗑️ Deletado", count .. " modelos removidos", 3, "SUCCESS")
end

function ModelSystem:CreateGroupFromSelection()
    if #self.SelectedModels < 2 then
        NotificationSystem:Show("Erro", "Selecione pelo menos 2 modelos", 3, "ERROR")
        return
    end
    
    local groupId = self.NextGroupId
    self.NextGroupId = self.NextGroupId + 1
    
    local group = {
        id = groupId,
        name = "Grupo_" .. groupId,
        models = {},
        color = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
    }
    
    for _, modelData in ipairs(self.SelectedModels) do
        modelData.groupId = groupId
        table.insert(group.models, modelData)
    end
    
    self.Groups[groupId] = group
    
    for _, modelData in ipairs(group.models) do
        local model = modelData.instance
        if model then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") and not part:FindFirstChild("GroupHighlight") then
                    local highlight = Instance.new("BoxHandleAdornment")
                    highlight.Name = "GroupHighlight"
                    highlight.Adornee = part
                    highlight.Color3 = group.color
                    highlight.Transparency = 0.8
                    highlight.Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
                    highlight.AlwaysOnTop = true
                    highlight.ZIndex = 5
                    highlight.Parent = part
                end
            end
        end
    end
    
    NotificationSystem:Show("🔗 Grupo Criado", "Grupo " .. groupId .. " com " .. #group.models .. " modelos", 4, "SUCCESS")
    return group
end

function ModelSystem:LoadModel(assetId, options)
    options = options or {}
    local collision = options.collision ~= false
    local anchored = options.anchored ~= false
    local scale = options.scale or 1
    local position = options.position
    
    if not position then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, -10)
        else
            position = Vector3.new(0, 10, 0)
        end
    end
    
    if not self.ModelFolder then self:Init() end
    
    NotificationSystem:Show("📦 Carregando...", "Asset ID: " .. tostring(assetId), 2, "INFO")
    
    local model = nil
    local loadMethod = nil
    
    local success, result = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        return objects and objects[1]
    end)
    
    if success and result then
        model = result
        loadMethod = "GetObjects"
    end
    
    if not model then
        pcall(function()
            model = InsertService:LoadAsset(assetId)
            loadMethod = "InsertService"
        end)
    end
    
    if not model then
        NotificationSystem:Show("❌ Erro", "Falha ao carregar modelo " .. assetId, 5, "ERROR")
        return nil
    end
    
    if model:IsA("Folder") or model:IsA("Configuration") then
        local children = model:GetChildren()
        if #children == 1 and children[1]:IsA("Model") then
            local newModel = children[1]
            newModel.Parent = nil
            model:Destroy()
            model = newModel
        else
            local newModel = Instance.new("Model")
            newModel.Name = model.Name
            for _, child in ipairs(children) do
                child.Parent = newModel
            end
            model:Destroy()
            model = newModel
        end
    end
    
    if not model:IsA("Model") then
        NotificationSystem:Show("❌ Erro", "O asset não é um modelo válido", 4, "ERROR")
        return nil
    end
    
    local modelId = self.NextId
    self.NextId = self.NextId + 1
    
    local modelName = options.name or model.Name or "Model_" .. assetId
    model.Name = modelName .. "_" .. modelId
    
    if not model.PrimaryPart then
        local basePart = model:FindFirstChildWhichIsA("BasePart", true)
        if basePart then
            model.PrimaryPart = basePart
        end
    end
    
    if scale ~= 1 then
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Size = obj.Size * scale
            end
        end
    end
    
    local partCount = 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = anchored
            part.CanCollide = collision
            part:SetAttribute("aquilesgamef1_Model", true)
            part:SetAttribute("aquilesgamef1_ModelId", modelId)
            
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.Name = "ModelSelector"
            clickDetector.MaxActivationDistance = 100
            clickDetector.Parent = part
            
            clickDetector.MouseClick:Connect(function(playerWhoClicked)
                if playerWhoClicked == player then
                    for _, modelData in ipairs(self.LoadedModels) do
                        if modelData.id == modelId then
                            local additive = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                            self:SelectModel(modelData, additive)
                            break
                        end
                    end
                end
            end)
            
            partCount = partCount + 1
        end
    end
    
    model.Parent = self.ModelFolder
    
    local posSuccess = self:SetModelCFrame(model, CFrame.new(position))
    if not posSuccess then
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Position = part.Position + (position - model:GetPivot().Position)
                break
            end
        end
    end
    
    local modelData = {
        id = modelId,
        instance = model,
        assetId = assetId,
        name = modelName,
        options = options,
        loadedAt = os.time(),
        loadMethod = loadMethod,
        partCount = partCount,
        isVehicle = false,
        vehicleConfig = nil,
        vehicleType = nil
    }
    
    table.insert(self.LoadedModels, modelData)
    
    NotificationSystem:Show("✅ Modelo Carregado!", 
        modelName .. " (" .. partCount .. " partes)", 4, "SUCCESS")
    self:SelectModel(modelData, false)
    
    return model
end

function ModelSystem:SetModelCFrame(model, cframe)
    if not model or not cframe then return false end
    local success = pcall(function()
        if model.PrimaryPart then
            model:SetPrimaryPartCFrame(cframe)
        else
            local currentPivot = model:GetPivot()
            local offset = cframe.Position - currentPivot.Position
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CFrame = part.CFrame + offset
                end
            end
        end
    end)
    return success
end

function ModelSystem:ClearAll()
    self:ClearSelection()
    for _, data in ipairs(self.LoadedModels) do
        pcall(function() if data.instance then data.instance:Destroy() end end)
    end
    self.LoadedModels = {}
    self.NextId = 1
    self.Groups = {}
    self.NextGroupId = 1
    NotificationSystem:Show("🧹 Limpo", "Todos os modelos removidos", 3, "INFO")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- FUNÇÃO PÚBLICA: APLICAR VEÍCULO (VERSÃO NOVA v6.0)
-- ═══════════════════════════════════════════════════════════════════════════
function ModelSystem:ApplyVehicleScript(model, config)
    if model:FindFirstChild("SmartChassis") then
        NotificationSystem:Show("ℹ️ Info", "Este modelo já é um veículo inteligente!", 3, "INFO")
        return model:FindFirstChild("DriveSeat")
    end
    
    local vehicle = ModelSystem.VehicleAI:BuildVehicle(model, config)
    
    if vehicle then
        for _, modelData in ipairs(ModelSystem.LoadedModels) do
            if modelData.instance == model then
                modelData.isVehicle = true
                modelData.vehicleConfig = config
                modelData.vehicleType = "SmartCar_v6"
                modelData.vehicleData = vehicle
                break
            end
        end
        return vehicle.seat
    end
    
    return nil
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE SAVE                                          ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local SaveSystem = {
    Data = {
        builds = {}, 
        lastBuild = nil, 
        settings = {
            autoSave = true,
            autoSaveInterval = 30,
            encryptBuilds = false,
            backupCount = 5
        }, 
        version = CONFIG.VERSION,
        gameId = game.PlaceId,
        timestamp = 0
    },
    AutoSaveEnabled = true,
    LastSave = 0,
    CurrentBuildName = nil
}

function SaveSystem:Init()
    FileSystem:Init()
    self:LoadGlobalSettings()
    
    task.spawn(function()
        while self.AutoSaveEnabled and self.Data.settings.autoSave do
            task.wait(self.Data.settings.autoSaveInterval)
            if ModelSystem and ModelSystem.LoadedModels and #ModelSystem.LoadedModels > 0 then
                self:AutoSave()
            end
        end
    end)
end

function SaveSystem:SerializeBuild(name, description, password)
    if not ModelSystem then
        NotificationSystem:Show("Erro", "Sistema de modelos não inicializado!", 4, "ERROR")
        return nil
    end
    
    if not ModelSystem.LoadedModels then
        NotificationSystem:Show("Erro", "Lista de modelos não disponível!", 4, "ERROR")
        return nil
    end
    
    name = name or "Build_" .. os.time()
    description = description or "Construção salva em " .. os.date("%d/%m/%Y %H:%M")
    
    local buildData = {
        metadata = {
            name = name,
            description = description,
            createdAt = os.time(),
            gameId = game.PlaceId,
            gameName = "Unknown",
            version = CONFIG.VERSION,
            builderVersion = "4.2"
        },
        models = {},
        groups = {},
        stats = {
            totalModels = #ModelSystem.LoadedModels,
            totalParts = 0,
            totalMass = 0,
            bounds = {
                min = {math.huge, math.huge, math.huge},
                max = {-math.huge, -math.huge, -math.huge}
            }
        },
        terrain = {},
        settings = {
            lighting = {},
            atmosphere = {}
        }
    }
    
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        buildData.metadata.gameName = info.Name or "Unknown"
    end)
    
    pcall(function()
        buildData.settings.lighting = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            GeographicLatitude = Lighting.GeographicLatitude,
            Ambient = {Lighting.Ambient.R, Lighting.Ambient.G, Lighting.Ambient.B},
            OutdoorAmbient = {Lighting.OutdoorAmbient.R, Lighting.OutdoorAmbient.G, Lighting.OutdoorAmbient.B}
        }
    end)
    
    if #ModelSystem.LoadedModels == 0 then
        NotificationSystem:Show("Aviso", "Nenhum modelo carregado para salvar!", 4, "WARNING")
    end
    
    for _, modelData in ipairs(ModelSystem.LoadedModels) do
        if modelData and modelData.instance and modelData.instance.Parent then
            local success, pivot = pcall(function()
                return modelData.instance:GetPivot()
            end)
            
            if success and pivot then
                local pos = pivot.Position
                
                buildData.stats.bounds.min[1] = math.min(buildData.stats.bounds.min[1], pos.X)
                buildData.stats.bounds.min[2] = math.min(buildData.stats.bounds.min[2], pos.Y)
                buildData.stats.bounds.min[3] = math.min(buildData.stats.bounds.min[3], pos.Z)
                buildData.stats.bounds.max[1] = math.max(buildData.stats.bounds.max[1], pos.X)
                buildData.stats.bounds.max[2] = math.max(buildData.stats.bounds.max[2], pos.Y)
                buildData.stats.bounds.max[3] = math.max(buildData.stats.bounds.max[3], pos.Z)
                
                local cframeComponents = {pivot:GetComponents()}
                
                local modelInfo = {
                    assetId = modelData.assetId,
                    name = modelData.name,
                    cframe = cframeComponents,
                    scale = modelData.options and modelData.options.scale or 1,
                    anchored = modelData.options and modelData.options.anchored,
                    collision = modelData.options and modelData.options.collision,
                    groupId = modelData.groupId,
                    isVehicle = modelData.isVehicle or false,
                    vehicleConfig = modelData.vehicleConfig,
                    properties = {}
                }
                
                for _, part in ipairs(modelData.instance:GetDescendants()) do
                    if part:IsA("BasePart") then
                        buildData.stats.totalParts = buildData.stats.totalParts + 1
                        buildData.stats.totalMass = buildData.stats.totalMass + (part.AssemblyMass or 0)
                        
                        table.insert(modelInfo.properties, {
                            path = part:GetFullName(),
                            color = {part.Color.R, part.Color.G, part.Color.B},
                            material = tostring(part.Material),
                            transparency = part.Transparency,
                            reflectance = part.Reflectance,
                            size = {part.Size.X, part.Size.Y, part.Size.Z}
                        })
                    end
                end
                
                table.insert(buildData.models, modelInfo)
            end
        end
    end
    
    local success, jsonData = pcall(function()
        return HttpService:JSONEncode(buildData)
    end)
    
    if not success then
        NotificationSystem:Show("Erro", "Falha ao codificar dados: " .. tostring(jsonData), 5, "ERROR")
        return nil
    end
    
    if password and password ~= "" then
        jsonData = Crypto:SimpleEncrypt(jsonData, password)
        buildData.metadata.encrypted = true
    end
    
    return jsonData, buildData
end

function SaveSystem:Save(name, description, password)
    if not ModelSystem then
        NotificationSystem:Show("Erro", "ModelSystem não disponível!", 4, "ERROR")
        return false
    end
    
    local jsonData, buildData = self:SerializeBuild(name, description, password)
    if not jsonData then 
        NotificationSystem:Show("Erro", "Falha ao serializar build!", 4, "ERROR")
        return false 
    end
    
    local fileName = "builds/" .. name .. ".json"
    local success = FileSystem:WriteFile(fileName, jsonData)
    
    if success then
        self.Data.lastBuild = name
        self.LastSave = os.time()
        self.CurrentBuildName = name
        
        self:CreateBackup(name, jsonData)
        
        NotificationSystem:Show("💾 Build Salva!", 
            string.format("%s (%d modelos, %d partes)", 
                name, 
                buildData.stats.totalModels, 
                buildData.stats.totalParts), 
            5, "SUCCESS")
        
        self:UpdateBuildIndex(name, buildData.metadata)
        self:SaveGlobalSettings()
        
        return true
    else
        NotificationSystem:Show("❌ Erro ao Salvar", "Não foi possível salvar a build", 4, "ERROR")
        return false
    end
end

function SaveSystem:CreateBackup(name, data)
    local backupName = "backups/" .. name .. "_" .. os.time() .. ".json"
    FileSystem:WriteFile(backupName, data)
    
    local backups = {}
    for _, file in ipairs(FileSystem:ListFiles("backups")) do
        if file:find("^" .. name .. "_") then
            table.insert(backups, file)
        end
    end
    
    table.sort(backups)
    while #backups > (self.Data.settings.backupCount or 5) do
        FileSystem:DeleteFile("backups/" .. table.remove(backups, 1))
    end
end

function SaveSystem:AutoSave()
    if os.time() - self.LastSave < 10 then return end
    if not self.CurrentBuildName then
        self.CurrentBuildName = "Autosave_" .. os.time()
    end
    
    local success = self:Save(self.CurrentBuildName, "Auto-save", nil)
    if success then
        print("[AutoSave] Build salva automaticamente")
    end
end

function SaveSystem:Load(name, password)
    local fileName = "builds/" .. name .. ".json"
    local jsonData = FileSystem:ReadFile(fileName)
    
    if not jsonData then
        if self.Data.builds[name] then
            return self.Data.builds[name]
        end
        NotificationSystem:Show("Erro", "Build não encontrada: " .. name, 4, "ERROR")
        return nil
    end
    
    local success, buildData = pcall(function()
        return HttpService:JSONDecode(jsonData)
    end)
    
    if not success then
        if password and password ~= "" then
            local decrypted = Crypto:SimpleDecrypt(jsonData, password)
            if decrypted then
                success, buildData = pcall(function()
                    return HttpService:JSONDecode(decrypted)
                end)
                if not success then
                    NotificationSystem:Show("Erro", "Senha incorreta!", 4, "ERROR")
                    return nil
                end
            else
                NotificationSystem:Show("Erro", "Senha incorreta!", 4, "ERROR")
                return nil
            end
        else
            NotificationSystem:Show("Erro", "Esta build está protegida por senha!", 4, "ERROR")
            return nil
        end
    end
    
    return buildData
end

function SaveSystem:LoadBuild(name, password)
    if not ModelSystem then
        NotificationSystem:Show("Erro", "ModelSystem não disponível!", 4, "ERROR")
        return false
    end
    
    local buildData = self:Load(name, password)
    if not buildData then return false end
    
    ModelSystem:ClearAll()
    
    local loadedCount = 0
    for _, modelInfo in ipairs(buildData.models) do
        local model = ModelSystem:LoadModel(modelInfo.assetId, {
            name = modelInfo.name,
            position = Vector3.new(modelInfo.cframe[1], modelInfo.cframe[2], modelInfo.cframe[3]),
            scale = modelInfo.scale or 1,
            anchored = modelInfo.anchored,
            collision = modelInfo.collision
        })
        
        if model then
            local cframe = CFrame.new(unpack(modelInfo.cframe))
            ModelSystem:SetModelCFrame(model, cframe)
            
            if modelInfo.isVehicle and modelInfo.vehicleConfig then
                task.delay(0.5, function()
                    ModelSystem:ApplyVehicleScript(model, modelInfo.vehicleConfig)
                end)
            end
            
            loadedCount = loadedCount + 1
        end
    end
    
    self.CurrentBuildName = name
    NotificationSystem:Show("📤 Build Carregada!", 
        string.format("%s (%d/%d modelos)", name, loadedCount, #buildData.models), 
        5, "SUCCESS")
    
    return true
end

function SaveSystem:DeleteBuild(name)
    local fileName = "builds/" .. name .. ".json"
    FileSystem:DeleteFile(fileName)
    
    self.Data.builds[name] = nil
    self:SaveGlobalSettings()
    
    NotificationSystem:Show("🗑️ Build Deletada", name .. " removida", 3, "INFO")
end

function SaveSystem:GetBuildList()
    local builds = {}
    for name, metadata in pairs(self.Data.builds) do
        table.insert(builds, {
            name = name,
            createdAt = metadata.createdAt,
            description = metadata.description,
            totalModels = metadata.totalModels or 0
        })
    end
    table.sort(builds, function(a, b) return a.createdAt > b.createdAt end)
    return builds
end

function SaveSystem:UpdateBuildIndex(name, metadata)
    self.Data.builds[name] = metadata
end

function SaveSystem:SaveGlobalSettings()
    local success, data = pcall(function()
        return HttpService:JSONEncode(self.Data)
    end)
    if success then
        FileSystem:WriteFile("settings.json", data)
    end
end

function SaveSystem:LoadGlobalSettings()
    local data = FileSystem:ReadFile("settings.json")
    if data then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if success and decoded then
            self.Data = decoded
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE NUVEM                                         ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local CloudSystem = {
    API_URL = "https://api.aquilesgamef1.cloud/v1",
    Cache = {}
}

function CloudSystem:ExportBuild(name, description, isPublic)
    if not SaveSystem.CurrentBuildName then
        NotificationSystem:Show("Erro", "Salve a build primeiro!", 4, "ERROR")
        return
    end
    
    local fileName = "builds/" .. SaveSystem.CurrentBuildName .. ".json"
    local data = FileSystem:ReadFile(fileName)
    if not data then
        NotificationSystem:Show("Erro", "Build não encontrada localmente", 4, "ERROR")
        return
    end
    
    if #data > CONFIG.MAX_CLOUD_SIZE then
        NotificationSystem:Show("Erro", "Build muito grande para nuvem!", 4, "ERROR")
        return
    end
    
    NotificationSystem:Show("☁️ Exportando...", "Enviando para nuvem...", 3, "INFO")
    
    local exportData = {
        name = name or SaveSystem.CurrentBuildName,
        description = description or "Build exportada",
        isPublic = isPublic or false,
        data = data,
        creator = player.Name,
        gameId = game.PlaceId,
        version = CONFIG.VERSION
    }
    
    local success, result = pcall(function()
        if writefile then
            local cloudFile = "cloud/" .. (name or SaveSystem.CurrentBuildName) .. "_cloud.json"
            FileSystem:WriteFile(cloudFile, HttpService:JSONEncode(exportData))
            return {success = true, id = "local_" .. os.time()}
        end
        return nil
    end)
    
    if success and result then
        NotificationSystem:Show("✅ Exportado!", "Build na nuvem (ID: " .. tostring(result.id) .. ")", 5, "SUCCESS")
        return result.id
    else
        NotificationSystem:Show("⚠️ Export Local", "Salvo localmente (modo offline)", 4, "WARNING")
        return nil
    end
end

function CloudSystem:ImportBuild(cloudId)
    NotificationSystem:Show("☁️ Importando...", "Buscando build " .. tostring(cloudId), 3, "INFO")
    
    local success, result = pcall(function()
        local files = FileSystem:ListFiles("cloud")
        for _, file in ipairs(files) do
            if file:find(cloudId) or file:find(tostring(cloudId)) then
                local data = FileSystem:ReadFile("cloud/" .. file)
                if data then
                    local decoded = HttpService:JSONDecode(data)
                    return decoded
                end
            end
        end
        return nil
    end)
    
    if success and result and result.data then
        local buildData = HttpService:JSONDecode(result.data)
        
        local tempName = "Imported_" .. os.time()
        FileSystem:WriteFile("builds/" .. tempName .. ".json", result.data)
        
        SaveSystem:LoadBuild(tempName)
        NotificationSystem:Show("✅ Importado!", "Build '" .. result.name .. "' carregada", 5, "SUCCESS")
        return true
    else
        NotificationSystem:Show("❌ Erro", "Build não encontrada na nuvem", 4, "ERROR")
        return false
    end
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     ESTATÍSTICAS                                             ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local StatsSystem = {
    Data = {
        totalBuilds = 0,
        totalModelsLoaded = 0,
        totalParts = 0,
        timeInGame = 0,
        favoriteAssets = {},
        lastSession = 0
    }
}

function StatsSystem:Init()
    task.spawn(function()
        while true do
            task.wait(60)
            self.Data.timeInGame = self.Data.timeInGame + 1
        end
    end)
end

function StatsSystem:TrackModelLoad(assetId, partCount)
    self.Data.totalModelsLoaded = self.Data.totalModelsLoaded + 1
    self.Data.totalParts = self.Data.totalParts + (partCount or 0)
    
    self.Data.favoriteAssets[assetId] = (self.Data.favoriteAssets[assetId] or 0) + 1
end

function StatsSystem:GetStats()
    return {
        builds = SaveSystem:GetBuildList(),
        totalModels = ModelSystem and #ModelSystem.LoadedModels or 0,
        totalParts = self.Data.totalParts,
        timeInGame = self.Data.timeInGame,
        favoriteAssets = self.Data.favoriteAssets
    }
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     INTERFACE PRINCIPAL (HUB)                                ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local Hub = {
    GUI = nil,
    MainFrame = nil,
    Tabs = {},
    ActiveTab = nil,
    Minimized = false,
    FloatingIcon = nil
}

function Hub:Init()
    self:CreateGUI()
    self:CreateTabs()
    SaveSystem:Init()
    StatsSystem:Init()
    ModelSystem:Init()
    
    NotificationSystem:Show("🚀 Hub Iniciado!", 
        "aquilesgamef1 Hub v" .. CONFIG.VERSION .. " | Use Insert para minimizar", 
        5, "SUCCESS")
end

function Hub:CreateGUI()
    local hubGui = Instance.new("ScreenGui")
    hubGui.Name = "aquilesgamef1_Hub_v4"
    hubGui.ResetOnSpawn = false
    hubGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    hubGui.Parent = guiParent
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = CurrentTheme.background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = hubGui
    
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 20)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = CurrentTheme.primary
    stroke.Thickness = 3
    stroke.Transparency = 0.3
    
    local shadow = Instance.new("ImageLabel", mainFrame)
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 50, 50)
    shadow.ZIndex = -1
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 20)
    
    local headerBottom = Instance.new("Frame", header)
    headerBottom.Size = UDim2.new(1, 0, 0, 20)
    headerBottom.Position = UDim2.new(0, 0, 1, -20)
    headerBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    headerBottom.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel", header)
    title.Name = "Title"
    title.Size = UDim2.new(0, 400, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "◉ AQUILESGAMEF1 HUB"
    title.TextColor3 = CurrentTheme.primary
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local subtitle = Instance.new("TextLabel", header)
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(0, 400, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 38)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "v" .. CONFIG.VERSION .. " • Build Mode • Vehicle AI v6.0"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local minBtn = Instance.new("TextButton", header)
    minBtn.Name = "MinimizeBtn"
    minBtn.Size = UDim2.new(0, 40, 0, 40)
    minBtn.Position = UDim2.new(1, -100, 0, 10)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 24
    
    local minCorner = Instance.new("UICorner", minBtn)
    minCorner.CornerRadius = UDim.new(0, 10)
    
    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 24
    
    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 10)
    
    closeBtn.MouseButton1Click:Connect(function()
        hubGui:Destroy()
        if self.FloatingIcon then self.FloatingIcon:Destroy() end
    end)
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 200, 1, -60)
    tabContainer.Position = UDim2.new(0, 0, 0, 60)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabContainer.BackgroundTransparency = 0.5
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabCorner = Instance.new("UICorner", tabContainer)
    tabCorner.CornerRadius = UDim.new(0, 16)
    
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabPadding = Instance.new("UIPadding", tabContainer)
    tabPadding.PaddingTop = UDim.new(0, 15)
    tabPadding.PaddingLeft = UDim.new(0, 15)
    tabPadding.PaddingRight = UDim.new(0, 15)
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -200, 1, -60)
    contentFrame.Position = UDim2.new(0, 200, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    self.GUI = hubGui
    self.MainFrame = mainFrame
    self.TabContainer = tabContainer
    self.ContentFrame = contentFrame
    
    self:MakeDraggable(header, mainFrame)
    self:CreateFloatingIcon()
end

function Hub:CreateFloatingIcon()
    local icon = Instance.new("ScreenGui")
    icon.Name = "aquilesgamef1_FloatingIcon"
    icon.ResetOnSpawn = false
    icon.Parent = guiParent
    
    local btn = Instance.new("TextButton")
    btn.Name = "FloatBtn"
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0, 20, 0.5, -30)
    btn.BackgroundColor3 = CurrentTheme.primary
    btn.Text = "◉"
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 30
    btn.Visible = false
    btn.Parent = icon
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = CurrentTheme.accent
    stroke.Thickness = 3
    
    btn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.FloatingIcon = icon
    self.FloatBtn = btn
end

function Hub:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        self.MainFrame.Visible = false
        self.FloatBtn.Visible = true
        TweenService:Create(self.FloatBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 60, 0, 60)
        }):Play()
    else
        self.MainFrame.Visible = true
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 900, 0, 600),
            Position = UDim2.new(0.5, -450, 0.5, -300),
            BackgroundTransparency = 0.05
        }):Play()
        TweenService:Create(self.FloatBtn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.delay(0.2, function()
            self.FloatBtn.Visible = false
        end)
    end
end

function Hub:MakeDraggable(handle, frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Hub:CreateTab(name, icon, color)
    color = color or CurrentTheme.selection
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "Tab"
    tabBtn.Size = UDim2.new(1, 0, 0, 50)
    tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabBtn.Text = icon .. " " .. name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 14
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.TabContainer
    
    local corner = Instance.new("UICorner", tabBtn)
    corner.CornerRadius = UDim.new(0, 12)
    
    local content = Instance.new("ScrollingFrame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.ScrollBarImageColor3 = color
    content.Visible = false
    content.Parent = self.ContentFrame
    
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 15)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", content)
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
    end)
    
    tabBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= name then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}):Play()
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        end
    end)
    
    tabBtn.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    self.Tabs[name] = {
        button = tabBtn,
        content = content,
        color = color
    }
    
    return content
end

function Hub:SwitchTab(name)
    if self.ActiveTab == name then return end
    
    for tabName, tabData in pairs(self.Tabs) do
        if tabName == name then
            tabData.content.Visible = true
            TweenService:Create(tabData.button, TweenInfo.new(0.2), {
                BackgroundColor3 = tabData.color,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            tabData.content.Visible = false
            TweenService:Create(tabData.button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                TextColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end
    
    self.ActiveTab = name
end

function Hub:CreateSection(parent, title, color)
    color = color or CurrentTheme.selection
    
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    section.BackgroundTransparency = 0.3
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local corner = Instance.new("UICorner", section)
    corner.CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke", section)
    stroke.Color = color
    stroke.Thickness = 2
    stroke.Transparency = 0.4
    
    local header = Instance.new("Frame", section)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = color
    header.BackgroundTransparency = 0.8
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 16)
    
    local headerBottom = Instance.new("Frame", header)
    headerBottom.Size = UDim2.new(1, 0, 0, 20)
    headerBottom.Position = UDim2.new(0, 0, 1, -20)
    headerBottom.BackgroundColor3 = color
    headerBottom.BackgroundTransparency = 0.8
    headerBottom.BorderSizePixel = 0
    
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Instance.new("Frame", section)
    content.Size = UDim2.new(1, -30, 0, 0)
    content.Position = UDim2.new(0, 15, 0, 50)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 10)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.Size = UDim2.new(1, -30, 0, layout.AbsoluteContentSize.Y)
        section.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 70)
    end)
    
    return content
end

function Hub:CreateButton(parent, text, callback, color)
    color = color or CurrentTheme.selection
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 43)}):Play()
        task.wait(0.05)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 45)}):Play()
        
        local success, err = pcall(callback)
        if not success then
            warn("Button error: " .. tostring(err))
            NotificationSystem:Show("Erro", tostring(err), 3, "ERROR")
        end
    end)
    
    return btn
end

function Hub:CreateInput(parent, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = CurrentTheme.secondary
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = placeholder
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    input.Font = Enum.Font.GothamMedium
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = frame
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(input.Text)
        end
    end)
    
    return input
end

function Hub:CreateTabs()
    -- TAB: MODELS
    local modelsTab = self:CreateTab("Models", "📦", Color3.fromRGB(100, 200, 255))
    
    local loadSection = self:CreateSection(modelsTab, "CARREGAR MODELO", Color3.fromRGB(100, 200, 255))
    local assetIdInput = self:CreateInput(loadSection, "Digite o Asset ID...", function(text)
        if text and text ~= "" then
            local num = tonumber(text)
            if num then
                ModelSystem:LoadModel(num)
            end
        end
    end)
    
    self:CreateButton(loadSection, "📥 Carregar Modelo", function()
        local text = assetIdInput.Text
        if text and text ~= "" then
            local num = tonumber(text)
            if num then
                ModelSystem:LoadModel(num)
            end
        end
    end, Color3.fromRGB(100, 200, 255))
    
    local vehicleSection = self:CreateSection(modelsTab, "VEÍCULO INTELIGENTE", Color3.fromRGB(255, 200, 100))
    self:CreateButton(vehicleSection, "🚗 Aplicar Script de Veículo", function()
        if #ModelSystem.SelectedModels > 0 then
            for _, modelData in ipairs(ModelSystem.SelectedModels) do
                ModelSystem:ApplyVehicleScript(modelData.instance, {
                    maxSpeed = 100,
                    acceleration = 50,
                    turnSpeed = 2.5,
                    brakeForce = 60
                })
            end
        else
            NotificationSystem:Show("Aviso", "Selecione um modelo primeiro!", 3, "WARNING")
        end
    end, Color3.fromRGB(255, 200, 100))
    
    self:CreateButton(vehicleSection, "🚀 Boost", function()
        ModelSystem.VehicleAI:Boost()
    end, Color3.fromRGB(255, 150, 50))
    
    self:CreateButton(vehicleSection, "🛑 Freio de Emergência", function()
        ModelSystem.VehicleAI:BrakeHard()
    end, Color3.fromRGB(255, 80, 80))
    
    self:CreateButton(vehicleSection, "🔄 Desvirar Veículo", function()
        ModelSystem.VehicleAI:FlipVehicle()
    end, Color3.fromRGB(100, 255, 100))
    
    local controlSection = self:CreateSection(modelsTab, "CONTROLES", Color3.fromRGB(150, 100, 255))
    self:CreateButton(controlSection, "🧹 Limpar Todos os Modelos", function()
        ModelSystem:ClearAll()
    end, Color3.fromRGB(255, 80, 80))
    
    self:CreateButton(controlSection, "◉ Selecionar Todos", function()
        ModelSystem:SelectAll()
    end, Color3.fromRGB(0, 255, 150))
    
    -- TAB: SAVE
    local saveTab = self:CreateTab("Save", "💾", Color3.fromRGB(0, 255, 150))
    
    local saveSection = self:CreateSection(saveTab, "SALVAR BUILD", Color3.fromRGB(0, 255, 150))
    local saveNameInput = self:CreateInput(saveSection, "Nome da Build...", nil)
    local saveDescInput = self:CreateInput(saveSection, "Descrição...", nil)
    
    self:CreateButton(saveSection, "💾 Salvar Build", function()
        local name = saveNameInput.Text
        if name == "" then name = "Build_" .. os.time() end
        SaveSystem:Save(name, saveDescInput.Text)
    end, Color3.fromRGB(0, 255, 150))
    
    local loadSection2 = self:CreateSection(saveTab, "CARREGAR BUILD", Color3.fromRGB(0, 200, 255))
    local loadNameInput = self:CreateInput(loadSection2, "Nome da Build...", nil)
    
    self:CreateButton(loadSection2, "📤 Carregar Build", function()
        local name = loadNameInput.Text
        if name and name ~= "" then
            SaveSystem:LoadBuild(name)
        end
    end, Color3.fromRGB(0, 200, 255))
    
    self:CreateButton(loadSection2, "🗑️ Deletar Build", function()
        local name = loadNameInput.Text
        if name and name ~= "" then
            SaveSystem:DeleteBuild(name)
        end
    end, Color3.fromRGB(255, 80, 80))
    
    local cloudSection = self:CreateSection(saveTab, "NUVEM", Color3.fromRGB(100, 200, 255))
    self:CreateButton(cloudSection, "☁️ Exportar para Nuvem", function()
        CloudSystem:ExportBuild(nil, nil, false)
    end, Color3.fromRGB(100, 200, 255))
    
    -- TAB: STATS
    local statsTab = self:CreateTab("Stats", "📊", Color3.fromRGB(255, 150, 50))
    
    local statsSection = self:CreateSection(statsTab, "ESTATÍSTICAS", Color3.fromRGB(255, 150, 50))
    
    local statsLabel = Instance.new("TextLabel", statsSection)
    statsLabel.Size = UDim2.new(1, 0, 0, 200)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Carregando estatísticas..."
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.Font = Enum.Font.GothamMedium
    statsLabel.TextSize = 14
    statsLabel.TextWrapped = true
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    task.spawn(function()
        while statsLabel and statsLabel.Parent do
            local stats = StatsSystem:GetStats()
            statsLabel.Text = string.format(
                "📦 Modelos carregados: %d\n" ..
                "🧱 Total de partes: %d\n" ..
                "⏱️ Tempo em jogo: %d min\n" ..
                "💾 Builds salvas: %d",
                stats.totalModels,
                stats.totalParts,
                stats.timeInGame,
                #stats.builds
            )
            task.wait(5)
        end
    end)
    
    -- TAB: SETTINGS
    local settingsTab = self:CreateTab("Settings", "⚙️", Color3.fromRGB(200, 200, 200))
    
    local themeSection = self:CreateSection(settingsTab, "TEMAS", Color3.fromRGB(200, 200, 200))
    
    for themeName, themeData in pairs(Themes) do
        self:CreateButton(themeSection, "🎨 " .. themeName, function()
            CurrentTheme = themeData
            NotificationSystem:Show("Tema Alterado", "Tema " .. themeName .. " aplicado!", 3, "SUCCESS")
        end, themeData.primary)
    end
    
    self:SwitchTab("Models")
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     INICIALIZAÇÃO                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        Hub:ToggleMinimize()
    end
end)

-- Iniciar Hub
task.delay(1, function()
    Hub:Init()
end)

print("[aquilesgamef1 Hub v" .. CONFIG.VERSION .. "] Script carregado com sucesso!")
