--[[
    senden hub UI Library (Rayfield-compatible API)
    macOS Dark Obsidian + Purple Neon Style
    Upload this file to GitHub and load it via:
        local Rayfield = loadstring(game:HttpGet("RAW_URL/menu.lua"))()
]]

local BRAND_TITLE = "senden hub"
local FORCE_BRAND_TITLE = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local function getPlayer()
    if not LocalPlayer then
        LocalPlayer = Players.LocalPlayer
    end
    return LocalPlayer
end

local function getUiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end
    local okCore = pcall(function()
        return CoreGui:GetChildren()
    end)
    if okCore then
        return CoreGui
    end
    local lp = getPlayer() or Players.PlayerAdded:Wait()
    return lp:WaitForChild("PlayerGui")
end

local Theme = {
    WindowBg = Color3.fromRGB(18, 18, 24),
    SidebarBg = Color3.fromRGB(16, 16, 22),
    BorderPurple = Color3.fromRGB(145, 72, 255),
    GlowPurple = Color3.fromRGB(130, 52, 255),
    Divider = Color3.fromRGB(40, 38, 54),

    CardBg = Color3.fromRGB(24, 24, 33),
    CardBgHover = Color3.fromRGB(30, 30, 42),
    CardBorder = Color3.fromRGB(48, 44, 66),
    SubCardBg = Color3.fromRGB(20, 20, 28),

    TabActiveBar = Color3.fromRGB(172, 96, 255),
    TabActiveBgStart = Color3.fromRGB(88, 44, 148),
    TabActiveBgEnd = Color3.fromRGB(28, 20, 44),
    TabTextActive = Color3.fromRGB(255, 255, 255),
    TabTextIdle = Color3.fromRGB(168, 170, 184),

    ToggleOn = Color3.fromRGB(146, 66, 255),
    ToggleOff = Color3.fromRGB(54, 57, 68),
    KnobOn = Color3.fromRGB(255, 255, 255),
    KnobOff = Color3.fromRGB(185, 188, 200),

    TextPrimary = Color3.fromRGB(244, 244, 250),
    TextMuted = Color3.fromRGB(168, 173, 186),
    ConsoleBg = Color3.fromRGB(15, 15, 21),

    DotRed = Color3.fromRGB(255, 95, 86),
    DotYellow = Color3.fromRGB(255, 189, 46),
    DotGreen = Color3.fromRGB(39, 201, 63),
}

local LucideIcons = {
    Home = "rbxassetid://10723407389",
    User = "rbxassetid://10747373176",
    Eye = "rbxassetid://10723346959",
    Settings = "rbxassetid://10734950309",
    Stats = "rbxassetid://10709770317",
    Activity = "rbxassetid://10709752035",
    Swords = "rbxassetid://10734975692",
    ChevronDown = "rbxassetid://10709790948",
    Check = "rbxassetid://10709752405",
    Close = "rbxassetid://10709789407",
    Shadow = "rbxassetid://6014261993",
}

local function resolveTabIcon(tabName, customIcon)
    if type(customIcon) == "string" and customIcon ~= "" then
        if customIcon:find("rbxassetid://", 1, true) then
            return customIcon
        elseif tonumber(customIcon) and tonumber(customIcon) ~= 4483362458 then
            return "rbxassetid://" .. customIcon
        end
    elseif type(customIcon) == "number" and customIcon ~= 4483362458 then
        return "rbxassetid://" .. tostring(customIcon)
    end

    local lower = string.lower(tostring(tabName or ""))
    if lower:find("player") then
        return LucideIcons.User
    elseif lower:find("farm") or lower:find("main") or lower:find("combat") then
        return LucideIcons.Home
    elseif lower:find("visual") or lower:find("various") or lower:find("esp") or lower:find("misc") then
        if lower:find("misc") or lower:find("setting") or lower:find("config") then
            return LucideIcons.Settings
        end
        return LucideIcons.Eye
    elseif lower:find("stat") then
        return LucideIcons.Stats
    elseif lower:find("kaitun") or lower:find("auto") then
        return LucideIcons.Activity
    elseif lower:find("setting") or lower:find("config") then
        return LucideIcons.Settings
    end
    return LucideIcons.Home
end

local function create(className, props, parent)
    local inst = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function tween(obj, duration, props)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local RayfieldLibrary = {
    Flags = {},
    Theme = Theme,
    _connections = {},
    _screenGui = nil,
    _mainFrame = nil,
    _logFn = nil,
    _notifHolder = nil,
    _destroyed = false,
}

local function trackConn(conn)
    table.insert(RayfieldLibrary._connections, conn)
    return conn
end

function RayfieldLibrary:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    for _, conn in ipairs(self._connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    self._connections = {}
    if self._screenGui and self._screenGui.Parent then
        self._screenGui:Destroy()
    end
    self._screenGui = nil
    self._mainFrame = nil
end

function RayfieldLibrary:SetVisibility(visible)
    if self._mainFrame and self._mainFrame.Parent then
        self._mainFrame.Visible = (visible == true)
    end
end

function RayfieldLibrary:IsVisible()
    return self._mainFrame ~= nil and self._mainFrame.Parent ~= nil and self._mainFrame.Visible == true
end

function RayfieldLibrary:LoadConfiguration()
    -- Config saving/loading is managed cleanly by the caller or via Flags
end

function RayfieldLibrary:Notify(opts)
    opts = opts or {}
    local title = tostring(opts.Title or BRAND_TITLE)
    local content = tostring(opts.Content or "")
    local duration = tonumber(opts.Duration) or 4

    if self._logFn then
        local firstLine = content:match("^([^\n]+)") or content
        self._logFn(title .. (firstLine ~= "" and (": " .. firstLine) or ""))
    end

    if not self._notifHolder or not self._notifHolder.Parent then
        return
    end

    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 50,
    }, self._notifHolder)
    create("UICorner", { CornerRadius = UDim.new(0, 10) }, card)
    create("UIStroke", { Color = Theme.BorderPurple, Thickness = 1.4, Transparency = 0.15 }, card)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, card)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    }, card)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.TabActiveBar,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        ZIndex = 51,
    }, card)

    if content ~= "" then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = content,
            TextColor3 = Theme.TextPrimary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            ZIndex = 51,
        }, card)
    end

    task.delay(duration, function()
        if card and card.Parent then
            local t = tween(card, 0.2, { BackgroundTransparency = 1 })
            t.Completed:Wait()
            if card and card.Parent then
                card:Destroy()
            end
        end
    end)
end

function RayfieldLibrary:CreateWindow(cfg)
    cfg = cfg or {}
    local uiName = "SendenHub_UI"
    local parent = getUiParent()
    local old = parent:FindFirstChild(uiName)
    if old then
        old:Destroy()
    end

    if self._screenGui then
        self:Destroy()
    end
    self._destroyed = false

    local windowTitle = BRAND_TITLE
    if not FORCE_BRAND_TITLE and type(cfg.Name) == "string" and cfg.Name ~= "" then
        windowTitle = cfg.Name
    end

    local toggleKey = Enum.KeyCode.RightShift
    if type(cfg.ToggleUIKeybind) == "string" and Enum.KeyCode[cfg.ToggleUIKeybind] then
        toggleKey = Enum.KeyCode[cfg.ToggleUIKeybind]
    elseif typeof(cfg.ToggleUIKeybind) == "EnumItem" then
        toggleKey = cfg.ToggleUIKeybind
    end

    local ScreenGui = create("ScreenGui", {
        Name = uiName,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, parent)
    self._screenGui = ScreenGui

    -- Notification Container (Bottom Right)
    local NotifHolder = create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, -30),
        Position = UDim2.new(1, -16, 1, -16),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 49,
    }, ScreenGui)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }, NotifHolder)
    self._notifHolder = NotifHolder

    local BASE_SIZE = UDim2.fromOffset(620, 420)
    local EXPANDED_SIZE = UDim2.fromOffset(740, 500)
    local MINI_SIZE = UDim2.fromOffset(620, 48)

    local MainFrame = create("Frame", {
        Name = "Main",
        Size = BASE_SIZE,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, ScreenGui)
    self._mainFrame = MainFrame

    create("UICorner", { CornerRadius = UDim.new(0, 12) }, MainFrame)
    create("UIStroke", {
        Color = Theme.BorderPurple,
        Thickness = 1.6,
        Transparency = 0.08,
    }, MainFrame)

    -- Soft Purple Neon Outer Glow
    create("ImageLabel", {
        Name = "PurpleGlow",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 56, 1, 56),
        ZIndex = 0,
        Image = LucideIcons.Shadow,
        ImageColor3 = Theme.GlowPurple,
        ImageTransparency = 0.28,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
    }, MainFrame)

    local Inner = create("Frame", {
        Name = "InnerContainer",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
    }, MainFrame)
    create("UICorner", { CornerRadius = UDim.new(0, 12) }, Inner)

    -- Top Titlebar
    local TitleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, Inner)

    create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, TitleBar)

    local DotsHolder = create("Frame", {
        Name = "TrafficDots",
        Size = UDim2.fromOffset(60, 16),
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 4,
    }, TitleBar)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
    }, DotsHolder)

    local function makeDot(name, color)
        local btn = create("TextButton", {
            Name = name,
            Size = UDim2.fromOffset(13, 13),
            BackgroundColor3 = color,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 5,
        }, DotsHolder)
        create("UICorner", { CornerRadius = UDim.new(1, 0) }, btn)
        return btn
    end

    local RedDot = makeDot("RedDot", Theme.DotRed)
    local YellowDot = makeDot("YellowDot", Theme.DotYellow)
    local GreenDot = makeDot("GreenDot", Theme.DotGreen)

    local TitleLabel = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 88, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = windowTitle,
        TextColor3 = Theme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, TitleBar)

    local CloseBtn = create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -14, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    }, TitleBar)

    local CloseIcon = create("ImageLabel", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = LucideIcons.Close,
        ImageColor3 = Theme.TextPrimary,
        ZIndex = 5,
    }, CloseBtn)

    -- Body Split
    local Body = create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, Inner)

    local Sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 170, 1, 0),
        BackgroundColor3 = Theme.SidebarBg,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, Body)

    create("Frame", {
        Name = "SidebarDivider",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, Sidebar)

    local SidebarScroll = create("ScrollingFrame", {
        Name = "SidebarList",
        Size = UDim2.new(1, 0, 1, -16),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.BorderPurple,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 4,
    }, Sidebar)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }, SidebarScroll)

    -- Right Panel
    local RightPanel = create("Frame", {
        Name = "RightPanel",
        Size = UDim2.new(1, -170, 1, 0),
        Position = UDim2.new(0, 170, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, Body)

    local PagesHolder = create("Frame", {
        Name = "PagesHolder",
        Size = UDim2.new(1, -24, 1, -108),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, RightPanel)

    -- Bottom Console Log Box
    local ConsoleBox = create("Frame", {
        Name = "ConsoleBox",
        Size = UDim2.new(1, -24, 0, 82),
        Position = UDim2.new(0, 12, 1, -12),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.ConsoleBg,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, RightPanel)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, ConsoleBox)
    create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, ConsoleBox)

    local ConsoleScroll = create("ScrollingFrame", {
        Name = "ConsoleScroll",
        Size = UDim2.new(1, -16, 1, -12),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.BorderPurple,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 4,
    }, ConsoleBox)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    }, ConsoleScroll)

    local logEntries = {}
    local function appendLog(msg)
        if not ConsoleScroll or not ConsoleScroll.Parent then
            return
        end
        local lbl = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 17),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code,
            Text = "> " .. tostring(msg),
            TextColor3 = Theme.TextMuted,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = #logEntries + 1,
            ZIndex = 5,
        }, ConsoleScroll)
        table.insert(logEntries, lbl)
        if #logEntries > 60 then
            local oldest = table.remove(logEntries, 1)
            if oldest then
                oldest:Destroy()
            end
        end
        task.defer(function()
            if ConsoleScroll and ConsoleScroll.Parent then
                ConsoleScroll.CanvasPosition = Vector2.new(0, math.max(0, ConsoleScroll.AbsoluteCanvasSize.Y - ConsoleScroll.AbsoluteWindowSize.Y))
            end
        end)
    end
    self._logFn = appendLog

    -- Draggable TitleBar
    do
        local dragging = false
        local dragInput = nil
        local dragStart = nil
        local startPos = nil

        trackConn(TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end))

        trackConn(TitleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end))

        trackConn(UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput and dragStart and startPos then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end))
    end

    -- Traffic light & close button interactions
    local isMinimized = false
    local isExpanded = false

    trackConn(CloseBtn.MouseEnter:Connect(function()
        tween(CloseIcon, 0.12, { ImageColor3 = Theme.DotRed })
    end))
    trackConn(CloseBtn.MouseLeave:Connect(function()
        tween(CloseIcon, 0.12, { ImageColor3 = Theme.TextPrimary })
    end))
    trackConn(CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end))

    trackConn(RedDot.MouseButton1Click:Connect(function()
        self:Destroy()
    end))

    trackConn(YellowDot.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Body.Visible = false
            tween(MainFrame, 0.18, { Size = MINI_SIZE })
        else
            tween(MainFrame, 0.18, { Size = isExpanded and EXPANDED_SIZE or BASE_SIZE })
            task.delay(0.1, function()
                if not isMinimized and Body and Body.Parent then
                    Body.Visible = true
                end
            end)
        end
    end))

    trackConn(GreenDot.MouseButton1Click:Connect(function()
        if isMinimized then
            isMinimized = false
            Body.Visible = true
        end
        isExpanded = not isExpanded
        tween(MainFrame, 0.18, { Size = isExpanded and EXPANDED_SIZE or BASE_SIZE })
    end))

    trackConn(UserInputService.InputBegan:Connect(function(input, gp)
        if gp or self._destroyed or not MainFrame or not MainFrame.Parent then
            return
        end
        if input.KeyCode == toggleKey or input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end))

    local tabs = {}
    local activeTab = nil

    local function selectTab(tabRec)
        if activeTab == tabRec then
            return
        end
        for _, t in ipairs(tabs) do
            local on = (t == tabRec)
            t.Page.Visible = on
            t.Bar.Visible = on
            if on then
                t.Button.BackgroundTransparency = 0
                t.Gradient.Enabled = true
                tween(t.Icon, 0.15, { ImageColor3 = Theme.TabTextActive })
                tween(t.TitleLabel, 0.15, { TextColor3 = Theme.TabTextActive })
                t.TitleLabel.Font = Enum.Font.GothamBold
            else
                t.Button.BackgroundTransparency = 1
                t.Gradient.Enabled = false
                tween(t.Icon, 0.15, { ImageColor3 = Theme.TabTextIdle })
                tween(t.TitleLabel, 0.15, { TextColor3 = Theme.TabTextIdle })
                t.TitleLabel.Font = Enum.Font.GothamSemibold
            end
        end
        activeTab = tabRec
    end

    local Window = {
        Rayfield = self,
    }

    function Window:ModifyTheme(newTheme)
        if type(newTheme) == "table" then
            for k, v in pairs(newTheme) do
                if Theme[k] ~= nil then
                    Theme[k] = v
                end
            end
        end
    end

    function Window:Log(msg)
        appendLog(msg)
    end

    function Window:SetTitle(newTitle)
        TitleLabel.Text = tostring(newTitle or windowTitle)
    end

    function Window:Destroy()
        RayfieldLibrary:Destroy()
    end

    function Window:CreateTab(tabName, iconArg)
        local displayName = tostring(tabName or "Tab")
        local iconId = resolveTabIcon(displayName, iconArg)

        local btn = create("TextButton", {
            Name = displayName,
            Size = UDim2.new(1, -8, 0, 40),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #tabs + 1,
            ZIndex = 4,
        }, SidebarScroll)
        create("UICorner", { CornerRadius = UDim.new(0, 8) }, btn)

        local grad = create("UIGradient", {
            Enabled = false,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.TabActiveBgStart),
                ColorSequenceKeypoint.new(1, Theme.TabActiveBgEnd),
            }),
        }, btn)

        local bar = create("Frame", {
            Name = "ActiveBar",
            Size = UDim2.new(0, 4, 1, -8),
            Position = UDim2.new(0, 0, 0, 4),
            BackgroundColor3 = Theme.TabActiveBar,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 5,
        }, btn)
        create("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)

        local icon = create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(0, 16, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = Theme.TabTextIdle,
            ZIndex = 5,
        }, btn)

        local titleLbl = create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 44, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = displayName,
            TextColor3 = Theme.TabTextIdle,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 5,
        }, btn)

        local page = create("ScrollingFrame", {
            Name = displayName .. "_Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.BorderPurple,
            CanvasSize = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
        }, PagesHolder)
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        }, page)
        create("UIPadding", {
            PaddingRight = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 4),
        }, page)

        local tabRec = {
            Button = btn,
            Gradient = grad,
            Bar = bar,
            Icon = icon,
            TitleLabel = titleLbl,
            Page = page,
            Order = 0,
        }
        table.insert(tabs, tabRec)

        trackConn(btn.MouseButton1Click:Connect(function()
            selectTab(tabRec)
        end))
        trackConn(btn.MouseEnter:Connect(function()
            if activeTab ~= tabRec then
                tween(icon, 0.12, { ImageColor3 = Theme.TextPrimary })
                tween(titleLbl, 0.12, { TextColor3 = Theme.TextPrimary })
            end
        end))
        trackConn(btn.MouseLeave:Connect(function()
            if activeTab ~= tabRec then
                tween(icon, 0.12, { ImageColor3 = Theme.TabTextIdle })
                tween(titleLbl, 0.12, { TextColor3 = Theme.TabTextIdle })
            end
        end))

        if #tabs == 1 then
            selectTab(tabRec)
        end

        local TabObj = {}

        local function nextOrder()
            tabRec.Order = tabRec.Order + 1
            return tabRec.Order
        end

        function TabObj:CreateSection(sectionTitle)
            local secText = tostring(sectionTitle or "Section")
            local holder = create("Frame", {
                Name = "SectionTitle",
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)

            local lbl = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -6, 1, 0),
                Position = UDim2.new(0, 4, 0, 2),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = secText,
                TextColor3 = Theme.TabActiveBar,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4,
            }, holder)

            local SectionAPI = {}
            function SectionAPI:Set(newText)
                lbl.Text = tostring(newText or "")
            end
            return SectionAPI
        end

        function TabObj:CreateLabel(text)
            local card = create("Frame", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = Theme.SubCardBg,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, card)

            local lbl = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamSemibold,
                Text = tostring(text or ""),
                TextColor3 = Theme.TextMuted,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 5,
            }, card)

            local LabelAPI = {}
            function LabelAPI:Set(newText)
                lbl.Text = tostring(newText or "")
            end
            return LabelAPI
        end

        function TabObj:CreateParagraph(opts)
            opts = opts or {}
            local card = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.SubCardBg,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, card)
            create("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
            }, card)
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
            }, card)

            local titleL = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 18),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = tostring(opts.Title or ""),
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                LayoutOrder = 1,
                ZIndex = 5,
            }, card)

            local contentL = create("TextLabel", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 16),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = tostring(opts.Content or ""),
                TextColor3 = Theme.TextMuted,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                LayoutOrder = 2,
                ZIndex = 5,
            }, card)

            local ParagraphAPI = {}
            function ParagraphAPI:Set(newOpts)
                newOpts = newOpts or {}
                if newOpts.Title ~= nil then
                    titleL.Text = tostring(newOpts.Title)
                end
                if newOpts.Content ~= nil then
                    contentL.Text = tostring(newOpts.Content)
                end
            end
            return ParagraphAPI
        end

        function TabObj:CreateButton(opts)
            opts = opts or {}
            local btnName = tostring(opts.Name or "Button")
            local cb = opts.Callback

            local card = create("TextButton", {
                Name = btnName,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.CardBg,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, card)

            local titleL = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -86, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = btnName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 5,
            }, card)

            local badge = create("Frame", {
                Size = UDim2.fromOffset(54, 24),
                Position = UDim2.new(1, -12, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.ToggleOn,
                BorderSizePixel = 0,
                ZIndex = 5,
            }, card)
            create("UICorner", { CornerRadius = UDim.new(0, 6) }, badge)

            create("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = "Click",
                TextColor3 = Theme.TextPrimary,
                TextSize = 12,
                ZIndex = 6,
            }, badge)

            trackConn(card.MouseEnter:Connect(function()
                tween(card, 0.12, { BackgroundColor3 = Theme.CardBgHover })
            end))
            trackConn(card.MouseLeave:Connect(function()
                tween(card, 0.12, { BackgroundColor3 = Theme.CardBg })
            end))
            trackConn(card.MouseButton1Click:Connect(function()
                appendLog("Clicked " .. titleL.Text)
                if cb then
                    local ok, err = pcall(cb)
                    if not ok then
                        warn("[senden hub] Button callback error:", err)
                    end
                end
            end))

            local ButtonAPI = {}
            function ButtonAPI:Set(newName)
                local s = tostring(newName or "")
                titleL.Text = s
                card.Name = s
            end
            return ButtonAPI
        end

        function TabObj:CreateToggle(opts)
            opts = opts or {}
            local toggleName = tostring(opts.Name or "Toggle")
            local curVal = (opts.CurrentValue == true)
            local cb = opts.Callback
            local flag = opts.Flag

            local card = create("Frame", {
                Name = toggleName,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.CardBg,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, card)

            local titleL = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = toggleName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 5,
            }, card)

            local switchBg = create("Frame", {
                Size = UDim2.fromOffset(48, 24),
                Position = UDim2.new(1, -12, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = curVal and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel = 0,
                ZIndex = 5,
            }, card)
            create("UICorner", { CornerRadius = UDim.new(1, 0) }, switchBg)

            local knob = create("Frame", {
                Size = UDim2.fromOffset(18, 18),
                Position = curVal and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = curVal and Theme.KnobOn or Theme.KnobOff,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, switchBg)
            create("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

            local hitBtn = create("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 7,
            }, card)

            local data = {
                Name = toggleName,
                Title = toggleName,
                CurrentValue = curVal,
            }

            local function applyState(newVal, logIt)
                local b = (newVal == true)
                data.CurrentValue = b
                tween(switchBg, 0.16, { BackgroundColor3 = b and Theme.ToggleOn or Theme.ToggleOff })
                tween(knob, 0.16, {
                    Position = b and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    BackgroundColor3 = b and Theme.KnobOn or Theme.KnobOff,
                })
                if logIt then
                    appendLog(titleL.Text .. (b and " enabled" or " disabled"))
                end
                if cb then
                    task.spawn(cb, b)
                end
            end

            trackConn(hitBtn.MouseEnter:Connect(function()
                tween(card, 0.12, { BackgroundColor3 = Theme.CardBgHover })
            end))
            trackConn(hitBtn.MouseLeave:Connect(function()
                tween(card, 0.12, { BackgroundColor3 = Theme.CardBg })
            end))
            trackConn(hitBtn.MouseButton1Click:Connect(function()
                applyState(not data.CurrentValue, true)
            end))

            local ToggleAPI = {}
            function ToggleAPI:Set(val)
                applyState(val, false)
            end

            setmetatable(ToggleAPI, {
                __index = data,
                __newindex = function(_, k, v)
                    data[k] = v
                    if k == "Name" or k == "Title" then
                        local s = tostring(v or "")
                        titleL.Text = s
                        card.Name = s
                    elseif k == "CurrentValue" then
                        applyState(v, false)
                    end
                end,
            })

            if flag then
                RayfieldLibrary.Flags[flag] = ToggleAPI
            end
            return ToggleAPI
        end

        function TabObj:CreateSlider(opts)
            opts = opts or {}
            local sliderName = tostring(opts.Name or "Slider")
            local range = opts.Range or { 0, 100 }
            local minVal = tonumber(range[1]) or 0
            local maxVal = tonumber(range[2]) or 100
            local step = tonumber(opts.Increment) or 1
            local suffix = opts.Suffix and (" " .. tostring(opts.Suffix)) or ""
            local curVal = math.clamp(tonumber(opts.CurrentValue) or minVal, minVal, maxVal)
            local cb = opts.Callback
            local flag = opts.Flag

            local card = create("Frame", {
                Name = sliderName,
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = Theme.CardBg,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, card)

            local titleL = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -92, 0, 22),
                Position = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = sliderName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 5,
            }, card)

            local valL = create("TextLabel", {
                Name = "ValueLabel",
                Size = UDim2.fromOffset(70, 22),
                Position = UDim2.new(1, -14, 0, 6),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                Text = tostring(curVal) .. suffix,
                TextColor3 = Theme.TabActiveBar,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 5,
            }, card)

            local track = create("Frame", {
                Size = UDim2.new(1, -28, 0, 6),
                Position = UDim2.new(0, 14, 0, 38),
                BackgroundColor3 = Theme.ToggleOff,
                BorderSizePixel = 0,
                ZIndex = 5,
            }, card)
            create("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

            local initPct = (maxVal > minVal) and ((curVal - minVal) / (maxVal - minVal)) or 0
            local fill = create("Frame", {
                Size = UDim2.new(initPct, 0, 1, 0),
                BackgroundColor3 = Theme.ToggleOn,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, track)
            create("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

            local knob = create("Frame", {
                Size = UDim2.fromOffset(14, 14),
                Position = UDim2.new(initPct, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Theme.KnobOn,
                BorderSizePixel = 0,
                ZIndex = 7,
            }, track)
            create("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

            local hitBtn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 8,
            }, track)

            local data = {
                Name = sliderName,
                Title = sliderName,
                CurrentValue = curVal,
            }

            local function applyValue(newVal, fireCb)
                local num = tonumber(newVal) or minVal
                local snapped = math.clamp(math.floor((num - minVal) / step + 0.5) * step + minVal, minVal, maxVal)
                -- Round decimal artifacts if step < 1
                if step < 1 then
                    snapped = math.floor(snapped * 1000 + 0.5) / 1000
                end
                local pct = (maxVal > minVal) and ((snapped - minVal) / (maxVal - minVal)) or 0
                data.CurrentValue = snapped
                valL.Text = tostring(snapped) .. suffix
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                if fireCb and cb then
                    task.spawn(cb, snapped)
                end
            end

            local sliding = false
            local function updateFromX(absX)
                local rel = math.clamp((absX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                local raw = minVal + (maxVal - minVal) * rel
                local prev = data.CurrentValue
                applyValue(raw, true)
                return prev ~= data.CurrentValue
            end

            trackConn(hitBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateFromX(input.Position.X)
                end
            end))

            trackConn(UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromX(input.Position.X)
                end
            end))

            trackConn(UserInputService.InputEnded:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    sliding = false
                    appendLog(titleL.Text .. " set to " .. tostring(data.CurrentValue))
                end
            end))

            local SliderAPI = {}
            function SliderAPI:Set(val)
                applyValue(val, false)
            end

            setmetatable(SliderAPI, {
                __index = data,
                __newindex = function(_, k, v)
                    data[k] = v
                    if k == "Name" or k == "Title" then
                        local s = tostring(v or "")
                        titleL.Text = s
                        card.Name = s
                    elseif k == "CurrentValue" then
                        applyValue(v, false)
                    end
                end,
            })

            if flag then
                RayfieldLibrary.Flags[flag] = SliderAPI
            end
            return SliderAPI
        end

        function TabObj:CreateDropdown(opts)
            opts = opts or {}
            local ddName = tostring(opts.Name or "Dropdown")
            local options = opts.Options or {}
            local multi = (opts.MultipleOptions == true)
            local cb = opts.Callback
            local flag = opts.Flag

            local selectedMap = {}
            local function normalizeInput(val)
                local list = {}
                if type(val) == "table" then
                    for _, item in ipairs(val) do
                        table.insert(list, tostring(item))
                    end
                elseif type(val) == "string" and val ~= "" then
                    table.insert(list, val)
                end
                return list
            end

            for _, item in ipairs(normalizeInput(opts.CurrentOption)) do
                selectedMap[item] = true
                if not multi then
                    break
                end
            end

            local function getSelectedList()
                local out = {}
                for _, opt in ipairs(options) do
                    local s = tostring(opt)
                    if selectedMap[s] then
                        table.insert(out, s)
                    end
                end
                -- Preserve selections even if not currently in options list
                for k, v in pairs(selectedMap) do
                    if v and not table.find(out, k) then
                        table.insert(out, k)
                    end
                end
                return out
            end

            local function formatSummary()
                local sel = getSelectedList()
                if #sel == 0 then
                    return "None"
                elseif #sel == 1 then
                    return sel[1]
                else
                    return table.concat(sel, ", ")
                end
            end

            local container = create("Frame", {
                Name = ddName,
                Size = UDim2.new(1, 0, 0, 44),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.CardBg,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, container)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, container)
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
            }, container)

            local headerBtn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = 1,
                ZIndex = 5,
            }, container)

            local titleL = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(0.55, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = ddName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 6,
            }, headerBtn)

            local selectedL = create("TextLabel", {
                Size = UDim2.new(0.45, -36, 1, 0),
                Position = UDim2.new(1, -34, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = formatSummary(),
                TextColor3 = Theme.TabActiveBar,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 6,
            }, headerBtn)

            local chevron = create("ImageLabel", {
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(1, -12, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = LucideIcons.ChevronDown,
                ImageColor3 = Theme.TextMuted,
                ZIndex = 6,
            }, headerBtn)

            local listFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.SubCardBg,
                BorderSizePixel = 0,
                Visible = false,
                LayoutOrder = 2,
                ZIndex = 5,
            }, container)
            create("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }, listFrame)
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
            }, listFrame)

            local optionButtons = {}
            local data = {
                Name = ddName,
                Title = ddName,
                CurrentOption = getSelectedList(),
            }

            local function refreshVisuals()
                selectedL.Text = formatSummary()
                data.CurrentOption = getSelectedList()
                for optStr, rec in pairs(optionButtons) do
                    local isSel = (selectedMap[optStr] == true)
                    rec.Btn.BackgroundColor3 = isSel and Theme.TabActiveBgEnd or Theme.CardBg
                    rec.Stroke.Color = isSel and Theme.BorderPurple or Theme.CardBorder
                    rec.Label.TextColor3 = isSel and Theme.TextPrimary or Theme.TextMuted
                    rec.Check.Visible = isSel
                end
            end

            local function buildOptions(newOpts)
                options = newOpts or {}
                for _, c in ipairs(listFrame:GetChildren()) do
                    if c:IsA("TextButton") then
                        c:Destroy()
                    end
                end
                optionButtons = {}

                for idx, opt in ipairs(options) do
                    local optStr = tostring(opt)
                    local optBtn = create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.CardBg,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = idx,
                        ZIndex = 6,
                    }, listFrame)
                    create("UICorner", { CornerRadius = UDim.new(0, 6) }, optBtn)
                    local st = create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, optBtn)

                    local optLbl = create("TextLabel", {
                        Size = UDim2.new(1, -34, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamSemibold,
                        Text = optStr,
                        TextColor3 = Theme.TextMuted,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ZIndex = 7,
                    }, optBtn)

                    local chk = create("ImageLabel", {
                        Size = UDim2.fromOffset(14, 14),
                        Position = UDim2.new(1, -10, 0.5, 0),
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        Image = LucideIcons.Check,
                        ImageColor3 = Theme.TabActiveBar,
                        Visible = false,
                        ZIndex = 7,
                    }, optBtn)

                    optionButtons[optStr] = {
                        Btn = optBtn,
                        Stroke = st,
                        Label = optLbl,
                        Check = chk,
                    }

                    trackConn(optBtn.MouseButton1Click:Connect(function()
                        if multi then
                            selectedMap[optStr] = not selectedMap[optStr]
                        else
                            selectedMap = { [optStr] = true }
                            listFrame.Visible = false
                            tween(chevron, 0.15, { Rotation = 0 })
                        end
                        refreshVisuals()
                        appendLog(titleL.Text .. ": " .. formatSummary())
                        if cb then
                            task.spawn(cb, data.CurrentOption)
                        end
                    end))
                end
                refreshVisuals()
            end

            buildOptions(options)

            trackConn(headerBtn.MouseButton1Click:Connect(function()
                local nextOpen = not listFrame.Visible
                listFrame.Visible = nextOpen
                tween(chevron, 0.15, { Rotation = nextOpen and 180 or 0 })
            end))

            local DropdownAPI = {}
            function DropdownAPI:Set(val)
                selectedMap = {}
                for _, item in ipairs(normalizeInput(val)) do
                    selectedMap[item] = true
                    if not multi then
                        break
                    end
                end
                refreshVisuals()
            end

            function DropdownAPI:Refresh(newOptions)
                buildOptions(newOptions)
            end

            setmetatable(DropdownAPI, {
                __index = data,
                __newindex = function(_, k, v)
                    data[k] = v
                    if k == "Name" or k == "Title" then
                        local s = tostring(v or "")
                        titleL.Text = s
                        container.Name = s
                    elseif k == "CurrentOption" then
                        DropdownAPI:Set(v)
                    end
                end,
            })

            if flag then
                RayfieldLibrary.Flags[flag] = DropdownAPI
            end
            return DropdownAPI
        end

        function TabObj:CreateInput(opts)
            opts = opts or {}
            local inputName = tostring(opts.Name or "Input")
            local cb = opts.Callback
            local clearOnLost = (opts.RemoveTextAfterFocusLost == true)

            local card = create("Frame", {
                Name = inputName,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.CardBg,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, card)

            local titleL = create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(0.48, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = inputName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 5,
            }, card)

            local box = create("TextBox", {
                Size = UDim2.new(0.52, -16, 0, 28),
                Position = UDim2.new(1, -10, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.ConsoleBg,
                BorderSizePixel = 0,
                Font = Enum.Font.Gotham,
                Text = tostring(opts.CurrentValue or ""),
                PlaceholderText = tostring(opts.PlaceholderText or "Enter text..."),
                PlaceholderColor3 = Theme.TextMuted,
                TextColor3 = Theme.TextPrimary,
                TextSize = 13,
                ClearTextOnFocus = false,
                ZIndex = 5,
            }, card)
            create("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, box)

            trackConn(box.FocusLost:Connect(function(enterPressed)
                local txt = box.Text
                if clearOnLost then
                    box.Text = ""
                end
                if cb then
                    task.spawn(cb, txt, enterPressed)
                end
            end))

            local InputAPI = {}
            function InputAPI:Set(val)
                box.Text = tostring(val or "")
            end
            return InputAPI
        end

        function TabObj:CreateKeybind(opts)
            opts = opts or {}
            local kbName = tostring(opts.Name or "Keybind")
            local curKey = tostring(opts.CurrentKeybind or "K")
            local cb = opts.Callback
            local listening = false

            local card = create("Frame", {
                Name = kbName,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = Theme.CardBg,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 4,
            }, page)
            create("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, card)

            create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = kbName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, card)

            local keyBtn = create("TextButton", {
                Size = UDim2.fromOffset(72, 26),
                Position = UDim2.new(1, -12, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.ConsoleBg,
                Font = Enum.Font.Code,
                Text = curKey,
                TextColor3 = Theme.TabActiveBar,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex = 5,
            }, card)
            create("UICorner", { CornerRadius = UDim.new(0, 6) }, keyBtn)
            create("UIStroke", { Color = Theme.CardBorder, Thickness = 1 }, keyBtn)

            trackConn(keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
            end))

            trackConn(UserInputService.InputBegan:Connect(function(input, gp)
                if gp then
                    return
                end
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    curKey = input.KeyCode.Name
                    keyBtn.Text = curKey
                elseif not listening and input.KeyCode.Name == curKey and cb then
                    task.spawn(cb, curKey)
                end
            end))

            local KeybindAPI = {}
            function KeybindAPI:Set(k)
                curKey = tostring(k or "K")
                keyBtn.Text = curKey
            end
            return KeybindAPI
        end

        return TabObj
    end

    appendLog(windowTitle .. " loaded (RightShift / K to toggle)")
    return Window
end

return RayfieldLibrary
