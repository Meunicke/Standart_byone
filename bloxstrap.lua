--[[
    Bloxstrap Enhanced Loader
    Author: qwertyui-is-back (Enhanced by aquilesgamef1)
    Version: 2.0
    Description: Improved Bloxstrap loader with error handling, caching, auto-update, and better performance
]]

--// Environment Setup
local getgenv = getgenv or _G
local setidentity = setidentity or setthreadidentity or function() end
local getidentity = getidentity or getthreadidentity or function() return 8 end

--// Configuration
local CONFIG = {
    FolderName = "Bloxstrap",
    VersionFile = "Bloxstrap/version.txt",
    GitHubOwner = "qwertyui-is-back",
    GitHubRepo = "Bloxstrap",
    Branch = "main",
    CacheTimeout = 300, -- seconds before checking for updates
    MaxRetries = 3,
    DebugMode = false,
}

--// Utility: Safe cloneref
local cloneref = cloneref or function(...) return ... end

--// Services
local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

--// Executor Compatibility Layer
local ExecutorAPI = {
    isfolder = isfolder or function(path) return false end,
    isfile = isfile or function(path) return false end,
    makefolder = makefolder or function(path) end,
    writefile = writefile or function(name, src) end,
    readfile = readfile or function(path) return nil end,
    delfile = delfile or function(path) end,
    listfiles = listfiles or function(path) return {} end,
    getcustomasset = getcustomasset or function(path) return "" end,
    setclipboard = setclipboard or function(text) end,
    getexecutorname = getexecutorname or function() return "Unknown" end,
    gethui = gethui or function() return CoreGui end,
    hookfunction = hookfunction or function() end,
    setfpscap = setfpscap or function() end,
    getfflag = getfflag or function(flag) return nil end,
    setfflag = setfflag or function(flag, value) end,
    loadstring = loadstring or function(src) return function() end end,
    gameHttpGet = function(url, nocache)
        local success, result = pcall(function()
            return game:HttpGet(url, nocache or true)
        end)
        if success then return result end
        -- Fallback for executors with different HttpGet signatures
        success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then return result end
        error("Failed to fetch: " .. url .. " | Error: " .. tostring(result))
    end,
}

--// Logger System
local Logger = {
    logs = {},
    maxLogs = 100,
}

function Logger:log(level, message)
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] [%s] %s", timestamp, level, message)
    table.insert(self.logs, entry)
    if #self.logs > self.maxLogs then
        table.remove(self.logs, 1)
    end
    if CONFIG.DebugMode then
        print("[Bloxstrap] " .. entry)
    end
end

function Logger:info(msg) self:log("INFO", msg) end
function Logger:warn(msg) self:log("WARN", msg) end
function Logger:error(msg) self:log("ERROR", msg) end
function Logger:success(msg) self:log("SUCCESS", msg) end

--// Notification System
local function notify(title, text, duration)
    duration = duration or 5
    local success = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Bloxstrap",
            Text = text or "",
            Duration = duration,
            Icon = ""
        })
    end)
    if not success then
        Logger:warn("Notification failed: " .. tostring(text))
    end
end

--// Safe HTTP Request with retries
local function safeHttpGet(url, nocache, retries)
    retries = retries or 0
    local success, result = pcall(function()
        return ExecutorAPI.gameHttpGet(url, nocache)
    end)
    if success then
        return result
    elseif retries < CONFIG.MaxRetries then
        Logger:warn(string.format("Retry %d/%d for %s", retries + 1, CONFIG.MaxRetries, url))
        task.wait(0.5 * (retries + 1))
        return safeHttpGet(url, nocache, retries + 1)
    else
        Logger:error("Failed to fetch after " .. CONFIG.MaxRetries .. " retries: " .. url)
        error("HTTP GET failed: " .. tostring(result))
    end
end

--// GitHub API Helper
local GitHubAPI = {}

function GitHubAPI:getRawUrl(path)
    return string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s",
        CONFIG.GitHubOwner, CONFIG.GitHubRepo, CONFIG.Branch, path)
end

function GitHubAPI:getApiUrl(path)
    return string.format("https://api.github.com/repos/%s/%s/contents/%s",
        CONFIG.GitHubOwner, CONFIG.GitHubRepo, path or "")
end

--// File Manager
local FileManager = {}

function FileManager:ensureFolders()
    local folders = {
        CONFIG.FolderName,
        CONFIG.FolderName .. "/Main",
        CONFIG.FolderName .. "/Main/Functions",
        CONFIG.FolderName .. "/Main/Configs",
        CONFIG.FolderName .. "/Main/Fonts",
        CONFIG.FolderName .. "/Images",
        CONFIG.FolderName .. "/Logs",
    }
    for _, folder in ipairs(folders) do
        if not ExecutorAPI.isfolder(folder) then
            pcall(ExecutorAPI.makefolder, folder)
            Logger:info("Created folder: " .. folder)
        end
    end
end

function FileManager:writeFile(path, content, isBinary)
    local success, err = pcall(function()
        ExecutorAPI.writefile(path, content)
    end)
    if success then
        Logger:info("Written file: " .. path .. " (" .. #content .. " bytes)")
        return true
    else
        Logger:error("Failed to write " .. path .. ": " .. tostring(err))
        return false
    end
end

function FileManager:readFile(path)
    if ExecutorAPI.isfile(path) then
        local success, content = pcall(ExecutorAPI.readfile, path)
        if success and content then
            return content
        end
    end
    return nil
end

function FileManager:listFiles(path)
    local success, files = pcall(ExecutorAPI.listfiles, path)
    if success and files then
        return files
    end
    return {}
end

function FileManager:fileExists(path)
    return ExecutorAPI.isfile(path)
end

function FileManager:folderExists(path)
    return ExecutorAPI.isfolder(path)
end

--// Cache System
local Cache = {
    data = {},
    timestamps = {},
}

function Cache:get(key, maxAge)
    maxAge = maxAge or CONFIG.CacheTimeout
    local timestamp = self.timestamps[key]
    if timestamp and (os.time() - timestamp) < maxAge then
        return self.data[key]
    end
    return nil
end

function Cache:set(key, value)
    self.data[key] = value
    self.timestamps[key] = os.time()
end

function Cache:invalidate(key)
    self.data[key] = nil
    self.timestamps[key] = nil
end

function Cache:clear()
    self.data = {}
    self.timestamps = {}
end

--// Version Manager
local VersionManager = {}

function VersionManager:getLocalVersion()
    return FileManager:readFile(CONFIG.VersionFile) or "0.0.0"
end

function VersionManager:setLocalVersion(version)
    FileManager:writeFile(CONFIG.VersionFile, version)
end

function VersionManager:needsUpdate()
    local localVer = self:getLocalVersion()
    -- Check if essential files are missing
    local essentialFiles = {
        CONFIG.FolderName .. "/Main/Bloxstrap.lua",
        CONFIG.FolderName .. "/Main/Functions/ToggleFFlag.lua",
        CONFIG.FolderName .. "/Main/Functions/GetFFlag.lua",
        CONFIG.FolderName .. "/Main/Functions/GuiLibrary.lua",
    }
    for _, file in ipairs(essentialFiles) do
        if not FileManager:fileExists(file) then
            Logger:warn("Missing essential file: " .. file)
            return true
        end
    end
    -- Check file count
    local files = FileManager:listFiles(CONFIG.FolderName)
    if #files <= 6 then
        return true
    end
    return false
end

--// Installer
local Installer = {}

function Installer:downloadFile(name, path, isBinary)
    local url = GitHubAPI:getRawUrl(path or name)
    local content = safeHttpGet(url, true)
    local filePath = CONFIG.FolderName .. "/" .. (path or name)
    return FileManager:writeFile(filePath, content, isBinary)
end

function Installer:downloadDirectory(apiPath, localPath)
    local url = GitHubAPI:getApiUrl(apiPath)
    local cached = Cache:get(url)
    local contents
    
    if cached then
        contents = cached
    else
        contents = safeHttpGet(url, true)
        Cache:set(url, contents)
    end
    
    local success, decoded = pcall(HttpService.JSONDecode, HttpService, contents)
    if not success then
        Logger:error("Failed to decode JSON from " .. url)
        return
    end
    
    for _, item in ipairs(decoded) do
        if item.type == "file" then
            local fileName = item.name
            local relativePath = localPath and (localPath .. "/" .. fileName) or fileName
            local isBinary = fileName:find("%.mp3$") or fileName:find("%.png$") or fileName:find("%.ttf$")
            
            if fileName:find("%.lua$") then
                local luaContent = string.format(
                    "return loadstring(game:HttpGet('https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s', true))()",
                    CONFIG.GitHubOwner, CONFIG.GitHubRepo, CONFIG.Branch, relativePath
                )
                FileManager:writeFile(CONFIG.FolderName .. "/" .. relativePath, luaContent)
            elseif isBinary then
                local binaryContent = safeHttpGet(GitHubAPI:getRawUrl(relativePath), true)
                FileManager:writeFile(CONFIG.FolderName .. "/" .. relativePath, binaryContent, true)
            end
        elseif item.type == "dir" then
            local newLocalPath = localPath and (localPath .. "/" .. item.name) or item.name
            local newApiPath = apiPath and (apiPath .. "/" .. item.name) or item.name
            self:downloadDirectory(newApiPath, newLocalPath)
        end
    end
end

function Installer:install(config)
    config = config or {}
    Logger:info("Starting installation...")
    notify("Bloxstrap", "Installing/Updating files...", 3)
    
    FileManager:ensureFolders()
    
    -- Download root files
    self:downloadDirectory("", nil)
    
    -- Download Main/Bloxstrap.lua specifically
    local bloxstrapContent = string.format(
        "return loadstring(game:HttpGet('https://raw.githubusercontent.com/%s/%s/refs/heads/%s/Main/Bloxstrap.lua', true))()",
        CONFIG.GitHubOwner, CONFIG.GitHubRepo, CONFIG.Branch
    )
    FileManager:writeFile(CONFIG.FolderName .. "/Main/Bloxstrap.lua", bloxstrapContent)
    
    -- Download Functions directory
    self:downloadDirectory("Main/Functions", "Main/Functions")
    
    -- Create default config if not exists
    if not FileManager:fileExists(CONFIG.FolderName .. "/Main/Configs/Default.json") then
        FileManager:writeFile(CONFIG.FolderName .. "/Main/Configs/Default.json", "{}")
    end
    
    -- Create empty FFlags.json if not exists
    if not FileManager:fileExists(CONFIG.FolderName .. "/FFlags.json") then
        FileManager:writeFile(CONFIG.FolderName .. "/FFlags.json", "[]")
    end
    
    -- Update version
    VersionManager:setLocalVersion(os.date("%Y.%m.%d.%H%M"))
    
    Logger:success("Installation completed!")
    notify("Bloxstrap", "Installation completed successfully!", 3)
end

--// Main Execution
local function main()
    Logger:info("Bloxstrap Enhanced Loader v2.0")
    Logger:info("Executor: " .. ExecutorAPI.getexecutorname())
    
    --// Hide UI option
    local hidegui = getgenv().hideui or getgenv().BloxstrapHideUI or false
    
    --// Check if needs installation
    local needsInstall = not FileManager:folderExists(CONFIG.FolderName) or VersionManager:needsUpdate()
    
    if needsInstall then
        local installSuccess = pcall(function()
            Installer:install({})
        end)
        if not installSuccess then
            Logger:error("Installation failed!")
            notify("Bloxstrap", "Installation failed! Check console for details.", 5)
            return
        end
    else
        Logger:info("Files up to date, skipping installation")
    end
    
    --// Load Bloxstrap
    local loadSuccess, Bloxstrap = pcall(function()
        return loadfile(CONFIG.FolderName .. "/Main/Bloxstrap.lua")()
    end)
    
    if not loadSuccess or not Bloxstrap then
        Logger:error("Failed to load Bloxstrap: " .. tostring(Bloxstrap))
        notify("Bloxstrap", "Failed to load! Reinstalling...", 3)
        
        -- Force reinstall
        pcall(function()
            if FileManager:folderExists(CONFIG.FolderName) then
                -- Clear cache and reinstall
                Cache:clear()
                Installer:install({})
                Bloxstrap = loadfile(CONFIG.FolderName .. "/Main/Bloxstrap.lua")()
            end
        end)
        
        if not Bloxstrap then
            notify("Bloxstrap", "Critical error! Please restart.", 5)
            return
        end
    end
    
    --// Start Bloxstrap
    local startSuccess, startError = pcall(function()
        Bloxstrap.start()
    end)
    
    if not startSuccess then
        Logger:error("Bloxstrap.start() failed: " .. tostring(startError))
        notify("Bloxstrap", "Failed to start UI!", 5)
        return
    end
    
    --// Set visibility
    local visSuccess = pcall(function()
        if Bloxstrap.Visible then
            Bloxstrap.Visible(not hidegui)
        end
    end)
    
    if visSuccess then
        Logger:success("Bloxstrap started successfully!")
        if not hidegui then
            notify("Bloxstrap", "Loaded successfully! Press the icon in the topbar to toggle.", 4)
        end
    else
        Logger:warn("Could not set visibility, UI might be hidden")
    end
    
    --// Expose to global
    getgenv().Bloxstrap = Bloxstrap
    getgenv().BloxstrapLoader = {
        Logger = Logger,
        Cache = Cache,
        VersionManager = VersionManager,
        FileManager = FileManager,
        CONFIG = CONFIG,
    }
end

--// Run with error handling
local success, errorMsg = pcall(main)
if not success then
    Logger:error("Critical error in main: " .. tostring(errorMsg))
    notify("Bloxstrap", "Critical Error: " .. tostring(errorMsg):sub(1, 50), 8)
end
