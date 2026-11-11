
local v5_6 = game:GetService("HttpService")
local v6_21 = game:GetService("Players")
local v7_13 = v6_21.LocalPlayer
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
    AutoOpenRaidChests = false
}
local function v10_3(p1)
    local v2_2, v3_2 = pcall(function()
        local v1 = syn and syn.read_file or readfile
        if v1 then
            return v1(p1)
        end
        return nil
    end)
    if v2_2 and v3_2 and v3_2 ~= "" then
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
local function v15_22(p1)
    local v2_2, v3_2 = pcall(function()
        return v5_6:JSONEncode(p1)
    end)
    if v2_2 and v3_2 then
        v11(v12, v3_2)
    end
    return
end
local v16_9 = (function()
    local v1 = v10_3(v12)
    if v1 then
        local v2_3, v3_2 = pcall(function()
            return v5_6:JSONDecode(v1)
        end)
        if v2_3 and type(v3_2) == "table" then
            return v3_2
        end
    end
    return {}
end)()
local function v8_6(p1)
    if v16_9[p1] ~= nil then
        return v16_9[p1]
    end
    return v13_2[p1]
end
local function v9_4(p1, p2)
    v16_9[p1] = p2
    v15_22(v16_9)
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
        getnamecallmethod = type(getnamecallmethod) == "function",
        checkcaller = type(checkcaller) == "function",
        getconnections = type(getconnections) == "function",
        newcclosure = type(newcclosure) == "function"
    },
    OriginalSizes = setmetatable({}, { __mode = "k" }),
    HooksInstalled = false,
    BlockedRemotes = 0,
    BlockedKicks = 0,
    IsolatedScripts = 0,
    AutoGasThread = nil
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
    v67_2 = run_on_actor or runonactor or syn and (syn.run_on_actor or syn.runonactor) or getgenv and (getgenv().run_on_actor or getgenv().runonactor)
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
    v70_2()
    v71_3 = function()
        local v1_3 = v13_8:FindFirstChild("Characters")
        return v1_3 and v1_3:FindFirstChild(v7_13.Name) or v7_13.Character
    end
    v72_2 = function()
        local v1_2 = v71_3()
        return v1_2 and v1_2:FindFirstChild("Rig_" .. v7_13.Name) or nil
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
        if v1 then
            return v2_2
        end
        return nil
    end
    local function v83_2()
        local v1, v2_2 = pcall(function()
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
        if v1 then
            return v2_2
        end
        return false
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
        local v2_2 = p1:FindFirstChild("Hitboxes")
        if not v2_2 then
            return nil
        end
        local v3_5 = v2_2:FindFirstChild("Hit")
        if not v3_5 then
            return nil
        end
        return v3_5:FindFirstChild("Nape")
    end
    v90_2 = function(p1)
        if not p1 or not p1.Parent then
            return true
        end
        local v2_4 = p1:FindFirstChild("HumanoidRootPart")
        if not v2_4 then
            return true
        end
        if v2_4.Anchored == true then
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
        local v2_3 = v13_8:FindFirstChild("Titans")
        if not v2_3 then
            return false
        end
        if p1.Parent ~= v2_3 then
            return false
        end
        return not v90_2(p1)
    end
    local function v92_2()
        local v1 = pcall
        v1(function()
            local v1_2 = v71_3()
            local v2 = v1_2 and v1_2:FindFirstChild("Actor") or v66 and v66()[1]
            if v2 and v67_2 then
                v67_2(v2, "                pcall(function()\n                    local obj = _G.__CachedHost\n                    if not obj or type(obj) ~= \"table\" or not rawget(obj, \"Cache\") then\n                        for _, v in ipairs(getgc(true)) do\n                            if type(v) == \"table\" and type(rawget(v, \"Cache\")) == \"table\" and rawget(v, \"Services\") and rawget(v, \"Modules\") then\n                                obj = v\n                                _G.__CachedHost = v\n                                break\n                            end\n                        end\n                    end\n                    if obj then\n                        obj.Spear_State = nil\n                        obj.Using_Spear = nil\n                        obj.Detonate = nil\n                        obj.Can_Detonate = nil\n\n                        if type(obj.Cache.Variables) == \"table\" and obj.Cache.Variables.Slash then\n                            obj.Cache.Variables.Slash.Slashing = false\n                            obj.Cache.Variables.Slash.Holding = false\n                            obj.Cache.Variables.Slash.Released = false\n                        end\n\n                        if obj.Events then\n                            if obj.Events.Spear_Stepped_2 then\n                                pcall(function() obj.Events.Spear_Stepped_2:Disconnect() end)\n                                obj.Events.Spear_Stepped_2 = nil\n                            end\n                            if obj.Events.Spear_Stepped then\n                                pcall(function() obj.Events.Spear_Stepped:Disconnect() end)\n                                obj.Events.Spear_Stepped = nil\n                            end\n                        end\n\n                        if type(obj.Cache.Interface) == \"table\" and obj.Cache.Interface.Cursor and obj.Cache.Interface.Cursor.Distance2 then\n                            obj.Cache.Interface.Cursor.Distance2.Visible = false\n                        end\n\n                        if type(obj.Cache.Tracks) == \"table\" then\n                            for name, track in pairs(obj.Cache.Tracks) do\n                                if tostring(name):find(\"Spear\") or tostring(name):find(\"Hit\") or tostring(name):find(\"Slash\") then\n                                    pcall(function() track:Stop(0.1) end)\n                                end\n                            end\n                        end\n\n                        if type(obj.Cache.Animations) == \"table\" then\n                            for name, track in pairs(obj.Cache.Animations) do\n                                if tostring(name):find(\"Spear\") or tostring(name):find(\"Hit\") or tostring(name):find(\"Slash\") then\n                                    pcall(function() track:Stop(0.1) end)\n                                end\n                            end\n                        end\n                    end\n                end)\n            ")
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
                v67_2(v5_16, string.format("                local host = _G.__CachedHost\n                if type(host) ~= \"table\"\n                    or type(rawget(host, \"Modules\")) ~= \"table\"\n                    or type(rawget(host, \"Cache\")) ~= \"table\"\n                    or not host.Modules.Zones\n                then\n                    host = nil\n                    _G.__CachedHost = nil\n                    for _, obj in ipairs(getgc(true)) do\n                        if type(obj) == \"table\"\n                            and type(rawget(obj, \"Modules\")) == \"table\"\n                            and type(rawget(obj, \"Cache\")) == \"table\"\n                            and rawget(obj, \"Services\")\n                            and obj.Modules.Zones\n                        then\n                            host = obj\n                            _G.__CachedHost = obj\n                            break\n                        end\n                    end\n                end\n\n                if host then\n                    if host.Loadout and host.Loadout.Stats then\n                        host.Loadout.Stats.Crit_Chance = 100\n                        host.Loadout.Stats.Strike = %d\n                    end\n                    local zones = host.Modules.Zones\n                    if zones and not zones.__SymbioteCritHooked and type(zones.Damage_Check) == \"function\" then\n                        zones.__SymbioteCritHooked = true\n                        local origDamageCheck = zones.Damage_Check\n                        zones.Damage_Check = function(p2, p3, p4, p5, p6, p7, p8, p9)\n                            return origDamageCheck(p2, p3, p4, true, p6, p7, p8, p9)\n                        end\n                    end\n                end\n            ", #v2_3))
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
        local v2_3 = v13_8:FindFirstChild("Titans")
        if not v2_3 then
            return
        end
        for v6, v7 in ipairs(v2_3:GetChildren()) do
            v95_8(v7, p1)
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
        local v2_7 = {}
        local v3_6 = {}
        local v4_2 = v59_2 and 8 or 1
        if type(p1) == "table" then
            for v8_2, v9_2 in ipairs(p1) do
                if typeof(v9_2) == "Instance" then
                    local v10_4 = v9_2:IsA("Model") and v9_2 or v9_2:FindFirstAncestorOfClass("Model")
                    local v11_5 = v9_2:IsA("BasePart") and v9_2.Name == "Nape" and v9_2
                    if not v11_5 then
                        v11_5 = v10_4
                        if v11_5 then
                            local v12_8 = v10_4:FindFirstChild("Hitboxes")
                            if not v12_8 then
                                v11_5 = nil
                            else
                                local v13_13 = v12_8:FindFirstChild("Hit")
                                if not v13_13 then
                                    v11_5 = nil
                                else
                                    v11_5 = v13_13:FindFirstChild("Nape")
                                end
                            end
                        end
                    end
                    local v12_6 = v10_4 and v11_5
                    if v12_6 then
                        if not v10_4 or not v10_4.Parent then
                            v12_6 = false
                        else
                            local v13_26 = v13_8:FindFirstChild("Titans")
                            if not v13_26 then
                                v12_6 = false
                            elseif v10_4.Parent ~= v13_26 then
                                v12_6 = false
                            else
                                v12_6 = not v90_2(v10_4)
                            end
                        end
                    end
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
            local v6_11 = p1:IsA("BasePart") and p1.Name == "Nape" and p1 or v5_8 and v89_2(v5_8)
            if v5_8 and v6_11 and v91_2(v5_8) then
                table.insert(v2_7, v5_8)
                table.insert(v3_6, v6_11)
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
        local v12_10 = math.max(100, (55 + v60_2) * 2 + 30)
        if v8_8 and v8_8:IsA("BasePart") then
            if not v150_10.OriginalSizes[v8_8] then
                v150_10.OriginalSizes[v8_8] = v11_9
            end
            v8_8.CollisionGroup = "Default"
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
                        v24_3.CanTouch = v24_3.Name == "Nape"
                    end
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
            v9_6:SetAttribute("SlashHandled", false)
            pcall(function()
                v67_2(v9_6, "                local Players = game:GetService(\"Players\")\n                local lp = Players.LocalPlayer\n                local chars = workspace:FindFirstChild(\"Characters\")\n                local c = (chars and chars:FindFirstChild(lp.Name)) or lp.Character\n                local act = c and c:FindFirstChild(\"Actor\")\n                if not act then return end\n\n                local targetId = act:GetAttribute(\"TargetTitan\")\n                local targetNamesStr = act:GetAttribute(\"TargetTitanNames\") or \"\"\n                local nameMap = {}\n                for name in string.gmatch(targetNamesStr, \"[^,]+\") do\n                    nameMap[name] = true\n                end\n                local maxTargets = tonumber(act:GetAttribute(\"SlashMaxTargets\")) or 1\n                local tit = workspace:FindFirstChild(\"Titans\")\n                local napes = {}\n                if tit then\n                    for _, m in ipairs(tit:GetChildren()) do\n                        if (targetId and m:GetAttribute(\"__SymbioteTarget\") == targetId) or nameMap[m.Name] then\n                            local np = m:FindFirstChild(\"Hitboxes\") and m.Hitboxes:FindFirstChild(\"Hit\") and m.Hitboxes.Hit:FindFirstChild(\"Nape\")\n                            if np then\n                                table.insert(napes, np)\n                                if #napes >= maxTargets then\n                                    break\n                                end\n                            end\n                        end\n                    end\n                    if #napes == 0 then\n                        for _, m in ipairs(tit:GetChildren()) do\n                            if m:IsA(\"Model\") and not m:GetAttribute(\"State\") then\n                                local np = m:FindFirstChild(\"Hitboxes\") and m.Hitboxes:FindFirstChild(\"Hit\") and m.Hitboxes.Hit:FindFirstChild(\"Nape\")\n                                if np then\n                                    table.insert(napes, np)\n                                    if #napes >= maxTargets then break end\n                                end\n                            end\n                        end\n                    end\n                end\n\n                local h = c and c:FindFirstChild(\"HumanoidRootPart\")\n                local hm = c and c:FindFirstChild(\"Humanoid\")\n                local hb = c and c:FindFirstChild(\"Hitbox\")\n                if hb and hb:IsA(\"BasePart\") then\n                    hb.CanTouch = true\n                end\n\n                local host = _G.__CachedHost\n                if type(host) ~= \"table\"\n                    or type(rawget(host, \"Modules\")) ~= \"table\"\n                    or type(rawget(host, \"Cache\")) ~= \"table\"\n                    or host.Cache.Character ~= c\n                    or not host.Modules.Zones\n                    or not host.Modules.Input\n                    or not host.Modules.ODMG\n                    or not host.Modules.Effects\n                then\n                    host = nil\n                    _G.__CachedHost = nil\n                    local now = os.clock()\n                    local lastScan = _G.__LastHostScan or 0\n                    if (now - lastScan) >= 1 then\n                        _G.__LastHostScan = now\n                        for _, obj in ipairs(getgc(true)) do\n                            if type(obj) == \"table\"\n                                and type(rawget(obj, \"Modules\")) == \"table\"\n                                and type(rawget(obj, \"Cache\")) == \"table\"\n                                and obj.Cache.Character == c\n                                and obj.Modules.Zones\n                            then\n                                host = obj\n                                _G.__CachedHost = obj\n                                break\n                            end\n                        end\n                    end\n                end\n\n                if host and #napes > 0 and h and hm then\n                    act:SetAttribute(\"SlashHandled\", true)\n                    pcall(function()\n                        local slash = host.Cache.Variables.Slash\n                        local odmg = host.Modules.ODMG\n                        local inputMod = host.Modules.Input\n                        local effects = host.Modules.Effects\n                        local zones = host.Modules.Zones\n\n                        if inputMod.Slashing then\n                            pcall(function() task.cancel(inputMod.Slashing) end)\n                            inputMod.Slashing = nil\n                        end\n                        if type(odmg.Events) == \"table\" then\n                            for _, ev in pairs(odmg.Events) do\n                                pcall(function() task.cancel(ev) end)\n                            end\n                            table.clear(odmg.Events)\n                        end\n\n                        if effects.Slash_State == true then\n                            pcall(function() effects.Slash(host, false, true) end)\n                            effects.Slash_State = false\n                        end\n\n                        host.Invoked = false\n                        if host.Modules.Shift then\n                            host.Modules.Shift.Stunned = false\n                        end\n\n                        if host.Loadout and host.Loadout.Stats then\n                            host.Loadout.Stats.Crit_Chance = 100\n                            host.Loadout.Stats.Strike = maxTargets\n                        end\n\n                        if not zones.__SymbioteCritHooked and type(zones.Damage_Check) == \"function\" then\n                            zones.__SymbioteCritHooked = true\n                            local origDamageCheck = zones.Damage_Check\n                            zones.Damage_Check = function(p2, p3, p4, p5, p6, p7, p8, p9)\n                                return origDamageCheck(p2, p3, p4, true, p6, p7, p8, p9)\n                            end\n                        end\n\n                        slash.Slashing = false\n                        slash.Released = false\n                        slash.Holding = false\n                        slash.Cooldown = false\n                        slash.Combo = 0\n                        table.clear(zones.Hit)\n\n                        if not host.__OrigTasks and type(odmg.Tasks) == \"function\" then\n                            host.__OrigTasks = odmg.Tasks\n                        end\n                        odmg.Tasks = function() end\n                        pcall(function() odmg.M1(host, false) end)\n                        if host.__OrigTasks then\n                            odmg.Tasks = host.__OrigTasks\n                        end\n\n                        slash.Slashing = true\n                        slash.Released = false\n                        slash.Holding = false\n                        slash.Type = \"Air\"\n                        slash.Last = tick() - 0.65\n                        zones.Time_Difference = 0.65\n\n                        task.wait(0.04)\n\n                        table.clear(zones.Hit)\n                        pcall(function() inputMod.Slash(host, h, hm) end)\n                        slash.Slashing = true\n                        slash.Released = true\n                        slash.Holding = false\n                        slash.Type = \"Air\"\n\n                        if effects.Slash_State ~= true then\n                            pcall(function() effects.Slash(host, true, true) end)\n                            effects.Slash_State = true\n                        end\n                        host:Send(\"Attacks\", \"Slash\", true)\n\n                        local a = hm:FindFirstChild(\"Animator\")\n                        if a then\n                            for _, track in ipairs(a:GetPlayingAnimationTracks()) do\n                                if track.Priority == Enum.AnimationPriority.Action4 or track.Priority == Enum.AnimationPriority.Action3 or track.Name:find(\"Hit\") or track.Name:find(\"Slash\") then\n                                    track:Stop(0)\n                                end\n                            end\n                        end\n\n                        for _, np in ipairs(napes) do\n                            table.insert(zones.Hit, np)\n                            host:Send(\"Hitboxes\", \"Register\", np, 0.65)\n                        end\n\n                        task.wait(0.12)\n\n                        if inputMod.Slashing then\n                            pcall(function() task.cancel(inputMod.Slashing) end)\n                            inputMod.Slashing = nil\n                        end\n                        slash.Slashing = false\n                        slash.Released = false\n                        slash.Holding = false\n                        pcall(function() effects.Slash(host, false, true) end)\n                        if effects.Slash_State ~= false then\n                            effects.Slash_State = false\n                        end\n                        host:Send(\"Attacks\", \"Slash\", false)\n                    end)\n                end\n\n                act:SetAttribute(\"SlashDone\", true)\n            ")
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
    v111_3 = function()
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
        v113_2 = task.spawn(function()
            local v1_3 = v7_13:WaitForChild("PlayerGui", 15)
            local v2 = v1_3 and v1_3:WaitForChild("Interface", 15)
            local v3_3 = v2 and v2:WaitForChild("Rewards", 15)
            if not v3_3 or not v38_2 then
                return
            end
            if v3_3.Visible then
                task.wait(1)
                if v38_2 then
                    pcall(function()
                        v69_2:InvokeServer("Functions", "Retry", "Add")
                        return
                    end)
                end
            end
            v112_2 = v3_3:GetPropertyChangedSignal("Visible"):Connect(function()
                if not v38_2 or not v3_3.Visible then
                    return
                end
                task.wait(1)
                if v38_2 then
                    pcall(function()
                        v69_2:InvokeServer("Functions", "Retry", "Add")
                        return
                    end)
                end
                return
            end)
            v113_2 = nil
            return
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
    v113_3 = function()
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
        v116_2 = task.spawn(function()
            local v1_3 = v7_13:WaitForChild("PlayerGui", 15)
            local v2 = v1_3 and v1_3:WaitForChild("Interface", 15)
            local v3_3 = v2 and v2:WaitForChild("Skip", 15)
            if not v3_3 or not v39_2 then
                return
            end
            if v3_3.Visible then
                task.spawn(function()
                    v119_2(v3_3)
                    return
                end)
            end
            v114_2 = v3_3:GetPropertyChangedSignal("Visible"):Connect(function()
                if not v39_2 or not v3_3.Visible then
                    return
                end
                task.spawn(function()
                    v119_2(v3_3)
                    return
                end)
                return
            end)
            v116_2 = nil
            return
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
    local function v119_5(p1)
        local v2 = v89_2(p1) or p1 and p1:FindFirstChild("HumanoidRootPart")
        if not v2 then
            return nil
        end
        if v73_2() then
            return CFrame.lookAt(v2.Position + Vector3.new(0, 48, 0) - v2.CFrame.LookVector * (75 + v60_2), v2.Position)
        end
        local v3_8 = os.clock() * 8
        local v4_6 = 55 + v60_2
        local v6_7 = v3_8 + 0.2
        return CFrame.lookAt(v2.Position + Vector3.new(math.cos(v3_8) * 32, v4_6, math.sin(v3_8) * 32), v2.Position + Vector3.new(math.cos(v6_7) * 32, v4_6, math.sin(v6_7) * 32))
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
        if v53_2 or v61_2.IsUpgrading or v61_2.IsRetrievingSkillCrate or v48_3 and v52_2 then
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
            if v53_2 or v61_2.IsRetrievingSkillCrate then
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
            if v13_8:FindFirstChild("Titans") ~= nil and v2_11:GetAttribute("Setup") ~= true then
                return
            end
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
        local SAFE_REMOTE_CATEGORIES = {
            Attacks = true, Hitboxes = true, Spears = true, Blades = true,
            Functions = true, S_Rewards = true, S_Equipment = true, Family = true,
            Skills = true, Upgrades = true, ODMG = true, Shift = true,
            Movement = true, Combat = true, Stats = true, Lobby = true,
            Mission = true, Waves = true, Cutscene = true, Dialogue = true,
            Shop = true, Customisation = true, Settings = true, Interact = true,
            Inventory = true, Profile = true, Party = true, Quest = true,
            Quests = true, Raid = true, Rewards = true, Titans = true,
            Carry = true, Emote = true, Chat = true
        }
        local SUSPICIOUS_TOKENS = {
            "anticheat", "anti_cheat", "antiexploit", "cheat", "exploit",
            "shadowban", "violation", "tamper", "speedhack", "noclip",
            "hitbox", "kicklog", "banplayer", "flagplayer", "reportexploit"
        }
        local CORE_SCRIPT_WHITELIST = {
            actor = true, animate = true, playermodule = true, controlmodule = true,
            cameramodule = true, chat = true, rbxcharactersounds = true
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
                "securitycheck", "tamper", "ac_client", "ac_check"
            })
        end
        local function isSuspiciousRemoteCall(remote, arg1, arg2)
            if typeof(remote) ~= "Instance" then
                return false
            end
            local rName = remote.Name
            if remote == v68_2 or remote == v69_2 or rName == "POST" or rName == "GET" then
                if type(arg1) == "string" then
                    if SAFE_REMOTE_CATEGORIES[arg1] then
                        return false
                    end
                    local combined = arg1 .. " " .. (type(arg2) == "string" and arg2 or "")
                    if containsToken(combined, SUSPICIOUS_TOKENS) or string.find(string.lower(combined), "flag", 1, true) then
                        return true
                    end
                end
                return false
            end
            if containsToken(rName, SUSPICIOUS_TOKENS) then
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
                    if method == "Kick" and self == v7_13 then
                        v150_10.BlockedKicks = v150_10.BlockedKicks + 1
                        return nil
                    end
                    if method == "FireServer" or method == "InvokeServer" then
                        local arg1, arg2 = ...
                        if isSuspiciousRemoteCall(self, arg1, arg2) then
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
                    elseif key == "CanCollide" and v19_3 then
                        local char = v7_13 and v7_13.Character
                        if char and typeof(self) == "Instance" and self:IsDescendantOf(char) then
                            return true
                        end
                    end
                    return origIndex(self, key)
                end))
            end)
            if ok then
                v150_10.HooksInstalled = true
            end
            return ok
        end

        function v150_10.IsolateLocalAntiCheat()
            local isolated = 0
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
                    end
                    if hrp then
                        table.insert(signals, hrp:GetPropertyChangedSignal("CFrame"))
                        table.insert(signals, hrp:GetPropertyChangedSignal("Size"))
                    end
                    for _, sig in ipairs(signals) do
                        for _, conn in ipairs(getconnections(sig)) do
                            if conn.Function and type(getfenv) == "function" then
                                local okEnv, env = pcall(getfenv, conn.Function)
                                local src = okEnv and type(env) == "table" and rawget(env, "script")
                                if typeof(src) == "Instance" and isAntiCheatName(src.Name) then
                                    pcall(function() conn:Disable() end)
                                    isolated = isolated + 1
                                end
                            end
                        end
                    end
                end
            end)
            if isolated > 0 then
                v150_10.IsolatedScripts = v150_10.IsolatedScripts + isolated
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
            local v8_9 = v7_12 and (v7_12:FindFirstChild("2") and v7_12["2"]:FindFirstChild("Gold") or v7_12:FindFirstChild("Gold", true))
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
        local v7_4 = v6_5 and v6_5:FindFirstChild("Main") and v6_5.Main:FindFirstChild("Upgrades") and v6_5.Main.Upgrades:FindFirstChild("Max") and v6_5.Main.Upgrades.Max:FindFirstChild("Max_Use")
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
        local v7_4 = v6_5 and v6_5:FindFirstChild("Main") and v6_5.Main:FindFirstChild("Upgrades") and v6_5.Main.Upgrades:FindFirstChild("Regen") and v6_5.Main.Upgrades.Regen:FindFirstChild("Regen_Use")
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
        local v7_4 = v6_5 and v6_5:FindFirstChild("Main") and v6_5.Main:FindFirstChild("Upgrades") and v6_5.Main.Upgrades:FindFirstChild("Refills") and v6_5.Main.Upgrades.Refills:FindFirstChild("Refills_Use")
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
    local function v135_3()
        local v1_2 = v71_3()
        local v2 = v1_2 and v1_2:FindFirstChild("Actor") or v66 and v66()[1]
        if v2 and v67_2 then
            pcall(function()
                v67_2(v2, "                local foundData = nil\n                for _, v in ipairs(getgc(true)) do\n                    if type(v) == \"table\" and rawget(v, \"Currency\") and rawget(v, \"Progression\") and rawget(v, \"Upgrades\") then\n                        if type(v.Currency) == \"table\" and type(v.Currency.Gold) == \"number\" and v.Currency.Gold > 0 then\n                            foundData = v\n                            break\n                        end\n                    end\n                end\n                local minLvl = 999\n                if foundData and foundData.Upgrades then\n                    local w = foundData.Weapon or \"Blades\"\n                    local upgs = foundData.Upgrades[w]\n                    if type(upgs) == \"table\" then\n                        for _, lvl in pairs(upgs) do\n                            if type(lvl) == \"number\" and lvl < minLvl then\n                                minLvl = lvl\n                            end\n                        end\n                    end\n                end\n                local lp = game:GetService(\"Players\").LocalPlayer\n                local chars = workspace:FindFirstChild(\"Characters\")\n                local c = (chars and chars:FindFirstChild(lp.Name)) or lp.Character\n                local myAct = c and c:FindFirstChild(\"Actor\")\n                if myAct then\n                    myAct:SetAttribute(\"WeaponMinLevel\", minLvl < 999 and minLvl or 0)\n                end\n            ")
                return
            end)
            local v3_7 = v2:GetAttribute("WeaponMinLevel")
            if type(v3_7) == "number" and 0 <= v3_7 and 15 >= v3_7 then
                v61_2.CachedWeaponMinLevel = v3_7
                return v3_7
            end
        end
        return v61_2.CachedWeaponMinLevel
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
        local v4_4 = v3_4 and v3_4:FindFirstChild("Stat") and v3_4.Stat:FindFirstChild("Cost") and v3_4.Stat.Cost:FindFirstChild("Title")
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
        local v3_4 = v2_4 and v2_4:FindFirstChild("Stat") and v2_4.Stat:FindFirstChild("Cost") and v2_4.Stat.Cost:FindFirstChild("Title")
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
        local v9_3 = v8_3 and (v8_3:FindFirstChild("Bottom") or v8_3.PrimaryPart or v8_3:FindFirstChildWhichIsA("BasePart"))
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
            local v13_11 = v4_6:FindFirstChild("Hitbox") or v4_6:FindFirstChild("Box") or v4_6.PrimaryPart or v4_6:FindFirstChildWhichIsA("BasePart")
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
                                        if not v9:GetAttribute("Broken") and v9.Transparency < 0.9 then
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
                        if not v20_2 or not v91_2(v20_2) then
                            v20_2 = v73_2() and v122_3() or v121_4()
                        end
                        if v59_2 then
                            local v2_31 = v88_2()
                            local v3_22 = {}
                            local v4_11 = nil
                            local v5_5 = v20_2 and v20_2.PrimaryPart and v20_2.PrimaryPart.Position
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
                                            v10_5 = v12_10 and v12_10:FindFirstChild("Spears") ~= nil or v13_14 and v13_14:FindFirstChild("Spears") ~= nil or false
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
                                                                if not v9:GetAttribute("Broken") and v9.Transparency < 0.9 then
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
                                                                if not v9:GetAttribute("Broken") and v9.Transparency < 0.9 then
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
                                            local v15_23 = v14_31.titan
                                            if v15_23 then
                                                local v16_15 = v14_31.titan
                                                if not v16_15 or not v16_15.Parent then
                                                    v15_23 = false
                                                else
                                                    local v17_14 = v13_8:FindFirstChild("Titans")
                                                    if not v17_14 then
                                                        v15_23 = false
                                                    elseif v16_15.Parent ~= v17_14 then
                                                        v15_23 = false
                                                    else
                                                        v15_23 = not v90_2(v16_15)
                                                    end
                                                end
                                            end
                                            if v15_23 then
                                                v15_23 = v14_31.nape
                                            end
                                            if v15_23 then
                                                v15_23 = v14_31.nape.Parent
                                            end
                                            if v15_23 then
                                                table.insert(v10_19, v14_31.titan)
                                            end
                                        end
                                        if #v10_19 ~= 0 then
                                            v127_2(v20_2)
                                            local v12_32 = v72_2()
                                            local v11_38
                                            if not v12_32 then
                                                v11_38 = false
                                            else
                                                local v13_30 = v12_32:FindFirstChild("LeftLowerArm")
                                                local v14_35 = v12_32:FindFirstChild("RightLowerArm")
                                                v11_38 = v13_30 and v13_30:FindFirstChild("Spears") ~= nil or v14_35 and v14_35:FindFirstChild("Spears") ~= nil or false
                                            end
                                            if v11_38 then
                                                if v93_2(v10_19) then
                                                    task.wait(v57_3 and #v6_10 >= v7_18 + 8 and math.max(v58_2, 0.35) or 0.35)
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
                            if not v18_4 then
                                break
                            elseif v73_2() then
                                local v2_41 = v122_3(v20_2) or v20_2
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
                                        local v7_31
                                        if not v2_41 or not v2_41.Parent then
                                            v7_31 = false
                                        else
                                            local v8_24 = v13_8:FindFirstChild("Titans")
                                            if not v8_24 then
                                                v7_31 = false
                                            elseif v2_41.Parent ~= v8_24 then
                                                v7_31 = false
                                            else
                                                v7_31 = not v90_2(v2_41)
                                            end
                                        end
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
                                    local v7_36
                                    if not v2_41 or not v2_41.Parent then
                                        v7_36 = false
                                    else
                                        local v8_29 = v13_8:FindFirstChild("Titans")
                                        if not v8_29 then
                                            v7_36 = false
                                        elseif v2_41.Parent ~= v8_29 then
                                            v7_36 = false
                                        else
                                            v7_36 = not v90_2(v2_41)
                                        end
                                    end
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
                                local v2_43 = v121_4(v20_2) or v20_2
                                while true do
                                    if v18_4 and not v59_2 then
                                        task.wait(0.06)
                                        if not v18_4 then
                                            break
                                        else
                                            local v3_40 = v25_2 and not v26_2
                                            if v3_40 then
                                                if v73_2() then
                                                    v3_40 = false
                                                else
                                                    local v4_29 = v72_2()
                                                    if not v4_29 then
                                                        v3_40 = false
                                                    else
                                                        local _brk2 = false
                                                        for v8_17, v9_7 in ipairs(v4_29:GetDescendants()) do
                                                            if v9_7:IsA("MeshPart") and v9_7.Name:sub(1, 5) == "Blade" then
                                                                v3_40 = true
                                                                _brk2 = true
                                                                break
                                                            end
                                                        end
                                                        if not _brk2 then
                                                            v3_40 = false
                                                        end
                                                    end
                                                end
                                            end
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
                                                            if not v9:GetAttribute("Broken") and v9.Transparency < 0.9 then
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
                                                local v4_45
                                                if not v5_27 or not v5_27.Parent then
                                                    v4_45 = false
                                                else
                                                    local v6_37 = v13_8:FindFirstChild("Titans")
                                                    if not v6_37 then
                                                        v4_45 = false
                                                    elseif v5_27.Parent ~= v6_37 then
                                                        v4_45 = false
                                                    else
                                                        v4_45 = not v90_2(v5_27)
                                                    end
                                                end
                                                if not v4_45 then
                                                    v20_2 = v121_4(v20_2)
                                                    if not v20_2 then
                                                        break
                                                    end
                                                end
                                                local v3_51 = not v2_43
                                                if not v3_51 then
                                                    local v5_30 = v2_43
                                                    local v4_50
                                                    if not v5_30 or not v5_30.Parent then
                                                        v4_50 = false
                                                    else
                                                        local v6_41 = v13_8:FindFirstChild("Titans")
                                                        if not v6_41 then
                                                            v4_50 = false
                                                        elseif v5_30.Parent ~= v6_41 then
                                                            v4_50 = false
                                                        else
                                                            v4_50 = not v90_2(v5_30)
                                                        end
                                                    end
                                                    v3_51 = not v4_50
                                                end
                                                if v3_51 then
                                                    if v57_3 and not v1_2 then
                                                        task.wait(v58_2)
                                                    end
                                                    v1_2 = false
                                                    v2_43 = v121_4(v20_2) or v20_2
                                                elseif v2_43 == v20_2 then
                                                    local v3_54 = v121_4(v20_2)
                                                    if v3_54 then
                                                        v2_43 = v3_54
                                                    end
                                                end
                                                local v3_59 = not v2_43
                                                if not v3_59 then
                                                    local v5_31 = v2_43
                                                    local v4_55
                                                    if not v5_31 or not v5_31.Parent then
                                                        v4_55 = false
                                                    else
                                                        local v6_49 = v13_8:FindFirstChild("Titans")
                                                        if not v6_49 then
                                                            v4_55 = false
                                                        elseif v5_31.Parent ~= v6_49 then
                                                            v4_55 = false
                                                        else
                                                            v4_55 = not v90_2(v5_31)
                                                        end
                                                    end
                                                    v3_59 = not v4_55
                                                end
                                                if v3_59 then
                                                    break
                                                else
                                                    local v5_33 = v2_43:FindFirstChild("Hitboxes")
                                                    local v3_60
                                                    if not v5_33 then
                                                        v3_60 = nil
                                                    else
                                                        local v6_47 = v5_33:FindFirstChild("Hit")
                                                        if not v6_47 then
                                                            v3_60 = nil
                                                        else
                                                            v3_60 = v6_47:FindFirstChild("Nape")
                                                        end
                                                    end
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
                                                                local v6_54
                                                                if not v7_75 or not v7_75.Parent then
                                                                    v6_54 = false
                                                                else
                                                                    local v8_45 = v13_8:FindFirstChild("Titans")
                                                                    if not v8_45 then
                                                                        v6_54 = false
                                                                    elseif v7_75.Parent ~= v8_45 then
                                                                        v6_54 = false
                                                                    else
                                                                        v6_54 = not v90_2(v7_75)
                                                                    end
                                                                end
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

    function v150_9.wrapTab(rayfieldTab)
        local wrapped = {}

        function wrapped:AddLabel(text)
            return rayfieldTab:CreateSection(tostring(text or ""))
        end

        function wrapped:AddParagraph(title, content)
            local titleStr = tostring(title or "")
            local paragraph = rayfieldTab:CreateParagraph({
                Title = titleStr,
                Content = tostring(content or "")
            })
            return {
                Set = function(_, newContent)
                    paragraph:Set({
                        Title = titleStr,
                        Content = tostring(newContent or "")
                    })
                end
            }
        end

        function wrapped:AddButton(name, callback)
            return rayfieldTab:CreateButton({
                Name = tostring(name or ""),
                Callback = function()
                    if callback then
                        callback()
                    end
                end
            })
        end

        function wrapped:AddToggle(name, callback)
            local suppressing = false
            local toggle = rayfieldTab:CreateToggle({
                Name = tostring(name or ""),
                CurrentValue = false,
                Callback = function(value)
                    if suppressing then
                        return
                    end
                    if callback then
                        callback(value)
                    end
                end
            })
            function toggle:SetState(state)
                local nextState = state == true
                if self.CurrentValue == nextState then
                    return
                end
                suppressing = true
                local ok, err = pcall(function()
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
            local suppressing = false
            local initialVal = clampNum(defaultVal, minVal, maxVal)
            local slider = rayfieldTab:CreateSlider({
                Name = tostring(name or ""),
                Range = { minVal, maxVal },
                Increment = increment or 1,
                CurrentValue = initialVal,
                Callback = function(value)
                    if suppressing then
                        return
                    end
                    if callback then
                        callback(value)
                    end
                end
            })
            function slider:SetValue(val)
                local clamped = clampNum(val, minVal, maxVal)
                if self.CurrentValue == clamped then
                    return
                end
                suppressing = true
                local ok, err = pcall(function()
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
            local suppressing = false
            local dropdown = rayfieldTab:CreateDropdown({
                Name = tostring(name or ""),
                Options = options or {},
                CurrentOption = {},
                MultipleOptions = true,
                Callback = function(selectedList)
                    if suppressing then
                        return
                    end
                    if callback then
                        callback(toOptionSet(selectedList))
                    end
                end
            })
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

        return wrapped
    end

    v150_9.toOptionSet = toOptionSet
end
local v150_8 = v12_4:CreateWindow({
    Name = "Symbiote",
    LoadingTitle = "Đang tải...",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = false
    }
})
local v151_6 = v150_9.wrapTab(v150_8:CreateTab("Player"))
local v152_7 = v150_9.wrapTab(v150_8:CreateTab("Auto Farm"))
local v153_9 = v150_9.wrapTab(v150_8:CreateTab("Various"))
local v154_8 = v150_9.wrapTab(v150_8:CreateTab("Stats"))
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
local v156_4 = {
    Player = {
        Prestige = tonumber(v157_2.Player and v157_2.Player.Prestige) or 0,
        Level = tonumber(v157_2.Player and v157_2.Player.Level) or 1,
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
        DivineFragments = tonumber(v157_2.LastRound and (v157_2.LastRound.DivineFragments or v157_2.LastRound["Divine Fragments"])) or 0,
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
        DivineFragments = tonumber(v157_2.Session and (v157_2.Session.DivineFragments or v157_2.Session["Divine Fragments"])) or 0,
        BP_XP = tonumber(v157_2.Session and (v157_2.Session.BP_XP or v157_2.Session["BP XP"])) or 0,
        XP = tonumber(v157_2.Session and v157_2.Session.XP) or 0,
        Items = v157_2.Session and type(v157_2.Session.Items) == "table" and v157_2.Session.Items or {},
        RarityCounts = v157_2.Session and type(v157_2.Session.RarityCounts) == "table" and v157_2.Session.RarityCounts or {
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
        return v154_8:AddParagraph(title, "Đang tải...")
    end
    v173_2.Player = v176_4("PLAYER STATS:")
    v173_2.LiveMission = v176_4("MISSION STATS (LIVE):")
    v173_2.LastRound = v176_4("LAST ROUND STATS:")
    v173_2.Session = v176_4("TOTAL SESSION STATS:")
end
local function v174_5()
    local v6 = v156_4
    local v7 = v6
    local v8 = v7
    local v9_2 = v8
    v173_2.Player:Set(string.format("Prestige: %s\nLevel: %s\nGems: %s\nGold: %s\nPumpkins: %s", v165_3(v6.Player.Prestige), v165_3(v7.Player.Level), v165_3(v8.Player.Gems), v165_3(v9_2.Player.Gold), v165_3(v9_2.Player.Pumpkins or 0)))
    v173_2.LiveMission:Set(string.format("Status: %s\nTime: %s\nDifficulty: %s", v158_4.Status, v166_2(v158_4.Seconds), v158_4.Difficulty))
    local v1_3 = v156_4.LastRound
    local v2_3 = v1_3.Items and #v1_3.Items or 0
    local v4_4 = {}
    local v5_8 = "Time Taken: " .. tostring(v1_3.TimeTaken)
    local v6_11 = "Difficulty: " .. tostring(v1_3.Difficulty)
    local v7_9 = "Titans Killed: " .. v165_3(v1_3.TitansKilled or 0)
    local v8_10 = "Damage Dealt: " .. v165_3(v1_3.DamageDealt or 0)
    local v9_8 = "Gold: " .. v165_3(v1_3.Gold)
    local v10_6 = "Gems: " .. v165_3(v1_3.Gems)
    local v11_5 = "Pumpkins: " .. v165_3(v1_3.Pumpkins or 0)
    local v12_5 = "Divine Fragments: " .. v165_3(v1_3.DivineFragments or 0)
    local v14_4 = "BP XP: "
    local v15_3 = v165_3(v1_3.BP_XP or 0)
    local v16_3 = v165_3(v1_3.XP)
    local v18_2 = tostring(v2_3)
    v4_4[1] = v5_8
    v4_4[2] = v6_11
    v4_4[3] = v7_9
    v4_4[4] = v8_10
    v4_4[5] = v9_8
    v4_4[6] = v10_6
    v4_4[7] = v11_5
    v4_4[8] = v12_5
    v4_4[9] = v14_4 .. v15_3
    v4_4[10] = "XP: " .. v16_3
    v4_4[11] = "Drops (" .. v18_2 .. "):"
    local v3_6 = v4_4
    if 0 < v2_3 then
        for v7_10, v8_11 in ipairs(v1_3.Items) do
            table.insert(v3_6, "  " .. v8_11)
        end
    else
        table.insert(v3_6, "  None")
    end
    v173_2.LastRound:Set(table.concat(v3_6, "\n"))
    local v4_10 = v156_4.Session
    local v5_13 = v4_10.MissionsCompleted or 0
    local v6_17 = v4_10.FastestSeconds and 0 < v4_10.FastestSeconds and v166_2(v4_10.FastestSeconds) or "00:00"
    local v7_16 = v167_2(v4_10.TotalSeconds or 0, v5_13)
    local v8_14 = v4_10.RarityCounts or {}
    local v10_9 = {}
    local v11_9 = string.format("Common: %s | Uncommon: %s | Rare: %s", v165_3(v8_14.Common or 0), v165_3(v8_14.Uncommon or 0), v165_3(v8_14.Rare or 0))
    local v12_8 = string.format
    local v14_10 = v165_3(v8_14.Epic or 0)
    local v15_11 = v165_3(v8_14.Legendary or 0)
    local v16_8 = v165_3(v8_14.Mythic or 0)
    v10_9[1] = v11_9
    v10_9[2] = v12_8("Epic: %s | Legendary: %s | Mythic: %s", v14_10, v15_11, v16_8)
    local v9_12 = v10_9
    if 0 < (v8_14.Secret or 0) then
        table.insert(v9_12, string.format("Secret: %s", v165_3(v8_14.Secret)))
    end
    local v11_13 = {}
    local v12_12 = "Missions Completed: " .. v165_3(v5_13)
    local v13_15 = "Fastest Time: " .. v6_17
    local v14_18 = "Average Time: " .. v7_16
    local v15_17 = "Titans Killed: " .. v165_3(v4_10.TitansKilled or 0)
    local v16_12 = "Damage Dealt: " .. v165_3(v4_10.DamageDealt or 0)
    local v17_9 = "Gold: " .. v165_3(v4_10.Gold or 0)
    local v18_9 = "Gems: " .. v165_3(v4_10.Gems or 0)
    local v19_9 = "Pumpkins: " .. v165_3(v4_10.Pumpkins or 0)
    local v20_7 = "Divine Fragments: " .. v165_3(v4_10.DivineFragments or 0)
    local v21_7 = "BP XP: " .. v165_3(v4_10.BP_XP or 0)
    local v22_7 = "XP: " .. v165_3(v4_10.XP or 0)
    local v24_6 = "Total Drops: "
    local v25_5 = tostring(#(v4_10.Items or {}))
    local v26_6 = table.concat(v9_12, "\n  ")
    v11_13[1] = v12_12
    v11_13[2] = v13_15
    v11_13[3] = v14_18
    v11_13[4] = v15_17
    v11_13[5] = v16_12
    v11_13[6] = v17_9
    v11_13[7] = v18_9
    v11_13[8] = v19_9
    v11_13[9] = v20_7
    v11_13[10] = v21_7
    v11_13[11] = v22_7
    v11_13[12] = v24_6 .. v25_5
    v11_13[13] = "Rarity Breakdown:\n  " .. v26_6
    v173_2.Session:Set(table.concat(v11_13, "\n"))
    return
end
local function v175_4(p1)
    if type(p1) ~= "table" then
        return false
    end
    local v2_4 = false
    if type(p1.Progression) == "table" then
        if p1.Progression.Prestige ~= nil then
            v156_4.Player.Prestige = tonumber(p1.Progression.Prestige) or v156_4.Player.Prestige
            v2_4 = true
        end
        if p1.Progression.Level ~= nil then
            v156_4.Player.Level = tonumber(p1.Progression.Level) or v156_4.Player.Level
            v2_4 = true
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
        v156_4.Player.Prestige = tonumber(v3_2) or v156_4.Player.Prestige
        v1 = true
    end
    local v4_8 = v7_13:GetAttribute("Level")
    if v4_8 ~= nil then
        v156_4.Player.Level = tonumber(v4_8) or v156_4.Player.Level
        v1 = true
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
    local v1_7 = tonumber(v13_8:GetAttribute("Seconds"))
    if not v1_7 or v1_7 <= 0 then
        v1_7 = math.max(1, v158_4.Seconds)
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
            local v25_8 = tonumber(v21_19.Divine_Fragment or v21_19["Divine Fragment"] or v21_19.DivineFragments or v21_19["Divine Fragments"]) or 0
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
                        table.insert(v15_3, string.gsub(v33_5, "_", " ") .. (1 < v34_14 and " x" .. tostring(v34_14) or "") .. " (" .. v35_34 .. ")")
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
                        table.insert(v15_3, string.gsub(v33_6, "_", " ") .. (v34_20 > 1 and " x" .. tostring(v34_20) or "") .. " (" .. v35_44 .. ")")
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
                        table.insert(v15_3, string.gsub(v33_7, "_", " ") .. (v34_24 > 1 and " x" .. tostring(v34_24) or "") .. " (" .. v35_38 .. ")")
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
                        table.insert(v15_3, string.gsub(v33_9, "_", " ") .. (1 < v34_26 and " x" .. tostring(v34_26) or "") .. " (" .. v35_42 .. ")")
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
                        local v2_2 = tonumber(tostring(p7 or ""):gsub(",", ""):gsub("%+", ""):gsub("x", ""):gsub("%s", "")) or 1
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
                            table.insert(v159_6.Items, string.gsub(v3_7, "_", " ") .. (v2_2 > 1 and " x" .. tostring(v2_2) or "") .. " (" .. v4_21 .. ")")
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
v56_2.HitAll = v152_7:AddToggle("Hit All", function(p1)
    v59_2 = p1
    v9_4("HitAll", p1)
    return
end)
v56_2.DistanceToTitanSlider = v152_7:AddSlider("Distance to Titan", 0, 100, v8_6("DistanceToTitan"), function(p1)
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
pcall(function()
    for v5, v6 in pairs(require(v16_15.Modules.Storage.Families)) do
        if type(v6) == "table" then
            for v10, v11 in pairs(v6) do
                table.insert(v180_68.AllFamilies, v10)
                v180_68.TierMap[v10] = v5
            end
        end
    end
    table.sort(v180_68.AllFamilies)
    return
end)
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
    end
end
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
                                v67_2(v2_2, "                                pcall(function()\n                                    local p = game:GetService(\"Players\")\n                                    local lp = p.LocalPlayer\n                                    local chars = workspace:FindFirstChild(\"Characters\")\n                                    local c = (chars and chars:FindFirstChild(lp.Name)) or lp.Character\n                                    local act = c and c:FindFirstChild(\"Actor\")\n                                    local raw = act and act:GetAttribute(\"Symbiote_RollSync\")\n                                    if not raw then return end\n                                    local http = game:GetService(\"HttpService\")\n                                    local sync = http:JSONDecode(raw)\n                                    local host = _G.__CachedCustHost\n                                    if type(host) ~= \"table\"\n                                        or type(rawget(host, \"Modules\")) ~= \"table\"\n                                        or not host.Modules.Customisation\n                                    then\n                                        host = nil\n                                        _G.__CachedCustHost = nil\n                                        for _, v in ipairs(getgc(true)) do\n                                            if type(v) == \"table\"\n                                                and type(rawget(v, \"Cache\")) == \"table\"\n                                                and type(rawget(v, \"Modules\")) == \"table\"\n                                                and v.Modules.Customisation\n                                            then\n                                                host = v\n                                                _G.__CachedCustHost = v\n                                                break\n                                            end\n                                        end\n                                    end\n                                    if host then\n                                        local custMod = host.Modules.Customisation\n                                        local updMod = host.Modules.Update\n                                        local data, slot = nil, nil\n                                        if updMod and type(updMod.Get_Data) == \"function\" then\n                                            data, slot = updMod.Get_Data(host, true)\n                                        elseif type(host.Cache) == \"table\" and type(host.Cache.Data) == \"table\" then\n                                            data = host.Cache.Data\n                                            slot = data.Slots and data.Current_Slot and data.Slots[data.Current_Slot]\n                                        end\n                                        if type(data) == \"table\" then\n                                            if type(sync.Spins) == \"table\" then\n                                                data.Spins = sync.Spins\n                                            end\n                                            if sync.SpinLuck ~= nil then\n                                                data.Spin_Luck = sync.SpinLuck\n                                            end\n                                        end\n                                        if type(slot) == \"table\" and type(slot.Avatar) == \"table\" then\n                                            slot.Avatar.Family = sync.Family\n                                            if type(sync.Pity) == \"table\" then\n                                                slot.Avatar.Pity = sync.Pity\n                                            end\n                                        end\n                                        local pgui = game:GetService(\"Players\").LocalPlayer:FindFirstChild(\"PlayerGui\")\n                                        local cust = pgui and pgui:FindFirstChild(\"Interface\") and pgui.Interface:FindFirstChild(\"Customisation\")\n                                        local fUI = cust and cust:FindFirstChild(\"Family\")\n                                        if custMod then\n                                            custMod.Spinning = false\n                                            if fUI then\n                                                if custMod.Rates and host.Services and host.Services.W and data then\n                                                    pcall(function()\n                                                        custMod.Rates(host, fUI, host.Services.W, data)\n                                                    end)\n                                                end\n                                                if custMod.Family_Details then\n                                                    pcall(function()\n                                                        custMod.Family_Details(host, fUI, true, false)\n                                                    end)\n                                                end\n                                            end\n                                        end\n                                    end\n                                end)\n                            ")
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
pcall(function()
    for v5, v6 in pairs(require(v16_15.Modules.Storage.Perks)) do
        if type(v6) == "table" then
            for v10, v11 in pairs(v6) do
                table.insert(v186_32.AllPerks, v10)
                v186_32.RarityMap[v10] = v5
            end
        end
    end
    table.sort(v186_32.AllPerks)
    return
end)
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
    end
end
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
                v67_2(v2, "                    local p = game:GetService(\"Players\")\n                    local lp = p.LocalPlayer\n                    local chars = workspace:FindFirstChild(\"Characters\")\n                    local c = (chars and chars:FindFirstChild(lp.Name)) or lp.Character\n                    local act = c and c:FindFirstChild(\"Actor\")\n                    local rs = game:GetService(\"ReplicatedStorage\")\n                    local remoteGET = rs:WaitForChild(\"Assets\"):WaitForChild(\"Remotes\"):WaitForChild(\"GET\")\n                    local perksMod = require(rs.Modules.Storage.Perks)\n                    local rarityMap = {}\n                    for r, list in pairs(perksMod) do\n                        if type(list) == \"table\" then\n                            for name in pairs(list) do\n                                rarityMap[name] = r\n                            end\n                        end\n                    end\n\n                    local hostObj = _G.__CachedDataHost\n                    if not hostObj or type(hostObj) ~= \"table\" or type(rawget(hostObj, \"Cache\")) ~= \"table\" or type(rawget(hostObj.Cache, \"Data\")) ~= \"table\" then\n                        hostObj = nil\n                        for _, v in ipairs(getgc(true)) do\n                            if type(v) == \"table\" and type(rawget(v, \"Cache\")) == \"table\" then\n                                local cache = rawget(v, \"Cache\")\n                                if type(rawget(cache, \"Data\")) == \"table\" then\n                                    hostObj = v\n                                    _G.__CachedDataHost = v\n                                    break\n                                end\n                            end\n                        end\n                    end\n\n                    if hostObj and type(hostObj.Cache) == \"table\" and type(hostObj.Cache.Data) == \"table\" then\n                        local data = hostObj.Cache.Data\n                        local currentSlot = data.Current_Slot or 1\n                        local slotData = data.Slots and data.Slots[currentSlot]\n                        if slotData and slotData.Perks and slotData.Perks.Storage then\n                            local equippedIds = {}\n                            for _, eqId in pairs(slotData.Perks.Equipped or {}) do\n                                if eqId and eqId ~= \"\" then\n                                    equippedIds[eqId] = true\n                                end\n                            end\n\n                            local rawFilter = act and act:GetAttribute(\"Symbiote_PerkFilter\")\n                            local http = game:GetService(\"HttpService\")\n                            local filter = rawFilter and http:JSONDecode(rawFilter) or { Tiers = {}, Specific = {} }\n\n                            local batch = {}\n                            local deletedList = {}\n                            for id, info in pairs(slotData.Perks.Storage) do\n                                local name = info.Name\n                                local rarity = rarityMap[name] or \"Common\"\n                                local match = (filter.Tiers[rarity] == true) or (filter.Specific[name] == true)\n                                if match and not equippedIds[id] then\n                                    table.insert(batch, tostring(id))\n                                    table.insert(deletedList, tostring(id))\n                                    if #batch >= 25 then\n                                        local res = remoteGET:InvokeServer(\"S_Equipment\", \"Delete\", \"Perk\", batch)\n                                        if type(res) == \"table\" then\n                                            hostObj.Cache.Data = res\n                                            data = res\n                                            slotData = data.Slots and data.Slots[currentSlot]\n                                        end\n                                        batch = {}\n                                    end\n                                end\n                            end\n                            if #batch > 0 then\n                                local res = remoteGET:InvokeServer(\"S_Equipment\", \"Delete\", \"Perk\", batch)\n                                if type(res) == \"table\" then\n                                    hostObj.Cache.Data = res\n                                end\n                            end\n                            if act then\n                                act:SetAttribute(\"Symbiote_PerkDeleted\", http:JSONEncode(deletedList))\n                            end\n                        end\n                    end\n                ")
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
    task.spawn(function()
        v28_2 = v8_6("WalkSpeedAmount")
        v30_2 = v8_6("LaggyRunDistance")
        v31_2 = v8_6("LaggyRunDelay")
        v23_2 = v8_6("HitboxSize")
        v58_2 = v8_6("DelayToKillAmount")
        v60_2 = v8_6("DistanceToTitan")
        v61_2.UpgradeDelay = v8_6("UpgradeDelay") or 0
        if v56_2.WalkSpeedSlider then
            v56_2.WalkSpeedSlider:SetValue(v8_6("WalkSpeedAmount"))
        end
        if v56_2.LaggyRunDistSlider then
            v56_2.LaggyRunDistSlider:SetValue(v8_6("LaggyRunDistance"))
        end
        if v56_2.LaggyRunDelaySlider then
            v56_2.LaggyRunDelaySlider:SetValue(v8_6("LaggyRunDelay"))
        end
        if v56_2.DelayToKillSlider then
            v56_2.DelayToKillSlider:SetValue(v8_6("DelayToKillAmount"))
        end
        if v56_2.DistanceToTitanSlider then
            v56_2.DistanceToTitanSlider:SetValue(v8_6("DistanceToTitan"))
        end
        if v56_2.HitboxSizeSlider then
            v56_2.HitboxSizeSlider:SetValue(v8_6("HitboxSize"))
        end
        if v56_2.UpgradeDelaySlider then
            v56_2.UpgradeDelaySlider:SetValue(v8_6("UpgradeDelay") or 0)
        end
        local v1_35 = v8_6("FamiliesToStop")
        if type(v1_35) == "table" and v56_2.FamiliesDropdown then
            v43_2 = v150_9.toOptionSet(v1_35)
            v56_2.FamiliesDropdown:SetSelected(v1_35)
        end
        local v2_35 = v8_6("FamilyTiersToStop")
        if type(v2_35) == "table" and v56_2.FamilyTiersDropdown then
            v44_3 = v150_9.toOptionSet(v2_35)
            v56_2.FamilyTiersDropdown:SetSelected(v2_35)
        end
        local v3_26 = v8_6("PerkTiersToSell")
        if type(v3_26) == "table" and v56_2.PerkTiersDropdown then
            v46_2 = v150_9.toOptionSet(v3_26)
            v56_2.PerkTiersDropdown:SetSelected(v3_26)
        end
        local v4_27 = v8_6("SpecificPerksToSell")
        if type(v4_27) == "table" and v56_2.SpecificPerksDropdown then
            v47_3 = v150_9.toOptionSet(v4_27)
            v56_2.SpecificPerksDropdown:SetSelected(v4_27)
        end
        if v8_6("ChangeCursor") then
            v37_2 = true
            v108_3()
            if v56_2.ChangeCursor then
                v56_2.ChangeCursor:SetState(true)
            end
        end
        if v8_6("AutoRetry") then
            v38_2 = true
            v110_3()
            if v56_2.AutoRetry then
                v56_2.AutoRetry:SetState(true)
            end
        end
        if v8_6("AutoSkipCutscenes") then
            v39_2 = true
            v112_3()
            if v56_2.AutoSkipCutscenes then
                v56_2.AutoSkipCutscenes:SetState(true)
            end
        end
        if v8_6("AutoOpenRaidChests") then
            v40_2 = true
            v114_3()
            if v56_2.AutoOpenRaidChests then
                v56_2.AutoOpenRaidChests:SetState(true)
            end
        end
        if v8_6("AutoSellPerks") then
            v45_3 = true
            if v56_2.AutoSellPerks then
                v56_2.AutoSellPerks:SetState(true)
            end
            v187_20()
            v188_24()
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
            task.wait(0.8)
            if v8_6("NoClip") then
                v19_3 = true
                v98_2()
                if v56_2.NoClip then
                    v56_2.NoClip:SetState(true)
                end
            end
            if v8_6("WalkSpeed") then
                v27_2 = true
                v100_3()
                if v56_2.WalkSpeed then
                    v56_2.WalkSpeed:SetState(true)
                end
            end
            if v8_6("LaggyRun") then
                v29_2 = true
                v102_3()
                if v56_2.LaggyRun then
                    v56_2.LaggyRun:SetState(true)
                end
            end
            if v8_6("CtrlClickTP") then
                v32_2 = true
                v104_3()
                if v56_2.CtrlClickTP then
                    v56_2.CtrlClickTP:SetState(true)
                end
            end
            if v8_6("InfiniteJump") then
                v33_2 = true
                v106_3()
                if v56_2.InfiniteJump then
                    v56_2.InfiniteJump:SetState(true)
                end
            end
            if v8_6("AutoReload") then
                v25_2 = true
                if v56_2.AutoReload then
                    v56_2.AutoReload:SetState(true)
                end
            end
            if v8_6("DelayToKill") then
                v57_3 = true
                if v56_2.DelayToKill then
                    v56_2.DelayToKill:SetState(true)
                end
            end
            if v8_6("HitAll") then
                v59_2 = true
                if v56_2.HitAll then
                    v56_2.HitAll:SetState(true)
                end
            end
            if v8_6("ExpandNapeHitbox") then
                v22_2 = true
                v116_4()
                if v56_2.ExpandNapeHitbox then
                    v56_2.ExpandNapeHitbox:SetState(true)
                end
            end
            if v56_2.HitboxSizeSlider then
                v56_2.HitboxSizeSlider:SetValue(v8_6("HitboxSize"))
            end
            if v8_6("VisualizeHitbox") then
                v24_2 = true
                if v56_2.VisualizeHitbox then
                    v56_2.VisualizeHitbox:SetState(true)
                end
            end
            if v8_6("TitanESP") then
                v21_2 = true
                if v56_2.TitanESP then
                    v56_2.TitanESP:SetState(true)
                end
            end
            if v8_6("AutoRefill") then
                v34_2 = true
                if v56_2.AutoRefill then
                    v56_2.AutoRefill:SetState(true)
                end
            end
            if v8_6("AutoCreateTowers") then
                v48_3 = true
                if v56_2.AutoCreateTowers then
                    v56_2.AutoCreateTowers:SetState(true)
                end
                v123_4()
                v128_2()
            end
            if v8_6("AutoRetrieveSupplyCrates") then
                v49_2 = true
                if v56_2.AutoRetrieveSupplyCrates then
                    v56_2.AutoRetrieveSupplyCrates:SetState(true)
                end
                v51_2()
                task.spawn(v50_2)
            end
            if v8_6("AutoVoteReady") then
                v61_2.AutoVoteReady = true
                if v56_2.AutoVoteReady then
                    v56_2.AutoVoteReady:SetState(true)
                end
                task.spawn(v130_4)
                v62_3()
            end
            if v8_6("AutoUpgradeMaxHQHP") then
                v61_2.AutoUpgradeMaxHQHP = true
                if v56_2.AutoUpgradeMaxHQHP then
                    v56_2.AutoUpgradeMaxHQHP:SetState(true)
                end
                v62_3()
            end
            if v8_6("AutoUpgradeHQHealthRegen") then
                v61_2.AutoUpgradeHQHealthRegen = true
                if v56_2.AutoUpgradeHQHealthRegen then
                    v56_2.AutoUpgradeHQHealthRegen:SetState(true)
                end
                v62_3()
            end
            if v8_6("AutoUpgradeRefillLimit") then
                v61_2.AutoUpgradeRefillLimit = true
                if v56_2.AutoUpgradeRefillLimit then
                    v56_2.AutoUpgradeRefillLimit:SetState(true)
                end
                v62_3()
            end
            if v8_6("AutoUpgradeWeapon") then
                v61_2.AutoUpgradeWeapon = true
                if v56_2.AutoUpgradeWeapon then
                    v56_2.AutoUpgradeWeapon:SetState(true)
                end
                v62_3()
            end
            if v8_6("AutoGetRetrieveSkillCrate") then
                v61_2.AutoGetRetrieveSkillCrate = true
                if v56_2.AutoGetRetrieveSkillCrate then
                    v56_2.AutoGetRetrieveSkillCrate:SetState(true)
                end
                v62_3()
                task.spawn(v63_9)
            end
            if v8_6("AutoFarm") then
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
                if v56_2.AutoFarm then
                    v56_2.AutoFarm:SetState(true)
                end
                if v56_2.ExpandNapeHitbox then
                    v56_2.ExpandNapeHitbox:SetState(true)
                end
            end
            return
        end)
        return
    end)
end
return
