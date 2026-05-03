-- [[ SHADE-RS V2 + STRETCH + SKY + RGB WAVE FLUID v6.0 - NO GUI EDITION ]] --
local Lighting = game:GetService("Lighting")
local Terrain = game:GetService("Workspace").Terrain
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
local UserInputService = game:GetService("UserInputService")

-- [[ RESOLUTION STRETCH SYSTEM ]] --
getgenv().Resolution = {
    [".gg/scripters"] = 0.65
}

if getgenv().gg_scripters == nil then
    RunService.RenderStepped:Connect(function()
        Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
    end)
end
getgenv().gg_scripters = "Aori0001"

-- [[ SKY SYSTEM - IMPORTA CÉU DO MODELO ]] --
local SkyID = 116402178504134
local CurrentSky = nil
local DefaultSkyBackup = nil
local SkyLoaded = false

local function BackupDefaultSky()
    local existingSky = Lighting:FindFirstChildOfClass("Sky")
    if existingSky then
        DefaultSkyBackup = existingSky:Clone()
        DefaultSkyBackup.Name = "DefaultSkyBackup"
        DefaultSkyBackup.Parent = ReplicatedStorage
    end
end

local function TryLoadAssetAsync()
    local success, result = pcall(function()
        return AssetService:LoadAssetAsync(SkyID)
    end)
    
    if success and result then
        local skyObject = nil
        
        if result:IsA("Sky") then
            skyObject = result
        else
            for _, obj in pairs(result:GetDescendants()) do
                if obj:IsA("Sky") then
                    skyObject = obj
                    break
                end
            end
        end
        
        if skyObject then
            for _, child in pairs(Lighting:GetChildren()) do
                if child:IsA("Sky") then
                    child:Destroy()
                end
            end
            
            local newSky = skyObject:Clone()
            newSky.Name = "CustomSky_ShadRS"
            newSky.Parent = Lighting
            CurrentSky = newSky
            SkyLoaded = true
            print("Céu carregado via AssetService:LoadAssetAsync!")
            return true
        end
        
        result:Destroy()
    end
    return false
end

local function ApplySkyTextureDirect()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
    
    local newSky = Instance.new("Sky")
    newSky.Name = "CustomSky_ShadRS"
    
    local assetUrl = "rbxassetid://" .. SkyID
    
    newSky.SkyboxBk = assetUrl
    newSky.SkyboxDn = assetUrl
    newSky.SkyboxFt = assetUrl
    newSky.SkyboxLf = assetUrl
    newSky.SkyboxRt = assetUrl
    newSky.SkyboxUp = assetUrl
    
    newSky.SunTextureId = ""
    newSky.MoonTextureId = ""
    newSky.StarCount = 0
    
    newSky.Parent = Lighting
    CurrentSky = newSky
    SkyLoaded = true
    print("Céu aplicado via textura direta. ID: " .. SkyID)
end

local function TryGetObjects()
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. SkyID)
    end)
    
    if success and objects and #objects > 0 then
        local skyObject = nil
        
        for _, obj in pairs(objects) do
            if obj:IsA("Sky") then
                skyObject = obj
                break
            end
            for _, desc in pairs(obj:GetDescendants()) do
                if desc:IsA("Sky") then
                    skyObject = desc
                    break
                end
            end
            if skyObject then break end
        end
        
        if skyObject then
            for _, child in pairs(Lighting:GetChildren()) do
                if child:IsA("Sky") then
                    child:Destroy()
                end
            end
            
            local newSky = skyObject:Clone()
            newSky.Name = "CustomSky_ShadRS"
            newSky.Parent = Lighting
            CurrentSky = newSky
            SkyLoaded = true
            print("Céu carregado via GetObjects!")
            return true
        end
        
        for _, obj in pairs(objects) do
            obj:Destroy()
        end
    end
    return false
end

local function ApplyCustomSky()
    SkyLoaded = false
    
    if TryLoadAssetAsync() then return end
    if TryGetObjects() then return end
    
    ApplySkyTextureDirect()
end

local function RestoreDefaultSky()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end
    
    if DefaultSkyBackup then
        local restored = DefaultSkyBackup:Clone()
        restored.Name = "Sky"
        restored.Parent = Lighting
        CurrentSky = restored
        print("Céu original restaurado")
    else
        local defaultSky = Instance.new("Sky")
        defaultSky.Name = "Sky"
        defaultSky.SkyboxBk = "rbxassetid://6444884334"
        defaultSky.SkyboxDn = "rbxassetid://6444884785"
        defaultSky.SkyboxFt = "rbxassetid://6444884334"
        defaultSky.SkyboxLf = "rbxassetid://6444884334"
        defaultSky.SkyboxRt = "rbxassetid://6444884334"
        defaultSky.SkyboxUp = "rbxassetid://6444884334"
        defaultSky.Parent = Lighting
        CurrentSky = defaultSky
    end
end

-- [[ SHADER SYSTEM (SUAVE - SEM BRILHO FORTE) ]] --
local ShadersEnabled = false
local ShaderEffects = {}

local function ApplySoftShaders()
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1.8
    Lighting.ShadowSoftness = 0.15
    Lighting.EnvironmentDiffuseScale = 0.8
    Lighting.EnvironmentSpecularScale = 0.8
    
    local Bloom = Instance.new("BloomEffect", Lighting)
    Bloom.Intensity = 0.2
    Bloom.Size = 8
    Bloom.Threshold = 0.85
    table.insert(ShaderEffects, Bloom)
    
    local ColorCorr = Instance.new("ColorCorrectionEffect", Lighting)
    ColorCorr.Brightness = 0.03
    ColorCorr.Contrast = 0.15
    ColorCorr.Saturation = 0.2
    ColorCorr.TintColor = Color3.fromRGB(255, 252, 240)
    table.insert(ShaderEffects, ColorCorr)
    
    local SunRays = Instance.new("SunRaysEffect", Lighting)
    SunRays.Intensity = 0.05
    SunRays.Spread = 0.3
    table.insert(ShaderEffects, SunRays)
    
    local DOF = Instance.new("DepthOfFieldEffect", Lighting)
    DOF.FarIntensity = 0.08
    DOF.FocusDistance = 30
    DOF.InFocusRadius = 60
    table.insert(ShaderEffects, DOF)
    
    Terrain.WaterReflectance = 0.8
    Terrain.WaterTransparency = 0.5
    Terrain.WaterWaveSize = 0.1
    Terrain.WaterWaveSpeed = 1
    
    ShadersEnabled = true
end

local function DisableShaders()
    for _, effect in pairs(ShaderEffects) do
        if effect and effect.Parent then
            effect:Destroy()
        end
    end
    ShaderEffects = {}
    
    Lighting.GlobalShadows = true
    Lighting.Brightness = 1
    Lighting.FogEnd = 1000
    
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 1
    
    ShadersEnabled = false
end

-- [[ RGB WAVE FLUID v6.0 - EFEITO ONDINHA EM NOME E BIO ]] --
local LP = Players.LocalPlayer
local Remote = ReplicatedStorage.RE:FindFirstChild("1RPNam1eColo1r")

-- Configuração da Ondinha
local WAVE_SPEED = 1.5
local WAVE_AMPLITUDE = 0.3
local COLOR_SPEED = 0.4
local UPDATE_RATE = 0.03

local waveTime = 0
local hue = 0
local rgbRunning = true

local function GetWaveColor(baseHue, waveOffset)
    local wave = math.sin(waveTime * WAVE_SPEED + waveOffset) * WAVE_AMPLITUDE
    local h = (baseHue + wave) % 1
    
    local s = 0.8 + math.sin(waveTime * WAVE_SPEED * 0.7) * 0.2
    local v = 0.9 + math.sin(waveTime * WAVE_SPEED * 0.5) * 0.1
    
    local r, g, b
    local hi = math.floor(h * 6)
    local f = h * 6 - hi
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    if hi == 0 then r, g, b = v, t, p
    elseif hi == 1 then r, g, b = q, v, p
    elseif hi == 2 then r, g, b = p, v, t
    elseif hi == 3 then r, g, b = p, q, v
    elseif hi == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q
    end
    
    return Color3.new(
        math.clamp(r, 0, 1),
        math.clamp(g, 0, 1),
        math.clamp(b, 0, 1)
    )
end

local function SendSmoothColor(targetColor, isBio)
    if not Remote then return end
    
    pcall(function()
        Remote:FireServer(
            isBio and "PickingRPBioColor" or "PickingRPNameColor",
            targetColor
        )
    end)
end

-- Loop RGB Wave Fluid
local lastRgbUpdate = 0

RunService.Heartbeat:Connect(function(dt)
    if not rgbRunning then return end
    
    lastRgbUpdate = lastRgbUpdate + dt
    if lastRgbUpdate < UPDATE_RATE then return end
    lastRgbUpdate = 0
    
    waveTime = waveTime + dt
    hue = (hue + dt * COLOR_SPEED * 0.1) % 1
    
    local mainColor = GetWaveColor(hue, 0)
    local secondColor = GetWaveColor(hue, math.pi)
    
    SendSmoothColor(mainColor, false)
    SendSmoothColor(secondColor, true)
end)

-- [[ INICIALIZAÇÃO ]] --
BackupDefaultSky()

task.delay(1, function()
    ApplyCustomSky()
    ApplySoftShaders()
end)

-- [[ CONTROLE POR TECLADO ]] --
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F = Toggle Shaders
    if input.KeyCode == Enum.KeyCode.F then
        if not ShadersEnabled then
            ApplySoftShaders()
            print("Shaders: ON")
        else
            DisableShaders()
            print("Shaders: OFF")
        end
    end
    
    -- G = Toggle Sky
    if input.KeyCode == Enum.KeyCode.G then
        if CurrentSky and CurrentSky.Name == "CustomSky_ShadRS" then
            RestoreDefaultSky()
            print("Céu: ORIGINAL")
        else
            ApplyCustomSky()
            print("Céu: CUSTOM")
        end
    end
    
    -- Insert = Toggle RGB Wave
    if input.KeyCode == Enum.KeyCode.Insert then
        rgbRunning = not rgbRunning
        print("RGB Wave: " .. (rgbRunning and "ON" or "OFF"))
    end
    
    -- PageUp = Aumentar Wave Speed
    if input.KeyCode == Enum.KeyCode.PageUp then
        WAVE_SPEED = WAVE_SPEED + 0.5
        print("Wave Speed: " .. WAVE_SPEED)
    end
    
    -- PageDown = Diminuir Wave Speed
    if input.KeyCode == Enum.KeyCode.PageDown then
        WAVE_SPEED = math.max(0.1, WAVE_SPEED - 0.5)
        print("Wave Speed: " .. WAVE_SPEED)
    end
end)

-- Auto-restart RGB ao respawn
LP.CharacterAdded:Connect(function()
    task.wait(2)
    rgbRunning = true
end)

print("========================================")
print("SHADE-RS V2 + STRETCH + SKY + RGB WAVE")
print("Loaded Successfully!")
print("F = Toggle Shaders")
print("G = Toggle Céu (Custom/Original)")
print("Insert = Toggle RGB Wave Fluid")
print("PageUp/PageDown = Wave Speed")
print("========================================")
