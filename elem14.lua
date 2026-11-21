-- AoTR Raid & Colossal Diagnostic Logger (Standalone - Safe Read-Only)
-- Huong dan:
--   1. Chay script nay trong game (truoc hoac ngay khi vao tran Raid Colossal / Attack Titan).
--   2. Tu tay ban: ngoi len 1 khau phao xoay va ban 1-2 phat trung Colossal, danh 1 con Titan gan Eren, doi qua Phase 2.
--   3. Script tu luu log vao file "aotr_raid_log.txt" trong thu muc workspace cua Executor (hoac bam nut [Copy Log] o goc tren).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local LOG_FILE = "aotr_raid_log.txt"
local MAX_LINES = 600

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
        if depth >= 2 then return "{...}" end
        local parts = {}
        local n = 0
        for k, val in pairs(v) do
            n = n + 1
            if n > 12 then
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

local function takeSnapshot(reason)
    addLog("========== SNAPSHOT (" .. tostring(reason) .. ") ==========")
    addLog("PlaceId=" .. tostring(game.PlaceId))

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

    -- 5. Cannons sample
    local cl = workspace:FindFirstChild("Climbable")
    local cannonList = {}
    for _, root in ipairs({ cl, workspace:FindFirstChild("Cannons"), workspace:FindFirstChild("Map") }) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("Model") and (d.Name == "Cannon" or (d:FindFirstChild("Barrel") and d:FindFirstChild("Base"))) then
                    cannonList[#cannonList + 1] = d
                end
            end
        end
    end
    addLog("Cannons found: " .. tostring(#cannonList))
    for i = 1, math.min(2, #cannonList) do
        local cn = cannonList[i]
        local barrel = cn:FindFirstChild("Barrel")
        local bw = barrel and barrel:FindFirstChild("BarrelWood") or cn:FindFirstChild("BarrelWood", true)
        local base = cn:FindFirstChild("Base")
        local seat = cn:FindFirstChildWhichIsA("Seat", true) or cn:FindFirstChildWhichIsA("VehicleSeat", true)
        local childNames = {}
        for _, chPart in ipairs(cn:GetChildren()) do
            childNames[#childNames + 1] = chPart.Name .. "(" .. chPart.ClassName .. ")"
        end
        addLog(string.format("  Cannon[%d]=%s | Children=%s", i, cn:GetFullName(), table.concat(childNames, ",")))
        if bw and bw:IsA("BasePart") then addLog("    BarrelWood=" .. fmtVec(bw.CFrame)) end
        if base and base:IsA("BasePart") then addLog("    Base=" .. fmtVec(base.CFrame)) end
        if seat and seat:IsA("BasePart") then addLog("    Seat=" .. fmtVec(seat.CFrame)) end
    end
    flushLog(true)
end

-- Remote Spy Hook (only important AoTR remotes, ignoring spam!)
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
}

local function shouldLogRemote(remoteName, args)
    local a1 = type(args[1]) == "string" and args[1] or ""
    if IMPORTANT_CATEGORIES[a1] then
        return true
    end
    local rn = string.lower(tostring(remoteName or ""))
    if rn:find("cannon", 1, true) or rn:find("skill", 1, true) or rn:find("attack", 1, true)
        or rn:find("hitbox", 1, true) or rn:find("spear", 1, true) or rn:find("raid", 1, true)
    then
        return true
    end
    return false
end

local hookInstalled = false
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    local okHook = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer") and not checkcaller() then
                local args = { ... }
                local okCheck, isImp = pcall(shouldLogRemote, self.Name, args)
                if okCheck and isImp then
                    remoteCount = remoteCount + 1
                    local formattedArgs = {}
                    for i = 1, #args do
                        formattedArgs[#formattedArgs + 1] = fmtVal(args[i], 0)
                    end
                    addLog(string.format("REMOTE %s:%s(%s)", self.Name, method, table.concat(formattedArgs, ", ")))

                    -- Extra geometry capture when user fires or aims a Cannon!
                    if args[1] == "Cannon" then
                        pcall(function()
                            local napePos = findNapePos()
                            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                            local seat = hum and hum.SeatPart
                            local cn = seat and seat:FindFirstAncestorOfClass("Model")
                            if cn then
                                local bw = cn:FindFirstChild("BarrelWood", true)
                                local base = cn:FindFirstChild("Base")
                                addLog("  [CANNON_GEO] Model=" .. cn:GetFullName()
                                    .. " | BW=" .. (bw and fmtVec(bw.CFrame) or "nil")
                                    .. " | Base=" .. (base and base:IsA("BasePart") and fmtVec(base.CFrame) or "nil")
                                    .. " | Nape=" .. (napePos and fmtVec(napePos) or "nil"))
                            end
                        end)
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        hookInstalled = true
    end)
    if not okHook then
        hookInstalled = false
    end
end

-- Also listen to OnClientEvent for Skills/Impact/Cannon if found
pcall(function()
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") then
            local dn = string.lower(d.Name)
            if dn:find("event") or dn:find("post") or dn:find("remote") or dn:find("cannon") or dn:find("skill") then
                d.OnClientEvent:Connect(function(a1, a2, ...)
                    if a1 == "Skills" or a1 == "Cannon" or a1 == "Raid" or a1 == "Phase" then
                        remoteCount = remoteCount + 1
                        local extra = { a1, a2, ... }
                        local parts = {}
                        for i = 1, math.min(#extra, 6) do
                            parts[#parts + 1] = fmtVal(extra[i], 0)
                        end
                        addLog("CLIENT_EVT[" .. d.Name .. "](" .. table.concat(parts, ", ") .. ")")
                    end
                end)
            end
        end
    end
end)

-- Minimal UI overlay (top-center, always visible + F9 print + Roblox notification)
print("[AoTR Logger] Dang khoi dong... Neu khong thay bang UI, bam F9 de xem.")
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "AoTR Raid Logger",
        Text = "Da bat thanh cong! Choi 1 tran Colo roi bam Copy Log.",
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
            frame.Size = UDim2.fromOffset(330, 68)
            frame.Position = UDim2.new(0.5, -165, 0, 10)
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
            snapBtn.Size = UDim2.fromOffset(105, 26)
            snapBtn.Position = UDim2.fromOffset(6, 34)
            snapBtn.BackgroundColor3 = Color3.fromRGB(52, 118, 224)
            snapBtn.TextColor3 = Color3.new(1, 1, 1)
            snapBtn.TextSize = 12
            snapBtn.Font = Enum.Font.GothamSemibold
            snapBtn.Text = "Chup Snapshot"
            snapBtn.Parent = frame
            Instance.new("UICorner", snapBtn).CornerRadius = UDim.new(0, 6)
            snapBtn.MouseButton1Click:Connect(function()
                takeSnapshot("Manual")
            end)

            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.fromOffset(105, 26)
            copyBtn.Position = UDim2.fromOffset(116, 34)
            copyBtn.BackgroundColor3 = Color3.fromRGB(46, 160, 92)
            copyBtn.TextColor3 = Color3.new(1, 1, 1)
            copyBtn.TextSize = 12
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
            closeBtn.Size = UDim2.fromOffset(96, 26)
            closeBtn.Position = UDim2.fromOffset(226, 34)
            closeBtn.BackgroundColor3 = Color3.fromRGB(175, 55, 55)
            closeBtn.TextColor3 = Color3.new(1, 1, 1)
            closeBtn.TextSize = 12
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

addLog("Logger started | hookmetamethod=" .. tostring(hookInstalled) .. " | writefile=" .. tostring(type(writefile) == "function"))

-- Auto-snapshots: at start, and whenever Colossal HP crosses Phase milestones or every 15s
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
