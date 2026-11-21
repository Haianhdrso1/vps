-- ============================================================================
-- AoTR Colossal Raid Standalone Test Script (v1 - Real Live Log Tuned)
-- Khong sua bat ky file nao khac. Chay doc lap de test rieng Raid Colossal.
-- Dual-mode: tu nhan Kiem (9-hit 700..900) hoac Thuong (9x S_Explode).
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer

-- Trang thai & Cau hinh
local Config = {
    Enabled = true,
    AutoCannon = true,
    AutoDefendEren = true,
    AutoRefill = true,
    DefendRadius = 420,
    CannonImpactBurst = 15,
    HitAllBatch = 8,
}

local State = {
    Mode = "INIT", -- INIT | REFILL | DEFEND_EREN | CANNON | PHASE2 | IDLE
    HoverTarget = nil,
    CannonBusy = false,
    ActiveCannon = nil,
    MountedCannon = nil,
    DefendErenActive = false,
    AttackBusy = false,
    RefillBusy = false,
    LastRefillAt = 0,
    LastShotAt = 0,
    Shots = 0,
    ImpactEvents = 0,
    Impacts = 0,
    StatusText = "Dang khoi tao...",
}

local CannonHome = setmetatable({}, { __mode = "k" })
local CannonCalib = setmetatable({}, { __mode = "k" })
local OriginalSizes = setmetatable({}, { __mode = "k" })

-- ============================================================================
-- Remotes & Character Helpers
-- ============================================================================
local POST, GET = nil, nil
local function resolveRemotes()
    if POST and GET and POST.Parent and GET.Parent then
        return true
    end
    local assets = ReplicatedStorage:FindFirstChild("Assets") or ReplicatedStorage:WaitForChild("Assets", 10)
    local rems = assets and (assets:FindFirstChild("Remotes") or assets:WaitForChild("Remotes", 10))
    if rems then
        POST = rems:FindFirstChild("POST") or rems:WaitForChild("POST", 5)
        GET = rems:FindFirstChild("GET") or rems:WaitForChild("GET", 5)
    end
    return POST ~= nil and GET ~= nil
end

local function getNilInstance(name)
    local res = nil
    pcall(function()
        if type(getnilinstances) ~= "function" then return end
        for _, inst in ipairs(getnilinstances()) do
            if inst.Name == name then
                res = inst
                break
            end
        end
    end)
    return res
end

local function getChar()
    local chars = workspace:FindFirstChild("Characters")
    return (chars and lp and chars:FindFirstChild(lp.Name)) or (lp and lp.Character)
end

local function getRig()
    local ch = getChar()
    return ch and lp and ch:FindFirstChild("Rig_" .. lp.Name)
end

local function isSpearEquipped()
    local rig = getRig()
    if not rig then return false end
    local lla = rig:FindFirstChild("LeftLowerArm")
    local rla = rig:FindFirstChild("RightLowerArm")
    return (lla and lla:FindFirstChild("Spears") ~= nil) or (rla and rla:FindFirstChild("Spears") ~= nil) or false
end

local function getNextSpearSlot()
    local rig = getRig()
    if not rig then return 0 end
    local lla = rig:FindFirstChild("LeftLowerArm") and rig.LeftLowerArm:FindFirstChild("Spears")
    local rla = rig:FindFirstChild("RightLowerArm") and rig.RightLowerArm:FindFirstChild("Spears")
    if lla or rla then
        for i = 16, 1, -1 do
            local arm = (i % 2 == 0) and rla or lla
            local sp = arm and arm:FindFirstChild(tostring(i))
            if sp and sp:GetAttribute("Used") ~= true and sp.Transparency < 0.9 then
                return i
            end
        end
    end
    return 0
end

local function areBladesBroken()
    if isSpearEquipped() then return false end
    local rig = getRig()
    if not rig then return false end
    local hasAny = false
    for _, d in ipairs(rig:GetDescendants()) do
        if d:IsA("MeshPart") and d.Name:sub(1, 5) == "Blade" then
            hasAny = true
            if d:GetAttribute("Broken") ~= true and d.Transparency < 0.9 then
                return false
            end
        end
    end
    return hasAny
end

local function needsRefill()
    if isSpearEquipped() then
        local slot = getNextSpearSlot()
        if slot > 0 then return false end
        local ch = getChar()
        local attrSp = ch and tonumber(ch:GetAttribute("Spears"))
        return (attrSp == nil or attrSp <= 0)
    end
    return areBladesBroken()
end

local function canAct()
    local ch = getChar()
    if not ch then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    -- Theo log that: nhan vat dung attr "Ragdoll", "Setup"
    if ch:GetAttribute("Ragdoll") == true or ch:GetAttribute("Ragdolled") == true then
        return false
    end
    local pg = lp and lp:FindFirstChild("PlayerGui")
    local fs = pg and pg:FindFirstChild("Fullscreen")
    local ls = fs and fs:FindFirstChild("Loading_Screen")
    if ls and ls.Visible == true then
        return false
    end
    return true
end

-- ============================================================================
-- Real Log Findings: Eren, Colossal, Phase 2 & PlayerGui Objectives
-- ============================================================================
local erenCache = nil
local function getErenModel()
    if erenCache and erenCache.Parent then
        return erenCache
    end
    erenCache = nil
    local uncl = workspace:FindFirstChild("Unclimbable")
    local objFld = uncl and uncl:FindFirstChild("Objective")
    if objFld then
        local direct = objFld:FindFirstChild("Defend_Eren_2") or objFld:FindFirstChild("Defend_Eren")
        if direct then
            erenCache = direct
            return direct
        end
        for _, ch in ipairs(objFld:GetChildren()) do
            if string.lower(ch.Name):find("eren", 1, true) then
                erenCache = ch
                return ch
            end
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and string.lower(d.Name):find("defend_eren", 1, true) then
            erenCache = d
            return d
        end
    end
    return nil
end

local function getErenPos()
    local em = getErenModel()
    if not em then return nil end
    if em:IsA("BasePart") then return em.Position end
    local ok, cf = pcall(function() return em:GetPivot() end)
    if ok and cf then return cf.Position end
    local part = em.PrimaryPart or em:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position or nil
end

local function readGuiObjectives()
    local erenPct, stallText, stallCur, stallReq = nil, nil, nil, nil
    local pg = lp and lp:FindFirstChild("PlayerGui")
    if not pg then return nil, nil, nil, nil end

    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") then
            local name = d.Name
            local txt = tostring(d.Text or "")
            local low = string.lower(txt)
            if name:find("Defend_Eren", 1, true) or low:find("defend eren", 1, true) or low:find("bảo vệ eren", 1, true) then
                local pct = txt:match("(%d+%.?%d*)%%")
                if pct then erenPct = tonumber(pct) end
            elseif name:find("Stall_Colossal", 1, true) or low:find("stall bertholdt", 1, true) or low:find("stall colossal", 1, true) then
                stallText = txt
                local c1, c2 = txt:match("(%d+)%s*/%s*(%d+)")
                if c1 and c2 then
                    stallCur = tonumber(c1)
                    stallReq = tonumber(c2)
                end
            end
        end
    end
    return erenPct, stallText, stallCur, stallReq
end

local function getColossalModel()
    for _, fn in ipairs({ "Titans", "Boss", "Bosses", "Shifters", "Raid" }) do
        local f = workspace:FindFirstChild(fn)
        if f then
            local c = f:FindFirstChild("Colossal_Titan")
            if c and c:IsA("Model") then return c end
            for _, m in ipairs(f:GetChildren()) do
                if m:IsA("Model") then
                    local ln = string.lower(m.Name)
                    if ln:find("colossal", 1, true) or ln:find("bertholdt", 1, true) or m:GetAttribute("Type") == "Colossal" then
                        return m
                    end
                end
            end
        end
    end
    return nil
end

local function getTitanNape(model)
    if not model or not model.Parent then return nil end
    local hb = model:FindFirstChild("Hitboxes")
    local hit = hb and hb:FindFirstChild("Hit")
    if hit then
        local np = hit:FindFirstChild("Nape") or hit:FindFirstChild("Weakpoint") or hit:FindFirstChild("Core")
        if np and np:IsA("BasePart") then return np end
    end
    local np2 = model:FindFirstChild("Nape", true)
    if np2 and np2:IsA("BasePart") then return np2 end
    return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
end

local function isTitanAlive(model)
    if not model or not model.Parent or not model:IsA("Model") then return false end
    -- Theo log that: Titan chet co Attr Dead=true va mat Humanoid
    if model:GetAttribute("Dead") == true then return false end
    local st = model:GetAttribute("State")
    if st == "Dead" or st == "Die" or st == "Dying" then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    -- Neu la Titan thuong ma khong co Humanoid thi da chet hoac khong phai quai song
    local ln = string.lower(model.Name)
    local isColossal = (model.Name == "Colossal_Titan" or ln:find("colossal", 1, true) or model:GetAttribute("Type") == "Colossal")
    if not isColossal and not hum then
        return false
    end
    return getTitanNape(model) ~= nil
end

local sawStallGui, reachedPhase2 = false, false
local function isColossalPhase2()
    local col = getColossalModel()
    if not col then
        sawStallGui, reachedPhase2 = false, false
        return false
    end
    if reachedPhase2 then return true end
    if col:GetAttribute("Phase") == 2 or col:GetAttribute("Phase2") == true then
        reachedPhase2 = true
        return true
    end
    local em = getErenModel()
    if em and em:GetAttribute("Phase") == 2 then
        reachedPhase2 = true
        return true
    end
    local _, stallTxt, stallCur, stallReq = readGuiObjectives()
    if stallTxt then
        sawStallGui = true
        if stallCur and stallReq and stallReq > 0 and stallCur >= stallReq then
            reachedPhase2 = true
            return true
        end
    elseif sawStallGui then
        -- Chi sang Phase 2 neu Stall muc tieu da xuat hien o Phase 1 roi bien mat
        reachedPhase2 = true
        return true
    end
    return false
end

local function collectEnemyTitans(excludeColossal)
    local list = {}
    local f = workspace:FindFirstChild("Titans")
    if not f then return list end
    for _, m in ipairs(f:GetChildren()) do
        if m:IsA("Model") and isTitanAlive(m) then
            local ln = string.lower(m.Name)
            local isCol = (m.Name == "Colossal_Titan" or ln:find("colossal", 1, true) or m:GetAttribute("Type") == "Colossal")
            if not (excludeColossal and isCol) then
                list[#list + 1] = m
            end
        end
    end
    return list
end

-- ============================================================================
-- Cannon Seat, Aim (-LookVector + High-Distance Pitch) & Auto-Calibration
-- ============================================================================
local function isExternalCannonPart(part, ch, targetC)
    if not part or not part:IsA("BasePart") then return false end
    if ch and part:IsDescendantOf(ch) then return false end
    if targetC and targetC.Parent and part:IsDescendantOf(targetC) then return true end
    local cur = part.Parent
    while cur and cur ~= workspace do
        local ln = string.lower(cur.Name)
        if ln:find("cannon", 1, true) or ln == "climbable" then
            return true
        end
        cur = cur.Parent
    end
    return false
end

local function isAttachedToCannon()
    local ch = getChar()
    if not ch then return false end
    if lp and State.ActiveCannon and State.ActiveCannon.Parent and State.ActiveCannon:GetAttribute("Player") == lp.Name then
        return true
    end
    local hm = ch:FindFirstChildOfClass("Humanoid")
    if hm and (hm.SeatPart ~= nil or hm.Sit == true) then
        return true
    end
    for _, d in ipairs(ch:GetDescendants()) do
        if d:IsA("JointInstance") or d:IsA("WeldConstraint") then
            if d.Name == "SeatWeld"
                or (d.Part0 and isExternalCannonPart(d.Part0, ch, State.ActiveCannon))
                or (d.Part1 and isExternalCannonPart(d.Part1, ch, State.ActiveCannon))
            then
                return true
            end
        end
    end
    return false
end

local function detachFromCannon(canWait)
    local function stripOnce()
        local ch = getChar()
        local hm = ch and ch:FindFirstChildOfClass("Humanoid")
        if hm then
            pcall(function()
                local seat = hm.SeatPart
                if seat then
                    for _, w in ipairs(seat:GetChildren()) do
                        if w:IsA("Weld") or w:IsA("SeatWeld") or w.Name == "SeatWeld" then w:Destroy() end
                    end
                end
            end)
            if hm.Sit then hm.Sit = false end
            pcall(function() hm:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
        if ch then
            for _, d in ipairs(ch:GetDescendants()) do
                if d:IsA("JointInstance") or d:IsA("WeldConstraint") then
                    if d.Name == "SeatWeld"
                        or (d.Part0 and isExternalCannonPart(d.Part0, ch, State.ActiveCannon))
                        or (d.Part1 and isExternalCannonPart(d.Part1, ch, State.ActiveCannon))
                    then
                        pcall(function() d:Destroy() end)
                    end
                end
            end
        end
    end

    stripOnce()
    if canWait then
        local t0 = os.clock()
        while isAttachedToCannon() and os.clock() - t0 < 0.65 do
            task.wait(0.05)
            stripOnce()
        end
    end
    local ch = getChar()
    local hm = ch and ch:FindFirstChildOfClass("Humanoid")
    if hm then hm.PlatformStand = false end
end

local function invokeCannon(...)
    if not resolveRemotes() then return false, "no remote" end
    local args = table.pack(...)
    local done, r1, r2 = false, nil, nil
    task.spawn(function()
        local ok, a, b = pcall(function() return GET:InvokeServer(table.unpack(args, 1, args.n)) end)
        if ok then r1, r2 = a, b else r1, r2 = false, a end
        done = true
    end)
    local t0 = os.clock()
    while not done and os.clock() - t0 < 3.5 do
        task.wait(0.04)
    end
    if not done then return false, "timeout" end
    return r1 == true, r2
end

local function findWallCannons()
    local list = {}
    local cl = workspace:FindFirstChild("Climbable")
    if cl then
        for _, d in ipairs(cl:GetDescendants()) do
            if d:IsA("Model") and d:FindFirstChild("Barrel") and d:FindFirstChild("Base") then
                list[#list + 1] = d
            end
        end
    end
    return list
end

local function getCannonGeometry(cannon)
    if not cannon or not cannon.Parent then return nil end
    -- Luon doc tu khau phao tren thanh (Workspace.Cannon la vien dan bay, khong phai nong phao)
    local barrel = cannon:FindFirstChild("Barrel")
    local bw = (barrel and (barrel:FindFirstChild("BarrelWood") or barrel:FindFirstChildWhichIsA("BasePart")))
        or cannon:FindFirstChild("BarrelWood", true)
    local base = cannon:FindFirstChild("Base")
    local seat = cannon:FindFirstChildWhichIsA("Seat", true) or cannon:FindFirstChildWhichIsA("VehicleSeat", true)
    if not (bw and bw:IsA("BasePart")) then return nil end

    -- Huong mac dinh theo log that: (BarrelWood.Pos - Base.Pos) la +X, va BarrelWood.LookVector la -1 -> muzzle = -LookVector!
    local home = CannonHome[cannon]
    if not home then
        local fwdXZ = Vector3.new(1, 0, 0)
        if base and base:IsA("BasePart") then
            local dv = Vector3.new(bw.Position.X - base.Position.X, 0, bw.Position.Z - base.Position.Z)
            if dv.Magnitude > 0.25 then
                fwdXZ = dv.Unit
            end
        end
        local cf = bw.CFrame
        local candidates = {
            { axis = "LookVector", sign = 1, vec = cf.LookVector },
            { axis = "LookVector", sign = -1, vec = -cf.LookVector },
            { axis = "RightVector", sign = 1, vec = cf.RightVector },
            { axis = "RightVector", sign = -1, vec = -cf.RightVector },
        }
        local best = candidates[2]
        local bestDot = -math.huge
        for _, c in ipairs(candidates) do
            local xz = Vector3.new(c.vec.X, 0, c.vec.Z)
            if xz.Magnitude > 0.05 then
                local d = xz.Unit:Dot(fwdXZ)
                if d > bestDot then
                    bestDot = d
                    best = c
                end
            end
        end
        home = { fwdXZ = fwdXZ, muzzleAxis = best.axis, muzzleSign = best.sign }
        CannonHome[cannon] = home
    end

    return {
        cannon = cannon,
        liveModel = liveModel,
        barrelWood = bw,
        base = base,
        seat = seat,
        muzzleOrigin = bw.Position,
        fwdXZ = home.fwdXZ,
        home = home,
    }
end

local function readMuzzleDir(bw, home)
    if not (bw and bw.Parent and home) then return nil end
    local cf = bw.CFrame
    local v = (home.muzzleAxis == "RightVector" and cf.RightVector) or cf.LookVector
    if (home.muzzleSign or 1) < 0 then v = -v end
    return v
end

local function measureCannonErr(cannon, targetPos, overrideDir)
    local geo = getCannonGeometry(cannon)
    if not (geo and targetPos) then return nil, nil, nil end
    local liveDir = overrideDir or readMuzzleDir(geo.barrelWood, geo.home)
    if not liveDir then return nil, nil, nil end
    local toTarget = targetPos - geo.muzzleOrigin
    if toTarget.Magnitude < 1 then return 0, 0, liveDir end
    local toDir = toTarget.Unit
    local lxz = Vector3.new(liveDir.X, 0, liveDir.Z)
    local txz = Vector3.new(toDir.X, 0, toDir.Z)
    local errYaw = 0
    if lxz.Magnitude > 0.05 and txz.Magnitude > 0.05 then
        lxz, txz = lxz.Unit, txz.Unit
        local dot = math.clamp(lxz:Dot(txz), -1, 1)
        local cross = lxz.Z * txz.X - lxz.X * txz.Z
        errYaw = math.deg(math.atan2(cross, dot))
    end
    local livePitch = math.deg(math.asin(math.clamp(liveDir.Y, -1, 1)))
    local wantPitch = math.deg(math.asin(math.clamp(toDir.Y, -1, 1)))
    return errYaw, wantPitch - livePitch, liveDir
end

local function computeCannonAim(cannon, napePos)
    local geo = getCannonGeometry(cannon)
    if not geo or not napePos then
        return { BarrelWood = 26, Base = 0 }, 0, 1400, geo
    end
    local calib = CannonCalib[cannon] or { yawSign = 1, yawTrim = 0, pitchTrim = 0, flips = 0 }
    local delta = napePos - geo.muzzleOrigin
    local horiz = Vector3.new(delta.X, 0, delta.Z)
    local distXZ = horiz.Magnitude
    local toXZ = distXZ > 0.1 and horiz.Unit or geo.fwdXZ
    local alignDot = math.clamp(geo.fwdXZ:Dot(toXZ), -1, 1)
    local crossY = geo.fwdXZ.Z * toXZ.X - geo.fwdXZ.X * toXZ.Z
    local rawYaw = math.deg(math.atan2(crossY, alignDot)) * (calib.yawSign or 1)
    local yawDeg = math.clamp(math.floor(rawYaw + (calib.yawTrim or 0) + 0.5), -65, 65)

    -- Theo log that: cu ly ~1400 studs can tong goc ngang ~22-30 do (directPitch ~6 + bu roi trong luc ~21)
    local directPitch = math.deg(math.atan2(delta.Y, math.max(distXZ, 1)))
    local gravityComp = math.clamp(distXZ * 0.0155, 0, 23)
    local pitchDeg = math.clamp(math.floor(directPitch + gravityComp + (calib.pitchTrim or 0) + 0.5), -10, 55)
    return { BarrelWood = pitchDeg, Base = yawDeg }, alignDot, distXZ, geo
end

local function calibrateAfterShot(cannon, sentAngles, napePos, dirBeforeShot)
    if not (cannon and sentAngles and napePos) then return nil, nil end
    local errYaw, errPitch, dirAfterShot = measureCannonErr(cannon, napePos)
    if not (errYaw and errPitch and dirAfterShot) then return errYaw, errPitch end
    local moved = dirBeforeShot and (dirBeforeShot:Dot(dirAfterShot) < 0.99998)
    local calib = CannonCalib[cannon]
    if not calib then
        calib = { yawSign = 1, yawTrim = 0, pitchTrim = 0, flips = 0 }
        CannonCalib[cannon] = calib
    end
    local errBefore = dirBeforeShot and select(1, measureCannonErr(cannon, napePos, dirBeforeShot)) or nil
    local baseline = errBefore or calib.lastYawErr
    if moved and baseline and math.abs(sentAngles.Base or 0) >= 3 and math.abs(baseline) > 4 then
        if math.abs(errYaw) > math.abs(baseline) + 4 and calib.flips < 2 then
            calib.yawSign = -calib.yawSign
            calib.yawTrim = 0
            calib.flips = calib.flips + 1
            calib.lastYawErr = errYaw
            return errYaw, errPitch
        end
    end
    local confirmed = (calib.lastYawErr ~= nil) or (math.abs(errYaw) <= 8) or (errBefore ~= nil and math.abs(errYaw) < math.abs(errBefore))
    if moved and confirmed and math.abs(errYaw) <= 55 then
        calib.yawTrim = math.clamp(calib.yawTrim + errYaw * calib.yawSign * 0.40, -45, 45)
    end
    -- Pitch giu trim nho de khong tu day len troi neu dang co du gravityComp
    if moved and math.abs(errPitch) <= 35 then
        calib.pitchTrim = math.clamp(calib.pitchTrim + errPitch * 0.25, -18, 22)
    end
    calib.lastYawErr = errYaw
    return errYaw, errPitch
end

local function buildCannonTable(cannon, napePos)
    local geo = getCannonGeometry(cannon)
    local angles = select(1, computeCannonAim(cannon, napePos))
    return {
        SFX = { Y = getNilInstance("Cannon_Y"), X = getNilInstance("Cannon_X") },
        Object = cannon,
        BarrelWood = geo and geo.barrelWood,
        Angles = angles,
        Base = geo and geo.base,
        Directions = {},
    }
end

local function findModelInArgs(val, depth)
    depth = depth or 0
    if typeof(val) == "Instance" then
        if val:IsA("Model") then return val end
        if val:IsA("BasePart") and val.Parent and val.Parent:IsA("Model") then return val.Parent end
        return nil
    end
    if type(val) == "table" and depth < 4 then
        for _, v in pairs(val) do
            local m = findModelInArgs(v, depth + 1)
            if m then return m end
        end
    end
    return nil
end

local function getOwnedProjectile()
    local fallback = nil
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name == "Cannon" and child:IsA("Model") then
            if lp and child:GetAttribute("Player") == lp.Name then
                return child
            end
            fallback = fallback or child
        end
    end
    return fallback
end

local function mountCannonPrompt(cannon)
    if type(fireproximityprompt) ~= "function" or not cannon then return false end
    local prompt = cannon:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return false end
    return pcall(function()
        local p = prompt.Parent
        local pPos = p and ((p:IsA("Attachment") and p.WorldPosition) or (p:IsA("BasePart") and p.Position))
        local ch = getChar()
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if pPos and hrp and (hrp.Position - pPos).Magnitude > math.max((prompt.MaxActivationDistance or 10) - 2, 5) then
            hrp.CFrame = CFrame.new(pPos + Vector3.new(0, 3, 0))
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            task.wait(0.2)
        end
        fireproximityprompt(prompt)
    end)
end

-- ============================================================================
-- Combat: Refill, 9-Hit Blades (700..900), 9x Thunder Spears (S_Explode)
-- ============================================================================
local function doRefill()
    if State.RefillBusy or os.clock() - State.LastRefillAt < 5 then return end
    State.RefillBusy = true
    detachFromCannon(true)
    if isSpearEquipped() then
        local refillPart = nil
        for _, root in ipairs({ workspace:FindFirstChild("Unclimbable"), workspace:FindFirstChild("Climbable"), workspace }) do
            if root then
                refillPart = root:FindFirstChild("Refill", true)
                if refillPart and refillPart:IsA("BasePart") then break else refillPart = nil end
            end
        end
        local ch = getChar()
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if refillPart and hrp then
            hrp.CFrame = refillPart.CFrame + Vector3.new(0, 3, 0)
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            task.wait(0.45)
            resolveRemotes()
            if POST then pcall(function() POST:FireServer("Attacks", "Reload", refillPart) end) end
        end
    else
        resolveRemotes()
        if GET then pcall(function() GET:InvokeServer("Blades", "Reload") end) end
        task.wait(0.4)
    end
    State.LastRefillAt = os.clock()
    State.RefillBusy = false
end

local function attackTargets(targetsList)
    if State.AttackBusy or not canAct() then return false end
    resolveRemotes()
    if not POST then return false end

    local napes, models = {}, {}
    for _, m in ipairs(targetsList) do
        if m and m.Parent and isTitanAlive(m) then
            local np = getTitanNape(m)
            if np and np.Parent then
                models[#models + 1] = m
                napes[#napes + 1] = np
                if #napes >= Config.HitAllBatch then break end
            end
        end
    end
    if #napes == 0 then return false end

    if isSpearEquipped() then
        local slot = getNextSpearSlot()
        if slot <= 0 or not GET then return false end
        local fired = false
        pcall(function() fired = GET:InvokeServer("Spears", "S_Fire", tostring(slot)) == true end)
        if not fired then return false end
        task.wait(0.03)
        local function jitter(p)
            return p + Vector3.new((math.random() - 0.5) * 0.6, (math.random() - 0.5) * 0.6, (math.random() - 0.5) * 0.6)
        end
        for i = 1, 9 do
            local np = napes[((i - 1) % #napes) + 1]
            if np and np.Parent then
                pcall(function() POST:FireServer("Spears", "S_Explode", jitter(np.Position), 2.5) end)
            end
        end
        return true
    end

    -- Blades 9-hit ("chem no 9 dame")
    local ch = getChar()
    local hb = ch and ch:FindFirstChild("Hitbox")
    State.AttackBusy = true
    local ok = pcall(function()
        local oldCG, oldSize
        if hb and hb:IsA("BasePart") then
            oldCG, oldSize = hb.CollisionGroup, hb.Size
            if not OriginalSizes[hb] then OriginalSizes[hb] = oldSize end
            hb.CollisionGroup = "Default"
            hb.CanTouch = true
            hb.Size = Vector3.new(140, 140, 140)
        end
        for _, m in ipairs(models) do
            local hit = m:FindFirstChild("Hitboxes") and m.Hitboxes:FindFirstChild("Hit")
            if hit then
                for _, p in ipairs(hit:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.CollisionGroup = "Default"
                        p.CanTouch = (p.Name == "Nape")
                    end
                end
            end
        end
        pcall(function()
            if hb and type(getconnections) == "function" then
                local conns = getconnections(hb.Touched)
                for _, np in ipairs(napes) do
                    for _, c in ipairs(conns) do pcall(c.Fire, c, np) end
                end
            end
        end)
        for i = 1, 9 do
            local np = napes[((i - 1) % #napes) + 1]
            if np and np.Parent then
                POST:FireServer("Attacks", "Slash", true)
                POST:FireServer("Hitboxes", "Register", np, math.random(700, 900))
            end
        end
        if os.clock() - (_G.__coloLastM1Anim or 0) >= 0.35 then
            _G.__coloLastM1Anim = os.clock()
            task.spawn(function()
                pcall(function()
                    local cam = workspace.CurrentCamera
                    local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
                    VirtualInputManager:SendMouseButtonEvent(vp.X * 0.5, vp.Y * 0.5, 0, true, game, 0)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(vp.X * 0.5, vp.Y * 0.5, 0, false, game, 0)
                end)
            end)
        end
        if hb and hb.Parent and hb:IsA("BasePart") then
            pcall(function()
                if oldCG then hb.CollisionGroup = oldCG end
                if oldSize then hb.Size = oldSize end
            end)
        end
    end)
    State.AttackBusy = false
    return ok
end

-- ============================================================================
-- Single Unified Hover + NoClip Heartbeat (Yields 100% during Cannon!)
-- ============================================================================
local orbAngle = 0
local hbConn, stepConn = nil, nil

local function startMovementHooks()
    if not stepConn then
        stepConn = RunService.Stepped:Connect(function()
            if not Config.Enabled or State.Mode == "IDLE" or State.Mode == "CANNON" then return end
            local ch = getChar()
            if ch then
                for _, d in ipairs(ch:GetDescendants()) do
                    if d:IsA("BasePart") then d.CanCollide = false end
                end
            end
        end)
    end
    if not hbConn then
        hbConn = RunService.Heartbeat:Connect(function(dt)
            if not Config.Enabled then return end
            -- Nhuong hoan toan khi dang ngoi/dung phao
            if State.CannonBusy or isAttachedToCannon() then return end
            local target = State.HoverTarget
            if not (target and target.Parent and isTitanAlive(target)) then return end
            local np = getTitanNape(target)
            if not np then return end
            local ch = getChar()
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum and hum.Health > 0) then return end

            local stepDt = math.clamp(tonumber(dt) or 0.016, 0.005, 0.08)
            local isSp = isSpearEquipped()
            orbAngle = (orbAngle + stepDt * (isSp and 3.5 or 6)) % (math.pi * 2)
            local hoverY = isSp and 40 or 10
            local radius = isSp and 12 or 6
            local bob = isSp and 4 or 1.5
            local dest = np.Position + Vector3.new(math.cos(orbAngle) * radius, hoverY + math.sin(orbAngle * 2) * bob, math.sin(orbAngle) * radius)

            hum.PlatformStand = true
            if hum.SeatPart ~= nil or hum.Sit == true then hum.Sit = false end
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            local diff = dest - hrp.Position
            local dist = diff.Magnitude
            if dist > 1 then
                local nextPos = hrp.Position + diff.Unit * math.min(600 * stepDt, dist)
                hrp.CFrame = CFrame.lookAt(nextPos, Vector3.new(np.Position.X, nextPos.Y, np.Position.Z))
            else
                hrp.CFrame = CFrame.lookAt(dest, Vector3.new(np.Position.X, dest.Y, np.Position.Z))
            end
        end)
    end
end

local function stopAllHooks()
    Config.Enabled = false
    State.HoverTarget = nil
    State.CannonBusy = false
    detachFromCannon(false)
    if hbConn then hbConn:Disconnect(); hbConn = nil end
    if stepConn then stepConn:Disconnect(); stepConn = nil end
    local ch = getChar()
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        for _, d in ipairs(ch:GetDescendants()) do
            if d:IsA("BasePart") then d.CanCollide = true end
        end
    end
end

-- ============================================================================
-- Compact Top-Center Control Overlay
-- ============================================================================
local statusLabel = nil
local function mountGui()
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
            local old = guiParent:FindFirstChild("AoTRColossalTestGui")
            if old then old:Destroy() end

            local sg = Instance.new("ScreenGui")
            sg.Name = "AoTRColossalTestGui"
            sg.ResetOnSpawn = false
            sg.IgnoreGuiInset = true
            sg.DisplayOrder = 999999

            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromOffset(486, 74)
            frame.Position = UDim2.new(0.5, -243, 0, 10)
            frame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
            frame.BorderSizePixel = 0
            frame.Active = true
            frame.Draggable = true
            frame.Parent = sg
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(255, 165, 60)
            stroke.Thickness = 1.5

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 0, 26)
            lbl.Position = UDim2.fromOffset(6, 4)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 220, 140)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = "[Colo Test] Dang khoi dong..."
            lbl.Parent = frame

            local function makeBtn(txt, x, w, col, cb)
                local b = Instance.new("TextButton")
                b.Size = UDim2.fromOffset(w, 28)
                b.Position = UDim2.fromOffset(x, 38)
                b.BackgroundColor3 = col
                b.TextColor3 = Color3.new(1, 1, 1)
                b.TextSize = 11
                b.Font = Enum.Font.GothamSemibold
                b.Text = txt
                b.Parent = frame
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
                b.MouseButton1Click:Connect(function() cb(b) end)
                return b
            end

            makeBtn("Chay: BAT", 6, 86, Color3.fromRGB(46, 160, 92), function(b)
                Config.Enabled = not Config.Enabled
                b.Text = Config.Enabled and "Chay: BAT" or "Chay: TAT"
                b.BackgroundColor3 = Config.Enabled and Color3.fromRGB(46, 160, 92) or Color3.fromRGB(110, 110, 120)
                if not Config.Enabled then
                    State.HoverTarget = nil
                    State.CannonBusy = false
                    detachFromCannon(false)
                end
            end)

            makeBtn("Phao: ON", 98, 86, Color3.fromRGB(52, 118, 224), function(b)
                Config.AutoCannon = not Config.AutoCannon
                b.Text = Config.AutoCannon and "Phao: ON" or "Phao: OFF"
                b.BackgroundColor3 = Config.AutoCannon and Color3.fromRGB(52, 118, 224) or Color3.fromRGB(110, 110, 120)
            end)

            makeBtn("Bao Ve: ON", 190, 98, Color3.fromRGB(145, 85, 210), function(b)
                Config.AutoDefendEren = not Config.AutoDefendEren
                b.Text = Config.AutoDefendEren and "Bao Ve: ON" or "Bao Ve: OFF"
                b.BackgroundColor3 = Config.AutoDefendEren and Color3.fromRGB(145, 85, 210) or Color3.fromRGB(110, 110, 120)
            end)

            makeBtn("Burst: 15", 294, 92, Color3.fromRGB(215, 130, 35), function(b)
                if Config.CannonImpactBurst == 15 then
                    Config.CannonImpactBurst = 25
                elseif Config.CannonImpactBurst == 25 then
                    Config.CannonImpactBurst = 1
                else
                    Config.CannonImpactBurst = 15
                end
                b.Text = "Burst: " .. tostring(Config.CannonImpactBurst)
            end)

            makeBtn("Thoat Han", 392, 88, Color3.fromRGB(175, 55, 55), function()
                stopAllHooks()
                sg:Destroy()
            end)

            sg.Parent = guiParent
            statusLabel = lbl
        end)
        if okMount and statusLabel then break end
    end
end

local function setStatus(txt)
    State.StatusText = txt
    if statusLabel then
        pcall(function() statusLabel.Text = txt end)
    end
end

-- ============================================================================
-- Single Coordinated State-Machine Loop (No Fighting Threads!)
-- ============================================================================
mountGui()
startMovementHooks()

local impactListenerBound = false
local lastErenPct, erenHitUntil = nil, 0
local lastStateYaw, lastStatePitch = nil, nil

local function releaseCannonState()
    if State.MountedCannon or State.CannonBusy or isAttachedToCannon() then
        local c = State.MountedCannon or State.ActiveCannon
        State.MountedCannon = nil
        State.ActiveCannon = nil
        State.CannonBusy = false
        lastStateYaw, lastStatePitch = nil, nil
        if c then
            pcall(function() invokeCannon("Cannon", "State", c, false, buildCannonTable(c)) end)
        end
        detachFromCannon(true)
    end
end

task.spawn(function()
    resolveRemotes()
    while true do
        task.wait(0.08)
        if not Config.Enabled then
            State.Mode = "IDLE"
            setStatus("[Tam dung] Dang tat")
            task.wait(0.2)
        elseif not canAct() then
            setStatus("[Cho] Nhan vat chua san sang / Loading...")
            task.wait(0.15)
        elseif Config.AutoRefill and needsRefill() then
            State.Mode = "REFILL"
            State.HoverTarget = nil
            setStatus("[Nap Do] Dang nap Kiem/Thuong...")
            doRefill()
        else
            local col = getColossalModel()
            if not col then
                State.Mode = "IDLE"
                State.HoverTarget = nil
                releaseCannonState()
                setStatus("[Cho] Chua thay Colossal_Titan...")
                task.wait(0.25)
            else
                local phase2 = isColossalPhase2()
                local erenPct, stallTxt = readGuiObjectives()
                if erenPct and lastErenPct and erenPct < lastErenPct - 0.05 then
                    erenHitUntil = os.clock() + 8
                end
                if erenPct then lastErenPct = erenPct end

                -- Tim Titan nguy hiem gan Workspace.Unclimbable.Objective.Defend_Eren_2
                local erenPos = getErenPos()
                local enemies = collectEnemyTitans(true)
                local nearEren = {}
                local radius = (erenPct and erenPct < 99.8 or os.clock() < erenHitUntil) and 1500 or Config.DefendRadius
                for _, tm in ipairs(enemies) do
                    local np = getTitanNape(tm)
                    if np then
                        local d = erenPos and (np.Position - erenPos).Magnitude or 0
                        if not erenPos or d <= radius then
                            nearEren[#nearEren + 1] = { titan = tm, dist = d }
                        end
                    end
                end
                table.sort(nearEren, function(a, b) return a.dist < b.dist end)

                -- MUC 1 (Phase 1): Bao ve Eren neu co Titan ap sat hoac Eren mat mau
                if not phase2 and Config.AutoDefendEren and #nearEren > 0 then
                    State.Mode = "DEFEND_EREN"
                    State.DefendErenActive = true
                    releaseCannonState()
                    local batch = {}
                    for i = 1, math.min(Config.HitAllBatch, #nearEren) do
                        batch[#batch + 1] = nearEren[i].titan
                    end
                    State.HoverTarget = batch[1]
                    setStatus(string.format("[Bao Ve Eren] %d Titan (Eren: %.1f%%)", #nearEren, erenPct or 100))
                    if attackTargets(batch) then
                        task.wait(isSpearEquipped() and 0.35 or 0.12)
                    end
                elseif not phase2 and Config.AutoCannon then
                    -- MUC 2 (Phase 1, Eren an toan): Ban phao
                    State.DefendErenActive = false
                    local cannons = findWallCannons()
                    local cannon = cannons[1]
                    local nape = getTitanNape(col)
                    if not cannon then
                        State.HoverTarget = nil
                        setStatus("[Phao P1] Khong tim thay phao!")
                        task.wait(0.25)
                    elseif not nape then
                        setStatus("[Phao P1] Dang dinh vi Nape Colossal...")
                        task.wait(0.2)
                    else
                        State.Mode = "CANNON"
                        State.HoverTarget = nil
                        State.CannonBusy = true
                        State.ActiveCannon = cannon

                        if POST and not impactListenerBound then
                            impactListenerBound = true
                            POST.OnClientEvent:Connect(function(a1, a2, ...)
                                if a1 == "Skills" and a2 == "Impact" and Config.Enabled and State.Mode == "CANNON" then
                                    State.ImpactEvents = State.ImpactEvents + 1
                                    local liveNape = getTitanNape(getColossalModel())
                                    if liveNape then
                                        local evtProj = findModelInArgs({ ... }, 0)
                                        local targetProj = evtProj or getOwnedProjectile()
                                        if targetProj and targetProj.Parent then
                                            local burst = math.max(1, tonumber(Config.CannonImpactBurst) or 15)
                                            for _ = 1, burst do
                                                pcall(function() POST:FireServer("S_Skills", "Impact", targetProj, liveNape.Position) end)
                                            end
                                            State.Impacts = State.Impacts + burst
                                        end
                                    end
                                end
                            end)
                        end

                        -- Kiem tra ngoi phao bang attribute Player == lp.Name tren model phao that
                        local isMountedAttr = lp and cannon:GetAttribute("Player") == lp.Name
                        if State.MountedCannon ~= cannon or not isMountedAttr then
                            local ch = getChar()
                            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                            local geoMount = getCannonGeometry(cannon)
                            if hrp and geoMount and geoMount.base then
                                local dCan = (hrp.Position - geoMount.base.Position).Magnitude
                                if dCan > 45 then
                                    hrp.CFrame = CFrame.new(geoMount.base.Position + Vector3.new(0, 6, 0))
                                    pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
                                    task.wait(0.15)
                                end
                            end
                            -- Thu nil theo kieu game/SmoothHub truoc, neu chua nhan Player thi thu gui kem tbl
                            local okS = invokeCannon("Cannon", "State", cannon, true, nil)
                            task.wait(0.12)
                            if not okS or (lp and cannon:GetAttribute("Player") ~= lp.Name) then
                                local tbl = buildCannonTable(cannon, nape.Position)
                                invokeCannon("Cannon", "State", cannon, true, tbl)
                                task.wait(0.12)
                            end
                            State.MountedCannon = cannon
                            lastStateYaw, lastStatePitch = nil, nil
                        end

                        local freshNape = nape.Position
                        local aimAngles, _, distXZ, geo = computeCannonAim(cannon, freshNape)
                        local dirBefore = geo and readMuzzleDir(geo.barrelWood, geo.home)
                        if lastStateYaw == nil or math.abs(aimAngles.Base - lastStateYaw) >= 3 or math.abs(aimAngles.BarrelWood - (lastStatePitch or 0)) >= 3 then
                            lastStateYaw, lastStatePitch = aimAngles.Base, aimAngles.BarrelWood
                            invokeCannon("Cannon", "State", cannon, true, buildCannonTable(cannon, freshNape))
                            task.wait(0.03)
                        end

                        local colHum = col:FindFirstChildOfClass("Humanoid")
                        local colHpPct = (colHum and colHum.MaxHealth > 0) and (colHum.Health / colHum.MaxHealth * 100) or 100
                        local cdSec = tonumber(cannon:GetAttribute("CD")) or 2.7
                        local sinceShot = os.clock() - State.LastShotAt
                        local isFiringAttr = cannon:GetAttribute("Firing") == true
                        local mountedNow = (lp and cannon:GetAttribute("Player") == lp.Name)

                        if not isFiringAttr and sinceShot >= math.min(cdSec, 0.75) then
                            local prevImpactEvts = State.ImpactEvents
                            local okShoot, resShoot = invokeCannon("Cannon", "Shoot", aimAngles)
                            if okShoot and resShoot ~= false then
                                State.Shots = State.Shots + 1
                                State.LastShotAt = os.clock()
                                -- Cho server spawn vien dan Workspace.Cannon va tra ve Skills/Impact
                                local waitT0 = os.clock()
                                while State.ImpactEvents == prevImpactEvts and os.clock() - waitT0 < 0.65 do
                                    task.wait(0.04)
                                end
                                local ey, ep = calibrateAfterShot(cannon, aimAngles, nape.Position, dirBefore)
                                -- Chi fallback neu server chua tra event ma vien dan Workspace.Cannon dang ton tai
                                if State.ImpactEvents == prevImpactEvts then
                                    local proj = getOwnedProjectile()
                                    if proj and POST then
                                        local burst = math.max(1, tonumber(Config.CannonImpactBurst) or 15)
                                        for _ = 1, burst do
                                            pcall(function() POST:FireServer("S_Skills", "Impact", proj, nape.Position) end)
                                        end
                                        State.Impacts = State.Impacts + burst
                                    end
                                end
                                colHpPct = (colHum and colHum.MaxHealth > 0) and (colHum.Health / colHum.MaxHealth * 100) or colHpPct
                                setStatus(string.format("[Phao P1] HP:%.1f%% | Plr:%s | Ban:%d Evt:%d Imp:%d | %.0fst (L %.0f/%.0f)",
                                    colHpPct, mountedNow and "OK" or "?", State.Shots, State.ImpactEvents, State.Impacts, distXZ or 0, ey or 0, ep or 0))
                            else
                                setStatus(string.format("[Phao CD] HP:%.1f%% | Plr:%s | CD:%.1fs | Ban:%d Evt:%d",
                                    colHpPct, mountedNow and "OK" or "NO", cdSec, State.Shots, State.ImpactEvents))
                            end
                        else
                            setStatus(string.format("[Phao] HP:%.1f%% | Plr:%s | Cho CD... | Ban:%d Evt:%d Imp:%d",
                                colHpPct, mountedNow and "OK" or "NO", State.Shots, State.ImpactEvents, State.Impacts))
                        end
                        task.wait(0.18)
                    end
                elseif phase2 then
                    -- MUC 3 (Phase 2): Guc roi -> nha phao, don 9 hit vao Nape Colossal
                    State.DefendErenActive = false
                    State.Mode = "PHASE2"
                    releaseCannonState()
                    if isTitanAlive(col) then
                        State.HoverTarget = col
                        local hum = col:FindFirstChildOfClass("Humanoid")
                        local hpPct = (hum and hum.MaxHealth > 0) and (hum.Health / hum.MaxHealth * 100) or 0
                        setStatus(string.format("[Phase 2] Don dame Colossal (HP: %.1f%%)", hpPct))
                        if attackTargets({ col }) then
                            task.wait(isSpearEquipped() and 0.35 or 0.12)
                        end
                    else
                        State.HoverTarget = nil
                        setStatus("[Phase 2] Colossal da guc/chet!")
                        task.wait(0.3)
                    end
                else
                    State.DefendErenActive = false
                    State.Mode = "IDLE"
                    State.HoverTarget = nil
                    releaseCannonState()
                    setStatus(string.format("[Cho] Eren %.0f%% | %s", erenPct or 100, stallTxt or "P1"))
                    task.wait(0.2)
                end
            end
        end
    end
end)
