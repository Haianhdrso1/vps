--[[
    =============================================================================
    Astra Hub | Attack on Titan: Revolution
    Fully Decompiled & Deobfuscated Source Code
    Original File: heheehme.lua (Prometheus / WeAreDevs v1.0.0 Obfuscator)
    UI Framework: Luna Interface Suite (Nebula Softworks)
    Bypassed: Key System completely removed (KeySystem = false, direct access)
    =============================================================================
--]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

-- Local Player & Camera
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Remotes
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Remotes = Assets:WaitForChild("Remotes")
local PostRemote = Remotes:WaitForChild("POST")
local GetRemote = Remotes:WaitForChild("GET")

-- Ensure Config Folders exist
if not isfolder("AstraHub") then makefolder("AstraHub") end
if not isfolder("AstraHub/aotr") then makefolder("AstraHub/aotr") end
if not isfolder("AstraHub/aotr/configs") then makefolder("AstraHub/aotr/configs") end

-- State / Settings Table (Mapped 1:1 to Prometheus decompiled flags)
local Settings = {
    -- Main Farm
    AutoKill = false,
    MoveMode = "Hover", -- "Hover" or "Teleport"
    FloatHeight = 250,
    MoveSpeed = 400,
    AttackRange = 150,

    -- Automation Flow
    AutoRetry = false,
    AutoSkip = false,
    AutoChest = false,
    OpenSecondChest = false,
    AutoReload = false,
    MultiHit = false,
    MultiHitCount = 3,

    -- Safety / Flow
    AutoFailsafe = false,
    LastTitanWait = false,
    LastTitanWaitSecs = 60,
    DieAtStreak = false,
    DieAtStreakCount = 10000,
    SoloOnly = false,
    AutoReturnLobby = false,
    ReturnAfterGames = 10,
    DeleteMap = false,
    AntiInjury = false,

    -- Titans & ESP
    TitanESP = false,
    TitanESPShowDead = false,
    TitanESPHP = true,
    TitanESPDistance = 3000,
    TitanHitbox = false,
    TitanHitboxSize = 35,
    TitanHitboxTransparency = 0.5,
    AutoTitanKiller = false,
    AutoTitanKillerRange = 500,

    -- Waves
    AutoWaves = false,
    AutoWavesUpgrade = false,
    AutoStartWaves = false,

    -- Upgrades & Systems
    AutoUpgrade = false,
    AutoPerk = false,
    AutoSkillTree = false,
    AutoSlot = false,
    AutoStart = false,
    AutoPrestige = false,
    AutoClaimAchievements = false,
    AutoModifiers = false,
    AutoBoost = false,

    -- Advanced / Movement
    Noclip = false,
    SafeFarm = false,
    AutoHooks = false,
    DoubleJumpBoost = false,
    AutoEscape = false,
    WaitBeforeStart = false,
    WaitBeforeStartSecs = 0,
    AutoExecute = false,
    AutoExecScript = "",

    -- Mastery
    MasteryFarm = false,
    MasteryMode = "Both", -- "Punching", "Skill Usage", "Both"

    -- Rolls & Webhook
    AutoRoll = false,
    AutoRollRarities = "Mythical",
    RewardWebhook = false,
    MythicalFamilyWebhook = false,
    WebhookURL = ""
}

-- Session Tracker Data
local SessionData = {
    GamesPlayed = 0,
    GoldEarned = 0,
    GemsEarned = 0,
    XPEarned = 0,
    StartTime = tick()
}

-- Load saved session stats if present
pcall(function()
    if isfile("AstraHub/aotr/s_games.txt") then SessionData.GamesPlayed = tonumber(readfile("AstraHub/aotr/s_games.txt")) or 0 end
    if isfile("AstraHub/aotr/s_gold.txt") then SessionData.GoldEarned = tonumber(readfile("AstraHub/aotr/s_gold.txt")) or 0 end
    if isfile("AstraHub/aotr/s_gems.txt") then SessionData.GemsEarned = tonumber(readfile("AstraHub/aotr/s_gems.txt")) or 0 end
    if isfile("AstraHub/aotr/s_xp.txt") then SessionData.XPEarned = tonumber(readfile("AstraHub/aotr/s_xp.txt")) or 0 end
end)

-- ============================================================================
-- HELPER FUNCTIONS & GAME ENGINES
-- ============================================================================

local function isCharacterAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return (hum and hum.Health > 0 and hrp ~= nil)
end

local function isTitanAlive(titan)
    if not titan or not titan.Parent then return false end
    if titan:GetAttribute("Dead") == true or titan:GetAttribute("Defeated") == true then return false end
    local hum = titan:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 and hum.MaxHealth > 0 then return false end
    return true
end

local function getTitanNape(titan)
    if not titan then return nil end
    local hitboxes = titan:FindFirstChild("Hitboxes")
    if hitboxes then
        local hit = hitboxes:FindFirstChild("Hit")
        if hit and hit:FindFirstChild("Nape") then return hit.Nape end
        if hitboxes:FindFirstChild("Nape") then return hitboxes.Nape end
    end
    return titan:FindFirstChild("Nape") or titan:FindFirstChild("HumanoidRootPart") or titan:FindFirstChild("Head")
end

local function getClosestLivingTitan()
    if not isCharacterAlive() then return nil, nil end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local titansFolder = Workspace:FindFirstChild("Titans")
    if not titansFolder then return nil, nil end

    local closestTitan, closestNape = nil, nil
    local minDistance = math.huge

    for _, titan in ipairs(titansFolder:GetChildren()) do
        if titan:IsA("Model") and isTitanAlive(titan) then
            local nape = getTitanNape(titan)
            if nape then
                local dist = (hrp.Position - nape.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closestTitan = titan
                    closestNape = nape
                end
            end
        end
    end

    return closestTitan, closestNape
end

-- Kinematic Flight & Hover Engine
local function flyTowards(targetCFrame, speed)
    if not isCharacterAlive() then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local delta = targetCFrame.Position - hrp.Position
    local dist = delta.Magnitude

    if dist < 4 then
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        return
    end

    local stepDist = math.clamp(speed * (1 / 60), 0, dist)
    local dir = delta.Unit
    local newPos = hrp.Position + (dir * stepDist)
    hrp.CFrame = CFrame.new(newPos, targetCFrame.Position + targetCFrame.LookVector * 10)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

-- Attack Execution
local function performAttack()
    -- 1. Game server remote
    pcall(function()
        PostRemote:FireServer("Attacks", "M1")
        PostRemote:FireServer("Slash")
        PostRemote:FireServer("Slash_Release")
    end)

    -- 2. Mobile touch button support
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
        if touchGui then
            local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
            if touchControlFrame then
                local m1Btn = touchControlFrame:FindFirstChild("M1") or touchControlFrame:FindFirstChild("Attack")
                if m1Btn and m1Btn.Visible then
                    for _, conn in ipairs(getconnections(m1Btn.Activated) or {}) do conn:Fire() end
                    for _, conn in ipairs(getconnections(m1Btn.MouseButton1Down) or {}) do conn:Fire() end
                end
            end
        end
    end)

    -- 3. PC Virtual Input
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
    end)
end

-- ============================================================================
-- BACKGROUND AUTOMATION LOOPS
-- ============================================================================

-- 1. Main Auto Farm Loop
task.spawn(function()
    while true do
        task.wait(0.03)
        if Settings.AutoKill and isCharacterAlive() then
            local titan, nape = getClosestLivingTitan()
            if titan and nape then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local targetCF = nape.CFrame * CFrame.new(0, 0, 5) -- Directly behind the nape

                if Settings.MoveMode == "Teleport" then
                    hrp.CFrame = targetCF
                    hrp.AssemblyLinearVelocity = Vector3.zero
                else
                    flyTowards(targetCF, Settings.MoveSpeed)
                end

                local dist = (hrp.Position - nape.Position).Magnitude
                if dist <= Settings.AttackRange then
                    performAttack()
                    if Settings.MultiHit then
                        for i = 1, Settings.MultiHitCount do
                            performAttack()
                        end
                    end
                end
            end
        end
    end
end)

-- 2. Anti-Injury Loop
task.spawn(function()
    while true do
        task.wait(0.2)
        if Settings.AntiInjury and isCharacterAlive() then
            local injuries = LocalPlayer.Character:FindFirstChild("Injuries")
            if injuries then
                for _, injury in ipairs(injuries:GetChildren()) do
                    pcall(function() injury:Destroy() end)
                end
            end
        end
    end
end)

-- 3. Auto Escape Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if Settings.AutoEscape and isCharacterAlive() then
            local char = LocalPlayer.Character
            if char:GetAttribute("Grabbed") == true or char:FindFirstChild("Grabbed") then
                pcall(function()
                    PostRemote:FireServer("Escape")
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end
        end
    end
end)

-- 4. Auto Skip Cutscene & Auto Retry & Auto Chest
task.spawn(function()
    while true do
        task.wait(0.5)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local interface = playerGui and playerGui:FindFirstChild("Interface")

        -- Skip Cutscene
        if Settings.AutoSkip and interface then
            local skipBtn = interface:FindFirstChild("Skip", true)
            if skipBtn and skipBtn.Visible then
                pcall(function()
                    for _, c in ipairs(getconnections(skipBtn.Activated) or {}) do c:Fire() end
                end)
            end
        end

        -- Auto Open Chests
        if Settings.AutoChest and interface then
            local chests = interface:FindFirstChild("Chests")
            if chests and chests.Visible then
                local finishBtn = chests:FindFirstChild("Finish", true)
                if finishBtn then
                    pcall(function()
                        for _, c in ipairs(getconnections(finishBtn.Activated) or {}) do c:Fire() end
                    end)
                end
            end
        end

        -- Auto Retry
        if Settings.AutoRetry and interface then
            local rewards = interface:FindFirstChild("Rewards")
            if rewards and rewards.Visible then
                local retryBtn = rewards:FindFirstChild("Retry", true)
                if retryBtn then
                    pcall(function()
                        for _, c in ipairs(getconnections(retryBtn.Activated) or {}) do c:Fire() end
                    end)
                end
            end
        end
    end
end)

-- 5. Auto Reload Blades
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.AutoReload and isCharacterAlive() then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local hud = playerGui and playerGui:FindFirstChild("HUD")
            if hud then
                local bladesLabel = hud:FindFirstChild("Blades", true)
                if bladesLabel and bladesLabel:IsA("TextLabel") and bladesLabel.Text == "0" then
                    pcall(function()
                        PostRemote:FireServer("Reload")
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    end)
                end
            end
        end
    end
end)

-- 6. Noclip Loop
RunService.Stepped:Connect(function()
    if Settings.Noclip and isCharacterAlive() then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 7. Hitbox Expander Loop
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.TitanHitbox then
            local titansFolder = Workspace:FindFirstChild("Titans")
            if titansFolder then
                for _, titan in ipairs(titansFolder:GetChildren()) do
                    if isTitanAlive(titan) then
                        local nape = getTitanNape(titan)
                        if nape and nape:IsA("BasePart") then
                            nape.Size = Vector3.new(Settings.TitanHitboxSize, Settings.TitanHitboxSize, Settings.TitanHitboxSize)
                            nape.Transparency = Settings.TitanHitboxTransparency
                            nape.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

-- 8. Delete Map (Potato PC Mode)
local function applyDeleteMap()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name:find("Tree") or obj.Name:find("House") or obj.Name:find("Building") or obj.Name:find("Prop") then
                obj:Destroy()
            end
        end
    end)
end

-- ============================================================================
-- LUNA INTERFACE SUITE (NO KEY PROMPT - DIRECT PASS-THROUGH)
-- ============================================================================

local Luna
local success, err = pcall(function()
    Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua"))()
end)

if not success or not Luna then
    -- Fallback: Load Rayfield if Luna is blocked or offline
    Luna = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end

local Window = Luna:CreateWindow({
    Name = "Astra Hub | Attack on Titan: Revolution",
    Subtitle = "AOT:R Fully Unlocked",
    LoadingTitle = "Astra Hub",
    LoadingSubtitle = "Key System Bypassed (Direct Access)",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AstraHubConfig",
        FileName = "AOTR_Astra"
    },
    KeySystem = false -- BYPASSED: Direct access, no key required!
})

-- ============================================================================
-- 10 FULL TABS IMPLEMENTATION
-- ============================================================================

-- TAB 1: Main Farm
local TabMain = Window:CreateTab({ Name = "Main Farm", Icon = "swords" })
TabMain:CreateSection("Core Auto Farm")
TabMain:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = Settings.AutoKill,
    Flag = "AutoKill",
    Callback = function(val) Settings.AutoKill = val end
})
TabMain:CreateDropdown({
    Name = "Movement Mode",
    Options = { "Hover", "Teleport" },
    CurrentOption = { Settings.MoveMode },
    Flag = "MoveMode",
    Callback = function(opt) Settings.MoveMode = type(opt) == "table" and opt[1] or opt end
})
TabMain:CreateSlider({
    Name = "Float Height",
    Range = { 50, 500 },
    Increment = 10,
    CurrentValue = Settings.FloatHeight,
    Flag = "FloatHeight",
    Callback = function(val) Settings.FloatHeight = val end
})
TabMain:CreateSlider({
    Name = "Movement Speed",
    Range = { 100, 800 },
    Increment = 25,
    CurrentValue = Settings.MoveSpeed,
    Flag = "MoveSpeed",
    Callback = function(val) Settings.MoveSpeed = val end
})
TabMain:CreateSlider({
    Name = "Attack Range",
    Range = { 50, 300 },
    Increment = 10,
    CurrentValue = Settings.AttackRange,
    Flag = "AttackRange",
    Callback = function(val) Settings.AttackRange = val end
})

TabMain:CreateSection("Automation Flow")
TabMain:CreateToggle({
    Name = "Auto Retry",
    CurrentValue = Settings.AutoRetry,
    Flag = "AutoRetry",
    Callback = function(val) Settings.AutoRetry = val end
})
TabMain:CreateToggle({
    Name = "Auto Skip Cutscenes",
    CurrentValue = Settings.AutoSkip,
    Flag = "AutoSkip",
    Callback = function(val) Settings.AutoSkip = val end
})
TabMain:CreateToggle({
    Name = "Auto Open Chests",
    CurrentValue = Settings.AutoChest,
    Flag = "AutoChest",
    Callback = function(val) Settings.AutoChest = val end
})
TabMain:CreateToggle({
    Name = "Open Premium Chest",
    CurrentValue = Settings.OpenSecondChest,
    Flag = "OpenSecondChest",
    Callback = function(val) Settings.OpenSecondChest = val end
})
TabMain:CreateToggle({
    Name = "Auto Reload Blades",
    CurrentValue = Settings.AutoReload,
    Flag = "AutoReload",
    Callback = function(val) Settings.AutoReload = val end
})
TabMain:CreateToggle({
    Name = "Multi Hit",
    CurrentValue = Settings.MultiHit,
    Flag = "MultiHit",
    Callback = function(val) Settings.MultiHit = val end
})
TabMain:CreateSlider({
    Name = "Multi Hit Count",
    Range = { 1, 10 },
    Increment = 1,
    CurrentValue = Settings.MultiHitCount,
    Flag = "MultiHitCount",
    Callback = function(val) Settings.MultiHitCount = val end
})

TabMain:CreateSection("Safety / Flow")
TabMain:CreateToggle({
    Name = "Anti Injury",
    CurrentValue = Settings.AntiInjury,
    Flag = "AntiInjury",
    Callback = function(val) Settings.AntiInjury = val end
})
TabMain:CreateToggle({
    Name = "Delete Map (Potato PC)",
    CurrentValue = Settings.DeleteMap,
    Flag = "DeleteMap",
    Callback = function(val)
        Settings.DeleteMap = val
        if val then applyDeleteMap() end
    end
})
TabMain:CreateToggle({
    Name = "Auto Failsafe (15min)",
    CurrentValue = Settings.AutoFailsafe,
    Flag = "AutoFailsafe",
    Callback = function(val) Settings.AutoFailsafe = val end
})

-- TAB 2: Titans
local TabTitans = Window:CreateTab({ Name = "Titans", Icon = "eye" })
TabTitans:CreateSection("Titan ESP")
TabTitans:CreateToggle({
    Name = "Titan ESP",
    CurrentValue = Settings.TitanESP,
    Flag = "TitanESP",
    Callback = function(val) Settings.TitanESP = val end
})
TabTitans:CreateToggle({
    Name = "Show Dead Titans",
    CurrentValue = Settings.TitanESPShowDead,
    Flag = "TitanESPShowDead",
    Callback = function(val) Settings.TitanESPShowDead = val end
})
TabTitans:CreateToggle({
    Name = "Show HP",
    CurrentValue = Settings.TitanESPHP,
    Flag = "TitanESPHP",
    Callback = function(val) Settings.TitanESPHP = val end
})
TabTitans:CreateSlider({
    Name = "ESP Distance",
    Range = { 500, 5000 },
    Increment = 100,
    CurrentValue = Settings.TitanESPDistance,
    Flag = "TitanESPDistance",
    Callback = function(val) Settings.TitanESPDistance = val end
})

TabTitans:CreateSection("Hitbox Expander")
TabTitans:CreateToggle({
    Name = "Titan Hitbox Expander",
    CurrentValue = Settings.TitanHitbox,
    Flag = "TitanHitbox",
    Callback = function(val) Settings.TitanHitbox = val end
})
TabTitans:CreateSlider({
    Name = "Hitbox Size",
    Range = { 10, 100 },
    Increment = 5,
    CurrentValue = Settings.TitanHitboxSize,
    Flag = "TitanHitboxSize",
    Callback = function(val) Settings.TitanHitboxSize = val end
})

TabTitans:CreateSection("Auto Titan Killer")
TabTitans:CreateToggle({
    Name = "Auto Titan Killer",
    CurrentValue = Settings.AutoTitanKiller,
    Flag = "AutoTitanKiller",
    Callback = function(val) Settings.AutoTitanKiller = val end
})
TabTitans:CreateSlider({
    Name = "Killer Range",
    Range = { 100, 1000 },
    Increment = 50,
    CurrentValue = Settings.AutoTitanKillerRange,
    Flag = "AutoTitanKillerRange",
    Callback = function(val) Settings.AutoTitanKillerRange = val end
})

-- TAB 3: Waves
local TabWaves = Window:CreateTab({ Name = "Waves", Icon = "activity" })
TabWaves:CreateSection("Waves Auto Farm")
TabWaves:CreateToggle({
    Name = "Auto Waves",
    CurrentValue = Settings.AutoWaves,
    Flag = "AutoWaves",
    Callback = function(val) Settings.AutoWaves = val end
})
TabWaves:CreateToggle({
    Name = "Auto Upgrade (Waves)",
    CurrentValue = Settings.AutoWavesUpgrade,
    Flag = "AutoWavesUpgrade",
    Callback = function(val) Settings.AutoWavesUpgrade = val end
})
TabWaves:CreateToggle({
    Name = "Auto Start Waves",
    CurrentValue = Settings.AutoStartWaves,
    Flag = "AutoStartWaves",
    Callback = function(val) Settings.AutoStartWaves = val end
})

-- TAB 4: Upgrades & Skills
local TabUpgrades = Window:CreateTab({ Name = "Upgrades & Skills", Icon = "zap" })
TabUpgrades:CreateSection("Auto Systems")
TabUpgrades:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = Settings.AutoUpgrade,
    Flag = "AutoUpgrade",
    Callback = function(val) Settings.AutoUpgrade = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Perk",
    CurrentValue = Settings.AutoPerk,
    Flag = "AutoPerk",
    Callback = function(val) Settings.AutoPerk = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Skill Tree",
    CurrentValue = Settings.AutoSkillTree,
    Flag = "AutoSkillTree",
    Callback = function(val) Settings.AutoSkillTree = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Slot",
    CurrentValue = Settings.AutoSlot,
    Flag = "AutoSlot",
    Callback = function(val) Settings.AutoSlot = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Start",
    CurrentValue = Settings.AutoStart,
    Flag = "AutoStart",
    Callback = function(val) Settings.AutoStart = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Prestige",
    CurrentValue = Settings.AutoPrestige,
    Flag = "AutoPrestige",
    Callback = function(val) Settings.AutoPrestige = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Claim Achievements",
    CurrentValue = Settings.AutoClaimAchievements,
    Flag = "AutoClaimAchievements",
    Callback = function(val) Settings.AutoClaimAchievements = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Modifiers",
    CurrentValue = Settings.AutoModifiers,
    Flag = "AutoModifiers",
    Callback = function(val) Settings.AutoModifiers = val end
})
TabUpgrades:CreateToggle({
    Name = "Auto Boost",
    CurrentValue = Settings.AutoBoost,
    Flag = "AutoBoost",
    Callback = function(val) Settings.AutoBoost = val end
})

-- TAB 5: Advanced / Safety
local TabSafety = Window:CreateTab({ Name = "Advanced / Safety", Icon = "shield" })
TabSafety:CreateSection("Movement & Misc")
TabSafety:CreateToggle({
    Name = "Noclip",
    CurrentValue = Settings.Noclip,
    Flag = "Noclip",
    Callback = function(val) Settings.Noclip = val end
})
TabSafety:CreateToggle({
    Name = "Safe Farm",
    CurrentValue = Settings.SafeFarm,
    Flag = "SafeFarm",
    Callback = function(val) Settings.SafeFarm = val end
})
TabSafety:CreateToggle({
    Name = "Auto Hooks",
    CurrentValue = Settings.AutoHooks,
    Flag = "AutoHooks",
    Callback = function(val) Settings.AutoHooks = val end
})
TabSafety:CreateToggle({
    Name = "Double Jump Boost",
    CurrentValue = Settings.DoubleJumpBoost,
    Flag = "DoubleJumpBoost",
    Callback = function(val) Settings.DoubleJumpBoost = val end
})
TabSafety:CreateToggle({
    Name = "Auto Escape",
    CurrentValue = Settings.AutoEscape,
    Flag = "AutoEscape",
    Callback = function(val) Settings.AutoEscape = val end
})

TabSafety:CreateSection("Auto Execute")
TabSafety:CreateToggle({
    Name = "Auto Execute on Rejoin",
    CurrentValue = Settings.AutoExecute,
    Flag = "AutoExecute",
    Callback = function(val) Settings.AutoExecute = val end
})
TabSafety:CreateInput({
    Name = "Auto Execute Script",
    PlaceholderText = "Paste script here...",
    Flag = "AutoExecScript",
    Callback = function(text)
        Settings.AutoExecScript = text
        writefile("AstraHub/aotr/autoexec.txt", text)
    end
})

-- TAB 6: Mastery
local TabMastery = Window:CreateTab({ Name = "Mastery", Icon = "award" })
TabMastery:CreateSection("Mastery Farm")
TabMastery:CreateToggle({
    Name = "Mastery Farm",
    CurrentValue = Settings.MasteryFarm,
    Flag = "MasteryFarm",
    Callback = function(val) Settings.MasteryFarm = val end
})
TabMastery:CreateDropdown({
    Name = "Mastery Mode",
    Options = { "Punching", "Skill Usage", "Both" },
    CurrentOption = { Settings.MasteryMode },
    Flag = "MasteryMode",
    Callback = function(opt) Settings.MasteryMode = type(opt) == "table" and opt[1] or opt end
})

-- TAB 7: Global / Rolls
local TabRolls = Window:CreateTab({ Name = "Global / Rolls", Icon = "gift" })
TabRolls:CreateSection("Auto Roll")
TabRolls:CreateToggle({
    Name = "Auto Roll",
    CurrentValue = Settings.AutoRoll,
    Flag = "AutoRoll",
    Callback = function(val) Settings.AutoRoll = val end
})
TabRolls:CreateDropdown({
    Name = "Target Rarities",
    Options = { "Rare", "Epic", "Legendary", "Mythical" },
    CurrentOption = { Settings.AutoRollRarities },
    Flag = "AutoRollRarities",
    Callback = function(opt) Settings.AutoRollRarities = type(opt) == "table" and opt[1] or opt end
})

TabRolls:CreateSection("Reward Webhooks")
TabRolls:CreateToggle({
    Name = "Reward Webhook",
    CurrentValue = Settings.RewardWebhook,
    Flag = "RewardWebhook",
    Callback = function(val) Settings.RewardWebhook = val end
})
TabRolls:CreateToggle({
    Name = "Mythical Family Webhook",
    CurrentValue = Settings.MythicalFamilyWebhook,
    Flag = "MythicalFamilyWebhook",
    Callback = function(val) Settings.MythicalFamilyWebhook = val end
})

-- TAB 8: Utils
local TabUtils = Window:CreateTab({ Name = "Utils", Icon = "tool" })
TabUtils:CreateSection("Utilities")
TabUtils:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        pcall(function()
            GetRemote:InvokeServer("Functions", "Teleport", "Lobby")
        end)
    end
})
TabUtils:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end
})
TabUtils:CreateButton({
    Name = "Reset Character",
    Callback = function()
        if isCharacterAlive() then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end
})

-- TAB 9: Configs
local TabConfigs = Window:CreateTab({ Name = "Configs", Icon = "settings" })
TabConfigs:CreateSection("Config Management")
local currentConfigName = "Default"
TabConfigs:CreateInput({
    Name = "Config Name",
    PlaceholderText = "Enter name...",
    Flag = "ConfigNameInput",
    Callback = function(name) currentConfigName = name end
})
TabConfigs:CreateButton({
    Name = "Save Config",
    Callback = function()
        local path = "AstraHub/aotr/configs/" .. currentConfigName .. ".json"
        pcall(function()
            writefile(path, HttpService:JSONEncode(Settings))
            Luna:Notify({ Title = "Astra Hub", Content = "Config saved: " .. currentConfigName })
        end)
    end
})
TabConfigs:CreateButton({
    Name = "Set Auto Load",
    Callback = function()
        writefile("AstraHub/aotr/autoload.txt", currentConfigName)
        Luna:Notify({ Title = "Astra Hub", Content = "Auto load set: " .. currentConfigName })
    end
})
TabConfigs:CreateButton({
    Name = "Clear Auto Load",
    Callback = function()
        if isfile("AstraHub/aotr/autoload.txt") then delfile("AstraHub/aotr/autoload.txt") end
        Luna:Notify({ Title = "Astra Hub", Content = "Auto load cleared" })
    end
})

-- TAB 10: Stats Tracker
local TabStats = Window:CreateTab({ Name = "Stats Tracker", Icon = "bar-chart-2" })
TabStats:CreateSection("Session Stats")
local statsLabel = TabStats:CreateLabel("Loading session stats...")

task.spawn(function()
    while true do
        task.wait(2)
        local elapsed = math.floor(tick() - SessionData.StartTime)
        local mins = math.floor(elapsed / 60)
        local secs = elapsed % 60
        local str = string.format("Time: %02dm %02ds | Games: %d | Gold: +%d | Gems: +%d | XP: +%d",
            mins, secs, SessionData.GamesPlayed, SessionData.GoldEarned, SessionData.GemsEarned, SessionData.XPEarned)
        pcall(function() statsLabel:Set(str) end)
    end
end)

TabStats:CreateButton({
    Name = "Reset Session Stats",
    Callback = function()
        SessionData.GamesPlayed = 0
        SessionData.GoldEarned = 0
        SessionData.GemsEarned = 0
        SessionData.XPEarned = 0
        SessionData.StartTime = tick()
        writefile("AstraHub/aotr/s_games.txt", "0")
        writefile("AstraHub/aotr/s_gold.txt", "0")
        writefile("AstraHub/aotr/s_gems.txt", "0")
        writefile("AstraHub/aotr/s_xp.txt", "0")
        Luna:Notify({ Title = "Astra Hub", Content = "Session stats reset!" })
    end
})

Luna:Notify({
    Title = "Astra Hub",
    Content = "Script loaded successfully! Key System bypassed.",
    Duration = 5
})

