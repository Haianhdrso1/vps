if type(game.IsLoaded) == "function" and not game:IsLoaded() then
    pcall(function()
        game.Loaded:Wait()
    end)
end
local v5_6 = game:GetService("HttpService")
local v6_21 = game:GetService("Players")
local v7_13 = v6_21.LocalPlayer or (v6_21.PlayerAdded and v6_21.PlayerAdded:Wait())
local v12 = "SymbioteSettings_" .. tostring(game.PlaceId) .. ".json"
local v13_2 = {
    NoClip = false,
    WalkSpeed = false,
    WalkSpeedAmount = 1,
    LaggyRun = false,
    LaggyRunDistance = 1,
    LaggyRunDelay = 1,
    CtrlClickTP = false,
    InfiniteJump = false,
    AutoFarm = false,
    DistanceToTitan = 0,
    AutoReload = false,
    ExpandNapeHitbox = false,
    HitboxSize = 20,
    VisualizeHitbox = false,
    TitanESP = false,
    AutoRefill = false,
    ChangeCursor = false,
    AutoRetry = false,
    AutoSkipCutscenes = false,
    DelayToKill = false,
    DelayToKillAmount = 1,
    HitAll = false,
    FamiliesToStop = {},
    FamilyTiersToStop = {},
    AutoSellPerks = false,
    PerkTiersToSell = {},
    SpecificPerksToSell = {},
    AutoCreateTowers = false,
    AutoRetrieveSupplyCrates = false,
    AutoVoteReady = false,
    AutoUpgradeMaxHQHP = false,
    AutoUpgradeHQHealthRegen = false,
    AutoUpgradeRefillLimit = false,
    AutoUpgradeWeapon = false,
    UpgradeDelay = 0,
    AutoGetRetrieveSkillCrate = false,
    AutoOpenRaidChests = false,
    AutoRaid = false,
    AutoClaimAchievements = true,
    AutoResetStreak = false,
    KaitunEnabled = false,
    KaitunAutoUpgradeWeapon = true,
    KaitunWeaponType = "Auto",
    KaitunMap = "Auto (Best)",
    KaitunAutoMap = true,
    KaitunAutoPrestige = true,
    KaitunMaxPrestige = 5,
    KaitunPrioritizeBonusMap = true,
    AutoLoadGlobalConfig = true,
    SelectedSettingSlot = "Setting 1",
    CachedWeaponMinLevel = 0,
    Language = "English"
}
local v15_isRestoring = true
local v15_SettingOrderFile = "Symbiote_SettingOrder.json"
local v15_SettingSlotsList = {
    "Setting 1",
    "Setting 2",
    "Setting 3",
    "Setting 4",
    "Setting 5",
    "Setting 6",
    "Setting 7",
    "Setting 8",
    "Setting 9",
    "Setting 10"
}
local function v10_3(p1)
    local v2_2, v3_2 = pcall(function()
        local v1 = syn and syn.read_file or readfile
        if v1 then
            return v1(p1)
        end
        return nil
    end)
    if v2_2 and type(v3_2) == "string" and v3_2 ~= "" then
        return v3_2
    end
    return nil
end
local function v11(p1, p2)
    pcall(function()
        local v1 = syn and syn.write_file or writefile
        if v1 then
            v1(p1, p2)
        end
        return
    end)
    return
end
local function v15_getSlotFile(slotName)
    local n = tonumber(tostring(slotName or ""):match("(%d+)")) or 1
    if n < 1 then n = 1 elseif n > 10 then n = 10 end
    return "Symbiote_Setting_" .. tostring(n) .. ".json", "Setting " .. tostring(n), n
end
local v15_orderData = (function()
    local info = {
        ActiveSlot = "Setting 1",
        LastOrder = 0,
        Created = {}
    }
    local rawOrder = v10_3(v15_SettingOrderFile)
    if rawOrder then
        local ok, dec = pcall(function()
            return v5_6:JSONDecode(rawOrder)
        end)
        if ok and type(dec) == "table" then
            if type(dec.ActiveSlot) == "string" and dec.ActiveSlot ~= "" then
                local _, normSlot = v15_getSlotFile(dec.ActiveSlot)
                info.ActiveSlot = normSlot
            end
            if tonumber(dec.LastOrder) then
                info.LastOrder = tonumber(dec.LastOrder)
            end
            if type(dec.Created) == "table" then
                info.Created = dec.Created
            end
        end
    end
    local foundList = {}
    local maxFound = 0
    for i = 1, 10 do
        local fName, sName = v15_getSlotFile("Setting " .. tostring(i))
        if v10_3(fName) then
            table.insert(foundList, sName)
            maxFound = i
        end
    end
    if #foundList > 0 then
        info.Created = foundList
        if info.LastOrder < maxFound then
            info.LastOrder = maxFound
        end
        if not rawOrder then
            info.ActiveSlot = "Setting " .. tostring(maxFound)
        end
    end
    return info
end)()
local function v15_saveOrderData()
    local ok, encoded = pcall(function()
        return v5_6:JSONEncode(v15_orderData)
    end)
    if ok and encoded then
        v11(v15_SettingOrderFile, encoded)
    end
end
local function v15_markSlotCreated(slotName)
    local _, normSlot, num = v15_getSlotFile(slotName)
    v15_orderData.ActiveSlot = normSlot
    if num > (tonumber(v15_orderData.LastOrder) or 0) then
        v15_orderData.LastOrder = num
    end
    local exists = false
    if type(v15_orderData.Created) ~= "table" then
        v15_orderData.Created = {}
    end
    for _, s in ipairs(v15_orderData.Created) do
        if s == normSlot then
            exists = true
            break
        end
    end
    if not exists then
        table.insert(v15_orderData.Created, normSlot)
        table.sort(v15_orderData.Created, function(a, b)
            local na = tonumber(tostring(a):match("(%d+)")) or 0
            local nb = tonumber(tostring(b):match("(%d+)")) or 0
            return na < nb
        end)
    end
    v15_saveOrderData()
end
local function v15_22(p1)
    if type(p1) ~= "table" then
        return
    end
    local slotFile, normSlot = v15_getSlotFile(p1.SelectedSettingSlot or v15_orderData.ActiveSlot or "Setting 1")
    p1.SelectedSettingSlot = normSlot
    v15_orderData.ActiveSlot = normSlot
    local v2_2, v3_2 = pcall(function()
        return v5_6:JSONEncode(p1)
    end)
    if v2_2 and v3_2 then
        v11(v12, v3_2)
        v11(slotFile, v3_2)
        v15_markSlotCreated(normSlot)
        if p1.AutoLoadGlobalConfig ~= false then
            v11("Symbiote_GlobalSettings.json", v3_2)
        end
    end
    if type(_G) == "table" then
        _G.__SymbioteSavedConfig = p1
    end
    return
end
local v16_9 = (function()
    local merged = {}
    local function mergeFromRaw(rawStr)
        if not rawStr then
            return nil
        end
        local okD, tbl = pcall(function()
            return v5_6:JSONDecode(rawStr)
        end)
        if okD and type(tbl) == "table" then
            for k, v in pairs(tbl) do
                merged[k] = v
            end
            return tbl
        end
        return nil
    end
    mergeFromRaw(v10_3(v12))
    local rawGlobal = v10_3("Symbiote_GlobalSettings.json")
    if rawGlobal then
        local okG, tblG = pcall(function()
            return v5_6:JSONDecode(rawGlobal)
        end)
        if okG and type(tblG) == "table" and tblG.AutoLoadGlobalConfig ~= false then
            for k, v in pairs(tblG) do
                merged[k] = v
            end
        end
    end
    local activeSlot = v15_orderData.ActiveSlot or merged.SelectedSettingSlot or "Setting 1"
    local slotFile, normSlot = v15_getSlotFile(activeSlot)
    local rawSlot = v10_3(slotFile)
    if rawSlot and merged.AutoLoadGlobalConfig ~= false then
        mergeFromRaw(rawSlot)
    end
    merged.SelectedSettingSlot = normSlot
    v15_orderData.ActiveSlot = normSlot
    return merged
end)()
local function v8_6(p1)
    if v16_9[p1] ~= nil then
        return v16_9[p1]
    end
    return v13_2[p1]
end
local function v9_4(p1, p2)
    v16_9[p1] = p2
    if not v15_isRestoring then
        v15_22(v16_9)
    end
    return
end
local v12_4 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Haianhdrso1/vps/refs/heads/main/menuhenu.lua"))()
local v13_8 = game:GetService("Workspace")
local v14_9 = game:GetService("RunService")
local v15_29 = game:GetService("UserInputService")
local v16_15 = game:GetService("ReplicatedStorage")
local v17_6 = game:GetService("VirtualInputManager")
local v150_10 = {
    Caps = {
        hookmetamethod = type(hookmetamethod) == "function",
        hookfunction = type(hookfunction) == "function",
        getnamecallmethod = type(getnamecallmethod) == "function",
        checkcaller = type(checkcaller) == "function",
        getconnections = type(getconnections) == "function",
        newcclosure = type(newcclosure) == "function",
        run_on_actor = type(run_on_actor) == "function" or
            (type(syn) == "table" and type(syn.run_on_actor) == "function")
    },
    OriginalSizes = setmetatable({}, { __mode = "k" }),
    HooksInstalled = false,
    ActorShielded = false,
    BlockedRemotes = 0,
    BlockedKicks = 0,
    IsolatedScripts = 0,
    SilencedConnections = 0,
    AutoGasThread = nil,
    AutoResetStreak = false,
    BreakingStreak = false,
    CurrentKillStreak = 0,
    StreakThreshold = 1000,
    AutoRaid = false,
    AutoClaimAchievements = true,
    MissionStartTime = os.clock()
}
local v18_4 = false
local v19_3 = false
local v20_2 = nil
local v21_2 = false
local v22_2 = false
local v23_2 = 20
local v24_2 = false
local v25_2 = false
local v26_2 = false
local v27_2 = false
local v28_2 = 1
local v29_2 = false
local v30_2 = 1
local v31_2 = 1
local v32_2 = false
local v33_2 = false
local v34_2 = false
local v35_2 = false
local v36_2 = nil
local v37_2 = false
local v38_2, v39_2, v40_2, v42_2, v43_2, v44_3, v45_3, v46_2, v47_3, v48_3, v49_2, v52_2, v53_2, v54_2, v55_2, v56_2, v57_3, v58_2, v59_2, v60_2, v61_2, v64_2, v66, v67_2, v68_2, v69_2, v70_2, v71_3, v72_2, v73_2, v75_2, v77_2, v84_2, v85_2, v86_2, v87_2, v88_2, v89_2, v90_2, v91_2, v93_2, v94_2
do
    v38_2 = false
    v39_2 = false
    v40_2 = false
    local v41_2 = 0
    v42_2 = false
    v43_2 = {}
    v44_3 = {}
    v45_3 = false
    v46_2 = {}
    v47_3 = {}
    v48_3 = false
    v49_2 = false
    v52_2 = nil
    v53_2 = false
    v54_2 = nil
    v55_2 = nil
    v56_2 = {}
    v57_3 = false
    v58_2 = 1
    v59_2 = false
    v60_2 = 0
    v61_2 = {
        AutoVoteReady = false,
        AutoUpgradeMaxHQHP = false,
        AutoUpgradeHQHealthRegen = false,
        AutoUpgradeRefillLimit = false,
        AutoUpgradeWeapon = false,
        AutoGetRetrieveSkillCrate = false,
        UpgradeDelay = 0,
        LastUpgradeTimestamp = 0,
        UpgradeIndex = 1,
        HasVotedReady = false,
        LoopRunning = false,
        IsUpgrading = false,
        IsRetrievingSkillCrate = false,
        LastSkillCrateTimestamp = 0,
        TargetCFrame = nil,
        CachedWeaponMinLevel = 0
    }
    v64_2 = false
    local v65_2 = nil
    v66 = getactors or syn and syn.getactors
    v67_2 = run_on_actor or runonactor or syn and (syn.run_on_actor or syn.runonactor) or
        getgenv and (getgenv().run_on_actor or getgenv().runonactor)
    v68_2 = nil
    v69_2 = nil
    v70_2 = function()
        if v68_2 and v69_2 then
            return true
        end
        local v1_5 = v16_15:WaitForChild("Assets", 15)
        local v2 = v1_5 and v1_5:WaitForChild("Remotes", 15)
        if v2 then
            v68_2 = v2:FindFirstChild("POST") or v2:WaitForChild("POST", 5)
            v69_2 = v2:FindFirstChild("GET") or v2:WaitForChild("GET", 5)
        end
        return v68_2 ~= nil and v69_2 ~= nil
    end
    task.spawn(v70_2)
    v71_3 = function()
        local v1_3 = v13_8:FindFirstChild("Characters")
        return v1_3 and v1_3:FindFirstChild(v7_13.Name) or v7_13.Character
    end
    v72_2 = function()
        local v1_2 = v71_3()
        if not v1_2 then return nil end
        local rig = v1_2:FindFirstChild("Rig_" .. v7_13.Name) or v1_2:FindFirstChild("Rig")
        if rig then return rig end
        if v1_2:FindFirstChild("LeftLowerArm") or v1_2:FindFirstChild("LeftHand") then
            return v1_2
        end
        return nil
    end
    v73_2 = function()
        local v1_2 = v72_2()
        if not v1_2 then
            return false
        end
        local v2_4 = v1_2:FindFirstChild("LeftLowerArm")
        local v3_3 = v1_2:FindFirstChild("RightLowerArm")
        return v2_4 and v2_4:FindFirstChild("Spears") ~= nil or v3_3 and v3_3:FindFirstChild("Spears") ~= nil or false
    end
    local function v74_2()
        local v1_2 = v72_2()
        if not v1_2 then
            local v2_3 = v71_3()
            local v3 = v2_3 and v2_3:GetAttribute("Spears")
            return v3 and tonumber(v3) or 0
        end
        local v2_4 = v1_2:FindFirstChild("LeftLowerArm") and v1_2.LeftLowerArm:FindFirstChild("Spears")
        local v3_5 = v1_2:FindFirstChild("RightLowerArm") and v1_2.RightLowerArm:FindFirstChild("Spears")
        if not v2_4 and not v3_5 then
            local v4_10 = v71_3()
            local v5_5 = v4_10 and v4_10:GetAttribute("Spears")
            return v5_5 and tonumber(v5_5) or 0
        end
        local v4_11 = 0
        for v5_6 = 1, 16 do
            local v8 = v5_6 % 2 == 0 and v3_5 or v2_4
            local v9_2 = v8 and v8:FindFirstChild(tostring(v5_6))
            if v9_2 and v9_2:GetAttribute("Used") == nil and 0.9 > v9_2.Transparency then
                v4_11 = v4_11 + 1
            end
        end
        return v4_11
    end
    v75_2 = function()
        local v1_2 = v74_2()
        local v2_2 = v71_3()
        local v3 = v2_2 and v2_2:GetAttribute("Spears")
        if v1_2 == 0 then
            if v2_2 and v3 ~= 0 then
                pcall(function()
                    v2_2:SetAttribute("Spears", 0)
                    return
                end)
            end
            return true
        end
        if v3 ~= nil and tonumber(v3) ~= nil and tonumber(v3) <= 0 then
            return true
        end
        return false
    end
    local function v76_2()
        if v75_2() then
            return 0
        end
        local v1_4 = v72_2()
        if v1_4 then
            local v2 = v1_4:FindFirstChild("LeftLowerArm") and v1_4.LeftLowerArm:FindFirstChild("Spears")
            local v3_3 = v1_4:FindFirstChild("RightLowerArm") and v1_4.RightLowerArm:FindFirstChild("Spears")
            for v4_5 = 16, 1, -1 do
                local v7 = v4_5 % 2 == 0 and v3_3 or v2
                local v8_2 = v7 and v7:FindFirstChild(tostring(v4_5))
                if v8_2 and v8_2:GetAttribute("Used") == nil and v8_2.Transparency < 0.9 then
                    return v4_5
                end
            end
        end
        return 0
    end
    v77_2 = function()
        if v73_2() then
            return false
        end
        local v1_5 = v72_2()
        if not v1_5 then
            return false
        end
        for v5, v6 in ipairs(v1_5:GetDescendants()) do
            if v6:IsA("MeshPart") and v6.Name:sub(1, 5) == "Blade" then
                return true
            end
        end
        return false
    end
    local function v78_2()
        if not v77_2() then
            return
        end
        pcall(function()
            v69_2:InvokeServer("Blades", "Reload")
            return
        end)
        return
    end
    local v80_2 = nil
    local function v79_2()
        if v80_2 and v80_2.Parent and v80_2:IsA("BasePart") then
            return v80_2
        end
        v80_2 = nil
        pcall(function()
            for v5, v6 in ipairs({ v13_8:FindFirstChild("Unclimbable"), v13_8:FindFirstChild("Climbable") }) do
                if v6 then
                    for v10_2, v11_2 in ipairs(v6:GetDescendants()) do
                        if v11_2:IsA("BasePart") and v11_2.Name == "Refill" then
                            v80_2 = v11_2
                            return
                        end
                    end
                end
            end
            return
        end)
        if not v80_2 then
            pcall(function()
                for _, obj in ipairs(v13_8:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name == "Refill" then
                        v80_2 = obj
                        return
                    end
                end
            end)
        end
        return v80_2
    end
    local function v80_3(p1)
        local v2 = v13_8:FindFirstChild("Characters") and v13_8.Characters:FindFirstChild(v7_13.Name) or v7_13.Character
        local v3_4 = v2 and v2:FindFirstChild("HumanoidRootPart")
        if v3_4 and p1 then
            v3_4.CFrame = p1.CFrame + Vector3.new(0, 3, 0)
            pcall(function()
                local v1 = v3_4
                local v3 = Vector3
                v1.AssemblyLinearVelocity = v3.zero
                v1.AssemblyAngularVelocity = v3.zero
                return
            end)
        end
        return
    end
    local function v81_2(p1)
        local v2_2 = v79_2()
        if not v2_2 then
            return
        end
        v80_3(v2_2)
        task.wait(0.5)
        v70_2()
        if v68_2 then
            pcall(function()
                v68_2:FireServer("Attacks", "Reload", v2_2)
                return
            end)
        end
        v41_2 = os.clock()
        return
    end
    local function v82_2()
        local v1, v2_2 = pcall(function()
            local v4 = v7_13.PlayerGui.Interface.HUD.Main.Top["7"].Blades.Sets.Text:match("^(%d+)%s*/")
            if v4 then
                return tonumber(v4)
            end
            return nil
        end)
        if v1 and v2_2 ~= nil then
            return v2_2
        end
        local v3, v4_res = pcall(function()
            local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
            local iface = pgui and pgui:FindFirstChild("Interface")
            if iface then
                for _, desc in ipairs(iface:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Visible and desc.Text:find("/") then
                        local num = desc.Text:match("^(%d+)%s*/")
                        if num and (desc.Name == "Sets" or (desc.Parent and desc.Parent.Name == "Blades") or desc.Name:find("Blade")) then
                            return tonumber(num)
                        end
                    end
                end
            end
            return nil
        end)
        if v3 and v4_res ~= nil then
            return v4_res
        end
        return nil
    end
    local function v83_2()
        local v1, v2_2 = pcall(function()
            local v1_2 = v72_2()
            if not v1_2 then
                v1_2 = v71_3()
            end
            if not v1_2 then
                return true
            end
            local v2_3 = v1_2:FindFirstChild("LeftHand")
            local v3_3 = v1_2:FindFirstChild("RightHand")
            if v2_3 then
                local v4_4 = v2_3:FindFirstChild("Blade_1")
                if v4_4 and v4_4:GetAttribute("Broken") then
                    return true
                end
            end
            if v3_3 then
                local v4_6 = v3_3:FindFirstChild("Blade_1")
                if v4_6 and v4_6:GetAttribute("Broken") then
                    return true
                end
            end
            local hasBlade = false
            for v8, v9 in ipairs(v1_2:GetDescendants()) do
                if v9:IsA("MeshPart") and v9.Name:sub(1, 5) == "Blade" then
                    hasBlade = true
                    if not v9:GetAttribute("Broken") and 0.9 > v9.Transparency then
                        return false
                    end
                end
            end
            -- If no blades exist in hand at all, they are broken/empty -> MUST return true to refill!
            return true
        end)
        if v1 then
            return v2_2
        end
        return true
    end
    v84_2 = function()
        if os.clock() - v41_2 < 5 then
            return false
        end
        local v3_4 = v82_2()
        if not (v3_4 ~= nil and v3_4 == 0) then
            v36_2 = nil
            return false
        end
        if v36_2 == nil then
            v36_2 = os.clock()
            return false
        end
        if 2 > os.clock() - v36_2 then
            return false
        end
        return v83_2()
    end
    v85_2 = function()
        if v26_2 then
            return
        end
        if 5 > os.clock() - v41_2 then
            return
        end
        v26_2 = true
        task.wait(0.05)
        if v73_2() then
            v81_2(true)
        elseif v77_2() then
            v78_2()
            local v1_14 = os.clock()
            while true do
                if os.clock() - v1_14 < 1.8 then
                    task.wait(0.1)
                    local v4_2, v5_2 = pcall(function()
                        local v1_2 = v72_2()
                        if not v1_2 then
                            return false
                        end
                        local v2_3 = v1_2:FindFirstChild("LeftHand")
                        local v3_3 = v1_2:FindFirstChild("RightHand")
                        if v2_3 then
                            local v4_4 = v2_3:FindFirstChild("Blade_1")
                            if v4_4 and v4_4:GetAttribute("Broken") then
                                return true
                            end
                        end
                        if v3_3 then
                            local v4_6 = v3_3:FindFirstChild("Blade_1")
                            if v4_6 and v4_6:GetAttribute("Broken") then
                                return true
                            end
                        end
                        local v4_7 = false
                        for v8, v9 in ipairs(v1_2:GetDescendants()) do
                            if v9:IsA("MeshPart") and v9.Name:sub(1, 5) == "Blade" then
                                v4_7 = true
                                if not v9:GetAttribute("Broken") and v9.Transparency < 0.9 then
                                    return false
                                end
                            end
                        end
                        return v4_7
                    end)
                    local v3_8
                    if v4_2 then
                        v3_8 = v5_2
                    else
                        v3_8 = false
                    end
                    if not v3_8 then
                        task.wait(0.2)
                        v26_2 = false
                        return
                    end
                else
                    task.wait(0.2)
                    v26_2 = false
                    return
                end
            end
        end
        task.wait(0.2)
        v26_2 = false
        return
    end
    v86_2 = function()
        if v35_2 then
            return
        end
        if os.clock() - v41_2 < 5 then
            return
        end
        v35_2 = true
        v36_2 = nil
        v81_2(false)
        v36_2 = nil
        v35_2 = false
        return
    end
    v87_2 = function()
        if v26_2 or v35_2 or v61_2.IsUpgrading or v61_2.IsRetrievingSkillCrate then
            return false
        end
        local v1_4 = v71_3()
        if not v1_4 then
            return false
        end
        local v2_6 = v1_4:FindFirstChild("Humanoid")
        if not v2_6 or 0 >= v2_6.Health then
            return false
        end
        if v13_8:FindFirstChild("Titans") ~= nil and v1_4:GetAttribute("Setup") ~= true then
            return false
        end
        local v4_8 = v7_13 or v6_21.LocalPlayer
        local v5_6 = v4_8 and v4_8:FindFirstChild("PlayerGui")
        local v6_5 = v5_6 and v5_6:FindFirstChild("Fullscreen")
        local v7_4 = v6_5 and v6_5:FindFirstChild("Loading_Screen")
        if v7_4 and v7_4.Visible == true then
            return false
        end
        if v1_4:GetAttribute("Ragdolled") ~= nil or v1_4:GetAttribute("Shifter") ~= nil then
            return false
        end
        if v25_2 and v77_2() and v83_2() then
            return false
        end
        local v8_11 = v34_2 and v77_2()
        if v8_11 then
            local v9_8 = v82_2()
            v8_11 = v9_8 ~= nil and v9_8 == 0
        end
        if v8_11 then
            v8_11 = v83_2()
        end
        if v8_11 then
            return false
        end
        if v73_2() and v75_2() then
            return false
        end
        return true
    end
    v88_2 = function()
        local v1 = {}
        local v2_2 = v13_8:FindFirstChild("Titans")
        if not v2_2 then
            return v1
        end
        for v6, v7 in ipairs(v2_2:GetChildren()) do
            if v7:IsA("Model") then
                table.insert(v1, v7)
            end
        end
        return v1
    end
    v89_2 = function(p1)
        if not p1 then return nil end
        local v2_2 = p1:FindFirstChild("Hitboxes")
        if v2_2 then
            local v3_5 = v2_2:FindFirstChild("Hit")
            if v3_5 and v3_5:FindFirstChild("Nape") then
                return v3_5.Nape
            end
        end
        local v3_fallback = p1:FindFirstChild("Nape", true)
        if v3_fallback and v3_fallback:IsA("BasePart") then
            return v3_fallback
        end
        return nil
    end
    v90_2 = function(p1)
        if not p1 or not p1.Parent then
            return true
        end
        local v2_4 = p1:FindFirstChild("HumanoidRootPart") or p1.PrimaryPart or p1:FindFirstChild("Torso") or
            p1:FindFirstChild("Hitboxes") or p1:FindFirstChild("Hitbox")
        if not v2_4 then
            return true
        end
        local v3_8 = p1:GetAttribute("State")
        if v3_8 == "Dead" or v3_8 == "Die" or v3_8 == "Dying" then
            return true
        end
        local v4_7 = p1:FindFirstChild("Humanoid")
        if v4_7 and v4_7.Health <= 0 then
            return true
        end
        return false
    end
    v91_2 = function(p1)
        if not p1 or not p1.Parent then
            return false
        end
        if v150_10 and v150_10.IsBossModel and v150_10.IsBossModel(p1) then
            return not v90_2(p1)
        end
        local v2_3 = v13_8:FindFirstChild("Titans")
        local pName = p1.Parent and p1.Parent.Name
        local isTitanParent = (v2_3 and p1.Parent == v2_3)
            or (v13_8:FindFirstChild("Boss") and p1.Parent == v13_8.Boss)
            or (v13_8:FindFirstChild("Shifters") and p1.Parent == v13_8.Shifters)
            or pName == "Bosses" or pName == "Enemies" or pName == "Raid"
            or pName == "Spawns" or pName == "Living" or pName == "Entities"
        if not isTitanParent then
            return false
        end
        return not v90_2(p1)
    end

    function v150_10.IsBossModel(model)
        if not model or not model.Parent then return false end
        if v90_2(model) then return false end

        local pName = model.Parent and model.Parent.Name
        if pName == "Boss" or pName == "Bosses" or pName == "Shifters" or pName == "Raid" then
            return true
        end

        if model:GetAttribute("Boss") == true
            or model:GetAttribute("Shifter") == true
            or model:GetAttribute("IsBoss") == true
            or model:GetAttribute("RaidBoss") == true then
            return true
        end
        local titanType = tostring(model:GetAttribute("TitanType") or model:GetAttribute("Type") or ""):lower()
        if titanType:find("boss") or titanType:find("shifter") or titanType:find("raid") then
            return true
        end

        local pTag, cs = pcall(function() return game:GetService("CollectionService") end)
        if pTag and cs and (type(cs) == "userdata" or (type(cs) == "table" and type(cs.HasTag) == "function")) then
            local ok, has = pcall(function()
                return cs:HasTag(model, "Boss") or cs:HasTag(model, "Shifter") or cs:HasTag(model, "RaidBoss") or cs:HasTag(model, "Raid")
            end)
            if ok and has then
                return true
            end
        end

        local nameLower = string.lower(model.Name)
        local bossKeywords = {
            "boss", "shifter", "eren", "attack", "female", "annie", "armored", "reiner",
            "beast", "zeke", "colossal", "bertholdt", "jaw", "warhammer", "founder",
            "tấn công", "thiết giáp", "hình nữ", "quái thú", "đại hình", "quỷ"
        }
        for _, kw in ipairs(bossKeywords) do
            if string.find(nameLower, kw) then
                return true
            end
        end

        local hum = model:FindFirstChild("Humanoid")
        if hum and hum.MaxHealth and hum.MaxHealth >= 20000 then
            return true
        end

        return false
    end

    function v150_10.GetRaidBoss()
        local searchContainers = {
            v13_8:FindFirstChild("Boss"),
            v13_8:FindFirstChild("Bosses"),
            v13_8:FindFirstChild("Shifters"),
            v13_8:FindFirstChild("Raid"),
            v13_8:FindFirstChild("Titans"),
            v13_8:FindFirstChild("Enemies"),
            v13_8:FindFirstChild("Spawns"),
            v13_8:FindFirstChild("Characters"),
            v13_8:FindFirstChild("Living"),
            v13_8:FindFirstChild("Entities")
        }
        for _, container in ipairs(searchContainers) do
            if container then
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("Model") and v150_10.IsBossModel(child) and v91_2(child) then
                        return child
                    end
                end
            end
        end
        for _, child in ipairs(v13_8:GetChildren()) do
            if child:IsA("Model") and v150_10.IsBossModel(child) and v91_2(child) then
                return child
            end
        end
        return nil
    end

    function v150_10.GetAliveTitansCount()
        local count = 0
        pcall(function()
            local titanFolders = {
                v13_8:FindFirstChild("Titans"),
                v13_8:FindFirstChild("Boss"),
                v13_8:FindFirstChild("Shifters"),
                v13_8:FindFirstChild("Bosses"),
                v13_8:FindFirstChild("Enemies"),
                v13_8:FindFirstChild("Raid"),
                v13_8:FindFirstChild("Living")
            }
            for _, folder in ipairs(titanFolders) do
                if folder then
                    for _, titan in ipairs(folder:GetChildren()) do
                        if titan:IsA("Model") and not v90_2(titan) then
                            count = count + 1
                        end
                    end
                end
            end
        end)
        return count
    end

    function v150_10.CheckMissionSafetyWait(targetTitan)
        local minSafeDuration = 30
        local startTime = v150_10.MissionStartTime or os.clock()
        local elapsed = os.clock() - startTime
        if elapsed < minSafeDuration then
            local aliveCount = v150_10.GetAliveTitansCount()
            if aliveCount <= 1 then
                while v18_4 and (os.clock() - (v150_10.MissionStartTime or 0) < minSafeDuration) do
                    if targetTitan and v91_2(targetTitan) and v127_2 then
                        pcall(function()
                            v127_2(targetTitan)
                        end)
                    end
                    task.wait(0.2)
                end
            end
        end
    end

    function v150_10.GetActualGameTime()
        local resTime = nil
        pcall(function()
            local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
            local iface = pgui and pgui:FindFirstChild("Interface")
            if iface then
                local rewards = iface:FindFirstChild("Rewards")
                if rewards and rewards:FindFirstChild("Main") and rewards.Main:FindFirstChild("Info") then
                    local stats = rewards.Main.Info.Main:FindFirstChild("Stats")
                    local tt = stats and stats:FindFirstChild("Time_Taken") and stats.Time_Taken:FindFirstChild("Amount")
                    if tt and tt:IsA("TextLabel") and tt.Text ~= "" and tt.Text ~= "00:00" then
                        local m, s = string.match(tt.Text, "(%d+):(%d+)")
                        if m and s then
                            local total = (tonumber(m) or 0) * 60 + (tonumber(s) or 0)
                            if total > 0 then
                                resTime = total
                                return
                            end
                        end
                    end
                end
                local hud = iface:FindFirstChild("HUD")
                if hud then
                    for _, desc in ipairs(hud:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Visible and desc.Text:match("^%d+:%d+$") then
                            local m, s = string.match(desc.Text, "(%d+):(%d+)")
                            if m and s then
                                local total = (tonumber(m) or 0) * 60 + (tonumber(s) or 0)
                                if total > 0 then
                                    resTime = total
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end)
        if not resTime then
            local attrSec = tonumber(v13_8:GetAttribute("Seconds")) or tonumber(v13_8:GetAttribute("Time")) or tonumber(v13_8:GetAttribute("Timer"))
            if attrSec and attrSec > 0 then
                resTime = attrSec
            end
        end
        if not resTime then
            local elapsed = math.floor(os.clock() - (v150_10.MissionStartTime or os.clock()))
            resTime = math.max(30, elapsed)
        end
        return resTime
    end

    function v150_10.ClaimAchievements()
        if not v150_10.AutoClaimAchievements then
            return
        end
        task.spawn(function()
            pcall(function()
                if v69_2 then
                    v69_2:InvokeServer("Achievements", "ClaimAll")
                end
            end)
            pcall(function()
                if v68_2 then
                    v68_2:FireServer("Achievements", "ClaimAll")
                end
            end)
            pcall(function()
                if v69_2 then
                    v69_2:InvokeServer("Functions", "Achievements", "ClaimAll")
                end
            end)
            pcall(function()
                local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                if not pgui then return end
                for _, container in ipairs({ pgui:FindFirstChild("Interface"), pgui }) do
                    if container then
                        for _, name in ipairs({ "Achievements", "Achievement", "Tasks", "Quests", "Missions" }) do
                            local achFrame = container:FindFirstChild(name, true)
                            if achFrame then
                                for _, btn in ipairs(achFrame:GetDescendants()) do
                                    if btn:IsA("GuiButton") and btn.Visible then
                                        local txt = tostring(btn.Text or (btn:FindFirstChild("Title") and btn.Title.Text) or btn.Name):upper()
                                        if txt:find("CLAIM") or txt:find("NHẬN") or txt:find("COLLECT") or txt:find("ALL") then
                                            if v150_10.ClickGuiButton then
                                                v150_10.ClickGuiButton(btn)
                                            else
                                                pcall(function()
                                                    if type(firesignal) == "function" then
                                                        firesignal(btn.MouseButton1Click)
                                                        firesignal(btn.Activated)
                                                    end
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end

    function v150_10.ClaimDailyReward()
        -- Always enabled, no toggle required
        task.spawn(function()
            pcall(function()
                if v69_2 then
                    v69_2:InvokeServer("Daily", "Claim")
                end
            end)
            pcall(function()
                if v69_2 then
                    v69_2:InvokeServer("S_Rewards", "Daily")
                end
            end)
            pcall(function()
                if v69_2 then
                    v69_2:InvokeServer("Rewards", "Daily")
                end
            end)
            pcall(function()
                if v69_2 then
                    v69_2:InvokeServer("DailyReward", "Claim")
                end
            end)
            pcall(function()
                if v69_2 then
                    v69_2:InvokeServer("Lobby", "Daily")
                end
            end)
            pcall(function()
                if v68_2 then
                    v68_2:FireServer("Daily", "Claim")
                end
            end)
            pcall(function()
                local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                if not pgui then return end
                for _, container in ipairs({ pgui:FindFirstChild("Interface"), pgui }) do
                    if container then
                        for _, name in ipairs({ "Daily", "DailyReward", "DailyRewards", "Calendar", "LoginReward" }) do
                            local dailyFrame = container:FindFirstChild(name, true)
                            if dailyFrame then
                                for _, btn in ipairs(dailyFrame:GetDescendants()) do
                                    if btn:IsA("GuiButton") and btn.Visible then
                                        local txt = tostring(btn.Text or (btn:FindFirstChild("Title") and btn.Title.Text) or btn.Name):upper()
                                        if txt:find("CLAIM") or txt:find("NHẬN") or txt:find("COLLECT") or txt:find("DAY") then
                                            if v150_10.ClickGuiButton then
                                                v150_10.ClickGuiButton(btn)
                                            else
                                                pcall(function()
                                                    if type(firesignal) == "function" then
                                                        firesignal(btn.MouseButton1Click)
                                                        firesignal(btn.Activated)
                                                    end
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end

    local function v92_2()
        local v1 = pcall
        v1(function()
            local v1_2 = v71_3()
            local v2 = v1_2 and v1_2:FindFirstChild("Actor") or v66 and v66()[1]
            if v2 and v67_2 then
                v67_2(v2,
                    "                pcall(function()\n                    local obj = _G.__CachedHost\n                    if not obj or type(obj) ~= \"table\" or not rawget(obj, \"Cache\") then\n                        for _, v in ipairs(getgc(true)) do\n                            if type(v) == \"table\" and type(rawget(v, \"Cache\")) == \"table\" and rawget(v, \"Services\") and rawget(v, \"Modules\") then\n                                obj = v\n                                _G.__CachedHost = v\n                                break\n                            end\n                        end\n                    end\n                    if obj then\n                        obj.Spear_State = nil\n                        obj.Using_Spear = nil\n                        obj.Detonate = nil\n                        obj.Can_Detonate = nil\n\n                        if type(obj.Cache.Variables) == \"table\" and obj.Cache.Variables.Slash then\n                            obj.Cache.Variables.Slash.Slashing = false\n                            obj.Cache.Variables.Slash.Holding = false\n                            obj.Cache.Variables.Slash.Released = false\n                        end\n\n                        if obj.Events then\n                            if obj.Events.Spear_Stepped_2 then\n                                pcall(function() obj.Events.Spear_Stepped_2:Disconnect() end)\n                                obj.Events.Spear_Stepped_2 = nil\n                            end\n                            if obj.Events.Spear_Stepped then\n                                pcall(function() obj.Events.Spear_Stepped:Disconnect() end)\n                                obj.Events.Spear_Stepped = nil\n                            end\n                        end\n\n                        if type(obj.Cache.Interface) == \"table\" and obj.Cache.Interface.Cursor and obj.Cache.Interface.Cursor.Distance2 then\n                            obj.Cache.Interface.Cursor.Distance2.Visible = false\n                        end\n\n                        if type(obj.Cache.Tracks) == \"table\" then\n                            for name, track in pairs(obj.Cache.Tracks) do\n                                if tostring(name):find(\"Spear\") or tostring(name):find(\"Hit\") or tostring(name):find(\"Slash\") then\n                                    pcall(function() track:Stop(0.1) end)\n                                end\n                            end\n                        end\n\n                        if type(obj.Cache.Animations) == \"table\" then\n                            for name, track in pairs(obj.Cache.Animations) do\n                                if tostring(name):find(\"Spear\") or tostring(name):find(\"Hit\") or tostring(name):find(\"Slash\") then\n                                    pcall(function() track:Stop(0.1) end)\n                                end\n                            end\n                        end\n                    end\n                end)\n            ")
            end
            return
        end)
        v1(function()
            local v1_3 = v7_13:FindFirstChild("PlayerGui")
            local v2 = v1_3 and v1_3:FindFirstChild("Interface")
            local v3_3 = v2 and v2:FindFirstChild("Cursor")
            local v4_3 = v3_3 and v3_3:FindFirstChild("Distance2")
            if v4_3 then
                v4_3.Visible = false
            end
            return
        end)
        v1(function()
            local v1 = v7_13.Character
            local v2 = v1 and v1:FindFirstChild("Humanoid")
            local v3_2 = v2 and v2:FindFirstChild("Animator")
            if v3_2 then
                for v7, v8 in ipairs(v3_2:GetPlayingAnimationTracks()) do
                    if v8.Name:find("Spear") or v8.Name:find("Slash") or v8.Name:find("Hit") or v8.Name:find("Throw") then
                        v8:Stop(0.1)
                    end
                end
            end
            return
        end)
        return
    end
    v93_2 = function(p1)
        if not v87_2() then
            return false
        end
        local raidBoss = v150_10.AutoRaid and v150_10.GetRaidBoss()
        if raidBoss then
            local bossNape = v89_2(raidBoss)
            if bossNape then
                p1 = bossNape
            else
                p1 = raidBoss
            end
        end
        local v2_3 = {}
        local v3_3 = v59_2 and 8 or 1
        if type(p1) == "table" and p1[1] ~= nil then
            for v7, v8 in ipairs(p1) do
                if typeof(v8) == "Instance" then
                    if v8:IsA("BasePart") and v8.Name == "Nape" then
                        table.insert(v2_3, v8)
                    else
                        local v11_5 = v8:FindFirstChild("Hitboxes")
                        local v9_7
                        if not v11_5 then
                            v9_7 = nil
                        else
                            local v12_5 = v11_5:FindFirstChild("Hit")
                            if not v12_5 then
                                v9_7 = nil
                            else
                                v9_7 = v12_5:FindFirstChild("Nape")
                            end
                        end
                        if v9_7 then
                            table.insert(v2_3, v9_7)
                        end
                    end
                    if #v2_3 >= v3_3 then
                        break
                    end
                end
            end
        elseif typeof(p1) == "Instance" then
            if p1:IsA("BasePart") and p1.Name == "Nape" then
                table.insert(v2_3, p1)
            else
                local v4_13 = v89_2(p1)
                if v4_13 then
                    table.insert(v2_3, v4_13)
                end
            end
        end
        if raidBoss and #v2_3 > 0 then
            local singleNape = v2_3[1]
            while #v2_3 < v3_3 do
                table.insert(v2_3, singleNape)
            end
        end
        if #v2_3 == 0 then
            return false
        end
        local v4_11 = v71_3()
        if not v4_11 then
            return false
        end
        local v5_16 = v4_11:FindFirstChild("Actor") or v66 and v66()[1]
        if v5_16 and v67_2 then
            pcall(function()
                v67_2(v5_16,
                    string.format(
                        "                local host = _G.__CachedHost\n                if type(host) ~= \"table\"\n                    or type(rawget(host, \"Modules\")) ~= \"table\"\n                    or type(rawget(host, \"Cache\")) ~= \"table\"\n                    or not host.Modules.Zones\n                then\n                    host = nil\n                    _G.__CachedHost = nil\n                    for _, obj in ipairs(getgc(true)) do\n                        if type(obj) == \"table\"\n                            and type(rawget(obj, \"Modules\")) == \"table\"\n                            and type(rawget(obj, \"Cache\")) == \"table\"\n                            and rawget(obj, \"Services\")\n                            and obj.Modules.Zones\n                        then\n                            host = obj\n                            _G.__CachedHost = obj\n                            break\n                        end\n                    end\n                end\n\n                if host then\n                    if host.Loadout and host.Loadout.Stats then\n                        host.Loadout.Stats.Crit_Chance = 100\n                        host.Loadout.Stats.Strike = %d\n                    end\n                    local zones = host.Modules.Zones\n                    if zones and not zones.__SymbioteCritHooked and type(zones.Damage_Check) == \"function\" then\n                        zones.__SymbioteCritHooked = true\n                        local origDamageCheck = zones.Damage_Check\n                        zones.Damage_Check = function(p2, p3, p4, p5, p6, p7, p8, p9)\n                            return origDamageCheck(p2, p3, p4, true, p6, p7, p8, p9)\n                        end\n                    end\n                end\n            ",
                        #v2_3))
                return
            end)
        end
        local v6_17 = v76_2()
        if not v6_17 or v6_17 <= 0 then
            if (v25_2 or v34_2) and not v26_2 then
                v85_2()
            end
            return false
        end
        local v7_8 = nil
        if not pcall(function()
                v7_8 = v69_2:InvokeServer("Spears", "S_Fire", tostring(v6_17))
                return
            end) or v7_8 ~= true then
            local v9_11 = v76_2()
            if v9_11 and 0 < v9_11 and v9_11 ~= v6_17 then
                local v6_18 = v9_11
                pcall(function()
                    v7_8 = v69_2:InvokeServer("Spears", "S_Fire", tostring(v6_18))
                    return
                end)
            end
        end
        if v7_8 == true then
            task.wait(0.03)
            for v12_7, v13_7 in ipairs(v2_3) do
                if v13_7 and v13_7.Parent then
                    pcall(function()
                        v68_2:FireServer("Spears", "S_Explode", v13_7.Position, 2.5)
                        return
                    end)
                end
            end
            v92_2()
            return true
        end
        pcall(function()
            v68_2:FireServer("Spears", "Reset")
            return
        end)
        return false
    end
    v94_2 = function(p1)
        if v65_2 then
            v65_2:Disconnect()
            v65_2 = nil
        end
        if not p1 then
            return
        end
        local v2_7 = p1:WaitForChild("Humanoid", 5)
        local v3_2 = v2_7 and v2_7:WaitForChild("Animator", 5)
        if v3_2 then
            v65_2 = v3_2.AnimationPlayed:Connect(function(p1)
                if v18_4 and (p1.Priority == Enum.AnimationPriority.Action4 or p1.Priority == Enum.AnimationPriority.Action3 or p1.Name:find("Hit") or p1.Name:find("Slash")) then
                    p1:Stop(0)
                end
                return
            end)
        end
        return
    end
end
v7_13.CharacterAdded:Connect(v94_2)
do
    local v95_2 = v13_8:FindFirstChild("Characters") and v13_8.Characters:FindFirstChild(v7_13.Name) or v7_13.Character
    if v95_2 then
        v94_2(v95_2)
    end
end
local v96_6, v97_6, v98_2, v99_2, v100_3, v101_2, v102_3, v103_2, v104_3, v105_3, v106_3, v107_2, v108_3, v109_2, v111_3, v110_3, v113_3, v112_3, v115_3, v114_3, v116_4, v117_4, v121_3, v118_4
do
    local function v95_8(p1, p2)
        local v3 = p1 and p1:FindFirstChild("Hitboxes")
        local v4_2 = v3 and v3:FindFirstChild("Hit")
        if v4_2 then
            for v8, v9 in ipairs(v4_2:GetChildren()) do
                if v9:IsA("BasePart") then
                    v9.CanTouch = p2 and v9.Name == "Nape" or false
                end
            end
        end
        return
    end
    v96_6 = function(p1)
        local searchFolders = {
            v13_8:FindFirstChild("Titans"),
            v13_8:FindFirstChild("Boss"),
            v13_8:FindFirstChild("Shifters")
        }
        for _, fld in ipairs(searchFolders) do
            if fld then
                for _, child in ipairs(fld:GetChildren()) do
                    v95_8(child, p1)
                end
            end
        end
        return
    end
    v97_6 = function(p1)
        if v64_2 or not v87_2() then
            return false
        end
        if v73_2() then
            return v93_2(p1)
        end
        local raidBoss = v150_10.AutoRaid and v150_10.GetRaidBoss()
        if raidBoss then
            if type(p1) == "table" then
                local filtered = {}
                for _, item in ipairs(p1) do
                    local m = (typeof(item) == "Instance" and (item:IsA("Model") and item or item:FindFirstAncestorOfClass("Model")))
                    if m == raidBoss then
                        table.insert(filtered, item)
                    end
                end
                if #filtered > 0 then
                    p1 = filtered
                else
                    p1 = raidBoss
                end
            elseif typeof(p1) == "Instance" then
                local m = p1:IsA("Model") and p1 or p1:FindFirstAncestorOfClass("Model")
                if m ~= raidBoss then
                    p1 = raidBoss
                end
            end
        end
        local v2_7 = {}
        local v3_6 = {}
        local v4_2 = v59_2 and 8 or 1
        if type(p1) == "table" then
            for v8_2, v9_2 in ipairs(p1) do
                if typeof(v9_2) == "Instance" then
                    local v10_4 = v9_2:IsA("Model") and v9_2 or v9_2:FindFirstAncestorOfClass("Model")
                    local v11_5 = (v9_2:IsA("BasePart") and v9_2.Name == "Nape" and v9_2) or (v10_4 and v89_2(v10_4))
                    local v12_6 = v10_4 and v11_5 and v91_2(v10_4)
                    if v12_6 then
                        table.insert(v2_7, v10_4)
                        table.insert(v3_6, v11_5)
                        if v4_2 <= #v3_6 then
                            break
                        end
                    end
                end
            end
        elseif typeof(p1) == "Instance" then
            local v5_8 = p1:IsA("Model") and p1 or p1:FindFirstAncestorOfClass("Model")
            local v6_11 = (p1:IsA("BasePart") and p1.Name == "Nape" and p1) or (v5_8 and v89_2(v5_8))
            if v5_8 and v6_11 and v91_2(v5_8) then
                table.insert(v2_7, v5_8)
                table.insert(v3_6, v6_11)
            end
        end
        if raidBoss and #v3_6 == 1 then
            local singleNape = v3_6[1]
            while #v3_6 < v4_2 do
                table.insert(v3_6, singleNape)
            end
        end
        if #v3_6 == 0 then
            return false
        end
        local v5_13 = v71_3()
        if not v5_13 then
            return false
        end
        local v6_16 = v5_13:FindFirstChild("HumanoidRootPart")
        local v7_9 = v5_13:FindFirstChild("Humanoid")
        local v8_8 = v5_13:FindFirstChild("Hitbox")
        local v9_6 = v5_13:FindFirstChild("Actor")
        if not v6_16 or not v7_9 then
            return false
        end
        local v10_11 = v8_8 and v8_8.CollisionGroup
        local v11_9 = v8_8 and v8_8.Size
        local v12_10 = math.max(120, (55 + v60_2 * 2) * 2 + 50)
        if v8_8 and v8_8:IsA("BasePart") then
            if not v150_10.OriginalSizes[v8_8] then
                v150_10.OriginalSizes[v8_8] = v11_9
            end
            v8_8.CollisionGroup = "Default"
            v8_8.CanCollide = false
            v8_8.CanTouch = true
            v8_8.Size = Vector3.new(v12_10, v12_10, v12_10)
        end
        for v16_6, v17_3 in ipairs(v2_7) do
            local v18_3 = v17_3:FindFirstChild("Hitboxes")
            local v19_2 = v18_3 and v18_3:FindFirstChild("Hit")
            if v19_2 then
                for v23_3, v24_3 in ipairs(v19_2:GetChildren()) do
                    if v24_3:IsA("BasePart") then
                        v24_3.CollisionGroup = "Default"
                        v24_3.CanCollide = false
                        v24_3.CanTouch = v24_3.Name == "Nape"
                    end
                end
            else
                local napePart = v89_2(v17_3)
                if napePart and napePart:IsA("BasePart") then
                    napePart.CollisionGroup = "Default"
                    napePart.CanCollide = false
                    napePart.CanTouch = true
                end
            end
        end
        v64_2 = true
        local v13_27 = v7_9:FindFirstChild("Animator")
        if v13_27 then
            for v17_4, v18_4 in ipairs(v13_27:GetPlayingAnimationTracks()) do
                if v18_4.Priority == Enum.AnimationPriority.Action4 or v18_4.Priority == Enum.AnimationPriority.Action3 or v18_4.Name:find("Hit") or v18_4.Name:find("Slash") then
                    v18_4:Stop(0)
                end
            end
        end
        local v14_25 = false
        if v9_6 and v67_2 then
            local v15_18 = tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))
            local v16_16 = {}
            for v20_9, v21_9 in ipairs(v2_7) do
                table.insert(v16_16, v21_9.Name)
                v21_9:SetAttribute("__SymbioteTarget", v15_18)
            end
            v9_6:SetAttribute("TargetTitanNames", table.concat(v16_16, ","))
            v9_6:SetAttribute("TargetTitan", v15_18)
            v9_6:SetAttribute("SlashMaxTargets", #v3_6)
            v9_6:SetAttribute("SlashDone", false)
            v9_6:SetAttribute("BossBurst", raidBoss ~= nil)
            v9_6:SetAttribute("SlashHandled", false)
            pcall(function()
                v67_2(v9_6,
                    "                local Players = game:GetService(\"Players\")\n                local lp = Players.LocalPlayer\n                local chars = workspace:FindFirstChild(\"Characters\")\n                local c = (chars and chars:FindFirstChild(lp.Name)) or lp.Character\n                local act = c and c:FindFirstChild(\"Actor\")\n                if not act then return end\n\n                local targetId = act:GetAttribute(\"TargetTitan\")\n                local targetNamesStr = act:GetAttribute(\"TargetTitanNames\") or \"\"\n                local nameMap = {}\n                for name in string.gmatch(targetNamesStr, \"[^,]+\") do\n                    nameMap[name] = true\n                end\n                local maxTargets = tonumber(act:GetAttribute(\"SlashMaxTargets\")) or 1\n                local searchFolders = {\n                    workspace:FindFirstChild(\"Titans\"),\n                    workspace:FindFirstChild(\"Boss\"),\n                    workspace:FindFirstChild(\"Shifters\"),\n                    workspace:FindFirstChild(\"Characters\")\n                }\n                local napes = {}\n                for _, fld in ipairs(searchFolders) do\n                    if fld then\n                        for _, m in ipairs(fld:GetChildren()) do\n                            if (targetId and m:GetAttribute(\"__SymbioteTarget\") == targetId) or nameMap[m.Name] then\n                                local np = (m:FindFirstChild(\"Hitboxes\") and m.Hitboxes:FindFirstChild(\"Hit\") and m.Hitboxes.Hit:FindFirstChild(\"Nape\"))\n                                    or m:FindFirstChild(\"Nape\", true)\n                                if np and np:IsA(\"BasePart\") then\n                                    table.insert(napes, np)\n                                    if #napes >= maxTargets then break end\n                                end\n                            end\n                        end\n                    end\n                    if #napes >= maxTargets then break end\n                end\n                if #napes == 0 then\n                    for _, fld in ipairs(searchFolders) do\n                        if fld then\n                            for _, m in ipairs(fld:GetChildren()) do\n                                if m:IsA(\"Model\") and not m:GetAttribute(\"State\") then\n                                    local np = (m:FindFirstChild(\"Hitboxes\") and m.Hitboxes:FindFirstChild(\"Hit\") and m.Hitboxes.Hit:FindFirstChild(\"Nape\"))\n                                        or m:FindFirstChild(\"Nape\", true)\n                                    if np and np:IsA(\"BasePart\") then\n                                        table.insert(napes, np)\n                                        if #napes >= maxTargets then break end\n                                    end\n                                end\n                            end\n                        end\n                        if #napes >= maxTargets then break end\n                    end\n                end\n\n                if #napes > 0 and #napes < maxTargets and (act:GetAttribute(\"BossBurst\") == true or targetId) then\n                    local singleNape = napes[1]\n                    while #napes < maxTargets do\n                        table.insert(napes, singleNape)\n                    end\n                end\n\n                local h = c and c:FindFirstChild(\"HumanoidRootPart\")\n                local hm = c and c:FindFirstChild(\"Humanoid\")\n                local hb = c and c:FindFirstChild(\"Hitbox\")\n                if hb and hb:IsA(\"BasePart\") then\n                    hb.CanCollide = false\n                    hb.CanTouch = true\n                end\n\n                local host = _G.__CachedHost\n                if type(host) ~= \"table\"\n                    or type(rawget(host, \"Modules\")) ~= \"table\"\n                    or type(rawget(host, \"Cache\")) ~= \"table\"\n                    or host.Cache.Character ~= c\n                    or not host.Modules.Zones\n                    or not host.Modules.Input\n                    or not host.Modules.ODMG\n                    or not host.Modules.Effects\n                then\n                    host = nil\n                    _G.__CachedHost = nil\n                    local now = os.clock()\n                    local lastScan = _G.__LastHostScan or 0\n                    if (now - lastScan) >= 1 then\n                        _G.__LastHostScan = now\n                        for _, obj in ipairs(getgc(true)) do\n                            if type(obj) == \"table\"\n                                and type(rawget(obj, \"Modules\")) == \"table\"\n                                and type(rawget(obj, \"Cache\")) == \"table\"\n                                and obj.Cache.Character == c\n                                and obj.Modules.Zones\n                            then\n                                host = obj\n                                _G.__CachedHost = obj\n                                break\n                            end\n                        end\n                    end\n                end\n\n                if host and #napes > 0 and h and hm then\n                    act:SetAttribute(\"SlashHandled\", true)\n                    pcall(function()\n                        local slash = host.Cache.Variables.Slash\n                        local odmg = host.Modules.ODMG\n                        local inputMod = host.Modules.Input\n                        local effects = host.Modules.Effects\n                        local zones = host.Modules.Zones\n\n                        if inputMod.Slashing then\n                            pcall(function() task.cancel(inputMod.Slashing) end)\n                            inputMod.Slashing = nil\n                        end\n                        if type(odmg.Events) == \"table\" then\n                            for _, ev in pairs(odmg.Events) do\n                                pcall(function() task.cancel(ev) end)\n                            end\n                            table.clear(odmg.Events)\n                        end\n\n                        if effects.Slash_State == true then\n                            pcall(function() effects.Slash(host, false, true) end)\n                            effects.Slash_State = false\n                        end\n\n                        host.Invoked = false\n                        if host.Modules.Shift then\n                            host.Modules.Shift.Stunned = false\n                        end\n\n                        if host.Loadout and host.Loadout.Stats then\n                            host.Loadout.Stats.Crit_Chance = 100\n                            host.Loadout.Stats.Strike = maxTargets\n                        end\n\n                        if not zones.__SymbioteCritHooked and type(zones.Damage_Check) == \"function\" then\n                            zones.__SymbioteCritHooked = true\n                            local origDamageCheck = zones.Damage_Check\n                            zones.Damage_Check = function(p2, p3, p4, p5, p6, p7, p8, p9)\n                                return origDamageCheck(p2, p3, p4, true, p6, p7, p8, p9)\n                            end\n                        end\n\n                        slash.Slashing = false\n                        slash.Released = false\n                        slash.Holding = false\n                        slash.Cooldown = false\n                        slash.Combo = 0\n                        table.clear(zones.Hit)\n\n                        if not host.__OrigTasks and type(odmg.Tasks) == \"function\" then\n                            host.__OrigTasks = odmg.Tasks\n                        end\n                        odmg.Tasks = function() end\n                        pcall(function() odmg.M1(host, false) end)\n                        if host.__OrigTasks then\n                            odmg.Tasks = host.__OrigTasks\n                        end\n\n                        slash.Slashing = true\n                        slash.Released = false\n                        slash.Holding = false\n                        slash.Type = \"Air\"\n                        slash.Last = tick() - 0.65\n                        zones.Time_Difference = 0.65\n\n                        task.wait(0.04)\n\n                        table.clear(zones.Hit)\n                        pcall(function() inputMod.Slash(host, h, hm) end)\n                        slash.Slashing = true\n                        slash.Released = true\n                        slash.Holding = false\n                        slash.Type = \"Air\"\n\n                        if effects.Slash_State ~= true then\n                            pcall(function() effects.Slash(host, true, true) end)\n                            effects.Slash_State = true\n                        end\n                        host:Send(\"Attacks\", \"Slash\", true)\n\n                        local a = hm:FindFirstChild(\"Animator\")\n                        if a then\n                            for _, track in ipairs(a:GetPlayingAnimationTracks()) do\n                                if track.Priority == Enum.AnimationPriority.Action4 or track.Priority == Enum.AnimationPriority.Action3 or track.Name:find(\"Hit\") or track.Name:find(\"Slash\") then\n                                    track:Stop(0)\n                                end\n                            end\n                        end\n\n                        for _, np in ipairs(napes) do\n                            table.insert(zones.Hit, np)\n                            host:Send(\"Hitboxes\", \"Register\", np, 0.65)\n                        end\n\n                        task.wait(0.12)\n\n                        if inputMod.Slashing then\n                            pcall(function() task.cancel(inputMod.Slashing) end)\n                            inputMod.Slashing = nil\n                        end\n                        slash.Slashing = false\n                        slash.Released = false\n                        slash.Holding = false\n                        pcall(function() effects.Slash(host, false, true) end)\n                        if effects.Slash_State ~= false then\n                            effects.Slash_State = false\n                        end\n                        host:Send(\"Attacks\", \"Slash\", false)\n                    end)\n                end\n\n                act:SetAttribute(\"SlashDone\", true)\n            ")
                return
            end)
            local v17_20 = os.clock()
            while os.clock() - v17_20 < 0.22 do
                if v9_6:GetAttribute("SlashDone") == true then
                    break
                else
                    task.wait(0.02)
                end
            end
            v14_25 = v9_6:GetAttribute("SlashHandled") == true
        end
        if not v14_25 then
            local v15_20 = _G.__CachedHost
            if type(v15_20) ~= "table" or type(rawget(v15_20, "Modules")) ~= "table" or type(rawget(v15_20, "Cache")) ~= "table" or v15_20.Cache.Character ~= v5_13 or not v15_20.Modules.Zones or not v15_20.Modules.Input or not v15_20.Modules.ODMG or not v15_20.Modules.Effects then
                v15_20 = nil
                _G.__CachedHost = nil
                if getgc then
                    for v19_36, v20_31 in ipairs(getgc(true)) do
                        if type(v20_31) == "table" and type(rawget(v20_31, "Modules")) == "table" and type(rawget(v20_31, "Cache")) == "table" and v20_31.Cache.Character == v5_13 and v20_31.Modules.Zones then
                            v15_20 = v20_31
                            _G.__CachedHost = v20_31
                            break
                        end
                    end
                end
            end
            if v15_20 then
                pcall(function()
                    local v4 = v15_20
                    local v1 = v4.Cache.Variables.Slash
                    local v2_2 = v4.Modules.ODMG
                    local v5 = v4
                    local v3_3 = v5.Modules.Input
                    local v6_2 = v5
                    local v4_4 = v6_2.Modules.Effects
                    local v5_3 = v6_2.Modules.Zones
                    if v3_3.Slashing then
                        pcall(function()
                            task.cancel(v3_3.Slashing)
                            return
                        end)
                        v3_3.Slashing = nil
                    end
                    if type(v2_2.Events) == "table" then
                        for v9, v10 in pairs(v2_2.Events) do
                            pcall(function()
                                task.cancel(v10)
                                return
                            end)
                        end
                        table.clear(v2_2.Events)
                    end
                    if v4_4.Slash_State == true then
                        pcall(function()
                            v4_4.Slash(v15_20, false, true)
                            return
                        end)
                        v4_4.Slash_State = false
                    end
                    local v6_15 = v15_20
                    v6_15.Invoked = false
                    if v6_15.Modules.Shift then
                        v15_20.Modules.Shift.Stunned = false
                    end
                    if v15_20.Loadout and v15_20.Loadout.Stats then
                        local v8_6 = v15_20
                        v8_6.Loadout.Stats.Crit_Chance = 100
                        v8_6.Loadout.Stats.Strike = v4_2
                    end
                    if not v5_3.__SymbioteCritHooked and type(v5_3.Damage_Check) == "function" then
                        v5_3.__SymbioteCritHooked = true
                        local v6_23 = v5_3.Damage_Check
                        v5_3.Damage_Check = function(p1, p2, p3, p4, p5, p6, p7, p8)
                            return v6_23(p1, p2, p3, true, p5, p6, p7, p8)
                        end
                    end
                    v1.Slashing = false
                    v1.Released = false
                    v1.Holding = false
                    v1.Cooldown = false
                    v1.Combo = 0
                    table.clear(v5_3.Hit)
                    if not v15_20.__OrigTasks and type(v2_2.Tasks) == "function" then
                        v15_20.__OrigTasks = v2_2.Tasks
                    end
                    v2_2.Tasks = function()
                        return
                    end
                    pcall(function()
                        v2_2.M1(v15_20, false)
                        return
                    end)
                    if v15_20.__OrigTasks then
                        v2_2.Tasks = v15_20.__OrigTasks
                    end
                    v1.Slashing = true
                    v1.Released = false
                    v1.Holding = false
                    v1.Type = "Air"
                    v1.Last = tick() - 0.65
                    v5_3.Time_Difference = 0.65
                    task.wait(0.04)
                    table.clear(v5_3.Hit)
                    pcall(function()
                        v3_3.Slash(v15_20, v6_16, v7_9)
                        return
                    end)
                    v1.Slashing = true
                    v1.Released = true
                    v1.Holding = false
                    v1.Type = "Air"
                    if v4_4.Slash_State ~= true then
                        pcall(function()
                            v4_4.Slash(v15_20, true, true)
                            return
                        end)
                        v4_4.Slash_State = true
                    end
                    v15_20:Send("Attacks", "Slash", true)
                    local v6_47 = v7_9:FindFirstChild("Animator")
                    if v6_47 then
                        for v10_3, v11_2 in ipairs(v6_47:GetPlayingAnimationTracks()) do
                            if v11_2.Priority == Enum.AnimationPriority.Action4 or v11_2.Priority == Enum.AnimationPriority.Action3 or v11_2.Name:find("Hit") or v11_2.Name:find("Slash") then
                                v11_2:Stop(0)
                            end
                        end
                    end
                    for v10_5, v11_4 in ipairs(v3_6) do
                        table.insert(v5_3.Hit, v11_4)
                        v15_20:Send("Hitboxes", "Register", v11_4, 0.65)
                    end
                    task.wait(0.12)
                    if v3_3.Slashing then
                        pcall(function()
                            task.cancel(v3_3.Slashing)
                            return
                        end)
                        v3_3.Slashing = nil
                    end
                    v1.Slashing = false
                    v1.Released = false
                    v1.Holding = false
                    pcall(function()
                        v4_4.Slash(v15_20, false, true)
                        return
                    end)
                    if v4_4.Slash_State ~= false then
                        v4_4.Slash_State = false
                    end
                    v15_20:Send("Attacks", "Slash", false)
                    return
                end)
            else
                pcall(function()
                    local v7 = game
                    v17_6:SendMouseButtonEvent(0, 0, 0, true, v7, 0)
                    task.wait(0.04)
                    v17_6:SendMouseButtonEvent(0, 0, 0, false, v7, 0)
                    return
                end)
                task.wait(0.08)
                local v16_27 = v8_8 and getconnections and getconnections(v8_8.Touched) or {}
                for v20_33, v21_25 in ipairs(v3_6) do
                    if v21_25 and v21_25.Parent then
                        for v25_19, v26_14 in ipairs(v16_27) do
                            pcall(function()
                                v26_14:Fire(v21_25)
                                return
                            end)
                        end
                        pcall(function()
                            v68_2:FireServer("Hitboxes", "Register", v21_25, 0.65)
                            return
                        end)
                    end
                end
                task.wait(0.1)
            end
        end
        if v8_8 and v8_8:IsA("BasePart") then
            v8_8.CollisionGroup = v10_11
            v8_8.Size = v11_9
        end
        for v18_31, v19_33 in ipairs(v2_7) do
            v95_8(v19_33, true)
        end
        v64_2 = false
        return true
    end
    local v100_2 = nil
    v98_2 = function()
        if v100_2 then
            return
        end
        v100_2 = v14_9.Stepped:Connect(function()
            local v1 = v7_13.Character
            if v1 then
                for v5, v6 in pairs(v1:GetDescendants()) do
                    if v6:IsA("BasePart") then
                        v6.CanCollide = false
                    end
                end
            end
            return
        end)
        return
    end
    v99_2 = function()
        if v100_2 then
            v100_2:Disconnect()
            v100_2 = nil
        end
        local v1_5 = v7_13.Character
        if v1_5 then
            for v5, v6 in pairs(v1_5:GetDescendants()) do
                if v6:IsA("BasePart") then
                    v6.CanCollide = true
                end
            end
        end
        return
    end
    local v102_2 = nil
    v100_3 = function()
        if v102_2 then
            v102_2:Disconnect()
        end
        v102_2 = v14_9.Heartbeat:Connect(function()
            if not v27_2 then
                return
            end
            local v1_2 = v7_13.Character
            if not v1_2 then
                return
            end
            local v2_5 = v1_2:FindFirstChild("HumanoidRootPart")
            if not v2_5 then
                return
            end
            local v3_4 = v1_2:FindFirstChild("Humanoid")
            if not v3_4 or v3_4.Health <= 0 then
                return
            end
            local v4_4 = v3_4.MoveDirection
            if 0.1 > v4_4.Magnitude then
                return
            end
            v2_5.CFrame = v2_5.CFrame + v4_4.Unit * v28_2
            return
        end)
        return
    end
    v101_2 = function()
        if v102_2 then
            v102_2:Disconnect()
            v102_2 = nil
        end
        return
    end
    local v104_2 = nil
    local v105_2 = 0
    v102_3 = function()
        if v104_2 then
            v104_2:Disconnect()
        end
        v105_2 = 0
        v104_2 = v14_9.Heartbeat:Connect(function(p1)
            if not v29_2 then
                return
            end
            local v2_2 = v7_13.Character
            if not v2_2 then
                return
            end
            local v3_5 = v2_2:FindFirstChild("HumanoidRootPart")
            if not v3_5 then
                return
            end
            local v4_4 = v2_2:FindFirstChild("Humanoid")
            if not v4_4 or v4_4.Health <= 0 then
                return
            end
            local v5_4 = v4_4.MoveDirection
            if 0.1 > v5_4.Magnitude then
                v105_2 = 0
                return
            end
            v105_2 = v105_2 + p1
            if v31_2 * 0.1 > v105_2 then
                return
            end
            v105_2 = 0
            v3_5.CFrame = v3_5.CFrame + v5_4.Unit * v30_2
            return
        end)
        return
    end
    v103_2 = function()
        if v104_2 then
            v104_2:Disconnect()
            v104_2 = nil
        end
        v105_2 = 0
        return
    end
    local v106_2 = nil
    v104_3 = function()
        if v106_2 then
            return
        end
        v106_2 = v15_29.InputBegan:Connect(function(p1, p2)
            if not v32_2 then
                return
            end
            if p2 then
                return
            end
            if p1.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            if not (v15_29:IsKeyDown(Enum.KeyCode.LeftControl) or v15_29:IsKeyDown(Enum.KeyCode.RightControl)) then
                return
            end
            local v3_4 = v7_13.Character
            local v4_8 = v3_4 and v3_4:FindFirstChild("HumanoidRootPart")
            if not v4_8 then
                return
            end
            local v5_6 = v13_8.CurrentCamera
            local v6_10 = v15_29:GetMouseLocation()
            local v7_5 = v5_6:ViewportPointToRay(v6_10.X, v6_10.Y)
            local v8_3 = RaycastParams.new()
            v8_3.FilterType = Enum.RaycastFilterType.Exclude
            v8_3.FilterDescendantsInstances = { v3_4 }
            local v9 = v13_8:Raycast(v7_5.Origin, v7_5.Direction * 5000, v8_3)
            if v9 then
                v4_8.CFrame = CFrame.new(v9.Position + Vector3.new(0, 3, 0)) * (v4_8.CFrame - v4_8.CFrame.Position)
            end
            return
        end)
        return
    end
    v105_3 = function()
        if v106_2 then
            v106_2:Disconnect()
            v106_2 = nil
        end
        return
    end
    local v108_2 = nil
    v106_3 = function()
        if v108_2 then
            v108_2:Disconnect()
        end
        v108_2 = v15_29.JumpRequest:Connect(function()
            if not v33_2 then
                return
            end
            local v1_2 = v7_13.Character
            local v2_2 = v1_2 and v1_2:FindFirstChild("Humanoid")
            if v2_2 then
                v2_2:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            return
        end)
        return
    end
    v107_2 = function()
        if v108_2 then
            v108_2:Disconnect()
            v108_2 = nil
        end
        return
    end
    local v110_2 = nil
    local v111_2 = nil
    v108_3 = function()
        local v1_3 = v7_13:FindFirstChild("PlayerGui")
        local v2 = v1_3 and v1_3:FindFirstChild("Interface")
        local v3_3 = v2 and v2:FindFirstChild("Cursor")
        if v3_3 and v111_2 == nil then
            v111_2 = v3_3.Visible
        end
        if v3_3 then
            v3_3.Visible = false
        end
        v15_29.MouseIconEnabled = true
        if v110_2 then
            v110_2:Disconnect()
        end
        v110_2 = v14_9.Heartbeat:Connect(function()
            if not v37_2 then
                return
            end
            if not v3_3 or not v3_3.Parent then
                local v1_5 = v7_13:FindFirstChild("PlayerGui")
                local v2_4 = v1_5 and v1_5:FindFirstChild("Interface")
                v3_3 = v2_4 and v2_4:FindFirstChild("Cursor")
            end
            if v3_3 then
                v3_3.Visible = false
            end
            return
        end)
        return
    end
    v109_2 = function()
        if v110_2 then
            v110_2:Disconnect()
            v110_2 = nil
        end
        local v1_7 = v7_13:FindFirstChild("PlayerGui")
        local v2_2 = v1_7 and v1_7:FindFirstChild("Interface")
        local v3_3 = v2_2 and v2_2:FindFirstChild("Cursor")
        if v3_3 then
            v3_3.Visible = v111_2 ~= nil and v111_2 or true
        end
        v111_2 = nil
        return
    end
    local v112_2 = nil
    local v113_2 = nil
    local autoRetryWatcherThread = nil
    local lastRetryInvokeTime = 0

    function v150_10.IsMatchEnded()
        local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
        local iface = pgui and pgui:FindFirstChild("Interface")
        if not pgui then return false end

        local rewards = iface and iface:FindFirstChild("Rewards")
        if rewards and (rewards.Visible == true or (rewards:IsA("LayerCollector") and rewards.Enabled == true)) then
            return true
        end

        if iface then
            for _, name in ipairs({ "Result", "Results", "Victory", "Defeat", "MissionComplete", "GameEnd", "MatchEnd", "EndScreen" }) do
                local f = iface:FindFirstChild(name)
                if f and (f.Visible == true or (f:IsA("LayerCollector") and f.Enabled == true)) then
                    return true
                end
            end
        end

        for _, name in ipairs({ "Rewards", "Results", "EndScreen", "Victory", "Defeat" }) do
            local f = pgui:FindFirstChild(name)
            if f and f ~= iface and (f.Visible == true or (f:IsA("LayerCollector") and f.Enabled == true)) then
                return true
            end
        end

        return false
    end

    function v150_10.HandleRetryAndContinueScreen()
        local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
        local iface = pgui and pgui:FindFirstChild("Interface")
        if not pgui then
            lastRetryInvokeTime = 0
            return false
        end

        -- STRICT MATCH END CHECK:
        -- Absolutely NEVER retry, click next, or leave while the mission is still running!
        if not v150_10.IsMatchEnded() then
            lastRetryInvokeTime = 0
            return false
        end

        -- Mission Safety Timer check: ensure minimum 30 seconds before continuing/retrying
        local elapsed = os.clock() - (v150_10.MissionStartTime or os.clock())
        if elapsed < 30 then
            return false
        end

        if v150_10.ShouldKaitunReturnToLobby and v150_10.ShouldKaitunReturnToLobby() then
            v150_10.KaitunReturnToLobby()
            return true
        end

        local candidateFrames = {}
        local rewards = iface and iface:FindFirstChild("Rewards")
        if rewards and (rewards.Visible == true or (rewards:IsA("LayerCollector") and rewards.Enabled == true)) then
            table.insert(candidateFrames, rewards)
        end
        if iface then
            for _, name in ipairs({ "Result", "Results", "Victory", "Defeat", "MissionComplete", "GameEnd", "MatchEnd", "EndScreen" }) do
                local f = iface:FindFirstChild(name)
                if f and (f.Visible == true or (f:IsA("LayerCollector") and f.Enabled == true)) then
                    table.insert(candidateFrames, f)
                end
            end
        end
        for _, name in ipairs({ "Rewards", "Results", "EndScreen", "Victory", "Defeat" }) do
            local f = pgui:FindFirstChild(name)
            if f and f ~= iface and (f.Visible == true or (f:IsA("LayerCollector") and f.Enabled == true)) then
                table.insert(candidateFrames, f)
            end
        end

        if #candidateFrames == 0 then
            lastRetryInvokeTime = 0
            return false
        end

        local handled = false

        local function getBtnText(b)
            if b.Text and b.Text ~= "" then return b.Text end
            for _, ch in ipairs(b:GetChildren()) do
                if ch:IsA("TextLabel") and ch.Text and ch.Text ~= "" then
                    return ch.Text
                end
            end
            return b.Name or ""
        end

        local retryBtns = {}
        local claimBtns = {}

        for _, f in ipairs(candidateFrames) do
            for _, btn in ipairs(f:GetDescendants()) do
                if btn:IsA("GuiButton") and btn.Visible == true then
                    local rawText = getBtnText(btn)
                    local t = tostring(rawText):upper()
                    local n = tostring(btn.Name):upper()

                    local isLobby = t:find("LOBBY") or t:find("SẢNH") or t:find("TRỞ VỀ")
                        or t:find("TRỞ LẠI") or t:find("RETURN") or t:find("LEAVE") or t:find("THOÁT")
                        or n:find("LOBBY")

                    if not isLobby then
                        local isRetry = t:find("CHƠI LẠI") or t:find("CHOI LAI") or t:find("RETRY") or t:find("REPLAY")
                            or t:find("THỬ LẠI") or t:find("THU LAI") or t:find("AGAIN") or n:find("RETRY") or n:find("REPLAY")

                        local isClaim = t:find("NHẬN") or t:find("CLAIM") or t:find("XÁC NHẬN") or t:find("CONFIRM")
                            or t:find("BỎ QUA") or t:find("SKIP") or t:find("OK") or t:find("ACCEPT") or t:find("CLOSE")
                            or n:find("CLAIM") or n:find("OK") or n:find("CLOSE")

                        if isRetry then
                            table.insert(retryBtns, btn)
                        elseif isClaim then
                            table.insert(claimBtns, btn)
                        end
                    end
                end
            end
        end

        local function doClick(b)
            if v150_10.ClickGuiButton then
                v150_10.ClickGuiButton(b)
            else
                pcall(function()
                    if type(firesignal) == "function" then
                        firesignal(b.MouseButton1Click)
                        firesignal(b.Activated)
                    end
                end)
            end
        end

        -- 1. Click reward / confirmation popups first (Claim, OK)
        for _, btn in ipairs(claimBtns) do
            doClick(btn)
            handled = true
        end

        -- 2. ONLY RETRY if AutoRetry is enabled or Kaitun is active!
        -- NEVER click Next! Clicking Next advances to another map, which ruins farming!
        local canRetry = v8_6("AutoRetry") == true or v8_6("KaitunEnabled") == true
        if canRetry then
            if #retryBtns > 0 then
                for _, btn in ipairs(retryBtns) do
                    doClick(btn)
                    handled = true
                end
            end

            local now = os.clock()
            if lastRetryInvokeTime == 0 or now - lastRetryInvokeTime >= 1.0 then
                lastRetryInvokeTime = now
                if v69_2 then
                    -- Asynchronous non-blocking invoke to prevent thread hangs after 15-20 matches
                    task.spawn(function()
                        pcall(function()
                            v69_2:InvokeServer("Functions", "Retry", "Add")
                        end)
                    end)
                    v150_10.MissionStartTime = os.clock()
                    handled = true
                end
            end
        end

        return handled
    end

    v111_3 = function()
        if autoRetryWatcherThread then
            task.cancel(autoRetryWatcherThread)
            autoRetryWatcherThread = nil
        end
        if v112_2 then
            v112_2:Disconnect()
            v112_2 = nil
        end
        if v113_2 then
            task.cancel(v113_2)
            v113_2 = nil
        end
        return
    end

    v110_3 = function()
        v111_3()
        autoRetryWatcherThread = task.spawn(function()
            while v38_2 do
                pcall(function()
                    v150_10.HandleRetryAndContinueScreen()
                end)
                task.wait(0.8)
            end
            autoRetryWatcherThread = nil
        end)
        return
    end
    local v114_2 = nil
    local v115_2 = false
    local v116_2 = nil
    local function v117_2(p1)
        local v2 = getnilinstances or get_nil_instances
        if not v2 then
            return nil
        end
        local v3_4 = v2()
        if type(v3_4) == "table" then
            for v7, v8 in ipairs(v3_4) do
                if v8.Name == p1 then
                    return v8
                end
            end
        end
        return nil
    end
    local function v118_2(p1)
        pcall(function()
            v17_6:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            v17_6:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            return
        end)
        local v2 = p1 and (p1:FindFirstChild("Interact") or p1:FindFirstChildWhichIsA("GuiButton", true))
        if v2 then
            local v3_4 = firesignal
            if v3_4 then
                local v4_3 = pcall
                v4_3(function()
                    v3_4(v2.MouseButton1Click)
                    return
                end)
                v4_3(function()
                    v3_4(v2.MouseButton1Down)
                    return
                end)
                v4_3(function()
                    v3_4(v2.MouseButton1Up)
                    return
                end)
                v4_3(function()
                    v3_4(v2.Activated)
                    return
                end)
            end
            if v2.AbsolutePosition and v2.AbsoluteSize then
                local v4_5 = v2.AbsolutePosition + v2.AbsoluteSize / 2
                pcall(function()
                    local v4 = v4_5
                    local v7 = game
                    v17_6:SendMouseButtonEvent(v4.X, v4.Y, 0, true, v7, 0)
                    task.wait(0.05)
                    local v4_3 = v4_5
                    v17_6:SendMouseButtonEvent(v4_3.X, v4_3.Y, 0, false, v7, 0)
                    return
                end)
            end
        end
        return
    end
    local function v119_2(p1)
        if not v39_2 or v115_2 then
            return
        end
        if not (p1 and p1.Visible) then
            return
        end
        v115_2 = true
        local v2_3 = v117_2("Middle")
        if v2_3 then
            pcall(function()
                v68_2:FireServer("Functions", "Finished", v2_3)
                return
            end)
        end
        task.wait(0.3)
        if v39_2 and p1 and p1.Visible then
            v118_2(p1)
        end
        task.wait(0.5)
        v115_2 = false
        return
    end
    local autoSkipWatcherThread = nil
    v113_3 = function()
        if autoSkipWatcherThread then
            task.cancel(autoSkipWatcherThread)
            autoSkipWatcherThread = nil
        end
        if v114_2 then
            v114_2:Disconnect()
            v114_2 = nil
        end
        if v116_2 then
            task.cancel(v116_2)
            v116_2 = nil
        end
        v115_2 = false
        return
    end
    v112_3 = function()
        v113_3()
        autoSkipWatcherThread = task.spawn(function()
            while v39_2 do
                pcall(function()
                    local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                    local iface = pgui and pgui:FindFirstChild("Interface")
                    local skipBtn = iface and iface:FindFirstChild("Skip")
                    if skipBtn and skipBtn.Visible then
                        v119_2(skipBtn)
                    end
                end)
                task.wait(0.5)
            end
            autoSkipWatcherThread = nil
        end)
        return
    end
    local v116_3 = nil
    local v117_3 = false
    local v118_3 = nil
    local function v119_3(p1)
        if not v40_2 or v117_3 then
            return
        end
        if not (p1 and p1.Visible) then
            return
        end
        v117_3 = true
        pcall(function()
            v70_2()
            if not v69_2 then
                return
            end
            local v1_5 = p1:FindFirstChild("Free")
            local v2_5 = p1:FindFirstChild("Premium")
            local v3_5 = p1:FindFirstChild("Finish")
            if v1_5 and v1_5.Visible then
                local v4_4 = firesignal
                if v4_4 then
                    pcall(function()
                        v4_4(v1_5.MouseButton1Click)
                        return
                    end)
                end
                pcall(function()
                    v69_2:InvokeServer("S_Rewards", "Chest", "Free")
                    return
                end)
                task.wait(0.3)
            end
            if v2_5 and v2_5.Visible then
                local v4_7 = v2_5:FindFirstChild("Title")
                local v5_6 = 0
                if v4_7 and v4_7.Text then
                    v5_6 = tonumber(v4_7.Text:match("%((%d+)%)")) or 0
                end
                if v5_6 > 0 then
                    local v6_11 = firesignal
                    if v6_11 then
                        pcall(function()
                            v6_11(v2_5.MouseButton1Click)
                            return
                        end)
                    end
                    pcall(function()
                        v69_2:InvokeServer("S_Rewards", "Chest", "Premium")
                        return
                    end)
                    task.wait(0.3)
                end
            end
            if v3_5 then
                local v4_8 = firesignal
                if v4_8 then
                    pcall(function()
                        v4_8(v3_5.MouseButton1Click)
                        return
                    end)
                end
                local v5_8 = getconnections
                if v5_8 then
                    pcall(function()
                        for v4, v5 in ipairs(v5_8(v3_5.MouseButton1Click)) do
                            if v5.Fire then
                                v5:Fire()
                            end
                        end
                        return
                    end)
                end
            end
            local v4_9 = v7_13 or v6_21.LocalPlayer
            if v4_9 then
                local v5_10 = pcall
                v5_10(function()
                    v4_9:SetAttribute("Free_Chest", true)
                    return
                end)
                v5_10(function()
                    v4_9:SetAttribute("Premium_Chest", true)
                    return
                end)
                v5_10(function()
                    v4_9:SetAttribute("Cutscene", nil)
                    return
                end)
            end
            local v5_11 = v13_8:FindFirstChild("Chest_End")
            if v5_11 then
                pcall(function()
                    v5_11:Destroy()
                    return
                end)
            end
            p1.Visible = false
            local v6_22 = ((v7_13 or v6_21.LocalPlayer)):FindFirstChild("PlayerGui")
            local v7_11 = v6_22 and v6_22:FindFirstChild("Interface")
            local v8_9 = v7_11 and v7_11:FindFirstChild("Rewards")
            if v8_9 then
                v8_9.Visible = true
                local v9_5 = v8_9:FindFirstChild("Main")
                if v9_5 then
                    v9_5.Visible = true
                    v9_5.GroupTransparency = 0
                end
            end
            return
        end)
        task.wait(0.5)
        v117_3 = false
        return
    end
    v115_3 = function()
        if v116_3 then
            v116_3:Disconnect()
            v116_3 = nil
        end
        if v118_3 then
            task.cancel(v118_3)
            v118_3 = nil
        end
        v117_3 = false
        return
    end
    v114_3 = function()
        v115_3()
        v118_3 = task.spawn(function()
            local v1_3 = v7_13:WaitForChild("PlayerGui", 15)
            local v2 = v1_3 and v1_3:WaitForChild("Interface", 15)
            local v3_3 = v2 and v2:WaitForChild("Chests", 15)
            if not v3_3 or not v40_2 then
                return
            end
            if v3_3.Visible then
                task.spawn(function()
                    v119_3(v3_3)
                    return
                end)
            end
            v116_3 = v3_3:GetPropertyChangedSignal("Visible"):Connect(function()
                if not v40_2 or not v3_3.Visible then
                    return
                end
                task.spawn(function()
                    v119_3(v3_3)
                    return
                end)
                return
            end)
            v118_3 = nil
            return
        end)
        return
    end
    local v119_4 = {}
    local v120_3 = {}
    v116_4 = function(p1)
        local v2 = p1 or v23_2
        for v7, v8 in ipairs(v88_2()) do
            local v11_2 = v8:FindFirstChild("Hitboxes")
            local v9
            if not v11_2 then
                v9 = nil
            else
                local v12_5 = v11_2:FindFirstChild("Hit")
                if not v12_5 then
                    v9 = nil
                else
                    v9 = v12_5:FindFirstChild("Nape")
                end
            end
            if v9 and v9:IsA("BasePart") then
                if not v119_4[v8] then
                    v119_4[v8] = v9.Size
                end
                if not v150_10.OriginalSizes[v9] then
                    v150_10.OriginalSizes[v9] = v119_4[v8]
                end
                v9.CanCollide = false
                if 0.01 < math.abs(math.max(v9.Size.X, v9.Size.Y, v9.Size.Z) - v2) then
                    v9.Size = Vector3.new(v2, v2, v2)
                end
            end
        end
        for v7_2, v8_2 in pairs(v119_4) do
            if not v7_2.Parent then
                v119_4[v7_2] = nil
            end
        end
        return
    end
    v117_4 = function()
        for v5, v6 in ipairs(v88_2()) do
            local v9_2 = v6:FindFirstChild("Hitboxes")
            local v7
            if not v9_2 then
                v7 = nil
            else
                local v10_5 = v9_2:FindFirstChild("Hit")
                if not v10_5 then
                    v7 = nil
                else
                    v7 = v10_5:FindFirstChild("Nape")
                end
            end
            if v7 and v7:IsA("BasePart") then
                if v119_4[v6] then
                    local v9_5 = v119_4
                    v7.Size = v9_5[v6]
                    v9_5[v6] = nil
                    v150_10.OriginalSizes[v7] = nil
                end
            end
        end
        for v5_2, v6_2 in pairs(v119_4) do
            if not v5_2.Parent then
                v119_4[v5_2] = nil
            end
        end
        return
    end
    v121_3 = function()
        if not v24_2 then
            return
        end
        local v2_2 = {}
        for v6, v7 in ipairs(v88_2()) do
            v2_2[v7] = true
            local v10_2 = v7:FindFirstChild("Hitboxes")
            local v8_2
            if not v10_2 then
                v8_2 = nil
            else
                local v11_5 = v10_2:FindFirstChild("Hit")
                if not v11_5 then
                    v8_2 = nil
                else
                    v8_2 = v11_5:FindFirstChild("Nape")
                end
            end
            if v8_2 and v8_2:IsA("BasePart") then
                if not v120_3[v7] then
                    local v9_9 = Instance.new("SelectionBox")
                    v9_9.Color3 = Color3.fromRGB(255, 50, 50)
                    v9_9.LineThickness = 0.08
                    v9_9.SurfaceTransparency = 1
                    v9_9.Adornee = v8_2
                    v9_9.Parent = v13_8.CurrentCamera
                    v120_3[v7] = v9_9
                end
            end
        end
        for v6_2, v7_2 in pairs(v120_3) do
            if not v2_2[v6_2] then
                if v7_2 and v7_2.Parent then
                    v7_2:Destroy()
                end
                v120_3[v6_2] = nil
            end
        end
        return
    end
    v118_4 = function()
        for v4, v5 in pairs(v120_3) do
            if v5 and v5.Parent then
                v5:Destroy()
            end
        end
        v120_3 = {}
        return
    end
end
do
    local v122_2 = 0
    v14_9.Heartbeat:Connect(function()
        local v1_2 = os.clock()
        if 0.5 > v1_2 - v122_2 then
            return
        end
        v122_2 = v1_2
        if v22_2 then
            v116_4(v23_2)
        end
        if v24_2 then
            v121_3()
        end
        return
    end)
end
local v121_4, v122_3, v123_4, v127_2, v128_2, v129_4, v50_2
do
    local function toNumY(v)
        if type(v) == "number" then return v end
        if type(v) == "table" or type(v) == "userdata" then
            local ok, y = pcall(function() return v.Y end)
            if ok and type(y) == "number" then return y end
            if type(v[2]) == "number" then return v[2] end
        end
        return 0
    end

    local function getTitanTopY(model, defaultPart)
        if not model then
            local defPosY = defaultPart and pcall(function() return defaultPart.Position.Y end) and toNumY(defaultPart.Position.Y) or 0
            return defPosY + 15
        end
        local head = model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            local hy = toNumY(head.Position and head.Position.Y)
            local sy = toNumY(head.Size and head.Size.Y)
            return hy + sy * 0.5
        end
        local nape = defaultPart or model:FindFirstChild("Nape", true)
        if nape and nape:IsA("BasePart") then
            local ny = toNumY(nape.Position and nape.Position.Y)
            local sy = toNumY(nape.Size and nape.Size.Y)
            return ny + sy * 0.5 + 8
        end
        local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if root and root:IsA("BasePart") then
            local ry = toNumY(root.Position and root.Position.Y)
            return ry + 25
        end
        local defPosY = defaultPart and pcall(function() return defaultPart.Position.Y end) and toNumY(defaultPart.Position.Y) or 0
        return defPosY + 15
    end

    local function v119_5(p1)
        local v2 = v89_2(p1) or p1 and p1:FindFirstChild("HumanoidRootPart")
        if not v2 then
            return nil
        end
        local topY = getTitanTopY(p1, v2)
        local v2PosY = toNumY(v2.Position and v2.Position.Y)
        local headOffset = math.max(0, topY - v2PosY)

        if v73_2() then
            local hoverHeight = headOffset + 35 + (v60_2 * 2)
            local hoverPos = v2.Position + Vector3.new(0, hoverHeight, 0)
            return CFrame.lookAt(hoverPos, v2.Position, Vector3.new(0, 0, -1))
        end
        local v3_8 = os.clock() * 8
        local v4_6 = 55 + v60_2
        local v6_7 = v3_8 + 0.2
        return CFrame.lookAt(v2.Position + Vector3.new(math.cos(v3_8) * 32, v4_6, math.sin(v3_8) * 32),
            v2.Position + Vector3.new(math.cos(v6_7) * 32, v4_6, math.sin(v6_7) * 32))
    end
    local function v120_4(p1)
        local v3 = math
        local v2 = v3.huge
        local v3_2 = -v3.huge
        for v7, v8 in ipairs(p1:GetDescendants()) do
            if v8:IsA("BasePart") then
                local v9_4 = v8.Position.Y + v8.Size.Y / 2
                local v10_4 = v8.Position.Y - v8.Size.Y / 2
                if v3_2 < v9_4 then
                    v3_2 = v9_4
                end
                if v10_4 < v2 then
                    v2 = v10_4
                end
            end
        end
        if v3_2 == -math.huge then
            return 0
        end
        return v3_2 - v2
    end
    v121_4 = function(p1)
        local v2 = v13_8:FindFirstChild("Titans")
        if not v2 then
            return nil
        end
        local v3_6 = nil
        local v4_2 = -math.huge
        for v8, v9 in ipairs(v2:GetChildren()) do
            if v9:IsA("Model") and v9 ~= p1 and v91_2(v9) then
                local v10_5 = v120_4(v9)
                if v10_5 > v4_2 then
                    v4_2 = v10_5
                    v3_6 = v9
                end
            end
        end
        return v3_6
    end
    v122_3 = function(p1)
        local v2 = v13_8:FindFirstChild("Titans")
        if not v2 then
            return nil
        end
        local v3_6 = {}
        for v7, v8 in ipairs(v2:GetChildren()) do
            local v9_2 = v8:IsA("Model") and v8 ~= p1 and v91_2(v8)
            if v9_2 then
                local v11_4 = v8:FindFirstChild("Hitboxes")
                if not v11_4 then
                    v9_2 = nil
                else
                    local v12_7 = v11_4:FindFirstChild("Hit")
                    if not v12_7 then
                        v9_2 = nil
                    else
                        v9_2 = v12_7:FindFirstChild("Nape")
                    end
                end
            end
            if v9_2 then
                table.insert(v3_6, v8)
            end
        end
        if #v3_6 == 0 then
            return nil
        end
        if #v3_6 == 1 then
            return v3_6[1]
        end
        local v4_9 = v3_6[1]
        local v5_7 = -1
        for v9_5, v10_4 in ipairs(v3_6) do
            local v13_4 = v10_4:FindFirstChild("Hitboxes")
            local v11_6
            if not v13_4 then
                v11_6 = nil
            else
                local v14_7 = v13_4:FindFirstChild("Hit")
                if not v14_7 then
                    v11_6 = nil
                else
                    v11_6 = v14_7:FindFirstChild("Nape")
                end
            end
            local v12_8 = v11_6 and v11_6.Position
            if v12_8 then
                local v13_11 = 0
                for v17_3, v18_2 in ipairs(v3_6) do
                    local v21_3 = v18_2:FindFirstChild("Hitboxes")
                    local v19_2
                    if not v21_3 then
                        v19_2 = nil
                    else
                        local v22_6 = v21_3:FindFirstChild("Hit")
                        if not v22_6 then
                            v19_2 = nil
                        else
                            v19_2 = v22_6:FindFirstChild("Nape")
                        end
                    end
                    if v19_2 and ((v19_2.Position - v12_8)).Magnitude <= 135 then
                        v13_11 = v13_11 + 1
                    end
                end
                if v5_7 < v13_11 then
                    v5_7 = v13_11
                    v4_9 = v10_4
                end
            end
        end
        return v4_9
    end
    local v126_2 = 0
    local function v124_3(p1)
        if not p1 or not p1.Parent then
            return false
        end
        local v2_4 = p1:FindFirstChild("Watch_Tower")
        if not v2_4 then
            return false
        end
        if v2_4:FindFirstChild("H") then
            return false
        end
        local v3_9 = p1:FindFirstChild("Circle")
        if not v3_9 then
            return false
        end
        local v4_7 = v3_9:FindFirstChild("Beam1")
        if not v4_7 or not v4_7:IsA("BasePart") then
            return false
        end
        return true
    end
    local function v125_3(p1)
        local v2 = p1 and p1:FindFirstChild("Circle")
        local v3_2 = v2 and v2:FindFirstChild("Hitbox")
        if v3_2 and v3_2:IsA("BasePart") then
            pcall(function()
                if not v150_10.OriginalSizes[v3_2] then
                    v150_10.OriginalSizes[v3_2] = v3_2.Size
                end
                v3_2.Size = Vector3.new(1984, 1984, 1984)
                return
            end)
        end
        return
    end
    v123_4 = function()
        for v4, v5 in ipairs(v13_8:GetChildren()) do
            if v5:IsA("Model") and v5.Name:find("WatchTower") then
                v125_3(v5)
                if v124_3(v5) then
                    return v5
                end
            end
        end
        local v1_3 = v13_8:FindFirstChild("Map") or v13_8:FindFirstChild("Unclimbable")
        if v1_3 then
            for v5_3, v6_9 in ipairs(v1_3:GetChildren()) do
                if v6_9:IsA("Model") and v6_9.Name:find("WatchTower") then
                    v125_3(v6_9)
                    if v124_3(v6_9) then
                        return v6_9
                    end
                end
            end
        end
        local v2_10 = os.clock()
        if 2 < v2_10 - v126_2 then
            v126_2 = v2_10
            local v3_12 = v13_8:FindFirstChild("Map")
            if v3_12 then
                for v7_11, v8_7 in ipairs(v3_12:GetDescendants()) do
                    if v8_7:IsA("Model") and v8_7.Name:find("WatchTower") then
                        v125_3(v8_7)
                        if v124_3(v8_7) then
                            return v8_7
                        end
                    end
                end
            end
        end
        return nil
    end
    local function v126_3(p1, p2, p3)
        if not p1 or not p3 then
            return
        end
        v55_2 = p3
        p1.CFrame = p3
        if v73_2() then
            if p2 then
                p2.PlatformStand = true
            end
            pcall(function()
                local v1 = p1
                local v3 = Vector3
                v1.AssemblyLinearVelocity = v3.zero
                v1.AssemblyAngularVelocity = v3.zero
                return
            end)
        else
            if p2 then
                p2.PlatformStand = false
                pcall(function()
                    p2:ChangeState(Enum.HumanoidStateType.Freefall)
                    return
                end)
            end
            pcall(function()
                local v1 = p1
                v1.AssemblyLinearVelocity = p3.LookVector * 160
                v1.AssemblyAngularVelocity = Vector3.zero
                return
            end)
        end
        return
    end
    v127_2 = function(p1)
        if not p1 or not v91_2(p1) then
            return
        end
        if v150_10.BreakingStreak or v53_2 or v61_2.IsUpgrading or v61_2.IsRetrievingSkillCrate or v48_3 and v52_2 then
            return
        end
        local v2_4 = v71_3()
        if not v2_4 then
            return
        end
        local v3_7 = v2_4:FindFirstChild("HumanoidRootPart")
        local v4_4 = v2_4:FindFirstChild("Humanoid")
        local v5_4 = v119_5(p1)
        if v3_7 and v5_4 then
            v126_3(v3_7, v4_4, v5_4)
        end
        return
    end
    v128_2 = function()
        if not (v18_4 or v48_3) then
            if v54_2 then
                v54_2:Disconnect()
                v54_2 = nil
            end
            v55_2 = nil
            local v2_9 = v71_3()
            local v3_2 = v2_9 and v2_9:FindFirstChild("Humanoid")
            if v3_2 then
                v3_2.PlatformStand = false
            end
            return
        end
        if v54_2 then
            return
        end
        v54_2 = v14_9.Heartbeat:Connect(function()
            if not (v18_4 or v48_3) then
                if v54_2 then
                    v54_2:Disconnect()
                    v54_2 = nil
                end
                v55_2 = nil
                local v2_9 = v71_3()
                local v3_2 = v2_9 and v2_9:FindFirstChild("Humanoid")
                if v3_2 then
                    v3_2.PlatformStand = false
                end
                return
            end
            if v150_10.BreakingStreak or v53_2 or v61_2.IsRetrievingSkillCrate then
                return
            end
            local v2_11 = v71_3()
            if not v2_11 then
                return
            end
            local v3_7 = v2_11:FindFirstChild("Humanoid")
            if not v3_7 or 0 >= v3_7.Health then
                return
            end
            local v4_6 = v2_11:FindFirstChild("HumanoidRootPart")
            if not v4_6 then
                return
            end
            if v61_2.IsUpgrading and v61_2.TargetCFrame then
                v126_3(v4_6, v3_7, v61_2.TargetCFrame)
                return
            end
            -- Setup attribute check removed so flight starts immediately without delay
            local v6_10 = v7_13 or v6_21.LocalPlayer
            local v7_6 = v6_10 and v6_10:FindFirstChild("PlayerGui")
            local v8_7 = v7_6 and v7_6:FindFirstChild("Fullscreen")
            local v9_4 = v8_7 and v8_7:FindFirstChild("Loading_Screen")
            if v9_4 and v9_4.Visible == true then
                return
            end
            local v10_4 = nil
            if v48_3 then
                if v52_2 and not v124_3(v52_2) then
                    v52_2 = nil
                end
                if not v52_2 then
                    v52_2 = v123_4()
                    if v52_2 then
                        v125_3(v52_2)
                    end
                end
                if v52_2 and v124_3(v52_2) then
                    local v12_11 = v52_2
                    v125_3(v12_11)
                    local v11_18 = v12_11:FindFirstChild("Circle")
                    local v12_10 = v11_18 and v11_18:FindFirstChild("Beam1")
                    if v12_10 and v12_10:IsA("BasePart") then
                        v10_4 = v12_10.CFrame + Vector3.new(0, 200, 0)
                    end
                end
            end
            local v11_5 = not v10_4 and v18_4 and not v35_2
            if v11_5 then
                v11_5 = not (v26_2 and v73_2())
            end
            if v11_5 then
                local raidBoss = v150_10.AutoRaid and v150_10.GetRaidBoss()
                if raidBoss then
                    v20_2 = raidBoss
                elseif not v20_2 or not v91_2(v20_2) then
                    v20_2 = v73_2() and v122_3() or v121_4()
                end
                if v20_2 and v91_2(v20_2) then
                    v10_4 = v119_5(v20_2)
                else
                    v10_4 = v55_2 or v4_6.CFrame
                end
            end
            if v10_4 then
                v126_3(v4_6, v3_7, v10_4)
            elseif not v18_4 and not v52_2 then
                v3_7.PlatformStand = false
            end
            return
        end)
        return
    end
    do
        local ALWAYS_SAFE_CATEGORIES = {
            Attacks = true,
            Hitboxes = true,
            Spears = true,
            Blades = true,
            S_Rewards = true,
            S_Equipment = true,
            S_Data = true,
            Data = true,
            Slots = true,
            Slot = true,
            Main_Menu = true,
            MainMenu = true,
            Menu = true,
            Title = true,
            Teleport = true,
            Family = true,
            Skills = true,
            Upgrades = true,
            ODMG = true,
            Shift = true,
            Waves = true,
            Cutscene = true,
            Dialogue = true,
            Shop = true,
            Customisation = true,
            Interact = true,
            Inventory = true,
            Profile = true,
            Party = true,
            Quest = true,
            Quests = true,
            Raid = true,
            Rewards = true,
            Titans = true,
            Carry = true,
            Emote = true,
            Chat = true,
            Codes = true,
            Market = true,
            Banners = true,
            Cosmetics = true,
            Titles = true,
            Achievements = true,
            Prestiges = true,
            Prestige = true,
            Progression = true,
            Missions = true,
            S_Missions = true,
            Mission = true,
            Lobby = true,
            S_Lobby = true,
            Memories = true,
            Memory = true,
            Battlepass = true,
            Leaderboard = true,
            Clans = true
        }
        local INSPECTED_SAFE_CATEGORIES = {
            Functions = true,
            Movement = true,
            Combat = true,
            Stats = true,
            Lobby = true,
            Mission = true,
            Settings = true
        }
        local SAFE_SUBACTIONS = {
            Retry = true,
            Finished = true,
            Teleport = true,
            Start = true,
            Join = true,
            Leave = true,
            Select = true,
            Equip = true,
            Unequip = true,
            Upgrade = true,
            Claim = true,
            Roll = true,
            Spin = true,
            Save = true,
            Load = true
        }
        local SUSPICIOUS_TOKENS = {
            "anticheat", "anti_cheat", "antiexploit", "cheat", "exploit",
            "shadowban", "violation", "tamper", "speedhack", "noclip",
            "hitbox", "kicklog", "banplayer", "flagplayer", "reportexploit",
            "sanity", "detected", "macro", "autoclick", "traceback",
            "memorycheck", " spoof"
        }
        local CORE_SCRIPT_WHITELIST = {
            actor = true,
            animate = true,
            playermodule = true,
            controlmodule = true,
            cameramodule = true,
            chat = true,
            rbxcharactersounds = true,
            health = true,
            sound = true
        }
        local function containsToken(str, tokens)
            if type(str) ~= "string" or str == "" then
                return false
            end
            local lower = string.lower(str)
            for _, tok in ipairs(tokens) do
                if string.find(lower, tok, 1, true) then
                    return true
                end
            end
            return false
        end
        local function valueContainsSuspiciousToken(val, depth)
            if (depth or 0) > 2 then
                return false
            end
            local t = type(val)
            if t == "string" then
                if containsToken(val, SUSPICIOUS_TOKENS) then
                    return true
                end
            elseif t == "table" then
                for k, v in pairs(val) do
                    if valueContainsSuspiciousToken(k, (depth or 0) + 1) or valueContainsSuspiciousToken(v, (depth or 0) + 1) then
                        return true
                    end
                end
            end
            return false
        end
        local function isAntiCheatName(name)
            if type(name) ~= "string" or name == "" then
                return false
            end
            local lower = string.lower(name)
            if CORE_SCRIPT_WHITELIST[lower] then
                return false
            end
            return containsToken(lower, {
                "anticheat", "anti_cheat", "antiexploit", "cheatdetect",
                "securitycheck", "tamper", "ac_client", "ac_check",
                "sanitycheck", "flagcheck", "telemetry"
            })
        end
        local function isSuspiciousRemoteCall(remote, arg1, arg2, arg3, arg4)
            if typeof(remote) ~= "Instance" then
                return false
            end
            local rName = remote.Name
            if remote == v68_2 or remote == v69_2 or rName == "POST" or rName == "GET" then
                if type(arg1) == "string" then
                    if ALWAYS_SAFE_CATEGORIES[arg1] then
                        return false
                    end
                    if INSPECTED_SAFE_CATEGORIES[arg1] then
                        if type(arg2) == "string" and SAFE_SUBACTIONS[arg2] and type(arg3) ~= "table" and type(arg4) ~= "table" then
                            if not valueContainsSuspiciousToken(arg3, 0) and not valueContainsSuspiciousToken(arg4, 0) then
                                return false
                            end
                        end
                        if valueContainsSuspiciousToken(arg2, 0)
                            or valueContainsSuspiciousToken(arg3, 0)
                            or valueContainsSuspiciousToken(arg4, 0)
                        then
                            return true
                        end
                        return false
                    end
                    if valueContainsSuspiciousToken(arg1, 0)
                        or valueContainsSuspiciousToken(arg2, 0)
                        or valueContainsSuspiciousToken(arg3, 0)
                        or valueContainsSuspiciousToken(arg4, 0)
                    then
                        return true
                    end
                end
                return false
            end
            if containsToken(rName, SUSPICIOUS_TOKENS) then
                return true
            end
            if valueContainsSuspiciousToken(arg1, 0)
                or valueContainsSuspiciousToken(arg2, 0)
                or valueContainsSuspiciousToken(arg3, 0)
            then
                return true
            end
            return false
        end

        function v150_10.InstallHooks()
            if v150_10.HooksInstalled then
                return true
            end
            if not (v150_10.Caps.hookmetamethod and v150_10.Caps.getnamecallmethod and v150_10.Caps.checkcaller) then
                return false
            end
            local wrapC = type(newcclosure) == "function" and newcclosure or function(fn) return fn end
            local ok = pcall(function()
                local origNamecall
                origNamecall = hookmetamethod(game, "__namecall", wrapC(function(self, ...)
                    if checkcaller() then
                        return origNamecall(self, ...)
                    end
                    local method = getnamecallmethod()
                    if (method == "Kick" or method == "kick") and self == v7_13 then
                        v150_10.BlockedKicks = v150_10.BlockedKicks + 1
                        return nil
                    end
                    if method == "FireServer" or method == "InvokeServer" or method == "fireServer" or method == "invokeServer" then
                        local a1, a2, a3, a4 = ...
                        local okCheck, shouldBlock = pcall(isSuspiciousRemoteCall, self, a1, a2, a3, a4)
                        if okCheck and shouldBlock then
                            v150_10.BlockedRemotes = v150_10.BlockedRemotes + 1
                            return nil
                        end
                    end
                    return origNamecall(self, ...)
                end))

                local origIndex
                origIndex = hookmetamethod(game, "__index", wrapC(function(self, key)
                    if checkcaller() then
                        return origIndex(self, key)
                    end
                    if key == "Size" then
                        local origSize = v150_10.OriginalSizes[self]
                        if origSize ~= nil then
                            return origSize
                        end
                    elseif key == "CanTouch" then
                        if v150_10.OriginalSizes[self] ~= nil then
                            return true
                        end
                    elseif key == "CollisionGroup" then
                        if v150_10.OriginalSizes[self] ~= nil then
                            return "Default"
                        end
                    elseif key == "CanCollide" and v19_3 then
                        local okCol, isCharPart = pcall(function()
                            local char = v7_13 and v7_13.Character
                            return char ~= nil and typeof(self) == "Instance" and self:IsDescendantOf(char)
                        end)
                        if okCol and isCharPart then
                            return true
                        end
                    elseif key == "PlatformStand" and (v18_4 or v48_3) then
                        local okPs, isHum = pcall(function()
                            local char = v7_13 and v7_13.Character
                            return char ~= nil and typeof(self) == "Instance" and self == char:FindFirstChild("Humanoid")
                        end)
                        if okPs and isHum then
                            return false
                        end
                    elseif (key == "AssemblyLinearVelocity" or key == "Velocity") and v18_4 then
                        local okVel, isHrp = pcall(function()
                            local char = v7_13 and v7_13.Character
                            return char ~= nil and typeof(self) == "Instance" and
                                self == char:FindFirstChild("HumanoidRootPart")
                        end)
                        if okVel and isHrp then
                            local realVel = origIndex(self, key)
                            if typeof(realVel) == "Vector3" and realVel.Magnitude > 80 then
                                return realVel.Unit * 80
                            end
                            return realVel
                        end
                    end
                    return origIndex(self, key)
                end))

                if v150_10.Caps.hookfunction and v7_13 and type(v7_13.Kick) == "function" then
                    pcall(function()
                        local origKick
                        origKick = hookfunction(v7_13.Kick, wrapC(function(self, ...)
                            if not checkcaller() and self == v7_13 then
                                v150_10.BlockedKicks = v150_10.BlockedKicks + 1
                                return nil
                            end
                            return origKick(self, ...)
                        end))
                    end)
                end
            end)
            if ok then
                v150_10.HooksInstalled = true
            end
            return ok
        end

        function v150_10.IsolateLocalAntiCheat()
            local isolated = 0
            local silenced = 0
            pcall(function()
                local containers = {
                    v7_13 and v7_13:FindFirstChild("PlayerScripts"),
                    v7_13 and v7_13:FindFirstChild("PlayerGui"),
                    v7_13 and v7_13.Character
                }
                for _, root in ipairs(containers) do
                    if root then
                        for _, inst in ipairs(root:GetDescendants()) do
                            if inst:IsA("LocalScript") and isAntiCheatName(inst.Name) and not inst.Disabled then
                                inst.Disabled = true
                                isolated = isolated + 1
                            end
                        end
                    end
                end
                if type(getconnections) == "function" and v7_13 and v7_13.Character then
                    local char = v7_13.Character
                    local hum = char:FindFirstChild("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local signals = {}
                    if hum then
                        table.insert(signals, hum:GetPropertyChangedSignal("WalkSpeed"))
                        table.insert(signals, hum:GetPropertyChangedSignal("JumpPower"))
                        table.insert(signals, hum:GetPropertyChangedSignal("PlatformStand"))
                        if hum.StateChanged then
                            table.insert(signals, hum.StateChanged)
                        end
                    end
                    if hrp then
                        table.insert(signals, hrp:GetPropertyChangedSignal("CFrame"))
                        table.insert(signals, hrp:GetPropertyChangedSignal("Size"))
                        table.insert(signals, hrp:GetPropertyChangedSignal("Velocity"))
                        table.insert(signals, hrp:GetPropertyChangedSignal("AssemblyLinearVelocity"))
                    end
                    for _, sig in ipairs(signals) do
                        for _, conn in ipairs(getconnections(sig)) do
                            if conn.Function and type(getfenv) == "function" then
                                local okEnv, env = pcall(getfenv, conn.Function)
                                local src = okEnv and type(env) == "table" and rawget(env, "script")
                                if typeof(src) == "Instance" and isAntiCheatName(src.Name) then
                                    pcall(function() conn:Disable() end)
                                    isolated = isolated + 1
                                    silenced = silenced + 1
                                end
                            end
                        end
                    end
                end
            end)
            if isolated > 0 then
                v150_10.IsolatedScripts = v150_10.IsolatedScripts + isolated
            end
            if silenced > 0 then
                v150_10.SilencedConnections = (v150_10.SilencedConnections or 0) + silenced
            end
            return isolated
        end

        local gasLoopRunning = false
        local function pulseMobileGasButton()
            local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
            local iface = pgui and pgui:FindFirstChild("Interface")
            if not iface then
                return
            end
            for _, rootName in ipairs({ "Mobile", "HUD" }) do
                local root = iface:FindFirstChild(rootName)
                if root then
                    for _, obj in ipairs(root:GetDescendants()) do
                        if obj:IsA("GuiButton") and obj.Visible then
                            local lname = string.lower(obj.Name)
                            if lname == "gas" or lname == "boost" or lname == "odmg_boost" then
                                if type(firesignal) == "function" then
                                    pcall(function() firesignal(obj.MouseButton1Down) end)
                                    pcall(function() firesignal(obj.Activated) end)
                                    task.delay(0.25, function()
                                        pcall(function() firesignal(obj.MouseButton1Up) end)
                                    end)
                                end
                                return
                            end
                        end
                    end
                end
            end
        end

        function v150_10.StopAutoGas()
            gasLoopRunning = false
            pcall(function()
                v17_6:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end

        function v150_10.StartAutoGas()
            if gasLoopRunning then
                return
            end
            gasLoopRunning = true
            task.spawn(function()
                while v18_4 and gasLoopRunning do
                    if v13_8:FindFirstChild("Titans") ~= nil and v87_2() then
                        pcall(function()
                            v17_6:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        end)
                        pcall(pulseMobileGasButton)
                        task.wait(0.25)
                        pcall(function()
                            v17_6:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                    end
                    task.wait(0.55)
                end
                gasLoopRunning = false
                pcall(function()
                    v17_6:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end)
        end

        local lastGcScan = -100
        local lastResetAttempt = -100
        local streakNotified = false
        local streakResetting = false

        local function isLobbyPlace()
            return game.PlaceId == 14916516914 or game.PlaceId == 13379208636
        end

        local function readNumericField(tbl, keys)
            if type(tbl) ~= "table" then
                return nil
            end
            for _, k in ipairs(keys) do
                local v = rawget(tbl, k)
                if type(v) == "number" then
                    return v
                end
            end
            return nil
        end

        local function parseHudNumber(text)
            if type(text) ~= "string" or text == "" or text:find("/", 1, true) then
                return nil
            end
            local num = tonumber((text:gsub(",", "")):match("(%d+)"))
            return num
        end

        function v150_10.GetKillStreak()
            local best = 0
            local function bump(val)
                if type(val) == "number" and val > best then
                    best = val
                end
            end

            pcall(function()
                local char = v71_3()
                for _, src in ipairs({ v7_13, char }) do
                    if src then
                        for _, attr in ipairs({ "Streak", "KillStreak", "Kill_Streak", "TitansStreak" }) do
                            bump(tonumber(src:GetAttribute(attr)))
                        end
                    end
                end
                local ls = v7_13 and v7_13:FindFirstChild("leaderstats")
                if ls then
                    for _, cname in ipairs({ "Streak", "KillStreak", "Kill Streak" }) do
                        local st = ls:FindFirstChild(cname)
                        if st and st.Value ~= nil then
                            bump(tonumber(st.Value))
                        end
                    end
                end
            end)

            pcall(function()
                local host = _G.__CachedCustHost or _G.__CachedHost
                if type(host) ~= "table" and type(getgc) == "function" and os.clock() - lastGcScan >= 12 then
                    lastGcScan = os.clock()
                    for _, obj in ipairs(getgc(true)) do
                        if type(obj) == "table" and type(rawget(obj, "Cache")) == "table" and type(rawget(obj, "Modules")) == "table" then
                            host = obj
                            _G.__CachedHost = obj
                            break
                        end
                    end
                end
                if type(host) == "table" then
                    local data, slot = nil, nil
                    local mods = rawget(host, "Modules")
                    local upd = type(mods) == "table" and rawget(mods, "Update")
                    if type(upd) == "table" and type(upd.Get_Data) == "function" then
                        local okD, d, s = pcall(upd.Get_Data, host, true)
                        if okD then
                            data, slot = d, s
                        end
                    end
                    if not data and type(rawget(host, "Cache")) == "table" then
                        data = rawget(host.Cache, "Data")
                    end
                    if not slot and type(data) == "table" and type(data.Slots) == "table" and data.Current_Slot then
                        slot = data.Slots[data.Current_Slot]
                    end
                    local streakKeys = { "Streak", "Kill_Streak", "KillStreak" }
                    bump(readNumericField(data, streakKeys))
                    bump(readNumericField(slot, streakKeys))
                    if type(slot) == "table" then
                        bump(readNumericField(rawget(slot, "Stats"), streakKeys))
                        bump(readNumericField(rawget(slot, "Records"), streakKeys))
                    end
                end
            end)

            pcall(function()
                local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                local iface = pgui and pgui:FindFirstChild("Interface")
                local hud = iface and iface:FindFirstChild("HUD")
                if not hud then
                    return
                end
                for _, obj in ipairs(hud:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Visible ~= false then
                        local lname = string.lower(obj.Name)
                        local pname = obj.Parent and string.lower(obj.Parent.Name) or ""
                        local ltext = string.lower(obj.Text or "")
                        local isIgnored = ltext:find("best", 1, true) or ltext:find("max", 1, true) or
                            ltext:find("high", 1, true) or pname:find("best", 1, true)
                        if not isIgnored then
                            if lname:find("streak", 1, true) or pname:find("streak", 1, true) or ltext:find("streak", 1, true) then
                                bump(parseHudNumber(obj.Text))
                            elseif (lname == "amount" and pname == "kills") or lname == "kills" or ltext:match("^kills%s*:") then
                                bump(parseHudNumber(obj.Text))
                            end
                        end
                    end
                end
            end)

            v150_10.CurrentKillStreak = best
            return best
        end

        function v150_10.PerformStreakReset()
            if streakResetting then
                return
            end
            streakResetting = true
            lastResetAttempt = os.clock()
            task.spawn(function()
                pcall(function()
                    local char = v71_3()
                    local hum = char and char:FindFirstChild("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not (char and hum and hum.Health > 0) then
                        return
                    end
                    v150_10.StopAutoGas()
                    v128_2()
                    v96_6(true)
                    local hb = char:FindFirstChild("Hitbox")
                    if hb and hb:IsA("BasePart") then
                        hb.CanTouch = true
                    end
                    hum.PlatformStand = false
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.Dead)
                    end)
                    hum.Health = 0
                    pcall(function()
                        char:BreakJoints()
                    end)
                    task.wait(0.3)
                    if v150_10.AutoResetStreak and v150_10.BreakingStreak and hum.Health > 0 and hrp then
                        local titan = v121_4()
                        local tPart = titan and
                            (titan.PrimaryPart or titan:FindFirstChild("HumanoidRootPart") or titan:FindFirstChildWhichIsA("BasePart"))
                        if tPart then
                            hrp.CFrame = tPart.CFrame * CFrame.new(0, 2, -5)
                        end
                    end
                end)
                streakResetting = false
            end)
        end

        function v150_10.CheckAutoResetStreak()
            if not v150_10.AutoResetStreak then
                v150_10.BreakingStreak = false
                streakNotified = false
                return false
            end
            local streak = v150_10.GetKillStreak()
            if isLobbyPlace() or streak <= v150_10.StreakThreshold then
                v150_10.BreakingStreak = false
                streakNotified = false
                return false
            end
            local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
            local iface = pgui and pgui:FindFirstChild("Interface")
            local rewards = iface and iface:FindFirstChild("Rewards")
            if rewards and rewards.Visible == true then
                return false
            end
            v150_10.BreakingStreak = true
            v150_10.StopAutoGas()
            if not streakNotified then
                streakNotified = true
                local isVi = v8_6("Language") == "Tiếng Việt"
                pcall(function()
                    v12_4:Notify({
                        Title = isVi and "Hủy Chuỗi Giết" or "Auto Reset Streak",
                        Content = isVi
                            and ("Chuỗi giết (" .. tostring(streak) .. ") vượt quá 1000 — đang tự hủy chuỗi để tránh bị quét!")
                            or ("Kill streak (" .. tostring(streak) .. ") exceeded 1000 — resetting streak to avoid scan!"),
                        Duration = 5
                    })
                end)
            end
            if os.clock() - lastResetAttempt >= 2 then
                v150_10.PerformStreakReset()
            end
            return true
        end

        v150_10.InstallHooks()
        v150_10.IsolateLocalAntiCheat()
        v7_13.CharacterAdded:Connect(function()
            task.delay(0.5, function()
                v150_10.IsolateLocalAntiCheat()
            end)
        end)
    end
    v13_8.DescendantAdded:Connect(function(p1)
        if not v48_3 then
            return
        end
        if p1:IsA("Model") and p1.Name:find("WatchTower") then
            task.delay(0.2, function()
                v125_3(p1)
                return
            end)
        elseif p1.Name == "Hitbox" and p1.Parent and p1.Parent.Name == "Circle" and p1.Parent.Parent and p1.Parent.Parent.Name:find("WatchTower") then
            pcall(function()
                if not v150_10.OriginalSizes[p1] then
                    v150_10.OriginalSizes[p1] = p1.Size
                end
                p1.Size = Vector3.new(1984, 1984, 1984)
                return
            end)
        end
        return
    end)
    v129_4 = nil
    local v130_3 = {}
    v50_2 = function()
        if not v49_2 then
            return
        end
        local v1_4 = v13_8:FindFirstChild("Unclimbable")
        if not v1_4 then
            return
        end
        local v2_5 = tick()
        for v6 in pairs(v130_3) do
            local v8 = not v6.Parent
            if not v8 then
                v8 = v2_5 > (v130_3[v6] or 0)
            end
            if v8 then
                v130_3[v6] = nil
            end
        end
        local v3_4 = {}
        for v7, v8_2 in ipairs(v1_4:GetChildren()) do
            if v8_2:IsA("Model") and v8_2.Name:find("ThunderSpear") then
                if not v130_3[v8_2] or v130_3[v8_2] < v2_5 then
                    table.insert(v3_4, v8_2)
                end
            end
        end
        if #v3_4 == 0 then
            return
        end
        local v4_7 = v7_13.Character
        local v5_7 = v4_7 and v4_7:FindFirstChild("HumanoidRootPart")
        if not v5_7 then
            return
        end
        v53_2 = true
        for v9_10, v10_7 in ipairs(v3_4) do
            if not v49_2 then
                break
            else
                v130_3[v10_7] = tick() + 4
                local v11_8 = v10_7:FindFirstChild("Hitbox") or v10_7:FindFirstChild("Hitbox", true)
                if v11_8 and v11_8:IsA("BasePart") then
                    pcall(function()
                        if not v150_10.OriginalSizes[v11_8] then
                            v150_10.OriginalSizes[v11_8] = v11_8.Size
                        end
                        v11_8.Size = Vector3.new(1984, 1984, 1984)
                        return
                    end)
                    v5_7.CFrame = v11_8.CFrame
                    pcall(function()
                        local v1 = v5_7
                        local v3 = Vector3
                        v1.AssemblyLinearVelocity = v3.zero
                        v1.AssemblyAngularVelocity = v3.zero
                        return
                    end)
                    task.wait(0.2)
                elseif v10_7.PrimaryPart then
                    v5_7.CFrame = v10_7.PrimaryPart.CFrame
                    task.wait(0.2)
                end
            end
        end
        if v49_2 then
            local v6_12 = v1_4:FindFirstChild("Supplies_Circle")
            if v6_12 then
                local v7_8 = v6_12:FindFirstChild("Hitbox") or v6_12:FindFirstChild("Hitbox", true)
                if v7_8 and v7_8:IsA("BasePart") then
                    pcall(function()
                        v7_8.Size = Vector3.new(1984, 1984, 1984)
                        return
                    end)
                    v5_7.CFrame = v7_8.CFrame
                    pcall(function()
                        local v1 = v5_7
                        local v3 = Vector3
                        v1.AssemblyLinearVelocity = v3.zero
                        v1.AssemblyAngularVelocity = v3.zero
                        return
                    end)
                    task.wait(0.2)
                elseif v6_12.PrimaryPart then
                    v5_7.CFrame = v6_12.PrimaryPart.CFrame
                    task.wait(0.2)
                end
            end
        end
        v53_2 = false
        return
    end
end
local function v51_2()
    if v129_4 then
        return
    end
    v129_4 = task.spawn(function()
        while true do
            if v49_2 then
                v50_2()
                task.wait(0.5)
            else
                v129_4 = nil
                return
            end
        end
    end)
    return
end
do
    local v131_2 = v13_8:FindFirstChild("Unclimbable")
    if v131_2 then
        if v131_2 then
            v131_2.ChildAdded:Connect(function(p1)
                if v49_2 and p1:IsA("Model") and p1.Name:find("ThunderSpear") then
                    task.delay(0.1, v50_2)
                end
                return
            end)
        end
    end
end
v13_8.ChildAdded:Connect(function(p1)
    if p1.Name == "Unclimbable" then
        if p1 then
            p1.ChildAdded:Connect(function(p1)
                if v49_2 and p1:IsA("Model") and p1.Name:find("ThunderSpear") then
                    task.delay(0.1, v50_2)
                end
                return
            end)
        end
    end
    return
end)
local v130_4, v63_9, v62_3, v148_4
do
    local function v129_5()
        local v1 = v7_13:FindFirstChild("PlayerGui") and v7_13.PlayerGui:FindFirstChild("Interface")
        if v1 then
            local v2_5 = v1:FindFirstChild("Upgrade")
            local v3_3 = v2_5 and v2_5:FindFirstChild("Gold") and v2_5.Gold:FindFirstChild("Title")
            if v3_3 and v3_3.Text and v3_3.Text ~= "" then
                local v5_4 = tonumber(v3_3.Text:gsub(",", ""):gsub("%s+", ""):gsub("%$", ""))
                if v5_4 then
                    return v5_4
                end
            end
            local v4_13 = v1:FindFirstChild("Equipment")
            local v5_9 = v4_13 and v4_13:FindFirstChild("Gold") and v4_13.Gold:FindFirstChild("Title")
            if v5_9 and v5_9.Text and v5_9.Text ~= "" then
                local v7_7 = tonumber(v5_9.Text:gsub(",", ""):gsub("%s+", ""):gsub("%$", ""))
                if v7_7 then
                    return v7_7
                end
            end
            local v6_18 = v1:FindFirstChild("HUD")
            local v7_12 = v6_18 and v6_18:FindFirstChild("Main") and v6_18.Main:FindFirstChild("Top")
            local v8_9 = v7_12 and
                (v7_12:FindFirstChild("2") and v7_12["2"]:FindFirstChild("Gold") or v7_12:FindFirstChild("Gold", true))
            local v9_7 = v8_9 and v8_9:FindFirstChild("Title")
            if v9_7 and v9_7.Text and v9_7.Text ~= "" then
                local v11_4 = tonumber(v9_7.Text:gsub(",", ""):gsub("%s+", ""):gsub("%$", ""))
                if v11_4 then
                    return v11_4
                end
            end
        end
        return 0
    end
    v130_4 = function()
        if not v61_2.AutoVoteReady then
            return
        end
        if not v68_2 then
            return
        end
        local v1_3 = v7_13:FindFirstChild("PlayerGui") and v7_13.PlayerGui:FindFirstChild("Interface")
        local v2_6 = v1_3 and v1_3:FindFirstChild("Waves")
        local v3_5 = v2_6 and v2_6:FindFirstChild("Inner")
        if v3_5 and v3_5.Visible and 0.5 > v3_5.GroupTransparency then
            if not v61_2.HasVotedReady then
                v61_2.HasVotedReady = true
                pcall(function()
                    v68_2:FireServer("Waves", "Update")
                    return
                end)
            end
        else
            v61_2.HasVotedReady = false
        end
        return
    end
    local function v131_6()
        local v1_3 = v13_8:FindFirstChild("Waves")
        local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
        local v3_3 = v2 and v2:FindFirstChild("Max")
        if not v3_3 then
            return false
        end
        if v3_3:GetAttribute("Cost") == 0 then
            return true
        end
        local v5_5 = v7_13:FindFirstChild("PlayerGui") and v7_13.PlayerGui:FindFirstChild("Interface")
        local v6_5 = v5_5 and v5_5:FindFirstChild("Upgrade")
        local v7_4 = v6_5 and v6_5:FindFirstChild("Main") and v6_5.Main:FindFirstChild("Upgrades") and
            v6_5.Main.Upgrades:FindFirstChild("Max") and v6_5.Main.Upgrades.Max:FindFirstChild("Max_Use")
        local v8_8 = v7_4 and v7_4:FindFirstChild("Title")
        return v8_8 and v8_8.Text:find("MAX") ~= nil or false
    end
    local function v132_6()
        local v1_3 = v13_8:FindFirstChild("Waves")
        local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
        local v3_3 = v2 and v2:FindFirstChild("Regen")
        if not v3_3 then
            return false
        end
        if v3_3:GetAttribute("Cost") == 0 then
            return true
        end
        local v5_5 = v7_13:FindFirstChild("PlayerGui") and v7_13.PlayerGui:FindFirstChild("Interface")
        local v6_5 = v5_5 and v5_5:FindFirstChild("Upgrade")
        local v7_4 = v6_5 and v6_5:FindFirstChild("Main") and v6_5.Main:FindFirstChild("Upgrades") and
            v6_5.Main.Upgrades:FindFirstChild("Regen") and v6_5.Main.Upgrades.Regen:FindFirstChild("Regen_Use")
        local v8_8 = v7_4 and v7_4:FindFirstChild("Title")
        return v8_8 and v8_8.Text:find("MAX") ~= nil or false
    end
    local function v133_4()
        local v1_3 = v13_8:FindFirstChild("Waves")
        local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
        local v3_3 = v2 and v2:FindFirstChild("Refills")
        if not v3_3 then
            return false
        end
        if v3_3:GetAttribute("Cost") == 0 then
            return true
        end
        local v5_5 = v7_13:FindFirstChild("PlayerGui") and v7_13.PlayerGui:FindFirstChild("Interface")
        local v6_5 = v5_5 and v5_5:FindFirstChild("Upgrade")
        local v7_4 = v6_5 and v6_5:FindFirstChild("Main") and v6_5.Main:FindFirstChild("Upgrades") and
            v6_5.Main.Upgrades:FindFirstChild("Refills") and v6_5.Main.Upgrades.Refills:FindFirstChild("Refills_Use")
        local v8_8 = v7_4 and v7_4:FindFirstChild("Title")
        return v8_8 and v8_8.Text:find("MAX") ~= nil or false
    end
    local v134_3 = {
        [1] = 500,
        [2] = 1250,
        [3] = 2000,
        [4] = 3000,
        [5] = 5000,
        [6] = 7500,
        [7] = 11000,
        [8] = 17500,
        [9] = 25000,
        [10] = 37500,
        [11] = 50000,
        [12] = 70000,
        [13] = 100000,
        [14] = 135000,
        [15] = 169420
    }
    local v135_scanning = false
    local v135_lastScan = 0
    if tonumber(v8_6("CachedWeaponMinLevel")) and (tonumber(v61_2.CachedWeaponMinLevel) or 0) == 0 then
        v61_2.CachedWeaponMinLevel = tonumber(v8_6("CachedWeaponMinLevel")) or 0
    end
    local function v135_3()
        local lpAttr = v7_13 and v7_13:GetAttribute("WeaponMinLevel")
        if type(lpAttr) == "number" and 0 <= lpAttr and 15 >= lpAttr then
            v61_2.CachedWeaponMinLevel = math.max(v61_2.CachedWeaponMinLevel or 0, lpAttr)
            v16_9["CachedWeaponMinLevel"] = v61_2.CachedWeaponMinLevel
        end
        local now = os.clock()
        if not v135_scanning and (now - v135_lastScan) > 3.5 then
            v135_scanning = true
            v135_lastScan = now
            task.spawn(function()
                pcall(function()
                    -- Direct Main Thread GC Scan First (Works on Mobile and PC without Actor)
                    if type(getgc) == "function" then
                        local foundData = nil
                        for _, v in ipairs(getgc(true)) do
                            if type(v) == "table" and rawget(v, "Currency") and rawget(v, "Progression") and rawget(v, "Upgrades") then
                                if type(v.Currency) == "table" and type(v.Currency.Gold) == "number" then
                                    foundData = v
                                    break
                                end
                            end
                        end
                        if foundData and foundData.Upgrades then
                            local w = foundData.Weapon or (v73_2() and "Spears" or "Blades")
                            local upgs = foundData.Upgrades[w]
                            if type(upgs) == "table" then
                                local minLvl = 999
                                for _, lvl in pairs(upgs) do
                                    if type(lvl) == "number" and lvl < minLvl then
                                        minLvl = lvl
                                    end
                                end
                                if minLvl < 999 then
                                    v61_2.CachedWeaponMinLevel = math.max(v61_2.CachedWeaponMinLevel or 0, minLvl)
                                    v16_9["CachedWeaponMinLevel"] = v61_2.CachedWeaponMinLevel
                                    if v7_13 then
                                        pcall(function() v7_13:SetAttribute("WeaponMinLevel", v61_2.CachedWeaponMinLevel) end)
                                    end
                                end
                            end
                            if type(foundData.Progression) == "table" then
                                local pLv = tonumber(foundData.Progression.Level)
                                if pLv and pLv >= 1 and pLv <= 225 then
                                    v156_4.Player.Level = pLv
                                    if v7_13 then pcall(function() v7_13:SetAttribute("Level", pLv) end) end
                                end
                                local pPr = tonumber(foundData.Progression.Prestige)
                                if pPr and pPr >= 0 and pPr <= 5 then
                                    v156_4.Player.Prestige = pPr
                                    if v7_13 then pcall(function() v7_13:SetAttribute("Prestige", pPr) end) end
                                end
                            end
                            if type(foundData.Currency) == "table" and tonumber(foundData.Currency.Gold) then
                                v156_4.Player.Gold = tonumber(foundData.Currency.Gold)
                            end
                        end
                    end

                    local v1_2 = v71_3()
                    local v2 = v1_2 and v1_2:FindFirstChild("Actor") or v66 and v66()[1]
                    if v2 and v67_2 then
                        v67_2(v2,
                            "                local foundData = nil\n                for _, v in ipairs(getgc(true)) do\n                    if type(v) == \"table\" and rawget(v, \"Currency\") and rawget(v, \"Progression\") and rawget(v, \"Upgrades\") then\n                        if type(v.Currency) == \"table\" and type(v.Currency.Gold) == \"number\" then\n                            foundData = v\n                            break\n                        end\n                    end\n                end\n                local minLvl = 999\n                if foundData and foundData.Upgrades then\n                    local w = foundData.Weapon or \"Blades\"\n                    local upgs = foundData.Upgrades[w]\n                    if type(upgs) == \"table\" then\n                        for _, lvl in pairs(upgs) do\n                            if type(lvl) == \"number\" and lvl < minLvl then\n                                minLvl = lvl\n                            end\n                        end\n                    end\n                end\n                local resolvedMin = minLvl < 999 and minLvl or 0\n                local lp = game:GetService(\"Players\").LocalPlayer\n                if lp then\n                    lp:SetAttribute(\"WeaponMinLevel\", resolvedMin)\n                    if foundData and type(foundData.Currency) == \"table\" and type(foundData.Currency.Gold) == \"number\" then\n                        lp:SetAttribute(\"Symbiote_Gold\", foundData.Currency.Gold)\n                    end\n                    if foundData and type(foundData.Progression) == \"table\" then\n                        if type(foundData.Progression.Level) == \"number\" and foundData.Progression.Level <= 225 then\n                            lp:SetAttribute(\"Symbiote_Level\", foundData.Progression.Level)\n                        end\n                        if type(foundData.Progression.Prestige) == \"number\" and foundData.Progression.Prestige <= 5 then\n                            lp:SetAttribute(\"Symbiote_Prestige\", foundData.Progression.Prestige)\n                        end\n                    end\n                end\n                local chars = workspace:FindFirstChild(\"Characters\")\n                local c = (chars and lp and chars:FindFirstChild(lp.Name)) or (lp and lp.Character)\n                local myAct = c and c:FindFirstChild(\"Actor\")\n                if myAct then\n                    myAct:SetAttribute(\"WeaponMinLevel\", resolvedMin)\n                end\n            ")
                        local v3_7 = (v7_13 and v7_13:GetAttribute("WeaponMinLevel")) or
                            v2:GetAttribute("WeaponMinLevel")
                        if type(v3_7) == "number" and 0 <= v3_7 and 15 >= v3_7 then
                            v61_2.CachedWeaponMinLevel = v3_7
                            v16_9["CachedWeaponMinLevel"] = v3_7
                        end
                    end
                end)
                v135_scanning = false
            end)
        end
        return v61_2.CachedWeaponMinLevel or 0
    end
    local function v136_17(p1)
        if type(p1) ~= "table" then
            return
        end
        local v3_3 = p1[v73_2() and "Spears" or "Blades"]
        if type(v3_3) == "table" then
            local v4_3 = 999
            for v8, v9 in pairs(v3_3) do
                if type(v9) == "number" and v4_3 > v9 then
                    v4_3 = v9
                end
            end
            if v4_3 < 999 then
                v61_2.CachedWeaponMinLevel = v4_3
                local v5_8 = v71_3()
                local v6_3 = v5_8 and v5_8:FindFirstChild("Actor") or v66 and v66()[1]
                if v6_3 then
                    pcall(function()
                        v6_3:SetAttribute("WeaponMinLevel", v4_3)
                        return
                    end)
                end
            end
        end
        return
    end
    local function v137_2()
        if 15 <= v135_3() then
            return true
        end
        local v2_3 = v7_13:FindFirstChild("PlayerGui") and v7_13.PlayerGui:FindFirstChild("Interface")
        local v3_4 = v2_3 and v2_3:FindFirstChild("Equipment")
        local v4_4 = v3_4 and v3_4:FindFirstChild("Stat") and v3_4.Stat:FindFirstChild("Cost") and
            v3_4.Stat.Cost:FindFirstChild("Title")
        if v4_4 and v4_4.Text and v4_4.Text:find("MAX") then
            return true
        end
        return false
    end
    local function v138_2()
        if v137_2() then
            return nil
        end
        local v1_4 = v7_13:FindFirstChild("PlayerGui") and v7_13.PlayerGui:FindFirstChild("Interface")
        local v2_4 = v1_4 and v1_4:FindFirstChild("Equipment")
        local v3_4 = v2_4 and v2_4:FindFirstChild("Stat") and v2_4.Stat:FindFirstChild("Cost") and
            v2_4.Stat.Cost:FindFirstChild("Title")
        if v3_4 and v3_4.Text and v3_4.Text ~= "" and not v3_4.Text:find("MAX") then
            local v5_12 = tonumber(v3_4.Text:gsub(",", ""):gsub("%s+", ""):gsub("%$", ""))
            if v5_12 and 0 < v5_12 then
                return v5_12
            end
        end
        local v4_14 = v135_3()
        if 15 <= v4_14 then
            return nil
        end
        local v5_15 = v134_3[v4_14 + 1]
        if not v5_15 then
            local v6_9 = v134_3
            v5_15 = v6_9[#v6_9]
        end
        return v5_15
    end
    local function v139_2(p1)
        local v2_3 = v13_8:FindFirstChild("Waves")
        local v3 = v2_3 and v2_3:FindFirstChild("Zones")
        local v4_3 = v3 and v3:FindFirstChild(p1)
        if v4_3 then
            local v5_4 = v4_3:FindFirstChild("Hitbox")
            if v5_4 and v5_4:IsA("BasePart") then
                v5_4.Size = Vector3.new(1984, 1984, 1984)
                v5_4.CanCollide = false
            end
        end
        return
    end
    local function v140_2(p1)
        local v2_3 = v13_8:FindFirstChild("Waves")
        if not v2_3 then
            return nil
        end
        local v3_5 = v2_3:FindFirstChild("Zones")
        local v4_2 = v3_5 and v3_5:FindFirstChild(p1)
        if v4_2 then
            local v5_4 = v4_2:FindFirstChild("Hitbox")
            if v5_4 and v5_4:IsA("BasePart") then
                return v5_4.CFrame + Vector3.new(0, 3, 0)
            end
            if v4_2.PrimaryPart then
                return v4_2.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
        local v5_6 = v2_3:FindFirstChild("NPCs")
        local v7_6 = v5_6 and v5_6:FindFirstChild(p1 == "Upgrade" and "Cole" or "Lulu")
        if v7_6 and v7_6.PrimaryPart then
            return v7_6.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        end
        local v8_11 = v2_3:FindFirstChild("Props")
        local v9_7 = v8_11 and v8_11:FindFirstChild(p1)
        if v9_7 and v9_7.PrimaryPart then
            return v9_7.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        end
        return nil
    end
    local function v141_2(p1, p2)
        v139_2(p1)
        local v3_3 = v140_2(p1)
        local v4_4 = v71_3()
        local v5 = v4_4 and v4_4:FindFirstChild("HumanoidRootPart")
        if v3_3 and v5 then
            local v6_3 = v61_2
            v6_3.IsUpgrading = true
            v6_3.TargetCFrame = v3_3
            v5.CFrame = v3_3
            task.wait(0.08)
        end
        local v6_5 = p2()
        local v7_5 = v61_2
        v7_5.IsUpgrading = false
        v7_5.TargetCFrame = nil
        return v6_5
    end
    local function v142_2()
        local v1_3 = v13_8:FindFirstChild("Waves")
        local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
        local v3_3 = v2 and v2:FindFirstChild("Max")
        if not v3_3 then
            return false
        end
        local v4_6 = v3_3:GetAttribute("Cost")
        if not v4_6 or 0 >= v4_6 then
            return false
        end
        if v131_6() then
            return false
        end
        if v129_5() < v4_6 then
            return false
        end
        if not v69_2 then
            return false
        end
        return v141_2("Upgrade", function()
            local v1_2, v2_2 = pcall(function()
                return v69_2:InvokeServer("Waves", "Upgrade", { "Max" })
            end)
            return v1_2 and v2_2 ~= false and v2_2 ~= nil
        end)
    end
    local function v143_2()
        local v1_3 = v13_8:FindFirstChild("Waves")
        local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
        local v3_3 = v2 and v2:FindFirstChild("Regen")
        if not v3_3 then
            return false
        end
        local v4_6 = v3_3:GetAttribute("Cost")
        if not v4_6 or 0 >= v4_6 then
            return false
        end
        if v132_6() then
            return false
        end
        if v4_6 > v129_5() then
            return false
        end
        if not v69_2 then
            return false
        end
        return v141_2("Upgrade", function()
            local v1_2, v2_2 = pcall(function()
                return v69_2:InvokeServer("Waves", "Upgrade", { "Regen" })
            end)
            return v1_2 and v2_2 ~= false and v2_2 ~= nil
        end)
    end
    local function v144_2()
        local v1_3 = v13_8:FindFirstChild("Waves")
        local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
        local v3_3 = v2 and v2:FindFirstChild("Refills")
        if not v3_3 then
            return false
        end
        local v4_6 = v3_3:GetAttribute("Cost")
        if not v4_6 or v4_6 <= 0 then
            return false
        end
        if v133_4() then
            return false
        end
        if v129_5() < v4_6 then
            return false
        end
        if not v69_2 then
            return false
        end
        return v141_2("Upgrade", function()
            local v1_2, v2_2 = pcall(function()
                return v69_2:InvokeServer("Waves", "Upgrade", { "Refills" })
            end)
            return v1_2 and v2_2 ~= false and v2_2 ~= nil
        end)
    end
    local function v145_2()
        if v137_2() then
            return false
        end
        local v1_5 = v138_2()
        if not v1_5 or v1_5 <= 0 then
            return false
        end
        if v129_5() < v1_5 then
            return false
        end
        if not v69_2 then
            return false
        end
        local v3_5
        if v73_2() then
            v3_5 = {
                "Crit_Damage",
                "TS_Damage",
                "Crit_Chance",
                "Blast_Radius",
                "TS_Speed",
                "TS_Gas",
                "TS_Control",
                "TS_Range"
            }
        else
            v3_5 = {
                "Crit_Damage",
                "ODM_Damage",
                "Crit_Chance",
                "Blade_Durability",
                "ODM_Speed",
                "ODM_Gas",
                "ODM_Control",
                "ODM_Range"
            }
        end
        return v141_2("Equipment", function()
            local v1_2, v2_2 = pcall(function()
                return v69_2:InvokeServer("Equipment", "Upgrade", v3_5)
            end)
            if v1_2 and type(v2_2) == "table" then
                v136_17(v2_2)
                return true
            end
            return v1_2 and v2_2 ~= nil and v2_2 ~= false
        end)
    end
    v150_10.UpgradeCostTable = v134_3
    v150_10.GetWeaponMinLevel = v135_3
    v150_10.UpgradeWeaponStep = v145_2
    v150_10.GetHudGold = v129_5
    v63_9 = function()
        if not v61_2.AutoGetRetrieveSkillCrate then
            return
        end
        if v61_2.IsRetrievingSkillCrate then
            return
        end
        if 2 > tick() - (v61_2.LastSkillCrateTimestamp or 0) then
            return
        end
        local v1_6 = v13_8:FindFirstChild("Waves")
        if not v1_6 then
            return
        end
        local v2_9 = v1_6:FindFirstChild("Crates")
        if not v2_9 then
            return
        end
        local v3_6 = v7_13 or v6_21.LocalPlayer
        if not v3_6 then
            return
        end
        local v4_6 = v2_9:FindFirstChild("Crate_" .. v3_6.Name)
        if not v4_6 or not v4_6:GetAttribute("Skill") then
            return
        end
        local v5_4 = v71_3()
        local v6_5 = v5_4 and v5_4:FindFirstChild("HumanoidRootPart")
        if not v6_5 then
            return
        end
        local v7_6 = v1_6:FindFirstChild("Props")
        local v8_3 = v7_6 and v7_6:FindFirstChild("Dropoff")
        local v9_3 = v8_3 and
            (v8_3:FindFirstChild("Bottom") or v8_3.PrimaryPart or v8_3:FindFirstChildWhichIsA("BasePart"))
        local v10_4 = v1_6:FindFirstChild("Zones")
        local v11_2 = v10_4 and v10_4:FindFirstChild("Skills")
        local v12_3 = v11_2 and v11_2:FindFirstChild("Hitbox")
        if not v9_3 or not v12_3 then
            return
        end
        if v12_3.Size.X > 50 then
            v12_3.Size = Vector3.new(22.5, 33, 24)
        end
        local v13_9 = v61_2
        v13_9.LastSkillCrateTimestamp = tick()
        v13_9.IsRetrievingSkillCrate = true
        if v4_6:GetAttribute("Occupied") ~= true then
            local v13_11 = v4_6:FindFirstChild("Hitbox") or v4_6:FindFirstChild("Box") or v4_6.PrimaryPart or
                v4_6:FindFirstChildWhichIsA("BasePart")
            if v13_11 and v13_11:IsA("BasePart") then
                v6_5.CFrame = v13_11.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.1)
            end
            if v4_6.Parent == v2_9 and v4_6:GetAttribute("Occupied") ~= true then
                v6_5.CFrame = v9_3.CFrame + Vector3.new(0, 4, 0)
                local v14_32 = 0
                while true do
                    if 0.3 > v14_32 and v4_6.Parent == v2_9 and v4_6:GetAttribute("Occupied") ~= true then
                        task.wait(0.05)
                        v14_32 = v14_32 + 0.05
                    else
                        break
                    end
                end
            end
        end
        if v4_6.Parent == v2_9 and v4_6:GetAttribute("Occupied") == true then
            v6_5.CFrame = v12_3.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.08)
            if v69_2 then
                pcall(function()
                    v69_2:InvokeServer("Equipment", "Crate")
                    return
                end)
            end
            task.wait(0.08)
        end
        local v14_21 = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        local v15_9 = v14_21 and v14_21:FindFirstChild("Utilities")
        local v16_7 = v15_9 and v15_9:FindFirstChild("Areas")
        if v16_7 then
            pcall(function()
                local v1_2 = require(v16_7)
                if v1_2 and v1_2.Open and (not v1_2.Selected or not v1_2.Selected.Object) then
                    v1_2.Open = false
                    v1_2.Selected = nil
                    if v1_2.Params and v1_2.Params.FilterDescendantsInstances then
                        for v5, v6 in pairs(v1_2.Params.FilterDescendantsInstances) do
                            v6.CanQuery = true
                        end
                    end
                end
                return
            end)
        end
        v61_2.IsRetrievingSkillCrate = false
        return
    end
    local function v146_2()
        local v2_3 = tick()
        local v4 = v61_2
        if v2_3 - v4.LastUpgradeTimestamp < v4.UpgradeDelay then
            return
        end
        local v1_2 = {}
        if v61_2.AutoUpgradeMaxHQHP then
            table.insert(v1_2, {
                Name = "Max",
                IsMaxed = v131_6,
                CanAfford = function()
                    local v1_3 = v13_8:FindFirstChild("Waves")
                    local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
                    local v3_3 = v2 and v2:FindFirstChild("Max")
                    local v4_3 = v3_3 and v3_3:GetAttribute("Cost")
                    return v4_3 and 0 < v4_3 and v129_5() >= v4_3
                end,
                TryUpgrade = v142_2
            })
        end
        if v61_2.AutoUpgradeHQHealthRegen then
            table.insert(v1_2, {
                Name = "Regen",
                IsMaxed = v132_6,
                CanAfford = function()
                    local v1_3 = v13_8:FindFirstChild("Waves")
                    local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
                    local v3_3 = v2 and v2:FindFirstChild("Regen")
                    local v4_3 = v3_3 and v3_3:GetAttribute("Cost")
                    return v4_3 and 0 < v4_3 and v129_5() >= v4_3
                end,
                TryUpgrade = v143_2
            })
        end
        if v61_2.AutoUpgradeRefillLimit then
            table.insert(v1_2, {
                Name = "Refills",
                IsMaxed = v133_4,
                CanAfford = function()
                    local v1_3 = v13_8:FindFirstChild("Waves")
                    local v2 = v1_3 and v1_3:FindFirstChild("Upgrades")
                    local v3_3 = v2 and v2:FindFirstChild("Refills")
                    local v4_3 = v3_3 and v3_3:GetAttribute("Cost")
                    return v4_3 and v4_3 > 0 and v129_5() >= v4_3
                end,
                TryUpgrade = v144_2
            })
        end
        if v61_2.AutoUpgradeWeapon then
            table.insert(v1_2, {
                Name = "Weapon",
                IsMaxed = v137_2,
                CanAfford = function()
                    local v1_2 = v138_2()
                    return v1_2 and 0 < v1_2 and v1_2 <= v129_5()
                end,
                TryUpgrade = v145_2
            })
        end
        if #v1_2 == 0 then
            return
        end
        if v61_2.UpgradeIndex > #v1_2 then
            v61_2.UpgradeIndex = 1
        end
        local v2_16 = #v1_2
        local v3_19 = false
        for v4_6 = 1, v2_16 do
            local v7 = v1_2[v61_2.UpgradeIndex]
            if v7 then
                if v7.IsMaxed() then
                    local v8_4 = v61_2
                    v8_4.UpgradeIndex = v8_4.UpgradeIndex % v2_16 + 1
                elseif v7.CanAfford() then
                    local v8_8 = v7.TryUpgrade()
                    local v9_3 = v61_2
                    v9_3.LastUpgradeTimestamp = tick()
                    v9_3.UpgradeIndex = v9_3.UpgradeIndex % v2_16 + 1
                    v3_19 = true
                    break
                else
                    local v8_9 = v61_2
                    v8_9.UpgradeIndex = v8_9.UpgradeIndex % v2_16 + 1
                end
            end
        end
        if not v3_19 then
            v61_2.LastUpgradeTimestamp = tick()
        end
        return
    end
    v62_3 = function()
        if v61_2.LoopRunning then
            return
        end
        v61_2.LoopRunning = true
        task.spawn(function()
            while true do
                if v61_2.LoopRunning then
                    task.wait(1)
                    pcall(function()
                        v130_4()
                        v63_9()
                        v146_2()
                        return
                    end)
                else
                    return
                end
            end
        end)
        return
    end
    task.spawn(function()
        local v1_3 = v7_13:WaitForChild("PlayerGui", 10)
        local v2 = v1_3 and v1_3:WaitForChild("Interface", 10)
        local v3_3 = v2 and v2:WaitForChild("Waves", 10)
        local v4_4 = v3_3 and v3_3:WaitForChild("Inner", 5)
        if v4_4 then
            v4_4:GetPropertyChangedSignal("Visible"):Connect(function()
                if v4_4.Visible and v61_2.AutoVoteReady then
                    task.spawn(v130_4)
                end
                return
            end)
        end
        local function v5_7(p1)
            if not p1 or p1:GetAttribute("__SymbioteCratesConnected") then
                return
            end
            p1:SetAttribute("__SymbioteCratesConnected", true)
            p1.ChildAdded:Connect(function(p1)
                local v2 = v7_13 or v6_21.LocalPlayer
                if v2 and p1.Name == "Crate_" .. v2.Name then
                    task.wait(0.1)
                    if v61_2.AutoGetRetrieveSkillCrate then
                        task.spawn(v63_9)
                    end
                end
                return
            end)
            return
        end
        local v6_5 = v13_8:FindFirstChild("Waves")
        if v6_5 then
            v5_7(v6_5:FindFirstChild("Crates"))
        end
        v13_8.ChildAdded:Connect(function(p1)
            if p1.Name == "Waves" then
                local v2_2 = p1:WaitForChild("Crates", 5)
                if v2_2 then
                    v5_7(v2_2)
                end
            end
            return
        end)
        return
    end)
    task.spawn(v62_3)
    v148_4 = function()
        v128_2()
        local v1_2 = true
        while v18_4 do
            if not v18_4 then
                break
            else
                if (v25_2 or v34_2) and not v26_2 then
                    if v73_2() and v75_2() then
                        v85_2()
                    else
                        local v2_13 = v25_2 and v77_2()
                        if v2_13 then
                            local v3_8, v4_8 = pcall(function()
                                local v1_2 = v72_2()
                                if not v1_2 then
                                    return false
                                end
                                local v2_3 = v1_2:FindFirstChild("LeftHand")
                                local v3_3 = v1_2:FindFirstChild("RightHand")
                                if v2_3 then
                                    local v4_4 = v2_3:FindFirstChild("Blade_1")
                                    if v4_4 and v4_4:GetAttribute("Broken") then
                                        return true
                                    end
                                end
                                if v3_3 then
                                    local v4_6 = v3_3:FindFirstChild("Blade_1")
                                    if v4_6 and v4_6:GetAttribute("Broken") then
                                        return true
                                    end
                                end
                                local v4_7 = false
                                for v8, v9 in ipairs(v1_2:GetDescendants()) do
                                    if v9:IsA("MeshPart") and v9.Name:sub(1, 5) == "Blade" then
                                        v4_7 = true
                                        if not v9:GetAttribute("Broken") and 0.9 > v9.Transparency then
                                            return false
                                        end
                                    end
                                end
                                return v4_7
                            end)
                            if v3_8 then
                                v2_13 = v4_8
                            else
                                v2_13 = false
                            end
                        end
                        if v2_13 then
                            v85_2()
                        end
                    end
                end
                if not v18_4 then
                    break
                else
                    if v34_2 and not v35_2 and v77_2() then
                        if v84_2() then
                            task.spawn(v86_2)
                            while v35_2 do
                                task.wait(0.2)
                            end
                        end
                    end
                    if not v18_4 then
                        break
                    elseif not v87_2() then
                        task.wait(0.1)
                    else
                        local raidBoss = v150_10.AutoRaid and v150_10.GetRaidBoss()
                        if raidBoss then
                            v20_2 = raidBoss
                        elseif not v20_2 or not v91_2(v20_2) then
                            v20_2 = v73_2() and v122_3() or v121_4()
                        end
                        if v59_2 then
                            local v2_31 = v88_2()
                            local v3_22 = {}
                            local v4_11 = nil
                            local v5_5 = v20_2 and v20_2.PrimaryPart and v20_2.PrimaryPart.Position
                            if raidBoss then
                                local bossNape = v89_2(raidBoss)
                                if bossNape then
                                    v4_11 = { nape = bossNape, titan = raidBoss }
                                end
                            else
                                for v9, v10 in ipairs(v2_31) do
                                    local v12 = v10
                                    local v11
                                    if not v12 or not v12.Parent then
                                        v11 = false
                                    else
                                        local v13_3 = v13_8:FindFirstChild("Titans")
                                        if not v13_3 then
                                            v11 = false
                                        elseif v12.Parent ~= v13_3 then
                                            v11 = false
                                        else
                                            v11 = not v90_2(v12)
                                        end
                                    end
                                    if v11 then
                                        local v13_7 = v10:FindFirstChild("Hitboxes")
                                        local v11_3
                                        if not v13_7 then
                                            v11_3 = nil
                                        else
                                            local v14_13 = v13_7:FindFirstChild("Hit")
                                            if not v14_13 then
                                                v11_3 = nil
                                            else
                                                v11_3 = v14_13:FindFirstChild("Nape")
                                            end
                                        end
                                        if v11_3 then
                                            if v10 == v20_2 then
                                                v4_11 = { nape = v11_3, titan = v10 }
                                            else
                                                local v12_6 = 0
                                                if v5_5 and v10.PrimaryPart then
                                                    v12_6 = ((v10.PrimaryPart.Position - v5_5)).Magnitude
                                                end
                                                table.insert(v3_22, { nape = v11_3, titan = v10, dist = v12_6 })
                                            end
                                        end
                                    end
                                end
                            end
                            table.sort(v3_22, function(p1, p2)
                                return p2.dist > p1.dist
                            end)
                            if not v4_11 and #v3_22 > 0 then
                                local v6_9 = table.remove(v3_22, 1)
                                v20_2 = v6_9.titan
                                v4_11 = v6_9
                            end
                            local v6_10 = {}
                            for v10_2, v11_2 in ipairs(v3_22) do
                                table.insert(v6_10, v11_2)
                            end
                            if v4_11 then
                                table.insert(v6_10, v4_11)
                            end
                            if #v6_10 == 0 then
                                v20_2 = nil
                                task.wait(0.2)
                            else
                                for v7_18 = 1, #v6_10, 8 do
                                    if not v87_2() or not v18_4 or not v59_2 then
                                        break
                                    else
                                        local v11_9 = v72_2()
                                        local v10_5
                                        if not v11_9 then
                                            v10_5 = false
                                        else
                                            local v12_10 = v11_9:FindFirstChild("LeftLowerArm")
                                            local v13_14 = v11_9:FindFirstChild("RightLowerArm")
                                            v10_5 = v12_10 and v12_10:FindFirstChild("Spears") ~= nil or
                                                v13_14 and v13_14:FindFirstChild("Spears") ~= nil or false
                                        end
                                        if v10_5 then
                                            if (v25_2 or v34_2) and not v26_2 and v75_2() then
                                                v85_2()
                                                if v75_2() then
                                                    break
                                                end
                                            end
                                        else
                                            local v10_10
                                            if v73_2() then
                                                v10_10 = false
                                            else
                                                local v11_16 = v72_2()
                                                if not v11_16 then
                                                    v10_10 = false
                                                else
                                                    local _brk1 = false
                                                    for v15_18, v16_10 in ipairs(v11_16:GetDescendants()) do
                                                        if v16_10:IsA("MeshPart") and v16_10.Name:sub(1, 5) == "Blade" then
                                                            v10_10 = true
                                                            _brk1 = true
                                                            break
                                                        end
                                                    end
                                                    if not _brk1 then
                                                        v10_10 = false
                                                    end
                                                end
                                            end
                                            if v10_10 then
                                                local v10_13 = v25_2 and not v26_2
                                                if v10_13 then
                                                    local v11_28, v12_24 = pcall(function()
                                                        local v1_2 = v72_2()
                                                        if not v1_2 then
                                                            return false
                                                        end
                                                        local v2_3 = v1_2:FindFirstChild("LeftHand")
                                                        local v3_3 = v1_2:FindFirstChild("RightHand")
                                                        if v2_3 then
                                                            local v4_4 = v2_3:FindFirstChild("Blade_1")
                                                            if v4_4 and v4_4:GetAttribute("Broken") then
                                                                return true
                                                            end
                                                        end
                                                        if v3_3 then
                                                            local v4_6 = v3_3:FindFirstChild("Blade_1")
                                                            if v4_6 and v4_6:GetAttribute("Broken") then
                                                                return true
                                                            end
                                                        end
                                                        local v4_7 = false
                                                        for v8, v9 in ipairs(v1_2:GetDescendants()) do
                                                            if v9:IsA("MeshPart") and v9.Name:sub(1, 5) == "Blade" then
                                                                v4_7 = true
                                                                if not v9:GetAttribute("Broken") and 0.9 > v9.Transparency then
                                                                    return false
                                                                end
                                                            end
                                                        end
                                                        return v4_7
                                                    end)
                                                    if v11_28 then
                                                        v10_13 = v12_24
                                                    else
                                                        v10_13 = false
                                                    end
                                                end
                                                if v10_13 then
                                                    v85_2()
                                                    local v11_34, v12_29 = pcall(function()
                                                        local v1_2 = v72_2()
                                                        if not v1_2 then
                                                            return false
                                                        end
                                                        local v2_3 = v1_2:FindFirstChild("LeftHand")
                                                        local v3_3 = v1_2:FindFirstChild("RightHand")
                                                        if v2_3 then
                                                            local v4_4 = v2_3:FindFirstChild("Blade_1")
                                                            if v4_4 and v4_4:GetAttribute("Broken") then
                                                                return true
                                                            end
                                                        end
                                                        if v3_3 then
                                                            local v4_6 = v3_3:FindFirstChild("Blade_1")
                                                            if v4_6 and v4_6:GetAttribute("Broken") then
                                                                return true
                                                            end
                                                        end
                                                        local v4_7 = false
                                                        for v8, v9 in ipairs(v1_2:GetDescendants()) do
                                                            if v9:IsA("MeshPart") and v9.Name:sub(1, 5) == "Blade" then
                                                                v4_7 = true
                                                                if not v9:GetAttribute("Broken") and 0.9 > v9.Transparency then
                                                                    return false
                                                                end
                                                            end
                                                        end
                                                        return v4_7
                                                    end)
                                                    local v10_27
                                                    if v11_34 then
                                                        v10_27 = v12_29
                                                    else
                                                        v10_27 = false
                                                    end
                                                    if v10_27 then
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                        local v10_19 = {}
                                        for v11_24 = v7_18, math.min(v7_18 + 8 - 1, #v6_10) do
                                            local v14_31 = v6_10[v11_24]
                                            local v15_23 = v14_31.titan and v91_2(v14_31.titan) and v14_31.nape and v14_31.nape.Parent
                                            if v15_23 then
                                                table.insert(v10_19, v14_31.titan)
                                            end
                                        end
                                        if #v10_19 ~= 0 then
                                            v127_2(v20_2)
                                            if v150_10.CheckMissionSafetyWait then
                                                v150_10.CheckMissionSafetyWait(v20_2)
                                            end
                                            local v12_32 = v72_2()
                                            local v11_38
                                            if not v12_32 then
                                                v11_38 = false
                                            else
                                                local v13_30 = v12_32:FindFirstChild("LeftLowerArm")
                                                local v14_35 = v12_32:FindFirstChild("RightLowerArm")
                                                v11_38 = v13_30 and v13_30:FindFirstChild("Spears") ~= nil or
                                                    v14_35 and v14_35:FindFirstChild("Spears") ~= nil or false
                                            end
                                            if v11_38 then
                                                if v93_2(v10_19) then
                                                    task.wait(v57_3 and #v6_10 >= v7_18 + 8 and math.max(v58_2, 0.35) or
                                                        0.35)
                                                else
                                                    task.wait(0.1)
                                                end
                                            elseif v97_6(v10_19) then
                                                task.wait(v57_3 and v7_18 + 8 <= #v6_10 and math.max(v58_2, 0.12) or 0.12)
                                            else
                                                task.wait(0.08)
                                            end
                                        end
                                    end
                                end
                                task.wait(0.1)
                            end
                        elseif not v20_2 or not v91_2(v20_2) then
                            task.wait(0.2)
                        elseif not v87_2() then
                            task.wait(0.1)
                        else
                            v127_2(v20_2)
                            if v150_10.CheckMissionSafetyWait then
                                v150_10.CheckMissionSafetyWait(v20_2)
                            end
                            if not v18_4 then
                                break
                            elseif v73_2() then
                                local v2_41 = raidBoss or v122_3(v20_2) or v20_2
                                local v4_14 = v2_41:FindFirstChild("Hitboxes")
                                local v3_36
                                if not v4_14 then
                                    v3_36 = nil
                                else
                                    local v5_10 = v4_14:FindFirstChild("Hit")
                                    if not v5_10 then
                                        v3_36 = nil
                                    else
                                        v3_36 = v5_10:FindFirstChild("Nape")
                                    end
                                end
                                if v3_36 and v87_2() then
                                    v93_2(v2_41)
                                end
                                local v4_23 = os.clock()
                                local v5_12 = v57_3 and math.max(v58_2, 0.45) or 0.5
                                while true do
                                    if v18_4 and not v59_2 and os.clock() - v4_23 < v5_12 then
                                        task.wait(0.04)
                                        local v7_31 = v2_41 and v91_2(v2_41)
                                        if not v7_31 then
                                            break
                                        end
                                    else
                                        break
                                    end
                                end
                                if not v18_4 then
                                    break
                                else
                                    local v7_36 = v2_41 and v91_2(v2_41)
                                    if not v7_36 then
                                        if v2_41 == v20_2 then
                                            v20_2 = nil
                                        end
                                        if v57_3 and not v1_2 then
                                            task.wait(v58_2)
                                        end
                                        v1_2 = false
                                    end
                                end
                            else
                                local v2_43 = raidBoss or v121_4(v20_2) or v20_2
                                while true do
                                    if v18_4 and not v59_2 then
                                        task.wait(0.06)
                                        if not v18_4 then
                                            break
                                        else
                                            local v3_40 = v25_2 and not v26_2
                                            if v3_40 then
                                                local v4_30, v5_17 = pcall(function()
                                                    local v1_2 = v72_2()
                                                    if not v1_2 then
                                                        return false
                                                    end
                                                    local v2_3 = v1_2:FindFirstChild("LeftHand")
                                                    local v3_3 = v1_2:FindFirstChild("RightHand")
                                                    if v2_3 then
                                                        local v4_4 = v2_3:FindFirstChild("Blade_1")
                                                        if v4_4 and v4_4:GetAttribute("Broken") then
                                                            return true
                                                        end
                                                    end
                                                    if v3_3 then
                                                        local v4_6 = v3_3:FindFirstChild("Blade_1")
                                                        if v4_6 and v4_6:GetAttribute("Broken") then
                                                            return true
                                                        end
                                                    end
                                                    local v4_7 = false
                                                    for v8, v9 in ipairs(v1_2:GetDescendants()) do
                                                        if v9:IsA("MeshPart") and v9.Name:sub(1, 5) == "Blade" then
                                                            v4_7 = true
                                                            if not v9:GetAttribute("Broken") and 0.9 > v9.Transparency then
                                                                return false
                                                            end
                                                        end
                                                    end
                                                    return v4_7
                                                end)
                                                if v4_30 then
                                                    v3_40 = v5_17
                                                else
                                                    v3_40 = false
                                                end
                                            end
                                            if v3_40 then
                                                v85_2()
                                            end
                                            local v3_42 = v34_2 and not v35_2
                                            if v3_42 then
                                                if v73_2() then
                                                    v3_42 = false
                                                else
                                                    local v4_37 = v72_2()
                                                    if not v4_37 then
                                                        v3_42 = false
                                                    else
                                                        local _brk3 = false
                                                        for v8_26, v9_15 in ipairs(v4_37:GetDescendants()) do
                                                            if v9_15:IsA("MeshPart") and v9_15.Name:sub(1, 5) == "Blade" then
                                                                v3_42 = true
                                                                _brk3 = true
                                                                break
                                                            end
                                                        end
                                                        if not _brk3 then
                                                            v3_42 = false
                                                        end
                                                    end
                                                end
                                            end
                                            if v3_42 then
                                                v3_42 = v84_2()
                                            end
                                            if v3_42 then
                                                task.spawn(v86_2)
                                                while v35_2 do
                                                    task.wait(0.2)
                                                end
                                            end
                                            if not v18_4 then
                                                break
                                            elseif not v87_2() then
                                            else
                                                local v5_27 = v20_2
                                                local v4_45 = v5_27 and v91_2(v5_27)
                                                if not v4_45 then
                                                    v20_2 = raidBoss or v121_4(v20_2)
                                                    if not v20_2 then
                                                        break
                                                    end
                                                end
                                                local v3_51 = not v2_43
                                                if not v3_51 then
                                                    local v5_30 = v2_43
                                                    local v4_50 = v5_30 and v91_2(v5_30)
                                                    v3_51 = not v4_50
                                                end
                                                if v3_51 then
                                                    if v57_3 and not v1_2 then
                                                        task.wait(v58_2)
                                                    end
                                                    v1_2 = false
                                                    v2_43 = raidBoss or v121_4(v20_2) or v20_2
                                                elseif not raidBoss and v2_43 == v20_2 then
                                                    local v3_54 = v121_4(v20_2)
                                                    if v3_54 then
                                                        v2_43 = v3_54
                                                    end
                                                end
                                                local v3_59 = not v2_43
                                                if not v3_59 then
                                                    local v5_31 = v2_43
                                                    local v4_55 = v5_31 and v91_2(v5_31)
                                                    v3_59 = not v4_55
                                                end
                                                if v3_59 then
                                                    break
                                                else
                                                    local v3_60 = v89_2(v2_43)
                                                    if v3_60 and v87_2() then
                                                        pcall(function()
                                                            v97_6(v2_43)
                                                            return
                                                        end)
                                                        local v4_60 = os.clock()
                                                        while true do
                                                            if v18_4 and not v59_2 and 0.22 > os.clock() - v4_60 then
                                                                task.wait(0.03)
                                                                local v7_75 = v2_43
                                                                local v6_54 = v7_75 and v91_2(v7_75)
                                                                if not v6_54 then
                                                                    break
                                                                end
                                                            else
                                                                break
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    else
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        v96_6(true)
        local v2_5 = v71_3()
        local v3_2 = v2_5 and v2_5:FindFirstChild("Hitbox")
        if v3_2 and v3_2:IsA("BasePart") then
            v3_2.CanTouch = true
        end
        v128_2()
        v20_2 = nil
        return
    end
end
task.spawn(function()
    while true do
        repeat
            task.wait(0.2)
            if not v25_2 then
                break
            end
            if v18_4 then
            elseif v26_2 or v35_2 then
            elseif v73_2() then
                if v75_2() then
                    v85_2()
                end
            elseif v77_2() then
                local v2_4, v3_2 = pcall(function()
                    local v1_2 = v72_2()
                    if not v1_2 then
                        return false
                    end
                    local v2_3 = v1_2:FindFirstChild("LeftHand")
                    local v3_3 = v1_2:FindFirstChild("RightHand")
                    if v2_3 then
                        local v4_4 = v2_3:FindFirstChild("Blade_1")
                        if v4_4 and v4_4:GetAttribute("Broken") then
                            return true
                        end
                    end
                    if v3_3 then
                        local v4_6 = v3_3:FindFirstChild("Blade_1")
                        if v4_6 and v4_6:GetAttribute("Broken") then
                            return true
                        end
                    end
                    local v4_7 = false
                    for v8, v9 in ipairs(v1_2:GetDescendants()) do
                        if v9:IsA("MeshPart") and v9.Name:sub(1, 5) == "Blade" then
                            v4_7 = true
                            if not v9:GetAttribute("Broken") and 0.9 > v9.Transparency then
                                return false
                            end
                        end
                    end
                    return v4_7
                end)
                local v1_12
                if v2_4 then
                    v1_12 = v3_2
                else
                    v1_12 = false
                end
                if v1_12 then
                    v85_2()
                end
            end
        until true
    end
end)
task.spawn(function()
    while true do
        task.wait(0.5)
        if not v34_2 or not v77_2() then
            v36_2 = nil
        elseif v18_4 then
        elseif v35_2 then
        elseif v84_2() then
            task.spawn(v86_2)
        end
    end
end)
local v150_6 = {}
local function v149_8()
    for v4, v5 in pairs(v150_6) do
        if v5.highlight and v5.highlight.Parent then
            v5.highlight:Destroy()
        end
        if v5.billboard and v5.billboard.Parent then
            v5.billboard:Destroy()
        end
    end
    v150_6 = {}
    return
end
do
    local function v151_3(p1)
        if v150_6[p1] then
            return
        end
        local v2_2 = p1:FindFirstChild("HumanoidRootPart") or p1:FindFirstChildWhichIsA("BasePart") or p1.PrimaryPart
        if not v2_2 then
            return
        end
        local v3_6 = Instance.new("SelectionBox")
        v3_6.Color3 = Color3.fromRGB(120, 80, 255)
        v3_6.LineThickness = 0.07
        v3_6.SurfaceTransparency = 0.85
        v3_6.SurfaceColor3 = Color3.fromRGB(120, 80, 255)
        v3_6.Adornee = p1
        v3_6.Parent = v13_8.CurrentCamera
        local v4_13 = Instance.new("BillboardGui")
        v4_13.AlwaysOnTop = true
        v4_13.Size = UDim2.new(0, 160, 0, 50)
        v4_13.StudsOffset = Vector3.new(0, 4, 0)
        v4_13.Adornee = v2_2
        v4_13.Parent = v13_8.CurrentCamera
        local v5_15 = Instance.new("TextLabel")
        v5_15.Size = UDim2.new(1, 0, 0.52, 0)
        v5_15.BackgroundTransparency = 1
        v5_15.TextColor3 = Color3.fromRGB(200, 170, 255)
        v5_15.TextStrokeTransparency = 0.35
        v5_15.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
        v5_15.Font = Enum.Font.GothamBold
        v5_15.TextSize = 14
        v5_15.Text = "Titan"
        v5_15.Parent = v4_13
        local v6_22 = Instance.new("TextLabel")
        v6_22.Size = UDim2.new(1, 0, 0.48, 0)
        v6_22.Position = UDim2.new(0, 0, 0.52, 0)
        v6_22.BackgroundTransparency = 1
        v6_22.TextColor3 = Color3.fromRGB(255, 220, 100)
        v6_22.TextStrokeTransparency = 0.35
        v6_22.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
        v6_22.Font = Enum.Font.GothamBold
        v6_22.TextSize = 13
        v6_22.Text = "- m"
        v6_22.Parent = v4_13
        v150_6[p1] = {
            highlight = v3_6,
            billboard = v4_13,
            distLabel = v6_22,
            rootPart = v2_2,
            lastDist = nil
        }
        return
    end
    v14_9.Heartbeat:Connect(function()
        if not v21_2 then
            return
        end
        local v1_2 = v7_13.Character
        local v2_2 = v1_2 and v1_2:FindFirstChild("HumanoidRootPart")
        local v3_2 = v13_8:FindFirstChild("Titans")
        local v4_5 = {}
        if v3_2 then
            for v8, v9 in pairs(v3_2:GetChildren()) do
                if v9:IsA("Model") then
                    v4_5[v9] = true
                    if not v150_6[v9] then
                        v151_3(v9)
                    end
                end
            end
        end
        local v5_5 = {}
        for v9_3 in pairs(v150_6) do
            if not v4_5[v9_3] then
                table.insert(v5_5, v9_3)
            end
        end
        for v9_4, v10_4 in ipairs(v5_5) do
            local v11_6 = v150_6[v10_4]
            if v11_6.highlight and v11_6.highlight.Parent then
                v11_6.highlight:Destroy()
            end
            if v11_6.billboard and v11_6.billboard.Parent then
                v11_6.billboard:Destroy()
            end
            v150_6[v10_4] = nil
        end
        if v2_2 then
            for v9_5, v10_8 in pairs(v150_6) do
                if v10_8.rootPart and v10_8.rootPart.Parent then
                    local v11_9 = math.floor(((v2_2.Position - v10_8.rootPart.Position)).Magnitude)
                    if v10_8.lastDist ~= v11_9 then
                        v10_8.lastDist = v11_9
                        v10_8.distLabel.Text = v11_9 .. " m"
                    end
                end
            end
        end
        return
    end)
end
local v150_9 = {}
do
    local currentLang = v8_6("Language") == "Tiếng Việt" and "Tiếng Việt" or "English"
    local VI_MAP = {
        ["Loading..."] = "Đang tải...",
        ["Player"] = "Người Chơi",
        ["Auto Farm"] = "Tự Động Farm",
        ["Various"] = "Tiện Ích",
        ["Stats"] = "Thống Kê",
        ["WAVES"] = "CHẾ ĐỘ WAVES",
        ["RAID"] = "CHẾ ĐỘ RAID",
        ["Auto Raid (Focus Boss)"] = "Tự Động Đi Raid (Dồn Dame Boss)",
        ["VARIOUS"] = "TIỆN ÍCH",
        ["LANGUAGE / SETTINGS"] = "NGÔN NGỮ / CÀI ĐẶT",
        ["AUTO FAMILY ROLL"] = "TỰ QUAY GIA TỘC",
        ["AUTO SELL PERKS"] = "TỰ BÁN PERK",
        ["THUNDER SPEARS"] = "LÔI THƯƠNG (THUNDER SPEARS)",
        ["Language / Ngôn Ngữ"] = "Ngôn Ngữ / Language",
        ["NoClip"] = "Xuyên Tường (NoClip)",
        ["Walk Speed"] = "Tăng Tốc Chạy",
        ["Walk Speed Amount"] = "Mức Tốc Độ Chạy",
        ["Laggy Run"] = "Chạy Giật Tầm Xa (Laggy Run)",
        ["Laggy Run Distance"] = "Khoảng Cách Chạy Giật",
        ["Laggy Run Delay"] = "Độ Trễ Chạy Giật",
        ["CTRL + Click to TP"] = "CTRL + Click Để Dịch Chuyển",
        ["Infinite Jump"] = "Nhảy Vô Hạn",
        ["Auto Reset Kill Streak (>1000)"] = "Tự Hủy Chuỗi Giết (>1000 Kill)",
        ["Hit All"] = "Đánh Tất Cả (Hit All)",
        ["Distance to Titan"] = "Khoảng Cách Tới Titan",
        ["Auto Reload"] = "Tự Nạp Kiếm",
        ["Delay To Kill"] = "Chờ Trước Khi Giết",
        ["Delay(s)"] = "Thời Gian Chờ (giây)",
        ["Expand Nape Hitbox"] = "Mở Rộng Gáy Titan",
        ["Hitbox Size"] = "Kích Thước Hitbox",
        ["Visualize Hitbox"] = "Hiện Khung Hitbox",
        ["TP To Base"] = "Dịch Chuyển Về Căn Cứ",
        ["Auto Vote Ready"] = "Tự Bấm Sẵn Sàng",
        ["Auto Upgrade Max HQ HP"] = "Tự Nâng Máu Tối Đa HQ",
        ["Auto Upgrade HQ Health Regen"] = "Tự Nâng Hồi Máu HQ",
        ["Auto Upgrade Refill Limit"] = "Tự Nâng Giới Hạn Tiếp Tế",
        ["Auto Upgrade Weapon"] = "Tự Nâng Cấp Vũ Khí",
        ["Upgrade Delay"] = "Độ Trễ Nâng Cấp",
        ["Auto Get & Retrieve Skill Crate"] = "Tự Nhặt & Mở Rương Kỹ Năng",
        ["Titan ESP"] = "Định Vị Titan (ESP)",
        ["Change Cursor"] = "Đổi Con Trỏ Chuột",
        ["Auto Refill"] = "Tự Tiếp Tế (Gas & Kiếm)",
        ["Auto Retry"] = "Tự Chơi Lại (Auto Retry)",
        ["Auto Skip Cutscenes"] = "Tự Bỏ Qua Cắt Cảnh",
        ["Auto Open Raid Chests"] = "Tự Mở Rương Raid",
        ["Auto Claim Achievements"] = "Tự Nhận Thành Tựu (Auto Claim Achievements)",
        ["Auto Claim Daily Reward"] = "Tự Nhận Quà Hàng Ngày (Auto Claim Daily)",
        ["Mission Safety Timer"] = "Bộ Đếm An Toàn (Mission Safety Timer)",
        ["Auto Family Spin"] = "Tự Quay Gia Tộc",
        ["Families To Stop"] = "Gia Tộc Muốn Dừng",
        ["Family Tiers To Stop"] = "Bậc Gia Tộc Muốn Dừng",
        ["Auto Sell Selected Tier Perks"] = "Tự Bán Perk Đã Chọn",
        ["Perk Tiers To Sell"] = "Bậc Perk Muốn Bán",
        ["Select Perks To Sell"] = "Chọn Perk Cụ Thể Để Bán",
        ["Auto Create Towers(Outskirts)"] = "Tự Tạo Tháp (Outskirts)",
        ["Auto Retrieve Supply Crates(Forest)"] = "Tự Lấy Thùng Tiếp Tế (Forest)",
        ["PLAYER STATS:"] = "THỐNG KÊ NGƯỜI CHƠI:",
        ["MISSION STATS (LIVE):"] = "NHIỆM VỤ HIỆN TẠI (LIVE):",
        ["LAST ROUND STATS:"] = "THỐNG KÊ TRẬN VỪA RỒI:",
        ["TOTAL SESSION STATS:"] = "TỔNG THỐNG KÊ PHIÊN CHƠI:",
        ["Reset Session Stats"] = "Đặt Lại Thống Kê Phiên",
        ["Refresh Stats"] = "Làm Mới Thống Kê",
        ["In Lobby"] = "Ở Sảnh",
        ["In Progress"] = "Đang Chơi",
        ["Ended"] = "Đã Kết Thúc",
        ["Completed"] = "Hoàn Thành",
        ["None"] = "Không có",
        ["Kaitun"] = "Kaitun (Cày Cấp)",
        ["Settings"] = "Cài Đặt",
        ["KAITUN STATUS:"] = "TRẠNG THÁI KAITUN:",
        ["KAITUN AUTOMATION"] = "TỰ ĐỘNG HÓA KAITUN",
        ["WEAPON & MAP PROGRESSION"] = "NÂNG KIẾM & CHUYỂN MAP (E- -> S)",
        ["AUTO PRESTIGE (REBIRTH)"] = "TỰ ĐỘNG TÁI SINH (PRESTIGE)",
        ["Enable Kaitun (Auto Level & Prestige)"] = "Bật Kaitun (Tự Cày Cấp & Tái Sinh)",
        ["Auto Upgrade Weapon (E- -> S)"] = "Tự Nâng Hạng Kiếm (E- -> S)",
        ["Kaitun Weapon"] = "Vũ Khí Kaitun",
        ["Auto Select Map & Difficulty (E- -> S)"] = "Tự Chuyển Map & Độ Khó (E- -> S)",
        ["Kaitun Map"] = "Bản Đồ Kaitun",
        ["Auto Prestige (Rebirth)"] = "Tự Động Tái Sinh (Prestige)",
        ["Target Max Prestige"] = "Giới Hạn Cấp Tái Sinh Tối Đa",
        ["Upgrade Weapon Now"] = "Nâng Hạng Vũ Khí Ngay",
        ["SHADOW BAN DETECTION"] = "KIỂM TRA SHADOW BAN LIÊN TỤC",
        ["SHADOW BAN STATUS:"] = "TRẠNG THÁI SHADOW BAN:",
        ["Check Shadow Ban Now"] = "Kiểm Tra Shadow Ban Ngay",
        ["CONFIG & SETTINGS"] = "LƯU TRỮ & ĐỒNG BỘ CÀI ĐẶT",
        ["CONFIG STATUS:"] = "TRẠNG THÁI CẤU HÌNH:",
        ["Select Setting File (Order)"] = "Chọn File Setting (Theo Thứ Tự)",
        ["Create Next Setting File (In Order)"] = "Tạo & Lưu File Setting Tiếp Theo (Theo Thứ Tự)",
        ["Auto Load Global Settings"] = "Tự Tải Setting Cũ Khi Đổi Map",
        ["Save Settings Now"] = "Lưu Vào File Setting Đang Chọn",
        ["Load Saved Settings"] = "Tải File Setting Đang Chọn",
        ["Reset Default Settings"] = "Đặt Lại Mặc Định"
    }
    local REVERSE_KEY = {}
    for en, vi in pairs(VI_MAP) do
        REVERSE_KEY[en] = en
        REVERSE_KEY[vi] = en
    end
    local registeredRecords = {}

    local function tr(key)
        local s = tostring(key or "")
        if currentLang == "Tiếng Việt" then
            return VI_MAP[s] or s
        end
        return s
    end

    local function clampNum(val, minVal, maxVal)
        local n = tonumber(val) or minVal
        if n < minVal then
            return minVal
        elseif n > maxVal then
            return maxVal
        end
        return n
    end

    local function toOptionSet(tbl)
        local set = {}
        if type(tbl) ~= "table" then
            return set
        end
        for k, v in pairs(tbl) do
            if type(k) == "number" then
                if type(v) == "string" and v ~= "" then
                    set[v] = true
                end
            elseif v == true and type(k) == "string" and k ~= "" then
                set[k] = true
            end
        end
        return set
    end

    local function toOptionList(tbl)
        local list = {}
        local seen = {}
        if type(tbl) ~= "table" then
            return list
        end
        for _, v in ipairs(tbl) do
            if type(v) == "string" and v ~= "" and not seen[v] then
                seen[v] = true
                table.insert(list, v)
            end
        end
        for k, v in pairs(tbl) do
            if type(k) == "string" and k ~= "" and v == true and not seen[k] then
                seen[k] = true
                table.insert(list, k)
            end
        end
        table.sort(list)
        return list
    end

    local function syncRayfieldDomLanguage()
        local roots = {}
        if type(gethui) == "function" then
            local ok, uiRoot = pcall(gethui)
            if ok and uiRoot then
                table.insert(roots, uiRoot)
            end
        end
        pcall(function()
            local cg = game:GetService("CoreGui")
            if cg then
                table.insert(roots, cg)
                local rg = cg:FindFirstChild("RobloxGui")
                if rg then
                    table.insert(roots, rg)
                end
            end
        end)
        for _, root in ipairs(roots) do
            pcall(function()
                for _, gui in ipairs(root:GetChildren()) do
                    local main = gui:FindFirstChild("Main")
                    if main and (main:FindFirstChild("TabList") or main:FindFirstChild("Elements")) then
                        local tabList = main:FindFirstChild("TabList")
                        if tabList then
                            for _, btn in ipairs(tabList:GetChildren()) do
                                local t = btn:FindFirstChild("Title")
                                if t and type(t.Text) == "string" and REVERSE_KEY[t.Text] then
                                    local nextTxt = tr(REVERSE_KEY[t.Text])
                                    t.Text = nextTxt
                                    btn.Name = nextTxt
                                    pcall(function()
                                        if t.TextBounds and t.TextBounds.X then
                                            local img = btn:FindFirstChild("Image")
                                            local pad = (img and img.Visible) and 52 or 30
                                            btn.Size = UDim2.new(0, t.TextBounds.X + pad, 0, 30)
                                        end
                                    end)
                                end
                            end
                        end
                        local elements = main:FindFirstChild("Elements")
                        if elements then
                            for _, page in ipairs(elements:GetChildren()) do
                                for _, el in ipairs(page:GetChildren()) do
                                    local t = el:FindFirstChild("Title")
                                    if t and type(t.Text) == "string" and REVERSE_KEY[t.Text] then
                                        local nextTxt = tr(REVERSE_KEY[t.Text])
                                        t.Text = nextTxt
                                        if el.Name ~= "SectionTitle" and el.Name ~= "Placeholder" and REVERSE_KEY[el.Name] then
                                            el.Name = nextTxt
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    function v150_9.T(key)
        return tr(key)
    end

    function v150_9.GetLanguage()
        return currentLang
    end

    function v150_9.IsVietnamese()
        return currentLang == "Tiếng Việt"
    end

    function v150_9.SetLanguage(lang)
        local norm = lang == "Tiếng Việt" and "Tiếng Việt" or "English"
        local changed = currentLang ~= norm
        currentLang = norm
        v9_4("Language", norm)
        for _, rec in ipairs(registeredRecords) do
            local nextTxt = tr(rec.key)
            if rec.kind == "Section" or rec.kind == "Button" then
                pcall(function()
                    rec.obj:Set(nextTxt)
                end)
            elseif rec.kind == "Paragraph" then
                pcall(function()
                    rec.obj:Set({
                        Title = nextTxt,
                        Content = rec.lastContent or ""
                    })
                end)
            elseif rec.kind == "Tab" and type(rec.tabData) == "table" then
                rec.tabData.Name = nextTxt
            elseif type(rec.obj) == "table" then
                rec.obj.Name = nextTxt
                rec.obj.Title = nextTxt
            end
        end
        syncRayfieldDomLanguage()
        if type(v150_9.OnLanguageChanged) == "function" then
            pcall(v150_9.OnLanguageChanged)
        end
        if changed then
            pcall(function()
                v12_4:Notify({
                    Title = norm == "Tiếng Việt" and "Ngôn Ngữ" or "Language",
                    Content = norm == "Tiếng Việt" and "Đã chuyển sang Tiếng Việt." or "Switched language to English.",
                    Duration = 3
                })
            end)
        end
    end

    function v150_9.wrapWindow(win)
        local wrappedWin = {}
        function wrappedWin:CreateTab(name, ...)
            local key = tostring(name or "")
            local tab = win:CreateTab(tr(key), ...)
            table.insert(registeredRecords, { kind = "Tab", key = key, tabData = tab })
            return v150_9.wrapTab(tab)
        end

        return wrappedWin
    end

    function v150_9.wrapTab(rayfieldTab)
        local wrapped = {}

        function wrapped:AddLabel(text)
            local key = tostring(text or "")
            local sec = rayfieldTab:CreateSection(tr(key))
            table.insert(registeredRecords, { kind = "Section", key = key, obj = sec })
            return sec
        end

        function wrapped:AddParagraph(title, content)
            local key = tostring(title or "")
            local rec = { kind = "Paragraph", key = key, lastContent = tostring(content or "") }
            local paragraph = rayfieldTab:CreateParagraph({
                Title = tr(key),
                Content = rec.lastContent
            })
            rec.obj = paragraph
            table.insert(registeredRecords, rec)
            return {
                Set = function(_, newContent)
                    rec.lastContent = tostring(newContent or "")
                    paragraph:Set({
                        Title = tr(rec.key),
                        Content = rec.lastContent
                    })
                end
            }
        end

        function wrapped:AddButton(name, callback)
            local key = tostring(name or "")
            local btn = rayfieldTab:CreateButton({
                Name = tr(key),
                Callback = function()
                    if callback then
                        callback()
                    end
                end
            })
            table.insert(registeredRecords, { kind = "Button", key = key, obj = btn })
            return btn
        end

        function wrapped:AddToggle(name, callback)
            local key = tostring(name or "")
            local suppressing = true
            local toggle = rayfieldTab:CreateToggle({
                Name = tr(key),
                CurrentValue = false,
                Callback = function(value)
                    if suppressing or v15_isRestoring then
                        return
                    end
                    if callback then
                        callback(value)
                    end
                end
            })
            suppressing = false
            table.insert(registeredRecords, { kind = "Toggle", key = key, obj = toggle })
            function toggle:SetState(state)
                local nextState = state == true
                suppressing = true
                local ok, err = pcall(function()
                    self.CurrentValue = nextState
                    self:Set(nextState)
                end)
                suppressing = false
                if not ok then
                    warn("[Symbiote] SetState error:", err)
                end
            end

            return toggle
        end

        function wrapped:AddSlider(name, minVal, maxVal, defaultVal, callback, increment)
            local key = tostring(name or "")
            local suppressing = true
            local initialVal = clampNum(defaultVal, minVal, maxVal)
            local slider = rayfieldTab:CreateSlider({
                Name = tr(key),
                Range = { minVal, maxVal },
                Increment = increment or 1,
                CurrentValue = initialVal,
                Callback = function(value)
                    if suppressing or v15_isRestoring then
                        return
                    end
                    if callback then
                        callback(value)
                    end
                end
            })
            suppressing = false
            table.insert(registeredRecords, { kind = "Slider", key = key, obj = slider })
            function slider:SetValue(val)
                local clamped = clampNum(val, minVal, maxVal)
                suppressing = true
                local ok, err = pcall(function()
                    self.CurrentValue = clamped
                    self:Set(clamped)
                end)
                suppressing = false
                if not ok then
                    warn("[Symbiote] SetValue error:", err)
                end
            end

            return slider
        end

        function wrapped:AddDropdown(name, options, callback)
            local key = tostring(name or "")
            local suppressing = true
            local dropdown = rayfieldTab:CreateDropdown({
                Name = tr(key),
                Options = options or {},
                CurrentOption = {},
                MultipleOptions = true,
                Callback = function(selectedList)
                    if suppressing or v15_isRestoring then
                        return
                    end
                    if callback then
                        callback(toOptionSet(selectedList))
                    end
                end
            })
            suppressing = false
            table.insert(registeredRecords, { kind = "Dropdown", key = key, obj = dropdown })
            function dropdown:SetSelected(selectedTbl)
                local optionList = toOptionList(selectedTbl)
                suppressing = true
                local ok, err = pcall(function()
                    self:Set(optionList)
                end)
                suppressing = false
                if not ok then
                    warn("[Symbiote] SetSelected error:", err)
                end
            end

            return dropdown
        end

        function wrapped:AddSingleDropdown(name, options, defaultOpt, callback)
            local key = tostring(name or "")
            local suppressing = true
            local dropdown = rayfieldTab:CreateDropdown({
                Name = tr(key),
                Options = options or {},
                CurrentOption = { defaultOpt },
                MultipleOptions = false,
                Callback = function(selected)
                    if suppressing or v15_isRestoring then
                        return
                    end
                    local chosen = type(selected) == "table" and selected[1] or selected
                    if callback and type(chosen) == "string" then
                        callback(chosen)
                    end
                end
            })
            suppressing = false
            table.insert(registeredRecords, { kind = "Dropdown", key = key, obj = dropdown })
            function dropdown:SetSelected(optStr)
                if type(optStr) ~= "string" then
                    return
                end
                suppressing = true
                local ok, err = pcall(function()
                    self:Set({ optStr })
                end)
                suppressing = false
                if not ok then
                    warn("[Symbiote] SetSelected error:", err)
                end
            end

            return dropdown
        end

        return wrapped
    end

    v150_9.toOptionSet = toOptionSet
end
local v150_8 = v150_9.wrapWindow(v12_4:CreateWindow({
    Name = "HAIANHHUB (premium)",
    LoadingTitle = "HAIANHHUB",
    LoadingSubtitle = "Phiên bản 0.0.1",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = false
    }
}))
local v151_6 = v150_8:CreateTab("Player")
local v152_7 = v150_8:CreateTab("Auto Farm")
local v153_9 = v150_8:CreateTab("Various")
local v154_8 = v150_8:CreateTab("Stats")
v56_2.KaitunTab = v150_8:CreateTab("Kaitun")
v56_2.SettingsTab = v150_8:CreateTab("Settings")
local v157_2 = (function()
    local v1_2 = v10_3("Symbiote_AOTR_Stats.json")
    if not v1_2 then
        return nil
    end
    local v2_5, v3_2 = pcall(function()
        return v5_6:JSONDecode(v1_2)
    end)
    if v2_5 and type(v3_2) == "table" then
        return v3_2
    end
    return nil
end)() or {}
local rawPrestige = tonumber(v157_2.Player and v157_2.Player.Prestige) or 0
if rawPrestige > 5 or rawPrestige < 0 then rawPrestige = 0 end
local rawLevel = tonumber(v157_2.Player and v157_2.Player.Level) or 1
if rawLevel > 225 or rawLevel < 1 then rawLevel = 1 end

local v156_4 = {
    Player = {
        Prestige = rawPrestige,
        Level = rawLevel,
        Gems = tonumber(v157_2.Player and v157_2.Player.Gems) or 0,
        Gold = tonumber(v157_2.Player and v157_2.Player.Gold) or 0,
        Pumpkins = tonumber(v157_2.Player and v157_2.Player.Pumpkins) or 0
    },
    LastRound = {
        TimeTaken = tostring(v157_2.LastRound and v157_2.LastRound.TimeTaken or "00:00"),
        Difficulty = tostring(v157_2.LastRound and v157_2.LastRound.Difficulty or "N/A"),
        TitansKilled = tonumber(v157_2.LastRound and v157_2.LastRound.TitansKilled) or 0,
        DamageDealt = tonumber(v157_2.LastRound and v157_2.LastRound.DamageDealt) or 0,
        Gold = tonumber(v157_2.LastRound and v157_2.LastRound.Gold) or 0,
        Gems = tonumber(v157_2.LastRound and v157_2.LastRound.Gems) or 0,
        Pumpkins = tonumber(v157_2.LastRound and v157_2.LastRound.Pumpkins) or 0,
        DivineFragments = tonumber(v157_2.LastRound and
            (v157_2.LastRound.DivineFragments or v157_2.LastRound["Divine Fragments"])) or 0,
        BP_XP = tonumber(v157_2.LastRound and (v157_2.LastRound.BP_XP or v157_2.LastRound["BP XP"])) or 0,
        XP = tonumber(v157_2.LastRound and v157_2.LastRound.XP) or 0,
        Items = v157_2.LastRound and type(v157_2.LastRound.Items) == "table" and v157_2.LastRound.Items or {}
    },
    Session = {
        MissionsCompleted = tonumber(v157_2.Session and v157_2.Session.MissionsCompleted) or 0,
        TotalSeconds = tonumber(v157_2.Session and v157_2.Session.TotalSeconds) or 0,
        FastestSeconds = tonumber(v157_2.Session and v157_2.Session.FastestSeconds) or 0,
        TitansKilled = tonumber(v157_2.Session and v157_2.Session.TitansKilled) or 0,
        DamageDealt = tonumber(v157_2.Session and v157_2.Session.DamageDealt) or 0,
        Gold = tonumber(v157_2.Session and v157_2.Session.Gold) or 0,
        Gems = tonumber(v157_2.Session and v157_2.Session.Gems) or 0,
        Pumpkins = tonumber(v157_2.Session and v157_2.Session.Pumpkins) or 0,
        DivineFragments = tonumber(v157_2.Session and
            (v157_2.Session.DivineFragments or v157_2.Session["Divine Fragments"])) or 0,
        BP_XP = tonumber(v157_2.Session and (v157_2.Session.BP_XP or v157_2.Session["BP XP"])) or 0,
        XP = tonumber(v157_2.Session and v157_2.Session.XP) or 0,
        Items = v157_2.Session and type(v157_2.Session.Items) == "table" and v157_2.Session.Items or {},
        RarityCounts = v157_2.Session and type(v157_2.Session.RarityCounts) == "table" and v157_2.Session.RarityCounts or
            {
                Common = 0,
                Uncommon = 0,
                Rare = 0,
                Epic = 0,
                Legendary = 0,
                Mythic = 0,
                Secret = 0
            }
    }
}
local function v157_5()
    if v156_4 and v156_4.Player then
        v156_4.Player.Prestige = math.min(5, math.max(0, tonumber(v156_4.Player.Prestige) or 0))
        v156_4.Player.Level = math.min(225, math.max(1, tonumber(v156_4.Player.Level) or 1))
    end
    local v1_2, v2_2 = pcall(function()
        return v5_6:JSONEncode(v156_4)
    end)
    if v1_2 and v2_2 then
        v11("Symbiote_AOTR_Stats.json", v2_2)
    end
    return
end
local v158_4 = { Status = "In Progress", Seconds = 0, Difficulty = "N/A" }
local v159_6 = {
    Gold = 0,
    Gems = 0,
    Pumpkins = 0,
    DivineFragments = 0,
    BP_XP = 0,
    XP = 0,
    Items = {},
    Rarities = {}
}
local v160_9 = {
    Common_Perk = true,
    Uncommon_Perk = true,
    Rare_Perk = true,
    Epic_Perk = true,
    Legendary_Perk = true,
    Mythic_Perk = true,
    ["Common Perk"] = true,
    ["Uncommon Perk"] = true,
    ["Rare Perk"] = true,
    ["Epic Perk"] = true,
    ["Legendary Perk"] = true,
    ["Mythic Perk"] = true,
    Gold = true,
    Gems = true,
    Pumpkins = true,
    Pumpkin = true,
    XP = true,
    ["BP XP"] = true,
    BP_XP = true,
    BPXP = true
}
local function v161_61(p1)
    if not p1 or p1 == "" then
        return true
    end
    if v160_9[p1] then
        return true
    end
    if p1:match("^BP[%s_]?XP") then
        return true
    end
    return false
end
local v162_72 = "Playing"
local v163_11 = false
local v164_3 = os.clock()
local function v165_3(p1)
    if not p1 then
        return "0"
    end
    local v3_11 = tostring(math.floor(tonumber(p1) or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if v3_11:sub(1, 1) == "," then
        v3_11 = v3_11:sub(2)
    end
    return v3_11
end
local function v166_2(p1)
    local v2_2 = math.max(0, math.floor(tonumber(p1) or 0))
    return string.format("%02d:%02d", math.floor(v2_2 / 60), v2_2 % 60)
end
local function v167_2(p1, p2)
    if not p2 or p2 <= 0 then
        return "00:00"
    end
    local v4_5 = math.max(0, math.floor(math.floor(p1 / p2) / 5) * 5)
    return string.format("%s - %s", v166_2(v4_5), v166_2(v4_5 + 5))
end
local v168_2 = {}
local function v169_3()
    if not v168_2.Perks then
        pcall(function()
            v168_2.Perks = require(v16_15.Modules.Storage.Perks)
            return
        end)
    end
    return v168_2.Perks
end
local function v170_2()
    if not v168_2.Items then
        pcall(function()
            v168_2.Items = require(v16_15.Modules.Storage.Items)
            return
        end)
    end
    return v168_2.Items
end
local function v171_2(p1)
    local v2_2 = v169_3()
    if type(v2_2) == "table" then
        local v3_4 = string.gsub(p1, "_", " ")
        for v7, v8 in pairs(v2_2) do
            if type(v8) == "table" and (v8[p1] or v8[v3_4]) then
                return v7
            end
        end
    end
    return "Rare"
end
local function v172_2(p1)
    local v2_2 = v170_2()
    if type(v2_2) == "table" then
        local v3_4 = string.gsub(p1, "_", " ")
        if v2_2[p1] then
            return v2_2[p1].Rarity
        end
        if v2_2[v3_4] then
            return v2_2[v3_4].Rarity
        end
    end
    return nil
end
local v173_2 = {}
do
    local function v176_4(title)
        return v154_8:AddParagraph(title, v150_9.T("Loading..."))
    end
    v173_2.Player = v176_4("PLAYER STATS:")
    v173_2.LiveMission = v176_4("MISSION STATS (LIVE):")
    v173_2.LastRound = v176_4("LAST ROUND STATS:")
    v173_2.Session = v176_4("TOTAL SESSION STATS:")
end
local function v174_5()
    local isVi = v150_9.IsVietnamese()
    local v6 = v156_4
    local pPrestige = math.min(5, math.max(0, tonumber(v6.Player.Prestige) or 0))
    local pLevel = math.min(225, math.max(1, tonumber(v6.Player.Level) or 1))
    v173_2.Player:Set(string.format(
        isVi and "Prestige: %s\nCấp Độ (Level): %s\nGems: %s\nGold: %s\nPumpkins: %s"
        or "Prestige: %s\nLevel: %s\nGems: %s\nGold: %s\nPumpkins: %s",
        v165_3(pPrestige),
        v165_3(pLevel),
        v165_3(v6.Player.Gems),
        v165_3(v6.Player.Gold),
        v165_3(v6.Player.Pumpkins or 0)
    ))
    v173_2.LiveMission:Set(string.format(
        isVi and "Trạng Thái: %s\nThời Gian: %s\nĐộ Khó: %s\nChuỗi Giết (Streak): %s"
        or "Status: %s\nTime: %s\nDifficulty: %s\nKill Streak: %s",
        v150_9.T(v158_4.Status),
        v166_2(v158_4.Seconds),
        v158_4.Difficulty,
        v165_3(v150_10.CurrentKillStreak or 0)
    ))
    local v1_3 = v156_4.LastRound
    local v2_3 = v1_3.Items and #v1_3.Items or 0
    local v3_6 = {
        (isVi and "Thời Gian Hoàn Thành: " or "Time Taken: ") .. tostring(v1_3.TimeTaken),
        (isVi and "Độ Khó: " or "Difficulty: ") .. tostring(v1_3.Difficulty),
        (isVi and "Titan Đã Giết: " or "Titans Killed: ") .. v165_3(v1_3.TitansKilled or 0),
        (isVi and "Sát Thương Gây Ra: " or "Damage Dealt: ") .. v165_3(v1_3.DamageDealt or 0),
        "Gold: " .. v165_3(v1_3.Gold),
        "Gems: " .. v165_3(v1_3.Gems),
        "Pumpkins: " .. v165_3(v1_3.Pumpkins or 0),
        "Divine Fragments: " .. v165_3(v1_3.DivineFragments or 0),
        "BP XP: " .. v165_3(v1_3.BP_XP or 0),
        "XP: " .. v165_3(v1_3.XP),
        (isVi and "Vật Phẩm Rơi (" or "Drops (") .. tostring(v2_3) .. "):"
    }
    if 0 < v2_3 then
        for _, v8_11 in ipairs(v1_3.Items) do
            table.insert(v3_6, "  " .. v8_11)
        end
    else
        table.insert(v3_6, "  " .. v150_9.T("None"))
    end
    v173_2.LastRound:Set(table.concat(v3_6, "\n"))
    local v4_10 = v156_4.Session
    local v5_13 = v4_10.MissionsCompleted or 0
    local v6_17 = v4_10.FastestSeconds and 0 < v4_10.FastestSeconds and v166_2(v4_10.FastestSeconds) or "00:00"
    local v7_16 = v167_2(v4_10.TotalSeconds or 0, v5_13)
    local v8_14 = v4_10.RarityCounts or {}
    local v9_12 = {
        string.format("Common: %s | Uncommon: %s | Rare: %s", v165_3(v8_14.Common or 0), v165_3(v8_14.Uncommon or 0),
            v165_3(v8_14.Rare or 0)),
        string.format("Epic: %s | Legendary: %s | Mythic: %s", v165_3(v8_14.Epic or 0), v165_3(v8_14.Legendary or 0),
            v165_3(v8_14.Mythic or 0))
    }
    if 0 < (v8_14.Secret or 0) then
        table.insert(v9_12, string.format("Secret: %s", v165_3(v8_14.Secret)))
    end
    local v11_13 = {
        (isVi and "Số Trận Hoàn Thành: " or "Missions Completed: ") .. v165_3(v5_13),
        (isVi and "Trận Nhanh Nhất: " or "Fastest Time: ") .. v6_17,
        (isVi and "Thời Gian Trung Bình: " or "Average Time: ") .. v7_16,
        (isVi and "Tổng Titan Đã Giết: " or "Titans Killed: ") .. v165_3(v4_10.TitansKilled or 0),
        (isVi and "Tổng Sát Thương: " or "Damage Dealt: ") .. v165_3(v4_10.DamageDealt or 0),
        "Gold: " .. v165_3(v4_10.Gold or 0),
        "Gems: " .. v165_3(v4_10.Gems or 0),
        "Pumpkins: " .. v165_3(v4_10.Pumpkins or 0),
        "Divine Fragments: " .. v165_3(v4_10.DivineFragments or 0),
        "BP XP: " .. v165_3(v4_10.BP_XP or 0),
        "XP: " .. v165_3(v4_10.XP or 0),
        (isVi and "Tổng Vật Phẩm Rơi: " or "Total Drops: ") .. tostring(#(v4_10.Items or {})),
        (isVi and "Thống Kê Độ Hiếm:\n  " or "Rarity Breakdown:\n  ") .. table.concat(v9_12, "\n  ")
    }
    v173_2.Session:Set(table.concat(v11_13, "\n"))
    if v150_10.UpdateKaitunParagraph then
        pcall(v150_10.UpdateKaitunParagraph)
    end
    if v150_10.UpdateConfigParagraph then
        pcall(v150_10.UpdateConfigParagraph)
    end
    return
end
v150_9.OnLanguageChanged = v174_5
local function v175_4(p1)
    if type(p1) ~= "table" then
        return false
    end
    local v2_4 = false
    if type(p1.Progression) == "table" then
        if p1.Progression.Prestige ~= nil then
            local pVal = tonumber(p1.Progression.Prestige)
            if pVal and pVal >= 0 and pVal <= 5 then
                v156_4.Player.Prestige = pVal
                v2_4 = true
            end
        end
        if p1.Progression.Level ~= nil then
            local lVal = tonumber(p1.Progression.Level)
            if lVal and lVal >= 1 and lVal <= 225 then
                v156_4.Player.Level = lVal
                v2_4 = true
            end
        end
    end
    if type(p1.Currency) == "table" then
        if p1.Currency.Gold ~= nil then
            v156_4.Player.Gold = tonumber(p1.Currency.Gold) or v156_4.Player.Gold
            v2_4 = true
        end
        if p1.Currency.Gems ~= nil then
            v156_4.Player.Gems = tonumber(p1.Currency.Gems) or v156_4.Player.Gems
            v2_4 = true
        end
        if p1.Currency.Pumpkins ~= nil then
            v156_4.Player.Pumpkins = tonumber(p1.Currency.Pumpkins) or v156_4.Player.Pumpkins
            v2_4 = true
        end
    end
    return v2_4
end
local function v176_5()
    local v1 = false
    local v2 = game.PlaceId == 14916516914 or game.PlaceId == 13379208636
    local v3_2 = v7_13:GetAttribute("Prestige")
    if v3_2 ~= nil then
        local pVal = tonumber(v3_2)
        if pVal and pVal >= 0 and pVal <= 5 then
            v156_4.Player.Prestige = pVal
            v1 = true
        end
    end
    local v4_8 = v7_13:GetAttribute("Level")
    if v4_8 ~= nil then
        local lVal = tonumber(v4_8)
        if lVal and lVal >= 1 and lVal <= 225 then
            v156_4.Player.Level = lVal
            v1 = true
        end
    end
    if v2 then
        local v5_10 = v7_13:FindFirstChild("PlayerGui")
        local v6_7 = v5_10 and v5_10:FindFirstChild("Interface")
        local v7_7 = v6_7 and v6_7:FindFirstChild("Topbar")
        if v7_7 and v7_7:FindFirstChild("Main") and v7_7.Main:FindFirstChild("Currencies") then
            local v8_10 = v7_7.Main.Currencies
            local v9_5 = v8_10:FindFirstChild("Gold") and v8_10.Gold:FindFirstChild("Amount")
            local v10_5 = v8_10:FindFirstChild("Gems") and v8_10.Gems:FindFirstChild("Amount")
            local v11_5 = v8_10:FindFirstChild("Pumpkins") and v8_10.Pumpkins:FindFirstChild("Amount")
            if v9_5 and v9_5:IsA("TextLabel") then
                local v12_7 = tonumber(v9_5.Text:gsub(",", ""):gsub("%s", ""))
                if v12_7 then
                    v156_4.Player.Gold = v12_7
                    v1 = true
                end
            end
            if v10_5 and v10_5:IsA("TextLabel") then
                local v12_11 = tonumber(v10_5.Text:gsub(",", ""):gsub("%s", ""))
                if v12_11 then
                    v156_4.Player.Gems = v12_11
                    v1 = true
                end
            end
            if v11_5 and v11_5:IsA("TextLabel") then
                local v12_15 = tonumber(v11_5.Text:gsub(",", ""):gsub("%s", ""))
                if v12_15 then
                    v156_4.Player.Pumpkins = v12_15
                    v1 = true
                end
            end
        end
    else
        local v5_12, v6_10, v7_5 = pcall(function()
            return v69_2:InvokeServer("S_Rewards", "Get")
        end)
        if v5_12 and v175_4(v7_5) then
            v1 = true
        end
    end
    if v1 then
        v157_5()
    end
    v174_5()
    return
end
local function v177_13()
    if v162_72 == "Ended" or v163_11 then
        return
    end
    v163_11 = true
    v162_72 = "Ended"
    task.wait(0.6)
    v158_4.Status = "Completed"
    local v1_7 = v150_10.GetActualGameTime and v150_10.GetActualGameTime()
    if not v1_7 or v1_7 <= 0 then
        v1_7 = tonumber(v13_8:GetAttribute("Seconds")) or math.max(30, v158_4.Seconds)
    end
    local v2_13 = v13_8:GetAttribute("Difficulty")
    if not v2_13 or tostring(v2_13) == "" or tostring(v2_13) == "N/A" then
        if v158_4.Difficulty and v158_4.Difficulty ~= "N/A" then
            v2_13 = v158_4.Difficulty
        elseif v156_4.LastRound.Difficulty and v156_4.LastRound.Difficulty ~= "N/A" then
            v2_13 = v156_4.LastRound.Difficulty
        else
            v2_13 = "Easy"
        end
    end
    local v2_14 = tostring(v2_13)
    local v3_12 = 0
    local v4_12 = v3_12
    local v5_8 = v7_13:FindFirstChild("PlayerGui")
    local v6_2 = v5_8 and v5_8:FindFirstChild("Interface")
    local v7_4 = v6_2 and v6_2:FindFirstChild("Rewards")
    local v8_4 = nil
    if v7_4 and v7_4:FindFirstChild("Main") and v7_4.Main:FindFirstChild("Info") then
        local v9_7 = v7_4.Main.Info.Main
        local v10_4 = v9_7:FindFirstChild("Stats")
        if v10_4 then
            local v11_8 = v10_4:FindFirstChild("Time_Taken") and v10_4.Time_Taken:FindFirstChild("Amount")
            if v11_8 and v11_8:IsA("TextLabel") and v11_8.Text ~= "" and v11_8.Text ~= "00:00" then
                local v12_11, v13_13 = string.match(v11_8.Text, "(%d+):(%d+)")
                if v12_11 and v13_13 then
                    local v14_17 = (tonumber(v12_11) or 0) * 60 + (tonumber(v13_13) or 0)
                    if v14_17 > 0 then
                        v1_7 = v14_17
                    end
                end
            end
            local v12_12 = v10_4:FindFirstChild("Kills") and v10_4.Kills:FindFirstChild("Amount")
            if v12_12 and v12_12:IsA("TextLabel") then
                v3_12 = tonumber(v12_12.Text:gsub(",", ""):gsub("%s", "")) or 0
            end
            local v13_23 = v10_4:FindFirstChild("Damage") and v10_4.Damage:FindFirstChild("Amount")
            if v13_23 and v13_23:IsA("TextLabel") then
                v4_12 = tonumber(v13_23.Text:gsub(",", ""):gsub("%s", "")) or 0
            end
        end
        v8_4 = v9_7:FindFirstChild("Items")
    end
    local v10_7 = v159_6
    local v9_8 = v10_7.Gold
    local v11_7 = v10_7
    local v10_8 = v11_7.Gems
    local v11_6 = v11_7.Pumpkins or 0
    local v12_6 = v159_6.DivineFragments or 0
    local v13_6 = v159_6.BP_XP or 0
    local v14_4 = v159_6.XP
    local v15_3 = {}
    local v16_3 = {}
    local v17_4, v18_3, v19_2 = pcall(function()
        return v69_2:InvokeServer("S_Rewards", "Get")
    end)
    local v20_2 = false
    if v17_4 and type(v18_3) == "table" then
        if v18_3.Seconds and tonumber(v18_3.Seconds) and tonumber(v18_3.Seconds) > 0 then
            v1_7 = tonumber(v18_3.Seconds)
        end
        if v18_3.Stats and type(v18_3.Stats) == "table" then
            if tonumber(v18_3.Stats.Kills) and tonumber(v18_3.Stats.Kills) > v3_12 then
                v3_12 = tonumber(v18_3.Stats.Kills)
            end
            if tonumber(v18_3.Stats.Damage) and tonumber(v18_3.Stats.Damage) > v4_12 then
                v4_12 = tonumber(v18_3.Stats.Damage)
            end
        end
        local v21_19 = v18_3.Obtained
        if type(v21_19) == "table" then
            local v22_30 = tonumber(v21_19.Gold) or 0
            local v23_21 = tonumber(v21_19.Gems) or 0
            local v24_7 = tonumber(v21_19.Pumpkins) or 0
            local v25_8 = tonumber(v21_19.Divine_Fragment or v21_19["Divine Fragment"] or v21_19.DivineFragments or
                v21_19["Divine Fragments"]) or 0
            local v26_11 = tonumber(v21_19["BP XP"] or v21_19.BP_XP or v21_19.BPXP or v21_19.BP) or 0
            local v27_10 = tonumber(v21_19.XP) or 0
            if v22_30 > 0 then
                v9_8 = v22_30
            end
            if v23_21 > 0 then
                v10_8 = v23_21
            end
            if v24_7 > 0 then
                v11_6 = v24_7
            end
            if v25_8 > 0 then
                v12_6 = v25_8
            end
            if 0 < v26_11 then
                v13_6 = v26_11
            end
            if 0 < v27_10 then
                v14_4 = v27_10
            end
            if type(v21_19.Perks) == "table" then
                for v31_11, v32_8 in pairs(v21_19.Perks) do
                    local v33_5 = type(v31_11) == "string" and not tonumber(v31_11) and v31_11 or tostring(v32_8)
                    local v34_14 = type(v32_8) == "number" and v32_8 or 1
                    local v36_19
                    if not v33_5 or v33_5 == "" then
                        v36_19 = true
                    elseif v160_9[v33_5] then
                        v36_19 = true
                    elseif v33_5:match("^BP[%s_]?XP") then
                        v36_19 = true
                    else
                        v36_19 = false
                    end
                    if not v36_19 then
                        local v35_34 = v171_2(v33_5) or "Common"
                        table.insert(v15_3,
                            string.gsub(v33_5, "_", " ") ..
                            (1 < v34_14 and " x" .. tostring(v34_14) or "") .. " (" .. v35_34 .. ")")
                        table.insert(v16_3, v35_34)
                    end
                end
            end
            if type(v21_19.Drops) == "table" then
                for v31_12, v32_9 in pairs(v21_19.Drops) do
                    local v33_6 = type(v31_12) == "string" and not tonumber(v31_12) and v31_12 or tostring(v32_9)
                    local v34_20 = type(v32_9) == "number" and v32_9 or 1
                    if v33_6 == "Divine_Fragment" or v33_6 == "Divine Fragment" or v33_6:find("Divine") and v33_6:find("Fragment") then
                        v12_6 = v12_6 + v34_20
                    end
                    local v36_26
                    if not v33_6 or v33_6 == "" then
                        v36_26 = true
                    elseif v160_9[v33_6] then
                        v36_26 = true
                    elseif v33_6:match("^BP[%s_]?XP") then
                        v36_26 = true
                    else
                        v36_26 = false
                    end
                    if not v36_26 and v33_6 ~= "Pumpkins" and v33_6 ~= "Pumpkin" then
                        local v35_44 = v172_2(v33_6) or "Common"
                        table.insert(v15_3,
                            string.gsub(v33_6, "_", " ") ..
                            (v34_20 > 1 and " x" .. tostring(v34_20) or "") .. " (" .. v35_44 .. ")")
                        table.insert(v16_3, v35_44)
                    end
                end
            end
            if type(v21_19.Chests) == "table" then
                for v31_13, v32_10 in pairs(v21_19.Chests) do
                    local v33_7 = type(v31_13) == "string" and not tonumber(v31_13) and v31_13 or tostring(v32_10)
                    local v34_24 = type(v32_10) == "number" and v32_10 or 1
                    local v36_24
                    if not v33_7 or v33_7 == "" then
                        v36_24 = true
                    elseif v160_9[v33_7] then
                        v36_24 = true
                    elseif v33_7:match("^BP[%s_]?XP") then
                        v36_24 = true
                    else
                        v36_24 = false
                    end
                    if not v36_24 then
                        local v35_38 = v172_2(v33_7) or "Rare"
                        table.insert(v15_3,
                            string.gsub(v33_7, "_", " ") ..
                            (v34_24 > 1 and " x" .. tostring(v34_24) or "") .. " (" .. v35_38 .. ")")
                        table.insert(v16_3, v35_38)
                    end
                end
            end
            if type(v21_19.Cosmetics) == "table" then
                for v31_14, v32_11 in pairs(v21_19.Cosmetics) do
                    local v33_9 = type(v31_14) == "string" and not tonumber(v31_14) and v31_14 or tostring(v32_11)
                    local v34_26 = type(v32_11) == "number" and v32_11 or 1
                    local v36_25
                    if not v33_9 or v33_9 == "" then
                        v36_25 = true
                    elseif v160_9[v33_9] then
                        v36_25 = true
                    elseif v33_9:match("^BP[%s_]?XP") then
                        v36_25 = true
                    else
                        v36_25 = false
                    end
                    if not v36_25 then
                        local v35_42 = v172_2(v33_9) or "Common"
                        table.insert(v15_3,
                            string.gsub(v33_9, "_", " ") ..
                            (1 < v34_26 and " x" .. tostring(v34_26) or "") .. " (" .. v35_42 .. ")")
                        table.insert(v16_3, v35_42)
                    end
                end
            end
            v20_2 = true
        end
    end
    if (not v20_2 or #v15_3 == 0) and 0 < #v159_6.Items then
        v15_3 = table.clone(v159_6.Items)
        v16_3 = table.clone(v159_6.Rarities)
        if v159_6.Gold > 0 then
            v9_8 = v159_6.Gold
        end
        if v159_6.Gems > 0 then
            v10_8 = v159_6.Gems
        end
        if 0 < (v159_6.Pumpkins or 0) then
            v11_6 = v159_6.Pumpkins
        end
        if (v159_6.DivineFragments or 0) > 0 then
            v12_6 = v159_6.DivineFragments
        end
        if (v159_6.BP_XP or 0) > 0 then
            v13_6 = v159_6.BP_XP
        end
        if v159_6.XP > 0 then
            v14_4 = v159_6.XP
        end
    elseif (not v20_2 or #v15_3 == 0) and v8_4 then
        for v24_3, v25_2 in ipairs(v8_4:GetChildren()) do
            if v25_2:IsA("Frame") and v25_2:FindFirstChild("Main") and v25_2.Main:FindFirstChild("Inner") then
                local v26_9 = v25_2.Main.Inner
                local v27_8 = v26_9:FindFirstChild("Quantity")
                local v30_3 = tonumber(((v27_8 and v27_8.Text or "")):gsub(",", ""):gsub("%+", ""):gsub("%s", "")) or 1
                local v31_8 = v26_9:FindFirstChild("Rarity")
                local v32_6 = v31_8 and v31_8.BackgroundColor3
                local v33_4 = "Common"
                if not v168_2.Values then
                    pcall(function()
                        v168_2.Values = require(v16_15.Modules.Storage.Values)
                        return
                    end)
                end
                local v34_3 = v168_2.Values
                if v34_3 and v34_3.Colours then
                    for v38_3, v39_3 in pairs(v34_3.Colours) do
                        if v32_6 and math.abs(v32_6.R - v39_3.R) < 0.05 and 0.05 > math.abs(v32_6.G - v39_3.G) and math.abs(v32_6.B - v39_3.B) < 0.05 then
                            v33_4 = v38_3
                            break
                        end
                    end
                end
                local v35_10 = v26_9:FindFirstChild("Icon")
                local v36_8 = v35_10 and v35_10.Image or ""
                local v37_7 = nil
                if not v168_2.Items then
                    pcall(function()
                        v168_2.Items = require(v16_15.Modules.Storage.Items)
                        return
                    end)
                end
                local v38_4 = v168_2.Items
                if v38_4 then
                    for v42_15, v43_6 in pairs(v38_4) do
                        if v43_6.Image and tostring(v43_6.Image) ~= "" and v36_8:find(tostring(v43_6.Image)) then
                            v37_7 = v42_15
                            break
                        end
                    end
                end
                if not v37_7 then
                    if not v168_2.Perks then
                        pcall(function()
                            v168_2.Perks = require(v16_15.Modules.Storage.Perks)
                            return
                        end)
                    end
                    local v39_11 = v168_2.Perks
                    if v39_11 then
                        for v43_10, v44_6 in pairs(v39_11) do
                            if type(v44_6) == "table" then
                                for v48_4, v49_4 in pairs(v44_6) do
                                    if type(v49_4) == "table" and v49_4.Image and tostring(v49_4.Image) ~= "" and v36_8:find(tostring(v49_4.Image)) then
                                        v37_7 = v48_4
                                        break
                                    end
                                end
                            end
                            if v37_7 then
                                break
                            end
                        end
                    end
                end
                local v39_10 = v37_7
                if v39_10 then
                    local v41_15 = v37_7
                    local v40_18
                    if not v41_15 or v41_15 == "" then
                        v40_18 = true
                    elseif v160_9[v41_15] then
                        v40_18 = true
                    elseif v41_15:match("^BP[%s_]?XP") then
                        v40_18 = true
                    else
                        v40_18 = false
                    end
                    v39_10 = not v40_18
                end
                if v39_10 then
                    table.insert(v15_3, string.gsub(v37_7, "_", " ") .. " (" .. v33_4 .. ")")
                    table.insert(v16_3, v33_4)
                elseif v37_7 then
                    if v37_7 == "Gold" and v9_8 == 0 then
                        v9_8 = v30_3
                    elseif v37_7 == "Gems" and v10_8 == 0 then
                        v10_8 = v30_3
                    elseif (v37_7 == "Pumpkins" or v37_7 == "Pumpkin") and v11_6 == 0 then
                        v11_6 = v30_3
                    elseif (v37_7 == "Divine_Fragment" or v37_7 == "Divine Fragment" or v37_7:find("Divine") and v37_7:find("Fragment")) and v12_6 == 0 then
                        v12_6 = v30_3
                    elseif (v37_7 == "BP XP" or v37_7 == "BP_XP" or v37_7 == "BPXP") and v13_6 == 0 then
                        v13_6 = v30_3
                    elseif v37_7 == "XP" and v14_4 == 0 then
                        v14_4 = v30_3
                    end
                end
            end
        end
    end
    local v21_30 = v156_4.LastRound
    v21_30.TimeTaken = v166_2(v1_7)
    v21_30.Difficulty = v2_14
    v21_30.TitansKilled = v3_12
    v21_30.DamageDealt = v4_12
    v21_30.Gold = v9_8
    v21_30.Gems = v10_8
    v21_30.Pumpkins = v11_6
    v21_30.DivineFragments = v12_6
    v21_30.BP_XP = v13_6
    v21_30.XP = v14_4
    v21_30.Items = table.clone(v15_3)
    local v22_46 = v156_4.Session
    v22_46.MissionsCompleted = (v22_46.MissionsCompleted or 0) + 1
    v22_46.TotalSeconds = (v22_46.TotalSeconds or 0) + v1_7
    if 0 < v1_7 then
        if not v22_46.FastestSeconds or v22_46.FastestSeconds == 0 or v22_46.FastestSeconds > v1_7 then
            v22_46.FastestSeconds = v1_7
        end
    end
    v22_46.TitansKilled = (v22_46.TitansKilled or 0) + v3_12
    v22_46.DamageDealt = (v22_46.DamageDealt or 0) + v4_12
    v22_46.Gold = (v22_46.Gold or 0) + v9_8
    v22_46.Gems = (v22_46.Gems or 0) + v10_8
    v22_46.Pumpkins = (v22_46.Pumpkins or 0) + v11_6
    v22_46.DivineFragments = (v22_46.DivineFragments or 0) + v12_6
    v22_46.BP_XP = (v22_46.BP_XP or 0) + v13_6
    v22_46.XP = (v22_46.XP or 0) + v14_4
    v22_46.Items = v22_46.Items or {}
    for v26_12, v27_12 in ipairs(v15_3) do
        table.insert(v22_46.Items, v27_12)
    end
    v22_46.RarityCounts = v22_46.RarityCounts or {}
    for v26_14, v27_13 in ipairs(v16_3) do
        v22_46.RarityCounts[v27_13] = (v22_46.RarityCounts[v27_13] or 0) + 1
    end
    if v17_4 then
        v175_4(v19_2)
    end
    v157_5()
    v174_5()
    v163_11 = false
    return
end
local function v178_5()
    if v162_72 == "Playing" then
        return
    end
    v162_72 = "Playing"
    v164_3 = os.clock()
    v150_10.MissionStartTime = os.clock()
    local v1_5 = v158_4
    v1_5.Status = "In Progress"
    v1_5.Seconds = 0
    local v1_8 = v13_8:GetAttribute("Difficulty")
    if not v1_8 or tostring(v1_8) == "" or tostring(v1_8) == "N/A" then
        v1_8 = v156_4.LastRound.Difficulty or "N/A"
    end
    v158_4.Difficulty = tostring(v1_8)
    v159_6 = {
        Gold = 0,
        Gems = 0,
        Pumpkins = 0,
        DivineFragments = 0,
        BP_XP = 0,
        XP = 0,
        Items = {},
        Rarities = {}
    }
    v174_5()
    return
end
do
    local function v179_5()
        pcall(function()
            local v1_3 = v16_15:WaitForChild("Modules", 10)
            local v2 = v1_3 and v1_3:WaitForChild("User Interface", 10)
            local v3_3 = v2 and v2:WaitForChild("Rewards", 10)
            if not v3_3 then
                return
            end
            local v4_6 = require(v3_3)
            if type(v4_6) ~= "table" then
                return
            end
            if type(v4_6.Create) == "function" and not v4_6.__SymbioteHooked then
                v4_6.__SymbioteHooked = true
                local v5_8 = v4_6.Create
                v4_6.Create = function(p1, p2, p3, p4, p5, p6, p7)
                    pcall(function()
                        local v2_2 = tonumber(tostring(p7 or ""):gsub(",", ""):gsub("%+", ""):gsub("x", ""):gsub("%s", "")) or
                            1
                        local v3_7 = tostring(p4 or "")
                        if p3 == 1 or p4 == "Gold" or v3_7 == "Gold" then
                            local v4_7 = v159_6
                            v4_7.Gold = v4_7.Gold + v2_2
                        elseif p4 == "Gems" or v3_7 == "Gems" then
                            local v4_9 = v159_6
                            v4_9.Gems = v4_9.Gems + v2_2
                        elseif p4 == "Pumpkins" or v3_7 == "Pumpkins" or p4 == "Pumpkin" or v3_7 == "Pumpkin" then
                            local v4_11 = v159_6
                            v4_11.Pumpkins = (v4_11.Pumpkins or 0) + v2_2
                        elseif p4 == "Divine_Fragment" or v3_7 == "Divine_Fragment" or v3_7:find("Divine") and v3_7:find("Fragment") then
                            local v4_14 = v159_6
                            v4_14.DivineFragments = (v4_14.DivineFragments or 0) + v2_2
                        elseif p4 == "BP XP" or v3_7 == "BP XP" or p4 == "BP_XP" or v3_7 == "BP_XP" or p4 == "BPXP" or v3_7 == "BPXP" then
                            local v4_17 = v159_6
                            v4_17.BP_XP = (v4_17.BP_XP or 0) + v2_2
                        elseif p4 == "XP" or v3_7 == "XP" then
                            local v4_19 = v159_6
                            v4_19.XP = v4_19.XP + v2_2
                        elseif not v161_61(v3_7) then
                            local v4_21 = p5 and p5 ~= "" and p5 or v171_2(v3_7) or v172_2(v3_7) or "Common"
                            table.insert(v159_6.Items,
                                string.gsub(v3_7, "_", " ") ..
                                (v2_2 > 1 and " x" .. tostring(v2_2) or "") .. " (" .. v4_21 .. ")")
                            table.insert(v159_6.Rarities, v4_21)
                        end
                        return
                    end)
                    return v5_8(p1, p2, p3, p4, p5, p6, p7)
                end
            end
            if type(v4_6.Setup) == "function" and not v4_6.__SymbioteSetupHooked then
                v4_6.__SymbioteSetupHooked = true
                local v5_11 = v4_6.Setup
                v4_6.Setup = function(p1, p2)
                    local v3_2 = v5_11(p1, p2)
                    if v162_72 == "Playing" then
                        task.defer(function()
                            v177_13()
                            return
                        end)
                    end
                    return v3_2
                end
            end
            return
        end)
        task.spawn(function()
            local v1_3 = v7_13:WaitForChild("PlayerGui", 60)
            local v2 = v1_3 and v1_3:WaitForChild("Interface", 60)
            local v3_3 = v2 and v2:WaitForChild("Rewards", 60)
            if not v3_3 then
                return
            end
            v3_3:GetPropertyChangedSignal("Visible"):Connect(function()
                if v3_3.Visible then
                    if v162_72 == "Playing" then
                        task.delay(0.6, function()
                            v177_13()
                            return
                        end)
                    end
                elseif v162_72 == "Ended" and not v163_11 then
                    v178_5()
                end
                return
            end)
            return
        end)
        v13_8:GetAttributeChangedSignal("Difficulty"):Connect(function()
            local v1_3 = v13_8:GetAttribute("Difficulty")
            if v1_3 and tostring(v1_3) ~= "" and tostring(v1_3) ~= "N/A" then
                v158_4.Difficulty = tostring(v1_3)
                v174_5()
            end
            return
        end)
        return
    end
    v154_8:AddButton("Reset Session Stats", function()
        v156_4.Session = {
            MissionsCompleted = 0,
            TotalSeconds = 0,
            FastestSeconds = 0,
            TitansKilled = 0,
            DamageDealt = 0,
            Gold = 0,
            Gems = 0,
            Pumpkins = 0,
            DivineFragments = 0,
            BP_XP = 0,
            XP = 0,
            Items = {},
            RarityCounts = {
                Common = 0,
                Uncommon = 0,
                Rare = 0,
                Epic = 0,
                Legendary = 0,
                Mythic = 0,
                Secret = 0
            }
        }
        v157_5()
        v174_5()
        return
    end)
    v154_8:AddButton("Refresh Stats", function()
        v176_5()
        return
    end)
    task.spawn(function()
        task.wait(0.3)
        v176_5()
        v179_5()
        local v1 = game.PlaceId == 14916516914 or game.PlaceId == 13379208636
        local v2_4 = 0
        if not v1 then
            v162_72 = "Playing"
            local v3_9 = v13_8:GetAttribute("Difficulty")
            if not v3_9 or tostring(v3_9) == "" or tostring(v3_9) == "N/A" then
                v3_9 = v156_4.LastRound.Difficulty or "N/A"
            end
            v158_4.Difficulty = tostring(v3_9)
        else
            v162_72 = "Lobby"
        end
        while true do
            task.wait(0.5)
            v2_4 = v2_4 + 0.5
            if v1 then
                local v3_13 = v158_4
                v3_13.Status = "In Lobby"
                v3_13.Seconds = 0
                v3_13.Difficulty = "N/A"
            else
                local v3_16 = v7_13:FindFirstChild("PlayerGui")
                local v4_10 = v3_16 and v3_16:FindFirstChild("Interface")
                local v5_11 = v4_10 and v4_10:FindFirstChild("Rewards")
                if v5_11 and v5_11.Visible then
                    if v162_72 == "Playing" and not v163_11 then
                        task.delay(0.6, function()
                            v177_13()
                            return
                        end)
                    end
                elseif v162_72 == "Ended" and not v163_11 then
                    v178_5()
                elseif v162_72 == "Playing" then
                    local v7_7 = v158_4
                    v7_7.Status = "In Progress"
                    v7_7.Seconds = math.max(0, math.floor(os.clock() - v164_3))
                    local v7_10 = v13_8:GetAttribute("Difficulty")
                    if v7_10 and tostring(v7_10) ~= "" and tostring(v7_10) ~= "N/A" then
                        v158_4.Difficulty = tostring(v7_10)
                    elseif v158_4.Difficulty == "N/A" and v156_4.LastRound.Difficulty and v156_4.LastRound.Difficulty ~= "N/A" then
                        v158_4.Difficulty = v156_4.LastRound.Difficulty
                    end
                end
            end
            v150_10.CheckAutoResetStreak()
            if 15 <= v2_4 then
                v2_4 = 0
                v176_5()
            else
                v174_5()
            end
        end
    end)
end
v56_2.NoClip = v151_6:AddToggle("NoClip", function(p1)
    v19_3 = p1
    v9_4("NoClip", p1)
    if p1 then
        v98_2()
    else
        v99_2()
    end
    return
end)
v56_2.WalkSpeed = v151_6:AddToggle("Walk Speed", function(p1)
    v27_2 = p1
    v9_4("WalkSpeed", p1)
    if p1 then
        v100_3()
    else
        v101_2()
    end
    return
end)
v56_2.WalkSpeedSlider = v151_6:AddSlider("Walk Speed Amount", 1, 5, v8_6("WalkSpeedAmount"), function(p1)
    v28_2 = p1
    v9_4("WalkSpeedAmount", p1)
    return
end)
v56_2.LaggyRun = v151_6:AddToggle("Laggy Run", function(p1)
    v29_2 = p1
    v9_4("LaggyRun", p1)
    if p1 then
        v102_3()
    else
        v103_2()
    end
    return
end)
v56_2.LaggyRunDistSlider = v151_6:AddSlider("Laggy Run Distance", 1, 10, v8_6("LaggyRunDistance"), function(p1)
    v30_2 = p1
    v9_4("LaggyRunDistance", p1)
    return
end)
v56_2.LaggyRunDelaySlider = v151_6:AddSlider("Laggy Run Delay", 1, 10, v8_6("LaggyRunDelay"), function(p1)
    v31_2 = p1
    v9_4("LaggyRunDelay", p1)
    return
end)
v56_2.CtrlClickTP = v151_6:AddToggle("CTRL + Click to TP", function(p1)
    v32_2 = p1
    v9_4("CtrlClickTP", p1)
    if p1 then
        v104_3()
    else
        v105_3()
    end
    return
end)
v56_2.InfiniteJump = v151_6:AddToggle("Infinite Jump", function(p1)
    v33_2 = p1
    v9_4("InfiniteJump", p1)
    if p1 then
        v106_3()
    else
        v107_2()
    end
    return
end)
v56_2.AutoFarm = v152_7:AddToggle("Auto Farm", function(p1)
    v9_4("AutoFarm", p1)
    if p1 then
        v18_4 = true
        v22_2 = true
        if v16_9["HitboxSize"] == nil then
            v23_2 = 100
            if v56_2.HitboxSizeSlider then
                v56_2.HitboxSizeSlider:SetValue(100)
            end
        end
        v116_4(v23_2)
        v150_10.StartAutoGas()
        task.spawn(v148_4)
    else
        v18_4 = false
        v20_2 = nil
        v150_10.StopAutoGas()
        v128_2()
    end
    return
end)
v56_2.AutoResetStreak = v152_7:AddToggle("Auto Reset Kill Streak (>1000)", function(p1)
    v150_10.AutoResetStreak = p1
    v9_4("AutoResetStreak", p1)
    if not p1 then
        v150_10.BreakingStreak = false
    else
        task.spawn(v150_10.CheckAutoResetStreak)
    end
    return
end)
v56_2.HitAll = v152_7:AddToggle("Hit All", function(p1)
    v59_2 = p1
    v9_4("HitAll", p1)
    return
end)
v152_7:AddLabel("RAID")
v56_2.AutoRaid = v152_7:AddToggle("Auto Raid (Focus Boss)", function(p1)
    v150_10.AutoRaid = p1
    v9_4("AutoRaid", p1)
    if p1 then
        if not v18_4 then
            if v56_2.AutoFarm then
                v56_2.AutoFarm:SetState(true)
            else
                v18_4 = true
                v22_2 = true
                v116_4(v23_2)
                v150_10.StartAutoGas()
                task.spawn(v148_4)
            end
        end
        v40_2 = true
        v9_4("AutoOpenRaidChests", true)
        if v56_2.AutoOpenRaidChests then
            v56_2.AutoOpenRaidChests:SetState(true)
        end
        v114_3()
    end
    return
end)
v56_2.DistanceToTitanSlider = v152_7:AddSlider("Distance to Titan", 0, 300, v8_6("DistanceToTitan"), function(p1)
    v60_2 = p1
    v9_4("DistanceToTitan", p1)
    return
end)
v56_2.AutoReload = v152_7:AddToggle("Auto Reload", function(p1)
    v25_2 = p1
    v9_4("AutoReload", p1)
    return
end)
v56_2.DelayToKill = v152_7:AddToggle("Delay To Kill", function(p1)
    v57_3 = p1
    v9_4("DelayToKill", p1)
    return
end)
v56_2.DelayToKillSlider = v152_7:AddSlider("Delay(s)", 0, 300, v8_6("DelayToKillAmount"), function(p1)
    v58_2 = p1
    v9_4("DelayToKillAmount", p1)
    return
end)
v56_2.ExpandNapeHitbox = v152_7:AddToggle("Expand Nape Hitbox", function(p1)
    v22_2 = p1
    v9_4("ExpandNapeHitbox", p1)
    if not p1 then
        v117_4()
    else
        v116_4()
    end
    return
end)
v56_2.HitboxSizeSlider = v152_7:AddSlider("Hitbox Size", 20, 100, v8_6("HitboxSize"), function(p1)
    v23_2 = p1
    v9_4("HitboxSize", p1)
    if v22_2 then
        v116_4()
    end
    return
end)
v56_2.VisualizeHitbox = v152_7:AddToggle("Visualize Hitbox", function(p1)
    v24_2 = p1
    v9_4("VisualizeHitbox", p1)
    if not p1 then
        v118_4()
    end
    return
end)
v152_7:AddLabel("WAVES")
v152_7:AddButton("TP To Base", function()
    local v1_2 = v71_3()
    local v2 = v1_2 and v1_2:FindFirstChild("HumanoidRootPart")
    if v2 then
        v2.CFrame = CFrame.new(-843, 4, 360)
    end
    return
end)
v56_2.AutoVoteReady = v152_7:AddToggle("Auto Vote Ready", function(p1)
    v61_2.AutoVoteReady = p1
    v9_4("AutoVoteReady", p1)
    if p1 then
        task.spawn(v130_4)
        v62_3()
    end
    return
end)
v56_2.AutoUpgradeMaxHQHP = v152_7:AddToggle("Auto Upgrade Max HQ HP", function(p1)
    v61_2.AutoUpgradeMaxHQHP = p1
    v9_4("AutoUpgradeMaxHQHP", p1)
    if p1 then
        v62_3()
    end
    return
end)
v56_2.AutoUpgradeHQHealthRegen = v152_7:AddToggle("Auto Upgrade HQ Health Regen", function(p1)
    v61_2.AutoUpgradeHQHealthRegen = p1
    v9_4("AutoUpgradeHQHealthRegen", p1)
    if p1 then
        v62_3()
    end
    return
end)
v56_2.AutoUpgradeRefillLimit = v152_7:AddToggle("Auto Upgrade Refill Limit", function(p1)
    v61_2.AutoUpgradeRefillLimit = p1
    v9_4("AutoUpgradeRefillLimit", p1)
    if p1 then
        v62_3()
    end
    return
end)
v56_2.AutoUpgradeWeapon = v152_7:AddToggle("Auto Upgrade Weapon", function(p1)
    v61_2.AutoUpgradeWeapon = p1
    v9_4("AutoUpgradeWeapon", p1)
    if p1 then
        v62_3()
    end
    return
end)
v56_2.UpgradeDelaySlider = v152_7:AddSlider("Upgrade Delay", 0, 30, v8_6("UpgradeDelay") or 0, function(p1)
    v61_2.UpgradeDelay = p1
    v9_4("UpgradeDelay", p1)
    return
end)
v56_2.AutoGetRetrieveSkillCrate = v152_7:AddToggle("Auto Get & Retrieve Skill Crate", function(p1)
    v61_2.AutoGetRetrieveSkillCrate = p1
    v9_4("AutoGetRetrieveSkillCrate", p1)
    if p1 then
        v62_3()
        task.spawn(v63_9)
    end
    return
end)
v153_9:AddLabel("LANGUAGE / SETTINGS")
v56_2.LanguageDropdown = v153_9:AddSingleDropdown("Language / Ngôn Ngữ", { "English", "Tiếng Việt" },
    v150_9.GetLanguage(), function(p1)
        v150_9.SetLanguage(p1)
        return
    end)
v153_9:AddLabel("VARIOUS")
v56_2.TitanESP = v153_9:AddToggle("Titan ESP", function(p1)
    v21_2 = p1
    v9_4("TitanESP", p1)
    if not p1 then
        v149_8()
    end
    return
end)
v56_2.ChangeCursor = v153_9:AddToggle("Change Cursor", function(p1)
    v37_2 = p1
    v9_4("ChangeCursor", p1)
    if p1 then
        v108_3()
    else
        v109_2()
    end
    return
end)
v56_2.AutoRefill = v153_9:AddToggle("Auto Refill", function(p1)
    v34_2 = p1
    v9_4("AutoRefill", p1)
    if not p1 then
        v36_2 = nil
    end
    return
end)
v56_2.AutoRetry = v153_9:AddToggle("Auto Retry", function(p1)
    v38_2 = p1
    v9_4("AutoRetry", p1)
    if p1 then
        v110_3()
    else
        v111_3()
    end
    return
end)
v56_2.AutoSkipCutscenes = v153_9:AddToggle("Auto Skip Cutscenes", function(p1)
    v39_2 = p1
    v9_4("AutoSkipCutscenes", p1)
    if p1 then
        v112_3()
    else
        v113_3()
    end
    return
end)
v56_2.AutoOpenRaidChests = v153_9:AddToggle("Auto Open Raid Chests", function(p1)
    v40_2 = p1
    v9_4("AutoOpenRaidChests", p1)
    if p1 then
        v114_3()
    else
        v115_3()
    end
    return
end)
v56_2.AutoClaimAchievements = v153_9:AddToggle("Auto Claim Achievements", function(p1)
    v150_10.AutoClaimAchievements = p1
    v9_4("AutoClaimAchievements", p1)
    if p1 then
        if v150_10.ClaimAchievements then
            v150_10.ClaimAchievements()
        end
    end
    return
end)
local v180_68 = {
    AllFamilies = {},
    TierMap = {},
    TiersList = {
        "Common",
        "Rare",
        "Epic",
        "Legendary",
        "Mythic",
        "Secret"
    }
}
if #v180_68.AllFamilies == 0 then
    v180_68.AllFamilies = {
        "Ackerman",
        "Arlert",
        "Azumabito",
        "Boyega",
        "Bozado",
        "Braun",
        "Braus",
        "Finger",
        "Fritz",
        "Galliard",
        "Grice",
        "Helos",
        "Hume",
        "Iglehaut",
        "Inocenio",
        "Kirstein",
        "Kruger",
        "Ksaver",
        "Leonhart",
        "Munsell",
        "Pikale",
        "Ral",
        "Reeves",
        "Reiss",
        "Shiki",
        "Smith",
        "Springer",
        "Tybur",
        "Yeager",
        "Zoe"
    }
    for v185_17, v186_17 in pairs({
        Legendary = { "Yeager", "Ackerman", "Reiss" },
        Common = {
            "Reeves",
            "Blouse",
            "Inocenio",
            "Munsell",
            "Boyega",
            "Ral",
            "Bozado",
            "Pikale",
            "Hume",
            "Iglehaut"
        },
        Epic = {
            "Galliard",
            "Zoe",
            "Leonhart",
            "Tybur",
            "Ksaver",
            "Braun",
            "Finger",
            "Arlert"
        },
        Secret = { "Shiki" },
        Mythic = { "Helos", "Fritz" },
        Rare = {
            "Braus",
            "Kruger",
            "Azumabito",
            "Smith",
            "Grice",
            "Springer",
            "Kirstein"
        }
    }) do
        for _, fName in ipairs(v186_17) do
            v180_68.TierMap[fName] = v185_17
        end
    end
end
task.spawn(function()
    pcall(function()
        local mod = v16_15:FindFirstChild("Modules") and v16_15.Modules:FindFirstChild("Storage") and
            v16_15.Modules.Storage:FindFirstChild("Families")
        if not mod then return end
        for v5, v6 in pairs(require(mod)) do
            if type(v6) == "table" then
                for v10 in pairs(v6) do
                    v180_68.TierMap[v10] = v5
                end
            end
        end
    end)
end)
local function v181_44(p1, p2)
    local v3 = nil
    pcall(function()
        local v1_3 = game:GetService("CoreGui")
        Instance.new("Folder", v1_3):Destroy()
        v3 = v1_3
        return
    end)
    if not v3 then
        v3 = v7_13:FindFirstChildOfClass("PlayerGui") or v7_13:WaitForChild("PlayerGui", 3)
    end
    if not v3 then
        return
    end
    local v4_9 = v3:FindFirstChild("Symbiote_FamilyFoundNotify")
    if v4_9 then
        v4_9:Destroy()
    end
    local v5_7 = Instance.new("ScreenGui")
    v5_7.Name = "Symbiote_FamilyFoundNotify"
    v5_7.ResetOnSpawn = false
    v5_7.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    v5_7.Parent = v3
    local v6_11 = Instance.new("Frame")
    v6_11.Size = UDim2.new(0, 280, 0, 52)
    v6_11.Position = UDim2.new(0.5, 0, 0.88, 0)
    v6_11.AnchorPoint = Vector2.new(0.5, 0.5)
    v6_11.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
    v6_11.BackgroundTransparency = 1
    v6_11.BorderSizePixel = 0
    v6_11.Parent = v5_7
    local v7_17 = Instance.new("UIStroke")
    v7_17.Color = Color3.fromRGB(140, 60, 255)
    v7_17.Thickness = 1.5
    v7_17.Transparency = 1
    v7_17.Parent = v6_11
    local v8_17 = Instance.new("Frame")
    v8_17.Size = UDim2.new(0, 4, 0.65, 0)
    v8_17.Position = UDim2.new(0, 8, 0.5, 0)
    v8_17.AnchorPoint = Vector2.new(0, 0.5)
    v8_17.BackgroundColor3 = Color3.fromRGB(80, 220, 150)
    v8_17.BackgroundTransparency = 1
    v8_17.BorderSizePixel = 0
    v8_17.Parent = v6_11
    local v9_20 = Instance.new("TextLabel")
    v9_20.Text = "Family found!"
    v9_20.Size = UDim2.new(1, -26, 0, 20)
    v9_20.Position = UDim2.new(0, 22, 0, 7)
    v9_20.BackgroundTransparency = 1
    v9_20.TextColor3 = Color3.fromRGB(80, 220, 150)
    v9_20.TextTransparency = 1
    local v12_7 = Enum
    v9_20.Font = v12_7.Font.GothamBold
    v9_20.TextSize = 14
    v9_20.TextXAlignment = v12_7.TextXAlignment.Left
    v9_20.Parent = v6_11
    local v10_28 = Instance.new("TextLabel")
    v10_28.Text = string.format("%s (%s)", tostring(p1), tostring(p2))
    v10_28.Size = UDim2.new(1, -26, 0, 18)
    v10_28.Position = UDim2.new(0, 22, 0, 27)
    v10_28.BackgroundTransparency = 1
    v10_28.TextColor3 = Color3.fromRGB(245, 240, 255)
    v10_28.TextTransparency = 1
    local v13_11 = Enum
    v10_28.Font = v13_11.Font.GothamMedium
    v10_28.TextSize = 12
    v10_28.TextXAlignment = v13_11.TextXAlignment.Left
    v10_28.Parent = v6_11
    local v11_33 = game:GetService("TweenService")
    local v16_2 = Enum
    local v12_20 = TweenInfo.new(0.25, v16_2.EasingStyle.Quart, v16_2.EasingDirection.Out)
    v11_33:Create(v6_11, v12_20, { Position = UDim2.new(0.5, 0, 0.84, 0), BackgroundTransparency = 0.1 }):Play()
    v11_33:Create(v7_17, v12_20, { Transparency = 0 }):Play()
    v11_33:Create(v8_17, v12_20, { BackgroundTransparency = 0 }):Play()
    v11_33:Create(v9_20, v12_20, { TextTransparency = 0 }):Play()
    v11_33:Create(v10_28, v12_20, { TextTransparency = 0 }):Play()
    task.delay(5, function()
        if not v5_7 or not v5_7.Parent then
            return
        end
        local v5 = Enum
        local v1_3 = TweenInfo.new(0.25, v5.EasingStyle.Quart, v5.EasingDirection.In)
        local v2_7 = v11_33:Create(v6_11, v1_3, { Position = UDim2.new(0.5, 0, 0.88, 0), BackgroundTransparency = 1 })
        v11_33:Create(v7_17, v1_3, { Transparency = 1 }):Play()
        v11_33:Create(v8_17, v1_3, { BackgroundTransparency = 1 }):Play()
        v11_33:Create(v9_20, v1_3, { TextTransparency = 1 }):Play()
        v11_33:Create(v10_28, v1_3, { TextTransparency = 1 }):Play()
        v2_7:Play()
        v2_7.Completed:Connect(function()
            if v5_7 and v5_7.Parent then
                v5_7:Destroy()
            end
            return
        end)
        return
    end)
    return
end
local function v182_47(p1, p2)
    if type(p1) ~= "table" or not p2 then
        return false
    end
    if p1[p2] == true then
        return true
    end
    for v6, v7 in pairs(p1) do
        if v7 == p2 or v6 == p2 and v7 == true then
            return true
        end
    end
    return false
end
local v183_48 = nil
local function v184_20()
    local v1_3 = v7_13:FindFirstChild("PlayerGui")
    local v2 = v1_3 and v1_3:FindFirstChild("Interface") and v1_3.Interface:FindFirstChild("Customisation")
    return v2 and v2:FindFirstChild("Family") or nil
end
do
    local function v185_26()
        if v183_48 then
            return
        end
        v183_48 = task.spawn(function()
            while v42_2 do
                local v1_3 = v184_20()
                local v3 = v1_3 and v1_3:FindFirstChild("Pity")
                local v2
                if v3 and v3:IsA("TextLabel") and v3.Text:upper():find("LEGENDARY") then
                    v2 = "Lucky"
                else
                    v2 = "Normal"
                end
                local v3_3, v4_11, v5_5, v6_3, v7, v8 = pcall(function()
                    return v69_2:InvokeServer("Family", "Roll", v2)
                end)
                local v9 = nil
                local v10 = nil
                local v11 = nil
                local v12 = nil
                local v13 = 0
                local v14 = nil
                if v3_3 then
                    if type(v4_11) == "table" and type(v5_5) == "string" then
                        v10 = v4_11
                        v9 = v5_5
                        v11 = type(v6_3) == "table" and v6_3 or nil
                        v12 = v8
                        local v15_10 = v10[v2] or v10.Normal
                        if type(v15_10) == "table" then
                            v13 = (tonumber(v15_10.Amount) or 0) + (tonumber(v15_10.Free) or 0)
                        end
                        if v11 then
                            v14 = v11[v2] or v11.Normal
                        end
                    elseif type(v6_3) == "string" then
                        v9 = v6_3
                        v13 = (tonumber(v4_11) or 0) + (tonumber(v5_5) or 0)
                        v14 = tonumber(v7)
                    end
                end
                if type(v9) == "string" and v9 ~= "" then
                    local v15_6 = v180_68.TierMap[v9] or "Common"
                    if v67_2 then
                        pcall(function()
                            local v1_2 = v71_3()
                            local v2_2 = v1_2 and v1_2:FindFirstChild("Actor") or v66 and v66()[1]
                            if v2_2 then
                                v2_2:SetAttribute("Symbiote_RollSync", v5_6:JSONEncode({
                                    Currency = v2,
                                    Spins = v10,
                                    TotalSpins = v13,
                                    Family = v9,
                                    Pity = v11,
                                    PityVal = v14,
                                    SpinLuck = v12
                                }))
                                v67_2(v2_2,
                                    "                                pcall(function()\n                                    local p = game:GetService(\"Players\")\n                                    local lp = p.LocalPlayer\n                                    local chars = workspace:FindFirstChild(\"Characters\")\n                                    local c = (chars and chars:FindFirstChild(lp.Name)) or lp.Character\n                                    local act = c and c:FindFirstChild(\"Actor\")\n                                    local raw = act and act:GetAttribute(\"Symbiote_RollSync\")\n                                    if not raw then return end\n                                    local http = game:GetService(\"HttpService\")\n                                    local sync = http:JSONDecode(raw)\n                                    local host = _G.__CachedCustHost\n                                    if type(host) ~= \"table\"\n                                        or type(rawget(host, \"Modules\")) ~= \"table\"\n                                        or not host.Modules.Customisation\n                                    then\n                                        host = nil\n                                        _G.__CachedCustHost = nil\n                                        for _, v in ipairs(getgc(true)) do\n                                            if type(v) == \"table\"\n                                                and type(rawget(v, \"Cache\")) == \"table\"\n                                                and type(rawget(v, \"Modules\")) == \"table\"\n                                                and v.Modules.Customisation\n                                            then\n                                                host = v\n                                                _G.__CachedCustHost = v\n                                                break\n                                            end\n                                        end\n                                    end\n                                    if host then\n                                        local custMod = host.Modules.Customisation\n                                        local updMod = host.Modules.Update\n                                        local data, slot = nil, nil\n                                        if updMod and type(updMod.Get_Data) == \"function\" then\n                                            data, slot = updMod.Get_Data(host, true)\n                                        elseif type(host.Cache) == \"table\" and type(host.Cache.Data) == \"table\" then\n                                            data = host.Cache.Data\n                                            slot = data.Slots and data.Current_Slot and data.Slots[data.Current_Slot]\n                                        end\n                                        if type(data) == \"table\" then\n                                            if type(sync.Spins) == \"table\" then\n                                                data.Spins = sync.Spins\n                                            end\n                                            if sync.SpinLuck ~= nil then\n                                                data.Spin_Luck = sync.SpinLuck\n                                            end\n                                        end\n                                        if type(slot) == \"table\" and type(slot.Avatar) == \"table\" then\n                                            slot.Avatar.Family = sync.Family\n                                            if type(sync.Pity) == \"table\" then\n                                                slot.Avatar.Pity = sync.Pity\n                                            end\n                                        end\n                                        local pgui = game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"PlayerGui\")\n                                        local cust = pgui and pgui:FindFirstChild(\"Interface\") and pgui.Interface:FindFirstChild(\"Customisation\")\n                                        local fUI = cust and cust:FindFirstChild(\"Family\")\n                                        if custMod then\n                                            custMod.Spinning = false\n                                            if fUI then\n                                                if custMod.Rates and host.Services and host.Services.W and data then\n                                                    pcall(function()\n                                                        custMod.Rates(host, fUI, host.Services.W, data)\n                                                    end)\n                                                end\n                                                if custMod.Family_Details then\n                                                    pcall(function()\n                                                        custMod.Family_Details(host, fUI, true, false)\n                                                    end)\n                                                end\n                                            end\n                                        end\n                                    end\n                                end)\n                            ")
                            end
                            return
                        end)
                    end
                    pcall(function()
                        local v1 = v184_20()
                        if v1 then
                            local v2_2 = v1:FindFirstChild("Family") and v1.Family:FindFirstChild("Title")
                            if v2_2 and v2_2:IsA("TextLabel") then
                                v2_2.Text = string.upper(v9) .. " (" .. v15_6 .. ")"
                                v2_2.Visible = true
                            end
                            local v3_7 = v1:FindFirstChild("Buttons") or v1:FindFirstChild("Buttons_2")
                            local v4_7 = v3_7 and v3_7:FindFirstChild("Roll")
                            local v5_8 = v4_7 and v4_7:FindFirstChild("Title")
                            if v5_8 and v5_8:IsA("TextLabel") then
                                v5_8.Text = "ROLL (" .. tostring(v13) .. ")"
                            end
                            local v6_8 = v1:FindFirstChild("Pity")
                            if v6_8 and v6_8:IsA("TextLabel") and v14 ~= nil then
                                if v2 == "Lucky" then
                                    v6_8.Text = "LEGENDARY+ PITY: " .. tostring(v14) .. "/100"
                                else
                                    v6_8.Text = "EPIC+ PITY: " .. tostring(v14) .. "/400"
                                end
                            end
                        end
                        return
                    end)
                    if v182_47(v43_2, v9) or v182_47(v44_3, v15_6) then
                        v42_2 = false
                        v183_48 = nil
                        if v56_2.AutoFamilySpin then
                            v56_2.AutoFamilySpin:SetState(false)
                        end
                        v181_44(v9, v15_6)
                        break
                    elseif 0 >= v13 then
                        v42_2 = false
                        v183_48 = nil
                        if v56_2.AutoFamilySpin then
                            v56_2.AutoFamilySpin:SetState(false)
                        end
                        break
                    else
                        task.wait(0.1)
                    end
                else
                    task.wait(0.25)
                end
            end
            v183_48 = nil
            return
        end)
        return
    end
    v153_9:AddLabel("AUTO FAMILY ROLL")
    v56_2.AutoFamilySpin = v153_9:AddToggle("Auto Family Spin", function(p1)
        v42_2 = p1
        if p1 then
            v185_26()
        end
        return
    end)
end
v56_2.FamiliesDropdown = v153_9:AddDropdown("Families To Stop", v180_68.AllFamilies, function(p1)
    v43_2 = p1 or {}
    v9_4("FamiliesToStop", v43_2)
    return
end)
v56_2.FamilyTiersDropdown = v153_9:AddDropdown("Family Tiers To Stop", v180_68.TiersList, function(p1)
    v44_3 = p1 or {}
    v9_4("FamilyTiersToStop", v44_3)
    return
end)
local v186_32 = {
    AllPerks = {},
    RarityMap = {},
    TiersList = {
        "Common",
        "Rare",
        "Epic",
        "Legendary",
        "Mythic"
    }
}
if #v186_32.AllPerks == 0 then
    v186_32.AllPerks = {
        "Adaptation",
        "Adrenaline",
        "Aegis",
        "Art of War",
        "Black Flash",
        "Blessed",
        "Butcher",
        "Carnifex",
        "Courage Catalyst",
        "Cripple",
        "Critical Hunter",
        "Enduring",
        "Enhanced Metabolism",
        "Everlasting Flame",
        "Eviscerate",
        "Exhumation",
        "Experimental Shells",
        "First Aid",
        "Flame Rhapsody",
        "Flawed Release",
        "Focus",
        "Font of Inspiration",
        "Font of Vitality",
        "Forceful",
        "Fortitude",
        "Founder's Blessing",
        "Fully Stocked",
        "Gear Beginner",
        "Gear Expert",
        "Gear Intermediate",
        "Gear Master",
        "Hardy",
        "Heavenly Restriction",
        "Heightened Vitality",
        "Hollow",
        "Immortal",
        "Indefatigable",
        "Invincible",
        "Kengo",
        "Lightweight",
        "Lucky",
        "Luminous",
        "Mangle",
        "Maximum Firepower",
        "Mighty",
        "Munitions Expert",
        "Munitions Master",
        "Mutilate",
        "Peerless Commander",
        "Peerless Constitution",
        "Peerless Focus",
        "Peerless Strength",
        "Perfect Form",
        "Perfect Soul",
        "Protection",
        "Reckless Abandon",
        "Resilient",
        "Robust",
        "Safeguard",
        "Sanctified",
        "Siphoning",
        "Sixth Sense",
        "Solo",
        "Soulfeed",
        "Speedy",
        "Stalwart Durability",
        "Tatsujin",
        "Tough",
        "Trauma Battery",
        "Tyrant's Stare",
        "Unbreakable",
        "Unyielding",
        "Unparalleled Strength",
        "Unwavering Belief",
        "Warchief",
        "Warrior",
        "Wind Rhapsody"
    }
    for v191_9, v192_7 in pairs({
        Common = {
            "Cripple",
            "Enduring",
            "Enhanced Metabolism",
            "First Aid",
            "Fortitude",
            "Gear Beginner",
            "Hollow",
            "Lucky",
            "Mighty"
        },
        Rare = {
            "Blessed",
            "Critical Hunter",
            "Experimental Shells",
            "Forceful",
            "Fully Stocked",
            "Gear Intermediate",
            "Heightened Vitality",
            "Lightweight",
            "Mangle",
            "Protection",
            "Tough",
            "Unyielding"
        },
        Epic = {
            "Adrenaline",
            "Butcher",
            "Flawed Release",
            "Focus",
            "Gear Expert",
            "Hardy",
            "Luminous",
            "Munitions Expert",
            "Mutilate",
            "Peerless Strength",
            "Reckless Abandon",
            "Resilient",
            "Safeguard",
            "Siphoning",
            "Solo",
            "Speedy",
            "Stalwart Durability",
            "Trauma Battery",
            "Unbreakable",
            "Warrior"
        },
        Legendary = {
            "Aegis",
            "Carnifex",
            "Courage Catalyst",
            "Eviscerate",
            "Exhumation",
            "Flame Rhapsody",
            "Font of Vitality",
            "Gear Master",
            "Indefatigable",
            "Invincible",
            "Munitions Master",
            "Peerless Commander",
            "Peerless Constitution",
            "Peerless Focus",
            "Perfect Form",
            "Perfect Soul",
            "Robust",
            "Sanctified",
            "Sixth Sense",
            "Tyrant's Stare",
            "Unparalleled Strength",
            "Warchief",
            "Wind Rhapsody"
        },
        Mythic = {
            "Adaptation",
            "Art of War",
            "Black Flash",
            "Everlasting Flame",
            "Explosive Fortune",
            "Font of Inspiration",
            "Founder's Blessing",
            "Heavenly Restriction",
            "Immortal",
            "Kengo",
            "Maximum Firepower",
            "Soulfeed",
            "Tatsujin",
            "Unwavering Belief"
        }
    }) do
        for _, pName in ipairs(v192_7) do
            v186_32.RarityMap[pName] = v191_9
        end
    end
end
task.spawn(function()
    pcall(function()
        local mod = v16_15:FindFirstChild("Modules") and v16_15.Modules:FindFirstChild("Storage") and
            v16_15.Modules.Storage:FindFirstChild("Perks")
        if not mod then return end
        for v5, v6 in pairs(require(mod)) do
            if type(v6) == "table" then
                for v10 in pairs(v6) do
                    v186_32.RarityMap[v10] = v5
                end
            end
        end
    end)
end)
local function v187_20()
    if not v45_3 then
        return
    end
    local v1_2 = false
    local v2_2 = {}
    if v67_2 then
        pcall(function()
            local v1_3 = v71_3()
            local v2 = v1_3 and v1_3:FindFirstChild("Actor") or v66 and v66()[1]
            if v2 then
                v2:SetAttribute("Symbiote_PerkFilter", v5_6:JSONEncode({ Tiers = v46_2, Specific = v47_3 }))
                v67_2(v2,
                    "                    local p = game:GetService(\"Players\")\n                    local lp = p.LocalPlayer\n                    local chars = workspace:FindFirstChild(\"Characters\")\n                    local c = (chars and chars:FindFirstChild(lp.Name)) or lp.Character\n                    local act = c and c:FindFirstChild(\"Actor\")\n                    local rs = game:GetService(\"ReplicatedStorage\")\n                    local remoteGET = rs:WaitForChild(\"Assets\"):WaitForChild(\"Remotes\"):WaitForChild(\"GET\")\n                    local perksMod = require(rs.Modules.Storage.Perks)\n                    local rarityMap = {}\n                    for r, list in pairs(perksMod) do\n                        if type(list) == \"table\" then\n                            for name in pairs(list) do\n                                rarityMap[name] = r\n                            end\n                        end\n                    end\n\n                    local hostObj = _G.__CachedDataHost\n                    if not hostObj or type(hostObj) ~= \"table\" or type(rawget(hostObj, \"Cache\")) ~= \"table\" or type(rawget(hostObj.Cache, \"Data\")) ~= \"table\" then\n                        hostObj = nil\n                        for _, v in ipairs(getgc(true)) do\n                            if type(v) == \"table\" and type(rawget(v, \"Cache\")) == \"table\" then\n                                local cache = rawget(v, \"Cache\")\n                                if type(rawget(cache, \"Data\")) == \"table\" then\n                                    hostObj = v\n                                    _G.__CachedDataHost = v\n                                    break\n                                end\n                            end\n                        end\n                    end\n\n                    if hostObj and type(hostObj.Cache) == \"table\" and type(hostObj.Cache.Data) == \"table\" then\n                        local data = hostObj.Cache.Data\n                        local currentSlot = data.Current_Slot or 1\n                        local slotData = data.Slots and data.Slots[currentSlot]\n                        if slotData and slotData.Perks and slotData.Perks.Storage then\n                            local equippedIds = {}\n                            for _, eqId in pairs(slotData.Perks.Equipped or {}) do\n                                if eqId and eqId ~= \"\" then\n                                    equippedIds[eqId] = true\n                                end\n                            end\n\n                            local rawFilter = act and act:GetAttribute(\"Symbiote_PerkFilter\")\n                            local http = game:GetService(\"HttpService\")\n                            local filter = rawFilter and http:JSONDecode(rawFilter) or { Tiers = {}, Specific = {} }\n\n                            local batch = {}\n                            local deletedList = {}\n                            for id, info in pairs(slotData.Perks.Storage) do\n                                local name = info.Name\n                                local rarity = rarityMap[name] or \"Common\"\n                                local match = (filter.Tiers[rarity] == true) or (filter.Specific[name] == true)\n                                if match and not equippedIds[id] then\n                                    table.insert(batch, tostring(id))\n                                    table.insert(deletedList, tostring(id))\n                                    if #batch >= 25 then\n                                        local res = remoteGET:InvokeServer(\"S_Equipment\", \"Delete\", \"Perk\", batch)\n                                        if type(res) == \"table\" then\n                                            hostObj.Cache.Data = res\n                                            data = res\n                                            slotData = data.Slots and data.Slots[currentSlot]\n                                        end\n                                        batch = {}\n                                    end\n                                end\n                            end\n                            if #batch > 0 then\n                                local res = remoteGET:InvokeServer(\"S_Equipment\", \"Delete\", \"Perk\", batch)\n                                if type(res) == \"table\" then\n                                    hostObj.Cache.Data = res\n                                end\n                            end\n                            if act then\n                                act:SetAttribute(\"Symbiote_PerkDeleted\", http:JSONEncode(deletedList))\n                            end\n                        end\n                    end\n                ")
                v1_2 = true
                local v3_2 = v2:GetAttribute("Symbiote_PerkDeleted")
                if v3_2 then
                    local v4_7 = v5_6:JSONDecode(v3_2)
                    if type(v4_7) == "table" then
                        for v8_3, v9_4 in ipairs(v4_7) do
                            v2_2[v9_4] = true
                        end
                    end
                end
            end
            return
        end)
    end
    local v3_6 = v7_13:FindFirstChild("PlayerGui")
    local v4_2 = v3_6 and v3_6:FindFirstChild("Interface")
    local v5_3 = v4_2 and v4_2:FindFirstChild("Equipment")
    local v6_3 = v5_3 and v5_3:FindFirstChild("Perk_List")
    local v7_3 = v6_3 and v6_3:FindFirstChild("Holder")
    local v8_3 = v7_3 and v7_3:FindFirstChild("Items")
    if v8_3 then
        local v9_3 = {}
        local v10_3 = {}
        for v14, v15 in ipairs(v8_3:GetChildren()) do
            if v15:IsA("GuiObject") and v15.Name ~= "Grid" then
                local v16_6 = v15:GetAttribute("ID")
                local v17_4 = v15:GetAttribute("Tag") or v15.Name
                local v18_9 = v15:GetAttribute("Rarity") or v186_32.RarityMap[v17_4] or "Common"
                if v16_6 then
                    local v19_8 = tostring(v16_6)
                    if v2_2[v19_8] then
                        v15:Destroy()
                    else
                        local v20_7 = not v1_2
                        if v20_7 then
                            if not v17_4 then
                                v20_7 = false
                            elseif v46_2[v18_9 or v186_32.RarityMap[v17_4] or "Common"] == true then
                                v20_7 = true
                            elseif v47_3[v17_4] == true then
                                v20_7 = true
                            else
                                v20_7 = false
                            end
                        end
                        if v20_7 then
                            table.insert(v9_3, v19_8)
                            table.insert(v10_3, v15)
                        end
                    end
                end
            end
        end
        if #v9_3 > 0 then
            local v11_5 = {}
            for v15_3, v16_4 in ipairs(v9_3) do
                table.insert(v11_5, v16_4)
                if 25 <= #v11_5 or v15_3 == #v9_3 then
                    pcall(function()
                        v69_2:InvokeServer("S_Equipment", "Delete", "Perk", v11_5)
                        return
                    end)
                    v11_5 = {}
                end
            end
            for v15_4, v16_7 in ipairs(v10_3) do
                if v16_7 and v16_7.Parent then
                    v16_7:Destroy()
                end
            end
        end
    end
    return
end
do
    local function v188_24()
        if AutoSellPerksThread then
            return
        end
        AutoSellPerksThread = task.spawn(function()
            while true do
                if v45_3 then
                    v187_20()
                    task.wait(1.5)
                else
                    AutoSellPerksThread = nil
                    return
                end
            end
        end)
        return
    end
    v153_9:AddLabel("AUTO SELL PERKS")
    v56_2.AutoSellPerks = v153_9:AddToggle("Auto Sell Selected Tier Perks", function(p1)
        v45_3 = p1
        v9_4("AutoSellPerks", p1)
        if p1 then
            v187_20()
            v188_24()
        end
        return
    end)
    v56_2.PerkTiersDropdown = v153_9:AddDropdown("Perk Tiers To Sell", v186_32.TiersList, function(p1)
        v46_2 = p1 or {}
        v9_4("PerkTiersToSell", v46_2)
        if v45_3 then
            v187_20()
        end
        return
    end)
    v56_2.SpecificPerksDropdown = v153_9:AddDropdown("Select Perks To Sell", v186_32.AllPerks, function(p1)
        v47_3 = p1 or {}
        v9_4("SpecificPerksToSell", v47_3)
        if v45_3 then
            v187_20()
        end
        return
    end)
    v153_9:AddLabel("THUNDER SPEARS")
    v56_2.AutoCreateTowers = v153_9:AddToggle("Auto Create Towers(Outskirts)", function(p1)
        v48_3 = p1
        v9_4("AutoCreateTowers", p1)
        if p1 then
            v123_4()
            v128_2()
        else
            v52_2 = nil
            v128_2()
        end
        return
    end)
    v56_2.AutoRetrieveSupplyCrates = v153_9:AddToggle("Auto Retrieve Supply Crates(Forest)", function(p1)
        v49_2 = p1
        v9_4("AutoRetrieveSupplyCrates", p1)
        if p1 then
            v51_2()
            task.spawn(v50_2)
        else
            v53_2 = false
        end
        return
    end)
    task.spawn(function()
        local v6_3
        while true do
            local v1_3 = v7_13:FindFirstChild("PlayerGui")
            local v2 = v1_3 and v1_3:FindFirstChild("Interface")
            local v3_3 = v2 and v2:FindFirstChild("Equipment")
            local v4_3 = v3_3 and v3_3:FindFirstChild("Perk_List")
            local v5_3 = v4_3 and v4_3:FindFirstChild("Holder")
            v6_3 = v5_3 and v5_3:FindFirstChild("Items")
            if v6_3 then
                break
            else
                task.wait(1)
            end
        end
        v6_3.ChildAdded:Connect(function(p1)
            if not v45_3 then
                return
            end
            task.delay(0.1, function()
                if not v45_3 then
                    return
                end
                if p1 and p1:IsA("GuiObject") and p1.Name ~= "Grid" then
                    local v1_5 = p1:GetAttribute("Tag") or p1.Name
                    local v2_5 = p1:GetAttribute("Rarity") or v186_32.RarityMap[v1_5] or "Common"
                    local v3_9 = p1:GetAttribute("ID")
                    if v3_9 and (v46_2[v2_5] == true or v47_3[v1_5] == true) then
                        pcall(function()
                            v69_2:InvokeServer("S_Equipment", "Delete", "Perk", { tostring(v3_9) })
                            return
                        end)
                        if p1 and p1.Parent then
                            p1:Destroy()
                        end
                    end
                end
                return
            end)
            return
        end)
        return
    end)
    do
        local GRADE_LETTERS = {
            [0] = "E-",
            [1] = "E",
            [2] = "E+",
            [3] = "D-",
            [4] = "D",
            [5] = "D+",
            [6] = "C-",
            [7] = "C",
            [8] = "C+",
            [9] = "B-",
            [10] = "B",
            [11] = "B+",
            [12] = "A-",
            [13] = "A",
            [14] = "A+",
            [15] = "S-"
        }
        local LETTER_TO_LEVEL = {
            ["E-"] = 0,
            ["E"] = 1,
            ["E+"] = 2,
            ["D-"] = 3,
            ["D"] = 4,
            ["D+"] = 5,
            ["C-"] = 6,
            ["C"] = 7,
            ["C+"] = 8,
            ["B-"] = 9,
            ["B"] = 10,
            ["B+"] = 11,
            ["A-"] = 12,
            ["A"] = 13,
            ["A+"] = 14,
            ["S-"] = 15,
            ["S"] = 15
        }
        local GRADE_ORDER = {
            ["E-"] = 1,
            ["E+"] = 2,
            ["D+"] = 3,
            ["B"] = 4,
            ["A"] = 5,
            ["S"] = 6
        }
        local cachedXPPercent = 0
        local kaitunActionState = "Idle"
        local kaitunLoopThread = nil
        local lastUpgradeAttemptGold = -1
        local lastUpgradeAttemptTime = 0

        local VI_FOLD_PAIRS = {
            { "à", "a" }, { "á", "a" }, { "ả", "a" }, { "ã", "a" }, { "ạ", "a" },
            { "ă", "a" }, { "ằ", "a" }, { "ắ", "a" }, { "ẳ", "a" }, { "ẵ", "a" }, { "ặ", "a" },
            { "â", "a" }, { "ầ", "a" }, { "ấ", "a" }, { "ẩ", "a" }, { "ẫ", "a" }, { "ậ", "a" },
            { "À", "a" }, { "Á", "a" }, { "Ả", "a" }, { "Ã", "a" }, { "Ạ", "a" },
            { "Ă", "a" }, { "Ằ", "a" }, { "Ắ", "a" }, { "Ẳ", "a" }, { "Ẵ", "a" }, { "Ặ", "a" },
            { "Â", "a" }, { "Ầ", "a" }, { "Ấ", "a" }, { "Ẩ", "a" }, { "Ẫ", "a" }, { "Ậ", "a" },
            { "đ", "d" }, { "Đ", "d" },
            { "è", "e" }, { "é", "e" }, { "ẻ", "e" }, { "ẽ", "e" }, { "ẹ", "e" },
            { "ê", "e" }, { "ề", "e" }, { "ế", "e" }, { "ể", "e" }, { "ễ", "e" }, { "ệ", "e" },
            { "È", "e" }, { "É", "e" }, { "Ẻ", "e" }, { "Ẽ", "e" }, { "Ẹ", "e" },
            { "Ê", "e" }, { "Ề", "e" }, { "Ế", "e" }, { "Ể", "e" }, { "Ễ", "e" }, { "Ệ", "e" },
            { "ì", "i" }, { "í", "i" }, { "ỉ", "i" }, { "ĩ", "i" }, { "ị", "i" },
            { "Ì", "i" }, { "Í", "i" }, { "Ỉ", "i" }, { "Ĩ", "i" }, { "Ị", "i" },
            { "ò", "o" }, { "ó", "o" }, { "ỏ", "o" }, { "õ", "o" }, { "ọ", "o" },
            { "ô", "o" }, { "ồ", "o" }, { "ố", "o" }, { "ổ", "o" }, { "ỗ", "o" }, { "ộ", "o" },
            { "ơ", "o" }, { "ờ", "o" }, { "ớ", "o" }, { "ở", "o" }, { "ỡ", "o" }, { "ợ", "o" },
            { "Ò", "o" }, { "Ó", "o" }, { "Ỏ", "o" }, { "Õ", "o" }, { "Ọ", "o" },
            { "Ô", "o" }, { "Ồ", "o" }, { "Ố", "o" }, { "Ổ", "o" }, { "Ỗ", "o" }, { "Ộ", "o" },
            { "Ơ", "o" }, { "Ờ", "o" }, { "Ớ", "o" }, { "Ở", "o" }, { "Ỡ", "o" }, { "Ợ", "o" },
            { "ù", "u" }, { "ú", "u" }, { "ủ", "u" }, { "ũ", "u" }, { "ụ", "u" },
            { "ư", "u" }, { "ừ", "u" }, { "ứ", "u" }, { "ử", "u" }, { "ữ", "u" }, { "ự", "u" },
            { "Ù", "u" }, { "Ú", "u" }, { "Ủ", "u" }, { "Ũ", "u" }, { "Ụ", "u" },
            { "Ư", "u" }, { "Ừ", "u" }, { "Ứ", "u" }, { "Ử", "u" }, { "Ữ", "u" }, { "Ự", "u" },
            { "ỳ", "y" }, { "ý", "y" }, { "ỷ", "y" }, { "ỹ", "y" }, { "ỵ", "y" },
            { "Ỳ", "y" }, { "Ý", "y" }, { "Ỷ", "y" }, { "Ỹ", "y" }, { "Ỵ", "y" }
        }

        local function normalizeVi(str)
            local s = tostring(str or "")
            for _, pair in ipairs(VI_FOLD_PAIRS) do
                s = s:gsub(pair[1], pair[2])
            end
            s = s:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
            return s
        end

        local function getGuiObjectText(obj)
            if not obj then
                return ""
            end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if type(obj.Text) == "string" and obj.Text ~= "" then
                    return obj.Text
                end
            end
            local title = obj:FindFirstChild("Title") or obj:FindFirstChild("Text") or obj:FindFirstChild("Label")
            if title and (title:IsA("TextLabel") or title:IsA("TextButton")) and type(title.Text) == "string" then
                return title.Text
            end
            for _, child in ipairs(obj:GetChildren()) do
                if (child:IsA("TextLabel") or child:IsA("TextButton")) and type(child.Text) == "string" and child.Text ~= "" then
                    return child.Text
                end
            end
            return ""
        end

        local function getDifficultyBracket(minLvl)
            local lvl = math.max(0, math.min(15, math.floor(tonumber(minLvl) or 0)))
            if lvl <= 1 then
                return {
                    Grade = "E-",
                    DiffEN = "Easy",
                    DiffVI = "Dễ (E- Grade)",
                    NextMinLvl = 2,
                    NextGrade = "E+",
                    Order = 1
                }
            elseif lvl <= 4 then
                return {
                    Grade = "E+",
                    DiffEN = "Normal",
                    DiffVI = "Bình thường (E+ Grade)",
                    NextMinLvl = 5,
                    NextGrade = "D+",
                    Order = 2
                }
            elseif lvl <= 9 then
                return {
                    Grade = "D+",
                    DiffEN = "Hard",
                    DiffVI = "Khó (D+ Grade)",
                    NextMinLvl = 10,
                    NextGrade = "B",
                    Order = 3
                }
            elseif lvl <= 12 then
                return {
                    Grade = "B",
                    DiffEN = "Severe",
                    DiffVI = "Khốc liệt (B Grade)",
                    NextMinLvl = 13,
                    NextGrade = "A",
                    Order = 4
                }
            elseif lvl <= 14 then
                return {
                    Grade = "A",
                    DiffEN = "Aberrant",
                    DiffVI = "Dị thường (A Grade)",
                    NextMinLvl = 15,
                    NextGrade = "S",
                    Order = 5
                }
            else
                return {
                    Grade = "S",
                    DiffEN = "Aberrant",
                    DiffVI = "Cấp S (S Grade)",
                    NextMinLvl = nil,
                    NextGrade = nil,
                    Order = 6
                }
            end
        end

        local function getGoldNeededForLevel(fromLvl, toLvl)
            if not toLvl or toLvl <= fromLvl then
                return 0
            end
            local costTbl = v150_10.UpgradeCostTable or {}
            local total = 0
            for step = math.max(1, fromLvl + 1), math.min(15, toLvl) do
                total = total + 8 * (tonumber(costTbl[step]) or 169420)
            end
            return total
        end

        local function fireButtonSignalsDirect(target)
            if not target then
                return false
            end
            local fired = false
            local cx = math.floor((target.AbsolutePosition and target.AbsolutePosition.X or 0) + (target.AbsoluteSize and target.AbsoluteSize.X / 2 or 0))
            local cy = math.floor((target.AbsolutePosition and target.AbsolutePosition.Y or 0) + (target.AbsoluteSize and target.AbsoluteSize.Y / 2 or 0))
            local v2Pos = Vector2.new(cx, cy)
            local v3Pos = Vector3.new(cx, cy, 0)

            if type(firesignal) == "function" then
                pcall(function() firesignal(target.MouseButton1Click) fired = true end)
                pcall(function() firesignal(target.Activated) fired = true end)
                pcall(function() firesignal(target.MouseButton1Down) firesignal(target.MouseButton1Up) fired = true end)
                pcall(function() firesignal(target.TouchTap) fired = true end)
                pcall(function()
                    firesignal(target.InputBegan, {
                        UserInputType = Enum.UserInputType.MouseButton1,
                        UserInputState = Enum.UserInputState.Begin,
                        Position = v3Pos
                    })
                    firesignal(target.InputEnded, {
                        UserInputType = Enum.UserInputType.MouseButton1,
                        UserInputState = Enum.UserInputState.End,
                        Position = v3Pos
                    })
                    fired = true
                end)
                pcall(function()
                    firesignal(target.InputBegan, {
                        UserInputType = Enum.UserInputType.Touch,
                        UserInputState = Enum.UserInputState.Begin,
                        Position = v3Pos
                    })
                    firesignal(target.InputEnded, {
                        UserInputType = Enum.UserInputType.Touch,
                        UserInputState = Enum.UserInputState.End,
                        Position = v3Pos
                    })
                    fired = true
                end)
            end
            if type(getconnections) == "function" then
                for _, sigName in ipairs({ "MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up", "TouchTap", "InputBegan", "InputEnded" }) do
                    pcall(function()
                        local sig = target[sigName]
                        if sig then
                            for _, conn in ipairs(getconnections(sig)) do
                                if conn.Fire then pcall(conn.Fire, conn) fired = true end
                                if conn.Function then pcall(conn.Function) fired = true end
                            end
                        end
                    end)
                end
            end
            pcall(function()
                local vu = game:GetService("VirtualUser")
                if vu then
                    vu:CaptureController()
                    vu:Button1Down(v2Pos)
                    task.wait(0.02)
                    vu:Button1Up(v2Pos)
                    fired = true
                end
            end)
            return fired
        end

        function v150_10.ClickGuiButton(btn)
            if not btn then
                return false
            end
            local targetBtn = (btn:IsA("GuiButton") and btn)
                or btn:FindFirstAncestorWhichIsA("GuiButton")
                or btn:FindFirstChildWhichIsA("GuiButton", true)
                or btn

            local clicked = fireButtonSignalsDirect(btn)
            if targetBtn ~= btn then
                if fireButtonSignalsDirect(targetBtn) then
                    clicked = true
                end
            end

            local char = v71_3()
            local act = (char and char:FindFirstChild("Actor")) or (v66 and v66()[1])
            if act and v67_2 then
                clicked = true
                task.spawn(function()
                    pcall(function()
                        targetBtn:SetAttribute("Symbiote_ClickTarget", true)
                        btn:SetAttribute("Symbiote_ClickTarget", true)
                        v67_2(act, [[
                            local lp = game:GetService("Players").LocalPlayer
                            local pgui = lp and lp:FindFirstChild("PlayerGui")
                            local iface = pgui and pgui:FindFirstChild("Interface")
                            if not iface then return end
                            for _, obj in ipairs(iface:GetDescendants()) do
                                if obj:GetAttribute("Symbiote_ClickTarget") == true then
                                    obj:SetAttribute("Symbiote_ClickTarget", nil)
                                    local targets = { obj }
                                    local ab = obj:FindFirstAncestorWhichIsA("GuiButton")
                                    if ab then table.insert(targets, ab) end
                                    local cb = obj:FindFirstChildWhichIsA("GuiButton", true)
                                    if cb then table.insert(targets, cb) end
                                    for _, t in ipairs(targets) do
                                        if type(firesignal) == "function" then
                                            pcall(function() firesignal(t.MouseButton1Click) end)
                                            pcall(function() firesignal(t.Activated) end)
                                            pcall(function() firesignal(t.MouseButton1Down) end)
                                            pcall(function() firesignal(t.MouseButton1Up) end)
                                            pcall(function() firesignal(t.TouchTap) end)
                                        end
                                        if type(getconnections) == "function" then
                                            for _, sigName in ipairs({ "MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up", "TouchTap" }) do
                                                local sig = t[sigName]
                                                if sig then
                                                    pcall(function()
                                                        for _, conn in ipairs(getconnections(sig)) do
                                                            if conn.Fire then pcall(conn.Fire, conn) end
                                                            if conn.Function then pcall(conn.Function) end
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        ]])
                    end)
                end)
            end

            pcall(function()
                local clickObj = (targetBtn.AbsoluteSize and targetBtn.AbsoluteSize.X > 0 and targetBtn) or btn
                if clickObj.AbsolutePosition and clickObj.AbsoluteSize and clickObj.AbsoluteSize.X > 0 and clickObj.AbsoluteSize.Y > 0 then
                    local cx = math.floor(clickObj.AbsolutePosition.X + (clickObj.AbsoluteSize.X / 2))
                    local cy = math.floor(clickObj.AbsolutePosition.Y + (clickObj.AbsoluteSize.Y / 2))
                    if v17_6 and type(v17_6.SendMouseButtonEvent) == "function" then
                        v17_6:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                        task.wait(0.04)
                        v17_6:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                    end
                    local vu = game:GetService("VirtualUser")
                    if vu then
                        vu:CaptureController()
                        vu:ClickButton1(Vector2.new(cx, cy))
                    end
                    clicked = true
                end
            end)
            return clicked
        end

        local function isTrulyVisible(obj, root)
            if not obj or not obj.Parent then
                return false
            end
            local cur = obj
            local reachedRoot = (root == nil)
            while cur do
                if cur:IsA("GuiObject") and cur.Visible == false then
                    return false
                end
                if root and cur == root then
                    reachedRoot = true
                    break
                end
                cur = cur.Parent
            end
            return reachedRoot
        end

        v150_10.ShadowBanData = {
            IsBanned = false,
            Reason = "Clean (No Shadow Ban detected)",
            LastChecked = 0,
            CheckCount = 0
        }

        function v150_10.CheckShadowBan(isManual)
            local lp = v7_13 or v6_21.LocalPlayer
            local isVi = v150_9.IsVietnamese()
            local detected = false
            local reason = ""

            pcall(function()
                if lp then
                    local bannedAttr = lp:GetAttribute("ShadowBanned")
                        or lp:GetAttribute("ShadowBan")
                        or lp:GetAttribute("IsShadowBanned")
                        or lp:GetAttribute("Flagged")
                        or lp:GetAttribute("RewardBan")
                        or lp:GetAttribute("RewardsDisabled")
                    if bannedAttr == true or (type(bannedAttr) == "string" and string.lower(bannedAttr):find("ban")) then
                        detected = true
                        reason = "Player Attribute: " .. tostring(bannedAttr)
                        return
                    end

                    local gm = lp:GetAttribute("GoldMultiplier")
                    local xm = lp:GetAttribute("ExpMultiplier")
                    local dm = lp:GetAttribute("DropMultiplier")
                    if (type(gm) == "number" and gm == 0) or (type(xm) == "number" and xm == 0) or (type(dm) == "number" and dm == 0) then
                        detected = true
                        reason = "Hệ số thưởng bị ép về 0 (Gold/XP/Drop = 0)"
                        return
                    end

                    -- Check Trade Ban / Trade Locked
                    local tradeAttr = lp:GetAttribute("TradingDisabled")
                        or lp:GetAttribute("TradeDisabled")
                        or lp:GetAttribute("TradeLock")
                        or lp:GetAttribute("TradeBanned")
                        or lp:GetAttribute("IsTradeBanned")
                    if tradeAttr == true or (type(tradeAttr) == "string" and string.lower(tradeAttr):find("ban")) then
                        detected = true
                        reason = "Bị khóa Giao Dịch (Trade Banned/Locked)"
                        return
                    end
                    if lp:GetAttribute("CanTrade") == false then
                        detected = true
                        reason = "Không thể giao dịch (CanTrade = false)"
                        return
                    end

                    -- Check Friend / Party / Matchmaking restriction (Không chơi với bạn bè được)
                    local partyAttr = lp:GetAttribute("PartyDisabled")
                        or lp:GetAttribute("PartyBlocked")
                        or lp:GetAttribute("MatchmakingDisabled")
                        or lp:GetAttribute("MatchmakingBanned")
                        or lp:GetAttribute("FriendsDisabled")
                        or lp:GetAttribute("MultiplayerDisabled")
                    if partyAttr == true or (type(partyAttr) == "string" and string.lower(partyAttr):find("ban")) then
                        detected = true
                        reason = "Bị cấm chơi cùng bạn bè (Party/Matchmaking Restricted)"
                        return
                    end
                    if lp:GetAttribute("CanJoinFriends") == false then
                        detected = true
                        reason = "Không thể tham gia cùng bạn bè (CanJoinFriends = false)"
                        return
                    end

                    local char = lp.Character
                    if char then
                        local charBan = char:GetAttribute("ShadowBanned") or char:GetAttribute("ShadowBan") or
                            char:GetAttribute("IsShadowBanned")
                        if charBan == true then
                            detected = true
                            reason = "Character Attribute: ShadowBanned = true"
                            return
                        end
                    end
                end

                local host = _G.__CachedDataHost or _G.__CachedCustHost or _G.__CachedHost
                if type(host) == "table" and type(rawget(host, "Cache")) == "table" and type(rawget(host.Cache, "Data")) == "table" then
                    local data = host.Cache.Data
                    if data.ShadowBanned == true or data.IsShadowBanned == true or data.RewardsDisabled == true or data.Flagged == true then
                        detected = true
                        reason = "Game Cache Data: ShadowBanned/Flagged = true"
                        return
                    end
                    if data.TradingDisabled == true or data.TradeDisabled == true or data.TradeLock == true or data.TradeBanned == true or data.CanTrade == false then
                        detected = true
                        reason = "Game Cache: Bị cấm giao dịch (Trade Banned/CanTrade = false)"
                        return
                    end
                    if data.PartyDisabled == true or data.PartyBlocked == true or data.MatchmakingDisabled == true or data.CanJoinFriends == false or data.MultiplayerDisabled == true then
                        detected = true
                        reason = "Game Cache: Bị cấm chơi với bạn bè (Party/Matchmaking Restricted)"
                        return
                    end
                end

                if v156_4 and v156_4.Player then
                    if v156_4.Player.ShadowBanned == true or v156_4.Player.IsShadowBanned == true or v156_4.Player.RewardsDisabled == true then
                        detected = true
                        reason = "Internal Player State: ShadowBanned = true"
                        return
                    end
                end

                local pgui = lp and lp:FindFirstChild("PlayerGui")
                if pgui then
                    for _, obj in ipairs(pgui:GetDescendants()) do
                        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Visible then
                            local t = string.lower(tostring(obj.Text or ""))
                            if t:find("shadowban") or t:find("shadow ban") or t:find("shadow-ban")
                                or t:find("rewards disabled") or t:find("suspicious activity detected")
                                or t:find("vo hieu hoa phan thuong") or t:find("bi cam nhan phan thuong")
                                or t:find("không thể giao dịch") or t:find("khong the giao dich")
                                or t:find("bị cấm giao dịch") or t:find("bị khóa giao dịch")
                                or t:find("trading disabled") or t:find("trade locked") or t:find("trade restricted")
                                or t:find("cannot trade") or t:find("trade ban")
                                or t:find("không thể chơi với bạn bè") or t:find("khong the choi voi ban be")
                                or t:find("không thể tham gia cùng bạn bè") or t:find("cannot play with friends")
                                or t:find("cannot join friends") or t:find("party disabled") or t:find("party restricted")
                                or t:find("matchmaking restricted") or t:find("giới hạn tìm trận") then
                                detected = true
                                reason = "GUI Alert: \"" .. tostring(obj.Text):sub(1, 40) .. "...\""
                                return
                            end
                        end
                    end
                end
            end)

            v150_10.ShadowBanData.IsBanned = detected
            v150_10.ShadowBanData.LastChecked = os.clock()
            v150_10.ShadowBanData.CheckCount = v150_10.ShadowBanData.CheckCount + 1

            if detected then
                v150_10.ShadowBanData.Reason = isVi and ("BỊ SHADOW BAN! (" .. reason .. ")") or
                    ("SHADOW BANNED! (" .. reason .. ")")
                pcall(function()
                    v150_8.Rayfield:Notify({
                        Title = isVi and "CẢNH BÁO SHADOW BAN!" or "SHADOW BAN DETECTED!",
                        Content = isVi and ("Tài khoản bị phát hiện Shadow Ban:\n" .. reason) or
                            ("Account detected Shadow Banned:\n" .. reason),
                        Duration = 10,
                        Image = 4483362458
                    })
                end)
            else
                v150_10.ShadowBanData.Reason = isVi and "Tài khoản sạch 100% (Không có dấu hiệu Shadow Ban)" or
                    "100% Clean (No Shadow Ban detected)"
                if isManual then
                    pcall(function()
                        v150_8.Rayfield:Notify({
                            Title = isVi and "KIỂM TRA SHADOW BAN" or "SHADOW BAN CHECK",
                            Content = isVi and
                                "Tài khoản 100% Sạch! Tất cả thuộc tính, chỉ số & giao diện đều bình thường." or
                                "Account is 100% Clean! All attributes, stats & UI normal.",
                            Duration = 5,
                            Image = 4483362458
                        })
                    end)
                end
            end

            v150_10.UpdateShadowBanParagraph()
            return detected, v150_10.ShadowBanData.Reason
        end

        function v150_10.UpdateShadowBanParagraph()
            if not v56_2.ShadowBanParagraph then
                return
            end
            pcall(function()
                local isVi = v150_9.IsVietnamese()
                local sb = v150_10.ShadowBanData
                local statusStr = sb.IsBanned
                    and (isVi and "[⚠️ BỊ PHÁT HIỆN SHADOW BAN]" or "[⚠️ SHADOW BAN DETECTED]")
                    or (isVi and "[✅ 100% AN TOÀN / SẠCH]" or "[✅ 100% CLEAN / SAFE]")
                local timeStr = os.date("%H:%M:%S")

                if isVi then
                    v56_2.ShadowBanParagraph:Set(string.format(
                        "Trạng Thái Shadow Ban: %s\nChi Tiết: %s\nSố Lần Đã Quét: %d lần\nThời Gian Quét Gần Nhất: %s",
                        statusStr,
                        sb.Reason,
                        sb.CheckCount,
                        timeStr
                    ))
                else
                    v56_2.ShadowBanParagraph:Set(string.format(
                        "Shadow Ban Status: %s\nDetails: %s\nScan Count: %d times\nLast Scanned: %s",
                        statusStr,
                        sb.Reason,
                        sb.CheckCount,
                        timeStr
                    ))
                end
            end)
        end

        function v150_10.GetDataHost()
            local host = _G.__CachedDataHost or _G.__CachedCustHost or _G.__CachedHost
            if type(host) == "table" and type(rawget(host, "Cache")) == "table" and type(rawget(host.Cache, "Data")) == "table" then
                return host
            end
            if type(getgc) == "function" then
                pcall(function()
                    for _, v in ipairs(getgc(true)) do
                        if type(v) == "table" and type(rawget(v, "Cache")) == "table" then
                            local cache = rawget(v, "Cache")
                            if type(rawget(cache, "Data")) == "table" then
                                _G.__CachedDataHost = v
                                host = v
                                return
                            end
                        end
                    end
                end)
            end
            return host
        end

        function v150_10.GetKaitunPlayerState()
            local minLvl = tonumber(v150_10.GetWeaponMinLevel and v150_10.GetWeaponMinLevel())
                or tonumber(v61_2.CachedWeaponMinLevel)
                or 0
            local prestige = tonumber(v7_13 and
                    (v7_13:GetAttribute("Prestige") or v7_13:GetAttribute("Symbiote_Prestige")))
                or tonumber(v156_4.Player.Prestige)
                or 0
            if prestige > 5 or prestige < 0 then
                prestige = 0
                v156_4.Player.Prestige = 0
                if v7_13 then
                    pcall(function() v7_13:SetAttribute("Symbiote_Prestige", nil) end)
                end
            end
            local level = tonumber(v7_13 and (v7_13:GetAttribute("Level") or v7_13:GetAttribute("Symbiote_Level")))
                or tonumber(v156_4.Player.Level)
                or 1
            if level > 225 or level < 1 then
                level = 1
                v156_4.Player.Level = 1
                if v7_13 then
                    pcall(function() v7_13:SetAttribute("Symbiote_Level", nil) end)
                end
            end
            local gold = tonumber(v7_13 and v7_13:GetAttribute("Symbiote_Gold"))
                or tonumber(v156_4.Player.Gold)
                or 0
            local hudGold = v150_10.GetHudGold and v150_10.GetHudGold() or 0
            if hudGold > 0 then
                gold = hudGold
                v156_4.Player.Gold = hudGold
            end

            -- Priority 1: Game Cache Data (Server-replicated true player slot data)
            pcall(function()
                local host = v150_10.GetDataHost()
                if type(host) == "table" and type(rawget(host, "Cache")) == "table" and type(rawget(host.Cache, "Data")) == "table" then
                    local data = host.Cache.Data
                    local slot = type(data.Slots) == "table" and data.Current_Slot and data.Slots[data.Current_Slot]
                    if type(slot) == "table" then
                        if type(slot.Progression) == "table" then
                            local pNum = tonumber(slot.Progression.Prestige)
                            if pNum and pNum >= 0 and pNum <= 5 then
                                prestige = pNum
                                v156_4.Player.Prestige = prestige
                            end
                            local lNum = tonumber(slot.Progression.Level)
                            if lNum and lNum >= 1 and lNum <= 225 then
                                level = lNum
                                v156_4.Player.Level = level
                            end
                        end
                        if type(slot.Currency) == "table" and tonumber(slot.Currency.Gold) then
                            gold = tonumber(slot.Currency.Gold)
                            v156_4.Player.Gold = gold
                        end
                        if type(slot.Upgrades) == "table" then
                            local wName = tostring(slot.Weapon or (v73_2() and "Spears" or "Blades"))
                            local upgs = slot.Upgrades[wName]
                            if type(upgs) == "table" then
                                local m = 999
                                for _, lv in pairs(upgs) do
                                    if type(lv) == "number" and lv < m then
                                        m = lv
                                    end
                                end
                                if m < 999 then
                                    minLvl = math.max(minLvl, m)
                                    v61_2.CachedWeaponMinLevel = minLvl
                                end
                            end
                        end
                    end
                end
            end)

            -- Priority 2: In-Game UI Parsing (With strict sanitization)
            local bonusMapDetected = nil
            pcall(function()
                local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                local iface = pgui and pgui:FindFirstChild("Interface")
                if not iface then
                    return
                end

                -- Robust Gold & Currency Extraction from Topbar
                local topbar = iface:FindFirstChild("Topbar")
                if topbar then
                    for _, tObj in ipairs(topbar:GetDescendants()) do
                        if tObj:IsA("TextLabel") and type(tObj.Text) == "string" and tObj.Text ~= "" then
                            local cleanTxt = tObj.Text:gsub(",", ""):gsub("%s+", "")
                            local pNum = tonumber(cleanTxt:match("^(%d+)$"))
                            if pNum then
                                local pName = string.lower(tostring(tObj.Parent and tObj.Parent.Name or ""))
                                local oName = string.lower(tostring(tObj.Name or ""))
                                if pName:find("gold") or oName:find("gold") or pName:find("vang") or oName:find("vang") then
                                    gold = pNum
                                    v156_4.Player.Gold = pNum
                                end
                            end
                        end
                    end
                end

                for _, obj in ipairs(iface:GetDescendants()) do
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local txt = tostring(obj.Text or "")
                        if txt ~= "" then
                            local xpMatch = txt:match("XP:%s*(%d+)%%")
                            if xpMatch then
                                cachedXPPercent = tonumber(xpMatch) or cachedXPPercent
                            end

                            -- Multilingual Weapon Grade Extraction (UTF-8 normalized)
                            local norm = normalizeVi(txt):upper()
                            local gradeMatch = norm:match("%[%s*CAP%s*DO%s*([E%-%+DCBAS]+)%s*%]")
                                or norm:match("%[%s*([E%-%+DCBAS]+)%s*CAP%s*DO%s*%]")
                                or norm:match("%[%s*GRADE%s*([E%-%+DCBAS]+)%s*%]")
                                or norm:match("%[%s*([E%-%+DCBAS]+)%s*GRADE%s*%]")
                                or norm:match("NANG%s*CAP%s*%[%s*CAP%s*DO%s*([E%-%+DCBAS]+)%s*%]")
                                or norm:match("NANG%s*CAP%s*%[%s*([E%-%+DCBAS]+)%s*%]")
                                or norm:match("UPGRADE%s*%[%s*([E%-%+DCBAS]+)%s*%]")
                                or norm:match("%[%s*([E%-%+DCBAS]+)%s*%]")
                            if gradeMatch and LETTER_TO_LEVEL[gradeMatch] ~= nil then
                                local gLvl = LETTER_TO_LEVEL[gradeMatch]
                                if gLvl > minLvl then
                                    minLvl = gLvl
                                    v61_2.CachedWeaponMinLevel = minLvl
                                    if v7_13 then
                                        pcall(function() v7_13:SetAttribute("WeaponMinLevel", minLvl) end)
                                    end
                                end
                            end

                            -- Safe Level extraction ONLY if level is not yet determined (level <= 1)
                            if level <= 1 then
                                local normLvTxt = normalizeVi(txt)
                                local curLvStr, maxCapStr = normLvTxt:match("cap%.?%s*(%d+)%s*/%s*(%d+)")
                                if not curLvStr then curLvStr, maxCapStr = normLvTxt:match("lv%.?%s*(%d+)%s*/%s*(%d+)") end
                                if not curLvStr then curLvStr, maxCapStr = normLvTxt:match("level%s*(%d+)%s*/%s*(%d+)") end
                                if curLvStr and maxCapStr then
                                    local parsedCur = tonumber(curLvStr)
                                    local parsedCap = tonumber(maxCapStr)
                                    -- Strictly require standard AOT:R prestige caps: 100, 125, 150, 175, 200, 225
                                    if parsedCap and parsedCap >= 100 and parsedCap <= 225 and ((parsedCap - 100) % 25 == 0) then
                                            local derivedP = math.floor((parsedCap - 100) / 25)
                                            if derivedP >= 0 and derivedP <= 5 then
                                                prestige = derivedP
                                                v156_4.Player.Prestige = prestige
                                            end
                                            if parsedCur and parsedCur > 0 and parsedCur <= parsedCap then
                                                level = parsedCur
                                                v156_4.Player.Level = parsedCur
                                            end
                                        end
                                    end
                                end

                            -- In-Text Gold Parser
                            local gNorm = normalizeVi(txt)
                            if gNorm:find("vang:") or gNorm:find("gold:") then
                                local pG = tonumber(txt:gsub(",", ""):match("(%d+)"))
                                if pG and pG > 0 then
                                    gold = pG
                                    v156_4.Player.Gold = pG
                                end
                            end

                            -- Bonus Map Detection
                            local normTxt = normalizeVi(txt)
                            if (normTxt:find("tang phan thuong", 1, true) or normTxt:find("bonus", 1, true)) and obj.Parent then
                                local pNorm = normalizeVi(getGuiObjectText(obj.Parent) ..
                                    " " .. tostring(obj.Parent.Name or ""))
                                if pNorm:find("shiganshina", 1, true) then
                                    bonusMapDetected = "Shiganshina"
                                elseif pNorm:find("trost", 1, true) then
                                    bonusMapDetected = "Trost"
                                elseif pNorm:find("outskirts", 1, true) or pNorm:find("do lot", 1, true) then
                                    bonusMapDetected = "Outskirts"
                                elseif pNorm:find("forest", 1, true) or pNorm:find("rung", 1, true) then
                                    bonusMapDetected = "Giant Forest"
                                end
                            end
                        end
                    end
                end
            end)

            prestige = math.min(5, math.max(0, prestige))
            level = math.min(225, math.max(1, level))
            minLvl = math.max(0, math.min(15, math.floor(tonumber(minLvl) or 0)))
            local gradeLetter = GRADE_LETTERS[minLvl] or "E-"
            local bracket = getDifficultyBracket(minLvl)

            local maxLevelCap = 100 + (prestige * 25)
            local readyToPrestige = (prestige < 5)
                and ((level > maxLevelCap) or (level == maxLevelCap and cachedXPPercent >= 100))
            local maxPrestigeTarget = 5

            local canUpgradeStep = false
            local goldForNext = nil
            if minLvl < 15 then
                local nextLvl = minLvl + 1
                local goldNeeded = getGoldNeededForLevel(minLvl, nextLvl)
                if gold >= goldNeeded then
                    canUpgradeStep = true
                end
            end

            local readyForNextBracket = false
            if bracket.NextMinLvl then
                goldForNext = getGoldNeededForLevel(minLvl, bracket.NextMinLvl)
                if gold >= goldForNext then
                    readyForNextBracket = true
                end
            end

            local resolvedMap = bracket.Map
            if bonusMapDetected and v8_6("KaitunPrioritizeBonusMap") ~= false then
                resolvedMap = bonusMapDetected
            end

            return {
                Prestige = prestige,
                Level = level,
                MaxLevelCap = maxLevelCap,
                XPPercent = cachedXPPercent,
                Gold = gold,
                WeaponMinLevel = minLvl,
                GradeLetter = gradeLetter,
                WeaponGradeLetter = gradeLetter,
                Bracket = bracket,
                GoldForNextBracket = goldForNext,
                ReadyToPrestige = readyToPrestige,
                MaxPrestigeTarget = maxPrestigeTarget,
                CanUpgradeStep = canUpgradeStep,
                ReadyForNextBracket = readyForNextBracket,
                BonusMapDetected = bonusMapDetected,
                TargetMap = resolvedMap
            }
        end

        function v150_10.KaitunUpgradeWeapon()
            local state = v150_10.GetKaitunPlayerState()
            if state.WeaponMinLevel >= 15 then
                return false
            end
            lastUpgradeAttemptGold = state.Gold
            lastUpgradeAttemptTime = os.clock()

            local weaponPref = tostring(v8_6("KaitunWeaponType") or "Auto")
            local useSpears = false
            if weaponPref == "Spears" then
                useSpears = true
            elseif weaponPref == "Blades" then
                useSpears = false
            else
                useSpears = v73_2() == true
            end
            local weaponCategory = useSpears and "Spears" or "Blades"
            local statBranches = useSpears and {
                "Crit_Damage",
                "TS_Damage",
                "Crit_Chance",
                "Blast_Radius",
                "TS_Speed",
                "TS_Gas",
                "TS_Control",
                "TS_Range"
            } or {
                "Crit_Damage",
                "ODM_Damage",
                "Crit_Chance",
                "Blade_Durability",
                "ODM_Speed",
                "ODM_Gas",
                "ODM_Control",
                "ODM_Range"
            }

            local startMinLvl = state.WeaponMinLevel
            local startGold = state.Gold
            kaitunActionState = "Upgrading Weapon [" ..
                (GRADE_LETTERS[startMinLvl] or "E-") ..
                " -> " .. (GRADE_LETTERS[math.min(15, startMinLvl + 1)] or "S-") .. "]"
            if v150_10.UpdateKaitunParagraph then
                pcall(v150_10.UpdateKaitunParagraph)
            end

            if v13_8:FindFirstChild("Waves") and v150_10.UpgradeWeaponStep then
                for _ = 1, 15 do
                    local okW, resW = pcall(v150_10.UpgradeWeaponStep)
                    if not (okW and resW) then
                        break
                    end
                    task.wait(0.15)
                end
            else
                -- Try Remote "Upgrade All" invocations first
                if v69_2 then
                    pcall(function()
                        v69_2:InvokeServer("S_Equipment", "UpgradeAll")
                    end)
                    pcall(function()
                        v69_2:InvokeServer("S_Equipment", "Upgrade", "All")
                    end)
                    pcall(function()
                        v69_2:InvokeServer("Equipment", "UpgradeAll")
                    end)
                    pcall(function()
                        v69_2:InvokeServer("Equipment", "Upgrade", "All")
                    end)
                    for _ = 1, 3 do
                        local anyTableReturned = false
                        local okB1, resB1 = pcall(function()
                            return v69_2:InvokeServer("S_Equipment", "Upgrade", statBranches)
                        end)
                        if okB1 and type(resB1) == "table" then
                            anyTableReturned = true
                        end
                        for _, statName in ipairs(statBranches) do
                            pcall(function()
                                local r1 = v69_2:InvokeServer("S_Equipment", "Upgrade", weaponCategory, statName)
                                if type(r1) == "table" then anyTableReturned = true end
                            end)
                            pcall(function()
                                local r2 = v69_2:InvokeServer("S_Equipment", "Upgrade", statName)
                                if type(r2) == "table" then anyTableReturned = true end
                            end)
                        end
                        if not anyTableReturned then
                            break
                        end
                        task.wait(0.12)
                    end
                end

                pcall(function()
                    local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                    local iface = pgui and pgui:FindFirstChild("Interface")
                    if not iface then
                        return
                    end
                    local equip = iface:FindFirstChild("Equipment")
                    if equip and not isTrulyVisible(equip, iface) then
                        local topbar = iface:FindFirstChild("Topbar")
                        local equipTopBtn = nil
                        if topbar then
                            equipTopBtn = topbar:FindFirstChild("Equipment", true)
                            if not equipTopBtn then
                                local trangBiCount = 0
                                for _, b in ipairs(topbar:GetDescendants()) do
                                    if b:IsA("GuiButton") and isTrulyVisible(b, iface) then
                                        local nb = normalizeVi(getGuiObjectText(b) .. " " .. tostring(b.Name or ""))
                                        if nb:find("equipment", 1, true) then
                                            equipTopBtn = b
                                            break
                                        elseif nb:find("trang bi", 1, true) then
                                            trangBiCount = trangBiCount + 1
                                            equipTopBtn = b
                                            if trangBiCount >= 2 then
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if equipTopBtn then
                            v150_10.ClickGuiButton(equipTopBtn)
                            task.wait(0.4)
                        end
                    end

                    if equip and isTrulyVisible(equip, iface) then
                        -- Ensure "Nâng cấp" tab on left sidebar is clicked
                        for _, b in ipairs(equip:GetDescendants()) do
                            if b:IsA("GuiButton") and isTrulyVisible(b, equip) then
                                local nb = normalizeVi(getGuiObjectText(b) .. " " .. tostring(b.Name or ""))
                                if (nb:find("nang cap", 1, true) or nb:find("upgrade", 1, true)) and not nb:find("tat ca", 1, true) and not nb:find("all", 1, true) then
                                    if b.AbsolutePosition.X < 350 then
                                        v150_10.ClickGuiButton(b)
                                        task.wait(0.25)
                                        break
                                    end
                                end
                            end
                        end

                        -- Priority 1: CLICK "Nâng cấp tất cả" / "Upgrade All" button!
                        for _ = 1, 15 do
                            local upgradeAllBtn = nil
                            for _, b in ipairs(equip:GetDescendants()) do
                                if b:IsA("GuiButton") and isTrulyVisible(b, equip) then
                                    local nb = normalizeVi(getGuiObjectText(b) .. " " .. tostring(b.Name or ""))
                                    if nb:find("nang cap tat ca", 1, true) or nb:find("upgrade all", 1, true) or nb == "all" or nb == "tat ca" then
                                        upgradeAllBtn = b
                                        break
                                    end
                                end
                            end
                            if upgradeAllBtn then
                                v150_10.ClickGuiButton(upgradeAllBtn)
                                task.wait(0.2)
                                for _, cb in ipairs(iface:GetDescendants()) do
                                    if cb:IsA("GuiButton") and isTrulyVisible(cb, iface) then
                                        local cnb = normalizeVi(getGuiObjectText(cb) .. " " .. tostring(cb.Name or ""))
                                        if cnb == "xac nhan" or cnb == "confirm" or cnb == "yes" or cnb == "dong y" then
                                            v150_10.ClickGuiButton(cb)
                                            task.wait(0.15)
                                            break
                                        end
                                    end
                                end
                            else
                                break
                            end
                            local curSt = v150_10.GetKaitunPlayerState()
                            if curSt.WeaponMinLevel >= 15 or curSt.Gold < 1000 then
                                break
                            end
                        end

                        -- Priority 2: Fallback to individual stat buttons + cost button
                        local statButtons = {}
                        local statNameSet = {}
                        for _, sName in ipairs(statBranches) do
                            statNameSet[string.lower(sName)] = true
                        end
                        for _, b in ipairs(equip:GetDescendants()) do
                            if b:IsA("GuiButton") and isTrulyVisible(b, equip) then
                                local lname = string.lower(tostring(b.Name or ""))
                                if statNameSet[lname] or lname:find("odm_") or lname:find("ts_") or lname:find("crit_") or lname:find("blade_") or lname:find("blast_") then
                                    table.insert(statButtons, b)
                                elseif b.Parent and #b.Parent:GetChildren() >= 8 and b.AbsoluteSize.X > 20 and b.AbsoluteSize.X < 120 and math.abs(b.AbsoluteSize.X - b.AbsoluteSize.Y) < 15 then
                                    table.insert(statButtons, b)
                                end
                            end
                        end

                        local statPanel = equip:FindFirstChild("Stat")
                        local costBtn = statPanel and statPanel:FindFirstChild("Cost")
                        if not costBtn then
                            for _, b in ipairs(equip:GetDescendants()) do
                                if b:IsA("GuiButton") and isTrulyVisible(b, equip) then
                                    local nb = normalizeVi(getGuiObjectText(b) .. " " .. tostring(b.Name or ""))
                                    if (nb:find("toi da", 1, true) or nb:find("max", 1, true) or nb:find("gold", 1, true)) and not nb:find("tat ca", 1, true) then
                                        costBtn = b
                                        break
                                    end
                                end
                            end
                        end

                        if costBtn and #statButtons > 0 then
                            for _ = 1, 4 do
                                local clickedCost = false
                                for _, sBtn in ipairs(statButtons) do
                                    v150_10.ClickGuiButton(sBtn)
                                    task.wait(0.06)
                                    local cTxt = normalizeVi(getGuiObjectText(costBtn))
                                    if not cTxt:find("max", 1, true) and not cTxt:find("toi da", 1, true) then
                                        local cNum = tonumber(cTxt:gsub("[^%d]", ""))
                                        local curG = tonumber(v156_4.Player.Gold) or state.Gold or 0
                                        if not cNum or (cNum > 0 and curG >= cNum) then
                                            v150_10.ClickGuiButton(costBtn)
                                            clickedCost = true
                                            task.wait(0.08)
                                        end
                                    end
                                end
                                if not clickedCost then
                                    break
                                end
                            end
                        end
                    end
                end)
            end

            local afterState = v150_10.GetKaitunPlayerState()
            local upgradedAny = (afterState.WeaponMinLevel > startMinLvl) or (afterState.Gold < startGold)
            if upgradedAny then
                lastUpgradeAttemptGold = -1
            end
            if v150_10.UpdateKaitunParagraph then
                pcall(v150_10.UpdateKaitunParagraph)
            end
            return upgradedAny
        end

        function v150_10.KaitunPerformPrestige()
            local state = v150_10.GetKaitunPlayerState()
            if not state.ReadyToPrestige then
                return false
            end
            kaitunActionState = "Performing Prestige (Rebirth)..."
            if v150_10.UpdateKaitunParagraph then
                pcall(v150_10.UpdateKaitunParagraph)
            end

            local prestiged = false
            if v69_2 then
                for _, args in ipairs({
                    { "S_Equipment", "Prestige" },
                    { "Equipment",   "Prestige" },
                    { "Progression", "Prestige" },
                    { "Functions",   "Prestige" }
                }) do
                    pcall(function()
                        local res = v69_2:InvokeServer(args[1], args[2])
                        if type(res) == "table" or res == true then
                            prestiged = true
                        end
                    end)
                end
            end
            if v68_2 then
                pcall(function()
                    v68_2:FireServer("Functions", "Prestige")
                end)
            end

            pcall(function()
                local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                local iface = pgui and pgui:FindFirstChild("Interface")
                if not iface then
                    return
                end
                local equip = iface:FindFirstChild("Equipment")
                if equip and not isTrulyVisible(equip, iface) then
                    local topbar = iface:FindFirstChild("Topbar")
                    local equipBtn = topbar and topbar:FindFirstChild("Equipment", true)
                    if not equipBtn then
                        local countTB = 0
                        for _, btn in ipairs(iface:GetDescendants()) do
                            if btn:IsA("GuiButton") and isTrulyVisible(btn, iface) then
                                local nb = normalizeVi(getGuiObjectText(btn) .. " " .. tostring(btn.Name or ""))
                                if nb:find("equipment", 1, true) then
                                    equipBtn = btn
                                    break
                                elseif nb:find("trang bi", 1, true) then
                                    countTB = countTB + 1
                                    equipBtn = btn
                                    if countTB >= 2 then
                                        break
                                    end
                                end
                            end
                        end
                    end
                    if equipBtn then
                        v150_10.ClickGuiButton(equipBtn)
                        task.wait(0.35)
                    end
                end

                -- STEP 1: Click left sidebar "Linh Mục" tab
                local sidebarPriestBtn = nil
                for _, btn in ipairs(iface:GetDescendants()) do
                    if btn:IsA("GuiButton") and isTrulyVisible(btn, iface) then
                        local nb = normalizeVi(getGuiObjectText(btn) .. " " .. tostring(btn.Name or ""))
                        if nb:find("linh muc", 1, true) or nb:find("priest", 1, true) then
                            if btn.AbsolutePosition.X < 350 or (btn.Parent and tostring(btn.Parent.Name):lower():find("side")) then
                                sidebarPriestBtn = btn
                                break
                            end
                        end
                    end
                end
                if sidebarPriestBtn then
                    v150_10.ClickGuiButton(sidebarPriestBtn)
                    task.wait(0.4)
                end

                -- STEP 2: Click the golden "Linh Mục" / Prestige action button inside the panel
                for _, btn in ipairs(iface:GetDescendants()) do
                    if btn:IsA("GuiButton") and isTrulyVisible(btn, iface) then
                        local nb = normalizeVi(getGuiObjectText(btn) .. " " .. tostring(btn.Name or ""))
                        if nb:find("linh muc", 1, true) or nb:find("prestige", 1, true) or nb:find("tai sinh", 1, true) then
                            if btn ~= sidebarPriestBtn then
                                v150_10.ClickGuiButton(btn)
                                prestiged = true
                                task.wait(0.35)
                                break
                            end
                        end
                    end
                end

                -- STEP 3: Confirm modal ("Xác nhận", "Bảo quản", "Confirm", "Yes")
                for _, btn in ipairs(iface:GetDescendants()) do
                    if btn:IsA("GuiButton") and isTrulyVisible(btn, iface) then
                        local nb = normalizeVi(getGuiObjectText(btn) .. " " .. tostring(btn.Name or ""))
                        if nb == "confirm" or nb == "xac nhan" or nb == "yes" or nb == "dong y" or nb == "bao quan" or nb == "select" or nb == "chon" then
                            v150_10.ClickGuiButton(btn)
                            prestiged = true
                            task.wait(0.3)
                        end
                    end
                end
            end)

            if v69_2 then
                pcall(function()
                    v69_2:InvokeServer("S_Equipment", "Memory", 1)
                end)
                pcall(function()
                    v69_2:InvokeServer("Progression", "Memory", 1)
                end)
            end

            if prestiged then
                cachedXPPercent = 0
                v61_2.CachedWeaponMinLevel = 0
                lastUpgradeAttemptGold = -1
                if v8_6("KaitunAutoUpgradeWeapon") ~= false then
                    v150_10.KaitunUpgradeWeapon()
                end
            end
            return prestiged
        end

        function v150_10.ConfigureModifiers(iface)
            pcall(function()
                local modRows = {}
                for _, obj in ipairs(iface:GetDescendants()) do
                    if (obj:IsA("Frame") or obj:IsA("GuiButton")) and isTrulyVisible(obj, iface) then
                        local txt = getGuiObjectText(obj)
                        local ntxt = normalizeVi(txt)
                        if ntxt:find("%+", 1, true) or ntxt:find("vang/xp", 1, true) or ntxt:find("gold/xp", 1, true)
                            or ntxt:find("uu dai", 1, true) or ntxt:find("ky nang", 1, true) or ntxt:find("ky uc", 1, true)
                            or ntxt:find("ac mong", 1, true) or ntxt:find("oddball", 1, true) or ntxt:find("hardcore", 1, true) then
                            local rowFrame = obj
                            while rowFrame.Parent and rowFrame.Parent ~= iface and rowFrame.Parent:IsA("GuiObject") do
                                if rowFrame.Parent:IsA("ScrollingFrame") or rowFrame.Parent.Name == "List" or rowFrame.Parent.Name == "Container" then
                                    break
                                end
                                rowFrame = rowFrame.Parent
                            end
                            local alreadyAdded = false
                            for _, r in ipairs(modRows) do
                                if r == rowFrame then
                                    alreadyAdded = true
                                    break
                                end
                            end
                            if not alreadyAdded then
                                table.insert(modRows, rowFrame)
                            end
                        end
                    end
                end

                if #modRows > 0 then
                    table.sort(modRows, function(a, b)
                        local loA = a.LayoutOrder or 0
                        local loB = b.LayoutOrder or 0
                        if loA ~= loB and loA > 0 and loB > 0 then
                            return loA < loB
                        end
                        return a.AbsolutePosition.Y < b.AbsolutePosition.Y
                    end)

                    local totalMods = #modRows
                    -- User requirement: Turn ON all modifiers except the last 4!
                    local safeEnableCount = math.max(0, totalMods - 4)

                    local function isChecked(row)
                        for _, d in ipairs(row:GetDescendants()) do
                            if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                                local iname = string.lower(d.Name)
                                if (iname:find("check") or iname:find("tick") or iname:find("icon") or iname:find("box")) and d.Visible then
                                    if d.ImageTransparency < 0.5 and d.Image ~= "" then
                                        return true
                                    end
                                end
                            elseif d:IsA("TextLabel") or d:IsA("TextButton") then
                                local t = tostring(d.Text or "")
                                if t:find("✓") or t == "X" or t == "x" then
                                    return true
                                end
                            end
                        end
                        return row:GetAttribute("Enabled") == true or row:GetAttribute("Checked") == true
                    end

                    local function getClickTarget(row)
                        if row:IsA("GuiButton") then return row end
                        for _, b in ipairs(row:GetDescendants()) do
                            if b:IsA("GuiButton") and isTrulyVisible(b, iface) then
                                return b
                            end
                        end
                        return nil
                    end

                    for idx, row in ipairs(modRows) do
                        local targetState = (idx <= safeEnableCount)
                        local currentlyOn = isChecked(row)
                        if currentlyOn ~= targetState then
                            local clickBtn = getClickTarget(row)
                            if clickBtn then
                                v150_10.ClickGuiButton(clickBtn)
                                task.wait(0.06)
                            end
                        end
                    end
                end
            end)
        end

        function v150_10.HandleModeSelectionScreen()
            -- Wrapper maintaining backwards compatibility
            return v150_10.KaitunCreateAndStartMission()
        end

        function v150_10.KaitunCreateAndStartMission()
            local state = v150_10.GetKaitunPlayerState()
            local targetMap = state.TargetMap
            local targetGrade = state.Bracket.Grade
            local targetDiffEN = state.Bracket.DiffEN
            local targetOrder = state.Bracket.Order

            local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
            local iface = pgui and pgui:FindFirstChild("Interface")
            if not iface then return false end

            local function getClickable(o)
                if not o then return nil end
                if o:IsA("GuiButton") then return o end
                return o:FindFirstAncestorWhichIsA("GuiButton")
                    or o:FindFirstChildWhichIsA("GuiButton", true)
                    or (o.Parent and o.Parent:IsA("GuiObject") and o.Parent)
                    or o
            end

            -- =========================================================================
            -- SCAN CURRENT UI ELEMENTS
            -- =========================================================================
            local startMissionBtn = nil
            local createRoomBtn = nil
            local modifiersBtn = nil
            local backFromModsBtn = nil
            local isModWindowOpen = false
            local diffLabel = nil
            local nextDiffBtn = nil
            local prevDiffBtn = nil
            local mapButtons = {}
            local modeCards = {}
            local modePlayBtn = nil
            local topbarMissionBtn = nil

            -- 1. Scan Topbar
            local topbar = iface:FindFirstChild("Topbar")
            if topbar then
                for _, b in ipairs(topbar:GetDescendants()) do
                    if isTrulyVisible(b, iface) then
                        local nb = normalizeVi(getGuiObjectText(b) .. " " .. tostring(b.Name or ""))
                        if nb:find("nhiem vu", 1, true) or nb:find("mission", 1, true) then
                            topbarMissionBtn = getClickable(b)
                            break
                        end
                    end
                end
            end

            -- 2. Scan visible interface descendants
            for _, obj in ipairs(iface:GetDescendants()) do
                if isTrulyVisible(obj, iface) then
                    local rawTxt = getGuiObjectText(obj)
                    local norm = normalizeVi(rawTxt)
                    local up = rawTxt:upper()
                    local lname = string.lower(tostring(obj.Name or ""))
                    local clickable = getClickable(obj)
                    local sz = obj.AbsoluteSize or (clickable and clickable.AbsoluteSize)
                    local pos = obj.AbsolutePosition or (clickable and clickable.AbsolutePosition)
                    local isCardSize = sz and (sz.X > 40 or sz.Y > 60)

                    -- Check if Modifiers modal is active
                    if (norm == "sua doi" or norm == "modifiers") and (obj:IsA("TextLabel") or (pos and pos.Y < 200)) then
                        isModWindowOpen = true
                    end
                    if (norm == "tro lai" or norm == "back" or norm == "return") and clickable then
                        backFromModsBtn = clickable
                    end

                    -- Difficulty label & arrows
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and (up:find("GRADE)", 1, true) or up:find("CAP DO)", 1, true) or up:find("CẤP ĐỘ)", 1, true)) then
                        diffLabel = obj
                    end
                    if rawTxt == ">" or lname == "next" or lname == "right" or lname == "arrowright" then
                        nextDiffBtn = clickable
                    elseif rawTxt == "<" or lname == "prev" or lname == "previous" or lname == "left" or lname == "arrowleft" then
                        prevDiffBtn = clickable
                    end

                    -- Map buttons
                    if lname:find("shiganshina", 1, true) or norm:find("shiganshina", 1, true) then
                        mapButtons["Shiganshina"] = clickable
                    elseif lname:find("trost", 1, true) or norm:find("trost", 1, true) then
                        mapButtons["Trost"] = clickable
                    elseif lname:find("outskirts", 1, true) or norm:find("outskirts", 1, true) or norm:find("do lot", 1, true) then
                        mapButtons["Outskirts"] = clickable
                    elseif lname:find("forest", 1, true) or norm:find("forest", 1, true) or norm:find("rung", 1, true) then
                        mapButtons["Giant Forest"] = clickable
                    end

                    -- Mode cards
                    if (norm == "nhiem vu" or norm == "missions" or lname == "mission" or lname == "missions") and isCardSize and pos and pos.Y > 40 then
                        modeCards.missions = clickable
                    elseif (norm == "raid" or lname == "raid") and isCardSize and pos and pos.Y > 40 then
                        modeCards.raid = clickable
                    elseif (norm == "song" or norm == "waves" or lname == "wave") and isCardSize and pos and pos.Y > 40 then
                        modeCards.waves = clickable
                    elseif (norm == "tham gia" or norm == "join" or lname == "join") and isCardSize and pos and pos.Y > 40 then
                        modeCards.join = clickable
                    end

                    -- Action buttons
                    if (norm == "tao" or norm == "create" or lname == "create") and clickable then
                        createRoomBtn = clickable
                    elseif (norm == "sua doi" or norm == "modifiers" or lname == "modifier" or lname == "modifiers") and clickable then
                        modifiersBtn = clickable
                    elseif (norm == "choi" or norm == "play") and clickable then
                        modePlayBtn = clickable
                    elseif (norm == "bat dau" or norm == "start" or lname == "start") and clickable then
                        startMissionBtn = clickable
                    end
                end
            end

            -- =========================================================================
            -- 5-STATE AUTOMATION LOGIC (Mutually Exclusive Priority)
            -- =========================================================================

            -- STATE 1: In Room Lobby (Ready to start)
            if startMissionBtn then
                kaitunActionState = "Room Ready - Starting Mission..."
                if v150_10.UpdateKaitunParagraph then pcall(v150_10.UpdateKaitunParagraph) end
                v150_10.ClickGuiButton(startMissionBtn)
                task.wait(2.0)
                return true
            end

            -- STATE 2: Modifiers Modal is open
            if isModWindowOpen and backFromModsBtn then
                kaitunActionState = "Configuring Modifiers (All ON except last 4)..."
                if v150_10.UpdateKaitunParagraph then pcall(v150_10.UpdateKaitunParagraph) end
                v150_10.ConfigureModifiers(iface)
                task.wait(0.3)
                v150_10.ClickGuiButton(backFromModsBtn)
                task.wait(0.5)
                return true
            end

            -- STATE 3: Room Creation Screen (TẠO button is visible)
            if createRoomBtn then
                kaitunActionState = "Creating Room: " .. targetMap .. " [" .. targetGrade .. " GRADE]..."
                if v150_10.UpdateKaitunParagraph then pcall(v150_10.UpdateKaitunParagraph) end

                -- 3a. Select Map
                local mBtn = mapButtons[targetMap] or mapButtons["Shiganshina"]
                if mBtn then
                    v150_10.ClickGuiButton(mBtn)
                    task.wait(0.25)
                end

                -- 3b. Adjust Difficulty Arrow
                if diffLabel then
                    for _ = 1, 5 do
                        local dTxt = tostring(getGuiObjectText(diffLabel)):upper()
                        local curG = dTxt:match("%(([E%-%+DBAS]+)%s*GRADE%)")
                        local curOrder = curG and GRADE_ORDER[curG] or nil
                        if not curOrder or curOrder == targetOrder then
                            break
                        elseif curOrder < targetOrder and nextDiffBtn then
                            v150_10.ClickGuiButton(nextDiffBtn)
                            task.wait(0.2)
                        elseif curOrder > targetOrder and prevDiffBtn then
                            v150_10.ClickGuiButton(prevDiffBtn)
                            task.wait(0.2)
                        else
                            break
                        end
                    end
                end

                -- 3c. Click Modifiers button if available to configure before starting
                if modifiersBtn and not v150_10._modifiersConfiguredThisSession then
                    v150_10.ClickGuiButton(modifiersBtn)
                    v150_10._modifiersConfiguredThisSession = true
                    task.wait(0.5)
                    return true
                end

                -- 3d. Click TẠO
                v150_10.ClickGuiButton(createRoomBtn)
                task.wait(0.75)
                return true
            end

            -- STATE 4: 4-Card Mode Selection Screen (Cards + CHƠI button visible)
            if (modeCards.missions or modeCards.raid) and modePlayBtn then
                kaitunActionState = "Selecting Mode: NHIỆM VỤ..."
                if v150_10.UpdateKaitunParagraph then pcall(v150_10.UpdateKaitunParagraph) end

                -- Select NHIỆM VỤ
                local targetCard = modeCards.missions or modeCards.raid
                if targetCard then
                    v150_10.ClickGuiButton(targetCard)
                    task.wait(0.3)
                end

                -- Click CHƠI
                v150_10.ClickGuiButton(modePlayBtn)
                task.wait(0.75)
                return true
            end

            -- STATE 5: Lobby Idle (Nothing open -> Click Topbar NHIỆM VỤ)
            if topbarMissionBtn then
                kaitunActionState = "Opening Missions Menu from Topbar..."
                if v150_10.UpdateKaitunParagraph then pcall(v150_10.UpdateKaitunParagraph) end
                v150_10.ClickGuiButton(topbarMissionBtn)
                task.wait(0.75)
                return true
            end

            -- Fallback remote call if UI not responsive
            if v69_2 then
                pcall(function()
                    v69_2:InvokeServer("S_Missions", "Create", {
                        Map = targetMap,
                        Difficulty = targetDiffEN,
                        Objective = "Skirmish"
                    })
                end)
                pcall(function()
                    v69_2:InvokeServer("S_Missions", "Start")
                end)
            end
            return false
        end

        function v150_10.ShouldKaitunReturnToLobby()
            if not v8_6("KaitunEnabled") then
                return false
            end
            local state = v150_10.GetKaitunPlayerState()
            if v8_6("KaitunAutoPrestige") ~= false and state.ReadyToPrestige then
                return true
            end
            if v8_6("KaitunAutoUpgradeWeapon") ~= false and v8_6("KaitunAutoMap") ~= false and state.ReadyForNextBracket then
                return true
            end
            return false
        end

        function v150_10.KaitunReturnToLobby()
            kaitunActionState = "Returning to Lobby (Upgrade / Prestige)..."
            if v150_10.UpdateKaitunParagraph then
                pcall(v150_10.UpdateKaitunParagraph)
            end
            if v69_2 then
                pcall(function()
                    v69_2:InvokeServer("Functions", "Teleport")
                end)
                pcall(function()
                    v69_2:InvokeServer("S_Missions", "Leave")
                end)
            end
            pcall(function()
                local pgui = v7_13 and v7_13:FindFirstChild("PlayerGui")
                local iface = pgui and pgui:FindFirstChild("Interface")
                local rewards = iface and iface:FindFirstChild("Rewards")
                if rewards then
                    for _, btn in ipairs(rewards:GetDescendants()) do
                        if btn:IsA("GuiButton") and btn.Visible then
                            local t = tostring(btn.Text or (btn:FindFirstChild("Title") and btn.Title.Text) or ""):upper()
                            if t:find("LOBBY", 1, true) or t:find("TRỞ LẠI", 1, true) or t:find("RETURN", 1, true) or btn.Name == "Lobby" then
                                v150_10.ClickGuiButton(btn)
                                break
                            end
                        end
                    end
                end
            end)
            return true
        end

        function v150_10.UpdateKaitunParagraph()
            if not v56_2.KaitunStatusParagraph then
                return
            end
            pcall(function()
                local isVi = v150_9.IsVietnamese()
                local st = v150_10.GetKaitunPlayerState()
                local enabledStr = v8_6("KaitunEnabled") and (isVi and "ĐANG BẬT (ON)" or "ACTIVE (ON)") or
                    (isVi and "ĐANG TẮT (OFF)" or "DISABLED (OFF)")
                local nextBracketTxt = st.Bracket.NextGrade
                    and string.format("%s (%s Gold)", st.Bracket.NextGrade, v165_3(st.GoldForNextBracket or 0))
                    or (isVi and "Đã tối đa (MAX S)" or "MAXED (S Grade)")
                local isMaxPrestige = st.Prestige >= st.MaxPrestigeTarget
                local prestigeReadyTxt = isMaxPrestige
                    and string.format(isVi and "ĐÃ ĐẠT CẤP TÁI SINH MỤC TIÊU (MAX PRESTIGE %d)" or "TARGET MAX PRESTIGE REACHED (PRESTIGE %d)", st.MaxPrestigeTarget)
                    or (st.ReadyToPrestige
                        and (isVi and "SẴN SÀNG TÁI SINH! (Vào Linh Mục)" or "READY TO PRESTIGE!")
                        or string.format("Lv.%d/%d (XP: %d%%)", st.Level, st.MaxLevelCap, st.XPPercent))
                local prestigeDisplay = isMaxPrestige
                    and string.format("%s/%s (MAX)", tostring(st.Prestige), tostring(st.MaxPrestigeTarget))
                    or string.format("%s/%s", tostring(st.Prestige), tostring(st.MaxPrestigeTarget))

                if isVi then
                    v56_2.KaitunStatusParagraph:Set(string.format(
                        "Trạng Thái Kaitun: %s\nHành Động: %s\nCấp Độ: Lv.%s / %s (Prestige %s)\nTiến Độ Tái Sinh: %s\nGold Hiện Tại: %s\nHạng Vũ Khí: [%s GRADE] (Cấp %d/15)\nMap & Độ Khó Mục Tiêu: %s - %s\nMốc Mở Khóa Độ Khó Tiếp: %s",
                        tostring(enabledStr),
                        tostring(kaitunActionState),
                        tostring(v165_3(st.Level)),
                        tostring(v165_3(st.MaxLevelCap)),
                        tostring(prestigeDisplay),
                        tostring(prestigeReadyTxt),
                        tostring(v165_3(st.Gold)),
                        tostring(st.WeaponGradeLetter or st.GradeLetter or "E-"),
                        tonumber(st.WeaponMinLevel) or 0,
                        tostring(st.TargetMap or "Shiganshina"),
                        tostring(st.Bracket and st.Bracket.DiffVI or "Dễ"),
                        tostring(nextBracketTxt or "N/A")
                    ))
                else
                    v56_2.KaitunStatusParagraph:Set(string.format(
                        "Kaitun Mode: %s\nAction: %s\nLevel: Lv.%s / %s (Prestige %s)\nPrestige Progress: %s\nCurrent Gold: %s\nWeapon Grade: [%s GRADE] (Lv.%d/15)\nTarget Map & Difficulty: %s - %s (%s GRADE)\nNext Difficulty Unlock: %s",
                        tostring(enabledStr),
                        tostring(kaitunActionState),
                        tostring(v165_3(st.Level)),
                        tostring(v165_3(st.MaxLevelCap)),
                        tostring(prestigeDisplay),
                        tostring(prestigeReadyTxt),
                        tostring(v165_3(st.Gold)),
                        tostring(st.WeaponGradeLetter or st.GradeLetter or "E-"),
                        tonumber(st.WeaponMinLevel) or 0,
                        tostring(st.TargetMap or "Shiganshina"),
                        tostring(st.Bracket and st.Bracket.DiffEN or "Easy"),
                        tostring(st.Bracket and st.Bracket.Grade or "E-"),
                        tostring(nextBracketTxt or "N/A")
                    ))
                end
            end)
        end

        function v150_10.UpdateConfigParagraph()
            if not v56_2.ConfigStatusParagraph then
                return
            end
            pcall(function()
                local isVi = v150_9.IsVietnamese()
                local globalSync = v8_6("AutoLoadGlobalConfig") ~= false
                local kaitunOn = v8_6("KaitunEnabled") == true
                local autoFarmOn = v8_6("AutoFarm") == true
                local slotFile, normSlot = v15_getSlotFile(v8_6("SelectedSettingSlot") or v15_orderData.ActiveSlot or
                    "Setting 1")
                local createdList = (type(v15_orderData.Created) == "table" and #v15_orderData.Created > 0)
                    and table.concat(v15_orderData.Created, ", ")
                    or normSlot
                if isVi then
                    v56_2.ConfigStatusParagraph:Set(string.format(
                        "File Setting Đang Dùng: %s (%s)\nCác File Đã Tạo Theo Thứ Tự: %s\nTự Tải Setting Khi Đổi Map: %s\nTrạng Thái Lưu: Kaitun [%s] | Auto Farm [%s]",
                        normSlot,
                        slotFile,
                        createdList,
                        globalSync and "ĐANG BẬT (ON)" or "ĐANG TẮT (OFF)",
                        kaitunOn and "BẬT" or "TẮT",
                        autoFarmOn and "BẬT" or "TẮT"
                    ))
                else
                    v56_2.ConfigStatusParagraph:Set(string.format(
                        "Active Setting File: %s (%s)\nSaved Files (In Order): %s\nAuto-Load On Map Change: %s\nSaved State: Kaitun [%s] | Auto Farm [%s]",
                        normSlot,
                        slotFile,
                        createdList,
                        globalSync and "ENABLED (ON)" or "DISABLED (OFF)",
                        kaitunOn and "ON" or "OFF",
                        autoFarmOn and "ON" or "OFF"
                    ))
                end
            end)
        end

        function v150_10.StopKaitunLoop()
            kaitunActionState = "Idle"
            if kaitunLoopThread then
                pcall(function()
                    task.cancel(kaitunLoopThread)
                end)
                kaitunLoopThread = nil
            end
            v150_10.UpdateKaitunParagraph()
            v150_10.UpdateConfigParagraph()
        end

        function v150_10.StartKaitunLoop()
            if kaitunLoopThread then
                return
            end
            if not v18_4 then
                v18_4 = true
                v22_2 = true
                v9_4("AutoFarm", true)
                v116_4(v23_2)
                v150_10.StartAutoGas()
                task.spawn(v148_4)
                if v56_2.AutoFarm then
                    v56_2.AutoFarm:SetState(true)
                end
            end
            if not v25_2 then
                v25_2 = true
                v9_4("AutoReload", true)
                if v56_2.AutoReload then
                    v56_2.AutoReload:SetState(true)
                end
            end
            if not v38_2 then
                v38_2 = true
                v9_4("AutoRetry", true)
                v110_3()
                if v56_2.AutoRetry then
                    v56_2.AutoRetry:SetState(true)
                end
            end
            if not v39_2 then
                v39_2 = true
                v9_4("AutoSkipCutscenes", true)
                v112_3()
                if v56_2.AutoSkipCutscenes then
                    v56_2.AutoSkipCutscenes:SetState(true)
                end
            end

            kaitunLoopThread = task.spawn(function()
                while v8_6("KaitunEnabled") do
                    local st = v150_10.GetKaitunPlayerState()
                    local inLobby = (game.PlaceId == 14916516914 or game.PlaceId == 13379208636)

                    pcall(function()
                        v150_10.CheckShadowBan(false)
                    end)

                    if inLobby then
                        if v8_6("KaitunAutoPrestige") ~= false and st.ReadyToPrestige then
                            v150_10.KaitunPerformPrestige()
                            st = v150_10.GetKaitunPlayerState()
                        end
                        if v8_6("KaitunAutoUpgradeWeapon") ~= false and st.CanUpgradeStep then
                            v150_10.KaitunUpgradeWeapon()
                            st = v150_10.GetKaitunPlayerState()
                        end
                        if v8_6("KaitunAutoMap") ~= false then
                            v150_10.KaitunCreateAndStartMission()
                        else
                            kaitunActionState = "In Lobby (Waiting)"
                        end
                    else
                        if not v18_4 then
                            v18_4 = true
                            v22_2 = true
                            v116_4(v23_2)
                            v150_10.StartAutoGas()
                            task.spawn(v148_4)
                        end
                        local isMatchEnded = v150_10.IsMatchEnded()

                        if isMatchEnded then
                            if v150_10.ShouldKaitunReturnToLobby() then
                                v150_10.KaitunReturnToLobby()
                            else
                                kaitunActionState = "Retrying Mission [" .. st.Bracket.Grade .. " GRADE]"
                                v150_10.HandleRetryAndContinueScreen()
                            end
                        else
                            if v8_6("KaitunAutoUpgradeWeapon") ~= false and v13_8:FindFirstChild("Waves") and st.CanUpgradeStep then
                                v150_10.KaitunUpgradeWeapon()
                            end
                            kaitunActionState = "Farming Titans [" .. st.Bracket.Grade .. " GRADE]"
                        end
                    end

                    v150_10.UpdateKaitunParagraph()
                    v150_10.UpdateConfigParagraph()
                    task.wait(1.2)
                end
                kaitunLoopThread = nil
                kaitunActionState = "Idle"
                v150_10.UpdateKaitunParagraph()
                v150_10.UpdateConfigParagraph()
            end)
        end

        function v150_10.ApplySettingsToUI(startRuntimeFeatures)
            local prevRestoring = v15_isRestoring
            v15_isRestoring = true
            pcall(function()
                v28_2 = tonumber(v8_6("WalkSpeedAmount")) or 1
                v30_2 = tonumber(v8_6("LaggyRunDistance")) or 1
                v31_2 = tonumber(v8_6("LaggyRunDelay")) or 1
                if v8_6("AutoFarm") == true and v16_9["HitboxSize"] == nil then
                    v23_2 = 100
                else
                    v23_2 = tonumber(v8_6("HitboxSize")) or 20
                end
                v58_2 = tonumber(v8_6("DelayToKillAmount")) or 1
                v60_2 = tonumber(v8_6("DistanceToTitan")) or 0
                v61_2.UpgradeDelay = tonumber(v8_6("UpgradeDelay")) or 0

                if v56_2.WalkSpeedSlider then v56_2.WalkSpeedSlider:SetValue(v28_2) end
                if v56_2.LaggyRunDistSlider then v56_2.LaggyRunDistSlider:SetValue(v30_2) end
                if v56_2.LaggyRunDelaySlider then v56_2.LaggyRunDelaySlider:SetValue(v31_2) end
                if v56_2.DelayToKillSlider then v56_2.DelayToKillSlider:SetValue(v58_2) end
                if v56_2.DistanceToTitanSlider then v56_2.DistanceToTitanSlider:SetValue(v60_2) end
                if v56_2.HitboxSizeSlider then v56_2.HitboxSizeSlider:SetValue(v23_2) end
                if v56_2.UpgradeDelaySlider then v56_2.UpgradeDelaySlider:SetValue(v61_2.UpgradeDelay) end

                local fStop = v8_6("FamiliesToStop")
                if type(fStop) == "table" and v56_2.FamiliesDropdown then
                    v43_2 = v150_9.toOptionSet(fStop)
                    v56_2.FamiliesDropdown:SetSelected(fStop)
                end
                local ftStop = v8_6("FamilyTiersToStop")
                if type(ftStop) == "table" and v56_2.FamilyTiersDropdown then
                    v44_3 = v150_9.toOptionSet(ftStop)
                    v56_2.FamilyTiersDropdown:SetSelected(ftStop)
                end
                local ptSell = v8_6("PerkTiersToSell")
                if type(ptSell) == "table" and v56_2.PerkTiersDropdown then
                    v46_2 = v150_9.toOptionSet(ptSell)
                    v56_2.PerkTiersDropdown:SetSelected(ptSell)
                end
                local spSell = v8_6("SpecificPerksToSell")
                if type(spSell) == "table" and v56_2.SpecificPerksDropdown then
                    v47_3 = v150_9.toOptionSet(spSell)
                    v56_2.SpecificPerksDropdown:SetSelected(spSell)
                end

                v19_3 = v8_6("NoClip") == true
                if v56_2.NoClip then v56_2.NoClip:SetState(v19_3) end
                v27_2 = v8_6("WalkSpeed") == true
                if v56_2.WalkSpeed then v56_2.WalkSpeed:SetState(v27_2) end
                v29_2 = v8_6("LaggyRun") == true
                if v56_2.LaggyRun then v56_2.LaggyRun:SetState(v29_2) end
                v32_2 = v8_6("CtrlClickTP") == true
                if v56_2.CtrlClickTP then v56_2.CtrlClickTP:SetState(v32_2) end
                v33_2 = v8_6("InfiniteJump") == true
                if v56_2.InfiniteJump then v56_2.InfiniteJump:SetState(v33_2) end

                v25_2 = v8_6("AutoReload") == true
                if v56_2.AutoReload then v56_2.AutoReload:SetState(v25_2) end
                v57_3 = v8_6("DelayToKill") == true
                if v56_2.DelayToKill then v56_2.DelayToKill:SetState(v57_3) end
                v59_2 = v8_6("HitAll") == true
                if v56_2.HitAll then v56_2.HitAll:SetState(v59_2) end
                v22_2 = v8_6("ExpandNapeHitbox") == true or v8_6("AutoFarm") == true
                if v56_2.ExpandNapeHitbox then v56_2.ExpandNapeHitbox:SetState(v22_2) end
                v24_2 = v8_6("VisualizeHitbox") == true
                if v56_2.VisualizeHitbox then v56_2.VisualizeHitbox:SetState(v24_2) end
                v21_2 = v8_6("TitanESP") == true
                if v56_2.TitanESP then v56_2.TitanESP:SetState(v21_2) end
                v34_2 = v8_6("AutoRefill") == true
                if v56_2.AutoRefill then v56_2.AutoRefill:SetState(v34_2) end

                v37_2 = v8_6("ChangeCursor") == true
                if v56_2.ChangeCursor then v56_2.ChangeCursor:SetState(v37_2) end
                if v37_2 then v108_3() end

                v38_2 = v8_6("AutoRetry") == true
                if v56_2.AutoRetry then v56_2.AutoRetry:SetState(v38_2) end
                if v38_2 then v110_3() end

                v39_2 = v8_6("AutoSkipCutscenes") == true
                if v56_2.AutoSkipCutscenes then v56_2.AutoSkipCutscenes:SetState(v39_2) end
                if v39_2 then v112_3() end

                v40_2 = v8_6("AutoOpenRaidChests") == true
                if v56_2.AutoOpenRaidChests then v56_2.AutoOpenRaidChests:SetState(v40_2) end
                if v40_2 then v114_3() end

                v150_10.AutoRaid = v8_6("AutoRaid") == true
                if v56_2.AutoRaid then v56_2.AutoRaid:SetState(v150_10.AutoRaid) end

                v150_10.AutoClaimAchievements = v8_6("AutoClaimAchievements") ~= false
                if v56_2.AutoClaimAchievements then v56_2.AutoClaimAchievements:SetState(v150_10.AutoClaimAchievements) end
                if v150_10.AutoClaimAchievements and v150_10.ClaimAchievements then v150_10.ClaimAchievements() end

                v45_3 = v8_6("AutoSellPerks") == true
                if v56_2.AutoSellPerks then v56_2.AutoSellPerks:SetState(v45_3) end
                if v45_3 then
                    v187_20()
                    v188_24()
                end

                v48_3 = v8_6("AutoCreateTowers") == true
                if v56_2.AutoCreateTowers then v56_2.AutoCreateTowers:SetState(v48_3) end
                v49_2 = v8_6("AutoRetrieveSupplyCrates") == true
                if v56_2.AutoRetrieveSupplyCrates then v56_2.AutoRetrieveSupplyCrates:SetState(v49_2) end

                v61_2.AutoVoteReady = v8_6("AutoVoteReady") == true
                if v56_2.AutoVoteReady then v56_2.AutoVoteReady:SetState(v61_2.AutoVoteReady) end
                v61_2.AutoUpgradeMaxHQHP = v8_6("AutoUpgradeMaxHQHP") == true
                if v56_2.AutoUpgradeMaxHQHP then v56_2.AutoUpgradeMaxHQHP:SetState(v61_2.AutoUpgradeMaxHQHP) end
                v61_2.AutoUpgradeHQHealthRegen = v8_6("AutoUpgradeHQHealthRegen") == true
                if v56_2.AutoUpgradeHQHealthRegen then
                    v56_2.AutoUpgradeHQHealthRegen:SetState(v61_2
                        .AutoUpgradeHQHealthRegen)
                end
                v61_2.AutoUpgradeRefillLimit = v8_6("AutoUpgradeRefillLimit") == true
                if v56_2.AutoUpgradeRefillLimit then v56_2.AutoUpgradeRefillLimit:SetState(v61_2.AutoUpgradeRefillLimit) end
                v61_2.AutoUpgradeWeapon = v8_6("AutoUpgradeWeapon") == true
                if v56_2.AutoUpgradeWeapon then v56_2.AutoUpgradeWeapon:SetState(v61_2.AutoUpgradeWeapon) end
                v61_2.AutoGetRetrieveSkillCrate = v8_6("AutoGetRetrieveSkillCrate") == true
                if v56_2.AutoGetRetrieveSkillCrate then
                    v56_2.AutoGetRetrieveSkillCrate:SetState(v61_2
                        .AutoGetRetrieveSkillCrate)
                end

                v150_10.AutoResetStreak = v8_6("AutoResetStreak") == true
                if v56_2.AutoResetStreak then v56_2.AutoResetStreak:SetState(v150_10.AutoResetStreak) end

                v18_4 = v8_6("AutoFarm") == true
                if v56_2.AutoFarm then v56_2.AutoFarm:SetState(v18_4) end

                if v56_2.KaitunEnabledToggle then
                    v56_2.KaitunEnabledToggle:SetState(v8_6("KaitunEnabled") == true)
                end
                if v56_2.KaitunAutoUpgradeToggle then
                    v56_2.KaitunAutoUpgradeToggle:SetState(v8_6("KaitunAutoUpgradeWeapon") ~= false)
                end
                if v56_2.KaitunWeaponDropdown then
                    v56_2.KaitunWeaponDropdown:SetSelected(tostring(v8_6("KaitunWeaponType") or "Auto"))
                end
                if v56_2.KaitunAutoMapToggle then
                    v56_2.KaitunAutoMapToggle:SetState(v8_6("KaitunAutoMap") ~= false)
                end
                if v56_2.KaitunMapDropdown then
                    v56_2.KaitunMapDropdown:SetSelected(tostring(v8_6("KaitunMap") or "Auto (Best)"))
                end
                if v56_2.KaitunAutoPrestigeToggle then
                    v56_2.KaitunAutoPrestigeToggle:SetState(v8_6("KaitunAutoPrestige") ~= false)
                end
                if v56_2.KaitunMaxPrestigeSlider then
                    v56_2.KaitunMaxPrestigeSlider:SetValue(tonumber(v8_6("KaitunMaxPrestige")) or 5)
                end
                if v56_2.SettingSlotDropdown then
                    local _, normSlot = v15_getSlotFile(v8_6("SelectedSettingSlot") or v15_orderData.ActiveSlot or
                        "Setting 1")
                    v56_2.SettingSlotDropdown:SetSelected(normSlot)
                end
                if v56_2.AutoLoadGlobalToggle then
                    v56_2.AutoLoadGlobalToggle:SetState(v8_6("AutoLoadGlobalConfig") ~= false)
                end
                if v56_2.LanguageDropdown then
                    v56_2.LanguageDropdown:SetSelected(v150_9.GetLanguage())
                end

                if startRuntimeFeatures then
                    if v19_3 then v98_2() else v99_2() end
                    if v27_2 then v100_3() else v101_2() end
                    if v29_2 then v102_3() else v103_2() end
                    if v32_2 then v104_3() else v105_3() end
                    if v33_2 then v106_3() else v107_2() end
                    if v22_2 then v116_4(v23_2) end
                    if v18_4 then
                        v150_10.StartAutoGas()
                        task.spawn(v148_4)
                    else
                        v150_10.StopAutoGas()
                    end
                end
            end)
            v15_isRestoring = prevRestoring
            if v8_6("KaitunEnabled") == true then
                v150_10.StartKaitunLoop()
            else
                v150_10.StopKaitunLoop()
            end
            v150_10.UpdateKaitunParagraph()
            v150_10.UpdateConfigParagraph()
        end

        function v150_10.SaveAllSettings()
            for k, defVal in pairs(v13_2) do
                if v16_9[k] == nil then
                    v16_9[k] = defVal
                end
            end
            local slotFile, normSlot = v15_getSlotFile(v16_9.SelectedSettingSlot or v15_orderData.ActiveSlot or
                "Setting 1")
            v16_9.SelectedSettingSlot = normSlot
            v15_22(v16_9)
            local raw = v5_6:JSONEncode(v16_9)
            v11("Symbiote_GlobalSettings.json", raw)
            v11(slotFile, raw)
            v150_10.UpdateConfigParagraph()
            local isVi = v150_9.IsVietnamese()
            pcall(function()
                v12_4:Notify({
                    Title = isVi and "Đã Lưu Cài Đặt" or "Settings Saved",
                    Content = isVi
                        and ("Đã lưu vào " .. normSlot .. " (" .. slotFile .. ")!")
                        or ("Saved configuration to " .. normSlot .. " (" .. slotFile .. ")!"),
                    Duration = 3
                })
            end)
        end

        function v150_10.CreateNextSettingInOrder()
            local nextNum = 1
            if type(v15_orderData.Created) == "table" and #v15_orderData.Created > 0 then
                nextNum = (tonumber(v15_orderData.LastOrder) or #v15_orderData.Created) + 1
                if nextNum > 10 then
                    nextNum = 1
                end
            end
            local slotFile, normSlot = v15_getSlotFile("Setting " .. tostring(nextNum))
            v16_9.SelectedSettingSlot = normSlot
            v15_orderData.ActiveSlot = normSlot
            v15_orderData.LastOrder = nextNum
            v15_22(v16_9)
            if v56_2.SettingSlotDropdown then
                v56_2.SettingSlotDropdown:SetSelected(normSlot)
            end
            v150_10.UpdateConfigParagraph()
            local isVi = v150_9.IsVietnamese()
            pcall(function()
                v12_4:Notify({
                    Title = isVi and "Tạo File Setting Theo Thứ Tự" or "Created Sequential Setting",
                    Content = isVi
                        and ("Đã tạo & lưu " .. normSlot .. " (" .. slotFile .. ")!")
                        or ("Created & saved " .. normSlot .. " (" .. slotFile .. ")!"),
                    Duration = 3
                })
            end)
        end

        function v150_10.SelectSettingSlot(slotName)
            local slotFile, normSlot = v15_getSlotFile(slotName)
            v15_orderData.ActiveSlot = normSlot
            v16_9.SelectedSettingSlot = normSlot
            v15_saveOrderData()
            local rawSlot = v10_3(slotFile)
            if rawSlot then
                local ok, decoded = pcall(function()
                    return v5_6:JSONDecode(rawSlot)
                end)
                if ok and type(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        v16_9[k] = v
                    end
                    v16_9.SelectedSettingSlot = normSlot
                    v15_22(v16_9)
                    if type(v16_9.Language) == "string" and v16_9.Language ~= v150_9.GetLanguage() then
                        v150_9.SetLanguage(v16_9.Language)
                    end
                    v150_10.ApplySettingsToUI(true)
                    local isVi = v150_9.IsVietnamese()
                    pcall(function()
                        v12_4:Notify({
                            Title = isVi and ("Đã Chuyển Sang " .. normSlot) or ("Switched To " .. normSlot),
                            Content = isVi
                                and ("Đã tải tự động file " .. slotFile .. "!")
                                or ("Automatically loaded " .. slotFile .. "!"),
                            Duration = 3
                        })
                    end)
                    return
                end
            end
            v15_22(v16_9)
            v150_10.UpdateConfigParagraph()
        end

        function v150_10.LoadAllSettings()
            local slotFile, normSlot = v15_getSlotFile(v8_6("SelectedSettingSlot") or v15_orderData.ActiveSlot or
                "Setting 1")
            local rawG = v10_3(slotFile) or v10_3("Symbiote_GlobalSettings.json") or v10_3(v12)
            if rawG then
                local ok, decoded = pcall(function()
                    return v5_6:JSONDecode(rawG)
                end)
                if ok and type(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        v16_9[k] = v
                    end
                    v16_9.SelectedSettingSlot = normSlot
                    v15_22(v16_9)
                end
            end
            if type(v16_9.Language) == "string" and v16_9.Language ~= v150_9.GetLanguage() then
                v150_9.SetLanguage(v16_9.Language)
            end
            v150_10.ApplySettingsToUI(true)
            local isVi = v150_9.IsVietnamese()
            pcall(function()
                v12_4:Notify({
                    Title = isVi and "Đã Tải Cài Đặt" or "Settings Loaded",
                    Content = isVi
                        and ("Đã tải cấu hình từ " .. normSlot .. " (" .. slotFile .. ")!")
                        or ("Loaded configuration from " .. normSlot .. " (" .. slotFile .. ")!"),
                    Duration = 3
                })
            end)
        end

        function v150_10.ResetAllSettings()
            local _, normSlot = v15_getSlotFile(v8_6("SelectedSettingSlot") or v15_orderData.ActiveSlot or "Setting 1")
            for k, defVal in pairs(v13_2) do
                if type(defVal) == "table" then
                    v16_9[k] = {}
                else
                    v16_9[k] = defVal
                end
            end
            v16_9.SelectedSettingSlot = normSlot
            v15_22(v16_9)
            local raw = v5_6:JSONEncode(v16_9)
            v11("Symbiote_GlobalSettings.json", raw)
            v150_10.StopKaitunLoop()
            v150_10.ApplySettingsToUI(true)
        end

        local kTab = v56_2.KaitunTab
        if kTab then
            v56_2.KaitunStatusParagraph = kTab:AddParagraph("KAITUN STATUS:", "...")
            pcall(v150_10.UpdateKaitunParagraph)
            kTab:AddLabel("KAITUN AUTOMATION")
            v56_2.KaitunEnabledToggle = kTab:AddToggle("Enable Kaitun (Auto Level & Prestige)", function(p1)
                v9_4("KaitunEnabled", p1)
                if p1 then
                    v150_10.StartKaitunLoop()
                else
                    v150_10.StopKaitunLoop()
                end
                v150_10.UpdateConfigParagraph()
            end)
            kTab:AddLabel("WEAPON & MAP PROGRESSION")
            v56_2.KaitunAutoUpgradeToggle = kTab:AddToggle("Auto Upgrade Weapon (E- -> S)", function(p1)
                v9_4("KaitunAutoUpgradeWeapon", p1)
                v150_10.UpdateKaitunParagraph()
            end)
            v56_2.KaitunWeaponDropdown = kTab:AddSingleDropdown("Kaitun Weapon", { "Auto", "Blades", "Spears" },
                tostring(v8_6("KaitunWeaponType") or "Auto"), function(p1)
                    v9_4("KaitunWeaponType", p1)
                    v150_10.UpdateKaitunParagraph()
                end)
            v56_2.KaitunAutoMapToggle = kTab:AddToggle("Auto Select Map & Difficulty (E- -> S)", function(p1)
                v9_4("KaitunAutoMap", p1)
                v150_10.UpdateKaitunParagraph()
            end)
            v56_2.KaitunMapDropdown = kTab:AddSingleDropdown("Kaitun Map",
                { "Auto (Best)", "Shiganshina", "Trost", "Outskirts", "Giant Forest" },
                tostring(v8_6("KaitunMap") or "Auto (Best)"), function(p1)
                    v9_4("KaitunMap", p1)
                    v150_10.UpdateKaitunParagraph()
                end)
            kTab:AddButton("Upgrade Weapon Now", function()
                task.spawn(function()
                    v150_10.KaitunUpgradeWeapon()
                    v150_10.UpdateKaitunParagraph()
                end)
            end)
            kTab:AddLabel("AUTO PRESTIGE (REBIRTH)")
            v56_2.KaitunAutoPrestigeToggle = kTab:AddToggle("Auto Prestige (Rebirth)", function(p1)
                v9_4("KaitunAutoPrestige", p1)
                v150_10.UpdateKaitunParagraph()
            end)
            v56_2.KaitunMaxPrestigeSlider = kTab:AddSlider("Target Max Prestige", 1, 5,
                tonumber(v8_6("KaitunMaxPrestige")) or 5, function(p1)
                    v9_4("KaitunMaxPrestige", p1)
                    v150_10.UpdateKaitunParagraph()
                end)
            kTab:AddLabel("SHADOW BAN DETECTION")
            v56_2.ShadowBanParagraph = kTab:AddParagraph("SHADOW BAN STATUS:", "...")
            kTab:AddButton("Check Shadow Ban Now", function()
                task.spawn(function()
                    v150_10.CheckShadowBan(true)
                end)
            end)
        end

        local sTab = v56_2.SettingsTab
        if sTab then
            v56_2.ConfigStatusParagraph = sTab:AddParagraph("CONFIG STATUS:", "...")
            pcall(v150_10.UpdateConfigParagraph)
            sTab:AddLabel("CONFIG & SETTINGS")
            v56_2.SettingSlotDropdown = sTab:AddSingleDropdown("Select Setting File (Order)", v15_SettingSlotsList,
                tostring(v8_6("SelectedSettingSlot") or "Setting 1"), function(p1)
                    v150_10.SelectSettingSlot(p1)
                end)
            sTab:AddButton("Create Next Setting File (In Order)", function()
                v150_10.CreateNextSettingInOrder()
            end)
            v56_2.AutoLoadGlobalToggle = sTab:AddToggle("Auto Load Global Settings", function(p1)
                v9_4("AutoLoadGlobalConfig", p1)
                v150_10.UpdateConfigParagraph()
            end)
            sTab:AddButton("Save Settings Now", function()
                v150_10.SaveAllSettings()
            end)
            sTab:AddButton("Load Saved Settings", function()
                v150_10.LoadAllSettings()
            end)
            sTab:AddButton("Reset Default Settings", function()
                v150_10.ResetAllSettings()
            end)
        end

        v15_isRestoring = false
        v150_10.ApplySettingsToUI(false)
        pcall(function()
            if v150_10.UpdateKaitunParagraph then v150_10.UpdateKaitunParagraph() end
            if v150_10.UpdateConfigParagraph then v150_10.UpdateConfigParagraph() end
            if v150_10.UpdateShadowBanParagraph then v150_10.UpdateShadowBanParagraph() end
        end)

        task.spawn(function()
            while true do
                task.wait(6)
                if v150_10.CheckShadowBan then
                    pcall(function()
                        v150_10.CheckShadowBan(false)
                    end)
                end
            end
        end)
    end
    task.spawn(function()
        local v1 = v7_13 or v6_21.LocalPlayer
        local v2_2 = os.clock()
        local v3 = v13_8:FindFirstChild("Titans") ~= nil or v13_8:FindFirstChild("Characters") ~= nil
        while os.clock() - v2_2 < 35 do
            local v5_10 = v13_8:FindFirstChild("Characters")
            local v4_16 = v5_10 and v5_10:FindFirstChild(v7_13.Name) or v7_13.Character
            local v5_20 = v4_16 and v4_16:FindFirstChild("HumanoidRootPart")
            local v6_10 = v4_16 and v4_16:FindFirstChild("Humanoid")
            local v7_6 = v1 and v1:FindFirstChild("PlayerGui")
            local v8_5 = v7_6 and v7_6:FindFirstChild("Fullscreen")
            local v9_3 = v8_5 and v8_5:FindFirstChild("Loading_Screen")
            local v10_3 = v7_6 and v7_6:FindFirstChild("Interface")
            local v11_3 = not v9_3 or v9_3.Visible == false
            local v12_4
            if v3 then
                v12_4 = v5_20 ~= nil and v6_10 ~= nil and (v4_16 and v4_16:GetAttribute("Setup")) == true
            else
                v12_4 = v5_20 ~= nil and v6_10 ~= nil
            end
            if v11_3 and v12_4 and (v10_3 == nil or v10_3.Enabled ~= false) then
                break
            else
                task.wait(0.3)
            end
        end
        task.wait(0.5)
        v150_10.ApplySettingsToUI(true)
        if v8_6("AutoCreateTowers") then
            v123_4()
            v128_2()
        end
        if v8_6("AutoRetrieveSupplyCrates") then
            v51_2()
            task.spawn(v50_2)
        end
        if v8_6("AutoVoteReady") then
            task.spawn(v130_4)
            v62_3()
        end
        if v8_6("AutoUpgradeMaxHQHP") or v8_6("AutoUpgradeHQHealthRegen") or v8_6("AutoUpgradeRefillLimit") or v8_6("AutoUpgradeWeapon") then
            v62_3()
        end
        if v8_6("AutoGetRetrieveSkillCrate") then
            v62_3()
            task.spawn(v63_9)
        end
        -- Background standing task: Auto Claim Daily Reward (always on), Achievements, and Auto Retry Watchdog
        task.spawn(function()
            task.wait(2.0)
            if v150_10.ClaimDailyReward then pcall(v150_10.ClaimDailyReward) end
            if v150_10.AutoClaimAchievements and v150_10.ClaimAchievements then pcall(v150_10.ClaimAchievements) end
            while true do
                task.wait(10)
                if v150_10.ClaimDailyReward then pcall(v150_10.ClaimDailyReward) end
                if v150_10.AutoClaimAchievements and v150_10.ClaimAchievements then pcall(v150_10.ClaimAchievements) end
                if v38_2 and (not autoRetryWatcherThread or coroutine.status(autoRetryWatcherThread) == "dead") then
                    pcall(v110_3)
                end
            end
        end)
        return
    end)
end
return
