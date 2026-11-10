-- ============================================================================
-- Decompiled & Deobfuscated Script: memem.lua (Symbiote Loader)
-- 100% Full Functionality, Original UI Hierarchy & Auto-Dump for Delta X
---- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

---- ============================================================================
-- Safe UI Parent Resolution (Prototype root/2)
---- ============================================================================
local function get_safe_gui_parent()
    local okHui, hui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
    end)
    if okHui and hui then return hui end

    if CoreGui then
        local okCore, canCore = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = CoreGui
            test:Destroy()
            return true
        end)
        if okCore and canCore then
            return CoreGui
        end
    end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    return playerGui
end

---- ============================================================================
-- Exact Theme Colors Extracted From Bytecode
---- ============================================================================
local Theme = {
    Background      = Color3.fromRGB(10, 11, 20),
    CardBg          = Color3.fromRGB(15, 17, 30),
    CardBgDark      = Color3.fromRGB(12, 13, 24),
    Border          = Color3.fromRGB(38, 32, 64),
    BorderFocus     = Color3.fromRGB(124, 58, 237),
    BorderSubtle    = Color3.fromRGB(24, 20, 42),
    Accent          = Color3.fromRGB(124, 58, 237),
    AccentDark      = Color3.fromRGB(76, 29, 149),
    AccentLight     = Color3.fromRGB(167, 139, 250),
    AccentGlow      = Color3.fromRGB(139, 92, 246),
    Text            = Color3.fromRGB(248, 250, 252),
    TextMuted       = Color3.fromRGB(148, 163, 184),
    TextDim         = Color3.fromRGB(71, 85, 105),
    InputBg         = Color3.fromRGB(10, 11, 20),
    ButtonBg        = Color3.fromRGB(20, 22, 38),
    ButtonBorder    = Color3.fromRGB(42, 36, 70),
    Success         = Color3.fromRGB(34, 197, 94),
    Error           = Color3.fromRGB(239, 68, 68),
    ToastBg         = Color3.fromRGB(14, 15, 26),
    ToastBorder     = Color3.fromRGB(46, 38, 76),
    Yellow          = Color3.fromRGB(234, 179, 8),
    Green           = Color3.fromRGB(34, 197, 94),
    Red             = Color3.fromRGB(239, 68, 68),
    White           = Color3.fromRGB(255, 255, 255),
    DarkBase        = Color3.fromRGB(8, 8, 14),
    InputPlaceholder= Color3.fromRGB(80, 80, 110),
    HeaderBg        = Color3.fromRGB(17, 19, 34)
}

---- ============================================================================
-- Base64 Encoder Implementation (Prototype root/23 Base64 Routine)
---- ============================================================================
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64_encode(data)
    local result = {}
    local len = #data
    for i = 1, len, 3 do
        local b1 = data:byte(i)
        local b2 = (i + 1 <= len) and data:byte(i + 1) or nil
        local b3 = (i + 2 <= len) and data:byte(i + 2) or nil

        local c1 = math.floor(b1 / 4)
        local c2 = (b1 % 4) * 16 + (b2 and math.floor(b2 / 16) or 0)
        local c3 = b2 and ((b2 % 16) * 4 + (b3 and math.floor(b3 / 64) or 0)) or 64
        local c4 = b3 and (b3 % 64) or 64

        table.insert(result, b64chars:sub(c1 + 1, c1 + 1))
        table.insert(result, b64chars:sub(c2 + 1, c2 + 1))
        table.insert(result, c3 == 64 and "=" or b64chars:sub(c3 + 1, c3 + 1))
        table.insert(result, c4 == 64 and "=" or b64chars:sub(c4 + 1, c4 + 1))
    end
    return table.concat(result)
end

---- ============================================================================
-- Universal HTTP Request Helper (Tương thích 100% Delta X & Android Executors)
---- ============================================================================
local http_request_fn = (typeof(request) == "function" and request)
    or (typeof(http_request) == "function" and http_request)
    or (typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request)
    or (typeof(fluxus) == "table" and typeof(fluxus.request) == "function" and fluxus.request)
    or (typeof(http) == "table" and typeof(http.request) == "function" and http.request)

local function make_request(endpoint, payload, method)
    local endpoints = {
        "https://symbiote.cc" .. endpoint,
        "https://symbiote.up.railway.app" .. endpoint
    }
    
    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "Roblox/WinInet"
    }
    if payload then
        headers["X-Payload"] = base64_encode(HttpService:JSONEncode(payload))
    end

    local reqMethod = method or "GET"

    local reqFn = (typeof(request) == "function" and request)
        or (typeof(http_request) == "function" and http_request)
        or (typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request)
        or (typeof(fluxus) == "table" and typeof(fluxus.request) == "function" and fluxus.request)
        or (typeof(http) == "table" and typeof(http.request) == "function" and http.request)

    if not reqFn then
        return false, "Executor khong ho tro ham HTTP request", 0
    end

    for _, targetUrl in ipairs(endpoints) do
        local options = {
            Url = targetUrl,
            url = targetUrl,
            Method = reqMethod,
            method = reqMethod,
            Headers = headers,
            headers = headers,
            Timeout = 10,
            timeout = 10
        }

        local success, res = pcall(function()
            return reqFn(options)
        end)

        if success and typeof(res) == "table" then
            local body = res.Body or res.body or ""
            local status = res.StatusCode or res.status or res.status_code or res.Status or 200
            if #body > 0 then
                return true, body, status
            end
        end
    end

    return false, "Khong the ket noi toi server (timeout hoac block)", 0
end
---- ============================================================================
-- UI Helper: Create UIStroke (Prototype root/7)
---- ============================================================================
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

---- ============================================================================
-- Session Deactivation Handler (Prototype root/27/6)
---- ============================================================================
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

---- ============================================================================
-- Toast Notification System (Prototype root/27/2)
---- ============================================================================
local function show_key_expiry_toast(keyData)
    local targetParent = get_safe_gui_parent()
    local ToastGui = Instance.new("ScreenGui")
    ToastGui.Name = "SymbioteToast"
    ToastGui.ResetOnSpawn = false
    ToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToastGui.Parent = targetParent

    local ToastCard = Instance.new("Frame")
    ToastCard.Name = "ToastCard"
    ToastCard.Size = UDim2.new(0, 320, 0, 70)
    ToastCard.Position = UDim2.new(1, 20, 1, -90)
    ToastCard.BackgroundColor3 = Theme.ToastBg
    ToastCard.BorderSizePixel = 0
    ToastCard.Parent = ToastGui

    local ToastCorner = Instance.new("UICorner")
    ToastCorner.CornerRadius = UDim.new(0, 8)
    ToastCorner.Parent = ToastCard

    create_stroke(ToastCard, Theme.ToastBorder, 1, 0)

    local ToastIcon = Instance.new("TextLabel")
    ToastIcon.Name = "ToastIcon"
    ToastIcon.Size = UDim2.new(0, 40, 1, 0)
    ToastIcon.Position = UDim2.new(0, 10, 0, 0)
    ToastIcon.BackgroundTransparency = 1
    ToastIcon.Text = "âœ…"
    ToastIcon.TextSize = 22
    ToastIcon.TextColor3 = Theme.Success
    ToastIcon.Font = Enum.Font.GothamBold
    ToastIcon.Parent = ToastCard

    local ToastTitle = Instance.new("TextLabel")
    ToastTitle.Name = "ToastTitle"
    ToastTitle.Size = UDim2.new(1, -60, 0, 24)
    ToastTitle.Position = UDim2.new(0, 55, 0, 12)
    ToastTitle.BackgroundTransparency = 1
    ToastTitle.Text = "Key Activated"
    ToastTitle.TextColor3 = Theme.Text
    ToastTitle.Font = Enum.Font.GothamBold
    ToastTitle.TextSize = 14
    ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToastTitle.Parent = ToastCard

    local ToastSubtitle = Instance.new("TextLabel")
    ToastSubtitle.Name = "ToastSubtitle"
    ToastSubtitle.Size = UDim2.new(1, -60, 0, 20)
    ToastSubtitle.Position = UDim2.new(0, 55, 0, 36)
    ToastSubtitle.BackgroundTransparency = 1
    local expText = "Valid Session"
    if keyData and keyData.expires then
        expText = "Expires in: " .. tostring(keyData.expires)
    elseif keyData and keyData.tier then
        expText = "Tier: " .. tostring(keyData.tier)
    end
    ToastSubtitle.Text = expText
    ToastSubtitle.TextColor3 = Theme.TextMuted
    ToastSubtitle.Font = Enum.Font.Gotham
    ToastSubtitle.TextSize = 12
    ToastSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    ToastSubtitle.Parent = ToastCard

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = Theme.Accent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ToastCard

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 2)
    BarCorner.Parent = ProgressBar

    TweenService:Create(ToastCard, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -340, 1, -90)
    }):Play()

    TweenService:Create(ProgressBar, TweenInfo.new(4.5, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()

    task.delay(4.5, function()
        local tweenOut = TweenService:Create(ToastCard, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 1, -90)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            ToastGui:Destroy()
        end)
    end)
end

---- ============================================================================
-- GUI Construction: Main Interface Hierarchy (Prototypes root/14 to root/22)
---- ============================================================================
local guiParent = get_safe_gui_parent()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SymbioteAuth"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local setParentOk = pcall(function()
    ScreenGui.Parent = guiParent
end)
if not setParentOk or not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    end)
end

local Overlay = Instance.new("Frame")
Overlay.Name = "Overlay"
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.Position = UDim2.new(0, 0, 0, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(4, 5, 10)
Overlay.BackgroundTransparency = 0.45
Overlay.BorderSizePixel = 0
Overlay.Parent = ScreenGui

local screenWidth = 460
pcall(function()
    screenWidth = workspace.CurrentCamera.ViewportSize.X
end)
local cardWidth = math.clamp(screenWidth - 30, 280, 460)
local cardHeight = 340

local Card = Instance.new("Frame")
Card.Name = "Card"
Card.Size = UDim2.new(0, cardWidth, 0, cardHeight)
Card.Position = UDim2.new(0.5, -math.floor(cardWidth / 2), 0.5, -math.floor(cardHeight / 2))
Card.BackgroundColor3 = Theme.CardBg
Card.BorderSizePixel = 0
Card.ClipsDescendants = true
Card.Parent = ScreenGui

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 14)
CardCorner.Parent = Card

local CardStroke = create_stroke(Card, Theme.Border, 1.2, 0)

local CardGradient = Instance.new("UIGradient")
CardGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 20, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 13, 24))
})
CardGradient.Rotation = 45
CardGradient.Parent = Card

local TopAccentBar = Instance.new("Frame")
TopAccentBar.Name = "TopAccentBar"
TopAccentBar.Size = UDim2.new(1, 0, 0, 3)
TopAccentBar.Position = UDim2.new(0, 0, 0, 0)
TopAccentBar.BackgroundColor3 = Theme.Accent
TopAccentBar.BorderSizePixel = 0
TopAccentBar.Parent = Card

local TopAccentGradient = Instance.new("UIGradient")
TopAccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.AccentDark),
    ColorSequenceKeypoint.new(0.5, Theme.AccentLight),
    ColorSequenceKeypoint.new(1, Theme.AccentDark)
})
TopAccentGradient.Parent = TopAccentBar

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.Position = UDim2.new(0, 0, 0, 3)
Header.BackgroundColor3 = Theme.HeaderBg
Header.BackgroundTransparency = 0.5
Header.BorderSizePixel = 0
Header.Parent = Card

local BrandIcon = Instance.new("ImageLabel")
BrandIcon.Name = "BrandIcon"
BrandIcon.Size = UDim2.new(0, 26, 0, 26)
BrandIcon.Position = UDim2.new(0, 20, 0.5, -13)
BrandIcon.BackgroundTransparency = 1
BrandIcon.Image = "rbxassetid://10723345518"
BrandIcon.ImageColor3 = Theme.AccentLight
BrandIcon.Parent = Header

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Name = "BrandTitle"
BrandTitle.Size = UDim2.new(0, 200, 0, 24)
BrandTitle.Position = UDim2.new(0, 54, 0.5, -12)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "SYMBIOTE"
BrandTitle.TextColor3 = Theme.Text
BrandTitle.Font = Enum.Font.GothamBold
BrandTitle.TextSize = 16
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
BrandTitle.Parent = Header

local VersionTag = Instance.new("TextLabel")
VersionTag.Name = "VersionTag"
VersionTag.Size = UDim2.new(0, 50, 0, 18)
VersionTag.Position = UDim2.new(0, 142, 0.5, -9)
VersionTag.BackgroundColor3 = Theme.ButtonBg
VersionTag.Text = "v2.0"
VersionTag.TextColor3 = Theme.AccentLight
VersionTag.Font = Enum.Font.GothamMedium
VersionTag.TextSize = 10
VersionTag.Parent = Header

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0, 4)
VersionCorner.Parent = VersionTag
create_stroke(VersionTag, Theme.BorderSubtle, 1, 0)

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -44, 0.5, -14)
CloseButton.BackgroundColor3 = Theme.ButtonBg
CloseButton.Text = "âœ•"
CloseButton.TextColor3 = Theme.TextMuted
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 13
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton
create_stroke(CloseButton, Theme.BorderSubtle, 1, 0)

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Theme.Error
    CloseButton.TextColor3 = Theme.White
end)
CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Theme.ButtonBg
    CloseButton.TextColor3 = Theme.TextMuted
end)
CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 460, 0, 0),
        Position = UDim2.new(0.5, -230, 0.5, 0)
    }):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.35)
    ScreenGui:Destroy()
end)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -40, 1, -76)
Content.Position = UDim2.new(0, 20, 0, 66)
Content.BackgroundTransparency = 1
Content.Parent = Card

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 24)
TitleLabel.Position = UDim2.new(0, 0, 0, 6)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Key System Verification"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Content

local DescLabel = Instance.new("TextLabel")
DescLabel.Name = "DescLabel"
DescLabel.Size = UDim2.new(1, 0, 0, 32)
DescLabel.Position = UDim2.new(0, 0, 0, 32)
DescLabel.BackgroundTransparency = 1
DescLabel.Text = "Please enter your key below to access the script. If you don't have a key, click 'Get Key' to generate one."
DescLabel.TextColor3 = Theme.TextMuted
DescLabel.Font = Enum.Font.Gotham
DescLabel.TextSize = 12
DescLabel.TextWrapped = true
DescLabel.TextXAlignment = Enum.TextXAlignment.Left
DescLabel.TextYAlignment = Enum.TextYAlignment.Top
DescLabel.Parent = Content

local InputBoxContainer = Instance.new("Frame")
InputBoxContainer.Name = "InputBoxContainer"
InputBoxContainer.Size = UDim2.new(1, 0, 0, 44)
InputBoxContainer.Position = UDim2.new(0, 0, 0, 78)
InputBoxContainer.BackgroundColor3 = Theme.InputBg
InputBoxContainer.Parent = Content

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputBoxContainer

local InputStroke = create_stroke(InputBoxContainer, Theme.Border, 1, 0)

local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(1, -24, 1, 0)
KeyInput.Position = UDim2.new(0, 12, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.PlaceholderText = "Paste your key here..."
KeyInput.PlaceholderColor3 = Theme.InputPlaceholder
KeyInput.Text = ""
KeyInput.TextColor3 = Theme.Text
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 13
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = InputBoxContainer

KeyInput.Focused:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.2), { Color = Theme.BorderFocus }):Play()
end)
KeyInput.FocusLost:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.2), { Color = Theme.Border }):Play()
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 18)
StatusLabel.Position = UDim2.new(0, 0, 0, 126)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Theme.Error
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Content

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Size = UDim2.new(1, 0, 0, 42)
ButtonContainer.Position = UDim2.new(0, 0, 0, 150)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = Content

local ContinueButton = Instance.new("TextButton")
ContinueButton.Name = "ContinueButton"
ContinueButton.Size = UDim2.new(0.48, 0, 1, 0)
ContinueButton.Position = UDim2.new(0, 0, 0, 0)
ContinueButton.BackgroundColor3 = Theme.Accent
ContinueButton.Text = "Continue"
ContinueButton.TextColor3 = Theme.White
ContinueButton.Font = Enum.Font.GothamBold
ContinueButton.TextSize = 13
ContinueButton.Parent = ButtonContainer

local ContinueCorner = Instance.new("UICorner")
ContinueCorner.CornerRadius = UDim.new(0, 8)
ContinueCorner.Parent = ContinueButton

local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Name = "GetKeyButton"
GetKeyButton.Size = UDim2.new(0.48, 0, 1, 0)
GetKeyButton.Position = UDim2.new(0.52, 0, 0, 0)
GetKeyButton.BackgroundColor3 = Theme.ButtonBg
GetKeyButton.Text = "Get Key"
GetKeyButton.TextColor3 = Theme.Text
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextSize = 13
GetKeyButton.Parent = ButtonContainer

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 8)
GetKeyCorner.Parent = GetKeyButton
create_stroke(GetKeyButton, Theme.ButtonBorder, 1, 0)

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 206)
Divider.BackgroundColor3 = Theme.BorderSubtle
Divider.BorderSizePixel = 0
Divider.Parent = Content

local DiscordButton = Instance.new("TextButton")
DiscordButton.Name = "DiscordButton"
DiscordButton.Size = UDim2.new(1, 0, 0, 34)
DiscordButton.Position = UDim2.new(0, 0, 0, 218)
DiscordButton.BackgroundColor3 = Theme.CardBgDark
DiscordButton.Text = "Join Support Discord"
DiscordButton.TextColor3 = Theme.AccentLight
DiscordButton.Font = Enum.Font.GothamMedium
DiscordButton.TextSize = 12
DiscordButton.Parent = Content

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 6)
DiscordCorner.Parent = DiscordButton
create_stroke(DiscordButton, Theme.BorderSubtle, 1, 0)

---- ============================================================================
-- Drag Functionality (Prototype root/25)
---- ============================================================================
local dragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Card.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Card.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Entrance Animation (340px total height)
TweenService:Create(Card, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 460, 0, 340),
    Position = UDim2.new(0.5, -230, 0.5, -170)
}):Play()

---- ============================================================================
-- Auto-Load Saved Key From advanced_key.json (Prototype root/27)
---- ============================================================================
pcall(function()
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        if isfile("advanced_key.json") then
            local rawData = readfile("advanced_key.json")
            local parsed = HttpService:JSONDecode(rawData)
            if parsed and parsed.key then
                KeyInput.Text = parsed.key
            end
        end
    end
end)

---- ============================================================================
-- Button Callback: Get Key (Prototype root/26)
---- ============================================================================
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
                GetKeyButton.TextColor3 = Theme.Text
            end)
            return
        end
    end

    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard("https://symbiote.cc/start")
        end
    end)
    StatusLabel.TextColor3 = Theme.Yellow
    StatusLabel.Text = "Fallback: Link copied to clipboard!"
    GetKeyButton.Text = "Copied!"
    GetKeyButton.TextColor3 = Theme.Success
    task.delay(2.5, function()
        GetKeyButton.Active = true
        GetKeyButton.Text = "Get Key"
        GetKeyButton.TextColor3 = Theme.Text
    end)
end)

---- ============================================================================
-- Button Callback: Discord Link (Prototype root/27)
---- ============================================================================
DiscordButton.MouseButton1Click:Connect(function()
    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard("https://discord.gg/9QAWtYxbcb")
        end
    end)
    local oldText = DiscordButton.Text
    DiscordButton.Text = "Discord Invite Copied!"
    DiscordButton.TextColor3 = Theme.Success
    task.delay(2, function()
        DiscordButton.Text = oldText
        DiscordButton.TextColor3 = Theme.AccentLight
    end)
end)

---- ============================================================================
-- Button Callback: Continue / Verify Key & AUTO-DUMP (Prototype root/27)
---- ============================================================================
ContinueButton.MouseButton1Click:Connect(function()
    task.spawn(function()
        local rawKey = KeyInput.Text or ""
    local key = rawKey:match("^%s*(.-)%s*$")
    if key then 
        key = key:gsub("%s+", "")
    end

    if not key or key == "" then
        StatusLabel.TextColor3 = Theme.Error
        StatusLabel.Text = "Key cannot be empty!"
        return
    end

    ContinueButton.Active = false
    ContinueButton.Text = "Verifying..."
    ContinueButton.BackgroundColor3 = Theme.AccentDark
    StatusLabel.TextColor3 = Theme.TextDim
    StatusLabel.Text = "Dang ket noi toi server..."

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
        local reason = resData.reason or "Invalid Key"
        if reason:lower():find("invalid") then
            StatusLabel.Text = "Key khong hop le hoac da het han!"
        else
            StatusLabel.Text = tostring(reason)
        end
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

    -- Luu ban backup cua Stage 2 Loader vao workspace
    pcall(function()
        if typeof(writefile) == "function" then
            writefile("symbiote_stage2_loader_backup.lua", resData.loader)
        end
    end)

    -- ========================================================================
    -- LIVE PATCHING STAGE 2 LOADER: FIX NETWORK & EXTRACT 100% REAL GAME SOURCE
    -- ========================================================================
    local rawLoaderCode = resData.loader
    local patchedLoader = rawLoaderCode

    -- 1. Bổ sung User-Agent: Roblox/WinInet vào loader để Cloudflare không chặn /verify
    patchedLoader = patchedLoader:gsub("(headers%s*=%s*headers%s*or%s*%{%})", "%1; headers['User-Agent'] = 'Roblox/WinInet'")

    -- 2. Vô hiệu hóa RequestAsync bên trong loader (tránh đơ game trên Roblox client)
    patchedLoader = patchedLoader:gsub(":RequestAsync%b()", ":RequestAsync_DISABLED()")

    -- 3. Vô hiệu hóa bẫy Anti-Tamper
    patchedLoader = patchedLoader:gsub("local%s+isCompromised%s*=[^\n\r]+", "local isCompromised = false; _TAMPERED = false")
    patchedLoader = patchedLoader:gsub("_TAMPERED%s*=%s*true", "-- _TAMPERED = true")

    -- 4. Chèn bộ bắt mã nguồn thật ngay khi rawScript vừa được giải mã xong
    local extractionPayload = [[
    targetScript = rawScript
    pcall(function()
        if rawScript and #rawScript > 50 then
            print("==================================================")
            print("[SYMBIOTE DUMP] >>> DA TRICH XUAT THANH CONG FULL SOURCE CODE THUC! <<<")
            print("[SYMBIOTE DUMP] Kich thuoc code: " .. tostring(#rawScript) .. " bytes")
            print("==================================================")
            local wf = (typeof(writefile) == "function" and writefile) or (typeof(syn) == "table" and syn.write_file)
            if typeof(wf) == "function" then
                wf("symbiote_full_source.lua", rawScript)
                print("[SYMBIOTE DUMP] Da luu thanh cong vao file: workspace/symbiote_full_source.lua")
            end
            local sc = (typeof(setclipboard) == "function" and setclipboard) or (typeof(toclipboard) == "function" and toclipboard)
            if typeof(sc) == "function" then
                sc(rawScript)
                print("[SYMBIOTE DUMP] Da copy 100% Full Source Code vao Clipboard!")
            end
        end
    end)
    ]]

    if patchedLoader:find("targetScript%s*=%s*rawScript") then
        patchedLoader = patchedLoader:gsub("targetScript%s*=%s*rawScript", extractionPayload)
    end

    -- Compile loader (Prototype root/27/5)
    local loaderFn, compileErr = loadstring(patchedLoader, "SymbiotePatchedLoader")
    if not loaderFn then
        loaderFn, compileErr = loadstring(rawLoaderCode, "Load")
    end
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
end)
