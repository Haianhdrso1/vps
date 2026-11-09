local getgenv = getgenv or function() return _G end
local loadstring = loadstring or load

-- Read first, so secure mode covers Rayfield's output from its first line.
local secureMode = false
if getgenv then
	local ok, result = pcall(function() return getgenv().RAYFIELD_SECURE end)
	if ok and result then secureMode = true end
end

-- Rayfield's own console output goes through these locals. Under secure mode they are silent.
-- They are never assigned as globals: in an executor those are shared with every other script.
local warn, print, error, assert = warn, print, error, assert
if secureMode then
	local rawError = error
	local rawAssert = assert
	warn = function(...) end
	print = function(...) end
	error = function(_, level) rawError("", level) end
	assert = function(v, ...) return rawAssert(v) end
end

if debugX then
	warn('Initialising Rayfield')
end

local function getService(name)
	local ok, service = pcall(game.GetService, game, name)
	if not ok or not service then
		pcall(function()
			service = game:FindFirstChildOfClass(name) or game:FindFirstChild(name)
		end)
	end
	if cloneref and service then
		local cOk, cloned = pcall(cloneref, service)
		if cOk and cloned then
			return cloned
		end
	end
	return service
end

-- Remote modules are fetched from a fixed commit rather than a branch, so what runs is exactly what
-- was reviewed and a push to a branch can't change it under every running script. Bump this to
-- ship a new reporter or icon set. sirius-gate pins its reporter to the same commit.
local RAYFIELD_COMMIT =
"a2c3063cc1e54db522dac4ab837b0a35a0da5ed0" -- SiriusSoftwareLtd/Rayfield: reporter.lua, icons.lua, sia.lua
local RAYFIELD_RAW = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/" .. RAYFIELD_COMMIT .. "/"

-- Services
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local GuiService = getService("GuiService")
local Workspace = getService("Workspace")

local requestFunc = (syn and syn.request)
	or (fluxus and fluxus.request)
	or (http and http.request)
	or (krnl and krnl.request)
	or (delta and delta.request)
	or http_request
	or request

local customAssetFunc = getcustomasset or getsynasset

-- Universal HTTP GET helper across all PC and Mobile clients/executors
local function httpGet(url)
	if type(url) ~= "string" or #url == 0 then
		return false, "Invalid URL"
	end

	-- 1. Standard game:HttpGet via method call (__namecall)
	local ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(res) == "string" and #res > 0 then
		return true, res
	end

	-- 2. Direct game.HttpGet index call
	ok, res = pcall(game.HttpGet, game, url)
	if ok and type(res) == "string" and #res > 0 then
		return true, res
	end

	-- 3. Global HttpGet fallback
	if type(HttpGet) == "function" then
		ok, res = pcall(HttpGet, url)
		if ok and type(res) == "string" and #res > 0 then
			return true, res
		end
	end

	-- 4. Executor request / http_request fallback
	if type(requestFunc) == "function" then
		ok, res = pcall(requestFunc, { Url = url, Method = "GET" })
		if ok and type(res) == "table" and type(res.Body) == "string" and #res.Body > 0 then
			return true, res.Body
		end
	end

	return false, tostring(res or "Empty response")
end

-- Some executors have no task.cancel. Without it the thread is left to finish on its own.
local function cancelThread(thread)
	if thread and task and type(task.cancel) == "function" then
		pcall(task.cancel, thread)
	end
end

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url, timeout)
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = httpGet(url)
		if not fetchSuccess or type(fetchResult) ~= "string" or #fetchResult == 0 then
			if not fetchResult or #fetchResult == 0 then
				fetchResult = "Empty response"
			end
			success, result = false, fetchResult
			requestCompleted = true
			return
		end
		local content = fetchResult
		local execSuccess, execResult = pcall(function()
			local fn = loadstring(content)
			if fn then return fn() end
			return nil
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			warn("Request for " .. url .. " timed out after " .. tostring(timeout) .. " seconds")
			cancelThread(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	-- Wait for completion or timeout
	local startWait = os.clock()
	while not requestCompleted and (os.clock() - startWait) < (timeout + 1) do
		task.wait()
	end
	-- Cancel timeout thread if still running when request completes
	if type(timeoutThread) == "thread" then
		local okStatus, status = pcall(coroutine.status, timeoutThread)
		if okStatus and status ~= "dead" then
			cancelThread(timeoutThread)
		end
	else
		cancelThread(timeoutThread)
	end
	if not success then
		warn("Failed to process " .. tostring(url) .. ": " .. tostring(result))
	end
	if success then return result end
	return nil
end

local requestsDisabled = false
local analyticsOptOut = false -- the player set getgenv().RAYFIELD_ANALYTICS = false
local customAssetId = nil
if getgenv then
	local ok, result = pcall(function() return getgenv().DISABLE_RAYFIELD_REQUESTS end)
	if ok and result then requestsDisabled = true end
	local ok2, result2 = pcall(function() return getgenv().RAYFIELD_ASSET_ID end)
	if ok2 and type(result2) == "number" then customAssetId = result2 end
	local ok3, result3 = pcall(function() return getgenv().RAYFIELD_ANALYTICS end)
	if ok3 and result3 == false then analyticsOptOut = true end
end

local secureWarnings = {}
local customAssets = {}

local function secureNotify(wType, title, content)
	if secureWarnings[wType] then return end
	secureWarnings[wType] = true
	task.spawn(function()
		while not RayfieldLibrary or not RayfieldLibrary.Notify do task.wait(0.5) end
		RayfieldLibrary:Notify({
			Title = title,
			Content = content,
			Duration = 8,
		})
	end)
end
local InterfaceBuild = 'UU2NX'
local Release = "Build 1.758"
local RayfieldFolder = "Rayfield"
local ConfigurationFolder = RayfieldFolder .. "/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
	General = {
		-- if needs be in order just make getSetting(name)
		rayfieldOpen = { Type = 'bind', Value = 'K', Name = 'Rayfield Keybind' },
		-- buildwarnings
		-- rayfieldprompts

	},
	System = {
		usageAnalytics = {
			Type = 'toggle',
			Value = true,
			Name = 'Usage analytics',
			Description =
			'Sends anonymous counts of which parts of this window are used. Never your name, what you type or your messages. sirius.menu/privacy',
		},
	}
}

-- Settings that have been overridden by the developer. These will not be saved to the user's configuration file
-- Overridden settings always take precedence over settings in the configuration file, and are cleared if the user changes the setting in the UI
local overriddenSettings = {} -- For example, overriddenSettings["System.rayfieldOpen"] = "J"
local function overrideSetting(category, name, value)
	overriddenSettings[category .. "." .. name] = value
end

local function getSetting(category, name)
	if overriddenSettings[category .. "." .. name] ~= nil then
		return overriddenSettings[category .. "." .. name]
	elseif settingsTable[category][name] ~= nil then
		return settingsTable[category][name].Value
	end
end

-- If requests/analytics have been disabled by the developer or the player, set the user-facing
-- setting to false as well
if requestsDisabled or analyticsOptOut then
	overrideSetting("System", "usageAnalytics", false)
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')

-- Environment Check
local useStudio = (RunService and RunService:IsStudio()) or false

local settingsCreated = false
local settingsInitialized = false -- Whether the UI elements in the settings page have been set to the proper values


-- The function below provides a safe alternative for calling error-prone functions
-- Especially useful for filesystem function (writefile, makefolder, etc.)
local function callSafely(func, ...)
	if func then
		local success, result = pcall(func, ...)
		if not success then
			warn("Rayfield | Function failed with error: ", result)
			return false
		else
			return result
		end
	end
end

-- Ensures a folder exists by creating it if needed
local function ensureFolder(folderPath)
	if isfolder and not callSafely(isfolder, folderPath) then
		callSafely(makefolder, folderPath)
	end
end

-- Folder and file names a hub supplies go into paths under the executor's workspace, so they can't
-- be allowed to climb out of it. Removing a character can expose a new "..", so ".:./" is cleaned
-- of the character first and the dots after, repeating until nothing changes.
local function stripTraversal(text)
	local previous
	repeat
		previous = text
		text = string.gsub(text, "%.%.", "")
	until text == previous
	return text
end

-- Keeps "/" so a hub can still nest its folder, but never a leading one, a drive letter or "..".
local function sanitizeFolderName(value)
	local text = string.gsub(string.gsub(tostring(value), "\\", "/"), "[:%c]", "")
	text = string.gsub(stripTraversal(text), "/+", "/")
	return (string.gsub(text, "^/+", ""))
end

-- A single file name: no slashes of either kind, control characters or "..".
local function sanitizeFileName(value)
	local text = string.gsub(tostring(value), "[/\\%c]", "")
	return stripTraversal(text)
end

local function loadSettings()
	local file = nil

	local success, result = pcall(function()
		if callSafely(isfolder, RayfieldFolder) then
			if callSafely(isfile, RayfieldFolder .. '/settings' .. ConfigurationExtension) then
				file = callSafely(readfile, RayfieldFolder .. '/settings' .. ConfigurationExtension)
			end
		end

		-- for debug in studio
		if useStudio then
			file = [[
	{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Usage analytics","Element":{"Ext":true,"Name":"Usage analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
]]
		end

		if file then
			local decodeSuccess, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
			if decodeSuccess then
				file = decodedFile
			else
				file = {}
			end
		else
			file = {}
		end


		if not settingsCreated then
			return
		end

		-- Check if settings file has any entries
		if next(file) ~= nil then
			-- If it does, apply them
			for categoryName, categoryTable in pairs(file) do
				for settingName, setting in pairs(categoryTable) do
					local default = settingsTable[categoryName] and settingsTable[categoryName][settingName]
					if default then
						local settingType = typeof(default.Value)
						-- Make sure setting has the correct type
						if settingType == typeof(setting.Value) then
							default.Value = setting.Value
						else
							warn("Rayfield | Error parsing settings file. '" .. settingName ..
								"' must be a " .. settingType)
						end
					end
				end
			end
		end
		-- Apply the actual setting value to UI elements
		for categoryName, categoryTable in pairs(settingsTable) do
			for settingName, setting in pairs(categoryTable) do
				if setting.Element then
					setting.Element:Set(getSetting(categoryName, settingName))
				end
			end
		end
		settingsInitialized = true
	end)

	if not success then
		if writefile then
			warn('Rayfield had an issue accessing configuration saving capability.')
		end
	end
end

if debugX then
	warn('Now Loading Settings Configuration')
end

loadSettings()

if debugX then
	warn('Settings Loaded')
end

local ANALYTICS_TOKEN = "05de7f9fd320d3b8428cd1c77014a337b85b6c8efee2c5914f5ab5700c354b9a"

-- The reporter is fetched only at the moment it is about to be used, and only if the user hasn't
-- opted out and the developer hasn't set DISABLE_RAYFIELD_REQUESTS. Opting out means no request to
-- GitHub for it either, not just no event sent.
local reporter = nil
local reporterLoaded = false
local function loadReporter()
	if reporterLoaded then return reporter end
	reporterLoaded = true
	if requestsDisabled or useStudio then return nil end

	local fetchSuccess, fetchResult = httpGet(RAYFIELD_RAW .. "reporter.lua")
	if fetchSuccess and #fetchResult > 0 then
		local execSuccess, Analytics = pcall(function()
			local fn = loadstring(fetchResult)
			if fn then return fn() end
			return nil
		end)
		if execSuccess and Analytics then
			pcall(function()
				reporter = Analytics.new({
					url          = "https://rayfield-collect.sirius-software-ltd.workers.dev",
					token        = ANALYTICS_TOKEN,
					product_name = "Rayfield",
					category     = "UILibrary",
				})
			end)
		end
	end
	return reporter
end

-- Whether analytics may be sent right now. A saved opt-out is only known once the settings file has
-- been applied, so until then the answer is no; an executor that can't read files has nothing saved
-- to respect, so the default applies there, and getgenv().RAYFIELD_ANALYTICS = false is the
-- player's way to opt out.
local function analyticsAllowed()
	if requestsDisabled or analyticsOptOut or useStudio then return false end
	if not getSetting("System", "usageAnalytics") then return false end
	return settingsInitialized or not (isfile and readfile)
end

-- SIA (sia.lua) counts which parts of a window players use. Like the reporter it is
-- fetched at the pinned commit, and only once analytics are allowed. It starts as a window is
-- created, before the key system and the settings page, so until the settings page has applied
-- the saved file, the file itself is read for an opt-out.
local SIA_TOKEN = "sia_rayfield_bd0f30653a58a75bac2987e3"

local sia = nil
local siaState = "off" -- "loading" while sia.lua is fetched, then "on"
local siaQueue = {}    -- calls made while it loads, run in order once it has
local siaElements = {} -- every element made, registered whenever the client starts
local siaScript = nil  -- the window's script details, kept for a restart from settings
local siaLoads = 0     -- counts starts, so a load the player cancelled and restarted gives way

local function savedAnalyticsChoice()
	local ok, value = pcall(function()
		local path = RayfieldFolder .. "/settings" .. ConfigurationExtension
		if not (isfile and readfile and isfile(path)) then return nil end
		return HttpService:JSONDecode(readfile(path)).System.usageAnalytics.Value
	end)
	if ok and type(value) == "boolean" then return value end
	return nil
end

local function siaAllowed()
	if requestsDisabled or analyticsOptOut or useStudio then return false end
	if not getSetting("System", "usageAnalytics") then return false end
	return settingsInitialized or savedAnalyticsChoice() ~= false
end

-- Runs fn(client) now, after the client loads, or not at all when SIA is off.
local function siaRun(fn)
	if siaState == "on" and sia then
		pcall(fn, sia)
	elseif siaState == "loading" and #siaQueue < 500 then
		table.insert(siaQueue, fn)
	end
end

local function siaId(client, handle)
	handle.id = handle.id or client:element(handle.kind, handle.name, handle.tab)
	return handle.id
end

local function siaStart(info)
	siaScript = info
	if siaState ~= "off" or not siaAllowed() then return end
	siaState = "loading"
	siaLoads = siaLoads + 1
	local load = siaLoads
	task.spawn(function()
		local client = nil
		local fetched, source = httpGet(RAYFIELD_RAW .. "sia.lua")
		if fetched and type(source) == "string" and #source > 0 then
			pcall(function()
				local fn = loadstring(source)
				local SIA = fn and fn() or nil
				if SIA then
					client = SIA.new({
						token = SIA_TOKEN,
						lib = "gen1",
						libVersion = Release,
						script = info,
						theme = info
							.theme
					})
				end
			end)
		end
		-- the player may have turned it off while it loaded
		if load ~= siaLoads then return end
		if not client or siaState ~= "loading" then
			siaState, siaQueue = "off", {}
			return
		end
		sia, siaState = client, "on"
		for _, handle in ipairs(siaElements) do
			pcall(function()
				local id = siaId(client, handle)
				if handle.value then client:state(id, handle.value) end
			end)
		end
		local queued = siaQueue
		siaQueue = {}
		for _, fn in ipairs(queued) do
			pcall(fn, client)
		end
	end)
end

local function siaStop()
	if sia then pcall(sia.disable, sia) end
	sia, siaState, siaQueue = nil, "off", {}
end

local siaCurrentTab = nil -- the tab on show, whose elements count as seen as they're made

-- An element's handle, for siaUsed, siaSetState and siaError. The settings page is tab 0,
-- which is Rayfield's, not the script's. Labels stay on this side: the client sends a category
-- worked out from them.
local function siaElement(kind, name, tab)
	-- The Rayfield Settings page (no tab number) is tab 0: SIA keeps it apart from the script's tabs.
	tab = tab or 0
	local handle = { kind = kind, name = tostring(name), tab = tab }
	table.insert(siaElements, handle)
	siaRun(function(client)
		siaId(client, handle)
		if tab == siaCurrentTab then client:tab(tab) end
	end)
	return handle
end

-- A player used the element. value is 0..1 where the element has one.
local function siaUsed(handle, action, value)
	if not handle then return end
	siaRun(function(client) client:used(siaId(client, handle), action, value) end)
end

-- The element's value, from the player or the script: toggles 1 or 0, sliders 0..1.
local function siaSetState(handle, value)
	if not handle then return end
	handle.value = value -- for a client that starts later
	siaRun(function(client) client:state(siaId(client, handle), value) end)
end

local function siaError(handle)
	if not handle then return end
	siaRun(function(client) client:error(siaId(client, handle)) end)
end

local function siaCall(method, ...)
	local args = table.pack(...)
	siaRun(function(client) client[method](client, table.unpack(args, 1, args.n)) end)
end

if debugX then
	warn('Moving on to continue initialisation')
end

local RayfieldLibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),

			NotificationBackground = Color3.fromRGB(20, 20, 20),
			NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),

			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40),

			SliderBackground = Color3.fromRGB(50, 138, 220),
			SliderProgress = Color3.fromRGB(50, 138, 220),
			SliderStroke = Color3.fromRGB(58, 163, 255),

			ToggleBackground = Color3.fromRGB(30, 30, 30),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

			DropdownSelected = Color3.fromRGB(40, 40, 40),
			DropdownUnselected = Color3.fromRGB(30, 30, 30),

			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178)
		},

		Ocean = {
			TextColor = Color3.fromRGB(230, 240, 240),

			Background = Color3.fromRGB(20, 30, 30),
			Topbar = Color3.fromRGB(25, 40, 40),
			Shadow = Color3.fromRGB(15, 20, 20),

			NotificationBackground = Color3.fromRGB(25, 35, 35),
			NotificationActionsBackground = Color3.fromRGB(230, 240, 240),

			TabBackground = Color3.fromRGB(40, 60, 60),
			TabStroke = Color3.fromRGB(50, 70, 70),
			TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
			TabTextColor = Color3.fromRGB(210, 230, 230),
			SelectedTabTextColor = Color3.fromRGB(20, 50, 50),

			ElementBackground = Color3.fromRGB(30, 50, 50),
			ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
			SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
			ElementStroke = Color3.fromRGB(45, 70, 70),
			SecondaryElementStroke = Color3.fromRGB(40, 65, 65),

			SliderBackground = Color3.fromRGB(0, 110, 110),
			SliderProgress = Color3.fromRGB(0, 140, 140),
			SliderStroke = Color3.fromRGB(0, 160, 160),

			ToggleBackground = Color3.fromRGB(30, 50, 50),
			ToggleEnabled = Color3.fromRGB(0, 130, 130),
			ToggleDisabled = Color3.fromRGB(70, 90, 90),
			ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
			ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
			ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),

			DropdownSelected = Color3.fromRGB(30, 60, 60),
			DropdownUnselected = Color3.fromRGB(25, 40, 40),

			InputBackground = Color3.fromRGB(30, 50, 50),
			InputStroke = Color3.fromRGB(50, 70, 70),
			PlaceholderColor = Color3.fromRGB(140, 160, 160)
		},

		AmberGlow = {
			TextColor = Color3.fromRGB(255, 245, 230),

			Background = Color3.fromRGB(45, 30, 20),
			Topbar = Color3.fromRGB(55, 40, 25),
			Shadow = Color3.fromRGB(35, 25, 15),

			NotificationBackground = Color3.fromRGB(50, 35, 25),
			NotificationActionsBackground = Color3.fromRGB(245, 230, 215),

			TabBackground = Color3.fromRGB(75, 50, 35),
			TabStroke = Color3.fromRGB(90, 60, 45),
			TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
			TabTextColor = Color3.fromRGB(250, 220, 200),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 10),

			ElementBackground = Color3.fromRGB(60, 45, 35),
			ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
			SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
			ElementStroke = Color3.fromRGB(85, 60, 45),
			SecondaryElementStroke = Color3.fromRGB(75, 50, 35),

			SliderBackground = Color3.fromRGB(220, 130, 60),
			SliderProgress = Color3.fromRGB(250, 150, 75),
			SliderStroke = Color3.fromRGB(255, 170, 85),

			ToggleBackground = Color3.fromRGB(55, 40, 30),
			ToggleEnabled = Color3.fromRGB(240, 130, 30),
			ToggleDisabled = Color3.fromRGB(90, 70, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
			ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
			ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),

			DropdownSelected = Color3.fromRGB(70, 50, 40),
			DropdownUnselected = Color3.fromRGB(55, 40, 30),

			InputBackground = Color3.fromRGB(60, 45, 35),
			InputStroke = Color3.fromRGB(90, 65, 50),
			PlaceholderColor = Color3.fromRGB(190, 150, 130)
		},

		Light = {
			TextColor = Color3.fromRGB(40, 40, 40),

			Background = Color3.fromRGB(245, 245, 245),
			Topbar = Color3.fromRGB(230, 230, 230),
			Shadow = Color3.fromRGB(200, 200, 200),

			NotificationBackground = Color3.fromRGB(250, 250, 250),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 240),

			TabBackground = Color3.fromRGB(235, 235, 235),
			TabStroke = Color3.fromRGB(215, 215, 215),
			TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
			TabTextColor = Color3.fromRGB(80, 80, 80),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),

			ElementBackground = Color3.fromRGB(240, 240, 240),
			ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
			SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
			ElementStroke = Color3.fromRGB(210, 210, 210),
			SecondaryElementStroke = Color3.fromRGB(210, 210, 210),

			SliderBackground = Color3.fromRGB(150, 180, 220),
			SliderProgress = Color3.fromRGB(100, 150, 200),
			SliderStroke = Color3.fromRGB(120, 170, 220),

			ToggleBackground = Color3.fromRGB(220, 220, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(150, 150, 150),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),

			DropdownSelected = Color3.fromRGB(230, 230, 230),
			DropdownUnselected = Color3.fromRGB(220, 220, 220),

			InputBackground = Color3.fromRGB(240, 240, 240),
			InputStroke = Color3.fromRGB(180, 180, 180),
			PlaceholderColor = Color3.fromRGB(140, 140, 140)
		},

		Amethyst = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(30, 20, 40),
			Topbar = Color3.fromRGB(40, 25, 50),
			Shadow = Color3.fromRGB(20, 15, 30),

			NotificationBackground = Color3.fromRGB(35, 20, 40),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 250),

			TabBackground = Color3.fromRGB(60, 40, 80),
			TabStroke = Color3.fromRGB(70, 45, 90),
			TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
			TabTextColor = Color3.fromRGB(230, 230, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 20, 50),

			ElementBackground = Color3.fromRGB(45, 30, 60),
			ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
			SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
			ElementStroke = Color3.fromRGB(70, 50, 85),
			SecondaryElementStroke = Color3.fromRGB(65, 45, 80),

			SliderBackground = Color3.fromRGB(100, 60, 150),
			SliderProgress = Color3.fromRGB(130, 80, 180),
			SliderStroke = Color3.fromRGB(150, 100, 200),

			ToggleBackground = Color3.fromRGB(45, 30, 55),
			ToggleEnabled = Color3.fromRGB(120, 60, 150),
			ToggleDisabled = Color3.fromRGB(94, 47, 117),
			ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
			ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
			ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),

			DropdownSelected = Color3.fromRGB(50, 35, 70),
			DropdownUnselected = Color3.fromRGB(35, 25, 50),

			InputBackground = Color3.fromRGB(45, 30, 60),
			InputStroke = Color3.fromRGB(80, 50, 110),
			PlaceholderColor = Color3.fromRGB(178, 150, 200)
		},

		Green = {
			TextColor = Color3.fromRGB(30, 60, 30),

			Background = Color3.fromRGB(235, 245, 235),
			Topbar = Color3.fromRGB(210, 230, 210),
			Shadow = Color3.fromRGB(200, 220, 200),

			NotificationBackground = Color3.fromRGB(240, 250, 240),
			NotificationActionsBackground = Color3.fromRGB(220, 235, 220),

			TabBackground = Color3.fromRGB(215, 235, 215),
			TabStroke = Color3.fromRGB(190, 210, 190),
			TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
			TabTextColor = Color3.fromRGB(50, 80, 50),
			SelectedTabTextColor = Color3.fromRGB(20, 60, 20),

			ElementBackground = Color3.fromRGB(225, 240, 225),
			ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
			SecondaryElementBackground = Color3.fromRGB(235, 245, 235),
			ElementStroke = Color3.fromRGB(180, 200, 180),
			SecondaryElementStroke = Color3.fromRGB(180, 200, 180),

			SliderBackground = Color3.fromRGB(90, 160, 90),
			SliderProgress = Color3.fromRGB(70, 130, 70),
			SliderStroke = Color3.fromRGB(100, 180, 100),

			ToggleBackground = Color3.fromRGB(215, 235, 215),
			ToggleEnabled = Color3.fromRGB(60, 130, 60),
			ToggleDisabled = Color3.fromRGB(150, 175, 150),
			ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
			ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),

			DropdownSelected = Color3.fromRGB(225, 240, 225),
			DropdownUnselected = Color3.fromRGB(210, 225, 210),

			InputBackground = Color3.fromRGB(235, 245, 235),
			InputStroke = Color3.fromRGB(180, 200, 180),
			PlaceholderColor = Color3.fromRGB(120, 140, 120)
		},

		Bloom = {
			TextColor = Color3.fromRGB(60, 40, 50),

			Background = Color3.fromRGB(255, 240, 245),
			Topbar = Color3.fromRGB(250, 220, 225),
			Shadow = Color3.fromRGB(230, 190, 195),

			NotificationBackground = Color3.fromRGB(255, 235, 240),
			NotificationActionsBackground = Color3.fromRGB(245, 215, 225),

			TabBackground = Color3.fromRGB(240, 210, 220),
			TabStroke = Color3.fromRGB(230, 200, 210),
			TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
			TabTextColor = Color3.fromRGB(80, 40, 60),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 50),

			ElementBackground = Color3.fromRGB(255, 235, 240),
			ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 235, 240),
			ElementStroke = Color3.fromRGB(230, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(230, 200, 210),

			SliderBackground = Color3.fromRGB(240, 130, 160),
			SliderProgress = Color3.fromRGB(250, 160, 180),
			SliderStroke = Color3.fromRGB(255, 180, 200),

			ToggleBackground = Color3.fromRGB(240, 210, 220),
			ToggleEnabled = Color3.fromRGB(255, 140, 170),
			ToggleDisabled = Color3.fromRGB(200, 180, 185),
			ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
			ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),

			DropdownSelected = Color3.fromRGB(250, 220, 225),
			DropdownUnselected = Color3.fromRGB(240, 210, 220),

			InputBackground = Color3.fromRGB(255, 235, 240),
			InputStroke = Color3.fromRGB(220, 190, 200),
			PlaceholderColor = Color3.fromRGB(170, 130, 140)
		},

		DarkBlue = {
			TextColor = Color3.fromRGB(230, 230, 230),

			Background = Color3.fromRGB(20, 25, 30),
			Topbar = Color3.fromRGB(30, 35, 40),
			Shadow = Color3.fromRGB(15, 20, 25),

			NotificationBackground = Color3.fromRGB(25, 30, 35),
			NotificationActionsBackground = Color3.fromRGB(45, 50, 55),

			TabBackground = Color3.fromRGB(35, 40, 45),
			TabStroke = Color3.fromRGB(45, 50, 60),
			TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
			TabTextColor = Color3.fromRGB(200, 200, 200),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(30, 35, 40),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
			SecondaryElementBackground = Color3.fromRGB(35, 40, 45),
			ElementStroke = Color3.fromRGB(45, 50, 60),
			SecondaryElementStroke = Color3.fromRGB(40, 45, 55),

			SliderBackground = Color3.fromRGB(0, 90, 180),
			SliderProgress = Color3.fromRGB(0, 120, 210),
			SliderStroke = Color3.fromRGB(0, 150, 240),

			ToggleBackground = Color3.fromRGB(35, 40, 45),
			ToggleEnabled = Color3.fromRGB(0, 120, 210),
			ToggleDisabled = Color3.fromRGB(70, 70, 80),
			ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
			ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
			ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),

			DropdownSelected = Color3.fromRGB(30, 70, 90),
			DropdownUnselected = Color3.fromRGB(25, 30, 35),

			InputBackground = Color3.fromRGB(25, 30, 35),
			InputStroke = Color3.fromRGB(45, 50, 60),
			PlaceholderColor = Color3.fromRGB(150, 150, 160)
		},

		Serenity = {
			TextColor = Color3.fromRGB(50, 55, 60),
			Background = Color3.fromRGB(240, 245, 250),
			Topbar = Color3.fromRGB(215, 225, 235),
			Shadow = Color3.fromRGB(200, 210, 220),

			NotificationBackground = Color3.fromRGB(210, 220, 230),
			NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

			TabBackground = Color3.fromRGB(200, 210, 220),
			TabStroke = Color3.fromRGB(180, 190, 200),
			TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
			TabTextColor = Color3.fromRGB(50, 55, 60),
			SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

			ElementBackground = Color3.fromRGB(210, 220, 230),
			ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
			SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
			ElementStroke = Color3.fromRGB(190, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

			SliderBackground = Color3.fromRGB(200, 220, 235), -- Lighter shade
			SliderProgress = Color3.fromRGB(70, 130, 180),
			SliderStroke = Color3.fromRGB(150, 180, 220),

			ToggleBackground = Color3.fromRGB(210, 220, 230),
			ToggleEnabled = Color3.fromRGB(70, 160, 210),
			ToggleDisabled = Color3.fromRGB(180, 180, 180),
			ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
			ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

			DropdownSelected = Color3.fromRGB(220, 230, 240),
			DropdownUnselected = Color3.fromRGB(200, 210, 220),

			InputBackground = Color3.fromRGB(220, 230, 240),
			InputStroke = Color3.fromRGB(180, 190, 200),
			PlaceholderColor = Color3.fromRGB(150, 150, 150)
		},
	}
}




-- Interface Management

local function getSafeGuiParent()
	if useStudio and script and script.Parent then
		return script.Parent
	end
	if type(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then return hui end
	end
	if CoreGui then
		local ok, robloxGui = pcall(function()
			return CoreGui:FindFirstChild("RobloxGui")
		end)
		if ok and robloxGui then return robloxGui end
		local ok2, _ = pcall(function()
			return CoreGui.Name
		end)
		if ok2 then return CoreGui end
	end
	local lp = Players and Players.LocalPlayer
	if lp then
		local ok, playerGui = pcall(function()
			return lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
		end)
		if ok and playerGui then return playerGui end
	end
	return nil
end

local function parentGui(gui)
	if not gui then return end
	if not useStudio and syn and type(syn.protect_gui) == "function" then
		pcall(syn.protect_gui, gui)
	end
	local targetParent = getSafeGuiParent()
	if targetParent then
		local ok = pcall(function()
			gui.Parent = targetParent
		end)
		if ok then return end
	end
	local lp = Players and Players.LocalPlayer
	if lp then
		pcall(function()
			gui.Parent = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
		end)
	end
end

local function loadGuiAsset(assetId)
	if useStudio and script and script.Parent then
		local found = script.Parent:FindFirstChild("Rayfield")
		if found then return found end
	end
	local uri = "rbxassetid://" .. tostring(assetId)
	local ok, objects = pcall(game.GetObjects, game, uri)
	if ok and type(objects) == "table" and objects[1] then
		return objects[1]
	end
	return nil
end

local RayfieldAssetId = customAssetId or 10804731440
local Rayfield = loadGuiAsset(RayfieldAssetId)
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false -- True when RayfieldLibrary:Destroy() is called

repeat
	if Rayfield and Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version (' ..
			((Rayfield and Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..
			').\n\nThis version of Rayfield is intended for interface build ' .. InterfaceBuild .. '.')
		warned = true
	end

	local toDestroy = Rayfield
	Rayfield = loadGuiAsset(RayfieldAssetId)
	if toDestroy and not useStudio then pcall(function() toDestroy:Destroy() end) end

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

Rayfield.Enabled = false
parentGui(Rayfield)

-- Running a script again loads a second copy of Rayfield. The copy it replaces is torn down through
-- this event, which calls its Destroy: that removes its interface and disconnects its input
-- listeners, which would otherwise keep answering hotkeys for a window nobody can see. Builds
-- before 1.753 have no event, so those are only hidden and renamed, as before.
local TEARDOWN_EVENT = "RayfieldTeardown"

local function retireInterface(Interface)
	pcall(function()
		Interface.Enabled = false
		Interface.Name = "Rayfield-Old"
		local teardown = Interface:FindFirstChild(TEARDOWN_EVENT)
		if teardown and teardown:IsA("BindableEvent") then
			teardown:Fire()
		end
	end)
end

do
	local parentContainer = Rayfield.Parent
	if parentContainer then
		pcall(function()
			for _, Interface in ipairs(parentContainer:GetChildren()) do
				if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
					retireInterface(Interface)
				end
			end
		end)
	end
end

do
	local teardown = Instance.new("BindableEvent")
	teardown.Name = TEARDOWN_EVENT
	teardown.Event:Connect(function()
		if not rayfieldDestroyed and type(RayfieldLibrary.Destroy) == "function" then
			RayfieldLibrary:Destroy()
		end
	end)
	teardown.Parent = Rayfield
end

if secureMode and not customAssetId then
	secureNotify("default_asset", "Secure Mode",
		"You are using the default Rayfield asset ID. Set RAYFIELD_ASSET_ID to a custom upload to avoid detection.")
end

do
	local AssetPath = RayfieldFolder .. "/Assets"
	local AssetBaseURL = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/assets/"

	local assetFiles = {
		["111263549366178"] = AssetBaseURL .. "111263549366178.png",
		["77891951053543"] = AssetBaseURL .. "77891951053543.png",
		["78137979054938"] = AssetBaseURL .. "78137979054938.png",
		["80503127983237"] = AssetBaseURL .. "80503127983237.png",
		["10137832201"] = AssetBaseURL .. "10137832201.png",
		["10137941941"] = AssetBaseURL .. "10137941941.png",
		["11036884234"] = AssetBaseURL .. "11036884234.png",
		["11413591840"] = AssetBaseURL .. "11413591840.png",
		["11745872910"] = AssetBaseURL .. "11745872910.png",
		["12577727209"] = AssetBaseURL .. "12577727209.png",
		["18458939117"] = AssetBaseURL .. "18458939117.png",
		["3259050989"] = AssetBaseURL .. "3259050989.png",
		["3523728077"] = AssetBaseURL .. "3523728077.png",
		["3602733521"] = AssetBaseURL .. "3602733521.png",
		["IconChevronTopMedium"] = AssetBaseURL .. "IconChevronTopMedium.png",
		["4483362458"] = AssetBaseURL .. "4483362458.png",
		["5587865193"] = AssetBaseURL .. "5587865193.png",
		["IconMagnifyingGlass2"] = AssetBaseURL .. "IconMagnifyingGlass2.png",
	}

	for id, _ in pairs(assetFiles) do
		if not secureMode and tonumber(id) then
			customAssets[tostring(id)] = "rbxassetid://" .. tostring(id)
		else
			customAssets[tostring(id)] = ""
		end
	end

	local hasCustomAsset = type(customAssetFunc) == "function"
	local hasFilesystem = type(writefile) == "function" and type(makefolder) == "function" and type(isfile) == "function" and
		type(isfolder) == "function" and type(readfile) == "function"

	local function isValidPng(data)
		return type(data) == "string" and #data > 8 and string.sub(data, 1, 4) == "\137PNG"
	end

	-- Only block/download custom PNGs in secureMode; in normal mode on Delta/Mobile/PC executors,
	-- the prefab's built-in rbxassetid:// textures work immediately without binary corruption or startup delay.
	if secureMode and hasCustomAsset and hasFilesystem then
		local ok, err = pcall(function()
			ensureFolder(RayfieldFolder)
			ensureFolder(AssetPath)

			local pending = 0
			for id, url in pairs(assetFiles) do
				local filePath = AssetPath .. "/" .. tostring(id) .. ".png"
				local existingOk = callSafely(isfile, filePath) and isValidPng(callSafely(readfile, filePath))
				if not existingOk then
					pending = pending + 1
					task.spawn(function()
						local fetched, body = httpGet(url)
						if fetched and isValidPng(body) then
							pcall(writefile, filePath, body)
						end
						pending = pending - 1
					end)
				end
			end

			local waitStart = os.clock()
			while pending > 0 and (os.clock() - waitStart) < 5 do
				task.wait(0.05)
			end

			for id, _ in pairs(assetFiles) do
				local filePath = AssetPath .. "/" .. tostring(id) .. ".png"
				if callSafely(isfile, filePath) and isValidPng(callSafely(readfile, filePath)) then
					local success, asset = pcall(customAssetFunc, filePath)
					if success and type(asset) == "string" and #asset > 0 then
						customAssets[tostring(id)] = asset
					end
				end
			end
		end)

		if not ok then
			warn("Rayfield | Failed to load custom assets: " .. tostring(err))
			if secureMode then
				secureNotify("asset_load_fail", "Rayfield",
					"Failed to load custom assets. UI images may not display correctly.")
			end
		end
	elseif secureMode then
		secureNotify("no_getcustomasset", "Rayfield",
			"Your executor does not support getcustomasset. Some UI images may not render correctly.")
	end

	local function applyCustomAsset(imageObject, key, resetRect)
		if not imageObject then return end
		local asset = customAssets[tostring(key)]
		if asset and asset ~= "" then
			imageObject.Image = asset
			if resetRect then
				imageObject.ImageRectOffset = Vector2.new(0, 0)
				imageObject.ImageRectSize = Vector2.new(0, 0)
			end
		elseif secureMode then
			imageObject.Image = ""
		end
	end

	applyCustomAsset(Rayfield.Main.Shadow.Image, 5587865193)
	applyCustomAsset(Rayfield.Main.Topbar.Hide, 10137832201)
	applyCustomAsset(Rayfield.Main.Topbar.ChangeSize, 10137941941)
	applyCustomAsset(Rayfield.Main.Topbar.Settings, 80503127983237)
	applyCustomAsset(Rayfield.Main.Topbar.Icon, 78137979054938)
	applyCustomAsset(Rayfield.Main.Topbar.Search, "IconMagnifyingGlass2", true)
	applyCustomAsset(Rayfield.Main.Elements.Template.Toggle.Switch.Shadow, 3602733521)
	applyCustomAsset(Rayfield.Main.Elements.Template.Slider.Main.Shadow, 3602733521)
	applyCustomAsset(Rayfield.Main.Elements.Template.Dropdown.Toggle, "IconChevronTopMedium", true)
	applyCustomAsset(Rayfield.Main.Elements.Template.Label.Icon, 11745872910)
	applyCustomAsset(Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP, 11413591840)
	applyCustomAsset(Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP.MainPoint, 3259050989)
	applyCustomAsset(Rayfield.Main.Elements.Template.ColorPicker.ColorSlider.SliderPoint, 3259050989)
	applyCustomAsset(Rayfield.Main.TabList.Template.Image, 4483362458)
	applyCustomAsset(Rayfield.Main.Search.Search, 18458939117)
	applyCustomAsset(Rayfield.Main.Search.Shadow, 5587865193)
	applyCustomAsset(Rayfield.Notifications.Template.Icon, 77891951053543)
	applyCustomAsset(Rayfield.Notifications.Template.Shadow, 3523728077)
	applyCustomAsset(Rayfield.Loading.Banner, 111263549366178)
end -- custom asset block

local minSize = Vector2.new(1024, 680)
local function getViewportSize()
	local cam = Workspace and Workspace.CurrentCamera
	if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
		return cam.ViewportSize
	end
	if Rayfield.AbsoluteSize.X > 0 and Rayfield.AbsoluteSize.Y > 0 then
		return Rayfield.AbsoluteSize
	end
	return Vector2.new(1920, 1080)
end

local viewportSize = getViewportSize()
local isMobileDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local useMobileSizing = isMobileDevice or viewportSize.X < minSize.X or viewportSize.Y < minSize.Y
local useMobilePrompt = UserInputService.TouchEnabled


-- Object Variables

local Main = Rayfield.Main
local MPrompt = Rayfield:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil

local dragOffset = 255
local dragOffsetMobile = 150

-- Responsive UIScale so the window fits on any mobile phone, tablet, emulator, or PC resolution
local mainUIScale = Main:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
mainUIScale.Parent = Main

local function updateResponsiveScale()
	local vp = getViewportSize()
	local mobileMode = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or vp.X < minSize.X or
		vp.Y < minSize.Y
	useMobileSizing = mobileMode
	local targetW = 520
	local targetH = mobileMode and 330 or 530
	local scaleX = vp.X / targetW
	local scaleY = vp.Y / targetH
	local scale = math.clamp(math.min(scaleX, scaleY, 1), 0.55, 1)
	mainUIScale.Scale = scale
end

updateResponsiveScale()
if Workspace and Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
end
if Workspace then
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		if Workspace.CurrentCamera then
			Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
			updateResponsiveScale()
		end
	end)
end

-- Enable smooth touch & mouse wheel horizontal scrolling on TabList
if TabList and TabList:IsA("ScrollingFrame") then
	TabList.ScrollingEnabled = true
	TabList.ScrollingDirection = Enum.ScrollingDirection.X
	TabList.AutomaticCanvasSize = Enum.AutomaticSize.X
end

Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release

-- Thanks to Latte Softworks for the Lucide integration for Roblox
local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout(RAYFIELD_RAW .. 'icons.lua')
if type(Icons) ~= "table" then Icons = nil end
-- Variables

local CFileName = nil
local CLegacyFileName = nil -- the place-only file name configs had before Build 1.753, read as a fallback
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local Notifications = Rayfield.Notifications
local keybindConnections = {} -- For storing keybind connections to disconnect when Rayfield is destroyed

local SelectedTheme = RayfieldLibrary.Theme.Default

local function ChangeTheme(Theme)
	if typeof(Theme) == 'string' then
		SelectedTheme = RayfieldLibrary.Theme[Theme]
	elseif typeof(Theme) == 'table' then
		SelectedTheme = Theme
	end

	Rayfield.Main.BackgroundColor3 = SelectedTheme.Background
	Rayfield.Main.Topbar.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Topbar.CornerRepair.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Shadow.Image.ImageColor3 = SelectedTheme.Shadow

	Rayfield.Main.Topbar.ChangeSize.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Hide.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Search.ImageColor3 = SelectedTheme.TextColor
	if Topbar:FindFirstChild('Settings') then
		Rayfield.Main.Topbar.Settings.ImageColor3 = SelectedTheme.TextColor
		Rayfield.Main.Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	end

	Main.Search.BackgroundColor3 = SelectedTheme.TextColor
	Main.Search.Shadow.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Search.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Input.PlaceholderColor3 = SelectedTheme.TextColor
	Main.Search.UIStroke.Color = SelectedTheme.SecondaryElementStroke

	if Main:FindFirstChild('Notice') then
		Main.Notice.BackgroundColor3 = SelectedTheme.Background
	end

	for _, text in ipairs(Rayfield:GetDescendants()) do
		if text.Parent.Parent ~= Notifications then
			if text:IsA('TextLabel') or text:IsA('TextBox') then text.TextColor3 = SelectedTheme.TextColor end
		end
	end

	for _, TabPage in ipairs(Elements:GetChildren()) do
		for _, Element in ipairs(TabPage:GetChildren()) do
			if Element.ClassName == "Frame" and Element.Name ~= "Placeholder" and Element.Name ~= "SectionSpacing" and Element.Name ~= "Divider" and Element.Name ~= "SectionTitle" and Element.Name ~= "SearchTitle-fsefsefesfsefesfesfThanks" then
				Element.BackgroundColor3 = SelectedTheme.ElementBackground
				Element.UIStroke.Color = SelectedTheme.ElementStroke
			end
		end
	end
end

local function getIcon(name)
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name = string.match(string.lower(name), "^%s*(.*)%s*$")
	local sizedicons = Icons['48px']
	local r = sizedicons[name]
	if not r then
		error("Lucide Icons: Failed to find icon by the name of \"" .. name .. "\"", 2)
	end

	local rirs = r[2]
	local riro = r[3]

	if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
		error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
	end

	local irs = Vector2.new(rirs[1], rirs[2])
	local iro = Vector2.new(riro[1], riro[2])

	local asset = {
		id = r[1],
		imageRectSize = irs,
		imageRectOffset = iro,
	}

	return asset
end
local function getAssetUri(id)
	local assetUri = ""
	if type(id) == "number" then
		assetUri = "rbxassetid://" .. id
	elseif type(id) == "string" and not Icons then
		warn("Rayfield | Cannot use Lucide icons as icons library is not loaded")
	else
		warn("Rayfield | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
	end
	return assetUri
end

local function isCustomAsset(value)
	return type(value) == "string" and (string.find(value, "rbxasset://") == 1 or string.find(value, "rbxthumb://") == 1)
end

local function resolveIcon(icon)
	if not icon or icon == 0 then
		return "", nil, nil
	end

	if isCustomAsset(icon) then
		return icon, nil, nil
	end

	if secureMode then
		secureNotify("icon_blocked", "Secure Mode",
			"Element icons using asset IDs or Lucide names are blocked. Use getcustomasset() for icons to stay undetected.")
		return "", nil, nil
	end

	if typeof(icon) == "string" and Icons then
		local ok, asset = pcall(getIcon, icon)
		if ok and asset then
			return "rbxassetid://" .. asset.id, asset.imageRectOffset, asset.imageRectSize
		end
		return "", nil, nil
	else
		return getAssetUri(icon), nil, nil
	end
end

local function getGuiInsetOffset(object)
	local screenGui = object and object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset and GuiService then
		local ok, inset = pcall(GuiService.GetGuiInset, GuiService)
		if ok and inset then
			return inset
		end
	end
	return Vector2.zero
end

local function getPointerPosition(inputObj)
	if inputObj and inputObj.UserInputType == Enum.UserInputType.Touch then
		local inset = GuiService and select(2, pcall(GuiService.GetGuiInset, GuiService)) or Vector2.zero
		if typeof(inset) ~= "Vector2" then inset = Vector2.zero end
		return Vector2.new(inputObj.Position.X, inputObj.Position.Y) + inset
	end
	return UserInputService:GetMouseLocation()
end

local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
	if not object or not dragObject then return end
	local dragging = false
	local activeInput = nil
	local relative = Vector2.zero

	local offset = getGuiInsetOffset(object)

	local function getScaledDragOffset()
		if not tapticOffset then return 0 end
		local baseOffset = (useMobileSizing and tapticOffset[2]) or tapticOffset[1]
		local scale = mainUIScale and mainUIScale.Scale or 1
		return baseOffset * scale
	end

	local function connectFunctions()
		if dragBar and enableTaptic then
			dragBar.MouseEnter:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4) }):Play()
				end
			end)

			dragBar.MouseLeave:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4) }):Play()
				end
			end)
		end
	end

	connectFunctions()

	dragObject.InputBegan:Connect(function(input, processed)
		if processed then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = true
			activeInput = input
			offset = getGuiInsetOffset(object)

			local pointerPos = getPointerPosition(input)
			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - pointerPos
			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0 }):Play()
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end

		local inputType = input.UserInputType.Name
		if input == activeInput or inputType == "MouseButton1" or (inputType == "Touch" and activeInput == nil) then
			dragging = false
			activeInput = nil

			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7 }):Play()
			end
		end
	end)

	local renderStepped = RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local pointerPos = getPointerPosition(activeInput)
			local position = pointerPos + relative + offset
			local vp = getViewportSize()
			position = Vector2.new(
				math.clamp(position.X, 40, math.max(40, vp.X - 40)),
				math.clamp(position.Y, 30, math.max(30, vp.Y - 30))
			)
			local currentDragOffset = getScaledDragOffset()
			if enableTaptic and tapticOffset then
				TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{ Position = UDim2.fromOffset(position.X, position.Y) }):Play()
				TweenService:Create(dragObject.Parent,
					TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{ Position = UDim2.fromOffset(position.X, position.Y + currentDragOffset) }):Play()
			else
				if dragBar and tapticOffset then
					dragBar.Position = UDim2.fromOffset(position.X, position.Y + currentDragOffset)
				end
				object.Position = UDim2.fromOffset(position.X, position.Y)
			end
		end
	end)

	object.Destroying:Connect(function()
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end


local function PackColor(Color)
	return { R = Color.R * 255, G = Color.G * 255, B = Color.B * 255 }
end

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadConfiguration(Configuration)
	local success, Data = pcall(function() return HttpService:JSONDecode(Configuration) end)
	local changed

	if not success then
		warn('Rayfield had an issue decoding the configuration file, please try delete the file and reopen Rayfield.')
		return
	end

	-- Iterate through current UI elements' flags
	for FlagName, Flag in pairs(RayfieldLibrary.Flags) do
		local FlagValue = Data[FlagName]

		if (typeof(FlagValue) == 'boolean' and FlagValue == false) or FlagValue then
			task.spawn(function()
				if Flag.Type == "ColorPicker" then
					changed = true
					Flag:Set(UnpackColor(FlagValue))
				else
					if (Flag.CurrentValue or Flag.CurrentKeybind or Flag.CurrentOption or Flag.Color) ~= FlagValue then
						changed = true
						Flag:Set(FlagValue)
					end
				end
			end)
		else
			warn("Rayfield | Unable to find '" .. FlagName .. "' in the save file.")
			print("The error above may not be an issue if new elements have been added or not been set values.")
			--RayfieldLibrary:Notify({Title = "Rayfield Flags", Content = "Rayfield was unable to find '"..FlagName.. "' in the save file. Check sirius.menu/discord for help.", Image = 3944688398})
		end
	end

	return changed
end

local function SaveConfiguration()
	if not CEnabled or not globalLoaded then return end

	if debugX then
		print('Saving')
	end

	local Data = {}
	for i, v in pairs(RayfieldLibrary.Flags) do
		if v.Type == "ColorPicker" then
			Data[i] = PackColor(v.Color)
		else
			if typeof(v.CurrentValue) == 'boolean' then
				if v.CurrentValue == false then
					Data[i] = false
				else
					Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
				end
			else
				Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
			end
		end
	end

	if useStudio then
		if script.Parent:FindFirstChild('configuration') then script.Parent.configuration:Destroy() end

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Parent = script.Parent
		ScreenGui.Name = 'configuration'

		local TextBox = Instance.new("TextBox")
		TextBox.Parent = ScreenGui
		TextBox.Size = UDim2.new(0, 800, 0, 50)
		TextBox.AnchorPoint = Vector2.new(0.5, 0)
		TextBox.Position = UDim2.new(0.5, 0, 0, 30)
		TextBox.Text = HttpService:JSONEncode(Data)
		TextBox.ClearTextOnFocus = false
	end

	if debugX then
		warn(HttpService:JSONEncode(Data))
	end


	callSafely(writefile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension,
		tostring(HttpService:JSONEncode(Data)))
end

function RayfieldLibrary:Notify(data) -- action e.g open messages
	-- a destroyed interface has no template left to clone
	if rayfieldDestroyed then return end
	task.spawn(function()
		-- Notification Object Creation
		local newNotification = Notifications.Template:Clone()
		newNotification.Name = data.Title or 'No Title Provided'
		newNotification.Parent = Notifications
		newNotification.LayoutOrder = #Notifications:GetChildren()
		newNotification.Visible = false

		-- Set Data
		newNotification.Title.Text = data.Title or "Unknown Title"
		newNotification.Description.Text = data.Content or "Unknown Content"

		if data.Image then
			local img, rectOffset, rectSize = resolveIcon(data.Image)
			newNotification.Icon.Image = img
			if rectOffset then newNotification.Icon.ImageRectOffset = rectOffset end
			if rectSize then newNotification.Icon.ImageRectSize = rectSize end
		else
			newNotification.Icon.Image = ""
		end

		-- Set initial transparency values

		newNotification.Title.TextColor3 = SelectedTheme.TextColor
		newNotification.Description.TextColor3 = SelectedTheme.TextColor
		newNotification.BackgroundColor3 = SelectedTheme.Background
		newNotification.UIStroke.Color = SelectedTheme.TextColor
		newNotification.Icon.ImageColor3 = SelectedTheme.TextColor

		newNotification.BackgroundTransparency = 1
		newNotification.Title.TextTransparency = 1
		newNotification.Description.TextTransparency = 1
		newNotification.UIStroke.Transparency = 1
		newNotification.Shadow.ImageTransparency = 1
		newNotification.Size = UDim2.new(1, 0, 0, 800)
		newNotification.Icon.ImageTransparency = 1
		newNotification.Icon.BackgroundTransparency = 1

		task.wait()

		newNotification.Visible = true

		if data.Actions then
			warn('Rayfield | Not seeing your actions in notifications?')
			print(
				"Notification Actions are being sunset for now, keep up to date on when they're back in the discord. (sirius.menu/discord)")
		end

		-- Calculate textbounds and set initial values
		local bounds = { newNotification.Title.TextBounds.Y, newNotification.Description.TextBounds.Y }
		newNotification.Size = UDim2.new(1, -60, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)

		newNotification.Icon.Size = UDim2.new(0, 32, 0, 32)
		newNotification.Icon.Position = UDim2.new(0, 20, 0.5, 0)

		TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
			{ Size = UDim2.new(1, 0, 0, math.max(bounds[1] + bounds[2] + 31, 60)) }):Play()

		task.wait(0.15)
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
			{ BackgroundTransparency = 0.45 }):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
			{ TextTransparency = 0 }):Play()

		task.wait(0.05)

		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 0 }):Play()

		task.wait(0.05)
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
			{ TextTransparency = 0.35 }):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
			{ Transparency = 0.95 }):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 0.82 }):Play()

		local waitDuration = math.min(math.max((#newNotification.Description.Text * 0.1) + 2.5, 3), 10)
		task.wait(data.Duration or waitDuration)

		newNotification.Icon.Visible = false
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
			{ BackgroundTransparency = 1 }):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
			{ Transparency = 1 }):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 1 }):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
			{ TextTransparency = 1 }):Play()
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
			{ TextTransparency = 1 }):Play()

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential),
			{ Size = UDim2.new(1, -90, 0, 0) }):Play()

		task.wait(1)

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential),
			{ Size = UDim2.new(1, -90, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset) }):Play()

		newNotification.Visible = false
		newNotification:Destroy()
	end)
end

local function openSearch()
	searchOpen = true

	Main.Search.BackgroundTransparency = 1
	Main.Search.Shadow.ImageTransparency = 1
	Main.Search.Input.TextTransparency = 1
	Main.Search.Search.ImageTransparency = 1
	Main.Search.UIStroke.Transparency = 1
	Main.Search.Size = UDim2.new(1, 0, 0, 80)
	Main.Search.Position = UDim2.new(0.5, 0, 0, 70)

	Main.Search.Input.Interactable = true

	Main.Search.Visible = true

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = false
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
				:Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
				:Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
				:Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 1 })
				:Play()
		end
	end

	Main.Search.Input:CaptureFocus()
	TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), { ImageTransparency = 0.95 })
		:Play()
	TweenService:Create(Main.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
		{ Position = UDim2.new(0.5, 0, 0, 57), BackgroundTransparency = 0.9 }):Play()
	TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 0.8 })
		:Play()
	TweenService:Create(Main.Search.Input, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { TextTransparency = 0.2 })
		:Play()
	TweenService:Create(Main.Search.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { ImageTransparency = 0.5 })
		:Play()
	TweenService:Create(Main.Search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ Size = UDim2.new(1, -35, 0, 35) })
		:Play()
end

local function closeSearch()
	searchOpen = false

	TweenService:Create(Main.Search, TweenInfo.new(0.35, Enum.EasingStyle.Quint),
		{ BackgroundTransparency = 1, Size = UDim2.new(1, -55, 0, 30) }):Play()
	TweenService:Create(Main.Search.Search, TweenInfo.new(0.15, Enum.EasingStyle.Quint), { ImageTransparency = 1 }):Play()
	TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), { ImageTransparency = 1 }):Play()
	TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), { Transparency = 1 }):Play()
	TweenService:Create(Main.Search.Input, TweenInfo.new(0.15, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = true
			if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ BackgroundTransparency = 0 }):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ ImageTransparency = 0 }):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ TextTransparency = 0 }):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ Transparency = 1 })
					:Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ BackgroundTransparency = 0.7 }):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ ImageTransparency = 0.2 }):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ TextTransparency = 0.2 }):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ Transparency = 0.5 }):Play()
			end
		end
	end

	Main.Search.Input.Text = ''
	Main.Search.Input.Interactable = false
end

-- Sets element visibility across all tab pages (used by Hide, Unhide, Maximise, Minimise)
local function setElementsVisible(show)
	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ TextTransparency = show and 0.4 or 1 }):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = show and 0.85 or 1 }):Play()
						else
							local bgTarget = element:GetAttribute("BackgroundTransparencyTarget") or 0
							local strokeTarget = element:GetAttribute("UIStrokeTransparencyTarget") or 0
							local titleTarget = element:GetAttribute("TitleTextTransparencyTarget") or 0
							TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = show and bgTarget or 1 }):Play()
							TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ Transparency = show and strokeTarget or 1 }):Play()
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ TextTransparency = show and titleTarget or 1 }):Play()
						end
						for _, child in ipairs(element:GetChildren()) do
							if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
								child.Visible = show
							end
						end
					end
				end
			end
		end
	end
end

-- Sets tab button visibility (used by Hide, Unhide, Maximise, Minimise)
local function setTabButtonsVisible(show)
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			if show then
				if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
					TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }):Play()
					TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }):Play()
					TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0 }):Play()
					TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
				else
					TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.7 }):Play()
					TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.2 }):Play()
					TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0.2 }):Play()
					TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ Transparency = 0.5 }):Play()
				end
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ BackgroundTransparency = 1 }):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ TextTransparency = 1 }):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ ImageTransparency = 1 }):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
					{ Transparency = 1 })
					:Play()
			end
		end
	end
end

local function Hide(notify)
	siaCall("window", "minimise")
	if MPrompt then
		MPrompt.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		MPrompt.Position = UDim2.new(0.5, 0, 0, -50)
		MPrompt.Size = UDim2.new(0, 40, 0, 10)
		MPrompt.BackgroundTransparency = 1
		MPrompt.Title.TextTransparency = 1
		MPrompt.Visible = true
	end

	task.spawn(closeSearch)

	Debounce = true
	if notify then
		if useMobilePrompt then
			RayfieldLibrary:Notify({
				Title = "Interface Hidden",
				Content =
				"The interface has been hidden, you can unhide the interface by tapping 'Show'.",
				Duration = 7,
				Image = 4400697855
			})
		else
			RayfieldLibrary:Notify({
				Title = "Interface Hidden",
				Content =
					"The interface has been hidden, you can unhide the interface by tapping " ..
					tostring(getSetting("General", "rayfieldOpen")) .. ".",
				Duration = 7,
				Image = 4400697855
			})
		end
	end

	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 470, 0, 0) }):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ Size = UDim2.new(0, 470, 0, 45) })
		:Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
		:Play()
	TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ BackgroundTransparency = 1 }):Play()
	TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
		{ BackgroundTransparency = 1 }):Play()
	TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
		:Play()
	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
	if dragBarCosmetic then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }):Play()
	end

	if MPrompt then
		TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
			{ Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 0.3 }):Play()
		TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0.3 })
			:Play()
	end

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			TweenService:Create(TopbarButton, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
				:Play()
		end
	end

	setTabButtonsVisible(false)

	if dragInteract then dragInteract.Visible = false end

	setElementsVisible(false)

	task.wait(0.5)
	Main.Visible = false
	Debounce = false
end

local function getCurrentDragOffset()
	local base = useMobileSizing and dragOffsetMobile or dragOffset
	local scale = mainUIScale and mainUIScale.Scale or 1
	return math.floor(base * scale + 0.5)
end

local function Maximise()
	siaCall("window", "restore")
	Debounce = true
	Topbar.ChangeSize.Image = customAssets[tostring(10137941941)]

	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0.6 })
		:Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ BackgroundTransparency = 0 }):Play()
	TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
		:Play()
	if dragBarCosmetic then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.7 }):Play()
	end
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475) }):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 500, 0, 45) })
		:Play()
	TabList.Visible = true
	task.wait(0.2)

	Elements.Visible = true

	setElementsVisible(true)

	task.wait(0.1)

	setTabButtonsVisible(true)

	task.wait(0.5)
	Debounce = false
end


local function Unhide()
	siaCall("window", "restore")
	Debounce = true
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Visible = true
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475) }):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ Size = UDim2.new(0, 500, 0, 45) })
		:Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { ImageTransparency = 0.6 })
		:Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
		:Play()
	TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ BackgroundTransparency = 0 }):Play()
	TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ BackgroundTransparency = 0 }):Play()
	TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		:Play()

	if MPrompt then
		TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
			{ Size = UDim2.new(0, 40, 0, 10), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1 }):Play()
		TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
			:Play()

		task.spawn(function()
			task.wait(0.5)
			MPrompt.Visible = false
		end)
	end

	if Minimised then
		task.spawn(Maximise)
	end

	if dragBar then
		dragBar.Position = UDim2.new(0.5, 0, 0.5, getCurrentDragOffset())
	end

	if dragInteract then
		dragInteract.Visible = true
	end

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			if TopbarButton.Name == 'Icon' then
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
					{ ImageTransparency = 0 }):Play()
			else
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
					{ ImageTransparency = 0.8 }):Play()
			end
		end
	end

	setTabButtonsVisible(true)

	setElementsVisible(true)

	if dragBarCosmetic then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.5 }):Play()
	end

	task.wait(0.5)
	Minimised = false
	Debounce = false
end

local function Minimise()
	siaCall("window", "minimise")
	Debounce = true
	Topbar.ChangeSize.Image = customAssets[tostring(11036884234)]

	Topbar.UIStroke.Color = SelectedTheme.ElementStroke

	task.spawn(closeSearch)

	setTabButtonsVisible(false)

	setElementsVisible(false)

	if dragBarCosmetic then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }):Play()
	end
	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Transparency = 0 }):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
		:Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ BackgroundTransparency = 1 }):Play()
	TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
		:Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 495, 0, 45) })
		:Play()
	TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 495, 0, 45) })
		:Play()

	task.wait(0.3)

	Elements.Visible = false
	TabList.Visible = false

	task.wait(0.2)
	Debounce = false
end

local function saveSettings() -- Save settings to config file
	local encoded
	local success, err = pcall(function()
		encoded = HttpService:JSONEncode(settingsTable)
	end)

	if success then
		if useStudio then
			if script.Parent['get.val'] then
				script.Parent['get.val'].Value = encoded
			end
		end
		callSafely(writefile, RayfieldFolder .. '/settings' .. ConfigurationExtension, encoded)
	end
end

local function updateSetting(category, setting, value)
	if not settingsInitialized then
		return
	end
	settingsTable[category][setting].Value = value
	overriddenSettings[category .. "." .. setting] = nil -- If user changes an overriden setting, remove the override
	saveSettings()

	-- Turning analytics off mid-session also stops anything already armed, like the kick watcher.
	if category == "System" and setting == "usageAnalytics" and not value and reporter and reporter.disable then
		pcall(reporter.disable, reporter)
	end
	if category == "System" and setting == "usageAnalytics" then
		if value then
			if siaScript then siaStart(siaScript) end
		else
			siaStop()
		end
	end
end

local function createSettings(window)
	if not (writefile and isfile and readfile and isfolder and makefolder) and not useStudio then
		if Topbar['Settings'] then Topbar.Settings.Visible = false end
		Topbar['Search'].Position = UDim2.new(1, -75, 0.5, 0)
		warn('Can\'t create settings as no file-saving functionality is available.')
		return
	end

	local newTab = window:CreateTab('Rayfield Settings', 0, true)

	if TabList['Rayfield Settings'] then
		TabList['Rayfield Settings'].LayoutOrder = 1000
	end

	if Elements['Rayfield Settings'] then
		Elements['Rayfield Settings'].LayoutOrder = 1000
	end

	-- Create sections and elements
	for categoryName, settingCategory in pairs(settingsTable) do
		newTab:CreateSection(categoryName)

		for settingName, setting in pairs(settingCategory) do
			if setting.Type == 'input' then
				setting.Element = newTab:CreateInput({
					Name = setting.Name,
					CurrentValue = setting.Value,
					PlaceholderText = setting.Placeholder,
					Ext = true,
					RemoveTextAfterFocusLost = setting.ClearOnFocus,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			elseif setting.Type == 'toggle' then
				setting.Element = newTab:CreateToggle({
					Name = setting.Name,
					CurrentValue = setting.Value,
					Ext = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
				if setting.Description then
					newTab:CreateLabel(setting.Description)
				end
			elseif setting.Type == 'bind' then
				setting.Element = newTab:CreateKeybind({
					Name = setting.Name,
					CurrentKeybind = setting.Value,
					HoldToInteract = false,
					Ext = true,
					CallOnChange = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			end
		end
	end

	settingsCreated = true
	loadSettings()
	saveSettings()
end

local function fadeOutKeyUI(KeyMain)
	TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 467, 0, 175) })
		:Play()
	TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
		:Play()
	TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
	TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
		:Play()
	TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Transparency = 1 })
		:Play()
	TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
		{ TextTransparency = 1 })
		:Play()
	TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { ImageTransparency = 1 }):Play()
end

function RayfieldLibrary:CreateWindow(Settings)
	if Rayfield:FindFirstChild('Loading') then
		if getgenv and not getgenv().rayfieldCached then
			Rayfield.Enabled = true
			Rayfield.Loading.Visible = true

			task.wait(1.4)
			Rayfield.Loading.Visible = false
		end
	end

	if getgenv then getgenv().rayfieldCached = true end

	if not correctBuild and not Settings.DisableBuildWarnings then
		task.delay(3,
			function()
				RayfieldLibrary:Notify({
					Title = 'Build Mismatch',
					Content =
						'Rayfield may encounter issues as you are running an incompatible interface version (' ..
						((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..
						').\n\nThis version of Rayfield is intended for interface build ' ..
						InterfaceBuild .. '.\n\nTry rejoining and then run the script twice.',
					Image = 4335487866,
					Duration = 15
				})
			end)
	end

	if Settings.ToggleUIKeybind then -- Can either be a string or an Enum.KeyCode
		local keybind = Settings.ToggleUIKeybind
		if type(keybind) == "string" then
			keybind = string.upper(keybind)
			assert(pcall(function()
				return Enum.KeyCode[keybind]
			end), "ToggleUIKeybind must be a valid KeyCode")
			overrideSetting("General", "rayfieldOpen", keybind)
		elseif typeof(keybind) == "EnumItem" then
			assert(keybind.EnumType == Enum.KeyCode, "ToggleUIKeybind must be a KeyCode enum")
			overrideSetting("General", "rayfieldOpen", keybind.Name)
		else
			error("ToggleUIKeybind must be a string or KeyCode enum")
		end
	end

	ensureFolder(RayfieldFolder)
	pcall(siaStart, {
		name = Settings.Name,
		id = Settings.ScriptID,
		token = Settings.VerificationToken,
		theme = (type(Settings.Theme) == "string" and Settings.Theme) or (Settings.Theme and "Custom") or "Default",
	})

	Settings.KeySystem = false
	local Passthrough = true
	Topbar.Title.Text = Settings.Name

	Main.Size = UDim2.new(0, 420, 0, 100)
	Main.Visible = true
	Main.BackgroundTransparency = 1
	if Main:FindFirstChild('Notice') then Main.Notice.Visible = false end
	Main.Shadow.Image.ImageTransparency = 1

	LoadingFrame.Title.TextTransparency = 1
	LoadingFrame.Subtitle.TextTransparency = 1

	if Settings.ShowText then
		MPrompt.Title.Text = 'Show ' .. Settings.ShowText
	end

	LoadingFrame.Version.TextTransparency = 1
	LoadingFrame.Title.Text = Settings.LoadingTitle or "Rayfield"
	LoadingFrame.Subtitle.Text = Settings.LoadingSubtitle or "Interface Suite"

	if Settings.LoadingTitle ~= "Rayfield Interface Suite" then
		LoadingFrame.Version.Text = "Rayfield UI"
	end

	if Settings.Icon and Settings.Icon ~= 0 and Topbar:FindFirstChild('Icon') then
		Topbar.Icon.Visible = true
		Topbar.Title.Position = UDim2.new(0, 47, 0.5, 0)

		if Settings.Icon then
			local img, rectOffset, rectSize = resolveIcon(Settings.Icon)
			Topbar.Icon.Image = img
			if rectOffset then Topbar.Icon.ImageRectOffset = rectOffset end
			if rectSize then Topbar.Icon.ImageRectSize = rectSize end
		else
			Topbar.Icon.Image = ""
		end
	end

	if dragBar then
		dragBar.Visible = false
		dragBarCosmetic.BackgroundTransparency = 1
		dragBar.Visible = true
	end

	if Settings.Theme then
		local success, result = pcall(ChangeTheme, Settings.Theme)
		if not success then
			local success, result2 = pcall(ChangeTheme, 'Default')
			if not success then
				warn('CRITICAL ERROR - NO DEFAULT THEME')
				print(result2)
			end
			warn('issue rendering theme. no theme on file')
			print(result)
		end
	end

	Topbar.Visible = false
	Elements.Visible = false
	LoadingFrame.Visible = true

	if not Settings.DisableRayfieldPrompts then
		task.spawn(function()
			while not rayfieldDestroyed do
				task.wait(math.random(180, 600))
				if rayfieldDestroyed then break end
				RayfieldLibrary:Notify({
					Title = "Rayfield Interface",
					Content = "Enjoying this UI library? Find it at sirius.menu/discord",
					Duration = 7,
					Image = 4370033185,
				})
			end
		end)
	end

	pcall(function()
		-- Without a FileName the config used to be named after the place alone, so every hub in the
		-- same game wrote over the others'. It's now the hub's name and the place. That older file is
		-- still read when the new one doesn't exist yet, so nobody's saved settings go missing.
		CLegacyFileName = nil
		if not Settings.ConfigurationSaving.FileName then
			local placeName = tostring(game.PlaceId)
			-- window names often carry characters Windows refuses in a file name, like "|" or ":",
			-- and a trailing dot or space that it drops
			local hubName = string.gsub(sanitizeFileName(Settings.Name or ""), '[:<>"|?*]', "")
			hubName = string.match(hubName, "^%s*(.-)[%s%.]*$") or ""
			if hubName ~= "" then
				Settings.ConfigurationSaving.FileName = hubName .. "-" .. placeName
				CLegacyFileName = placeName
			else
				Settings.ConfigurationSaving.FileName = placeName
			end
		end

		if Settings.ConfigurationSaving.Enabled == nil then
			Settings.ConfigurationSaving.Enabled = false
		end

		CFileName = sanitizeFileName(Settings.ConfigurationSaving.FileName)
		if CFileName == "" then
			CFileName = tostring(game.PlaceId)
		end
		if Settings.ConfigurationSaving.FolderName then
			local folderName = sanitizeFolderName(Settings.ConfigurationSaving.FolderName)
			if folderName ~= "" then
				ConfigurationFolder = folderName
			end
		end
		CEnabled = Settings.ConfigurationSaving.Enabled

		if Settings.ConfigurationSaving.Enabled then
			ensureFolder(ConfigurationFolder)
		end
	end)


	makeDraggable(Main, Topbar, false, { dragOffset, dragOffsetMobile })
	if dragBar then
		dragBar.Position = UDim2.new(0.5, 0, 0.5, getCurrentDragOffset())
		makeDraggable(Main, dragInteract, true, { dragOffset, dragOffsetMobile })
	end

	for _, TabButton in ipairs(TabList:GetChildren()) do
		if TabButton.ClassName == "Frame" and TabButton.Name ~= "Placeholder" then
			TabButton.BackgroundTransparency = 1
			TabButton.Title.TextTransparency = 1
			TabButton.Image.ImageTransparency = 1
			TabButton.UIStroke.Transparency = 1
		end
	end

	if Settings.Discord and Settings.Discord.Enabled and not useStudio and not secureMode then
		ensureFolder(RayfieldFolder .. "/Discord Invites")
		local inviteFile = RayfieldFolder ..
			"/Discord Invites" .. "/" .. sanitizeFileName(Settings.Discord.Invite) .. ConfigurationExtension

		if not callSafely(isfile, inviteFile) then
			if requestFunc then
				pcall(function()
					requestFunc({
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Method = 'POST',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = HttpService:JSONEncode({
							cmd = 'INVITE_BROWSER',
							nonce = HttpService:GenerateGUID(false),
							args = { code = Settings.Discord.Invite }
						})
					})
				end)
			end

			if Settings.Discord.RememberJoins then -- We do logic this way so if the developer changes this setting, the user still won't be prompted, only new users
				callSafely(writefile, inviteFile,
					"Rayfield RememberJoins is true for this invite, this invite will not ask you to join again")
			end
		end
	end

	-- [BYPASS KEY SYSTEM] Bo hoan toan yeu cau Key, luon vao thang menu
	if false and (Settings.KeySystem) then
		if not Settings.KeySettings then
			Passthrough = true
			return
		end

		ensureFolder(RayfieldFolder .. "/Key System")

		if typeof(Settings.KeySettings.Key) == "string" then Settings.KeySettings.Key = { Settings.KeySettings.Key } end

		if Settings.KeySettings.GrabKeyFromSite then
			for i, Key in ipairs(Settings.KeySettings.Key) do
				local Success, Response = pcall(function()
					local fetched, body = httpGet(Key)
					assert(fetched and type(body) == "string", tostring(body))
					Settings.KeySettings.Key[i] = tostring(body:gsub("[\n\r]", " "))
					Settings.KeySettings.Key[i] = string.gsub(Settings.KeySettings.Key[i], " ", "")
				end)
				if not Success then
					print("Rayfield | " .. Key .. " Error " .. tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
				end
			end
		end

		if not Settings.KeySettings.FileName then
			Settings.KeySettings.FileName = "No file name specified"
		end
		local keyFileName = sanitizeFileName(Settings.KeySettings.FileName)
		if keyFileName == "" then
			keyFileName = "No file name specified"
		end
		local keyFile = RayfieldFolder .. "/Key System" .. "/" .. keyFileName .. ConfigurationExtension

		if callSafely(isfile, keyFile) then
			for _, MKey in ipairs(Settings.KeySettings.Key) do
				local savedKeys = callSafely(readfile, keyFile)
				if savedKeys and string.find(savedKeys, tostring(MKey), 1, true) then
					Passthrough = true
				end
			end
		end

		if not Passthrough and secureMode then
			warn(
				"Rayfield | Secure Mode: Key system requires a valid saved key. The key UI cannot be shown as it requires loading detectable assets.")
			Rayfield.Enabled = false
			return RayfieldLibrary
		end

		if not Passthrough then
			siaCall("keyScreen", "shown")
			local AttemptsRemaining = Settings.KeySettings.MaxAttempts or 5
			Rayfield.Enabled = false
			local KeyUI = useStudio and script.Parent:FindFirstChild('Key') or
				game:GetObjects("rbxassetid://11380036235")[1]

			KeyUI.Enabled = true
			parentGui(KeyUI)

			if KeyUI.Parent then
				pcall(function()
					for _, Interface in ipairs(KeyUI.Parent:GetChildren()) do
						if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
							Interface.Enabled = false
							Interface.Name = "KeyUI-Old"
						end
					end
				end)
			end

			local KeyMain = KeyUI.Main
			local keyUIScale = KeyMain:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
			keyUIScale.Scale = mainUIScale and mainUIScale.Scale or 1
			keyUIScale.Parent = KeyMain
			makeDraggable(KeyMain, KeyMain)
			KeyMain.Title.Text = Settings.KeySettings.Title or Settings.Name
			KeyMain.Subtitle.Text = Settings.KeySettings.Subtitle or "Key System"
			KeyMain.NoteMessage.Text = Settings.KeySettings.Note or "No instructions"

			KeyMain.Size = UDim2.new(0, 467, 0, 175)
			KeyMain.BackgroundTransparency = 1
			KeyMain.Shadow.Image.ImageTransparency = 1
			KeyMain.Title.TextTransparency = 1
			KeyMain.Subtitle.TextTransparency = 1
			KeyMain.KeyNote.TextTransparency = 1
			KeyMain.Input.BackgroundTransparency = 1
			KeyMain.Input.UIStroke.Transparency = 1
			KeyMain.Input.InputBox.TextTransparency = 1
			KeyMain.NoteTitle.TextTransparency = 1
			KeyMain.NoteMessage.TextTransparency = 1
			KeyMain.Hide.ImageTransparency = 1

			TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
				{ Size = UDim2.new(0, 500, 0, 187) }):Play()
			TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 0.5 }):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
				:Play()
			TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 }):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 })
				:Play()
			TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0 }):Play()
			TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ Transparency = 0 }):Play()
			TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 }):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 }):Play()
			TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 }):Play()
			task.wait(0.15)
			TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 0.3 })
				:Play()


			KeyUI.Main.Input.InputBox.FocusLost:Connect(function()
				if #KeyUI.Main.Input.InputBox.Text == 0 then return end
				local KeyFound = false
				local FoundKey = ''
				for _, MKey in ipairs(Settings.KeySettings.Key) do
					--if string.find(KeyMain.Input.InputBox.Text, MKey) then
					--	KeyFound = true
					--	FoundKey = MKey
					--end


					-- stricter key check
					if KeyMain.Input.InputBox.Text == MKey then
						KeyFound = true
						FoundKey = MKey
					end
				end
				siaCall("keyScreen", "attempt")
				if KeyFound then
					siaCall("keyScreen", "accepted")
					fadeOutKeyUI(KeyMain)
					task.wait(0.51)
					Passthrough = true
					KeyMain.Visible = false
					if Settings.KeySettings.SaveKey then
						callSafely(writefile, keyFile, FoundKey)
						RayfieldLibrary:Notify({
							Title = "Key System",
							Content =
							"The key for this script has been saved successfully.",
							Image = 3605522284
						})
					end
				else
					if AttemptsRemaining == 0 then
						fadeOutKeyUI(KeyMain)
						task.wait(0.45)
						Players.LocalPlayer:Kick("No Attempts Remaining")
						game:Shutdown()
					end
					KeyMain.Input.InputBox.Text = ""
					AttemptsRemaining = AttemptsRemaining - 1
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(0, 467, 0, 175) }):Play()
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic),
						{ Position = UDim2.new(0.495, 0, 0.5, 0) }):Play()
					task.wait(0.1)
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic),
						{ Position = UDim2.new(0.505, 0, 0.5, 0) }):Play()
					task.wait(0.1)
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
						{ Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(0, 500, 0, 187) }):Play()
				end
			end)

			KeyMain.Hide.MouseButton1Click:Connect(function()
				fadeOutKeyUI(KeyMain)
				task.wait(0.51)
				Passthrough = true
				RayfieldLibrary:Destroy()
				KeyUI:Destroy()
			end)
		else
			Passthrough = true
		end
	end
	if false and Settings.KeySystem then
		repeat task.wait() until Passthrough
		if rayfieldDestroyed then return end
	end
	siaCall("window", "open")

	Notifications.Template.Visible = false
	Notifications.Visible = true
	Rayfield.Enabled = true

	task.wait(0.5)
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { ImageTransparency = 0.6 })
		:Play()
	task.wait(0.1)
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		:Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		:Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
		:Play()


	Elements.Template.LayoutOrder = 100000
	Elements.Template.Visible = false

	Elements.UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
	Elements.UIPageLayout.ScrollWheelInputEnabled = false
	Elements.UIPageLayout.GamepadInputEnabled = false
	Elements.UIPageLayout.TouchInputEnabled = false
	TabList.Template.Visible = false

	-- Tab
	local FirstTab = false
	local Window = {}
	local siaTabCount = 0
	function Window:CreateTab(Name, Image, Ext)
		local siaTab = nil
		if not Ext then
			siaTabCount = siaTabCount + 1
			siaTab = siaTabCount
			siaCall("tabName", siaTab, Name)
		end
		local SDone = false
		local TabButton = TabList.Template:Clone()
		TabButton.Name = Name
		TabButton.Title.Text = Name
		TabButton.Parent = TabList
		TabButton.Title.TextWrapped = false
		TabButton.Size = UDim2.new(0, TabButton.Title.TextBounds.X + 30, 0, 30)

		if Image and Image ~= 0 then
			local img, rectOffset, rectSize = resolveIcon(Image)
			TabButton.Image.Image = img
			if rectOffset then TabButton.Image.ImageRectOffset = rectOffset end
			if rectSize then TabButton.Image.ImageRectSize = rectSize end

			TabButton.Title.AnchorPoint = Vector2.new(0, 0.5)
			TabButton.Title.Position = UDim2.new(0, 37, 0.5, 0)
			TabButton.Image.Visible = true
			TabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
			TabButton.Size = UDim2.new(0, TabButton.Title.TextBounds.X + 52, 0, 30)
		else
			TabButton.Image.Visible = false
			TabButton.Image.Image = ""
			TabButton.Title.AnchorPoint = Vector2.new(0.5, 0.5)
			TabButton.Title.Position = UDim2.new(0.5, 0, 0.5, 0)
			TabButton.Title.TextXAlignment = Enum.TextXAlignment.Center
			TabButton.Size = UDim2.new(0, TabButton.Title.TextBounds.X + 26, 0, 30)
		end



		TabButton.BackgroundTransparency = 1
		TabButton.Title.TextTransparency = 1
		TabButton.Image.ImageTransparency = 1
		TabButton.UIStroke.Transparency = 1

		TabButton.Visible = not Ext or false

		-- Create Elements Page
		local TabPage = Elements.Template:Clone()
		TabPage.Name = Name
		TabPage.Visible = true

		TabPage.LayoutOrder = Ext and 10000 or #Elements:GetChildren()

		for _, TemplateElement in ipairs(TabPage:GetChildren()) do
			if TemplateElement.ClassName == "Frame" and TemplateElement.Name ~= "Placeholder" then
				TemplateElement:Destroy()
			end
		end

		TabPage.Parent = Elements
		if not FirstTab and not Ext then
			Elements.UIPageLayout.Animated = false
			Elements.UIPageLayout:JumpTo(TabPage)
			Elements.UIPageLayout.Animated = true
		end

		TabButton.UIStroke.Color = SelectedTheme.TabStroke

		if Elements.UIPageLayout.CurrentPage == TabPage then
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
		else
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
		end


		-- Animate
		task.wait(0.1)
		if FirstTab or Ext then
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0.7 }):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0.2 }):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 0.2 }):Play()
			TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ Transparency = 0.5 }):Play()
		elseif not Ext then
			FirstTab = Name
			siaCurrentTab = siaTab
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 0 }):Play()
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 })
				:Play()
		end


		TabButton.Interact.MouseButton1Click:Connect(function()
			if Minimised then return end
			if siaTab and siaCurrentTab ~= siaTab then
				siaCurrentTab = siaTab
				siaCall("tab", siaTab)
			end
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ Transparency = 1 })
				:Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 })
				:Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 0 }):Play()
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ BackgroundColor3 = SelectedTheme.TabBackgroundSelected }):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextColor3 = SelectedTheme.SelectedTabTextColor }):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ ImageColor3 = SelectedTheme.SelectedTabTextColor }):Play()

			for _, OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton and OtherTabButton.Name ~= "Placeholder" then
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.TabBackground }):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ TextColor3 = SelectedTheme.TabTextColor }):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ ImageColor3 = SelectedTheme.TabTextColor }):Play()
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.7 }):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0.2 }):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.2 }):Play()
					TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ Transparency = 0.5 }):Play()
				end
			end

			if Elements.UIPageLayout.CurrentPage ~= TabPage then
				Elements.UIPageLayout:JumpTo(TabPage)
			end
		end)

		local Tab = {}

		-- Button
		function Tab:CreateButton(ButtonSettings)
			local ButtonValue = {}
			local siaHandle = siaElement("button", ButtonSettings.Name, siaTab)

			local Button = Elements.Template.Button:Clone()
			Button.Name = ButtonSettings.Name
			Button.Title.Text = ButtonSettings.Name
			Button.Visible = true
			Button.Parent = TabPage

			Button.BackgroundTransparency = 1
			Button.UIStroke.Transparency = 1
			Button.Title.TextTransparency = 1

			TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(Button.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Transparency = 0 })
				:Play()
			TweenService:Create(Button.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
				:Play()


			Button.Interact.MouseButton1Click:Connect(function()
				siaUsed(siaHandle, "press")
				local Success, Response = pcall(ButtonSettings.Callback)
				if not Success then siaError(siaHandle) end
				-- Prevents animation from trying to play if the button's callback called RayfieldLibrary:Destroy()
				if rayfieldDestroyed then
					return
				end
				if not Success then
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ TextTransparency = 1 }):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					Button.Title.Text = "Callback Error"
					print("Rayfield | " .. ButtonSettings.Name .. " Callback Error " .. tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Button.Title.Text = ButtonSettings.Name
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0.9 }):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				else
					if not ButtonSettings.Ext then
						SaveConfiguration(ButtonSettings.Name .. '\n')
					end
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ TextTransparency = 1 }):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					task.wait(0.2)
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0.9 }):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end
			end)

			Button.MouseEnter:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
				TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ TextTransparency = 0.7 }):Play()
			end)

			Button.MouseLeave:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
				TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ TextTransparency = 0.9 }):Play()
			end)

			function ButtonValue:Set(NewButton)
				Button.Title.Text = NewButton
				Button.Name = NewButton
			end

			return ButtonValue
		end

		-- ColorPicker
		function Tab:CreateColorPicker(ColorPickerSettings) -- by Throit
			ColorPickerSettings.Type = "ColorPicker"
			local siaHandle = siaElement("colorpicker", ColorPickerSettings.Name, siaTab)
			local ColorPicker = Elements.Template.ColorPicker:Clone()
			local Background = ColorPicker.CPBackground
			local Display = Background.Display
			local Main = Background.MainCP
			local Slider = ColorPicker.ColorSlider
			ColorPicker.ClipsDescendants = true
			ColorPicker.Name = ColorPickerSettings.Name
			ColorPicker.Title.Text = ColorPickerSettings.Name
			ColorPicker.Visible = true
			ColorPicker.Parent = TabPage
			ColorPicker.Size = UDim2.new(1, -10, 0, 45)
			Background.Size = UDim2.new(0, 39, 0, 22)
			Display.BackgroundTransparency = 0
			Main.MainPoint.ImageTransparency = 1
			ColorPicker.Interact.Size = UDim2.new(1, 0, 1, 0)
			ColorPicker.Interact.Position = UDim2.new(0.5, 0, 0.5, 0)
			ColorPicker.RGB.Position = UDim2.new(0, 17, 0, 70)
			ColorPicker.HexInput.Position = UDim2.new(0, 17, 0, 90)
			Main.ImageTransparency = 1
			Background.BackgroundTransparency = 1

			for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
				if rgbinput:IsA("Frame") then
					rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
					rgbinput.UIStroke.Color = SelectedTheme.InputStroke
				end
			end

			ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
			ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke

			local opened = false
			local mouse = Players.LocalPlayer and Players.LocalPlayer:GetMouse() or nil
			local mainDragging = false
			local sliderDragging = false
			local activeCPInput = nil

			local function getCPPointerPosition()
				local screenGui = ColorPicker:FindFirstAncestorWhichIsA("ScreenGui")
				local ignoreInset = screenGui and screenGui.IgnoreGuiInset or false
				local inset = GuiService and select(2, pcall(GuiService.GetGuiInset, GuiService)) or Vector2.zero
				if typeof(inset) ~= "Vector2" then inset = Vector2.zero end

				if activeCPInput and activeCPInput.UserInputType == Enum.UserInputType.Touch then
					local pos = Vector2.new(activeCPInput.Position.X, activeCPInput.Position.Y)
					if ignoreInset then
						return pos + inset
					end
					return pos
				end
				local mouseLoc = UserInputService:GetMouseLocation()
				if ignoreInset then
					return mouseLoc
				end
				return mouseLoc - inset
			end

			local function toggleColorPickerOpen()
				task.spawn(function()
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					task.wait(0.2)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end)

				if not opened then
					opened = true
					TweenService:Create(Background, TweenInfo.new(0.45, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(0, 18, 0, 15) }):Play()
					task.wait(0.1)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(1, -10, 0, 120) }):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(0, 173, 0, 86) }):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Position = UDim2.new(0.289, 0, 0.5, 0) }):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.8, Enum.EasingStyle.Exponential),
						{ Position = UDim2.new(0, 17, 0, 40) }):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ Position = UDim2.new(0, 17, 0, 73) }):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(0.574, 0, 1, 0) }):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0 }):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ ImageTransparency = SelectedTheme ~= RayfieldLibrary.Theme.Default and 0.25 or 0.1 }):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }):Play()
				else
					opened = false
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(1, -10, 0, 45) }):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(0, 39, 0, 22) }):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(1, 0, 1, 0) }):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Position = UDim2.new(0, 17, 0, 70) }):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ Position = UDim2.new(0, 17, 0, 90) }):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0 }):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 1 }):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
						:Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 1 }):Play()
				end
			end

			ColorPicker.Interact.MouseButton1Click:Connect(toggleColorPickerOpen)

			local colorPickerInputConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if mainDragging or sliderDragging then
						siaUsed(siaHandle, "set")
						if TabPage and TabPage:IsA("ScrollingFrame") then
							TabPage.ScrollingEnabled = true
						end
					end
					mainDragging = false
					sliderDragging = false
					activeCPInput = nil
				end
			end)

			local function beginMainDrag(input)
				if not opened then return end
				if input and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					activeCPInput = input
					mainDragging = true
					if TabPage and TabPage:IsA("ScrollingFrame") then
						TabPage.ScrollingEnabled = false
					end
				end
			end

			local function beginSliderDrag(input)
				if not opened then return end
				if input and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					activeCPInput = input
					sliderDragging = true
					if TabPage and TabPage:IsA("ScrollingFrame") then
						TabPage.ScrollingEnabled = false
					end
				end
			end

			Main.InputBegan:Connect(beginMainDrag)
			Main.MainPoint.InputBegan:Connect(beginMainDrag)
			Slider.InputBegan:Connect(beginSliderDrag)
			Slider.SliderPoint.InputBegan:Connect(beginSliderDrag)

			Main.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true
				end
			end)
			Main.MainPoint.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true
				end
			end)
			Slider.MouseButton1Down:Connect(function()
				if opened then
					sliderDragging = true
				end
			end)
			Slider.SliderPoint.MouseButton1Down:Connect(function()
				if opened then
					sliderDragging = true
				end
			end)
			local h, s, v = ColorPickerSettings.Color:ToHSV()
			local color = Color3.fromHSV(h, s, v)
			local hex = string.format("#%02X%02X%02X", color.R * 0xFF, color.G * 0xFF, color.B * 0xFF)
			ColorPicker.HexInput.InputBox.Text = hex
			local function setDisplay()
				local uiScale = (mainUIScale and mainUIScale.Scale > 0) and mainUIScale.Scale or 1
				--Main
				Main.MainPoint.Position = UDim2.new(s, -(Main.MainPoint.AbsoluteSize.X / uiScale) / 2, 1 - v,
					-(Main.MainPoint.AbsoluteSize.Y / uiScale) / 2)
				Main.MainPoint.ImageColor3 = Color3.fromHSV(h, s, v)
				Background.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				Display.BackgroundColor3 = Color3.fromHSV(h, s, v)
				--Slider
				local x = h * (Slider.AbsoluteSize.X / uiScale)
				Slider.SliderPoint.Position = UDim2.new(0, x - (Slider.SliderPoint.AbsoluteSize.X / uiScale) / 2, 0.5, 0)
				Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h, 1, 1)
				local color = Color3.fromHSV(h, s, v)
				local r, g, b = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5),
					math.floor((color.B * 255) + 0.5)
				ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
				ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
				ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
				hex = string.format("#%02X%02X%02X", color.R * 0xFF, color.G * 0xFF, color.B * 0xFF)
				ColorPicker.HexInput.InputBox.Text = hex
			end
			setDisplay()
			ColorPicker.HexInput.InputBox.FocusLost:Connect(function()
				siaUsed(siaHandle, "set")
				if not pcall(function()
						local r, g, b = string.match(ColorPicker.HexInput.InputBox.Text, "^#?(%w%w)(%w%w)(%w%w)$")
						local rgbColor = Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
						h, s, v = rgbColor:ToHSV()
						hex = ColorPicker.HexInput.InputBox.Text
						setDisplay()
						ColorPickerSettings.Color = rgbColor
					end)
				then
					ColorPicker.HexInput.InputBox.Text = hex
				end
				pcall(function() ColorPickerSettings.Callback(Color3.fromHSV(h, s, v)) end)
				local r, g, b = math.floor((h * 255) + 0.5), math.floor((s * 255) + 0.5), math.floor((v * 255) + 0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration()
				end
			end)
			--RGB
			local function rgbBoxes(box, toChange)
				local value = tonumber(box.Text)
				local color = Color3.fromHSV(h, s, v)
				local oldR, oldG, oldB = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5),
					math.floor((color.B * 255) + 0.5)
				local save
				if toChange == "R" then
					save = oldR; oldR = value
				elseif toChange == "G" then
					save = oldG; oldG = value
				else
					save = oldB; oldB = value
				end
				if value then
					value = math.clamp(value, 0, 255)
					h, s, v = Color3.fromRGB(oldR, oldG, oldB):ToHSV()

					setDisplay()
				else
					box.Text = tostring(save)
				end
				local r, g, b = math.floor((h * 255) + 0.5), math.floor((s * 255) + 0.5), math.floor((v * 255) + 0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration(ColorPickerSettings.Flag .. '\n' .. tostring(ColorPickerSettings.Color))
				end
			end
			ColorPicker.RGB.RInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.RInput.InputBox, "R")
				siaUsed(siaHandle, "set")
				pcall(function() ColorPickerSettings.Callback(Color3.fromHSV(h, s, v)) end)
			end)
			ColorPicker.RGB.GInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.GInput.InputBox, "G")
				siaUsed(siaHandle, "set")
				pcall(function() ColorPickerSettings.Callback(Color3.fromHSV(h, s, v)) end)
			end)
			ColorPicker.RGB.BInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.BInput.InputBox, "B")
				siaUsed(siaHandle, "set")
				pcall(function() ColorPickerSettings.Callback(Color3.fromHSV(h, s, v)) end)
			end)

			local colorPickerRenderConnection = RunService.RenderStepped:connect(function()
				if mainDragging or sliderDragging then
					local pointerPos = getCPPointerPosition()
					local uiScale = (mainUIScale and mainUIScale.Scale > 0) and mainUIScale.Scale or 1
					if mainDragging and Main.AbsoluteSize.X > 0 and Main.AbsoluteSize.Y > 0 then
						local localX = math.clamp(pointerPos.X - Main.AbsolutePosition.X, 0, Main.AbsoluteSize.X)
						local localY = math.clamp(pointerPos.Y - Main.AbsolutePosition.Y, 0, Main.AbsoluteSize.Y)
						Main.MainPoint.Position = UDim2.new(0, (localX - Main.MainPoint.AbsoluteSize.X / 2) / uiScale, 0,
							(localY - Main.MainPoint.AbsoluteSize.Y / 2) / uiScale)
						s = localX / Main.AbsoluteSize.X
						v = 1 - (localY / Main.AbsoluteSize.Y)
						Display.BackgroundColor3 = Color3.fromHSV(h, s, v)
						Main.MainPoint.ImageColor3 = Color3.fromHSV(h, s, v)
						Background.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						local color = Color3.fromHSV(h, s, v)
						local r, g, b = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5),
							math.floor((color.B * 255) + 0.5)
						ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
						ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
						ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
						ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X", color.R * 0xFF, color.G *
							0xFF, color.B * 0xFF)
						pcall(function() ColorPickerSettings.Callback(Color3.fromHSV(h, s, v)) end)
						ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
						if not ColorPickerSettings.Ext then
							SaveConfiguration()
						end
					end
					if sliderDragging and Slider.AbsoluteSize.X > 0 then
						local localX = math.clamp(pointerPos.X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
						h = localX / Slider.AbsoluteSize.X
						Display.BackgroundColor3 = Color3.fromHSV(h, s, v)
						Slider.SliderPoint.Position = UDim2.new(0,
							(localX - Slider.SliderPoint.AbsoluteSize.X / 2) / uiScale, 0.5, 0)
						Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h, 1, 1)
						Background.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						Main.MainPoint.ImageColor3 = Color3.fromHSV(h, s, v)
						local color = Color3.fromHSV(h, s, v)
						local r, g, b = math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5),
							math.floor((color.B * 255) + 0.5)
						ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
						ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
						ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
						ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X", color.R * 0xFF, color.G *
							0xFF, color.B * 0xFF)
						pcall(function() ColorPickerSettings.Callback(Color3.fromHSV(h, s, v)) end)
						ColorPickerSettings.Color = Color3.fromRGB(r, g, b)
						if not ColorPickerSettings.Ext then
							SaveConfiguration()
						end
					end
				end
			end)

			ColorPicker.Destroying:Connect(function()
				if colorPickerRenderConnection then
					colorPickerRenderConnection:Disconnect()
				end
				if colorPickerInputConnection then
					colorPickerInputConnection:Disconnect()
				end
			end)

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and ColorPickerSettings.Flag then
					RayfieldLibrary.Flags[ColorPickerSettings.Flag] = ColorPickerSettings
				end
			end

			function ColorPickerSettings:Set(RGBColor)
				ColorPickerSettings.Color = RGBColor
				h, s, v = ColorPickerSettings.Color:ToHSV()
				color = Color3.fromHSV(h, s, v)
				setDisplay()
			end

			ColorPicker.MouseEnter:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
			end)

			ColorPicker.MouseLeave:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
			end)

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
					if rgbinput:IsA("Frame") then
						rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
						rgbinput.UIStroke.Color = SelectedTheme.InputStroke
					end
				end

				ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
				ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return ColorPickerSettings
		end

		-- Section
		function Tab:CreateSection(SectionName)
			siaCall("section", siaTab or 0, SectionName)

			local SectionValue = {}

			if SDone then
				local SectionSpace = Elements.Template.SectionSpacing:Clone()
				SectionSpace.Visible = true
				SectionSpace.Parent = TabPage
			end

			local Section = Elements.Template.SectionTitle:Clone()
			Section.Title.Text = SectionName
			Section.Visible = true
			Section.Parent = TabPage

			Section.Title.TextTransparency = 1
			TweenService:Create(Section.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0.4 })
				:Play()

			function SectionValue:Set(NewSection)
				Section.Title.Text = NewSection
			end

			SDone = true

			return SectionValue
		end

		-- Divider
		function Tab:CreateDivider()
			local DividerValue = {}

			local Divider = Elements.Template.Divider:Clone()
			Divider.Visible = true
			Divider.Parent = TabPage

			Divider.Divider.BackgroundTransparency = 1
			TweenService:Create(Divider.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0.85 }):Play()

			function DividerValue:Set(Value)
				Divider.Visible = Value
			end

			return DividerValue
		end

		-- Label
		function Tab:CreateLabel(LabelText, Icon, Color, IgnoreTheme)
			local LabelValue = {}

			local Label = Elements.Template.Label:Clone()
			Label.Title.Text = LabelText
			Label.Visible = true
			Label.Parent = TabPage

			Label.BackgroundColor3 = Color or SelectedTheme.SecondaryElementBackground
			Label.UIStroke.Color = Color or SelectedTheme.SecondaryElementStroke

			if Icon then
				local img, rectOffset, rectSize = resolveIcon(Icon)
				Label.Icon.Image = img
				if rectOffset then Label.Icon.ImageRectOffset = rectOffset end
				if rectSize then Label.Icon.ImageRectSize = rectSize end
			else
				Label.Icon.Image = ""
			end

			if Icon and Label:FindFirstChild('Icon') then
				Label.Title.Position = UDim2.new(0, 45, 0.5, 0)
				Label.Title.Size = UDim2.new(1, -100, 0, 14)
				Label.Icon.Visible = true
			end

			Label.Icon.ImageTransparency = 1
			Label.BackgroundTransparency = 1
			Label.UIStroke.Transparency = 1
			Label.Title.TextTransparency = 1

			Label:SetAttribute("BackgroundTransparencyTarget", Color and 0.8 or 0)
			Label:SetAttribute("UIStrokeTransparencyTarget", Color and 0.7 or 0)
			Label:SetAttribute("TitleTextTransparencyTarget", Color and 0.2 or 0)

			TweenService:Create(Label, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = Color and 0.8 or 0 }):Play()
			TweenService:Create(Label.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ Transparency = Color and 0.7 or 0 }):Play()
			TweenService:Create(Label.Icon, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { ImageTransparency = 0.2 })
				:Play()
			TweenService:Create(Label.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = Color and 0.2 or 0 }):Play()

			function LabelValue:Set(NewLabel, Icon, Color)
				Label.Title.Text = NewLabel

				if Color then
					Label.BackgroundColor3 = Color or SelectedTheme.SecondaryElementBackground
					Label.UIStroke.Color = Color or SelectedTheme.SecondaryElementStroke
				end

				if Icon and Label:FindFirstChild('Icon') then
					Label.Title.Position = UDim2.new(0, 45, 0.5, 0)
					Label.Title.Size = UDim2.new(1, -100, 0, 14)

					local img, rectOffset, rectSize = resolveIcon(Icon)
					Label.Icon.Image = img
					if rectOffset then Label.Icon.ImageRectOffset = rectOffset end
					if rectSize then Label.Icon.ImageRectSize = rectSize end

					Label.Icon.Visible = true
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Label.BackgroundColor3 = IgnoreTheme and (Color or Label.BackgroundColor3) or
					SelectedTheme.SecondaryElementBackground
				Label.UIStroke.Color = IgnoreTheme and (Color or Label.BackgroundColor3) or
					SelectedTheme.SecondaryElementStroke
			end)

			return LabelValue
		end

		-- Paragraph
		function Tab:CreateParagraph(ParagraphSettings)
			local ParagraphValue = {}

			local Paragraph = Elements.Template.Paragraph:Clone()
			Paragraph.Title.Text = ParagraphSettings.Title
			Paragraph.Content.Text = ParagraphSettings.Content
			Paragraph.Visible = true
			Paragraph.Parent = TabPage

			Paragraph.BackgroundTransparency = 1
			Paragraph.UIStroke.Transparency = 1
			Paragraph.Title.TextTransparency = 1
			Paragraph.Content.TextTransparency = 1

			Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
			Paragraph.UIStroke.Color = SelectedTheme.SecondaryElementStroke

			TweenService:Create(Paragraph, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(Paragraph.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ Transparency = 0 })
				:Play()
			TweenService:Create(Paragraph.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 })
				:Play()
			TweenService:Create(Paragraph.Content, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 }):Play()

			function ParagraphValue:Set(NewParagraphSettings)
				Paragraph.Title.Text = NewParagraphSettings.Title
				Paragraph.Content.Text = NewParagraphSettings.Content
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
				Paragraph.UIStroke.Color = SelectedTheme.SecondaryElementStroke
			end)

			return ParagraphValue
		end

		-- Input
		function Tab:CreateInput(InputSettings)
			local siaHandle = siaElement("input", InputSettings.Name, siaTab)
			local Input = Elements.Template.Input:Clone()
			Input.Name = InputSettings.Name
			Input.Title.Text = InputSettings.Name
			Input.Visible = true
			Input.Parent = TabPage

			Input.BackgroundTransparency = 1
			Input.UIStroke.Transparency = 1
			Input.Title.TextTransparency = 1

			Input.InputFrame.InputBox.Text = InputSettings.CurrentValue or ''

			Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke

			TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Transparency = 0 })
				:Play()
			TweenService:Create(Input.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
				:Play()

			Input.InputFrame.InputBox.PlaceholderText = InputSettings.PlaceholderText
			Input.InputFrame.Size = UDim2.new(0, Input.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

			Input.InputFrame.InputBox.FocusLost:Connect(function()
				siaUsed(siaHandle, "set")
				local Success, Response = pcall(function()
					InputSettings.Callback(Input.InputFrame.InputBox.Text)
					InputSettings.CurrentValue = Input.InputFrame.InputBox.Text
				end)

				if not Success then
					siaError(siaHandle)
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					Input.Title.Text = "Callback Error"
					print("Rayfield | " .. InputSettings.Name .. " Callback Error " .. tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Input.Title.Text = InputSettings.Name
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end

				if InputSettings.RemoveTextAfterFocusLost then
					Input.InputFrame.InputBox.Text = ""
				end

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end)

			Input.MouseEnter:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
			end)

			Input.MouseLeave:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
			end)

			Input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Input.InputFrame,
					TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, Input.InputFrame.InputBox.TextBounds.X + 24, 0, 30) }):Play()
			end)

			function InputSettings:Set(text)
				Input.InputFrame.InputBox.Text = text
				InputSettings.CurrentValue = text

				local Success, Response = pcall(function()
					InputSettings.Callback(text)
				end)

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and InputSettings.Flag then
					RayfieldLibrary.Flags[InputSettings.Flag] = InputSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return InputSettings
		end

		-- Dropdown
		function Tab:CreateDropdown(DropdownSettings)
			local siaHandle = siaElement("dropdown", DropdownSettings.Name, siaTab)
			local Dropdown = Elements.Template.Dropdown:Clone()
			if string.find(DropdownSettings.Name, "closed") then
				Dropdown.Name = "Dropdown"
			else
				Dropdown.Name = DropdownSettings.Name
			end
			Dropdown.Title.Text = DropdownSettings.Name
			Dropdown.Visible = true
			Dropdown.Parent = TabPage

			Dropdown.List.Visible = false
			if DropdownSettings.CurrentOption then
				if type(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = { DropdownSettings.CurrentOption }
				end
				if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
					DropdownSettings.CurrentOption = { DropdownSettings.CurrentOption[1] }
				end
			else
				DropdownSettings.CurrentOption = {}
			end

			if DropdownSettings.MultipleOptions then
				if DropdownSettings.CurrentOption and type(DropdownSettings.CurrentOption) == "table" then
					if #DropdownSettings.CurrentOption == 1 then
						Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						Dropdown.Selected.Text = "None"
					else
						Dropdown.Selected.Text = "Various"
					end
				else
					DropdownSettings.CurrentOption = {}
					Dropdown.Selected.Text = "None"
				end
			else
				Dropdown.Selected.Text = DropdownSettings.CurrentOption[1] or "None"
			end

			Dropdown.Toggle.ImageColor3 = SelectedTheme.TextColor
			TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
				{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()

			Dropdown.BackgroundTransparency = 1
			Dropdown.UIStroke.Transparency = 1
			Dropdown.Title.TextTransparency = 1

			Dropdown.Size = UDim2.new(1, -10, 0, 45)

			TweenService:Create(Dropdown, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Transparency = 0 })
				:Play()
			TweenService:Create(Dropdown.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ TextTransparency = 0 })
				:Play()

			for _, ununusedoption in ipairs(Dropdown.List:GetChildren()) do
				if ununusedoption.ClassName == "Frame" and ununusedoption.Name ~= "Placeholder" then
					ununusedoption:Destroy()
				end
			end

			Dropdown.Toggle.Rotation = 180

			Dropdown.Interact.MouseButton1Click:Connect(function()
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
				TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
					{ Transparency = 1 }):Play()
				task.wait(0.1)
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
				TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
					{ Transparency = 0 }):Play()
				if Debounce then return end
				if Dropdown.List.Visible then
					Debounce = true
					TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(1, -10, 0, 45) }):Play()
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 1 }):Play()
							TweenService:Create(DropdownOpt.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ Transparency = 1 }):Play()
							TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ TextTransparency = 1 }):Play()
						end
					end
					TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ ScrollBarImageTransparency = 1 }):Play()
					TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ Rotation = 180 }):Play()
					task.wait(0.35)
					Dropdown.List.Visible = false
					Debounce = false
				else
					TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
						{ Size = UDim2.new(1, -10, 0, 180) }):Play()
					Dropdown.List.Visible = true
					TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
						{ ScrollBarImageTransparency = 0.7 }):Play()
					TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ Rotation = 0 })
						:Play()
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							if DropdownOpt.Name ~= Dropdown.Selected.Text then
								TweenService:Create(DropdownOpt.UIStroke,
									TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 0 }):Play()
							end
							TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ BackgroundTransparency = 0 }):Play()
							TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ TextTransparency = 0 }):Play()
						end
					end
				end
			end)

			Dropdown.MouseEnter:Connect(function()
				if not Dropdown.List.Visible then
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
				end
			end)

			Dropdown.MouseLeave:Connect(function()
				TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
			end)

			local function SetDropdownOptions()
				for _, Option in ipairs(DropdownSettings.Options) do
					local DropdownOption = Elements.Template.Dropdown.List.Template:Clone()
					DropdownOption.Name = Option
					DropdownOption.Title.Text = Option
					DropdownOption.Parent = Dropdown.List
					DropdownOption.Visible = true

					DropdownOption.BackgroundTransparency = 1
					DropdownOption.UIStroke.Transparency = 1
					DropdownOption.Title.TextTransparency = 1

					--local Dropdown = Tab:CreateDropdown({
					--	Name = "Dropdown Example",
					--	Options = {"Option 1","Option 2"},
					--	CurrentOption = {"Option 1"},
					--  MultipleOptions = true,
					--	Flag = "Dropdown1",
					--	Callback = function(TableOfOptions)

					--	end,
					--})


					DropdownOption.Interact.ZIndex = 50
					DropdownOption.Interact.MouseButton1Click:Connect(function()
						if not DropdownSettings.MultipleOptions and table.find(DropdownSettings.CurrentOption, Option) then
							return
						end

						if table.find(DropdownSettings.CurrentOption, Option) then
							table.remove(DropdownSettings.CurrentOption,
								table.find(DropdownSettings.CurrentOption, Option))
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									Dropdown.Selected.Text = "None"
								else
									Dropdown.Selected.Text = "Various"
								end
							else
								Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
							end
						else
							if not DropdownSettings.MultipleOptions then
								table.clear(DropdownSettings.CurrentOption)
							end
							table.insert(DropdownSettings.CurrentOption, Option)
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									Dropdown.Selected.Text = "None"
								else
									Dropdown.Selected.Text = "Various"
								end
							else
								Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
							end
							TweenService:Create(DropdownOption.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ Transparency = 1 }):Play()
							TweenService:Create(DropdownOption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = SelectedTheme.DropdownSelected }):Play()
							Debounce = true
						end


						-- the option's place in the list, 0 for the first and 1 for the last
						local position = table.find(DropdownSettings.Options, Option) or 1
						siaUsed(siaHandle, "pick", (position - 1) / math.max(#DropdownSettings.Options - 1, 1))

						local Success, Response = pcall(function()
							DropdownSettings.Callback(DropdownSettings.CurrentOption)
						end)

						if not Success then
							siaError(siaHandle)
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
							TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ Transparency = 1 }):Play()
							Dropdown.Title.Text = "Callback Error"
							print("Rayfield | " .. DropdownSettings.Name .. " Callback Error " .. tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Dropdown.Title.Text = DropdownSettings.Name
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
							TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ Transparency = 0 }):Play()
						end

						for _, droption in ipairs(Dropdown.List:GetChildren()) do
							if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" and not table.find(DropdownSettings.CurrentOption, droption.Name) then
								TweenService:Create(droption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
									{ BackgroundColor3 = SelectedTheme.DropdownUnselected }):Play()
							end
						end
						if not DropdownSettings.MultipleOptions then
							task.wait(0.1)
							TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
								{ Size = UDim2.new(1, -10, 0, 45) }):Play()
							for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
								if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
									TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
										{ BackgroundTransparency = 1 }):Play()
									TweenService:Create(DropdownOpt.UIStroke,
										TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 1 }):Play()
									TweenService:Create(DropdownOpt.Title,
										TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { TextTransparency = 1 }):Play()
								end
							end
							TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
								{ ScrollBarImageTransparency = 1 }):Play()
							TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
								{ Rotation = 180 }):Play()
							task.wait(0.35)
							Dropdown.List.Visible = false
						end
						Debounce = false
						if not DropdownSettings.Ext then
							SaveConfiguration()
						end
					end)

					Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
						DropdownOption.UIStroke.Color = SelectedTheme.ElementStroke
					end)
				end
			end
			SetDropdownOptions()

			for _, droption in ipairs(Dropdown.List:GetChildren()) do
				if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
					if not table.find(DropdownSettings.CurrentOption, droption.Name) then
						droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
					else
						droption.BackgroundColor3 = SelectedTheme.DropdownSelected
					end

					Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end)
				end
			end

			function DropdownSettings:Set(NewOption)
				DropdownSettings.CurrentOption = NewOption

				if typeof(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = { DropdownSettings.CurrentOption }
				end

				if not DropdownSettings.MultipleOptions then
					DropdownSettings.CurrentOption = { DropdownSettings.CurrentOption[1] }
				end

				if DropdownSettings.MultipleOptions then
					if #DropdownSettings.CurrentOption == 1 then
						Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						Dropdown.Selected.Text = "None"
					else
						Dropdown.Selected.Text = "Various"
					end
				else
					Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
				end


				local Success, Response = pcall(function()
					DropdownSettings.Callback(NewOption)
				end)
				if not Success then
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
					TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					Dropdown.Title.Text = "Callback Error"
					print("Rayfield | " .. DropdownSettings.Name .. " Callback Error " .. tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Dropdown.Title.Text = DropdownSettings.Name
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end

				for _, droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end
				end
				--SaveConfiguration()
			end

			function DropdownSettings:Refresh(optionsTable) -- updates a dropdown with new options from optionsTable
				DropdownSettings.Options = optionsTable
				for _, option in ipairs(Dropdown.List:GetChildren()) do
					if option.ClassName == "Frame" and option.Name ~= "Placeholder" then
						option:Destroy()
					end
				end
				SetDropdownOptions()

				-- Apply selected/unselected background colors to new options
				for _, droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end
				end

				-- If the dropdown is currently open, make new options visible immediately
				if Dropdown.List.Visible then
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							DropdownOpt.BackgroundTransparency = 0
							DropdownOpt.Title.TextTransparency = 0
							if not table.find(DropdownSettings.CurrentOption, DropdownOpt.Name) then
								DropdownOpt.UIStroke.Transparency = 0
							end
						end
					end
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and DropdownSettings.Flag then
					RayfieldLibrary.Flags[DropdownSettings.Flag] = DropdownSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Dropdown.Toggle.ImageColor3 = SelectedTheme.TextColor
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
			end)

			return DropdownSettings
		end

		-- Keybind
		function Tab:CreateKeybind(KeybindSettings)
			local siaHandle = siaElement("keybind", KeybindSettings.Name, siaTab)
			local CheckingForKey = false
			local Keybind = Elements.Template.Keybind:Clone()
			Keybind.Name = KeybindSettings.Name
			Keybind.Title.Text = KeybindSettings.Name
			Keybind.Visible = true
			Keybind.Parent = TabPage

			Keybind.BackgroundTransparency = 1
			Keybind.UIStroke.Transparency = 1
			Keybind.Title.TextTransparency = 1

			Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke

			TweenService:Create(Keybind, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Transparency = 0 })
				:Play()
			TweenService:Create(Keybind.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
				:Play()

			Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
			Keybind.KeybindFrame.Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30)

			Keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
				CheckingForKey = true
				Keybind.KeybindFrame.KeybindBox.Text = ""
			end)
			Keybind.KeybindFrame.KeybindBox.FocusLost:Connect(function()
				CheckingForKey = false
				if Keybind.KeybindFrame.KeybindBox.Text == nil or Keybind.KeybindFrame.KeybindBox.Text == "" then
					Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
					if not KeybindSettings.Ext then
						SaveConfiguration()
					end
				end
			end)

			Keybind.MouseEnter:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
			end)

			Keybind.MouseLeave:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
			end)

			local connection = UserInputService.InputBegan:Connect(function(input, processed)
				if rayfieldDestroyed then return end
				if CheckingForKey then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						local SplitMessage = string.split(tostring(input.KeyCode), ".")
						local NewKeyNoEnum = SplitMessage[3]
						Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeyNoEnum)
						KeybindSettings.CurrentKeybind = tostring(NewKeyNoEnum)
						Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
						siaUsed(siaHandle, "bind")
						if not KeybindSettings.Ext then
							SaveConfiguration()
						end

						if KeybindSettings.CallOnChange then
							KeybindSettings.Callback(tostring(NewKeyNoEnum))
						end
					end
				elseif not KeybindSettings.CallOnChange and KeybindSettings.CurrentKeybind ~= nil and (input.KeyCode == Enum.KeyCode[KeybindSettings.CurrentKeybind] and not processed) then -- Test
					siaUsed(siaHandle, "press")
					local Held = true
					local Connection
					Connection = input.Changed:Connect(function(prop)
						if prop == "UserInputState" then
							Connection:Disconnect()
							Held = false
						end
					end)

					if not KeybindSettings.HoldToInteract then
						local Success, Response = pcall(KeybindSettings.Callback)
						if not Success then
							siaError(siaHandle)
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ Transparency = 1 }):Play()
							Keybind.Title.Text = "Callback Error"
							print("Rayfield | " .. KeybindSettings.Name .. " Callback Error " .. tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Keybind.Title.Text = KeybindSettings.Name
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
								{ Transparency = 0 }):Play()
						end
					else
						task.wait(0.25)
						if Held then
							local Loop; Loop = RunService.Stepped:Connect(function()
								if not Held then
									KeybindSettings.Callback(false) -- maybe pcall this
									Loop:Disconnect()
								else
									KeybindSettings.Callback(true) -- maybe pcall this
								end
							end)
						end
					end
				end
			end)
			table.insert(keybindConnections, connection)

			Keybind.KeybindFrame.KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Keybind.KeybindFrame,
					TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30) }):Play()
			end)

			function KeybindSettings:Set(NewKeybind)
				Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeybind)
				KeybindSettings.CurrentKeybind = tostring(NewKeybind)
				Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
				if not KeybindSettings.Ext then
					SaveConfiguration()
				end

				if KeybindSettings.CallOnChange then
					KeybindSettings.Callback(tostring(NewKeybind))
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and KeybindSettings.Flag then
					RayfieldLibrary.Flags[KeybindSettings.Flag] = KeybindSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return KeybindSettings
		end

		-- Toggle
		function Tab:CreateToggle(ToggleSettings)
			local ToggleValue = {}
			local siaHandle = siaElement("toggle", ToggleSettings.Name, siaTab)
			siaSetState(siaHandle, ToggleSettings.CurrentValue == true and 1 or 0)

			local Toggle = Elements.Template.Toggle:Clone()
			Toggle.Name = ToggleSettings.Name
			Toggle.Title.Text = ToggleSettings.Name
			Toggle.Visible = true
			Toggle.Parent = TabPage

			Toggle.BackgroundTransparency = 1
			Toggle.UIStroke.Transparency = 1
			Toggle.Title.TextTransparency = 1
			Toggle.Switch.BackgroundColor3 = SelectedTheme.ToggleBackground

			if SelectedTheme ~= RayfieldLibrary.Theme.Default then
				Toggle.Switch.Shadow.Visible = false
			end

			TweenService:Create(Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Transparency = 0 })
				:Play()
			TweenService:Create(Toggle.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
				:Play()

			if ToggleSettings.CurrentValue == true then
				Toggle.Switch.Indicator.Position = UDim2.new(1, -20, 0.5, 0)
				Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleEnabledStroke
				Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleEnabled
				Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleEnabledOuterStroke
			else
				Toggle.Switch.Indicator.Position = UDim2.new(1, -40, 0.5, 0)
				Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
				Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
				Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleDisabledOuterStroke
			end

			Toggle.MouseEnter:Connect(function()
				TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
			end)

			Toggle.MouseLeave:Connect(function()
				TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
			end)

			Toggle.Interact.MouseButton1Click:Connect(function()
				if ToggleSettings.CurrentValue == true then
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Position = UDim2.new(1, -40, 0.5, 0) }):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleDisabledStroke }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ BackgroundColor3 = SelectedTheme.ToggleDisabled }):Play()
					TweenService:Create(Toggle.Switch.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleDisabledOuterStroke }):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				else
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Position = UDim2.new(1, -20, 0.5, 0) }):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleEnabledStroke }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ BackgroundColor3 = SelectedTheme.ToggleEnabled }):Play()
					TweenService:Create(Toggle.Switch.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleEnabledOuterStroke }):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end

				siaUsed(siaHandle, ToggleSettings.CurrentValue and "on" or "off", ToggleSettings.CurrentValue and 1 or 0)
				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \'' .. ToggleSettings.Name .. '\' (Interact)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					siaError(siaHandle)
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					Toggle.Title.Text = "Callback Error"
					print("Rayfield | " .. ToggleSettings.Name .. " Callback Error " .. tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end)

			function ToggleSettings:Set(NewToggleValue)
				if NewToggleValue == true then
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Position = UDim2.new(1, -20, 0.5, 0) }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(0, 12, 0, 12) }):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleEnabledStroke }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ BackgroundColor3 = SelectedTheme.ToggleEnabled }):Play()
					TweenService:Create(Toggle.Switch.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleEnabledOuterStroke }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(0, 17, 0, 17) }):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				else
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Position = UDim2.new(1, -40, 0.5, 0) }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(0, 12, 0, 12) }):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleDisabledStroke }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ BackgroundColor3 = SelectedTheme.ToggleDisabled }):Play()
					TweenService:Create(Toggle.Switch.UIStroke,
						TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{ Color = SelectedTheme.ToggleDisabledOuterStroke }):Play()
					TweenService:Create(Toggle.Switch.Indicator,
						TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Size = UDim2.new(0, 17, 0, 17) }):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end

				siaSetState(siaHandle, ToggleSettings.CurrentValue and 1 or 0)
				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \'' .. ToggleSettings.Name .. '\' (:Set)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					siaError(siaHandle)
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					Toggle.Title.Text = "Callback Error"
					print("Rayfield | " .. ToggleSettings.Name .. " Callback Error " .. tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end

			if not ToggleSettings.Ext then
				if Settings.ConfigurationSaving then
					if Settings.ConfigurationSaving.Enabled and ToggleSettings.Flag then
						RayfieldLibrary.Flags[ToggleSettings.Flag] = ToggleSettings
					end
				end
			end


			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Toggle.Switch.BackgroundColor3 = SelectedTheme.ToggleBackground

				if SelectedTheme ~= RayfieldLibrary.Theme.Default then
					Toggle.Switch.Shadow.Visible = false
				end

				task.wait()

				if not ToggleSettings.CurrentValue then
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleDisabledOuterStroke
				else
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleEnabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleEnabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleEnabledOuterStroke
				end
			end)

			return ToggleSettings
		end

		-- Slider
		function Tab:CreateSlider(SliderSettings)
			local SLDragging = false
			local activeSliderInput = nil
			local sliderLoop = nil
			local siaHandle = siaElement("slider", SliderSettings.Name, siaTab)
			-- where a value sits in the slider's range, 0..1
			local function siaPosition(value)
				local span = SliderSettings.Range[2] - SliderSettings.Range[1]
				if span > 0 then
					return (value - SliderSettings.Range[1]) / span
				end
				return 0
			end
			siaSetState(siaHandle, siaPosition(SliderSettings.CurrentValue))
			local Slider = Elements.Template.Slider:Clone()
			Slider.Name = SliderSettings.Name
			Slider.Title.Text = SliderSettings.Name
			Slider.Visible = true
			Slider.Parent = TabPage

			Slider.BackgroundTransparency = 1
			Slider.UIStroke.Transparency = 1
			Slider.Title.TextTransparency = 1

			if SelectedTheme ~= RayfieldLibrary.Theme.Default then
				Slider.Main.Shadow.Visible = false
			end

			Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground
			Slider.Main.UIStroke.Color = SelectedTheme.SliderStroke
			Slider.Main.Progress.UIStroke.Color = SelectedTheme.SliderStroke
			Slider.Main.Progress.BackgroundColor3 = SelectedTheme.SliderProgress

			TweenService:Create(Slider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
				:Play()
			TweenService:Create(Slider.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Transparency = 0 })
				:Play()
			TweenService:Create(Slider.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
				:Play()

			local function getUnscaledSliderWidth()
				local uiScale = (mainUIScale and mainUIScale.Scale > 0) and mainUIScale.Scale or 1
				local absW = Slider.Main.AbsoluteSize.X / uiScale
				if absW > 10 then
					return absW
				end
				return 220
			end

			local initialRatio = math.clamp(
				(SliderSettings.CurrentValue - SliderSettings.Range[1]) /
				math.max(SliderSettings.Range[2] - SliderSettings.Range[1], 0.0001), 0, 1)
			local initialPx = math.max(getUnscaledSliderWidth() * initialRatio, 5)
			Slider.Main.Progress.Size = UDim2.new(0, initialPx, 1, 0)

			if not SliderSettings.Suffix then
				Slider.Main.Information.Text = tostring(SliderSettings.CurrentValue)
			else
				Slider.Main.Information.Text = tostring(SliderSettings.CurrentValue) .. " " .. SliderSettings.Suffix
			end

			Slider.MouseEnter:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackgroundHover }):Play()
			end)

			Slider.MouseLeave:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
			end)

			local function getSliderPointerX()
				local screenGui = Slider:FindFirstAncestorWhichIsA("ScreenGui")
				local ignoreInset = screenGui and screenGui.IgnoreGuiInset or false
				local inset = GuiService and select(2, pcall(GuiService.GetGuiInset, GuiService)) or Vector2.zero
				if typeof(inset) ~= "Vector2" then inset = Vector2.zero end

				if activeSliderInput and activeSliderInput.UserInputType == Enum.UserInputType.Touch then
					if ignoreInset then
						return activeSliderInput.Position.X + inset.X
					end
					return activeSliderInput.Position.X
				end
				local mouseX = UserInputService:GetMouseLocation().X
				if ignoreInset then
					return mouseX
				end
				return mouseX - inset.X
			end

			local function stopSliderDrag()
				if not SLDragging then return end
				siaUsed(siaHandle, "set", siaPosition(SliderSettings.CurrentValue))
				TweenService:Create(Slider.Main.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ Transparency = 0.4 }):Play()
				TweenService:Create(Slider.Main.Progress.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ Transparency = 0.3 }):Play()
				SLDragging = false
				activeSliderInput = nil
				if TabPage and TabPage:IsA("ScrollingFrame") then
					TabPage.ScrollingEnabled = true
				end
			end

			local function startSliderDrag(inputObj)
				if SLDragging then return end
				SLDragging = true
				activeSliderInput = inputObj
				if TabPage and TabPage:IsA("ScrollingFrame") then
					TabPage.ScrollingEnabled = false
				end
				TweenService:Create(Slider.Main.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ Transparency = 1 }):Play()
				TweenService:Create(Slider.Main.Progress.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
					{ Transparency = 1 }):Play()

				local Location = getSliderPointerX()
				if sliderLoop then sliderLoop:Disconnect() end
				sliderLoop = RunService.RenderStepped:Connect(function()
					if SLDragging then
						Location = getSliderPointerX()
						local barStart = Slider.Main.AbsolutePosition.X
						local barWidth = math.max(Slider.Main.AbsoluteSize.X, 1)
						local clampedX = math.clamp(Location, barStart, barStart + barWidth)
						local ratio = math.clamp((clampedX - barStart) / barWidth, 0, 1)
						local targetPx = math.max(getUnscaledSliderWidth() * ratio, 5)

						TweenService:Create(Slider.Main.Progress,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{ Size = UDim2.new(0, targetPx, 1, 0) }):Play()
						local NewValue = SliderSettings.Range[1] +
							ratio * (SliderSettings.Range[2] - SliderSettings.Range[1])

						NewValue = math.floor(NewValue / SliderSettings.Increment + 0.5) *
							(SliderSettings.Increment * 10000000) / 10000000
						NewValue = math.clamp(NewValue, SliderSettings.Range[1], SliderSettings.Range[2])

						if not SliderSettings.Suffix then
							Slider.Main.Information.Text = tostring(NewValue)
						else
							Slider.Main.Information.Text = tostring(NewValue) .. " " .. SliderSettings.Suffix
						end

						if SliderSettings.CurrentValue ~= NewValue then
							siaSetState(siaHandle, siaPosition(NewValue))
							local Success, Response = pcall(function()
								SliderSettings.Callback(NewValue)
							end)
							if not Success then
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
									{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
									{ Transparency = 1 }):Play()
								Slider.Title.Text = "Callback Error"
								siaError(siaHandle)
								print("Rayfield | " .. SliderSettings.Name .. " Callback Error " .. tostring(Response))
								warn('Check docs.sirius.menu for help with Rayfield specific development.')
								task.wait(0.5)
								Slider.Title.Text = SliderSettings.Name
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
									{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
									{ Transparency = 0 }):Play()
							end

							SliderSettings.CurrentValue = NewValue
							if not SliderSettings.Ext then
								SaveConfiguration()
							end
						end
					else
						if sliderLoop then
							sliderLoop:Disconnect()
							sliderLoop = nil
						end
					end
				end)
			end

			Slider.Main.Interact.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					startSliderDrag(Input)
				end
			end)

			Slider.Main.Interact.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					stopSliderDrag()
				end
			end)

			local sliderInputEndedConn = UserInputService.InputEnded:Connect(function(Input)
				if SLDragging and (Input == activeSliderInput or Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
					stopSliderDrag()
				end
			end)

			Slider.Destroying:Connect(function()
				if sliderLoop then sliderLoop:Disconnect() end
				if sliderInputEndedConn then sliderInputEndedConn:Disconnect() end
			end)

			function SliderSettings:Set(NewVal)
				local NewVal = math.clamp(NewVal, SliderSettings.Range[1], SliderSettings.Range[2])
				local ratio = math.clamp(
					(NewVal - SliderSettings.Range[1]) /
					math.max(SliderSettings.Range[2] - SliderSettings.Range[1], 0.0001),
					0, 1)
				local targetPx = math.max(getUnscaledSliderWidth() * ratio, 5)

				TweenService:Create(Slider.Main.Progress,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{ Size = UDim2.new(0, targetPx, 1, 0) }):Play()
				Slider.Main.Information.Text = tostring(NewVal) .. " " .. (SliderSettings.Suffix or "")
				siaSetState(siaHandle, siaPosition(NewVal))

				local Success, Response = pcall(function()
					SliderSettings.Callback(NewVal)
				end)

				if not Success then
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = Color3.fromRGB(85, 0, 0) }):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 1 }):Play()
					Slider.Title.Text = "Callback Error"
					siaError(siaHandle)
					print("Rayfield | " .. SliderSettings.Name .. " Callback Error " .. tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Slider.Title.Text = SliderSettings.Name
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.ElementBackground }):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
						{ Transparency = 0 }):Play()
				end

				SliderSettings.CurrentValue = NewVal
				if not SliderSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and SliderSettings.Flag then
					RayfieldLibrary.Flags[SliderSettings.Flag] = SliderSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				if SelectedTheme ~= RayfieldLibrary.Theme.Default then
					Slider.Main.Shadow.Visible = false
				end

				Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground
				Slider.Main.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.BackgroundColor3 = SelectedTheme.SliderProgress
			end)

			return SliderSettings
		end

		Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			TabButton.UIStroke.Color = SelectedTheme.TabStroke

			if Elements.UIPageLayout.CurrentPage == TabPage then
				TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
				TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			else
				TabButton.BackgroundColor3 = SelectedTheme.TabBackground
				TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			end
		end)

		return Tab
	end

	Elements.Visible = true


	task.wait(1.1)
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
		{ Size = UDim2.new(0, 390, 0, 90) }):Play()
	task.wait(0.3)
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
		:Play()
	task.wait(0.1)
	TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{ Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475) }):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { ImageTransparency = 0.6 })
		:Play()

	Topbar.BackgroundTransparency = 1
	Topbar.Divider.Size = UDim2.new(0, 0, 0, 1)
	Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	Topbar.CornerRepair.BackgroundTransparency = 1
	Topbar.Title.TextTransparency = 1
	Topbar.Search.ImageTransparency = 1
	if Topbar:FindFirstChild('Settings') then
		Topbar.Settings.ImageTransparency = 1
	end
	Topbar.ChangeSize.ImageTransparency = 1
	Topbar.Hide.ImageTransparency = 1


	task.wait(0.5)
	Topbar.Visible = true
	TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
		{ BackgroundTransparency = 0 }):Play()
	task.wait(0.1)
	TweenService:Create(Topbar.Divider, TweenInfo.new(1, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, 1) })
		:Play()
	TweenService:Create(Topbar.Title, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { TextTransparency = 0 }):Play()
	task.wait(0.05)
	TweenService:Create(Topbar.Search, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { ImageTransparency = 0.8 })
		:Play()
	task.wait(0.05)
	if Topbar:FindFirstChild('Settings') then
		TweenService:Create(Topbar.Settings, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
			{ ImageTransparency = 0.8 })
			:Play()
		task.wait(0.05)
	end
	TweenService:Create(Topbar.ChangeSize, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { ImageTransparency = 0.8 })
		:Play()
	task.wait(0.05)
	TweenService:Create(Topbar.Hide, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { ImageTransparency = 0.8 }):Play()
	task.wait(0.3)

	if dragBar then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
			{ BackgroundTransparency = 0.7 }):Play()
	end

	function Window.ModifyTheme(NewTheme)
		local success = pcall(ChangeTheme, NewTheme)
		if not success then
			RayfieldLibrary:Notify({ Title = 'Unable to Change Theme', Content = 'We are unable find a theme on file.', Image = 4400704299 })
		else
			RayfieldLibrary:Notify({
				Title = 'Theme Changed',
				Content = 'Successfully changed theme to ' ..
					(typeof(NewTheme) == 'string' and NewTheme or 'Custom Theme') .. '.',
				Image = 4483362748
			})
		end
	end

	local success, result = pcall(function()
		createSettings(Window)
	end)

	if not success then warn('Rayfield had an issue creating settings.') end

	-- Report after createSettings so loadSettings() has run and usageAnalytics reflects the user's saved preference
	if analyticsAllowed() and loadReporter() then
		local themeName = "Default"
		if Settings.Theme then
			if type(Settings.Theme) == "string" then
				themeName = Settings.Theme
			elseif type(Settings.Theme) == "table" then
				themeName = "Custom"
			end
		end

		local discordInvite = nil
		if Settings.Discord and Settings.Discord.Enabled and Settings.Discord.Invite and Settings.Discord.Invite ~= "" then
			local raw = tostring(Settings.Discord.Invite)
			-- Normalize: strip URL prefixes to extract just the invite code
			discordInvite = (raw:match("discord%.gg/([%w%-]+)") or raw:match("discord%.com/invite/([%w%-]+)") or raw)
				:sub(1, 32)
		end

		local sampleSend = false

		-- Random Sampling Test
		if not Settings.ScriptID and math.random() > 0.4 then
			sampleSend = true
		end

		--if Settings.ScriptID then
		reporter:windowCreated({
			script_name        = Settings.Name or "Unknown",
			script_version     = Release,
			interface_version  = InterfaceBuild,
			theme              = themeName,
			is_mobile          = useMobileSizing and true or false,
			has_key_system     = Settings.KeySystem and true or false,
			discord_invite     = discordInvite,
			config_saving      = (Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled) and true or
				false,
			script_id          = Settings.ScriptID or sampleSend and 'sid_tzfyxawonjx9' or nil,
			verification_token = Settings.VerificationToken,
		})
		--end
	end

	return Window
end

local function setVisibility(visibility, notify)
	if Debounce then return end
	if visibility then
		Hidden = false
		Unhide()
	else
		Hidden = true
		Hide(notify)
	end
end

function RayfieldLibrary:SetVisibility(visibility)
	setVisibility(visibility, false)
end

function RayfieldLibrary:IsVisible()
	return not Hidden
end

local hideHotkeyConnection -- Has to be initialized here since the connection is made later in the script
function RayfieldLibrary:Destroy()
	rayfieldDestroyed = true
	siaCall("window", "close")
	-- stops the kick watcher the reporter armed, so nothing is sent for a window that's gone
	if reporter and reporter.disable then
		pcall(reporter.disable, reporter)
	end
	if hideHotkeyConnection then
		hideHotkeyConnection:Disconnect()
	end
	for _, connection in ipairs(keybindConnections) do
		connection:Disconnect()
	end
	Rayfield:Destroy()
end

Topbar.ChangeSize.MouseButton1Click:Connect(function()
	if Debounce then return end
	if Minimised then
		Minimised = false
		Maximise()
	else
		Minimised = true
		Minimise()
	end
end)

Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()
	if #Main.Search.Input.Text > 0 then
		if not Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks') then
			local searchTitle = Elements.Template.SectionTitle:Clone()
			searchTitle.Parent = Elements.UIPageLayout.CurrentPage
			searchTitle.Name = 'SearchTitle-fsefsefesfsefesfesfThanks'
			searchTitle.LayoutOrder = -100
			searchTitle.Title.Text = "Results from '" .. Elements.UIPageLayout.CurrentPage.Name .. "'"
			searchTitle.Visible = true
		end
	else
		local searchTitle = Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks')

		if searchTitle then
			searchTitle:Destroy()
		end
	end

	for _, element in ipairs(Elements.UIPageLayout.CurrentPage:GetChildren()) do
		if element.ClassName ~= 'UIListLayout' and element.Name ~= 'Placeholder' and element.Name ~= 'SearchTitle-fsefsefesfsefesfesfThanks' then
			if element.Name == 'SectionTitle' then
				if #Main.Search.Input.Text == 0 then
					element.Visible = true
				else
					element.Visible = false
				end
			else
				if string.lower(element.Name):find(string.lower(Main.Search.Input.Text), 1, true) then
					element.Visible = true
				else
					element.Visible = false
				end
			end
		end
	end
end)

Main.Search.Input.FocusLost:Connect(function(enterPressed)
	if #Main.Search.Input.Text == 0 and searchOpen then
		task.wait(0.12)
		closeSearch()
	end
end)

Topbar.Search.MouseButton1Click:Connect(function()
	task.spawn(function()
		if searchOpen then
			closeSearch()
		else
			openSearch()
		end
	end)
end)

if Topbar:FindFirstChild('Settings') then
	Topbar.Settings.MouseButton1Click:Connect(function()
		task.spawn(function()
			for _, OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton.Name ~= "Placeholder" then
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ BackgroundColor3 = SelectedTheme.TabBackground }):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ TextColor3 = SelectedTheme.TabTextColor }):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ ImageColor3 = SelectedTheme.TabTextColor }):Play()
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ BackgroundTransparency = 0.7 }):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ TextTransparency = 0.2 }):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ ImageTransparency = 0.2 }):Play()
					TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
						{ Transparency = 0.5 }):Play()
				end
			end

			siaCurrentTab = nil
			Elements.UIPageLayout:JumpTo(Elements['Rayfield Settings'])
		end)
	end)
end


Topbar.Hide.MouseButton1Click:Connect(function()
	setVisibility(Hidden, not useMobileSizing)
end)

hideHotkeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if rayfieldDestroyed or processed then return end
	local openKey = getSetting("General", "rayfieldOpen")
	local ok, keyCode = pcall(function()
		return openKey and Enum.KeyCode[openKey] or nil
	end)
	if ok and keyCode and input.KeyCode == keyCode then
		if Debounce then return end
		if Hidden then
			Hidden = false
			Unhide()
		else
			Hidden = true
			Hide()
		end
	end
end)

if MPrompt then
	MPrompt.Interact.MouseButton1Click:Connect(function()
		if Debounce then return end
		if Hidden then
			Hidden = false
			Unhide()
		end
	end)
end

for _, TopbarButton in ipairs(Topbar:GetChildren()) do
	if TopbarButton.ClassName == "ImageButton" and TopbarButton.Name ~= 'Icon' then
		TopbarButton.MouseEnter:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
				:Play()
		end)

		TopbarButton.MouseLeave:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential),
				{ ImageTransparency = 0.8 })
				:Play()
		end)
	end
end


function RayfieldLibrary:LoadConfiguration()
	local config

	if debugX then
		warn('Loading Configuration')
	end

	if useStudio then
		config =
		[[{"Toggle1adwawd":true,"ColorPicker1awd":{"B":255,"G":255,"R":255},"Slider1dawd":100,"ColorPicfsefker1":{"B":255,"G":255,"R":255},"Slidefefsr1":80,"dawdawd":"","Input1":"hh","Keybind1":"B","Dropdown1":["Ocean"]}]]
	end

	if CEnabled then
		local notified
		local loaded

		local success, result = pcall(function()
			if useStudio and config then
				loaded = LoadConfiguration(config)
				return
			end

			if isfile then
				local configPath = ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension
				if CLegacyFileName and not callSafely(isfile, configPath) then
					local legacyPath = ConfigurationFolder .. "/" .. CLegacyFileName .. ConfigurationExtension
					if callSafely(isfile, legacyPath) then
						configPath = legacyPath
					end
				end
				if callSafely(isfile, configPath) then
					loaded = LoadConfiguration(callSafely(readfile, configPath))
				end
			else
				notified = true
				RayfieldLibrary:Notify({
					Title = "Rayfield Configurations",
					Content =
					"We couldn't enable Configuration Saving as you are not using software with filesystem support.",
					Image = 4384402990
				})
			end
		end)

		if success and loaded and not notified then
			RayfieldLibrary:Notify({
				Title = "Rayfield Configurations",
				Content =
				"The configuration file for this script has been loaded from a previous session.",
				Image = 4384403532
			})
		elseif not success and not notified then
			warn('Rayfield Configurations Error | ' .. tostring(result))
			RayfieldLibrary:Notify({
				Title = "Rayfield Configurations",
				Content =
				"We've encountered an issue loading your configuration correctly.\n\nCheck the Developer Console for more information.",
				Image = 4384402990
			})
		end
	end

	globalLoaded = true
end

if useStudio then
	-- run w/ studio
	-- Feel free to place your own script here to see how it'd work in Roblox Studio before running it on your execution software.


	--local Window = RayfieldLibrary:CreateWindow({
	--	Name = "Rayfield Example Window",
	--	LoadingTitle = "Rayfield Interface Suite",
	--	Theme = 'Default',
	--	Icon = 0,
	--	LoadingSubtitle = "by Sirius",
	--	ConfigurationSaving = {
	--		Enabled = true,
	--		FolderName = nil, -- Create a custom folder for your hub/game
	--		FileName = "Big Hub52"
	--	},
	--	Discord = {
	--		Enabled = false,
	--		Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
	--		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	--	},
	--	KeySystem = false, -- Set this to true to use our key system
	--	KeySettings = {
	--		Title = "Untitled",
	--		Subtitle = "Key System",
	--		Note = "No method of obtaining the key is provided",
	--		FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
	--		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
	--		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
	--		Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
	--	}
	--})

	--local Tab = Window:CreateTab("Tab Example", 'key-round') -- Title, Image
	--local Tab2 = Window:CreateTab("Tab Example 2", 4483362458) -- Title, Image

	--local Section = Tab2:CreateSection("Section")


	--local ColorPicker = Tab2:CreateColorPicker({
	--	Name = "Color Picker",
	--	Color = Color3.fromRGB(255,255,255),
	--	Flag = "ColorPicfsefker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider = Tab2:CreateSlider({
	--	Name = "Slider Example",
	--	Range = {0, 100},
	--	Increment = 10,
	--	Suffix = "Bananas",
	--	CurrentValue = 40,
	--	Flag = "Slidefefsr1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input = Tab2:CreateInput({
	--	Name = "Input Example",
	--	CurrentValue = '',
	--	PlaceholderText = "Input Placeholder",
	--	Flag = 'dawdawd',
	--	RemoveTextAfterFocusLost = false,
	--	Callback = function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})


	----RayfieldLibrary:Notify({Title = "Rayfield Interface", Content = "Welcome to Rayfield. These - are the brand new notification design for Rayfield, with custom sizing and Rayfield calculated wait times.", Image = 4483362458})

	--local Section = Tab:CreateSection("Section Example")

	--local Button = Tab:CreateButton({
	--	Name = "Change Theme",
	--	Callback = function()
	--		-- The function that takes place when the button is pressed
	--		Window.ModifyTheme('DarkBlue')
	--	end,
	--})

	--local Toggle = Tab:CreateToggle({
	--	Name = "Toggle Example",
	--	CurrentValue = false,
	--	Flag = "Toggle1adwawd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the toggle is pressed
	--		-- The variable (Value) is a boolean on whether the toggle is true or false
	--	end,
	--})

	--local ColorPicker = Tab:CreateColorPicker({
	--	Name = "Color Picker",
	--	Color = Color3.fromRGB(255,255,255),
	--	Flag = "ColorPicker1awd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider = Tab:CreateSlider({
	--	Name = "Slider Example",
	--	Range = {0, 100},
	--	Increment = 10,
	--	Suffix = "Bananas",
	--	CurrentValue = 40,
	--	Flag = "Slider1dawd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input = Tab:CreateInput({
	--	Name = "Input Example",
	--	CurrentValue = "Helo",
	--	PlaceholderText = "Adaptive Input",
	--	RemoveTextAfterFocusLost = false,
	--	Flag = 'Input1',
	--	Callback = function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})

	--local thoptions = {}
	--for themename, theme in pairs(RayfieldLibrary.Theme) do
	--	table.insert(thoptions, themename)
	--end

	--local Dropdown = Tab:CreateDropdown({
	--	Name = "Theme",
	--	Options = thoptions,
	--	CurrentOption = {"Default"},
	--	MultipleOptions = false,
	--	Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Options)
	--		--Window.ModifyTheme(Options[1])
	--		-- The function that takes place when the selected option is changed
	--		-- The variable (Options) is a table of strings for the current selected options
	--	end,
	--})


	--Window.ModifyTheme({
	--	TextColor = Color3.fromRGB(50, 55, 60),
	--	Background = Color3.fromRGB(240, 245, 250),
	--	Topbar = Color3.fromRGB(215, 225, 235),
	--	Shadow = Color3.fromRGB(200, 210, 220),

	--	NotificationBackground = Color3.fromRGB(210, 220, 230),
	--	NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

	--	TabBackground = Color3.fromRGB(200, 210, 220),
	--	TabStroke = Color3.fromRGB(180, 190, 200),
	--	TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
	--	TabTextColor = Color3.fromRGB(50, 55, 60),
	--	SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

	--	ElementBackground = Color3.fromRGB(210, 220, 230),
	--	ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
	--	SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
	--	ElementStroke = Color3.fromRGB(190, 200, 210),
	--	SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

	--	SliderBackground = Color3.fromRGB(200, 220, 235),  -- Lighter shade
	--	SliderProgress = Color3.fromRGB(70, 130, 180),
	--	SliderStroke = Color3.fromRGB(150, 180, 220),

	--	ToggleBackground = Color3.fromRGB(210, 220, 230),
	--	ToggleEnabled = Color3.fromRGB(70, 160, 210),
	--	ToggleDisabled = Color3.fromRGB(180, 180, 180),
	--	ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
	--	ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
	--	ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
	--	ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

	--	DropdownSelected = Color3.fromRGB(220, 230, 240),
	--	DropdownUnselected = Color3.fromRGB(200, 210, 220),

	--	InputBackground = Color3.fromRGB(220, 230, 240),
	--	InputStroke = Color3.fromRGB(180, 190, 200),
	--	PlaceholderColor = Color3.fromRGB(150, 150, 150)
	--})

	--local Keybind = Tab:CreateKeybind({
	--	Name = "Keybind Example",
	--	CurrentKeybind = "Q",
	--	HoldToInteract = false,
	--	Flag = "Keybind1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Keybind)
	--		-- The function that takes place when the keybind is pressed
	--		-- The variable (Keybind) is a boolean for whether the keybind is being held or not (HoldToInteract needs to be true)
	--	end,
	--})

	--local Label = Tab:CreateLabel("Label Example")

	--local Label2 = Tab:CreateLabel("Warning", 4483362458, Color3.fromRGB(255, 159, 49),  true)

	--local Paragraph = Tab:CreateParagraph({Title = "Paragraph Example", Content = "Paragraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph Example"})
end

if CEnabled and Main:FindFirstChild('Notice') then
	Main.Notice.BackgroundTransparency = 1
	Main.Notice.Title.TextTransparency = 1
	Main.Notice.Size = UDim2.new(0, 0, 0, 0)
	Main.Notice.Position = UDim2.new(0.5, 0, 0, -100)
	Main.Notice.Visible = true


	TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
		{ Size = UDim2.new(0, 280, 0, 35), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 0.5 }):Play()
	TweenService:Create(Main.Notice.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { TextTransparency = 0.1 })
		:Play()
end
-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA why :(
--if not useStudio then
--	task.spawn(loadWithTimeout, "https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/boost.lua")
--end

task.delay(4, function()
	RayfieldLibrary.LoadConfiguration()
	if Main:FindFirstChild('Notice') and Main.Notice.Visible then
		TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
			{ Size = UDim2.new(0, 100, 0, 25), Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1 }):Play()
		TweenService:Create(Main.Notice.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
			:Play()

		task.wait(0.5)
		Main.Notice.Visible = false
	end
end)

if getgenv then
	pcall(function()
		getgenv().RayfieldLibrary = RayfieldLibrary
	end)
end

-- Auto-launch HaiAnh Menu Multi-Game Script Window + Floating Toggle Button when main.lua is executed directly
local libraryOnly = false
if getgenv then
	local ok, val = pcall(function() return getgenv().RAYFIELD_LIBRARY_ONLY end)
	if ok and val then libraryOnly = true end
end

if not libraryOnly then
	task.spawn(function()
		local ReplicatedStorage = getService("ReplicatedStorage")
		local VirtualInputManager = getService("VirtualInputManager")
		local VirtualUser = getService("VirtualUser")
		local MarketplaceService = getService("MarketplaceService")

		-- ============================================================================
		-- 1. ANTI-BAN & TELEMETRY SHIELD ENGINE (VIOLET HUB & TEKKIT HUB VIP MECHANISM)
		-- ============================================================================
		local AntiBanShield = {
			Enabled = true,
			BlockedCount = 0,
			LastBlockedRemote = "None",
		}

		local DetectionKeywords = {
			"ban", "detect", "anticheat", "security", "flag", "telemetry",
			"exploit", "kick", "tamper", "report", "cheat", "suspicious",
			"unusual", "illegal", "speedhack", "nofall", "flyhack", "abnormal",
			"damagecheck", "checkdamage", "integrity"
		}

		-- Hook metamethod __namecall to intercept and drop client-side detection reports
		pcall(function()
			if hookmetamethod then
				local oldNamecall
				oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
					local method = getnamecallmethod()
					if AntiBanShield.Enabled and (method == "FireServer" or method == "InvokeServer") then
						local remoteName = string.lower(tostring(self.Name))
						for _, kw in ipairs(DetectionKeywords) do
							if string.find(remoteName, kw, 1, true) then
								AntiBanShield.BlockedCount = AntiBanShield.BlockedCount + 1
								AntiBanShield.LastBlockedRemote = tostring(self.Name)
								return nil
							end
						end

						local args = { ... }
						for _, arg in ipairs(args) do
							if type(arg) == "string" then
								local lowerArg = string.lower(arg)
								for _, kw in ipairs(DetectionKeywords) do
									if string.find(lowerArg, kw, 1, true) then
										AntiBanShield.BlockedCount = AntiBanShield.BlockedCount + 1
										AntiBanShield.LastBlockedRemote = tostring(self.Name) .. " [" .. arg .. "]"
										return nil
									end
								end
							end
						end
					end
					return oldNamecall(self, ...)
				end))
			end
		end)

		-- Hook LocalPlayer:Kick to prevent client scripts from kicking the user
		pcall(function()
			if hookfunction and Players and Players.LocalPlayer then
				local oldKick
				oldKick = hookfunction(Players.LocalPlayer.Kick, newcclosure(function(self, ...)
					if AntiBanShield.Enabled then
						AntiBanShield.BlockedCount = AntiBanShield.BlockedCount + 1
						AntiBanShield.LastBlockedRemote = "LocalPlayer:Kick"
						return nil
					end
					return oldKick(self, ...)
				end))
			end
		end)

		-- ============================================================================
		-- 2. AUTO GAME DETECTION
		-- ============================================================================
		local AOTR_GAME_ID = 4658598196
		local AOTR_PLACES = {
			[13379208636] = true,
			[14214532675] = true,
		}

		local BLOX_FRUITS_GAME_ID = 994732206
		local BLOX_FRUITS_PLACES = {
			[2753915549] = true,
			[4442272183] = true,
			[7449423635] = true,
		}

		local function detectCurrentGame()
			local pId = game.PlaceId
			local gId = game.GameId

			if AOTR_PLACES[pId] or gId == AOTR_GAME_ID then
				return "AOTR"
			end
			if BLOX_FRUITS_PLACES[pId] or gId == BLOX_FRUITS_GAME_ID then
				return "BLOX_FRUITS"
			end

			local title = ""
			pcall(function()
				local product = MarketplaceService:GetProductInfo(pId)
				if product and product.Name then
					title = string.lower(product.Name)
				end
			end)

			if string.find(title, "attack on titan", 1, true) or string.find(title, "revolution", 1, true) or string.find(title, "aotr", 1, true) then
				return "AOTR"
			end
			if string.find(title, "blox fruits", 1, true) or string.find(title, "bloxfruits", 1, true) then
				return "BLOX_FRUITS"
			end

			return "UNIVERSAL"
		end

		-- ============================================================================
		-- 3. FLOATING TOGGLE BUTTON (DRAGGABLE & MOBILE FRIENDLY)
		-- ============================================================================
		local rayfieldDestroyed = false

		local function createFloatingToggle()
			local CoreGui = getService("CoreGui")
			local UserInputService = getService("UserInputService")
			local TweenService = getService("TweenService")
			local lp = Players and Players.LocalPlayer
			local targetParent = CoreGui
			if not pcall(function() return CoreGui:GetChildren() end) then
				targetParent = (lp and lp:FindFirstChildOfClass("PlayerGui")) or CoreGui
			end

			local existing = targetParent:FindFirstChild("HaiAnhFloatingToggle")
			if existing then existing:Destroy() end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "HaiAnhFloatingToggle"
			screenGui.ResetOnSpawn = false
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

			local btn = Instance.new("TextButton")
			btn.Name = "ToggleButton"
			btn.Size = UDim2.new(0, 50, 0, 50)
			btn.Position = UDim2.new(0.04, 0, 0.28, 0)
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
			btn.Text = "HA"
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 16
			btn.AutoButtonColor = false
			btn.Parent = screenGui

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 14)
			corner.Parent = btn

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(170, 95, 255)
			stroke.Thickness = 2.2
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Parent = btn

			local dragging = false
			local dragInput, dragStart, startPos

			btn.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = btn.Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)

			btn.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if input == dragInput and dragging then
					local delta = input.Position - dragStart
					btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
						startPos.Y.Offset + delta.Y)
				end
			end)

			btn.MouseButton1Click:Connect(function()
				pcall(function()
					local mainGui = CoreGui:FindFirstChild("Rayfield") or
						(lp and lp:FindFirstChildOfClass("PlayerGui") and lp:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Rayfield"))
					if mainGui then
						mainGui.Enabled = not mainGui.Enabled
					end
				end)
			end)

			pcall(function() screenGui.Parent = targetParent end)
		end

		local function clickGuiButton(btn)
			if not btn then return false end
			pcall(function()
				if getconnections then
					for _, c in ipairs(getconnections(btn.MouseButton1Click)) do
						if c.Function then c.Function() end
					end
					for _, c in ipairs(getconnections(btn.Activated)) do
						if c.Function then c.Function() end
					end
				end
				local vp = (Workspace and Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or
					Vector2.new(1280, 720)
				local absPos = btn.AbsolutePosition
				local absSz = btn.AbsoluteSize
				local cx = absPos.X + absSz.X / 2
				local cy = absPos.Y + absSz.Y / 2
				if VirtualInputManager then
					VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
					task.wait(0.005)
					VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
				end
			end)
			return true
		end

		-- Hệ thống cache GUI Button & Durability Bar: Quét 1 lần mỗi 3 giây, triệt tiêu 100% giật lag FPS
		local cachedGuiState = {
			m1 = nil,
			reload = nil,
			durabilityBar = nil,
			skills = {},
			lastScan = 0
		}

		local function refreshCachedGuiElements(force)
			local now = os.clock()
			if not force and (now - cachedGuiState.lastScan < 3.5) and cachedGuiState.m1 and cachedGuiState.m1.Parent then
				return
			end
			cachedGuiState.lastScan = now
			local lp = Players and Players.LocalPlayer
			local pgui = lp and lp:FindFirstChildOfClass("PlayerGui")
			if not pgui then return end

			cachedGuiState.skills = {}
			cachedGuiState.buttons = {}
			for _, obj in ipairs(pgui:GetDescendants()) do
				if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
					local name = string.lower(obj.Name)
					local text = obj:IsA("TextButton") and string.lower(obj.Text) or ""
					local childLabel = obj:FindFirstChildWhichIsA("TextLabel", true)
					if childLabel and childLabel.Text ~= "" then
						text = text .. " " .. string.lower(childLabel.Text)
					end
					local combined = name .. " " .. text
					table.insert(cachedGuiState.buttons, { btn = obj, text = combined })
					if string.find(combined, "m1", 1, true) or string.find(combined, "slash", 1, true) or string.find(combined, "attack", 1, true) then
						if not cachedGuiState.m1 or not cachedGuiState.m1.Parent then
							cachedGuiState.m1 = obj
						end
					end
					if string.find(combined, "reload", 1, true) or string.find(combined, "nạp", 1, true) or string.find(combined, "nap", 1, true) then
						if not cachedGuiState.reload or not cachedGuiState.reload.Parent then
							cachedGuiState.reload = obj
						end
					end
					if string.find(combined, "skill", 1, true) or string.find(combined, "slot", 1, true) then
						table.insert(cachedGuiState.skills, obj)
					end
				elseif obj:IsA("Frame") or obj:IsA("ImageLabel") then
					local oName = string.lower(obj.Name)
					if string.find(oName, "durab", 1, true) or string.find(oName, "bladebar", 1, true) or string.find(oName, "sharp", 1, true) then
						cachedGuiState.durabilityBar = obj
					end
				end
			end
		end

		local function clickGuiButtonFast(btn)
			if not btn or not btn.Parent then return false end
			pcall(function()
				local fired = false
				if firesignal then
					if btn.Activated then firesignal(btn.Activated); fired = true end
					if btn.MouseButton1Click then firesignal(btn.MouseButton1Click); fired = true end
					if btn.MouseButton1Down then firesignal(btn.MouseButton1Down); fired = true end
					if btn.MouseButton1Up then firesignal(btn.MouseButton1Up); fired = true end
				end
				if not fired and VirtualUser then
					local absPos = btn.AbsolutePosition
					local absSz = btn.AbsoluteSize
					VirtualUser:ClickButton1(Vector2.new(absPos.X + absSz.X / 2, absPos.Y + absSz.Y / 2))
				end
			end)
			return true
		end

		local lastActionScan = 0
		local function triggerActionButtons(keywords)
			-- Popup như Retry, Start, Claim xuất hiện động: làm mới cache tối đa mỗi 1.5 giây
			if os.clock() - lastActionScan > 1.5 then
				lastActionScan = os.clock()
				refreshCachedGuiElements(true)
			end
			local triggered = false
			for _, entry in ipairs(cachedGuiState.buttons or {}) do
				local obj = entry.btn
				if obj and obj.Parent and obj.Visible then
					for _, kw in ipairs(keywords) do
						if string.find(entry.text, kw, 1, true) then
							clickGuiButtonFast(obj)
							triggered = true
							break
						end
					end
				end
			end
			return triggered
		end

		-- Kích hoạt nút M1 chém siêu tốc 0 delay không tốn CPU
		local function triggerMobileM1Attack()
			refreshCachedGuiElements(false)
			if cachedGuiState.m1 and cachedGuiState.m1.Parent and cachedGuiState.m1.Visible then
				clickGuiButtonFast(cachedGuiState.m1)
				return true
			end
			return false
		end

		-- Kích hoạt chém vũ khí trực tiếp
		local function activateEquippedTool()
			local lp = Players and Players.LocalPlayer
			local char = lp and lp.Character
			if char then
				local tool = char:FindFirstChildOfClass("Tool")
				if tool then
					pcall(function() tool:Activate() end)
				end
			end
		end

		-- ============================================================================
		-- MENU 1: ATTACK ON TITAN: REVOLUTION (FULL 6-TAB EDITION)
		-- 100% Rayfield UI - Exactly matching all requested features & tab structures
		-- ============================================================================
		local function loadAOTRMenu()
			local HttpService = getService("HttpService")
			local TeleportService = getService("TeleportService")
			local VirtualInputManager = getService("VirtualInputManager")
			local RunService = getService("RunService")
			local ReplicatedStorage = getService("ReplicatedStorage")
			local LocalPlayer = Players.LocalPlayer

			-- File System Helpers for Config System
			local isfile = isfile or function() return false end
			local isfolder = isfolder or function() return false end
			local makefolder = makefolder or function() end
			local writefile = writefile or function() end
			local readfile = readfile or function() return "" end
			local listfiles = listfiles or function() return {} end

			local configFolder = "HaiAnhMenuConfig/AOTR"
			pcall(function()
				if makefolder then
					if not isfolder("HaiAnhMenuConfig") then makefolder("HaiAnhMenuConfig") end
					if not isfolder(configFolder) then makefolder(configFolder) end
				end
			end)

			-- Master Configuration Table
			local AOTConfig = {
				-- Tab 1: Main (Auto Farm)
				AutoFarm = false,
				AutoKillSafe = false,
				AutoMastery = false,
				MoveMode = "Teleport", -- "Teleport" or "Hover"
				StartDelay = 5,
				HoverSpeed = 250,
				FloatHeight = 250,

				-- Tab 1: Main (Misc)
				AutoEscape = false,
				AntiInjuries = false,
				AutoRetry = false,
				AutoReload = false,
				AutoRefill = false,
				RemoveDmgText = false,
				AutoHideUI = false,
				FailSafe = false,
				Noclip = false,

				-- Tab 2: Raids
				AutoRaid = false,
				RaidHoverSpeed = 250,
				AutoSkipCutscene = false,
				AutoOpenChests = false,

				-- Tab 4: Webhook
				SendWebhook = false,
				DisplayUsername = true,
				PingSpecialOnly = false,
				WebhookURL = "",

				-- Tab 5: Visual
				TitanESP = false,
				ESPColor = Color3.fromRGB(255, 0, 0),
				OptimizeGame = false,
				DeleteMap = false,

				-- Tab 6: Config
				CurrentConfigName = "Default",
			}

			-- Real-time Session Stats Table
			local SessionStats = {
				Gold = "0",
				XP = "0",
				Gems = "0",
				BP_XP = "0",
				TotalDamage = "0",
				TitansKilled = "0",
				CriticalHits = "0",
				MissionsCompleted = "0",
				CommonPerks = "0",
				RarePerks = "0",
				EpicPerks = "0",
				LegendaryPerks = "0",
				PrestigeScrolls = "0",
				MythicalPerks = "0",
				Serum = "0",
				Scarfs = "0",
				LastUpdated = "Never"
			}

			-- Forward declarations
			local updateStatsUI
			local sendDiscordWebhook
			local updateConfigDropdown
			local configDropdownRef

			-- Create Rayfield Window
			local Window = RayfieldLibrary:CreateWindow({
				Name = "HaiAnh Menu | Attack on Titan: Revolution",
				LoadingTitle = "HaiAnh Menu",
				LoadingSubtitle = "Attack on Titan: Revolution",
				ConfigurationSaving = {
					Enabled = true,
					FolderName = "HaiAnhMenuConfig",
					FileName = "AOTRevolution"
				},
				KeySystem = false,
			})

			createFloatingToggle()

			-- ========================================================================
			-- 1. ⚔️ TAB MAIN (Auto Farm & Tiện ích sinh tồn)
			-- ========================================================================
			local MainTab = Window:CreateTab("Main (Farm & Tiện ích)", "swords")

			MainTab:CreateSection("Nhóm Auto Farm")

			MainTab:CreateToggle({
				Name = "Auto Farm",
				CurrentValue = false,
				Flag = "Lunar_AutoFarm",
				Callback = function(Value)
					AOTConfig.AutoFarm = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Auto Farm [Safer]",
				CurrentValue = false,
				Flag = "Lunar_AutoKillSafe",
				Callback = function(Value)
					AOTConfig.AutoKillSafe = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Auto Mastery",
				CurrentValue = false,
				Flag = "Lunar_AutoMastery",
				Callback = function(Value)
					AOTConfig.AutoMastery = Value
				end,
			})

			MainTab:CreateDropdown({
				Name = "Movement Mode",
				Options = { "Teleport", "Hover" },
				CurrentOption = { "Teleport" },
				MultipleOptions = false,
				Flag = "Lunar_MoveMode",
				Callback = function(Option)
					AOTConfig.MoveMode = type(Option) == "table" and Option[1] or Option
				end,
			})

			MainTab:CreateSlider({
				Name = "Farm Delay",
				Range = { 1, 50 },
				Increment = 1,
				Suffix = "s",
				CurrentValue = 5,
				Flag = "Lunar_FarmDelay",
				Callback = function(Value)
					AOTConfig.StartDelay = Value
				end,
			})

			MainTab:CreateSlider({
				Name = "Hover Speed",
				Range = { 50, 500 },
				Increment = 10,
				Suffix = "Speed",
				CurrentValue = 250,
				Flag = "Lunar_HoverSpeed",
				Callback = function(Value)
					AOTConfig.HoverSpeed = Value
				end,
			})

			MainTab:CreateSlider({
				Name = "Float Height",
				Range = { 50, 300 },
				Increment = 10,
				Suffix = "Studs",
				CurrentValue = 250,
				Flag = "Lunar_FloatHeight",
				Callback = function(Value)
					AOTConfig.FloatHeight = Value
				end,
			})

			MainTab:CreateSection("Nhóm Tiện ích sinh tồn (Misc)")

			MainTab:CreateToggle({
				Name = "Auto Escape",
				CurrentValue = false,
				Flag = "Lunar_AutoEscape",
				Callback = function(Value)
					AOTConfig.AutoEscape = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Anti Injuries",
				CurrentValue = false,
				Flag = "Lunar_AntiInjuries",
				Callback = function(Value)
					AOTConfig.AntiInjuries = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Auto Retry",
				CurrentValue = false,
				Flag = "Lunar_AutoRetry",
				Callback = function(Value)
					AOTConfig.AutoRetry = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Auto Reload Blades",
				CurrentValue = false,
				Flag = "Lunar_AutoReload",
				Callback = function(Value)
					AOTConfig.AutoReload = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Auto Refill",
				CurrentValue = false,
				Flag = "Lunar_AutoRefill",
				Callback = function(Value)
					AOTConfig.AutoRefill = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Remove Dmg Text",
				CurrentValue = false,
				Flag = "Lunar_RemoveDmgText",
				Callback = function(Value)
					AOTConfig.RemoveDmgText = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Auto Hide UI (15s)",
				CurrentValue = false,
				Flag = "Lunar_AutoHideUI",
				Callback = function(Value)
					AOTConfig.AutoHideUI = Value
					if Value then
						task.delay(15, function()
							if AOTConfig.AutoHideUI and RayfieldLibrary and RayfieldLibrary.Toggle then
								RayfieldLibrary:Toggle()
							end
						end)
					end
				end,
			})

			MainTab:CreateToggle({
				Name = "Fail Safe (180s Retry)",
				CurrentValue = false,
				Flag = "Lunar_FailSafe",
				Callback = function(Value)
					AOTConfig.FailSafe = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Noclip",
				CurrentValue = false,
				Flag = "Lunar_Noclip",
				Callback = function(Value)
					AOTConfig.Noclip = Value
				end,
			})

			-- ========================================================================
			-- 2. 🏰 TAB RAIDS (Chế độ Đột kích / Đánh Boss)
			-- ========================================================================
			local RaidTab = Window:CreateTab("Raids (Đột kích & Boss)", "skull")

			RaidTab:CreateSection("Raid [VERY RISKY USE NEW ACC/ALT]")

			RaidTab:CreateToggle({
				Name = "Auto Raid [Blade]",
				CurrentValue = false,
				Flag = "Lunar_AutoRaid",
				Callback = function(Value)
					AOTConfig.AutoRaid = Value
				end,
			})

			RaidTab:CreateSlider({
				Name = "Hover Speed",
				Range = { 50, 300 },
				Increment = 10,
				Suffix = "Speed",
				CurrentValue = 250,
				Flag = "Lunar_RaidHoverSpeed",
				Callback = function(Value)
					AOTConfig.RaidHoverSpeed = Value
				end,
			})

			RaidTab:CreateSection("Misc & Điều hướng")

			RaidTab:CreateToggle({
				Name = "Auto Skip Cutscene",
				CurrentValue = false,
				Flag = "Lunar_AutoSkipCutscene",
				Callback = function(Value)
					AOTConfig.AutoSkipCutscene = Value
				end,
			})

			RaidTab:CreateToggle({
				Name = "Auto Open Chests",
				CurrentValue = false,
				Flag = "Lunar_AutoOpenChests",
				Callback = function(Value)
					AOTConfig.AutoOpenChests = Value
				end,
			})

			RaidTab:CreateButton({
				Name = "Return to Lobby",
				Callback = function()
					if TeleportService and LocalPlayer then
						TeleportService:Teleport(14214532675, LocalPlayer)
					end
				end,
			})

			RaidTab:CreateButton({
				Name = "Return to Main Menu",
				Callback = function()
					pcall(function()
						local Assets = ReplicatedStorage:FindFirstChild("Assets")
						local Remotes = Assets and Assets:FindFirstChild("Remotes")
						local MenuRemote = Remotes and (Remotes:FindFirstChild("Menu") or Remotes:FindFirstChild("ReturnToMenu"))
						if MenuRemote and MenuRemote:IsA("RemoteEvent") then
							MenuRemote:FireServer()
						end
					end)
				end,
			})

			RaidTab:CreateButton({
				Name = "Force Retry",
				Callback = function()
					pcall(function()
						local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
						local rewards = playerGui and playerGui:FindFirstChild("Interface") and playerGui.Interface:FindFirstChild("Rewards")
						if rewards and rewards:FindFirstChild("Main") then
							local retryBtn = rewards.Main.Info.Main.Buttons:FindFirstChild("Retry")
							if retryBtn and VirtualInputManager then
								VirtualInputManager:SendMouseButtonEvent(retryBtn.AbsolutePosition.X + 20, retryBtn.AbsolutePosition.Y + 20, 0, true, game, 0)
								task.wait(0.1)
								VirtualInputManager:SendMouseButtonEvent(retryBtn.AbsolutePosition.X + 20, retryBtn.AbsolutePosition.Y + 20, 0, false, game, 0)
							end
						end
					end)
				end,
			})

			-- ========================================================================
			-- 3. 📊 TAB STATS (Bảng thống kê phiên treo máy)
			-- ========================================================================
			local StatsTab = Window:CreateTab("Stats (Thống kê Live)", "bar-chart")

			StatsTab:CreateSection("Earnings (Thu nhập)")
			local goldLabel = StatsTab:CreateLabel("Gold: 0")
			local xpLabel = StatsTab:CreateLabel("XP: 0")
			local gemsLabel = StatsTab:CreateLabel("Gems: 0")
			local bpXpLabel = StatsTab:CreateLabel("BP XP: 0")

			StatsTab:CreateSection("Performance (Hiệu suất)")
			local dmgLabel = StatsTab:CreateLabel("Total Damage: 0")
			local killsLabel = StatsTab:CreateLabel("Titans Killed: 0")
			local critsLabel = StatsTab:CreateLabel("Critical Hits: 0")
			local missionsLabel = StatsTab:CreateLabel("Missions/Raids Completed: 0")

			StatsTab:CreateSection("Perks & Special Items (Vật phẩm hiếm rơi ra)")
			local commonPerksLabel = StatsTab:CreateLabel("Common Perks: 0")
			local rarePerksLabel = StatsTab:CreateLabel("Rare Perks: 0")
			local epicPerksLabel = StatsTab:CreateLabel("Epic Perks: 0")
			local legPerksLabel = StatsTab:CreateLabel("Legendary Perks: 0")
			local presScrollsLabel = StatsTab:CreateLabel("Prestige Scrolls: 0")
			local mythPerksLabel = StatsTab:CreateLabel("Mythical Perks: 0")
			local serumLabel = StatsTab:CreateLabel("Serum: 0")
			local scarfsLabel = StatsTab:CreateLabel("Scarfs: 0")
			local lastUpdatedLabel = StatsTab:CreateLabel("Last Updated: Never")

			updateStatsUI = function()
				pcall(function()
					goldLabel:Set("Gold: " .. tostring(SessionStats.Gold))
					xpLabel:Set("XP: " .. tostring(SessionStats.XP))
					gemsLabel:Set("Gems: " .. tostring(SessionStats.Gems))
					bpXpLabel:Set("BP XP: " .. tostring(SessionStats.BP_XP))
					dmgLabel:Set("Total Damage: " .. tostring(SessionStats.TotalDamage))
					killsLabel:Set("Titans Killed: " .. tostring(SessionStats.TitansKilled))
					critsLabel:Set("Critical Hits: " .. tostring(SessionStats.CriticalHits))
					missionsLabel:Set("Missions/Raids Completed: " .. tostring(SessionStats.MissionsCompleted))
					commonPerksLabel:Set("Common Perks: " .. tostring(SessionStats.CommonPerks))
					rarePerksLabel:Set("Rare Perks: " .. tostring(SessionStats.RarePerks))
					epicPerksLabel:Set("Epic Perks: " .. tostring(SessionStats.EpicPerks))
					legPerksLabel:Set("Legendary Perks: " .. tostring(SessionStats.LegendaryPerks))
					presScrollsLabel:Set("Prestige Scrolls: " .. tostring(SessionStats.PrestigeScrolls))
					mythPerksLabel:Set("Mythical Perks: " .. tostring(SessionStats.MythicalPerks))
					serumLabel:Set("Serum: " .. tostring(SessionStats.Serum))
					scarfsLabel:Set("Scarfs: " .. tostring(SessionStats.Scarfs))
					lastUpdatedLabel:Set("Last Updated: " .. tostring(SessionStats.LastUpdated))
				end)
			end

			StatsTab:CreateButton({
				Name = "Reset Stats (Đặt lại bộ đếm)",
				Callback = function()
					SessionStats.Gold = "0"
					SessionStats.XP = "0"
					SessionStats.Gems = "0"
					SessionStats.BP_XP = "0"
					SessionStats.TotalDamage = "0"
					SessionStats.TitansKilled = "0"
					SessionStats.CriticalHits = "0"
					SessionStats.MissionsCompleted = "0"
					SessionStats.CommonPerks = "0"
					SessionStats.RarePerks = "0"
					SessionStats.EpicPerks = "0"
					SessionStats.LegendaryPerks = "0"
					SessionStats.PrestigeScrolls = "0"
					SessionStats.MythicalPerks = "0"
					SessionStats.Serum = "0"
					SessionStats.Scarfs = "0"
					SessionStats.LastUpdated = "Reset"
					updateStatsUI()
				end,
			})

			StatsTab:CreateButton({
				Name = "Force Update Stats (Làm mới dữ liệu)",
				Callback = function()
					updateStatsUI()
				end,
			})

			-- ========================================================================
			-- 4. 🔔 TAB WEBHOOK (Báo cáo kết quả về Discord)
			-- ========================================================================
			local WebhookTab = Window:CreateTab("Webhook (Báo cáo Discord)", "send")

			WebhookTab:CreateSection("Discord Webhook")

			WebhookTab:CreateToggle({
				Name = "Notify Webhook",
				CurrentValue = false,
				Flag = "Lunar_SendWebhook",
				Callback = function(Value)
					AOTConfig.SendWebhook = Value
				end,
			})

			WebhookTab:CreateToggle({
				Name = "Display Roblox Username",
				CurrentValue = true,
				Flag = "Lunar_DisplayUsername",
				Callback = function(Value)
					AOTConfig.DisplayUsername = Value
				end,
			})

			WebhookTab:CreateToggle({
				Name = "Ping on Serum/Mythic Only",
				CurrentValue = false,
				Flag = "Lunar_PingSpecialOnly",
				Callback = function(Value)
					AOTConfig.PingSpecialOnly = Value
				end,
			})

			WebhookTab:CreateInput({
				Name = "Webhook URL",
				PlaceholderText = "https://discord.com/api/webhooks/...",
				RemoveTextAfterFocusLost = false,
				Callback = function(Text)
					AOTConfig.WebhookURL = Text
				end,
			})

			sendDiscordWebhook = function(title, description, isSpecialItem)
				if not AOTConfig.SendWebhook or AOTConfig.WebhookURL == "" then return end
				if AOTConfig.PingSpecialOnly and not isSpecialItem then return end

				local content = isSpecialItem and "@everyone Rare Item Dropped!" or ""
				local playerName = AOTConfig.DisplayUsername and (LocalPlayer and LocalPlayer.Name or "Unknown") or "Anonymous"

				local embed = {
					title = title or "AOT:R Mission Complete",
					description = description or "Session Update",
					color = isSpecialItem and 16766720 or 65280,
					fields = {
						{ name = "Player", value = playerName, inline = true },
						{ name = "Titans Killed", value = tostring(SessionStats.TitansKilled), inline = true },
						{ name = "Total Damage", value = tostring(SessionStats.TotalDamage), inline = true },
						{ name = "Gold", value = tostring(SessionStats.Gold), inline = true },
						{ name = "Gems", value = tostring(SessionStats.Gems), inline = true },
						{ name = "Prestige Scrolls", value = tostring(SessionStats.PrestigeScrolls), inline = true },
						{ name = "Serum", value = tostring(SessionStats.Serum), inline = true },
					},
					footer = { text = "HaiAnh Menu | Attack on Titan: Revolution" },
					timestamp = DateTime and DateTime.now():ToIsoDate() or ""
				}

				local payload = {
					content = content,
					embeds = { embed }
				}

				pcall(function()
					local jsonBody = HttpService:JSONEncode(payload)
					if requestFunc then
						requestFunc({
							Url = AOTConfig.WebhookURL,
							Method = "POST",
							Headers = { ["Content-Type"] = "application/json" },
							Body = jsonBody
						})
					end
				end)
			end

			WebhookTab:CreateButton({
				Name = "Test Webhook",
				Callback = function()
					sendDiscordWebhook("LunarZ Hub Webhook Test", "Test ping from HaiAnh Menu AOT:R!", false)
				end,
			})

			-- ========================================================================
			-- 5. 👁️ TAB VISUAL (Hình ảnh & Tối ưu hóa FPS)
			-- ========================================================================
			local VisualTab = Window:CreateTab("Visual (Hình ảnh & FPS)", "eye")

			VisualTab:CreateSection("Visuals & Optimization")

			VisualTab:CreateToggle({
				Name = "Titan ESP",
				CurrentValue = false,
				Flag = "Lunar_TitanESP",
				Callback = function(Value)
					AOTConfig.TitanESP = Value
				end,
			})

			VisualTab:CreateColorPicker({
				Name = "ESP Color",
				Color = Color3.fromRGB(255, 0, 0),
				Flag = "Lunar_ESPColor",
				Callback = function(color)
					AOTConfig.ESPColor = color
				end,
			})

			VisualTab:CreateToggle({
				Name = "Optimize Game (Potato PC Mode)",
				CurrentValue = false,
				Flag = "Lunar_OptimizeGame",
				Callback = function(Value)
					AOTConfig.OptimizeGame = Value
					if Value then
						pcall(function()
							for _, obj in ipairs(Workspace:GetDescendants()) do
								if obj:IsA("BasePart") then
									obj.Material = Enum.Material.SmoothPlastic
								elseif obj:IsA("Decal") or obj:IsA("Texture") then
									obj.Transparency = 1
								end
							end
							local Lighting = getService("Lighting")
							if Lighting then Lighting.GlobalShadows = false end
						end)
					end
				end,
			})

			VisualTab:CreateToggle({
				Name = "Delete Map",
				CurrentValue = false,
				Flag = "Lunar_DeleteMap",
				Callback = function(Value)
					AOTConfig.DeleteMap = Value
					if Value then
						pcall(function()
							local unclimbable = Workspace:FindFirstChild("Unclimbable")
							if unclimbable then
								for _, obj in ipairs(unclimbable:GetChildren()) do
									if obj.Name ~= "Objective" and obj.Name ~= "Reloads" then
										obj:Destroy()
									end
								end
							end
						end)
					end
				end,
			})

			-- ========================================================================
			-- 6. ⚙️ TAB SETTINGS (Hệ thống Quản lý Cấu hình)
			-- ========================================================================
			local SettingsTab = Window:CreateTab("Settings (Quản lý Cấu hình)", "settings")

			SettingsTab:CreateSection("Hệ thống Quản lý Cấu hình")

			SettingsTab:CreateInput({
				Name = "Config Name",
				PlaceholderText = "Tên cấu hình (ví dụ: AfkNight)",
				RemoveTextAfterFocusLost = false,
				Callback = function(Text)
					AOTConfig.CurrentConfigName = Text ~= "" and Text or "Default"
				end,
			})

			local function getConfigList()
				local list = { "Default" }
				pcall(function()
					if isfolder and isfolder(configFolder) and listfiles then
						for _, f in ipairs(listfiles(configFolder)) do
							local fname = string.match(f, "([^/\\]+)%.json$")
							if fname and fname ~= "Default" then
								table.insert(list, fname)
							end
						end
					end
				end)
				return list
			end

			local configDropdown = SettingsTab:CreateDropdown({
				Name = "Select Config",
				Options = getConfigList(),
				CurrentOption = { "Default" },
				MultipleOptions = false,
				Flag = "Lunar_SelectConfig",
				Callback = function(Option)
					AOTConfig.CurrentConfigName = type(Option) == "table" and Option[1] or Option
				end,
			})

			local autoloadLabel = SettingsTab:CreateLabel("Autoload config: None")

			SettingsTab:CreateButton({
				Name = "Create Config (Tạo cấu hình mới)",
				Callback = function()
					pcall(function()
						local cfgName = AOTConfig.CurrentConfigName or "Default"
						local path = configFolder .. "/" .. cfgName .. ".json"
						local data = HttpService:JSONEncode(AOTConfig)
						writefile(path, data)
						RayfieldLibrary:Notify({
							Title = "Config Manager",
							Content = "Đã lưu cấu hình: " .. cfgName,
							Duration = 3,
						})
						if configDropdown and configDropdown.Set then
							configDropdown:Set(getConfigList())
						end
					end)
				end,
			})

			SettingsTab:CreateButton({
				Name = "Load Config (Tải cấu hình)",
				Callback = function()
					pcall(function()
						local cfgName = AOTConfig.CurrentConfigName or "Default"
						local path = configFolder .. "/" .. cfgName .. ".json"
						if isfile and isfile(path) then
							local data = readfile(path)
							local decoded = HttpService:JSONDecode(data)
							if type(decoded) == "table" then
								for k, v in pairs(decoded) do
									AOTConfig[k] = v
								end
								RayfieldLibrary:Notify({
									Title = "Config Manager",
									Content = "Đã nạp thành công cấu hình: " .. cfgName,
									Duration = 3,
								})
							end
						end
					end)
				end,
			})

			SettingsTab:CreateButton({
				Name = "Overwrite Config (Ghi đè cấu hình)",
				Callback = function()
					pcall(function()
						local cfgName = AOTConfig.CurrentConfigName or "Default"
						local path = configFolder .. "/" .. cfgName .. ".json"
						local data = HttpService:JSONEncode(AOTConfig)
						writefile(path, data)
						RayfieldLibrary:Notify({
							Title = "Config Manager",
							Content = "Đã ghi đè cấu hình: " .. cfgName,
							Duration = 3,
						})
					end)
				end,
			})

			SettingsTab:CreateButton({
				Name = "Refresh Config List (Làm mới danh sách)",
				Callback = function()
					pcall(function()
						if configDropdown and configDropdown.Set then
							configDropdown:Set(getConfigList())
						end
					end)
				end,
			})

			SettingsTab:CreateButton({
				Name = "Set as autoload (Đặt làm mặc định)",
				Callback = function()
					pcall(function()
						local cfgName = AOTConfig.CurrentConfigName or "Default"
						writefile(configFolder .. "/autoload.txt", cfgName)
						autoloadLabel:Set("Autoload config: " .. cfgName)
						RayfieldLibrary:Notify({
							Title = "Config Manager",
							Content = "Đã đặt " .. cfgName .. " làm autoload!",
							Duration = 3,
						})
					end)
				end,
			})

			-- Kiểm tra Autoload khi mở menu
			pcall(function()
				local autoPath = configFolder .. "/autoload.txt"
				if isfile and isfile(autoPath) then
					local autoName = readfile(autoPath)
					if autoName and autoName ~= "" then
						autoloadLabel:Set("Autoload config: " .. autoName)
						local cfgPath = configFolder .. "/" .. autoName .. ".json"
						if isfile(cfgPath) then
							local d = HttpService:JSONDecode(readfile(cfgPath))
							if type(d) == "table" then
								for k, v in pairs(d) do AOTConfig[k] = v end
							end
						end
					end
				end
			end)

			-- ========================================================================
			-- CORE GAMEPLAY LOGIC & BACKGROUND TASKS
			-- ========================================================================

			-- 1. Noclip Handler
			local noclipConn = nil
			task.spawn(function()
				while not rayfieldDestroyed do
					if AOTConfig.Noclip then
						if not noclipConn then
							noclipConn = RunService.Stepped:Connect(function()
								pcall(function()
									if LocalPlayer and LocalPlayer.Character then
										for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
											if p:IsA("BasePart") and p.CanCollide then
												p.CanCollide = false
											end
										end
									end
								end)
							end)
						end
					else
						if noclipConn then
							noclipConn:Disconnect()
							noclipConn = nil
						end
					end
					task.wait(0.5)
				end
				if noclipConn then noclipConn:Disconnect() end
			end)

			-- 2. Anti Injuries Handler
			local function setupAntiInjuries(char)
				if not char then return end
				pcall(function()
					local injuries = char:WaitForChild("Injuries", 3)
					if injuries then
						for _, child in ipairs(injuries:GetChildren()) do
							child:Destroy()
						end
						injuries.ChildAdded:Connect(function(child)
							if AOTConfig.AntiInjuries then
								task.defer(function()
									pcall(function() child:Destroy() end)
								end)
							end
						end)
					end
				end)
			end

			if LocalPlayer and LocalPlayer.Character then
				setupAntiInjuries(LocalPlayer.Character)
			end
			LocalPlayer.CharacterAdded:Connect(setupAntiInjuries)

			-- 3. Auto Escape Grab (from menau.txt)
			task.spawn(function()
				while not rayfieldDestroyed do
					task.wait(0.12)
					if AOTConfig.AutoEscape and LocalPlayer and LocalPlayer.Character then
						pcall(function()
							local char = LocalPlayer.Character
							local isGrabbed = char:FindFirstChild("Grabbed")
								or char:GetAttribute("Grabbed")
								or (char:GetAttribute("State") == "Grabbed")
								or (char.Parent and char.Parent ~= Workspace and char.Parent:FindFirstChildOfClass("Humanoid") and char.Parent ~= char)
							if isGrabbed then
								if VirtualInputManager then
									VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
									task.wait(0.02)
									VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
								end
								local postRemote = getAOTRemotes()
								if postRemote then
									pcall(function() postRemote:FireServer("Character", "Escape") end)
									pcall(function() postRemote:FireServer("Attacks", "M1") end)
								end
								refreshCachedGuiElements(false)
								if cachedGuiState.m1 and cachedGuiState.m1.Parent then
									clickGuiButtonFast(cachedGuiState.m1)
								end
							end
						end)
					end
				end
			end)

			-- ========================================================================
			-- AOT:R CORE COMBAT, TARGETING & UTILITY ENGINE (VIP ROBUST EDITION)
			-- ========================================================================
			local deadTitanCache = setmetatable({}, { __mode = "k" })
			local napeCache = setmetatable({}, { __mode = "k" })
			local consecutiveSlashes = 0
			local lastBladeSlashTime = 0
			local lastReloadTime = 0
			local lastRefillTime = 0
			local lastMasteryTime = 0

			-- Remote detection helper
			local function getAOTRemotes()
				local assets = ReplicatedStorage:FindFirstChild("Assets")
				local remotes = (assets and assets:FindFirstChild("Remotes"))
					or ReplicatedStorage:FindFirstChild("Remotes")
					or ReplicatedStorage:FindFirstChild("Remotes", true)
				local post = (remotes and remotes:FindFirstChild("POST"))
					or ReplicatedStorage:FindFirstChild("POST", true)
				local get = (remotes and remotes:FindFirstChild("GET"))
					or ReplicatedStorage:FindFirstChild("GET", true)
				return post, get
			end

			-- Mobile Touch / GUI Detection Helper
			local cachedGuiState = {
				m1 = nil,
				reload = nil,
				lastScan = 0
			}

			local function refreshCachedGuiElements(force)
				local now = os.clock()
				if not force and (now - cachedGuiState.lastScan < 3.0) and cachedGuiState.m1 and cachedGuiState.m1.Parent then
					return
				end
				cachedGuiState.lastScan = now
				local pgui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
				if not pgui then return end

				for _, obj in ipairs(pgui:GetDescendants()) do
					if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
						local name = string.lower(obj.Name)
						local text = obj:IsA("TextButton") and string.lower(obj.Text) or ""
						local childLabel = obj:FindFirstChildWhichIsA("TextLabel", true)
						if childLabel and childLabel.Text ~= "" then
							text = text .. " " .. string.lower(childLabel.Text)
						end
						local combined = name .. " " .. text
						if string.find(combined, "m1", 1, true) or string.find(combined, "slash", 1, true) or string.find(combined, "attack", 1, true) then
							if not cachedGuiState.m1 or not cachedGuiState.m1.Parent then
								cachedGuiState.m1 = obj
							end
						end
						if string.find(combined, "reload", 1, true) or string.find(combined, "nạp", 1, true) or string.find(combined, "nap", 1, true) then
							if not cachedGuiState.reload or not cachedGuiState.reload.Parent then
								cachedGuiState.reload = obj
							end
						end
					end
				end
			end

			local function clickGuiButtonFast(btn)
				if not btn or not btn.Parent then return false end
				pcall(function()
					local fired = false
					if firesignal then
						if btn.Activated then firesignal(btn.Activated); fired = true end
						if btn.MouseButton1Click then firesignal(btn.MouseButton1Click); fired = true end
						if btn.MouseButton1Down then firesignal(btn.MouseButton1Down); fired = true end
						if btn.MouseButton1Up then firesignal(btn.MouseButton1Up); fired = true end
					end
					if not fired and VirtualUser then
						local absPos = btn.AbsolutePosition
						local absSz = btn.AbsoluteSize
						VirtualUser:ClickButton1(Vector2.new(absPos.X + absSz.X / 2, absPos.Y + absSz.Y / 2))
					end
				end)
				return true
			end

			-- Check if Titan is dead or defeated
			local function isTitanDead(titan, hum, nape)
				if not titan or not titan.Parent then return true end
				if deadTitanCache[titan] then return true end
				if Players and Players:GetPlayerFromCharacter(titan) then return true end

				-- Check server dead attributes
				if titan:GetAttribute("Dead") == true or titan:GetAttribute("Defeated") == true or titan:GetAttribute("Died") == true then
					deadTitanCache[titan] = true
					return true
				end

				-- If humanoid exists and has valid MaxHealth > 0, check if health <= 0
				if hum and hum.MaxHealth > 0 and hum.Health <= 0 then
					deadTitanCache[titan] = true
					return true
				end

				return false
			end

			-- Find Nape or WeakPoint Hitbox
			local function findTitanNape(titan)
				if not titan or not titan.Parent then return nil end
				if Players and Players:GetPlayerFromCharacter(titan) then return nil end

				local hitboxes = titan:FindFirstChild("Hitboxes")
				local hitFolder = hitboxes and hitboxes:FindFirstChild("Hit")
				local nape = (hitFolder and hitFolder:FindFirstChild("Nape"))
					or (hitboxes and hitboxes:FindFirstChild("Nape"))
					or titan:FindFirstChild("Nape")

				if not nape or not nape:IsA("BasePart") then
					for _, part in ipairs(titan:GetDescendants()) do
						if part:IsA("BasePart") then
							local pName = string.lower(part.Name)
							if pName == "nape" or pName == "weakpoint" then
								nape = part
								break
							end
						end
					end
				end

				if not nape or not nape:IsA("BasePart") then
					local head = titan:FindFirstChild("Head")
					if head and head:IsA("BasePart") then
						nape = head
					end
				end

				return nape
			end

			-- Multi-Folder Titan Scanner
			local function getTitansList()
				local list = {}
				local char = LocalPlayer and LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if not Workspace then return list end

				local searchFolders = {}
				local titansFolder = Workspace:FindFirstChild("Titans")
				if titansFolder then
					table.insert(searchFolders, titansFolder)
				end

				for _, fName in ipairs({ "Titans", "Enemies", "Boss", "Bosses", "Raid", "Spawns", "Entities", "Living", "Targets", "Mobs" }) do
					local f = Workspace:FindFirstChild(fName)
					if f and f ~= titansFolder then table.insert(searchFolders, f) end
				end

				local map = Workspace:FindFirstChild("Map")
				if map then
					for _, sub in ipairs(map:GetChildren()) do
						local subName = sub.Name
						if subName == "Titans" or subName == "Enemies" or subName == "Boss" or subName == "Spawns" or subName == "Mobs" then
							table.insert(searchFolders, sub)
						end
					end
				end

				if #searchFolders == 0 then
					table.insert(searchFolders, Workspace)
				end

				local seen = {}
				for _, folder in ipairs(searchFolders) do
					for _, titan in ipairs(folder:GetChildren()) do
						if titan:IsA("Model") and not seen[titan] and titan ~= char then
							seen[titan] = true
							local hum = titan:FindFirstChildOfClass("Humanoid")
							local nape = findTitanNape(titan)
							if nape and not isTitanDead(titan, hum, nape) then
								local dist = root and (nape.Position - root.Position).Magnitude or 9999
								table.insert(list, {
									model = titan,
									humanoid = hum,
									nape = nape,
									dist = dist
								})
							end
						end
					end
				end

				table.sort(list, function(a, b) return a.dist < b.dist end)
				return list
			end

			-- 4. Target Acquisition & Boss Shifter Priority (from menau.txt)
			local function getClosestRefillStation()
				local unclimbable = Workspace:FindFirstChild("Unclimbable")
				local reloads = unclimbable and unclimbable:FindFirstChild("Reloads")
				if not reloads then
					local map = Workspace:FindFirstChild("Map")
					reloads = map and map:FindFirstChild("Reloads", true)
				end
				if not reloads then return nil end
				local char = LocalPlayer and LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return nil end
				local closest, closestDist = nil, math.huge
				for _, station in ipairs(reloads:GetChildren()) do
					local part = station:IsA("BasePart") and station or station:FindFirstChildWhichIsA("BasePart", true)
					if part then
						local d = (hrp.Position - part.Position).Magnitude
						if d < closestDist then
							closestDist = d
							closest = station
						end
					end
				end
				return closest
			end

			local isRefillingStation = false

			local function getClosestValidTarget()
				local char = LocalPlayer and LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return nil, nil, false end

				-- Priority 1: Raids Mode or Shifter Boss Objective (menau.txt SkillTarget)
				if AOTConfig.AutoRaid then
					local unclimbable = Workspace:FindFirstChild("Unclimbable")
					local objective = unclimbable and unclimbable:FindFirstChild("Objective")
					if objective then
						for _, child in ipairs(objective:GetChildren()) do
							local hp = child:FindFirstChild("Health")
							if hp and hp:IsA("NumberValue") and hp.Value > 0 then
								local targetPart = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)
								if targetPart then
									return targetPart, child, true
								end
							end
						end
					end

					local titansFolder = Workspace:FindFirstChild("Titans")
					if titansFolder then
						for _, titan in ipairs(titansFolder:GetChildren()) do
							if titan:IsA("Model") and titan ~= char and titan:GetAttribute("Shifter") == true then
								local hum = titan:FindFirstChildOfClass("Humanoid")
								local nape = findTitanNape(titan)
								if nape and not isTitanDead(titan, hum, nape) then
									return nape, titan, true
								end
							end
						end
					end
				end

				-- Priority 2: Standard Living Titans
				local list = getTitansList()
				if #list > 0 then
					local best = list[1]
					local isBoss = best.model:GetAttribute("Shifter") == true
					return best.nape, best.model, isBoss
				end

				return nil, nil, false
			end

			-- Multi-Attack Executor (Remotes + Tool + Mobile Touch UI + Input from menau.txt)
			local lastAttackTime = 0
			local function performTitanAttack(targetPart, targetModel, isBoss)
				if not targetPart then return end
				local now = os.clock()
				local postRemote, getRemote = getAOTRemotes()

				-- 1. Server Remotes: High-damage instant slash & Hitbox registration
				if postRemote then
					pcall(function() postRemote:FireServer("Attacks", "M1") end)
					pcall(function() postRemote:FireServer("Attacks", "Slash", true) end)
					pcall(function() postRemote:FireServer("Attacks", "Slash_Release") end)
					pcall(function() postRemote:FireServer("Hitboxes", "Register", targetPart, 500, 100) end)
					pcall(function() postRemote:FireServer("Hitboxes", "Register", targetPart, 500) end)
					pcall(function() postRemote:FireServer("Hitboxes", "Register", targetPart) end)
					if isBoss then
						pcall(function() postRemote:FireServer("Attacks", "Heavy") end)
					end
				end

				-- 2. Auto Mastery: Fire skill remotes and abilities
				if AOTConfig.AutoMastery and (now - lastMasteryTime >= 0.45) then
					lastMasteryTime = now
					if postRemote then
						pcall(function()
							for slot = 1, 4 do
								postRemote:FireServer("Skills", "Use", slot)
								postRemote:FireServer("S_Character", "Skill", slot)
							end
						end)
					end
				end

				-- 3. Tool Activation (if weapon tool is equipped)
				local char = LocalPlayer and LocalPlayer.Character
				if char then
					for _, item in ipairs(char:GetChildren()) do
						if item:IsA("Tool") then
							pcall(function() item:Activate() end)
						end
					end
				end

				-- 4. Mobile Touch GUI: Click on-screen M1 button if present
				refreshCachedGuiElements(false)
				if cachedGuiState.m1 and cachedGuiState.m1.Parent and cachedGuiState.m1.Visible then
					clickGuiButtonFast(cachedGuiState.m1)
				end

				-- 5. VirtualInputManager / VirtualUser click (PC and screen center)
				if (now - lastAttackTime >= 0.12) then
					lastAttackTime = now
					if VirtualInputManager then
						pcall(function()
							local vp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
							local cx = vp.X * 0.75
							local cy = vp.Y * 0.65
							VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
							task.delay(0.03, function()
								VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
							end)
						end)
					elseif VirtualUser then
						pcall(function()
							VirtualUser:CaptureController()
							VirtualUser:ClickButton1(Vector2.new(400, 300))
						end)
					end
				end
			end

			-- 5. Auto Farm Combat Loop (Kinematic 60 FPS Flight Engine from Luraph menau.txt Closure V)
			local farmHoldCF = nil
			local lastTargetUpdate = 0
			local cachedTargetPart, cachedTargetModel, cachedIsBoss = nil, nil, false

			-- Noclip connection for farm: glide through map obstacles & limbs
			RunService.Stepped:Connect(function()
				if rayfieldDestroyed then return end
				if AOTConfig.AutoFarm or AOTConfig.AutoRaid or AOTConfig.Noclip then
					local char = LocalPlayer and LocalPlayer.Character
					if char then
						for _, part in ipairs(char:GetDescendants()) do
							if part:IsA("BasePart") and part.CanCollide then
								part.CanCollide = false
							end
						end
					end
				end
			end)

			RunService.Heartbeat:Connect(function(dt)
				if rayfieldDestroyed then return end

				if not (AOTConfig.AutoFarm or AOTConfig.AutoRaid) then
					farmHoldCF = nil
					cachedTargetPart = nil
					cachedTargetModel = nil
					cachedIsBoss = false
					return
				end

				local char = LocalPlayer and LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not hrp or not hum or hum.Health <= 0 then return end

				hum.PlatformStand = false

				-- Handle Refill flight navigation if currently refilling
				if isRefillingStation then
					local station = getClosestRefillStation()
					local sPart = station and (station:IsA("BasePart") and station or station:FindFirstChildWhichIsA("BasePart", true))
					if sPart then
						local targetPos = sPart.Position + Vector3.new(0, 3, 0)
						local toStation = targetPos - hrp.Position
						local dist = toStation.Magnitude
						local currentSpeed = AOTConfig.HoverSpeed or 250
						if dist > 1.0 then
							local step = math.min(dist, currentSpeed * dt)
							hrp.CFrame = CFrame.lookAt(hrp.Position + toStation.Unit * step, targetPos)
						else
							hrp.CFrame = CFrame.new(targetPos)
						end
						hrp.AssemblyLinearVelocity = Vector3.zero
						farmHoldCF = hrp.CFrame
						return
				end
				end

				local now = os.clock()
				if (now - lastTargetUpdate >= 0.2) or not cachedTargetPart or not cachedTargetPart.Parent or not cachedTargetModel or not cachedTargetModel.Parent then
					lastTargetUpdate = now
					cachedTargetPart, cachedTargetModel, cachedIsBoss = getClosestValidTarget()
				end

				local targetPart = cachedTargetPart
				local targetModel = cachedTargetModel
				local isBoss = cachedIsBoss

				if not targetPart or not targetModel or not targetPart.Parent or not targetModel.Parent then
					-- No target alive: lock in air smoothly
					if farmHoldCF then
						hrp.CFrame = farmHoldCF
						hrp.AssemblyLinearVelocity = Vector3.zero
					end
					return
				end

				-- Calculate movement parameters
				local currentSpeed = AOTConfig.AutoRaid and (AOTConfig.RaidHoverSpeed or 250) or (AOTConfig.HoverSpeed or 250)
				local goalPos = nil
				local goalCF = nil

				if isBoss then
					-- Boss Shifter Positioning (menau.txt SkillTarget: 30 studs horizontal, facing boss)
					local bossPos = targetModel:GetPivot().Position
					local delta = Vector3.new(hrp.Position.X - bossPos.X, 0, hrp.Position.Z - bossPos.Z)
					local dir = (delta.Magnitude > 1 and delta.Unit or Vector3.new(0, 0, 1)) * 30
					goalPos = bossPos + dir + Vector3.new(0, 8, 0)
					goalCF = CFrame.lookAt(goalPos, Vector3.new(bossPos.X, goalPos.Y, bossPos.Z))
				else
					-- Normal Titan: Position DIRECTLY BEHIND THE NAPE (Safe Kill Spot from menau.txt)
					local titanPivot = targetModel:GetPivot()
					local titanLook = titanPivot.LookVector
					local behindDist = AOTConfig.AutoKillSafe and 5.5 or 4.0
					local heightOffset = math.clamp((AOTConfig.FloatHeight or 250) * 0.012, 1.2, 3.5)
					goalPos = targetPart.Position - (titanLook * behindDist) + Vector3.new(0, heightOffset, 0)
					goalCF = CFrame.lookAt(goalPos, targetPart.Position)
				end

				if AOTConfig.MoveMode == "Teleport" and not isBoss and not AOTConfig.AutoRaid then
					-- Teleport Mode: Instant reposition behind nape
					hrp.CFrame = goalCF
					hrp.AssemblyLinearVelocity = Vector3.zero
					farmHoldCF = hrp.CFrame
				else
					-- Hover Mode: Smooth 60 FPS kinematic gliding without velocity drag (menau.txt function V)
					local toGoal = goalPos - hrp.Position
					local dist = toGoal.Magnitude

					if dist > 0.4 then
						local moveDir = toGoal.Unit
						local step = math.min(dist, currentSpeed * dt)
						hrp.CFrame = CFrame.lookAt(hrp.Position + moveDir * step, targetPart.Position)
					else
						hrp.CFrame = goalCF
					end
					hrp.AssemblyLinearVelocity = Vector3.zero
					farmHoldCF = hrp.CFrame
				end

				-- Attack Target when in strike range
				local strikeDist = (hrp.Position - targetPart.Position).Magnitude
				local maxRange = isBoss and 38 or 16
				if strikeDist <= maxRange then
					performTitanAttack(targetPart, targetModel, isBoss)
				end
			end)

			-- 6. Weapon Check & Auto Reload Blades
			local function performBladeReload()
				local postRemote, getRemote = getAOTRemotes()
				if postRemote then
					pcall(function() postRemote:FireServer("Attacks", "Reload") end)
					pcall(function() postRemote:FireServer("S_Equipment", "Reload") end)
					pcall(function() postRemote:FireServer("Equipment", "Reload") end)
				end
				if getRemote then
					pcall(function() getRemote:InvokeServer("S_Equipment", "Reload") end)
				end

				refreshCachedGuiElements()
				if cachedGuiState.reload and cachedGuiState.reload.Parent then
					clickGuiButtonFast(cachedGuiState.reload)
				end

				if VirtualInputManager then
					pcall(function()
						VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
						task.wait(0.05)
						VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
					end)
				end
			end

			task.spawn(function()
				while not rayfieldDestroyed do
					task.wait(1.0)
					if AOTConfig.AutoReload and LocalPlayer then
						pcall(function()
							local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
							local hud = playerGui and playerGui:FindFirstChild("Interface") and playerGui.Interface:FindFirstChild("HUD")
							local needsReload = false

							if hud and hud:FindFirstChild("Main") and hud.Main:FindFirstChild("Top") then
								local bladesUI = hud.Main.Top:FindFirstChild("Blades")
								if bladesUI and bladesUI:FindFirstChild("Sets") then
									local sets = tonumber(bladesUI.Sets.Text) or 0
									if sets <= 0 then
										needsReload = true
									end
								end
							end

							local char = LocalPlayer.Character
							if char and (char:GetAttribute("BladeBroken") == true or char:GetAttribute("Blades") == 0) then
								needsReload = true
							end

							if needsReload then
								performBladeReload()
							end
						end)
					end
				end
			end)

			-- 7. Auto Refill Supplies at Station (from menau.txt)
			task.spawn(function()
				while not rayfieldDestroyed do
					task.wait(1.5)
					if AOTConfig.AutoRefill and LocalPlayer and LocalPlayer.Character then
						pcall(function()
							local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
							local hud = playerGui and playerGui:FindFirstChild("Interface") and playerGui.Interface:FindFirstChild("HUD")
							local needsRefill = false

							if hud and hud:FindFirstChild("Main") and hud.Main:FindFirstChild("Top") then
								local bladesUI = hud.Main.Top:FindFirstChild("Blades")
								if bladesUI and bladesUI:FindFirstChild("Sets") then
									local sets = tonumber(bladesUI.Sets.Text) or 0
									if sets <= 0 then
										needsRefill = true
									end
								end
							end

							local char = LocalPlayer.Character
							if char and (char:GetAttribute("BladeBroken") == true or char:GetAttribute("Blades") == 0) then
								needsRefill = true
							end

							if needsRefill then
								isRefillingStation = true
								local station = getClosestRefillStation()
								if station then
									local prompt = station:FindFirstChildWhichIsA("ProximityPrompt", true)
									if prompt and fireproximityprompt then
										fireproximityprompt(prompt, 0)
										fireproximityprompt(prompt)
									end
								end
								local postRemote = getAOTRemotes()
								if postRemote then
									pcall(function() postRemote:FireServer("S_Equipment", "Refill") end)
									pcall(function() postRemote:FireServer("Equipment", "Refill") end)
									pcall(function() postRemote:FireServer("Character", "Refill") end)
								end
								task.wait(0.8)
								isRefillingStation = false
							else
								isRefillingStation = false
							end
						end)
					end
				end
			end)

			-- 8. Auto Skip Cutscene
			task.spawn(function()
				while not rayfieldDestroyed do
					task.wait(0.5)
					if AOTConfig.AutoSkipCutscene and LocalPlayer then
						pcall(function()
							local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
							local iface = playerGui and playerGui:FindFirstChild("Interface")
							local skipBtn = iface and (iface:FindFirstChild("Skip") or iface:FindFirstChild("SkipCutscene", true))
							if skipBtn and skipBtn.Visible then
								clickGuiButtonFast(skipBtn)
								if VirtualInputManager then
									VirtualInputManager:SendMouseButtonEvent(skipBtn.AbsolutePosition.X + 15, skipBtn.AbsolutePosition.Y + 15, 0, true, game, 0)
									task.wait(0.05)
									VirtualInputManager:SendMouseButtonEvent(skipBtn.AbsolutePosition.X + 15, skipBtn.AbsolutePosition.Y + 15, 0, false, game, 0)
								end
							end
						end)
					end
				end
			end)

			-- 9. Auto Open Chests
			task.spawn(function()
				while not rayfieldDestroyed do
					task.wait(0.8)
					if AOTConfig.AutoOpenChests and LocalPlayer then
						pcall(function()
							local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
							local iface = playerGui and playerGui:FindFirstChild("Interface")
							local chests = iface and iface:FindFirstChild("Chests")
							if chests and chests:FindFirstChild("Finish") and chests.Finish.Visible then
								local finishBtn = chests.Finish
								clickGuiButtonFast(finishBtn)
								if VirtualInputManager then
									VirtualInputManager:SendMouseButtonEvent(finishBtn.AbsolutePosition.X + 20, finishBtn.AbsolutePosition.Y + 20, 0, true, game, 0)
									task.wait(0.05)
									VirtualInputManager:SendMouseButtonEvent(finishBtn.AbsolutePosition.X + 20, finishBtn.AbsolutePosition.Y + 20, 0, false, game, 0)
								end
							end
						end)
					end
				end
			end)

			-- 10. Auto Retry & Stats Harvesting
			task.spawn(function()
				while not rayfieldDestroyed do
					task.wait(1.0)
					if LocalPlayer then
						pcall(function()
							local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
							local rewards = playerGui and playerGui:FindFirstChild("Interface") and playerGui.Interface:FindFirstChild("Rewards")
							if rewards and rewards.Visible and rewards:FindFirstChild("Main") then
								local statsFolder = rewards.Main.Info.Main:FindFirstChild("Stats")
								if statsFolder then
									if statsFolder:FindFirstChild("Time_Taken") then
										SessionStats.TimeTaken = statsFolder.Time_Taken.Amount.Text
									end
									if statsFolder:FindFirstChild("Damage_Dealt") then
										SessionStats.TotalDamage = statsFolder.Damage_Dealt.Amount.Text
									end
									if statsFolder:FindFirstChild("Titans_Killed") then
										SessionStats.TitansKilled = statsFolder.Titans_Killed.Amount.Text
									end
									if statsFolder:FindFirstChild("Critical_Hits") then
										SessionStats.CriticalHits = statsFolder.Critical_Hits.Amount.Text
									end
									SessionStats.LastUpdated = os.date("%X")
									if updateStatsUI then updateStatsUI() end
								end

								-- Check Items
								local itemsFolder = rewards.Main.Info.Main:FindFirstChild("Items")
								local hasSpecialItem = false
								if itemsFolder then
									for _, item in ipairs(itemsFolder:GetChildren()) do
										local itemName = string.lower(item.Name)
										if string.find(itemName, "serum", 1, true) then
											SessionStats.Serum = tostring((tonumber(SessionStats.Serum) or 0) + 1)
											hasSpecialItem = true
										elseif string.find(itemName, "mythic", 1, true) then
											SessionStats.MythicalPerks = tostring((tonumber(SessionStats.MythicalPerks) or 0) + 1)
											hasSpecialItem = true
										elseif string.find(itemName, "prestige", 1, true) then
											SessionStats.PrestigeScrolls = tostring((tonumber(SessionStats.PrestigeScrolls) or 0) + 1)
										end
									end
								end

								if AOTConfig.AutoRetry then
									local retryBtn = rewards.Main.Info.Main.Buttons:FindFirstChild("Retry")
									if retryBtn and retryBtn.Visible then
										if sendDiscordWebhook then
											sendDiscordWebhook("Mission Complete (Auto Retry)", "Cleared stage and retrying!", hasSpecialItem)
										end
										task.wait(0.4)
										clickGuiButtonFast(retryBtn)
										if VirtualInputManager then
											VirtualInputManager:SendMouseButtonEvent(retryBtn.AbsolutePosition.X + 20, retryBtn.AbsolutePosition.Y + 20, 0, true, game, 0)
											task.wait(0.05)
											VirtualInputManager:SendMouseButtonEvent(retryBtn.AbsolutePosition.X + 20, retryBtn.AbsolutePosition.Y + 20, 0, false, game, 0)
										end
									end
								end
							end
						end)
					end
				end
			end)

			-- 11. Fail Safe (180s Retry Timer)
			task.spawn(function()
				local failSafeTimer = 0
				while not rayfieldDestroyed do
					task.wait(1)
					if AOTConfig.FailSafe then
						failSafeTimer = failSafeTimer + 1
						if failSafeTimer >= 180 then
							failSafeTimer = 0
							pcall(function()
								local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
								local rewards = playerGui and playerGui:FindFirstChild("Interface") and playerGui.Interface:FindFirstChild("Rewards")
								local retryBtn = rewards and rewards:FindFirstChild("Main") and rewards.Main.Info.Main.Buttons:FindFirstChild("Retry")
								if retryBtn then
									clickGuiButtonFast(retryBtn)
									if VirtualInputManager then
										VirtualInputManager:SendMouseButtonEvent(retryBtn.AbsolutePosition.X + 20, retryBtn.AbsolutePosition.Y + 20, 0, true, game, 0)
										task.wait(0.05)
										VirtualInputManager:SendMouseButtonEvent(retryBtn.AbsolutePosition.X + 20, retryBtn.AbsolutePosition.Y + 20, 0, false, game, 0)
									end
								end
							end)
						end
					else
						failSafeTimer = 0
					end
				end
			end)

			-- 12. Remove Damage Text
			task.spawn(function()
				while not rayfieldDestroyed do
					task.wait(0.5)
					if AOTConfig.RemoveDmgText and LocalPlayer then
						pcall(function()
							local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
							local iface = playerGui and playerGui:FindFirstChild("Interface")
							if iface then
								for _, child in ipairs(iface:GetChildren()) do
									local n = string.lower(child.Name)
									if string.find(n, "damage", 1, true) or string.find(n, "dmg", 1, true) then
										child.Visible = false
									end
								end
							end
						end)
					end
				end
			end)

			-- 13. Titan ESP & Shifter Objective Radar (from menau.txt Closure w)
			local espHighlights = {}
			task.spawn(function()
				while not rayfieldDestroyed do
					if AOTConfig.TitanESP then
						pcall(function()
							local titans = getTitansList()
							local activeModels = {}
							for _, entry in ipairs(titans) do
								local titan = entry.model
								if titan and titan.Parent then
									activeModels[titan] = true
									local isShifter = titan:GetAttribute("Shifter") == true
									if not espHighlights[titan] then
										local hl = Instance.new("Highlight")
										hl.Name = "HaiAnh_TitanESP"
										hl.FillColor = isShifter and Color3.fromRGB(255, 200, 60) or AOTConfig.ESPColor
										hl.OutlineColor = Color3.fromRGB(255, 255, 255)
										hl.FillTransparency = 0.4
										hl.Adornee = titan
										hl.Parent = titan
										espHighlights[titan] = hl
									else
										espHighlights[titan].FillColor = isShifter and Color3.fromRGB(255, 200, 60) or AOTConfig.ESPColor
									end
								end
							end

							for titan, hl in pairs(espHighlights) do
								if not activeModels[titan] or not titan.Parent then
									pcall(function() hl:Destroy() end)
									espHighlights[titan] = nil
								end
							end
						end)
					else
						pcall(function()
							for titan, hl in pairs(espHighlights) do
								if hl then hl:Destroy() end
							end
							espHighlights = {}
						end)
					end
					task.wait(0.8)
				end
			end)
		end

		-- ============================================================================
		-- MENU 2: BLOX FRUITS (HAIANH MENU VIP EDITION)
		-- ============================================================================
		local function loadBloxFruitsMenu()
			local HubConfig = {
				SelectedWeapon = "Melee",
				AttackSpeed = "Super Fast",
				HoverHeight = 15,
				FlightSpeed = 260,
				BringMobs = true,
				AutoBuso = true,
				AutoLevel = false,
				AutoNearestMob = false,
				AutoBoss = false,
				AutoCandy = false,
				KillAura = false,
				HitboxSize = 65,
				AutoStatMelee = false,
				AutoStatDefense = false,
				AutoStatSword = false,
				AutoStatFruit = false,
				AntiAFK = true,
			}

			local Window = RayfieldLibrary:CreateWindow({
				Name = "HaiAnh Menu | Blox Fruits",
				LoadingTitle = "HaiAnh Menu",
				LoadingSubtitle = "Blox Fruits",
				ConfigurationSaving = {
					Enabled = true,
					FolderName = "HaiAnhMenuConfig",
					FileName = "BloxFruits"
				},
				KeySystem = false,
			})

			createFloatingToggle()

			-- TAB 1: Auto Farm
			local FarmTab = Window:CreateTab("Auto Farm", 0)
			FarmTab:CreateSection("Farm Settings")

			FarmTab:CreateDropdown({
				Name = "Select Weapon",
				Options = { "Melee", "Sword", "Fruit" },
				CurrentOption = { "Melee" },
				MultipleOptions = false,
				Flag = "BF_Weapon",
				Callback = function(Option)
					HubConfig.SelectedWeapon = type(Option) == "table" and Option[1] or Option
				end,
			})

			FarmTab:CreateSlider({
				Name = "Farm Distance",
				Range = { 5, 30 },
				Increment = 1,
				Suffix = "Studs",
				CurrentValue = 15,
				Flag = "BF_FarmDist",
				Callback = function(Value)
					HubConfig.HoverHeight = Value
				end,
			})

			FarmTab:CreateSlider({
				Name = "Tween Speed",
				Range = { 150, 400 },
				Increment = 10,
				Suffix = "Studs/s",
				CurrentValue = 260,
				Flag = "BF_FlightSpeed",
				Callback = function(Value)
					HubConfig.FlightSpeed = Value
				end,
			})

			FarmTab:CreateToggle({
				Name = "Bring Mobs",
				CurrentValue = true,
				Flag = "BF_BringMobs",
				Callback = function(Value)
					HubConfig.BringMobs = Value
				end,
			})

			FarmTab:CreateToggle({
				Name = "Auto Buso Haki",
				CurrentValue = true,
				Flag = "BF_AutoBuso",
				Callback = function(Value)
					HubConfig.AutoBuso = Value
				end,
			})

			FarmTab:CreateSection("Level Farming")

			FarmTab:CreateToggle({
				Name = "Auto Farm Level",
				CurrentValue = false,
				Flag = "BF_AutoLevel",
				Callback = function(Value)
					HubConfig.AutoLevel = Value
				end,
			})

			FarmTab:CreateToggle({
				Name = "Auto Farm Nearest Mob",
				CurrentValue = false,
				Flag = "BF_AutoNearest",
				Callback = function(Value)
					HubConfig.AutoNearestMob = Value
				end,
			})

			FarmTab:CreateToggle({
				Name = "Auto Farm Bosses",
				CurrentValue = false,
				Flag = "BF_AutoBoss",
				Callback = function(Value)
					HubConfig.AutoBoss = Value
				end,
			})

			-- TAB 2: Combat & Stats
			local CombatTab = Window:CreateTab("Combat & Stats", 0)
			CombatTab:CreateSection("Combat & Aura")

			CombatTab:CreateToggle({
				Name = "Fast Attack Kill Aura",
				CurrentValue = false,
				Flag = "BF_KillAura",
				Callback = function(Value)
					HubConfig.KillAura = Value
				end,
			})

			CombatTab:CreateSlider({
				Name = "Mob Hitbox Expander",
				Range = { 15, 120 },
				Increment = 5,
				Suffix = "Studs",
				CurrentValue = 65,
				Flag = "BF_Hitbox",
				Callback = function(Value)
					HubConfig.HitboxSize = Value
				end,
			})

			CombatTab:CreateSection("Auto Stats")

			CombatTab:CreateToggle({
				Name = "Auto Melee Stat",
				CurrentValue = false,
				Flag = "BF_StatMelee",
				Callback = function(Value)
					HubConfig.AutoStatMelee = Value
				end,
			})

			CombatTab:CreateToggle({
				Name = "Auto Defense Stat",
				CurrentValue = false,
				Flag = "BF_StatDefense",
				Callback = function(Value)
					HubConfig.AutoStatDefense = Value
				end,
			})

			CombatTab:CreateToggle({
				Name = "Auto Sword Stat",
				CurrentValue = false,
				Flag = "BF_StatSword",
				Callback = function(Value)
					HubConfig.AutoStatSword = Value
				end,
			})

			CombatTab:CreateToggle({
				Name = "Auto Demon Fruit Stat",
				CurrentValue = false,
				Flag = "BF_StatFruit",
				Callback = function(Value)
					HubConfig.AutoStatFruit = Value
				end,
			})

			-- TAB 3: Misc & Anti-Ban
			local MiscTab = Window:CreateTab("Misc & Anti-Ban", 0)
			MiscTab:CreateSection("Account Protection")

			MiscTab:CreateToggle({
				Name = "Anti-Ban Remote Shield",
				CurrentValue = true,
				Flag = "BF_AntiBan",
				Callback = function(Value)
					AntiBanShield.Enabled = Value
				end,
			})

			MiscTab:CreateToggle({
				Name = "Anti AFK",
				CurrentValue = true,
				Flag = "BF_AntiAFK",
				Callback = function(Value)
					HubConfig.AntiAFK = Value
				end,
			})

			MiscTab:CreateButton({
				Name = "Check Shield Status",
				Callback = function()
					RayfieldLibrary:Notify({
						Title = "Anti-Ban Shield",
						Content = "Active: Blocked " .. tostring(AntiBanShield.BlockedCount) .. " malicious remote calls",
						Duration = 5,
					})
				end,
			})

			-- BF Logic Loops
			local function getBFEnemies()
				local enemies = {}
				local lp = Players and Players.LocalPlayer
				local char = lp and lp.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local folder = Workspace:FindFirstChild("Enemies")
				if folder then
					for _, mob in ipairs(folder:GetChildren()) do
						local hum = mob:FindFirstChildOfClass("Humanoid")
						local hrp = mob:FindFirstChild("HumanoidRootPart")
						if hum and hum.Health > 0 and hrp then
							local dist = root and (hrp.Position - root.Position).Magnitude or 9999
							table.insert(enemies, { model = mob, humanoid = hum, root = hrp, dist = dist })
						end
					end
				end
				table.sort(enemies, function(a, b) return a.dist < b.dist end)
				return enemies
			end

			local function equipBFWeapon()
				pcall(function()
					local lp = Players and Players.LocalPlayer
					local char = lp and lp.Character
					local bp = lp and lp:FindFirstChildOfClass("Backpack")
					if not char or not bp then return end
					local targetType = HubConfig.SelectedWeapon
					for _, tool in ipairs(bp:GetChildren()) do
						if tool:IsA("Tool") then
							local tType = tool:GetAttribute("WeaponType") or tool.ToolTip or tool.Name
							if string.find(string.lower(tType), string.lower(targetType), 1, true) then
								char.Humanoid:EquipTool(tool)
								break
							end
						end
					end
				end)
			end

			local function performBFAttack(targets)
				pcall(function()
					local remotes = ReplicatedStorage:FindFirstChild("Remotes")
					local validator = remotes and remotes:FindFirstChild("Validator")
					if validator then
						validator:FireServer(math.floor(os.clock()))
					end

					local combatRemote = (ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net") and ReplicatedStorage.Modules.Net:FindFirstChild("RE/CombatRegister"))
						or ReplicatedStorage:FindFirstChild("RE/CombatRegister", true)

					if combatRemote then
						combatRemote:FireServer(0.1)
					end

					if VirtualUser then
						VirtualUser:CaptureController()
						VirtualUser:ClickButton1(Vector2.new(640, 360))
					end
				end)
			end

			local function tweenBFFlight(targetPos)
				pcall(function()
					local lp = Players and Players.LocalPlayer
					local char = lp and lp.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					if not root then return end

					local bv = root:FindFirstChild("HaiAnh_BFAntiGrav")
					if not bv then
						bv = Instance.new("BodyVelocity")
						bv.Name = "HaiAnh_BFAntiGrav"
						bv.Velocity = Vector3.zero
						bv.MaxForce = Vector3.new(9e8, 9e8, 9e8)
						bv.Parent = root
					else
						bv.Velocity = Vector3.zero
					end

					local currentPos = root.Position
					local dist = (targetPos - currentPos).Magnitude
					local speed = math.max(HubConfig.FlightSpeed, 150)
					local step = math.min(dist, speed * 0.05)
					if dist > 5 then
						local dir = (targetPos - currentPos).Unit
						root.CFrame = CFrame.new(currentPos + dir * step, targetPos)
					else
						root.CFrame = CFrame.new(targetPos)
					end
				end)
			end

			task.spawn(function()
				while not rayfieldDestroyed do
					pcall(function()
						if HubConfig.AutoBuso then
							local lp = Players and Players.LocalPlayer
							local char = lp and lp.Character
							local hasHaki = char and (char:FindFirstChild("HasBuso") or char:GetAttribute("HasBuso"))
							if not hasHaki then
								local remotes = ReplicatedStorage:FindFirstChild("Remotes")
								local commF = remotes and remotes:FindFirstChild("CommF_")
								if commF then
									commF:InvokeServer("Buso")
								end
							end
						end

						if HubConfig.KillAura or HubConfig.AutoLevel or HubConfig.AutoNearestMob or HubConfig.AutoBoss then
							local enemies = getBFEnemies()
							if #enemies > 0 then
								equipBFWeapon()
								local target = enemies[1]
								if HubConfig.AutoLevel or HubConfig.AutoNearestMob or HubConfig.AutoBoss then
									local hoverPos = target.root.Position + Vector3.new(0, HubConfig.HoverHeight, 0)
									tweenBFFlight(hoverPos)
								end

								if HubConfig.BringMobs and #enemies > 1 then
									for i = 2, math.min(#enemies, 6) do
										pcall(function()
											enemies[i].root.CFrame = target.root.CFrame
											enemies[i].root.CanCollide = false
										end)
									end
								end

								performBFAttack(enemies)
							end
						end
					end)
					task.wait(0.04)
				end
			end)

			task.spawn(function()
				while not rayfieldDestroyed do
					pcall(function()
						if HubConfig.HitboxSize > 15 then
							local enemies = getBFEnemies()
							for _, mob in ipairs(enemies) do
								mob.root.Size = Vector3.new(HubConfig.HitboxSize, HubConfig.HitboxSize,
									HubConfig.HitboxSize)
								mob.root.Transparency = 0.85
								mob.root.CanCollide = false
							end
						end

						if HubConfig.AntiAFK and VirtualUser then
							VirtualUser:CaptureController()
							VirtualUser:ClickButton2(Vector2.new(50, 50))
						end
					end)
					task.wait(1)
				end
			end)
		end

		-- ============================================================================
		-- MENU 3: UNIVERSAL FALLBACK
		-- ============================================================================
		local function loadUniversalMenu()
			local Window = RayfieldLibrary:CreateWindow({
				Name = "HaiAnh Menu | Universal",
				LoadingTitle = "HaiAnh Menu",
				LoadingSubtitle = "Universal Hub",
				ConfigurationSaving = {
					Enabled = true,
					FolderName = "HaiAnhMenuConfig",
					FileName = "Universal"
				},
				KeySystem = false,
			})

			createFloatingToggle()

			local MainTab = Window:CreateTab("Main", 0)
			MainTab:CreateSection("Universal Protection")

			MainTab:CreateToggle({
				Name = "Anti-Ban Remote Shield",
				CurrentValue = true,
				Flag = "Uni_AntiBan",
				Callback = function(Value)
					AntiBanShield.Enabled = Value
				end,
			})

			MainTab:CreateToggle({
				Name = "Anti AFK",
				CurrentValue = true,
				Flag = "Uni_AntiAFK",
				Callback = function(Value)
					if Value and VirtualUser then
						VirtualUser:CaptureController()
						VirtualUser:ClickButton2(Vector2.new(50, 50))
					end
				end,
			})
		end


		local detectedGame = detectCurrentGame()
		if detectedGame == "AOTR" then
			loadAOTRMenu()
		elseif detectedGame == "BLOX_FRUITS" then
			loadBloxFruitsMenu()
		else
			loadUniversalMenu()
		end
	end)
end

return RayfieldLibrary
