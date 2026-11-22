-- AoTR Sigma-Spy (Fork) + 100% Client <-> Server Remote Logger, Parser, Blocker & Spoofer
-- Tich hop:
--   1. Bat 100% OUT (FireServer / InvokeServer / UnreliableRemoteEvent) + FULL InvokeServer Return Values
--   2. Bat 100% IN (OnClientEvent / OnClientInvoke tu Server gui ve + tu dong hook Remote moi spawn)
--   3. Bo phan tich Sigma-Spy Parser & Lua CodeGen (full nil-hole varargs, cyclic table, Instance path, CFrame/Vec3/UDim2/Color3/Buffer/Enum)
--   4. Filter / Search / Ignore / Block OUT / Block IN / Spoof Args / Spoof Return / Spoof In Args (theo Remote, Remote+Arg1, Remote+Arg1+Arg2)
--   5. Actor VM Bridge (bat an toan theo nut bam) + Cong cu AoTR Raid (Snapshot / Quet Phao / Soi Code)

local getgenvFn = type(getgenv) == "function" and getgenv or function() return _G end
local gEnv = getgenvFn()

-- Don dep phien cu neu script duoc chay lai (giu nguyen trampoline hook de khong chong hook)
if type(gEnv.__AOTR_SIGMA_CLEANUP) == "function" then
    pcall(gEnv.__AOTR_SIGMA_CLEANUP)
end

local cloneRefFn = type(cloneref) == "function" and cloneref or function(inst) return inst end
local function getServiceSafe(name)
    local ok, svc = pcall(function() return cloneRefFn(game:GetService(name)) end)
    return ok and svc or nil
end

local Services = {
    Players = getServiceSafe("Players"),
    ReplicatedStorage = getServiceSafe("ReplicatedStorage"),
    ReplicatedFirst = getServiceSafe("ReplicatedFirst"),
    CoreGui = getServiceSafe("CoreGui"),
    UserInputService = getServiceSafe("UserInputService"),
    RunService = getServiceSafe("RunService"),
    CollectionService = getServiceSafe("CollectionService"),
    StarterGui = getServiceSafe("StarterGui"),
    StarterPack = getServiceSafe("StarterPack"),
    StarterPlayer = getServiceSafe("StarterPlayer"),
    Lighting = getServiceSafe("Lighting"),
    SoundService = getServiceSafe("SoundService"),
    TextService = getServiceSafe("TextService"),
    Workspace = cloneRefFn(workspace),
}

local Caps = {
    hookmetamethod = type(hookmetamethod) == "function" and hookmetamethod or nil,
    getnamecallmethod = type(getnamecallmethod) == "function" and getnamecallmethod or nil,
    hookfunction = type(hookfunction) == "function" and hookfunction or nil,
    newcclosure = type(newcclosure) == "function" and newcclosure or function(f) return f end,
    islclosure = type(islclosure) == "function" and islclosure or nil,
    checkcaller = type(checkcaller) == "function" and checkcaller or nil,
    getcallingscript = type(getcallingscript) == "function" and getcallingscript or nil,
    getthreadidentity = type(getthreadidentity) == "function" and getthreadidentity or nil,
    getconnections = type(getconnections) == "function" and getconnections or nil,
    getcallbackvalue = type(getcallbackvalue) == "function" and getcallbackvalue
        or (type(getcallbackmember) == "function" and getcallbackmember) or nil,
    getactors = type(getactors) == "function" and getactors or (syn and type(syn.getactors) == "function" and syn.getactors) or nil,
    runOnActor = type(run_on_actor) == "function" and run_on_actor or (syn and type(syn.run_on_actor) == "function" and syn.run_on_actor) or nil,
    setclipboard = type(setclipboard) == "function" and setclipboard or (type(toclipboard) == "function" and toclipboard) or nil,
    writefile = type(writefile) == "function" and writefile or nil,
    appendfile = type(appendfile) == "function" and appendfile or nil,
    readfile = type(readfile) == "function" and readfile or nil,
    isfile = type(isfile) == "function" and isfile or nil,
    loadstring = type(loadstring) == "function" and loadstring or nil,
    gethui = type(gethui) == "function" and gethui or nil,
    decompile = type(decompile) == "function" and decompile or (syn and type(syn.decompile) == "function" and syn.decompile) or nil,
    getscripts = type(getscripts) == "function" and getscripts or nil,
    getloadedmodules = type(getloadedmodules) == "function" and getloadedmodules or nil,
    getgc = type(getgc) == "function" and getgc or nil,
    getconstants = type(getconstants) == "function" and getconstants or (debug and type(debug.getconstants) == "function" and debug.getconstants) or nil,
}

local typeofFn = typeof or type
local unpackFn = table.unpack or unpack

local LOG_FILE = "aotr_raw_all.txt"
local EXTRACTED_FILE = "aotr_extracted_data.txt"
local EXPORT_LUA_FILE = "aotr_spy_export.lua"
local BRIDGE_NAME = "__AOTR_SigmaSpyBridge"
local MAX_MEMORY_ENTRIES = 4000
local MAX_VISIBLE_ROWS = 160

local Config = {
    paused = false,
    captureExecutor = true,
    captureBindables = false,
    muteNoisePreset = false,
    rawUnfiltered = true,
    autoSaveFile = true,
    captureTraceback = false,
    autoSnapLoop = false,
    dirFilter = "ALL", -- ALL | OUT | IN | RET | MOD
    viewTab = "STREAM", -- STREAM | GROUPED | RULES | AOTR
    searchQuery = "",
    selectedScope = "SIG1", -- REMOTE | SIG1 | SIG2
    spoofMode = "PATCH", -- PATCH | REPLACE | RETURN | IN_ARGS | FN
}

-- Trang thai hook persistent tren getgenv de re-run khong bi chong hookmetamethod
local Persistent = gEnv.__AOTR_SIGMA_PERSISTENT
if not Persistent then
    Persistent = {
        installed = {},
        oldFns = {},
        handlers = {},
        hookedInCallbacks = setmetatable({}, { __mode = "k" }),
        hookedInMeta = setmetatable({}, { __mode = "k" }),
        wrappedClientInvokes = setmetatable({}, { __mode = "k" }),
        ourSignalCallbacks = setmetatable({}, { __mode = "k" }),
        boundRemotes = setmetatable({}, { __mode = "k" }),
        disabledConns = setmetatable({}, { __mode = "k" }),
    }
    gEnv.__AOTR_SIGMA_PERSISTENT = Persistent
end

local State = {
    running = true,
    nextId = 0,
    entries = {},
    entryById = {},
    selectedEntryId = nil,
    grouped = {}, -- [groupKey] = { key, name, path, sig1, count, outC, inC, retC, blkC, spfC, lastId }
    stats = { total = 0, outC = 0, inC = 0, retC = 0, blkC = 0, spfC = 0 },
    rules = {}, -- [ruleKey] = RuleObj
    ruleOrder = {},
    pendingUiFlush = false,
    lastFlushUiAt = 0,
    internalThreads = setmetatable({}, { __mode = "k" }),
    dispatch = setmetatable({}, { __mode = "k" }),
    connections = {},
    fileBuffer = {},
    lastFileFlushAt = 0,
    diagLogs = {},
    actorBridge = nil,
    actorsHookedCount = 0,
    gui = nil,
    refs = {},
    isFullScanning = false,
    isInspectingCode = false,
    isDumpingRaw = false,
    isExtracting = false,
    lastExtractedText = "",
}

local NOISE_ARG1 = {
    Replication = true,
    Movement = true,
    Move = true,
    Position = true,
    Ping = true,
    Heartbeat = true,
    StateSync = true,
    Camera = true,
}

local AoTRTools = {}

-- ============================================================================
-- 1. UTILITIES & SAFE FILE LOGGING
-- ============================================================================
local Utils = {}

function Utils.getThreadKey()
    return coroutine.running() or "MAIN"
end

function Utils.packTuple(...)
    return { ... }, select("#", ...)
end

function Utils.trim(s)
    return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

function Utils.roundInt(x)
    return math.floor(x + 0.5)
end

function Utils.formatNum(n)
    if n ~= n then return "0/0" end
    if n == math.huge then return "math.huge" end
    if n == -math.huge then return "-math.huge" end
    if n == 0 then return "0" end
    if n == math.floor(n) and math.abs(n) < 1e15 then
        return string.format("%.0f", n)
    end
    return string.format("%.10g", n)
end

function Utils.isValidIdentifier(s)
    if type(s) ~= "string" or #s == 0 then return false end
    if not s:match("^[%a_][%w_]*$") then return false end
    local kw = {
        ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true, ["elseif"] = true,
        ["end"] = true, ["false"] = true, ["for"] = true, ["function"] = true, ["if"] = true,
        ["in"] = true, ["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true,
        ["repeat"] = true, ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
        ["while"] = true, ["continue"] = true,
    }
    return not kw[s]
end

function Utils.trackConn(conn)
    if conn then
        State.connections[#State.connections + 1] = conn
    end
    return conn
end

function Utils.getLocalPlayer()
    if Services.Players then
        return Services.Players.LocalPlayer
    end
    return nil
end

function Utils.notify(title, text)
    pcall(function()
        if Services.StarterGui then
            Services.StarterGui:SetCore("SendNotification", {
                Title = title or "Sigma-Spy Fork",
                Text = text or "",
                Duration = 4,
            })
        end
    end)
end

function Utils.copyText(text)
    if Caps.setclipboard then
        local ok = pcall(Caps.setclipboard, tostring(text or ""))
        return ok
    end
    return false
end

local LogWriter = {}

function LogWriter.initFile()
    local header = string.format(
        "-- AoTR Sigma-Spy (Fork) Log | Started at %s | PlaceId=%s\n-- Caps: hookmetamethod=%s | hookfunction=%s | getconnections=%s | getactors=%s\n",
        os.date and tostring(os.date("%Y-%m-%d %H:%M:%S")) or "unknown",
        tostring(game and game.PlaceId or "?"),
        tostring(Caps.hookmetamethod ~= nil),
        tostring(Caps.hookfunction ~= nil),
        tostring(Caps.getconnections ~= nil),
        tostring(Caps.getactors ~= nil)
    )
    if Caps.writefile then
        pcall(Caps.writefile, LOG_FILE, header)
    end
end

function LogWriter.pushLine(line)
    if not Config.autoSaveFile then return end
    local ts = string.format("[%.3fs]", os.clock())
    State.fileBuffer[#State.fileBuffer + 1] = ts .. " " .. tostring(line)
end

function LogWriter.flush(force)
    if not (Caps.appendfile or Caps.writefile) then
        State.fileBuffer = {}
        return
    end
    local now = os.clock()
    if not force and (now - State.lastFileFlushAt < 1.2) then
        return
    end
    if #State.fileBuffer == 0 then
        State.lastFileFlushAt = now
        return
    end
    State.lastFileFlushAt = now
    local chunk = table.concat(State.fileBuffer, "\n") .. "\n"
    State.fileBuffer = {}
    if Caps.appendfile then
        local ok = pcall(Caps.appendfile, LOG_FILE, chunk)
        if ok then return end
    end
    if Caps.writefile then
        pcall(function()
            local prev = (Caps.isfile and Caps.readfile and Caps.isfile(LOG_FILE)) and Caps.readfile(LOG_FILE) or ""
            Caps.writefile(LOG_FILE, prev .. chunk)
        end)
    end
end

function LogWriter.writeLines(lines)
    if type(lines) ~= "table" or #lines == 0 then return end
    local ts = string.format("[%.3fs]", os.clock())
    for _, ln in ipairs(lines) do
        State.fileBuffer[#State.fileBuffer + 1] = ts .. " " .. tostring(ln)
    end
    LogWriter.flush(true)
end

-- ============================================================================
-- 2. SIGMA-SPY DEEP PARSER, SNAPSHOT CLONER & LUA CODE GENERATOR
-- ============================================================================
local Parser = {}

function Parser.formatInstancePath(inst)
    if typeofFn(inst) ~= "Instance" then
        return tostring(inst)
    end
    local okChain, errOrOut = pcall(function()
        if inst == game then return "game" end
        local lp = Utils.getLocalPlayer()
        if lp and inst == lp then
            return 'game:GetService("Players").LocalPlayer'
        end
        local chain = {}
        local cur = inst
        local steps = 0
        while cur and cur ~= game and steps < 48 do
            steps = steps + 1
            chain[#chain + 1] = cur
            cur = cur.Parent
        end
        if cur ~= game then
            local okF, full = pcall(function() return inst:GetFullName() end)
            return string.format("nil --[[unparented %s: %s]]", inst.ClassName, okF and full or inst.Name)
        end

        local root = chain[#chain]
        local out = ""
        if root == Services.Workspace or root.ClassName == "Workspace" then
            out = "workspace"
        else
            local okSvc = pcall(function() return game:FindService(root.ClassName) end)
            if okSvc and game:FindService(root.ClassName) == root then
                out = string.format('game:GetService(%q)', root.ClassName)
            else
                out = Utils.isValidIdentifier(root.Name) and ("game." .. root.Name) or string.format("game:FindFirstChild(%q)", root.Name)
            end
        end

        for i = #chain - 1, 1, -1 do
            local node = chain[i]
            if lp and node == lp then
                out = 'game:GetService("Players").LocalPlayer'
            else
                local n = node.Name
                if Utils.isValidIdentifier(n) then
                    out = out .. "." .. n
                else
                    out = out .. string.format("[%q]", n)
                end
            end
        end
        return out
    end)
    if okChain and type(errOrOut) == "string" then
        return errOrOut
    end
    return tostring(inst)
end

-- Dong bang payload ngay luc bat goi tin de tranh game sua table sau khi FireServer tra ve
function Parser.cloneSnapshot(val, depth, seen, opts)
    depth = depth or 0
    local maxD = (opts and opts.maxDepth) or 12
    local maxI = (opts and opts.maxItems) or 1500
    local maxHex = (opts and opts.maxHex) or 1024
    local t = typeofFn(val)
    if t == "nil" or t == "boolean" or t == "number" or t == "string" then
        return val
    elseif t == "Instance" then
        local okF, full = pcall(function() return val:GetFullName() end)
        return {
            __sigmaMarker = "Instance",
            inst = val,
            name = pcall(function() return val.Name end) and val.Name or "?",
            className = pcall(function() return val.ClassName end) and val.ClassName or "Instance",
            fullPath = okF and full or tostring(val),
            luaPath = Parser.formatInstancePath(val),
        }
    elseif t == "function" then
        local infoTxt = "?"
        pcall(function()
            if debug and type(debug.info) == "function" then
                local src, line, fname = debug.info(val, "sln")
                infoTxt = string.format("%s:%s %s", tostring(src), tostring(line), tostring(fname or ""))
            elseif debug and type(debug.getinfo) == "function" then
                local d = debug.getinfo(val, "Sl")
                if d then
                    infoTxt = string.format("%s:%s", tostring(d.short_src or d.source), tostring(d.currentline or d.linedefined))
                end
            end
        end)
        return { __sigmaMarker = "Function", desc = infoTxt }
    elseif t == "buffer" then
        local bLen = 0
        local hexPreview = ""
        pcall(function()
            bLen = buffer.len(val)
            local raw = buffer.tostring(val)
            local lim = math.min(#raw, maxHex)
            local parts = {}
            for i = 1, lim do
                parts[i] = string.format("%02X", string.byte(raw, i))
            end
            hexPreview = table.concat(parts, " ")
        end)
        return { __sigmaMarker = "Buffer", len = bLen, hex = hexPreview }
    elseif t == "table" then
        if depth >= maxD then
            return { __sigmaMarker = "Truncated", reason = "max_depth" }
        end
        seen = seen or {}
        if seen[val] then
            return { __sigmaMarker = "Cycle" }
        end
        seen[val] = true
        local out = { __sigmaMarker = "Table", items = {}, maxArray = 0, hasHash = false, truncated = false }
        local count = 0
        local maxIdx = 0
        local arrayCount = 0
        for k, v in next, val do
            count = count + 1
            if count > maxI then
                out.truncated = true
                break
            end
            local ck = Parser.cloneSnapshot(k, depth + 1, seen, opts)
            local cv = Parser.cloneSnapshot(v, depth + 1, seen, opts)
            if type(k) == "number" and k >= 1 and k == math.floor(k) then
                arrayCount = arrayCount + 1
                if k > maxIdx then maxIdx = k end
            else
                out.hasHash = true
            end
            out.items[#out.items + 1] = { k = ck, v = cv }
        end
        out.maxArray = maxIdx
        out.isPureArray = (not out.hasHash) and (arrayCount == maxIdx) and maxIdx > 0
        table.sort(out.items, function(a, b)
            local ta, tb = type(a.k), type(b.k)
            if ta == "number" and tb == "number" then return a.k < b.k end
            if ta == "number" then return true end
            if tb == "number" then return false end
            return tostring(a.k) < tostring(b.k)
        end)
        seen[val] = nil
        return out
    end
    return val
end

local function serializeVector3(v)
    return string.format("Vector3.new(%s, %s, %s)", Utils.formatNum(v.X), Utils.formatNum(v.Y), Utils.formatNum(v.Z))
end

local function serializeCFrame(v)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = v:GetComponents()
    local isIdentity = math.abs(r00 - 1) < 1e-4 and math.abs(r11 - 1) < 1e-4 and math.abs(r22 - 1) < 1e-4
        and math.abs(r01) < 1e-4 and math.abs(r02) < 1e-4 and math.abs(r10) < 1e-4
        and math.abs(r12) < 1e-4 and math.abs(r20) < 1e-4 and math.abs(r21) < 1e-4
    if isIdentity then
        return string.format("CFrame.new(%s, %s, %s)", Utils.formatNum(x), Utils.formatNum(y), Utils.formatNum(z))
    end
    return string.format(
        "CFrame.new(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
        Utils.formatNum(x), Utils.formatNum(y), Utils.formatNum(z),
        Utils.formatNum(r00), Utils.formatNum(r01), Utils.formatNum(r02),
        Utils.formatNum(r10), Utils.formatNum(r11), Utils.formatNum(r12),
        Utils.formatNum(r20), Utils.formatNum(r21), Utils.formatNum(r22)
    )
end

local function serializeSnapshotTable(snap, indent, depth, opts)
    local pretty = opts and opts.pretty
    local maxDepth = (opts and opts.maxDepth) or 8
    local maxItems = (opts and opts.maxItems) or 180
    if depth >= maxDepth then
        return "{ --[[max_depth]] }"
    end
    if #snap.items == 0 then
        return "{}"
    end
    local pad = pretty and string.rep("    ", depth) or ""
    local nextPad = pretty and string.rep("    ", depth + 1) or ""
    local parts = {}
    local n = math.min(#snap.items, maxItems)
    for i = 1, n do
        local item = snap.items[i]
        local vs = Parser.serializeValue(item.v, depth + 1, opts)
        if snap.isPureArray then
            parts[#parts + 1] = nextPad .. vs
        else
            local keyExpr
            if type(item.k) == "string" and Utils.isValidIdentifier(item.k) then
                keyExpr = item.k
            else
                keyExpr = "[" .. Parser.serializeValue(item.k, depth + 1, opts) .. "]"
            end
            parts[#parts + 1] = nextPad .. keyExpr .. " = " .. vs
        end
    end
    if #snap.items > maxItems or snap.truncated then
        parts[#parts + 1] = nextPad .. "--[[...truncated...]]"
    end
    if pretty then
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
    end
    return "{ " .. table.concat(parts, ", ") .. " }"
end

function Parser.serializeValue(val, depth, opts)
    depth = depth or 0
    opts = opts or {}
    if type(val) == "table" and val.__sigmaMarker then
        local mk = val.__sigmaMarker
        if mk == "Instance" then
            return opts.shortInst and ("<" .. val.className .. ":" .. val.name .. ">") or val.luaPath
        elseif mk == "Function" then
            return string.format("function() --[[%s]] end", val.desc)
        elseif mk == "Buffer" then
            return string.format('buffer.fromstring("") --[[len=%d hex=%s]]', val.len or 0, val.hex or "")
        elseif mk == "Cycle" then
            return "nil --[[cycle]]"
        elseif mk == "Truncated" then
            return "{ --[[truncated]] }"
        elseif mk == "Table" then
            return serializeSnapshotTable(val, "", depth, opts)
        end
    end

    local t = typeofFn(val)
    if t == "nil" then
        return "nil"
    elseif t == "boolean" then
        return tostring(val)
    elseif t == "number" then
        return Utils.formatNum(val)
    elseif t == "string" then
        local cap = opts.maxStrLen or 4096
        if #val > cap then
            return string.format("%q --[[len=%d]]", val:sub(1, cap), #val)
        end
        return string.format("%q", val)
    elseif t == "Instance" then
        return opts.shortInst and ("<" .. val.ClassName .. ":" .. val.Name .. ">") or Parser.formatInstancePath(val)
    elseif t == "Vector3" then
        return serializeVector3(val)
    elseif t == "Vector2" then
        return string.format("Vector2.new(%s, %s)", Utils.formatNum(val.X), Utils.formatNum(val.Y))
    elseif t == "Vector3int16" then
        return string.format("Vector3int16.new(%d, %d, %d)", val.X, val.Y, val.Z)
    elseif t == "Vector2int16" then
        return string.format("Vector2int16.new(%d, %d)", val.X, val.Y)
    elseif t == "CFrame" then
        return serializeCFrame(val)
    elseif t == "Color3" then
        return string.format("Color3.fromRGB(%d, %d, %d)", Utils.roundInt(val.R * 255), Utils.roundInt(val.G * 255), Utils.roundInt(val.B * 255))
    elseif t == "BrickColor" then
        return string.format("BrickColor.new(%q)", tostring(val))
    elseif t == "UDim" then
        return string.format("UDim.new(%s, %d)", Utils.formatNum(val.Scale), val.Offset)
    elseif t == "UDim2" then
        return string.format("UDim2.new(%s, %d, %s, %d)", Utils.formatNum(val.X.Scale), val.X.Offset, Utils.formatNum(val.Y.Scale), val.Y.Offset)
    elseif t == "Rect" then
        return string.format("Rect.new(%s, %s, %s, %s)", Utils.formatNum(val.Min.X), Utils.formatNum(val.Min.Y), Utils.formatNum(val.Max.X), Utils.formatNum(val.Max.Y))
    elseif t == "Ray" then
        return string.format("Ray.new(%s, %s)", serializeVector3(val.Origin), serializeVector3(val.Direction))
    elseif t == "NumberRange" then
        return string.format("NumberRange.new(%s, %s)", Utils.formatNum(val.Min), Utils.formatNum(val.Max))
    elseif t == "TweenInfo" then
        return string.format(
            "TweenInfo.new(%s, %s, %s, %d, %s, %s)",
            Utils.formatNum(val.Time), tostring(val.EasingStyle), tostring(val.EasingDirection),
            val.RepeatCount, tostring(val.Reverses), Utils.formatNum(val.DelayTime)
        )
    elseif t == "NumberSequence" then
        local kp = {}
        for _, p in ipairs(val.Keypoints) do
            kp[#kp + 1] = string.format("NumberSequenceKeypoint.new(%s, %s, %s)", Utils.formatNum(p.Time), Utils.formatNum(p.Value), Utils.formatNum(p.Envelope))
        end
        return "NumberSequence.new({" .. table.concat(kp, ", ") .. "})"
    elseif t == "ColorSequence" then
        local kp = {}
        for _, p in ipairs(val.Keypoints) do
            local c = p.Value
            kp[#kp + 1] = string.format("ColorSequenceKeypoint.new(%s, Color3.fromRGB(%d, %d, %d))", Utils.formatNum(p.Time), Utils.roundInt(c.R * 255), Utils.roundInt(c.G * 255), Utils.roundInt(c.B * 255))
        end
        return "ColorSequence.new({" .. table.concat(kp, ", ") .. "})"
    elseif t == "EnumItem" or t == "Enum" then
        return tostring(val)
    elseif t == "table" then
        return Parser.serializeValue(Parser.cloneSnapshot(val, 0, {}), depth, opts)
    end
    return string.format("nil --[[%s: %s]]", t, tostring(val))
end

function Parser.serializeTuple(tbl, n, opts)
    local out = {}
    for i = 1, n do
        out[i] = Parser.serializeValue(tbl[i], 0, opts)
    end
    return table.concat(out, ", ")
end

function Parser.generateReplayLua(entry)
    local lines = {}
    lines[#lines + 1] = string.format(
        "-- [%s] %s (%s) | Src=%s | Caller=%s | Time=%.2fs",
        entry.dir,
        entry.remotePath,
        entry.method,
        entry.sourceTag or "MAIN",
        entry.callerName or "?",
        entry.ts or 0
    )
    if entry.status and entry.status ~= "OK" then
        lines[#lines + 1] = "-- Status: " .. entry.status
    end
    if entry.elapsedMs then
        lines[#lines + 1] = string.format("-- Server RoundTrip: %.2f ms", entry.elapsedMs)
    end

    local useArgs = entry.finalArgs or entry.origArgs
    local useN = entry.finalN or entry.argN or 0
    if useN == 0 then
        lines[#lines + 1] = "local args = {}"
    else
        lines[#lines + 1] = "local args = {"
        for i = 1, useN do
            local sep = (i < useN) and "," or ""
            local valCode = Parser.serializeValue(useArgs[i], 1, { pretty = true, maxDepth = 8, maxItems = 180 })
            lines[#lines + 1] = string.format("    [%d] = %s%s", i, valCode, sep)
        end
        lines[#lines + 1] = "}"
    end

    if entry.dir == "OUT" then
        if useN == 0 then
            lines[#lines + 1] = string.format("%s:%s()", entry.luaPath, entry.method)
        else
            lines[#lines + 1] = string.format("%s:%s(unpack(args, 1, %d))", entry.luaPath, entry.method, useN)
        end
    else
        lines[#lines + 1] = string.format("-- Incoming payload tu Server (%s:%s)", entry.luaPath, entry.method)
        lines[#lines + 1] = string.format("local remote = %s", entry.luaPath)
    end

    if entry.argsSpoofed and entry.origArgs then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "-- [ORIGINAL ARGS BEFORE SPOOF]"
        for i = 1, (entry.argN or 0) do
            lines[#lines + 1] = string.format("-- orig[%d] = %s", i, Parser.serializeValue(entry.origArgs[i], 0, { pretty = false }))
        end
    end

    if entry.retN and entry.retN > 0 then
        lines[#lines + 1] = ""
        lines[#lines + 1] = string.format("-- [SERVER / CLIENT RETURN (%d)]", entry.retN)
        local rTbl = entry.srvRets or entry.outRets
        for i = 1, entry.retN do
            lines[#lines + 1] = string.format("-- ret[%d] = %s", i, Parser.serializeValue(rTbl[i], 0, { pretty = true, maxDepth = 6 }))
        end
    elseif entry.method == "InvokeServer" or entry.method == "OnClientInvoke" then
        lines[#lines + 1] = "-- [RETURN: nil (0 values)]"
    end

    if entry.retSpoofed and entry.outRets then
        lines[#lines + 1] = "-- [SPOOFED RETURN GIVEN TO GAME]"
        for i = 1, (entry.outRetN or 0) do
            lines[#lines + 1] = string.format("-- spoofRet[%d] = %s", i, Parser.serializeValue(entry.outRets[i], 0, { pretty = false }))
        end
    end

    if entry.traceback and #entry.traceback > 0 then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "-- [CALLER TRACEBACK]"
        for tl in entry.traceback:gmatch("[^\r\n]+") do
            lines[#lines + 1] = "-- " .. tl
        end
    end

    return table.concat(lines, "\n")
end

-- ============================================================================
-- 3. RULE ENGINE: IGNORE / BLOCK OUT / BLOCK IN / SPOOF ARGS & RETURN
-- ============================================================================
local Rules = {}

function Rules.makeKey(remotePath, sig1, sig2, scope)
    if scope == "REMOTE" or not sig1 or sig1 == "" then
        return "R::" .. tostring(remotePath)
    elseif scope == "SIG1" or not sig2 or sig2 == "" then
        return "S1::" .. tostring(remotePath) .. "::" .. tostring(sig1)
    else
        return "S2::" .. tostring(remotePath) .. "::" .. tostring(sig1) .. "::" .. tostring(sig2)
    end
end

function Rules.getOrCreate(key, label)
    local r = State.rules[key]
    if not r then
        r = {
            key = key,
            label = label or key,
            ignore = false,
            blockOut = false,
            blockIn = false,
            spoofOutArgs = nil, -- { active, mode, raw, fn, tbl, n }
            spoofOutReturn = nil,
            spoofInArgs = nil,
        }
        State.rules[key] = r
        State.ruleOrder[#State.ruleOrder + 1] = key
    end
    return r
end

function Rules.pruneIfEmpty(key)
    local r = State.rules[key]
    if not r then return end
    if not r.ignore and not r.blockOut and not r.blockIn
        and not (r.spoofOutArgs and r.spoofOutArgs.active)
        and not (r.spoofOutReturn and r.spoofOutReturn.active)
        and not (r.spoofInArgs and r.spoofInArgs.active)
    then
        State.rules[key] = nil
        local newOrder = {}
        for _, k in ipairs(State.ruleOrder) do
            if k ~= key then newOrder[#newOrder + 1] = k end
        end
        State.ruleOrder = newOrder
    end
end

function Rules.resolve(remotePath, sig1, sig2)
    local r0 = State.rules["R::" .. remotePath]
    local r1 = sig1 and State.rules["S1::" .. remotePath .. "::" .. sig1] or nil
    local r2 = (sig1 and sig2) and State.rules["S2::" .. remotePath .. "::" .. sig1 .. "::" .. sig2] or nil
    if not (r0 or r1 or r2) then return nil end

    local merged = {}
    for i = 1, 3 do
        local src = (i == 1 and r0) or (i == 2 and r1) or r2
        if src then
            if src.ignore then merged.ignore = true end
            if src.blockOut then merged.blockOut = true end
            if src.blockIn then merged.blockIn = true end
            if src.spoofOutArgs and src.spoofOutArgs.active then merged.spoofOutArgs = src.spoofOutArgs end
            if src.spoofOutReturn and src.spoofOutReturn.active then merged.spoofOutReturn = src.spoofOutReturn end
            if src.spoofInArgs and src.spoofInArgs.active then merged.spoofInArgs = src.spoofInArgs end
        end
    end
    return merged
end

function Rules.compileSpoofSpec(rawText, mode)
    rawText = Utils.trim(rawText)
    if #rawText == 0 then
        return false, nil, "Nhap bieu thuc Lua (VD: { [2] = 999 } hoac \"S_Skills\", 10)"
    end
    if not Caps.loadstring then
        return false, nil, "Executor khong co loadstring"
    end
    local chunkFn, syntaxErr = Caps.loadstring("return " .. rawText)
    if not chunkFn then
        return false, nil, "Loi cu phap: " .. tostring(syntaxErr)
    end
    local okEval, evalVals = pcall(function()
        return Utils.packTuple(chunkFn())
    end)
    if not okEval then
        return false, nil, "Loi thuc thi: " .. tostring(evalVals)
    end

    if mode == "FN" then
        if type(evalVals[1]) ~= "function" then
            return false, nil, "Mode FN can expression dang function(tbl, n, ...) ... end"
        end
        return true, { active = true, mode = "FN", raw = rawText, fn = evalVals[1] }, nil
    elseif mode == "PATCH" then
        if type(evalVals[1]) ~= "table" then
            return false, nil, "Mode PATCH can table (VD: { [2] = 999 })"
        end
        return true, { active = true, mode = "PATCH", raw = rawText, patchTbl = evalVals[1], evalFn = chunkFn }, nil
    else
        return true, { active = true, mode = mode, raw = rawText, evalFn = chunkFn }, nil
    end
end

function Rules.applyTupleSpoof(spec, baseTbl, baseN, ...)
    if not (spec and spec.active) then
        return baseTbl, baseN
    end
    if spec.mode == "FN" and spec.fn then
        local copyT = {}
        for i = 1, baseN do copyT[i] = baseTbl[i] end
        local resTbl, resN = spec.fn(copyT, baseN, ...)
        if type(resTbl) == "table" then
            return resTbl, resN or #resTbl
        end
        return copyT, baseN
    elseif spec.mode == "PATCH" and spec.evalFn then
        local okP, patch = pcall(spec.evalFn)
        if not okP or type(patch) ~= "table" then
            patch = spec.patchTbl or {}
        end
        local out = {}
        local maxN = baseN
        for i = 1, baseN do out[i] = baseTbl[i] end
        for k, v in pairs(patch) do
            if type(k) == "number" and k >= 1 and k == math.floor(k) then
                out[k] = v
                if k > maxN then maxN = k end
            end
        end
        return out, maxN
    elseif spec.evalFn then
        return Utils.packTuple(spec.evalFn())
    end
    return baseTbl, baseN
end

function Rules.applyArgSpoof(spec, origArgs, origN, remoteInst)
    return Rules.applyTupleSpoof(spec, origArgs, origN, remoteInst)
end

function Rules.applyReturnSpoof(spec, srvRets, srvN, callArgs, callN, remoteInst)
    return Rules.applyTupleSpoof(spec, srvRets, srvN, callArgs, callN, remoteInst)
end

function Rules.syncBridgeAttributes()
    local b = State.actorBridge
    if not b then return end
    local blockedOutList = {}
    for key, r in pairs(State.rules) do
        if r.blockOut then
            blockedOutList[#blockedOutList + 1] = key
        end
    end
    pcall(function()
        b:SetAttribute("BlockedOutKeys", "|" .. table.concat(blockedOutList, "|") .. "|")
        b:SetAttribute("CaptureExecutor", Config.captureExecutor)
    end)
end

-- ============================================================================
-- 4. RECORDING & STATS MANAGER
-- ============================================================================
local Recorder = {}

function Recorder.extractRemoteMeta(inst)
    local okName, rName = pcall(function() return inst.Name end)
    local okFull, rFull = pcall(function() return inst:GetFullName() end)
    local okCls, rCls = pcall(function() return inst.ClassName end)
    return {
        inst = inst,
        name = okName and rName or "?",
        fullPath = okFull and rFull or tostring(inst),
        luaPath = Parser.formatInstancePath(inst),
        className = okCls and rCls or "Remote",
    }
end

function Recorder.getCallerInfo()
    local callerName = "?"
    if Caps.getcallingscript then
        local okS, scr = pcall(Caps.getcallingscript)
        if okS and typeofFn(scr) == "Instance" then
            local okF, fn = pcall(function() return scr:GetFullName() end)
            callerName = okF and fn or scr.Name
        elseif okS and scr ~= nil then
            callerName = tostring(scr)
        end
    end
    local tb = Config.captureTraceback and debug and type(debug.traceback) == "function" and debug.traceback("", 4) or nil
    return callerName, tb
end

local RAW_SNAP_OPTS = { maxDepth = 12, maxItems = 1500, maxHex = 1024 }
local RAW_SER_OPTS = { pretty = false, maxDepth = 12, maxItems = 1500, maxStrLen = 65536, shortInst = false }

function Recorder.push(rec)
    if Config.paused and not Config.rawUnfiltered then return end
    rec.ts = os.clock()

    -- Snap full depth ngay luc goi de file raw khong cat xen va khong bi mutate sau call
    local origSnap = {}
    for i = 1, (rec.argN or 0) do
        origSnap[i] = Parser.cloneSnapshot(rec.origArgs and rec.origArgs[i], 0, {}, RAW_SNAP_OPTS)
    end
    rec.origArgs = origSnap

    if rec.argsSpoofed and rec.finalArgs then
        local fSnap = {}
        for i = 1, (rec.finalN or 0) do
            fSnap[i] = Parser.cloneSnapshot(rec.finalArgs[i], 0, {}, RAW_SNAP_OPTS)
        end
        rec.finalArgs = fSnap
    else
        rec.finalArgs = origSnap
        rec.finalN = rec.argN or 0
    end

    if rec.retN and rec.retN > 0 and rec.srvRets then
        local rSnap = {}
        for i = 1, rec.retN do
            rSnap[i] = Parser.cloneSnapshot(rec.srvRets[i], 0, {}, RAW_SNAP_OPTS)
        end
        rec.srvRets = rSnap
    end
    if rec.retSpoofed and rec.outRets then
        local srSnap = {}
        for i = 1, (rec.outRetN or 0) do
            srSnap[i] = Parser.cloneSnapshot(rec.outRets[i], 0, {}, RAW_SNAP_OPTS)
        end
        rec.outRets = srSnap
    end

    local useArgs = rec.finalArgs
    local useN = rec.finalN or 0
    local rawArgsStr = useN > 0 and Parser.serializeTuple(useArgs, useN, RAW_SER_OPTS) or ""
    local rawRetStr = (rec.retN and rec.retN > 0) and Parser.serializeTuple(rec.srvRets, rec.retN, RAW_SER_OPTS) or nil
    local rawExtra = ""
    if rec.argsSpoofed and (rec.argN or 0) > 0 then
        rawExtra = rawExtra .. " | ORIG(" .. Parser.serializeTuple(origSnap, rec.argN, RAW_SER_OPTS) .. ")"
    end
    if rec.retSpoofed and (rec.outRetN or 0) > 0 then
        rawExtra = rawExtra .. " | SPOOF_RET(" .. Parser.serializeTuple(rec.outRets, rec.outRetN, RAW_SER_OPTS) .. ")"
    end

    -- Luon ghi FULL 100% khong chon loc vao file RAW (ke ca khi Ignore/Mute o UI)
    if Config.rawUnfiltered or not rec.uiHidden then
        local rawLine = string.format(
            "[%s][%s][%s] %s:%s(%s)%s%s%s",
            rec.dir,
            rec.status or "OK",
            rec.sourceTag or "MAIN",
            rec.remotePath,
            rec.method,
            rawArgsStr,
            rawRetStr and (" => RET(" .. rawRetStr .. ")") or "",
            rawExtra,
            rec.callerName and (" | caller=" .. rec.callerName) or ""
        )
        LogWriter.pushLine(rawLine)
    end

    if Config.paused or rec.uiHidden then
        return
    end

    State.nextId = State.nextId + 1
    rec.id = State.nextId

    local previewOpts = { pretty = false, maxDepth = 2, maxItems = 12, maxStrLen = 64, shortInst = true }
    rec.preview = useN > 0 and Parser.serializeTuple(useArgs, useN, previewOpts) or ""
    if rawRetStr then
        rec.retPreview = Parser.serializeTuple(rec.srvRets, rec.retN, previewOpts)
    end

    -- Cap nhat counters & grouped map
    State.stats.total = State.stats.total + 1
    if rec.dir == "OUT" then State.stats.outC = State.stats.outC + 1 else State.stats.inC = State.stats.inC + 1 end
    if rec.retN and rec.retN > 0 then State.stats.retC = State.stats.retC + 1 end
    if rec.status == "BLOCKED" or rec.status == "BLK+SPF" then State.stats.blkC = State.stats.blkC + 1 end
    if rec.argsSpoofed or rec.retSpoofed then State.stats.spfC = State.stats.spfC + 1 end

    local gKey = rec.sig1 and (rec.remotePath .. "::" .. rec.sig1) or rec.remotePath
    local grp = State.grouped[gKey]
    if not grp then
        grp = {
            key = gKey,
            name = rec.remoteName,
            path = rec.remotePath,
            sig1 = rec.sig1,
            sig2 = rec.sig2,
            count = 0,
            outC = 0,
            inC = 0,
            retC = 0,
            blkC = 0,
            spfC = 0,
            lastId = rec.id,
        }
        State.grouped[gKey] = grp
    end
    grp.count = grp.count + 1
    if rec.dir == "OUT" then grp.outC = grp.outC + 1 else grp.inC = grp.inC + 1 end
    if rec.retN and rec.retN > 0 then grp.retC = grp.retC + 1 end
    if rec.status == "BLOCKED" or rec.status == "BLK+SPF" then grp.blkC = grp.blkC + 1 end
    if rec.argsSpoofed or rec.retSpoofed then grp.spfC = grp.spfC + 1 end
    grp.lastId = rec.id

    -- Ring buffer luu trong RAM
    State.entries[#State.entries + 1] = rec
    State.entryById[rec.id] = rec
    if #State.entries > MAX_MEMORY_ENTRIES then
        local dropped = table.remove(State.entries, 1)
        if dropped then
            State.entryById[dropped.id] = nil
        end
    end

    if AoTRTools.onRemoteCaptured then
        pcall(AoTRTools.onRemoteCaptured, rec)
    end
    State.pendingUiFlush = true
end

-- ============================================================================
-- 5. HOOKS: OUTGOING (__namecall + hookfunction), INCOMING (OnClientEvent + OnClientInvoke), ACTORS
-- ============================================================================
local Hooks = {}

local OUTGOING_REMOTE_METHODS = {
    FireServer = "RE",
    InvokeServer = "RF",
    Fire = "BE",
    Invoke = "BF",
}

local function isTargetRemoteForKind(inst, kind)
    if typeofFn(inst) ~= "Instance" then return false end
    if inst == State.actorBridge then return false end
    if kind == "RE" then
        return inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent")
    elseif kind == "RF" then
        return inst:IsA("RemoteFunction")
    elseif (kind == "BE" or kind == "BF") and Config.captureBindables then
        return inst:IsA("BindableEvent") or inst:IsA("BindableFunction")
    end
    return false
end

function Hooks.handleOutgoing(sourceKind, method, selfObj, oldFn, ...)
    local co = Utils.getThreadKey()
    if State.internalThreads[co] then
        return oldFn(selfObj, ...)
    end

    if sourceKind == "FN" then
        local d = State.dispatch[co]
        if d and d.remote == selfObj and d.method == method and (os.clock() - d.t) < 0.005 then
            State.dispatch[co] = nil
            return oldFn(selfObj, ...)
        end
    end

    local kind = OUTGOING_REMOTE_METHODS[method]
    if not kind then
        return oldFn(selfObj, ...)
    end

    State.internalThreads[co] = true
    local okKind, validTarget = pcall(isTargetRemoteForKind, selfObj, kind)
    State.internalThreads[co] = nil
    if not okKind or not validTarget then
        return oldFn(selfObj, ...)
    end

    local isExec = Caps.checkcaller and Caps.checkcaller() or false
    if isExec and not Config.captureExecutor then
        return oldFn(selfObj, ...)
    end

    local argN = select("#", ...)
    local origArgs = { ... }

    State.internalThreads[co] = true
    local meta, sig1, sig2, rule, isIgnored, callerName, traceback
    local finalArgs, finalN, argsSpoofed = origArgs, argN, false
    local blockedOut = false

    pcall(function()
        meta = Recorder.extractRemoteMeta(selfObj)
        sig1 = type(origArgs[1]) == "string" and origArgs[1] or nil
        sig2 = type(origArgs[2]) == "string" and origArgs[2] or nil
        rule = Rules.resolve(meta.fullPath, sig1, sig2)
        isIgnored = (rule and rule.ignore) or (Config.muteNoisePreset and sig1 and NOISE_ARG1[sig1]) or false
        blockedOut = rule and rule.blockOut or false
        callerName, traceback = Recorder.getCallerInfo()

        if rule and rule.spoofOutArgs and rule.spoofOutArgs.active then
            local okS, repArgs, repN = pcall(Rules.applyArgSpoof, rule.spoofOutArgs, origArgs, argN, selfObj)
            if okS and type(repArgs) == "table" then
                finalArgs = repArgs
                finalN = repN or 0
                argsSpoofed = true
            end
        end
    end)
    State.internalThreads[co] = nil

    if not meta then
        return oldFn(selfObj, ...)
    end

    local sourceTag = (isExec and "EXEC:" or "") .. sourceKind

    -- Truong hop bi chan (BLOCK OUT)
    if blockedOut then
        if method == "InvokeServer" or method == "Invoke" then
            local outRets, outRetN, retSpoofed = {}, 0, false
            if rule and rule.spoofOutReturn and rule.spoofOutReturn.active then
                State.internalThreads[co] = true
                local okR, rT, rN = pcall(Rules.applyReturnSpoof, rule.spoofOutReturn, {}, 0, finalArgs, finalN, selfObj)
                State.internalThreads[co] = nil
                if okR and type(rT) == "table" then
                    outRets, outRetN, retSpoofed = rT, rN or 0, true
                end
            end
            State.internalThreads[co] = true
            pcall(Recorder.push, {
                uiHidden = isIgnored,
                dir = "OUT",
                method = method,
                sourceTag = sourceTag,
                remoteName = meta.name,
                remotePath = meta.fullPath,
                luaPath = meta.luaPath,
                sig1 = sig1,
                sig2 = sig2,
                argN = argN,
                origArgs = origArgs,
                finalArgs = finalArgs,
                finalN = finalN,
                argsSpoofed = argsSpoofed,
                outRets = outRets,
                outRetN = outRetN,
                retSpoofed = retSpoofed,
                status = retSpoofed and "BLK+SPF" or "BLOCKED",
                callerName = callerName,
                traceback = traceback,
            })
            State.internalThreads[co] = nil
            return unpackFn(outRets, 1, outRetN)
        else
            State.internalThreads[co] = true
            pcall(Recorder.push, {
                uiHidden = isIgnored,
                dir = "OUT",
                method = method,
                sourceTag = sourceTag,
                remoteName = meta.name,
                remotePath = meta.fullPath,
                luaPath = meta.luaPath,
                sig1 = sig1,
                sig2 = sig2,
                argN = argN,
                origArgs = origArgs,
                finalArgs = finalArgs,
                finalN = finalN,
                argsSpoofed = argsSpoofed,
                status = "BLOCKED",
                callerName = callerName,
                traceback = traceback,
            })
            State.internalThreads[co] = nil
            return
        end
    end

    if sourceKind == "NC" then
        State.dispatch[co] = { remote = selfObj, method = method, t = os.clock() }
    end

    if method == "FireServer" or method == "Fire" then
        State.internalThreads[co] = true
        pcall(Recorder.push, {
            uiHidden = isIgnored,
            dir = "OUT",
            method = method,
            sourceTag = sourceTag,
            remoteName = meta.name,
            remotePath = meta.fullPath,
            luaPath = meta.luaPath,
            sig1 = sig1,
            sig2 = sig2,
            argN = argN,
            origArgs = origArgs,
            finalArgs = finalArgs,
            finalN = finalN,
            argsSpoofed = argsSpoofed,
            status = argsSpoofed and "SPOOFED" or "OK",
            callerName = callerName,
            traceback = traceback,
        })
        State.internalThreads[co] = nil
        oldFn(selfObj, unpackFn(finalArgs, 1, finalN))
        State.dispatch[co] = nil
        return
    end

    -- InvokeServer / Invoke: bat tron ven Server Return (giu nguyen tail/yield semantics)
    local tStart = os.clock()
    local function finishInvoke(...)
        State.dispatch[co] = nil
        local elapsedMs = (os.clock() - tStart) * 1000
        local srvRetN = select("#", ...)
        local srvRets = { ... }
        local outRets, outRetN, retSpoofed = srvRets, srvRetN, false

        if rule and rule.spoofOutReturn and rule.spoofOutReturn.active then
            State.internalThreads[co] = true
            local okR, rT, rN = pcall(Rules.applyReturnSpoof, rule.spoofOutReturn, srvRets, srvRetN, finalArgs, finalN, selfObj)
            State.internalThreads[co] = nil
            if okR and type(rT) == "table" then
                outRets, outRetN, retSpoofed = rT, rN or 0, true
            end
        end

        State.internalThreads[co] = true
        pcall(Recorder.push, {
            uiHidden = isIgnored,
            dir = "OUT",
            method = method,
            sourceTag = sourceTag,
            remoteName = meta.name,
            remotePath = meta.fullPath,
            luaPath = meta.luaPath,
            sig1 = sig1,
            sig2 = sig2,
            argN = argN,
            origArgs = origArgs,
            finalArgs = finalArgs,
            finalN = finalN,
            argsSpoofed = argsSpoofed,
            srvRets = srvRets,
            retN = srvRetN,
            outRets = outRets,
            outRetN = outRetN,
            retSpoofed = retSpoofed,
            elapsedMs = elapsedMs,
            status = (argsSpoofed or retSpoofed) and "SPOOFED" or "OK",
            callerName = callerName,
            traceback = traceback,
        })
        State.internalThreads[co] = nil
        return unpackFn(outRets, 1, outRetN)
    end
    return finishInvoke(oldFn(selfObj, unpackFn(finalArgs, 1, finalN)))
end

function Hooks.wrapOnClientInvoke(rfInst, origCb)
    if type(origCb) ~= "function" then return origCb end
    if Persistent.wrappedClientInvokes[origCb] then return origCb end

    local wrapper = function(...)
        local co = Utils.getThreadKey()
        if State.internalThreads[co] then
            return origCb(...)
        end
        local argN = select("#", ...)
        local origArgs = { ... }

        State.internalThreads[co] = true
        local meta, sig1, sig2, rule, isIgnored
        local finalArgs, finalN, argsSpoofed = origArgs, argN, false
        local blockedIn = false
        pcall(function()
            meta = Recorder.extractRemoteMeta(rfInst)
            sig1 = type(origArgs[1]) == "string" and origArgs[1] or nil
            sig2 = type(origArgs[2]) == "string" and origArgs[2] or nil
            rule = Rules.resolve(meta.fullPath, sig1, sig2)
            isIgnored = (rule and rule.ignore) or (Config.muteNoisePreset and sig1 and NOISE_ARG1[sig1]) or false
            blockedIn = rule and rule.blockIn or false
            if rule and rule.spoofInArgs and rule.spoofInArgs.active then
                local okS, repA, repN = pcall(Rules.applyArgSpoof, rule.spoofInArgs, origArgs, argN, rfInst)
                if okS and type(repA) == "table" then
                    finalArgs, finalN, argsSpoofed = repA, repN or 0, true
                end
            end
        end)
        State.internalThreads[co] = nil

        if blockedIn then
            local retT, retN, retSpoofed = {}, 0, false
            if rule and rule.spoofOutReturn and rule.spoofOutReturn.active then
                State.internalThreads[co] = true
                local okR, rT, rN = pcall(Rules.applyReturnSpoof, rule.spoofOutReturn, {}, 0, finalArgs, finalN, rfInst)
                State.internalThreads[co] = nil
                if okR and type(rT) == "table" then
                    retT, retN, retSpoofed = rT, rN or 0, true
                end
            end
            if meta then
                State.internalThreads[co] = true
                pcall(Recorder.push, {
                    uiHidden = isIgnored,
                    dir = "IN",
                    method = "OnClientInvoke",
                    sourceTag = "SRV",
                    remoteName = meta.name,
                    remotePath = meta.fullPath,
                    luaPath = meta.luaPath,
                    sig1 = sig1,
                    sig2 = sig2,
                    argN = argN,
                    origArgs = origArgs,
                    finalArgs = finalArgs,
                    finalN = finalN,
                    argsSpoofed = argsSpoofed,
                    outRets = retT,
                    outRetN = retN,
                    retSpoofed = retSpoofed,
                    status = retSpoofed and "BLK+SPF" or "BLOCKED",
                    callerName = "Server",
                })
                State.internalThreads[co] = nil
            end
            return unpackFn(retT, 1, retN)
        end

        local function finishClientInvoke(...)
            local cliRetN = select("#", ...)
            local cliRets = { ... }
            local outRets, outRetN, retSpoofed = cliRets, cliRetN, false
            if rule and rule.spoofOutReturn and rule.spoofOutReturn.active then
                State.internalThreads[co] = true
                local okR, rT, rN = pcall(Rules.applyReturnSpoof, rule.spoofOutReturn, cliRets, cliRetN, finalArgs, finalN, rfInst)
                State.internalThreads[co] = nil
                if okR and type(rT) == "table" then
                    outRets, outRetN, retSpoofed = rT, rN or 0, true
                end
            end
            if meta then
                State.internalThreads[co] = true
                pcall(Recorder.push, {
                    uiHidden = isIgnored,
                    dir = "IN",
                    method = "OnClientInvoke",
                    sourceTag = "SRV",
                    remoteName = meta.name,
                    remotePath = meta.fullPath,
                    luaPath = meta.luaPath,
                    sig1 = sig1,
                    sig2 = sig2,
                    argN = argN,
                    origArgs = origArgs,
                    finalArgs = finalArgs,
                    finalN = finalN,
                    argsSpoofed = argsSpoofed,
                    srvRets = cliRets,
                    retN = cliRetN,
                    outRets = outRets,
                    outRetN = outRetN,
                    retSpoofed = retSpoofed,
                    status = (argsSpoofed or retSpoofed) and "SPOOFED" or "OK",
                    callerName = "Server",
                })
                State.internalThreads[co] = nil
            end
            return unpackFn(outRets, 1, outRetN)
        end
        return finishClientInvoke(origCb(unpackFn(finalArgs, 1, finalN)))
    end
    Persistent.wrappedClientInvokes[wrapper] = true
    return wrapper
end

function Hooks.syncIncomingControlsForRemote(inst)
    if not (Caps.getconnections and typeofFn(inst) == "Instance") then return end
    local sig
    local okSig = pcall(function()
        if inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") then
            sig = inst.OnClientEvent
        elseif inst:IsA("BindableEvent") and Config.captureBindables then
            sig = inst.Event
        end
    end)
    if not (okSig and sig) then return end

    local okF, fullPath = pcall(function() return inst:GetFullName() end)
    if not okF then return end

    local r0 = State.rules["R::" .. fullPath]
    local wholeBlocked = r0 and r0.blockIn or false
    local needGranular = false
    for key, r in pairs(State.rules) do
        if (r.blockIn or (r.spoofInArgs and r.spoofInArgs.active)) and key:find(fullPath, 1, true) then
            needGranular = true
            break
        end
    end

    local okC, conns = pcall(Caps.getconnections, sig)
    if not (okC and type(conns) == "table") then return end

    for _, conn in ipairs(conns) do
        local fn
        pcall(function() fn = conn.Function end)
        if not (fn and Persistent.ourSignalCallbacks[fn]) then
            if wholeBlocked then
                pcall(function()
                    if type(conn.Disable) == "function" then
                        conn:Disable()
                        Persistent.disabledConns[conn] = inst
                    end
                end)
            else
                if Persistent.disabledConns[conn] then
                    pcall(function()
                        if type(conn.Enable) == "function" then
                            conn:Enable()
                        end
                    end)
                    Persistent.disabledConns[conn] = nil
                end
                if needGranular and Caps.hookfunction and type(fn) == "function" and not Persistent.hookedInCallbacks[fn] then
                    local isLua = not Caps.islclosure or Caps.islclosure(fn)
                    if isLua then
                        Persistent.hookedInMeta[fn] = { inst = inst, fullPath = fullPath }
                        pcall(function()
                            local origFn
                            local hookedFn = Caps.newcclosure(function(...)
                                local h = Persistent.handlers.onIncomingCallback
                                local metaInfo = Persistent.hookedInMeta[fn]
                                if h and metaInfo then
                                    return h(metaInfo.inst, metaInfo.fullPath, origFn, ...)
                                end
                                return origFn(...)
                            end)
                            origFn = Caps.hookfunction(fn, hookedFn)
                            Persistent.hookedInCallbacks[fn] = true
                            Persistent.hookedInCallbacks[hookedFn] = true
                        end)
                    end
                end
            end
        end
    end
end

function Hooks.syncAllIncomingControls()
    if not Caps.getconnections then return end
    for inst, _ in pairs(Persistent.boundRemotes) do
        local okF, full = pcall(function() return inst:GetFullName() end)
        if okF then
            for _, r in pairs(State.rules) do
                if r.key:find(full, 1, true) then
                    Hooks.syncIncomingControlsForRemote(inst)
                    break
                end
            end
        end
    end
    for conn, inst in pairs(Persistent.disabledConns) do
        local okF, full = pcall(function() return inst:GetFullName() end)
        local r0 = okF and State.rules["R::" .. full]
        if not (r0 and r0.blockIn) then
            pcall(function()
                if type(conn.Enable) == "function" then conn:Enable() end
            end)
            Persistent.disabledConns[conn] = nil
        end
    end
end

function Hooks.bindIncomingRemote(inst)
    if typeofFn(inst) ~= "Instance" or inst == State.actorBridge then return end
    if Persistent.boundRemotes[inst] then return end

    local co = Utils.getThreadKey()
    State.internalThreads[co] = true
    local okBind = pcall(function()
        if inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") or (Config.captureBindables and inst:IsA("BindableEvent")) then
            local sig = inst:IsA("BindableEvent") and inst.Event or inst.OnClientEvent
            local cb = function(...)
                if not State.running then return end
                local argN = select("#", ...)
                local origArgs = { ... }
                local c = Utils.getThreadKey()
                State.internalThreads[c] = true
                pcall(function()
                    local meta = Recorder.extractRemoteMeta(inst)
                    local sig1 = type(origArgs[1]) == "string" and origArgs[1] or nil
                    local sig2 = type(origArgs[2]) == "string" and origArgs[2] or nil
                    local rule = Rules.resolve(meta.fullPath, sig1, sig2)
                    local isIgnored = (rule and rule.ignore) or (Config.muteNoisePreset and sig1 and NOISE_ARG1[sig1]) or false

                    local finalArgs, finalN, argsSpoofed = origArgs, argN, false
                    local blockedIn = rule and rule.blockIn or false
                    if rule and rule.spoofInArgs and rule.spoofInArgs.active then
                        local okS, repA, repN = pcall(Rules.applyArgSpoof, rule.spoofInArgs, origArgs, argN, inst)
                        if okS and type(repA) == "table" then
                            finalArgs, finalN, argsSpoofed = repA, repN or 0, true
                        end
                    end

                    local status = "OK"
                    if blockedIn and argsSpoofed then
                        status = "BLK+SPF"
                    elseif blockedIn then
                        status = "BLOCKED"
                    elseif argsSpoofed then
                        status = "SPOOFED"
                    end

                    Recorder.push({
                        uiHidden = isIgnored,
                        dir = "IN",
                        method = inst:IsA("BindableEvent") and "BindableEvent" or "OnClientEvent",
                        sourceTag = "SRV",
                        remoteName = meta.name,
                        remotePath = meta.fullPath,
                        luaPath = meta.luaPath,
                        sig1 = sig1,
                        sig2 = sig2,
                        argN = argN,
                        origArgs = origArgs,
                        finalArgs = finalArgs,
                        finalN = finalN,
                        argsSpoofed = argsSpoofed,
                        status = status,
                        callerName = "Server",
                    })
                end)
                State.internalThreads[c] = nil
            end
            Persistent.ourSignalCallbacks[cb] = true
            local conn = sig:Connect(cb)
            Utils.trackConn(conn)
            Persistent.boundRemotes[inst] = conn
            Hooks.syncIncomingControlsForRemote(inst)
        elseif inst:IsA("RemoteFunction") then
            Persistent.boundRemotes[inst] = true
            if Caps.getcallbackvalue then
                local okCb, existingCb = pcall(Caps.getcallbackvalue, inst, "OnClientInvoke")
                if okCb and type(existingCb) == "function" and not Persistent.wrappedClientInvokes[existingCb] then
                    inst.OnClientInvoke = Hooks.wrapOnClientInvoke(inst, existingCb)
                end
            end
        end
    end)
    State.internalThreads[co] = nil
    return okBind
end

function Hooks.installAll()
    -- Gan delegate cho trampoline
    Persistent.handlers.onNamecall = function(oldNamecall, self, ...)
        local method = Caps.getnamecallmethod and Caps.getnamecallmethod() or nil
        if not method or not State.running then
            return oldNamecall(self, ...)
        end
        return Hooks.handleOutgoing("NC", method, self, oldNamecall, ...)
    end

    Persistent.handlers.onNewIndex = function(oldNewIndex, self, key, val)
        if State.running and key == "OnClientInvoke" and type(val) == "function" then
            local co = Utils.getThreadKey()
            if not State.internalThreads[co] then
                State.internalThreads[co] = true
                local okIsRF, isRF = pcall(function()
                    return typeofFn(self) == "Instance" and self:IsA("RemoteFunction")
                end)
                State.internalThreads[co] = nil
                if okIsRF and isRF then
                    val = Hooks.wrapOnClientInvoke(self, val)
                end
            end
        end
        return oldNewIndex(self, key, val)
    end

    Persistent.handlers.onDirectMethod = function(methodName, oldFn, self, ...)
        if not State.running then
            return oldFn(self, ...)
        end
        return Hooks.handleOutgoing("FN", methodName, self, oldFn, ...)
    end

    Persistent.handlers.onIncomingCallback = function(inst, fullPath, origFn, ...)
        if not State.running then
            return origFn(...)
        end
        local co = Utils.getThreadKey()
        if State.internalThreads[co] then
            return origFn(...)
        end
        local n = select("#", ...)
        local args = { ... }
        local s1 = type(args[1]) == "string" and args[1] or nil
        local s2 = type(args[2]) == "string" and args[2] or nil
        local rule = Rules.resolve(fullPath, s1, s2)
        if rule and rule.blockIn then
            return nil
        end
        if rule and rule.spoofInArgs and rule.spoofInArgs.active then
            local okS, repA, repN = pcall(Rules.applyArgSpoof, rule.spoofInArgs, args, n, inst)
            if okS and type(repA) == "table" then
                return origFn(unpackFn(repA, 1, repN or 0))
            end
        end
        return origFn(...)
    end

    -- 1. Install __namecall trampoline (1 lan duy nhat)
    if not Persistent.installed.namecall and Caps.hookmetamethod and Caps.getnamecallmethod then
        local okNC = pcall(function()
            local oldNC
            oldNC = Caps.hookmetamethod(game, "__namecall", Caps.newcclosure(function(self, ...)
                local h = Persistent.handlers.onNamecall
                if h then
                    return h(oldNC, self, ...)
                end
                return oldNC(self, ...)
            end))
            Persistent.oldFns.namecall = oldNC
            Persistent.installed.namecall = true
        end)
    end

    -- 2. Install __newindex trampoline (de bat OnClientInvoke tu Server)
    if not Persistent.installed.newindex and Caps.hookmetamethod then
        pcall(function()
            local oldNI
            oldNI = Caps.hookmetamethod(game, "__newindex", Caps.newcclosure(function(self, k, v)
                local h = Persistent.handlers.onNewIndex
                if h then
                    return h(oldNI, self, k, v)
                end
                return oldNI(self, k, v)
            end))
            Persistent.installed.newindex = true
        end)
    end

    -- 3. Install direct method hookfunction cho FireServer / InvokeServer / UnreliableRemoteEvent
    if not Persistent.installed.directFns and Caps.hookfunction then
        local function hookClassMethod(className, methodName)
            pcall(function()
                local tmp = Instance.new(className)
                local targetFn = tmp[methodName]
                local oldFn
                oldFn = Caps.hookfunction(targetFn, Caps.newcclosure(function(self, ...)
                    local h = Persistent.handlers.onDirectMethod
                    if h then
                        return h(methodName, oldFn, self, ...)
                    end
                    return oldFn(self, ...)
                end))
                tmp:Destroy()
            end)
        end
        hookClassMethod("RemoteEvent", "FireServer")
        hookClassMethod("UnreliableRemoteEvent", "FireServer")
        hookClassMethod("RemoteFunction", "InvokeServer")
        hookClassMethod("BindableEvent", "Fire")
        hookClassMethod("BindableFunction", "Invoke")
        Persistent.installed.directFns = true
    end

    -- 4. Scan va bind tat ca Remote hien co + DescendantAdded
    local safeRoots = {
        Services.ReplicatedStorage,
        Services.ReplicatedFirst,
        Services.Workspace,
        Services.Players,
        Services.Lighting,
        Services.SoundService,
        Services.StarterGui,
        Services.StarterPack,
        Services.StarterPlayer,
    }
    function Hooks.scanSafeRoots(includeBindables)
        for _, root in ipairs(safeRoots) do
            if root then
                pcall(function()
                    for _, d in ipairs(root:GetDescendants()) do
                        if d:IsA("RemoteEvent") or d:IsA("UnreliableRemoteEvent") or d:IsA("RemoteFunction")
                            or (includeBindables and d:IsA("BindableEvent"))
                        then
                            Hooks.bindIncomingRemote(d)
                        end
                    end
                end)
            end
        end
    end

    Hooks.scanSafeRoots(Config.captureBindables)
    for _, root in ipairs(safeRoots) do
        if root then
            Utils.trackConn(root.DescendantAdded:Connect(function(d)
                if d:IsA("RemoteEvent") or d:IsA("UnreliableRemoteEvent") or d:IsA("RemoteFunction")
                    or (Config.captureBindables and d:IsA("BindableEvent"))
                then
                    task.defer(Hooks.bindIncomingRemote, d)
                end
            end))
        end
    end

    if Hooks.bindRaidColoWatchers then
        pcall(Hooks.bindRaidColoWatchers)
    end

    -- Watchdog nhe cho rules Incoming moi
    task.spawn(function()
        while State.running do
            task.wait(0.45)
            pcall(Hooks.syncAllIncomingControls)
        end
    end)
end

function Hooks.ensureActorBridge()
    if State.actorBridge and State.actorBridge.Parent then
        return State.actorBridge
    end
    local huiHost = nil
    if Caps.gethui then
        local okH, h = pcall(Caps.gethui)
        if okH and h then huiHost = h end
    end
    local host = huiHost or Services.CoreGui
    if not host then return nil end

    local existing = host:FindFirstChild(BRIDGE_NAME)
    if existing and existing:IsA("BindableEvent") then
        State.actorBridge = existing
    else
        local be = Instance.new("BindableEvent")
        be.Name = BRIDGE_NAME
        be.Parent = host
        State.actorBridge = be
    end

    Utils.trackConn(State.actorBridge.Event:Connect(function(dir, method, rName, rPath, actorName, preview, codeBody, blockedFlag, retPreview)
        if not State.running then return end
        local sig1 = nil
        local s1Match = tostring(preview or ""):match('^"([^"]+)"')
        if s1Match then sig1 = s1Match end

        Recorder.push({
            dir = dir or "OUT",
            method = method or "ActorSend",
            sourceTag = "ACTOR:" .. tostring(actorName or "?"),
            remoteName = rName or "ActorRemote",
            remotePath = rPath or tostring(actorName),
            luaPath = rPath or tostring(rName),
            sig1 = sig1,
            argN = 1,
            origArgs = { preview or "" },
            retN = (retPreview and #retPreview > 0) and 1 or 0,
            srvRets = (retPreview and #retPreview > 0) and { retPreview } or nil,
            status = blockedFlag and "BLOCKED" or "OK",
            callerName = "Actor:" .. tostring(actorName or "?"),
            actorRawPreview = preview,
            actorRawCode = codeBody,
        })
    end))
    Rules.syncBridgeAttributes()
    return State.actorBridge
end

function Hooks.injectActors()
    if not (Caps.getactors and Caps.runOnActor) then
        return 0, "Executor khong ho tro getactors / run_on_actor"
    end
    local bridge = Hooks.ensureActorBridge()
    if not bridge then
        return 0, "Khong tao duoc Actor Bridge"
    end
    Rules.syncBridgeAttributes()

    local okA, actors = pcall(Caps.getactors)
    if not (okA and type(actors) == "table") then
        return 0, "getactors loi: " .. tostring(actors)
    end

    local actorSource = [===[
        local g = (type(getgenv) == "function" and getgenv()) or _G
        if g.__SIGMA_ACTOR_HOOKED then return end
        g.__SIGMA_ACTOR_HOOKED = true

        local CoreGui = game:GetService("CoreGui")
        local function findBridge()
            local b = CoreGui:FindFirstChild("__AOTR_SigmaSpyBridge")
            if b then return b end
            if type(gethui) == "function" then
                local okH, h = pcall(gethui)
                if okH and h then
                    return h:FindFirstChild("__AOTR_SigmaSpyBridge")
                end
            end
            return nil
        end

        local actorName = "?"
        pcall(function()
            local scr = getcallingscript and getcallingscript()
            actorName = scr and scr:GetFullName() or tostring(script)
        end)

        local function serVal(v, d)
            d = d or 0
            local tv = typeof(v)
            if tv == "string" then return string.format("%q", #v > 120 and v:sub(1, 120) or v)
            elseif tv == "number" or tv == "boolean" or tv == "nil" then return tostring(v)
            elseif tv == "Vector3" then return string.format("Vector3.new(%.4g, %.4g, %.4g)", v.X, v.Y, v.Z)
            elseif tv == "CFrame" then return string.format("CFrame.new(%.3g, %.3g, %.3g)", v.X, v.Y, v.Z)
            elseif tv == "Instance" then
                local okF, f = pcall(function() return v:GetFullName() end)
                return okF and f or v.Name
            elseif tv == "table" then
                if d >= 3 then return "{...}" end
                local p, c = {}, 0
                for k, vv in next, v do
                    c = c + 1
                    if c > 20 then p[#p + 1] = "..."; break end
                    p[#p + 1] = tostring(k) .. "=" .. serVal(vv, d + 1)
                end
                return "{" .. table.concat(p, ", ") .. "}"
            end
            return tostring(v)
        end

        local function serArgs(t, n)
            local p = {}
            for i = 1, n do p[i] = serVal(t[i], 0) end
            return table.concat(p, ", ")
        end

        if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
            local inSelf = false
            local oldNC
            oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                if inSelf then return oldNC(self, ...) end
                local m = getnamecallmethod()
                if m == "FireServer" or m == "InvokeServer" then
                    local okInst = typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("UnreliableRemoteEvent") or self:IsA("RemoteFunction"))
                    if okInst then
                        local n = select("#", ...)
                        local args = { ... }
                        inSelf = true
                        local bridge = findBridge()
                        local rName, rPath = "?", "?"
                        pcall(function() rName = self.Name; rPath = self:GetFullName() end)
                        local preview = serArgs(args, n)
                        local isBlocked = false
                        if bridge then
                            local bStr = tostring(bridge:GetAttribute("BlockedOutKeys") or "")
                            local s1 = type(args[1]) == "string" and args[1] or ""
                            if bStr:find("|R::" .. rPath .. "|", 1, true) or (s1 ~= "" and bStr:find("|S1::" .. rPath .. "::" .. s1 .. "|", 1, true)) then
                                isBlocked = true
                            end
                        end
                        inSelf = false

                        if isBlocked then
                            if bridge then pcall(bridge.Fire, bridge, "OUT", m, rName, rPath, actorName, preview, "", true, "") end
                            return nil
                        end

                        if m == "FireServer" then
                            if bridge then pcall(bridge.Fire, bridge, "OUT", m, rName, rPath, actorName, preview, "", false, "") end
                            return oldNC(self, ...)
                        else
                            local function onRet(...)
                                local rn = select("#", ...)
                                local rt = { ... }
                                inSelf = true
                                local retStr = serArgs(rt, rn)
                                if bridge then pcall(bridge.Fire, bridge, "OUT", m, rName, rPath, actorName, preview, "", false, retStr) end
                                inSelf = false
                                return unpack(rt, 1, rn)
                            end
                            return onRet(oldNC(self, ...))
                        end
                    end
                end
                return oldNC(self, ...)
            end)
        end
    ]===]

    local injected = 0
    for _, act in ipairs(actors) do
        local okR = pcall(Caps.runOnActor, act, actorSource)
        if okR then injected = injected + 1 end
    end
    State.actorsHookedCount = State.actorsHookedCount + injected
    return injected, string.format("Da tiem %d/%d Actors", injected, #actors)
end


-- ============================================================================
-- 6B. RAW UNFILTERED DUMPER (-> aotr_raw_all.txt) & EXTRACTOR (-> aotr_extracted_data.txt)
-- ============================================================================
local RawDumper = {}
local Extractor = {}
local UI = {}

local COLORS = {
    bg = Color3.fromRGB(16, 19, 27),
    panel = Color3.fromRGB(23, 27, 38),
    card = Color3.fromRGB(30, 35, 50),
    cardSel = Color3.fromRGB(45, 56, 84),
    border = Color3.fromRGB(58, 72, 105),
    text = Color3.fromRGB(232, 236, 245),
    muted = Color3.fromRGB(150, 160, 185),
    outFire = Color3.fromRGB(78, 178, 255),
    outInvoke = Color3.fromRGB(182, 126, 255),
    inEvent = Color3.fromRGB(74, 222, 138),
    inInvoke = Color3.fromRGB(46, 214, 195),
    blocked = Color3.fromRGB(255, 90, 102),
    spoofed = Color3.fromRGB(255, 208, 72),
    accent = Color3.fromRGB(72, 136, 248),
    green = Color3.fromRGB(44, 158, 92),
    red = Color3.fromRGB(190, 58, 66),
    amber = Color3.fromRGB(205, 136, 38),
}

function Parser.fmtAttrs(inst)
    local ok, attrs = pcall(function() return inst:GetAttributes() end)
    if not ok or type(attrs) ~= "table" then return "{}" end
    local out = {}
    for k, v in pairs(attrs) do
        out[#out + 1] = tostring(k) .. "=" .. Parser.serializeValue(v, 0, { maxDepth = 2, shortInst = true })
    end
    table.sort(out)
    return "{" .. table.concat(out, ", ") .. "}"
end

local function isOwnSpyObject(tbl)
    return tbl == State or tbl == Config or tbl == Persistent or tbl == Services or tbl == Caps
        or tbl == Utils or tbl == Parser or tbl == Rules or tbl == Recorder or tbl == Hooks
        or tbl == AoTRTools or tbl == RawDumper or tbl == Extractor or tbl == State.entries
        or tbl == State.entryById or tbl == State.grouped or tbl == State.rules
end

local function flushBatchLines(lines, threshold)
    if #lines >= (threshold or 250) then
        LogWriter.writeLines(lines)
        for i = #lines, 1, -1 do lines[i] = nil end
    end
end

function RawDumper.dumpServiceTree(rootInst, tagPrefix, outLines, seenCountRef)
    if not rootInst then return end
    local okDesc, desc = pcall(function() return rootInst:GetDescendants() end)
    if not (okDesc and type(desc) == "table") then return end

    local list = { rootInst }
    for _, d in ipairs(desc) do list[#list + 1] = d end

    for _, d in ipairs(list) do
        seenCountRef.n = seenCountRef.n + 1
        if seenCountRef.n % 500 == 0 then
            flushBatchLines(outLines, 1)
            task.wait()
        end
        pcall(function()
            local okF, full = pcall(function() return d:GetFullName() end)
            local pathStr = okF and full or d.Name
            local attrs = Parser.fmtAttrs(d)
            if attrs ~= "{}" then
                outLines[#outLines + 1] = string.format("[%s_ATTR] %s [%s] %s", tagPrefix, pathStr, d.ClassName, attrs)
            end
            if d:IsA("RemoteEvent") or d:IsA("UnreliableRemoteEvent") or d:IsA("RemoteFunction")
                or d:IsA("BindableEvent") or d:IsA("BindableFunction")
            then
                local connTxt = ""
                if Caps.getconnections and (d:IsA("RemoteEvent") or d:IsA("UnreliableRemoteEvent") or d:IsA("BindableEvent")) then
                    local sig = d:IsA("BindableEvent") and d.Event or d.OnClientEvent
                    local okC, conns = pcall(Caps.getconnections, sig)
                    if okC and type(conns) == "table" then
                        local validC = 0
                        for _, c in ipairs(conns) do
                            local fn
                            pcall(function() fn = c.Function end)
                            if not (fn and Persistent.ourSignalCallbacks[fn]) then
                                validC = validC + 1
                            end
                        end
                        connTxt = " | Conns=" .. tostring(validC)
                    end
                elseif d:IsA("RemoteFunction") and Caps.getcallbackvalue then
                    local okCb, cb = pcall(Caps.getcallbackvalue, d, "OnClientInvoke")
                    if okCb and type(cb) == "function" then
                        connTxt = " | HasOnClientInvoke=true"
                    end
                end
                outLines[#outLines + 1] = string.format("[RAW_REMOTE] %s [%s]%s", pathStr, d.ClassName, connTxt)
            elseif d:IsA("ValueBase") then
                local okV, rawV = pcall(function() return d.Value end)
                local valStr = Parser.serializeValue(okV and rawV or "ERR", 0, { pretty = false, maxDepth = 6, maxItems = 200, maxStrLen = 8192 })
                outLines[#outLines + 1] = string.format("[RAW_VAL] %s [%s] = %s", pathStr, d.ClassName, valStr)
            elseif d:IsA("Humanoid") then
                outLines[#outLines + 1] = string.format("[RAW_HUM] %s | HP=%.1f/%.1f | Walk=%.1f", pathStr, d.Health or 0, d.MaxHealth or 0, d.WalkSpeed or 0)
            elseif d:IsA("ProximityPrompt") then
                outLines[#outLines + 1] = string.format("[RAW_PROMPT] %s | En=%s | Action=%q | Obj=%q", pathStr, tostring(d.Enabled), tostring(d.ActionText), tostring(d.ObjectText))
            elseif d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                local txt = tostring(d.Text or "")
                if #txt > 0 and #txt < 2000 then
                    outLines[#outLines + 1] = string.format("[RAW_GUI] %s [%s] Vis=%s Text=%q", pathStr, d.ClassName, tostring(d.Visible), txt)
                end
            elseif d:IsA("LocalScript") or d:IsA("ModuleScript") then
                outLines[#outLines + 1] = string.format("[RAW_SCRIPT] %s [%s]", pathStr, d.ClassName)
            end
        end)
        flushBatchLines(outLines, 250)
    end
end

local function dumpOneModelBox(m, tag, outLines)
    local hum = m:FindFirstChildOfClass("Humanoid")
    local hpTxt = hum and string.format("%.1f/%.1f", hum.Health or 0, hum.MaxHealth or 0) or "noHum"
    local npPosTxt = "nil"
    local np = m:FindFirstChild("Nape", true)
    if np and np:IsA("BasePart") then
        npPosTxt = Parser.serializeValue(np.CFrame or np.Position, 0, { pretty = false })
    end
    outLines[#outLines + 1] = string.format("[%s] %s | HP=%s | Attrs=%s | Nape=%s", tag, m:GetFullName(), hpTxt, Parser.fmtAttrs(m), npPosTxt)
    local hb = m:FindFirstChild("Hitboxes")
    if hb then
        for _, p in ipairs(hb:GetDescendants()) do
            if p:IsA("BasePart") then
                local sz = p.Size
                local cfTxt = Parser.serializeValue(p.CFrame or p.Position, 0, { pretty = false })
                outLines[#outLines + 1] = string.format(
                    "[RAW_COLOSSAL] Hitbox %s | Size=(%.1f,%.1f,%.1f) | Touch=%s | %s",
                    p:GetFullName(), sz and sz.X or 0, sz and sz.Y or 0, sz and sz.Z or 0, tostring(p.CanTouch), cfTxt
                )
            end
        end
    end
end

function RawDumper.dumpRaidColoContext(outLines, opts)
    outLines[#outLines + 1] = "--- RAID COLO CONTEXT (COLOSSAL / CANNONS / OBJECTIVES / CODE) ---"
    pcall(function()
        local napePos, colModel = AoTRTools.findNapePos()
        if colModel then
            dumpOneModelBox(colModel, "RAW_COLOSSAL", outLines)
        end
        local seenModels = {}
        if colModel then seenModels[colModel] = true end
        for _, cname in ipairs({ "Titans", "Boss", "Bosses", "Shifters", "Raid", "Allies", "NPCs", "Living", "Entities" }) do
            local c = Services.Workspace:FindFirstChild(cname)
            if c then
                for _, d in ipairs(c:GetDescendants()) do
                    if d:IsA("Model") and not seenModels[d] and (d:FindFirstChildOfClass("Humanoid") or d:FindFirstChild("Hitboxes") or d:FindFirstChild("Nape", true)) then
                        seenModels[d] = true
                        dumpOneModelBox(d, "RAW_COLOSSAL", outLines)
                    end
                end
            end
        end

        local cannons = AoTRTools.collectAllCannons()
        outLines[#outLines + 1] = "[RAW_CANNON_COUNT] Total=" .. tostring(#cannons)
        for i, cn in ipairs(cannons) do
            pcall(function()
                local barrel = cn:FindFirstChild("Barrel")
                local bw = (barrel and barrel:FindFirstChild("BarrelWood")) or cn:FindFirstChild("BarrelWood", true)
                local base = cn:FindFirstChild("Base")
                local prompt = cn:FindFirstChildWhichIsA("ProximityPrompt", true)
                local seat = cn:FindFirstChildWhichIsA("Seat", true) or cn:FindFirstChildWhichIsA("VehicleSeat", true)
                local okP, piv = pcall(function() return cn:GetPivot() end)
                local pos = (base and base:IsA("BasePart") and base.Position) or (bw and bw:IsA("BasePart") and bw.Position) or (okP and piv and piv.Position)
                local distTxt = "?"
                if napePos and pos then
                    local okD, d = pcall(function() return (napePos - pos).Magnitude end)
                    if okD and type(d) == "number" then
                        distTxt = string.format("%.1f", d)
                    end
                end
                outLines[#outLines + 1] = string.format(
                    "[RAW_CANNON] #%d %s | Pos=%s | DistNape=%s | BW=%s | Base=%s | Prompt=%s | Seat=%s | Attrs=%s",
                    i, cn:GetFullName(),
                    pos and Parser.serializeValue(pos, 0, { pretty = false }) or "nil",
                    distTxt,
                    (bw and bw:IsA("BasePart")) and Parser.serializeValue(bw.CFrame or bw.Position, 0, { pretty = false }) or "nil",
                    (base and base:IsA("BasePart")) and Parser.serializeValue(base.CFrame or base.Position, 0, { pretty = false }) or "nil",
                    prompt and (prompt.Name .. "(En=" .. tostring(prompt.Enabled) .. ")") or "nil",
                    seat and seat:GetFullName() or "nil",
                    Parser.fmtAttrs(cn)
                )
            end)
        end

        local objRoots = {
            Services.Workspace:FindFirstChild("Objectives"),
            Services.ReplicatedStorage and Services.ReplicatedStorage:FindFirstChild("Objectives"),
            Services.Workspace:FindFirstChild("Mission"),
            Services.ReplicatedStorage and Services.ReplicatedStorage:FindFirstChild("Mission"),
            Services.Workspace:FindFirstChild("Raid"),
            Services.ReplicatedStorage and Services.ReplicatedStorage:FindFirstChild("Raid"),
        }
        for _, root in ipairs(objRoots) do
            if root then
                for _, chObj in ipairs(root:GetDescendants()) do
                    local valStr = ""
                    if chObj:IsA("ValueBase") then
                        local okV, rawV = pcall(function() return chObj.Value end)
                        valStr = " Val=" .. Parser.serializeValue(okV and rawV or "ERR", 0, { pretty = false })
                    end
                    outLines[#outLines + 1] = string.format("[RAW_OBJECTIVE] %s [%s]%s Attrs=%s", chObj:GetFullName(), chObj.ClassName, valStr, Parser.fmtAttrs(chObj))
                end
            end
        end
    end)

    if opts and opts.skipCode then return end

    local function isRaidScriptName(s)
        local l = string.lower(tostring(s or ""))
        return l:find("cannon", 1, true) or l:find("colossal", 1, true) or l:find("bertholdt", 1, true)
            or l:find("raid", 1, true) or l:find("spear", 1, true) or l:find("hitbox", 1, true)
            or l:find("attack", 1, true) or l:find("skill", 1, true) or l:find("cutscene", 1, true)
            or l:find("reward", 1, true) or l:find("phase", 1, true) or l:find("steam", 1, true)
            or l:find("eren", 1, true) or l:find("titan", 1, true) or l:find("host", 1, true)
    end

    if Caps.decompile then
        pcall(function()
            local cands, seen = {}, {}
            local function pushScr(s)
                if s and not seen[s] and (s:IsA("LocalScript") or s:IsA("ModuleScript")) then
                    seen[s] = true
                    local okF, fn = pcall(function() return s:GetFullName() end)
                    local full = okF and fn or s.Name
                    if isRaidScriptName(s.Name) or isRaidScriptName(full) then
                        cands[#cands + 1] = { scr = s, full = full }
                    end
                end
            end
            local lp = Utils.getLocalPlayer()
            local ps = lp and lp:FindFirstChild("PlayerScripts")
            for _, r in ipairs({ Services.ReplicatedStorage, ps }) do
                if r then
                    for _, d in ipairs(r:GetDescendants()) do pushScr(d) end
                end
            end
            if Caps.getscripts then
                for _, s in ipairs(Caps.getscripts()) do pushScr(s) end
            end
            local decomped = 0
            for _, item in ipairs(cands) do
                local okD, code = pcall(Caps.decompile, item.scr)
                if okD and type(code) == "string" and #code > 0 then
                    decomped = decomped + 1
                    outLines[#outLines + 1] = string.format("[RAW_RAID_SRC] Script=%s (len=%d)", item.full, #code)
                    local hits = 0
                    for ln in code:gmatch("[^\r\n]+") do
                        local ll = string.lower(ln)
                        if ll:find("fireserver", 1, true) or ll:find("invokeserver", 1, true) or ll:find(":send(", 1, true)
                            or ll:find("s_skills", 1, true) or ll:find("s_explode", 1, true) or ll:find("cannon", 1, true)
                            or ll:find("colossal", 1, true) or ll:find("bertholdt", 1, true) or ll:find("nape", 1, true)
                            or ll:find("cutscene", 1, true) or ll:find("reward", 1, true) or ll:find("phase", 1, true)
                        then
                            hits = hits + 1
                            outLines[#outLines + 1] = "[RAW_RAID_SRC]   " .. Utils.trim(ln):sub(1, 220)
                            if hits >= 25 then break end
                        end
                    end
                    if decomped >= 20 then break end
                end
            end
        end)
    end

    if Caps.getgc and Caps.getconstants then
        pcall(function()
            local fnHits = 0
            for _, obj in ipairs(Caps.getgc(false)) do
                if type(obj) == "function" then
                    local okC, consts = pcall(Caps.getconstants, obj)
                    if okC and type(consts) == "table" then
                        local matched, isSelf = false, false
                        local strs = {}
                        for _, cv in pairs(consts) do
                            if type(cv) == "string" then
                                if cv:find("RAW_COLOSSAL", 1, true) or cv:find("Sigma-Spy", 1, true) or cv:find("__AOTR_SIGMA", 1, true) then
                                    isSelf = true
                                    break
                                end
                                if cv == "S_Skills" or cv == "Cannon" or cv == "Colossal" or cv == "Bertholdt"
                                    or cv == "S_Explode" or cv == "S_Rewards" or cv == "Cutscene" or cv == "Register"
                                then
                                    matched = true
                                end
                                if #cv > 0 and #cv <= 60 and #strs < 16 then
                                    strs[#strs + 1] = string.format("%q", cv)
                                end
                            end
                        end
                        if matched and not isSelf then
                            fnHits = fnHits + 1
                            outLines[#outLines + 1] = "[RAW_RAID_CONST#" .. fnHits .. "] {" .. table.concat(strs, ", ") .. "}"
                            if fnHits >= 40 then break end
                        end
                    end
                end
            end
        end)
    end
end

function RawDumper.dumpAll(btnRef, opts)
    if State.isDumpingRaw then
        return false, "Dang dump raw..."
    end
    State.isDumpingRaw = true
    if btnRef and btnRef.Parent then btnRef.Text = "Dumping..." end

    local function runDump()
        local outLines = {}
        local totalCount = { n = 0 }
        xpcall(function()
            LogWriter.flush(true)
            outLines[#outLines + 1] = "==================== RAW UNFILTERED FULL DUMP START ===================="
            local lp = Utils.getLocalPlayer()
            local plrs = {}
            pcall(function()
                if Services.Players and type(Services.Players.GetPlayers) == "function" then
                    plrs = Services.Players:GetPlayers()
                end
            end)
            local pList = {}
            for _, p in ipairs(plrs) do
                local uid = "?"
                pcall(function() uid = tostring(p.UserId) end)
                pList[#pList + 1] = tostring(p.Name) .. "(" .. uid .. ")"
            end
            local placeIdStr, jobIdStr = "?", "?"
            pcall(function() placeIdStr = tostring(game.PlaceId) end)
            pcall(function() jobIdStr = tostring(game.JobId) end)
            outLines[#outLines + 1] = string.format(
                "[RAW_META] PlaceId=%s | JobId=%s | LocalPlayer=%s | Players(%d)=%s",
                placeIdStr,
                jobIdStr,
                lp and lp.Name or "nil",
                #plrs,
                table.concat(pList, ", ")
            )

            -- Quet khong chon loc tat ca Services chinh trong game
            local roots = {
                { inst = Services.Players, tag = "PLR" },
                { inst = Services.ReplicatedStorage, tag = "RS" },
                { inst = Services.ReplicatedFirst, tag = "RF" },
                { inst = Services.Workspace, tag = "WS" },
                { inst = Services.StarterGui, tag = "SG" },
                { inst = Services.StarterPack, tag = "SP" },
                { inst = Services.StarterPlayer, tag = "SPL" },
                { inst = Services.Lighting, tag = "LGT" },
                { inst = Services.SoundService, tag = "SND" },
            }
            for _, entry in ipairs(roots) do
                if entry.inst then
                    outLines[#outLines + 1] = "--- SERVICE: " .. entry.tag .. " ---"
                    RawDumper.dumpServiceTree(entry.inst, entry.tag, outLines, totalCount)
                    flushBatchLines(outLines, 1)
                end
            end

            if Caps.getloadedmodules then
                local okM, mods = pcall(Caps.getloadedmodules)
                if okM and type(mods) == "table" then
                    outLines[#outLines + 1] = "--- LOADED MODULES (" .. tostring(#mods) .. ") ---"
                    for _, m in ipairs(mods) do
                        local okF, fn = pcall(function() return m:GetFullName() end)
                        outLines[#outLines + 1] = "[RAW_MOD] " .. (okF and fn or tostring(m))
                        flushBatchLines(outLines, 250)
                    end
                end
            end

            -- Raid Colo chuyen sau: Colossal Hitboxes/Phase, Full Wall Cannons, Objectives, Raid Code & Consts
            RawDumper.dumpRaidColoContext(outLines, opts)
            flushBatchLines(outLines, 1)

            if Caps.getgc and not (opts and opts.skipGc) then
                local okG, gcObjs = pcall(Caps.getgc, true)
                if okG and type(gcObjs) == "table" then
                    outLines[#outLines + 1] = "--- LIVE GC TABLES SCAN ---"
                    local dumpedTbls = 0
                    for idx, obj in ipairs(gcObjs) do
                        if idx % 1500 == 0 then
                            flushBatchLines(outLines, 1)
                            task.wait()
                        end
                        if type(obj) == "table" and not isOwnSpyObject(obj) and getmetatable(obj) == nil then
                            local keyC = 0
                            local sampleKey = nil
                            for k, _ in next, obj do
                                keyC = keyC + 1
                                if sampleKey == nil then sampleKey = k end
                                if keyC >= 3 then break end
                            end
                            if keyC >= 2 and (type(sampleKey) == "string" or type(sampleKey) == "number") then
                                local okSer, sStr = pcall(function()
                                    local snap = Parser.cloneSnapshot(obj, 0, {}, { maxDepth = 5, maxItems = 180, maxHex = 128 })
                                    return Parser.serializeValue(snap, 0, { pretty = false, maxDepth = 5, maxItems = 180, maxStrLen = 2048, shortInst = true })
                                end)
                                if okSer and type(sStr) == "string" and #sStr > 10 and #sStr < 12000 then
                                    dumpedTbls = dumpedTbls + 1
                                    outLines[#outLines + 1] = string.format("[RAW_GC_TBL#%d] %s", dumpedTbls, sStr)
                                    flushBatchLines(outLines, 150)
                                    if dumpedTbls >= 800 then break end
                                end
                            end
                        end
                    end
                end
            end

            outLines[#outLines + 1] = string.format("==================== RAW FULL DUMP DONE (Objects=%d) ====================", totalCount.n)
            LogWriter.writeLines(outLines)
            UI.setStatusMsg(string.format("Da lay FULL RAW (%d objects) -> %s", totalCount.n, LOG_FILE), COLORS.inEvent)
            Utils.notify("Raw Dump Xong", "Da luu toan bo vao " .. LOG_FILE)
        end, function(err)
            outLines[#outLines + 1] = "[RAW_DUMP_ERR] " .. tostring(err)
            LogWriter.writeLines(outLines)
            pcall(UI.setStatusMsg, "Loi Dump Raw: " .. tostring(err), COLORS.blocked)
        end)
        if btnRef and btnRef.Parent then
            btnRef.Text = "Dump Full Raw"
        end
        State.isDumpingRaw = false
    end

    if opts and opts.sync then
        runDump()
    else
        task.spawn(runDump)
    end
    return true
end

function Extractor.scanRawToCleanFile(btnRef, customKeyword)
    if State.isExtracting then return false end
    State.isExtracting = true
    if btnRef and btnRef.Parent then btnRef.Text = "Dang quet..." end

    local rawText = ""
    local kw = string.lower(Utils.trim(customKeyword or Config.searchQuery or ""))

    xpcall(function()
        LogWriter.flush(true)
        if Caps.isfile and Caps.readfile and Caps.isfile(LOG_FILE) then
            local okR, txt = pcall(Caps.readfile, LOG_FILE)
            if okR and type(txt) == "string" then
                rawText = txt
            end
        end
        if #rawText == 0 and #State.entries > 0 then
            local memLines = {}
            for _, rec in ipairs(State.entries) do
                memLines[#memLines + 1] = string.format("[%s][%s][%s] %s:%s(%s)%s",
                    rec.dir, rec.status or "OK", rec.sourceTag or "MAIN",
                    rec.remotePath, rec.method,
                    Parser.serializeTuple(rec.finalArgs or {}, rec.finalN or 0, RAW_SER_OPTS),
                    (rec.retN and rec.retN > 0) and (" => RET(" .. Parser.serializeTuple(rec.srvRets or {}, rec.retN, RAW_SER_OPTS) .. ")") or ""
                )
            end
            rawText = table.concat(memLines, "\n")
        end

        local out = {}
        local kwHits, remoteDefs, srvPayloads, trafficMap, trafficOrder = {}, {}, {}, {}, {}
        local dataGroups = { VAL = {}, ATTR = {}, HUM = {}, GUI = {}, MOD = {}, GC = {}, OTHER = {} }
        local raidGroups = { TRAFFIC = {}, COLOSSAL = {}, CANNON = {}, OBJECTIVE = {}, CODE = {} }
        local function isRaidColoLine(s)
            local l = string.lower(s)
            return l:find("colossal", 1, true) or l:find("bertholdt", 1, true) or l:find("cannon", 1, true)
                or l:find("nape", 1, true) or l:find("raid", 1, true) or l:find("phase", 1, true)
                or l:find("steam", 1, true) or l:find("spear", 1, true) or l:find("s_skills", 1, true)
                or l:find("s_explode", 1, true) or l:find("cutscene", 1, true) or l:find("reward", 1, true)
                or l:find("eren", 1, true) or l:find("objective", 1, true) or l:find("hitbox", 1, true)
                or l:find("titan", 1, true) or l:find("seated", 1, true) or l:find("attack", 1, true)
        end
        local seenGlobal = {}
        local lineCount = 0

        for line in rawText:gmatch("[^\r\n]+") do
            lineCount = lineCount + 1
            local clean = line:gsub("^%[[%d%.]+s%]%s*", "")
            if #kw > 0 and string.lower(clean):find(kw, 1, true) and not seenGlobal["KW:" .. clean] then
                seenGlobal["KW:" .. clean] = true
                kwHits[#kwHits + 1] = clean
            end

            local tag = clean:match("^%[([%u_#%d]+)%]")
            if tag == "OUT" or tag == "IN" then
                local remCall = clean:match("^%[[^%]]+%]%[[^%]]+%]%[[^%]]+%]%s*([^%(]+)")
                local sigKey = remCall and (tag .. "|" .. remCall) or clean:sub(1, 90)
                if not trafficMap[sigKey] then
                    trafficMap[sigKey] = { count = 0, sample = clean }
                    trafficOrder[#trafficOrder + 1] = sigKey
                end
                trafficMap[sigKey].count = trafficMap[sigKey].count + 1
                if (clean:find("=> RET(", 1, true) and not trafficMap[sigKey].sample:find("=> RET(", 1, true))
                    or (#clean > #trafficMap[sigKey].sample and #clean < 8000)
                then
                    trafficMap[sigKey].sample = clean
                end

                if isRaidColoLine(clean) and not seenGlobal["RT:" .. clean] then
                    seenGlobal["RT:" .. clean] = true
                    raidGroups.TRAFFIC[#raidGroups.TRAFFIC + 1] = clean
                end
                if (tag == "IN" or clean:find("=> RET(", 1, true)) and not seenGlobal["SRV:" .. clean] then
                    seenGlobal["SRV:" .. clean] = true
                    srvPayloads[#srvPayloads + 1] = clean
                end
            elseif tag == "RAW_COLOSSAL" and not seenGlobal[clean] then
                seenGlobal[clean] = true
                raidGroups.COLOSSAL[#raidGroups.COLOSSAL + 1] = clean
            elseif (tag == "RAW_CANNON" or tag == "RAW_CANNON_COUNT" or tag == "RAW_CANNON_GEO" or tag == "RAW_WS_CANNON" or tag == "RAW_SEATED") and not seenGlobal[clean] then
                seenGlobal[clean] = true
                raidGroups.CANNON[#raidGroups.CANNON + 1] = clean
            elseif tag == "RAW_OBJECTIVE" and not seenGlobal[clean] then
                seenGlobal[clean] = true
                raidGroups.OBJECTIVE[#raidGroups.OBJECTIVE + 1] = clean
            elseif (tag == "RAW_RAID_SRC" or clean:find("^%[RAW_RAID_CONST")) and not seenGlobal[clean] then
                seenGlobal[clean] = true
                raidGroups.CODE[#raidGroups.CODE + 1] = clean
            elseif tag == "RAW_REMOTE" and not seenGlobal[clean] then
                seenGlobal[clean] = true
                remoteDefs[#remoteDefs + 1] = clean
                if isRaidColoLine(clean) then raidGroups.TRAFFIC[#raidGroups.TRAFFIC + 1] = clean end
            elseif tag == "RAW_VAL" and not seenGlobal[clean] then
                seenGlobal[clean] = true
                dataGroups.VAL[#dataGroups.VAL + 1] = clean
                if isRaidColoLine(clean) then raidGroups.OBJECTIVE[#raidGroups.OBJECTIVE + 1] = clean end
            elseif tag and tag:find("_ATTR$", 1) and not seenGlobal[clean] then
                seenGlobal[clean] = true
                dataGroups.ATTR[#dataGroups.ATTR + 1] = clean
                if isRaidColoLine(clean) then raidGroups.COLOSSAL[#raidGroups.COLOSSAL + 1] = clean end
            elseif tag == "RAW_HUM" and not seenGlobal[clean] then
                seenGlobal[clean] = true
                dataGroups.HUM[#dataGroups.HUM + 1] = clean
                if isRaidColoLine(clean) then raidGroups.COLOSSAL[#raidGroups.COLOSSAL + 1] = clean end
            elseif tag == "RAW_GUI" and not seenGlobal[clean] then
                seenGlobal[clean] = true
                dataGroups.GUI[#dataGroups.GUI + 1] = clean
                if isRaidColoLine(clean) then raidGroups.OBJECTIVE[#raidGroups.OBJECTIVE + 1] = clean end
            elseif (tag == "RAW_MOD" or tag == "RAW_SCRIPT") and not seenGlobal[clean] then
                seenGlobal[clean] = true
                dataGroups.MOD[#dataGroups.MOD + 1] = clean
            elseif clean:find("^%[RAW_GC_TBL") and not seenGlobal[clean] then
                seenGlobal[clean] = true
                dataGroups.GC[#dataGroups.GC + 1] = clean
            elseif (tag == "RAW_PROMPT" or tag == "AOTR") and not seenGlobal[clean] then
                seenGlobal[clean] = true
                dataGroups.OTHER[#dataGroups.OTHER + 1] = clean
            end
        end

        out[#out + 1] = string.format("-- AoTR EXTRACTED CLEAN DATA | Nguon: %s (%d dong raw) | Keyword: %q", LOG_FILE, lineCount, kw)
        out[#out + 1] = ""

        if #kwHits > 0 then
            out[#out + 1] = string.format("========== [0] KHOP TU KHOA %q (%d) ==========", kw, #kwHits)
            for _, l in ipairs(kwHits) do out[#out + 1] = l end
            out[#out + 1] = ""
        end

        out[#out + 1] = "========== [RAID COLO] BO DU LIEU CHUYEN DUNG RAID COLOSSAL =========="
        local raidSecs = {
            { k = "TRAFFIC", title = "-- [RAID_TRAFFIC] Remotes & Server Returns Raid Colo" },
            { k = "COLOSSAL", title = "-- [RAID_COLOSSAL_HITBOX] Colossal Model / Phase / Hitboxes" },
            { k = "CANNON", title = "-- [RAID_CANNONS] Phao Thanh / Toa Do / Ban & Seated Geo" },
            { k = "OBJECTIVE", title = "-- [RAID_OBJECTIVES] Muc Tieu / Wave / GUI Raid Colo" },
            { k = "CODE", title = "-- [RAID_CODE_CONSTS] Decompiled Code & GC Constants" },
        }
        for _, rs in ipairs(raidSecs) do
            local rArr = raidGroups[rs.k]
            out[#out + 1] = string.format("%s (%d)", rs.title, #rArr)
            for _, l in ipairs(rArr) do out[#out + 1] = l end
        end
        out[#out + 1] = ""

        out[#out + 1] = string.format("========== [1] TONG HOP REMOTES DA BAT (%d unique) ==========", #trafficOrder)
        for _, k in ipairs(trafficOrder) do
            local info = trafficMap[k]
            out[#out + 1] = string.format("(x%d) %s", info.count, info.sample)
        end
        out[#out + 1] = ""

        out[#out + 1] = string.format("========== [2] DU LIEU SERVER TRA VE / GUI XUONG (%d) ==========", #srvPayloads)
        for _, l in ipairs(srvPayloads) do out[#out + 1] = l end
        out[#out + 1] = ""

        out[#out + 1] = string.format("========== [3] DANH SACH TOAN BO REMOTES TRONG GAME (%d) ==========", #remoteDefs)
        for _, l in ipairs(remoteDefs) do out[#out + 1] = l end
        out[#out + 1] = ""

        local sectNames = {
            { k = "VAL", title = "[4] VALUEBASE (PLAYER / STATS / CONFIG)" },
            { k = "ATTR", title = "[5] ATTRIBUTES" },
            { k = "HUM", title = "[6] ENTITIES / HUMANOIDS" },
            { k = "GUI", title = "[7] PLAYERGUI TEXTS" },
            { k = "MOD", title = "[8] SCRIPTS & LOADED MODULES" },
            { k = "GC", title = "[9] LIVE GC DATA TABLES" },
            { k = "OTHER", title = "[10] PROMPTS & DIAGNOSTICS" },
        }
        for _, sec in ipairs(sectNames) do
            local arr = dataGroups[sec.k]
            out[#out + 1] = string.format("========== %s (%d) ==========", sec.title, #arr)
            for _, l in ipairs(arr) do out[#out + 1] = l end
            out[#out + 1] = ""
        end

        local replaySeen = {}
        out[#out + 1] = "========== [11] LUA REPLAY SNIPPETS SACH =========="
        for _, rec in ipairs(State.entries) do
            if rec.dir == "OUT" then
                local rk = rec.remotePath .. "|" .. tostring(rec.sig1 or "")
                if not replaySeen[rk] then
                    replaySeen[rk] = true
                    out[#out + 1] = Parser.generateReplayLua(rec)
                    out[#out + 1] = ""
                end
            end
        end

        local finalText = table.concat(out, "\n")
        State.lastExtractedText = finalText
        if Caps.writefile then
            pcall(Caps.writefile, EXTRACTED_FILE, finalText)
        end
        local kb = math.floor((#finalText / 1024) * 10 + 0.5) / 10
        UI.setStatusMsg(string.format("Quet xong -> %s (%.1f KB | %d remotes | %d server | %d vals)", EXTRACTED_FILE, kb, #trafficOrder, #srvPayloads, #dataGroups.VAL), COLORS.inEvent)
        Utils.notify("Quet File Xong", "Da luu file sach: " .. EXTRACTED_FILE)
    end, function(err)
        pcall(UI.setStatusMsg, "Loi quet file: " .. tostring(err), COLORS.blocked)
    end)

    if btnRef and btnRef.Parent then
        btnRef.Text = "Quet Raid Colo"
    end
    State.isExtracting = false
    return true
end

-- ============================================================================
-- 6. AOTR RAID DIAGNOSTIC TOOLS (GIU NGUYEN CHO NGUOI DUNG CU)
-- ============================================================================
function AoTRTools.log(msg)
    local ts = string.format("[%.2fs]", os.clock())
    local line = ts .. " [AOTR] " .. tostring(msg)
    State.diagLogs[#State.diagLogs + 1] = line
    if #State.diagLogs > 1500 then
        table.remove(State.diagLogs, 1)
    end
    LogWriter.pushLine(line)
    LogWriter.flush(false)
end

local function fmtVecShort(v)
    if typeofFn(v) == "Vector3" then
        return string.format("Vec3(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z)
    elseif typeofFn(v) == "CFrame" then
        local p = v.Position
        local lv = v.LookVector
        return string.format("CF(pos=%.2f,%.2f,%.2f | look=%.3f,%.3f,%.3f)", p.X, p.Y, p.Z, lv.X, lv.Y, lv.Z)
    end
    return tostring(v)
end

function AoTRTools.findNapePos()
    for _, folderName in ipairs({ "Titans", "Boss", "Bosses", "Shifters", "Raid", "Living", "Entities" }) do
        local fld = Services.Workspace:FindFirstChild(folderName)
        if fld then
            for _, d in ipairs(fld:GetDescendants()) do
                if d:IsA("Model") then
                    local ln = string.lower(d.Name)
                    if ln:find("colossal", 1, true) or ln:find("bertholdt", 1, true) then
                        local hb = d:FindFirstChild("Hitboxes")
                        local hit = hb and hb:FindFirstChild("Hit")
                        local np = (hit and hit:FindFirstChild("Nape")) or d:FindFirstChild("Nape", true)
                        if np and np:IsA("BasePart") then
                            return np.Position, d
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

function AoTRTools.isRealCannonModel(cn)
    if not (cn and cn:IsA("Model")) then return false end
    if cn.Parent == Services.Workspace and cn.Name == "Cannon" and not cn:FindFirstChild("Base") and not cn:FindFirstChild("Barrel") then
        return false
    end
    local okTag, hasTag = pcall(function() return cn:HasTag("Cannon") end)
    if okTag and hasTag then return true end
    return (cn:FindFirstChild("Barrel") and cn:FindFirstChild("Base")) ~= nil
end

function AoTRTools.collectAllCannons()
    local seen, list = {}, {}
    local function push(cn)
        if AoTRTools.isRealCannonModel(cn) and not seen[cn] then
            seen[cn] = true
            list[#list + 1] = cn
        end
    end
    for _, d in ipairs(Services.Workspace:GetDescendants()) do
        if d.Name == "Cannons" and not d:IsA("BasePart") then
            for _, ch in ipairs(d:GetChildren()) do
                if ch:IsA("Model") then
                    push(ch)
                elseif ch:IsA("ObjectValue") and ch.Value then
                    local val = ch.Value
                    if val:IsA("Model") then
                        push(val)
                    elseif val:IsA("BasePart") and val.Parent and val.Parent:IsA("Model") then
                        push(val.Parent)
                    end
                end
            end
        elseif d:IsA("Model") and AoTRTools.isRealCannonModel(d) then
            push(d)
        end
    end
    pcall(function()
        if Services.CollectionService then
            for _, tagged in ipairs(Services.CollectionService:GetTagged("Cannon")) do
                if tagged:IsA("Model") then
                    push(tagged)
                elseif tagged:IsA("BasePart") and tagged.Parent and tagged.Parent:IsA("Model") then
                    push(tagged.Parent)
                end
            end
        end
    end)
    return list
end

function AoTRTools.onRemoteCaptured(rec)
    if rec.dir ~= "OUT" then return end
    local check = string.lower(tostring(rec.remoteName or "") .. " " .. tostring(rec.sig1 or "") .. " " .. tostring(rec.sig2 or ""))
    if not (check:find("cannon", 1, true) or check:find("s_skills", 1, true) or check:find("spear", 1, true)
        or check:find("colossal", 1, true) or check:find("raid", 1, true) or check:find("hitbox", 1, true))
    then
        return
    end
    local lp = Utils.getLocalPlayer()
    local ch = lp and lp.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    local cn = (seat and seat.Parent and seat.Parent:IsA("Model") and seat.Parent) or Services.Workspace:FindFirstChild("Cannon")
    local napePos, colModel = AoTRTools.findNapePos()
    local phase = colModel and pcall(function() return colModel:GetAttribute("Phase") end) and colModel:GetAttribute("Phase") or nil
    if cn or napePos then
        local bw = cn and ((cn:FindFirstChild("Barrel") and cn.Barrel:FindFirstChild("BarrelWood")) or cn:FindFirstChild("BarrelWood", true))
        local base = cn and cn:FindFirstChild("Base")
        LogWriter.pushLine(string.format(
            "[RAW_CANNON_GEO] Trigger=%s:%s | Cn=%s | BW=%s | Base=%s | Nape=%s | Phase=%s",
            tostring(rec.remoteName), tostring(rec.sig1),
            cn and cn:GetFullName() or "nil",
            (bw and bw:IsA("BasePart")) and Parser.serializeValue(bw.CFrame or bw.Position, 0, { pretty = false }) or "nil",
            (base and base:IsA("BasePart")) and Parser.serializeValue(base.CFrame or base.Position, 0, { pretty = false }) or "nil",
            napePos and Parser.serializeValue(napePos, 0, { pretty = false }) or "nil",
            tostring(phase)
        ))
    end
end

function Hooks.bindRaidColoWatchers()
    if Services.Workspace and Services.Workspace.ChildAdded then
        Utils.trackConn(Services.Workspace.ChildAdded:Connect(function(child)
            if child and child.Name == "Cannon" then
                task.defer(function()
                    local bw = child:FindFirstChild("BarrelWood", true)
                    LogWriter.pushLine(string.format(
                        "[RAW_WS_CANNON] %s | BW=%s | Attrs=%s",
                        child:GetFullName(),
                        (bw and bw:IsA("BasePart")) and Parser.serializeValue(bw.CFrame or bw.Position, 0, { pretty = false }) or "nil",
                        Parser.fmtAttrs(child)
                    ))
                end)
            end
        end))
    end
    local lp = Utils.getLocalPlayer()
    local function watchChar(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid") or (type(char.WaitForChild) == "function" and char:WaitForChild("Humanoid", 4))
        if hum and hum.Seated then
            Utils.trackConn(hum.Seated:Connect(function(active, seatPart)
                local napePos = AoTRTools.findNapePos()
                LogWriter.pushLine(string.format(
                    "[RAW_SEATED] active=%s | seat=%s | Nape=%s",
                    tostring(active),
                    seatPart and seatPart:GetFullName() or "nil",
                    napePos and Parser.serializeValue(napePos, 0, { pretty = false }) or "nil"
                ))
            end))
        end
    end
    if lp then
        if lp.Character then task.spawn(watchChar, lp.Character) end
        if lp.CharacterAdded then Utils.trackConn(lp.CharacterAdded:Connect(function(c) task.spawn(watchChar, c) end)) end
    end
end

function AoTRTools.takeSnapshot(reason)
    AoTRTools.log("========== SNAPSHOT (" .. tostring(reason) .. ") ==========")
    xpcall(function()
        local lp = Utils.getLocalPlayer()
        local plrs = Services.Players and Services.Players:GetPlayers() or {}
        local pNames = {}
        for _, p in ipairs(plrs) do pNames[#pNames + 1] = p.Name end
        AoTRTools.log("PlaceId=" .. tostring(game.PlaceId) .. " | Streaming=" .. tostring(Services.Workspace.StreamingEnabled) .. " | Players(" .. #plrs .. "): " .. table.concat(pNames, ","))

        local chars = Services.Workspace:FindFirstChild("Characters")
        local ch = (chars and lp and chars:FindFirstChild(lp.Name)) or (lp and lp.Character)
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            AoTRTools.log("Char=" .. ch:GetFullName() .. " Attrs=" .. Parser.fmtAttrs(ch) .. " Seat=" .. (seat and seat:GetFullName() or "nil"))
        end

        local napePos = AoTRTools.findNapePos()
        for _, cname in ipairs({ "Titans", "Boss", "Bosses", "Shifters", "Raid", "Allies", "NPCs" }) do
            local c = Services.Workspace:FindFirstChild(cname)
            if c then
                local models = {}
                for _, d in ipairs(c:GetDescendants()) do
                    if d:IsA("Model") and (d:FindFirstChildOfClass("Humanoid") or d:FindFirstChild("Hitboxes") or d:FindFirstChild("Nape", true)) then
                        models[#models + 1] = d
                    end
                end
                AoTRTools.log(string.format("Container workspace.%s: %d models", cname, #models))
                for i = 1, math.min(6, #models) do
                    local m = models[i]
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    local hpTxt = hum and string.format("%.1f/%.1f", hum.Health, hum.MaxHealth) or "noHum"
                    local np = m:FindFirstChild("Nape", true)
                    AoTRTools.log(string.format("  Model %s | HP=%s | Nape=%s | Attrs=%s", m:GetFullName(), hpTxt, np and fmtVecShort(np.Position) or "nil", Parser.fmtAttrs(m)))
                end
            end
        end

        local cannons = AoTRTools.collectAllCannons()
        AoTRTools.log("Cannons found: " .. tostring(#cannons))
        for i = 1, math.min(25, #cannons) do
            local cn = cannons[i]
            local base = cn:FindFirstChild("Base")
            local bw = cn:FindFirstChild("BarrelWood", true)
            local okP, piv = pcall(function() return cn:GetPivot() end)
            local pos = (base and base:IsA("BasePart") and base.Position) or (bw and bw:IsA("BasePart") and bw.Position) or (okP and piv and piv.Position)
            local distTxt = (napePos and pos) and string.format("%.1f", (napePos - pos).Magnitude) or "?"
            AoTRTools.log(string.format("  Cannon[%d]=%s | Pos=%s | DistNape=%s | Attrs=%s", i, cn:GetFullName(), pos and fmtVecShort(pos) or "nil", distTxt, Parser.fmtAttrs(cn)))
        end
    end, function(err)
        AoTRTools.log("[SNAP_ERR] " .. tostring(err))
    end)
    LogWriter.flush(true)
end

function AoTRTools.scanAllWallCannons(statusBtn)
    if State.isFullScanning then return end
    State.isFullScanning = true
    task.spawn(function()
        xpcall(function()
            local lp = Utils.getLocalPlayer()
            local chars = Services.Workspace:FindFirstChild("Characters")
            local ch = (chars and lp and chars:FindFirstChild(lp.Name)) or (lp and lp.Character)
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local cl = Services.Workspace:FindFirstChild("Climbable")
            local walls = cl and cl:FindFirstChild("Walls")
            local discovered, order, visitedPos = {}, {}, {}

            local function recordVisible()
                local napePos = AoTRTools.findNapePos()
                for _, cn in ipairs(AoTRTools.collectAllCannons()) do
                    local okF, full = pcall(function() return cn:GetFullName() end)
                    local key = okF and full or tostring(cn)
                    local base = cn:FindFirstChild("Base")
                    local bw = cn:FindFirstChild("BarrelWood", true)
                    local okP, piv = pcall(function() return cn:GetPivot() end)
                    local pos = (base and base:IsA("BasePart") and base.Position) or (bw and bw:IsA("BasePart") and bw.Position) or (okP and piv and piv.Position)
                    if not discovered[key] then
                        order[#order + 1] = key
                        discovered[key] = { pos = pos, distNape = (napePos and pos) and (napePos - pos).Magnitude or nil }
                    end
                end
            end

            recordVisible()
            local savedCF = hrp and hrp.CFrame or nil
            local wasPS = hum and hum.PlatformStand or false
            if hum then hum.PlatformStand = true end

            local pending = {}
            if walls then
                for _, w in ipairs(walls:GetChildren()) do
                    local okP, cf = pcall(function() return w:GetPivot() end)
                    local pos = okP and cf and cf.Position or nil
                    if pos then
                        local skip = false
                        for _, vp in ipairs(visitedPos) do
                            if (vp - pos).Magnitude < 140 then skip = true; break end
                        end
                        if not skip then
                            visitedPos[#visitedPos + 1] = pos
                            pending[#pending + 1] = pos
                        end
                    end
                end
            end

            for idx, wp in ipairs(pending) do
                if statusBtn and statusBtn.Parent then
                    statusBtn.Text = string.format("Quet %d/%d", idx, #pending)
                end
                pcall(function()
                    if lp and type(lp.RequestStreamAroundAsync) == "function" then
                        lp:RequestStreamAroundAsync(wp + Vector3.new(0, 20, 0))
                    end
                end)
                if hrp and hrp.Parent then
                    hrp.CFrame = CFrame.new(wp + Vector3.new(0, 30, 0))
                end
                task.wait(0.24)
                recordVisible()
                if idx >= 60 then break end
            end

            if hrp and hrp.Parent and savedCF then hrp.CFrame = savedCF end
            if hum then hum.PlatformStand = wasPS end

            AoTRTools.log("[SWEEP_TOTAL_CANNONS] " .. tostring(#order))
            for i, key in ipairs(order) do
                local info = discovered[key]
                AoTRTools.log(string.format("  FullCannon[%d]=%s | Pos=%s | DistNape=%s", i, key, info.pos and fmtVecShort(info.pos) or "nil", info.distNape and string.format("%.1f", info.distNape) or "nil"))
            end
            LogWriter.flush(true)
            if statusBtn and statusBtn.Parent then
                statusBtn.Text = "Xong (" .. #order .. ")"
            end
        end, function(err)
            AoTRTools.log("[SWEEP_ERR] " .. tostring(err))
        end)
        State.isFullScanning = false
    end)
end

function AoTRTools.inspectCode(statusBtn)
    if State.isInspectingCode then return end
    State.isInspectingCode = true
    if statusBtn and statusBtn.Parent then statusBtn.Text = "Dang soi..." end
    task.spawn(function()
        xpcall(function()
            local lp = Utils.getLocalPlayer()
            local ps = lp and lp:FindFirstChild("PlayerScripts")
            local cands, seen = {}, {}
            local function add(scr)
                if scr and not seen[scr] and (scr:IsA("LocalScript") or scr:IsA("ModuleScript")) then
                    seen[scr] = true
                    local ln = string.lower(scr.Name)
                    if ln:find("cannon", 1, true) or ln:find("skill", 1, true) or ln:find("attack", 1, true)
                        or ln:find("hitbox", 1, true) or ln:find("raid", 1, true) or ln:find("combat", 1, true)
                    then
                        local okF, fn = pcall(function() return scr:GetFullName() end)
                        cands[#cands + 1] = { scr = scr, full = okF and fn or scr.Name, name = scr.Name }
                    end
                end
            end
            for _, root in ipairs({ Services.ReplicatedStorage, ps }) do
                if root then
                    for _, d in ipairs(root:GetDescendants()) do add(d) end
                end
            end
            if Caps.getscripts then
                pcall(function()
                    for _, s in ipairs(Caps.getscripts()) do add(s) end
                end)
            end
            AoTRTools.log("Matching AoTR scripts: " .. #cands)
            for i = 1, math.min(60, #cands) do
                AoTRTools.log("  Script[" .. i .. "]=" .. cands[i].full)
            end
            if Caps.decompile then
                for i = 1, math.min(12, #cands) do
                    local okD, src = pcall(Caps.decompile, cands[i].scr)
                    if okD and type(src) == "string" and #src > 0 then
                        AoTRTools.log("  [DECOMP_OK] " .. cands[i].full .. " (len=" .. #src .. ")")
                        if Caps.writefile then
                            pcall(Caps.writefile, ("aotr_combat_" .. cands[i].name):gsub("[^%w_]", "_") .. ".lua", src)
                        end
                    end
                end
            end
            LogWriter.flush(true)
            if statusBtn and statusBtn.Parent then statusBtn.Text = "Soi xong!" end
        end, function(err)
            AoTRTools.log("[CODE_ERR] " .. tostring(err))
        end)
        State.isInspectingCode = false
    end)
end

-- ============================================================================
-- 7. SIGMA-SPY FORK UI (DRAGGABLE, MINIMIZABLE, FILTER/BLOCK/SPOOF/CODEGEN)
-- ============================================================================


local function makeCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

local function makeStroke(parent, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or COLORS.border
    s.Thickness = thick or 1
    s.Parent = parent
    return s
end

local function makeBtn(parent, props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = true
    b.BorderSizePixel = 0
    b.BackgroundColor3 = props.bg or COLORS.card
    b.TextColor3 = props.fg or COLORS.text
    b.Font = props.font or Enum.Font.GothamSemibold
    b.TextSize = props.ts or 11
    b.Text = props.text or ""
    if props.size then b.Size = props.size end
    if props.pos then b.Position = props.pos end
    b.Parent = parent
    makeCorner(b, props.r or 5)
    if props.onClick then
        b.MouseButton1Click:Connect(props.onClick)
    end
    return b
end

local function makeScrollList(parent, pos, size)
    local sf = Instance.new("ScrollingFrame")
    sf.Position = pos
    sf.Size = size
    sf.BackgroundColor3 = COLORS.panel
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 5
    sf.ScrollBarImageColor3 = COLORS.border
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.Parent = parent
    makeCorner(sf, 6)
    makeStroke(sf, COLORS.border, 1)

    local lay = Instance.new("UIListLayout")
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 3)
    lay.Parent = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = sf

    Utils.trackConn(lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 10)
    end))
    return sf, lay
end

local function makeDraggable(handle, target)
    if not (Services.UserInputService and handle and target) then return end
    local dragging, dragStart, startPos = false, nil, nil
    Utils.trackConn(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end))
    Utils.trackConn(Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    Utils.trackConn(Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

local function getEntryBadgeColor(rec)
    if rec.status == "BLOCKED" or rec.status == "BLK+SPF" then return COLORS.blocked end
    if rec.status == "SPOOFED" then return COLORS.spoofed end
    if rec.dir == "IN" then
        return rec.method == "OnClientInvoke" and COLORS.inInvoke or COLORS.inEvent
    end
    return (rec.method == "InvokeServer" or rec.method == "Invoke") and COLORS.outInvoke or COLORS.outFire
end

local function matchesFilter(rec)
    local f = Config.dirFilter
    if f == "OUT" and rec.dir ~= "OUT" then return false end
    if f == "IN" and rec.dir ~= "IN" then return false end
    if f == "RET" and not (rec.retN and rec.retN > 0) then return false end
    if f == "MOD" and rec.status == "OK" then return false end

    local q = string.lower(Utils.trim(Config.searchQuery))
    if #q > 0 then
        local hay = string.lower(table.concat({
            rec.remoteName or "",
            rec.remotePath or "",
            rec.method or "",
            rec.sig1 or "",
            rec.preview or "",
            rec.retPreview or "",
            rec.callerName or "",
            rec.sourceTag or "",
        }, " "))
        if not hay:find(q, 1, true) then
            return false
        end
    end
    return true
end

function UI.setStatusMsg(msg, col)
    local lbl = State.refs.hintLabel
    if lbl and lbl.Parent then
        lbl.Text = msg
        lbl.TextColor3 = col or COLORS.muted
    end
end

function UI.refreshSelectedInspector()
    local refs = State.refs
    local rec = State.selectedEntryId and State.entryById[State.selectedEntryId] or nil
    if not rec then
        if refs.selTitle then refs.selTitle.Text = "Chon 1 Remote ben trai de soi / chan / spoof..." end
        if refs.codeBox then refs.codeBox.Text = "-- Sigma-Spy Fork ready.\n-- Moi FireServer / InvokeServer (+ Return) / OnClientEvent / OnClientInvoke se hien tai day." end
        if refs.ruleTargetLbl then refs.ruleTargetLbl.Text = "Scope: chua chon remote" end
        return
    end

    if not rec.codeCache then
        rec.codeCache = Parser.generateReplayLua(rec)
    end
    refs.selTitle.Text = string.format("[%s|%s] %s:%s", rec.dir, rec.status or "OK", rec.remoteName, rec.method)
    refs.selTitle.TextColor3 = getEntryBadgeColor(rec)
    refs.codeBox.Text = rec.codeCache
    pcall(function()
        if refs.codeScroll and refs.codeBox then
            local b = refs.codeBox.TextBounds
            refs.codeScroll.CanvasSize = UDim2.new(0, math.max(b.X + 20, refs.codeScroll.AbsoluteSize.X), 0, b.Y + 20)
        end
    end)

    local sKey = Rules.makeKey(rec.remotePath, rec.sig1, rec.sig2, Config.selectedScope)
    local scopeDesc = (Config.selectedScope == "REMOTE" or not rec.sig1) and ("Remote: " .. rec.remoteName)
        or (Config.selectedScope == "SIG1" and (rec.remoteName .. " + Arg1=" .. tostring(rec.sig1))
        or (rec.remoteName .. " + " .. tostring(rec.sig1) .. "/" .. tostring(rec.sig2)))
    local activeR = State.rules[sKey]
    local mR = Rules.resolve(rec.remotePath, rec.sig1, rec.sig2)
    if refs.ruleTargetLbl then
        local spTags = {}
        if mR and mR.spoofOutArgs and mR.spoofOutArgs.active then spTags[#spTags + 1] = "OUT" end
        if mR and mR.spoofOutReturn and mR.spoofOutReturn.active then spTags[#spTags + 1] = "RET" end
        if mR and mR.spoofInArgs and mR.spoofInArgs.active then spTags[#spTags + 1] = "IN" end
        local spSuffix = #spTags > 0 and (" | Spoofed:" .. table.concat(spTags, "+")) or ""
        refs.ruleTargetLbl.Text = "Rule Scope [" .. Config.selectedScope .. "]: " .. scopeDesc .. spSuffix
    end
    if refs.btnIgnore then
        local on = (activeR and activeR.ignore) or false
        refs.btnIgnore.BackgroundColor3 = on and COLORS.amber or COLORS.card
        refs.btnIgnore.Text = on and "Ignored ✓" or "Ignore"
    end
    if refs.btnBlockOut then
        local on = (activeR and activeR.blockOut) or (mR and mR.blockOut) or false
        refs.btnBlockOut.BackgroundColor3 = on and COLORS.red or COLORS.card
        refs.btnBlockOut.Text = on and "Blk OUT ✓" or "Block OUT"
    end
    if refs.btnBlockIn then
        local on = (activeR and activeR.blockIn) or (mR and mR.blockIn) or false
        refs.btnBlockIn.BackgroundColor3 = on and COLORS.red or COLORS.card
        refs.btnBlockIn.Text = on and "Blk IN ✓" or "Block IN"
    end
end

function UI.rebuildLeftList()
    local listFrame = State.refs.leftScroll
    if not (listFrame and listFrame.Parent) then return end
    for _, ch in ipairs(listFrame:GetChildren()) do
        if ch:IsA("Frame") or ch:IsA("TextButton") then
            ch:Destroy()
        end
    end

    local tab = Config.viewTab
    if tab == "STREAM" then
        local shown = 0
        for i = #State.entries, 1, -1 do
            local rec = State.entries[i]
            if matchesFilter(rec) then
                shown = shown + 1
                local isSel = (State.selectedEntryId == rec.id)
                local col = getEntryBadgeColor(rec)
                local btn = makeBtn(listFrame, {
                    size = UDim2.new(1, -2, 0, 38),
                    bg = isSel and COLORS.cardSel or COLORS.card,
                    text = "",
                    r = 5,
                    onClick = function()
                        State.selectedEntryId = rec.id
                        UI.refreshSelectedInspector()
                        UI.rebuildLeftList()
                    end,
                })
                btn.LayoutOrder = shown

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(0, 3, 1, -6)
                bar.Position = UDim2.fromOffset(3, 3)
                bar.BackgroundColor3 = col
                bar.BorderSizePixel = 0
                bar.Parent = btn
                makeCorner(bar, 2)

                local top = Instance.new("TextLabel")
                top.BackgroundTransparency = 1
                top.Position = UDim2.fromOffset(10, 2)
                top.Size = UDim2.new(1, -14, 0, 16)
                top.Font = Enum.Font.GothamBold
                top.TextSize = 11
                top.TextXAlignment = Enum.TextXAlignment.Left
                top.TextTruncate = Enum.TextTruncate.AtEnd
                top.TextColor3 = col
                local retMark = (rec.retN and rec.retN > 0) and string.format(" [RET:%d]", rec.retN) or ""
                local stMark = (rec.status ~= "OK") and (" [" .. rec.status .. "]") or ""
                top.Text = string.format("%s %s:%s%s%s", rec.dir, rec.remoteName, rec.method, retMark, stMark)
                top.Parent = btn

                local sub = Instance.new("TextLabel")
                sub.BackgroundTransparency = 1
                sub.Position = UDim2.fromOffset(10, 19)
                sub.Size = UDim2.new(1, -14, 0, 15)
                sub.Font = Enum.Font.Code
                sub.TextSize = 10
                sub.TextXAlignment = Enum.TextXAlignment.Left
                sub.TextTruncate = Enum.TextTruncate.AtEnd
                sub.TextColor3 = COLORS.muted
                sub.Text = rec.preview ~= "" and rec.preview or "(no args)"
                sub.Parent = btn

                if shown >= MAX_VISIBLE_ROWS then break end
            end
        end
    elseif tab == "GROUPED" then
        local list = {}
        local q = string.lower(Utils.trim(Config.searchQuery))
        for _, g in pairs(State.grouped) do
            if #q == 0 or string.lower(g.path .. " " .. tostring(g.sig1 or "")):find(q, 1, true) then
                list[#list + 1] = g
            end
        end
        table.sort(list, function(a, b) return a.count > b.count end)
        for idx, g in ipairs(list) do
            if idx > MAX_VISIBLE_ROWS then break end
            local btn = makeBtn(listFrame, {
                size = UDim2.new(1, -2, 0, 36),
                bg = COLORS.card,
                text = "",
                onClick = function()
                    State.selectedEntryId = g.lastId
                    UI.refreshSelectedInspector()
                end,
            })
            btn.LayoutOrder = idx

            local top = Instance.new("TextLabel")
            top.BackgroundTransparency = 1
            top.Position = UDim2.fromOffset(8, 2)
            top.Size = UDim2.new(1, -12, 0, 16)
            top.Font = Enum.Font.GothamBold
            top.TextSize = 11
            top.TextXAlignment = Enum.TextXAlignment.Left
            top.TextTruncate = Enum.TextTruncate.AtEnd
            top.TextColor3 = COLORS.outFire
            top.Text = string.format("%s%s  (x%d)", g.name, g.sig1 and (" · " .. g.sig1) or "", g.count)
            top.Parent = btn

            local sub = Instance.new("TextLabel")
            sub.BackgroundTransparency = 1
            sub.Position = UDim2.fromOffset(8, 19)
            sub.Size = UDim2.new(1, -12, 0, 14)
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 10
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.TextColor3 = COLORS.muted
            sub.Text = string.format("OUT:%d  IN:%d  RET:%d  BLK:%d  SPF:%d", g.outC, g.inC, g.retC, g.blkC, g.spfC)
            sub.Parent = btn
        end
    elseif tab == "RULES" then
        if #State.ruleOrder == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, -8, 0, 48)
            empty.BackgroundTransparency = 1
            empty.TextWrapped = true
            empty.TextSize = 11
            empty.Font = Enum.Font.Gotham
            empty.TextColor3 = COLORS.muted
            empty.Text = "Chua co rule Ignore / Block / Spoof nao.\nChon 1 Remote o tab Stream roi bam Block / Ignore / Apply Spoof."
            empty.Parent = listFrame
        else
            for idx, key in ipairs(State.ruleOrder) do
                local r = State.rules[key]
                if r then
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, -2, 0, 42)
                    row.BackgroundColor3 = COLORS.card
                    row.BorderSizePixel = 0
                    row.LayoutOrder = idx
                    row.Parent = listFrame
                    makeCorner(row, 5)

                    local flags = {}
                    if r.ignore then flags[#flags + 1] = "IGN" end
                    if r.blockOut then flags[#flags + 1] = "BLK_OUT" end
                    if r.blockIn then flags[#flags + 1] = "BLK_IN" end
                    if r.spoofOutArgs and r.spoofOutArgs.active then flags[#flags + 1] = "SPF_ARGS" end
                    if r.spoofOutReturn and r.spoofOutReturn.active then flags[#flags + 1] = "SPF_RET" end
                    if r.spoofInArgs and r.spoofInArgs.active then flags[#flags + 1] = "SPF_IN" end

                    local tLbl = Instance.new("TextLabel")
                    tLbl.BackgroundTransparency = 1
                    tLbl.Position = UDim2.fromOffset(6, 2)
                    tLbl.Size = UDim2.new(1, -56, 0, 17)
                    tLbl.Font = Enum.Font.GothamBold
                    tLbl.TextSize = 10
                    tLbl.TextXAlignment = Enum.TextXAlignment.Left
                    tLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    tLbl.TextColor3 = COLORS.spoofed
                    tLbl.Text = "[" .. table.concat(flags, "|") .. "]"
                    tLbl.Parent = row

                    local kLbl = Instance.new("TextLabel")
                    kLbl.BackgroundTransparency = 1
                    kLbl.Position = UDim2.fromOffset(6, 20)
                    kLbl.Size = UDim2.new(1, -56, 0, 18)
                    kLbl.Font = Enum.Font.Code
                    kLbl.TextSize = 10
                    kLbl.TextXAlignment = Enum.TextXAlignment.Left
                    kLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    kLbl.TextColor3 = COLORS.text
                    kLbl.Text = r.label or key
                    kLbl.Parent = row

                    makeBtn(row, {
                        pos = UDim2.new(1, -46, 0, 8),
                        size = UDim2.fromOffset(40, 26),
                        bg = COLORS.red,
                        text = "Xoa",
                        ts = 10,
                        onClick = function()
                            State.rules[key] = nil
                            Rules.pruneIfEmpty(key)
                            Rules.syncBridgeAttributes()
                            task.spawn(Hooks.syncAllIncomingControls)
                            UI.rebuildLeftList()
                            UI.refreshSelectedInspector()
                        end,
                    })
                end
            end
        end
    elseif tab == "AOTR" then
        local toolBox = Instance.new("Frame")
        toolBox.Size = UDim2.new(1, -2, 0, 180)
        toolBox.BackgroundColor3 = COLORS.card
        toolBox.BorderSizePixel = 0
        toolBox.Parent = listFrame
        makeCorner(toolBox, 6)

        local hdr = Instance.new("TextLabel")
        hdr.Size = UDim2.new(1, -12, 0, 20)
        hdr.Position = UDim2.fromOffset(6, 4)
        hdr.BackgroundTransparency = 1
        hdr.Font = Enum.Font.GothamBold
        hdr.TextSize = 11
        hdr.TextColor3 = COLORS.inEvent
        hdr.TextXAlignment = Enum.TextXAlignment.Left
        hdr.Text = "AoTR Raid Diagnostic Tools (Log -> " .. LOG_FILE .. ")"
        hdr.Parent = toolBox

        local btnSnap = makeBtn(toolBox, {
            pos = UDim2.fromOffset(6, 28),
            size = UDim2.new(0.48, -6, 0, 28),
            bg = COLORS.accent,
            text = "Chup Snapshot",
            onClick = function()
                AoTRTools.takeSnapshot("Manual")
                UI.setStatusMsg("Da chup Snapshot vao " .. LOG_FILE, COLORS.inEvent)
                UI.rebuildLeftList()
            end,
        })
        local sweepBtnRef
        sweepBtnRef = makeBtn(toolBox, {
            pos = UDim2.new(0.50, 2, 0, 28),
            size = UDim2.new(0.48, -6, 0, 28),
            bg = COLORS.amber,
            text = "Quet Phao (Walls)",
            onClick = function()
                AoTRTools.scanAllWallCannons(sweepBtnRef)
            end,
        })
        local codeBtnRef
        codeBtnRef = makeBtn(toolBox, {
            pos = UDim2.fromOffset(6, 62),
            size = UDim2.new(0.48, -6, 0, 28),
            bg = COLORS.outInvoke,
            fg = COLORS.bg,
            text = "Soi Code Combat",
            onClick = function()
                AoTRTools.inspectCode(codeBtnRef)
            end,
        })
        makeBtn(toolBox, {
            pos = UDim2.new(0.50, 2, 0, 62),
            size = UDim2.new(0.48, -6, 0, 28),
            bg = COLORS.green,
            text = "Copy Diag Log",
            onClick = function()
                LogWriter.flush(true)
                local okC = Utils.copyText(table.concat(State.diagLogs, "\n"))
                UI.setStatusMsg(okC and "Da copy Diag Log!" or "Da luu ra " .. LOG_FILE, COLORS.inEvent)
            end,
        })
        local autoSnapBtn
        autoSnapBtn = makeBtn(toolBox, {
            pos = UDim2.fromOffset(6, 96),
            size = UDim2.new(1, -12, 0, 26),
            bg = Config.autoSnapLoop and COLORS.green or COLORS.panel,
            text = Config.autoSnapLoop and "Auto Snapshot (20s): ON" or "Auto Snapshot (20s): OFF",
            onClick = function()
                Config.autoSnapLoop = not Config.autoSnapLoop
                autoSnapBtn.Text = Config.autoSnapLoop and "Auto Snapshot (20s): ON" or "Auto Snapshot (20s): OFF"
                autoSnapBtn.BackgroundColor3 = Config.autoSnapLoop and COLORS.green or COLORS.panel
            end,
        })
        local actorBtn
        actorBtn = makeBtn(toolBox, {
            pos = UDim2.fromOffset(6, 128),
            size = UDim2.new(1, -12, 0, 26),
            bg = COLORS.outFire,
            fg = COLORS.bg,
            text = string.format("Tiem Actor VMs (Da tiem: %d)", State.actorsHookedCount),
            onClick = function()
                local cnt, msg = Hooks.injectActors()
                actorBtn.Text = string.format("Tiem Actor VMs (Da tiem: %d)", State.actorsHookedCount)
                UI.setStatusMsg(msg, cnt > 0 and COLORS.inEvent or COLORS.amber)
            end,
        })

        -- Hien thi log diag gan nhat o duoi
        for i = #State.diagLogs, math.max(1, #State.diagLogs - 35), -1 do
            local lineLbl = Instance.new("TextLabel")
            lineLbl.Size = UDim2.new(1, -4, 0, 16)
            lineLbl.BackgroundTransparency = 1
            lineLbl.Font = Enum.Font.Code
            lineLbl.TextSize = 10
            lineLbl.TextColor3 = COLORS.muted
            lineLbl.TextXAlignment = Enum.TextXAlignment.Left
            lineLbl.TextTruncate = Enum.TextTruncate.AtEnd
            lineLbl.Text = State.diagLogs[i]
            lineLbl.LayoutOrder = 100 + (#State.diagLogs - i)
            lineLbl.Parent = listFrame
        end
    end
end

function UI.refreshStats()
    local refs = State.refs
    local st = State.stats
    if refs.titleLabel then
        refs.titleLabel.Text = string.format(
            "Sigma-Spy Fork | ALL:%d  OUT:%d  IN:%d  RET:%d  BLK:%d  SPF:%d",
            st.total, st.outC, st.inC, st.retC, st.blkC, st.spfC
        )
    end
    if refs.miniPill then
        refs.miniPill.Text = string.format("Σ Spy (%d)", st.total)
    end
end

function UI.toggleRuleFlag(flagName)
    local rec = State.selectedEntryId and State.entryById[State.selectedEntryId]
    if not rec then
        UI.setStatusMsg("Hay chon 1 remote truoc!", COLORS.blocked)
        return
    end
    local key = Rules.makeKey(rec.remotePath, rec.sig1, rec.sig2, Config.selectedScope)
    local r = Rules.getOrCreate(key, rec.remoteName .. (rec.sig1 and (" :: " .. rec.sig1) or ""))
    r[flagName] = not r[flagName]
    Rules.pruneIfEmpty(key)
    Rules.syncBridgeAttributes()
    if flagName == "blockIn" then
        task.spawn(Hooks.syncAllIncomingControls)
    end
    UI.refreshSelectedInspector()
    if Config.viewTab == "RULES" then UI.rebuildLeftList() end
    UI.setStatusMsg(string.format("%s -> %s", flagName, tostring(r[flagName])), COLORS.spoofed)
end

function UI.mount()
    local candidates = {}
    if Caps.gethui then
        local okH, h = pcall(Caps.gethui)
        if okH and h then candidates[#candidates + 1] = h end
    end
    if Services.CoreGui then candidates[#candidates + 1] = Services.CoreGui end
    local lp = Utils.getLocalPlayer()
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 3)
        if pg then candidates[#candidates + 1] = pg end
    end

    local clampFn = math.clamp or function(v, lo, hi)
        if v < lo then return lo end
        if v > hi then return hi end
        return v
    end
    for _, parentGui in ipairs(candidates) do
        local okM, errM = pcall(function()
            local prev = parentGui:FindFirstChild("AoTRSigmaSpyGui")
            if prev then prev:Destroy() end

            local sg = Instance.new("ScreenGui")
            sg.Name = "AoTRSigmaSpyGui"
            sg.ResetOnSpawn = false
            sg.IgnoreGuiInset = true
            sg.DisplayOrder = 999999

            local cam = Services.Workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(900, 540)
            local winW = clampFn(math.floor(vp.X * 0.88), 540, 880)
            local winH = clampFn(math.floor(vp.Y * 0.82), 330, 520)

            local main = Instance.new("Frame")
            main.Size = UDim2.fromOffset(winW, winH)
            main.Position = UDim2.new(0.5, -math.floor(winW / 2), 0.5, -math.floor(winH / 2))
            main.BackgroundColor3 = COLORS.bg
            main.BorderSizePixel = 0
            main.Parent = sg
            makeCorner(main, 8)
            makeStroke(main, COLORS.accent, 1.5)

            local miniPill = makeBtn(sg, {
                pos = UDim2.new(0.5, -55, 0, 8),
                size = UDim2.fromOffset(110, 28),
                bg = COLORS.bg,
                fg = COLORS.inEvent,
                ts = 11,
                text = "Σ Spy (0)",
                r = 14,
                onClick = function()
                    main.Visible = true
                    State.refs.miniPill.Visible = false
                end,
            })
            miniPill.Visible = false
            makeStroke(miniPill, COLORS.accent, 1.4)
            makeDraggable(miniPill, miniPill)

            -- Top Header (Draggable)
            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 32)
            header.BackgroundColor3 = COLORS.panel
            header.BorderSizePixel = 0
            header.Parent = main
            makeCorner(header, 8)
            makeDraggable(header, main)

            local titleLabel = Instance.new("TextLabel")
            titleLabel.BackgroundTransparency = 1
            titleLabel.Position = UDim2.fromOffset(10, 0)
            titleLabel.Size = UDim2.new(1, -340, 1, 0)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 11
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            titleLabel.TextColor3 = COLORS.inEvent
            titleLabel.Text = "Sigma-Spy Fork | ALL:0  OUT:0  IN:0  RET:0  BLK:0  SPF:0"
            titleLabel.Parent = header

            local function headerRightBtns()
                local pauseBtn, execBtn, bindBtn, noiseBtn
                pauseBtn = makeBtn(header, {
                    pos = UDim2.new(1, -330, 0, 4),
                    size = UDim2.fromOffset(56, 24),
                    bg = COLORS.card,
                    text = "Pause",
                    ts = 10,
                    onClick = function()
                        Config.paused = not Config.paused
                        pauseBtn.Text = Config.paused and "Resume" or "Pause"
                        pauseBtn.BackgroundColor3 = Config.paused and COLORS.amber or COLORS.card
                    end,
                })
                execBtn = makeBtn(header, {
                    pos = UDim2.new(1, -270, 0, 4),
                    size = UDim2.fromOffset(66, 24),
                    bg = Config.captureExecutor and COLORS.green or COLORS.card,
                    text = Config.captureExecutor and "Exec: ON" or "Exec: OFF",
                    ts = 10,
                    onClick = function()
                        Config.captureExecutor = not Config.captureExecutor
                        execBtn.Text = Config.captureExecutor and "Exec: ON" or "Exec: OFF"
                        execBtn.BackgroundColor3 = Config.captureExecutor and COLORS.green or COLORS.card
                        Rules.syncBridgeAttributes()
                    end,
                })
                bindBtn = makeBtn(header, {
                    pos = UDim2.new(1, -200, 0, 4),
                    size = UDim2.fromOffset(64, 24),
                    bg = COLORS.card,
                    text = "Bind: OFF",
                    ts = 10,
                    onClick = function()
                        Config.captureBindables = not Config.captureBindables
                        bindBtn.Text = Config.captureBindables and "Bind: ON" or "Bind: OFF"
                        bindBtn.BackgroundColor3 = Config.captureBindables and COLORS.green or COLORS.card
                        if Config.captureBindables and Hooks.scanSafeRoots then
                            task.spawn(Hooks.scanSafeRoots, true)
                        end
                    end,
                })
                noiseBtn = makeBtn(header, {
                    pos = UDim2.new(1, -132, 0, 4),
                    size = UDim2.fromOffset(68, 24),
                    bg = COLORS.card,
                    text = "Noise: ALL",
                    ts = 10,
                    onClick = function()
                        Config.muteNoisePreset = not Config.muteNoisePreset
                        noiseBtn.Text = Config.muteNoisePreset and "Noise: MUTE" or "Noise: ALL"
                        noiseBtn.BackgroundColor3 = Config.muteNoisePreset and COLORS.amber or COLORS.card
                    end,
                })
                makeBtn(header, {
                    pos = UDim2.new(1, -60, 0, 4),
                    size = UDim2.fromOffset(26, 24),
                    bg = COLORS.card,
                    text = "_",
                    onClick = function()
                        main.Visible = false
                        miniPill.Visible = true
                    end,
                })
                makeBtn(header, {
                    pos = UDim2.new(1, -30, 0, 4),
                    size = UDim2.fromOffset(26, 24),
                    bg = COLORS.red,
                    text = "X",
                    onClick = function()
                        LogWriter.flush(true)
                        State.running = false
                        sg:Destroy()
                    end,
                })
            end
            headerRightBtns()

            -- Toolbar 2 hang gon gang cho ca Mobile (540px) & PC (880px)
            local toolbar = Instance.new("Frame")
            toolbar.Position = UDim2.fromOffset(6, 36)
            toolbar.Size = UDim2.new(1, -12, 0, 56)
            toolbar.BackgroundColor3 = COLORS.panel
            toolbar.BorderSizePixel = 0
            toolbar.Parent = main
            makeCorner(toolbar, 6)

            local searchBox = Instance.new("TextBox")
            searchBox.Position = UDim2.fromOffset(4, 3)
            searchBox.Size = UDim2.new(0.42, -4, 0, 23)
            searchBox.BackgroundColor3 = COLORS.card
            searchBox.TextColor3 = COLORS.text
            searchBox.PlaceholderText = "Search / Keyword loc file..."
            searchBox.PlaceholderColor3 = COLORS.muted
            searchBox.Font = Enum.Font.Gotham
            searchBox.TextSize = 11
            searchBox.ClearTextOnFocus = false
            searchBox.Text = ""
            searchBox.Parent = toolbar
            makeCorner(searchBox, 5)
            Utils.trackConn(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                Config.searchQuery = searchBox.Text
                UI.rebuildLeftList()
            end))

            local dirButtons = {}
            local dirs = { "ALL", "OUT", "IN", "RET", "MOD" }
            for i, d in ipairs(dirs) do
                local b = makeBtn(toolbar, {
                    pos = UDim2.new(0.43, (i - 1) * 40, 0, 3),
                    size = UDim2.fromOffset(37, 23),
                    bg = (Config.dirFilter == d) and COLORS.accent or COLORS.card,
                    text = d,
                    ts = 10,
                    onClick = function()
                        Config.dirFilter = d
                        for k, db in pairs(dirButtons) do
                            db.BackgroundColor3 = (k == d) and COLORS.accent or COLORS.card
                        end
                        UI.rebuildLeftList()
                    end,
                })
                dirButtons[d] = b
            end

            makeBtn(toolbar, {
                pos = UDim2.new(1, -66, 0, 3),
                size = UDim2.fromOffset(62, 23),
                bg = COLORS.card,
                text = "Clear Log",
                ts = 10,
                onClick = function()
                    State.entries = {}
                    State.entryById = {}
                    State.grouped = {}
                    State.selectedEntryId = nil
                    State.stats = { total = 0, outC = 0, inC = 0, retC = 0, blkC = 0, spfC = 0 }
                    UI.refreshStats()
                    UI.rebuildLeftList()
                    UI.refreshSelectedInspector()
                end,
            })

            local tabButtons = {}
            local tabs = {
                { id = "STREAM", label = "Stream" },
                { id = "GROUPED", label = "Remotes" },
                { id = "RULES", label = "Rules" },
                { id = "AOTR", label = "AoTR" },
            }
            for i, t in ipairs(tabs) do
                local b = makeBtn(toolbar, {
                    pos = UDim2.fromOffset(4 + (i - 1) * 60, 29),
                    size = UDim2.fromOffset(57, 23),
                    bg = (Config.viewTab == t.id) and COLORS.accent or COLORS.card,
                    text = t.label,
                    ts = 10,
                    onClick = function()
                        Config.viewTab = t.id
                        for k, tb in pairs(tabButtons) do
                            tb.BackgroundColor3 = (k == t.id) and COLORS.accent or COLORS.card
                        end
                        UI.rebuildLeftList()
                    end,
                })
                tabButtons[t.id] = b
            end

            local dumpRawBtn
            dumpRawBtn = makeBtn(toolbar, {
                pos = UDim2.new(1, -216, 0, 29),
                size = UDim2.fromOffset(106, 23),
                bg = COLORS.green,
                text = "Dump Full Raw",
                ts = 10,
                onClick = function()
                    RawDumper.dumpAll(dumpRawBtn)
                end,
            })
            local extractBtn
            extractBtn = makeBtn(toolbar, {
                pos = UDim2.new(1, -106, 0, 29),
                size = UDim2.fromOffset(102, 23),
                bg = COLORS.amber,
                fg = COLORS.bg,
                text = "Quet Raid Colo",
                ts = 10,
                onClick = function()
                    Extractor.scanRawToCleanFile(extractBtn)
                end,
            })

            -- Split Body: Left List + Right Inspector
            local leftScroll = makeScrollList(main, UDim2.fromOffset(6, 96), UDim2.new(0.37, -8, 1, -122))

            local rightPanel = Instance.new("Frame")
            rightPanel.Position = UDim2.new(0.37, 4, 0, 96)
            rightPanel.Size = UDim2.new(0.63, -10, 1, -122)
            rightPanel.BackgroundColor3 = COLORS.panel
            rightPanel.BorderSizePixel = 0
            rightPanel.Parent = main
            makeCorner(rightPanel, 6)
            makeStroke(rightPanel, COLORS.border, 1)

            local selTitle = Instance.new("TextLabel")
            selTitle.Position = UDim2.fromOffset(8, 4)
            selTitle.Size = UDim2.new(1, -110, 0, 18)
            selTitle.BackgroundTransparency = 1
            selTitle.Font = Enum.Font.GothamBold
            selTitle.TextSize = 11
            selTitle.TextXAlignment = Enum.TextXAlignment.Left
            selTitle.TextTruncate = Enum.TextTruncate.AtEnd
            selTitle.TextColor3 = COLORS.text
            selTitle.Text = "Chon 1 Remote ben trai..."
            selTitle.Parent = rightPanel

            local scopeBtn
            scopeBtn = makeBtn(rightPanel, {
                pos = UDim2.new(1, -98, 0, 3),
                size = UDim2.fromOffset(92, 20),
                bg = COLORS.card,
                text = "Scope: SIG1",
                ts = 10,
                onClick = function()
                    local order = { REMOTE = "SIG1", SIG1 = "SIG2", SIG2 = "REMOTE" }
                    Config.selectedScope = order[Config.selectedScope] or "SIG1"
                    scopeBtn.Text = "Scope: " .. Config.selectedScope
                    UI.refreshSelectedInspector()
                end,
            })

            local ruleTargetLbl = Instance.new("TextLabel")
            ruleTargetLbl.Position = UDim2.fromOffset(8, 22)
            ruleTargetLbl.Size = UDim2.new(1, -16, 0, 14)
            ruleTargetLbl.BackgroundTransparency = 1
            ruleTargetLbl.Font = Enum.Font.Code
            ruleTargetLbl.TextSize = 10
            ruleTargetLbl.TextXAlignment = Enum.TextXAlignment.Left
            ruleTargetLbl.TextTruncate = Enum.TextTruncate.AtEnd
            ruleTargetLbl.TextColor3 = COLORS.muted
            ruleTargetLbl.Text = "Rule Scope: -"
            ruleTargetLbl.Parent = rightPanel

            -- Action Strip: Copy Lua, Replay, Ignore, Block OUT, Block IN, Save File
            local actBar = Instance.new("Frame")
            actBar.Position = UDim2.fromOffset(6, 38)
            actBar.Size = UDim2.new(1, -12, 0, 26)
            actBar.BackgroundTransparency = 1
            actBar.Parent = rightPanel

            makeBtn(actBar, {
                pos = UDim2.fromOffset(0, 0),
                size = UDim2.fromOffset(68, 24),
                bg = COLORS.green,
                text = "Copy Lua",
                ts = 10,
                onClick = function()
                    local rec = State.selectedEntryId and State.entryById[State.selectedEntryId]
                    if not rec then return end
                    local txt = rec.codeCache or Parser.generateReplayLua(rec)
                    local ok = Utils.copyText(txt)
                    UI.setStatusMsg(ok and "Da copy code Lua replay!" or "Clipboard khong kha dung, hay export file.", COLORS.inEvent)
                end,
            })
            makeBtn(actBar, {
                pos = UDim2.fromOffset(72, 0),
                size = UDim2.fromOffset(58, 24),
                bg = COLORS.accent,
                text = "Replay",
                ts = 10,
                onClick = function()
                    local rec = State.selectedEntryId and State.entryById[State.selectedEntryId]
                    if not rec then return end
                    local code = rec.codeCache or Parser.generateReplayLua(rec)
                    if not Caps.loadstring then
                        UI.setStatusMsg("Khong co loadstring de Replay!", COLORS.blocked)
                        return
                    end
                    task.spawn(function()
                        local fn, err = Caps.loadstring(code)
                        if not fn then
                            UI.setStatusMsg("Replay compile err: " .. tostring(err), COLORS.blocked)
                            return
                        end
                        local co = Utils.getThreadKey()
                        State.internalThreads[co] = true
                        local okR, r1, r2 = pcall(fn)
                        State.internalThreads[co] = nil
                        if okR then
                            UI.setStatusMsg("Replay OK! Ret: " .. tostring(r1 or "nil"), COLORS.inEvent)
                        else
                            UI.setStatusMsg("Replay err: " .. tostring(r1), COLORS.blocked)
                        end
                    end)
                end,
            })
            local btnIgnore = makeBtn(actBar, {
                pos = UDim2.fromOffset(134, 0),
                size = UDim2.fromOffset(62, 24),
                bg = COLORS.card,
                text = "Ignore",
                ts = 10,
                onClick = function() UI.toggleRuleFlag("ignore") end,
            })
            local btnBlockOut = makeBtn(actBar, {
                pos = UDim2.fromOffset(200, 0),
                size = UDim2.fromOffset(72, 24),
                bg = COLORS.card,
                text = "Block OUT",
                ts = 10,
                onClick = function() UI.toggleRuleFlag("blockOut") end,
            })
            local btnBlockIn = makeBtn(actBar, {
                pos = UDim2.fromOffset(276, 0),
                size = UDim2.fromOffset(68, 24),
                bg = COLORS.card,
                text = "Block IN",
                ts = 10,
                onClick = function() UI.toggleRuleFlag("blockIn") end,
            })
            makeBtn(actBar, {
                pos = UDim2.fromOffset(348, 0),
                size = UDim2.fromOffset(72, 24),
                bg = COLORS.card,
                text = "Save .lua",
                ts = 10,
                onClick = function()
                    LogWriter.flush(true)
                    local rec = State.selectedEntryId and State.entryById[State.selectedEntryId]
                    if rec and Caps.writefile then
                        local ok = pcall(Caps.writefile, EXPORT_LUA_FILE, rec.codeCache or Parser.generateReplayLua(rec))
                        UI.setStatusMsg(ok and ("Da xuat " .. EXPORT_LUA_FILE .. " & " .. LOG_FILE) or "Loi writefile", COLORS.inEvent)
                    else
                        UI.setStatusMsg("Da flush log ra " .. LOG_FILE, COLORS.inEvent)
                    end
                end,
            })

            -- Code & Parser Viewer
            local codeScroll = Instance.new("ScrollingFrame")
            codeScroll.Position = UDim2.fromOffset(6, 66)
            codeScroll.Size = UDim2.new(1, -12, 1, -138)
            codeScroll.BackgroundColor3 = COLORS.bg
            codeScroll.BorderSizePixel = 0
            codeScroll.ScrollBarThickness = 5
            codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            codeScroll.Parent = rightPanel
            makeCorner(codeScroll, 5)
            makeStroke(codeScroll, COLORS.border, 1)

            local codeBox = Instance.new("TextBox")
            codeBox.Position = UDim2.fromOffset(6, 4)
            codeBox.Size = UDim2.new(1, -12, 1, -8)
            codeBox.AutomaticSize = Enum.AutomaticSize.XY
            codeBox.BackgroundTransparency = 1
            codeBox.MultiLine = true
            codeBox.TextEditable = false
            codeBox.ClearTextOnFocus = false
            codeBox.TextWrapped = false
            codeBox.Font = Enum.Font.Code
            codeBox.TextSize = 11
            codeBox.TextColor3 = COLORS.text
            codeBox.TextXAlignment = Enum.TextXAlignment.Left
            codeBox.TextYAlignment = Enum.TextYAlignment.Top
            codeBox.Text = "-- Chon 1 remote ben trai de xem Lua CodeGen, Server Return & Traceback."
            codeBox.Parent = codeScroll

            -- Spoof Panel o duoi Right Panel
            local spoofFrame = Instance.new("Frame")
            spoofFrame.Position = UDim2.new(0, 6, 1, -68)
            spoofFrame.Size = UDim2.new(1, -12, 0, 62)
            spoofFrame.BackgroundColor3 = COLORS.card
            spoofFrame.BorderSizePixel = 0
            spoofFrame.Parent = rightPanel
            makeCorner(spoofFrame, 5)
            makeStroke(spoofFrame, COLORS.spoofed, 1)

            local spoofModeBtn
            local spoofTargetBtn
            local spoofTargetField = "spoofOutArgs"
            spoofTargetBtn = makeBtn(spoofFrame, {
                pos = UDim2.fromOffset(4, 4),
                size = UDim2.fromOffset(108, 24),
                bg = COLORS.panel,
                fg = COLORS.outFire,
                ts = 10,
                text = "Target: OUT Args",
                onClick = function()
                    if spoofTargetField == "spoofOutArgs" then
                        spoofTargetField = "spoofOutReturn"
                        spoofTargetBtn.Text = "Target: Return"
                    elseif spoofTargetField == "spoofOutReturn" then
                        spoofTargetField = "spoofInArgs"
                        spoofTargetBtn.Text = "Target: IN Args"
                    else
                        spoofTargetField = "spoofOutArgs"
                        spoofTargetBtn.Text = "Target: OUT Args"
                    end
                end,
            })

            spoofModeBtn = makeBtn(spoofFrame, {
                pos = UDim2.fromOffset(116, 4),
                size = UDim2.fromOffset(102, 24),
                bg = COLORS.panel,
                fg = COLORS.spoofed,
                ts = 10,
                text = "Mode: PATCH",
                onClick = function()
                    local nxt = { PATCH = "REPLACE", REPLACE = "FN", FN = "PATCH" }
                    Config.spoofMode = nxt[Config.spoofMode] or "PATCH"
                    spoofModeBtn.Text = "Mode: " .. Config.spoofMode
                end,
            })

            local spoofInput = Instance.new("TextBox")
            spoofInput.Position = UDim2.fromOffset(4, 32)
            spoofInput.Size = UDim2.new(1, -152, 0, 24)
            spoofInput.BackgroundColor3 = COLORS.bg
            spoofInput.TextColor3 = COLORS.spoofed
            spoofInput.PlaceholderText = 'VD PATCH: { [2] = 999 } | REPLACE: "Cannon", 123 | RETURN: true, 999'
            spoofInput.PlaceholderColor3 = COLORS.muted
            spoofInput.Font = Enum.Font.Code
            spoofInput.TextSize = 10
            spoofInput.ClearTextOnFocus = false
            spoofInput.TextXAlignment = Enum.TextXAlignment.Left
            spoofInput.Text = ""
            spoofInput.Parent = spoofFrame
            makeCorner(spoofInput, 4)

            makeBtn(spoofFrame, {
                pos = UDim2.new(1, -144, 0, 32),
                size = UDim2.fromOffset(82, 24),
                bg = COLORS.amber,
                fg = COLORS.bg,
                ts = 10,
                text = "Apply Spoof",
                onClick = function()
                    local rec = State.selectedEntryId and State.entryById[State.selectedEntryId]
                    if not rec then
                        UI.setStatusMsg("Hay chon 1 remote truoc!", COLORS.blocked)
                        return
                    end
                    local okSpec, spec, errMsg = Rules.compileSpoofSpec(spoofInput.Text, Config.spoofMode)
                    if not okSpec then
                        UI.setStatusMsg(errMsg, COLORS.blocked)
                        return
                    end
                    local key = Rules.makeKey(rec.remotePath, rec.sig1, rec.sig2, Config.selectedScope)
                    local r = Rules.getOrCreate(key, rec.remoteName .. (rec.sig1 and (" :: " .. rec.sig1) or ""))
                    r[spoofTargetField] = spec
                    if spoofTargetField == "spoofInArgs" then
                        task.spawn(Hooks.syncAllIncomingControls)
                    end
                    Rules.syncBridgeAttributes()
                    UI.refreshSelectedInspector()
                    if Config.viewTab == "RULES" then UI.rebuildLeftList() end
                    UI.setStatusMsg("Da bat Spoof [" .. spoofTargetField .. " / " .. Config.spoofMode .. "]!", COLORS.inEvent)
                end,
            })

            makeBtn(spoofFrame, {
                pos = UDim2.new(1, -58, 0, 32),
                size = UDim2.fromOffset(54, 24),
                bg = COLORS.red,
                ts = 10,
                text = "Clear",
                onClick = function()
                    local rec = State.selectedEntryId and State.entryById[State.selectedEntryId]
                    if not rec then return end
                    local key = Rules.makeKey(rec.remotePath, rec.sig1, rec.sig2, Config.selectedScope)
                    local r = State.rules[key]
                    if r then
                        r[spoofTargetField] = nil
                        Rules.pruneIfEmpty(key)
                        Rules.syncBridgeAttributes()
                        task.spawn(Hooks.syncAllIncomingControls)
                        UI.refreshSelectedInspector()
                        if Config.viewTab == "RULES" then UI.rebuildLeftList() end
                        UI.setStatusMsg("Da tat Spoof " .. spoofTargetField, COLORS.muted)
                    end
                end,
            })

            -- Footer hint
            local hintLabel = Instance.new("TextLabel")
            hintLabel.Position = UDim2.new(0, 8, 1, -22)
            hintLabel.Size = UDim2.new(1, -16, 0, 18)
            hintLabel.BackgroundTransparency = 1
            hintLabel.Font = Enum.Font.Gotham
            hintLabel.TextSize = 10
            hintLabel.TextXAlignment = Enum.TextXAlignment.Left
            hintLabel.TextColor3 = COLORS.muted
            hintLabel.Text = string.format(
                "Raw: %s | Loc: %s | hookmm=%s | hookfn=%s | conns=%s",
                LOG_FILE, EXTRACTED_FILE, tostring(Caps.hookmetamethod ~= nil), tostring(Caps.hookfunction ~= nil), tostring(Caps.getconnections ~= nil)
            )
            hintLabel.Parent = main

            sg.Parent = parentGui
            State.gui = sg
            State.refs = {
                main = main,
                miniPill = miniPill,
                titleLabel = titleLabel,
                leftScroll = leftScroll,
                selTitle = selTitle,
                ruleTargetLbl = ruleTargetLbl,
                codeScroll = codeScroll,
                codeBox = codeBox,
                btnIgnore = btnIgnore,
                btnBlockOut = btnBlockOut,
                btnBlockIn = btnBlockIn,
                hintLabel = hintLabel,
            }
        end)
        if okM and State.gui then
            break
        elseif not okM then
            print("[Sigma-Spy UI Mount ERR]", tostring(errM))
        end
    end

    -- Vong lap cap nhat UI muot ma (~12 FPS khi co su kien moi) + Auto-flush file
    task.spawn(function()
        while State.running do
            task.wait(0.08)
            local now = os.clock()
            if State.pendingUiFlush and (now - State.lastFlushUiAt >= 0.08) then
                State.pendingUiFlush = false
                State.lastFlushUiAt = now
                pcall(UI.refreshStats)
                if Config.viewTab == "STREAM" or Config.viewTab == "GROUPED" then
                    pcall(UI.rebuildLeftList)
                end
            end
            pcall(LogWriter.flush, false)
        end
    end)
end

-- ============================================================================
-- 8. CLEANUP & STARTUP
-- ============================================================================
gEnv.__AOTR_SIGMA_CLEANUP = function()
    State.running = false
    Persistent.handlers = {}
    for _, conn in ipairs(State.connections) do
        pcall(function() conn:Disconnect() end)
    end
    State.connections = {}
    for conn, _ in pairs(Persistent.disabledConns) do
        pcall(function()
            if type(conn.Enable) == "function" then conn:Enable() end
        end)
    end
    Persistent.disabledConns = setmetatable({}, { __mode = "k" })
    Persistent.boundRemotes = setmetatable({}, { __mode = "k" })
    if State.gui then
        pcall(function() State.gui:Destroy() end)
        State.gui = nil
    end
    pcall(LogWriter.flush, true)
end

gEnv.__AOTR_SIGMA_API = {
    State = State,
    Config = Config,
    Parser = Parser,
    Rules = Rules,
    Recorder = Recorder,
    Hooks = Hooks,
    AoTRTools = AoTRTools,
    RawDumper = RawDumper,
    Extractor = Extractor,
    UI = UI,
    LogWriter = LogWriter,
}

LogWriter.initFile()
Hooks.installAll()
UI.mount()
UI.refreshSelectedInspector()

Utils.notify("AoTR Sigma-Spy Fork", "Da bat 100% OUT + IN + Return + Block/Spoof!")
print(string.format(
    "[Sigma-Spy Fork] Started | hookmetamethod=%s | hookfunction=%s | getconnections=%s | getactors=%s",
    tostring(Caps.hookmetamethod ~= nil),
    tostring(Caps.hookfunction ~= nil),
    tostring(Caps.getconnections ~= nil),
    tostring(Caps.getactors ~= nil)
))

-- Auto-snapshot loop (chi chay khi user bat trong tab AoTR)
task.spawn(function()
    local lastPhase, lastHp, lastSnap = nil, nil, os.clock()
    while State.running do
        task.wait(2)
        if Config.autoSnapLoop then
            local _, colM = AoTRTools.findNapePos()
            local curPhase = colM and colM:GetAttribute("Phase")
            local hum = colM and colM:FindFirstChildOfClass("Humanoid")
            local hpPct = (hum and hum.MaxHealth > 0) and math.floor((hum.Health / hum.MaxHealth) * 10) * 10 or nil
            if curPhase ~= lastPhase or (hpPct and hpPct ~= lastHp and hpPct <= 60) then
                lastPhase, lastHp, lastSnap = curPhase, hpPct, os.clock()
                AoTRTools.takeSnapshot("Phase_" .. tostring(curPhase) .. "_" .. tostring(hpPct))
            elseif os.clock() - lastSnap >= 20 then
                lastSnap = os.clock()
                AoTRTools.takeSnapshot("Periodic")
            end
        end
    end
end)
