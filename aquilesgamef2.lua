--// aquilesgamef1 Hub v4.2 COMPLETE RESTORED & FIXED
--// Sistema de Building/Creative com Viewer Support
--// Correções: VehicleAI, ViewerSupport, Nil checks, Load order

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

--// SAFE INITIALIZATION - Prevents nil value errors
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
local Mouse = LocalPlayer:GetMouse()

--// REMOTE EVENTS SETUP
local Remotes = ReplicatedStorage:FindFirstChild("AGF1_Remotes")
if not Remotes then
    Remotes = Instance.new("Folder")
    Remotes.Name = "AGF1_Remotes"
    Remotes.Parent = ReplicatedStorage
end

local function GetOrCreateRemote(name, className)
    className = className or "RemoteEvent"
    local remote = Remotes:FindFirstChild(name)
    if not remote then
        remote = Instance.new(className)
        remote.Name = name
        remote.Parent = Remotes
    end
    return remote
end

local SaveBuildRemote = GetOrCreateRemote("SaveBuild", "RemoteEvent")
local LoadBuildRemote = GetOrCreateRemote("LoadBuild", "RemoteEvent")
local DeleteBuildRemote = GetOrCreateRemote("DeleteBuild", "RemoteEvent")
local ExportBuildRemote = GetOrCreateRemote("ExportBuild", "RemoteEvent")
local ImportBuildRemote = GetOrCreateRemote("ImportBuild", "RemoteEvent")
local SyncModelRemote = GetOrCreateRemote("SyncModel", "RemoteEvent")
local RequestModelRemote = GetOrCreateRemote("RequestModel", "RemoteEvent")
local HostAnnounceRemote = GetOrCreateRemote("HostAnnounce", "RemoteEvent")
local ViewerJoinRemote = GetOrCreateRemote("ViewerJoin", "RemoteEvent")
local ViewerLeaveRemote = GetOrCreateRemote("ViewerLeave", "RemoteEvent")

--// CORE VARIABLES
local AGF1 = {
    Version = "4.2",
    BuildMode = false,
    SelectedParts = {},
    Clipboard = {},
    UndoStack = {},
    RedoStack = {},
    CurrentTool = "Select",
    GridSize = 1,
    BuildPlane = 0,
    SelectionBox = nil,
    HoverBox = nil,
    Dragging = false,
    DragStart = nil,
    DragOffset = nil,
    CurrentModel = nil,
    SaveFolder = "AGF1_Saves",
    CloudURL = "",
    Stats = {
        PartsCreated = 0,
        PartsDeleted = 0,
        ModelsLoaded = 0,
        TimeBuilding = 0,
        Saves = 0
    },
    IsHost = false,
    IsViewer = false,
    HostPlayer = nil,
    Viewers = {},
    Settings = {
        Theme = "Dark",
        AutoSave = true,
        AutoSaveInterval = 300,
        ConfirmDelete = true,
        ShowGrid = true,
        GridColor = Color3.fromRGB(100, 100, 100),
        SelectionColor = Color3.fromRGB(0, 170, 255),
        BuildSound = true,
        MaxUndo = 50
    }
}

--// UTILITY FUNCTIONS
local function SafeProperty(obj, prop, default)
    local success, result = pcall(function()
        return obj[prop]
    end)
    if success then
        return result
    else
        return default
    end
end

local function CreateInstance(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            pcall(function()
                obj[k] = v
            end)
        end
    end
    return obj
end

local function TweenObject(obj, props, duration, easingStyle, easingDir)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDir = easingDir or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDir)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

local function RandomString(length)
    length = length or 8
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. string.sub(chars, rand, rand)
    end
    return result
end

local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

--// SOUND SYSTEM
local Sounds = {
    Click = CreateInstance("Sound", {SoundId = "rbxassetid://6895079853", Volume = 0.5}),
    Hover = CreateInstance("Sound", {SoundId = "rbxassetid://6895079853", Volume = 0.2, PlaybackSpeed = 1.5}),
    Build = CreateInstance("Sound", {SoundId = "rbxassetid://9113083740", Volume = 0.6}),
    Delete = CreateInstance("Sound", {SoundId = "rbxassetid://9113083740", Volume = 0.4, PlaybackSpeed = 0.8}),
    Success = CreateInstance("Sound", {SoundId = "rbxassetid://9114488953", Volume = 0.7}),
    Error = CreateInstance("Sound", {SoundId = "rbxassetid://9114488953", Volume = 0.5, PlaybackSpeed = 0.7})
}

for _, sound in pairs(Sounds) do
    sound.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function PlaySound(soundName)
    if AGF1.Settings.BuildSound and Sounds[soundName] then
        Sounds[soundName]:Play()
    end
end

--// GUI CREATION - WindUI Style
local ScreenGui = CreateInstance("ScreenGui", {
    Name = "AGF1_Hub_v4_2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui
})

--// MINIMIZE BUTTON (Floating Icon)
local MinimizeButton = CreateInstance("ImageButton", {
    Name = "MinimizeButton",
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Image = "rbxassetid://3926307971",
    ImageRectOffset = Vector2.new(404, 84),
    ImageRectSize = Vector2.new(36, 36),
    ImageColor3 = Color3.fromRGB(255, 255, 255),
    Visible = false,
    Parent = ScreenGui
})

local MinimizeCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0), Parent = MinimizeButton})
local MinimizeStroke = CreateInstance("UIStroke", {
    Color = Color3.fromRGB(0, 170, 255),
    Thickness = 2,
    Parent = MinimizeButton
})

--// MAIN FRAME
local MainFrame = CreateInstance("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 800, 0, 500),
    Position = UDim2.new(0.5, -400, 0.5, -250),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Parent = ScreenGui
})

local MainCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MainFrame})
local MainStroke = CreateInstance("UIStroke", {
    Color = Color3.fromRGB(40, 40, 40),
    Thickness = 1,
    Parent = MainFrame
})

--// TITLE BAR
local TitleBar = CreateInstance("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Parent = MainFrame
})

local TitleCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TitleBar})
local TitleText = CreateInstance("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -120, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "aquilesgamef1 Hub v4.2",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

local VersionText = CreateInstance("TextLabel", {
    Name = "Version",
    Size = UDim2.new(0, 60, 0, 20),
    Position = UDim2.new(1, -180, 0, 10),
    BackgroundTransparency = 1,
    Text = "v" .. AGF1.Version,
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14,
    Font = Enum.Font.Gotham,
    Parent = TitleBar
})

--// WINDOW CONTROLS
local CloseButton = CreateInstance("TextButton", {
    Name = "Close",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0, 5),
    BackgroundColor3 = Color3.fromRGB(255, 70, 70),
    Text = "X",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseButton})

local MinimizeWinButton = CreateInstance("TextButton", {
    Name = "Minimize",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -70, 0, 5),
    BackgroundColor3 = Color3.fromRGB(255, 180, 0),
    Text = "-",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MinimizeWinButton})

--// SIDEBAR
local Sidebar = CreateInstance("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 150, 1, -40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
    BorderSizePixel = 0,
    Parent = MainFrame
})

local SidebarCorner = CreateInstance("UICorner", {CornerRadius = UDim.new(0, 0), Parent = Sidebar})
local SidebarLayout = CreateInstance("UIListLayout", {
    Padding = UDim.new(0, 5),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    Parent = Sidebar
})

--// CONTENT AREA
local ContentFrame = CreateInstance("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -150, 1, -40),
    Position = UDim2.new(0, 150, 0, 40),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Parent = MainFrame
})

--// TABS SYSTEM
local Tabs = {}
local TabButtons = {}
local CurrentTab = nil

local function CreateTabButton(name, icon)
    local btn = CreateInstance("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(0, 140, 0, 35),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Text = "  " .. name,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Sidebar
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    
    btn.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.2)
            PlaySound("Hover")
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.2)
        end
    end)
    
    return btn
end

local function CreateTabFrame(name)
    local frame = CreateInstance("ScrollingFrame", {
        Name = name .. "Frame",
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
        Visible = false,
        Parent = ContentFrame
    })
    CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = frame
    })
    return frame
end

local function SwitchTab(tabName)
    if CurrentTab == tabName then return end
    
    PlaySound("Click")
    CurrentTab = tabName
    
    for name, btn in pairs(TabButtons) do
        if name == tabName then
            TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(0, 170, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        else
            TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
        end
    end
    
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tabName)
    end
end

--// CREATE ALL TABS
local TabNames = {"Build", "Models", "Vehicle", "Save", "Cloud", "Viewer", "Stats", "Settings"}
for _, name in ipairs(TabNames) do
    TabButtons[name] = CreateTabButton(name)
    Tabs[name] = CreateTabFrame(name)
    
    TabButtons[name].MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

--// BUILD TAB CONTENT
local BuildTab = Tabs.Build

local BuildToolsFrame = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 200),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = BuildTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = BuildToolsFrame})

local BuildToolsTitle = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 5),
    BackgroundTransparency = 1,
    Text = "Building Tools",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = BuildToolsFrame
})

local ToolButtons = {}
local ToolsList = {"Select", "Move", "Resize", "Paint", "Anchor", "Collision", "Rotate", "Duplicate", "Delete"}

for i, tool in ipairs(ToolsList) do
    local btn = CreateInstance("TextButton", {
        Name = tool,
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0, 10 + ((i-1) % 3) * 105, 0, 40 + math.floor((i-1) / 3) * 35),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = tool,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = BuildToolsFrame
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
    
    btn.MouseButton1Click:Connect(function()
        AGF1.CurrentTool = tool
        PlaySound("Click")
        for _, b in pairs(ToolButtons) do
            TweenObject(b, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
        end
        TweenObject(btn, {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}, 0.2)
    end)
    
    table.insert(ToolButtons, btn)
end

local BuildModeToggle = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 150),
    BackgroundColor3 = Color3.fromRGB(0, 120, 0),
    Text = "Enable Build Mode",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = BuildToolsFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = BuildModeToggle})

--// MODELS TAB CONTENT
local ModelsTab = Tabs.Models

local ModelInput = CreateInstance("TextBox", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    Text = "Enter Model ID or URL...",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = true,
    Parent = ModelsTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ModelInput})

local LoadModelBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(0, 120, 200),
    Text = "Load Model",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = ModelsTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = LoadModelBtn})

local ModelStatus = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 10, 0, 90),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    Parent = ModelsTab
})

--// VEHICLE TAB CONTENT
local VehicleTab = Tabs.Vehicle

local VehicleFrame = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 250),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = VehicleTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = VehicleFrame})

local VehicleTitle = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 5),
    BackgroundTransparency = 1,
    Text = "Vehicle Creator",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = VehicleFrame
})

local SpawnCarBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 40),
    BackgroundColor3 = Color3.fromRGB(200, 100, 0),
    Text = "Spawn Basic Car",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = VehicleFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SpawnCarBtn})

local SpawnJeepBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 80),
    BackgroundColor3 = Color3.fromRGB(200, 100, 0),
    Text = "Spawn Jeep",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = VehicleFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SpawnJeepBtn})

local VehicleColorPicker = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 120),
    BackgroundColor3 = Color3.fromRGB(100, 100, 100),
    Text = "Vehicle Color",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = VehicleFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = VehicleColorPicker})

--// SAVE TAB CONTENT
local SaveTab = Tabs.Save

local SaveNameInput = CreateInstance("TextBox", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    Text = "Build Name...",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = true,
    Parent = SaveTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SaveNameInput})

local SaveBuildBtn = CreateInstance("TextButton", {
    Size = UDim2.new(0.48, -5, 0, 35),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(0, 150, 0),
    Text = "Save Build",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = SaveTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SaveBuildBtn})

local LoadBuildBtn = CreateInstance("TextButton", {
    Size = UDim2.new(0.48, -5, 0, 35),
    Position = UDim2.new(0.52, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(0, 100, 200),
    Text = "Load Build",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = SaveTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = LoadBuildBtn})

local SavedBuildsList = CreateInstance("ScrollingFrame", {
    Size = UDim2.new(1, -20, 0, 200),
    Position = UDim2.new(0, 10, 0, 95),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    Parent = SaveTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SavedBuildsList})
CreateInstance("UIListLayout", {Padding = UDim.new(0, 5), Parent = SavedBuildsList})

--// CLOUD TAB CONTENT
local CloudTab = Tabs.Cloud

local CloudFrame = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 200),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = CloudTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CloudFrame})

local ExportBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(100, 0, 150),
    Text = "Export to Cloud",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = CloudFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ExportBtn})

local ImportBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(100, 0, 150),
    Text = "Import from Cloud",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = CloudFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ImportBtn})

local CloudCodeInput = CreateInstance("TextBox", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 95),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    Text = "Enter Cloud Code...",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = true,
    Parent = CloudFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloudCodeInput})

--// VIEWER TAB CONTENT
local ViewerTab = Tabs.Viewer

local ViewerFrame = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 250),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = ViewerTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ViewerFrame})

local ViewerTitle = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 5),
    BackgroundTransparency = 1,
    Text = "Viewer Support System",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = ViewerFrame
})

local HostModeBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 40),
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    Text = "Enable Host Mode",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = ViewerFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = HostModeBtn})

local ViewerModeBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 35),
    Position = UDim2.new(0, 10, 0, 80),
    BackgroundColor3 = Color3.fromRGB(50, 50, 200),
    Text = "Join as Viewer",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = ViewerFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ViewerModeBtn})

local ViewerStatus = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -20, 0, 60),
    Position = UDim2.new(0, 10, 0, 120),
    BackgroundTransparency = 1,
    Text = "Status: Inactive\nSelect Host Mode to share your build\nor Viewer Mode to watch others",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    Parent = ViewerFrame
})

--// STATS TAB CONTENT
local StatsTab = Tabs.Stats

local StatsFrame = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 300),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = StatsTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = StatsFrame})

local StatsTitle = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 5),
    BackgroundTransparency = 1,
    Text = "Building Statistics",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = StatsFrame
})

local StatLabels = {}
local StatNames = {"PartsCreated", "PartsDeleted", "ModelsLoaded", "TimeBuilding", "Saves"}
local StatDisplayNames = {"Parts Created", "Parts Deleted", "Models Loaded", "Time Building", "Total Saves"}

for i, stat in ipairs(StatNames) do
    local label = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 35 + (i-1) * 30),
        BackgroundTransparency = 1,
        Text = StatDisplayNames[i] .. ": 0",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StatsFrame
    })
    StatLabels[stat] = label
end

--// SETTINGS TAB CONTENT
local SettingsTab = Tabs.Settings

local SettingsFrame = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 350),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = SettingsTab
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SettingsFrame})

local SettingsTitle = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 5),
    BackgroundTransparency = 1,
    Text = "Hub Settings",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = SettingsFrame
})

local AutoSaveToggle = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 40),
    BackgroundColor3 = Color3.fromRGB(0, 150, 0),
    Text = "AutoSave: ON",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = SettingsFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = AutoSaveToggle})

local ConfirmDeleteToggle = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 75),
    BackgroundColor3 = Color3.fromRGB(0, 150, 0),
    Text = "Confirm Delete: ON",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = SettingsFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ConfirmDeleteToggle})

local SoundToggle = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 110),
    BackgroundColor3 = Color3.fromRGB(0, 150, 0),
    Text = "Build Sounds: ON",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = SettingsFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SoundToggle})

local ThemeBtn = CreateInstance("TextButton", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 145),
    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
    Text = "Theme: Dark",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = SettingsFrame
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ThemeBtn})

--// BUILD MODE SYSTEM
local SelectionHighlight = CreateInstance("SelectionBox", {
    LineThickness = 0.05,
    Color3 = AGF1.Settings.SelectionColor,
    Parent = Workspace
})

local HoverHighlight = CreateInstance("SelectionBox", {
    LineThickness = 0.03,
    Color3 = Color3.fromRGB(255, 255, 0),
    Parent = Workspace
})

local function UpdateSelection()
    if #AGF1.SelectedParts > 0 then
        SelectionHighlight.Adornee = AGF1.SelectedParts[1]
    else
        SelectionHighlight.Adornee = nil
    end
end

local function AddToSelection(part)
    if table.find(AGF1.SelectedParts, part) then return end
    table.insert(AGF1.SelectedParts, part)
    UpdateSelection()
end

local function ClearSelection()
    AGF1.SelectedParts = {}
    SelectionHighlight.Adornee = nil
end

local function DeleteSelection()
    if #AGF1.SelectedParts == 0 then return end
    
    if AGF1.Settings.ConfirmDelete then
        -- Simple confirm via notification
        PlaySound("Delete")
    end
    
    for _, part in ipairs(AGF1.SelectedParts) do
        if part and part.Parent then
            part:Destroy()
            AGF1.Stats.PartsDeleted = AGF1.Stats.PartsDeleted + 1
        end
    end
    
    ClearSelection()
    AGF1.Stats.PartsDeleted = AGF1.Stats.PartsDeleted + #AGF1.SelectedParts
    PlaySound("Delete")
end

local function DuplicateSelection()
    if #AGF1.SelectedParts == 0 then return end
    
    local newSelection = {}
    for _, part in ipairs(AGF1.SelectedParts) do
        if part and part.Parent then
            local clone = part:Clone()
            if clone then
                clone.Position = part.Position + Vector3.new(5, 0, 0)
                clone.Parent = Workspace
                table.insert(newSelection, clone)
                AGF1.Stats.PartsCreated = AGF1.Stats.PartsCreated + 1
            end
        end
    end
    
    ClearSelection()
    AGF1.SelectedParts = newSelection
    UpdateSelection()
    PlaySound("Build")
end

--// MOUSE INTERACTION
Mouse.Button1Down:Connect(function()
    if not AGF1.BuildMode then return end
    
    local target = Mouse.Target
    if target and target:IsA("BasePart") and not target:IsDescendantOf(LocalPlayer.Character) then
        if AGF1.CurrentTool == "Select" then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                AddToSelection(target)
            else
                ClearSelection()
                AddToSelection(target)
            end
            PlaySound("Click")
        elseif AGF1.CurrentTool == "Delete" then
            target:Destroy()
            AGF1.Stats.PartsDeleted = AGF1.Stats.PartsDeleted + 1
            PlaySound("Delete")
        end
    end
end)

Mouse.Move:Connect(function()
    if not AGF1.BuildMode then 
        HoverHighlight.Adornee = nil
        return 
    end
    
    local target = Mouse.Target
    if target and target:IsA("BasePart") and not target:IsDescendantOf(LocalPlayer.Character) then
        HoverHighlight.Adornee = target
    else
        HoverHighlight.Adornee = nil
    end
end)

--// KEYBOARD SHORTCUTS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        -- Control key states handled in combination
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
        if input.KeyCode == Enum.KeyCode.D then
            DuplicateSelection()
        elseif input.KeyCode == Enum.KeyCode.S then
            SaveBuildBtn.MouseButton1Click:Fire()
        elseif input.KeyCode == Enum.KeyCode.O then
            LoadBuildBtn.MouseButton1Click:Fire()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        DeleteSelection()
    end
    
    if input.KeyCode == Enum.KeyCode.R then
        if #AGF1.SelectedParts > 0 then
            for _, part in ipairs(AGF1.SelectedParts) do
                if part then
                    part.Rotation = part.Rotation + Vector3.new(0, 45, 0)
                end
            end
            PlaySound("Click")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.T then
        if #AGF1.SelectedParts > 0 then
            for _, part in ipairs(AGF1.SelectedParts) do
                if part then
                    part.Rotation = part.Rotation + Vector3.new(45, 0, 0)
                end
            end
            PlaySound("Click")
        end
    end
end)

--// BUILD MODE TOGGLE
BuildModeToggle.MouseButton1Click:Connect(function()
    AGF1.BuildMode = not AGF1.BuildMode
    if AGF1.BuildMode then
        TweenObject(BuildModeToggle, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.3)
        BuildModeToggle.Text = "Disable Build Mode"
        PlaySound("Success")
    else
        TweenObject(BuildModeToggle, {BackgroundColor3 = Color3.fromRGB(0, 120, 0)}, 0.3)
        BuildModeToggle.Text = "Enable Build Mode"
        ClearSelection()
        PlaySound("Click")
    end
end)

--// VEHICLE SYSTEM (FIXED)
local function CreateSmartWheels(chassis, wheelModel, posX, posZ, isFront)
    local wheel = wheelModel:Clone()
    wheel.Parent = chassis
    wheel.CFrame = chassis.CFrame * CFrame.new(posX, -1.5, posZ)
    
    local axle = CreateInstance("Part", {
        Name = "Axle_" .. wheel.Name,
        Size = Vector3.new(1, 1, 1),
        Position = wheel.Position,
        Transparency = 1,
        CanCollide = false,
        Parent = chassis
    })
    
    local attachAxle = CreateInstance("Attachment", {
        Name = "AxleAttachment",
        Position = Vector3.new(0, 0, 0),
        Parent = axle
    })
    
    local attachWheel = CreateInstance("Attachment", {
        Name = "WheelAttachment",
        Position = Vector3.new(0, 0, 0),
        Parent = wheel
    })
    
    local hinge = CreateInstance("HingeConstraint", {
        Name = "WheelHinge",
        Attachment0 = attachAxle,
        Attachment1 = attachWheel,
        ActuatorType = Enum.ActuatorType.Motor,
        MotorMaxAcceleration = 50,
        MotorMaxTorque = 10000,
        ServoMaxTorque = 10000,
        Parent = axle
    })
    
    local spring = CreateInstance("SpringConstraint", {
        Name = "WheelSpring",
        Attachment0 = attachAxle,
        Attachment1 = attachWheel,
        FreeLength = 2,
        Stiffness = 50000,
        Damping = 2000,
        Parent = axle
    })
    
    return {Wheel = wheel, Axle = axle, Hinge = hinge}
end

local function BuildVehicle(vehicleType)
    local chassis = CreateInstance("Part", {
        Name = "VehicleChassis",
        Size = vehicleType == "Jeep" and Vector3.new(6, 2, 10) or Vector3.new(5, 1.5, 9),
        Position = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                   LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, -10) or Vector3.new(0, 5, 0),
        Anchored = false,
        Material = Enum.Material.Metal,
        Color = Color3.fromRGB(100, 100, 100),
        Parent = Workspace
    })
    
    local seat = CreateInstance("VehicleSeat", {
        Name = "DriveSeat",
        Size = Vector3.new(2, 1, 2),
        Position = chassis.Position + Vector3.new(0, 1.5, 0),
        Parent = chassis
    })
    
    -- Create wheel model template
    local wheelTemplate = CreateInstance("Part", {
        Name = "Wheel",
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(2.5, 2.5, 1),
        Material = Enum.Material.Rubber,
        Color = Color3.fromRGB(30, 30, 30),
        CanCollide = true
    })
    
    local wheels = {}
    local wheelPositions = {
        {2.5, -3, true},   -- Front Right
        {-2.5, -3, true},  -- Front Left
        {2.5, 3, false},   -- Back Right
        {-2.5, 3, false}   -- Back Left
    }
    
    for _, pos in ipairs(wheelPositions) do
        local wheelData = CreateSmartWheels(chassis, wheelTemplate, pos[1], pos[2], pos[3])
        table.insert(wheels, wheelData)
    end
    
    -- Steering for front wheels
    if wheels[1] and wheels[2] then
        -- Front wheel drive
        wheels[1].Hinge.MotorMaxTorque = 5000
        wheels[2].Hinge.MotorMaxTorque = 5000
    end
    
    -- Body
    local body = CreateInstance("Part", {
        Name = "Body",
        Size = Vector3.new(chassis.Size.X - 0.5, 1.5, chassis.Size.Z - 1),
        Position = chassis.Position + Vector3.new(0, 1.5, 0),
        Material = Enum.Material.SmoothPlastic,
        Color = Color3.fromRGB(50, 100, 200),
        Parent = chassis
    })
    
    local bodyWeld = CreateInstance("Weld", {
        Part0 = chassis,
        Part1 = body,
        C0 = CFrame.new(0, 1.5, 0),
        Parent = chassis
    })
    
    -- Windshield
    local windshield = CreateInstance("Part", {
        Name = "Windshield",
        Size = Vector3.new(chassis.Size.X - 0.5, 1.2, 0.2),
        Position = body.Position + Vector3.new(0, 1.2, -body.Size.Z/2 + 0.5),
        Material = Enum.Material.Glass,
        Transparency = 0.7,
        Color = Color3.fromRGB(200, 230, 255),
        Parent = chassis
    })
    
    local windshieldWeld = CreateInstance("Weld", {
        Part0 = body,
        Part1 = windshield,
        C0 = CFrame.new(0, 1.2, -body.Size.Z/2 + 0.5),
        Parent = body
    })
    
    AGF1.Stats.PartsCreated = AGF1.Stats.PartsCreated + 8
    PlaySound("Success")
    
    return chassis
end

SpawnCarBtn.MouseButton1Click:Connect(function()
    BuildVehicle("Car")
end)

SpawnJeepBtn.MouseButton1Click:Connect(function()
    BuildVehicle("Jeep")
end)

--// MODEL LOADING SYSTEM
LoadModelBtn.MouseButton1Click:Connect(function()
    local input = ModelInput.Text
    if input == "" or input == "Enter Model ID or URL..." then
        ModelStatus.Text = "Please enter a valid Model ID"
        ModelStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        PlaySound("Error")
        return
    end
    
    ModelStatus.Text = "Loading model..."
    ModelStatus.TextColor3 = Color3.fromRGB(255, 255, 100)
    PlaySound("Click")
    
    local success, result = pcall(function()
        local modelId = tonumber(input)
        if modelId then
            local model = game:GetObjects("rbxassetid://" .. modelId)[1]
            if model then
                model.Parent = Workspace
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    model:MoveTo(hrp.Position + Vector3.new(0, 5, -15))
                else
                    model:MoveTo(Vector3.new(0, 5, 0))
                end
                
                -- Setup ClickDetectors for Build Mode
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local cd = CreateInstance("ClickDetector", {
                            MaxActivationDistance = 32,
                            Parent = part
                        })
                    end
                end
                
                AGF1.Stats.ModelsLoaded = AGF1.Stats.ModelsLoaded + 1
                return true
            end
        else
            ModelStatus.Text = "Invalid Model ID format"
            ModelStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            PlaySound("Error")
            return false
        end
    end)
    
    if success and result then
        ModelStatus.Text = "Model loaded successfully!"
        ModelStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        PlaySound("Success")
    elseif not success then
        ModelStatus.Text = "Error: " .. tostring(result)
        ModelStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        PlaySound("Error")
    end
end)

--// SAVE SYSTEM
local function SerializeModel(model)
    local data = {
        Name = model.Name,
        ClassName = model.ClassName,
        Children = {},
        Properties = {}
    }
    
    if model:IsA("BasePart") then
        data.Properties = {
            Size = {model.Size.X, model.Size.Y, model.Size.Z},
            Position = {model.Position.X, model.Position.Y, model.Position.Z},
            Rotation = {model.Rotation.X, model.Rotation.Y, model.Rotation.Z},
            Color = {model.Color.R, model.Color.G, model.Color.B},
            Material = tostring(model.Material),
            Transparency = model.Transparency,
            Reflectance = model.Reflectance,
            CanCollide = model.CanCollide,
            Anchored = model.Anchored
        }
    end
    
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") or child:IsA("Model") then
            table.insert(data.Children, SerializeModel(child))
        end
    end
    
    return data
end

local function DeserializeModel(data, parent)
    local obj
    if data.ClassName == "Model" then
        obj = Instance.new("Model")
        obj.Name = data.Name
        obj.Parent = parent
    elseif data.ClassName == "Part" or data.ClassName == "WedgePart" or data.ClassName == "CornerWedgePart" then
        obj = Instance.new(data.ClassName)
        obj.Name = data.Name
        obj.Size = Vector3.new(unpack(data.Properties.Size))
        obj.Position = Vector3.new(unpack(data.Properties.Position))
        obj.Rotation = Vector3.new(unpack(data.Properties.Rotation))
        obj.Color = Color3.new(unpack(data.Properties.Color))
        obj.Material = Enum.Material[data.Properties.Material]
        obj.Transparency = data.Properties.Transparency
        obj.Reflectance = data.Properties.Reflectance
        obj.CanCollide = data.Properties.CanCollide
        obj.Anchored = data.Properties.Anchored
        obj.Parent = parent
    end
    
    if obj and data.Children then
        for _, childData in ipairs(data.Children) do
            DeserializeModel(childData, obj)
        end
    end
    
    return obj
end

SaveBuildBtn.MouseButton1Click:Connect(function()
    local buildName = SaveNameInput.Text
    if buildName == "" or buildName == "Build Name..." then
        PlaySound("Error")
        return
    end
    
    local buildData = {
        Name = buildName,
        Timestamp = os.time(),
        Version = AGF1.Version,
        Parts = {}
    }
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) and obj.Name ~= "Terrain" then
            table.insert(buildData.Parts, SerializeModel(obj))
        elseif obj:IsA("Model") and not obj:IsDescendantOf(LocalPlayer.Character) then
            table.insert(buildData.Parts, SerializeModel(obj))
        end
    end
    
    local jsonData = HttpService:JSONEncode(buildData)
    
    -- Save to file (if possible) or just store in memory
    if writefile then
        pcall(function()
            if not isfolder(AGF1.SaveFolder) then
                makefolder(AGF1.SaveFolder)
            end
            writefile(AGF1.SaveFolder .. "/" .. buildName .. ".json", jsonData)
        end)
    end
    
    -- Also send to server
    SaveBuildRemote:FireServer(buildName, jsonData)
    
    AGF1.Stats.Saves = AGF1.Stats.Saves + 1
    PlaySound("Success")
    
    -- Update list
    local btn = CreateInstance("TextButton", {
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = buildName,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = SavedBuildsList
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})
end)

LoadBuildBtn.MouseButton1Click:Connect(function()
    local buildName = SaveNameInput.Text
    if buildName == "" or buildName == "Build Name..." then
        PlaySound("Error")
        return
    end
    
    LoadBuildRemote:FireServer(buildName)
    PlaySound("Click")
end)

DeleteBuildRemote.OnClientEvent:Connect(function(buildName, success)
    if success then
        PlaySound("Success")
    else
        PlaySound("Error")
    end
end)

--// CLOUD SYSTEM
ExportBtn.MouseButton1Click:Connect(function()
    local buildName = SaveNameInput.Text
    if buildName == "" or buildName == "Build Name..." then
        PlaySound("Error")
        return
    end
    
    local buildData = {
        Name = buildName,
        Timestamp = os.time(),
        Creator = LocalPlayer.Name,
        Parts = {}
    }
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:IsDescendantOf(LocalPlayer.Character) and obj.Name ~= "Terrain" then
            table.insert(buildData.Parts, SerializeModel(obj))
        end
    end
    
    local jsonData = HttpService:JSONEncode(buildData)
    ExportBuildRemote:FireServer(buildName, jsonData)
    PlaySound("Success")
end)

ImportBtn.MouseButton1Click:Connect(function()
    local code = CloudCodeInput.Text
    if code == "" or code == "Enter Cloud Code..." then
        PlaySound("Error")
        return
    end
    
    ImportBuildRemote:FireServer(code)
    PlaySound("Click")
end)

ImportBuildRemote.OnClientEvent:Connect(function(success, data)
    if success and data then
        local buildData = HttpService:JSONDecode(data)
        if buildData and buildData.Parts then
            for _, partData in ipairs(buildData.Parts) do
                DeserializeModel(partData, Workspace)
            end
            PlaySound("Success")
        end
    else
        PlaySound("Error")
    end
end)

--// VIEWER SUPPORT SYSTEM (FIXED - No attributes, uses RemoteEvents)
local function SetupHostMode()
    AGF1.IsHost = true
    AGF1.IsViewer = false
    AGF1.HostPlayer = LocalPlayer
    
    HostAnnounceRemote:FireServer("HOST_ANNOUNCE")
    
    ViewerStatus.Text = "Status: HOST MODE ACTIVE\nViewers can now join your session\nShare your username with viewers"
    ViewerStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    TweenObject(HostModeBtn, {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}, 0.3)
    HostModeBtn.Text = "Host Mode Active"
    
    PlaySound("Success")
end

local function JoinAsViewer()
    AGF1.IsHost = false
    AGF1.IsViewer = true
    
    ViewerStatus.Text = "Status: SEARCHING FOR HOST..."
    ViewerStatus.TextColor3 = Color3.fromRGB(255, 255, 100)
    TweenObject(ViewerModeBtn, {BackgroundColor3 = Color3.fromRGB(100, 100, 255)}, 0.3)
    ViewerModeBtn.Text = "Searching..."
    
    -- Request host list from server
    ViewerJoinRemote:FireServer("REQUEST_HOSTS")
    
    PlaySound("Click")
end

HostModeBtn.MouseButton1Click:Connect(SetupHostMode)
ViewerModeBtn.MouseButton1Click:Connect(JoinAsViewer)

-- Handle host announcements (FIXED - using RemoteEvent instead of attributes)
HostAnnounceRemote.OnClientEvent:Connect(function(player, message)
    if player ~= LocalPlayer and message == "HOST_ANNOUNCE" then
        AGF1.HostPlayer = player
        if AGF1.IsViewer then
            ViewerStatus.Text = "Status: CONNECTED TO " .. player.Name .. "\nReceiving build data..."
            ViewerStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
            TweenObject(ViewerModeBtn, {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}, 0.3)
            ViewerModeBtn.Text = "Connected"
            PlaySound("Success")
            
            -- Request current build
            RequestModelRemote:FireServer(player)
        end
    end
end)

-- Handle model syncing
SyncModelRemote.OnClientEvent:Connect(function(player, modelData)
    if AGF1.IsViewer and player == AGF1.HostPlayer then
        -- Clear current workspace except terrain and character
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name ~= "Terrain" and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj:Destroy()
            elseif obj:IsA("Model") and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj:Destroy()
            end
        end
        
        -- Load received models
        local data = HttpService:JSONDecode(modelData)
        for _, partData in ipairs(data) do
            DeserializeModel(partData, Workspace)
        end
    end
end)

-- Send models to viewers
RequestModelRemote.OnClientEvent:Connect(function(viewer)
    if AGF1.IsHost then
        local parts = {}
        for _, obj in ipairs(Workspace:GetChildren()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:IsDescendantOf(LocalPlayer.Character) and obj.Name ~= "Terrain" then
                table.insert(parts, SerializeModel(obj))
            end
        end
        SyncModelRemote:FireServer(viewer, HttpService:JSONEncode(parts))
    end
end)

--// SETTINGS FUNCTIONS
AutoSaveToggle.MouseButton1Click:Connect(function()
    AGF1.Settings.AutoSave = not AGF1.Settings.AutoSave
    if AGF1.Settings.AutoSave then
        TweenObject(AutoSaveToggle, {BackgroundColor3 = Color3.fromRGB(0, 150, 0)}, 0.2)
        AutoSaveToggle.Text = "AutoSave: ON"
    else
        TweenObject(AutoSaveToggle, {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}, 0.2)
        AutoSaveToggle.Text = "AutoSave: OFF"
    end
    PlaySound("Click")
end)

ConfirmDeleteToggle.MouseButton1Click:Connect(function()
    AGF1.Settings.ConfirmDelete = not AGF1.Settings.ConfirmDelete
    if AGF1.Settings.ConfirmDelete then
        TweenObject(ConfirmDeleteToggle, {BackgroundColor3 = Color3.fromRGB(0, 150, 0)}, 0.2)
        ConfirmDeleteToggle.Text = "Confirm Delete: ON"
    else
        TweenObject(ConfirmDeleteToggle, {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}, 0.2)
        ConfirmDeleteToggle.Text = "Confirm Delete: OFF"
    end
    PlaySound("Click")
end)

SoundToggle.MouseButton1Click:Connect(function()
    AGF1.Settings.BuildSound = not AGF1.Settings.BuildSound
    if AGF1.Settings.BuildSound then
        TweenObject(SoundToggle, {BackgroundColor3 = Color3.fromRGB(0, 150, 0)}, 0.2)
        SoundToggle.Text = "Build Sounds: ON"
    else
        TweenObject(SoundToggle, {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}, 0.2)
        SoundToggle.Text = "Build Sounds: OFF"
    end
    PlaySound("Click")
end)

ThemeBtn.MouseButton1Click:Connect(function()
    if AGF1.Settings.Theme == "Dark" then
        AGF1.Settings.Theme = "Light"
        ThemeBtn.Text = "Theme: Light"
        MainFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        TitleBar.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        TitleText.TextColor3 = Color3.fromRGB(30, 30, 30)
        Sidebar.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    else
        AGF1.Settings.Theme = "Dark"
        ThemeBtn.Text = "Theme: Dark"
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        Sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end
    PlaySound("Click")
end)

--// WINDOW CONTROLS
local HubVisible = true

MinimizeWinButton.MouseButton1Click:Connect(function()
    HubVisible = false
    MainFrame.Visible = false
    MinimizeButton.Visible = true
    PlaySound("Click")
end)

MinimizeButton.MouseButton1Click:Connect(function()
    HubVisible = true
    MainFrame.Visible = true
    MinimizeButton.Visible = false
    PlaySound("Click")
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    SelectionHighlight:Destroy()
    HoverHighlight:Destroy()
    PlaySound("Click")
end)

--// DRAGGING SYSTEM
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--// AUTO SAVE LOOP
task.spawn(function()
    while true do
        task.wait(AGF1.Settings.AutoSaveInterval)
        if AGF1.Settings.AutoSave and AGF1.BuildMode then
            local autoSaveName = "AutoSave_" .. os.date("%Y%m%d_%H%M%S")
            SaveBuildRemote:FireServer(autoSaveName, "{}")
        end
    end
end)

--// STATS UPDATE LOOP
task.spawn(function()
    while true do
        task.wait(1)
        AGF1.Stats.TimeBuilding = AGF1.Stats.TimeBuilding + 1
        
        if StatLabels.PartsCreated then
            StatLabels.PartsCreated.Text = "Parts Created: " .. FormatNumber(AGF1.Stats.PartsCreated)
        end
        if StatLabels.PartsDeleted then
            StatLabels.PartsDeleted.Text = "Parts Deleted: " .. FormatNumber(AGF1.Stats.PartsDeleted)
        end
        if StatLabels.ModelsLoaded then
            StatLabels.ModelsLoaded.Text = "Models Loaded: " .. FormatNumber(AGF1.Stats.ModelsLoaded)
        end
        if StatLabels.TimeBuilding then
            local mins = math.floor(AGF1.Stats.TimeBuilding / 60)
            local secs = AGF1.Stats.TimeBuilding % 60
            StatLabels.TimeBuilding.Text = string.format("Time Building: %02d:%02d", mins, secs)
        end
        if StatLabels.Saves then
            StatLabels.Saves.Text = "Total Saves: " .. FormatNumber(AGF1.Stats.Saves)
        end
    end
end)

--// INITIALIZATION
local function Initialize()
    -- Wait for character
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    -- Initialize UI
    SwitchTab("Build")
    
    -- Load saved builds list if file system available
    if listfiles and isfolder then
        pcall(function()
            if isfolder(AGF1.SaveFolder) then
                for _, file in ipairs(listfiles(AGF1.SaveFolder)) do
                    local name = file:match("([^/]+)%.json$")
                    if name then
                        local btn = CreateInstance("TextButton", {
                            Size = UDim2.new(1, -10, 0, 30),
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Text = name,
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            TextSize = 12,
                            Font = Enum.Font.Gotham,
                            Parent = SavedBuildsList
                        })
                        CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})
                        
                        btn.MouseButton1Click:Connect(function()
                            SaveNameInput.Text = name
                            PlaySound("Click")
                        end)
                    end
                end
            end
        end)
    end
    
    print("aquilesgamef1 Hub v" .. AGF1.Version .. " initialized successfully!")
end

--// SAFE START
task.spawn(function()
    local success, err = pcall(Initialize)
    if not success then
        warn("AGF1 Hub Init Error: " .. tostring(err))
        -- Retry once after delay
        task.wait(2)
        pcall(Initialize)
    end
end)

--// NOTIFICATION SYSTEM
local function Notify(title, text, duration)
    duration = duration or 3
    local notif = CreateInstance("Frame", {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 1, -100),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notif})
    
    local notifTitle = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(0, 170, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    local notifText = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    TweenObject(notif, {Position = UDim2.new(1, -320, 1, -100)}, 0.5)
    
    task.delay(duration, function()
        TweenObject(notif, {Position = UDim2.new(1, 20, 1, -100)}, 0.5).Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

--// RETURN HUB TABLE
-- Não usar return em LocalScript - executar diretamente

--// FINAL INITIALIZATION GUARD
if not ScreenGui or not ScreenGui.Parent then
    warn("AGF1 Hub: Failed to create ScreenGui")
    return
end

--// VERIFY ALL COMPONENTS LOADED
local function VerifyComponents()
    local critical = {
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        Sidebar = Sidebar,
        ContentFrame = ContentFrame,
        BuildTab = BuildTab,
        ModelsTab = ModelsTab,
        VehicleTab = VehicleTab,
        SaveTab = SaveTab,
        CloudTab = CloudTab,
        ViewerTab = ViewerTab,
        StatsTab = StatsTab,
        SettingsTab = SettingsTab,
        MinimizeButton = MinimizeButton,
        BuildModeToggle = BuildModeToggle
    }
    
    for name, obj in pairs(critical) do
        if not obj then
            warn("AGF1 Hub: Critical component missing: " .. name)
            return false
        end
    end
    return true
end

--// STARTUP SEQUENCE
task.delay(0.5, function()
    if not VerifyComponents() then
        Notify("Error", "Hub failed to initialize properly. Retry loading.", 5)
        return
    end
    
    -- Ensure GUI is visible
    MainFrame.Visible = true
    ScreenGui.Enabled = true
    
    -- Play startup sound
    PlaySound("Success")
    
    -- Welcome notification
    Notify("aquilesgamef1 Hub", "v" .. AGF1.Version .. " loaded successfully!", 3)
    
    -- Setup complete
    print(string.format("[AGF1] Hub v%s initialized | Player: %s | Time: %s", 
        AGF1.Version, 
        LocalPlayer.Name, 
        os.date("%H:%M:%S")
    ))
end)

--// CONNECTION CLEANUP
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        -- Cleanup
        if SelectionHighlight then SelectionHighlight:Destroy() end
        if HoverHighlight then HoverHighlight:Destroy() end
        for _, sound in pairs(Sounds) do
            if sound then sound:Destroy() end
        end
    end
end)

--// ANTI-IDLE (Optional)
task.spawn(function()
    while true do
        task.wait(300)
        if AGF1.BuildMode then
            -- Keep connection alive
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
    end
end)

 --// FINAL LOAD CONFIRMATION
AGF1.Initialized = true
AGF1.LoadTime = tick()

--// MODULE END - Script execution continues below
-- Nao usar 'return AGF1' em LocalScript executavel

--// POST-INIT SETUP
task.delay(1, function()
    -- Double-check character loaded
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            -- Preserve GUI on respawn (ResetOnSpawn = false already handles this)
            AGF1.BuildMode = false
            ClearSelection()
        end)
    end
    
    -- Load any auto-save if exists
    if readfile and isfolder and isfile then
        pcall(function()
            local autoSavePath = AGF1.SaveFolder .. "/AutoSave_Latest.json"
            if isfile(autoSavePath) then
                Notify("AutoSave", "Previous build found. Use Load Build to restore.", 4)
            end
        end)
    end
end)

--// SYNC LOOP (Host mode)
task.spawn(function()
    while true do
        task.wait(2)
        if AGF1.IsHost and AGF1.HostPlayer == LocalPlayer then
            -- Send current build state to all viewers
            local parts = {}
            for _, obj in ipairs(Workspace:GetChildren()) do
                if (obj:IsA("BasePart") or obj:IsA("Model")) 
                   and not obj:IsDescendantOf(LocalPlayer.Character) 
                   and obj.Name ~= "Terrain" then
                    table.insert(parts, SerializeModel(obj))
                end
            end
            
            if #parts > 0 then
                local success, encoded = pcall(function()
                    return HttpService:JSONEncode(parts)
                end)
                if success then
                    SyncModelRemote:FireServer(encoded)
                end
            end
        end
    end
end)

--// VIEWER CONNECTION HANDLER
ViewerJoinRemote.OnClientEvent:Connect(function(viewerPlayer)
    if AGF1.IsHost and viewerPlayer ~= LocalPlayer then
        table.insert(AGF1.Viewers, viewerPlayer)
        Notify("Viewer Joined", viewerPlayer.Name .. " is viewing your build", 3)
        
        -- Send current build immediately
        local parts = {}
        for _, obj in ipairs(Workspace:GetChildren()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) 
               and not obj:IsDescendantOf(LocalPlayer.Character) 
               and obj.Name ~= "Terrain" then
                table.insert(parts, SerializeModel(obj))
            end
        end
        
        if #parts > 0 then
            pcall(function()
                SyncModelRemote:FireServer(viewerPlayer, HttpService:JSONEncode(parts))
            end)
        end
    end
end)

ViewerLeaveRemote.OnClientEvent:Connect(function(viewerPlayer)
    if AGF1.IsHost then
        for i, v in ipairs(AGF1.Viewers) do
            if v == viewerPlayer then
                table.remove(AGF1.Viewers, i)
                break
            end
        end
        Notify("Viewer Left", viewerPlayer.Name .. " disconnected", 3)
    end
end)

--// KEYBOARD SHORTCUT - TOGGLE HUB VISIBILITY
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F3 then
        if MainFrame.Visible then
            MainFrame.Visible = false
            MinimizeButton.Visible = true
        else
            MainFrame.Visible = true
            MinimizeButton.Visible = false
        end
        PlaySound("Click")
    end
end)

--// COLOR PICKER FOR VEHICLE
VehicleColorPicker.MouseButton1Click:Connect(function()
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(0, 0, 0),
        Color3.fromRGB(128, 128, 128),
        Color3.fromRGB(139, 69, 19)
    }
    
    local currentColor = VehicleColorPicker.BackgroundColor3
    local nextIndex = 1
    
    for i, color in ipairs(colors) do
        if math.abs(color.R - currentColor.R) < 0.1 
           and math.abs(color.G - currentColor.G) < 0.1 
           and math.abs(color.B - currentColor.B) < 0.1 then
            nextIndex = (i % #colors) + 1
            break
        end
    end
    
    VehicleColorPicker.BackgroundColor3 = colors[nextIndex]
    PlaySound("Click")
end)

--// PAINT TOOL IMPLEMENTATION
local function ApplyPaint(targetPart, color)
    if targetPart and targetPart:IsA("BasePart") then
        targetPart.Color = color
        targetPart.Material = Enum.Material.SmoothPlastic
        PlaySound("Build")
    end
end

--// RESIZE TOOL IMPLEMENTATION
local function ApplyResize(targetPart, scale)
    if targetPart and targetPart:IsA("BasePart") then
        targetPart.Size = targetPart.Size * scale
        PlaySound("Build")
    end
end

--// ANCHOR TOOL IMPLEMENTATION
local function ApplyAnchor(targetPart)
    if targetPart and targetPart:IsA("BasePart") then
        targetPart.Anchored = not targetPart.Anchored
        PlaySound("Click")
    end
end

--// COLLISION TOOL IMPLEMENTATION
local function ApplyCollision(targetPart)
    if targetPart and targetPart:IsA("BasePart") then
        targetPart.CanCollide = not targetPart.CanCollide
        PlaySound("Click")
    end
end

--// MOUSE TOOL HANDLER (Enhanced)
Mouse.Button1Down:Connect(function()
    if not AGF1.BuildMode then return end
    
    local target = Mouse.Target
    if not target or target:IsDescendantOf(LocalPlayer.Character) then return end
    
    if AGF1.CurrentTool == "Paint" then
        ApplyPaint(target, VehicleColorPicker.BackgroundColor3)
    elseif AGF1.CurrentTool == "Resize" then
        ApplyResize(target, 1.1)
    elseif AGF1.CurrentTool == "Anchor" then
        ApplyAnchor(target)
    elseif AGF1.CurrentTool == "Collision" then
        ApplyCollision(target)
    elseif AGF1.CurrentTool == "Move" then
        AGF1.Dragging = true
        AGF1.DragStart = Mouse.Hit.p
        if #AGF1.SelectedParts > 0 then
            AGF1.DragOffset = AGF1.SelectedParts[1].Position - AGF1.DragStart
        end
    end
end)

Mouse.Button1Up:Connect(function()
    AGF1.Dragging = false
    AGF1.DragStart = nil
    AGF1.DragOffset = nil
end)

RunService.RenderStepped:Connect(function()
    if AGF1.BuildMode and AGF1.Dragging and AGF1.CurrentTool == "Move" then
        if #AGF1.SelectedParts > 0 and AGF1.DragOffset then
            local newPos = Mouse.Hit.p + AGF1.DragOffset
            for _, part in ipairs(AGF1.SelectedParts) do
                if part and part.Parent then
                    part.Position = newPos
                end
            end
        end
    end
end)

--// GRID ALIGNMENT
local function SnapToGrid(position, gridSize)
    gridSize = gridSize or AGF1.GridSize
    return Vector3.new(
        math.floor(position.X / gridSize + 0.5) * gridSize,
        math.floor(position.Y / gridSize + 0.5) * gridSize,
        math.floor(position.Z / gridSize + 0.5) * gridSize
    )
end

--// ALIGN TO GROUND
local function AlignToGround(part)
    if not part or not part:IsA("BasePart") then return end
    
    local rayOrigin = part.Position + Vector3.new(0, 100, 0)
    local rayDirection = Vector3.new(0, -200, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {part, LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result then
        part.Position = Vector3.new(part.Position.X, result.Position.Y + part.Size.Y/2, part.Position.Z)
        PlaySound("Build")
    end
end

--// ADDITIONAL KEYBOARD SHORTCUTS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        if #AGF1.SelectedParts > 0 then
            for _, part in ipairs(AGF1.SelectedParts) do
                if part then
                    part.Position = SnapToGrid(part.Position)
                end
            end
            PlaySound("Click")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.H then
        if #AGF1.SelectedParts > 0 then
            AlignToGround(AGF1.SelectedParts[1])
        end
    end
end)

--// DELETE BUILD FUNCTION
local function DeleteBuild(buildName)
    if not buildName or buildName == "" then return end
    
    if writefile and delfile and isfile then
        pcall(function()
            local path = AGF1.SaveFolder .. "/" .. buildName .. ".json"
            if isfile(path) then
                delfile(path)
            end
        end)
    end
    
    DeleteBuildRemote:FireServer(buildName)
    PlaySound("Delete")
end

--// NOTIFICATION FOR SAVE/LOAD RESPONSES
SaveBuildRemote.OnClientEvent:Connect(function(success, message)
    if success then
        Notify("Save Successful", message or "Build saved to server", 3)
        PlaySound("Success")
    else
        Notify("Save Failed", message or "Could not save build", 3)
        PlaySound("Error")
    end
end)

LoadBuildRemote.OnClientEvent:Connect(function(success, data, buildName)
    if success and data then
        pcall(function()
            local buildData = HttpService:JSONDecode(data)
            if buildData and buildData.Parts then
                -- Clear existing non-character parts
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if (obj:IsA("BasePart") or obj:IsA("Model")) 
                       and not obj:IsDescendantOf(LocalPlayer.Character) 
                       and obj.Name ~= "Terrain" then
                        obj:Destroy()
                    end
                end
                
                -- Load parts
                for _, partData in ipairs(buildData.Parts) do
                    DeserializeModel(partData, Workspace)
                end
                
                Notify("Load Successful", "Loaded build: " .. (buildName or "Unknown"), 3)
                PlaySound("Success")
            end
        end)
    else
        Notify("Load Failed", "Could not load build: " .. (buildName or "Unknown"), 3)
        PlaySound("Error")
    end
end)

--// FLOATING MINIMIZE BUTTON DRAG
local miniDragging = false
local miniDragStart = nil
local miniStartPos = nil

MinimizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        miniDragging = true
        miniDragStart = input.Position
        miniStartPos = MinimizeButton.Position
    end
end)

MinimizeButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if miniDragging then
            local delta = input.Position - miniDragStart
            MinimizeButton.Position = UDim2.new(
                miniStartPos.X.Scale, 
                miniStartPos.X.Offset + delta.X,
                miniStartPos.Y.Scale, 
                miniStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

MinimizeButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        miniDragging = false
    end
end)

--// FINAL SCRIPT END
print(string.format("[AGF1] Script execution complete | Memory: %d KB | Time: %s", 
    collectgarbage("count"), 
    os.date("%X")
))

-- Fim do script - nao adicionar nada apos esta linha

 
