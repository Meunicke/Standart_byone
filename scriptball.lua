local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", game.CoreGui)

--------------------------------------------------
-- 🔓 BOTÃO ARRASTÁVEL
--------------------------------------------------
local abrir = Instance.new("TextButton", gui)
abrir.Size = UDim2.new(0,120,0,45)
abrir.Position = UDim2.new(0,20,0.5,0)
abrir.Text = "ABRIR"
abrir.BackgroundColor3 = Color3.fromRGB(255,255,0)
abrir.TextColor3 = Color3.fromRGB(0,0,255)
abrir.TextScaled = true

local dragging = false
local dragStart, startPos

abrir.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = abrir.Position
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging then
		local delta = (input.Position - dragStart) * 0.6
		abrir.Position = UDim2.new(0,startPos.X.Offset + delta.X,0,startPos.Y.Offset + delta.Y)
	end
end)

--------------------------------------------------
-- 🧩 MENU
--------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,460)
frame.Position = UDim2.new(0.5,-160,0.5,-230)
frame.BackgroundColor3 = Color3.fromRGB(20,30,50)
frame.Visible = false
frame.Active = true
frame.Draggable = true

abrir.MouseButton1Click:Connect(function()
	frame.Visible = true
	abrir.Visible = false
end)

--------------------------------------------------
-- ❌ FECHAR
--------------------------------------------------
local fechar = Instance.new("TextButton", frame)
fechar.Size = UDim2.new(0,80,0,30)
fechar.Position = UDim2.new(1,-90,0,10)
fechar.Text = "FECHAR"
fechar.BackgroundColor3 = Color3.fromRGB(255,255,0)

fechar.MouseButton1Click:Connect(function()
	frame.Visible = false
	abrir.Visible = true
end)

--------------------------------------------------
-- 🎨 BOTÃO
--------------------------------------------------
local function botao(txt, y, func)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,40)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(0,120,255)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextScaled = true
	b.MouseButton1Click:Connect(func)
end

--------------------------------------------------
-- 🚫 IGNORAR PERSONAGEM
--------------------------------------------------
local function ehPersonagem(obj)
	local model = obj:FindFirstAncestorOfClass("Model")
	return model and model:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------
-- ⚽ DETECTAR BOLA
--------------------------------------------------
local function ehBola(p)
	if not p:IsA("BasePart") then return false end
	if ehPersonagem(p) then return false end

	local s = p.Size
	if s.X < 1 or s.X > 6 then return false end

	local diff = math.abs(s.X - s.Y) + math.abs(s.Y - s.Z)
	if diff > 1 then return false end

	return true
end

--------------------------------------------------
-- ⚽ COR DA BOLA
--------------------------------------------------
local corSelecionada = Color3.fromRGB(255,0,0)

local function aplicar(p)
	if p:IsA("MeshPart") then
		p.TextureID = ""
	end

	for _,m in ipairs(p:GetChildren()) do
		if m:IsA("SpecialMesh") then
			m.TextureId = ""
		end
	end

	for _,d in ipairs(p:GetDescendants()) do
		if d:IsA("Decal") or d:IsA("Texture") then
			d:Destroy()
		end
	end

	p.Reflectance = 0
	p.Color = corSelecionada
	p.Material = Enum.Material.SmoothPlastic
end

RunService.RenderStepped:Connect(function()
	for _,v in ipairs(workspace:GetDescendants()) do
		if ehBola(v) then
			pcall(function()
				aplicar(v)
			end)
		end
	end
end)

--------------------------------------------------
-- 🎨 CORES
--------------------------------------------------
botao("🔴 VERMELHO", 60, function()
	corSelecionada = Color3.fromRGB(255,0,0)
end)

botao("🔵 AZUL", 110, function()
	corSelecionada = Color3.fromRGB(0,0,255)
end)

botao("🟢 VERDE", 160, function()
	corSelecionada = Color3.fromRGB(0,255,0)
end)

botao("🟡 AMARELO", 210, function()
	corSelecionada = Color3.fromRGB(255,255,0)
end)

--------------------------------------------------
-- ❄️ NEVE
--------------------------------------------------
local neveData = {}

botao("❄️ NEVE", 260, function()

	if next(neveData) then
		for part,data in pairs(neveData) do
			if part and part.Parent then
				part.Material = data.Material
				part.Color = data.Color
			end
		end
		neveData = {}
		return
	end

	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not ehPersonagem(v) then
			neveData[v] = {Material=v.Material, Color=v.Color}
			v.Material = Enum.Material.Snow
			v.Color = Color3.fromRGB(240,240,240)
		end
	end
end)

--------------------------------------------------
-- ⚡ ANTI LAG
--------------------------------------------------
botao("⚡ ANTI LAG", 320, function()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Rate = 20
		end
		if v:IsA("BasePart") then
			v.CastShadow = false
		end
	end
	Lighting.GlobalShadows = false
end)
