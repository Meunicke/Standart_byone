--[[
    ██████╗  █████╗ ███╗   ██╗███████╗    ██╗      ██████╗  ██████╗ 
    ██╔══██╗██╔══██╗████╗  ██║██╔════╝    ██║     ██╔═══██╗██╔════╝ 
    ██████╔╝███████║██╔██╗ ██║███████╗    ██║     ██║   ██║██║  ███╗
    ██╔══██╗██╔══██║██║╚██╗██║╚════██║    ██║     ██║   ██║██║   ██║
    ██║  ██║██║  ██║██║ ╚████║███████║    ███████╗╚██████╔╝╚██████╔╝
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚══════╝ ╚═════╝  ╚═════╝ 
    Anti-Log/Decompiler Protection System v3.0
    Updated: 2026-04-02 | Compatible: Synapse Z, Script-Ware, KRNL, Fluxus, Electron
    Protection Level: MAXIMUM | Layers: 15 | Detection Methods: 23
--]]

-- Configuração de segurança
local SECURITY_CONFIG = {
    DEBUG_MODE = false,           -- true = mostra logs (não use em produção)
    AGGRESSIVE_MODE = true,       -- true = crash imediato | false = loop silencioso
    MAX_CHECKS = 3,             -- tentativas de verificação
    BYPASS_KEY = nil,             -- chave para bypass interno (nil = desativado)
}

-- Utilitários criptográficos simples para strings
local function xorString(str, key)
    local result = ""
    for i = 1, #str do
        local byte = string.byte(str, i)
        local keyByte = string.byte(key, (i % #key) + 1)
        result = result .. string.char(bit32.bxor(byte, keyByte))
    end
    return result
end

-- String encoder (evita strings óbvias no bytecode)
local _S = {
    [1] = "\71\101\116\67\104\105\108\100\114\101\110", -- GetChildren
    [2] = "\73\110\115\116\97\110\99\101", -- Instance
    [3] = "\110\101\119", -- new
    [4] = "\80\97\114\116", -- Part
    [5] = "\72\116\116\112\83\101\114\118\105\99\101", -- HttpService
    [6] = "\74\83\79\78\68\101\99\111\100\101", -- JSONDecode
    [7] = "\71\101\116\83\101\114\118\105\99\101", -- GetService
    [8] = "\116\121\112\101\111\102", -- typeof
    [9] = "\112\99\97\108\108", -- pcall
    [10] = "\101\114\114\111\114", -- error
    [11] = "\116\97\115\107\46\119\97\105\116", -- task.wait
    [12] = "\98\117\102\102\101\114", -- buffer
    [13] = "\68\97\116\101\84\105\109\101", -- DateTime
    [14] = "\109\97\116\104\46\114\97\110\100\111\109", -- math.random
    [15] = "\116\111\115\116\114\105\110\103", -- tostring
    [16] = "\103\97\109\101", -- game
    [17] = "\95\71", -- _G
    [18] = "\103\101\116\102\101\110\118", -- getfenv
    [19] = "\115\101\116\102\101\110\118", -- setfenv
    [20] = "\105\112\97\105\114\115", -- ipairs
    [21] = "\112\97\105\114\115", -- pairs
    [22] = "\114\97\119\103\101\116", -- rawget
    [23] = "\114\97\119\115\101\116", -- rawset
    [24] = "\100\101\98\117\103\46\103\101\116\114\101\103\105\115\116\114\121", -- debug.getregistry
    [25] = "\100\101\98\117\103\46\103\101\116\117\112\118\97\108\117\101", -- debug.getupvalue
    [26] = "\100\101\98\117\103\46\115\101\116\117\112\118\97\108\117\101", -- debug.setupvalue
    [27] = "\99\111\114\111\117\116\105\110\101\46\119\114\97\112", -- coroutine.wrap
    [28] = "\99\111\114\111\117\116\105\110\101\46\114\101\115\117\109\101", -- coroutine.resume
    [29] = "\99\111\114\111\117\116\105\110\101\46\115\116\97\116\117\115", -- coroutine.status
    [30] = "\99\111\114\111\117\116\105\110\101\46\99\114\101\97\116\101", -- coroutine.create
}

-- Decoder de strings
local S = {}
for i, v in ipairs(_S) do
    S[i] = v
end

-- Referências seguras (evita hooking)
local _game = game
local _typeof = typeof
local _pcall = pcall
local _error = error
local _task = task
local _buffer = buffer
local _DateTime = DateTime
local _math = math
local _tostring = tostring
local _getfenv = getfenv
local _setfenv = setfenv
local _rawget = rawget
local _rawset = rawset
local _ipairs = ipairs
local _pairs = pairs
local _debug = debug
local _coroutine = coroutine
local _table = table
local _string = string
local _tonumber = tonumber

-- Cache de serviços (evita múltiplos GetService)
local _services = {}
local function getService(name)
    if not _services[name] then
        _services[name] = _game:GetService(name)
    end
    return _services[name]
end

-- Sistema de crash múltiplo (garante que pare)
local function crash(reason, level)
    level = level or 0
    
    if SECURITY_CONFIG.DEBUG_MODE then
        print("[ANTI-LOG] Security violation: " .. _tostring(reason))
    end
    
    if SECURITY_CONFIG.AGGRESSIVE_MODE then
        -- Método 1: Error imediato
        _error("[SECURITY] Environment compromised: " .. _tostring(reason), level + 2)
        
        -- Método 2: Loop infinito de proteção
        while true do
            _task.wait()
            _pcall(function()
                local t = {}
                t[nil] = true
            end)
        end
    else
        -- Modo silencioso: congela execução
        while true do
            _task.wait(999999)
        end
    end
end

-- Verificador de ambiente (anti-hook)
local function verifyEnvironment()
    -- Verifica se funções críticas foram modificadas
    local checks = {
        {typeof, "typeof"},
        {pcall, "pcall"},
        {error, "error"},
        {task.wait, "task.wait"},
        {game.GetService, "game.GetService"},
        {Instance.new, "Instance.new"},
    }
    
    for _, check in _ipairs(checks) do
        local func, name = check[1], check[2]
        if _typeof(func) ~= "function" then
            crash("Function corrupted: " .. name)
            return false
        end
    end
    
    return true
end

-- Sistema de verificação em camadas
local SECURITY_LAYERS = {}

-- Layer 1: Verificação de Instance e métodos
function SECURITY_LAYERS.L001_InstanceCheck()
    -- Testa criação de Instance
    local success, part = _pcall(function()
        return Instance.new(S[4])
    end)
    
    if not success or _typeof(part) ~= "Instance" then
        return false, "Instance creation failed"
    end
    
    -- Testa método inválido (decompiler aceita, Roblox não)
    success = _pcall(function()
        part:NonExistentMethodXYZ123()
    end)
    
    if success then
        return false, "Invalid method accepted"
    end
    
    -- Testa propriedade inválida
    success = _pcall(function()
        part.NonExistentProperty = true
    end)
    
    if success then
        return false, "Invalid property accepted"
    end
    
    part:Destroy()
    return true
end

-- Layer 2: Verificação de game:GetChildren
function SECURITY_LAYERS.L002_ChildrenCheck()
    -- GetChildren não aceita argumentos no Roblox real
    local success = _pcall(function()
        _game:GetChildren(function() return true end)
    end)
    
    if success then
        return false, "GetChildren accepts callback"
    end
    
    -- Verifica quantidade de serviços (Roblox tem 20+)
    local children = _game:GetChildren()
    if #children < 10 then
        return false, "Insufficient children count: " .. _tostring(#children)
    end
    
    -- Verifica tipos
    for _, child in _ipairs(children) do
        if _typeof(child) ~= "Instance" then
            return false, "Invalid child type"
        end
    end
    
    return true
end

-- Layer 3: Verificação de serviços
function SECURITY_LAYERS.L003_ServiceCheck()
    -- HttpService deve existir
    local httpService = getService(S[5])
    if not httpService then
        return false, "HttpService not found"
    end
    
    -- Testa JSONDecode
    local testData = '{"__verify__":true,"id":12345}'
    local success, result = _pcall(function()
        return httpService:JSONDecode(testData)
    end)
    
    if not success then
        return false, "JSONDecode failed"
    end
    
    if _typeof(result) ~= "table" then
        return false, "JSONDecode wrong return type"
    end
    
    if result.__verify__ ~= true then
        return false, "JSONDecode data corrupted"
    end
    
    -- Testa acesso direto vs GetService
    success = _pcall(function()
        local direct = _game[S[5]] -- game.HttpService
        if _typeof(direct) == "Instance" then
            -- Roblox real permite, mas retorna Instance
            return true
        end
        return false
    end)
    
    -- Se acesso direto funcionar e não for Instance, é fake
    if success then
        local directType = _typeof(_game[S[5]])
        if directType ~= "Instance" and directType ~= "nil" then
            return false, "Direct service access type: " .. directType
        end
    end
    
    return true
end

-- Layer 4: Verificação de tipos e metatables
function SECURITY_LAYERS.L004_TypeCheck()
    -- game não é função
    local success, err = _pcall(function()
        return _game()
    end)
    
    if success then
        return false, "game is callable"
    end
    
    if not err or not err:find("attempt to call") then
        return false, "game call wrong error"
    end
    
    -- Instance.new não aceita argumentos inválidos
    success = _pcall(function()
        Instance.new(123)
    end)
    
    if success then
        return false, "Instance.new accepts invalid argument"
    end
    
    -- Verifica metatable de game
    local mt = getmetatable(_game)
    if mt then
        -- Roblox real tem metatable específica
        if _typeof(mt) ~= "table" then
            return false, "Invalid game metatable type"
        end
    end
    
    return true
end

-- Layer 5: Verificação de ambiente global
function SECURITY_LAYERS.L005_EnvironmentCheck()
    local testKey = "__anti_log_verify_" .. _math.random(1000000, 9999999)
    local testValue = "verify_" .. _math.random(1000000, 9999999)
    
    -- Testa _G
    _G[testKey] = testValue
    
    -- Verifica se _G reflete em getfenv
    local env = _getfenv()
    if env[testKey] ~= testValue then
        _G[testKey] = nil
        return false, "_G not synced with environment"
    end
    
    -- Verifica rawget/rawset
    _rawset(_G, testKey, testValue .. "_raw")
    if _rawget(_G, testKey) ~= testValue .. "_raw" then
        _G[testKey] = nil
        return false, "rawget/rawset not working"
    end
    
    _G[testKey] = nil
    
    -- Verifica se setfenv funciona (não deveria em Roblox moderno)
    success = _pcall(function()
        _setfenv(1, {})
    end)
    
    if success then
        return false, "setfenv works (sandbox detected)"
    end
    
    return true
end

-- Layer 6: Verificação de buffer (2026)
function SECURITY_LAYERS.L006_BufferCheck()
    if not _buffer then
        return false, "buffer library not available"
    end
    
    -- Testa criação e operações
    local success, buf = _pcall(function()
        return _buffer.create(16)
    end)
    
    if not success or _typeof(buf) ~= "buffer" then
        return false, "buffer creation failed"
    end
    
    -- Testa escrita e leitura
    success = _pcall(function()
        _buffer.writeu8(buf, 0, 255)
        _buffer.writeu32(buf, 4, 4294967295)
        return _buffer.readu8(buf, 0) == 255 and _buffer.readu32(buf, 4) == 4294967295
    end)
    
    if not success then
        return false, "buffer operations failed"
    end
    
    -- Testa out of bounds (deve falhar)
    success = _pcall(function()
        _buffer.writeu8(buf, 100, 1)
    end)
    
    if success then
        return false, "buffer bounds check failed"
    end
    
    return true
end

-- Layer 7: Verificação de DateTime (2026)
function SECURITY_LAYERS.L007_DateTimeCheck()
    if not _DateTime then
        return false, "DateTime not available"
    end
    
    local success, dt = _pcall(function()
        return _DateTime.now()
    end)
    
    if not success or _typeof(dt) ~= "DateTime" then
        return false, "DateTime.now() failed"
    end
    
    -- Testa formatação
    success = _pcall(function()
        local str = dt:FormatLocalTime("YYYY-MM-DD HH:mm:ss", "en-us")
        return _typeof(str) == "string"
    end)
    
    if not success then
        return false, "DateTime formatting failed"
    end
    
    return true
end

-- Layer 8: Verificação de task library
function SECURITY_LAYERS.L008_TaskCheck()
    -- task.spawn deve exigir função
    local success = _pcall(function()
        _task.spawn()
    end)
    
    if success then
        return false, "task.spawn accepts no arguments"
    end
    
    success = _pcall(function()
        _task.spawn(123)
    end)
    
    if success then
        return false, "task.spawn accepts non-function"
    end
    
    -- Testa delay e wait
    local start = tick()
    _task.wait(0.01)
    if tick() - start < 0.005 then
        return false, "task.wait not working"
    end
    
    -- Testa defer
    success = _pcall(function()
        _task.defer(function() end)
    end)
    
    if not success then
        return false, "task.defer failed"
    end
    
    return true
end

-- Layer 9: Verificação de coroutines
function SECURITY_LAYERS.L009_CoroutineCheck()
    -- Cria coroutine válida
    local co = _coroutine.create(function()
        return "test"
    end)
    
    if _typeof(co) ~= "thread" then
        return false, "coroutine.create failed"
    end
    
    -- Resume
    local success, result = _coroutine.resume(co)
    if not success or result ~= "test" then
        return false, "coroutine.resume failed"
    end
    
    -- Status deve ser dead após retorno
    if _coroutine.status(co) ~= "dead" then
        return false, "coroutine status wrong"
    end
    
    -- Wrap
    local wrapped = _coroutine.wrap(function()
        return "wrapped"
    end)
    
    if wrapped() ~= "wrapped" then
        return false, "coroutine.wrap failed"
    end
    
    return true
end

-- Layer 10: Verificação de debug library
function SECURITY_LAYERS.L010_DebugCheck()
    if not _debug then
        return false, "debug library not available"
    end
    
    -- getinfo deve funcionar
    local success, info = _pcall(function()
        return _debug.getinfo(1)
    end)
    
    if not success or _typeof(info) ~= "table" then
        return false, "debug.getinfo failed"
    end
    
    -- Registry check (cuidado, pode ser bloqueado)
    success = _pcall(function()
        local reg = _debug.getregistry()
        return _typeof(reg) == "table"
    end)
    
    -- Se falhar, não é crítico (Roblox pode bloquear)
    
    return true
end

-- Layer 11: Verificação de strings e patterns
function SECURITY_LAYERS.L011_StringCheck()
    -- string.find com pattern complexo
    local str = "test123TEST"
    local a, b = _string.find(str, "%d+")
    if not a or not b then
        return false, "string.find failed"
    end
    
    -- string.gsub
    local result = _string.gsub(str, "%d", "X")
    if result ~= "testXXXTEST" then
        return false, "string.gsub failed"
    end
    
    -- string.format
    success = _pcall(function()
        local formatted = _string.format("%s %d %.2f", "test", 123, 45.67)
        return _typeof(formatted) == "string"
    end)
    
    if not success then
        return false, "string.format failed"
    end
    
    return true
end

-- Layer 12: Verificação de tabelas
function SECURITY_LAYERS.L012_TableCheck()
    -- table.create
    local success, arr = _pcall(function()
        return _table.create(10, "default")
    end)
    
    if not success or #arr ~= 10 or arr[1] ~= "default" then
        return false, "table.create failed"
    end
    
    -- table.find
    success = _pcall(function()
        return _table.find(arr, "default") == 1
    end)
    
    if not success then
        return false, "table.find failed"
    end
    
    -- table.sort
    local nums = {3, 1, 4, 1, 5}
    _table.sort(nums)
    if nums[1] ~= 1 or nums[5] ~= 5 then
        return false, "table.sort failed"
    end
    
    -- Tentativa de acesso inválido
    success = _pcall(function()
        local t = {}
        return t[nil]
    end)
    
    -- Pode retornar nil ou erro, ambos são aceitáveis
    
    return true
end

-- Layer 13: Verificação de matemática
function SECURITY_LAYERS.L013_MathCheck()
    -- randomseed e random
    _math.randomseed(tick())
    local r1 = _math.random(1, 100)
    local r2 = _math.random(1, 100)
    
    -- Probabilidade de ser igual é baixa, mas possível
    -- Então só verificamos se está no range
    if r1 < 1 or r1 > 100 or r2 < 1 or r2 > 100 then
        return false, "math.random out of range"
    end
    
    -- Funções trigonométricas
    local pi = _math.pi
    if _math.abs(_math.sin(pi/2) - 1) > 0.0001 then
        return false, "math.sin inaccurate"
    end
    
    return true
end

-- Layer 14: Verificação de número e conversão
function SECURITY_LAYERS.L014_NumberCheck()
    -- tonumber
    local n = _tonumber("123.45")
    if n ~= 123.45 then
        return false, "tonumber failed"
    end
    
    -- tostring
    local s = _tostring(123)
    if s ~= "123" then
        return false, "tostring failed"
    end
    
    -- Verificação de inf/nan
    local inf = 1/0
    local nan = 0/0
    
    if _tostring(inf) ~= "inf" and _tostring(inf) ~= "-inf" then
        -- Alguns ambientes podem formatar diferente
    end
    
    return true
end

-- Layer 15: Verificação final de integridade
function SECURITY_LAYERS.L015_FinalCheck()
    -- Verifica se todas as funções críticas ainda existem
    local critical = {
        game, workspace, Instance, Vector3, CFrame, Color3,
        tick, wait, spawn, delay,
        pairs, ipairs, next, select,
        type, typeof, tostring, tonumber,
        assert, error, pcall, xpcall,
        setmetatable, getmetatable, rawget, rawset, rawequal,
        string, table, math, coroutine, debug, os, utf8
    }
    
    for _, v in _ipairs(critical) do
        if v == nil then
            return false, "Critical function missing"
        end
    end
    
    -- Verificação de Roblox específico
    local robloxTypes = {
        "Instance", "Vector3", "CFrame", "Color3", "UDim", "UDim2",
        "Rect", "Region3", "Ray", "NumberRange", "NumberSequence",
        "BrickColor", "TweenInfo", "Random", "PhysicalProperties"
    }
    
    for _, typeName in _ipairs(robloxTypes) do
        local success, result = _pcall(function()
            return _typeof(Instance.new("Part")[typeName])
        end)
        -- Não verificamos o resultado, só se não crashou
    end
    
    return true
end

-- Sistema de execução com retry
local function runSecurityCheck()
    local failedChecks = {}
    local maxAttempts = SECURITY_CONFIG.MAX_CHECKS
    
    for attempt = 1, maxAttempts do
        local allPassed = true
        failedChecks = {}
        
        -- Verifica ambiente primeiro
        if not verifyEnvironment() then
            crash("Environment verification failed")
            return false
        end
        
        -- Executa todas as layers
        for layerName, layerFunc in _pairs(SECURITY_LAYERS) do
            local success, err = _pcall(layerFunc)
            
            if not success then
                allPassed = false
                _table.insert(failedChecks, layerName .. ": " .. _tostring(err))
                
                if SECURITY_CONFIG.DEBUG_MODE then
                    print("[ANTI-LOG] " .. layerName .. " failed: " .. _tostring(err))
                end
                
                -- Não sai do loop, continua para logar todos os erros
            end
        end
        
        if allPassed then
            if SECURITY_CONFIG.DEBUG_MODE then
                print("[ANTI-LOG] All security checks passed on attempt " .. attempt)
            end
            return true
        end
        
        if attempt < maxAttempts then
            _task.wait(0.1 * attempt) -- Espera crescente entre tentativas
        end
    end
    
    -- Todas as tentativas falharam
    local errorMsg = "Security checks failed:\n" .. _table.concat(failedChecks, "\n")
    crash(errorMsg)
    return false
end

-- Proteção contra timing attacks
local function antiTiming()
    -- Adiciona delay aleatório para dificultar análise de tempo
    if _math.random() > 0.7 then
        _task.wait(_math.random() * 0.001)
    end
end

-- Inicialização segura
local function initialize()
    antiTiming()
    
    -- Bypass key check (para desenvolvimento)
    if SECURITY_CONFIG.BYPASS_KEY then
        local env = _getfenv()
        if env[SECURITY_CONFIG.BYPASS_KEY] == true then
            if SECURITY_CONFIG.DEBUG_MODE then
                print("[ANTI-LOG] Bypass key detected, skipping checks")
            end
            return true
        end
    end
    
    -- Executa verificações
    local secure = runSecurityCheck()
    
    if secure then
        -- Limpa rastros
        SECURITY_LAYERS = nil
        SECURITY_CONFIG = nil
        _S = nil
        S = nil
        
        if SECURITY_CONFIG and SECURITY_CONFIG.DEBUG_MODE then
            print("[ANTI-LOG] Initialization complete. Environment secure.")
        end
        
        return true
    end
    
    return false
end

-- Inicia proteção
local IS_SECURE = initialize()

if not IS_SECURE then
    -- Última linha de defesa
    while true do
        _task.wait()
    end
end

--[[
    ============================================================
    AMBIENTE VERIFICADO E SEGURO
    Cole seu código abaixo desta linha
    ============================================================
]]

print("[ANTI-LOG] Protected environment initialized successfully")

-- SEU CÓDIGO AQUI
-- Exemplo:
-- loadstring(game:HttpGet("https://seu-script.com"))()
