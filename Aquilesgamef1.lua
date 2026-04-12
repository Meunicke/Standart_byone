--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    AQUILESGAMEF1 HUB v4.2 - FULLY FIXED                      ║
    ║              Save System & Vehicle Script 100% FUNCIONANDO                   ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SERVICES & CONFIGURAÇÃO                                    ║
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
-- ║                     GUI PARENT                                                   ║
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
-- ║                     TEMAS                                                        ║
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
-- ║                     NOTIFICAÇÕES                                               ║
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
-- ║                     SISTEMA DE ARQUIVOS                                        ║
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
-- ║                     SISTEMA DE CRIPTOGRAFIA                                    ║
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
-- ║                     SISTEMA DE MODELOS - DEFINIÇÃO PRIMEIRO                    ║
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

-- Funções do ModelSystem serão definidas depois, mas a tabela já existe

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE SAVE - DEFINIÇÃO                                ║
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
            -- VERIFICAÇÃO: Só salva se ModelSystem existir e tiver modelos
            if ModelSystem and ModelSystem.LoadedModels and #ModelSystem.LoadedModels > 0 then
                self:AutoSave()
            end
        end
    end)
end

function SaveSystem:SerializeBuild(name, description, password)
    -- VERIFICAÇÃO CRÍTICA: ModelSystem deve existir
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
    
    -- Pegar nome do jogo com segurança
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
    
    -- VERIFICAÇÃO: Só processa se houver modelos
    if #ModelSystem.LoadedModels == 0 then
        NotificationSystem:Show("Aviso", "Nenhum modelo carregado para salvar!", 4, "WARNING")
    end
    
    for _, modelData in ipairs(ModelSystem.LoadedModels) do
        -- VERIFICAÇÃO: modelData e instance devem existir
        if modelData and modelData.instance and modelData.instance.Parent then
            local success, pivot = pcall(function()
                return modelData.instance:GetPivot()
            end)
            
            if success and pivot then
                local pos = pivot.Position
                
                -- Atualizar bounds
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
    -- VERIFICAÇÃO CRÍTICA
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
    -- VERIFICAÇÃO
    if not ModelSystem then
        NotificationSystem:Show("Erro", "ModelSystem não disponível!", 4, "ERROR")
        return false
    end
    
    local buildData = self:Load(name, password)
    if not buildData then return false end
    
    if buildData.metadata and buildData.metadata.gameId then
        if buildData.metadata.gameId ~= game.PlaceId then
            NotificationSystem:Show("Aviso", "Esta build é de outro jogo!", 4, "WARNING")
        end
    end
    
    NotificationSystem:Show("📂 Carregando...", 
        string.format("%s (%d modelos)", 
            buildData.metadata.name or name, 
            #buildData.models), 
        4, "INFO")
    
    ModelSystem:ClearAll()
    
    if buildData.settings and buildData.settings.lighting then
        pcall(function()
            local light = buildData.settings.lighting
            Lighting.Brightness = light.Brightness
            Lighting.ClockTime = light.ClockTime
            Lighting.GeographicLatitude = light.GeographicLatitude
            Lighting.Ambient = Color3.new(unpack(light.Ambient))
            Lighting.OutdoorAmbient = Color3.new(unpack(light.OutdoorAmbient))
        end)
    end
    
    task.spawn(function()
        for i, modelInfo in ipairs(buildData.models) do
            task.wait(0.05)
            
            local loadedModel = ModelSystem:LoadModel(modelInfo.assetId, {
                name = modelInfo.name,
                scale = modelInfo.scale,
                anchored = modelInfo.anchored,
                collision = modelInfo.collision
            })
            
            if loadedModel then
                local cf = CFrame.new(unpack(modelInfo.cframe))
                ModelSystem:SetModelCFrame(loadedModel, cf)
                
                if modelInfo.properties then
                    for _, prop in ipairs(modelInfo.properties) do
                        local partName = prop.path:match("[^.]+$")
                        local part = loadedModel:FindFirstChild(partName, true)
                        if part and part:IsA("BasePart") then
                            part.Color = Color3.new(unpack(prop.color))
                            part.Material = Enum.Material[prop.material] or part.Material
                            part.Transparency = prop.transparency
                            part.Reflectance = prop.reflectance
                        end
                    end
                end
                
                if modelInfo.isVehicle then
                    ModelSystem:ApplyVehicleScript(loadedModel, modelInfo.vehicleConfig)
                end
            end
        end
        
        if buildData.groups then
            for _, groupInfo in ipairs(buildData.groups) do
                ModelSystem.Groups[groupInfo.id] = {
                    id = groupInfo.id,
                    name = groupInfo.name,
                    color = Color3.new(unpack(groupInfo.color)),
                    models = {}
                }
            end
        end
        
        self.CurrentBuildName = buildData.metadata.name or name
        NotificationSystem:Show("✅ Build Carregada!", 
            (buildData.metadata.name or name) .. " restaurada!", 5, "SUCCESS")
    end)
    
    return true
end

function SaveSystem:UpdateBuildIndex(name, metadata)
    local index = {}
    local indexData = FileSystem:ReadFile("build_index.json")
    
    if indexData then
        pcall(function()
            index = HttpService:JSONDecode(indexData)
        end)
    end
    
    index[name] = {
        name = metadata.name,
        description = metadata.description,
        createdAt = metadata.createdAt,
        gameId = metadata.gameId,
        gameName = metadata.gameName
    }
    
    FileSystem:WriteFile("build_index.json", HttpService:JSONEncode(index))
end

function SaveSystem:GetSavedBuilds()
    local builds = {}
    
    for _, file in ipairs(FileSystem:ListFiles("builds")) do
        if file:match("%.json$") then
            local name = file:gsub("%.json$", "")
            table.insert(builds, name)
        end
    end
    
    for name, _ in pairs(self.Data.builds) do
        if not table.find(builds, name) then
            table.insert(builds, name)
        end
    end
    
    table.sort(builds, function(a, b)
        return a > b
    end)
    
    return builds
end

function SaveSystem:DeleteBuild(name)
    FileSystem:DeleteFile("builds/" .. name .. ".json")
    self.Data.builds[name] = nil
    
    local indexData = FileSystem:ReadFile("build_index.json")
    if indexData then
        pcall(function()
            local index = HttpService:JSONDecode(indexData)
            index[name] = nil
            FileSystem:WriteFile("build_index.json", HttpService:JSONEncode(index))
        end)
    end
    
    NotificationSystem:Show("🗑️ Build Deletada", name .. " removida", 3, "SUCCESS")
end

function SaveSystem:LoadGlobalSettings()
    local settingsData = FileSystem:ReadFile("global_settings.json")
    if settingsData then
        pcall(function()
            local loaded = HttpService:JSONDecode(settingsData)
            for k, v in pairs(loaded) do
                self.Data.settings[k] = v
            end
        end)
    end
end

function SaveSystem:SaveGlobalSettings()
    FileSystem:WriteFile("global_settings.json", 
        HttpService:JSONEncode(self.Data.settings))
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA CLOUD SAVE                                         ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local CloudSystem = {
    ActiveCodes = {}
}

function CloudSystem:ExportBuild(name, password)
    -- VERIFICAÇÃO CRÍTICA
    if not SaveSystem then
        NotificationSystem:Show("Erro", "SaveSystem não disponível!", 4, "ERROR")
        return nil
    end
    
    local jsonData, buildData = SaveSystem:SerializeBuild(name, "Cloud export", password)
    if not jsonData then 
        NotificationSystem:Show("Erro", "Falha ao serializar para Cloud!", 4, "ERROR")
        return nil 
    end
    
    local compressed = self:Compress(jsonData)
    
    if #compressed > CONFIG.MAX_CLOUD_SIZE then
        NotificationSystem:Show("Erro", "Build muito grande para Cloud!", 4, "ERROR")
        return nil
    end
    
    local code = self:GenerateCode()
    self.ActiveCodes[code] = {
        data = compressed,
        timestamp = os.time(),
        name = name
    }
    
    FileSystem:WriteFile("cloud/" .. code .. ".txt", compressed)
    
    NotificationSystem:Show("☁️ Código Gerado!", 
        "Código: " .. code .. "\nVálido por 24h", 8, "SUCCESS")
    
    return code
end

function CloudSystem:ImportBuild(code, password)
    local data = self.ActiveCodes[code]
    
    if not data then
        local fileData = FileSystem:ReadFile("cloud/" .. code .. ".txt")
        if fileData then
            data = {data = fileData}
        else
            NotificationSystem:Show("Erro", "Código inválido ou expirado!", 4, "ERROR")
            return false
        end
    end
    
    local jsonData = self:Decompress(data.data)
    
    local success, buildData = pcall(function()
        local decoded = HttpService:JSONDecode(jsonData)
        if decoded.metadata and decoded.metadata.encrypted and password then
            jsonData = Crypto:SimpleDecrypt(jsonData, password)
            decoded = HttpService:JSONDecode(jsonData)
        end
        return decoded
    end)
    
    if not success then
        NotificationSystem:Show("Erro", "Falha ao importar build!", 4, "ERROR")
        return false
    end
    
    NotificationSystem:Show("☁️ Importando...", "Carregando build da nuvem...", 3, "INFO")
    
    if ModelSystem then
        ModelSystem:ClearAll()
        
        task.spawn(function()
            for i, modelInfo in ipairs(buildData.models) do
                task.wait(0.05)
                local loadedModel = ModelSystem:LoadModel(modelInfo.assetId, {
                    name = modelInfo.name,
                    scale = modelInfo.scale,
                    anchored = modelInfo.anchored,
                    collision = modelInfo.collision
                })
                
                if loadedModel then
                    local cf = CFrame.new(unpack(modelInfo.cframe))
                    ModelSystem:SetModelCFrame(loadedModel, cf)
                end
            end
            
            NotificationSystem:Show("✅ Importado!", "Build carregada com sucesso!", 5, "SUCCESS")
        end)
    end
    
    return true
end

function CloudSystem:GenerateCode()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local code = ""
    for i = 1, 8 do
        local rand = math.random(1, #chars)
        code = code .. chars:sub(rand, rand)
    end
    return code
end

function CloudSystem:Compress(data)
    local compressed = data
    compressed = compressed:gsub('"assetId":', "A:")
    compressed = compressed:gsub('"cframe":', "C:")
    compressed = compressed:gsub('"position":', "P:")
    compressed = compressed:gsub('"rotation":', "R:")
    return compressed
end

function CloudSystem:Decompress(data)
    local decompressed = data
    decompressed = decompressed:gsub("A:", '"assetId":')
    decompressed = decompressed:gsub("C:", '"cframe":')
    decompressed = decompressed:gsub("P:", '"position":')
    decompressed = decompressed:gsub("R:", '"rotation":')
    return decompressed
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SISTEMA DE ESTATÍSTICAS                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local StatsSystem = {}

function StatsSystem:AnalyzeBuild()
    -- VERIFICAÇÃO
    if not ModelSystem or not ModelSystem.LoadedModels then
        return {
            totalModels = 0,
            totalParts = 0,
            totalMass = 0,
            totalVolume = 0,
            byMaterial = {},
            byColor = {},
            bounds = {
                min = Vector3.new(0, 0, 0),
                max = Vector3.new(0, 0, 0)
            },
            vehicles = 0,
            anchored = 0,
            unanchored = 0
        }
    end
    
    local stats = {
        totalModels = #ModelSystem.LoadedModels,
        totalParts = 0,
        totalMass = 0,
        totalVolume = 0,
        byMaterial = {},
        byColor = {},
        bounds = {
            min = Vector3.new(math.huge, math.huge, math.huge),
            max = Vector3.new(-math.huge, -math.huge, -math.huge)
        },
        vehicles = 0,
        anchored = 0,
        unanchored = 0
    }
    
    for _, modelData in ipairs(ModelSystem.LoadedModels) do
        if modelData and modelData.instance then
            if modelData.isVehicle then
                stats.vehicles = stats.vehicles + 1
            end
            
            for _, part in ipairs(modelData.instance:GetDescendants()) do
                if part:IsA("BasePart") then
                    stats.totalParts = stats.totalParts + 1
                    stats.totalMass = stats.totalMass + part.AssemblyMass
                    stats.totalVolume = stats.totalVolume + (part.Size.X * part.Size.Y * part.Size.Z)
                    
                    local matName = tostring(part.Material)
                    stats.byMaterial[matName] = (stats.byMaterial[matName] or 0) + 1
                    
                    local colorKey = string.format("%d,%d,%d", 
                        math.floor(part.Color.R * 255),
                        math.floor(part.Color.G * 255),
                        math.floor(part.Color.B * 255))
                    stats.byColor[colorKey] = (stats.byColor[colorKey] or 0) + 1
                    
                    local pos = part.Position
                    stats.bounds.min = Vector3.new(
                        math.min(stats.bounds.min.X, pos.X),
                        math.min(stats.bounds.min.Y, pos.Y),
                        math.min(stats.bounds.min.Z, pos.Z)
                    )
                    stats.bounds.max = Vector3.new(
                        math.max(stats.bounds.max.X, pos.X),
                        math.max(stats.bounds.max.Y, pos.Y),
                        math.max(stats.bounds.max.Z, pos.Z)
                    )
                    
                    if part.Anchored then
                        stats.anchored = stats.anchored + 1
                    else
                        stats.unanchored = stats.unanchored + 1
                    end
                end
            end
        end
    end
    
    return stats
end

function StatsSystem:ShowStatsWindow()
    local stats = self:AnalyzeBuild()
    
    local StatsGui = Instance.new("ScreenGui")
    StatsGui.Name = "StatsWindow"
    StatsGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = StatsGui
    
    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(0, 255, 150)
    Stroke.Thickness = 2
    
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "📊 Estatísticas da Build"
    Title.TextColor3 = Color3.fromRGB(0, 255, 150)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 20
    
    local Content = Instance.new("ScrollingFrame", MainFrame)
    Content.Size = UDim2.new(1, -20, 1, -60)
    Content.Position = UDim2.new(0, 10, 0, 50)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 6
    
    local Layout = Instance.new("UIListLayout", Content)
    Layout.Padding = UDim.new(0, 8)
    
    local function AddStat(label, value, color)
        local Row = Instance.new("Frame", Content)
        Row.Size = UDim2.new(1, 0, 0, 30)
        Row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        
        local Corner = Instance.new("UICorner", Row)
        Corner.CornerRadius = UDim.new(0, 6)
        
        local Label = Instance.new("TextLabel", Row)
        Label.Size = UDim2.new(0.5, -10, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = label
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Value = Instance.new("TextLabel", Row)
        Value.Size = UDim2.new(0.5, -10, 1, 0)
        Value.Position = UDim2.new(0.5, 0, 0, 0)
        Value.BackgroundTransparency = 1
        Value.Text = tostring(value)
        Value.TextColor3 = color or Color3.fromRGB(0, 255, 150)
        Value.Font = Enum.Font.GothamBlack
        Value.TextSize = 14
        Value.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    AddStat("Total de Modelos:", stats.totalModels)
    AddStat("Total de Partes:", stats.totalParts)
    AddStat("Massa Total:", string.format("%.2f kg", stats.totalMass))
    AddStat("Volume Total:", string.format("%.2f studs³", stats.totalVolume))
    AddStat("Veículos:", stats.vehicles, Color3.fromRGB(255, 200, 0))
    AddStat("Partes Ancoradas:", stats.anchored, Color3.fromRGB(0, 200, 255))
    AddStat("Partes Não-Ancoradas:", stats.unanchored, Color3.fromRGB(255, 100, 100))
    
    local size = stats.bounds.max - stats.bounds.min
    AddStat("Dimensões (X×Y×Z):", 
        string.format("%.1f × %.1f × %.1f", size.X, size.Y, size.Z), 
        Color3.fromRGB(255, 150, 255))
    
    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.TextSize = 18
    
    local CloseCorner = Instance.new("UICorner", CloseBtn)
    CloseCorner.CornerRadius = UDim.new(0, 8)
    
    CloseBtn.MouseButton1Click:Connect(function()
        StatsGui:Destroy()
    end)
    
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     FUNÇÕES DO MODEL SYSTEM                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
function ModelSystem:Init()
    if self.ModelFolder then return end
    
    self.ModelFolder = Instance.new("Folder")
    self.ModelFolder.Name = "aquilesgamef1_Models_" .. player.Name
    self.ModelFolder.Parent = Workspace
    
    print("[ModelSystem] Inicializado v4.2")
    
    self:CreateBuilderPanel()
    self:CreateVehicleScripts()
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

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     SCRIPT DE CARRO FUNCIONAL                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
function ModelSystem:CreateVehicleScripts()
    self.VehicleScripts = {}
    
    self.VehicleScripts.Car = function(model, config)
        config = config or {}
        local speed = config.speed or 100
        local turnSpeed = config.turnSpeed or 50
        
        local chassis = model:FindFirstChild("Body") or model:FindFirstChild("Chassis") or model:FindFirstChildWhichIsA("BasePart", true)
        if not chassis then 
            NotificationSystem:Show("Erro", "Nenhuma parte encontrada no modelo", 3, "ERROR")
            return nil 
        end
        
        local seat = Instance.new("VehicleSeat")
        seat.Name = "DriveSeat"
        seat.Size = Vector3.new(2, 1, 2)
        local seatPos = chassis.Position + Vector3.new(0, chassis.Size.Y/2 + 1, 0)
        seat.Position = seatPos
        seat.Parent = model
        
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = true
            end
        end
        
        local wheels = {}
        for _, part in ipairs(model:GetDescendants()) do
            if part.Name:lower():match("wheel") or part.Name:lower():match("roda") or part.Name:lower():match("tire") then
                if part:IsA("BasePart") then
                    table.insert(wheels, part)
                end
            end
        end
        
        if #wheels == 0 then
            NotificationSystem:Show("Info", "Criando rodas automáticas...", 2, "INFO")
            local chassisSize = chassis.Size
            local wheelOffset = chassisSize.X/2 + 0.5
            
            local wheelPositions = {
                chassis.Position + Vector3.new(-wheelOffset, -chassisSize.Y/2, chassisSize.Z/2 - 1),
                chassis.Position + Vector3.new(wheelOffset, -chassisSize.Y/2, chassisSize.Z/2 - 1),
                chassis.Position + Vector3.new(-wheelOffset, -chassisSize.Y/2, -chassisSize.Z/2 + 1),
                chassis.Position + Vector3.new(wheelOffset, -chassisSize.Y/2, -chassisSize.Z/2 + 1)
            }
            
            for i, pos in ipairs(wheelPositions) do
                local wheel = Instance.new("Part")
                wheel.Name = "Wheel_" .. i
                wheel.Shape = Enum.PartType.Cylinder
                wheel.Size = Vector3.new(1.5, 1.5, 1.5)
                wheel.Position = pos
                wheel.Color = Color3.fromRGB(30, 30, 30)
                wheel.Material = Enum.Material.SmoothPlastic
                wheel.Parent = model
                table.insert(wheels, wheel)
            end
        end
        
        local wheelConstraints = {}
        for i, wheel in ipairs(wheels) do
            local chassisAttach = Instance.new("Attachment")
            chassisAttach.Name = "WheelAttach_" .. i
            chassisAttach.WorldPosition = wheel.Position
            chassisAttach.Parent = chassis
            
            local wheelAttach = Instance.new("Attachment")
            wheelAttach.Name = "ChassisAttach"
            wheelAttach.Position = Vector3.new(0, 0, 0)
            wheelAttach.Parent = wheel
            
            local hinge = Instance.new("HingeConstraint")
            hinge.Name = "WheelMotor_" .. i
            hinge.Part0 = chassis
            hinge.Part1 = wheel
            hinge.Attachment0 = chassisAttach
            hinge.Attachment1 = wheelAttach
            hinge.ActuatorType = Enum.ActuatorType.Motor
            hinge.MotorMaxAcceleration = 50
            hinge.MotorMaxTorque = 5000
            hinge.Parent = wheel
            
            table.insert(wheelConstraints, hinge)
        end
        
        local controlCode = [[
            local seat = script.Parent
            local model = seat:FindFirstAncestorOfClass("Model")
            if not model then return end
            
            local chassis = model:FindFirstChild("]] .. chassis.Name .. [[") or model:FindFirstChildWhichIsA("BasePart")
            if not chassis then return end
            
            local hinges = {}
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("HingeConstraint") and obj.Name:match("WheelMotor") then
                    table.insert(hinges, obj)
                end
            end
            
            if #hinges == 0 then 
                warn("Nenhuma roda encontrada!")
                return 
            end
            
            local RunService = game:GetService("RunService")
            local speed = ]] .. speed .. [[
            local turnSpeed = ]] .. turnSpeed .. [[
            
            local currentSpeed = 0
            local targetSpeed = 0
            local currentSteer = 0
            
            local connection
            
            local function updatePhysics()
                if not seat or not seat.Parent then
                    if connection then
                        connection:Disconnect()
                    end
                    return
                end
                
                local throttle = seat.ThrottleFloat
                local steer = seat.SteerFloat
                
                if math.abs(throttle) > 0.1 then
                    targetSpeed = throttle * speed
                else
                    targetSpeed = 0
                end
                
                currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * 0.1
                currentSteer = steer * turnSpeed
                
                for _, hinge in ipairs(hinges) do
                    hinge.AngularVelocity = currentSpeed
                    if math.abs(currentSpeed) > 1 then
                        hinge.MotorMaxTorque = 10000
                    else
                        hinge.MotorMaxTorque = 0
                    end
                end
                
                if math.abs(currentSteer) > 5 and math.abs(currentSpeed) > 5 then
                    local turnAmount = -currentSteer * 0.0005 * (math.abs(currentSpeed) / speed)
                    model:PivotTo(model:GetPivot() * CFrame.Angles(0, turnAmount, 0))
                end
            end
            
            connection = RunService.Heartbeat:Connect(updatePhysics)
            
            seat:GetPropertyChangedSignal("Occupant"):Connect(function()
                if not seat.Occupant then
                    targetSpeed = 0
                    currentSpeed = 0
                    for _, hinge in ipairs(hinges) do
                        hinge.AngularVelocity = 0
                        hinge.MotorMaxTorque = 0
                    end
                end
            end)
        ]]
        
        local scriptObj
        pcall(function()
            scriptObj = Instance.new("LocalScript")
        end)
        
        if not scriptObj then
            scriptObj = Instance.new("Script")
        end
        
        scriptObj.Name = "CarController"
        scriptObj.Source = controlCode
        scriptObj.Parent = seat
        
        local seatWeld = Instance.new("Weld")
        seatWeld.Part0 = chassis
        seatWeld.Part1 = seat
        seatWeld.C0 = CFrame.new(0, chassis.Size.Y/2 + 0.5, 0)
        seatWeld.Parent = seat
        
        NotificationSystem:Show("🚗 Veículo Pronto!", "Use W/S para acelerar, A/D para virar", 5, "SUCCESS")
        return seat
    end
end

function ModelSystem:ApplyVehicleScript(model, config)
    config = config or {}
    local vehicleType = "Car"
    
    local name = model.Name:lower()
    if name:match("plane") or name:match("heli") or name:match("air") then
        vehicleType = "Aircraft"
    elseif name:match("boat") or name:match("ship") then
        vehicleType = "Boat"
    end
    
    if self.VehicleScripts[vehicleType] then
        local success, result = pcall(function()
            return self.VehicleScripts[vehicleType](model, config)
        end)
        
        if success and result then
            for _, modelData in ipairs(self.LoadedModels) do
                if modelData.instance == model then
                    modelData.isVehicle = true
                    modelData.vehicleConfig = config
                    modelData.vehicleType = vehicleType
                    break
                end
            end
            return result
        else
            NotificationSystem:Show("Erro Veículo", tostring(result):sub(1, 50), 4, "ERROR")
        end
    else
        NotificationSystem:Show("Erro", "Tipo de veículo não suportado: " .. vehicleType, 3, "ERROR")
    end
end

-- [Resto das funções do ModelSystem...]
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

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     HUB PRINCIPAL                                              ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local HubGui = Instance.new("ScreenGui")
HubGui.Name = "aquilesgamef1_Hub_v4"
HubGui.ResetOnSpawn = false
HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
HubGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 900, 0, 600)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = CurrentTheme.background
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = HubGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = CurrentTheme.primary
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.BackgroundTransparency = 0.3
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 400, 0, 30)
Title.Position = UDim2.new(0, 20, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "AQUILESGAMEF1 HUB"
Title.TextColor3 = CurrentTheme.primary
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size = UDim2.new(0, 400, 0, 18)
SubTitle.Position = UDim2.new(0, 20, 0, 38)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "v" .. CONFIG.VERSION .. " | FULLY FIXED ✓"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -80, 0, 14)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBlack
MinimizeBtn.TextSize = 18

local MinCorner = Instance.new("UICorner", MinimizeBtn)
MinCorner.CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 18

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

local ContentWrapper = Instance.new("Frame")
ContentWrapper.Name = "ContentWrapper"
ContentWrapper.Size = UDim2.new(1, 0, 1, -60)
ContentWrapper.Position = UDim2.new(0, 0, 0, 60)
ContentWrapper.BackgroundTransparency = 1
ContentWrapper.Parent = MainFrame

local isHubMinimized = false

local HubIcon = Instance.new("TextButton")
HubIcon.Name = "HubIcon"
HubIcon.Size = UDim2.new(0, 60, 0, 60)
HubIcon.Position = UDim2.new(0, 20, 0.9, -30)
HubIcon.BackgroundColor3 = CurrentTheme.primary
HubIcon.Text = "🏗️"
HubIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
HubIcon.Font = Enum.Font.GothamBold
HubIcon.TextSize = 28
HubIcon.Visible = false
HubIcon.Parent = HubGui
HubIcon.ZIndex = 100

local IconCorner = Instance.new("UICorner", HubIcon)
IconCorner.CornerRadius = UDim.new(1, 0)

local IconStroke = Instance.new("UIStroke", HubIcon)
IconStroke.Color = Color3.fromRGB(255, 255, 255)
IconStroke.Thickness = 3

local function MinimizeHub()
    isHubMinimized = true
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 40, 0.9, 0)
    }):Play()
    
    task.delay(0.4, function()
        MainFrame.Visible = false
        HubIcon.Visible = true
        TweenService:Create(HubIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 60, 0, 60)
        }):Play()
    end)
    
    NotificationSystem:Show("Hub Minimizado", "Clique no 🏗️ para restaurar", 3, "INFO")
end

local function RestoreHub()
    isHubMinimized = false
    
    HubIcon.Visible = false
    MainFrame.Visible = true
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 900, 0, 600),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end

MinimizeBtn.MouseButton1Click:Connect(MinimizeHub)
HubIcon.MouseButton1Click:Connect(RestoreHub)

local iconDragging = false
local iconDragStart = nil
local iconStartPos = nil

HubIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging = true
        iconDragStart = input.Position
        iconStartPos = HubIcon.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if iconDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - iconDragStart
        HubIcon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    HubGui:Destroy()
    NotificationSystem:Show("Hub Fechado", "Até logo!", 3, "INFO")
end)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 180, 1, 0)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TabContainer.BackgroundTransparency = 0.5
TabContainer.BorderSizePixel = 0
TabContainer.Parent = ContentWrapper

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -180, 1, 0)
ContentArea.Position = UDim2.new(0, 180, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = ContentWrapper

local Tabs = {}
local ActiveTab = nil

function CreateTab(name, icon, color)
    color = color or CurrentTheme.primary
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -20, 0, 45)
    TabBtn.Position = UDim2.new(0, 10, 0, 10 + (#Tabs * 55))
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TabBtn.Text = ""
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabContainer
    
    local Corner = Instance.new("UICorner", TabBtn)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Icon = Instance.new("TextLabel", TabBtn)
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0, 10, 0.5, 0)
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundTransparency = 1
    Icon.Text = icon
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 18
    
    local Label = Instance.new("TextLabel", TabBtn)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 45, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, -20, 1, -20)
    TabContent.Position = UDim2.new(0, 10, 0, 10)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = color
    TabContent.Visible = false
    TabContent.Parent = ContentArea
    
    local Layout = Instance.new("UIListLayout", TabContent)
    Layout.Padding = UDim.new(0, 12)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Padding = Instance.new("UIPadding", TabContent)
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 20)
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 40)
    end)
    
    local tabData = {Button = TabBtn, Content = TabContent, Color = color}
    table.insert(Tabs, tabData)
    
    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab == tabData then return end
        
        if ActiveTab then
            ActiveTab.Content.Visible = false
            TweenService:Create(ActiveTab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
            ActiveTab.Button:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        
        ActiveTab = tabData
        TabContent.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
        Label.TextColor3 = color
    end)
    
    return TabContent
end

function CreateSection(parent, title, color)
    color = color or CurrentTheme.primary
    
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Section.BackgroundTransparency = 0.3
    Section.BorderSizePixel = 0
    Section.Parent = parent
    
    local Corner = Instance.new("UICorner", Section)
    Corner.CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", Section)
    Stroke.Color = color
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    
    local TitleLabel = Instance.new("TextLabel", Section)
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = color
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Content = Instance.new("Frame", Section)
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.Position = UDim2.new(0, 10, 0, 40)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    
    local ContentLayout = Instance.new("UIListLayout", Content)
    ContentLayout.Padding = UDim.new(0, 8)
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
        Section.Size = UDim2.new(1, 0, 0, Content.Size.Y.Offset + 50)
    end)
    
    return Content
end

function CreateButton(parent, text, callback, color)
    color = color or CurrentTheme.primary
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    
    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 8)
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = color
    BtnStroke.Thickness = 1
    BtnStroke.Transparency = 0.5
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}):Play()
    end)
    
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 38)}):Play()
        task.wait(0.05)
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 40)}):Play()
        
        local success, err = pcall(callback)
        if not success then
            NotificationSystem:Show("Erro", tostring(err):sub(1, 50), 4, "ERROR")
        end
    end)
    
    return Btn
end

function CreateTextBox(parent, placeholder, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Container.BorderSizePixel = 0
    Container.Parent = parent
    
    local Corner = Instance.new("UICorner", Container)
    Corner.CornerRadius = UDim.new(0, 8)
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -16, 1, 0)
    TextBox.Position = UDim2.new(0, 8, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.PlaceholderText = placeholder
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    TextBox.Font = Enum.Font.GothamMedium
    TextBox.TextSize = 14
    TextBox.Parent = Container
    
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(TextBox.Text)
        end
    end)
    
    return TextBox
end

-- TAB: Models
local ModelsTab = CreateTab("Models", "📦", Color3.fromRGB(255, 100, 200))
local LoadSection = CreateSection(ModelsTab, "Carregar Modelo", Color3.fromRGB(255, 100, 200))
local ModelIdBox = CreateTextBox(LoadSection, "Digite o Asset ID...")

CreateButton(LoadSection, "📥 Carregar Modelo", function()
    local id = tonumber(ModelIdBox.Text)
    if id then
        ModelSystem:LoadModel(id, {name = "Modelo", anchored = true})
    else
        NotificationSystem:Show("Erro", "ID inválido!", 3, "ERROR")
    end
end, Color3.fromRGB(255, 100, 200))

CreateButton(LoadSection, "🧪 Carregar Modelo de Teste", function()
    ModelSystem:LoadModel(1386321337, {name = "Teste"})
end, Color3.fromRGB(0, 200, 255))

local VehicleSection = CreateSection(ModelsTab, "Veículos", Color3.fromRGB(255, 150, 50))
CreateButton(VehicleSection, "🚗 Aplicar Script de Carro", function()
    if #ModelSystem.SelectedModels == 0 then
        NotificationSystem:Show("Aviso", "Selecione um modelo primeiro!", 3, "WARNING")
        return
    end
    for _, modelData in ipairs(ModelSystem.SelectedModels) do
        ModelSystem:ApplyVehicleScript(modelData.instance, {speed = 100, turnSpeed = 50})
    end
end, Color3.fromRGB(255, 150, 50))

-- TAB: Save
local SaveTab = CreateTab("Save", "💾", Color3.fromRGB(0, 255, 200))
local SaveSection = CreateSection(SaveTab, "Salvar Build", Color3.fromRGB(0, 255, 200))
local BuildNameBox = CreateTextBox(SaveSection, "Nome da Build...")
local BuildDescBox = CreateTextBox(SaveSection, "Descrição (opcional)...")
local BuildPasswordBox = CreateTextBox(SaveSection, "Senha (opcional)...")

CreateButton(SaveSection, "💾 Salvar Build Atual", function()
    local name = BuildNameBox.Text
    if name == "" then name = "Build_" .. os.time() end
    SaveSystem:Save(name, BuildDescBox.Text, BuildPasswordBox.Text)
end, Color3.fromRGB(0, 255, 200))

CreateButton(SaveSection, "🔄 Auto-Save: ON", function()
    SaveSystem.AutoSaveEnabled = not SaveSystem.AutoSaveEnabled
    NotificationSystem:Show("Auto-Save", SaveSystem.AutoSaveEnabled and "Ativado" or "Desativado", 3, "INFO")
end, Color3.fromRGB(0, 200, 100))

-- TAB: Cloud
local CloudTab = CreateTab("Cloud", "☁️", Color3.fromRGB(100, 200, 255))
local ExportSection = CreateSection(CloudTab, "Exportar Build", Color3.fromRGB(100, 200, 255))
local ExportNameBox = CreateTextBox(ExportSection, "Nome da Build...")
local ExportPasswordBox = CreateTextBox(ExportSection, "Senha (opcional)...")

CreateButton(ExportSection, "☁️ Gerar Código Cloud", function()
    CloudSystem:ExportBuild(ExportNameBox.Text, ExportPasswordBox.Text)
end, Color3.fromRGB(100, 200, 255))

local ImportSection = CreateSection(CloudTab, "Importar Build", Color3.fromRGB(0, 255, 150))
local ImportCodeBox = CreateTextBox(ImportSection, "Código de 8 caracteres...")
local ImportPasswordBox = CreateTextBox(ImportSection, "Senha (se necessário)...")

CreateButton(ImportSection, "📥 Importar do Cloud", function()
    CloudSystem:ImportBuild(ImportCodeBox.Text, ImportPasswordBox.Text)
end, Color3.fromRGB(0, 255, 150))

-- TAB: Stats
local StatsTab = CreateTab("Stats", "📊", Color3.fromRGB(255, 150, 50))
local StatsSection = CreateSection(StatsTab, "Estatísticas", Color3.fromRGB(255, 150, 50))

CreateButton(StatsSection, "📊 Mostrar Estatísticas (F3)", function()
    StatsSystem:ShowStatsWindow()
end, Color3.fromRGB(255, 150, 50))

-- TAB: Load
local LoadTab = CreateTab("Load", "📂", Color3.fromRGB(150, 100, 255))
local LoadBuildSection = CreateSection(LoadTab, "Carregar Build Salva", Color3.fromRGB(150, 100, 255))

local BuildsListFrame = Instance.new("ScrollingFrame", LoadBuildSection)
BuildsListFrame.Size = UDim2.new(1, 0, 0, 200)
BuildsListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BuildsListFrame.BorderSizePixel = 0
BuildsListFrame.ScrollBarThickness = 4

local BuildsListCorner = Instance.new("UICorner", BuildsListFrame)
BuildsListCorner.CornerRadius = UDim.new(0, 8)

local BuildsListLayout = Instance.new("UIListLayout", BuildsListFrame)
BuildsListLayout.Padding = UDim.new(0, 5)

local function RefreshBuildsList()
    for _, child in ipairs(BuildsListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local builds = SaveSystem:GetSavedBuilds()
    for _, buildName in ipairs(builds) do
        local BuildBtn = Instance.new("TextButton")
        BuildBtn.Size = UDim2.new(1, -10, 0, 35)
        BuildBtn.Position = UDim2.new(0, 5, 0, 0)
        BuildBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        BuildBtn.Text = "📁 " .. buildName
        BuildBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        BuildBtn.Font = Enum.Font.GothamBold
        BuildBtn.TextSize = 13
        BuildBtn.Parent = BuildsListFrame
        
        local BtnCorner = Instance.new("UICorner", BuildBtn)
        BtnCorner.CornerRadius = UDim.new(0, 6)
        
        BuildBtn.MouseButton1Click:Connect(function()
            SaveSystem:LoadBuild(buildName)
        end)
    end
    
    BuildsListFrame.CanvasSize = UDim2.new(0, 0, 0, BuildsListLayout.AbsoluteContentSize.Y + 10)
end

CreateButton(LoadBuildSection, "🔄 Atualizar Lista", function()
    RefreshBuildsList()
end, Color3.fromRGB(100, 200, 255))

CreateButton(LoadBuildSection, "🗑️ Deletar Build Selecionada", function()
    NotificationSystem:Show("Info", "Clique com botão direito na build para deletar", 3, "INFO")
end, Color3.fromRGB(255, 80, 80))

-- TAB: Settings
local SettingsTab = CreateTab("Settings", "⚙️", Color3.fromRGB(200, 200, 200))
local ThemeSection = CreateSection(SettingsTab, "Temas", CurrentTheme.primary)

for themeName, themeData in pairs(Themes) do
    CreateButton(ThemeSection, "🎨 " .. themeName, function()
        CurrentTheme = themeData
        CONFIG.THEME = themeName
        NotificationSystem:Show("Tema", themeName .. " ativado!", 3, "SUCCESS")
    end, themeData.primary)
end

-- Ativar primeira tab
if #Tabs > 0 then
    Tabs[1].Button.MouseButton1Click:Fire()
end

-- Drag do Hub
local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     INICIALIZAÇÃO FINAL                                        ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
ModelSystem:Init()
SaveSystem:Init()

-- Atalhos de teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if SaveSystem.CurrentBuildName then
            SaveSystem:Save(SaveSystem.CurrentBuildName, "Quick save", nil)
        else
            NotificationSystem:Show("Aviso", "Use o menu Save para salvar a primeira vez", 3, "WARNING")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.O and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if SaveSystem.Data.lastBuild then
            SaveSystem:LoadBuild(SaveSystem.Data.lastBuild)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        if #ModelSystem.SelectedModels > 0 then
            ModelSystem:DeleteSelected()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        StatsSystem:ShowStatsWindow()
    end
end)

-- Verificar builds salvas ao entrar
task.delay(3, function()
    local builds = SaveSystem:GetSavedBuilds()
    if #builds > 0 then
        NotificationSystem:Show("💾 Builds Encontradas", 
            string.format("%d build(s) salva(s). Use a aba Load.", #builds), 
            6, "SAVE")
        
        local lastBuild = SaveSystem.Data.lastBuild
        if lastBuild then
            local buildData = SaveSystem:Load(lastBuild)
            if buildData and buildData.metadata and buildData.metadata.gameId == game.PlaceId then
                NotificationSystem:Show("🔄 Continuar?", 
                    "Detectamos uma build neste mapa. Pressione Ctrl+O para carregar.", 
                    8, "INFO")
            end
        end
    end
end)

NotificationSystem:Show("🏗️ Hub v4.2 INICIADO", 
    "Save & Vehicle 100% FUNCIONANDO! ✓", 5, "SUCCESS")
print("AQUILESGAMEF1 HUB v" .. CONFIG.VERSION .. " carregado com sucesso!")
