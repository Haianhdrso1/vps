--[[
    Decompiled from memem.lua
    Target: Symbiote Key System (Symbiote Hub)
    Endpoint: https://symbiote.cc
    Deobfuscated & Fully Restored Source Code
    Preserves 100% of original logic, UI hierarchy, colors, tweens, and authentication flow.
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local CoreGui
pcall(function()
    CoreGui = game:GetService("CoreGui")
end)

local function getGuiParent()
    if CoreGui then
        return CoreGui
    end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    return playerGui
end

-- ============================================================================
-- Theme Palette (Direct from Runtime Bytecode)
-- ============================================================================
local Theme = {
    Background       = Color3.fromRGB(8, 6, 14),
    Surface          = Color3.fromRGB(14, 11, 24),
    SurfaceLight     = Color3.fromRGB(22, 18, 36),
    SurfaceHover     = Color3.fromRGB(32, 26, 52),
    Accent           = Color3.fromRGB(140, 60, 255),
    AccentBright     = Color3.fromRGB(170, 100, 255),
    AccentDark       = Color3.fromRGB(90, 35, 180),
    AccentDim        = Color3.fromRGB(55, 25, 110),
    Border           = Color3.fromRGB(40, 30, 65),
    BorderLight      = Color3.fromRGB(55, 42, 90),
    Text             = Color3.fromRGB(245, 240, 255),
    TextSub          = Color3.fromRGB(180, 170, 200),
    TextDim          = Color3.fromRGB(120, 110, 150),
    TextMuted        = Color3.fromRGB(75, 65, 105),
    Success          = Color3.fromRGB(80, 220, 150),
    SuccessDim       = Color3.fromRGB(30, 80, 55),
    Error            = Color3.fromRGB(240, 65, 75),
    ErrorDim         = Color3.fromRGB(80, 25, 30),
    DropdownBg       = Color3.fromRGB(12, 9, 20),
    Green            = Color3.fromRGB(34, 140, 75),
    GreenHover       = Color3.fromRGB(40, 170, 90),
    Yellow           = Color3.fromRGB(250, 204, 21),
    Black            = Color3.fromRGB(0, 0, 0),
    Card             = Color3.fromRGB(18, 14, 28),
    CardHover        = Color3.fromRGB(26, 20, 42),
    InputBg          = Color3.fromRGB(20, 16, 32),
    Shadow           = Color3.fromRGB(12, 10, 20)
}

-- ============================================================================
-- Base64 Encoder (Prototype root/4)
-- ============================================================================
local b64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function base64_encode(data)
    local bytes = { string.byte(data, 1, #data) }
    local len = #bytes
    local result = {}
    local index = 1

    for i = 1, len - (len % 3), 3 do
        local b1, b2, b3 = bytes[i], bytes[i + 1], bytes[i + 2]
        local c1 = math.floor(b1 / 4)
        local c2 = (b1 % 4) * 16 + math.floor(b2 / 16)
        local c3 = (b2 % 16) * 4 + math.floor(b3 / 64)
        local c4 = b3 % 64

        result[index]     = string.sub(b64_chars, c1 + 1, c1 + 1)
        result[index + 1] = string.sub(b64_chars, c2 + 1, c2 + 1)
        result[index + 2] = string.sub(b64_chars, c3 + 1, c3 + 1)
        result[index + 3] = string.sub(b64_chars, c4 + 1, c4 + 1)
        index = index + 4
    end

    local remainder = len % 3
    if remainder == 1 then
        local b1 = bytes[len]
        local c1 = math.floor(b1 / 4)
        local c2 = (b1 % 4) * 16
        result[index]     = string.sub(b64_chars, c1 + 1, c1 + 1)
        result[index + 1] = string.sub(b64_chars, c2 + 1, c2 + 1)
        result[index + 2] = "="
        result[index + 3] = "="
    elseif remainder == 2 then
        local b1, b2 = bytes[len - 1], bytes[len]
        local c1 = math.floor(b1 / 4)
        local c2 = (b1 % 4) * 16 + math.floor(b2 / 16)
        local c3 = (b2 % 16) * 4
        result[index]     = string.sub(b64_chars, c1 + 1, c1 + 1)
        result[index + 1] = string.sub(b64_chars, c2 + 1, c2 + 1)
        result[index + 2] = string.sub(b64_chars, c3 + 1, c3 + 1)
        result[index + 3] = "="
    end

    return table.concat(result)
end

-- ============================================================================
-- Universal HTTP Request Helper (Prototype root/23)
-- ============================================================================
local http_request_fn = (typeof(request) == "function" and request)
    or (typeof(http_request) == "function" and http_request)
    or (typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request)
    or (typeof(fluxus) == "table" and typeof(fluxus.request) == "function" and fluxus.request)
    or (typeof(http) == "table" and typeof(http.request) == "function" and http.request)

local function make_request(endpoint, payload, method)
    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "Roblox/WinInet"
    }
    if payload then
        headers["X-Payload"] = base64_encode(HttpService:JSONEncode(payload))
    end

    local url = "https://symbiote.cc" .. endpoint
    local reqMethod = method or "GET"
    local options = {
        Url = url,
        url = url,
        Method = reqMethod,
        method = reqMethod,
        Headers = headers,
        headers = headers
    }

    if http_request_fn then
        local success, res = pcall(function()
            return http_request_fn(options)
        end)
        if success and typeof(res) == "table" then
            local body = res.Body or res.body or ""
            local status = res.StatusCode or res.status or res.status_code or res.Status or 200
            return true, body, status
        end
        return false, tostring(res), 0
    else
        local success, res = pcall(function()
            return HttpService:RequestAsync(options)
        end)
        if success and typeof(res) == "table" then
            return true, res.Body or "", res.StatusCode or 200
        end
        return false, tostring(res), 0
    end
end

-- ============================================================================
-- UI Helper: Create UIStroke (Prototype root/7)
-- ============================================================================
local function create_stroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    if transparency then
        stroke.Transparency = transparency
    end
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- ============================================================================
-- Session Deactivation Handler (Prototype root/27/6)
-- ============================================================================
local function setup_session_deactivation(sessionToken)
    if not sessionToken then return end
    local deactivated = false

    local function deactivate()
        if deactivated then return end
        deactivated = true
        pcall(function()
            make_request("/deactivate", { token = sessionToken }, "GET")
        end)
    end

    pcall(function()
        game:BindToClose(function()
            deactivate()
        end)
    end)

    pcall(function()
        Players.PlayerRemoving:Connect(function(player)
            if player == LocalPlayer then
                deactivate()
            end
        end)
    end)
end

-- ============================================================================
-- Key Expiry Toast Notification (Prototype root/27/2)
-- ============================================================================
local function show_key_expiry_toast(data)
    local expiryStr = data.expires_at or "Unknown"
    local timeText = "Active"

    if type(expiryStr) == "string" and expiryStr ~= "Unknown" then
        local ok, parsedDate = pcall(function()
            return DateTime.fromIsoDate(expiryStr)
        end)
        if ok and parsedDate then
            local nowTimestamp = DateTime.now().UnixTimestamp
            local targetTimestamp = parsedDate.UnixTimestamp
            local diff = targetTimestamp - nowTimestamp

            if diff <= 0 then
                timeText = "Expired"
            else
                local d = math.floor(diff / 86400)
                local h = math.floor((diff % 86400) / 3600)
                local m = math.floor((diff % 3600) / 60)

                local parts = {}
                if d > 0 then table.insert(parts, d .. "D") end
                if h > 0 then table.insert(parts, h .. "H") end
                if m > 0 then table.insert(parts, m .. "M") end
                if #parts == 0 then table.insert(parts, "0M") end
                timeText = table.concat(parts, " ")
            end
        end
    end

    local toastGui = Instance.new("ScreenGui")
    toastGui.Name = "KeyExpiryToast"
    toastGui.ResetOnSpawn = false
    toastGui.DisplayOrder = 999
    toastGui.IgnoreGuiInset = true
    toastGui.Parent = getGuiParent()

    local toastFrame = Instance.new("Frame")
    toastFrame.Size = UDim2.new(0, 260, 0, 50)
    toastFrame.Position = UDim2.new(1, 270, 1, -70)
    toastFrame.BackgroundColor3 = Theme.Surface
    toastFrame.BorderSizePixel = 0
    toastFrame.ZIndex = 100
    toastFrame.Parent = toastGui

    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, 8)
    toastCorner.Parent = toastFrame

    create_stroke(toastFrame, Theme.Border, 1)

    local greenPill = Instance.new("Frame")
    greenPill.Size = UDim2.new(0, 4, 1, -16)
    greenPill.Position = UDim2.new(0, 8, 0, 8)
    greenPill.BackgroundColor3 = Theme.Success
    greenPill.BorderSizePixel = 0
    greenPill.ZIndex = 101
    greenPill.Parent = toastFrame

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = greenPill

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Text = utf8.char(9670) -- "◆"
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(0, 18, 0.5, -12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.TextColor3 = Theme.Success
    iconLabel.Font = Enum.Font.GothamBlack
    iconLabel.TextSize = 18
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.ZIndex = 101
    iconLabel.Parent = toastFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "Key Active"
    titleLabel.Size = UDim2.new(1, -55, 0, 18)
    titleLabel.Position = UDim2.new(0, 48, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 101
    titleLabel.Parent = toastFrame

    local expiryLabel = Instance.new("TextLabel")
    expiryLabel.Text = "Expires in: " .. timeText
    expiryLabel.Size = UDim2.new(1, -55, 0, 16)
    expiryLabel.Position = UDim2.new(0, 48, 0, 26)
    expiryLabel.BackgroundTransparency = 1
    expiryLabel.TextColor3 = Theme.TextSub
    expiryLabel.Font = Enum.Font.Gotham
    expiryLabel.TextSize = 11
    expiryLabel.TextXAlignment = Enum.TextXAlignment.Left
    expiryLabel.ZIndex = 101
    expiryLabel.Parent = toastFrame

    -- Animate in
    TweenService:Create(toastFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -280, 1, -70)
    }):Play()

    task.wait(4.5)

    -- Animate out
    TweenService:Create(toastFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 270, 1, -70)
    }):Play()

    task.wait(0.38)
    toastGui:Destroy()
end

-- ============================================================================
-- GUI Construction (32 Instances from Exact Trace)
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SymbioteKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = getGuiParent()

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Theme.Black
Overlay.BackgroundTransparency = 0.5
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 1
Overlay.Parent = ScreenGui

local Card = Instance.new("Frame")
Card.Name = "Card"
Card.Size = UDim2.new(0, 460, 0, 0)
Card.Position = UDim2.new(0.5, -230, 0.5, 0)
Card.BackgroundColor3 = Theme.Background
Card.BorderSizePixel = 0
Card.ClipsDescendants = true
Card.ZIndex = 2
Card.Parent = ScreenGui

create_stroke(Card, Theme.Border, 1)

-- Card Entrance Tween
TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 460, 0, 260),
    Position = UDim2.new(0.5, -230, 0.5, -130)
}):Play()

local CardGradient = Instance.new("UIGradient")
CardGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Card),
    ColorSequenceKeypoint.new(0.4, Theme.CardHover),
    ColorSequenceKeypoint.new(0.7, Theme.InputBg),
    ColorSequenceKeypoint.new(1, Theme.Shadow)
})
CardGradient.Rotation = 120
CardGradient.Parent = Card

local OuterGlow = Instance.new("Frame")
OuterGlow.Size = UDim2.new(1, 6, 1, 6)
OuterGlow.Position = UDim2.new(0, -3, 0, -3)
OuterGlow.BackgroundTransparency = 1
OuterGlow.BorderSizePixel = 0
OuterGlow.ZIndex = 1
OuterGlow.Parent = Card

local OuterGlowStroke = create_stroke(OuterGlow, Theme.AccentDim, 2, 0.4)

local OuterGlowGradient = Instance.new("UIGradient")
OuterGlowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(0.15, Theme.AccentDim),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(20, 12, 40)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(20, 12, 40)),
    ColorSequenceKeypoint.new(0.85, Theme.AccentDim),
    ColorSequenceKeypoint.new(1, Theme.Accent)
})
OuterGlowGradient.Rotation = 45
OuterGlowGradient.Parent = OuterGlowStroke

local TopAccentLine = Instance.new("Frame")
TopAccentLine.Size = UDim2.new(1, 0, 0, 2)
TopAccentLine.Position = UDim2.new(0, 0, 0, 0)
TopAccentLine.BackgroundColor3 = Theme.Accent
TopAccentLine.BorderSizePixel = 0
TopAccentLine.ZIndex = 10
TopAccentLine.Parent = Card

local TopAccentGradient = Instance.new("UIGradient")
TopAccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Shadow),
    ColorSequenceKeypoint.new(0.2, Theme.AccentDim),
    ColorSequenceKeypoint.new(0.5, Theme.AccentBright),
    ColorSequenceKeypoint.new(0.8, Theme.AccentDim),
    ColorSequenceKeypoint.new(1, Theme.Shadow)
})
TopAccentGradient.Offset = Vector2.new(-0.35, 0)
TopAccentGradient.Parent = TopAccentLine

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.Position = UDim2.new(0, 0, 0, 2)
TopBar.BackgroundColor3 = Theme.Surface
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = Card

local TopBarLine = Instance.new("Frame")
TopBarLine.Size = UDim2.new(1, 0, 0, 1)
TopBarLine.Position = UDim2.new(0, 0, 1, 0)
TopBarLine.BackgroundColor3 = Theme.Border
TopBarLine.BorderSizePixel = 0
TopBarLine.ZIndex = 3
TopBarLine.Parent = TopBar

local DiamondIcon = Instance.new("TextLabel")
DiamondIcon.Text = utf8.char(9670) -- "◆"
DiamondIcon.Size = UDim2.new(0, 30, 0, 42)
DiamondIcon.Position = UDim2.new(0, 10, 0, -2)
DiamondIcon.BackgroundTransparency = 1
DiamondIcon.TextColor3 = Theme.Accent
DiamondIcon.Font = Enum.Font.GothamBlack
DiamondIcon.TextSize = 30
DiamondIcon.TextYAlignment = Enum.TextYAlignment.Center
DiamondIcon.ZIndex = 4
DiamondIcon.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "Symbiote Key System"
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 42, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Theme.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
TitleLabel.ZIndex = 4
TitleLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0.5, -14)
CloseButton.BackgroundColor3 = Theme.ErrorDim
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Theme.Error
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 13
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 4
CloseButton.Parent = TopBar

create_stroke(CloseButton, Theme.Border, 1)

-- Close Button Hover
CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Theme.Error
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
end)
CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Theme.ErrorDim
    CloseButton.TextColor3 = Theme.Error
end)

-- Close Button Click
CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 460, 0, 0),
        Position = UDim2.new(0.5, -230, 0.5, 0)
    }):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.38)
    ScreenGui:Destroy()
end)

-- Dragging TopBar Logic
local dragging = false
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Card.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Card.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -40, 1, -64)
Content.Position = UDim2.new(0, 20, 0, 54)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = Card

local Description = Instance.new("TextLabel")
Description.Text = "Enter your key below to continue. If you don't have one, click 'Get Key'."
Description.Size = UDim2.new(1, 0, 0, 30)
Description.Position = UDim2.new(0, 0, 0, 0)
Description.BackgroundTransparency = 1
Description.TextColor3 = Theme.TextDim
Description.Font = Enum.Font.Gotham
Description.TextSize = 12
Description.TextXAlignment = Enum.TextXAlignment.Left
Description.TextWrapped = true
Description.ZIndex = 3
Description.Parent = Content

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, 0, 0, 42)
InputFrame.Position = UDim2.new(0, 0, 0, 42)
InputFrame.BackgroundColor3 = Theme.DropdownBg
InputFrame.BorderSizePixel = 0
InputFrame.ZIndex = 3
InputFrame.Parent = Content

local InputStroke = create_stroke(InputFrame, Theme.Border, 1)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.PlaceholderText = "Paste key here..."
KeyInput.PlaceholderColor3 = Theme.TextMuted
KeyInput.TextColor3 = Theme.AccentBright
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.Code
KeyInput.ClearTextOnFocus = false
KeyInput.ZIndex = 4
KeyInput.Parent = InputFrame

-- Autoload saved key from advanced_key.json
pcall(function()
    if typeof(isfile) == "function" and isfile("advanced_key.json") then
        if typeof(readfile) == "function" then
            local raw = readfile("advanced_key.json")
            local parsed = HttpService:JSONDecode(raw)
            if typeof(parsed) == "table" and parsed.key then
                KeyInput.Text = tostring(parsed.key)
            end
        end
    end
end)

KeyInput.Focused:Connect(function()
    InputStroke.Color = Theme.Accent
end)

KeyInput.FocusLost:Connect(function()
    InputStroke.Color = Theme.Border
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = ""
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.Position = UDim2.new(0, 0, 0, 92)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Theme.Error
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.ZIndex = 3
StatusLabel.Parent = Content

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 6, 0, 6)
StatusDot.Position = UDim2.new(0, 0, 0, 100)
StatusDot.BackgroundColor3 = Theme.TextMuted
StatusDot.BackgroundTransparency = 1
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 3
StatusDot.Parent = Content

local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Size = UDim2.new(0.35, -4, 0, 42)
GetKeyButton.Position = UDim2.new(0, 0, 0, 124)
GetKeyButton.BackgroundColor3 = Theme.SurfaceLight
GetKeyButton.BorderSizePixel = 0
GetKeyButton.Text = "Get Key"
GetKeyButton.TextColor3 = Theme.Accent
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextSize = 13
GetKeyButton.AutoButtonColor = false
GetKeyButton.ZIndex = 3
GetKeyButton.Parent = Content

create_stroke(GetKeyButton, Theme.Border, 1)

GetKeyButton.MouseEnter:Connect(function()
    GetKeyButton.BackgroundColor3 = Theme.SurfaceHover
    GetKeyButton.TextColor3 = Theme.AccentBright
end)

GetKeyButton.MouseLeave:Connect(function()
    GetKeyButton.BackgroundColor3 = Theme.SurfaceLight
    GetKeyButton.TextColor3 = Theme.Accent
end)

local ContinueButton = Instance.new("TextButton")
ContinueButton.Size = UDim2.new(0.65, -4, 0, 42)
ContinueButton.Position = UDim2.new(0.35, 4, 0, 124)
ContinueButton.BackgroundColor3 = Theme.Accent
ContinueButton.BorderSizePixel = 0
ContinueButton.Text = "Continue"
ContinueButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ContinueButton.Font = Enum.Font.GothamBold
ContinueButton.TextSize = 14
ContinueButton.AutoButtonColor = false
ContinueButton.ZIndex = 3
ContinueButton.Parent = Content

ContinueButton.MouseEnter:Connect(function()
    ContinueButton.BackgroundColor3 = Theme.AccentBright
end)

ContinueButton.MouseLeave:Connect(function()
    ContinueButton.BackgroundColor3 = Theme.Accent
end)

ContinueButton.MouseButton1Down:Connect(function()
    ContinueButton.BackgroundColor3 = Theme.AccentDark
end)

ContinueButton.MouseButton1Up:Connect(function()
    ContinueButton.BackgroundColor3 = Theme.AccentBright
end)

local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(1, 0, 0, 30)
DiscordButton.Position = UDim2.new(0, 0, 0, 176)
DiscordButton.BackgroundTransparency = 1
DiscordButton.Text = "Join Discord: https://discord.gg/9QAWtYxbcb"
DiscordButton.TextColor3 = Theme.AccentBright
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.TextSize = 13
DiscordButton.AutoButtonColor = false
DiscordButton.ZIndex = 3
DiscordButton.Parent = Content

local DiscordStroke = create_stroke(DiscordButton, Theme.Accent, 0.5, 0.4)

DiscordButton.MouseEnter:Connect(function()
    DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordStroke.Color = Theme.AccentBright
    DiscordStroke.Transparency = 0.2
end)

DiscordButton.MouseLeave:Connect(function()
    DiscordButton.TextColor3 = Theme.AccentBright
    DiscordStroke.Color = Theme.Accent
    DiscordStroke.Transparency = 0.4
end)

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Text = ""
FooterLabel.Size = UDim2.new(1, 0, 0, 20)
FooterLabel.Position = UDim2.new(0, 0, 0, 216)
FooterLabel.BackgroundTransparency = 1
FooterLabel.TextColor3 = Theme.TextMuted
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.TextSize = 10
FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
FooterLabel.ZIndex = 3
FooterLabel.Parent = Content

local BottomAccentLine = Instance.new("Frame")
BottomAccentLine.Size = UDim2.new(1, 0, 0, 2)
BottomAccentLine.Position = UDim2.new(0, 0, 1, -2)
BottomAccentLine.BackgroundColor3 = Theme.Accent
BottomAccentLine.BorderSizePixel = 0
BottomAccentLine.ZIndex = 10
BottomAccentLine.Parent = Card

local BottomAccentGradient = Instance.new("UIGradient")
BottomAccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Shadow),
    ColorSequenceKeypoint.new(0.2, Theme.AccentDim),
    ColorSequenceKeypoint.new(0.5, Theme.AccentBright),
    ColorSequenceKeypoint.new(0.8, Theme.AccentDim),
    ColorSequenceKeypoint.new(1, Theme.Shadow)
})
BottomAccentGradient.Offset = Vector2.new(-0.35, 0)
BottomAccentGradient.Parent = BottomAccentLine

-- ============================================================================
-- Ambient Breathing Gradient & Outer Glow Animation (Prototype root/8)
-- ============================================================================
task.spawn(function()
    while Card and Card.Parent do
        local t1 = TweenService:Create(TopAccentGradient, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(0.35, 0)})
        local t2 = TweenService:Create(BottomAccentGradient, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(0.35, 0)})
        local t3 = TweenService:Create(OuterGlowStroke, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.25})
        t1:Play()
        t2:Play()
        t3:Play()
        task.wait(2.2)
        if not Card or not Card.Parent then break end
        local b1 = TweenService:Create(TopAccentGradient, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(-0.35, 0)})
        local b2 = TweenService:Create(BottomAccentGradient, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(-0.35, 0)})
        local b3 = TweenService:Create(OuterGlowStroke, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.55})
        b1:Play()
        b2:Play()
        b3:Play()
        task.wait(2.2)
    end
end)

-- ============================================================================
-- Button Callback: Get Key (Prototype root/9)
-- ============================================================================
GetKeyButton.MouseButton1Click:Connect(function()
    GetKeyButton.Active = false
    GetKeyButton.Text = "Loading..."
    GetKeyButton.TextColor3 = Theme.TextDim
    StatusLabel.Text = ""

    local success, response, statusCode = make_request("/getlink", nil, "GET")
    if success and response then
        local decodeOk, resData = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if decodeOk and typeof(resData) == "table" and resData.url then
            pcall(function()
                if typeof(setclipboard) == "function" then
                    setclipboard(resData.url)
                end
            end)
            StatusLabel.TextColor3 = Theme.Yellow
            StatusLabel.Text = "Link copied to clipboard!"
            GetKeyButton.Text = "Copied!"
            GetKeyButton.TextColor3 = Theme.Success
            task.delay(2.5, function()
                GetKeyButton.Active = true
                GetKeyButton.Text = "Get Key"
                GetKeyButton.TextColor3 = Theme.Accent
            end)
        else
            StatusLabel.TextColor3 = Theme.Error
            StatusLabel.Text = "Failed to fetch link: Invalid response"
            GetKeyButton.Active = true
            GetKeyButton.Text = "Get Key"
            GetKeyButton.TextColor3 = Theme.Accent
        end
    else
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = "Failed to fetch link: Connection error"
        GetKeyButton.Active = true
        GetKeyButton.Text = "Get Key"
        GetKeyButton.TextColor3 = Theme.Accent
    end
end)

-- ============================================================================
-- Button Callback: Join Discord (Prototype root/26)
-- ============================================================================
DiscordButton.MouseButton1Click:Connect(function()
    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard("https://discord.gg/9QAWtYxbcb")
        end
    end)
    local oldText = DiscordButton.Text
    DiscordButton.Text = "Copied Discord Link!"
    task.delay(2, function()
        DiscordButton.Text = oldText
    end)
end)

-- ============================================================================
-- Button Callback: Continue / Verify Key (Prototype root/27)
-- ============================================================================
ContinueButton.MouseButton1Click:Connect(function()
    local rawKey = KeyInput.Text or ""
    local key = rawKey:match("^%s*(.-)%s*$")
    if key then key = key:gsub("%s+", "") end
    if not key or key == "" then
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = "Key cannot be empty!"
        return
    end

    ContinueButton.Active = false
    ContinueButton.Text = "Verifying..."
    ContinueButton.BackgroundColor3 = Theme.AccentDark
    StatusLabel.TextColor3 = Theme.TextDim
    StatusLabel.Text = "Authenticating..."

    local clientId = "Unknown"
    pcall(function()
        clientId = game:GetService("RbxAnalyticsService"):GetClientId()
    end)

    local platform = "Unknown"
    pcall(function()
        platform = UserInputService:GetPlatform().Name
    end)

    local executorName = "Unknown"
    pcall(function()
        if typeof(identifyexecutor) == "function" then
            executorName = identifyexecutor()
        end
    end)

    local payload = {
        key = key,
        userId = tostring(LocalPlayer.UserId),
        clientId = tostring(clientId),
        platform = tostring(platform),
        executor = tostring(executorName)
    }

    print("[Symbiote] Dang gui yeu cau xac thuc key:", key)
    local success, response, statusCode = make_request("/getloader", payload, "GET")
    if not success or not response then
        local errDetail = tostring(response or "Khong co phan hoi")
        print("[Symbiote Error] Loi ket noi:", errDetail, "Status:", tostring(statusCode))
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = "Connection Error (" .. tostring(statusCode or "Fail") .. ")"
        ContinueButton.Active = true
        ContinueButton.Text = "Continue"
        ContinueButton.BackgroundColor3 = Theme.Accent
        return
    end

    print("[Symbiote] Phan hoi tu server:", tostring(response))

    local decodeOk, resData = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not decodeOk or typeof(resData) ~= "table" then
        print("[Symbiote Error] JSON Parse Error. Raw body:", tostring(response))
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = "JSON Parse Error: Server returned invalid format."
        ContinueButton.Active = true
        ContinueButton.Text = "Continue"
        ContinueButton.BackgroundColor3 = Theme.Accent
        return
    end

    if not resData.success then
        print("[Symbiote Error] Server tu choi key:", tostring(resData.reason))
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = resData.reason or "Invalid Key"
        ContinueButton.Active = true
        ContinueButton.Text = "Continue"
        ContinueButton.BackgroundColor3 = Theme.Accent
        return
    end

    if not resData.loader or type(resData.loader) ~= "string" or resData.loader == "" then
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = "Server Error: Please try again."
        ContinueButton.Active = true
        ContinueButton.Text = "Continue"
        ContinueButton.BackgroundColor3 = Theme.Accent
        return
    end

    -- Save verified key to advanced_key.json (Prototype root/27/3)
    pcall(function()
        if typeof(writefile) == "function" then
            writefile("advanced_key.json", HttpService:JSONEncode({
                key = key,
                date = os.date("%x")
            }))
        end
    end)

    -- Setup session deactivation on game close or leave (Prototype root/27/6)
    setup_session_deactivation(resData.session_token)

    -- [Auto Dump for Delta X] Tự động lưu và copy toàn bộ mã nguồn AoT
    pcall(function()
        if typeof(writefile) == "function" then
            writefile("symbiote_aot_dumped.lua", resData.loader)
            print("[DUMP SUCCESS] Đã lưu mã nguồn AoT vào: workspace/symbiote_aot_dumped.lua")
        end
        if typeof(setclipboard) == "function" then
            setclipboard(resData.loader)
            print("[CLIPBOARD] Đã copy toàn bộ mã nguồn AoT vào khay nhớ tạm (chỉ cần paste ra)!")
        end
    end)

    -- Compile loader (Prototype root/27/5)
    local loaderFn, compileErr = loadstring(resData.loader, "Load")
    if not loaderFn then
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = "Compilation failed: " .. tostring(compileErr)
        ContinueButton.Active = true
        ContinueButton.Text = "Continue"
        ContinueButton.BackgroundColor3 = Theme.Accent
        local warnMsg = "[Symbiote] Loader compilation failed: " .. tostring(compileErr)
        if typeof(rconsolewarn) == "function" then
            rconsolewarn(warnMsg)
        elseif typeof(warn) == "function" then
            warn(warnMsg)
        else
            print(warnMsg)
        end
        return
    end

    -- Animate out UI and Destroy
    pcall(function()
        TweenService:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 460, 0, 0),
            Position = UDim2.new(0.5, -230, 0.5, 0)
        }):Play()
        TweenService:Create(Overlay, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.38)
        ScreenGui:Destroy()
    end)

    -- Key Expiry Toast Notification (Prototype root/27/2)
    task.spawn(function()
        show_key_expiry_toast(resData)
    end)

    -- Execute loader
    task.spawn(function()
        local runOk, runErr = pcall(loaderFn)
        if not runOk then
            local warnMsg = "[Symbiote] Loader error: " .. tostring(runErr)
            if typeof(rconsolewarn) == "function" then
                rconsolewarn(warnMsg)
            elseif typeof(warn) == "function" then
                warn(warnMsg)
            else
                print(warnMsg)
            end
        end
    end)
end)

