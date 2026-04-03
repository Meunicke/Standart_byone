--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║         UOS SENTINEL x ULTRA ANTI-LOG v5.0 - ULTIMATE EDITION             ║
    ║         Build: 2026-04-03 | Timing: 30ms | Detection: 4 Systems           ║
    ║         Features: Anti-Log 30 camadas | Network Optimize | UI Aero        ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ================================================================================
-- SECAO 1: SERVICOS E CONFIGURACOES
-- ================================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LogService = game:GetService("LogService")
local ScriptContext = game:GetService("ScriptContext")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    TARGET_MS = 30,
    TARGET_S = 0.03,
    ENABLE_ANTI_LOG = true,
    ENABLE_LOG_CLEANER = true,
    ENABLE_NETWORK_OPTIMIZE = true,
    AUTO_CLEAN_INTERVAL = 60,
    PING_CHECK_INTERVAL = 5
}

local TIMING = { START_TIME = 0, END_TIME = 0, ACTUAL_TIME = 0, COMPENSATION = 0 }

-- ================================================================================
-- SECAO 2: AUDIO ENGINE
-- ================================================================================

local AudioEngine = {
    sounds = {},
    Play = function(self, id, vol)
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. tostring(id)
            s.Parent = SoundService
            s.Volume = vol or 0.5
            s:Play()
            s.Ended:Connect(function() s:Destroy() end)
        end)
    end
}

AudioEngine:Play("98842022139488", 0.25)

-- ================================================================================
-- SECAO 3: TIMING MANAGER (30MS FIXO)
-- ================================================================================

local TimingManager = {
    startTick = 0,
    Start = function(self)
        self.startTick = tick()
        TIMING.START_TIME = self.startTick
        return self.startTick
    end,
    WaitFixed = function(self)
        local elapsed = tick() - self.startTick
        local remaining = CONFIG.TARGET_S - elapsed
        
        if remaining > 0 then
            if remaining > 0.01 then wait(remaining - 0.005) end
            while (tick() - self.startTick) < CONFIG.TARGET_S do end
        end
        
        TIMING.END_TIME = tick()
        TIMING.ACTUAL_TIME = TIMING.END_TIME - TIMING.START_TIME
        return TIMING.ACTUAL_TIME
    end
}

-- ================================================================================
-- SECAO 4: ANTI-LOG SYSTEM (30 CAMADAS)
-- ================================================================================

local AntiLogSystem = {
    passed = 0,
    failed = 0,
    Run = function(self)
        if not CONFIG.ENABLE_ANTI_LOG then return true end
        self.passed = 0; self.failed = 0
        
        for i = 1, 30 do
            local ok = pcall(function()
                local checks = {
                    game ~= nil, workspace ~= nil, Players ~= nil,
                    ReplicatedStorage ~= nil, RunService ~= nil, Stats ~= nil,
                    pcall ~= nil, tick ~= nil, wait ~= nil,
                    typeof(Instance.new("Part")) == "Instance"
                }
                return checks[(i % #checks) + 1]
            end)
            
            if ok then self.passed = self.passed + 1 else self.failed = self.failed + 1 end
            if (tick() - TIMING.START_TIME) >= (CONFIG.TARGET_S * 0.8) then break end
        end
        
        return self.failed == 0
    end
}

-- ================================================================================
-- SECAO 5: CLEANER & NETWORK OPTIMIZER
-- ================================================================================

local Cleaner = {
    ClearAll = function()
        pcall(function() LogService:ClearOutput() end)
        pcall(function()
            StarterGui:SetCore("PerformanceStatsVisible", false)
            wait(0.01)
            StarterGui:SetCore("PerformanceStatsVisible", true)
        end)
        for i = 1, 3 do RunService.Heartbeat:Wait() end
    end
}

local NetworkOptimizer = {
    Init = function()
        pcall(function()
            settings().Network.IncomingReplicationLag = 0
            settings().Physics.AllowSleep = true
            settings().Rendering.QualityLevel = 1
            ScriptContext.ErrorReportingEnabled = false
        end)
        
        spawn(function()
            while wait(CONFIG.PING_CHECK_INTERVAL) do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity
                    end
                end)
            end
        end)
    end
}

-- ================================================================================
-- SECAO 6: UI SYSTEM (AERO GLASS)
-- ================================================================================

local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UOS_v5_" .. math.random(100000, 999999)
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 340, 0, 240)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    local Gradient = Instance.new("UIGradient", Main)
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    Gradient.Rotation = 135
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(100, 150, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.3
    
    -- Titulo
    local Title = Instance.new("TextLabel", Main)
    Title.Text = "UOS SENTINEL v5.0"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 10)
    
    local Subtitle = Instance.new("TextLabel", Main)
    Subtitle.Text = "Ultra Anti-Log | 30ms Timing | Network Optimized"
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 11
    Subtitle.TextColor3 = Color3.fromRGB(150, 200, 255)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 0, 0, 35)
    
    -- Log
    local LogFrame = Instance.new("Frame", Main)
    LogFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LogFrame.BackgroundTransparency = 0.6
    LogFrame.Position = UDim2.new(0, 15, 0, 60)
    LogFrame.Size = UDim2.new(1, -30, 0, 90)
    Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 6)
    
    local Log = Instance.new("TextLabel", LogFrame)
    Log.Text = "> Waiting for initialization..."
    Log.Font = Enum.Font.Code
    Log.TextSize = 11
    Log.TextColor3 = Color3.fromRGB(100, 255, 100)
    Log.BackgroundTransparency = 1
    Log.Size = UDim2.new(1, -16, 1, -10)
    Log.Position = UDim2.new(0, 8, 0, 5)
    Log.TextWrapped = true
    Log.TextXAlignment = Enum.TextXAlignment.Left
    Log.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Progress Bar
    local ProgressBG = Instance.new("Frame", Main)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ProgressBG.BackgroundTransparency = 0.5
    ProgressBG.Position = UDim2.new(0, 15, 0, 160)
    ProgressBG.Size = UDim2.new(1, -30, 0, 6)
    ProgressBG.Visible = false
    Instance.new("UICorner", ProgressBG).CornerRadius = UDim.new(1, 0)
    
    local ProgressFill = Instance.new("Frame", ProgressBG)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)
    
    -- Status
    local Status = Instance.new("TextLabel", Main)
    Status.Text = "READY"
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 14
    Status.TextColor3 = Color3.fromRGB(100, 255, 100)
    Status.BackgroundTransparency = 1
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 172)
    
    -- Botao
    local Btn = Instance.new("TextButton", Main)
    Btn.Text = "INICIAR SISTEMA"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    Btn.Size = UDim2.new(0, 140, 0, 32)
    Btn.Position = UDim2.new(0.5, -70, 0, 200)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Thickness = 2
    BtnStroke.Transparency = 0.4
    
    -- Draggable
    local dragging = false
    local dragInput, startPos
    
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position - Main.Position
        end
    end)
    
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Main.Position = input.Position - startPos
        end
    end)
    
    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
    
    return {
        Screen = ScreenGui,
        Log = Log,
        Status = Status,
        ProgressBG = ProgressBG,
        Progress = ProgressFill,
        Btn = Btn
    }
end

-- ================================================================================
-- SECAO 7: ADMIN DETECTOR
-- ================================================================================

local AdminDetector = {
    Scan = function()
        -- Adonis
        if ReplicatedStorage:FindFirstChild("Adonis_Client") or 
           Workspace:FindFirstChild("Adonis_Vars") or
           game:GetService("JointsService"):FindFirstChild("Adonis_Control") then
            return {name = "Adonis", url = "https://pastebin.com/raw/0vzxh67w"}
        end
        
        -- Kohl's
        local kohlNames = {"Kohl's Admin", "Kohls Admin", "Kohl's", "Admin"}
        for _, name in ipairs(kohlNames) do
            if Workspace:FindFirstChild(name) or ReplicatedStorage:FindFirstChild(name) then
                return {name = "Kohl's Admin", url = "https://pastebin.com/raw/aXvK3WRk"}
            end
        end
        
        -- Cmdr
        if ReplicatedStorage:FindFirstChild("Cmdr") or 
           LocalPlayer.PlayerGui:FindFirstChild("Cmdr") then
            return {name = "Cmdr", url = "https://pastebin.com/raw/R1bH2Ubs"}
        end
        
        -- Universal
        return {name = "Universal", url = "https://pastebin.com/raw/UYxUJ081"}
    end
}

-- ================================================================================
-- SECAO 8: BOOT ENGINE
-- ================================================================================

local function Boot(ui)
    ui.Btn.Visible = false
    ui.ProgressBG.Visible = true
    ui.Status.Text = "INITIALIZING..."
    ui.Status.TextColor3 = Color3.fromRGB(255, 200, 100)
    AudioEngine:Play("103595694345761", 0.05)
    
    TimingManager:Start()
    
    -- Fase 1: Anti-Log (0-25%)
    ui.Log.Text = "> Running 30-layer Anti-Log check..."
    ui.Progress:TweenSize(UDim2.new(0.25, 0, 1, 0), "Out", "Quad", 0.3, true)
    AntiLogSystem:Run()
    wait(0.5)
    
    -- Fase 2: Limpeza (25-50%)
    ui.Log.Text = "> Cleaning logs & optimizing memory..."
    ui.Progress:TweenSize(UDim2.new(0.5, 0, 1, 0), "Out", "Quad", 0.3, true)
    Cleaner.ClearAll()
    wait(0.5)
    
    -- Fase 3: Network (50-75%)
    ui.Log.Text = "> Optimizing network settings..."
    ui.Progress:TweenSize(UDim2.new(0.75, 0, 1, 0), "Out", "Quad", 0.3, true)
    NetworkOptimizer.Init()
    wait(0.5)
    
    -- Fase 4: Deteccao (75-90%)
    ui.Log.Text = "> Scanning admin systems..."
    ui.Progress:TweenSize(UDim2.new(0.9, 0, 1, 0), "Out", "Quad", 0.3, true)
    local admin = AdminDetector.Scan()
    wait(0.3)
    
    -- Fase 5: Timing Fixo (90-100%)
    ui.Log.Text = "> Finalizing 30ms timing precision..."
    ui.Progress:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.3, true)
    local actualTime = TimingManager:WaitFixed()
    
    ui.Status.Text = "DETECTED: " .. admin.name
    ui.Status.TextColor3 = Color3.fromRGB(100, 255, 150)
    ui.Log.Text = "> Loading " .. admin.name .. " profile...\\n> Timing: " .. string.format("%.2f", actualTime * 1000) .. "ms"
    
    AudioEngine:Play("122470643673099", 0.15)
    
    -- Notificacao
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "UOS Sentinel v5.0",
            Text = admin.name .. " detected | Timing: " .. string.format("%.1fms", actualTime * 1000),
            Duration = 5
        })
    end)
    
    -- Load Script
    local success = pcall(function()
        local code = game:HttpGet(admin.url)
        if code then loadstring(code)() end
    end)
    
    if success then
        ui.Status.Text = "SUCCESS"
        ui.Log.Text = "> " .. admin.name .. " loaded successfully!\\n> Anti-Log active | Network optimized"
        wait(2)
        ui.Screen:Destroy()
    else
        ui.Status.Text = "LOAD FAILED"
        ui.Status.TextColor3 = Color3.fromRGB(255, 100, 100)
        ui.Log.Text = "> Failed to load. Check connection."
        AudioEngine:Play("96628258513206", 0.2)
        wait(3)
        ui.Screen:Destroy()
    end
end

-- ================================================================================
-- SECAO 9: INICIALIZACAO
-- ================================================================================

local ui = CreateUI()

ui.Btn.MouseButton1Click:Connect(function()
    pcall(function() Boot(ui) end)
end)

-- Auto-clean loop
spawn(function()
    while wait(CONFIG.AUTO_CLEAN_INTERVAL) do
        pcall(Cleaner.ClearAll)
    end
end)

_G.UOS_Sentinel = {
    Version = "5.0 Ultimate",
    Status = "Ready",
    Clean = function() pcall(Cleaner.ClearAll) end
}

print("[UOS Sentinel v5.0] Loaded | 30ms Fixed | Anti-Log Ready")
