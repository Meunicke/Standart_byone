-- ═══════════════════════════════════════════════════════════════
-- aquilesgamef1 Hub v2.0 - Brookhaven Edition ULTRA
-- Powered by Redz Hub UI Library
-- Atualizado: 2026 | Com as melhores funções do Brookhaven
-- ═══════════════════════════════════════════════════════════════

local RedzLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzHUB/main/Source"))()

local Window = RedzLib:MakeWindow({
    Name = "aquilesgamef1 Hub | Brookhaven ULTRA",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "aquilesgamef1_Config",
    IntroText = "aquilesgamef1 Hub",
    IntroIcon = "rbxassetid://7733964640"
})

-- ═════════════════════ SERVIÇOS ═════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

-- ═════════════════════ VARIÁVEIS GLOBAIS ═════════════════════
local ESPEnabled = false
local ESPBoxes = {}
local ESPLabels = {}
local ESPTracers = {}
local SpeedEnabled = false
local SpeedValue = 50
local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local GodModeEnabled = false
local AutoFarmEnabled = false
local FullBrightEnabled = false
local NoFogEnabled = false
local AntiAFKEnabled = false
local WalkOnWaterEnabled = false
local RainbowHouseEnabled = false
local RainbowHairEnabled = false
local RainbowSkinEnabled = false
local SetCarSpeedEnabled = false
local CarSpeedValue = 100
local UnlockGamepassEnabled = false
local AutoCollectEnabled = false
local TrollGUIEnabled = false
local AvatarCloneEnabled = false
local AutoRobEnabled = false
local InvisibleEnabled = false
local FlingEnabled = false
local AutoGiveMoneyEnabled = false
local AutoGiveCarEnabled = false
local ESPShowName = true
local ESPShowDistance = true
local ESPShowHealth = true
local ESPShowBox = true
local ESPShowTracer = false
local ESPTeamCheck = false
local FreeCamEnabled = false
local FreeCam = nil
local FreeCamCF = nil
local AimbotEnabled = false
local AimbotFOV = 100
local AimbotSmoothness = 0.5
local AimbotTargetPart = "Head"
local AimbotTeamCheck = true

-- Variáveis de controle
local AutoFarmConnection = nil
local RainbowConnection = nil
local TrollConnections = {}
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local OriginalGravity = Workspace.Gravity

-- ═════════════════════ FUNÇÕES UTILITÁRIAS ═════════════════════

local function Notify(title, text, duration)
    RedzLib:MakeNotification({
        Name = title,
        Content = text,
        Image = "rbxassetid://4483345998",
        Time = duration or 3
    })
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:WaitForChild("Humanoid")
end

local function GetHRP()
    local char = GetCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

local function TweenTo(pos, speed)
    local hrp = GetHRP()
    local distance = (hrp.Position - pos).Magnitude
    local tweenInfo = TweenInfo.new(distance / (speed or 200), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

local function GetClosestPlayer(maxDistance)
    local closest = nil
    local minDist = maxDistance or math.huge
    local myHRP = GetHRP()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if AimbotTeamCheck and player.Team == LocalPlayer.Team then continue end
            local dist = (myHRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = player
            end
        end
    end
    return closest
end

-- ═════════════════════ ESP SYSTEM ULTRA ═════════════════════

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function SetupCharacter(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        
        -- Box ESP
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1.5
        box.Color = Color3.fromRGB(255, 0, 0)
        box.Filled = false
        box.Transparency = 1
        
        -- Name ESP
        local label = Drawing.new("Text")
        label.Visible = false
        label.Size = 14
        label.Color = Color3.fromRGB(255, 255, 255)
        label.Outline = true
        label.Center = true
        
        -- Health ESP
        local healthLabel = Drawing.new("Text")
        healthLabel.Visible = false
        healthLabel.Size = 12
        healthLabel.Color = Color3.fromRGB(0, 255, 0)
        healthLabel.Outline = true
        healthLabel.Center = true
        
        -- Tracer ESP
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1
        tracer.Color = Color3.fromRGB(255, 255, 255)
        tracer.Transparency = 1
        
        ESPBoxes[player] = box
        ESPLabels[player] = label
        ESPTracers[player] = tracer
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not ESPEnabled then
                box.Visible = false
                label.Visible = false
                healthLabel.Visible = false
                tracer.Visible = false
                return
            end
            
            local success, err = pcall(function()
                if not player.Character or not player.Character:FindFirstChild("Head") or not player.Character:FindFirstChild("HumanoidRootPart") then
                    box.Visible = false
                    label.Visible = false
                    healthLabel.Visible = false
                    tracer.Visible = false
                    return
                end
                
                if ESPTeamCheck and player.Team == LocalPlayer.Team then
                    box.Visible = false
                    label.Visible = false
                    healthLabel.Visible = false
                    tracer.Visible = false
                    return
                end
                
                local headPos = player.Character.Head.Position
                local hrpPos = player.Character.HumanoidRootPart.Position
                local humanoid = player.Character:FindFirstChild("Humanoid")
                
                local headScreen, headOnScreen = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 1.5, 0))
                local hrpScreen, hrpOnScreen = Camera:WorldToViewportPoint(hrpPos - Vector3.new(0, 2.5, 0))
                
                if headOnScreen and hrpOnScreen then
                    local height = math.abs(headScreen.Y - hrpScreen.Y)
                    local width = height * 0.6
                    
                    if ESPShowBox then
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(hrpScreen.X - width / 2, hrpScreen.Y - height)
                        box.Visible = true
                        
                        -- Cor baseada no time/equipe
                        if player.Team then
                            box.Color = player.TeamColor.Color
                        else
                            box.Color = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        box.Visible = false
                    end
                    
                    if ESPShowName then
                        local text = player.Name
                        if ESPShowDistance then
                            text = text .. " [" .. math.floor((GetHRP().Position - hrpPos).Magnitude) .. "m]"
                        end
                        label.Position = Vector2.new(headScreen.X, headScreen.Y - 20)
                        label.Text = text
                        label.Visible = true
                    else
                        label.Visible = false
                    end
                    
                    if ESPShowHealth and humanoid then
                        healthLabel.Position = Vector2.new(hrpScreen.X, hrpScreen.Y + 5)
                        healthLabel.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        healthLabel.Visible = true
                    else
                        healthLabel.Visible = false
                    end
                    
                    if ESPShowTracer then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(hrpScreen.X, hrpScreen.Y)
                        tracer.Visible = true
                        if player.Team then
                            tracer.Color = player.TeamColor.Color
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    box.Visible = false
                    label.Visible = false
                    healthLabel.Visible = false
                    tracer.Visible = false
                end
            end)
            
            if not success then
                box.Visible = false
                label.Visible = false
                healthLabel.Visible = false
                tracer.Visible = false
            end
        end)
        
        player.CharacterRemoving:Connect(function()
            box.Visible = false
            label.Visible = false
            healthLabel.Visible = false
            tracer.Visible = false
            if connection then connection:Disconnect() end
        end)
    end
    
    if player.Character then
        SetupCharacter(player.Character)
    end
    
    player.CharacterAdded:Connect(SetupCharacter)
end

local function ClearESP()
    for player, box in pairs(ESPBoxes) do
        box:Remove()
        ESPBoxes[player] = nil
    end
    for player, label in pairs(ESPLabels) do
        label:Remove()
        ESPLabels[player] = nil
    end
    for player, tracer in pairs(ESPTracers) do
        tracer:Remove()
        ESPTracers[player] = nil
    end
end

-- Inicializar ESP
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
    if ESPLabels[player] then
        ESPLabels[player]:Remove()
        ESPLabels[player] = nil
    end
    if ESPTracers[player] then
        ESPTracers[player]:Remove()
        ESPTracers[player] = nil
    end
end)

-- ═════════════════════ AIMBOT SYSTEM ═════════════════════

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestPlayer(AimbotFOV * 2)
        if target and target.Character and target.Character:FindFirstChild(AimbotTargetPart) then
            local targetPart = target.Character[AimbotTargetPart]
            local targetPos = targetPart.Position
            local cameraCF = Camera.CFrame
            local newCF = CFrame.new(cameraCF.Position, targetPos)
            Camera.CFrame = cameraCF:Lerp(newCF, AimbotSmoothness)
        end
    end
end)

-- ═════════════════════ FLY SYSTEM ═════════════════════

local function ToggleFly(enable)
    FlyEnabled = enable
    local char = GetCharacter()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    if enable then
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        FlyBodyVelocity.Parent = hrp
        
        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.P = 9e4
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp
        
        Notify("Fly", "Voo ativado! Use WASD + Espaço/Q", 3)
    else
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        FlyBodyVelocity = nil
        FlyBodyGyro = nil
        Notify("Fly", "Voo desativado!", 3)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not FlyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        FlyBodyVelocity.Velocity = Vector3.new(0, FlySpeed, 0)
    elseif input.KeyCode == Enum.KeyCode.Q then
        FlyBodyVelocity.Velocity = Vector3.new(0, -FlySpeed, 0)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not FlyEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Q then
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if FlyEnabled and FlyBodyGyro then
        FlyBodyGyro.CFrame = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            FlyBodyVelocity.Velocity = Camera.CFrame.LookVector * FlySpeed
        elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
            FlyBodyVelocity.Velocity = -Camera.CFrame.LookVector * FlySpeed
        elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
            FlyBodyVelocity.Velocity = -Camera.CFrame.RightVector * FlySpeed
        elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
            FlyBodyVelocity.Velocity = Camera.CFrame.RightVector * FlySpeed
        else
            FlyBodyVelocity.Velocity = Vector3.new(0, FlyBodyVelocity.Velocity.Y, 0)
        end
    end
end)

-- ═════════════════════ NOCLIP SYSTEM ═════════════════════

RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local char = GetCharacter()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ═════════════════════ INFINITE JUMP ═════════════════════

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local hum = GetHumanoid()
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ═════════════════════ ANTI-AFK ═════════════════════

local AntiAFKConnection
local function ToggleAntiAFK(enable)
    AntiAFKEnabled = enable
    if enable then
        AntiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Notify("Anti-AFK", "Anti-AFK ativado!", 3)
    else
        if AntiAFKConnection then AntiAFKConnection:Disconnect() end
        Notify("Anti-AFK", "Anti-AFK desativado!", 3)
    end
end

-- ═════════════════════ FULL BRIGHT / NO FOG ═════════════════════

local originalBrightness = Lighting.Brightness
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalGlobalShadows = Lighting.GlobalShadows
local originalAmbient = Lighting.Ambient

local function ToggleFullBright(enable)
    FullBrightEnabled = enable
    if enable then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Notify("Full Bright", "Claridade máxima ativada!", 3)
    else
        Lighting.Brightness = originalBrightness
        Lighting.GlobalShadows = originalGlobalShadows
        Lighting.Ambient = originalAmbient
        Notify("Full Bright", "Claridade restaurada!", 3)
    end
end

local function ToggleNoFog(enable)
    NoFogEnabled = enable
    if enable then
        Lighting.FogStart = 0
        Lighting.FogEnd = 999999
        Notify("No Fog", "Nevoeiro removido!", 3)
    else
        Lighting.FogStart = originalFogStart
        Lighting.FogEnd = originalFogEnd
        Notify("No Fog", "Nevoeiro restaurado!", 3)
    end
end

-- ═════════════════════ WALK ON WATER ═════════════════════

local WaterParts = {}
local function ToggleWalkOnWater(enable)
    WalkOnWaterEnabled = enable
    if enable then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("water") or obj.Material == Enum.Material.Water) then
                local platform = Instance.new("Part")
                platform.Size = Vector3.new(obj.Size.X, 1, obj.Size.Z)
                platform.Position = obj.Position + Vector3.new(0, obj.Size.Y/2, 0)
                platform.Anchored = true
                platform.Transparency = 1
                platform.CanCollide = true
                platform.Parent = Workspace
                table.insert(WaterParts, platform)
            end
        end
        Notify("Walk on Water", "Andar na água ativado!", 3)
    else
        for _, part in pairs(WaterParts) do
            if part then part:Destroy() end
        end
        WaterParts = {}
        Notify("Walk on Water", "Andar na água desativado!", 3)
    end
end

-- ═════════════════════ AUTO FARM BROOKHAVEN ═════════════════════

local function FindMoneySpots()
    local spots = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("money") or name:find("cash") or name:find("coin") or 
               name:find("atm") or name:find("register") or name:find("vault") or
               name:find("bank") or name:find("safe") then
                table.insert(spots, obj)
            end
        end
    end
    return spots
end

local function ToggleAutoFarm(enable)
    AutoFarmEnabled = enable
    if enable then
        Notify("Auto Farm", "Procurando dinheiro no mapa...", 3)
        task.spawn(function()
            while AutoFarmEnabled do
                task.wait(0.5)
                pcall(function()
                    local spots = FindMoneySpots()
                    for _, spot in pairs(spots) do
                        if not AutoFarmEnabled then break end
                        local hrp = GetHRP()
                        if spot and spot.Parent then
                            -- Tenta touch interest
                            if spot:FindFirstChild("TouchInterest") then
                                firetouchinterest(hrp, spot, 0)
                                task.wait(0.1)
                                firetouchinterest(hrp, spot, 1)
                            end
                            
                            -- Tenta proximidade
                            if (hrp.Position - spot.Position).Magnitude > 10 then
                                TweenTo(spot.Position + Vector3.new(0, 3, 0), 100)
                                task.wait(0.3)
                            end
                        end
                    end
                    
                    -- Procura por prompts de proximidade (ProximityPrompt)
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Parent and prompt.Parent:IsA("BasePart") then
                            if prompt.ActionText:lower():find("money") or 
                               prompt.ActionText:lower():find("cash") or
                               prompt.ActionText:lower():find("collect") then
                                local hrp = GetHRP()
                                if (hrp.Position - prompt.Parent.Position).Magnitude < prompt.MaxActivationDistance + 5 then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        Notify("Auto Farm", "Auto Farm desativado!", 3)
    end
end

-- ═════════════════════ AUTO COLLECT ITENS ═════════════════════

local function ToggleAutoCollect(enable)
    AutoCollectEnabled = enable
    if enable then
        Notify("Auto Collect", "Coletando itens automaticamente...", 3)
        task.spawn(function()
            while AutoCollectEnabled do
                task.wait(0.3)
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") then
                            local hrp = GetHRP()
                            if (hrp.Position - obj.Parent.Position).Magnitude < obj.MaxActivationDistance + 5 then
                                fireproximityprompt(obj)
                            end
                        end
                    end
                    
                    -- Coleta itens flutuantes
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:lower():find("candy") or 
                           obj.Name:lower():find("collect") or obj.Name:lower():find("item") then
                            if obj:FindFirstChild("TouchInterest") then
                                firetouchinterest(GetHRP(), obj, 0)
                                task.wait(0.05)
                                firetouchinterest(GetHRP(), obj, 1)
                            end
                        end
                    end
                end)
            end
        end)
    else
        Notify("Auto Collect", "Auto Collect desativado!", 3)
    end
end

-- ═════════════════════ RAINBOW HOUSE ═════════════════════

local function ToggleRainbowHouse(enable)
    RainbowHouseEnabled = enable
    if enable then
        Notify("Rainbow House", "Casa arco-íris ativada!", 3)
        task.spawn(function()
            local hue = 0
            while RainbowHouseEnabled do
                task.wait(0.1)
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name:lower():find("house") or 
                           obj.Name:lower():find("home") or obj.Name:lower():find("wall") or
                           obj.Name:lower():find("floor") or obj.Name:lower():find("roof")) then
                            if obj.Parent and (obj.Parent.Name:lower():find("house") or 
                               obj.Parent.Name:lower():find(LocalPlayer.Name:lower())) then
                                obj.Color = Color3.fromHSV(hue, 1, 1)
                                if obj:FindFirstChild("Material") then
                                    obj.Material = Enum.Material.Neon
                                end
                            end
                        end
                    end
                    hue = hue + 0.02
                    if hue > 1 then hue = 0 end
                end)
            end
        end)
    else
        Notify("Rainbow House", "Casa arco-íris desativada!", 3)
    end
end

-- ═════════════════════ RAINBOW HAIR / SKIN ═════════════════════

local function ToggleRainbowHair(enable)
    RainbowHairEnabled = enable
    if enable then
        Notify("Rainbow Hair", "Cabelo arco-íris ativado!", 3)
        task.spawn(function()
            local hue = 0
            while RainbowHairEnabled do
                task.wait(0.1)
                pcall(function()
                    local char = GetCharacter()
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("MeshPart") and (part.Name:lower():find("hair") or 
                           part.Name:lower():find("head")) then
                            part.Color = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                    hue = hue + 0.02
                    if hue > 1 then hue = 0 end
                end)
            end
        end)
    else
        Notify("Rainbow Hair", "Cabelo arco-íris desativado!", 3)
    end
end

local function ToggleRainbowSkin(enable)
    RainbowSkinEnabled = enable
    if enable then
        Notify("Rainbow Skin", "Pele arco-íris ativada!", 3)
        task.spawn(function()
            local hue = 0
            while RainbowSkinEnabled do
                task.wait(0.1)
                pcall(function()
                    local char = GetCharacter()
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Color = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                    hue = hue + 0.02
                    if hue > 1 then hue = 0 end
                end)
            end
        end)
    else
        -- Restaurar cor original
        pcall(function()
            local char = GetCharacter()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Color = Color3.fromRGB(255, 255, 255)
                end
            end
        end)
        Notify("Rainbow Skin", "Pele arco-íris desativada!", 3)
    end
end

-- ═════════════════════ SET CAR SPEED ═════════════════════

local function ToggleSetCarSpeed(enable)
    SetCarSpeedEnabled = enable
    if enable then
        Notify("Car Speed", "Velocidade do carro: " .. CarSpeedValue, 3)
        task.spawn(function()
            while SetCarSpeedEnabled do
                task.wait(0.1)
                pcall(function()
                    local char = GetCharacter()
                    local hum = char:FindFirstChild("Humanoid")
                    if hum and hum.SeatPart then
                        local seat = hum.SeatPart
                        local vehicle = seat.Parent
                        if vehicle then
                            for _, part in pairs(vehicle:GetDescendants()) do
                                if part:IsA("VehicleSeat") or part:IsA("Seat") then
                                    -- Modifica velocidade do veículo
                                    local bodyVelocity = part:FindFirstChildOfClass("BodyVelocity")
                                    if not bodyVelocity then
                                        bodyVelocity = Instance.new("BodyVelocity")
                                        bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
                                        bodyVelocity.Parent = part
                                    end
                                end
                                if part:IsA("BasePart") and part.Name:lower():find("wheel") then
                                    -- Aumenta rotação das rodas
                                    local angularVelocity = part:FindFirstChildOfClass("BodyAngularVelocity")
                                    if not angularVelocity then
                                        angularVelocity = Instance.new("BodyAngularVelocity")
                                        angularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                                        angularVelocity.Parent = part
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        Notify("Car Speed", "Velocidade do carro restaurada!", 3)
    end
end

-- ═════════════════════ UNLOCK GAMEPASS ═════════════════════

local function ToggleUnlockGamepass(enable)
    UnlockGamepassEnabled = enable
    if enable then
        Notify("Unlock Gamepass", "Tentando desbloquear gamepasses...", 3)
        pcall(function()
            -- Tenta acessar funções premium
            local remotes = ReplicatedStorage:GetDescendants()
            for _, remote in pairs(remotes) do
                if remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if name:find("premium") or name:find("vip") or name:find("gamepass") or 
                       name:find("unlock") or name:find("house") then
                        remote:FireServer(true)
                    end
                elseif remote:IsA("RemoteFunction") then
                    local name = remote.Name:lower()
                    if name:find("premium") or name:find("vip") or name:find("gamepass") then
                        remote:InvokeServer(true)
                    end
                end
            end
            
            -- Tenta ativar gamepasses via MarketplaceService
            local MarketplaceService = game:GetService("MarketplaceService")
            -- Lista comum de gamepasses do Brookhaven
            local commonGamepasses = {96651, 96652, 96653, 96654, 96655, 96656}
            for _, id in pairs(commonGamepasses) do
                pcall(function()
                    MarketplaceService:SignalPromptGamePassPurchaseFinished(LocalPlayer, id, true)
                end)
            end
        end)
        Notify("Unlock Gamepass", "Gamepasses desbloqueados (tentativa)!", 3)
    end
end

-- ═════════════════════ AVATAR CLONER ═════════════════════

local function CloneAvatar(targetPlayer)
    pcall(function()
        if not targetPlayer or not targetPlayer.Character then return end
        
        local targetChar = targetPlayer.Character
        local myChar = GetCharacter()
        
        -- Copia roupas
        for _, item in pairs(targetChar:GetDescendants()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                local clone = item:Clone()
                clone.Parent = myChar
            end
            if item:IsA("Accessory") or item:IsA("Hat") then
                local clone = item:Clone()
                clone.Parent = myChar
            end
        end
        
        -- Copia cores
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        local myHumanoid = myChar:FindFirstChild("Humanoid")
        if targetHumanoid and myHumanoid then
            myHumanoid.BodyTypeScale = targetHumanoid.BodyTypeScale
            myHumanoid.BodyDepthScale = targetHumanoid.BodyDepthScale
            myHumanoid.BodyHeightScale = targetHumanoid.BodyHeightScale
            myHumanoid.BodyWidthScale = targetHumanoid.BodyWidthScale
            myHumanoid.HeadScale = targetHumanoid.HeadScale
        end
        
        Notify("Avatar Cloner", "Avatar clonado de " .. targetPlayer.Name, 3)
    end)
end

-- ═════════════════════ TROLL GUI SYSTEM ═════════════════════

local function ToggleTrollGUI(enable)
    TrollGUIEnabled = enable
    if enable then
        Notify("Troll GUI", "Sistema de troll ativado!", 3)
    else
        for _, conn in pairs(TrollConnections) do
            conn:Disconnect()
        end
        TrollConnections = {}
        Notify("Troll GUI", "Sistema de troll desativado!", 3)
    end
end

local function TrollKill(target)
    pcall(function()
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
            Notify("Troll", target.Name .. " foi morto!", 3)
        end
    end)
end

local function TrollBring(target)
    pcall(function()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.CFrame = GetHRP().CFrame + Vector3.new(0, 0, -5)
            Notify("Troll", target.Name .. " foi trazido!", 3)
        end
    end)
end

local function TrollGoto(target)
    pcall(function()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            GetHRP().CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5)
            Notify("Troll", "Teleportado para " .. target.Name, 3)
        end
    end)
end

local function TrollFling(target)
    pcall(function()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(math.random(-500, 500), 500, math.random(-500, 500))
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = target.Character.HumanoidRootPart
            game:GetService("Debris"):AddItem(bodyVelocity, 2)
            Notify("Troll", target.Name .. " foi arremessado!", 3)
        end
    end)
end

local function TrollFreeze(target)
    pcall(function()
        if target and target.Character then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end
            Notify("Troll", target.Name .. " foi congelado!", 3)
        end
    end)
end

local function TrollUnfreeze(target)
    pcall(function()
        if target and target.Character then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
            Notify("Troll", target.Name .. " foi descongelado!", 3)
        end
    end)
end

-- ═════════════════════ INVISIBLE ═════════════════════

local function ToggleInvisible(enable)
    InvisibleEnabled = enable
    pcall(function()
        local char = GetCharacter()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = enable and 1 or 0
                if part:FindFirstChild("face") then
                    part.face.Transparency = enable and 1 or 0
                end
            end
            if part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = enable and 1 or 0
            end
        end
        Notify("Invisible", enable and "Invisível!" or "Visível!", 3)
    end)
end

-- ═════════════════════ FLING ALL ═════════════════════

local function FlingAll()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(math.random(-1000, 1000), 1000, math.random(-1000, 1000))
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Parent = player.Character.HumanoidRootPart
                game:GetService("Debris"):AddItem(bodyVelocity, 3)
            end
        end
        Notify("Fling", "Todos foram arremessados!", 3)
    end)
end

-- ═════════════════════ TELEPORTES BROOKHAVEN ═════════════════════

local BrookhavenLocations = {
    ["Spawn"] = CFrame.new(0, 10, 0),
    ["Banco"] = CFrame.new(0, 10, 0),
    ["Delegacia"] = CFrame.new(0, 10, 0),
    ["Hospital"] = CFrame.new(0, 10, 0),
    ["Escola"] = CFrame.new(0, 10, 0),
    ["Supermercado"] = CFrame.new(0, 10, 0),
    ["Cinema"] = CFrame.new(0, 10, 0),
    ["Restaurante"] = CFrame.new(0, 10, 0),
    ["Clube"] = CFrame.new(0, 10, 0),
    ["Auto Shop"] = CFrame.new(0, 10, 0),
    ["Gas Station"] = CFrame.new(0, 10, 0),
    ["Casa 1"] = CFrame.new(0, 10, 0),
    ["Casa 2"] = CFrame.new(0, 10, 0),
    ["Casa 3"] = CFrame.new(0, 10, 0),
    ["Casa 4"] = CFrame.new(0, 10, 0),
    ["Casa 5"] = CFrame.new(0, 10, 0),
    ["Casa 6"] = CFrame.new(0, 10, 0),
    ["Casa 7"] = CFrame.new(0, 10, 0),
    ["Casa 8"] = CFrame.new(0, 10, 0),
    ["Casa 9"] = CFrame.new(0, 10, 0),
    ["Casa 10"] = CFrame.new(0, 10, 0),
    ["Casa 11"] = CFrame.new(0, 10, 0),
    ["Casa 12"] = CFrame.new(0, 10, 0),
    ["Casa 13"] = CFrame.new(0, 10, 0),
    ["Casa 14"] = CFrame.new(0, 10, 0),
    ["Casa 15"] = CFrame.new(0, 10, 0),
    ["Casa 16"] = CFrame.new(0, 10, 0),
    ["Casa 17"] = CFrame.new(0, 10, 0),
    ["Casa 18"] = CFrame.new(0, 10, 0),
    ["Casa 19"] = CFrame.new(0, 10, 0),
    ["Casa 20"] = CFrame.new(0, 10, 0),
    ["Casa 21"] = CFrame.new(0, 10, 0),
    ["Casa 22"] = CFrame.new(0, 10, 0),
    ["Casa 23"] = CFrame.new(0, 10, 0),
    ["Casa 24"] = CFrame.new(0, 10, 0),
    ["Casa 25"] = CFrame.new(0, 10, 0),
    ["Casa 26"] = CFrame.new(0, 10, 0),
    ["Casa 27"] = CFrame.new(0, 10, 0),
    ["Casa 28"] = CFrame.new(0, 10, 0),
    ["Casa 29"] = CFrame.new(0, 10, 0),
    ["Casa 30"] = CFrame.new(0, 10, 0),
    ["Aqua Park"] = CFrame.new(0, 10, 0),
    ["Drone Spawn"] = CFrame.new(0, 10, 0),
    ["Secret Base"] = CFrame.new(0, 10, 0),
    ["HeliPad"] = CFrame.new(0, 10, 0),
}

-- Atualizar coordenadas reais do Brookhaven
task.spawn(function()
    task.wait(3)
    pcall(function()
        -- Spawn
        local spawnLoc = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Lobby")
        if spawnLoc then
            BrookhavenLocations["Spawn"] = spawnLoc.CFrame + Vector3.new(0, 5, 0)
        end
        
        -- Procurar locais comuns no Brookhaven
        for _, obj in pairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find("bank") then BrookhavenLocations["Banco"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("police") or name:find("sheriff") then BrookhavenLocations["Delegacia"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("hospital") or name:find("medical") then BrookhavenLocations["Hospital"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("school") then BrookhavenLocations["Escola"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("grocery") or name:find("store") or name:find("shop") then BrookhavenLocations["Supermercado"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("cinema") or name:find("theater") or name:find("movie") then BrookhavenLocations["Cinema"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("restaurant") or name:find("diner") or name:find("food") then BrookhavenLocations["Restaurante"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("club") or name:find("dance") or name:find("party") then BrookhavenLocations["Clube"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("autoshop") or name:find("mechanic") or name:find("garage") then BrookhavenLocations["Auto Shop"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("gas") or name:find("fuel") then BrookhavenLocations["Gas Station"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("aqua") or name:find("water park") or name:find("pool") then BrookhavenLocations["Aqua Park"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("drone") or name:find("heli") or name:find("air") then BrookhavenLocations["Drone Spawn"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("secret") or name:find("bunker") or name:find("base") then BrookhavenLocations["Secret Base"] = obj.CFrame + Vector3.new(0, 5, 0) end
            if name:find("helipad") or name:find("helicopter") then BrookhavenLocations["HeliPad"] = obj.CFrame + Vector3.new(0, 5, 0) end
        end
        
        -- Procurar casas numeradas
        for i = 1, 30 do
            for _, obj in pairs(Workspace:GetDescendants()) do
                local objName = obj.Name:lower()
                if (objName:find("house") or objName:find("home") or objName:find("casa")) and 
                   (objName:find(tostring(i)) or objName:find("#" .. tostring(i))) then
                    BrookhavenLocations["Casa " .. i] = obj.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end)
end)

-- ═════════════════════ CAR SPAWNER / VEHICLE SYSTEM ═════════════════════

local function SpawnCar(carName)
    pcall(function()
        -- Método 1: RemoteEvents comuns
        local args = {
            [1] = "SpawnVehicle",
            [2] = carName or "Sedan"
        }
        
        local remotes = ReplicatedStorage:GetDescendants()
        for _, remote in pairs(remotes) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("vehicle") or name:find("car") or name:find("spawn") or 
                   name:find("transport") or name:find("drive") then
                    remote:FireServer(unpack(args))
                end
            end
        end
        
        -- Método 2: Tenta spawnar via Workspace
        local vehicleFolder = Workspace:FindFirstChild("Vehicles") or Workspace:FindFirstChild("Cars")
        if vehicleFolder then
            for _, vehicle in pairs(vehicleFolder:GetChildren()) do
                if vehicle:IsA("Model") and (carName == nil or vehicle.Name:lower():find(carName:lower())) then
                    local clone = vehicle:Clone()
                    clone:SetPrimaryPartCFrame(GetHRP().CFrame + Vector3.new(0, 5, -10))
                    clone.Parent = Workspace
                    break
                end
            end
        end
        
        Notify("Car Spawner", "Tentando spawnar: " .. (carName or "Sedan"), 3)
    end)
end

local function TeleportToCar()
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") or (obj:IsA("Seat") and obj.Parent and obj.Parent:IsA("Model")) then
                local vehicle = obj.Parent
                if vehicle:FindFirstChild("DriveSeat") or vehicle:FindFirstChild("VehicleSeat") then
                    GetHRP().CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                    Notify("Teleport", "Teleportado para o veículo!", 3)
                    return
                end
            end
        end
    end)
end

-- ═════════════════════ ADMIN COMMANDS SIMULATOR ═════════════════════

local function AdminCommand(command)
    pcall(function()
        local args = string.split(command, " ")
        local cmd = args[1]:lower()
        
        if cmd == ":kill" or cmd == ":k" then
            local target = args[2]
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #target) == target:lower() then
                    TrollKill(plr)
                end
            end
            
        elseif cmd == ":bring" or cmd == ":b" then
            local target = args[2]
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #target) == target:lower() then
                    TrollBring(plr)
                end
            end
            
        elseif cmd == ":goto" or cmd == ":tp" then
            local target = args[2]
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #target) == target:lower() then
                    TrollGoto(plr)
                end
            end
            
        elseif cmd == ":speed" or cmd == ":ws" then
            local speed = tonumber(args[2]) or 50
            GetHumanoid().WalkSpeed = speed
            
        elseif cmd == ":jump" or cmd == ":jp" then
            local power = tonumber(args[2]) or 50
            GetHumanoid().JumpPower = power
            
        elseif cmd == ":heal" or cmd == ":h" then
            GetHumanoid().Health = GetHumanoid().MaxHealth
            
        elseif cmd == ":god" then
            GodModeEnabled = not GodModeEnabled
            if GodModeEnabled then
                GetHumanoid().MaxHealth = math.huge
                GetHumanoid().Health = math.huge
                Notify("God Mode", "God Mode ativado!", 3)
            else
                GetHumanoid().MaxHealth = 100
                GetHumanoid().Health = 100
                Notify("God Mode", "God Mode desativado!", 3)
            end
            
        elseif cmd == ":noclip" then
            NoclipEnabled = not NoclipEnabled
            Notify("Noclip", NoclipEnabled and "Noclip ativado!" or "Noclip desativado!", 3)
            
        elseif cmd == ":fly" then
            ToggleFly(not FlyEnabled)
            
        elseif cmd == ":invis" or cmd == ":invisible" then
            ToggleInvisible(not InvisibleEnabled)
            
        elseif cmd == ":tools" or cmd == ":t" then
            for _, tool in pairs(ReplicatedStorage:GetDescendants()) do
                if tool:IsA("Tool") then
                    local clone = tool:Clone()
                    clone.Parent = LocalPlayer.Backpack
                end
            end
            Notify("Tools", "Todas as ferramentas adicionadas!", 3)
            
        elseif cmd == ":reset" or cmd == ":re" then
            GetHumanoid().Health = 0
            
        elseif cmd == ":time" then
            local timeVal = tonumber(args[2]) or 12
            Lighting.ClockTime = timeVal
            
        elseif cmd == ":weather" then
            local weather = args[2] or "Clear"
            if weather:lower() == "rain" then
                local rain = Instance.new("ParticleEmitter")
                rain.Texture = "rbxassetid://241837017"
                rain.Rate = 100
                rain.Lifetime = NumberRange.new(2, 3)
                rain.Speed = NumberRange.new(20, 30)
                rain.Parent = Workspace.Terrain
            else
                for _, emitter in pairs(Workspace.Terrain:GetChildren()) do
                    if emitter:IsA("ParticleEmitter") then
                        emitter:Destroy()
                    end
                end
            end
            
        elseif cmd == ":fling" then
            local target = args[2]
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #target) == target:lower() then
                    TrollFling(plr)
                end
            end
            
        elseif cmd == ":freeze" then
            local target = args[2]
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #target) == target:lower() then
                    TrollFreeze(plr)
                end
            end
            
        elseif cmd == ":unfreeze" then
            local target = args[2]
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #target) == target:lower() then
                    TrollUnfreeze(plr)
                end
            end
            
        elseif cmd == ":clone" then
            local target = args[2]
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #target) == target:lower() then
                    CloneAvatar(plr)
                end
            end
            
        elseif cmd == ":car" then
            local carName = args[2] or "Sedan"
            SpawnCar(carName)
            
        elseif cmd == ":rainbow" then
            ToggleRainbowHouse(not RainbowHouseEnabled)
            
        elseif cmd == ":unlock" then
            ToggleUnlockGamepass(true)
        end
    end)
end

-- ═════════════════════ PLAYER LIST ═════════════════════

local function GetPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- ═════════════════════ FREE CAM ═════════════════════

local function ToggleFreeCam(enable)
    FreeCamEnabled = enable
    if enable then
        local camera = Workspace.CurrentCamera
        FreeCamCF = camera.CFrame
        FreeCam = camera
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
        
        Notify("Free Cam", "Free Cam ativado! Use WASD + Mouse", 3)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        FreeCam = nil
        Notify("Free Cam", "Free Cam desativado!", 3)
    end
end

RunService.RenderStepped:Connect(function()
    if FreeCamEnabled and FreeCam then
        local speed = 2
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            FreeCamCF = FreeCamCF * CFrame.new(0, 0, -speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            FreeCamCF = FreeCamCF * CFrame.new(0, 0, speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            FreeCamCF = FreeCamCF * CFrame.new(-speed, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            FreeCamCF = FreeCamCF * CFrame.new(speed, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            FreeCamCF = FreeCamCF * CFrame.new(0, speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            FreeCamCF = FreeCamCF * CFrame.new(0, -speed, 0)
        end
        
        FreeCam.CFrame = FreeCamCF
    end
end)

-- ═════════════════════ AUTO GIVE SYSTEMS ═════════════════════

local function AutoGiveMoney(targetName, amount)
    pcall(function()
        -- Tenta encontrar o jogador
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name:lower():find(targetName:lower()) then
                -- Tenta enviar dinheiro via RemoteEvents
                local remotes = ReplicatedStorage:GetDescendants()
                for _, remote in pairs(remotes) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:find("money") or name:find("cash") or name:find("give") or name:find("transfer") then
                            remote:FireServer(plr, amount or 1000)
                        end
                    end
                end
                Notify("Auto Give", "Tentando dar $" .. (amount or 1000) .. " para " .. plr.Name, 3)
            end
        end
    end)
end

local function AutoGiveCar(targetName, carName)
    pcall(function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name:lower():find(targetName:lower()) then
                -- Tenta spawnar carro para o jogador
                local remotes = ReplicatedStorage:GetDescendants()
                for _, remote in pairs(remotes) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:find("vehicle") or name:find("car") or name:find("spawn") then
                            remote:FireServer(plr, carName or "Sedan")
                        end
                    end
                end
                Notify("Auto Give", "Tentando dar carro para " .. plr.Name, 3)
            end
        end
    end)
end

-- ═════════════════════ AUTO ROB ═════════════════════

local function ToggleAutoRob(enable)
    AutoRobEnabled = enable
    if enable then
        Notify("Auto Rob", "Auto Rob ativado!", 3)
        task.spawn(function()
            while AutoRobEnabled do
                task.wait(1)
                pcall(function()
                    -- Procura por cofres, caixas registradoras, etc.
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local name = obj.Name:lower()
                            if name:find("vault") or name:find("safe") or name:find("register") or 
                               name:find("cashier") or name:find("atm") then
                                if obj:FindFirstChild("ProximityPrompt") then
                                    local hrp = GetHRP()
                                    if (hrp.Position - obj.Position).Magnitude < 20 then
                                        TweenTo(obj.Position + Vector3.new(0, 3, 0), 80)
                                        task.wait(0.5)
                                        fireproximityprompt(obj.ProximityPrompt)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        Notify("Auto Rob", "Auto Rob desativado!", 3)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: PRINCIPAL ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local MainTab = Window:MakeTab({
    Name = "Principal",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddSection({Name = "Informações"})

MainTab:AddLabel("Bem-vindo ao aquilesgamef1 Hub!")
MainTab:AddLabel("Jogo: Brookhaven 🏠")
MainTab:AddLabel("Versão: 2.0 ULTRA")

MainTab:AddSection({Name = "Status do Jogador"})

local WalkSpeedLabel = MainTab:AddLabel("WalkSpeed: " .. tostring(Humanoid.WalkSpeed))
local JumpPowerLabel = MainTab:AddLabel("JumpPower: " .. tostring(Humanoid.JumpPower))
local HealthLabel = MainTab:AddLabel("Health: " .. tostring(Humanoid.Health))
local PositionLabel = MainTab:AddLabel("Posição: Carregando...")

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local hum = GetHumanoid()
            local hrp = GetHRP()
            WalkSpeedLabel:Set("WalkSpeed: " .. tostring(hum.WalkSpeed))
            JumpPowerLabel:Set("JumpPower: " .. tostring(hum.JumpPower))
            HealthLabel:Set("Health: " .. tostring(math.floor(hum.Health)) .. "/" .. tostring(hum.MaxHealth))
            PositionLabel:Set("Posição: " .. math.floor(hrp.Position.X) .. ", " .. math.floor(hrp.Position.Y) .. ", " .. math.floor(hrp.Position.Z))
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: MOVIMENTO ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local MovementTab = Window:MakeTab({
    Name = "Movimento",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MovementTab:AddSection({Name = "Velocidade"})

MovementTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(Value)
        SpeedEnabled = Value
        if Value then
            GetHumanoid().WalkSpeed = SpeedValue
            Notify("Speed", "Speed Hack ativado: " .. SpeedValue, 3)
        else
            GetHumanoid().WalkSpeed = 16
            Notify("Speed", "Speed Hack desativado!", 3)
        end
    end
})

MovementTab:AddSlider({
    Name = "Velocidade",
    Min = 16,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "WS",
    Callback = function(Value)
        SpeedValue = Value
        if SpeedEnabled then
            GetHumanoid().WalkSpeed = Value
        end
    end
})

MovementTab:AddSection({Name = "Pulo"})

MovementTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "JP",
    Callback = function(Value)
        GetHumanoid().JumpPower = Value
    end
})

MovementTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
        Notify("Infinite Jump", Value and "Ativado!" or "Desativado!", 3)
    end
})

MovementTab:AddSection({Name = "Voo"})

MovementTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(Value)
        ToggleFly(Value)
    end
})

MovementTab:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 150, 255),
    Increment = 1,
    ValueName = "FS",
    Callback = function(Value)
        FlySpeed = Value
    end
})

MovementTab:AddSection({Name = "Outros"})

MovementTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
        Notify("Noclip", Value and "Noclip ativado!" or "Noclip desativado!", 3)
    end
})

MovementTab:AddToggle({
    Name = "Walk on Water",
    Default = false,
    Callback = function(Value)
        ToggleWalkOnWater(Value)
    end
})

MovementTab:AddToggle({
    Name = "Free Cam",
    Default = false,
    Callback = function(Value)
        ToggleFreeCam(Value)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: VISUAL ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VisualTab:AddSection({Name = "ESP"})

VisualTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            for _, box in pairs(ESPBoxes) do box.Visible = false end
            for _, label in pairs(ESPLabels) do label.Visible = false end
            for _, tracer in pairs(ESPTracers) do tracer.Visible = false end
        end
        Notify("ESP", Value and "ESP ativado!" or "ESP desativado!", 3)
    end
})

VisualTab:AddToggle({
    Name = "ESP - Mostrar Nome",
    Default = true,
    Callback = function(Value)
        ESPShowName = Value
    end
})

VisualTab:AddToggle({
    Name = "ESP - Mostrar Distância",
    Default = true,
    Callback = function(Value)
        ESPShowDistance = Value
    end
})

VisualTab:AddToggle({
    Name = "ESP - Mostrar Vida",
    Default = true,
    Callback = function(Value)
        ESPShowHealth = Value
    end
})

VisualTab:AddToggle({
    Name = "ESP - Mostrar Box",
    Default = true,
    Callback = function(Value)
        ESPShowBox = Value
    end
})

VisualTab:AddToggle({
    Name = "ESP - Tracer",
    Default = false,
    Callback = function(Value)
        ESPShowTracer = Value
    end
})

VisualTab:AddToggle({
    Name = "ESP - Team Check",
    Default = false,
    Callback = function(Value)
        ESPTeamCheck = Value
    end
})

VisualTab:AddSection({Name = "Aimbot"})

VisualTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
        Notify("Aimbot", Value and "Aimbot ativado!" or "Aimbot desativado!", 3)
    end
})

VisualTab:AddSlider({
    Name = "Aimbot FOV",
    Min = 50,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 10,
    ValueName = "px",
    Callback = function(Value)
        AimbotFOV = Value
    end
})

VisualTab:AddSlider({
    Name = "Aimbot Suavização",
    Min = 0.1,
    Max = 1,
    Default = 0.5,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 0.1,
    ValueName = "",
    Callback = function(Value)
        AimbotSmoothness = Value
    end
})

VisualTab:AddToggle({
    Name = "Aimbot - Team Check",
    Default = true,
    Callback = function(Value)
        AimbotTeamCheck = Value
    end
})

VisualTab:AddSection({Name = "Ambiente"})

VisualTab:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(Value)
        ToggleFullBright(Value)
    end
})

VisualTab:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(Value)
        ToggleNoFog(Value)
    end
})

VisualTab:AddSlider({
    Name = "Field of View",
    Min = 30,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(Value)
        Camera.FieldOfView = Value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: AUTO FARM ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FarmTab:AddSection({Name = "Farm de Dinheiro"})

FarmTab:AddToggle({
    Name = "Auto Farm Money",
    Default = false,
    Callback = function(Value)
        ToggleAutoFarm(Value)
    end
})

FarmTab:AddSection({Name = "Coleta Automática"})

FarmTab:AddToggle({
    Name = "Auto Collect Items",
    Default = false,
    Callback = function(Value)
        ToggleAutoCollect(Value)
    end
})

FarmTab:AddSection({Name = "Auto Rob"})

FarmTab:AddToggle({
    Name = "Auto Rob (Bancos/Cofres)",
    Default = false,
    Callback = function(Value)
        ToggleAutoRob(Value)
    end
})

FarmTab:AddSection({Name = "Anti-AFK"})

FarmTab:AddToggle({
    Name = "Anti-AFK",
    Default = false,
    Callback = function(Value)
        ToggleAntiAFK(Value)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: TELEPORTES ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local TeleportTab = Window:MakeTab({
    Name = "Teleportes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddSection({Name = "Locais do Brookhaven"})

for locationName, _ in pairs(BrookhavenLocations) do
    TeleportTab:AddButton({
        Name = "TP: " .. locationName,
        Callback = function()
            local cf = BrookhavenLocations[locationName]
            if cf then
                GetHRP().CFrame = cf
                Notify("Teleport", "Teleportado para " .. locationName, 3)
            end
        end
    })
end

TeleportTab:AddSection({Name = "Teleport para Jogadores"})

local PlayerTPDropdown
PlayerTPDropdown = TeleportTab:AddDropdown({
    Name = "Jogador para Teleportar",
    Default = "",
    Options = GetPlayerNames(),
    Callback = function(Value)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == Value and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                GetHRP().CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5)
                Notify("Teleport", "Teleportado para " .. plr.Name, 3)
            end
        end
    end
})

TeleportTab:AddButton({
    Name = "Atualizar Lista de Jogadores",
    Callback = function()
        PlayerTPDropdown:Refresh(GetPlayerNames(), true)
    end
})

TeleportTab:AddSection({Name = "Veículos"})

TeleportTab:AddButton({
    Name = "Teleport para Carro Próximo",
    Callback = function()
        TeleportToCar()
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: VEÍCULOS ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local VehicleTab = Window:MakeTab({
    Name = "Veículos",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VehicleTab:AddSection({Name = "Spawn de Carros"})

local carList = {"Sedan", "SUV", "Truck", "Sports", "Muscle", "Exotic", "Motorcycle", "Helicopter", "Boat", "Jeep"}
for _, carName in pairs(carList) do
    VehicleTab:AddButton({
        Name = "Spawn " .. carName,
        Callback = function()
            SpawnCar(carName)
        end
    })
end

VehicleTab:AddSection({Name = "Modificações"})

VehicleTab:AddToggle({
    Name = "Set Car Speed",
    Default = false,
    Callback = function(Value)
        ToggleSetCarSpeed(Value)
    end
})

VehicleTab:AddSlider({
    Name = "Velocidade do Carro",
    Min = 50,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(255, 100, 0),
    Increment = 10,
    ValueName = "Speed",
    Callback = function(Value)
        CarSpeedValue = Value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: TROLL / ADMIN ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local TrollTab = Window:MakeTab({
    Name = "Troll / Admin",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TrollTab:AddSection({Name = "Comandos Admin"})

TrollTab:AddTextbox({
    Name = "Comando Admin",
    Default = ":kill nome",
    TextDisappear = false,
    Callback = function(Value)
        AdminCommand(Value)
    end
})

TrollTab:AddLabel("Comandos: :kill, :bring, :goto, :fling, :freeze, :unfreeze, :speed, :jump, :heal, :god, :noclip, :fly, :invis, :clone, :car, :rainbow, :unlock")

TrollTab:AddSection({Name = "Troll Individual"})

local TrollTargetDropdown
TrollTargetDropdown = TrollTab:AddDropdown({
    Name = "Alvo do Troll",
    Default = "",
    Options = GetPlayerNames(),
    Callback = function(Value)
        -- Seleção do alvo
    end
})

TrollTab:AddButton({
    Name = "Atualizar Lista",
    Callback = function()
        TrollTargetDropdown:Refresh(GetPlayerNames(), true)
    end
})

TrollTab:AddButton({
    Name = "Kill",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == TrollTargetDropdown.Value then
                TrollKill(plr)
            end
        end
    end
})

TrollTab:AddButton({
    Name = "Bring",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == TrollTargetDropdown.Value then
                TrollBring(plr)
            end
        end
    end
})

TrollTab:AddButton({
    Name = "Goto",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == TrollTargetDropdown.Value then
                TrollGoto(plr)
            end
        end
    end
})

TrollTab:AddButton({
    Name = "Fling",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == TrollTargetDropdown.Value then
                TrollFling(plr)
            end
        end
    end
})

TrollTab:AddButton({
    Name = "Freeze",
    Callback = function()
                for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == TrollTargetDropdown.Value then
                TrollUnfreeze(plr)
            end
        end
    end
})

TrollTab:AddButton({
    Name = "Clone Avatar",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == TrollTargetDropdown.Value then
                CloneAvatar(plr)
            end
        end
    end
})

TrollTab:AddSection({Name = "Troll em Massa"})

TrollTab:AddButton({
    Name = "Fling All",
    Callback = function()
        FlingAll()
    end
})

TrollTab:AddButton({
    Name = "Kill All",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                TrollKill(plr)
            end
        end
    end
})

TrollTab:AddButton({
    Name = "Bring All",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                TrollBring(plr)
            end
        end
    end
})

TrollTab:AddSection({Name = "Outros"})

TrollTab:AddToggle({
    Name = "Invisible",
    Default = false,
    Callback = function(Value)
        ToggleInvisible(Value)
    end
})

TrollTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        GodModeEnabled = Value
        if Value then
            GetHumanoid().MaxHealth = math.huge
            GetHumanoid().Health = math.huge
            Notify("God Mode", "God Mode ativado!", 3)
        else
            GetHumanoid().MaxHealth = 100
            GetHumanoid().Health = 100
            Notify("God Mode", "God Mode desativado!", 3)
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: PERSONALIZAÇÃO ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local CustomTab = Window:MakeTab({
    Name = "Personalização",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CustomTab:AddSection({Name = "Casa"})

CustomTab:AddToggle({
    Name = "Rainbow House",
    Default = false,
    Callback = function(Value)
        ToggleRainbowHouse(Value)
    end
})

CustomTab:AddSection({Name = "Avatar"})

CustomTab:AddToggle({
    Name = "Rainbow Hair",
    Default = false,
    Callback = function(Value)
        ToggleRainbowHair(Value)
    end
})

CustomTab:AddToggle({
    Name = "Rainbow Skin",
    Default = false,
    Callback = function(Value)
        ToggleRainbowSkin(Value)
    end
})

CustomTab:AddSection({Name = "Gamepass"})

CustomTab:AddButton({
    Name = "Unlock Gamepasses",
    Callback = function()
        ToggleUnlockGamepass(true)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ ABA: CONFIGURAÇÕES ═════════════════════
-- ═══════════════════════════════════════════════════════════════

local SettingsTab = Window:MakeTab({
    Name = "Configurações",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddSection({Name = "Jogador"})

SettingsTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "WS",
    Callback = function(Value)
        GetHumanoid().WalkSpeed = Value
    end
})

SettingsTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "JP",
    Callback = function(Value)
        GetHumanoid().JumpPower = Value
    end
})

SettingsTab:AddSlider({
    Name = "Gravity",
    Min = 0,
    Max = 200,
    Default = 196,
    Color = Color3.fromRGB(0, 0, 255),
    Increment = 1,
    ValueName = "G",
    Callback = function(Value)
        Workspace.Gravity = Value
    end
})

SettingsTab:AddSection({Name = "Câmera"})

SettingsTab:AddSlider({
    Name = "Field of View",
    Min = 30,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(Value)
        Camera.FieldOfView = Value
    end
})

SettingsTab:AddButton({
    Name = "Reset Camera",
    Callback = function()
        Camera.FieldOfView = 70
        Notify("Camera", "Câmera resetada!", 3)
    end
})

SettingsTab:AddSection({Name = "Ambiente"})

SettingsTab:AddButton({
    Name = "Reset Lighting",
    Callback = function()
        Lighting.Brightness = originalBrightness
        Lighting.GlobalShadows = originalGlobalShadows
        Lighting.Ambient = originalAmbient
        Lighting.FogStart = originalFogStart
        Lighting.FogEnd = originalFogEnd
        FullBrightEnabled = false
        NoFogEnabled = false
        Notify("Lighting", "Iluminação restaurada!", 3)
    end
})

SettingsTab:AddSlider({
    Name = "Time of Day",
    Min = 0,
    Max = 24,
    Default = 12,
    Color = Color3.fromRGB(255, 200, 0),
    Increment = 1,
    ValueName = "h",
    Callback = function(Value)
        Lighting.ClockTime = Value
    end
})

SettingsTab:AddSection({Name = "Hub"})

SettingsTab:AddButton({
    Name = "Destroy Hub",
    Callback = function()
        -- Limpa todas as conexões
        if AutoFarmConnection then AutoFarmConnection:Disconnect() end
        if RainbowConnection then RainbowConnection:Disconnect() end
        if AntiAFKConnection then AntiAFKConnection:Disconnect() end
        
        for _, conn in pairs(TrollConnections) do
            conn:Disconnect()
        end
        
        -- Desativa tudo
        ESPEnabled = false
        SpeedEnabled = false
        FlyEnabled = false
        NoclipEnabled = false
        InfiniteJumpEnabled = false
        GodModeEnabled = false
        AutoFarmEnabled = false
        FullBrightEnabled = false
        NoFogEnabled = false
        AntiAFKEnabled = false
        WalkOnWaterEnabled = false
        RainbowHouseEnabled = false
        RainbowHairEnabled = false
        RainbowSkinEnabled = false
        SetCarSpeedEnabled = false
        UnlockGamepassEnabled = false
        AutoCollectEnabled = false
        TrollGUIEnabled = false
        AvatarCloneEnabled = false
        AutoRobEnabled = false
        InvisibleEnabled = false
        FlingEnabled = false
        AutoGiveMoneyEnabled = false
        AutoGiveCarEnabled = false
        FreeCamEnabled = false
        AimbotEnabled = false
        
        -- Limpa ESP
        ClearESP()
        
        -- Restaura valores originais
        GetHumanoid().WalkSpeed = 16
        GetHumanoid().JumpPower = 50
        Workspace.Gravity = 196
        Camera.FieldOfView = 70
        
        -- Remove fly parts
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        
        -- Remove water platforms
        for _, part in pairs(WaterParts) do
            if part then part:Destroy() end
        end
        WaterParts = {}
        
        -- Restaura iluminação
        Lighting.Brightness = originalBrightness
        Lighting.GlobalShadows = originalGlobalShadows
        Lighting.Ambient = originalAmbient
        Lighting.FogStart = originalFogStart
        Lighting.FogEnd = originalFogEnd
        
        -- Destrói a UI
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:find("Redz") then
                gui:Destroy()
            end
        end
        
        Notify("Hub", "Hub destruído com sucesso!", 3)
    end
})

SettingsTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- ═══════════════════════════════════════════════════════════════
-- ═════════════════════ NOTIFICAÇÃO INICIAL ═════════════════════
-- ═══════════════════════════════════════════════════════════════

Notify("aquilesgamef1 Hub", "Brookhaven Edition v2.0 carregado com sucesso!", 5)
Notify("Info", "Use as abas para navegar entre as funções!", 5)

-- ═════════════════════ FIM DO SCRIPT ═════════════════════
