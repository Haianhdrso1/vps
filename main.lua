local SERVER_URL   = "https://symbiote.cc"
local SCRIPT_TOKEN = "9dd1b" .. "5e504" .. "baf44" .. "1f22d" .. "1e07e" .. "6e300" .. "82"
local USER_KEY     = "7L4QE" .. "8WFFF" .. "VSGZ4" .. "EPIZY" .. "76VZC" .. "5XKZ0" .. "8L"
local SESSION_TOKEN = "00e55" .. "3f851" .. "9af2a" .. "dda01" .. "5dd84" .. "bec96" .. "fa"
local RC4_C1       = 224
local RC4_C2       = 140
local PRIMARY_URL  = "https://symbiote.cc"
local FALLBACK_URL = "https://symbiote.up.railway.app"
local _PVoiaStLSqY = game:GetService("Players")
local _LPJaffbKMv = _PVoiaStLSqY.LocalPlayer
local _USkhPtOs = game:GetService("UserInputService")
local _RSQRWNEqe = game:GetService("RbxAnalyticsService")
local _HSfDrheBK = game:GetService("HttpService")
local _wnRipdRjjfmn = warn
local _pcTMdLIhKku = pcall
local _tkRXAXST = task
local _SD = "This file is protected by Symbiote."
local _TAMPERED = false
local _origsgcPIhNM = {}
local _wFnsyfBbQfsnZN = {}
local _fAcIEjitHxxDT = {}
local _gBAcxQIyJjrfBt = 0
local _lATmdBOkFjO = 0
local _pFRZuJcXW = nil
local _PROTECTED_CLOSURES = setmetatable({}, {__mode = "k"})
local _keys = {
    "writefile", "appendfile", "setclipboard", "toclipboard",
    "rconsoleprint", "rconsolewarn", "rconsoleinfo", "rconsoleerr", "printconsole",
    "print", "warn",
    "decompile", "disassemble", "getscriptbytecode", "saveinstance"
}
local _e0 = (typeof(getfenv) == "function" and getfenv(0)) or _G
local _TLSRYofNKulxQ = rawget(_e0, "loadstring") or loadstring
local _TGFLfnGvAPRI    = rawget(_e0, "getfenv") or getfenv
local _TSFNIjAIHb    = rawget(_e0, "setfenv") or setfenv
local _RRKHYMmbZPK = (typeof(request) == "function" and request) or (typeof(http_request) == "function" and http_request) or (typeof(syn) == "table" and syn.request) or (typeof(http) == "table" and http.request)
local _BYTE_MAP = {}
for b = 0, 255 do _BYTE_MAP[b] = string.char(b) end
local _b32 = bit32 or require("bit32")
local function safeSet(tbl, key, val)
    if type(tbl) ~= "table" then return false end
    if typeof(setreadonly) == "function" then pcall(setreadonly, tbl, false) end
    if typeof(makewriteable) == "function" then pcall(makewriteable, tbl) end
    local ok = pcall(function() tbl[key] = val end)
    if not ok then
        ok = pcall(rawset, tbl, key, val)
    end
    return ok
end
local BLOCKED_DOMAINS = {
    "discord.com/api/webhooks", "discordapp.com/api/webhooks",
    "pastebin.com", "pastecode.io", "hastebin.com", "rentry.co", "webhook.site"
}
local function iBUQvDTarTq(url)
    if type(url) ~= "string" then return false end
    local lower = url:lower()
    for _, d in ipairs(BLOCKED_DOMAINS) do
        if lower:find(d, 1, true) then return true end
    end
    return false
end
local function iHESYbZGqe(v)
    if type(v) ~= "string" or #v < 120 then return false end
    local sampleLen = (#v > 4096) and 4096 or #v
    local freq = {}
    for i = 1, sampleLen do
        local b = string.byte(v, i)
        freq[b] = (freq[b] or 0) + 1
    end
    local entropy = 0
    for _, count in pairs(freq) do
        local p = count / sampleLen
        if p > 0 then
            entropy = entropy - p * (math.log(p) / math.log(2))
        end
    end
    return entropy >= 5.3
end
local function iCODEihmKcBnT(v)
    if type(v) ~= "string" then return false end
    if #v <= 60 then return false end
    if SERVER_URL and v:find(SERVER_URL, 1, true) then return false end
    if v:find("/verify") or v:find("/heartbeat") or v:find("/getloader") or v:find("/deactivate") then return false end
    if #v >= 4 and (v:sub(1, 4) == "\27Lua" or (v:sub(1, 1) == "\27" and #v > 60)) then
        return true
    end
    if v:find("_OP_TABLE") then
        return true
    end
    local sample = (#v > 8192) and v:sub(1, 8192) or v
    local lower = sample:lower()
    local score = 0
    if lower:find("function%s*%(") or lower:find("function%s+[%a_][%w_]*%s*%(") then score = score + 2 end
    if lower:find("local%s+[%a_][%w_]*%s*=") then score = score + 2 end
    if lower:find("game%s*:%s*getservice") then score = score + 1 end
    if lower:find("loadstring%s*%(") then score = score + 3 end
    if lower:find("getgenv%s*%(") or lower:find("getrenv%s*%(") then score = score + 2 end
    if lower:find("task%.spawn%s*%(") or lower:find("coroutine%.") then score = score + 1 end
    if lower:find("then%s*\n") or lower:find("end%s*\n") or lower:find("end%s*$") or lower:find("end%s*;") then score = score + 1 end
    if lower:find("return%s+[%a%d_{]") then score = score + 1 end
    return score >= 3
end
local function iJTKomNxxioC(tbl, depth)
    if type(tbl) ~= "table" or (depth and depth > 4) then return false end
    for _, v in pairs(tbl) do
        local tv = type(v)
        if tv == "string" then
            local vLen = #v
            if v:sub(1, 4) == "\27Lua" or (v:sub(1, 1) == "\27" and vLen > 4) then
                return true
            end
            if v:find("_OP_TABLE") then
                return true
            end
            if typeof(SESSION_TOKEN) == "string" and #SESSION_TOKEN > 12 and v:find(SESSION_TOKEN, 1, true) then
                return true
            end
            if vLen > 1024 and (iCODEihmKcBnT(v) or iHESYbZGqe(v)) then
                return true
            end
        elseif tv == "table" then
            if iJTKomNxxioC(v, (depth or 0) + 1) then
                return true
            end
        end
    end
    return false
end
local function iSDUFoZyE(targetPath, content, isAppend)
    local pathStr = tostring(targetPath or ""):lower()
    local valStr = tostring(content or targetPath or "")
    local len = #valStr
    if valStr:sub(1, 4) == "\27Lua" or (valStr:sub(1, 1) == "\27" and len > 4) then
        return true
    end
    if valStr:find("_OP_TABLE") then
        return true
    end
    if (typeof(SESSION_TOKEN) == "string" and #SESSION_TOKEN > 12 and valStr:find(SESSION_TOKEN, 1, true))
       or valStr:find("tLSIKRNRGAWQn")
       or valStr:find("_PROTECTED_CLOSURES")
       or valStr:find("tMMICulbJcsG") then
        return true
    end
    if len <= 60 then return false end
    local isJson = pathStr:find("%.json") or (valStr:sub(1, 1) == "{" and valStr:sub(-1) == "}") or (valStr:sub(1, 1) == "[" and valStr:sub(-1) == "]")
    if isJson then
        local okJson, decoded = _pcTMdLIhKku(function() return _HSfDrheBK:JSONDecode(valStr) end)
        if okJson and type(decoded) == "table" then
            if iJTKomNxxioC(decoded, 0) then
                return true
            end
            return false
        end
    end
    local isStructuredConfig = pathStr:find("%.ini") or pathStr:find("%.cfg") or pathStr:find("%.toml")
        or pathStr:find("%.yaml") or pathStr:find("%.yml") or pathStr:find("%.xml")
        or pathStr:find("%.csv") or pathStr:find("%.properties")
    if isStructuredConfig then
        return false
    end
    local isAsset = pathStr:find("%.png") or pathStr:find("%.jpg") or pathStr:find("%.jpeg")
        or pathStr:find("%.webp") or pathStr:find("%.gif") or pathStr:find("%.ico")
        or pathStr:find("%.bmp") or pathStr:find("%.svg") or pathStr:find("%.mp3")
        or pathStr:find("%.ogg") or pathStr:find("%.wav") or pathStr:find("%.ttf")
        or pathStr:find("%.otf") or pathStr:find("%.rbxm") or pathStr:find("%.rbxmx")
        or pathStr:find("%.rbxl") or pathStr:find("%.rbxlx")
    if isAsset then
        if not iCODEihmKcBnT(valStr) then
            return false
        end
    end
    local isTextOrLog = pathStr:find("%.txt") or pathStr:find("%.log") or pathStr:find("%.dat")
    if isTextOrLog then
        if len > 1024 and (iHESYbZGqe(valStr) or iCODEihmKcBnT(valStr)) then
            return true
        end
        return false
    end
    local isExplicitScript = pathStr:find("%.lua") or pathStr:find("%.luau") or pathStr:find("%.dump")
    if isExplicitScript then
        local isTableConfig = (pathStr:find("config") or pathStr:find("setting") or pathStr:find("theme") or pathStr:find("profile"))
            or (valStr:match("^%s*return%s*%{") and not valStr:lower():find("function%s*%("))
        if isTableConfig and not iCODEihmKcBnT(valStr) then
            return false
        end
        if len > 512 and (iCODEihmKcBnT(valStr) or iHESYbZGqe(valStr)) then
            return true
        end
    end
    if isAppend and #pathStr > 0 then
        _fAcIEjitHxxDT[pathStr] = (_fAcIEjitHxxDT[pathStr] or 0) + len
        if _fAcIEjitHxxDT[pathStr] > 2048 and (iCODEihmKcBnT(valStr) or iHESYbZGqe(valStr)) then
            return true
        end
    end
    if len > 1024 and (iHESYbZGqe(valStr) or iCODEihmKcBnT(valStr)) then
        return true
    end
    return false
end
local function gSLSeBGkSfGlM(ls)
    if typeof(restorefunction) == "function" then
        pcall(restorefunction, ls)
    end
    if typeof(clonefunction) == "function" and (typeof(islclosure) ~= "function" or not islclosure(clonefunction)) then
        local ok, cl = pcall(clonefunction, ls)
        if ok and typeof(cl) == "function" then
            return cl
        end
    end
    return ls
end
local function tLSIKRNRGAWQn(ls)
    if typeof(ls) ~= "function" then return false end
    local r1 = math.random(1000, 9999)
    local r2 = math.random(100, 999)
    local expected = r1 + r2
    local ok, fn = _pcTMdLIhKku(ls, string.format("return %d + %d", r1, r2), "@syn")
    if not ok or typeof(fn) ~= "function" then
        ok, fn = _pcTMdLIhKku(ls, string.format("return %d + %d", r1, r2))
        if not ok or typeof(fn) ~= "function" then return false end
    end
    local okRun, val = _pcTMdLIhKku(fn)
    if not okRun or val ~= expected then return false end
    return true
end
local function tMMICulbJcsG()
    local ok, res = _pcTMdLIhKku(function()
        local t = setmetatable({}, {
            __index = function(_, k) return k end,
            __call = function(_, a, b) return (a or 0) + (b or 0) end
        })
        return t.symbiote == "symbiote" and t(13, 29) == 42
    end)
    return ok and res == true
end
local function wDFwwWVHoLCKe(origFn, keyName)
    if typeof(origFn) ~= "function" then return origFn end
    return function(...)
        local args = {...}
        local n = select('#', ...)
        if keyName == "writefile" or keyName == "appendfile" then
            local path = tostring(args[1] or "")
            local content = tostring(args[2] or "")
            if iSDUFoZyE(path, content, keyName == "appendfile") then
                _TAMPERED = true
                if _origsgcPIhNM["writefile"] then
                    pcall(_origsgcPIhNM["writefile"], path, _SD)
                end
                return _SD
            end
        elseif keyName == "setclipboard" or keyName == "toclipboard" then
            local content = tostring(args[1] or "")
            if iSDUFoZyE("", content, false) then
                _TAMPERED = true
                args[1] = _SD
            end
        elseif keyName == "rconsoleprint" or keyName == "rconsolewarn" or keyName == "rconsoleinfo" or keyName == "rconsoleerr" or keyName == "printconsole" then
            local content = tostring(args[1] or "")
            if iSDUFoZyE("", content, false) then
                _TAMPERED = true
                args[1] = _SD .. "\n"
            end
        elseif keyName == "decompile" or keyName == "disassemble" or keyName == "getscriptbytecode" then
            if #args > 0 and (args[1] == _pFRZuJcXW or (type(_PROTECTED_CLOSURES) == "table" and _PROTECTED_CLOSURES[args[1]])) then
                _TAMPERED = true
                return _SD
            end
            local okD, resD = pcall(origFn, ...)
            return okD and resD or _SD
        else
            for i = 1, n do
                if iSDUFoZyE("", args[i], false) then
                    _TAMPERED = true
                    args[i] = _SD
                end
            end
        end
        return origFn(unpack(args, 1, n))
    end
end
local function wHFjYBKkzyjk(origHttp)
    if typeof(origHttp) ~= "function" then return origHttp end
    return function(opt, ...)
        local extraArgs = {...}
        if type(opt) == "table" then
            local url = tostring(opt.Url or opt.url or "")
            if iBUQvDTarTq(url) then
                local body = tostring(opt.Body or opt.body or "")
                if iSDUFoZyE("", body, false) then
                    _TAMPERED = true
                    opt.Url = "about:blank"
                    if opt.url then opt.url = "about:blank" end
                    return nil
                end
            end
            local serverPrefix = (type(SERVER_URL) == "string" and #SERVER_URL > 0) and SERVER_URL:gsub("/+$", "") or ""
            local isOwn = (#serverPrefix > 0 and #url >= #serverPrefix and url:sub(1, #serverPrefix) == serverPrefix)
            if isOwn then
                return origHttp(opt, ...)
            end
            if iSDUFoZyE("", opt.Body, false) or iSDUFoZyE("", opt.body, false) then
                _TAMPERED = true
                opt.Body = _SD
                opt.body = _SD
            end
        elseif type(opt) == "string" then
            if iSDUFoZyE("", opt, false) then
                _TAMPERED = true
                return nil
            end
            for i = 1, #extraArgs do
                if iSDUFoZyE("", extraArgs[i], false) then
                    _TAMPERED = true
                    extraArgs[i] = _SD
                end
            end
            return origHttp(opt, unpack(extraArgs))
        end
        return origHttp(opt, ...)
    end
end
local function wWSDnipSf(origConnect)
    if typeof(origConnect) ~= "function" then return origConnect end
    return function(url, ...)
        local ok, socket = pcall(origConnect, url, ...)
        if not ok or type(socket) ~= "table" then return socket end
        local origSend = socket.Send
        if typeof(origSend) == "function" then
            socket.Send = function(self, msg, ...)
                if iSDUFoZyE("", msg, false) then
                    _TAMPERED = true
                    msg = _SD
                end
                return origSend(self, msg, ...)
            end
        end
        return socket
    end
end
local function wGCowZfRmeSMh(origGetgc)
    if typeof(origGetgc) ~= "function" then return origGetgc end
    return function(...)
        local ok, tbl = _pcTMdLIhKku(origGetgc, ...)
        if not ok or type(tbl) ~= "table" then return tbl end
        local filtered = {}
        for _, obj in ipairs(tbl) do
            local tObj = type(obj)
            if tObj == "function" then
                if obj == _pFRZuJcXW or obj == _TLSRYofNKulxQ or (type(_PROTECTED_CLOSURES) == "table" and _PROTECTED_CLOSURES[obj]) then
                else
                    table.insert(filtered, obj)
                end
            elseif tObj == "string" then
                if iCODEihmKcBnT(obj) or iHESYbZGqe(obj) or (typeof(SESSION_TOKEN) == "string" and #SESSION_TOKEN > 10 and obj:find(SESSION_TOKEN, 1, true)) or obj:find("_OP_TABLE") then
                    table.insert(filtered, _SD)
                else
                    table.insert(filtered, obj)
                end
            else
                table.insert(filtered, obj)
            end
        end
        return filtered
    end
end
local function wGRMuexTcw(origGetreg)
    if typeof(origGetreg) ~= "function" then return origGetreg end
    return function(...)
        local ok, tbl = _pcTMdLIhKku(origGetreg, ...)
        if not ok or type(tbl) ~= "table" then return tbl end
        local filtered = {}
        for k, obj in pairs(tbl) do
            local tObj = type(obj)
            if tObj == "function" then
                if obj == _pFRZuJcXW or obj == _TLSRYofNKulxQ or (type(_PROTECTED_CLOSURES) == "table" and _PROTECTED_CLOSURES[obj]) then
                else
                    filtered[k] = obj
                end
            elseif tObj == "string" then
                if iCODEihmKcBnT(obj) or iHESYbZGqe(obj) or (typeof(SESSION_TOKEN) == "string" and #SESSION_TOKEN > 10 and obj:find(SESSION_TOKEN, 1, true)) or obj:find("_OP_TABLE") then
                    filtered[k] = _SD
                else
                    filtered[k] = obj
                end
            else
                filtered[k] = obj
            end
        end
        return filtered
    end
end
do
    local envs = {getfenv(), _G, shared}
    if typeof(getgenv) == "function" and type(getgenv()) == "table" then
        table.insert(envs, getgenv())
    end
    for _, env in ipairs(envs) do
        _wFnsyfBbQfsnZN[env] = _wFnsyfBbQfsnZN[env] or {}
        for _, k in ipairs(_keys) do
            local original = env[k]
            if typeof(original) == "function" then
                if not _origsgcPIhNM[k] then _origsgcPIhNM[k] = original end
                local wrapped = wDFwwWVHoLCKe(original, k)
                if safeSet(env, k, wrapped) then
                    _wFnsyfBbQfsnZN[env][k] = wrapped
                end
            end
        end
        for _, httpKey in ipairs({"request", "http_request", "HttpGet", "HttpPost"}) do
            local origHttp = env[httpKey]
            if typeof(origHttp) == "function" and not _origsgcPIhNM[httpKey] then
                _origsgcPIhNM[httpKey] = origHttp
                local wrapped = wHFjYBKkzyjk(origHttp)
                if safeSet(env, httpKey, wrapped) then
                    _wFnsyfBbQfsnZN[env][httpKey] = wrapped
                end
            end
        end
        for _, wsKey in ipairs({"WebSocket", "websocket"}) do
            local wsObj = env[wsKey]
            if type(wsObj) == "table" and typeof(wsObj.connect) == "function" and not _origsgcPIhNM[wsKey .. ".connect"] then
                _origsgcPIhNM[wsKey .. ".connect"] = wsObj.connect
                local wrappedWs = wWSDnipSf(wsObj.connect)
                if safeSet(wsObj, "connect", wrappedWs) then
                    _wFnsyfBbQfsnZN[env][wsKey .. ".connect"] = wrappedWs
                end
            end
        end
        local origGc = rawget(env, "getgc") or env["getgc"]
        if typeof(origGc) == "function" and not _origsgcPIhNM["getgc"] then
            _origsgcPIhNM["getgc"] = origGc
            local wrappedGc = wGCowZfRmeSMh(origGc)
            if safeSet(env, "getgc", wrappedGc) then
                _wFnsyfBbQfsnZN[env]["getgc"] = wrappedGc
            end
        end
        local origReg = rawget(env, "getreg") or env["getreg"]
        if typeof(origReg) == "function" and not _origsgcPIhNM["getreg"] then
            _origsgcPIhNM["getreg"] = origReg
            local wrappedReg = wGRMuexTcw(origReg)
            if safeSet(env, "getreg", wrappedReg) then
                _wFnsyfBbQfsnZN[env]["getreg"] = wrappedReg
            end
        end
    end
    if typeof(string) == "table" and typeof(string.dump) == "function" and not _origsgcPIhNM["string.dump"] then
        local origDump = string.dump
        _origsgcPIhNM["string.dump"] = origDump
        local wrappedDump = function(targetFn, ...)
            if targetFn == _pFRZuJcXW or (type(_PROTECTED_CLOSURES) == "table" and _PROTECTED_CLOSURES[targetFn]) then
                return _SD
            end
            local ok, res = pcall(origDump, targetFn, ...)
            return ok and res or _SD
        end
        safeSet(string, "dump", wrappedDump)
    end
    if typeof(debug) == "table" and typeof(debug.getregistry) == "function" and not _origsgcPIhNM["debug.getregistry"] then
        _origsgcPIhNM["debug.getregistry"] = debug.getregistry
        safeSet(debug, "getregistry", wGRMuexTcw(debug.getregistry))
    end
    if syn and type(syn.websocket) == "table" and typeof(syn.websocket.connect) == "function" and not _origsgcPIhNM["syn.websocket.connect"] then
        _origsgcPIhNM["syn.websocket.connect"] = syn.websocket.connect
        safeSet(syn.websocket, "connect", wWSDnipSf(syn.websocket.connect))
    end
end
local function dExecmnjRaGxpJ()
    if syn then return "Synapse X" end
    if KRNL_LOADED then return "KRNL" end
    if fluxus then return "Fluxus" end
    if typeof(Solara) ~= "nil" then return "Solara" end
    if typeof(Delta) ~= "nil" then return "Delta" end
    if typeof(electron) ~= "nil" then return "Electron" end
    if typeof(celery) ~= "nil" then return "Celery" end
    if typeof(getexecutorname) == "function" then
        local ok, name = pcall(getexecutorname)
        if ok and type(name) == "string" and name ~= "" then return name end
    end
    if typeof(identifyexecutor) == "function" then
        local ok, name = pcall(identifyexecutor)
        if ok and type(name) == "string" and name ~= "" then return name end
    end
    if typeof(request) == "function" then return "Script-Ware" end
    return "Unknown"
end
local _CSqAmFiscVvj = {
    STRIKES = 0,
    MAX_STRIKES = 5,
    PING_INTERVAL = 15,
    URL = SERVER_URL,
    LAST_ANNOUNCEMENT_ID = "",
    LAST_HEARTBEAT = (typeof(os) == "table" and typeof(os.clock) == "function" and os.clock()) or 0
}
local _bcMmjice = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64eCqFLhP(data)
    local result = {}
    local pad = ""
    local len = #data
    local mod = len % 3
    if mod > 0 then
        data = data .. string.rep("\0", 3 - mod)
        if mod == 1 then pad = "==" elseif mod == 2 then pad = "=" end
    end
    for i = 1, #data, 3 do
        local a, b, c = string.byte(data, i, i+2)
        local n = a * 65536 + b * 256 + c
        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64
        table.insert(result, string.sub(_bcMmjice, c1+1, c1+1))
        table.insert(result, string.sub(_bcMmjice, c2+1, c2+1))
        table.insert(result, string.sub(_bcMmjice, c3+1, c3+1))
        table.insert(result, string.sub(_bcMmjice, c4+1, c4+1))
    end
    local encoded = table.concat(result)
    if #pad > 0 then
        encoded = string.sub(encoded, 1, #encoded - #pad) .. pad
    end
    encoded = encoded:gsub("+", "-"):gsub("/", "_"):gsub("=", "")
    return encoded
end
local function uENzScJRTu(str)
    str = tostring(str)
    local result = {}
    for i = 1, #str do
        local c = string.sub(str, i, i)
        local b = string.byte(c)
        if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or c == "-" or c == "_" or c == "." or c == "~" then
            table.insert(result, c)
        else
            table.insert(result, string.format("%%%02X", b))
        end
    end
    return table.concat(result)
end
local function jDDIzvbGGo(s)
    local ok, v = _pcTMdLIhKku(function()
        local dec = _HSfDrheBK.JSONDecode
        return dec(_HSfDrheBK, s)
    end)
    return ok and v or nil
end
local function jEPcXfgKM(t)
    local ok, v = _pcTMdLIhKku(function()
        local enc = _HSfDrheBK.JSONEncode
        return enc(_HSfDrheBK, t)
    end)
    return ok and v or "{}"
end
local _bdtVKnEEmEOG = {}
for i = 0, 255 do _bdtVKnEEmEOG[i] = 0 end
do
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    for i = 1, #chars do
        _bdtVKnEEmEOG[string.byte(chars, i)] = i - 1
    end
    _bdtVKnEEmEOG[string.byte("-")] = 62
    _bdtVKnEEmEOG[string.byte("_")] = 63
end
local function b64dtrTngcrZFj(data)
    data = data:gsub("[^A-Za-z0-9+/%-_=]", "")
    local pad = (4 - (#data % 4)) % 4
    if pad > 0 then data = data .. string.rep("=", pad) end
    local result = {}
    local len = #data
    for i = 1, len, 4 do
        local b1, b2, b3, b4 = string.byte(data, i, i + 3)
        local a = _bdtVKnEEmEOG[b1] or 0
        local b = _bdtVKnEEmEOG[b2] or 0
        local c = (b3 ~= 61) and (_bdtVKnEEmEOG[b3] or 0) or 0
        local dv = (b4 ~= 61) and (_bdtVKnEEmEOG[b4] or 0) or 0
        local n = a * 262144 + b * 4096 + c * 64 + dv
        result[#result + 1] = _BYTE_MAP[math.floor(n / 65536) % 256]
        if b3 ~= 61 then result[#result + 1] = _BYTE_MAP[math.floor(n / 256) % 256] end
        if b4 ~= 61 then result[#result + 1] = _BYTE_MAP[n % 256] end
        if i % 60000 == 1 and _tkRXAXST and _tkRXAXST.wait then _tkRXAXST.wait() end
    end
    return table.concat(result)
end
local _b32 = bit32 or require("bit32")
local function sha256(msg)
    local K = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
    }
    local function rr(x,n) return _b32.bor(_b32.rshift(x,n), _b32.lshift(x, 32-n)) end
    local function badd(...) local s=0; for _,v in ipairs({...}) do s=_b32.band(s+v,0xFFFFFFFF) end; return s end
    local H = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}
    local msglen = #msg
    local bitlen_lo = (msglen * 8) % (2^32)
    msg = msg .. "\x80"
    while #msg % 64 ~= 56 do msg = msg .. "\x00" end
    msg = msg .. "\x00\x00\x00\x00"
    for i = 3, 0, -1 do msg = msg .. string.char(_b32.band(_b32.rshift(bitlen_lo, i*8), 0xFF)) end
    for blk = 1, #msg, 64 do
        local W = {}
        for i = 0, 15 do
            local o = blk + i*4
            W[i] = badd(
                string.byte(msg,o)*0x1000000,
                string.byte(msg,o+1)*0x10000,
                string.byte(msg,o+2)*0x100,
                string.byte(msg,o+3)
            )
        end
        for i = 16, 63 do
            local s0 = _b32.bxor(rr(W[i-15],7), _b32.bxor(rr(W[i-15],18), _b32.rshift(W[i-15],3)))
            local s1 = _b32.bxor(rr(W[i-2],17), _b32.bxor(rr(W[i-2],19),  _b32.rshift(W[i-2],10)))
            W[i] = badd(W[i-16], s0, W[i-7], s1)
        end
        local a,b,c,d,e,f,g,h = H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]
        for i = 0, 63 do
            local S1   = _b32.bxor(rr(e,6), _b32.bxor(rr(e,11), rr(e,25)))
            local ch   = _b32.bxor(_b32.band(e,f), _b32.band(_b32.bnot(e),g))
            local t1   = badd(h, S1, ch, K[i+1], W[i])
            local S0   = _b32.bxor(rr(a,2), _b32.bxor(rr(a,13), rr(a,22)))
            local maj  = _b32.bxor(_b32.band(a,b), _b32.bxor(_b32.band(a,c), _b32.band(b,c)))
            local t2   = badd(S0, maj)
            h=g; g=f; f=e; e=badd(d,t1)
            d=c; c=b; b=a; a=badd(t1,t2)
        end
        H[1]=badd(H[1],a); H[2]=badd(H[2],b); H[3]=badd(H[3],c); H[4]=badd(H[4],d)
        H[5]=badd(H[5],e); H[6]=badd(H[6],f); H[7]=badd(H[7],g); H[8]=badd(H[8],h)
    end
    local out = {}
    for i = 1, 8 do
        for j = 3, 0, -1 do
            out[#out+1] = string.char(_b32.band(_b32.rshift(H[i], j*8), 0xFF))
        end
    end
    return table.concat(out)  
end
local function r4CHJOpCtv(data, key)
    local S = {}
    for i = 0, 255 do S[i] = i end
    local j = 0
    for i = 0, 255 do
        j = (j + S[i] + string.byte(key, (i % #key) + 1) + RC4_C1) % 256
        S[i], S[j] = S[j], S[i]
    end
    local result = {}
    local i = 0
    j = 0
    for idx = 1, #data do
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]
        result[idx] = string.char(_b32.bxor(string.byte(data, idx), S[(S[i] + S[j] + RC4_C2) % 256]))
        if idx % 60000 == 0 then _tkRXAXST.wait() end 
    end
    return table.concat(result)
end
local function c20CdxCGWSmQ(data, key, nonce)
    local k0 = string.byte(key, 1) + string.byte(key, 2)*256 + string.byte(key, 3)*65536 + string.byte(key, 4)*16777216
    local k1 = string.byte(key, 5) + string.byte(key, 6)*256 + string.byte(key, 7)*65536 + string.byte(key, 8)*16777216
    local k2 = string.byte(key, 9) + string.byte(key, 10)*256 + string.byte(key, 11)*65536 + string.byte(key, 12)*16777216
    local k3 = string.byte(key, 13) + string.byte(key, 14)*256 + string.byte(key, 15)*65536 + string.byte(key, 16)*16777216
    local k4 = string.byte(key, 17) + string.byte(key, 18)*256 + string.byte(key, 19)*65536 + string.byte(key, 20)*16777216
    local k5 = string.byte(key, 21) + string.byte(key, 22)*256 + string.byte(key, 23)*65536 + string.byte(key, 24)*16777216
    local k6 = string.byte(key, 25) + string.byte(key, 26)*256 + string.byte(key, 27)*65536 + string.byte(key, 28)*16777216
    local k7 = string.byte(key, 29) + string.byte(key, 30)*256 + string.byte(key, 31)*65536 + string.byte(key, 32)*16777216
    local n0 = string.byte(nonce, 1) + string.byte(nonce, 2)*256 + string.byte(nonce, 3)*65536 + string.byte(nonce, 4)*16777216
    local n1 = string.byte(nonce, 5) + string.byte(nonce, 6)*256 + string.byte(nonce, 7)*65536 + string.byte(nonce, 8)*16777216
    local n2 = string.byte(nonce, 9) + string.byte(nonce, 10)*256 + string.byte(nonce, 11)*65536 + string.byte(nonce, 12)*16777216
    local state = {
        0x61707865, 0x3320646e, 0x79622d32, 0x6b206574,
        k0, k1, k2, k3, k4, k5, k6, k7,
        0, n0, n1, n2
    }
    local working = {}
    for i = 1, 16 do working[i] = 0 end
    local function badd(x, y) return _b32.band(x + y, 0xFFFFFFFF) end
    local function rotl(x, n) return _b32.bor(_b32.lshift(x, n), _b32.rshift(x, 32 - n)) end
    local function qr(st, a, b, c, d)
        st[a] = badd(st[a], st[b]); st[d] = _b32.bxor(st[d], st[a]); st[d] = rotl(st[d], 16)
        st[c] = badd(st[c], st[d]); st[b] = _b32.bxor(st[b], st[c]); st[b] = rotl(st[b], 12)
        st[a] = badd(st[a], st[b]); st[d] = _b32.bxor(st[d], st[a]); st[d] = rotl(st[d], 8)
        st[c] = badd(st[c], st[d]); st[b] = _b32.bxor(st[b], st[c]); st[b] = rotl(st[b], 7)
    end
    local out = {}
    local counter = 0
    local len = #data
    for i = 1, len, 64 do
        state[13] = counter % (2^32)
        counter = counter + 1
        for w = 1, 16 do working[w] = state[w] end
        for _ = 1, 10 do
            qr(working, 1, 5,  9, 13)
            qr(working, 2, 6, 10, 14)
            qr(working, 3, 7, 11, 15)
            qr(working, 4, 8, 12, 16)
            qr(working, 1, 6, 11, 16)
            qr(working, 2, 7, 12, 13)
            qr(working, 3, 8,  9, 14)
            qr(working, 4, 5, 10, 15)
        end
        local blockLen = math.min(64, len - i + 1)
        for w = 1, 16 do
            local val = badd(working[w], state[w])
            local baseIdx = (w - 1) * 4
            if baseIdx < blockLen then
                out[#out + 1] = _BYTE_MAP[_b32.bxor(string.byte(data, i + baseIdx), _b32.band(val, 0xFF))]
            end
            if baseIdx + 1 < blockLen then
                out[#out + 1] = _BYTE_MAP[_b32.bxor(string.byte(data, i + baseIdx + 1), _b32.band(_b32.rshift(val, 8), 0xFF))]
            end
            if baseIdx + 2 < blockLen then
                out[#out + 1] = _BYTE_MAP[_b32.bxor(string.byte(data, i + baseIdx + 2), _b32.band(_b32.rshift(val, 16), 0xFF))]
            end
            if baseIdx + 3 < blockLen then
                out[#out + 1] = _BYTE_MAP[_b32.bxor(string.byte(data, i + baseIdx + 3), _b32.band(_b32.rshift(val, 24), 0xFF))]
            end
        end
        if counter % 250 == 0 and _tkRXAXST and _tkRXAXST.wait then _tkRXAXST.wait() end
    end
    return table.concat(out)
end
local function rHCVhbiif(targetUrl, headers, bodyTable)
    targetUrl = targetUrl:gsub("/+$", "")
    headers = headers or {}
    if bodyTable and type(bodyTable) == "table" then
        local jsonStr = jEPcXfgKM(bodyTable)
        headers["X-Payload"] = b64eCqFLhP(jsonStr)
    end
    local _req = _RRKHYMmbZPK or (typeof(request) == "function" and request) or (typeof(http_request) == "function" and http_request) or (syn and syn.request)
    if _req then
        local ok, res = _pcTMdLIhKku(_req, {Url=targetUrl, Method="GET", Headers=headers})
        if ok and type(res)=="table" then
            local code = res.StatusCode or res.status or res.Status or 200
            if code < 400 then return res.Body or res.body or "", nil end
        end
        local ok2, res2 = _pcTMdLIhKku(_req, {url=targetUrl, method="GET", headers=headers})
        if ok2 and type(res2)=="table" then
            local code = res2.StatusCode or res2.status or res2.Status or 200
            if code < 400 then return res2.Body or res2.body or "", nil end
        end
    end
    local ok3, res3 = _pcTMdLIhKku(function()
        return _HSfDrheBK:RequestAsync({Url=targetUrl, Method="GET", Headers=headers})
    end)
    if ok3 and type(res3)=="table" then
        local code = res3.StatusCode or res3.status or 200
        if code < 400 then return res3.Body or res3.body or "", nil end
    end
    return nil, tostring(res3 or "HTTP Request Failed")
end
local function dHqmxloFx(url, headers, bodyTable)
    local endpoint = url
    if endpoint:sub(1, 4) == "http" then
        endpoint = endpoint:gsub("^https?://[^/]+", "")
    end
    local currentBase = _CSqAmFiscVvj.URL or SERVER_URL
    local primaryTarget = currentBase .. endpoint
    local rawBody, err = rHCVhbiif(primaryTarget, headers, bodyTable)
    local isValidJson = false
    if rawBody and rawBody ~= "" then
        local data = jDDIzvbGGo(rawBody)
        if data then isValidJson = true end
    end
    if isValidJson then return rawBody, nil end
    if currentBase == PRIMARY_URL or currentBase:find("symbiote.cc") then
        local fbTarget = FALLBACK_URL .. endpoint
        local fbBody, fbErr = rHCVhbiif(fbTarget, headers, bodyTable)
        if fbBody and fbBody ~= "" and jDDIzvbGGo(fbBody) then
            _CSqAmFiscVvj.URL = FALLBACK_URL
            return fbBody, nil
        end
    end
    return rawBody, err
end
local function kUPcHJODgF(reason)
    _pcTMdLIhKku(function()
        local lp = _LPJaffbKMv or _PVoiaStLSqY.LocalPlayer
        if not lp then
            pcall(function() lp = game:GetService("Players").LocalPlayer end)
        end
        if lp and typeof(lp.Kick) == "function" then
            lp:Kick(tostring(reason or "Disconnected"))
        end
    end)
end
local function toHex(bStr)
    local out = {}
    for i = 1, #bStr do
        out[i] = string.format("%02x", string.byte(bStr, i))
    end
    return table.concat(out)
end
local function mPPEyytBWaZ(token, secret, nonce)
    local hashBytes = sha256(token .. secret .. nonce)
    return toHex(hashBytes) 
end
local function sAUIsSOrtIa(text)
    _pcTMdLIhKku(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "SymbioteAnnouncement"
        sg.ResetOnSpawn = false
        local protected = false
        if typeof(syn) == "table" and type(syn.protect_gui) == "function" then
            _pcTMdLIhKku(syn.protect_gui, sg)
            _pcTMdLIhKku(function() sg.Parent = game:GetService("CoreGui") end)
            protected = true
        elseif type(gethui) == "function" then
            local hui = gethui()
            if hui then
                sg.Parent = hui
                protected = true
            end
        end
        if not protected or not sg.Parent then
            local okCore = _pcTMdLIhKku(function() sg.Parent = game:GetService("CoreGui") end)
            if not okCore or not sg.Parent then
                local lp = _LPJaffbKMv or _PVoiaStLSqY.LocalPlayer
                if lp then
                    sg.Parent = lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
                end
            end
        end
        local totalHeight = 80
        local boundsY = 24
        _pcTMdLIhKku(function()
            local txtService = game:GetService("TextService")
            local bounds = txtService:GetTextSize(tostring(text), 14, Enum.Font.GothamMedium, Vector2.new(300, 10000))
            boundsY = bounds.Y
            totalHeight = math.max(65, 55 + boundsY)
        end)
        local targetPos = UDim2.new(1, -340, 1, -20)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 320, 0, totalHeight)
        frame.Position = UDim2.new(1, 20, 1, -20)
        frame.AnchorPoint = Vector2.new(0, 1)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = sg
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(140, 60, 200)
        stroke.Thickness = 1.5
        stroke.Parent = frame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 24)
        title.Position = UDim2.new(0, 10, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = "Live Announcement !"
        title.TextColor3 = Color3.fromRGB(140, 60, 200)
        title.TextSize = 16
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame
        local body = Instance.new("TextLabel")
        body.Position = UDim2.new(0, 10, 0, 40)
        body.Size = UDim2.new(1, -20, 0, boundsY)
        body.BackgroundTransparency = 1
        body.Text = tostring(text)
        body.TextColor3 = Color3.fromRGB(201, 209, 217)
        body.TextSize = 14
        body.Font = Enum.Font.GothamMedium
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.TextWrapped = true
        body.Parent = frame
        local ts = game:GetService("TweenService")
        local tweenIn = ts:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos})
        tweenIn:Play()
        _tkRXAXST.delay(10, function()
            local fadeOut = ts:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -20)})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                sg:Destroy()
            end)
            _tkRXAXST.delay(1, function()
                if sg and sg.Parent then
                    sg:Destroy()
                end
            end)
        end)
    end)
end
local function sHBVnXufIKBB(initialSecret)
    local currentPingSecret = initialSecret or ""
    _tkRXAXST.spawn(function()
        while true do
            _tkRXAXST.wait(_CSqAmFiscVvj.PING_INTERVAL)
            local nonce = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
            local proof = mPPEyytBWaZ(SESSION_TOKEN, currentPingSecret, nonce)
            local raw, err = dHqmxloFx(
                _CSqAmFiscVvj.URL .. "/heartbeat",
                {["Content-Type"]="application/json"},
                {token = SESSION_TOKEN, proof = proof, nonce = nonce}
            )
            local data = jDDIzvbGGo(raw or "")
            if data and data.kick then
                kUPcHJODgF(data.reason or "You have been kicked by moderators.")
                break
            end
            if data and data.next_secret and data.hb_nonce then
                local hbKey = sha256(SESSION_TOKEN .. nonce)
                local hbNonce = b64dtrTngcrZFj(data.hb_nonce)
                local decNextSecret = c20CdxCGWSmQ(b64dtrTngcrZFj(data.next_secret), hbKey, hbNonce)
                if decNextSecret and #decNextSecret > 0 then
                    currentPingSecret = decNextSecret
                end
            end
            if data and type(data.announcement) == "table" then
                local ann_id = tostring(data.announcement.id)
                local ann_txt = tostring(data.announcement.text)
                if ann_id ~= "" and ann_id ~= "nil" and ann_id ~= _CSqAmFiscVvj.LAST_ANNOUNCEMENT_ID then
                    _CSqAmFiscVvj.LAST_ANNOUNCEMENT_ID = ann_id
                    sAUIsSOrtIa(ann_txt)
                end
            end
            if not data or data.status ~= "ok" then
                _CSqAmFiscVvj.STRIKES = _CSqAmFiscVvj.STRIKES + 1
            else
                _CSqAmFiscVvj.STRIKES = 0
                _CSqAmFiscVvj.LAST_HEARTBEAT = (typeof(os) == "table" and typeof(os.clock) == "function" and os.clock()) or 0
            end
            if _CSqAmFiscVvj.STRIKES >= _CSqAmFiscVvj.MAX_STRIKES then
                kUPcHJODgF("Connection Lost or Tampered (Heartbeat Failure)")
                break
            end
        end
    end)
end
local function main()
    local lp = _LPJaffbKMv or _PVoiaStLSqY.LocalPlayer
    if not lp then
        local st = (typeof(os) == "table" and typeof(os.clock) == "function" and os.clock()) or 0
        while not lp and (((typeof(os) == "table" and typeof(os.clock) == "function" and os.clock()) or 0) - st) < 5 do
            if typeof(_tkRXAXST) == "table" and typeof(_tkRXAXST.wait) == "function" then _tkRXAXST.wait(0.05) end
            lp = _PVoiaStLSqY.LocalPlayer
        end
    end
    if lp then _LPJaffbKMv = lp end
    local ok, cid = _pcTMdLIhKku(function() return _RSQRWNEqe:GetClientId() end)
    local clientId = ok and cid or "unknown"
    local platform  = tostring(_USkhPtOs:GetPlatform())
    local userId   = (lp and tostring(lp.UserId)) or ""
    local gameId   = tostring(game.GameId)
    local executor = dExecmnjRaGxpJ()
    if userId == "0" or userId == "" then return end
    local rawBody = dHqmxloFx(
        _CSqAmFiscVvj.URL .. "/verify",
        {["Content-Type"]="application/json", ["X-Script-Token"]=SCRIPT_TOKEN},
        {
            key          = USER_KEY,
            session_token = SESSION_TOKEN,
            clientId     = clientId,
            platform     = platform,
            executor     = executor,
            userId       = userId,
            gameId       = gameId
        }
    )
    if not rawBody or rawBody == "" then return end
    local data = jDDIzvbGGo(rawBody)
    if not data or not data.success then
        local reason = (data and type(data.reason) == "string" and #data.reason > 0) and data.reason or "Verification Failed"
        if data and data.kick then
            kUPcHJODgF(reason)
        else
            _wnRipdRjjfmn("[Symbiote] Verification notice: " .. tostring(reason))
        end
        return
    end
    local rawScriptEnc = tostring(data.payload)
    local rawScript = nil
    local pingSecret = ""
    if data.enc == 2 and data.enc_key and data.enc_mac_key and data.enc_ping_secret and data.nonce and data.dec_nonce then
        local decBase = sha256(clientId .. SESSION_TOKEN .. SCRIPT_TOKEN .. userId)
        local nonceBytes = b64dtrTngcrZFj(data.nonce)
        local decNonceBytes = b64dtrTngcrZFj(data.dec_nonce)
        local payloadKey = c20CdxCGWSmQ(b64dtrTngcrZFj(data.enc_key), decBase, decNonceBytes)
        local macKey = c20CdxCGWSmQ(b64dtrTngcrZFj(data.enc_mac_key), decBase, decNonceBytes)
        pingSecret = c20CdxCGWSmQ(b64dtrTngcrZFj(data.enc_ping_secret), decBase, decNonceBytes)
        local macCheck = toHex(sha256(rawScriptEnc .. macKey))
        if macCheck ~= data.mac then return end 
        rawScript = c20CdxCGWSmQ(b64dtrTngcrZFj(rawScriptEnc), payloadKey, nonceBytes)
        decBase = nil; payloadKey = nil; macKey = nil; rawScriptEnc = nil; nonceBytes = nil; decNonceBytes = nil
    elseif data.enc == 1 and data.enc_key and data.enc_mac_key and data.enc_ping_secret then
        local decBase = sha256(clientId .. SESSION_TOKEN .. SCRIPT_TOKEN .. userId)
        local payloadKey = r4CHJOpCtv(b64dtrTngcrZFj(data.enc_key), decBase)
        local macKey = r4CHJOpCtv(b64dtrTngcrZFj(data.enc_mac_key), decBase)
        pingSecret = r4CHJOpCtv(b64dtrTngcrZFj(data.enc_ping_secret), decBase)
        local macCheck = toHex(sha256(rawScriptEnc .. macKey))
        if macCheck ~= data.mac then return end
        rawScript = r4CHJOpCtv(b64dtrTngcrZFj(rawScriptEnc), payloadKey)
        decBase = nil; payloadKey = nil; macKey = nil; rawScriptEnc = nil
    else
        return 
    end
    local safeLoadstring = gSLSeBGkSfGlM(_TLSRYofNKulxQ)
    local isCompromised = _TAMPERED or (not tLSIKRNRGAWQn(safeLoadstring)) or (not tMMICulbJcsG())
    if isCompromised then
        _TAMPERED = true
    end
    local _g = (typeof(getgenv) == "function" and getgenv()) or _G
    local sourceLabel = (type(data) == "table" and type(data.source_label) == "string") and data.source_label or "@Symbiote"
    local payloadFn = nil
    local loadErr = nil
    do
        local targetScript = nil
        if isCompromised then
            targetScript = string.format("local _SD = %q\nif typeof(warn) == 'function' then warn(_SD) end\nreturn function() return _SD end", _SD)
        else
            targetScript = rawScript
        end
        rawScript = nil
        local ok1, fn1, err1 = _pcTMdLIhKku(function() return safeLoadstring(targetScript, sourceLabel) end)
        if ok1 and type(fn1) == "function" then
            payloadFn = fn1
        else
            local ok2, fn2, err2 = _pcTMdLIhKku(function() return safeLoadstring(targetScript) end)
            if ok2 and type(fn2) == "function" then
                payloadFn = fn2
            else
                loadErr = tostring(err1 or err2 or fn1 or fn2 or "Compilation failed")
            end
        end
        targetScript = nil
    end
    if typeof(collectgarbage) == "function" then
        _pcTMdLIhKku(function()
            for _ = 1, 3 do
                collectgarbage("collect")
            end
        end)
    end
    if isCompromised then
        if payloadFn then _pcTMdLIhKku(payloadFn) end
        return
    end
    _pFRZuJcXW = payloadFn
    if payloadFn then _PROTECTED_CLOSURES[payloadFn] = true end
    local _INTROSPECT_KEYS = {
        "getscript", "getsenv", "getrunningscripts", "getloadedmodules",
        "getupvalue", "getupvalues", "setupvalue", "setupvalues",
        "getconstant", "getconstants", "setconstant", "setconstants",
        "getproto", "getprotos", "setproto", "setprotos",
        "getstack", "setstack",
        "getscriptclosure", "getscriptbytecode",
        "getreg", "getregistry",
        "decompile", "disassemble"
    }
    if type(_g) == "table" then
        for _, fnName in ipairs(_INTROSPECT_KEYS) do
            local orig = rawget(_g, fnName) or _g[fnName]
            if typeof(orig) == "function" then
                local wrappedIntrospect = function(...)
                    local args = {...}
                    if #args > 0 and _PROTECTED_CLOSURES[args[1]] then
                        return nil
                    end
                    local ok, res = _pcTMdLIhKku(orig, ...)
                    return ok and res or nil
                end
                local okSet = _pcTMdLIhKku(function() _g[fnName] = wrappedIntrospect end)
                if okSet and type(_wFnsyfBbQfsnZN[_g]) == "table" then
                    _wFnsyfBbQfsnZN[_g][fnName] = wrappedIntrospect
                end
            end
        end
    end
    if typeof(debug) == "table" then
        for _, fnName in ipairs(_INTROSPECT_KEYS) do
            local orig = rawget(debug, fnName) or debug[fnName]
            if typeof(orig) == "function" then
                local wrappedDebug = function(...)
                    local args = {...}
                    if #args > 0 and _PROTECTED_CLOSURES[args[1]] then
                        return nil
                    end
                    local ok, r = _pcTMdLIhKku(orig, ...)
                    return ok and r or nil
                end
                _pcTMdLIhKku(function()
                    if typeof(setreadonly) == "function" then _pcTMdLIhKku(setreadonly, debug, false) end
                    if typeof(makewriteable) == "function" then _pcTMdLIhKku(makewriteable, debug) end
                    debug[fnName] = wrappedDebug
                end)
            end
        end
    end
    local _CRITICAL_GUARD_KEYS = {
        "writefile", "appendfile", "setclipboard", "toclipboard",
        "rconsoleprint", "rconsolewarn", "rconsoleinfo", "rconsoleerr", "printconsole",
        "decompile", "disassemble", "getscriptbytecode", "saveinstance"
    }
    local envs_chk = {getfenv(), _G, shared}
    if typeof(getgenv) == "function" and type(getgenv()) == "table" then table.insert(envs_chk, getgenv()) end
    for _, env in ipairs(envs_chk) do
        local envMap = _wFnsyfBbQfsnZN[env]
        if type(envMap) == "table" then
            for _, k in ipairs(_CRITICAL_GUARD_KEYS) do
                if envMap[k] and env[k] ~= envMap[k] then
                    safeSet(env, k, envMap[k])
                end
            end
        end
    end
    if typeof(collectgarbage) == "function" then
        _pcTMdLIhKku(function() collectgarbage("collect") end)
        _pcTMdLIhKku(function() collectgarbage("collect") end)
    end
    if not payloadFn then
        _wnRipdRjjfmn("[Symbiote] Script compilation failed:", tostring(loadErr or "Unknown error"))
        return
    end
    sHBVnXufIKBB(pingSecret)
    local lp = _LPJaffbKMv or _PVoiaStLSqY.LocalPlayer
    if not lp then
        _pcTMdLIhKku(function() lp = _PVoiaStLSqY:GetPropertyChangedSignal("LocalPlayer"):Wait() and _PVoiaStLSqY.LocalPlayer end)
    end
    if lp then _LPJaffbKMv = lp end
    local pName = (_LPJaffbKMv and _LPJaffbKMv.Name) or ""
    local pUid = (_LPJaffbKMv and _LPJaffbKMv.UserId) or 0
    local authPayload = tostring(SESSION_TOKEN) .. "_" .. tostring(pUid) .. "_" .. pName
    local maxHeartbeatGap = (_CSqAmFiscVvj.MAX_STRIKES * _CSqAmFiscVvj.PING_INTERVAL) + 15
    _CSqAmFiscVvj.LAST_HEARTBEAT = (typeof(os) == "table" and typeof(os.clock) == "function" and os.clock()) or 0
    local sessionContext = {
        S = SESSION_TOKEN,
        UID = pUid,
        IsAlive = function(challenge)
            local now = (typeof(os) == "table" and typeof(os.clock) == "function" and os.clock()) or 0
            if (now - (_CSqAmFiscVvj.LAST_HEARTBEAT or 0)) >= maxHeartbeatGap then
                return false
            end
            if challenge ~= nil then
                return tostring(challenge) .. "_" .. string.sub(SESSION_TOKEN, 1, 8)
            end
            return true
        end
    }
    local execOk, result = _pcTMdLIhKku(payloadFn, authPayload, sessionContext)
    payloadFn = nil
    _pFRZuJcXW = nil
    if not execOk then
        _wnRipdRjjfmn("[Symbiote] Script execution error:", tostring(result))
        return
    end
    if type(result) == "function" then
        _PROTECTED_CLOSURES[result] = true
        _pcTMdLIhKku(result, authPayload, sessionContext)
    elseif type(result) == "table" then
        for _, v in pairs(result) do
            if type(v) == "function" then
                _PROTECTED_CLOSURES[v] = true
            end
        end
    end
end
main()
