-- AoTR Raid & Colossal Diagnostic Logger (Standalone - Safe Read-Only + Actor VM Spy)
-- Huong dan:
--   1. Chay script nay trong game (truoc hoac ngay khi vao tran Raid Colossal).
--   2. Tu tay bam E ngoi len 1 khau phao va ban 1-2 phat vao Colossal.
--   3. Bam [Chup Snapshot] (hoac doi auto snapshot) roi bam [Copy Log], hoac lay file "aotr_raid_log.txt".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")

local lp = Players.LocalPlayer
local LOG_FILE = "aotr_raid_log.txt"
local ACTOR_FALLBACK_FILE = "aotr_raid_actor_log.txt"
local MAX_LINES = 2000

local logs = {}
local remoteCount = 0
local lastSaveAt = 0

local function safeWriteFile(content)
    if type(writefile) == "function" then
        pcall(writefile, LOG_FILE, content)
    end
end

local function flushLog(force)
    local now = os.clock()
    if not force and (now - lastSaveAt < 2) then
        return
    end
    lastSaveAt = now
    safeWriteFile(table.concat(logs, "\n"))
end

local statusLabel = nil
local function updateBadge()
    if statusLabel then
        pcall(function()
            statusLabel.Text = string.format("AoTR Logger | Events: %d | Lines: %d", remoteCount, #logs)
        end)
    end
end

local function addLog(line)
    if #logs >= MAX_LINES then
        return
    end
    local ts = string.format("[%.2fs]", os.clock())
    logs[#logs + 1] = ts .. " " .. tostring(line)
    updateBadge()
    flushLog(false)
end

local function fmtVec(v)
    if typeof(v) == "Vector3" then
        return string.format("Vec3(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z)
    elseif typeof(v) == "CFrame" then
        local p = v.Position
        local lv = v.LookVector
        return string.format("CF(pos=%.2f,%.2f,%.2f | look=%.3f,%.3f,%.3f)", p.X, p.Y, p.Z, lv.X, lv.Y, lv.Z)
    end
    return tostring(v)
end

local function fmtVal(v, depth)
    depth = depth or 0
    local tv = typeof(v)
    if tv == "Vector3" or tv == "CFrame" then
        return fmtVec(v)
    elseif tv == "Instance" then
        local ok, full = pcall(function() return v:GetFullName() end)
        return string.format("<%s:%s>", v.ClassName, ok and full or v.Name)
    elseif tv == "table" then
        if depth >= 3 then return "{...}" end
        local parts = {}
        local n = 0
        for k, val in pairs(v) do
            n = n + 1
            if n > 20 then
                parts[#parts + 1] = "..."
                break
            end
            parts[#parts + 1] = tostring(k) .. "=" .. fmtVal(val, depth + 1)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif tv == "string" then
        return string.format("%q", v)
    end
    return tostring(v)
end

local function fmtAttrs(inst)
    local ok, attrs = pcall(function() return inst:GetAttributes() end)
    if not ok or type(attrs) ~= "table" then return "{}" end
    local out = {}
    for k, v in pairs(attrs) do
        out[#out + 1] = tostring(k) .. "=" .. fmtVal(v, 1)
    end
    table.sort(out)
    return "{" .. table.concat(out, ", ") .. "}"
end

local function findNapePos()
    for _, folderName in ipairs({ "Titans", "Boss", "Bosses", "Shifters", "Raid", "Living", "Entities" }) do
        local fld = workspace:FindFirstChild(folderName)
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

local getActorsFn = type(getactors) == "function" and getactors or (syn and type(syn.getactors) == "function" and syn.getactors) or nil
local runOnActorFn = type(run_on_actor) == "function" and run_on_actor or (syn and type(syn.run_on_actor) == "function" and syn.run_on_actor) or nil

local function collectAllCannons()
    local seen = {}
    local list = {}
    local function push(cn)
        if cn and cn:IsA("Model") and not seen[cn] then
            seen[cn] = true
            list[#list + 1] = cn
        end
    end

    local cl = workspace:FindFirstChild("Climbable")
    for _, root in ipairs({ cl, workspace:FindFirstChild("Cannons"), workspace:FindFirstChild("Map") }) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                if d.Name == "Cannons" and not d:IsA("BasePart") then
                    for _, ch in ipairs(d:GetChildren()) do
                        if ch:IsA("Model") then
                            push(ch)
                        end
                    end
                elseif d:IsA("Model") and (d.Name == "Cannon" or (d:FindFirstChild("Barrel") and d:FindFirstChild("Base"))) then
                    push(d)
                end
            end
        end
    end

    pcall(function()
        for _, tagged in ipairs(CollectionService:GetTagged("Cannon")) do
            if tagged:IsA("Model") then
                push(tagged)
            elseif tagged:IsA("BasePart") and tagged.Parent and tagged.Parent:IsA("Model") then
                push(tagged.Parent)
            end
        end
    end)

    return list
end

local function takeSnapshot(reason)
    addLog("========== SNAPSHOT (" .. tostring(reason) .. ") ==========")
    local okSnap, snapErr = xpcall(function()
    addLog("PlaceId=" .. tostring(game.PlaceId) .. " | StreamingEnabled=" .. tostring(workspace.StreamingEnabled))

    -- 1. Character & Attributes
    local chars = workspace:FindFirstChild("Characters")
    local ch = (chars and lp and chars:FindFirstChild(lp.Name)) or (lp and lp.Character)
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        addLog("Char=" .. ch:GetFullName() .. " Attrs=" .. fmtAttrs(ch) .. " Seat=" .. (seat and seat:GetFullName() or "nil"))
    else
        addLog("Char=nil")
    end

    -- 2. Objectives (Workspace & ReplicatedStorage)
    local objRoots = {
        workspace:FindFirstChild("Objectives"),
        ReplicatedStorage:FindFirstChild("Objectives"),
    }
    local m1 = workspace:FindFirstChild("Mission")
    local m2 = ReplicatedStorage:FindFirstChild("Mission")
    if m1 and m1:FindFirstChild("Objectives") then objRoots[#objRoots + 1] = m1.Objectives end
    if m2 and m2:FindFirstChild("Objectives") then objRoots[#objRoots + 1] = m2.Objectives end

    for _, root in ipairs(objRoots) do
        if root then
            addLog("ObjRoot: " .. root:GetFullName())
            for _, chObj in ipairs(root:GetDescendants()) do
                local valStr = ""
                if chObj:IsA("ValueBase") then
                    local okV, rawV = pcall(function() return chObj.Value end)
                    valStr = " Val=" .. fmtVal(okV and rawV or "ERR")
                end
                addLog("  Obj: " .. chObj.Name .. " [" .. chObj.ClassName .. "]" .. valStr .. " Attrs=" .. fmtAttrs(chObj))
            end
        end
    end

    -- 3. PlayerGui Objective Texts (filtered for Raid/Eren/Bertholdt/Stall/Titan)
    local pg = lp and lp:FindFirstChild("PlayerGui")
    if pg then
        local seenTxt = {}
        for _, d in ipairs(pg:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible then
                local txt = tostring(d.Text or "")
                local low = string.lower(txt)
                if #txt > 2 and #txt < 120 and not seenTxt[txt] then
                    if low:find("eren", 1, true) or low:find("bertholdt", 1, true) or low:find("colossal", 1, true)
                        or low:find("stall", 1, true) or low:find("tấn công", 1, true) or low:find("khổng lồ", 1, true)
                        or low:find("bảo vệ", 1, true) or low:find("mục tiêu", 1, true)
                    then
                        seenTxt[txt] = true
                        addLog("  GUI[" .. d.Name .. "]: " .. string.format("%q", txt))
                    end
                end
            end
        end
    end

    -- 4. Titans / Bosses / Allies / Eren / Colossal
    local napePos = findNapePos()
    local containers = { "Titans", "Boss", "Bosses", "Shifters", "Raid", "Allies", "NPCs", "Friendly", "Enemies", "Spawns", "Living", "Entities" }
    local pureSample = 0
    for _, cname in ipairs(containers) do
        local c = workspace:FindFirstChild(cname)
        if c then
            local models = {}
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("Model") and (d:FindFirstChildOfClass("Humanoid") or d:FindFirstChild("Hitboxes") or d:FindFirstChild("Nape", true)) then
                    models[#models + 1] = d
                end
            end
            addLog(string.format("Container workspace.%s: %d models", cname, #models))
            for _, m in ipairs(models) do
                local ln = string.lower(m.Name)
                local isSpecial = (cname ~= "Titans")
                    or ln:find("colossal", 1, true) or ln:find("bertholdt", 1, true)
                    or ln:find("eren", 1, true) or ln:find("attack", 1, true)
                    or ln:find("boss", 1, true) or ln:find("shifter", 1, true)
                    or m:GetAttribute("Ally") == true or m:GetAttribute("Friendly") == true
                    or m:GetAttribute("Boss") == true or m:GetAttribute("Shifter") == true
                if isSpecial or pureSample < 2 then
                    if not isSpecial then pureSample = pureSample + 1 end
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    local hpTxt = hum and string.format("%.1f/%.1f", hum.Health, hum.MaxHealth) or "noHum"
                    local hb = m:FindFirstChild("Hitboxes")
                    local hit = hb and hb:FindFirstChild("Hit")
                    local np = (hit and hit:FindFirstChild("Nape")) or m:FindFirstChild("Nape", true)
                    local npTxt = np and fmtVec(np.Position) or "noNape"
                    addLog(string.format("  Model %s | HP=%s | Nape=%s | Attrs=%s", m:GetFullName(), hpTxt, npTxt, fmtAttrs(m)))
                end
            end
        end
    end

    -- 5. Wall & Cannons Full Scan
    local cl = workspace:FindFirstChild("Climbable")
    if cl then
        local clNames = {}
        for _, child in ipairs(cl:GetChildren()) do
            clNames[#clNames + 1] = child.Name .. "(" .. child.ClassName .. ")"
        end
        addLog("Climbable children: " .. table.concat(clNames, ", "))
        local walls = cl:FindFirstChild("Walls")
        if walls then
            local wallKids = walls:GetChildren()
            local nonEmpty = {}
            local folderDetails = {}
            for idx, w in ipairs(wallKids) do
                for _, cFolder in ipairs(w:GetDescendants()) do
                    if cFolder.Name == "Cannons" and not cFolder:IsA("BasePart") then
                        local ch = cFolder:GetChildren()
                        if #ch > 0 then
                            nonEmpty[#nonEmpty + 1] = string.format("#%d:%s(Cannons=%d)", idx, w.Name, #ch)
                            local itemDesc = {}
                            for _, sub in ipairs(ch) do
                                local subKids = {}
                                for k = 1, math.min(6, #sub:GetChildren()) do
                                    local gc = sub:GetChildren()[k]
                                    subKids[#subKids + 1] = gc.Name .. "(" .. gc.ClassName .. ")"
                                end
                                itemDesc[#itemDesc + 1] = string.format("%s[%s|Attrs=%s|Kids=%s]", sub.Name, sub.ClassName, fmtAttrs(sub), table.concat(subKids, ","))
                            end
                            folderDetails[#folderDetails + 1] = string.format("  [CANNON_DIR] %s -> %s", cFolder:GetFullName(), table.concat(itemDesc, " ; "))
                        end
                    end
                end
            end
            addLog(string.format("Climbable.Walls total=%d | WithCannons=%s", #wallKids, #nonEmpty > 0 and table.concat(nonEmpty, ", ") or "none"))
            if reason == "Initial" or reason == "Manual" then
                for _, line in ipairs(folderDetails) do
                    addLog(line)
                end
            end
        end
    end

    local cannonList = collectAllCannons()
    addLog("Cannons found: " .. tostring(#cannonList))
    for i = 1, math.min(50, #cannonList) do
        local cn = cannonList[i]
        local barrel = cn:FindFirstChild("Barrel")
        local bw = (barrel and barrel:FindFirstChild("BarrelWood")) or cn:FindFirstChild("BarrelWood", true)
        local base = cn:FindFirstChild("Base")
        local prompt = cn:FindFirstChildWhichIsA("ProximityPrompt", true)
        local seat = cn:FindFirstChildWhichIsA("Seat", true) or cn:FindFirstChildWhichIsA("VehicleSeat", true)
        local okPiv, pivCF = pcall(function() return cn:GetPivot() end)
        local refPos = (base and base:IsA("BasePart") and base.Position)
            or (bw and bw:IsA("BasePart") and bw.Position)
            or (okPiv and pivCF and pivCF.Position)
            or nil
        local distTxt = (napePos and refPos) and string.format("%.1f", (napePos - refPos).Magnitude) or "noNape"
        local tagsTxt = ""
        pcall(function()
            local tags = CollectionService:GetTags(cn)
            if #tags > 0 then tagsTxt = " | Tags=" .. table.concat(tags, ",") end
        end)
        addLog(string.format(
            "  Cannon[%d]=%s | Pos=%s | DistNape=%s | HasBarrel=%s | HasBase=%s | Prompt=%s | Seat=%s | Attrs=%s%s",
            i,
            cn:GetFullName(),
            refPos and fmtVec(refPos) or "nil",
            distTxt,
            tostring(barrel ~= nil),
            tostring(base ~= nil),
            prompt and (prompt.Name .. "(en=" .. tostring(prompt.Enabled) .. ")") or "nil",
            seat and seat.Name or "nil",
            fmtAttrs(cn),
            tagsTxt
        ))
        if i <= 3 then
            local childNames = {}
            for _, chPart in ipairs(cn:GetChildren()) do
                childNames[#childNames + 1] = chPart.Name .. "(" .. chPart.ClassName .. ")"
            end
            addLog("    Children=" .. table.concat(childNames, ","))
            if bw and bw:IsA("BasePart") then addLog("    BarrelWood=" .. fmtVec(bw.CFrame)) end
            if base and base:IsA("BasePart") then addLog("    Base=" .. fmtVec(base.CFrame)) end
        end
    end

    -- 6. Active Workspace.Cannon + Actors Check
    local activeCn = workspace:FindFirstChild("Cannon")
    if activeCn then
        local bw = activeCn:FindFirstChild("BarrelWood", true)
        local base = activeCn:FindFirstChild("Base")
        local acChildren = {}
        for _, chPart in ipairs(activeCn:GetChildren()) do
            acChildren[#acChildren + 1] = chPart.Name .. "(" .. chPart.ClassName .. ")"
        end
        addLog("Active workspace.Cannon=" .. activeCn:GetFullName()
            .. " | Attrs=" .. fmtAttrs(activeCn)
            .. " | BW=" .. (bw and bw:IsA("BasePart") and fmtVec(bw.CFrame) or "nil")
            .. " | Base=" .. (base and base:IsA("BasePart") and fmtVec(base.CFrame) or "nil")
            .. " | Children=" .. table.concat(acChildren, ","))
    end

    if reason == "Initial" or reason == "Manual" then
        -- Dump chi tiet Colossal_Titan.Hitboxes
        local _, colM = findNapePos()
        if colM then
            local hb = colM:FindFirstChild("Hitboxes")
            if hb then
                local partsOut = {}
                for _, p in ipairs(hb:GetDescendants()) do
                    if p:IsA("BasePart") then
                        partsOut[#partsOut + 1] = string.format("%s(sz=%.1f,%.1f,%.1f|pos=%s|touch=%s)", p:GetFullName():gsub("^.-Hitboxes%.", "Hitboxes."), p.Size.X, p.Size.Y, p.Size.Z, fmtVec(p.Position), tostring(p.CanTouch))
                    end
                end
                addLog("Colossal Hitboxes (" .. tostring(#partsOut) .. "): " .. table.concat(partsOut, " ; "))
            end
        end

        if getActorsFn then
            local okA, actors = pcall(getActorsFn)
            if okA and type(actors) == "table" then
                local aNames = {}
                for _, act in ipairs(actors) do
                    local okN, fn = pcall(function() return act:GetFullName() end)
                    aNames[#aNames + 1] = okN and fn or tostring(act)
                end
                addLog("Actors(" .. tostring(#actors) .. "): " .. table.concat(aNames, " ; "))
            else
                addLog("Actors=ERR(" .. tostring(actors) .. ")")
            end
        else
            addLog("Actors=UNSUPPORTED(no getactors)")
        end
    end

    if reason == "Initial" then
        local erenHits = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Model") or d:IsA("BasePart") then
                local ln = string.lower(d.Name)
                if ln:find("eren", 1, true) then
                    erenHits = erenHits + 1
                    local posTxt = d:IsA("BasePart") and fmtVec(d.Position) or (d.PrimaryPart and fmtVec(d.PrimaryPart.Position) or "noPos")
                    addLog("  [EREN_SCAN] " .. d:GetFullName() .. " [" .. d.ClassName .. "] " .. posTxt .. " Attrs=" .. fmtAttrs(d))
                    if erenHits >= 10 then break end
                end
            end
        end
    end
    end, debug.traceback)
    if not okSnap then
        addLog("[SNAP_ERR] " .. tostring(snapErr))
    end
    flushLog(true)
end

-- Remote Spy Filter & Logger (Main VM + Cross-VM Actor Bridge)
local IMPORTANT_CATEGORIES = {
    Cannon = true,
    Skills = true,
    S_Skills = true,
    Attacks = true,
    Hitboxes = true,
    Spears = true,
    Blades = true,
    Raid = true,
    Wave = true,
    Waves = true,
    Mission = true,
    Missions = true,
    Interact = true,
    Combat = true,
    Damage = true,
    Prompt = true,
    Seat = true,
    Mount = true,
    Turret = true,
    Titans = true,
    Colossal = true,
    Boss = true,
    Projectile = true,
}

local IGNORED_CATEGORIES = {
    Replication = true,
    Movement = true,
    Move = true,
    Position = true,
    Ping = true,
    Heartbeat = true,
    StateSync = true,
    Camera = true,
}

local function shouldLogRemote(remoteName, args)
    local a1 = type(args[1]) == "string" and args[1] or ""
    if IGNORED_CATEGORIES[a1] then
        return false
    end
    if IMPORTANT_CATEGORIES[a1] then
        return true
    end
    local rn = string.lower(tostring(remoteName or ""))
    if rn:find("cannon", 1, true) or rn:find("skill", 1, true) or rn:find("attack", 1, true)
        or rn:find("hitbox", 1, true) or rn:find("spear", 1, true) or rn:find("raid", 1, true)
        or rn == "post" or rn == "get" or rn:find("remote", 1, true)
    then
        return true
    end
    return false
end

local sigWindowStart, sigCounts = os.clock(), {}
local function allowThrottle(key, isImportant)
    local now = os.clock()
    if now - sigWindowStart > 2.0 then
        sigWindowStart = now
        sigCounts = {}
    end
    local c = (sigCounts[key] or 0) + 1
    sigCounts[key] = c
    local limit = isImportant and 18 or 4
    return c <= limit
end

local function logOutgoingRemote(sourceTag, remoteInst, method, args)
    if typeof(remoteInst) ~= "Instance" then return end
    local okCheck, isImp = pcall(shouldLogRemote, remoteInst.Name, args)
    if not okCheck or not isImp then return end

    local a1 = tostring(args[1] or "")
    local a2 = tostring(args[2] or "")
    local catImp = IMPORTANT_CATEGORIES[a1] == true
    local key = remoteInst.Name .. ":" .. method .. ":" .. a1 .. ":" .. a2
    if not allowThrottle(key, catImp) then
        return
    end

    local formattedArgs = {}
    for i = 1, #args do
        formattedArgs[#formattedArgs + 1] = fmtVal(args[i], 0)
    end
    local msg = string.format("REMOTE[%s] %s:%s(%s)", sourceTag, remoteInst.Name, method, table.concat(formattedArgs, ", "))
    remoteCount = remoteCount + 1
    addLog(msg)

    if args[1] == "Cannon" or args[1] == "S_Skills" then
        pcall(function()
            local napePos = findNapePos()
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            local cn = (seat and seat:FindFirstAncestorOfClass("Model")) or workspace:FindFirstChild("Cannon")
            if cn then
                local bw = cn:FindFirstChild("BarrelWood", true)
                local base = cn:FindFirstChild("Base")
                addLog("  [CANNON_GEO] Model=" .. cn:GetFullName()
                    .. " | BW=" .. (bw and bw:IsA("BasePart") and fmtVec(bw.CFrame) or "nil")
                    .. " | Base=" .. (base and base:IsA("BasePart") and fmtVec(base.CFrame) or "nil")
                    .. " | Nape=" .. (napePos and fmtVec(napePos) or "nil"))
            end
        end)
    end
end

local wrapC = type(newcclosure) == "function" and newcclosure or function(f) return f end
local function isFromCaller()
    return type(checkcaller) == "function" and checkcaller()
end

local hookInstalled = false
local hookFnInstalled = false

if type(hookfunction) == "function" then
    pcall(function()
        local tmpRE = Instance.new("RemoteEvent")
        local oldFire
        oldFire = hookfunction(tmpRE.FireServer, wrapC(function(self, ...)
            if not isFromCaller() then
                pcall(logOutgoingRemote, "FN", self, "FireServer", { ... })
            end
            return oldFire(self, ...)
        end))
        tmpRE:Destroy()
        hookFnInstalled = true
    end)
    pcall(function()
        local tmpRF = Instance.new("RemoteFunction")
        local oldInvoke
        oldInvoke = hookfunction(tmpRF.InvokeServer, wrapC(function(self, ...)
            if not isFromCaller() then
                pcall(logOutgoingRemote, "FN", self, "InvokeServer", { ... })
            end
            return oldInvoke(self, ...)
        end))
        tmpRF:Destroy()
        hookFnInstalled = true
    end)
end

if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    local okHook = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", wrapC(function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer") and not isFromCaller() then
                pcall(logOutgoingRemote, "NC", self, method, { ... })
            end
            return oldNamecall(self, ...)
        end))
        hookInstalled = true
    end)
    if not okHook then
        hookInstalled = false
    end
end

-- Khong tu tiem run_on_actor tren Delta iOS de tranh loi/treo Actor cua game;
-- chi doc danh sach Actor trong snapshot va dung hook an toan o luong chinh.

-- Watch Workspace.Cannon spawn & Player Seated state
pcall(function()
    workspace.ChildAdded:Connect(function(child)
        if child.Name == "Cannon" then
            task.defer(function()
                local bw = child:FindFirstChild("BarrelWood", true)
                addLog("EVENT[WS_CANNON_ADDED] " .. child:GetFullName()
                    .. " | Attrs=" .. fmtAttrs(child)
                    .. " | BW=" .. (bw and bw:IsA("BasePart") and fmtVec(bw.CFrame) or "nil"))
            end)
        end
    end)
end)

local function bindSeatedWatch(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if hum then
        hum.Seated:Connect(function(active, seatPart)
            addLog("EVENT[SEATED] active=" .. tostring(active) .. " | seat=" .. (seatPart and seatPart:GetFullName() or "nil"))
        end)
    end
end
if lp then
    if lp.Character then task.spawn(bindSeatedWatch, lp.Character) end
    lp.CharacterAdded:Connect(function(c) task.spawn(bindSeatedWatch, c) end)
end

-- Also listen to OnClientEvent for Skills/Impact/Cannon/Raid if found
pcall(function()
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") then
            local dn = string.lower(d.Name)
            if dn:find("event") or dn:find("post") or dn:find("remote") or dn:find("cannon") or dn:find("skill") then
                d.OnClientEvent:Connect(function(a1, a2, ...)
                    if a1 == "Skills" or a1 == "Cannon" or a1 == "Raid" or a1 == "Phase" or a1 == "Boss" then
                        remoteCount = remoteCount + 1
                        local extra = { a1, a2, ... }
                        local parts = {}
                        for i = 1, math.min(#extra, 10) do
                            parts[#parts + 1] = fmtVal(extra[i], 0)
                        end
                        addLog("CLIENT_EVT[" .. d.Name .. "](" .. table.concat(parts, ", ") .. ")")
                    end
                end)
            end
        end
    end
end)

-- Full Wall Cannon Sweep (handles StreamingEnabled=true by visiting sampled wall segments)
local isFullScanning = false
local function scanAllWallCannons(btnRef)
    if isFullScanning then return end
    isFullScanning = true
    task.spawn(function()
        local okScan, errScan = xpcall(function()
            local chars = workspace:FindFirstChild("Characters")
            local ch = (chars and lp and chars:FindFirstChild(lp.Name)) or (lp and lp.Character)
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local cl = workspace:FindFirstChild("Climbable")
            local walls = cl and cl:FindFirstChild("Walls")

            local discovered = {}
            local order = {}
            local function recordVisible()
                local napePos = findNapePos()
                for _, cn in ipairs(collectAllCannons()) do
                    local okF, full = pcall(function() return cn:GetFullName() end)
                    local key = okF and full or tostring(cn)
                    local barrel = cn:FindFirstChild("Barrel")
                    local base = cn:FindFirstChild("Base")
                    local bw = (barrel and barrel:FindFirstChild("BarrelWood")) or cn:FindFirstChild("BarrelWood", true)
                    local okP, piv = pcall(function() return cn:GetPivot() end)
                    local pos = (base and base:IsA("BasePart") and base.Position)
                        or (bw and bw:IsA("BasePart") and bw.Position)
                        or (okP and piv and piv.Position)
                        or nil
                    local prev = discovered[key]
                    if not prev then
                        order[#order + 1] = key
                        discovered[key] = {
                            pos = pos,
                            hasBarrel = barrel ~= nil,
                            hasBase = base ~= nil,
                            distNape = (napePos and pos) and (napePos - pos).Magnitude or nil,
                        }
                    else
                        if not prev.pos and pos then prev.pos = pos end
                        if barrel ~= nil then prev.hasBarrel = true end
                        if base ~= nil then prev.hasBase = true end
                        if not prev.distNape and napePos and pos then prev.distNape = (napePos - pos).Magnitude end
                    end
                end
            end

            recordVisible()
            local waypoints = {}
            if walls then
                for _, w in ipairs(walls:GetChildren()) do
                    local okP, cf = pcall(function() return w:GetPivot() end)
                    local pos = okP and cf and cf.Position or nil
                    if not pos then
                        local bp = w:FindFirstChildWhichIsA("BasePart", true)
                        if bp then pos = bp.Position end
                    end
                    if pos then
                        local tooClose = false
                        for _, wp in ipairs(waypoints) do
                            if (wp - pos).Magnitude < 180 then
                                tooClose = true
                                break
                            end
                        end
                        if not tooClose then
                            waypoints[#waypoints + 1] = pos
                        end
                    end
                end
            end

            addLog(string.format("========== FULL CANNON SWEEP (Waypoints=%d) ==========", #waypoints))
            local savedCF = hrp and hrp.CFrame or nil
            local wasPS = hum and hum.PlatformStand or false
            if hum then hum.PlatformStand = true end

            for idx, wp in ipairs(waypoints) do
                if btnRef and btnRef.Parent then
                    btnRef.Text = string.format("Quet %d/%d", idx, #waypoints)
                end
                pcall(function()
                    if lp and type(lp.RequestStreamAroundAsync) == "function" then
                        lp:RequestStreamAroundAsync(wp + Vector3.new(0, 20, 0))
                    end
                end)
                if hrp and hrp.Parent then
                    hrp.CFrame = CFrame.new(wp + Vector3.new(0, 30, 0))
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
                task.wait(0.22)
                recordVisible()
            end

            if hrp and hrp.Parent and savedCF then
                hrp.CFrame = savedCF
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            if hum then hum.PlatformStand = wasPS end

            if walls then
                local nonEmpty = {}
                for idx, w in ipairs(walls:GetChildren()) do
                    local cFolder = w:FindFirstChild("Cannons", true)
                    local cCnt = cFolder and #cFolder:GetChildren() or 0
                    if cCnt > 0 then
                        nonEmpty[#nonEmpty + 1] = string.format("#%d:%s(Cannons=%d)", idx, w.Name, cCnt)
                    end
                end
                addLog("  [SWEEP_WALLS_WITH_CANNONS] " .. (#nonEmpty > 0 and table.concat(nonEmpty, ", ") or "none"))
            end

            addLog("  [SWEEP_TOTAL_CANNONS] " .. tostring(#order))
            for i, key in ipairs(order) do
                local info = discovered[key]
                addLog(string.format(
                    "  FullCannon[%d]=%s | Pos=%s | DistNape=%s | HasBarrel=%s | HasBase=%s",
                    i,
                    key,
                    info.pos and fmtVec(info.pos) or "nil",
                    info.distNape and string.format("%.1f", info.distNape) or "nil",
                    tostring(info.hasBarrel),
                    tostring(info.hasBase)
                ))
            end
            flushLog(true)

            if btnRef and btnRef.Parent then
                btnRef.Text = "Xong: " .. tostring(#order)
                task.delay(2.5, function()
                    if btnRef and btnRef.Parent then btnRef.Text = "Quet Full Phao" end
                end)
            end
        end, debug.traceback)
        if not okScan then
            addLog("[FULL_SWEEP_ERR] " .. tostring(errScan))
            if btnRef and btnRef.Parent then btnRef.Text = "Quet Loi!" end
        end
        isFullScanning = false
    end)
end

-- Safe Read-Only Cannon / Skills Script & Constant Inspector (Android / iOS safe, no Actor hooks)
local isInspectingCode = false
local function inspectGameCannonCode(btnRef)
    if isInspectingCode then return end
    isInspectingCode = true
    if btnRef and btnRef.Parent then btnRef.Text = "Dang soi..." end
    task.spawn(function()
        local okCode, errCode = xpcall(function()
            local decompFn = type(decompile) == "function" and decompile or (syn and type(syn.decompile) == "function" and syn.decompile) or nil
            local getScriptsFn = type(getscripts) == "function" and getscripts or nil
            local getGcFn = type(getgc) == "function" and getgc or nil
            local getConstsFn = type(getconstants) == "function" and getconstants or (debug and type(debug.getconstants) == "function" and debug.getconstants) or nil

            addLog("========== CODE INSPECT (Android/Mobile Safe) ==========")
            addLog(string.format(
                "Capabilities | decompile=%s | getscripts=%s | getgc=%s | getconstants=%s",
                tostring(decompFn ~= nil), tostring(getScriptsFn ~= nil), tostring(getGcFn ~= nil), tostring(getConstsFn ~= nil)
            ))

            local function isInterestingName(name)
                local ln = string.lower(tostring(name or ""))
                return ln:find("cannon", 1, true)
                    or ln:find("skill", 1, true)
                    or ln:find("combat", 1, true)
                    or ln:find("attack", 1, true)
                    or ln:find("hitbox", 1, true)
                    or ln:find("colossal", 1, true)
                    or ln:find("bertholdt", 1, true)
                    or ln:find("raid", 1, true)
                    or ln:find("client", 1, true)
            end

            local candidates, seen = {}, {}
            local function addCand(scr)
                if scr and not seen[scr] and (scr:IsA("LocalScript") or scr:IsA("ModuleScript")) then
                    seen[scr] = true
                    local okF, fn = pcall(function() return scr:GetFullName() end)
                    local full = okF and fn or scr.Name
                    if isInterestingName(scr.Name) or isInterestingName(full) then
                        candidates[#candidates + 1] = { scr = scr, full = full, name = scr.Name }
                    end
                end
            end

            local chars = workspace:FindFirstChild("Characters")
            local ch = (chars and lp and chars:FindFirstChild(lp.Name)) or (lp and lp.Character)
            local ps = lp and lp:FindFirstChild("PlayerScripts")
            for _, root in ipairs({ ReplicatedStorage, ps, ch }) do
                if root then
                    for _, d in ipairs(root:GetDescendants()) do
                        addCand(d)
                    end
                end
            end
            if getScriptsFn then
                pcall(function()
                    for _, s in ipairs(getScriptsFn()) do
                        addCand(s)
                    end
                end)
            end

            table.sort(candidates, function(a, b)
                local la, lb = string.lower(a.full), string.lower(b.full)
                local pa = (la:find("cannon", 1, true) and 3) or (la:find("skill", 1, true) and 2) or 1
                local pb = (lb:find("cannon", 1, true) and 3) or (lb:find("skill", 1, true) and 2) or 1
                if pa ~= pb then return pa > pb end
                return a.full < b.full
            end)

            addLog("Matching scripts/modules: " .. tostring(#candidates))
            for i = 1, math.min(40, #candidates) do
                local c = candidates[i]
                addLog(string.format("  Script[%d]=%s (%s)", i, c.full, c.scr.ClassName))
            end

            if decompFn then
                local decompCount = 0
                for _, c in ipairs(candidates) do
                    local lf = string.lower(c.full)
                    if lf:find("cannon", 1, true) or lf:find("skill", 1, true) or lf:find("hitbox", 1, true) or lf:find("combat", 1, true) then
                        decompCount = decompCount + 1
                        local okD, src = pcall(decompFn, c.scr)
                        if okD and type(src) == "string" and #src > 0 then
                            addLog(string.format("  [DECOMP_OK] %s (len=%d)", c.full, #src))
                            if type(writefile) == "function" and decompCount <= 6 then
                                local safeName = ("aotr_src_" .. c.name):gsub("[^%w_]", "_") .. ".lua"
                                pcall(writefile, safeName, src)
                            end
                            local hits = 0
                            for line in src:gmatch("[^\r\n]+") do
                                local ll = string.lower(line)
                                if ll:find("s_skills", 1, true) or ll:find("impact", 1, true) or ll:find("cannon", 1, true)
                                    or ll:find("shoot", 1, true) or ll:find("fireserver", 1, true) or ll:find("invokeserver", 1, true)
                                then
                                    hits = hits + 1
                                    addLog("    SRC: " .. line:gsub("^%s+", ""):sub(1, 180))
                                    if hits >= 35 then break end
                                end
                            end
                        else
                            addLog(string.format("  [DECOMP_FAIL] %s -> %s", c.full, tostring(src)))
                        end
                        if decompCount >= 6 then break end
                    end
                end
            end

            if getGcFn and getConstsFn then
                local fnHits = 0
                pcall(function()
                    for _, obj in ipairs(getGcFn(false)) do
                        if type(obj) == "function" then
                            local okC, consts = pcall(getConstsFn, obj)
                            if okC and type(consts) == "table" then
                                local hasKey = false
                                local strList = {}
                                for _, cv in pairs(consts) do
                                    if type(cv) == "string" then
                                        if cv == "S_Skills" or cv == "Impact" or cv == "Cannon" or cv == "Shoot" or cv == "State" then
                                            hasKey = true
                                        end
                                        if #cv > 0 and #cv <= 50 and #strList < 14 then
                                            strList[#strList + 1] = string.format("%q", cv)
                                        end
                                    elseif type(cv) == "number" and #strList < 14 then
                                        strList[#strList + 1] = tostring(cv)
                                    end
                                end
                                if hasKey then
                                    local matchedStrong = false
                                    for _, cv in pairs(consts) do
                                        if cv == "S_Skills" or cv == "Shoot" or (cv == "Cannon" and #strList >= 3) then
                                            matchedStrong = true
                                            break
                                        end
                                    end
                                    if matchedStrong then
                                        fnHits = fnHits + 1
                                        addLog("  [GC_FN#" .. fnHits .. "] consts={" .. table.concat(strList, ", ") .. "}")
                                        if fnHits >= 20 then break end
                                    end
                                end
                            end
                        end
                    end
                end)
                addLog("GC matching function count: " .. tostring(fnHits))
            end

            flushLog(true)
            if btnRef and btnRef.Parent then
                btnRef.Text = "Soi xong!"
                task.delay(2.5, function()
                    if btnRef and btnRef.Parent then btnRef.Text = "Soi Code" end
                end)
            end
        end, debug.traceback)
        if not okCode then
            addLog("[CODE_INSPECT_ERR] " .. tostring(errCode))
            if btnRef and btnRef.Parent then btnRef.Text = "Soi Loi!" end
        end
        isInspectingCode = false
    end)
end

-- Minimal UI overlay (top-center, always visible + F9 print + Roblox notification)
print("[AoTR Logger] Dang khoi dong (Delta iOS Safe)... Neu khong thay bang UI, bam F9 de xem.")
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "AoTR Raid Logger",
        Text = "Da bat an toan! Ngoi phao ban tay 1-2 phat roi bam Copy Log.",
        Duration = 5,
    })
end)

local function mountLoggerGui()
    local candidates = {}
    if type(gethui) == "function" then
        local okH, h = pcall(gethui)
        if okH and h then candidates[#candidates + 1] = h end
    end
    candidates[#candidates + 1] = CoreGui
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 3)
        if pg then candidates[#candidates + 1] = pg end
    end

    for _, guiParent in ipairs(candidates) do
        local okMount = pcall(function()
            local existing = guiParent:FindFirstChild("AoTRRaidLoggerGui")
            if existing then existing:Destroy() end

            local sg = Instance.new("ScreenGui")
            sg.Name = "AoTRRaidLoggerGui"
            sg.ResetOnSpawn = false
            sg.IgnoreGuiInset = true
            sg.DisplayOrder = 999999

            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromOffset(478, 68)
            frame.Position = UDim2.new(0.5, -239, 0, 10)
            frame.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
            frame.BorderSizePixel = 0
            frame.Active = true
            frame.Draggable = true
            frame.Parent = sg

            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(70, 170, 255)
            stroke.Thickness = 1.5
            stroke.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 0, 24)
            lbl.Position = UDim2.fromOffset(6, 4)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(120, 255, 160)
            lbl.TextSize = 13
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = "AoTR Logger | DANG CHAY (keo duoc)"
            lbl.Parent = frame

            local snapBtn = Instance.new("TextButton")
            snapBtn.Size = UDim2.fromOffset(88, 26)
            snapBtn.Position = UDim2.fromOffset(6, 34)
            snapBtn.BackgroundColor3 = Color3.fromRGB(52, 118, 224)
            snapBtn.TextColor3 = Color3.new(1, 1, 1)
            snapBtn.TextSize = 11
            snapBtn.Font = Enum.Font.GothamSemibold
            snapBtn.Text = "Snapshot"
            snapBtn.Parent = frame
            Instance.new("UICorner", snapBtn).CornerRadius = UDim.new(0, 6)
            snapBtn.MouseButton1Click:Connect(function()
                takeSnapshot("Manual")
            end)

            local sweepBtn = Instance.new("TextButton")
            sweepBtn.Size = UDim2.fromOffset(96, 26)
            sweepBtn.Position = UDim2.fromOffset(99, 34)
            sweepBtn.BackgroundColor3 = Color3.fromRGB(215, 130, 35)
            sweepBtn.TextColor3 = Color3.new(1, 1, 1)
            sweepBtn.TextSize = 11
            sweepBtn.Font = Enum.Font.GothamSemibold
            sweepBtn.Text = "Quet Phao"
            sweepBtn.Parent = frame
            Instance.new("UICorner", sweepBtn).CornerRadius = UDim.new(0, 6)
            sweepBtn.MouseButton1Click:Connect(function()
                scanAllWallCannons(sweepBtn)
            end)

            local codeBtn = Instance.new("TextButton")
            codeBtn.Size = UDim2.fromOffset(82, 26)
            codeBtn.Position = UDim2.fromOffset(200, 34)
            codeBtn.BackgroundColor3 = Color3.fromRGB(135, 80, 205)
            codeBtn.TextColor3 = Color3.new(1, 1, 1)
            codeBtn.TextSize = 11
            codeBtn.Font = Enum.Font.GothamSemibold
            codeBtn.Text = "Soi Code"
            codeBtn.Parent = frame
            Instance.new("UICorner", codeBtn).CornerRadius = UDim.new(0, 6)
            codeBtn.MouseButton1Click:Connect(function()
                inspectGameCannonCode(codeBtn)
            end)

            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.fromOffset(90, 26)
            copyBtn.Position = UDim2.fromOffset(287, 34)
            copyBtn.BackgroundColor3 = Color3.fromRGB(46, 160, 92)
            copyBtn.TextColor3 = Color3.new(1, 1, 1)
            copyBtn.TextSize = 11
            copyBtn.Font = Enum.Font.GothamSemibold
            copyBtn.Text = "Copy Log"
            copyBtn.Parent = frame
            Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
            copyBtn.MouseButton1Click:Connect(function()
                flushLog(true)
                local text = table.concat(logs, "\n")
                if type(setclipboard) == "function" then
                    pcall(setclipboard, text)
                    copyBtn.Text = "Copied!"
                else
                    copyBtn.Text = "Saved txt!"
                end
                task.delay(1.5, function()
                    if copyBtn and copyBtn.Parent then copyBtn.Text = "Copy Log" end
                end)
            end)

            local closeBtn = Instance.new("TextButton")
            closeBtn.Size = UDim2.fromOffset(90, 26)
            closeBtn.Position = UDim2.fromOffset(382, 34)
            closeBtn.BackgroundColor3 = Color3.fromRGB(175, 55, 55)
            closeBtn.TextColor3 = Color3.new(1, 1, 1)
            closeBtn.TextSize = 11
            closeBtn.Font = Enum.Font.GothamSemibold
            closeBtn.Text = "Luu & Dong"
            closeBtn.Parent = frame
            Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
            closeBtn.MouseButton1Click:Connect(function()
                flushLog(true)
                sg:Destroy()
            end)

            sg.Parent = guiParent
            statusLabel = lbl
        end)
        if okMount and statusLabel then
            print("[AoTR Logger] Da hien bang UI o giua-tren man hinh (" .. guiParent:GetFullName() .. ")")
            break
        end
    end
end
mountLoggerGui()

addLog(string.format(
    "Logger started | hookmetamethod=%s | hookfunction=%s | getactors=%s | writefile=%s",
    tostring(hookInstalled),
    tostring(hookFnInstalled),
    tostring(getActorsFn ~= nil),
    tostring(type(writefile) == "function")
))

-- Auto-snapshots
task.spawn(function()
    task.wait(1.5)
    takeSnapshot("Initial")
    local lastColPhase = nil
    local lastHpBucket = nil
    local lastAutoSnap = os.clock()
    while #logs < MAX_LINES do
        task.wait(2)
        local _, colModel = findNapePos()
        local curPhase = colModel and colModel:GetAttribute("Phase")
        local hum = colModel and colModel:FindFirstChildOfClass("Humanoid")
        local hpPct = (hum and hum.MaxHealth > 0) and math.floor((hum.Health / hum.MaxHealth) * 10) * 10 or nil
        if curPhase ~= lastColPhase or (hpPct and hpPct ~= lastHpBucket and hpPct <= 60) then
            lastColPhase = curPhase
            lastHpBucket = hpPct
            takeSnapshot("PhaseOrHP_" .. tostring(curPhase) .. "_" .. tostring(hpPct))
            lastAutoSnap = os.clock()
        elseif os.clock() - lastAutoSnap >= 20 then
            takeSnapshot("Periodic")
            lastAutoSnap = os.clock()
        end
    end
end)
