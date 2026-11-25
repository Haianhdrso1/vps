--[[
	 __  __             _   _ ___
	|  \/  | __ _  ___ | | | |_ _|
	| |\/| |/ _` |/ __|| | | || |
	| |  | | (_| | (__ | |_| || |
	|_|  |_|\__,_|\___| \___/|___|

	MacUI — a macOS System Settings–style interface library for Roblox.

	Version : 4.4.0
	Author  : Kiwzu  (https://github.com/Kiwzu/Mac-OS-UI-LUA)
	Icons   : Lucide (ISC license) via the asset ids published with Fluent (MIT)

	The public API is a superset of the Fluent API, so most Fluent scripts
	work after swapping the loadstring. See README.md for the full reference.
]]

local MacUI = {
	Version = "4.4.0",
	Options = {},
	Windows = {},
	Unloaded = false,
	ThemeName = "Dark",
	Accent = Color3.fromRGB(235, 30, 50),
	FontFamily = "rbxasset://fonts/families/Roboto.json",
	MonoFamily = "rbxasset://fonts/families/RobotoMono.json",
	ReduceMotion = false,
	UndoEnabled = true,
	-- when this copy loaded: re-running a script keeps the newest copy
	LoadedAt = os.clock(),
}
MacUI.Flags = MacUI.Options

do
	local ok, face = pcall(Font.fromEnum, Enum.Font.Roboto)
	if ok and face then
		MacUI.FontFamily = face.Family
	end
	local okMono, mono = pcall(Font.fromEnum, Enum.Font.RobotoMono)
	if okMono and mono then
		MacUI.MonoFamily = mono.Family
	end
end

--------------------------------------------------------------------------------
-- Services & environment
--------------------------------------------------------------------------------

local cloneref = cloneref or function(object)
	return object
end

local function GetService(name)
	return cloneref(game:GetService(name))
end

local Players = GetService("Players")
local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local TextService = GetService("TextService")
local GuiService = GetService("GuiService")
local RunService = GetService("RunService")
local Workspace = GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local rgb = Color3.fromRGB

local function Viewport()
	local camera = Workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function ParentGui(gui)
	gui.ResetOnSpawn = false
	gui.Enabled = true
	local protect = (syn and syn.protect_gui) or protectgui or protect_gui
	if type(protect) == "function" then
		pcall(protect, gui)
	end
	if type(gethui) == "function" then
		local ok, container = pcall(gethui)
		if ok and typeof(container) == "Instance" then
			local okParent = pcall(function()
				gui.Parent = container
			end)
			if okParent and gui.Parent == container then
				return
			end
		end
	end
	local ok = pcall(function()
		local cg = GetService("CoreGui")
		gui.Parent = cg
	end)
	if ok and gui.Parent ~= nil then
		return
	end
	local lp = LocalPlayer or Players.LocalPlayer
	if not lp then
		pcall(function()
			lp = Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
		end)
		lp = lp or Players.LocalPlayer
		LocalPlayer = lp
	end
	if lp then
		local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 15)
		if pg then
			gui.Parent = pg
		end
	end
end

--------------------------------------------------------------------------------
-- Design tokens
--------------------------------------------------------------------------------

MacUI.Themes = {
	Dark = {
		Background = rgb(15, 15, 18),
		Sidebar = rgb(12, 12, 14),
		SidebarDivider = rgb(25, 25, 30),
		WindowStroke = rgb(35, 35, 42),
		Group = rgb(20, 20, 24),
		GroupStroke = rgb(35, 35, 42),
		Separator = rgb(30, 30, 36),
		Text = rgb(255, 255, 255),
		SubText = rgb(150, 150, 160),
		Tertiary = rgb(100, 100, 110),
		SelectionText = rgb(255, 255, 255),
		Control = rgb(25, 25, 30),
		ControlHover = rgb(38, 38, 45),
		ControlStroke = rgb(45, 45, 54),
		Button = rgb(28, 28, 34),
		ButtonHover = rgb(40, 40, 48),
		Field = rgb(16, 16, 20),
		FieldStroke = rgb(38, 38, 46),
		Search = rgb(22, 22, 26),
		SwitchOff = rgb(40, 40, 46),
		Knob = rgb(255, 255, 255),
		Track = rgb(35, 35, 42),
		SegmentBg = rgb(28, 28, 34),
		SegmentSelected = rgb(220, 25, 45),
		Hover = rgb(255, 255, 255),
		HoverTransparency = 0.94,
		Menu = rgb(22, 22, 26),
		MenuStroke = rgb(38, 38, 46),
		Hud = rgb(25, 25, 30),
		HudStroke = rgb(40, 40, 48),
		Scrollbar = rgb(80, 80, 90),
		Shadow = rgb(0, 0, 0),
		ShadowTransparency = 0.3,
		Dim = rgb(0, 0, 0),
		DimTransparency = 0.45,
		Destructive = rgb(235, 30, 50),
		WindowBorder = rgb(0, 0, 0),
		WindowBorderTransparency = 0.3,
		WindowHighlight = rgb(255, 255, 255),
		WindowHighlightTransparency = 0.88,
		Code = rgb(15, 15, 18),
		GlassTransparency = 0.28,
	},
	Light = {
		Background = rgb(243, 243, 246),
		Sidebar = rgb(230, 230, 234),
		SidebarDivider = rgb(208, 208, 213),
		WindowStroke = rgb(196, 196, 202),
		Group = rgb(255, 255, 255),
		GroupStroke = rgb(222, 222, 227),
		Separator = rgb(229, 229, 234),
		Text = rgb(28, 28, 30),
		SubText = rgb(110, 110, 116),
		Tertiary = rgb(160, 160, 166),
		SelectionText = rgb(255, 255, 255),
		Control = rgb(229, 229, 234),
		ControlHover = rgb(216, 216, 222),
		ControlStroke = rgb(206, 206, 212),
		Button = rgb(255, 255, 255),
		ButtonHover = rgb(246, 246, 248),
		Field = rgb(255, 255, 255),
		FieldStroke = rgb(206, 206, 212),
		Search = rgb(226, 226, 231),
		SwitchOff = rgb(221, 221, 226),
		Knob = rgb(255, 255, 255),
		Track = rgb(218, 218, 224),
		SegmentBg = rgb(226, 226, 231),
		SegmentSelected = rgb(255, 255, 255),
		Hover = rgb(0, 0, 0),
		HoverTransparency = 0.95,
		Menu = rgb(249, 249, 251),
		MenuStroke = rgb(206, 206, 212),
		Hud = rgb(236, 236, 240),
		HudStroke = rgb(196, 196, 202),
		Scrollbar = rgb(150, 150, 156),
		Shadow = rgb(0, 0, 0),
		ShadowTransparency = 0.55,
		Dim = rgb(0, 0, 0),
		DimTransparency = 0.7,
		Destructive = rgb(255, 59, 48),
		WindowBorder = rgb(0, 0, 0),
		WindowBorderTransparency = 0.8,
		WindowHighlight = rgb(255, 255, 255),
		WindowHighlightTransparency = 0.3,
		Code = rgb(245, 245, 247),
		GlassTransparency = 0.22,
	},
	Midnight = {
		Background = rgb(0, 0, 0),
		Sidebar = rgb(15, 15, 17),
		SidebarDivider = rgb(30, 30, 33),
		WindowStroke = rgb(52, 52, 56),
		Group = rgb(21, 21, 23),
		GroupStroke = rgb(35, 35, 39),
		Separator = rgb(37, 37, 41),
		Text = rgb(245, 245, 247),
		SubText = rgb(142, 142, 148),
		Tertiary = rgb(92, 92, 98),
		SelectionText = rgb(255, 255, 255),
		Control = rgb(50, 50, 54),
		ControlHover = rgb(63, 63, 68),
		ControlStroke = rgb(62, 62, 67),
		Button = rgb(54, 54, 58),
		ButtonHover = rgb(66, 66, 71),
		Field = rgb(10, 10, 11),
		FieldStroke = rgb(50, 50, 54),
		Search = rgb(28, 28, 31),
		SwitchOff = rgb(52, 52, 56),
		Knob = rgb(248, 248, 250),
		Track = rgb(46, 46, 50),
		SegmentBg = rgb(32, 32, 35),
		SegmentSelected = rgb(78, 78, 84),
		Hover = rgb(255, 255, 255),
		HoverTransparency = 0.94,
		Menu = rgb(26, 26, 28),
		MenuStroke = rgb(56, 56, 60),
		Hud = rgb(40, 40, 44),
		HudStroke = rgb(66, 66, 72),
		Scrollbar = rgb(110, 110, 116),
		Shadow = rgb(0, 0, 0),
		ShadowTransparency = 0.25,
		Dim = rgb(0, 0, 0),
		DimTransparency = 0.4,
		Destructive = rgb(255, 69, 58),
		WindowBorder = rgb(64, 64, 70),
		WindowBorderTransparency = 0.1,
		WindowHighlight = rgb(255, 255, 255),
		WindowHighlightTransparency = 0.94,
		Code = rgb(12, 12, 14),
		GlassTransparency = 0.3,
	},
}
MacUI.ThemeData = MacUI.Themes.Dark

-- The macOS accent colours (System Settings › Appearance)
MacUI.Accents = {
	Blue = rgb(10, 132, 255),
	Purple = rgb(191, 90, 242),
	Pink = rgb(255, 55, 95),
	Red = rgb(255, 69, 58),
	Orange = rgb(255, 159, 10),
	Yellow = rgb(255, 204, 0),
	Green = rgb(48, 209, 88),
	Graphite = rgb(142, 142, 147),
}
MacUI.AccentOrder = { "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite" }

-- Colours used for the rounded icon tiles in the sidebar (System Settings style)
MacUI.TileColors = {
	rgb(10, 132, 255), -- blue
	rgb(191, 90, 242), -- purple
	rgb(255, 159, 10), -- orange
	rgb(48, 209, 88), -- green
	rgb(255, 55, 95), -- pink
	rgb(64, 200, 224), -- teal
	rgb(94, 92, 230), -- indigo
	rgb(255, 69, 58), -- red
	rgb(142, 142, 147), -- gray
	rgb(0, 199, 190), -- mint
	rgb(255, 204, 0), -- yellow
	rgb(172, 142, 104), -- brown
}

local TRAFFIC = {
	{ Name = "Close",    Color = rgb(255, 95, 87),  Stroke = rgb(224, 68, 62),  Glyph = rgb(120, 10, 10) },
	{ Name = "Minimize", Color = rgb(254, 188, 46), Stroke = rgb(222, 161, 35), Glyph = rgb(140, 80, 0) },
	{ Name = "Zoom",     Color = rgb(40, 200, 64),  Stroke = rgb(26, 171, 41),  Glyph = rgb(0, 90, 10) },
}

local SHADOW_IMAGE = "rbxassetid://6014261993"

--------------------------------------------------------------------------------
-- Icons (Lucide)
--------------------------------------------------------------------------------

local IconData =
"accessibility=10709751939;activity=10709752035;air-vent=10709752131;airplay=10709752254;alarm-check=10709752405;alarm-clock=10709752630;alarm-clock-off=10709752508;alarm-minus=10709752732;alarm-plus=10709752825;album=10709752906;alert-circle=10709752996;alert-octagon=10709753064;alert-triangle=10709753149;align-center=10709753570;align-center-horizontal=10709753272;align-center-vertical=10709753421;align-end-horizontal=10709753692;align-end-vertical=10709753808;align-horizontal-distribute-center=10747779791;align-horizontal-distribute-end=10747784534;align-horizontal-distribute-start=10709754118;align-horizontal-justify-center=10709754204;align-horizontal-justify-end=10709754317;align-horizontal-justify-start=10709754436;align-horizontal-space-around=10709754590;align-horizontal-space-between=10709754749;align-justify=10709759610;align-left=10709759764;align-right=10709759895;align-start-horizontal=10709760051;align-start-vertical=10709760244;align-vertical-distribute-center=10709760351;align-vertical-distribute-end=10709760434;align-vertical-distribute-start=10709760612;align-vertical-justify-center=10709760814;align-vertical-justify-end=10709761003;align-vertical-justify-start=10709761176;align-vertical-space-around=10709761324;align-vertical-space-between=10709761434;anchor=10709761530;angry=10709761629;annoyed=10709761722;aperture=10709761813;apple=10709761889;archive=10709762233;archive-restore=10709762058;armchair=10709762327;arrow-big-down=10747796644;arrow-big-left=10709762574;arrow-big-right=10709762727;arrow-big-up=10709762879;arrow-down=10709767827;arrow-down-circle=10709763034;arrow-down-left=10709767656;arrow-down-right=10709767750;arrow-left=10709768114;arrow-left-circle=10709767936;arrow-left-right=10709768019;arrow-right=10709768347;arrow-right-circle=10709768226;arrow-up=10709768939;arrow-up-circle=10709768432;arrow-up-down=10709768538;arrow-up-left=10709768661;arrow-up-right=10709768787;asterisk=10709769095;at-sign=10709769286;award=10709769406;axe=10709769508;axis-3d=10709769598;baby=10709769732;backpack=10709769841;baggage-claim=10709769935;banana=10709770005;banknote=10709770178;bar-chart=10709773755;bar-chart-2=10709770317;bar-chart-3=10709770431;bar-chart-4=10709770560;bar-chart-horizontal=10709773669;barcode=10747360675;baseline=10709773863;bath=10709773963;battery=10709774640;battery-charging=10709774068;battery-full=10709774206;battery-low=10709774370;battery-medium=10709774513;beaker=10709774756;bed=10709775036;bed-double=10709774864;bed-single=10709774968;beer=10709775167;bell=10709775704;bell-minus=10709775241;bell-off=10709775320;bell-plus=10709775448;bell-ring=10709775560;bike=10709775894;binary=10709776050;bitcoin=10709776126;bluetooth=10709776655;bluetooth-connected=10709776240;bluetooth-off=10709776344;bluetooth-searching=10709776501;bold=10747813908;bomb=10709781460;bone=10709781605;book=10709781824;book-open=10709781717;bookmark=10709782154;bookmark-minus=10709781919;bookmark-plus=10709782044;bot=10709782230;box=10709782497;box-select=10709782342;boxes=10709782582;briefcase=10709782662;brush=10709782758;bug=10709782845;building=10709783051;building-2=10709782939;bus=10709783137;cake=10709783217;calculator=10709783311;calendar=10709789505;calendar-check=10709783474;calendar-check-2=10709783392;calendar-clock=10709783577;calendar-days=10709783673;calendar-heart=10709783835;calendar-minus=10709783959;calendar-off=10709788784;calendar-plus=10709788937;calendar-range=10709789053;calendar-search=10709789200;calendar-x=10709789407;calendar-x-2=10709789329;camera=10709789686;camera-off=10747822677;car=10709789810;carrot=10709789960;cast=10709790097;charge=10709790202;check=10709790644;check-circle=10709790387;check-circle-2=10709790298;check-square=10709790537;chef-hat=10709790757;cherry=10709790875;chevron-down=10709790948;chevron-first=10709791015;chevron-last=10709791130;chevron-left=10709791281;chevron-right=10709791437;chevron-up=10709791523;chevrons-down=10709796864;chevrons-down-up=10709791632;chevrons-left=10709797151;chevrons-left-right=10709797006;chevrons-right=10709797382;chevrons-right-left=10709797274;chevrons-up=10709797622;chevrons-up-down=10709797508;chrome=10709797725;circle=10709798174;circle-dot=10709797837;circle-ellipsis=10709797985;circle-slashed=10709798100;citrus=10709798276;clapperboard=10709798350;clipboard=10709799288;clipboard-check=10709798443;clipboard-copy=10709798574;clipboard-edit=10709798682;clipboard-list=10709798792;clipboard-signature=10709798890;clipboard-type=10709798999;clipboard-x=10709799124;clock=10709805144;clock-1=10709799535;clock-10=10709799718;clock-11=10709799818;clock-12=10709799962;clock-2=10709803876;clock-3=10709803989;clock-4=10709804164;clock-5=10709804291;clock-6=10709804435;clock-7=10709804599;clock-8=10709804784;clock-9=10709804996;cloud=10709806740;cloud-cog=10709805262;cloud-drizzle=10709805371;cloud-fog=10709805477;cloud-hail=10709805596;cloud-lightning=10709805727;cloud-moon=10709805942;cloud-moon-rain=10709805838;cloud-off=10709806060;cloud-rain=10709806277;cloud-rain-wind=10709806166;cloud-snow=10709806374;cloud-sun=10709806631;cloud-sun-rain=10709806475;cloudy=10709806859;clover=10709806995;code=10709810463;code-2=10709807111;codepen=10709810534;codesandbox=10709810676;coffee=10709810814;cog=10709810948;coins=10709811110;columns=10709811261;command=10709811365;compass=10709811445;component=10709811595;concierge-bell=10709811706;connection=10747361219;contact=10709811834;contrast=10709811939;cookie=10709812067;copy=10709812159;copyleft=10709812251;copyright=10709812311;corner-down-left=10709812396;corner-down-right=10709812485;corner-left-down=10709812632;corner-left-up=10709812784;corner-right-down=10709812939;corner-right-up=10709813094;corner-up-left=10709813185;corner-up-right=10709813281;cpu=10709813383;croissant=10709818125;crop=10709818245;cross=10709818399;crosshair=10709818534;crown=10709818626;cup-soda=10709818763;curly-braces=10709818847;currency=10709818931;database=10709818996;delete=10709819059;diamond=10709819149;dice-1=10709819266;dice-2=10709819361;dice-3=10709819508;dice-4=10709819670;dice-5=10709819801;dice-6=10709819896;dices=10723343321;diff=10723343416;disc=10723343537;divide=10723343805;divide-circle=10723343636;divide-square=10723343737;dollar-sign=10723343958;download=10723344270;download-cloud=10723344088;droplet=10723344432;droplets=10734883356;drumstick=10723344737;edit=10734883598;edit-2=10723344885;edit-3=10723345088;egg=10723345518;egg-fried=10723345347;electricity=10723345749;electricity-off=10723345643;equal=10723345990;equal-not=10723345866;eraser=10723346158;euro=10723346372;expand=10723346553;external-link=10723346684;eye=10723346959;eye-off=10723346871;factory=10723347051;fan=10723354359;fast-forward=10723354521;feather=10723354671;figma=10723354801;file=10723374641;file-archive=10723354921;file-audio=10723355148;file-audio-2=10723355026;file-axis-3d=10723355272;file-badge=10723355622;file-badge-2=10723355451;file-bar-chart=10723355887;file-bar-chart-2=10723355746;file-box=10723355989;file-check=10723356210;file-check-2=10723356100;file-clock=10723356329;file-code=10723356507;file-cog=10723356830;file-cog-2=10723356676;file-diff=10723357039;file-digit=10723357151;file-down=10723357322;file-edit=10723357495;file-heart=10723357637;file-image=10723357790;file-input=10723357933;file-json=10723364435;file-json-2=10723364361;file-key=10723364605;file-key-2=10723364515;file-line-chart=10723364725;file-lock=10723364957;file-lock-2=10723364861;file-minus=10723365254;file-minus-2=10723365086;file-output=10723365457;file-pie-chart=10723365598;file-plus=10723365877;file-plus-2=10723365766;file-question=10723365987;file-scan=10723366167;file-search=10723366550;file-search-2=10723366340;file-signature=10723366741;file-spreadsheet=10723366962;file-symlink=10723367098;file-terminal=10723367244;file-text=10723367380;file-type=10723367606;file-type-2=10723367509;file-up=10723367734;file-video=10723373884;file-video-2=10723367834;file-volume=10723374172;file-volume-2=10723374030;file-warning=10723374276;file-x=10723374544;file-x-2=10723374378;files=10723374759;film=10723374981;filter=10723375128;fingerprint=10723375250;flag=10723375890;flag-off=10723375443;flag-triangle-left=10723375608;flag-triangle-right=10723375727;flame=10723376114;flashlight=10723376471;flashlight-off=10723376365;flask-conical=10734883986;flask-round=10723376614;flip-horizontal=10723376884;flip-horizontal-2=10723376745;flip-vertical=10723377138;flip-vertical-2=10723377026;flower=10747830374;flower-2=10723377305;focus=10723377537;folder=10723387563;folder-archive=10723384478;folder-check=10723384605;folder-clock=10723384731;folder-closed=10723384893;folder-cog=10723385213;folder-cog-2=10723385036;folder-down=10723385338;folder-edit=10723385445;folder-heart=10723385545;folder-input=10723385721;folder-key=10723385848;folder-lock=10723386005;folder-minus=10723386127;folder-open=10723386277;folder-output=10723386386;folder-plus=10723386531;folder-search=10723386787;folder-search-2=10723386674;folder-symlink=10723386930;folder-tree=10723387085;folder-up=10723387265;folder-x=10723387448;folders=10723387721;form-input=10723387841;forward=10723388016;frame=10723394389;framer=10723394565;frown=10723394681;fuel=10723394846;function-square=10723395041;gamepad=10723395457;gamepad-2=10723395215;gauge=10723395708;gavel=10723395896;gem=10723396000;ghost=10723396107;gift=10723396402;gift-card=10723396225;git-branch=10723396676;git-branch-plus=10723396542;git-commit=10723396812;git-compare=10723396954;git-fork=10723397049;git-merge=10723397165;git-pull-request=10723397431;git-pull-request-closed=10723397268;git-pull-request-draft=10734884302;glass=10723397788;glass-2=10723397529;glass-water=10723397678;glasses=10723397895;globe=10723404337;globe-2=10723398002;grab=10723404472;graduation-cap=10723404691;grape=10723404822;grid=10723404936;grip-horizontal=10723405089;grip-vertical=10723405236;hammer=10723405360;hand=10723405649;hand-metal=10723405508;hard-drive=10723405749;hard-hat=10723405859;hash=10723405975;haze=10723406078;headphones=10723406165;heart=10723406885;heart-crack=10723406299;heart-handshake=10723406480;heart-off=10723406662;heart-pulse=10723406795;help-circle=10723406988;hexagon=10723407092;highlighter=10723407192;history=10723407335;home=10723407389;hourglass=10723407498;ice-cream=10723414308;image=10723415040;image-minus=10723414487;image-off=10723414677;image-plus=10723414827;import=10723415205;inbox=10723415335;indent=10723415494;indian-rupee=10723415642;infinity=10723415766;info=10723415903;inspect=10723416057;italic=10723416195;japanese-yen=10723416363;joystick=10723416527;key=10723416652;keyboard=10723416765;lamp=10723417513;lamp-ceiling=10723416922;lamp-desk=10723417016;lamp-floor=10723417131;lamp-wall-down=10723417240;lamp-wall-up=10723417356;landmark=10723417608;languages=10723417703;laptop=10723423881;laptop-2=10723417797;lasso=10723424235;lasso-select=10723424058;laugh=10723424372;layers=10723424505;layout=10723425376;layout-dashboard=10723424646;layout-grid=10723424838;layout-list=10723424963;layout-template=10723425187;leaf=10723425539;library=10723425615;life-buoy=10723425685;lightbulb=10723425852;lightbulb-off=10723425762;line-chart=10723426393;link=10723426722;link-2=10723426595;link-2-off=10723426513;list=10723433811;list-checks=10734884548;list-end=10723426886;list-minus=10723426986;list-music=10723427081;list-ordered=10723427199;list-plus=10723427334;list-start=10723427494;list-video=10723427619;list-x=10723433655;loader=10723434070;loader-2=10723433935;locate=10723434557;locate-fixed=10723434236;locate-off=10723434379;lock=10723434711;log-in=10723434830;log-out=10723434906;luggage=10723434993;magnet=10723435069;mail=10734885430;mail-check=10723435182;mail-minus=10723435261;mail-open=10723435342;mail-plus=10723435443;mail-question=10723435515;mail-search=10734884739;mail-warning=10734885015;mail-x=10734885247;mails=10734885614;map=10734886202;map-pin=10734886004;map-pin-off=10734885803;maximize=10734886735;maximize-2=10734886496;medal=10734887072;megaphone=10734887454;megaphone-off=10734887311;meh=10734887603;menu=10734887784;message-circle=10734888000;message-square=10734888228;mic=10734888864;mic-2=10734888430;mic-off=10734888646;microscope=10734889106;microwave=10734895076;milestone=10734895310;minimize=10734895698;minimize-2=10734895530;minus=10734896206;minus-circle=10734895856;minus-square=10734896029;monitor=10734896881;monitor-off=10734896360;monitor-speaker=10734896512;moon=10734897102;more-horizontal=10734897250;more-vertical=10734897387;mountain=10734897956;mountain-snow=10734897665;mouse=10734898592;mouse-pointer=10734898476;mouse-pointer-2=10734898194;mouse-pointer-click=10734898355;move=10734900011;move-3d=10734898756;move-diagonal=10734899164;move-diagonal-2=10734898934;move-horizontal=10734899414;move-vertical=10734899821;music=10734905958;music-2=10734900215;music-3=10734905665;music-4=10734905823;navigation=10734906744;navigation-2=10734906332;navigation-2-off=10734906144;navigation-off=10734906580;network=10734906975;newspaper=10734907168;octagon=10734907361;option=10734907649;outdent=10734907933;package=10734909540;package-2=10734908151;package-check=10734908384;package-minus=10734908626;package-open=10734908793;package-plus=10734909016;package-search=10734909196;package-x=10734909375;paint-bucket=10734909847;paintbrush=10734910187;paintbrush-2=10734910030;palette=10734910430;palmtree=10734910680;paperclip=10734910927;party-popper=10734918735;pause=10734919336;pause-circle=10735024209;pause-octagon=10734919143;pen-tool=10734919503;pencil=10734919691;percent=10734919919;person-standing=10734920149;phone=10734921524;phone-call=10734920305;phone-forwarded=10734920508;phone-incoming=10734920694;phone-missed=10734920845;phone-off=10734921077;phone-outgoing=10734921288;pie-chart=10734921727;piggy-bank=10734921935;pin=10734922324;pin-off=10734922180;pipette=10734922497;pizza=10734922774;plane=10734922971;play=10734923549;play-circle=10734923214;plus=10734924532;plus-circle=10734923868;plus-square=10734924219;podcast=10734929553;pointer=10734929723;pound-sterling=10734929981;power=10734930466;power-off=10734930257;printer=10734930632;puzzle=10734930886;quote=10734931234;radio=10734931596;radio-receiver=10734931402;rectangle-horizontal=10734931777;rectangle-vertical=10734932081;recycle=10734932295;redo=10734932822;redo-2=10734932586;refresh-ccw=10734933056;refresh-cw=10734933222;refrigerator=10734933465;regex=10734933655;repeat=10734933966;repeat-1=10734933826;reply=10734934252;reply-all=10734934132;rewind=10734934347;rocket=10734934585;rocking-chair=10734939942;rotate-3d=10734940107;rotate-ccw=10734940376;rotate-cw=10734940654;rss=10734940825;ruler=10734941018;russian-ruble=10734941199;sailboat=10734941354;save=10734941499;scale=10734941912;scale-3d=10734941739;scaling=10734942072;scan=10734942565;scan-face=10734942198;scan-line=10734942351;scissors=10734942778;screen-share=10734943193;screen-share-off=10734942967;scroll=10734943448;search=10734943674;send=10734943902;separator-horizontal=10734944115;separator-vertical=10734944326;server=10734949856;server-cog=10734944444;server-crash=10734944554;server-off=10734944668;settings=10734950309;settings-2=10734950020;share=10734950813;share-2=10734950553;sheet=10734951038;shield=10734951847;shield-alert=10734951173;shield-check=10734951367;shield-close=10734951535;shield-off=10734951684;shirt=10734952036;shopping-bag=10734952273;shopping-cart=10734952479;shovel=10734952773;shower-head=10734952942;shrink=10734953073;shrub=10734953241;shuffle=10734953451;sidebar=10734954301;sidebar-close=10734953715;sidebar-open=10734954000;sigma=10734954538;signal=10734961133;signal-high=10734954807;signal-low=10734955080;signal-medium=10734955336;signal-zero=10734960878;siren=10734961284;skip-back=10734961526;skip-forward=10734961809;skull=10734962068;slack=10734962339;slash=10734962600;slice=10734963024;sliders=10734963400;sliders-horizontal=10734963191;smartphone=10734963940;smartphone-charging=10734963671;smile=10734964441;smile-plus=10734964188;snowflake=10734964600;sofa=10734964852;sort-asc=10734965115;sort-desc=10734965287;speaker=10734965419;sprout=10734965572;square=10734965702;star=10734966248;star-half=10734965897;star-off=10734966097;stethoscope=10734966384;sticker=10734972234;sticky-note=10734972463;stop-circle=10734972621;stretch-horizontal=10734972862;stretch-vertical=10734973130;strikethrough=10734973290;subscript=10734973457;sun=10734974297;sun-dim=10734973645;sun-medium=10734973778;sun-moon=10734973999;sun-snow=10734974130;sunrise=10734974522;sunset=10734974689;superscript=10734974850;swiss-franc=10734975024;switch-camera=10734975214;sword=10734975486;swords=10734975692;syringe=10734975932;table=10734976230;table-2=10734976097;tablet=10734976394;tag=10734976528;tags=10734976739;target=10734977012;tent=10734981750;terminal=10734982144;terminal-square=10734981995;text-cursor=10734982395;text-cursor-input=10734982297;thermometer=10734983134;thermometer-snowflake=10734982571;thermometer-sun=10734982771;thumbs-down=10734983359;thumbs-up=10734983629;ticket=10734983868;timer=10734984606;timer-off=10734984138;timer-reset=10734984355;toggle-left=10734984834;toggle-right=10734985040;tornado=10734985247;toy-brick=10747361919;train=10747362105;trash=10747362393;trash-2=10747362241;tree-deciduous=10747362534;tree-pine=10747362748;trees=10747363016;trending-down=10747363205;trending-up=10747363465;triangle=10747363621;trophy=10747363809;truck=10747364031;tv=10747364593;tv-2=10747364302;type=10747364761;umbrella=10747364971;underline=10747365191;undo=10747365484;undo-2=10747365359;unlink=10747365771;unlink-2=10747397871;unlock=10747366027;upload=10747366434;upload-cloud=10747366266;usb=10747366606;user=10747373176;user-check=10747371901;user-cog=10747372167;user-minus=10747372346;user-plus=10747372702;user-x=10747372992;users=10747373426;utensils=10747373821;utensils-crossed=10747373629;venetian-mask=10747374003;verified=10747374131;vibrate=10747374489;vibrate-off=10747374269;video=10747374938;video-off=10747374721;view=10747375132;voicemail=10747375281;volume=10747376008;volume-1=10747375450;volume-2=10747375679;volume-x=10747375880;wallet=10747376205;wand=10747376565;wand-2=10747376349;watch=10747376722;waves=10747376931;webcam=10747381992;wifi=10747382504;wifi-off=10747382268;wind=10747382750;wrap-text=10747383065;wrench=10747383470;x=10747384394;x-circle=10747383819;x-octagon=10747384037;x-square=10747384217;zoom-in=10747384552;zoom-out=10747384679"

local Icons = {}
for name, id in string.gmatch(IconData, "([%w%-]+)=(%d+)") do
	Icons[name] = "rbxassetid://" .. id
end
local IconAliases = {
	["panel-left"] = "sidebar",
	["store"] = "shopping-bag",
	["sparkles"] = "star",
	["user-circle"] = "user",
	["app-window"] = "layout",
}
MacUI.Icons = Icons

function MacUI:GetIcon(name)
	if name == nil or name == "" then
		return nil
	end
	if type(name) == "number" then
		return "rbxassetid://" .. name
	end
	name = tostring(name)
	if name:find("^rbxasset") or name:find("^https?://") then
		return name
	end
	if name:match("^%d+$") then
		return "rbxassetid://" .. name
	end
	local key = (name:lower():gsub("^lucide%-", ""))
	return Icons[key] or Icons[IconAliases[key] or ""]
end

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

local function SafeCall(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[MacUI] callback error: " .. tostring(err))
	end
end

local function Spawn(fn, ...)
	if type(fn) == "function" then
		task.spawn(SafeCall, fn, ...)
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(fn)
	local handler = { Fn = fn, Connected = true }
	table.insert(self._handlers, handler)
	local handlers = self._handlers
	local connection = { Connected = true }
	function connection.Disconnect()
		connection.Connected = false
		handler.Connected = false
		local index = table.find(handlers, handler)
		if index then
			table.remove(handlers, index)
		end
	end

	return connection
end

function Signal:Fire(...)
	for _, handler in ipairs(table.clone(self._handlers)) do
		if handler.Connected then
			Spawn(handler.Fn, ...)
		end
	end
end

MacUI.ThemeChanged = Signal.new()
MacUI.AccentChanged = Signal.new()
-- Fires (names) when a theme is added or removed.
MacUI.ThemesChanged = Signal.new()
-- Fires (idx, value, element) whenever an element with an index changes.
MacUI.OptionChanged = Signal.new()
-- Fires when keybinds or element shortcuts change (drives the shortcut list).
local ShortcutsChanged = Signal.new()
-- Fires (element, message) when an element's callback errors.
MacUI.CallbackError = Signal.new()
-- Fires (paused) when the performance guard pauses or restores effects.
MacUI.PerformanceChanged = Signal.new()
-- Performance guard state (see MacUI:SetPerformanceGuard).
local Guard = { Enabled = false, Engaged = false, Applying = false, MinFps = 30, Notify = true }
-- Fires when a timer starts, finishes or is cancelled.
MacUI.TimersChanged = Signal.new()

-- Runs an element's callback on its own thread. An error also shows on the
-- element's row as a red badge with the message (see RowMethods:_ShowError).
local function RunCallback(element, fn, ...)
	if type(fn) ~= "function" then
		return
	end
	task.spawn(function(...)
		local trace
		local ok, err = xpcall(fn, function(message)
			trace = debug.traceback(tostring(message), 2)
			return message
		end, ...)
		if ok then
			return
		end
		local message = tostring(err)
		local title = element and element.Title
		warn("[MacUI] callback error" .. (title and (' in "' .. tostring(title) .. '"') or "") .. ": " .. message)
		local row = element and element.Row
		if row and row._ShowError and not row.Destroyed then
			row:_ShowError(message, trace)
		end
		MacUI.CallbackError:Fire(element, message)
	end, ...)
end

-- Set while a keybind is recording so the same key press doesn't also
-- trigger other keybinds or the window's show/hide key.
local KeyCapture = { Active = false, Token = 0, EndedAt = -1 }

-- When the user last clicked or typed in the interface (not the game), and
-- whether a press that began on it is still held. Only that counts as the
-- user's own change for undo, macros and suggestions: walking, turning the
-- camera or a script acting on its own doesn't.
local Activity = { Last = -1, Pressing = nil }
local function MarkActivity()
	Activity.Last = os.clock()
end

-- The GUI objects that make up the interface (windows, open menus, banners,
-- the dock...). Presses elsewhere, like the game's own buttons or the mobile
-- thumbstick, aren't the user using the interface.
local InterfaceRoots = setmetatable({}, { __mode = "k" })

local function OverInterface(position)
	for root in pairs(InterfaceRoots) do
		if root.Parent and root.Visible then
			local layer = root:FindFirstAncestorOfClass("ScreenGui")
			local corner, size = root.AbsolutePosition, root.AbsoluteSize
			if
				(not layer or layer.Enabled)
				and position.X >= corner.X
				and position.X <= corner.X + size.X
				and position.Y >= corner.Y
				and position.Y <= corner.Y + size.Y
			then
				return true
			end
		end
	end
	return false
end

-- Typing in one of the interface's own text fields (not the chat).
local function TypingInInterface()
	local box = UserInputService:GetFocusedTextBox()
	if not box then
		return false
	end
	for root in pairs(InterfaceRoots) do
		if box:IsDescendantOf(root) then
			return true
		end
	end
	return false
end

-- Records the next key press. `done(key)` receives a KeyCode name, "MB2"/"MB3"
-- (keyboard-only captures treat those as cancel), "None" (Backspace/Delete
-- clears) or false (Escape or a click cancels). Returns a handle whose
-- Disconnect() abandons the capture without calling `done`.
local function CaptureKey(done, keyboardOnly)
	KeyCapture.Token = KeyCapture.Token + (1)
	local token = KeyCapture.Token
	KeyCapture.Active = true
	local connection
	local function Finish()
		if connection then
			connection:Disconnect()
			connection = nil
		end
		KeyCapture.EndedAt = os.clock()
		-- keep the guard up until every other handler has seen this key press,
		-- unless a newer capture has started in the meantime
		task.delay(0.1, function()
			if KeyCapture.Token == token then
				KeyCapture.Active = false
			end
		end)
	end
	connection = UserInputService.InputBegan:Connect(function(input)
		if MacUI.Unloaded then
			Finish() -- unloaded while waiting: nothing to bind any more
			return
		end
		local key
		local kind = input.UserInputType
		if kind == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.None then
				return
			elseif input.KeyCode == Enum.KeyCode.Escape then
				key = false
			elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				key = "None"
			else
				key = input.KeyCode.Name
			end
		elseif kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
			key = false -- clicking anywhere cancels, like the macOS shortcut recorder
		elseif kind == Enum.UserInputType.MouseButton2 then
			key = not keyboardOnly and "MB2" or false
		elseif kind == Enum.UserInputType.MouseButton3 then
			key = not keyboardOnly and "MB3" or false
		else
			return
		end
		Finish()
		MarkActivity()
		done(key)
	end)
	local handle = {}
	function handle:Disconnect()
		if connection then
			Finish()
		end
	end

	return handle
end

-- True for a moment after a capture ends, so the click that ended it isn't
-- also taken as a click on what's under the mouse (a key cap would re-arm).
local function JustCaptured()
	return os.clock() - KeyCapture.EndedAt < 0.35
end

local function KeyMatches(input, key)
	if not key or key == "None" then
		return false
	end
	local kind = input.UserInputType
	if kind == Enum.UserInputType.Keyboard then
		return input.KeyCode.Name == key
	elseif kind == Enum.UserInputType.MouseButton1 then
		return key == "MB1"
	elseif kind == Enum.UserInputType.MouseButton2 then
		return key == "MB2"
	elseif kind == Enum.UserInputType.MouseButton3 then
		return key == "MB3"
	end
	return false
end

-- Mouse position in the coordinate space of our ScreenGuis (IgnoreGuiInset = false).
local function MousePosition()
	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

-- For text shown in RichText labels (error messages can contain < and >).
local function EscapeRich(text)
	return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function CopyToClipboard(text)
	local copy = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	if type(copy) ~= "function" then
		return false
	end
	return (pcall(copy, tostring(text)))
end

local function SameValue(a, b)
	if type(a) == "table" and type(b) == "table" then
		for key, value in pairs(a) do
			if b[key] ~= value then
				return false
			end
		end
		for key, value in pairs(b) do
			if a[key] ~= value then
				return false
			end
		end
		return true
	end
	return a == b
end

local function CopyValue(value)
	if type(value) == "table" then
		return table.clone(value)
	end
	return value
end

local function IsTruthy(value)
	if type(value) == "table" then
		return next(value) ~= nil
	elseif type(value) == "string" then
		return value ~= "" and value ~= "None"
	elseif type(value) == "number" then
		return value ~= 0
	end
	return value == true
end

local function Tween(object, goals, duration, style, direction)
	if MacUI.ReduceMotion then
		duration = 0
	end
	local tween = TweenService:Create(
		object,
		TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
		goals
	)
	tween:Play()
	return tween
end

local function Round(value, decimals)
	local factor = 10 ^ (decimals or 0)
	return math.floor(value * factor + 0.5) / factor
end

-- A Rounding option as whole decimal places (a stray 1.5 would break
-- string.format).
local function Places(value, fallback)
	value = tonumber(value) or fallback or 0
	if value ~= value then
		value = 0
	end
	return math.clamp(math.floor(value), -6, 10)
end

-- The decimal places a step needs: 0.25 -> 2, 1e-05 -> 5.
local function StepPlaces(step)
	step = tonumber(step)
	if not step or step <= 0 or step ~= step or step == math.huge then
		return 0
	end
	for places = 0, 10 do
		local scaled = step * 10 ^ places
		if math.abs(scaled - math.floor(scaled + 0.5)) < 1e-9 then
			return places
		end
	end
	return 10
end

-- A finite number, or nil.
local function Finite(value)
	value = tonumber(value)
	if value == nil or value ~= value or value == math.huge or value == -math.huge then
		return nil
	end
	return value
end

local PushButton -- defined with the element helpers below

local function IsPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

-- A drag follows the input that started it: the mouse, or that one finger. A
-- second finger (the movement thumbstick, say) neither moves nor ends it.
local function DragMoves(began, input)
	if began.UserInputType == Enum.UserInputType.Touch then
		return input == began
	end
	return input.UserInputType == Enum.UserInputType.MouseMovement
end

local function DragEnds(began, input)
	if began.UserInputType == Enum.UserInputType.Touch then
		return input == began
	end
	return input.UserInputType == Enum.UserInputType.MouseButton1
end

-- A phone or tablet with no keyboard.
local function TouchOnly()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local FontCache = {}
local CachedFontFamily = nil

local function GetFont(weight)
	local w = weight or Enum.FontWeight.Regular
	if CachedFontFamily ~= MacUI.FontFamily then
		table.clear(FontCache)
		CachedFontFamily = MacUI.FontFamily
	end
	local f = FontCache[w]
	if not f then
		f = Font.new(MacUI.FontFamily, w, Enum.FontStyle.Normal)
		FontCache[w] = f
	end
	return f
end

local MeasureFonts = {
	[Enum.FontWeight.Regular] = Enum.Font.Roboto,
	[Enum.FontWeight.Medium] = Enum.Font.SourceSansSemibold,
	[Enum.FontWeight.SemiBold] = Enum.Font.SourceSansBold,
	[Enum.FontWeight.Bold] = Enum.Font.SourceSansBold,
}

-- Width of a single line of text in logical (unscaled) pixels.
local function MeasureText(text, size, weight)
	local ok, bounds = pcall(function()
		return TextService:GetTextSize(
			tostring(text),
			size,
			MeasureFonts[weight or Enum.FontWeight.Regular] or Enum.Font.Roboto,
			Vector2.new(10000, 1000)
		)
	end)
	if ok and bounds then
		return bounds.X
	end
	return #tostring(text) * size * 0.52
end

--------------------------------------------------------------------------------
-- Theme registry: every themed property is re-resolved when the theme,
-- accent or an element's state changes.
--------------------------------------------------------------------------------

local ThemeRegistry = {}
local FontRegistry = {}

local function Resolve(token)
	if type(token) == "function" then
		return token(MacUI.ThemeData)
	elseif token == "Accent" then
		return MacUI.Accent
	end
	local value = MacUI.ThemeData[token]
	if value == nil then
		value = MacUI.Themes.Dark[token]
	end
	return value
end

-- Drops registry entries when an instance is destroyed so closed popups,
-- banners and dialogs can be garbage collected.
local function Watch(instance)
	instance.Destroying:Connect(function()
		ThemeRegistry[instance] = nil
		FontRegistry[instance] = nil
	end)
end

local function Themed(instance, map)
	local entry = ThemeRegistry[instance]
	if not entry then
		entry = {}
		if FontRegistry[instance] == nil then
			Watch(instance)
		end
		ThemeRegistry[instance] = entry
	end
	for property, token in pairs(map) do
		entry[property] = token
		local value = Resolve(token)
		if value ~= nil then
			instance[property] = value
		end
	end
	return instance
end

-- Re-resolves an instance's tokens (used after its state changes, e.g. hover).
-- Only what changed is animated: a theme change restyles thousands of objects,
-- and a tween for each would stall a frame. While a restyle tween is still on
-- its way, every goal counts (a hover that ends as it starts must go back).
local RestyleTweens = setmetatable({}, { __mode = "k" })
-- (Roblox keeps numbers like transparency as 32-bit floats: 0.94 reads back
-- as 0.9399999...)
local function Same(current, value)
	if type(current) == "number" and type(value) == "number" then
		return math.abs(current - value) < 1e-4
	end
	return current == value
end
local function Restyle(instance, duration)
	local entry = ThemeRegistry[instance]
	if not entry then
		return
	end
	local running = RestyleTweens[instance]
	if running and running.PlaybackState ~= Enum.PlaybackState.Playing then
		running = nil
		RestyleTweens[instance] = nil
	end
	local goals, any = {}, false
	for property, token in pairs(entry) do
		local value = Resolve(token)
		if value ~= nil and (running or not Same(instance[property], value)) then
			goals[property] = value
			any = true
		end
	end
	if not any then
		return
	end
	if duration == 0 then
		if running then
			running:Cancel()
			RestyleTweens[instance] = nil
		end
		for property, value in pairs(goals) do
			instance[property] = value
		end
	else
		RestyleTweens[instance] = Tween(instance, goals, duration or 0.18)
	end
end

local function RefreshTheme(duration)
	for instance in pairs(ThemeRegistry) do
		if instance.Parent == nil then
			ThemeRegistry[instance] = nil
		else
			Restyle(instance, duration)
		end
	end
end

local Defaults = {
	Frame = { BorderSizePixel = 0 },
	CanvasGroup = { BorderSizePixel = 0 },
		Frame = { BorderSizePixel = 0 },
	ScrollingFrame = { BorderSizePixel = 0, BackgroundTransparency = 1, ScrollBarThickness = 0 },
	TextLabel = {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	},
	TextButton = { BorderSizePixel = 0, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", TextSize = 14 },
	TextBox = {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	},
	ImageLabel = { BorderSizePixel = 0, BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit },
	ImageButton = { BorderSizePixel = 0, BackgroundTransparency = 1, AutoButtonColor = false },
}

local TextClasses = { TextLabel = true, TextButton = true, TextBox = true }

local function New(className, props)
	local instance = Instance.new(className)
	local defaults = Defaults[className]
	if defaults then
		for property, value in pairs(defaults) do
			instance[property] = value
		end
	end
	if TextClasses[className] then
		local weight = props and props.Weight or Enum.FontWeight.Regular
		instance.FontFace = GetFont(weight)
		FontRegistry[instance] = weight
		Watch(instance)
	end
	local parent, theme, children
	if props then
		for property, value in pairs(props) do
			if property == "Parent" then
				parent = value
			elseif property == "Theme" then
				theme = value
			elseif property == "Children" then
				children = value
			elseif property ~= "Weight" then
				instance[property] = value
			end
		end
	end
	if theme then
		Themed(instance, theme)
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

local function Corner(parent, radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function Stroke(parent, token, thickness, transparency)
	return New("UIStroke", {
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Theme = { Color = token },
		Parent = parent,
	})
end

local function Padding(parent, top, right, bottom, left)
	return New("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		Parent = parent,
	})
end

local function List(parent, direction, padding, props)
	local layout = New("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padding or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
	for property, value in pairs(props or {}) do
		layout[property] = value
	end
	return layout
end

-- SHADOW_IMAGE's 49px border is clear on the outside, fades in around the
-- middle and is solid inside. The object's edge sits in the middle of that
-- fade (as in Roblox's own examples) so only the soft half shows; the solid
-- part stays hidden behind the object. `spread` is how far the soft edge
-- reaches, in pixels. Keep it under about a tenth of the object's smallest
-- side so the slices fit.
local SHADOW_FADE = 0.11 -- visible fade, as a share of the border
local SHADOW_EDGE = 0.48 -- the object's edge, measured in from the outside

local function Shadow(parent, spread, transparencyToken)
	local shadow = New("ImageLabel", {
		Name = "Shadow",
		Image = SHADOW_IMAGE,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 0,
		Theme = { ImageColor3 = "Shadow", ImageTransparency = transparencyToken or "ShadowTransparency" },
		Parent = parent,
	})
	-- The image's corners have to fit inside it. On a small object (a one-item
	-- menu, an empty Spotlight) full-size corners would be squeezed together
	-- into a hard dark band, so the shadow shrinks with the object.
	local function Fit()
		local size = parent.Size
		local border = spread / SHADOW_FADE
		if size.X.Scale == 0 and size.Y.Scale == 0 then
			local smallest = math.min(size.X.Offset, size.Y.Offset)
			border = math.clamp(smallest / (2 * (1 - SHADOW_EDGE)), 1, border)
		end
		local reach = border * SHADOW_EDGE
		shadow.SliceScale = border / 49
		shadow.Size = UDim2.new(1, reach * 2, 1, reach * 2)
		shadow.Position = UDim2.new(0.5, 0, 0.5, math.floor(border * SHADOW_FADE * 0.3 + 0.5))
	end
	Fit()
	parent:GetPropertyChangedSignal("Size"):Connect(Fit)
	return shadow
end

local function IconImage(props)
	local icon = props.Icon
	props.Icon = nil
	local size = props.IconSize or 16
	props.IconSize = nil
	props.Image = MacUI:GetIcon(icon) or ""
	props.Size = props.Size or UDim2.fromOffset(size, size)
	return New("ImageLabel", props)
end

local function Lighten(color, amount)
	return color:Lerp(Color3.new(1, 1, 1), amount)
end

local function Darken(color, amount)
	return color:Lerp(Color3.new(0, 0, 0), amount)
end

local function TileGradient(color)
	return ColorSequence.new(Lighten(color, 0.14), Darken(color, 0.08))
end

-- A rounded, gradient-filled square with a white glyph: the System Settings icon.
local function IconTile(parent, icon, color, size, radius, glyphSize, props)
	local tile = New("Frame", {
		Name = "Tile",
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = parent,
	})
	for property, value in pairs(props or {}) do
		tile[property] = value
	end
	Corner(tile, radius)
	local gradient = New("UIGradient", { Rotation = 90, Parent = tile })
	local glyph = IconImage({
		Name = "Glyph",
		Icon = icon,
		IconSize = glyphSize,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageColor3 = Color3.new(1, 1, 1),
		ZIndex = 2,
		Parent = tile,
	})
	local function Paint()
		local value = type(color) == "function" and color() or color
		gradient.Color = TileGradient(value)
	end
	Paint()
	if type(color) == "function" then
		local connection = MacUI.AccentChanged:Connect(Paint)
		tile.Destroying:Connect(connection.Disconnect)
	end
	return tile, glyph, gradient
end

local function ResolveColor(value)
	if typeof(value) == "Color3" then
		return value
	elseif type(value) == "string" then
		if MacUI.Accents[value] then
			return MacUI.Accents[value]
		end
		local ok, color = pcall(Color3.fromHex, value)
		if ok then
			return color
		end
	end
	return nil
end

local function ParseArgs(idx, info)
	if type(idx) == "table" and info == nil then
		info = idx
		idx = info.Flag or info.Idx or info.Id
	end
	return idx, info or {}
end

local function KeyName(value)
	local names = {
		LeftControl = "L-Ctrl",
		RightControl = "R-Ctrl",
		LeftShift = "L-Shift",
		RightShift = "R-Shift",
		LeftAlt = "L-Alt",
		RightAlt = "R-Alt",
		LeftSuper = "L-Cmd",
		RightSuper = "R-Cmd",
		Return = "Enter",
		MB1 = "Mouse 1",
		MB2 = "Mouse 2",
		MB3 = "Mouse 3",
	}
	return names[value] or tostring(value)
end

--------------------------------------------------------------------------------
-- Library-level settings
--------------------------------------------------------------------------------

function MacUI:SetTheme(name, instant)
	local theme = self.Themes[name]
	if not theme then
		warn("[MacUI] unknown theme: " .. tostring(name))
		return
	end
	self.ThemeName = name
	self.ThemeData = theme
	RefreshTheme(instant and 0 or 0.3)
	self.ThemeChanged:Fire(name)
end

function MacUI:SetAccent(value, instant)
	local color = ResolveColor(value)
	if not color then
		warn("[MacUI] invalid accent: " .. tostring(value))
		return
	end
	self.Accent = color
	RefreshTheme(instant and 0 or 0.3)
	self.AccentChanged:Fire(color)
end

function MacUI:SetFont(family)
	if typeof(family) == "EnumItem" then
		family = Font.fromEnum(family).Family
	elseif type(family) == "string" and not family:find("://") then
		family = "rbxasset://fonts/families/" .. family .. ".json"
	end
	self.FontFamily = family
	for instance, weight in pairs(FontRegistry) do
		if instance.Parent == nil then
			FontRegistry[instance] = nil
		else
			instance.FontFace = GetFont(weight)
		end
	end
end

-- Registers a theme that inherits every token it doesn't define from `base` (Dark).
-- Theme colours can be Color3s or hex strings ("#1e1e20").
local function ThemeValue(token, value)
	if type(value) ~= "string" then
		return value
	end
	local ok, color = pcall(Color3.fromHex, (value:gsub("^#", "")))
	if ok then
		return color
	end
	warn(("[MacUI] theme colour %s: %q isn't a hex colour"):format(tostring(token), value))
	return nil
end

function MacUI:AddTheme(name, tokens, base)
	local theme = table.clone(self.Themes[base or "Dark"] or self.Themes.Dark)
	for token, value in pairs(tokens or {}) do
		value = ThemeValue(token, value)
		if value ~= nil then
			theme[token] = value
		end
	end
	self.Themes[name] = theme
	if self.ThemeName == name then
		-- redefining the theme in use: show the new colours straight away
		self.ThemeData = theme
		RefreshTheme(0.2)
	end
	self.ThemesChanged:Fire(self:GetThemes())
	return theme
end

local BUILT_IN_THEMES = { Dark = true, Light = true, Midnight = true }

-- Removes a theme added with AddTheme (the built-in ones stay).
function MacUI:RemoveTheme(name)
	if BUILT_IN_THEMES[name] or not self.Themes[name] then
		return false
	end
	self.Themes[name] = nil
	if self.ThemeName == name then
		self:SetTheme("Dark")
	end
	self.ThemesChanged:Fire(self:GetThemes())
	return true
end

-- Shows `tokens` on top of a theme without registering it (theme editors);
-- SetTheme(MacUI.ThemeName) goes back.
function MacUI:PreviewTheme(tokens, base)
	local theme = table.clone(self.Themes[base or self.ThemeName] or self.Themes.Dark)
	for token, value in pairs(tokens or {}) do
		value = ThemeValue(token, value)
		if value ~= nil then
			theme[token] = value
		end
	end
	self.ThemeData = theme
	RefreshTheme(0.15)
end

function MacUI:SetReduceMotion(enabled)
	if Guard.Engaged and Guard.Saved then
		-- effects are paused; this becomes the setting once they're restored
		Guard.Saved.ReduceMotion = enabled == true
		return
	end
	self.ReduceMotion = enabled == true
end

-- The reduce-motion setting as the user chose it, even while the performance
-- guard has effects paused.
function MacUI:GetReduceMotion()
	if Guard.Engaged and Guard.Saved then
		return Guard.Saved.ReduceMotion == true
	end
	return self.ReduceMotion == true
end

-- Copies text with the executor's clipboard function. Returns false if there is none.
function MacUI:SetClipboard(text)
	return CopyToClipboard(tostring(text or ""))
end

function MacUI:SetScale(scale)
	for _, window in ipairs(self.Windows) do
		window:SetScale(scale)
	end
end

function MacUI:SetMinimizeKey(key)
	for _, window in ipairs(self.Windows) do
		window:SetMinimizeKey(key)
	end
end

function MacUI:GetThemes()
	local names = {}
	for name in pairs(self.Themes) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

-- Elements whose callback failed: { Element, Message, Count }.
function MacUI:GetErrors()
	local list = {}
	for _, window in ipairs(self.Windows) do
		for _, tab in ipairs(window.Tabs or {}) do
			for _, row in ipairs(tab.Rows) do
				if row.ErrorMessage then
					table.insert(list, { Element = row.Element, Message = row.ErrorMessage, Count = row.ErrorCount })
				end
			end
		end
	end
	return list
end

function MacUI:SafeCallback(fn, ...)
	SafeCall(fn, ...)
end

function MacUI:Round(value, decimals)
	return Round(value, decimals)
end

local UnloadCallbacks = {}
function MacUI:OnUnload(fn)
	table.insert(UnloadCallbacks, fn)
end

--------------------------------------------------------------------------------
-- Notifications (macOS Notification Center banners)
--------------------------------------------------------------------------------

local NotificationGui
local Banners = {}

local function NotificationScale()
	return math.clamp(Viewport().X / 1150, TouchOnly() and 0.85 or 0.72, 1)
end

local function LayoutBanners()
	local y = 12
	for _, banner in ipairs(Banners) do
		if not banner.Closing then
			Tween(banner.Holder, { Position = UDim2.new(1, -14, 0, y) }, 0.45, Enum.EasingStyle.Quint)
			y = y + ((banner.Height * banner.Scale) + 10)
		end
	end
end

function MacUI:Notify(config)
	config = config or {}
	if self.Unloaded then
		return
	end
	if not NotificationGui or not NotificationGui.Parent then
		NotificationGui = New("ScreenGui", {
			Name = "MacUI_Notifications",
			ResetOnSpawn = false,
			DisplayOrder = 1000,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		ParentGui(NotificationGui)
	end

	local scale = NotificationScale()
	local width = 344
	local banner = { Scale = scale, Height = 72, Closing = false }

	local holder = New("Frame", {
		Name = "Banner",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, width * scale + 40, 0, 12),
		Size = UDim2.fromOffset(width, banner.Height),
		Parent = NotificationGui,
	})
	InterfaceRoots[holder] = true
	New("UIScale", { Scale = scale, Parent = holder })
	-- no drop shadow: over the game it reads as a dark smudge; the hairline
	-- border sets the banner apart
	local card = New("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		GroupTransparency = 1,
		ZIndex = 2,
		Theme = { BackgroundColor3 = "Menu" },
		Parent = holder,
	})
	Corner(card, 16)
	local border = New("Frame", {
		Name = "Border",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		ZIndex = 5,
		Parent = card,
	})
	Corner(border, 15)
	Stroke(border, "HudStroke", 1, 0)

	local content = New("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	Padding(content, 12, 14, 13, 12)

	local tileColor = ResolveColor(config.IconColor)
	IconTile(content, config.Icon or "bell", tileColor or function()
		return MacUI.Accent
	end, 36, 9, 20, { Position = UDim2.fromOffset(0, 1) })

	local column = New("Frame", {
		Name = "Text",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(48, 0),
		Size = UDim2.new(1, -48, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = content,
	})
	List(column, nil, 1)
	local header = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 1,
		Parent = column,
	})
	New("TextLabel", {
		Name = "Title",
		Text = tostring(config.Title or "Notification"),
		TextSize = 14,
		Weight = Enum.FontWeight.Bold,
		Size = UDim2.new(1, -40, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "Text" },
		Parent = header,
	})
	New("TextLabel", {
		Name = "Time",
		Text = config.Time or "now",
		TextSize = 12,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 40, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Theme = { TextColor3 = "SubText" },
		Parent = header,
	})
	if config.SubContent and config.SubContent ~= "" then
		New("TextLabel", {
			Name = "Subtitle",
			Text = tostring(config.SubContent),
			TextSize = 13,
			Weight = Enum.FontWeight.Medium,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			LayoutOrder = 2,
			Theme = { TextColor3 = "Text" },
			Parent = column,
		})
	end
	if config.Content and config.Content ~= "" then
		New("TextLabel", {
			Name = "Body",
			Text = tostring(config.Content),
			TextSize = 13,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			RichText = true,
			LayoutOrder = 3,
			Theme = {
				TextColor3 = function(t)
					return t.Text:Lerp(t.SubText, 0.35)
				end
			},
			Parent = column,
		})
	end
	if type(config.Buttons) == "table" and #config.Buttons > 0 then
		local actions = New("Frame", {
			Name = "Actions",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 4,
			Parent = column,
		})
		Padding(actions, 7, 0, 0, 0)
		List(actions, Enum.FillDirection.Horizontal, 6)
		for index, spec in ipairs(config.Buttons) do
			local push = PushButton(actions, spec.Title or "OK", spec.Style or (index == 1 and "Primary" or "Default"),
				24)
			push.Instance.LayoutOrder = index
			push.Instance.MouseButton1Click:Connect(function()
				if banner.Closing then
					return
				end
				banner:Close()
				Spawn(spec.Callback)
			end)
		end
	end

	-- Sits below the card: clicks on text fall through to it, while the
	-- action buttons inside the card still receive their own clicks.
	local hitbox = New("TextButton", {
		Name = "Hitbox",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		Parent = holder,
	})
	local close = New("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		ZIndex = 6,
		Theme = { BackgroundColor3 = "Menu" },
		Parent = holder,
	})
	Corner(close, 10)
	local closeStroke = Stroke(close, "MenuStroke", 1, 1)
	local closeGlyph = IconImage({
		Icon = "x",
		IconSize = 11,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageTransparency = 1,
		Theme = { ImageColor3 = "SubText" },
		ZIndex = 7,
		Parent = close,
	})

	card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local height = math.max(card.AbsoluteSize.Y / scale, 40)
		if math.abs(height - banner.Height) > 0.5 then
			banner.Height = height
			holder.Size = UDim2.fromOffset(width, height)
			LayoutBanners()
		end
	end)

	banner.Holder = holder
	function banner:Close()
		if banner.Closing then
			return
		end
		banner.Closing = true
		banner.Shown = false
		local index = table.find(Banners, banner)
		if index then
			table.remove(Banners, index)
		end
		LayoutBanners()
		Tween(holder, { Position = holder.Position + UDim2.fromOffset(width * scale + 40, 0) }, 0.4,
			Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		Tween(card, { GroupTransparency = 1 }, 0.35)
		task.delay(0.42, function()
			holder:Destroy()
		end)
	end

	hitbox.MouseEnter:Connect(function()
		Tween(close, { BackgroundTransparency = 0 }, 0.15)
		Tween(closeStroke, { Transparency = 0.2 }, 0.15)
		Tween(closeGlyph, { ImageTransparency = 0 }, 0.15)
	end)
	hitbox.MouseLeave:Connect(function()
		Tween(close, { BackgroundTransparency = 1 }, 0.15)
		Tween(closeStroke, { Transparency = 1 }, 0.15)
		Tween(closeGlyph, { ImageTransparency = 1 }, 0.15)
	end)
	close.MouseButton1Click:Connect(function()
		banner:Close()
	end)
	hitbox.MouseButton1Click:Connect(function()
		Spawn(config.Callback)
		banner:Close()
	end)

	table.insert(Banners, 1, banner)
	-- no more than fit on the screen, five at most: the oldest make way
	local function StackHeight()
		local height = 12
		for _, other in ipairs(Banners) do
			height = height + (other.Height * other.Scale + 10)
		end
		return height
	end
	while #Banners > 1 and (#Banners > 5 or StackHeight() > Viewport().Y - 24) do
		Banners[#Banners]:Close()
	end
	holder.Position = UDim2.new(1, width * scale + 40, 0, 12)
	LayoutBanners()
	banner.Shown = true
	Tween(card, { GroupTransparency = 0 }, 0.3)

	local duration = config.Duration
	if duration == nil then
		duration = 5
	end
	if duration and duration > 0 then
		task.delay(duration, function()
			banner:Close()
		end)
	end
	return banner
end

--------------------------------------------------------------------------------
-- Rows: every element lives in a row inside a rounded group box.
--------------------------------------------------------------------------------

local RowMethods = {}
RowMethods.__index = RowMethods

--------------------------------------------------------------------------------
-- Watermark: a floating status pill ("My Hub | 60 fps | 42 ms | 12:30")
--------------------------------------------------------------------------------

local WatermarkGui
local WATERMARK_ANCHORS = {
	TopLeft = { Vector2.new(0, 0), UDim2.new(0, 14, 0, 12) },
	TopCenter = { Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 12) },
	TopRight = { Vector2.new(1, 0), UDim2.new(1, -14, 0, 12) },
	BottomLeft = { Vector2.new(0, 1), UDim2.new(0, 14, 1, -14) },
	BottomCenter = { Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -14) },
	BottomRight = { Vector2.new(1, 1), UDim2.new(1, -14, 1, -14) },
}

local function ReadPing()
	local ok, ping = pcall(function()
		return GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(ping) == "number" then
		return ping
	end
	ok, ping = pcall(function()
		return LocalPlayer:GetNetworkPing() * 2000
	end)
	return ok and type(ping) == "number" and ping or nil
end

--[[
	MacUI:SetWatermark({
		Text = "My Hub",          -- or a function returning the text
		Icon = "command",
		Position = "TopCenter",   -- TopLeft/TopCenter/TopRight/BottomLeft/BottomCenter/BottomRight
		Fps = true, Ping = true, Clock = false,
	})
	MacUI:SetWatermark(false)     -- remove it
]]
function MacUI:SetWatermark(options)
	if WatermarkGui then
		WatermarkGui:Destroy()
		WatermarkGui = nil
	end
	self.Watermark = nil
	if not options or self.Unloaded then
		return nil
	end
	if options == true then
		options = {}
	elseif type(options) ~= "table" then
		options = { Text = options }
	end
	-- Under the windows: on a small screen it can't cover a window's toolbar
	-- or take its taps, and it's back in view when the window is hidden.
	local order = 99
	for _, window in ipairs(self.Windows) do
		if window.ScreenGui then
			order = math.min(order, window.ScreenGui.DisplayOrder - 1)
		end
	end
	local gui = New("ScreenGui", {
		Name = "MacUI_Watermark",
		ResetOnSpawn = false,
		DisplayOrder = order,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	ParentGui(gui)
	WatermarkGui = gui
	local anchor = WATERMARK_ANCHORS[options.Position or "TopCenter"] or WATERMARK_ANCHORS.TopCenter
	local holder = New("Frame", {
		Name = "Watermark",
		BackgroundTransparency = 1,
		AnchorPoint = anchor[1],
		Position = anchor[2],
		Size = UDim2.fromOffset(120, 28),
		Parent = gui,
	})
	InterfaceRoots[holder] = true
	New("UIScale", { Scale = NotificationScale(), Parent = holder })
	-- no drop shadow: around a pill it reads as a dark smudge over the game
	local body = New("Frame", {
		Name = "Body",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.04,
		Active = true,
		ZIndex = 2,
		Theme = { BackgroundColor3 = "Menu" },
		Parent = holder,
	})
	Corner(body, 14)
	Stroke(body, "HudStroke", 1, 0)
	IconTile(body, options.Icon or "command", ResolveColor(options.IconColor) or function()
		return MacUI.Accent
	end, 18, 5, 12, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
	})

	-- Segments get fixed widths (measured from a template) so the pill doesn't
	-- twitch as numbers change.
	local segments = {}
	local function Segment(template, token, weight)
		local label = New("TextLabel", {
			Text = template,
			TextSize = 12,
			Weight = weight or Enum.FontWeight.Medium,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromOffset(math.ceil(MeasureText(template, 12, weight or Enum.FontWeight.Medium)) + 2, 28),
			ZIndex = 3,
			Theme = { TextColor3 = token },
			Parent = body,
		})
		table.insert(segments, label)
		return label
	end
	local function TitleText()
		local text = options.Text
		if type(text) == "function" then
			local ok, value = pcall(text)
			text = ok and value or ""
		end
		if text == nil then
			-- (SetWatermark(true): the window's title)
			local window = MacUI.Windows[1]
			text = window and window.Title or "MacUI"
		end
		return tostring(text)
	end
	local title = Segment(type(options.Text) == "function" and "" or TitleText(), "Text", Enum.FontWeight.Bold)
	local fps = options.Fps ~= false and Segment("144 fps", "SubText") or nil
	local ping = options.Ping ~= false and Segment("999 ms", "SubText") or nil
	local clock = options.Clock and Segment("00:00", "SubText") or nil
	local dividers = {}
	for _ = 2, #segments do
		table.insert(dividers, New("Frame", {
			Size = UDim2.fromOffset(1, 12),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 3,
			Theme = { BackgroundColor3 = "Separator" },
			Parent = body,
		}))
	end
	local function Layout()
		title.Size = UDim2.fromOffset(math.ceil(MeasureText(title.Text, 12, Enum.FontWeight.Bold)) + 2, 28)
		-- a number longer than its template (1000+ fps) widens its slot; slots
		-- never shrink, so the pill doesn't twitch
		for index = 2, #segments do
			local label = segments[index]
			local needed = math.ceil(MeasureText(label.Text, 12, Enum.FontWeight.Medium)) + 2
			if needed > label.Size.X.Offset then
				label.Size = UDim2.fromOffset(needed, 28)
			end
		end
		local x = 32
		for index, label in ipairs(segments) do
			if index > 1 then
				dividers[index - 1].Position = UDim2.fromOffset(x + 8, 14)
				x = x + (17)
			end
			label.Position = UDim2.fromOffset(x, 0)
			x = x + (label.Size.X.Offset)
		end
		holder.Size = UDim2.fromOffset(x + 12, 28)
	end

	-- dragging
	local drag
	body.InputBegan:Connect(function(input)
		if IsPointer(input) then
			drag = { Start = input.Position, Origin = holder.Position, Input = input }
		end
	end)
	local connections = {
		UserInputService.InputChanged:Connect(function(input)
			if drag and DragMoves(drag.Input, input) then
				local delta = input.Position - drag.Start
				holder.Position = drag.Origin + UDim2.fromOffset(delta.X, delta.Y)
			end
		end),
		UserInputService.InputEnded:Connect(function(input)
			if drag and DragEnds(drag.Input, input) then
				drag = nil
			end
		end),
	}
	-- A Text function runs on its own thread, one call at a time: one that
	-- waits (a web request, say) can't pile up calls or hold the counters.
	local fetching = false
	local function RefreshTitle()
		if type(options.Text) ~= "function" then
			title.Text = TitleText()
			return
		end
		if fetching then
			return
		end
		fetching = true
		task.spawn(function()
			local text = TitleText()
			fetching = false
			if gui.Parent then
				title.Text = text
				Layout()
			end
		end)
	end
	local frames, elapsed = 0, 0
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		frames = frames + (1)
		elapsed = elapsed + (dt)
		if elapsed < 0.5 then
			return
		end
		RefreshTitle()
		if fps then
			fps.Text = math.floor(frames / elapsed + 0.5) .. " fps"
		end
		if ping then
			local value = ReadPing()
			ping.Text = value and (math.floor(value + 0.5) .. " ms") or "— ms"
		end
		if clock then
			clock.Text = os.date("%H:%M")
		end
		frames, elapsed = 0, 0
		Layout()
	end))
	gui.Destroying:Connect(function()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
	end)
	if fps then
		fps.Text = "— fps"
	end
	if ping then
		ping.Text = "— ms"
	end
	if clock then
		clock.Text = os.date("%H:%M")
	end
	RefreshTitle()
	Layout()

	local watermark = { Instance = holder }
	function watermark:SetText(text)
		options.Text = text
		RefreshTitle()
		Layout()
	end

	function watermark:SetVisible(visible)
		holder.Visible = visible ~= false
	end

	function watermark:Destroy()
		if WatermarkGui == gui then
			WatermarkGui = nil
		end
		if MacUI.Watermark == watermark then
			MacUI.Watermark = nil
		end
		gui:Destroy()
	end

	self.Watermark = watermark
	return watermark
end

--------------------------------------------------------------------------------
-- Loading screen: a startup card with the hub's icon and a progress bar
--------------------------------------------------------------------------------

--[[
	local loader = MacUI:ShowLoading({ Title = "My Hub", Subtitle = "Loading…", Icon = "command" })
	loader:SetProgress(0.5, "Fetching data…")  -- 0 to 1; until then the bar sweeps
	loader:Finish()                             -- fills the bar and fades out
]]
local ActiveLoaders = {}

function MacUI:ShowLoading(options)
	options = options or {}
	if self.Unloaded then
		local function Nothing() end
		return { Shown = false, Closed = true, SetProgress = Nothing, SetStatus = Nothing, Finish = Nothing, Close =
		Nothing }
	end
	local gui = New("ScreenGui", {
		Name = "MacUI_Loading",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1001,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	ParentGui(gui)
	local dim = New("Frame", {
		Name = "Dim",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	local holder = New("Frame", {
		Name = "Card",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 200),
		ZIndex = 2,
		Parent = gui,
	})
	local cardScale = New("UIScale", { Scale = NotificationScale() * 0.94, Parent = holder })
	local loader = { Shown = true, Progress = nil, Closed = false }
	ActiveLoaders[loader] = true
	local shadow = Shadow(holder, 14, function(t)
		return loader.Shown and t.ShadowTransparency or 1
	end)
	shadow.ImageTransparency = 1
	local card = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		GroupTransparency = 1,
		ZIndex = 2,
		Theme = { BackgroundColor3 = "Menu" },
		Parent = holder,
	})
	Corner(card, 18)
	local border = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		ZIndex = 5,
		Parent = card,
	})
	Corner(border, 17)
	Stroke(border, "MenuStroke", 1, 0.1)
	IconTile(card, options.Icon or "command", ResolveColor(options.IconColor) or function()
		return MacUI.Accent
	end, 64, 15, 34, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 28),
	})
	New("TextLabel", {
		Name = "Title",
		Text = tostring(options.Title or "Loading"),
		TextSize = 18,
		Weight = Enum.FontWeight.Bold,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(16, 104),
		Size = UDim2.new(1, -32, 0, 22),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "Text" },
		Parent = card,
	})
	local status = New("TextLabel", {
		Name = "Status",
		Text = tostring(options.Subtitle or "Loading…"),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(16, 128),
		Size = UDim2.new(1, -32, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "SubText" },
		Parent = card,
	})
	local track = New("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 166),
		Size = UDim2.fromOffset(200, 6),
		ClipsDescendants = true,
		Theme = { BackgroundColor3 = "Track" },
		Parent = card,
	})
	Corner(track, 3)
	local fill = New("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0.3, 1),
		Theme = { BackgroundColor3 = "Accent" },
		Parent = track,
	})
	Corner(fill, 3)

	-- indeterminate: the fill sweeps across until the first SetProgress
	local sweep
	task.spawn(function()
		while not loader.Closed and loader.Progress == nil do
			fill.Position = UDim2.fromScale(-0.3, 0)
			sweep = Tween(fill, { Position = UDim2.fromScale(1, 0) }, 1.1, Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut)
			task.wait(1.2)
		end
	end)

	function loader:SetProgress(alpha, text)
		if self.Closed then
			return
		end
		if sweep then
			sweep:Cancel()
			sweep = nil
		end
		self.Progress = math.clamp(tonumber(alpha) or 0, 0, 1)
		fill.Position = UDim2.fromScale(0, 0)
		Tween(fill, { Size = UDim2.fromScale(self.Progress, 1) }, 0.25)
		if text then
			status.Text = tostring(text)
		end
	end

	function loader:SetStatus(text)
		status.Text = tostring(text or "")
	end

	function loader:Close()
		if self.Closed then
			return
		end
		self.Closed = true
		self.Shown = false
		ActiveLoaders[self] = nil
		Tween(card, { GroupTransparency = 1 }, 0.25)
		Tween(cardScale, { Scale = NotificationScale() * 1.04 }, 0.25)
		Tween(dim, { BackgroundTransparency = 1 }, 0.3)
		Restyle(shadow, 0.2)
		task.delay(0.32, function()
			gui:Destroy()
		end)
	end

	function loader:Finish(text)
		if self.Closed then
			return
		end
		self:SetProgress(1, text)
		task.delay(0.35, function()
			self:Close()
		end)
	end

	Tween(dim, { BackgroundTransparency = options.Dim == false and 1 or 0.55 }, 0.3)
	Tween(card, { GroupTransparency = 0 }, 0.25)
	Tween(cardScale, { Scale = NotificationScale() }, 0.35, Enum.EasingStyle.Back)
	Restyle(shadow, 0.25)
	return loader
end

--------------------------------------------------------------------------------
-- Dependencies: DependsOn = "Flag" | { "Flag", value } | function() -> bool
--------------------------------------------------------------------------------

local Dependencies = {}
local dependencyCheckQueued = false

local function EvaluateDependency(dependency)
	if dependency.Row.Destroyed then
		return
	end
	local ok, result = pcall(dependency.Check)
	local active = ok and result and true or false
	if active == dependency.Active then
		return
	end
	dependency.Active = active
	local row = dependency.Row
	if dependency.Mode == "Hide" then
		row.DependencyHidden = not active
		row:_ApplyVisibility()
	else
		row.DependencyDisabled = not active
		row:_ApplyDisabled()
	end
end

local function CheckDependencies()
	if dependencyCheckQueued then
		return
	end
	dependencyCheckQueued = true
	task.defer(function()
		dependencyCheckQueued = false
		for _, dependency in ipairs(Dependencies) do
			EvaluateDependency(dependency)
		end
	end)
end

local function ResolveCondition(spec)
	if type(spec) == "function" then
		return spec
	end
	local flag, expected = spec, nil
	if type(spec) == "table" then
		flag = spec.Flag or spec[1]
		expected = spec.Value
		if expected == nil then
			expected = spec[2]
		end
	end
	return function()
		local option = MacUI.Options[flag]
		if not option then
			return false
		end
		local value = option.Value
		if expected == nil then
			return IsTruthy(value)
		elseif type(value) == "table" then
			return value[expected] == true
		end
		return value == expected
	end
end

local function AddDependency(row, spec, mode)
	table.insert(Dependencies, { Row = row, Check = ResolveCondition(spec), Mode = mode or "Disable" })
	CheckDependencies()
end

MacUI.OptionChanged:Connect(CheckDependencies)

--------------------------------------------------------------------------------
-- Timers: "turn this off in 30 minutes", "press this every 5 seconds"
--------------------------------------------------------------------------------

local DURATION_UNITS = {
	s = 1,
	sec = 1,
	secs = 1,
	second = 1,
	seconds = 1,
	m = 60,
	min = 60,
	mins = 60,
	minute = 60,
	minutes = 60,
	h = 3600,
	hr = 3600,
	hrs = 3600,
	hour = 3600,
	hours = 3600,
}

-- "45s", "20m", "1h 30m", "1 hour and 5 minutes", "1:30" (m:ss), "1:02:03",
-- or a bare number in `defaultUnit` ("m" unless given). Returns seconds or nil.
local function ParseDuration(text, defaultUnit)
	text = tostring(text or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then
		return nil
	end
	local h, m, s = text:match("^(%d+):(%d%d):(%d%d)$")
	if h then
		local total = tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)
		return total > 0 and total or nil
	end
	m, s = text:match("^(%d+):(%d%d)$")
	if m then
		local total = tonumber(m) * 60 + tonumber(s)
		return total > 0 and total or nil
	end
	local total, matched = 0, false
	for number, unit in text:gmatch("(%d*%.?%d+)%s*(%a*)") do
		local multiplier = DURATION_UNITS[unit ~= "" and unit or (defaultUnit or "m")]
		if not multiplier or not tonumber(number) then
			return nil
		end
		total = total + (tonumber(number) * multiplier)
		matched = true
	end
	-- anything left over besides "and" and commas means it wasn't a duration
	local rest = text:gsub("(%d*%.?%d+)%s*(%a*)", ""):gsub("and", ""):gsub("[%s,]", "")
	if not matched or rest ~= "" or total <= 0 then
		return nil
	end
	return total
end

-- 75 -> "1:15", 3725 -> "1:02:05"
local function FormatClock(seconds)
	seconds = math.max(math.ceil(seconds), 0)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)
	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, seconds % 60)
	end
	return string.format("%d:%02d", minutes, seconds % 60)
end

-- 90 -> "1 min 30 s"; with `long`, "1 Minute 30 Seconds" (menus)
local function DescribeDuration(seconds, long)
	seconds = math.max(math.floor(seconds + 0.5), 1)
	local parts = {}
	local function Add(amount, short, singular, plural)
		if amount > 0 then
			table.insert(parts, amount .. " " .. (long and (amount == 1 and singular or plural) or short))
		end
	end
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)
	Add(hours, "h", "Hour", "Hours")
	Add(minutes, "min", "Minute", "Minutes")
	if hours == 0 then
		Add(seconds % 60, "s", "Second", "Seconds")
	end
	return table.concat(parts, " ")
end

-- Running timers by row: { Ends, Value (toggles) or Interval (buttons), Icon, Fire }.
local ActiveTimers = {}
local timerLoopRunning = false

local function EnsureTimerLoop()
	if timerLoopRunning then
		return
	end
	timerLoopRunning = true
	task.spawn(function()
		while next(ActiveTimers) ~= nil and not MacUI.Unloaded do
			local now = os.clock()
			for row, timer in pairs(table.clone(ActiveTimers)) do
				if row.Destroyed then
					ActiveTimers[row] = nil
				elseif ActiveTimers[row] == timer and now >= timer.Ends then
					-- (another timer firing this tick may have cancelled it)
					SafeCall(timer.Fire, timer)
				end
				if ActiveTimers[row] == timer then
					row:_RenderTimer()
				end
			end
			task.wait(0.2)
		end
		timerLoopRunning = false
	end)
end

-- Every running timer, soonest first: { Element, Remaining, Value (toggles)
-- or Interval (buttons) }.
function MacUI:GetTimers()
	local list = {}
	local now = os.clock()
	for row, timer in pairs(ActiveTimers) do
		table.insert(list, {
			Element = row.Element,
			Remaining = math.max(timer.Ends - now, 0),
			Value = timer.Value,
			Interval = timer.Interval,
		})
	end
	table.sort(list, function(a, b)
		return a.Remaining < b.Remaining
	end)
	return list
end

function MacUI:CancelTimers()
	for row in pairs(table.clone(ActiveTimers)) do
		row:_CancelTimer()
	end
end

local TOGGLE_TIMER_PRESETS = { 60, 300, 900, 1800, 3600, 7200 }
local BUTTON_REPEAT_PRESETS = { 5, 10, 30, 60, 300, 900 }

local function CreateRow(container, info, options)
	options = options or {}
	local window = container.Window
	local tab = container.Tab
	local group = container:_GetGroup()

	local row = setmetatable({
		Window = window,
		Tab = tab,
		Group = group,
		Title = tostring(info.Title or ""),
		Description = tostring(info.Description or info.Desc or ""),
		Keywords = tostring(info.Keywords or ""),
		UserVisible = true,
		SearchMatch = true,
		Hovered = false,
		Pressed = false,
		Disabled = false,
		Connections = {},
	}, RowMethods)

	group.Order = group.Order + (1)
	row.Frame = New("Frame", {
		Name = "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = group.Order,
		Parent = group.Frame,
	})
	row.Separator = New("Frame", {
		Name = "Separator",
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 1),
		ZIndex = 4,
		Theme = { BackgroundColor3 = "Separator" },
		Parent = row.Frame,
	})

	if options.Clickable then
		row.Highlight = New("Frame", {
			Name = "Highlight",
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -8, 1, -8),
			ZIndex = 1,
			Theme = {
				BackgroundColor3 = "Hover",
				BackgroundTransparency = function(t)
					if row.Pressed then
						return t.HoverTransparency - 0.04
					end
					return row.Hovered and t.HoverTransparency or 1
				end,
			},
			Parent = row.Frame,
		})
		Corner(row.Highlight, 7)
		row.Hitbox = New("TextButton", {
			Name = "Hitbox",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = row.Frame,
		})
		row.Hitbox.MouseEnter:Connect(function()
			row.Hovered = true
			Restyle(row.Highlight, 0.12)
		end)
		row.Hitbox.MouseLeave:Connect(function()
			row.Hovered = false
			row.Pressed = false
			Restyle(row.Highlight, 0.2)
		end)
		row.Hitbox.MouseButton1Down:Connect(function()
			row.Pressed = true
			Restyle(row.Highlight, 0.08)
		end)
		row.Hitbox.MouseButton1Up:Connect(function()
			row.Pressed = false
			Restyle(row.Highlight, 0.2)
		end)
		row.Hitbox.MouseButton1Click:Connect(function()
			if not row.Disabled and row.OnClick and not JustCaptured() then
				row.OnClick()
			end
		end)
	end

	row.Content = New("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 3,
		Parent = row.Frame,
	})
	row.Padding = Padding(row.Content, 13, 12, 13, 12)
	row.Stack = New("Frame", {
		Name = "Text",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = row.Content,
	})
	List(row.Stack, nil, 2)
	row.TitleWeight = options.TitleWeight or Enum.FontWeight.Regular
	row.TitleLabel = New("TextLabel", {
		Name = "Title",
		Text = row.Title,
		TextSize = 14,
		Weight = row.TitleWeight,
		Size = UDim2.new(1, 0, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 1,
		Theme = { TextColor3 = "Text" },
		Parent = row.Stack,
	})
	row.DescLabel = New("TextLabel", {
		Name = "Description",
		Text = row.Description,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		RichText = true,
		LayoutOrder = 2,
		Theme = { TextColor3 = options.DescToken or "SubText" },
		Parent = row.Stack,
	})
	if options.DescSize then
		row.DescLabel.TextSize = options.DescSize
	end

	row.Accessory = New("Frame", {
		Name = "Accessory",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 5,
		Parent = row.Frame,
	})
	List(row.Accessory, Enum.FillDirection.Horizontal, 8, {
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	})

	row.Accessory:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		row:_UpdateReserve()
	end)
	-- (and when the window's width changes)
	local lastWidth = 0
	row.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local width = row.Frame.AbsoluteSize.X
		if width ~= lastWidth then
			lastWidth = width
			row:_UpdateReserve()
		end
	end)

	-- Right-click (or long-press on touch) opens the row's context menu.
	row:Connect(row.Frame.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			row:_OpenContextMenu()
		end
	end)
	row:Connect(row.Frame.TouchLongPress, function(positions, state)
		if state == Enum.UserInputState.Begin then
			row:_OpenContextMenu(positions and positions[1])
		end
	end)
	if row.Hitbox then
		row:_BindContext(row.Hitbox)
	end
	if info.Tooltip then
		window:_AttachTooltip(row.Frame, info.Tooltip)
	end

	table.insert(group.Rows, row)
	table.insert(tab.Rows, row)
	row:_UpdateLayout()
	row:_UpdateReserve()
	group:Refresh()
	if window.SearchQuery ~= "" then
		window:_ApplySearch()
	end
	if info.DependsOn ~= nil then
		AddDependency(row, info.DependsOn, info.DependsMode)
	end
	return row
end

-- Moves the row's control under its title and back.
function RowMethods:_WrapAccessory(wrap)
	if (self.Wrapped == true) == wrap then
		return
	end
	self.Wrapped = wrap
	local accessory = self.Accessory
	if wrap then
		if not self.WrapGap then
			self.WrapGap = New("Frame", {
				Name = "WrapGap",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 4),
				LayoutOrder = 9,
			})
		end
		self.WrapGap.Parent = self.Stack
		accessory.AnchorPoint = Vector2.zero
		accessory.Position = UDim2.new()
		accessory.LayoutOrder = 10
		accessory.Parent = self.Stack
	else
		if self.WrapGap then
			self.WrapGap.Parent = nil
		end
		accessory.AnchorPoint = Vector2.new(1, 0.5)
		accessory.Position = UDim2.new(1, -12, 0.5, 0)
		accessory.Parent = self.Frame
	end
end

function RowMethods:_UpdateReserve()
	local scale = self.Window:GetAbsoluteScale()
	local width = self.Accessory.AbsoluteSize.X / scale
	if self.FullWidthText then
		self.Stack.Size = UDim2.new(1, 0, 0, 0)
		return
	end
	-- A control too wide to sit beside the title (a segmented picker in a
	-- narrow window) moves under it rather than squeezing the title away.
	local room = self.Frame.AbsoluteSize.X / scale - 24
	if self.NoWrap or (self.Title == "" and self.Description == "") then
		-- (with no text there's nothing to make room for, and the text column
		-- is hidden)
		self:_WrapAccessory(false)
	elseif room > 0 and width > 1 then
		if not self.TextWidth then
			local description = (self.Description:gsub("<[^>]->", ""))
			self.TextWidth = math.max(
				math.ceil(MeasureText(self.Title, 14, self.TitleWeight)),
				description ~= "" and math.ceil(MeasureText(description, self.DescLabel.TextSize)) or 0
			)
		end
		-- the title and description need their width, or 40% of the row if
		-- they're longer (they wrap then, in a column that's still readable)
		self:_WrapAccessory(room - width - 14 < math.min(self.TextWidth + 4, room * 0.4))
	end
	if self.Wrapped then
		self.Stack.Size = UDim2.new(1, 0, 0, 0)
	else
		self.Stack.Size = UDim2.new(1, -(width > 1 and width + 14 or 0), 0, 0)
	end
end

function RowMethods:_UpdateLayout()
	local hasTitle = self.Title ~= ""
	local hasDesc = self.Description ~= ""
	self.Content.Size = UDim2.new(1, 0, 0, self.MinHeight or 44)
	self.TitleLabel.Visible = hasTitle
	self.DescLabel.Visible = hasDesc
	self.Stack.Visible = hasTitle or hasDesc or self.ForceStack == true
	local pad = (hasTitle and hasDesc) and 9 or 13
	if self.TallPadding then
		pad = math.max(pad, self.TallPadding)
	end
	self.Padding.PaddingTop = UDim.new(0, pad)
	self.Padding.PaddingBottom = UDim.new(0, pad)
end

function RowMethods:SetTitle(text)
	self.Title = tostring(text or "")
	self.TitleLabel.Text = self.Title
	self.TextWidth = nil
	self:_UpdateLayout()
	self:_UpdateReserve()
end

function RowMethods:SetDesc(text)
	self.Description = tostring(text or "")
	self.DescLabel.Text = self.Description
	self.TextWidth = nil
	self:_UpdateLayout()
	self:_UpdateReserve()
end

function RowMethods:_Matches(query)
	local haystack = (self.Title .. " " .. self.Description .. " " .. self.Keywords .. " " .. (self.SearchExtra or ""))
	:lower()
	return haystack:find(query, 1, true) ~= nil
end

-- Shown unless the script hid it or a DependsOn condition is unmet (search aside).
function RowMethods:_IsShown()
	return self.UserVisible and not self.DependencyHidden
end

function RowMethods:_ApplyVisibility()
	self.Frame.Visible = self:_IsShown() and self.SearchMatch
	self.Group:Refresh()
end

function RowMethods:SetVisible(visible)
	self.UserVisible = visible ~= false
	self:_ApplyVisibility()
end

function RowMethods:SetDisabled(disabled)
	self.UserDisabled = disabled == true
	self:_ApplyDisabled()
end

function RowMethods:_ApplyDisabled()
	self.Disabled = self.UserDisabled == true or self.DependencyDisabled == true
	if self.Disabled and not self.Blocker then
		self.Blocker = New("TextButton", {
			Name = "Disabled",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 20,
			Theme = { BackgroundColor3 = "Group" },
			Parent = self.Frame,
		})
		Tween(self.Blocker, { BackgroundTransparency = 0.45 }, 0.2)
	elseif not self.Disabled and self.Blocker then
		local blocker = self.Blocker
		self.Blocker = nil
		Tween(blocker, { BackgroundTransparency = 1 }, 0.2)
		task.delay(0.2, function()
			blocker:Destroy()
		end)
	end
end

-- Runs fn when the row is destroyed.
function RowMethods:_OnDestroy(fn)
	self.DestroyHooks = self.DestroyHooks or {}
	table.insert(self.DestroyHooks, fn)
end

function RowMethods:Destroy()
	self.Destroyed = true
	for _, fn in ipairs(self.DestroyHooks or {}) do
		pcall(fn)
	end
	if self.Capture then
		self.Capture:Disconnect()
		self.Capture = nil
	end
	self.Timer = nil
	if ActiveTimers[self] then
		ActiveTimers[self] = nil
		MacUI.TimersChanged:Fire()
	end
	for index = #Dependencies, 1, -1 do
		if Dependencies[index].Row == self then
			table.remove(Dependencies, index)
		end
	end
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	local index = table.find(self.Group.Rows, self)
	if index then
		table.remove(self.Group.Rows, index)
	end
	index = table.find(self.Tab.Rows, self)
	if index then
		table.remove(self.Tab.Rows, index)
	end
	self.Frame:Destroy()
	self.Group:Refresh()
end

-- A connection that is cleaned up with the row.
function RowMethods:Connect(signal, fn)
	local connection = signal:Connect(fn)
	if MacUI.Unloaded then
		connection:Disconnect() -- this copy was replaced while it was building
	else
		table.insert(self.Connections, connection)
	end
	return connection
end

-- Briefly pulses the row in the accent colour (used by search and Spotlight).
function RowMethods:Flash()
	local flash = self.FlashFrame
	if not flash then
		flash = New("Frame", {
			Name = "Flash",
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -8, 1, -8),
			BackgroundTransparency = 1,
			ZIndex = 1,
			Theme = { BackgroundColor3 = "Accent" },
			Parent = self.Frame,
		})
		Corner(flash, 7)
		self.FlashFrame = flash
	end
	task.spawn(function()
		for _ = 1, 2 do
			Tween(flash, { BackgroundTransparency = 0.7 }, 0.18, Enum.EasingStyle.Sine)
			task.wait(0.22)
			Tween(flash, { BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Sine)
			task.wait(0.32)
		end
	end)
end

function RowMethods:_BindContext(button)
	-- plain connections: `button` is inside the row and is destroyed with it
	button.MouseButton2Click:Connect(function()
		self:_OpenContextMenu()
	end)
	button.TouchLongPress:Connect(function(positions, state)
		if state == Enum.UserInputState.Begin then
			self:_OpenContextMenu(positions and positions[1])
		end
	end)
end

-- No separator first, last or twice in a row.
local function TidySeparators(items)
	local tidy = {}
	for _, item in ipairs(items) do
		if item ~= "-" or (#tidy > 0 and tidy[#tidy] ~= "-") then
			table.insert(tidy, item)
		end
	end
	if tidy[#tidy] == "-" then
		table.remove(tidy)
	end
	return tidy
end

function RowMethods:_ContextItems()
	local element = self.Element
	local items = {}
	if not element then
		return items
	end
	local window = self.Window
	if self.ErrorMessage then
		table.insert(items, {
			Text = "Show Error…",
			Icon = "bug",
			Callback = function()
				self:_OpenErrorDialog()
			end,
		})
		table.insert(items, {
			Text = "Clear Error",
			Icon = "x",
			Callback = function()
				self:ClearError()
			end,
		})
		table.insert(items, "-")
	end
	if element.Default ~= nil or element._Reset then
		table.insert(items, {
			Text = "Reset to Default",
			Icon = "rotate-ccw",
			Disabled = self.Disabled or element:IsDefault(),
			Callback = function()
				element:Reset()
				window:Toast(element.Title or "Setting", { Detail = "Reset", Icon = "rotate-ccw" })
			end,
		})
	end
	local text = not element.NoCopy and element:GetText() or nil
	if text and text ~= "" then
		local copyTitle = "Copy Value"
		if element.Type == "Label" or element.Type == "Paragraph" or element.Type == "Code" then
			copyTitle = "Copy Text"
		end
		table.insert(items, {
			Text = copyTitle,
			Icon = "copy",
			Callback = function()
				if CopyToClipboard(text) then
					window:Toast("Copied to Clipboard", { Icon = "clipboard" })
				else
					window:Toast("Clipboard isn’t available", { Icon = "x-circle" })
				end
			end,
		})
	end
	if element.Type == "Dropdown" and element.Multi and not self.Disabled then
		table.insert(items, "-")
		table.insert(items, {
			Text = "Select All",
			Icon = "list-checks",
			Callback = function()
				element:SetValue(element.Values)
			end,
		})
		table.insert(items, {
			Text = "Deselect All",
			Icon = "list",
			Callback = function()
				element:SetValue({})
			end,
		})
	end
	if element._ContextItems then
		for _, item in ipairs(element:_ContextItems()) do
			table.insert(items, item)
		end
	end
	if element._Activate and not TouchOnly() then
		table.insert(items, "-")
		table.insert(items, {
			Text = element.Shortcut and "Change Shortcut…" or "Add Shortcut…",
			Icon = "keyboard",
			Shortcut = element.Shortcut and KeyName(element.Shortcut) or nil,
			Callback = function()
				element:RecordShortcut()
			end,
		})
		if element.Shortcut then
			table.insert(items, {
				Text = "Remove Shortcut",
				Icon = "x",
				Callback = function()
					element:SetShortcut(nil)
				end,
			})
		end
	end
	if element.Type == "Toggle" or element.Type == "Button" then
		local isButton = element.Type == "Button"
		table.insert(items, "-")
		if self.Timer then
			table.insert(items, {
				Text = isButton and "Stop Repeating" or "Cancel Timer",
				Icon = "timer-off",
				Shortcut = FormatClock(self.Timer.Ends - os.clock()),
				Callback = function()
					self:_CancelTimer()
				end,
			})
		else
			table.insert(items, {
				Text = isButton and "Repeat Every…" or (element.Value and "Turn Off After…" or "Turn On After…"),
				Icon = isButton and "repeat" or "timer",
				Disabled = self.Disabled,
				Callback = function()
					self:_OpenTimerMenu()
				end,
			})
		end
	end
	return TidySeparators(items)
end

function RowMethods:_OpenContextMenu(point)
	if KeyCapture.Active or JustCaptured() or self.Destroyed then
		return
	end
	local now = os.clock()
	if now - (self.LastContext or 0) < 0.2 then
		return
	end
	self.LastContext = now
	-- kept for follow-up menus (timer durations) that open in the same place
	self.ContextPoint = point or MousePosition()
	local items = self:_ContextItems()
	if #items > 0 then
		self.Window:_OpenContextMenu(self.ContextPoint, items)
	end
end

-- The little key cap that shows an element's keyboard shortcut.
function RowMethods:_RenderShortcut()
	local element = self.Element
	local key = element and element.Shortcut
	local show = (key ~= nil or self.RecordingShortcut == true) and not TouchOnly()
	if show and not self.ShortcutCap then
		local cap = New("TextButton", {
			Name = "Shortcut",
			TextSize = 11,
			Weight = Enum.FontWeight.Medium,
			Size = UDim2.fromOffset(24, 20),
			LayoutOrder = -10,
			Theme = {
				BackgroundColor3 = function(t)
					return self.RecordingShortcut and t.Field or t.Control
				end,
				BackgroundTransparency = function()
					return 0
				end,
				TextColor3 = "SubText",
			},
			Parent = self.Accessory,
		})
		Corner(cap, 5)
		self.ShortcutStroke = Stroke(cap, function(t)
			return self.RecordingShortcut and MacUI.Accent or t.ControlStroke
		end)
		cap.MouseButton1Click:Connect(function()
			if self.Element and not self.Disabled and not self.RecordingShortcut and not JustCaptured() then
				self.Element:RecordShortcut()
			end
		end)
		self:_BindContext(cap)
		self.ShortcutCap = cap
	end
	if self.ShortcutCap then
		self.ShortcutCap.Visible = show
		local text = self.RecordingShortcut and "Type a key…" or KeyName(key or "")
		self.ShortcutCap.Text = text
		self.ShortcutCap.Size = UDim2.fromOffset(
		math.max(24, math.ceil(MeasureText(text, 11, Enum.FontWeight.Medium)) + 14), 20)
		Restyle(self.ShortcutCap, 0.12)
		Restyle(self.ShortcutStroke, 0.12)
	end
end

-- "Script.Name:12: attempt to index nil" -> "attempt to index nil", "line 12 of Name"
local function ErrorParts(message)
	message = tostring(message)
	local source, line, text = message:match("^(.-):(%d+): (.+)$")
	if not source or source == "" or source:find("\n") then
		return message, nil
	end
	if source:match("^%[string ") then
		return text, "line " .. line
	end
	local name = source:match("([^/\\]+)$") or source
	if not name:match("%.luau?$") then
		name = name:match("([^%.]+)$") or name -- Roblox paths: just the script's name
	end
	return text, "line " .. line .. " of " .. name
end

-- Callback errors: a red badge on the row. Hover it for the message, click it
-- for the details (copy them, or clear the badge).
function RowMethods:_ShowError(message, trace)
	self.ErrorCount = (self.ErrorCount or 0) + 1
	self.ErrorMessage = tostring(message)
	self.ErrorTrace = trace or self.ErrorMessage
	if self.Element then
		self.Element.LastError = self.ErrorMessage
	end
	if self.ErrorBadge then
		return
	end
	local badge = New("ImageButton", {
		Name = "Error",
		Image = MacUI:GetIcon("alert-triangle") or "",
		Size = UDim2.fromOffset(0, 16),
		LayoutOrder = -20,
		Theme = { ImageColor3 = "Destructive" },
		Parent = self.Accessory,
	})
	Tween(badge, { Size = UDim2.fromOffset(16, 16) }, 0.3, Enum.EasingStyle.Back)
	badge.MouseButton1Click:Connect(function()
		self:_OpenErrorDialog()
	end)
	self:_BindContext(badge)
	self.Window:_AttachTooltip(badge, function()
		local text = ErrorParts(self.ErrorMessage or "")
		if #text > 200 then
			text = text:sub(1, 197) .. "…"
		end
		local count = self.ErrorCount or 1
		return text .. (count > 1 and ("  (" .. count .. " times)") or "")
	end)
	self.ErrorBadge = badge
end

function RowMethods:ClearError()
	self.ErrorCount, self.ErrorMessage, self.ErrorTrace = nil, nil, nil
	if self.Element then
		self.Element.LastError = nil
	end
	if self.ErrorBadge then
		self.ErrorBadge:Destroy()
		self.ErrorBadge = nil
	end
end

function RowMethods:_OpenErrorDialog()
	if not self.ErrorMessage or self.Destroyed then
		return
	end
	local window = self.Window
	local count = self.ErrorCount or 1
	local name = self.Title ~= "" and self.Title or "This control"
	local text, where = ErrorParts(self.ErrorMessage)
	local notes = {}
	if where then
		table.insert(notes, (where:gsub("^%l", string.upper)))
	end
	if count > 1 then
		table.insert(notes, "happened " .. count .. " times")
	end
	window:Dialog({
		Title = "“" .. name .. "” ran into an error",
		Content = EscapeRich(text) .. (#notes > 0 and ("\n\n" .. EscapeRich(table.concat(notes, " · "))) or ""),
		Icon = "bug",
		IconColor = "Red",
		Buttons = {
			{
				Title = "Copy Details",
				Callback = function()
					if CopyToClipboard(self.ErrorTrace or self.ErrorMessage or "") then
						window:Toast("Copied to Clipboard", { Icon = "clipboard" })
					else
						window:Toast("Clipboard isn’t available", { Icon = "x-circle" })
					end
				end,
			},
			{
				Title = "Clear Error",
				Callback = function()
					self:ClearError()
				end,
			},
			{ Title = "Close" },
		},
	})
end

function RowMethods:_SetTimer(timer)
	if self.Destroyed then
		timer = nil
	end
	self.Timer = timer
	ActiveTimers[self] = timer
	if timer then
		EnsureTimerLoop()
	end
	self:_RenderTimer()
	MacUI.TimersChanged:Fire()
end

-- The countdown chip shown while a timer runs; click it to change or cancel.
function RowMethods:_RenderTimer()
	local timer = self.Timer
	if not timer then
		if self.TimerChip then
			self.TimerChip:Destroy()
			self.TimerChip = nil
		end
		return
	end
	if not self.TimerChip then
		local chip = New("TextButton", {
			Name = "Timer",
			Size = UDim2.fromOffset(56, 20),
			LayoutOrder = -15,
			Theme = {
				BackgroundColor3 = "Accent",
				BackgroundTransparency = function()
					return 0.84
				end,
			},
			Parent = self.Accessory,
		})
		Corner(chip, 10)
		IconImage({
			Name = "Icon",
			Icon = timer.Icon or "timer",
			IconSize = 12,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 7, 0.5, 0),
			Theme = { ImageColor3 = "Accent" },
			Parent = chip,
		})
		New("TextLabel", {
			Name = "Remaining",
			TextSize = 11,
			Weight = Enum.FontWeight.Medium,
			Position = UDim2.fromOffset(22, 0),
			Size = UDim2.new(1, -28, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Theme = { TextColor3 = "Accent" },
			Parent = chip,
		})
		chip.MouseButton1Click:Connect(function()
			self:_OpenTimerMenu(MousePosition())
		end)
		self:_BindContext(chip)
		self.Window:_AttachTooltip(chip, function()
			local current = self.Timer
			if not current then
				return nil
			end
			if current.Interval then
				return "Runs every " .. DescribeDuration(current.Interval) .. ". Click to change or stop."
			end
			return "Turns " .. (current.Value and "on" or "off") .. " when this reaches zero. Click to change or cancel."
		end)
		self.TimerChip = chip
	end
	local text = FormatClock(timer.Ends - os.clock())
	local label = self.TimerChip:FindFirstChild("Remaining")
	if label and label.Text ~= text then
		label.Text = text
		-- sized from zeros so the chip doesn't twitch as the digits change
		local width = MeasureText((text:gsub("%d", "0")), 11, Enum.FontWeight.Medium)
		self.TimerChip.Size = UDim2.fromOffset(math.ceil(width) + 34, 20)
	end
end

function RowMethods:_CancelTimer()
	local element = self.Element
	if element and element.Type == "Button" and element.SetRepeat then
		element:SetRepeat(nil)
	elseif element and element.SetTimer then
		element:SetTimer(nil)
	else
		self:_SetTimer(nil)
	end
end

function RowMethods:_StartTimer(seconds, target)
	local element = self.Element
	if not element or self.Destroyed then
		return
	end
	if element.Type == "Button" then
		element:SetRepeat(seconds)
		self.Window:Toast(element.Title or "Button", {
			Detail = "every " .. DescribeDuration(seconds),
			Icon = "repeat",
			Highlight = true,
		})
	elseif element.SetTimer then
		local timer = element:SetTimer(seconds, target)
		if timer then
			self.Window:Toast(element.Title or "Toggle", {
				Detail = (timer.Value and "on" or "off") .. " in " .. DescribeDuration(seconds),
				Icon = "timer",
				Highlight = true,
			})
		end
	end
end

-- Asks for a custom duration ("20m", "1h 30m", "45s").
function RowMethods:_AskTimer(target)
	local element = self.Element
	if not element then
		return
	end
	local isButton = element.Type == "Button"
	local name = tostring(element.Title or "this")
	self.Window:Dialog({
		Title = isButton and ("Repeat “" .. name .. "” every")
			or ((target and "Turn on “" or "Turn off “") .. name .. "” in"),
		Content = isButton and "Seconds, or a time like 90s, 5m or 1h."
			or "Minutes, or a time like 45s, 20m or 1h 30m.",
		Icon = isButton and "repeat" or "timer",
		Input = { Placeholder = isButton and "30s" or "20m" },
		Buttons = {
			{
				Title = "Start",
				Callback = function(text)
					local seconds = ParseDuration(text, isButton and "s" or "m")
					if seconds then
						self:_StartTimer(seconds, target)
					else
						self.Window:Toast("Couldn’t read that time", { Icon = "x-circle" })
					end
				end,
			},
			{ Title = "Cancel" },
		},
	})
end

-- Durations for a toggle timer or a button repeat, opened from the context
-- menu or the countdown chip.
function RowMethods:_OpenTimerMenu(point)
	local element = self.Element
	if not element or self.Destroyed then
		return
	end
	local isButton = element.Type == "Button"
	local target = self.Timer and self.Timer.Value
	if target == nil then
		target = not element.Value
	end
	local items = {}
	if self.Timer then
		table.insert(items, {
			Text = isButton and "Stop Repeating" or "Cancel Timer",
			Icon = "timer-off",
			Shortcut = FormatClock(self.Timer.Ends - os.clock()),
			Callback = function()
				self:_CancelTimer()
			end,
		})
		table.insert(items, "-")
	end
	local verb = isButton and "Repeat Every " or (target and "Turn On in " or "Turn Off in ")
	for _, seconds in ipairs(isButton and BUTTON_REPEAT_PRESETS or TOGGLE_TIMER_PRESETS) do
		table.insert(items, {
			Text = verb .. DescribeDuration(seconds, true),
			Callback = function()
				self:_StartTimer(seconds, target)
			end,
		})
	end
	table.insert(items, "-")
	table.insert(items, {
		Text = "Custom…",
		Icon = isButton and "repeat" or "timer",
		Callback = function()
			self:_AskTimer(target)
		end,
	})
	self.Window:_OpenContextMenu(point or self.ContextPoint or MousePosition(), items)
end

--------------------------------------------------------------------------------
-- Element base
--------------------------------------------------------------------------------

local ElementBase = {}
ElementBase.__index = ElementBase

local function NewElement(kind, row, info)
	local element = setmetatable({
		Type = kind,
		Row = row,
		Title = info.Title,
		Description = info.Description,
		Callback = info.Callback,
		_listeners = {},
	}, ElementBase)
	row.Element = element
	return element
end

function ElementBase:SetTitle(text)
	self.Title = text
	self.Row:SetTitle(text)
end

function ElementBase:SetDesc(text)
	self.Description = text
	self.Row:SetDesc(text)
end

ElementBase.SetDescription = ElementBase.SetDesc

function ElementBase:SetVisible(visible)
	self.Row:SetVisible(visible)
end

function ElementBase:SetDisabled(disabled)
	self.Disabled = disabled == true
	self.Row:SetDisabled(disabled)
end

function ElementBase:Lock()
	self:SetDisabled(true)
end

function ElementBase:Unlock()
	self:SetDisabled(false)
end

function ElementBase:OnChanged(fn)
	table.insert(self._listeners, fn)
	SafeCall(fn, self.Value)
	return self
end

function ElementBase:_Emit(...)
	RunCallback(self, self.Callback, ...)
	for _, fn in ipairs(self._listeners) do
		RunCallback(self, fn, ...)
	end
	if self.Idx ~= nil then
		MacUI.OptionChanged:Fire(self.Idx, self.Value, self)
	end
end

function ElementBase:IsDefault()
	if self._IsDefault then
		return self:_IsDefault()
	end
	return self.Default == nil or SameValue(self.Value, self.Default)
end

function ElementBase:Reset()
	if self._Reset then
		self:_Reset()
	elseif self.Default ~= nil and self.SetValue then
		self:SetValue(CopyValue(self.Default))
	end
end

-- Human-readable value, used by "Copy Value" and Spotlight.
function ElementBase:GetText()
	if self._Text then
		return self:_Text()
	end
	if self.Value == nil then
		return nil
	end
	return tostring(self.Value)
end

-- Binds a key that activates this element (toggles and buttons).
function ElementBase:SetShortcut(key)
	if self.Row.Destroyed then
		return
	end
	if typeof(key) == "EnumItem" then
		key = key.Name
	end
	if key == "None" or key == "" or key == false then
		key = nil
	end
	self.Shortcut = key
	local row = self.Row
	if row.ShortcutConnection then
		row.ShortcutConnection:Disconnect()
		row.ShortcutConnection = nil
	end
	if key then
		row.ShortcutConnection = row:Connect(UserInputService.InputBegan, function(input, processed)
			-- `processed` covers typing in chat and clicks on other interfaces
			if processed or KeyCapture.Active or row.Disabled or row.DependencyHidden or UserInputService:GetFocusedTextBox() then
				return
			end
			if KeyMatches(input, key) and self._Activate then
				MarkActivity()
				self:_Activate(true)
			end
		end)
	end
	row:_RenderShortcut()
	ShortcutsChanged:Fire()
	if self.Idx ~= nil then
		MacUI.OptionChanged:Fire(self.Idx, self.Value, self)
	end
end

function ElementBase:RecordShortcut()
	local row = self.Row
	if row.RecordingShortcut or not self._Activate then
		return
	end
	row.RecordingShortcut = true
	row:_RenderShortcut()
	-- keyboard only: a right-click shortcut would fire on every context-menu click
	row.Capture = CaptureKey(function(key)
		row.Capture = nil
		row.RecordingShortcut = false
		if row.Destroyed then
			return
		end
		if key == false then
			row:_RenderShortcut()
			return
		end
		self:SetShortcut(key)
	end, true)
end

-- Removes the error badge left by a failed callback.
function ElementBase:ClearError()
	self.Row:ClearError()
end

function ElementBase:Destroy()
	self.Row:Destroy()
	if self.Idx ~= nil and MacUI.Options[self.Idx] == self then
		MacUI.Options[self.Idx] = nil
	end
end

--------------------------------------------------------------------------------
-- Undo / redo (Ctrl/Cmd + Z, Ctrl/Cmd + Shift + Z or Ctrl + Y). Records what
-- the user changes on indexed controls. Changes made together (a slider drag,
-- a loaded profile, a toggle's knock-on effects) undo as one step, and changes
-- a script makes on its own aren't recorded.
--------------------------------------------------------------------------------

local UNDOABLE = {
	Toggle = true,
	Slider = true,
	Dropdown = true,
	Input = true,
	Keybind = true,
	Colorpicker = true,
	Segmented = true,
	Stepper = true,
	Radio = true,
}
local History = { Undo = {}, Redo = {}, Busy = false, Limit = 100 }
local Snapshots = setmetatable({}, { __mode = "k" })

-- Timers and macros change things through AutomationApply: not undoable, and
-- not recorded into a macro.
local Automation = { Depth = 0 }
-- The macro that is recording right now, if any.
local Macros = { Recorder = nil }
local function AutomationApply(fn, ...)
	Automation.Depth = Automation.Depth + (1)
	local busy = History.Busy
	History.Busy = true
	local ok, err = pcall(fn, ...)
	History.Busy = busy
	Automation.Depth = Automation.Depth - (1)
	if not ok then
		warn("[MacUI] " .. tostring(err))
	end
end

-- Runs fn with the changes it makes kept out of undo, macros and Spotlight's
-- suggestions: for code that updates controls to match something else (an
-- editor following the current theme, say).
function MacUI:Quietly(fn, ...)
	AutomationApply(fn, ...)
end

-- Stands in for a nil value (a cleared menu), so "no snapshot yet" and "empty"
-- aren't confused.
local NIL_VALUE = setmetatable({}, {
	__tostring = function()
		return "nil"
	end,
})

local function Snapshot(element)
	if element.Type == "Colorpicker" then
		return { Color = element.Value, Transparency = element.Transparency }
	elseif element.Type == "Keybind" then
		return { Key = element.Value, Mode = element.Mode }
	elseif element.Type == "Dropdown" and element.Multi then
		return element:GetActiveValues()
	end
	local value = CopyValue(element.Value)
	if value == nil then
		return NIL_VALUE
	end
	return value
end

local function RestoreSnapshot(element, snapshot)
	if snapshot == NIL_VALUE then
		element:SetValue(nil)
	elseif element.Type == "Colorpicker" then
		element.Transparency = snapshot.Transparency
		element:SetValueRGB(snapshot.Color)
	elseif element.Type == "Keybind" then
		element:SetValue(snapshot.Key, snapshot.Mode)
	else
		element:SetValue(CopyValue(snapshot))
	end
end

-- The user is using the interface: they clicked or typed in it a moment ago,
-- or are still holding a press that began on it (see Activity). The moment is
-- short, so a script's own change right after a click isn't taken for theirs.
local function UserActive()
	return os.clock() - Activity.Last < 0.25 or Activity.Pressing ~= nil
end

local function RecordChange(element, before, after)
	local now = os.clock()
	local top = History.Undo[#History.Undo]
	local merge = top
		and (now - top.Time < 0.15 or (now - top.Time < 1 and top.Changes[#top.Changes].Element == element))
	if merge then
		local existing
		for _, change in ipairs(top.Changes) do
			if change.Element == element then
				existing = change
				break
			end
		end
		if existing then
			existing.After = after
		else
			table.insert(top.Changes, { Element = element, Before = before, After = after })
		end
		top.Time = now
		-- flipped and flipped back: nothing left to undo
		for index = #top.Changes, 1, -1 do
			if SameValue(top.Changes[index].Before, top.Changes[index].After) then
				table.remove(top.Changes, index)
			end
		end
		if #top.Changes == 0 then
			table.remove(History.Undo)
		end
	else
		table.insert(History.Undo, { Changes = { { Element = element, Before = before, After = after } }, Time = now })
		if #History.Undo > History.Limit then
			table.remove(History.Undo, 1)
		end
	end
	table.clear(History.Redo)
end


--------------------------------------------------------------------------------
-- Usage: what the user reaches for, so Spotlight can suggest it ("frecency":
-- how often, weighted by how recently)
--------------------------------------------------------------------------------

-- Fires (a couple of seconds after a change) when usage changes; InterfaceManager saves it.
MacUI.UsageChanged = Signal.new()
local Usage = {}
local usageQueued = false

local function UsageKey(element)
	if element.Idx ~= nil then
		return "o:" .. tostring(element.Idx)
	end
	local tab = element.Row and element.Row.Tab
	return "p:" .. (tab and tab.Title or "") .. "/" .. tostring(element.Title or "")
end

local function NoteUsage(key)
	if not key then
		return
	end
	local entry = Usage[key]
	local now = os.clock()
	if entry and entry.Clock and now - entry.Clock < 2 then
		return -- a drag or a burst of typing counts once
	end
	if not entry then
		entry = { Count = 0, Last = 0 }
		Usage[key] = entry
	end
	entry.Count = entry.Count + (1)
	entry.Last = os.time()
	entry.Clock = now
	if not usageQueued then
		usageQueued = true
		task.delay(2, function()
			usageQueued = false
			if not MacUI.Unloaded then
				MacUI.UsageChanged:Fire()
			end
		end)
	end
end

local function Frecency(key)
	local entry = key and Usage[key]
	if not entry then
		return 0
	end
	local age = os.time() - (entry.Last or 0)
	local weight = age < 3600 and 4 or age < 86400 and 2 or age < 604800 and 1 or 0.5
	return entry.Count * weight
end

-- Usage as a plain table (to save); SetUsage merges a saved one back in.
function MacUI:GetUsage()
	local copy = {}
	for key, entry in pairs(Usage) do
		copy[key] = { c = entry.Count, t = entry.Last }
	end
	return copy
end

function MacUI:SetUsage(data)
	if type(data) ~= "table" then
		return
	end
	for key, entry in pairs(data) do
		local count = type(entry) == "table" and tonumber(entry.c)
		if type(key) == "string" and count then
			local current = Usage[key]
			if not current or current.Count < count then
				Usage[key] = { Count = count, Last = tonumber(entry.t) or 0, Clock = current and current.Clock }
			end
		end
	end
	self.UsageChanged:Fire()
end

function MacUI:ClearUsage()
	table.clear(Usage)
	self.UsageChanged:Fire()
end

-- One listener for undo, macro recording and suggestions, so all three agree
-- on what counts: a real change of value that the user made.
MacUI.OptionChanged:Connect(function(_, _, element)
	if type(element) ~= "table" or not UNDOABLE[element.Type] then
		return
	end
	local before = Snapshots[element]
	local after = Snapshot(element)
	Snapshots[element] = after
	if before == nil or SameValue(before, after) then
		return -- nothing changed (a new shortcut, say)
	end
	if Automation.Depth > 0 or not UserActive() then
		return -- a script, a timer or a macro did it
	end
	if not History.Busy and MacUI.UndoEnabled then
		RecordChange(element, before, after)
	end
	if Macros.Recorder then
		Macros.Recorder:_Capture(element, after)
	end
	if not MacUI._LoadingProfile then
		NoteUsage(UsageKey(element))
	end
end)

local function ReplayHistory(fromStack, toStack, field, verb, icon)
	local entry = table.remove(fromStack)
	while entry do
		local alive = {}
		for _, change in ipairs(entry.Changes) do
			if not change.Element.Row.Destroyed then
				table.insert(alive, change)
			end
		end
		if #alive > 0 then
			entry.Changes = alive
			break
		end
		entry = table.remove(fromStack)
	end
	if not entry then
		return false
	end
	History.Busy = true
	local first, last = 1, #entry.Changes
	local step = 1
	if field == "Before" then
		first, last, step = last, 1, -1
	end
	for index = first, last, step do
		local change = entry.Changes[index]
		local ok, err = pcall(RestoreSnapshot, change.Element, change[field])
		if not ok then
			warn("[MacUI] couldn't " .. verb:lower() .. ": " .. tostring(err))
		end
		Snapshots[change.Element] = Snapshot(change.Element)
	end
	History.Busy = false
	entry.Time = -1 -- never merge a replayed step with the next change
	table.insert(toStack, entry)
	local element = entry.Changes[1].Element
	local detail = #entry.Changes == 1 and tostring(element.Title or element.Idx or "Change") or
	(#entry.Changes .. " changes")
	local window = element.Row and element.Row.Window
	if window and window.Toast then
		window:Toast(verb, { Detail = detail, Icon = icon })
	end
	return true
end

-- Reverts the last change. Returns false when there's nothing to undo.
function MacUI:Undo()
	return ReplayHistory(History.Undo, History.Redo, "Before", "Undo", "undo-2")
end

-- Re-applies the last undone change.
function MacUI:Redo()
	return ReplayHistory(History.Redo, History.Undo, "After", "Redo", "redo-2")
end

function MacUI:CanUndo()
	return #History.Undo > 0
end

function MacUI:CanRedo()
	return #History.Redo > 0
end

function MacUI:ClearHistory()
	table.clear(History.Undo)
	table.clear(History.Redo)
end

function MacUI:SetUndoEnabled(enabled)
	self.UndoEnabled = enabled ~= false
	if not self.UndoEnabled then
		self:ClearHistory()
	end
end

-- Ctrl, or Command on a Mac (reported as Super or Meta).
local function CommandKeyDown()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.LeftSuper)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightSuper)
		or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightMeta)
end

-- One set of listeners per library (not per window): tracks when the user last
-- clicked or typed, and handles Ctrl/Cmd + Z, Ctrl/Cmd + Shift + Z and Ctrl + Y.
local LibraryConnections = {}
local function EnsureLibraryInput()
	if #LibraryConnections > 0 or MacUI.Unloaded then
		return
	end
	local POINTERS = {
		[Enum.UserInputType.MouseButton1] = true,
		[Enum.UserInputType.Touch] = true,
	}
	local function AnyWindowShown()
		for _, window in ipairs(MacUI.Windows) do
			if window.Shown and not window.Minimized then
				return true
			end
		end
		return false
	end
	table.insert(LibraryConnections, UserInputService.InputBegan:Connect(function(input, processed)
		local kind = input.UserInputType
		-- only input the interface took: presses on its own GUI and typing in
		-- its own fields (not the game's buttons, the thumbstick or the chat)
		if POINTERS[kind] or kind == Enum.UserInputType.MouseButton2 then
			if processed and OverInterface(input.Position) then
				MarkActivity()
				if POINTERS[kind] then
					Activity.Pressing = input
				end
			end
		elseif kind == Enum.UserInputType.Keyboard and processed and TypingInInterface() then
			MarkActivity()
		end
		if input.KeyCode ~= Enum.KeyCode.Z and input.KeyCode ~= Enum.KeyCode.Y then
			return
		end
		-- undo only while a window is showing: a hidden change is a surprise
		if processed or KeyCapture.Active or MacUI.Unloaded or UserInputService:GetFocusedTextBox() or not CommandKeyDown() or not AnyWindowShown() then
			return
		end
		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or
		UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		MarkActivity() -- a recording macro sees what the undo changes
		if input.KeyCode == Enum.KeyCode.Y or shift then
			MacUI:Redo()
		else
			MacUI:Undo()
		end
	end))
	table.insert(LibraryConnections, UserInputService.InputEnded:Connect(function(input)
		local pressing = Activity.Pressing
		if pressing and (input == pressing or (input.UserInputType == pressing.UserInputType and input.UserInputType ~= Enum.UserInputType.Touch)) then
			Activity.Pressing = nil
			MarkActivity() -- a slider that reports on release does so now
		end
	end))
end

local function Register(idx, element)
	if idx ~= nil then
		element.Idx = idx
		MacUI.Options[idx] = element
		CheckDependencies()
		if UNDOABLE[element.Type] then
			Snapshots[element] = Snapshot(element)
		end
	end
	return element
end

-- Push button used in rows, dialogs and notifications.
function PushButton(parent, text, style, height)
	local button = { Hovered = false, Pressed = false, Style = style or "Default" }
	button.Instance = New("TextButton", {
		Name = "PushButton",
		Text = tostring(text),
		TextSize = 13,
		Weight = Enum.FontWeight.Medium,
		-- measured rather than AutomaticSize: Roblox adds a UISizeConstraint's
		-- MinSize before the padding, which made short labels too wide
		Size = UDim2.fromOffset(math.max(56, math.ceil(MeasureText(text, 13, Enum.FontWeight.Medium)) + 24), height or 24),
		Theme = {
			BackgroundColor3 = function(t)
				local base
				if button.Style == "Primary" then
					base = MacUI.Accent
				elseif button.Style == "Destructive" then
					base = t.Destructive
				else
					base = t.Button
				end
				if button.Pressed then
					return Darken(base, 0.12)
				elseif button.Hovered then
					return button.Style == "Default" and t.ButtonHover or Lighten(base, 0.1)
				end
				return base
			end,
			BackgroundTransparency = function()
				return 0
			end,
			TextColor3 = function(t)
				if button.Style == "Default" then
					return t.Text
				end
				return rgb(255, 255, 255)
			end,
		},
		Parent = parent,
	})
	Corner(button.Instance, 6)
	New("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(234, 234, 234)),
		Parent = button.Instance,
	})
	button.Stroke = Stroke(button.Instance, function(t)
		if button.Style == "Primary" then
			return Darken(MacUI.Accent, 0.2)
		elseif button.Style == "Destructive" then
			return Darken(t.Destructive, 0.2)
		end
		return t.ControlStroke
	end, 1, 0.35)
	button.Instance.MouseEnter:Connect(function()
		button.Hovered = true
		Restyle(button.Instance, 0.12)
	end)
	button.Instance.MouseLeave:Connect(function()
		button.Hovered = false
		button.Pressed = false
		Restyle(button.Instance, 0.18)
	end)
	button.Instance.MouseButton1Down:Connect(function()
		button.Pressed = true
		Restyle(button.Instance, 0.06)
	end)
	button.Instance.MouseButton1Up:Connect(function()
		button.Pressed = false
		Restyle(button.Instance, 0.15)
	end)
	return button
end

--------------------------------------------------------------------------------
-- Containers (tabs and sections share these element constructors)
--------------------------------------------------------------------------------

local Container = {}

function Container:AddParagraph(idx, info)
	if type(idx) == "table" then
		info = idx
		idx = info.Flag
	end
	info = info or {}
	local row = CreateRow(self, {
		Title = info.Title,
		Description = info.Content or info.Description,
		Keywords = info.Keywords,
		Tooltip = info.Tooltip,
		DependsOn = info.DependsOn,
		DependsMode = info.DependsMode,
	}, { TitleWeight = Enum.FontWeight.Medium, DescSize = 13, DescToken = "SubText" })
	row.FullWidthText = true
	row:_UpdateReserve()
	local Paragraph = NewElement("Paragraph", row, info)
	Paragraph.Content = info.Content
	function Paragraph:SetContent(text)
		self.Content = text
		row:SetDesc(text)
	end

	function Paragraph:_Text()
		return self.Content and tostring(self.Content) or row.Title
	end

	Paragraph.SetDesc = Paragraph.SetContent
	Paragraph.SetValue = Paragraph.SetContent
	return Register(idx, Paragraph)
end

-- Key/value row: "Status ........ Fighting: Blessed Maiden"
function Container:AddLabel(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	row.NoWrap = true -- (the value caps its own width instead)
	local Label = NewElement("Label", row, info)
	Label.Value = tostring(info.Value or info.Text or "")

	local valueLabel = New("TextLabel", {
		Name = "Value",
		Text = Label.Value,
		TextSize = 14,
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Theme = {
			TextColor3 = function(t)
				return ResolveColor(info.ValueColor) or t.SubText
			end,
		},
		Parent = row.Accessory,
	})
	local limit = New("UISizeConstraint", { MaxSize = Vector2.new(320, 18), Parent = valueLabel })
	local function UpdateLimit()
		local rowWidth = row.Frame.AbsoluteSize.X / row.Window:GetAbsoluteScale()
		local share = row.Title == "" and row.Description == "" and 1 or 0.62
		limit.MaxSize = Vector2.new(math.max(rowWidth * share - 24, 40), 18)
	end
	row:Connect(row.Frame:GetPropertyChangedSignal("AbsoluteSize"), UpdateLimit)
	UpdateLimit()

	function Label:SetValue(text)
		self.Value = tostring(text or "")
		valueLabel.Text = self.Value
		row.SearchExtra = self.Value
	end

	Label.SetText = Label.SetValue
	function Label:SetValueColor(color)
		info.ValueColor = color
		Restyle(valueLabel, 0.15)
	end

	Label:SetValue(Label.Value)
	return Register(idx, Label)
end

Container.AddStatus = Container.AddLabel

function Container:AddButton(info, callback)
	local idx
	if type(info) == "string" and type(callback) == "table" then
		idx, info = info, callback
	elseif type(info) == "string" then
		info = { Title = info, Callback = callback }
	end
	info = info or {}
	idx = idx or info.Flag
	local row = CreateRow(self, info, { Clickable = true })
	local Button = NewElement("Button", row, info)

	local function Fire()
		if row.Disabled then
			return
		end
		if Automation.Depth == 0 then
			if Macros.Recorder then
				Macros.Recorder:_CaptureButton(Button)
			end
			NoteUsage(UsageKey(Button))
		end
		RunCallback(Button, Button.Callback)
	end

	function Button:_Activate(announce)
		if row.Disabled then
			return
		end
		Fire()
		if announce then
			row.Window:Toast(self.Title or "Button", { Icon = "play" })
		end
	end

	if info.ButtonText then
		local push = PushButton(row.Accessory, info.ButtonText, info.Style)
		push.Instance.MouseButton1Click:Connect(Fire)
		Button.PushButton = push
	else
		IconImage({
			Name = "Chevron",
			Icon = info.Icon or "chevron-right",
			IconSize = 14,
			Theme = { ImageColor3 = "Tertiary" },
			Parent = row.Accessory,
		})
	end
	row.OnClick = Fire

	function Button:SetCallback(fn)
		self.Callback = fn
	end

	function Button:Fire()
		Fire()
	end

	-- Presses the button every `seconds` until SetRepeat(nil). The row shows a
	-- countdown to the next press.
	function Button:SetRepeat(seconds)
		seconds = tonumber(seconds)
		if not seconds or seconds <= 0 then
			self.RepeatInterval = nil
			row:_SetTimer(nil)
			return nil
		end
		seconds = math.max(seconds, 1)
		self.RepeatInterval = seconds
		local timer = { Ends = os.clock() + seconds, Interval = seconds, Icon = "repeat", Runs = 0 }
		function timer.Fire()
			-- from the time it was due, so the interval doesn't drift
			timer.Ends = timer.Ends + (seconds)
			if timer.Ends <= os.clock() then
				timer.Ends = os.clock() + seconds -- fell far behind (the game froze)
			end
			timer.Runs = timer.Runs + (1)
			AutomationApply(Fire)
		end

		row:_SetTimer(timer)
		return timer
	end

	if info.Shortcut then
		Button:SetShortcut(info.Shortcut)
	end
	if idx ~= nil then
		Register(idx, Button)
	end
	return Button
end

function Container:AddToggle(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info, { Clickable = true })
	local Toggle = NewElement("Toggle", row, info)
	Toggle.Value = info.Default == true
	local checkbox = info.Style == "Checkbox"

	local knob, knobShadow, track, check
	if checkbox then
		track = New("Frame", {
			Name = "Checkbox",
			Size = UDim2.fromOffset(18, 18),
			Theme = {
				BackgroundColor3 = function(t)
					return Toggle.Value and MacUI.Accent or t.Field
				end,
			},
			Parent = row.Accessory,
		})
		Corner(track, 5)
		Stroke(track, function(t)
			return Toggle.Value and Darken(MacUI.Accent, 0.15) or t.FieldStroke
		end)
		check = IconImage({
			Icon = "check",
			IconSize = 13,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = Color3.new(1, 1, 1),
			ImageTransparency = Toggle.Value and 0 or 1,
			Parent = track,
		})
	else
		track = New("Frame", {
			Name = "Switch",
			Size = UDim2.fromOffset(30, 18),
			Theme = {
				BackgroundColor3 = function(t)
					return Toggle.Value and MacUI.Accent or t.SwitchOff
				end,
			},
			Parent = row.Accessory,
		})
		Corner(track, 9)
		knobShadow = New("Frame", {
			Name = "KnobShadow",
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.fromOffset(Toggle.Value and 14 or 2, 3),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.8,
			Parent = track,
		})
		Corner(knobShadow, 7)
		knob = New("Frame", {
			Name = "Knob",
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.fromOffset(Toggle.Value and 14 or 2, 2),
			ZIndex = 2,
			Theme = { BackgroundColor3 = "Knob" },
			Parent = track,
		})
		Corner(knob, 7)
	end

	local pressed = false
	local function Render(duration)
		Restyle(track, duration)
		if checkbox then
			local stroke = track:FindFirstChildOfClass("UIStroke")
			if stroke then
				Restyle(stroke, duration)
			end
			Tween(check, { ImageTransparency = Toggle.Value and 0 or 1 }, duration)
			return
		end
		local width = pressed and 18 or 14
		local x = Toggle.Value and (28 - width) or 2
		Tween(knob, { Position = UDim2.fromOffset(x, 2), Size = UDim2.fromOffset(width, 14) }, duration,
			Enum.EasingStyle.Quint)
		Tween(knobShadow, { Position = UDim2.fromOffset(x, 3), Size = UDim2.fromOffset(width, 14) }, duration,
			Enum.EasingStyle.Quint)
	end

	function Toggle:SetValue(value)
		value = value == true
		self.Value = value
		if row.Timer and row.Timer.Value == value then
			row:_SetTimer(nil) -- already where the timer was taking it
		end
		Render(0.25)
		self:_Emit(value)
		ShortcutsChanged:Fire()
	end

	function Toggle:_Text()
		return self.Value and "On" or "Off"
	end

	function Toggle:_Activate(announce)
		if row.Disabled then
			return
		end
		self:SetValue(not self.Value)
		if announce then
			row.Window:Toast(self.Title or "Toggle", {
				Detail = self.Value and "On" or "Off",
				Icon = self.Value and "check-circle" or "circle",
				Highlight = self.Value,
			})
		end
	end

	-- Flips the toggle after `seconds` (to `value`, or the opposite of what it
	-- is now); SetTimer(nil) cancels. The row shows a countdown meanwhile.
	function Toggle:SetTimer(seconds, value)
		seconds = tonumber(seconds)
		if value == nil then
			value = not self.Value
		end
		value = value == true
		if not seconds or seconds <= 0 or value == self.Value then
			row:_SetTimer(nil)
			return nil
		end
		local timer = { Ends = os.clock() + seconds, Duration = seconds, Value = value, Icon = "timer" }
		function timer.Fire()
			row:_SetTimer(nil)
			AutomationApply(function()
				Toggle:SetValue(value)
			end)
			MacUI:Notify({
				Title = tostring(Toggle.Title or "Timer"),
				Content = (value and "Turned on" or "Turned off") .. " by its timer.",
				Icon = "timer",
				Duration = 5,
			})
		end

		row:_SetTimer(timer)
		return timer
	end

	-- Seconds left and the value it will switch to, or nil.
	function Toggle:GetTimer()
		local timer = row.Timer
		if timer then
			return math.max(timer.Ends - os.clock(), 0), timer.Value
		end
		return nil
	end

	row.OnClick = function()
		Toggle:SetValue(not Toggle.Value)
	end
	if not checkbox then
		row.Hitbox.MouseButton1Down:Connect(function()
			pressed = true
			Render(0.2)
		end)
		row.Hitbox.MouseButton1Up:Connect(function()
			pressed = false
		end)
		row.Hitbox.MouseLeave:Connect(function()
			if pressed then
				pressed = false
				Render(0.2)
			end
		end)
	end

	Toggle.Default = Toggle.Value
	Render(0)
	Register(idx, Toggle)
	if info.Shortcut then
		Toggle:SetShortcut(info.Shortcut)
	end
	Toggle:_Emit(Toggle.Value)
	return Toggle
end

function Container:AddCheckbox(idx, info)
	idx, info = ParseArgs(idx, info)
	info.Style = "Checkbox"
	return self:AddToggle(idx, info)
end

-- A page doesn't scroll under a finger dragging a slider. Counted, since two
-- sliders on a page can be held at once.
local ScrollLocks = setmetatable({}, { __mode = "k" })
local function LockPageScrolling(page, lock)
	if not page then
		return
	end
	local count = math.max((ScrollLocks[page] or 0) + (lock and 1 or -1), 0)
	ScrollLocks[page] = count
	page.ScrollingEnabled = count == 0
end

function Container:AddSlider(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local Slider = NewElement("Slider", row, info)
	-- (Min above Max would make every clamp fail: they're put in order)
	Slider.Min = Finite(info.Min) or 0
	Slider.Max = Finite(info.Max) or 100
	Slider.Min, Slider.Max = math.min(Slider.Min, Slider.Max), math.max(Slider.Min, Slider.Max)
	Slider.Increment = Finite(info.Increment or info.Step)
	Slider.Rounding = Places(info.Rounding, StepPlaces(Slider.Increment))
	Slider.Finished = info.Finished == true
	Slider.Suffix = info.Suffix or ""
	Slider.Value = math.clamp(Finite(info.Default) or Slider.Min, Slider.Min, Slider.Max)

	local width = info.Width or 170
	local rail = New("Frame", {
		Name = "Slider",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(width, 22),
		LayoutOrder = 1,
		Parent = row.Accessory,
	})
	local bar = New("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 4),
		Theme = { BackgroundColor3 = "Track" },
		Parent = rail,
	})
	Corner(bar, 2)
	local fill = New("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		Theme = { BackgroundColor3 = "Accent" },
		Parent = bar,
	})
	Corner(fill, 2)
	local knobState = { Hovered = false, Dragging = false }
	local knob = New("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(18, 18),
		ZIndex = 3,
		Theme = { BackgroundColor3 = "Knob" },
		Parent = rail,
	})
	Corner(knob, 9)
	New("UIStroke", { Color = Color3.new(0, 0, 0), Transparency = 0.82, Thickness = 1, Parent = knob })
	local hit = New("TextButton", {
		Name = "Hitbox",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 16, 1, 10),
		ZIndex = 4,
		Parent = rail,
	})

	local box = New("TextBox", {
		Name = "Value",
		Text = "",
		TextSize = 13,
		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 0,
		LayoutOrder = 2,
		Theme = { BackgroundColor3 = "Field", TextColor3 = "Text" },
		Parent = row.Accessory,
	})
	Corner(box, 6)
	local boxStroke = Stroke(box, "FieldStroke")

	local function Format(value)
		return string.format("%." .. math.max(Slider.Rounding, 0) .. "f", value) .. Slider.Suffix
	end
	box.AutomaticSize = Enum.AutomaticSize.None
	box.Size = UDim2.fromOffset(
		math.max(56, math.ceil(math.max(MeasureText(Format(Slider.Max), 13), MeasureText(Format(Slider.Min), 13))) + 16),
		24
	)

	local function Render(duration)
		local range = Slider.Max - Slider.Min
		local alpha = range == 0 and 0 or (Slider.Value - Slider.Min) / range
		Tween(fill, { Size = UDim2.fromScale(alpha, 1) }, duration or 0.12, Enum.EasingStyle.Quart)
		Tween(knob, { Position = UDim2.fromScale(alpha, 0.5) }, duration or 0.12, Enum.EasingStyle.Quart)
		if not box:IsFocused() then
			box.Text = Format(Slider.Value)
		end
	end

	local function Normalize(value)
		value = math.clamp(Finite(value) or Slider.Min, Slider.Min, Slider.Max)
		if Slider.Increment and Slider.Increment > 0 then
			value = Slider.Min + Round((value - Slider.Min) / Slider.Increment) * Slider.Increment
		end
		return math.clamp(Round(value, Slider.Rounding), Slider.Min, Slider.Max)
	end

	local pendingEmit = false
	function Slider:SetValue(value)
		value = Normalize(value)
		local changed = value ~= self.Value
		self.Value = value
		Render()
		if changed or not self._initialized then
			if self.Finished and knobState.Dragging then
				pendingEmit = true
			else
				self:_Emit(value)
			end
		end
	end

	-- (a minimum above the maximum moves the maximum up, and the other way round)
	function Slider:SetMin(value)
		self.Min = Finite(value) or self.Min
		self.Max = math.max(self.Max, self.Min)
		self:SetValue(self.Value)
	end

	function Slider:SetMax(value)
		self.Max = Finite(value) or self.Max
		self.Min = math.min(self.Min, self.Max)
		self:SetValue(self.Value)
	end

	local function SetFromPointer(x)
		MarkActivity()
		local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		Slider:SetValue(Slider.Min + (Slider.Max - Slider.Min) * alpha)
	end

	local function RenderKnob()
		local size = (knobState.Dragging or knobState.Hovered) and 20 or 18
		Tween(knob, { Size = UDim2.fromOffset(size, size) }, 0.15)
	end

	hit.MouseEnter:Connect(function()
		knobState.Hovered = true
		RenderKnob()
	end)
	hit.MouseLeave:Connect(function()
		knobState.Hovered = false
		RenderKnob()
	end)
	-- a finger sliding along the track shouldn't also scroll the page
	local scrollLocked = false
	local function PageScrolling(enabled)
		if scrollLocked == not enabled then
			return
		end
		scrollLocked = not enabled
		LockPageScrolling(row.Tab and row.Tab.Page, scrollLocked)
	end
	row:_OnDestroy(function()
		PageScrolling(true) -- (removed mid-drag)
	end)
	hit.InputBegan:Connect(function(input)
		if IsPointer(input) and not row.Disabled then
			knobState.Dragging = input
			PageScrolling(false)
			RenderKnob()
			SetFromPointer(input.Position.X)
		end
	end)
	row:Connect(UserInputService.InputChanged, function(input)
		if knobState.Dragging and DragMoves(knobState.Dragging, input) then
			SetFromPointer(input.Position.X)
		end
	end)
	row:Connect(UserInputService.InputEnded, function(input)
		if knobState.Dragging and DragEnds(knobState.Dragging, input) then
			knobState.Dragging = false
			PageScrolling(true)
			RenderKnob()
			if pendingEmit then
				pendingEmit = false
				Slider:_Emit(Slider.Value)
			end
		end
	end)

	box.Focused:Connect(function()
		box.Text = string.format("%." .. math.max(Slider.Rounding, 0) .. "f", Slider.Value)
		Themed(boxStroke, { Color = "Accent" })
	end)
	box.FocusLost:Connect(function()
		MarkActivity()
		Themed(boxStroke, { Color = "FieldStroke" })
		local number = tonumber((box.Text:gsub("[^%d%.%-]", "")))
		if number then
			Slider:SetValue(number)
		end
		box.Text = Format(Slider.Value)
	end)

	Slider.Value = Normalize(Slider.Value)
	Slider.Default = Slider.Value
	function Slider:_Text()
		return Format(self.Value)
	end

	row:_BindContext(hit)
	Render(0)
	Register(idx, Slider)
	Slider:_Emit(Slider.Value)
	Slider._initialized = true
	return Slider
end

function Container:AddDropdown(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info, { Clickable = true })
	local window = row.Window
	local Dropdown = NewElement("Dropdown", row, info)
	local special = info.SpecialType
	if info.Values == "Players" then
		special = "Player"
	elseif info.Values == "Teams" then
		special = "Team"
	end
	local function SpecialValues()
		local list = {}
		if special == "Player" then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer or info.ExcludeLocal == false then
					table.insert(list, player.Name)
				end
			end
		elseif special == "Team" then
			local ok, teams = pcall(function()
				return GetService("Teams"):GetTeams()
			end)
			for _, team in ipairs(ok and teams or {}) do
				table.insert(list, team.Name)
			end
		end
		table.sort(list)
		return list
	end
	Dropdown.Values = special and SpecialValues() or (type(info.Values) == "table" and info.Values or {})
	Dropdown.Multi = info.Multi == true
	Dropdown.AllowNull = info.AllowNull == true or Dropdown.Multi or special ~= nil

	if Dropdown.Multi then
		Dropdown.Value = {}
		local default = info.Default
		if type(default) == "table" then
			for key, value in pairs(default) do
				if type(key) == "number" then
					Dropdown.Value[value] = true
				elseif value then
					Dropdown.Value[key] = true
				end
			end
		elseif type(default) == "string" then
			Dropdown.Value[default] = true
		end
	else
		local default = info.Default
		if type(default) == "number" then
			default = Dropdown.Values[default]
		end
		Dropdown.Value = default
		if Dropdown.Value == nil and not Dropdown.AllowNull then
			Dropdown.Value = Dropdown.Values[1]
		end
	end

	function Dropdown:_Display()
		if self.Multi then
			local selected = {}
			for _, value in ipairs(self.Values) do
				if self.Value[value] then
					table.insert(selected, tostring(value))
				end
			end
			if #selected == 0 then
				return "None"
			end
			local joined = table.concat(selected, ", ")
			if #selected > 2 and #joined > 26 then
				return #selected .. " selected"
			end
			return joined
		end
		if self.Value == nil then
			return "None"
		end
		return tostring(self.Value)
	end

	local popup = New("TextButton", {
		Name = "PopupButton",
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = row.Accessory,
	})
	List(popup, Enum.FillDirection.Horizontal, 7, { VerticalAlignment = Enum.VerticalAlignment.Center })
	local valueLabel = New("TextLabel", {
		Name = "Value",
		TextSize = 14,
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 1,
		Theme = {
			TextColor3 = function(t)
				return Dropdown:_Display() == "None" and t.SubText or t.Text
			end,
		},
		Parent = popup,
	})
	New("UISizeConstraint", { MaxSize = Vector2.new(info.MaxWidth or 200, 18), Parent = valueLabel })
	local capsuleState = { Hovered = false }
	local capsule = New("Frame", {
		Name = "Chevrons",
		Size = UDim2.fromOffset(17, 21),
		LayoutOrder = 2,
		Theme = {
			BackgroundColor3 = function(t)
				return capsuleState.Hovered and t.ControlHover or t.Control
			end,
		},
		Parent = popup,
	})
	Corner(capsule, 5)
	IconImage({
		Icon = "chevrons-up-down",
		IconSize = 12,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Theme = { ImageColor3 = "Text" },
		Parent = capsule,
	})

	function Dropdown:Display()
		valueLabel.Text = self:_Display()
		row.SearchExtra = valueLabel.Text
		Restyle(valueLabel, 0)
	end

	function Dropdown:GetActiveValues()
		if self.Multi then
			local list = {}
			for _, value in ipairs(self.Values) do
				if self.Value[value] then
					table.insert(list, value)
				end
			end
			return list
		end
		return self.Value and 1 or 0
	end

	function Dropdown:SetValue(value)
		if self.Multi then
			local set = {}
			if type(value) == "table" then
				for key, v in pairs(value) do
					if type(key) == "number" then
						set[v] = true
					elseif v then
						set[key] = true
					end
				end
			end
			self.Value = set
		else
			if value ~= nil and not table.find(self.Values, value) then
				value = nil
			end
			if value == nil and not self.AllowNull then
				value = self.Values[1]
			end
			self.Value = value
		end
		self:Display()
		self:_Emit(self.Value)
	end

	function Dropdown:SetValues(values)
		self.Values = values or {}
		-- a selection that no longer exists is dropped, and that is a change
		local changed = false
		if self.Multi then
			for key in pairs(self.Value) do
				if not table.find(self.Values, key) then
					self.Value[key] = nil
					changed = true
				end
			end
		elseif self.Value ~= nil and not table.find(self.Values, self.Value) then
			self.Value = (not self.AllowNull) and self.Values[1] or nil
			changed = true
		end
		self:Display()
		if changed then
			self:_Emit(self.Value)
		end
	end

	function Dropdown:Open()
		if row.Disabled then
			return
		end
		window:_OpenMenu(popup, {
			Values = self.Values,
			Multi = self.Multi,
			Searchable = info.Searchable,
			MinWidth = math.max(popup.AbsoluteSize.X / window:GetAbsoluteScale() + 24, 170),
			IsSelected = function(value)
				if self.Multi then
					return self.Value[value] == true
				end
				return self.Value == value
			end,
			OnPick = function(value)
				if self.Multi then
					self.Value[value] = not self.Value[value] or nil
					self:Display()
					self:_Emit(self.Value)
				else
					if self.Value == value and self.AllowNull then
						value = nil
					end
					self.Value = value
					self:Display()
					self:_Emit(self.Value)
				end
			end,
		})
	end

	function Dropdown:Close()
		window:_ClosePopup()
	end

	function Dropdown:_Text()
		if self.Multi then
			local list = {}
			for _, value in ipairs(self:GetActiveValues()) do
				table.insert(list, tostring(value))
			end
			return #list > 0 and table.concat(list, ", ") or nil
		end
		return self.Value ~= nil and tostring(self.Value) or nil
	end

	if special then
		local function Refresh()
			if not row.Destroyed then
				Dropdown:SetValues(SpecialValues())
			end
		end
		if special == "Player" then
			row:Connect(Players.PlayerAdded, Refresh)
			-- the leaving player is still in GetPlayers() while this fires
			row:Connect(Players.PlayerRemoving, function(leaving)
				if row.Destroyed then
					return
				end
				local list = SpecialValues()
				local index = table.find(list, leaving.Name)
				if index then
					table.remove(list, index)
				end
				Dropdown:SetValues(list)
			end)
		else
			local ok, teams = pcall(GetService, "Teams")
			if ok and teams then
				row:Connect(teams.ChildAdded, Refresh)
				row:Connect(teams.ChildRemoved, function()
					task.defer(Refresh)
				end)
			end
		end
	end

	popup.MouseEnter:Connect(function()
		capsuleState.Hovered = true
		Restyle(capsule, 0.12)
	end)
	popup.MouseLeave:Connect(function()
		capsuleState.Hovered = false
		Restyle(capsule, 0.18)
	end)
	popup.MouseButton1Click:Connect(function()
		Dropdown:Open()
	end)
	row.OnClick = function()
		Dropdown:Open()
	end

	Dropdown.Default = CopyValue(Dropdown.Value)
	row:_BindContext(popup)
	Dropdown:Display()
	return Register(idx, Dropdown)
end

function Container:AddInput(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local Input = NewElement("Input", row, info)
	Input.Value = tostring(info.Default or "")
	Input.Numeric = info.Numeric == true
	Input.Finished = info.Finished == true

	local field = New("Frame", {
		Name = "Field",
		Size = UDim2.fromOffset(info.Width or 180, 26),
		Theme = { BackgroundColor3 = "Field" },
		Parent = row.Accessory,
	})
	Corner(field, 6)
	local stroke = Stroke(field, "FieldStroke")
	local box = New("TextBox", {
		Name = "TextBox",
		Text = Input.Value,
		PlaceholderText = info.Placeholder or "",
		TextSize = 13,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		ClipsDescendants = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "Text", PlaceholderColor3 = "Tertiary" },
		Parent = field,
	})
	if info.MaxLength then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			if #box.Text > info.MaxLength then
				box.Text = box.Text:sub(1, info.MaxLength)
			end
		end)
	end

	function Input:SetValue(text)
		text = tostring(text or "")
		if self.Numeric and text ~= "" and not tonumber(text) then
			text = text:gsub("[^%d%.%-]", "")
		end
		self.Value = text
		if box.Text ~= text then
			box.Text = text
		end
		self:_Emit(text)
	end

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if box:IsFocused() then
			MarkActivity() -- the user typing
		end
		if Input.Numeric then
			local cleaned = box.Text:gsub("[^%d%.%-]", "")
			if cleaned ~= box.Text then
				box.Text = cleaned
				return
			end
		end
		if not Input.Finished and box.Text ~= Input.Value then
			Input:SetValue(box.Text)
		end
	end)
	box.Focused:Connect(function()
		Themed(stroke, { Color = "Accent" })
		Tween(stroke, { Thickness = 2 }, 0.15)
	end)
	box.FocusLost:Connect(function(enterPressed)
		MarkActivity()
		Themed(stroke, { Color = "FieldStroke" })
		Tween(stroke, { Thickness = 1 }, 0.15)
		if Input.Finished and (enterPressed or info.FinishOnFocusLost) then
			Input:SetValue(box.Text)
		end
	end)
	Input.Default = Input.Value
	return Register(idx, Input)
end

Container.AddTextbox = Container.AddInput

function Container:AddKeybind(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local Keybind = NewElement("Keybind", row, info)
	Keybind.Value = info.Default and (typeof(info.Default) == "EnumItem" and info.Default.Name or tostring(info.Default)) or
	"None"
	Keybind.Mode = info.Mode or "Toggle"
	Keybind.Toggled = false
	Keybind.Picking = false
	Keybind.ChangedCallback = info.ChangedCallback
	local clicked = Signal.new()

	local capState = { Hovered = false }
	local cap = New("TextButton", {
		Name = "KeyCap",
		TextSize = 13,
		Weight = Enum.FontWeight.Medium,
		Size = UDim2.fromOffset(58, 24),
		Theme = {
			BackgroundColor3 = function(t)
				return capState.Hovered and t.ControlHover or t.Control
			end,
			TextColor3 = function(t)
				return Keybind.Picking and t.SubText or t.Text
			end,
		},
		Parent = row.Accessory,
	})
	Corner(cap, 6)
	local capStroke = Stroke(cap, function(t)
		return Keybind.Picking and MacUI.Accent or t.ControlStroke
	end)

	local function Render()
		cap.Text = Keybind.Picking and "Press a key…" or KeyName(Keybind.Value)
		cap.Size = UDim2.fromOffset(math.max(58, math.ceil(MeasureText(cap.Text, 13, Enum.FontWeight.Medium)) + 20), 24)
		Restyle(cap, 0.12)
		Restyle(capStroke, 0.12)
		capStroke.Thickness = Keybind.Picking and 2 or 1
	end

	local function Matches(input)
		return KeyMatches(input, Keybind.Value)
	end

	function Keybind:GetState()
		if UserInputService:GetFocusedTextBox() and self.Mode ~= "Always" then
			return false
		end
		if self.Mode == "Always" then
			return true
		elseif self.Mode == "Hold" then
			if self.Value == "None" then
				return false
			elseif self.Value == "MB1" then
				return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			elseif self.Value == "MB2" then
				return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			end
			local ok, keycode = pcall(function()
				return Enum.KeyCode[self.Value]
			end)
			return ok and keycode and UserInputService:IsKeyDown(keycode) or false
		end
		return self.Toggled
	end

	function Keybind:SetValue(key, mode)
		if typeof(key) == "EnumItem" then
			key = key.Name
		end
		self.Value = key and tostring(key) or "None"
		self.Mode = mode or self.Mode
		Render()
		RunCallback(self, self.ChangedCallback, self.Value)
		for _, fn in ipairs(self._listeners) do
			RunCallback(self, fn, self.Value)
		end
		ShortcutsChanged:Fire()
		if self.Idx ~= nil then
			MacUI.OptionChanged:Fire(self.Idx, self.Value, self)
		end
	end

	function Keybind:OnClick(fn)
		return clicked:Connect(fn)
	end

	function Keybind:DoClick()
		RunCallback(self, self.Callback, self.Toggled)
		clicked:Fire(self.Toggled)
		ShortcutsChanged:Fire()
	end

	Keybind.DefaultKey, Keybind.DefaultMode = Keybind.Value, Keybind.Mode
	function Keybind:_IsDefault()
		return self.Value == self.DefaultKey and self.Mode == self.DefaultMode
	end

	function Keybind:_Reset()
		self:SetValue(self.DefaultKey, self.DefaultMode)
	end

	function Keybind:_Text()
		return self.Value ~= "None" and KeyName(self.Value) or nil
	end

	cap.MouseEnter:Connect(function()
		capState.Hovered = true
		Restyle(cap, 0.12)
	end)
	cap.MouseLeave:Connect(function()
		capState.Hovered = false
		Restyle(cap, 0.18)
	end)
	cap.MouseButton1Click:Connect(function()
		if row.Disabled or Keybind.Picking or JustCaptured() then
			return
		end
		Keybind.Picking = true
		Render()
		row.Capture = CaptureKey(function(key)
			row.Capture = nil
			Keybind.Picking = false
			if row.Destroyed then
				return
			end
			if key == false or key == Keybind.Value then
				Render()
				return
			end
			Keybind:SetValue(key)
		end)
	end)

	local holding = false
	row:Connect(UserInputService.InputBegan, function(input, processed)
		-- `processed` covers typing in chat and clicks on other interfaces
		if processed or Keybind.Picking or KeyCapture.Active or row.Disabled or row.DependencyHidden or UserInputService:GetFocusedTextBox() then
			return
		end
		if Matches(input) then
			if Keybind.Mode == "Toggle" then
				Keybind.Toggled = not Keybind.Toggled
			else
				Keybind.Toggled = true
				holding = Keybind.Mode == "Hold"
			end
			Keybind:DoClick()
		end
	end)
	row:Connect(UserInputService.InputEnded, function(input)
		if holding and Matches(input) then
			holding = false
			Keybind.Toggled = false
			RunCallback(Keybind, Keybind.Callback, false)
			clicked:Fire(false)
			ShortcutsChanged:Fire()
		end
	end)

	row:_BindContext(cap)
	Render()
	return Register(idx, Keybind)
end

function Container:AddColorpicker(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info, { Clickable = true })
	local window = row.Window
	local Picker = NewElement("Colorpicker", row, info)
	Picker.Value = ResolveColor(info.Default) or MacUI.Accent
	Picker.Transparency = info.Transparency
	Picker.Hue, Picker.Sat, Picker.Vib = Picker.Value:ToHSV()

	local wellState = { Hovered = false }
	local well = New("TextButton", {
		Name = "ColorWell",
		Size = UDim2.fromOffset(46, 24),
		Theme = {
			BackgroundColor3 = function(t)
				return wellState.Hovered and t.ControlHover or t.Control
			end,
		},
		Parent = row.Accessory,
	})
	Corner(well, 7)
	Stroke(well, "ControlStroke", 1, 0.3)
	local swatch = New("Frame", {
		Name = "Swatch",
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		BackgroundColor3 = Picker.Value,
		Parent = well,
	})
	Corner(swatch, 5)

	local listeners = {}
	function Picker:Display()
		swatch.BackgroundColor3 = self.Value
		swatch.BackgroundTransparency = self.Transparency or 0
		row.SearchExtra = "#" .. self.Value:ToHex()
		for _, fn in ipairs(listeners) do
			fn()
		end
	end

	function Picker:SetValueRGB(color, transparency)
		color = ResolveColor(color) or self.Value
		self.Value = color
		self.Hue, self.Sat, self.Vib = color:ToHSV()
		if transparency ~= nil then
			self.Transparency = transparency
		end
		self:Display()
		self:_Emit(self.Value)
	end

	function Picker:SetValue(hsv, transparency)
		if typeof(hsv) == "Color3" or type(hsv) == "string" then
			return self:SetValueRGB(hsv, transparency)
		end
		self.Hue, self.Sat, self.Vib = hsv[1], hsv[2], hsv[3]
		self.Value = Color3.fromHSV(hsv[1], hsv[2], hsv[3])
		if transparency ~= nil then
			self.Transparency = transparency
		end
		self:Display()
		self:_Emit(self.Value)
	end

	local function SetHSV(h, s, v)
		Picker.Hue, Picker.Sat, Picker.Vib = h, s, v
		Picker.Value = Color3.fromHSV(h, s, v)
		Picker:Display()
		Picker:_Emit(Picker.Value)
	end

	local function OpenPicker()
		if row.Disabled then
			return
		end
		local hasAlpha = Picker.Transparency ~= nil
		-- inner layout: SV box 0-140, hue 152-164, alpha 176-188, hex row, presets
		local rowY = (hasAlpha and 188 or 164) + 14
		local presetsY = rowY + 26 + 12
		local height = presetsY + 18 + 24
		window:_OpenPopup(well, 240, height, function(canvas, popover)
			local inner = New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Parent = canvas,
			})
			Padding(inner, 12, 12, 12, 12)

			local sv = New("Frame", {
				Name = "SaturationValue",
				Size = UDim2.new(1, 0, 0, 140),
				Parent = inner,
			})
			Corner(sv, 8)
			local white = New("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = sv,
			})
			Corner(white, 8)
			New("UIGradient", {
				Transparency = NumberSequence.new(0, 1),
				Parent = white,
			})
			local black = New("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(0, 0, 0),
				ZIndex = 2,
				Parent = sv,
			})
			Corner(black, 8)
			New("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new(1, 0),
				Parent = black,
			})
			local svCursor = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(14, 14),
				ZIndex = 3,
				Parent = sv,
			})
			Corner(svCursor, 7)
			New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = svCursor })

			local hue = New("Frame", {
				Name = "Hue",
				Position = UDim2.fromOffset(0, 152),
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = inner,
			})
			Corner(hue, 6)
			local keypoints = {}
			for i = 0, 6 do
				table.insert(keypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1)))
			end
			New("UIGradient", { Color = ColorSequence.new(keypoints), Parent = hue })
			local hueCursor = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromOffset(16, 16),
				ZIndex = 2,
				Parent = hue,
			})
			Corner(hueCursor, 8)
			New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = hueCursor })

			local alpha, alphaFill, alphaCursor
			if hasAlpha then
				alpha = New("Frame", {
					Name = "Alpha",
					Position = UDim2.fromOffset(0, 176),
					Size = UDim2.new(1, 0, 0, 12),
					Theme = { BackgroundColor3 = "Track" },
					Parent = inner,
				})
				Corner(alpha, 6)
				alphaFill = New("Frame", {
					Name = "Fill",
					Size = UDim2.fromScale(1, 1),
					Parent = alpha,
				})
				Corner(alphaFill, 6)
				New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = alphaFill })
				alphaCursor = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(16, 16),
					ZIndex = 2,
					Theme = { BackgroundColor3 = "Knob" },
					Parent = alpha,
				})
				Corner(alphaCursor, 8)
				New("UIStroke", { Color = Color3.new(0, 0, 0), Transparency = 0.75, Parent = alphaCursor })
			end

			local preview = New("Frame", {
				Name = "Preview",
				Position = UDim2.fromOffset(0, rowY),
				Size = UDim2.fromOffset(26, 26),
				Parent = inner,
			})
			Corner(preview, 6)
			Stroke(preview, "FieldStroke")
			local hexField = New("Frame", {
				Position = UDim2.fromOffset(36, rowY),
				Size = UDim2.new(1, -36, 0, 26),
				Theme = { BackgroundColor3 = "Field" },
				Parent = inner,
			})
			Corner(hexField, 6)
			local hexStroke = Stroke(hexField, "FieldStroke")
			local hexBox = New("TextBox", {
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -16, 1, 0),
				TextSize = 13,
				Theme = { TextColor3 = "Text" },
				Parent = hexField,
			})
			New("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -8, 0, 0),
				Size = UDim2.new(0, 40, 1, 0),
				Text = "HEX",
				TextSize = 11,
				Weight = Enum.FontWeight.Medium,
				TextXAlignment = Enum.TextXAlignment.Right,
				Theme = { TextColor3 = "SubText" },
				Parent = hexField,
			})
			local presets = New("Frame", {
				Name = "Presets",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, presetsY),
				Size = UDim2.new(1, 0, 0, 18),
				Parent = inner,
			})
			List(presets, Enum.FillDirection.Horizontal, 9, { VerticalAlignment = Enum.VerticalAlignment.Center })
			for index, name in ipairs(MacUI.AccentOrder) do
				local color = MacUI.Accents[name]
				local dot = New("TextButton", {
					Name = name,
					Size = UDim2.fromOffset(18, 18),
					BackgroundTransparency = 0,
					BackgroundColor3 = color,
					LayoutOrder = index,
					Parent = presets,
				})
				Corner(dot, 9)
				New("UIStroke", { Color = Darken(color, 0.25), Transparency = 0.4, Parent = dot })
				dot.MouseButton1Click:Connect(function()
					Picker:SetValueRGB(color)
				end)
			end

			local function Refresh()
				sv.BackgroundColor3 = Color3.fromHSV(Picker.Hue, 1, 1)
				svCursor.Position = UDim2.fromScale(Picker.Sat, 1 - Picker.Vib)
				svCursor.BackgroundColor3 = Picker.Value
				hueCursor.Position = UDim2.fromScale(Picker.Hue, 0.5)
				hueCursor.BackgroundColor3 = Color3.fromHSV(Picker.Hue, 1, 1)
				preview.BackgroundColor3 = Picker.Value
				preview.BackgroundTransparency = Picker.Transparency or 0
				if not hexBox:IsFocused() then
					hexBox.Text = "#" .. Picker.Value:ToHex():upper()
				end
				if alpha then
					alphaFill.BackgroundColor3 = Picker.Value
					alphaCursor.Position = UDim2.fromScale(Picker.Transparency or 0, 0.5)
				end
			end
			table.insert(listeners, Refresh)
			popover.OnClose = function()
				local index = table.find(listeners, Refresh)
				if index then
					table.remove(listeners, index)
				end
			end
			Refresh()

			local dragging, dragInput
			local function Update(position)
				MarkActivity()
				if dragging == "sv" then
					local s = math.clamp((position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
					local v = 1 - math.clamp((position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
					SetHSV(Picker.Hue, s, v)
				elseif dragging == "hue" then
					local h = math.clamp((position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 0.999)
					SetHSV(h, Picker.Sat, Picker.Vib)
				elseif dragging == "alpha" then
					Picker.Transparency = Round(
					math.clamp((position.X - alpha.AbsolutePosition.X) / alpha.AbsoluteSize.X, 0, 1), 2)
					Picker:Display()
					Picker:_Emit(Picker.Value)
				end
			end
			local function Begin(kind)
				return function(input)
					if IsPointer(input) then
						dragging, dragInput = kind, input
						Update(input.Position)
					end
				end
			end
			sv.InputBegan:Connect(Begin("sv"))
			hue.InputBegan:Connect(Begin("hue"))
			if alpha then
				alpha.InputBegan:Connect(Begin("alpha"))
			end
			popover:Connect(UserInputService.InputChanged, function(input)
				if dragging and DragMoves(dragInput, input) then
					Update(input.Position)
				end
			end)
			popover:Connect(UserInputService.InputEnded, function(input)
				if dragging and DragEnds(dragInput, input) then
					dragging, dragInput = nil, nil
				end
			end)
			hexBox.Focused:Connect(function()
				Themed(hexStroke, { Color = "Accent" })
			end)
			hexBox.FocusLost:Connect(function()
				MarkActivity()
				Themed(hexStroke, { Color = "FieldStroke" })
				local text = hexBox.Text:gsub("#", ""):gsub("%s", "")
				local ok, color = pcall(Color3.fromHex, text)
				if ok and color then
					Picker:SetValueRGB(color)
				else
					Refresh()
				end
			end)
		end)
	end

	well.MouseEnter:Connect(function()
		wellState.Hovered = true
		Restyle(well, 0.12)
	end)
	well.MouseLeave:Connect(function()
		wellState.Hovered = false
		Restyle(well, 0.18)
	end)
	well.MouseButton1Click:Connect(OpenPicker)
	row.OnClick = OpenPicker
	row:_BindContext(well)

	Picker.DefaultColor, Picker.DefaultTransparency = Picker.Value, Picker.Transparency
	function Picker:_IsDefault()
		return self.Value:ToHex() == self.DefaultColor:ToHex() and self.Transparency == self.DefaultTransparency
	end

	function Picker:_Reset()
		self.Transparency = self.DefaultTransparency
		self:SetValueRGB(self.DefaultColor)
	end

	function Picker:_Text()
		return "#" .. self.Value:ToHex():upper()
	end

	Picker:Display()
	return Register(idx, Picker)
end

Container.AddColorPicker = Container.AddColorpicker

function Container:AddSegmented(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local window = row.Window
	local Segmented = NewElement("Segmented", row, info)
	Segmented.Values = info.Values or {}
	local default = info.Default
	if type(default) == "number" then
		default = Segmented.Values[default]
	end
	Segmented.Value = default or Segmented.Values[1]

	local control = New("Frame", {
		Name = "Segmented",
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		Theme = { BackgroundColor3 = "SegmentBg" },
		Parent = row.Accessory,
	})
	Corner(control, 7)
	local pill = New("Frame", {
		Name = "Selection",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.fromOffset(0, 22),
		Theme = { BackgroundColor3 = "SegmentSelected" },
		Parent = control,
	})
	Corner(pill, 6)
	New("UIStroke", { Color = Color3.new(0, 0, 0), Transparency = 0.9, Parent = pill })
	local items = New("Frame", {
		Name = "Items",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 2,
		Parent = control,
	})
	List(items, Enum.FillDirection.Horizontal, 0)
	Padding(items, 0, 2, 0, 2)

	-- With more options than make sensible segments (a theme list that grew,
	-- say) it shows as a pop-up menu instead. MaxSegments sets how many.
	local maxSegments = math.max(math.floor(tonumber(info.MaxSegments) or 5), 2)
	local menuButton, menuLabel
	local function MenuButton()
		if menuButton then
			return
		end
		menuButton = New("TextButton", {
			Name = "PopupButton",
			Size = UDim2.fromOffset(0, 26),
			AutomaticSize = Enum.AutomaticSize.X,
			Visible = false,
			Parent = row.Accessory,
		})
		List(menuButton, Enum.FillDirection.Horizontal, 7, { VerticalAlignment = Enum.VerticalAlignment.Center })
		menuLabel = New("TextLabel", {
			Name = "Value",
			TextSize = 14,
			Size = UDim2.fromOffset(0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 1,
			Theme = { TextColor3 = "Text" },
			Parent = menuButton,
		})
		New("UISizeConstraint", { MaxSize = Vector2.new(200, 18), Parent = menuLabel })
		local capsule = New("Frame", {
			Name = "Chevrons",
			Size = UDim2.fromOffset(17, 21),
			LayoutOrder = 2,
			Theme = { BackgroundColor3 = "Control" },
			Parent = menuButton,
		})
		Corner(capsule, 5)
		IconImage({
			Icon = "chevrons-up-down",
			IconSize = 12,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Theme = { ImageColor3 = "Text" },
			Parent = capsule,
		})
		menuButton.MouseButton1Click:Connect(function()
			if row.Disabled then
				return
			end
			window:_OpenMenu(menuButton, {
				Values = Segmented.Values,
				MinWidth = math.max(menuButton.AbsoluteSize.X / window:GetAbsoluteScale() + 24, 170),
				IsSelected = function(value)
					return Segmented.Value == value
				end,
				OnPick = function(value)
					Segmented:SetValue(value)
				end,
			})
		end)
	end
	local function UpdateMode()
		local asMenu = #Segmented.Values > maxSegments
		if asMenu then
			MenuButton()
		end
		control.Visible = not asMenu
		if menuButton then
			menuButton.Visible = asMenu
			menuLabel.Text = Segmented.Value ~= nil and tostring(Segmented.Value) or "None"
		end
	end

	local buttons = {}
	local function MovePill(duration)
		local button = buttons[Segmented.Value]
		if not button then
			pill.Visible = false
			return
		end
		pill.Visible = true
		local scale = window:GetAbsoluteScale()
		local x = (button.AbsolutePosition.X - control.AbsolutePosition.X) / scale
		local width = button.AbsoluteSize.X / scale
		local goal = { Position = UDim2.fromOffset(x, 2), Size = UDim2.fromOffset(width, 22) }
		if duration == 0 or pill.Size.X.Offset == 0 then
			pill.Position = goal.Position
			pill.Size = goal.Size
		else
			Tween(pill, goal, duration or 0.25, Enum.EasingStyle.Quint)
		end
	end

	local function Build()
		for _, button in pairs(buttons) do
			button:Destroy()
		end
		table.clear(buttons)
		for index, value in ipairs(Segmented.Values) do
			local button = New("TextButton", {
				Name = tostring(value),
				Text = tostring(value),
				TextSize = 13,
				Weight = Enum.FontWeight.Medium,
				Size = UDim2.fromOffset(0, 26),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = index,
				Theme = { TextColor3 = "Text" },
				Parent = items,
			})
			Padding(button, 0, 14, 0, 14)
			buttons[value] = button
			button.MouseButton1Click:Connect(function()
				if not row.Disabled then
					Segmented:SetValue(value)
				end
			end)
			button:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				if Segmented.Value == value then
					MovePill(0)
				end
			end)
			button:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if Segmented.Value == value then
					MovePill(0)
				end
			end)
		end
		MovePill(0)
		UpdateMode()
	end

	function Segmented:SetValue(value)
		if not table.find(self.Values, value) then
			return
		end
		self.Value = value
		MovePill()
		UpdateMode()
		self:_Emit(value)
	end

	function Segmented:SetValues(values)
		self.Values = values or {}
		if not table.find(self.Values, self.Value) then
			self.Value = self.Values[1]
		end
		Build()
	end

	Segmented.Default = Segmented.Value
	Build()
	return Register(idx, Segmented)
end

Container.AddSegmentedControl = Container.AddSegmented

function Container:AddProgress(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local Progress = NewElement("Progress", row, info)
	Progress.Max = math.max(Finite(info.Max) or 100, 0)
	Progress.Value = math.clamp(tonumber(info.Default or info.Value) or 0, 0, Progress.Max)

	local bar = New("Frame", {
		Name = "Progress",
		Size = UDim2.fromOffset(info.Width or 150, 6),
		LayoutOrder = 1,
		Theme = { BackgroundColor3 = "Track" },
		Parent = row.Accessory,
	})
	Corner(bar, 3)
	local fill = New("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		Theme = { BackgroundColor3 = "Accent" },
		Parent = bar,
	})
	Corner(fill, 3)
	local label = New("TextLabel", {
		Name = "Percent",
		TextSize = 13,
		Size = UDim2.fromOffset(38, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
		LayoutOrder = 2,
		Theme = { TextColor3 = "SubText" },
		Parent = row.Accessory,
	})

	function Progress:SetValue(value)
		self.Value = math.clamp(tonumber(value) or 0, 0, self.Max)
		local alpha = self.Max == 0 and 0 or self.Value / self.Max
		Tween(fill, { Size = UDim2.fromScale(alpha, 1) }, 0.35)
		label.Text = math.floor(alpha * 100 + 0.5) .. "%"
		self:_Emit(self.Value)
	end

	function Progress:_Text()
		return label.Text
	end

	Progress:SetValue(Progress.Value)
	return Register(idx, Progress)
end

Container.AddProgressBar = Container.AddProgress

-- Numeric stepper: [ 12 ] [ − | + ]  (hold a button to repeat)
function Container:AddStepper(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local Stepper = NewElement("Stepper", row, info)
	Stepper.Min = Finite(info.Min) or 0
	Stepper.Max = Finite(info.Max) or 100
	Stepper.Min, Stepper.Max = math.min(Stepper.Min, Stepper.Max), math.max(Stepper.Min, Stepper.Max)
	Stepper.Step = Finite(info.Step or info.Increment) or 1
	Stepper.Rounding = Places(info.Rounding, StepPlaces(Stepper.Step))
	Stepper.Suffix = info.Suffix or ""

	local function Normalize(value)
		return math.clamp(Round(Finite(value) or Stepper.Min, Stepper.Rounding), Stepper.Min, Stepper.Max)
	end
	local function Format(value)
		return string.format("%." .. math.max(Stepper.Rounding, 0) .. "f", value) .. Stepper.Suffix
	end
	Stepper.Value = Normalize(info.Default or Stepper.Min)

	local box = New("TextBox", {
		Name = "Value",
		TextSize = 13,
		Size = UDim2.fromOffset(
			math.max(40,
				math.ceil(math.max(MeasureText(Format(Stepper.Max), 13), MeasureText(Format(Stepper.Min), 13))) + 16),
			24
		),
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 0,
		LayoutOrder = 1,
		Theme = { BackgroundColor3 = "Field", TextColor3 = "Text" },
		Parent = row.Accessory,
	})
	Corner(box, 6)
	local boxStroke = Stroke(box, "FieldStroke")

	local pill = New("Frame", {
		Name = "Stepper",
		Size = UDim2.fromOffset(62, 24),
		LayoutOrder = 2,
		Theme = { BackgroundColor3 = "Button" },
		Parent = row.Accessory,
	})
	Corner(pill, 6)
	Stroke(pill, "ControlStroke", 1, 0.35)
	New("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 1, 1, -10),
		ZIndex = 3,
		Theme = { BackgroundColor3 = "ControlStroke" },
		Parent = pill,
	})

	local halves = {}
	local function Half(direction)
		local state = { Hovered = false, Enabled = true }
		local button = New("TextButton", {
			Name = direction < 0 and "Decrement" or "Increment",
			Position = UDim2.fromScale(direction < 0 and 0 or 0.5, 0),
			Size = UDim2.fromScale(0.5, 1),
			Theme = {
				BackgroundColor3 = "Hover",
				BackgroundTransparency = function(t)
					return (state.Hovered and state.Enabled) and t.HoverTransparency - 0.03 or 1
				end,
			},
			Parent = pill,
		})
		Corner(button, 6)
		local glyph = IconImage({
			Icon = direction < 0 and "minus" or "plus",
			IconSize = 12,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 2,
			Theme = {
				ImageColor3 = function(t)
					return state.Enabled and t.Text or t.Tertiary
				end,
			},
			Parent = button,
		})
		local holdToken = 0
		button.MouseEnter:Connect(function()
			state.Hovered = true
			Restyle(button, 0.1)
		end)
		button.MouseLeave:Connect(function()
			state.Hovered = false
			holdToken = holdToken + (1)
			Restyle(button, 0.15)
		end)
		button.MouseButton1Down:Connect(function()
			if row.Disabled then
				return
			end
			holdToken = holdToken + (1)
			local token = holdToken
			Stepper:SetValue(Stepper.Value + direction * Stepper.Step)
			task.delay(0.4, function()
				while token == holdToken and button.Parent do
					Stepper:SetValue(Stepper.Value + direction * Stepper.Step)
					task.wait(0.07)
				end
			end)
		end)
		button.MouseButton1Up:Connect(function()
			holdToken = holdToken + (1)
		end)
		row:_BindContext(button)
		halves[direction] = {
			State = state,
			Button = button,
			Glyph = glyph,
			StopHold = function()
				holdToken = holdToken + (1)
			end,
		}
	end
	Half(-1)
	Half(1)
	row:Connect(UserInputService.InputEnded, function(input)
		if IsPointer(input) then
			halves[-1].StopHold()
			halves[1].StopHold()
		end
	end)

	local function Render()
		if not box:IsFocused() then
			box.Text = Format(Stepper.Value)
		end
		for direction, half in pairs(halves) do
			half.State.Enabled = direction < 0 and Stepper.Value > Stepper.Min or
			direction > 0 and Stepper.Value < Stepper.Max
			Restyle(half.Button, 0.12)
			Restyle(half.Glyph, 0.12)
		end
	end

	function Stepper:SetValue(value)
		value = Normalize(value)
		local changed = value ~= self.Value
		self.Value = value
		Render()
		if changed then
			self:_Emit(value)
		end
	end

	function Stepper:_Text()
		return Format(self.Value)
	end

	box.Focused:Connect(function()
		box.Text = string.format("%." .. math.max(Stepper.Rounding, 0) .. "f", Stepper.Value)
		Themed(boxStroke, { Color = "Accent" })
	end)
	box.FocusLost:Connect(function()
		MarkActivity()
		Themed(boxStroke, { Color = "FieldStroke" })
		local number = tonumber((box.Text:gsub("[^%d%.%-]", "")))
		if number then
			Stepper:SetValue(number)
		end
		box.Text = Format(Stepper.Value)
	end)

	Stepper.Default = Stepper.Value
	Render()
	Register(idx, Stepper)
	Stepper:_Emit(Stepper.Value)
	return Stepper
end

-- Radio group: the options stack on the right side of the row.
function Container:AddRadio(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local Radio = NewElement("Radio", row, info)
	Radio.Values = info.Values or {}
	local default = info.Default
	if type(default) == "number" then
		default = Radio.Values[default]
	end
	Radio.Value = default or Radio.Values[1]

	local list = New("Frame", {
		Name = "Radio",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = row.Accessory,
	})
	List(list, nil, 6)
	local options = {}

	local function Paint(duration)
		for value, option in pairs(options) do
			option.Selected = Radio.Value == value
			Restyle(option.Circle, duration)
			Restyle(option.Stroke, duration)
			Tween(option.Dot, { Size = option.Selected and UDim2.fromOffset(6, 6) or UDim2.fromOffset(0, 0) },
				duration or 0.2, Enum.EasingStyle.Back)
		end
	end

	local function Build()
		for _, option in pairs(options) do
			option.Button:Destroy()
		end
		table.clear(options)
		for index, value in ipairs(Radio.Values) do
			local option = { Selected = false }
			option.Button = New("TextButton", {
				Name = tostring(value),
				Size = UDim2.fromOffset(0, 20),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = index,
				Parent = list,
			})
			option.Circle = New("Frame", {
				Name = "Circle",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromOffset(16, 16),
				Theme = {
					BackgroundColor3 = function(t)
						return option.Selected and MacUI.Accent or t.Field
					end,
				},
				Parent = option.Button,
			})
			Corner(option.Circle, 8)
			option.Stroke = Stroke(option.Circle, function(t)
				return option.Selected and Darken(MacUI.Accent, 0.15) or t.FieldStroke
			end)
			option.Dot = New("Frame", {
				Name = "Dot",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(0, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = option.Circle,
			})
			Corner(option.Dot, 3)
			New("TextLabel", {
				Name = "Label",
				Text = tostring(value),
				TextSize = 13,
				Position = UDim2.fromOffset(24, 0),
				Size = UDim2.fromOffset(0, 20),
				AutomaticSize = Enum.AutomaticSize.X,
				Theme = { TextColor3 = "Text" },
				Parent = option.Button,
			})
			option.Button.MouseButton1Click:Connect(function()
				if not row.Disabled then
					Radio:SetValue(value)
				end
			end)
			row:_BindContext(option.Button)
			options[value] = option
		end
		local count = #Radio.Values
		row.MinHeight = math.max(44, count * 20 + math.max(count - 1, 0) * 6 + 22)
		row:_UpdateLayout()
		Paint(0)
	end

	function Radio:SetValue(value)
		if not table.find(self.Values, value) then
			return
		end
		self.Value = value
		Paint(0.2)
		self:_Emit(value)
	end

	function Radio:SetValues(values)
		self.Values = values or {}
		if not table.find(self.Values, self.Value) then
			self.Value = self.Values[1]
		end
		Build()
	end

	Radio.Default = Radio.Value
	Build()
	return Register(idx, Radio)
end

Container.AddRadioGroup = Container.AddRadio

-- Monospace block with a copy button, for keys, links and snippets.
function Container:AddCode(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, {
		Title = info.Title,
		Description = info.Description,
		Keywords = info.Keywords,
		Tooltip = info.Tooltip,
		DependsOn = info.DependsOn,
		DependsMode = info.DependsMode,
	}, { TitleWeight = Enum.FontWeight.Medium })
	row.FullWidthText = true
	row.ForceStack = true
	row:_UpdateLayout()
	row:_UpdateReserve()
	local Code = NewElement("Code", row, info)
	Code.Value = tostring(info.Code or info.Content or "")

	New("Frame",
		{ Name = "Gap", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 4), LayoutOrder = 3, Parent = row.Stack })
	local frame = New("Frame", {
		Name = "Code",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 4,
		Theme = { BackgroundColor3 = "Code" },
		Parent = row.Stack,
	})
	Corner(frame, 8)
	Stroke(frame, "FieldStroke")
	Padding(frame, 8, 40, 8, 12)
	-- at least as tall as the copy button, so one line sits in the middle
	local source = New("TextLabel", {
		Name = "Source",
		Text = Code.Value,
		TextSize = 12,
		FontFace = Font.new(MacUI.MonoFamily),
		Size = UDim2.new(1, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Center,
		Theme = { TextColor3 = "Text" },
		Parent = frame,
	})
	FontRegistry[source] = nil -- stays monospace when the UI font changes

	local copyState = { Hovered = false }
	local copy = New("TextButton", {
		Name = "Copy",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 33, 0, 0),
		Size = UDim2.fromOffset(24, 24),
		Theme = {
			BackgroundColor3 = "Hover",
			BackgroundTransparency = function(t)
				return copyState.Hovered and t.HoverTransparency - 0.03 or 1
			end,
		},
		Parent = frame,
	})
	Corner(copy, 6)
	IconImage({
		Icon = "copy",
		IconSize = 14,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Theme = { ImageColor3 = "SubText" },
		Parent = copy,
	})
	copy.MouseEnter:Connect(function()
		copyState.Hovered = true
		Restyle(copy, 0.1)
	end)
	copy.MouseLeave:Connect(function()
		copyState.Hovered = false
		Restyle(copy, 0.15)
	end)
	copy.MouseButton1Click:Connect(function()
		if CopyToClipboard(Code.Value) then
			row.Window:Toast("Copied to Clipboard", { Icon = "clipboard" })
		else
			row.Window:Toast("Clipboard isn’t available", { Icon = "x-circle" })
		end
	end)
	row.Window:_AttachTooltip(copy, "Copy")

	function Code:SetCode(text)
		self.Value = tostring(text or "")
		source.Text = self.Value
	end

	Code.SetValue = Code.SetCode
	function Code:_Text()
		return self.Value
	end

	return Register(idx, Code)
end

-- Full-width picture (banners, previews). Title/Description show underneath.
local function ResolveScaleType(value)
	if typeof(value) == "EnumItem" and value.EnumType == Enum.ScaleType then
		return value
	end
	local ok, item = pcall(function()
		return Enum.ScaleType[tostring(value or "Crop")]
	end)
	return ok and item or Enum.ScaleType.Crop
end

function Container:AddImage(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, {
		Title = info.Title,
		Description = info.Description,
		Keywords = info.Keywords,
		Tooltip = info.Tooltip,
		DependsOn = info.DependsOn,
		DependsMode = info.DependsMode,
	}, { TitleWeight = Enum.FontWeight.Medium })
	row.FullWidthText = true
	row.ForceStack = true
	row:_UpdateLayout()
	row:_UpdateReserve()
	local ImageElement = NewElement("Image", row, info)
	-- The icon set's glyphs are white: tint them (ImageColor, or the text
	-- colour) so they show on a light theme too. Pictures keep their colours.
	local tint = ResolveColor(info.ImageColor)
	local isIcon = false
	local function ResolveImage(value)
		local asset = MacUI:GetIcon(value) or tostring(value or "")
		isIcon = false
		for _, id in pairs(Icons) do
			if id == asset then
				isIcon = true
				break
			end
		end
		return asset
	end
	local image = New("ImageLabel", {
		Name = "Image",
		Image = ResolveImage(info.Image),
		Size = UDim2.new(1, 0, 0, info.Height or 150),
		ScaleType = ResolveScaleType(info.ScaleType),
		BackgroundTransparency = 0,
		LayoutOrder = -2,
		Theme = {
			BackgroundColor3 = "Field",
			ImageColor3 = function(t)
				return tint or (isIcon and t.Text) or Color3.new(1, 1, 1)
			end,
		},
		Parent = row.Stack,
	})
	Corner(image, 8)
	Stroke(image, "FieldStroke")
	if row.Title ~= "" or row.Description ~= "" then
		New("Frame",
			{ Name = "Gap", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 4), LayoutOrder = -1, Parent = row
			.Stack })
	end
	function ImageElement:SetImage(value)
		image.Image = ResolveImage(value)
		Restyle(image, 0)
	end

	function ImageElement:SetHeight(height)
		image.Size = UDim2.new(1, 0, 0, height)
	end

	return Register(idx, ImageElement)
end

-- Shared setup for the full-width rows (graph, table): title and description
-- on top, content underneath.
local function WideRow(container, info)
	local row = CreateRow(container, {
		Title = info.Title,
		Description = info.Description,
		Keywords = info.Keywords,
		Tooltip = info.Tooltip,
		DependsOn = info.DependsOn,
		DependsMode = info.DependsMode,
	}, { TitleWeight = Enum.FontWeight.Medium })
	row.FullWidthText = true
	row.ForceStack = true
	row:_UpdateLayout()
	row:_UpdateReserve()
	New("Frame",
		{ Name = "Gap", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = 3, Parent = row.Stack })
	return row
end

-- Live bar chart (FPS, ping, earnings...). Graph:Push(value) adds a sample;
-- the oldest one scrolls off the left.
function Container:AddGraph(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = WideRow(self, info)
	local Graph = NewElement("Graph", row, info)
	Graph.Points = math.max(math.floor(tonumber(info.Points) or 40), 2)
	Graph.Min = tonumber(info.Min)
	Graph.Max = tonumber(info.Max)
	Graph.Suffix = info.Suffix or ""
	Graph.Rounding = Places(info.Rounding, 0)
	Graph.Values = {}

	local chart = New("Frame", {
		Name = "Graph",
		Size = UDim2.new(1, 0, 0, tonumber(info.Height) or 76),
		ClipsDescendants = true,
		LayoutOrder = 4,
		Theme = { BackgroundColor3 = "Field" },
		Parent = row.Stack,
	})
	Corner(chart, 8)
	Stroke(chart, "FieldStroke")
	local latest = New("TextLabel", {
		Name = "Latest",
		TextSize = 12,
		Weight = Enum.FontWeight.Bold,
		Position = UDim2.fromOffset(10, 4),
		Size = UDim2.new(0.5, -10, 0, 16),
		Theme = { TextColor3 = "Text" },
		Parent = chart,
	})
	local average = New("TextLabel", {
		Name = "Average",
		TextSize = 11,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 4),
		Size = UDim2.new(0.5, -10, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
		Theme = { TextColor3 = "SubText" },
		Parent = chart,
	})
	local plot = New("Frame", {
		Name = "Plot",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 24),
		Size = UDim2.new(1, -16, 1, -30),
		Parent = chart,
	})
	New("Frame", {
		Name = "Midline",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "Separator" },
		Parent = plot,
	})
	local bars = {}
	for index = 1, Graph.Points do
		local bar = New("Frame", {
			Name = "Bar",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new((index - 1) / Graph.Points, 1, 1, 0),
			Size = UDim2.new(1 / Graph.Points, -2, 0, 0),
			Visible = false,
			Theme = {
				BackgroundColor3 = function()
					return ResolveColor(info.Color) or MacUI.Accent
				end,
			},
			Parent = plot,
		})
		Corner(bar, 2)
		bars[index] = bar
	end
	-- 2px between bars, less when there are too many for that (a fixed gap
	-- would leave nothing of the bars)
	local gap = 2
	local function LayoutBars()
		local scale = math.max(row.Window:GetAbsoluteScale(), 0.01)
		local slot = plot.AbsoluteSize.X / scale / Graph.Points
		gap = slot >= 6 and 2 or (slot >= 3 and 1 or 0)
		for index, bar in ipairs(bars) do
			bar.Position = UDim2.new((index - 1) / Graph.Points, gap / 2, 1, 0)
			bar.Size = UDim2.new(1 / Graph.Points, -gap, bar.Size.Y.Scale, 0)
		end
	end
	plot:GetPropertyChangedSignal("AbsoluteSize"):Connect(LayoutBars)

	local function Format(value)
		return string.format("%." .. math.max(Graph.Rounding, 0) .. "f", value) .. Graph.Suffix
	end
	local function Render()
		local values = Graph.Values
		local count = #values
		local low, high = Graph.Min, Graph.Max
		local sum, lowest, highest = 0, 0, nil
		for _, value in ipairs(values) do
			sum = sum + (value)
			lowest = math.min(lowest, value)
			highest = math.max(highest or value, value)
		end
		-- automatic scale: from zero (or the lowest value) to a little above the
		-- highest, so the tallest bar doesn't touch the labels
		low = low or lowest
		if not high then
			high = highest and highest + (highest - low) * 0.15 or low + 1
		end
		if high <= low then
			high = low + 1
		end
		for index, bar in ipairs(bars) do
			local value = values[count - Graph.Points + index] -- newest on the right
			if value then
				local alpha = math.clamp((value - low) / (high - low), 0, 1)
				bar.Size = UDim2.new(1 / Graph.Points, -gap, math.max(alpha, 0.03), 0)
				-- older samples fade a little so the latest reads first
				bar.BackgroundTransparency = 0.5 * (1 - index / Graph.Points)
				bar.Visible = true
			else
				bar.Visible = false
			end
		end
		latest.Text = count > 0 and Format(values[count]) or "—"
		average.Text = count > 0 and ("avg " .. Format(sum / count)) or ""
	end

	function Graph:Push(value)
		value = Finite(value) -- (NaN or infinity would break the scale)
		if not value then
			return
		end
		table.insert(self.Values, value)
		while #self.Values > self.Points do
			table.remove(self.Values, 1)
		end
		self.Value = value
		Render()
	end

	Graph.SetValue = Graph.Push
	function Graph:SetValues(values)
		self.Values = {}
		for _, value in ipairs(values or {}) do
			if Finite(value) then
				table.insert(self.Values, Finite(value))
			end
		end
		while #self.Values > self.Points do
			table.remove(self.Values, 1)
		end
		self.Value = self.Values[#self.Values]
		Render()
	end

	function Graph:Clear()
		self:SetValues({})
	end

	-- Fixes the vertical scale; nil for automatic.
	function Graph:SetRange(min, max)
		self.Min, self.Max = tonumber(min), tonumber(max)
		Render()
	end

	function Graph:_Text()
		return self.Value and Format(self.Value) or nil
	end

	Graph:SetValues(info.Values)
	return Register(idx, Graph)
end

Container.AddChart = Container.AddGraph

local TABLE_ALIGN = {
	Left = Enum.TextXAlignment.Left,
	Center = Enum.TextXAlignment.Center,
	Right = Enum.TextXAlignment.Right,
}

-- Sortable table: players, logs, stats. Columns are names or
-- { Title, Width, Align = "Left" | "Center" | "Right", Key }, where Width is a
-- share relative to the other columns (default 1); rows are arrays in column
-- order or tables keyed by column title (or Key). Clicking a row selects it:
-- Table.Value is the row, and Callback(row, index) fires.
function Container:AddTable(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = WideRow(self, info)
	local Table = NewElement("Table", row, info)
	local rowHeight, headerHeight = 26, 26
	Table.MaxRows = math.max(math.floor(tonumber(info.MaxRows) or 6), 1)
	Table.Rows = {}
	Table.Value = nil
	Table.SelectedIndex = nil

	local columns, total = {}, 0
	for index, spec in ipairs(info.Columns or { "Name" }) do
		if type(spec) ~= "table" then
			spec = { Title = tostring(spec) }
		end
		local column = {
			Index = index,
			Title = tostring(spec.Title or ("Column " .. index)),
			Key = spec.Key,
			Weight = math.max(tonumber(spec.Width) or 1, 0.05),
			Align = TABLE_ALIGN[spec.Align] or (typeof(spec.Align) == "EnumItem" and spec.Align) or
			Enum.TextXAlignment.Left,
		}
		total = total + (column.Weight)
		columns[index] = column
	end
	local offset = 0
	for _, column in ipairs(columns) do
		column.Scale = column.Weight / total
		column.X = offset
		offset = offset + (column.Scale)
	end
	Table.Columns = columns

	local function Cell(data, column)
		if type(data) ~= "table" then
			return column.Index == 1 and data or nil
		end
		local value = data[column.Index]
		if value == nil then
			value = data[column.Key or column.Title]
		end
		return value
	end

	local frame = New("Frame", {
		Name = "Table",
		Size = UDim2.new(1, 0, 0, headerHeight + rowHeight),
		ClipsDescendants = true,
		LayoutOrder = 4,
		Theme = { BackgroundColor3 = "Field" },
		Parent = row.Stack,
	})
	Corner(frame, 8)
	Stroke(frame, "FieldStroke")
	local header = New("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, headerHeight),
		Parent = frame,
	})
	New("Frame", {
		Name = "Rule",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "Separator" },
		Parent = header,
	})
	local body = New("ScrollingFrame", {
		Name = "Rows",
		Position = UDim2.fromOffset(0, headerHeight),
		Size = UDim2.new(1, 0, 1, -headerHeight),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.4,
		Theme = { ScrollBarImageColor3 = "Scrollbar" },
		Parent = frame,
	})
	List(body, nil, 0)
	local empty = New("TextLabel", {
		Name = "Empty",
		Text = info.EmptyText or "No items",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, rowHeight),
		LayoutOrder = 0,
		Theme = { TextColor3 = "SubText" },
		Parent = body,
	})

	local sortColumn, sortDescending = nil, false
	local headerLabels = {}
	local entries = {}
	-- when each row was added, so sorting is stable and can be undone
	local sequence, nextSequence = {}, 0

	local function Selected(entry)
		return Table.SelectedIndex == entry.Index
	end

	local function Paint(entry, duration)
		Restyle(entry.Button, duration or 0.1)
		for _, label in ipairs(entry.Labels) do
			Restyle(label, duration or 0.1)
		end
	end

	local function MakeEntry(index)
		local entry = { Index = index, Hovered = false, Labels = {} }
		entry.Button = New("TextButton", {
			Name = "Row",
			Size = UDim2.new(1, 0, 0, rowHeight),
			LayoutOrder = index,
			Theme = {
				BackgroundColor3 = function(t)
					return Selected(entry) and MacUI.Accent or t.Hover
				end,
				BackgroundTransparency = function(t)
					if Selected(entry) then
						return 0
					elseif entry.Hovered then
						return t.HoverTransparency - 0.02
					end
					return entry.Index % 2 == 0 and math.min(t.HoverTransparency + 0.025, 1) or 1
				end,
			},
			Parent = body,
		})
		for _, column in ipairs(columns) do
			table.insert(entry.Labels, New("TextLabel", {
				Text = "",
				TextSize = 13,
				TextXAlignment = column.Align,
				Position = UDim2.new(column.X, 10, 0, 0),
				Size = UDim2.new(column.Scale, -20, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Theme = {
					TextColor3 = function(t)
						if Selected(entry) then
							return t.SelectionText
						end
						return column.Index == 1 and t.Text or t.SubText
					end,
				},
				Parent = entry.Button,
			}))
		end
		entry.Button.MouseEnter:Connect(function()
			entry.Hovered = true
			Paint(entry)
		end)
		entry.Button.MouseLeave:Connect(function()
			entry.Hovered = false
			Paint(entry)
		end)
		entry.Button.MouseButton1Click:Connect(function()
			if not row.Disabled then
				Table:Select(entry.Index)
			end
		end)
		row:_BindContext(entry.Button)
		return entry
	end

	-- Shows the rows, reusing the ones already on screen (a live list can
	-- change every second).
	local function Render()
		for index, data in ipairs(Table.Rows) do
			local entry = entries[index]
			if not entry then
				entry = MakeEntry(index)
				entries[index] = entry
			end
			for columnIndex, column in ipairs(columns) do
				local value = Cell(data, column)
				local text = value == nil and "" or tostring(value)
				local label = entry.Labels[columnIndex]
				if label.Text ~= text then
					label.Text = text
				end
			end
			Paint(entry, 0) -- (the selection may have moved)
		end
		for index = #entries, #Table.Rows + 1, -1 do
			entries[index].Button:Destroy()
			entries[index] = nil
		end
		empty.Visible = #Table.Rows == 0
		local shown = math.clamp(#Table.Rows, 1, Table.MaxRows)
		frame.Size = UDim2.new(1, 0, 0, headerHeight + shown * rowHeight)
		for _, column in ipairs(columns) do
			local label = headerLabels[column.Index]
			local arrow = sortColumn == column and (sortDescending and "  ↓" or "  ↑") or ""
			label.Text = column.Title .. arrow
			Restyle(label, 0.1)
		end
	end

	-- Numbers, and text that is a number ("10"), sort by value and before
	-- other text; text ignores case.
	local function SortKey(value)
		if type(value) == "number" then
			return value == value and value or "nan"
		end
		local text = value == nil and "" or tostring(value)
		local number = tonumber(text)
		if number and number == number then
			return number
		end
		return text:lower()
	end
	local function Before(a, b)
		local x, y = SortKey(a), SortKey(b)
		local numberX, numberY = type(x) == "number", type(y) == "number"
		if numberX ~= numberY then
			return numberX
		end
		return x < y
	end

	-- Puts the rows in order (the sort, else the order they were added in),
	-- keeping the selected row selected.
	local function Arrange()
		local order = {}
		for index, data in ipairs(Table.Rows) do
			order[index] = { Data = data, Sequence = sequence[index], Index = index }
		end
		table.sort(order, function(a, b)
			if sortColumn then
				local x, y = Cell(a.Data, sortColumn), Cell(b.Data, sortColumn)
				if sortDescending then
					x, y = y, x
				end
				if Before(x, y) then
					return true
				elseif Before(y, x) then
					return false
				end
			end
			return a.Sequence < b.Sequence
		end)
		local selected = Table.SelectedIndex
		Table.SelectedIndex = nil
		for index, item in ipairs(order) do
			Table.Rows[index] = item.Data
			sequence[index] = item.Sequence
			if item.Index == selected then
				Table.SelectedIndex = index
			end
		end
		Table.Value = Table.SelectedIndex and Table.Rows[Table.SelectedIndex] or nil
	end

	-- Sorts by a column (its title, index or table); nil goes back to the
	-- order the rows were added in.
	function Table:SortBy(column, descending)
		if column ~= nil and type(column) ~= "table" then
			local found
			for _, candidate in ipairs(columns) do
				if candidate.Title == column or candidate.Index == column then
					found = candidate
					break
				end
			end
			if not found then
				return
			end
			column = found
		end
		sortColumn, sortDescending = column, column ~= nil and descending == true
		Arrange()
		Render()
	end

	for _, column in ipairs(columns) do
		local label = New("TextButton", {
			Name = "Column",
			Text = column.Title,
			TextSize = 11,
			Weight = Enum.FontWeight.Medium,
			TextXAlignment = column.Align,
			Position = UDim2.new(column.X, 10, 0, 0),
			Size = UDim2.new(column.Scale, -20, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Theme = {
				TextColor3 = function(t)
					return sortColumn == column and t.Text or t.SubText
				end,
			},
			Parent = header,
		})
		headerLabels[column.Index] = label
		-- up, down, then back to the order they were added in
		label.MouseButton1Click:Connect(function()
			if info.Sortable == false then
				return
			end
			if sortColumn ~= column then
				Table:SortBy(column, false)
			elseif not sortDescending then
				Table:SortBy(column, true)
			else
				Table:SortBy(nil)
			end
		end)
	end

	-- Selects a row (its index, or the row itself); nil clears the selection.
	function Table:Select(target)
		local index
		if type(target) == "number" then
			index = self.Rows[target] ~= nil and target or nil
		elseif target ~= nil then
			index = table.find(self.Rows, target)
		end
		self.SelectedIndex = index
		self.Value = index and self.Rows[index] or nil
		for _, entry in ipairs(entries) do
			Paint(entry)
		end
		self:_Emit(self.Value, self.SelectedIndex)
	end

	Table.SetValue = Table.Select

	function Table:SetRows(rows)
		local previous = self.Value
		self.Rows, sequence = {}, {}
		for _, data in ipairs(rows or {}) do
			nextSequence = nextSequence + (1)
			table.insert(self.Rows, data)
			table.insert(sequence, nextSequence)
		end
		-- the same row stays selected if it's still there
		self.SelectedIndex = previous ~= nil and table.find(self.Rows, previous) or nil
		Arrange()
		Render()
	end

	function Table:AddRow(data)
		nextSequence = nextSequence + (1)
		table.insert(self.Rows, data)
		table.insert(sequence, nextSequence)
		Arrange()
		Render()
		return data
	end

	function Table:RemoveRow(target)
		local index = type(target) == "number" and target or table.find(self.Rows, target)
		if not index or self.Rows[index] == nil then
			return
		end
		table.remove(self.Rows, index)
		table.remove(sequence, index)
		if self.SelectedIndex == index then
			self.SelectedIndex = nil
		elseif self.SelectedIndex and self.SelectedIndex > index then
			self.SelectedIndex = self.SelectedIndex - (1)
		end
		self.Value = self.SelectedIndex and self.Rows[self.SelectedIndex] or nil
		Render()
	end

	function Table:Clear()
		self:SetRows({})
	end

	function Table:GetSelected()
		return self.Value, self.SelectedIndex
	end

	function Table:_Text()
		if self.Value == nil then
			return nil
		end
		local parts = {}
		for _, column in ipairs(columns) do
			local value = Cell(self.Value, column)
			table.insert(parts, value == nil and "" or tostring(value))
		end
		return table.concat(parts, ", ")
	end

	Table:SetRows(info.Rows)
	if info.SortBy then
		Table:SortBy(info.SortBy, info.Descending)
	end
	return Register(idx, Table)
end

Container.AddList = Container.AddTable

local function SectionTitle(row)
	local block = row.Group and row.Group.Block
	return block and block.Title and tostring(block.Title) or ""
end

-- How a macro step finds its control again: by index, or else by page,
-- section, title and which of any same-titled controls it is.
local function MacroKey(element)
	if element.Idx ~= nil then
		return { i = element.Idx }
	end
	local row = element.Row
	local tab = row and row.Tab
	local section = row and SectionTitle(row) or ""
	local title = tostring(element.Title or "")
	local nth = 0
	for _, other in ipairs(tab and tab.Rows or {}) do
		if other.Element and tostring(other.Element.Title or "") == title and SectionTitle(other) == section then
			nth = nth + (1)
			if other == row then
				break
			end
		end
	end
	return { t = tab and tab.Title or "", s = section, n = title, k = math.max(nth, 1) }
end

local function FindMacroTarget(step)
	if step.i ~= nil then
		return MacUI.Options[step.i]
	end
	local tabTitle, section, title = step.t, step.s, step.n
	local nth = tonumber(step.k) or 1
	if tabTitle == nil and step.p then
		tabTitle, title = tostring(step.p):match("^(.*)/(.-)$") -- older "Page/Title" keys
	end
	if tabTitle == nil or title == nil then
		return nil
	end
	for _, window in ipairs(MacUI.Windows) do
		for _, tab in ipairs(window.Tabs or {}) do
			if tab.Title == tabTitle then
				local seen = 0
				for _, row in ipairs(tab.Rows) do
					local element = row.Element
					if element and tostring(element.Title or "") == title and (section == nil or SectionTitle(row) == section) then
						seen = seen + (1)
						if seen == nth then
							return element
						end
					end
				end
			end
		end
	end
	return nil
end

local function EncodeSnapshot(element, snapshot)
	if snapshot == NIL_VALUE then
		return { none = true }
	elseif element.Type == "Colorpicker" then
		return { color = snapshot.Color:ToHex(), alpha = snapshot.Transparency }
	elseif element.Type == "Keybind" then
		return { key = snapshot.Key, mode = snapshot.Mode }
	end
	return snapshot -- a boolean, number, string or list (multi-select)
end

local function DecodeSnapshot(element, value)
	if type(value) == "table" and value.none == true then
		return NIL_VALUE
	elseif element.Type == "Colorpicker" then
		local ok, color = pcall(Color3.fromHex, tostring(type(value) == "table" and value.color or ""))
		return ok and { Color = color, Transparency = value.alpha } or nil
	elseif element.Type == "Keybind" then
		return type(value) == "table" and { Key = value.key, Mode = value.mode } or nil
	end
	return value
end

--[[
	Records what the user changes and presses, then plays it back with the
	same timing, once or on a loop.

	local Routine = Section:AddMacro("Routine", { Title = "Farming routine", Loop = false, Speed = 1 })
	Routine:Record()  Routine:StopRecording()  Routine:Play()  Routine:Stop()
	Routine:SetLoop(true)  Routine:SetSpeed(2)  Routine:Clear()
	Routine:Export() -> table   Routine:Import(table)   (SaveManager saves it)
]]
function Container:AddMacro(idx, info)
	idx, info = ParseArgs(idx, info)
	local row = CreateRow(self, info)
	local Macro = NewElement("Macro", row, info)
	Macro.Steps = {}
	Macro.Value = 0
	Macro.Loop = info.Loop == true
	Macro.Speed = math.clamp(tonumber(info.Speed) or 1, 0.1, 10)
	Macro.Recording = false
	Macro.Playing = false
	Macro.NoCopy = true
	local baseDescription = info.Description and tostring(info.Description) or nil
	local playToken = 0

	local function RoundButton(order)
		local state = { Hovered = false }
		local button = New("TextButton", {
			Name = "MacroButton",
			Size = UDim2.fromOffset(26, 26),
			LayoutOrder = order,
			Theme = {
				BackgroundColor3 = function(t)
					return state.Hovered and t.ButtonHover or t.Button
				end,
			},
			Parent = row.Accessory,
		})
		Corner(button, 13)
		Stroke(button, "ControlStroke", 1, 0.35)
		button.MouseEnter:Connect(function()
			state.Hovered = true
			Restyle(button, 0.12)
		end)
		button.MouseLeave:Connect(function()
			state.Hovered = false
			Restyle(button, 0.18)
		end)
		row:_BindContext(button)
		return button
	end

	local recordButton = RoundButton(1)
	recordButton.Name = "Record"
	local recordDot = New("Frame", {
		Name = "Dot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		Theme = { BackgroundColor3 = "Destructive" },
		Parent = recordButton,
	})
	local recordCorner = Corner(recordDot, 5)
	local playButton = RoundButton(2)
	playButton.Name = "Play"
	local playIcon = IconImage({
		Name = "Icon",
		Icon = "play",
		IconSize = 12,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 1, 0.5, 0),
		Theme = {
			ImageColor3 = function(t)
				return #Macro.Steps > 0 and t.Text or t.Tertiary
			end,
		},
		Parent = playButton,
	})
	local stopSquare = New("Frame", {
		Name = "Stop",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(9, 9),
		Visible = false,
		Theme = { BackgroundColor3 = "Text" },
		Parent = playButton,
	})
	Corner(stopSquare, 2)
	row.Window:_AttachTooltip(recordButton, function()
		return Macro.Recording and "Stop recording" or "Record"
	end)
	row.Window:_AttachTooltip(playButton, function()
		return Macro.Playing and "Stop" or (#Macro.Steps > 0 and "Play" or "Record something first")
	end)

	local function Render()
		recordCorner.CornerRadius = UDim.new(0, Macro.Recording and 2 or 5)
		Tween(recordDot, { Size = Macro.Recording and UDim2.fromOffset(9, 9) or UDim2.fromOffset(10, 10) }, 0.15)
		playIcon.Visible = not Macro.Playing
		stopSquare.Visible = Macro.Playing
		Restyle(playIcon, 0.15)
	end

	local function Plural(count, word)
		return count .. " " .. word .. (count == 1 and "" or "s")
	end

	local function UpdateStatus()
		local text
		if Macro.Recording then
			text = "Recording: change settings or press buttons. " ..
			Plural(#(Macro._pending or {}), "step") .. " so far."
		elseif Macro.Playing then
			text = ("Playing step %d of %d"):format(Macro.Position or 1, #Macro.Steps)
				.. ((Macro.Run or 1) > 1 and (" · run " .. Macro.Run) or "")
		elseif #Macro.Steps > 0 then
			text = Plural(#Macro.Steps, "step") .. " · " .. DescribeDuration(math.max(Macro:GetDuration(), 1))
				.. (Macro.Loop and " · loops" or "")
		else
			text = baseDescription or "Press record, change some settings, then stop. Play repeats them."
		end
		row:SetDesc(text)
	end

	local function SetState(state)
		RunCallback(Macro, info.Callback, state)
	end

	local function Changed()
		Macro.Value = #Macro.Steps
		if Macro.Idx ~= nil then
			MacUI.OptionChanged:Fire(Macro.Idx, Macro.Value, Macro)
		end
	end

	function Macro:GetDuration()
		local total = 0
		for _, step in ipairs(self.Steps) do
			total = total + (step.Delay)
		end
		return total
	end

	function Macro:Record()
		if self.Recording or row.Destroyed then
			return
		end
		if self.Playing then
			self:Stop()
		end
		if Macros.Recorder and Macros.Recorder ~= self then
			Macros.Recorder:StopRecording()
		end
		self.Recording = true
		self._pending = {}
		self._last = os.clock()
		Macros.Recorder = self
		row.Window:_SetRecording(self)
		Render()
		UpdateStatus()
		SetState("Recording")
	end

	function Macro:_Capture(element, snapshot)
		if element == self or element.Type == "Macro" or not self.Recording then
			return
		end
		local now = os.clock()
		local steps = self._pending
		local last = steps[#steps]
		if last and last.Element == element and not last.Button and now - self._last < 0.4 then
			last.Snapshot = snapshot -- a drag or quick typing: keep where it ended
		else
			table.insert(steps, { Delay = now - self._last, Element = element, Snapshot = snapshot })
		end
		self._last = now
		row.Window:_SetRecording(self)
		UpdateStatus()
	end

	function Macro:_CaptureButton(button)
		if not self.Recording then
			return
		end
		local now = os.clock()
		table.insert(self._pending, { Delay = now - self._last, Element = button, Button = true })
		self._last = now
		row.Window:_SetRecording(self)
		UpdateStatus()
	end

	function Macro:StopRecording(silent)
		if not self.Recording then
			return
		end
		self.Recording = false
		if Macros.Recorder == self then
			Macros.Recorder = nil
		end
		row.Window:_SetRecording(nil)
		local steps = self._pending or {}
		self._pending = nil
		if #steps > 0 then
			-- the pause before the first change isn't part of the routine
			steps[1].Delay = math.min(steps[1].Delay, 0.3)
			self.Steps = steps
			Changed()
		elseif not row.Destroyed and not silent then
			row.Window:Toast("Nothing recorded", { Detail = "change a setting while recording", Icon = "circle-dot" })
		end
		Render()
		UpdateStatus()
		SetState("Idle")
	end

	local function ApplyStep(step)
		local element = step.Element
		if not element or (element.Row and element.Row.Destroyed) then
			return
		end
		if step.Button then
			AutomationApply(element.Fire, element)
		elseif step.Snapshot ~= nil then
			AutomationApply(RestoreSnapshot, element, step.Snapshot)
		end
	end

	-- Plays the recording; options { Loop, Speed } override the macro's own.
	function Macro:Play(options)
		if self.Recording then
			self:StopRecording()
		end
		if self.Playing or #self.Steps == 0 or row.Destroyed then
			return false
		end
		options = options or {}
		local loop = options.Loop
		if loop == nil then
			loop = self.Loop
		end
		-- read on every step, so SetLoop / SetSpeed apply to a playback in progress
		self._loop = loop
		self._speed = math.clamp(tonumber(options.Speed) or self.Speed, 0.1, 10)
		self.Playing = true
		self.Run = 1
		self.Position = 1
		playToken = playToken + (1)
		local token = playToken
		local steps = self.Steps
		task.spawn(function()
			local run = 0
			repeat
				run = run + (1)
				self.Run = run
				for index, step in ipairs(steps) do
					self.Position = index
					UpdateStatus()
					if step.Delay > 0 then
						task.wait(step.Delay / self._speed)
					end
					if token ~= playToken or MacUI.Unloaded or row.Destroyed then
						return
					end
					ApplyStep(step)
				end
				-- always yield between runs, even for a recording with no pauses
				task.wait(math.max(0.25 / self._speed, 0.03))
			until not self._loop or token ~= playToken or MacUI.Unloaded or row.Destroyed
			if token == playToken and not row.Destroyed then
				self.Playing = false
				Render()
				UpdateStatus()
				SetState("Idle")
			end
		end)
		Render()
		SetState("Playing")
		return true
	end

	-- Stops recording or playback.
	function Macro:Stop()
		if self.Recording then
			self:StopRecording()
			return
		end
		if self.Playing then
			playToken = playToken + (1)
			self.Playing = false
			Render()
			UpdateStatus()
			SetState("Idle")
		end
	end

	function Macro:Clear()
		self:Stop()
		self.Steps = {}
		Changed()
		Render()
		UpdateStatus()
	end

	function Macro:SetLoop(loop)
		self.Loop = loop == true
		self._loop = self.Loop
		UpdateStatus()
		Changed()
	end

	function Macro:SetSpeed(speed)
		self.Speed = math.clamp(tonumber(speed) or 1, 0.1, 10)
		self._speed = self.Speed
		Changed()
	end

	function Macro:Destroy()
		if self.Recording then
			self:StopRecording(true)
		end
		self:Stop()
		ElementBase.Destroy(self)
	end

	-- A plain table (JSON-safe) with the steps, loop and speed.
	function Macro:Export()
		local steps = {}
		for _, step in ipairs(self.Steps) do
			local element = step.Element
			if element and not (element.Row and element.Row.Destroyed) then
				local entry = MacroKey(element)
				entry.d = math.floor(step.Delay * 1000 + 0.5) / 1000
				if step.Button then
					entry.b = true
				else
					entry.v = EncodeSnapshot(element, step.Snapshot)
				end
				table.insert(steps, entry)
			end
		end
		return { v = 1, loop = self.Loop, speed = self.Speed, steps = steps }
	end

	-- Loads steps from Export(). Steps whose control no longer exists are skipped.
	function Macro:Import(data)
		if type(data) ~= "table" or type(data.steps) ~= "table" then
			return false
		end
		self:Stop()
		local steps = {}
		for _, entry in ipairs(data.steps) do
			local element = type(entry) == "table" and FindMacroTarget(entry)
			if element then
				local step = { Delay = math.max(tonumber(entry.d) or 0, 0), Element = element }
				if entry.b then
					step.Button = element.Type == "Button"
				else
					step.Snapshot = DecodeSnapshot(element, entry.v)
				end
				if step.Button or step.Snapshot ~= nil then
					table.insert(steps, step)
				end
			end
		end
		self.Steps = steps
		if data.loop ~= nil then
			self.Loop = data.loop == true
		end
		if tonumber(data.speed) then
			self.Speed = math.clamp(tonumber(data.speed), 0.1, 10)
		end
		Changed()
		Render()
		UpdateStatus()
		return true
	end

	function Macro:_Text()
		if self.Recording then
			return "Recording"
		elseif self.Playing then
			return "Playing"
		end
		return #self.Steps > 0 and Plural(#self.Steps, "step") or nil
	end

	-- Spotlight and keyboard shortcuts: play, or stop whatever is running.
	function Macro:_Activate(announce)
		if row.Disabled then
			return
		end
		NoteUsage(UsageKey(self))
		local window = row.Window
		if self.Recording then
			self:StopRecording()
		elseif self.Playing then
			self:Stop()
			if announce then
				window:Toast(self.Title or "Macro", { Detail = "Stopped", Icon = "square" })
			end
		elseif #self.Steps > 0 then
			self:Play()
			if announce then
				window:Toast(self.Title or "Macro", { Detail = "Playing", Icon = "play", Highlight = true })
			end
		else
			window:Toast("Nothing recorded yet", { Icon = "circle-dot" })
		end
	end

	function Macro:_ContextItems()
		return {
			"-",
			{
				Text = self.Recording and "Stop Recording" or (#self.Steps > 0 and "Record Again" or "Record"),
				Icon = "circle-dot",
				Disabled = row.Disabled,
				Callback = function()
					if self.Recording then
						self:StopRecording()
					else
						self:Record()
					end
				end,
			},
			{
				Text = self.Loop and "Stop Looping" or "Loop Playback",
				Icon = "repeat",
				Callback = function()
					self:SetLoop(not self.Loop)
				end,
			},
			{
				Text = "Clear Recording",
				Icon = "trash-2",
				Destructive = true,
				Disabled = #self.Steps == 0 or self.Recording,
				Callback = function()
					self:Clear()
				end,
			},
		}
	end

	recordButton.MouseButton1Click:Connect(function()
		if row.Disabled then
			return
		end
		if Macro.Recording then
			Macro:StopRecording()
		else
			Macro:Record()
		end
	end)
	playButton.MouseButton1Click:Connect(function()
		if row.Disabled then
			return
		end
		if Macro.Playing then
			Macro:Stop()
		elseif #Macro.Steps > 0 then
			NoteUsage(UsageKey(Macro))
			Macro:Play()
		else
			row.Window:Toast("Nothing recorded yet", { Detail = "press record first", Icon = "circle-dot" })
		end
	end)

	Render()
	UpdateStatus()
	Register(idx, Macro)
	if info.Shortcut then
		Macro:SetShortcut(info.Shortcut)
	end
	return Macro
end

--------------------------------------------------------------------------------
-- Groups, sections and tabs
--------------------------------------------------------------------------------

local GroupMethods = {}
GroupMethods.__index = GroupMethods

local function CreateGroup(tab, block)
	local group = setmetatable({ Tab = tab, Block = block, Rows = {}, Order = 0 }, GroupMethods)
	group.Frame = New("Frame", {
		Name = "Group",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = tab:_NextOrder(),
		Visible = false,
		Theme = { BackgroundColor3 = "Group" },
		Parent = tab.Content,
	})
	Corner(group.Frame, 10)
	Stroke(group.Frame, "GroupStroke")
	List(group.Frame, nil, 0)
	return group
end

function GroupMethods:Refresh()
	local first = true
	for _, row in ipairs(self.Rows) do
		if row.Frame.Visible then
			row.Separator.Visible = not first
			first = false
		end
	end
	local visible = not first
	-- a collapsed section keeps its header; searching shows its matches anyway
	local collapsed = self.Block.Collapsed == true and (self.Tab.SearchQuery or "") == ""
	self.Frame.Visible = visible and not collapsed
	if self.Block.Header then
		self.Block.Header.Visible = visible
	end
	self.Tab:_RefreshSpacers()
end

local TabMethods = setmetatable({}, { __index = Container })
TabMethods.__index = TabMethods

local SectionMethods = setmetatable({}, { __index = Container })
SectionMethods.__index = SectionMethods

function TabMethods:_NextOrder()
	self.Order = self.Order + (1)
	return self.Order
end

function TabMethods:_NewBlock(spacing)
	local block = {}
	block.Spacer = New("Frame", {
		Name = "Spacer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, spacing),
		LayoutOrder = self:_NextOrder(),
		Parent = self.Content,
	})
	block.Spacing = spacing
	table.insert(self.Blocks, block)
	return block
end

function TabMethods:_RefreshSpacers()
	local first = true
	for _, block in ipairs(self.Blocks) do
		local visible = (block.Group and (block.Group.Frame.Visible or (block.Header ~= nil and block.Header.Visible)))
			or (block.Hero ~= nil and block.Hero.Visible)
		block.Spacer.Visible = visible and not first
		if visible then
			first = false
		end
	end
end

function TabMethods:_GetGroup()
	if not self.CurrentGroup then
		local block = self:_NewBlock(16)
		block.Group = CreateGroup(self, block)
		self.CurrentGroup = block.Group
	end
	return self.CurrentGroup
end

function TabMethods:AddSection(info)
	if type(info) ~= "table" then
		info = { Title = tostring(info or "") }
	end
	local window = self.Window
	local block = self:_NewBlock(22)
	local header = New("Frame", {
		Name = "SectionHeader",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self:_NextOrder(),
		Visible = false,
		Parent = self.Content,
	})
	Padding(header, 0, 12, 8, 12)
	List(header, nil, 2)
	local titleRow = New("Frame", {
		Name = "TitleRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 1,
		Parent = header,
	})
	local offset = 0
	if info.Icon and MacUI:GetIcon(info.Icon) then
		IconImage({
			Name = "Icon",
			Icon = info.Icon,
			IconSize = 16,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Theme = {
				ImageColor3 = info.IconColor and function()
					return ResolveColor(info.IconColor)
				end or "Accent"
			},
			Parent = titleRow,
		})
		offset = 22
	end
	local titleLabel = New("TextLabel", {
		Name = "Title",
		Text = info.Title or "",
		TextSize = 15,
		Weight = Enum.FontWeight.Bold,
		Position = UDim2.fromOffset(offset, 0),
		Size = UDim2.new(1, -offset, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "Text" },
		Parent = titleRow,
	})
	local descLabel = New("TextLabel", {
		Name = "Description",
		Text = info.Description or "",
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		RichText = true,
		LayoutOrder = 2,
		Visible = (info.Description or "") ~= "",
		Theme = { TextColor3 = "SubText" },
		Parent = header,
	})
	block.Header = header
	block.Title = info.Title
	block.SearchText = ((info.Title or "") .. " " .. (info.Description or "")):lower()
	block.Collapsible = info.Collapsible == true
	block.Collapsed = block.Collapsible and info.Collapsed == true
	local disclosure
	if block.Collapsible then
		-- macOS disclosure chevron: click the title to show or hide the group
		disclosure = IconImage({
			Name = "Disclosure",
			Icon = "chevron-right",
			IconSize = 14,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Rotation = block.Collapsed and 0 or 90,
			Theme = { ImageColor3 = "SubText" },
			Parent = titleRow,
		})
		titleLabel.Size = UDim2.new(1, -offset - 22, 1, 0)
		New("TextButton", { Name = "Toggle", Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = titleRow })
			.MouseButton1Click:Connect(function()
			block.Section:SetCollapsed(not block.Collapsed)
		end)
	end
	block.Group = CreateGroup(self, block)
	self.CurrentGroup = nil

	local section = setmetatable({
		Window = window,
		Tab = self,
		Title = info.Title,
		Block = block,
		Group = block.Group,
		Collapsed = block.Collapsed,
	}, SectionMethods)
	block.Section = section
	-- Collapsible sections only. Search results and Window:Reveal open them.
	function section:SetCollapsed(collapsed)
		if not block.Collapsible then
			return
		end
		block.Collapsed = collapsed == true
		self.Collapsed = block.Collapsed
		Tween(disclosure, { Rotation = block.Collapsed and 0 or 90 }, 0.2)
		block.Group:Refresh()
	end

	function section:SetTitle(text)
		self.Title = text
		block.Title = tostring(text)
		titleLabel.Text = tostring(text)
		block.SearchText = (tostring(text) .. " " .. descLabel.Text):lower()
	end

	function section:SetDesc(text)
		descLabel.Text = tostring(text or "")
		descLabel.Visible = descLabel.Text ~= ""
		block.SearchText = (titleLabel.Text .. " " .. descLabel.Text):lower()
	end

	return section
end

function SectionMethods:_GetGroup()
	return self.Group
end

function TabMethods:_ApplySearch(query)
	self.SearchQuery = query
	local count = 0
	if self.Hero then
		self.Hero.Visible = query == ""
	end
	for _, block in ipairs(self.Blocks) do
		if block.Group then
			local sectionHit = query ~= "" and block.SearchText ~= nil and block.SearchText:find(query, 1, true) ~= nil
			for _, row in ipairs(block.Group.Rows) do
				row.SearchMatch = query == "" or sectionHit or row:_Matches(query)
				row.Frame.Visible = row:_IsShown() and row.SearchMatch
				if row.Frame.Visible then
					count = count + (1)
				end
			end
			block.Group:Refresh()
		end
	end
	self:_RefreshSpacers()
	return count
end

function TabMethods:Select()
	self.Window:SelectTab(self)
end

function TabMethods:SetTitle(text)
	self.Title = tostring(text)
	self.Label.Text = self.Title
	if self.HeroTitle then
		self.HeroTitle.Text = self.Title
	end
end

function TabMethods:SetBadge(value)
	local text = value ~= nil and value ~= false and value ~= 0 and tostring(value) or nil
	self.Badge.Visible = text ~= nil
	self.Badge.Text = text or ""
	-- a circle for one digit, a pill for more
	self.Badge.Size = UDim2.fromOffset(math.max(18, math.ceil(MeasureText(text or "", 11, Enum.FontWeight.Bold)) + 12),
		18)
end

--------------------------------------------------------------------------------
-- Acrylic: blurs the game behind a GUI object. A nearly invisible Glass part is
-- kept in front of the camera over the object's screen rectangle; with a
-- DepthOfFieldEffect present, Roblox renders glass with a blurred backdrop.
-- Requires graphics quality 8+ (or Automatic). Off unless Acrylic = true.
--------------------------------------------------------------------------------

local function AcrylicSupported()
	return false
end

local function CreateAcrylic(target)
	local controller = { Enabled = false, Destroyed = false }
	function controller:SetEnabled(enabled)
		self.Enabled = false
	end
	return controller
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Performance guard: when the game's frame rate drops, pause the heavy effects
-- (frosted glass, animations) until it recovers
--------------------------------------------------------------------------------

local function EngageGuard()
	if Guard.Engaged then
		return
	end
	Guard.Engaged = true
	Guard.Saved = { ReduceMotion = MacUI.ReduceMotion, Acrylic = {} }
	MacUI.ReduceMotion = true
	Guard.Applying = true
	for _, window in ipairs(MacUI.Windows) do
		if window.Acrylic and window.SetAcrylic then
			Guard.Saved.Acrylic[window] = true
			window:SetAcrylic(false)
		end
	end
	Guard.Applying = false
	MacUI.EffectsPaused = true
	if Guard.Notify then
		MacUI:Notify({
			Title = "Effects paused",
			Content = "The game slowed down, so blur and animations are off until it speeds up again.",
			Icon = "gauge",
			IconColor = "Orange",
			Duration = 5,
		})
	end
	MacUI.PerformanceChanged:Fire(true)
end

local function ReleaseGuard()
	if not Guard.Engaged then
		return
	end
	local saved = Guard.Saved or {}
	Guard.Engaged = false
	Guard.Saved = nil
	MacUI.ReduceMotion = saved.ReduceMotion == true
	Guard.Applying = true
	for window in pairs(saved.Acrylic or {}) do
		if not MacUI.Unloaded and window.SetAcrylic then
			window:SetAcrylic(true)
		end
	end
	Guard.Applying = false
	MacUI.EffectsPaused = false
	MacUI.PerformanceChanged:Fire(false)
end

--[[
	MacUI:SetPerformanceGuard(true)                            -- watch the frame rate
	MacUI:SetPerformanceGuard({ MinFps = 30, Notify = true })  -- below 30 fps for 3 s: pause effects
	MacUI:SetPerformanceGuard(false)
	MacUI.EffectsPaused, MacUI.Fps, MacUI.PerformanceChanged:Connect(function(paused) end)
]]
function MacUI:SetPerformanceGuard(options)
	if Guard.Connection then
		Guard.Connection:Disconnect()
		Guard.Connection = nil
	end
	if not options or self.Unloaded then
		Guard.Enabled = false
		self.PerformanceGuard = false
		ReleaseGuard()
		return
	end
	options = type(options) == "table" and options or {}
	Guard.Enabled = true
	self.PerformanceGuard = true
	-- at most 50, so recovering (MinFps + 8) stays reachable on a 60 fps cap
	Guard.MinFps = math.clamp(tonumber(options.MinFps) or 30, 1, 50)
	Guard.Notify = options.Notify ~= false
	local frames, elapsed, slow, fast = 0, 0, 0, 0
	Guard.Connection = RunService.Heartbeat:Connect(function(dt)
		frames = frames + (1)
		elapsed = elapsed + (dt)
		if elapsed < 1 then
			return
		end
		local fps = frames / elapsed
		frames, elapsed = 0, 0
		MacUI.Fps = fps
		if fps < Guard.MinFps then
			slow, fast = slow + 1, 0
			if slow >= 3 then
				EngageGuard()
			end
		else
			slow = 0
			fast = fps >= Guard.MinFps + 8 and fast + 1 or 0
			if fast >= 8 then
				ReleaseGuard()
			end
		end
	end)
end

local function SizeFromConfig(value, fallback)
	if typeof(value) == "UDim2" then
		return Vector2.new(value.X.Offset, value.Y.Offset)
	elseif typeof(value) == "Vector2" then
		return value
	end
	return fallback
end


--------------------------------------------------------------------------------
-- Senden Hub Asset Manager
--------------------------------------------------------------------------------
local _sendenLogoB64 =
"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"
local _sendenLogoAsset = nil
local _sendenLogoTried = false
local function GetSendenLogoAsset()
	if _sendenLogoAsset then return _sendenLogoAsset end
	if _sendenLogoTried then return "rbxassetid://132147363436034" end
	_sendenLogoTried = true
	local getAsset = getcustomasset or getsynasset
	if type(writefile) == "function" and type(getAsset) == "function" then
		pcall(function()
			if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder("sendenhub") then
				makefolder("sendenhub")
			end
			local filePath = "sendenhub/island_logo.png"
			local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
			local b64lookup = {}
			for i = 1, 64 do b64lookup[b64chars:byte(i)] = i - 1 end
			local cleanB64 = _sendenLogoB64:gsub("[^%w%+/=]", "")
			local out, buf, bits = {}, 0, 0
			for i = 1, #cleanB64 do
				local c = cleanB64:byte(i)
				if c ~= 61 then
					buf = buf * 64 + (b64lookup[c] or 0)
					bits = bits + 6
					if bits >= 8 then
						bits = bits - 8
						local byteVal = math.floor(buf / (2 ^ bits))
						buf = buf - byteVal * (2 ^ bits)
						out[#out + 1] = string.char(byteVal)
					end
				end
			end
			local decodedStr = table.concat(out)
			local needWrite = true
			if type(isfile) == "function" and isfile(filePath) then
				if #readfile(filePath) == #decodedStr then
					needWrite = false
				end
			end
			if needWrite then
				writefile(filePath, decodedStr)
			end
			_sendenLogoAsset = getAsset(filePath)
		end)
	end
	_sendenLogoAsset = _sendenLogoAsset or "rbxassetid://132147363436034"
	return _sendenLogoAsset
end

function MacUI:CreateWindow(config)
	config = config or {}
	self.Unloaded = false
	-- Re-running a script shouldn't stack a second copy of its window.
	if config.ReplaceExisting ~= false and config.Title ~= nil and type(shared) == "table" then
		local registry = shared.__MacUIWindows
		if type(registry) ~= "table" then
			registry = {}
			shared.__MacUIWindows = registry
		end
		local key = tostring(config.Title)
		local previous = registry[key]
		if previous and previous ~= self and not previous.Unloaded then
			pcall(previous.Destroy, previous)
		end
		registry[key] = self
	end
	if config.Theme and self.Themes[config.Theme] then
		self:SetTheme(config.Theme, true)
	end
	if config.Accent then
		self:SetAccent(config.Accent, true)
	end
	if config.Font then
		self:SetFont(config.Font)
	end

	local size = SizeFromConfig(config.Size, Vector2.new(840, 560))
	local minSize = SizeFromConfig(config.MinSize, Vector2.new(620, 400))
	-- the size asked for (by the script, a resize or a saved state); the window
	-- is smaller while the screen can't fit it
	local wantedSize = size
	local sidebarWidth = math.max(config.TabWidth or config.SidebarWidth or 220, 180)
	local sidebarStyle = config.SidebarStyle or "Tile"
	local toolbarHeight = 52

	local Window = {
		Title = tostring(config.Title or "MacUI"),
		SubTitle = tostring(config.SubTitle or config.Subtitle or ""),
		Tabs = {},
		History = {},
		HistoryIndex = 0,
		Minimized = false,
		Maximized = false,
		SidebarVisible = true,
		SearchQuery = "",
		MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightControl,
		Scale = 1,
		Size = size,
		Connections = {},
		Shown = false,
		Acrylic = false,
		StateChanged = Signal.new(),
		Commands = {},
	}
	-- (a copy that stepped aside above still builds its window for the script,
	-- but it isn't one of the library's windows)
	if not self.Unloaded then
		table.insert(self.Windows, Window)
	end
	local Cleanup = {}
	EnsureLibraryInput()

	local function Connect(signal, fn)
		local connection = signal:Connect(fn)
		if MacUI.Unloaded then
			connection:Disconnect() -- this copy was replaced while it was building
		else
			table.insert(Window.Connections, connection)
		end
		return connection
	end

	local ScreenGui = New("ScreenGui", {
		Name = "MacUI",
		ResetOnSpawn = false,
		DisplayOrder = config.DisplayOrder or 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	if not MacUI.Unloaded then
		ParentGui(ScreenGui)
	end
	Window.ScreenGui = ScreenGui
	-- the game (or an anti-cheat) removed the window: unload properly
	ScreenGui.Destroying:Connect(function()
		if not MacUI.Unloaded then
			task.defer(function()
				MacUI:Destroy()
			end)
		end
	end)

	-- Root: positioned & scaled container; Holder: the visible window.
	local Root = New("Frame", {
		Name = "Window",
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(12, 12, 15),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		ClipsDescendants = false,
		Parent = ScreenGui,
	})
	local RootScale = New("UIScale", { Scale = 1, Parent = Root })
	local ScaleTween
	InterfaceRoots[Root] = true
	local MouseUnlock = New("TextButton", {
		Name = "MouseUnlock",
		Modal = true,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(1, 1),
		Visible = false,
		Parent = Root,
	})

	function Window:GetAbsoluteScale()
		return RootScale.Scale
	end

	-- Red cyberpunk border stroke
	New("UIStroke", {
		Color = Color3.fromRGB(225, 25, 45),
		Thickness = 1.6,
		Transparency = 0.1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = Root,
	})
	Corner(Root, 10)

	-- 4 Cyberpunk red neon corner brackets matching Image 1
	local function MakeCornerAccent(pos, anchor, isLeft, isTop)
		local cornerFrame = New("Frame", {
			Name = "CyberCorner",
			AnchorPoint = anchor,
			Position = pos,
			Size = UDim2.fromOffset(36, 36),
			BackgroundTransparency = 1,
			ZIndex = 55,
			Parent = Root,
		})
		New("Frame", {
			Position = UDim2.new(isLeft and 0 or 1, isLeft and 0 or -32, isTop and 0 or 1, isTop and 0 or -2),
			Size = UDim2.fromOffset(32, 2.5),
			BackgroundColor3 = Color3.fromRGB(245, 35, 55),
			BorderSizePixel = 0,
			ZIndex = 56,
			Parent = cornerFrame,
		})
		New("Frame", {
			Position = UDim2.new(isLeft and 0 or 1, isLeft and 0 or -2, isTop and 0 or 1, isTop and 0 or -32),
			Size = UDim2.fromOffset(2.5, 32),
			BackgroundColor3 = Color3.fromRGB(245, 35, 55),
			BorderSizePixel = 0,
			ZIndex = 56,
			Parent = cornerFrame,
		})
	end
	MakeCornerAccent(UDim2.fromOffset(2, 2), Vector2.new(0, 0), true, true)
	MakeCornerAccent(UDim2.new(1, -2, 0, 2), Vector2.new(1, 0), false, true)
	MakeCornerAccent(UDim2.new(0, 2, 1, -2), Vector2.new(0, 1), true, false)
	MakeCornerAccent(UDim2.new(1, -2, 1, -2), Vector2.new(1, 1), false, false)

	local AnimGroup = New("Frame", {
		Name = "Transition",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 2,
		Parent = Root,
	})
	local Holder = New("Frame", {
		Name = "Holder",
		Size = UDim2.fromScale(1, 1),
		Active = true,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = Root,
	})
	Corner(Holder, 10)

	-- Popups layer
	local PopupLayer = New("Frame", {
		Name = "Popups",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 100,
		Parent = ScreenGui,
	})
	Window.PopupLayer = PopupLayer

	local TooltipFrame, TooltipLabel, TooltipScale
	local tooltipToken = 0
	local function HideTooltip()
		tooltipToken = tooltipToken + 1
		if TooltipFrame then
			TooltipFrame.Visible = false
		end
	end
	local function ShowTooltip(text)
		if not TooltipFrame then
			TooltipFrame = New("Frame", {
				Name = "Tooltip",
				Size = UDim2.fromOffset(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				Visible = false,
				ZIndex = 200,
				Theme = { BackgroundColor3 = "Menu" },
				Parent = PopupLayer,
			})
			Corner(TooltipFrame, 6)
			Stroke(TooltipFrame, "MenuStroke", 1, 0.1)
			Padding(TooltipFrame, 5, 8, 5, 8)
			TooltipScale = New("UIScale", { Parent = TooltipFrame })
			TooltipLabel = New("TextLabel", {
				Name = "Text",
				TextSize = 12,
				Size = UDim2.fromOffset(0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 201,
				Theme = { TextColor3 = "Text" },
				Parent = TooltipFrame,
			})
		end
		local scale = Window.Scale
		TooltipScale.Scale = scale
		TooltipLabel.Text = text
		TooltipLabel.Size = UDim2.fromOffset(math.min(math.ceil(MeasureText(text, 12)) + 2, 260), 0)
		local mouse = MousePosition() - PopupLayer.AbsolutePosition
		local screen = PopupLayer.AbsoluteSize
		local flip = mouse.X > screen.X - 290 * scale
		TooltipFrame.AnchorPoint = Vector2.new(flip and 1 or 0, 0)
		TooltipFrame.Position = UDim2.fromOffset(mouse.X + (flip and -6 or 12), math.min(mouse.Y + 20, screen.Y - 40 * scale))
		TooltipFrame.Visible = true
	end
	function Window:_AttachTooltip(gui, text)
		gui.MouseEnter:Connect(function()
			tooltipToken = tooltipToken + 1
			local token = tooltipToken
			task.delay(0.6, function()
				if token ~= tooltipToken or Window.ActivePopup or not gui.Parent or not Root.Visible then
					return
				end
				local value = text
				if type(text) == "function" then
					local ok, result = pcall(text)
					value = ok and result or nil
				end
				if value and value ~= "" then
					ShowTooltip(tostring(value))
				end
			end)
		end)
		gui.MouseLeave:Connect(HideTooltip)
		gui.InputBegan:Connect(function(input)
			if IsPointer(input) then
				HideTooltip()
			end
		end)
	end

	----------------------------------------------------------------------------
	-- Top Header Bar: Senden Hub Logo (Left) & Controls (Right)
	----------------------------------------------------------------------------
	local TopBar = New("Frame", {
		Name = "TopBar",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, toolbarHeight),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = Holder,
	})
	local BrandTitle = New("TextLabel", {
		Name = "BrandTitle",
		RichText = true,
		Text = '<font color="#FFFFFF"><b>Senden </b></font><font color="#E61E2E"><b>Hub</b></font>',
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(18, 11),
		Size = UDim2.fromOffset(150, 24),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = 11,
		Parent = TopBar,
	})
	local RightControls = New("Frame", {
		Name = "RightControls",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 11,
		Parent = TopBar,
	})
	local RightList = New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = RightControls,
	})
	-- Online Badge
	local OnlineBadge = New("Frame", {
		Size = UDim2.fromOffset(72, 22),
		BackgroundColor3 = Color3.fromRGB(16, 18, 20),
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Parent = RightControls,
	})
	Corner(OnlineBadge, 11)
	New("UIStroke", {
		Color = Color3.fromRGB(0, 200, 100),
		Thickness = 1,
		Transparency = 0.6,
		Parent = OnlineBadge,
	})
	local GreenDot = New("Frame", {
		Position = UDim2.fromOffset(8, 7),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Color3.fromRGB(0, 230, 118),
		BorderSizePixel = 0,
		Parent = OnlineBadge,
	})
	Corner(GreenDot, 4)
	New("TextLabel", {
		Text = "Online",
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(0, 230, 118),
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -22, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = OnlineBadge,
	})
	-- Divider "|"
	New("TextLabel", {
		Text = "|",
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(70, 70, 80),
		Size = UDim2.fromOffset(10, 20),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = RightControls,
	})
	-- Player dropdown "Người Chơi ⌄"
	local PlayerBadge = New("TextButton", {
		Size = UDim2.fromOffset(90, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = 3,
		Parent = RightControls,
	})
	local playerName = (LocalPlayer and LocalPlayer.DisplayName) or "Người Chơi"
	New("TextLabel", {
		Text = playerName .. "  ⌄",
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Color3.fromRGB(220, 220, 230),
		Size = UDim2.new(1, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		Parent = PlayerBadge,
	})
	local function MakeWinBtn(text, order, onClick, isClose)
		local btn = New("TextButton", {
			Size = UDim2.fromOffset(22, 22),
			Text = text,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			TextColor3 = isClose and Color3.fromRGB(220, 50, 60) or Color3.fromRGB(180, 180, 190),
			BackgroundColor3 = Color3.fromRGB(24, 24, 30),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			LayoutOrder = order,
			Parent = RightControls,
		})
		Corner(btn, 5)
		New("UIStroke", { Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Parent = btn })
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = isClose and Color3.fromRGB(215, 25, 40) or Color3.fromRGB(38, 38, 48)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
			btn.TextColor3 = isClose and Color3.fromRGB(220, 50, 60) or Color3.fromRGB(180, 180, 190)
		end)
		btn.MouseButton1Click:Connect(onClick)
		return btn
	end
	MakeWinBtn("—", 4, function() Window:Minimize() end)
	MakeWinBtn("□", 5, function() Window:SetMaximized(not Window.Maximized) end)
	MakeWinBtn("✕", 6, function() Window:SetVisible(false) end, true)

	----------------------------------------------------------------------------
	-- Left Sidebar (Navigation Tabs with Cyberpunk Red Border)
	----------------------------------------------------------------------------
	local Sidebar = New("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(12, toolbarHeight + 2),
		Size = UDim2.new(0, sidebarWidth, 1, -toolbarHeight - 38),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18),
		BackgroundTransparency = 0.35,
		ClipsDescendants = true,
		Parent = Holder,
	})
	Corner(Sidebar, 8)
	New("UIStroke", {
		Color = Color3.fromRGB(205, 25, 40),
		Thickness = 1.2,
		Transparency = 0.25,
		Parent = Sidebar,
	})
	local TabScroll = New("ScrollingFrame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(0, 6),
		Size = UDim2.new(1, 0, 1, -12),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = Sidebar,
	})
	local Pill = New("Frame", {
		Name = "Selection",
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 0, 36),
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(215, 25, 40),
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = TabScroll,
	})
	Corner(Pill, 8)
	New("UIStroke", {
		Color = Color3.fromRGB(255, 60, 75),
		Thickness = 1.2,
		Parent = Pill,
	})
	local TabList = New("Frame", {
		Name = "List",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 2,
		Parent = TabScroll,
	})
	Padding(TabList, 2, 8, 8, 8)
	List(TabList, nil, 4)
	TabList:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		TabScroll.CanvasSize = UDim2.fromOffset(0, TabList.AbsoluteSize.Y + 16)
	end)
	local TabOrder = 0
	local function NextTabOrder()
		TabOrder = TabOrder + 1
		return TabOrder
	end

	----------------------------------------------------------------------------
	-- Bottom Center Futuristic Bracket "Senden Hub"
	----------------------------------------------------------------------------
	local BottomCenterBracket = New("Frame", {
		Name = "BottomCenterBracket",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.fromOffset(130, 20),
		BackgroundColor3 = Color3.fromRGB(16, 16, 20),
		BorderSizePixel = 0,
		ZIndex = 50,
		Parent = Root,
	})
	Corner(BottomCenterBracket, 4)
	New("UIStroke", {
		Color = Color3.fromRGB(225, 25, 45),
		Thickness = 1.4,
		Parent = BottomCenterBracket,
	})
	New("TextLabel", {
		Name = "BrandLabel",
		RichText = true,
		Text = '<font color="#FFFFFF">Senden </font><font color="#E61E2E"><b>Hub</b></font>',
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 51,
		Parent = BottomCenterBracket,
	})

	----------------------------------------------------------------------------
	-- Main area: Car Artwork Background & Tab Content Host
	----------------------------------------------------------------------------
	local Main = New("Frame", {
		Name = "Main",
		Position = UDim2.fromOffset(sidebarWidth + 24, toolbarHeight + 2),
		Size = UDim2.new(1, -sidebarWidth - 36, 1, -toolbarHeight - 38),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Holder,
	})
	Corner(Main, 8)
	New("UIStroke", {
		Color = Color3.fromRGB(35, 35, 42),
		Thickness = 1,
		Parent = Main,
	})

	
	
	local PageHost = New("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, toolbarHeight),
		Size = UDim2.new(1, 0, 1, -toolbarHeight),
		ClipsDescendants = true,
		Parent = Main,
	})
	local PageFade = New("Frame", {
		Name = "Fade",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Theme = { BackgroundColor3 = "Background" },
		Parent = PageHost,
	})
	local EmptyState = New("Frame", {
		Name = "NoResults",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.new(1, -40, 0, 110),
		Visible = false,
		ZIndex = 5,
		Parent = PageHost,
	})
	IconImage({
		Icon = "search",
		IconSize = 34,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Theme = { ImageColor3 = "Tertiary" },
		Parent = EmptyState,
	})
	local EmptyTitle = New("TextLabel", {
		Text = "No Results",
		TextSize = 17,
		Weight = Enum.FontWeight.Bold,
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(1, 0, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Theme = { TextColor3 = "Text" },
		Parent = EmptyState,
	})
	New("TextLabel", {
		Text = "Check the spelling or try a new search.",
		TextSize = 13,
		Position = UDim2.fromOffset(0, 74),
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Center,
		Theme = { TextColor3 = "SubText" },
		Parent = EmptyState,
	})

	----------------------------------------------------------------------------
	-- Traffic lights
	----------------------------------------------------------------------------

	-- on a touch screen the lights sit further apart, each with a finger-sized
	-- invisible target around it
	local lightGap = TouchOnly() and 28 or 20
	local Lights = New("Frame", {
		Name = "TrafficLights",
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 20),
		Size = UDim2.fromOffset(lightGap * 2 + 12, 12),
		ZIndex = 20,
		Parent = Holder,
	})
	local LightGlyphs = {}
	local LightButtons = {}
	local LightTargets = {}
	for index, spec in ipairs(TRAFFIC) do
		local button = New("TextButton", {
			Name = spec.Name,
			Position = UDim2.fromOffset((index - 1) * lightGap, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundTransparency = 0,
			BackgroundColor3 = spec.Color,
			ZIndex = 21,
			Parent = Lights,
		})
		if TouchOnly() then
			LightTargets[spec.Name] = New("TextButton", {
				Name = "Target",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(28, 28),
				ZIndex = 23,
				Parent = button,
			})
		end
		Corner(button, 6)
		New("UIStroke", { Color = spec.Stroke, Thickness = 1, Transparency = 0.45, Parent = button })
		local glyphs = {}
		local function Bar(rotation, width)
			local bar = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(width, 1),
				Rotation = rotation,
				BackgroundColor3 = spec.Glyph,
				BackgroundTransparency = 1,
				ZIndex = 22,
				Parent = button,
			})
			table.insert(glyphs, bar)
		end
		if spec.Name == "Close" then
			Bar(45, 8)
			Bar(-45, 8)
		elseif spec.Name == "Minimize" then
			Bar(0, 7)
		else
			Bar(0, 7)
			Bar(90, 7)
		end
		LightGlyphs[spec.Name] = glyphs
		LightButtons[spec.Name] = button
	end
	Lights.MouseEnter:Connect(function()
		for _, glyphs in pairs(LightGlyphs) do
			for _, bar in ipairs(glyphs) do
				Tween(bar, { BackgroundTransparency = 0.15 }, 0.12)
			end
		end
	end)
	Lights.MouseLeave:Connect(function()
		for _, glyphs in pairs(LightGlyphs) do
			for _, bar in ipairs(glyphs) do
				Tween(bar, { BackgroundTransparency = 1 }, 0.15)
			end
		end
	end)

	----------------------------------------------------------------------------
	-- Dock icon shown while minimised
	----------------------------------------------------------------------------

	local Dock = New("TextButton", {
		Name = "Dock",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 90),
		Size = UDim2.fromOffset(64, 64),
		Visible = false,
		ZIndex = 5,
		Parent = ScreenGui,
	})
	local DockScale = New("UIScale", { Scale = 1, Parent = Dock })
	InterfaceRoots[Dock] = true
	local DockBody = New("Frame", {
		Name = "Body",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.08,
		ZIndex = 2,
		Theme = { BackgroundColor3 = "Menu" },
		Parent = Dock,
	})
	Corner(DockBody, 18)
	Stroke(DockBody, "HudStroke", 1, 0)
	IconTile(DockBody, config.Icon or "command", ResolveColor(config.IconColor) or function()
		return MacUI.Accent
	end, 48, 12, 26, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	})
	local DockDot = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 4),
		Size = UDim2.fromOffset(4, 4),
		Theme = { BackgroundColor3 = "Text" },
		Parent = Dock,
	})
	Corner(DockDot, 2)
	local DockTip = New("TextLabel", {
		Name = "Tooltip",
		Text = Window.Title,
		TextSize = 13,
		Weight = Enum.FontWeight.Medium,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 0, -10),
		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 0,
		Visible = false,
		Theme = { BackgroundColor3 = "Menu", TextColor3 = "Text" },
		Parent = Dock,
	})
	Corner(DockTip, 6)
	Padding(DockTip, 0, 10, 0, 10)
	Stroke(DockTip, "HudStroke", 1, 0)

	----------------------------------------------------------------------------
	-- Scale
	----------------------------------------------------------------------------

	function Window:SetScale(scale)
		scale = math.clamp(tonumber(scale) or 1, 0.4, 2)
		self.Scale = scale
		if ScaleTween then
			ScaleTween:Cancel()
			ScaleTween = nil
		end
		RootScale.Scale = scale
		DockScale.Scale = scale
		if self._ClosePopup then
			self:_ClosePopup(true)
		end
		if self._OnScale then
			self:_OnScale(scale)
		end
		for _, tab in ipairs(self.Tabs) do
			for _, row in ipairs(tab.Rows) do
				row:_UpdateReserve()
			end
		end
		if self._FitToScreen then
			self._FitToScreen()
		end
	end

	local function ScreenSize()
		local viewport = ScreenGui.AbsoluteSize
		if viewport.X < 10 or viewport.Y < 10 then
			viewport = Viewport() - Vector2.new(0, GuiService:GetGuiInset().Y)
		end
		return viewport
	end

	local function AutoScale()
		local viewport = ScreenSize()
		-- the largest scale (up to 1) at which the minimum size fits: on a small
		-- screen the window gets smaller before its text does
		local fit = math.min((viewport.X - 32) / minSize.X, (viewport.Y - 32) / minSize.Y, 1)
		-- and on a phone it never gets too small to read or tap
		return math.max(fit, TouchOnly() and 0.85 or 0.5)
	end

	local function Between(value, low, high)
		if low > high then
			return (low + high) / 2
		end
		return math.clamp(value, low, high)
	end

	-- The size and position that keep the whole window on screen: a size saved
	-- on a bigger screen, a rotated phone or a bigger interface scale shrinks it
	-- (below MinSize if the screen is that small) and it's pulled back into
	-- view. It grows back to the size asked for once there's room.
	local function FittedLayout(position)
		local viewport = ScreenSize()
		if viewport.X < 10 or viewport.Y < 10 then
			return wantedSize, position
		end
		local scale = Window.Scale
		local width = math.min(wantedSize.X, (viewport.X - 16) / scale)
		local height = math.min(wantedSize.Y, (viewport.Y - 16) / scale)
		local halfWidth, halfHeight = width * scale / 2, height * scale / 2
		local x = Between(position.X.Offset, halfWidth - viewport.X / 2, viewport.X / 2 - halfWidth)
		local y = Between(position.Y.Offset, halfHeight - viewport.Y / 2, viewport.Y / 2 - halfHeight)
		return Vector2.new(width, height), UDim2.new(0.5, x, 0.5, y)
	end

	local function FitToScreen()
		if Window.Maximized then
			-- the screen or the scale changed: fill the screen again
			local viewport = ScreenSize()
			if viewport.X >= 10 and viewport.Y >= 10 then
				Window.Size = Vector2.new((viewport.X - 24) / Window.Scale, (viewport.Y - 24) / Window.Scale)
				Root.Size = UDim2.fromOffset(Window.Size.X, Window.Size.Y)
				Root.Position = UDim2.fromScale(0.5, 0.5)
			end
			return
		end
		local fitted, position = FittedLayout(Root.Position)
		if fitted ~= Window.Size then
			Window.Size = fitted
			Root.Size = UDim2.fromOffset(fitted.X, fitted.Y)
		end
		Root.Position = position
	end
	Window._FitToScreen = FitToScreen

	Window:SetScale(config.Scale or AutoScale())
	FitToScreen()

	----------------------------------------------------------------------------
	-- Popups
	----------------------------------------------------------------------------

	function Window:_ClosePopup(instant)
		local popup = self.ActivePopup
		if not popup then
			return
		end
		self.ActivePopup = nil
		popup.Shown = false
		for _, connection in ipairs(popup.Connections) do
			connection:Disconnect()
		end
		SafeCall(popup.OnClose)
		popup.Catcher:Destroy()
		if instant then
			popup.Holder:Destroy()
			return
		end
		Tween(popup.Canvas, { GroupTransparency = 1 }, 0.14)
		Restyle(popup.Shadow, 0.14)
		Tween(popup.Scale, { Scale = self.Scale * 0.97 }, 0.14)
		task.delay(0.15, function()
			popup.Holder:Destroy()
		end)
	end

	function Window:_OpenPopup(anchor, width, height, build, options)
		options = options or {}
		self:_ClosePopup(true)
		HideTooltip()
		local scale = self.Scale
		local popup = { Connections = {} }
		function popup:Connect(signal, fn)
			local connection = signal:Connect(fn)
			table.insert(popup.Connections, connection)
			return connection
		end

		popup.Catcher = New("TextButton", {
			Name = "Dismiss",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = PopupLayer,
		})
		popup.Holder = New("Frame", {
			Name = "Popover",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(width, height),
			ZIndex = 2,
			Parent = PopupLayer,
		})
		-- while a popover is open, a press anywhere is on the interface
		InterfaceRoots[popup.Catcher] = true
		InterfaceRoots[popup.Holder] = true
		popup.Scale = New("UIScale", { Scale = scale * 0.96, Parent = popup.Holder })
		-- Frames don't sink clicks; without this the dismiss catcher underneath
		-- would close the popover when clicking its background or colour square.
		New("TextButton", {
			Name = "Sink",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = popup.Holder,
		})
		popup.Shadow = Shadow(popup.Holder, 4, function(t)
			return popup.Shown and t.ShadowTransparency + 0.2 or 1
		end)
		popup.Canvas = New("Frame", {
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			GroupTransparency = 1,
			ZIndex = 2,
			Theme = { BackgroundColor3 = "Menu" },
			Parent = popup.Holder,
		})
		Corner(popup.Canvas, 10)
		local border = New("Frame", {
			Name = "Border",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(1, 1),
			Size = UDim2.new(1, -2, 1, -2),
			ZIndex = 50,
			Parent = popup.Canvas,
		})
		Corner(border, 9)
		Stroke(border, "MenuStroke", 1, 0.1)

		local layerPos = PopupLayer.AbsolutePosition
		local screen = PopupLayer.AbsoluteSize
		local anchorPos, anchorSize, gap
		if typeof(anchor) == "Vector2" then
			anchorPos, anchorSize, gap = anchor - layerPos, Vector2.new(0, 0), 2
			options.Align = "Left"
		else
			anchorPos, anchorSize, gap = anchor.AbsolutePosition - layerPos, anchor.AbsoluteSize, 6 * scale
		end
		local w, h = width * scale, height * scale
		local x = options.Align == "Left" and anchorPos.X or (anchorPos.X + anchorSize.X - w)
		x = math.clamp(x, 8, math.max(screen.X - w - 8, 8))
		local y = anchorPos.Y + anchorSize.Y + gap
		if y + h > screen.Y - 8 then
			y = anchorPos.Y - h - gap
		end
		y = math.clamp(y, 8, math.max(screen.Y - h - 8, 8))
		popup.Holder.Position = UDim2.fromOffset(x, y)

		self.ActivePopup = popup
		popup.Catcher.MouseButton1Click:Connect(function()
			self:_ClosePopup()
		end)
		popup.Catcher.MouseButton2Click:Connect(function()
			self:_ClosePopup()
		end)

		build(popup.Canvas, popup)

		popup.Shown = true
		Tween(popup.Canvas, { GroupTransparency = 0 }, 0.16)
		Restyle(popup.Shadow, 0.2)
		Tween(popup.Scale, { Scale = scale }, 0.2, Enum.EasingStyle.Back)
		return popup
	end

	function Window:_OpenMenu(anchor, options)
		local values = options.Values or {}
		local itemHeight = 26
		local searchable = options.Searchable
		if searchable == nil then
			searchable = #values > 10
		end
		local widest = 0
		for _, value in ipairs(values) do
			widest = math.max(widest, MeasureText(tostring(value), 14))
		end
		local width = math.clamp(math.max(widest + 52, options.MinWidth or 0), 150, 320)
		local visible = math.clamp(#values, 1, 9)
		local height = 10 + (searchable and 34 or 0) + visible * itemHeight

		return self:_OpenPopup(anchor, width, height, function(canvas)
			local top = 5
			local query = ""
			local searchBox
			if searchable then
				local field = New("Frame", {
					Name = "Search",
					Position = UDim2.fromOffset(6, 6),
					Size = UDim2.new(1, -12, 0, 26),
					Theme = { BackgroundColor3 = "Field" },
					Parent = canvas,
				})
				Corner(field, 6)
				Stroke(field, "FieldStroke")
				IconImage({
					Icon = "search",
					IconSize = 13,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 8, 0.5, 0),
					Theme = { ImageColor3 = "SubText" },
					Parent = field,
				})
				searchBox = New("TextBox", {
					PlaceholderText = "Filter",
					Text = "",
					TextSize = 13,
					Position = UDim2.fromOffset(27, 0),
					Size = UDim2.new(1, -34, 1, 0),
					ClipsDescendants = true,
					Theme = { TextColor3 = "Text", PlaceholderColor3 = "Tertiary" },
					Parent = field,
				})
				top = 38
			end

			local scroll = New("ScrollingFrame", {
				Name = "Items",
				Position = UDim2.fromOffset(0, top),
				Size = UDim2.new(1, 0, 1, -top - 5),
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 3,
				ScrollBarImageTransparency = 0.4,
				VerticalScrollBarInset = Enum.ScrollBarInset.None,
				Theme = { ScrollBarImageColor3 = "Scrollbar" },
				Parent = canvas,
			})
			local listFrame = New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = scroll,
			})
			Padding(listFrame, 0, 5, 0, 5)
			List(listFrame, nil, 0)

			local empty = New("TextLabel", {
				Text = #values == 0 and "No Items" or "No Matches",
				TextSize = 13,
				Size = UDim2.new(1, 0, 0, itemHeight),
				TextXAlignment = Enum.TextXAlignment.Center,
				Visible = #values == 0,
				LayoutOrder = 100000,
				Theme = { TextColor3 = "SubText" },
				Parent = listFrame,
			})

			local items = {}
			for index, value in ipairs(values) do
				local state = { Hovered = false }
				local item = New("TextButton", {
					Name = "Item",
					Size = UDim2.new(1, 0, 0, itemHeight),
					BackgroundTransparency = 1,
					LayoutOrder = index,
					Theme = {
						BackgroundColor3 = "Accent",
						BackgroundTransparency = function()
							return state.Hovered and 0 or 1
						end,
					},
					Parent = listFrame,
				})
				Corner(item, 5)
				local check = IconImage({
					Name = "Check",
					Icon = "check",
					IconSize = 12,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 8, 0.5, 0),
					Theme = {
						ImageColor3 = function(t)
							return state.Hovered and t.SelectionText or t.Text
						end,
					},
					Parent = item,
				})
				local label = New("TextLabel", {
					Text = tostring(value),
					TextSize = 14,
					Position = UDim2.fromOffset(26, 0),
					Size = UDim2.new(1, -32, 1, 0),
					TextTruncate = Enum.TextTruncate.AtEnd,
					Theme = {
						TextColor3 = function(t)
							return state.Hovered and t.SelectionText or t.Text
						end,
					},
					Parent = item,
				})
				local entry = { Item = item, Check = check, Value = value, Text = tostring(value):lower() }
				table.insert(items, entry)
				local function Paint(duration)
					Restyle(item, duration)
					Restyle(check, duration)
					Restyle(label, duration)
				end
				item.MouseEnter:Connect(function()
					state.Hovered = true
					Paint(0.06)
				end)
				item.MouseLeave:Connect(function()
					state.Hovered = false
					Paint(0.1)
				end)
				item.MouseButton1Click:Connect(function()
					options.OnPick(value)
					if options.Multi then
						for _, other in ipairs(items) do
							other.Check.Visible = options.IsSelected(other.Value)
						end
					else
						self:_ClosePopup()
					end
				end)
				check.Visible = options.IsSelected(value)
			end

			if searchBox then
				searchBox:GetPropertyChangedSignal("Text"):Connect(function()
					query = searchBox.Text:lower()
					local shown = 0
					for _, entry in ipairs(items) do
						entry.Item.Visible = query == "" or entry.Text:find(query, 1, true) ~= nil
						if entry.Item.Visible then
							shown = shown + (1)
						end
					end
					empty.Visible = shown == 0
				end)
				task.defer(function()
					-- (on a touch screen the keyboard would cover the list)
					if searchBox.Parent and not TouchOnly() then
						searchBox:CaptureFocus()
					end
				end)
			end
		end, { Align = options.Align })
	end

	-- Right-click menu. `items` are { Text, Icon?, Shortcut?, Disabled?, Destructive?, Callback } or "-".
	function Window:_OpenContextMenu(point, items)
		items = TidySeparators(items or {})
		if #items == 0 then
			return
		end
		local itemHeight, separatorHeight = 24, 9
		local hasIcons, widest, height = false, 0, 10
		for _, item in ipairs(items) do
			if item == "-" then
				height = height + (separatorHeight)
			else
				height = height + (itemHeight)
				hasIcons = hasIcons or item.Icon ~= nil
				local extra = item.Shortcut and (MeasureText(item.Shortcut, 12) + 24) or 0
				widest = math.max(widest, MeasureText(item.Text, 13) + extra)
			end
		end
		local width = math.clamp(widest + (hasIcons and 44 or 24) + 10, 180, 320)
		return self:_OpenPopup(point, width, height, function(canvas)
			local list = New("Frame", {
				Name = "Items",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Parent = canvas,
			})
			Padding(list, 5, 5, 5, 5)
			List(list, nil, 0)
			for index, item in ipairs(items) do
				if item == "-" then
					local separator = New("Frame", {
						Name = "Separator",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, separatorHeight),
						LayoutOrder = index,
						Parent = list,
					})
					New("Frame", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 8, 0.5, 0),
						Size = UDim2.new(1, -16, 0, 1),
						Theme = { BackgroundColor3 = "Separator" },
						Parent = separator,
					})
				else
					local state = { Hovered = false }
					local function Foreground(t, normal)
						if item.Disabled then
							return t.Tertiary
						elseif state.Hovered then
							return t.SelectionText
						elseif item.Destructive then
							return t.Destructive
						end
						return normal
					end
					local button = New("TextButton", {
						Name = "Item",
						Size = UDim2.new(1, 0, 0, itemHeight),
						LayoutOrder = index,
						Theme = {
							BackgroundColor3 = function(t)
								return item.Destructive and t.Destructive or MacUI.Accent
							end,
							BackgroundTransparency = function()
								return state.Hovered and 0 or 1
							end,
						},
						Parent = list,
					})
					Corner(button, 5)
					local painted = { button }
					if item.Icon then
						table.insert(painted, IconImage({
							Icon = item.Icon,
							IconSize = 14,
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 9, 0.5, 0),
							Theme = {
								ImageColor3 = function(t)
									return Foreground(t, t.SubText)
								end,
							},
							Parent = button,
						}))
					end
					table.insert(painted, New("TextLabel", {
						Text = item.Text,
						TextSize = 13,
						Position = UDim2.fromOffset(hasIcons and 31 or 10, 0),
						Size = UDim2.new(1, -(hasIcons and 41 or 20), 1, 0),
						TextTruncate = Enum.TextTruncate.AtEnd,
						Theme = {
							TextColor3 = function(t)
								return Foreground(t, t.Text)
							end,
						},
						Parent = button,
					}))
					if item.Shortcut then
						table.insert(painted, New("TextLabel", {
							Text = item.Shortcut,
							TextSize = 12,
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -10, 0, 0),
							Size = UDim2.new(0, 80, 1, 0),
							TextXAlignment = Enum.TextXAlignment.Right,
							Theme = {
								TextColor3 = function(t)
									return Foreground(t, t.Tertiary)
								end,
							},
							Parent = button,
						}))
					end
					local function Paint(duration)
						for _, object in ipairs(painted) do
							Restyle(object, duration)
						end
					end
					button.MouseEnter:Connect(function()
						if not item.Disabled then
							state.Hovered = true
							Paint(0.05)
						end
					end)
					button.MouseLeave:Connect(function()
						state.Hovered = false
						Paint(0.1)
					end)
					button.MouseButton1Click:Connect(function()
						if item.Disabled then
							return
						end
						self:_ClosePopup()
						Spawn(item.Callback)
					end)
				end
			end
		end)
	end

	-- A pill under the toolbar while a macro records, with a Stop button: the
	-- macro's own row may be on another page.
	local RecordingPill
	function Window:_SetRecording(macro)
		if not macro then
			local pill = RecordingPill
			RecordingPill = nil
			if pill then
				pill.Shown = false
				Tween(pill.Body, { GroupTransparency = 1 }, 0.2)
				task.delay(0.21, function()
					pill.Holder:Destroy()
				end)
			end
			return
		end
		if not RecordingPill then
			local pill = { Shown = true, Macro = macro }
			pill.Holder = New("Frame", {
				Name = "Recording",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, toolbarHeight + 8),
				Size = UDim2.fromOffset(220, 32),
				ZIndex = 30,
				Parent = Main,
			})
			pill.Body = New("Frame", {
				Name = "Body",
				Size = UDim2.fromScale(1, 1),
				GroupTransparency = 1,
				ZIndex = 2,
				Theme = { BackgroundColor3 = "Hud" },
				Parent = pill.Holder,
			})
			Corner(pill.Body, 16)
			local border = New("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(1, 1),
				Size = UDim2.new(1, -2, 1, -2),
				ZIndex = 5,
				Parent = pill.Body,
			})
			Corner(border, 15)
			Stroke(border, "HudStroke", 1, 0)
			pill.Dot = New("Frame", {
				Name = "Dot",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 13, 0.5, 0),
				Size = UDim2.fromOffset(9, 9),
				Theme = { BackgroundColor3 = "Destructive" },
				Parent = pill.Body,
			})
			Corner(pill.Dot, 5)
			pill.Label = New("TextLabel", {
				Name = "Text",
				TextSize = 13,
				Weight = Enum.FontWeight.Medium,
				Position = UDim2.fromOffset(30, 0),
				Size = UDim2.new(1, -90, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Theme = { TextColor3 = "Text" },
				Parent = pill.Body,
			})
			local stop = PushButton(pill.Body, "Stop", "Destructive", 22)
			stop.Instance.AnchorPoint = Vector2.new(1, 0.5)
			stop.Instance.Position = UDim2.new(1, -5, 0.5, 0)
			stop.Instance.MouseButton1Click:Connect(function()
				if pill.Macro and pill.Macro.StopRecording then
					pill.Macro:StopRecording()
				end
			end)
			pill.StopWidth = stop.Instance.Size.X.Offset
			Tween(pill.Body, { GroupTransparency = 0 }, 0.2)
			-- the dot breathes while recording
			task.spawn(function()
				while pill.Shown and not MacUI.Unloaded do
					Tween(pill.Dot, { BackgroundTransparency = 0.6 }, 0.6, Enum.EasingStyle.Sine)
					task.wait(0.6)
					Tween(pill.Dot, { BackgroundTransparency = 0 }, 0.6, Enum.EasingStyle.Sine)
					task.wait(0.6)
				end
			end)
			RecordingPill = pill
		end
		local pill = RecordingPill
		pill.Macro = macro
		local count = #(macro._pending or {})
		local text = "Recording “" ..
		tostring(macro.Title or "Macro") .. "” · " .. count .. (count == 1 and " step" or " steps")
		pill.Label.Text = text
		local width = math.ceil(MeasureText(text, 13, Enum.FontWeight.Medium)) + 30 + 14 + pill.StopWidth
		pill.Holder.Size = UDim2.fromOffset(math.clamp(width, 180, 420), 32)
	end

	-- A short-lived HUD at the bottom of the screen ("Auto Farm  On").
	local ActiveToast
	function Window:Toast(text, options)
		options = options or {}
		if MacUI.Unloaded then
			return
		end
		if ActiveToast then
			ActiveToast.Close(true)
		end
		text = tostring(text)
		local scale = Window.Scale
		local detail = options.Detail and tostring(options.Detail)
		local width = 36 + (options.Icon and 24 or 0) + MeasureText(text, 14, Enum.FontWeight.Medium)
		if detail then
			width = width + (MeasureText(detail, 14, Enum.FontWeight.Medium) + 8)
		end
		width = math.clamp(math.ceil(width), 110, 440)
		local toast = { Shown = true }
		local position = UDim2.new(0.5, 0, 1, -90)
		if Window.Shown and not Window.Minimized then
			local layer = PopupLayer.AbsolutePosition
			local rootPosition, rootSize = Root.AbsolutePosition, Root.AbsoluteSize
			position = UDim2.fromOffset(
				rootPosition.X - layer.X + rootSize.X / 2,
				rootPosition.Y - layer.Y + rootSize.Y - 22 * RootScale.Scale
			)
		end
		local holder = New("Frame", {
			Name = "Toast",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = position,
			Size = UDim2.fromOffset(width, 40),
			ZIndex = 150,
			Parent = PopupLayer,
		})
		local toastScale = New("UIScale", { Scale = scale * 0.9, Parent = holder })
		local body = New("Frame", {
			Name = "Body",
			Size = UDim2.fromScale(1, 1),
			GroupTransparency = 1,
			ZIndex = 2,
			Theme = { BackgroundColor3 = "Hud" },
			Parent = holder,
		})
		Corner(body, 20)
		local border = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(1, 1),
			Size = UDim2.new(1, -2, 1, -2),
			ZIndex = 5,
			Parent = body,
		})
		Corner(border, 19)
		Stroke(border, "HudStroke", 1, 0)
		local content = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Parent = body,
		})
		List(content, Enum.FillDirection.Horizontal, 8, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})
		if options.Icon then
			IconImage({
				Icon = options.Icon,
				IconSize = 16,
				LayoutOrder = 1,
				Theme = { ImageColor3 = options.Highlight and "Accent" or "SubText" },
				Parent = content,
			})
		end
		New("TextLabel", {
			Text = text,
			TextSize = 14,
			Weight = Enum.FontWeight.Medium,
			Size = UDim2.fromOffset(0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			Theme = { TextColor3 = "Text" },
			Parent = content,
		})
		if detail then
			New("TextLabel", {
				Text = detail,
				TextSize = 14,
				Weight = Enum.FontWeight.Medium,
				Size = UDim2.fromOffset(0, 18),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 3,
				Theme = { TextColor3 = options.Highlight and "Accent" or "SubText" },
				Parent = content,
			})
		end
		Tween(body, { GroupTransparency = 0 }, 0.18)
		Tween(toastScale, { Scale = scale }, 0.3, Enum.EasingStyle.Back)
		local closed = false
		function toast.Close(instant)
			if closed then
				return
			end
			closed = true
			toast.Shown = false
			if ActiveToast == toast then
				ActiveToast = nil
			end
			if instant then
				holder:Destroy()
				return
			end
			Tween(body, { GroupTransparency = 1 }, 0.25)
			Tween(toastScale, { Scale = scale * 0.95 }, 0.25)
			task.delay(0.26, function()
				holder:Destroy()
			end)
		end

		ActiveToast = toast
		task.delay(options.Duration or 1.4, toast.Close)
		return toast
	end

	----------------------------------------------------------------------------
	-- Tabs
	----------------------------------------------------------------------------

	local stateToken = 0
	local function EmitState()
		stateToken = stateToken + (1)
		local token = stateToken
		task.delay(0.3, function()
			if token == stateToken and not MacUI.Unloaded then
				Window.StateChanged:Fire(Window:GetState())
			end
		end)
	end

	local function MovePill(animate)
		local tab = Window.CurrentTab
		if not tab or not tab.Button then
			Pill.Visible = false
			return
		end
		local y = (tab.Button.AbsolutePosition.Y - TabList.AbsolutePosition.Y) / Window:GetAbsoluteScale()
		local goal = UDim2.fromOffset(8, y)
		Pill.Visible = true
		if animate and not MacUI.ReduceMotion then
			Tween(Pill, { Position = goal }, 0.22, Enum.EasingStyle.Quint)
		else
			Pill.Position = goal
		end
	end

	local function UpdateNavigation()
		if type(SetBackEnabled) == "function" then
			SetBackEnabled(Window.HistoryIndex > 1)
		end
		if type(SetForwardEnabled) == "function" then
			SetForwardEnabled(Window.HistoryIndex < #Window.History)
		end
	end

	local function UpdateToolbarDivider()
		if not ToolbarDivider then return end
		local tab = Window.CurrentTab
		local scrolled = tab and tab.Page and tab.Page.CanvasPosition and tab.Page.CanvasPosition.Y > 1
		Tween(ToolbarDivider, { BackgroundTransparency = scrolled and 0 or 1 }, 0.2)
	end

	function Window:AddTabSection(title)
		New("TextLabel", {
			Name = "SectionTitle",
			Text = tostring(title),
			TextSize = 12,
			Weight = Enum.FontWeight.Bold,
			Size = UDim2.new(1, 0, 0, #Window.Tabs == 0 and TabOrder == 0 and 22 or 30),
			TextYAlignment = Enum.TextYAlignment.Bottom,
			LayoutOrder = NextTabOrder(),
			Theme = { TextColor3 = "SubText" },
			Children = { New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingBottom = UDim.new(0, 5) }) },
			Parent = TabList,
		})
		Window.LastTabSection = title
	end

	Window.AddSidebarSection = Window.AddTabSection

	function Window:AddTab(info)
		if type(info) ~= "table" then
			info = { Title = tostring(info) }
		end
		if info.Section and info.Section ~= Window.LastTabSection then
			Window:AddTabSection(info.Section)
		end
		local index = #Window.Tabs + 1
		local tab = setmetatable({
			Window = Window,
			Title = tostring(info.Title or ("Tab " .. index)),
			Index = index,
			Blocks = {},
			Rows = {},
			Order = 0,
			Selected = false,
			Hovered = false,
			Matches = true,
		}, TabMethods)
		tab.Tab = tab

		-- Sidebar entry
		local button = New("TextButton", {
			Name = tab.Title,
			Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = NextTabOrder(),
			BackgroundColor3 = Color3.fromRGB(24, 24, 30),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Parent = TabList,
		})
		Corner(button, 7)
		tab.Button = button

		local textOffset = 12
		local icon = info.Icon
		tab.TileColor = ResolveColor(info.IconColor) or MacUI.TileColors[(index - 1) % #MacUI.TileColors + 1]
		tab.Icon = icon and MacUI:GetIcon(icon) and icon or nil
		tab.Description = info.Description
		if icon and MacUI:GetIcon(icon) then
			if sidebarStyle == "Tile" then
				local color = tab.TileColor
				IconTile(button, icon, color, 22, 6, 14, {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 5, 0.5, 0),
				})
			else
				IconImage({
					Name = "Icon",
					Icon = icon,
					IconSize = 17,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 8, 0.5, 0),
					Theme = {
						ImageColor3 = function(t)
							if tab.Selected then
								return t.SelectionText
							end
							return sidebarStyle == "Tinted" and MacUI.Accent or t.SubText
						end,
					},
					Parent = button,
				})
			end
			textOffset = 35
		end
		tab.Label = New("TextLabel", {
			Name = "Title",
			Text = tab.Title,
			TextSize = 14,
			Position = UDim2.fromOffset(textOffset, 0),
			Size = UDim2.new(1, -textOffset - 8, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Theme = {
				TextColor3 = function(t)
					return tab.Selected and t.SelectionText or t.Text
				end,
				TextTransparency = function()
					return (tab.Matches or tab.Selected) and 0 or 0.55
				end,
			},
			Parent = button,
		})
		tab.Badge = New("TextLabel", {
			Name = "Badge",
			Text = "",
			TextSize = 11,
			Weight = Enum.FontWeight.Bold,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(18, 18),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
			BackgroundColor3 = rgb(255, 69, 58),
			Visible = false,
			ZIndex = 3,
			Parent = button,
		})
		Corner(tab.Badge, 9)
		tab.BadgeLabel = tab.Badge
		if info.Badge then
			tab:SetBadge(info.Badge)
		end

		button.MouseEnter:Connect(function()
			tab.Hovered = true
			Restyle(button, 0.12)
		end)
		button.MouseLeave:Connect(function()
			tab.Hovered = false
			Restyle(button, 0.18)
		end)
		button.MouseButton1Click:Connect(function()
			Window:SelectTab(tab)
		end)
		button:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if Window.CurrentTab == tab and not Window.PillMoving then
				MovePill(false)
			end
		end)

		-- Page
		tab.Page = New("ScrollingFrame", {
			Name = tab.Title,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 5,
			ScrollBarImageTransparency = 1,
			VerticalScrollBarInset = Enum.ScrollBarInset.None,
			Visible = false,
			Theme = { ScrollBarImageColor3 = "Scrollbar" },
			Parent = PageHost,
		})
		tab.Content = New("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = tab.Page,
		})
		Padding(tab.Content, 6, 22, 26, 22)
		List(tab.Content, nil, 0)

		-- System Settings pane header: big icon, title and a short description.
		if info.Description then
			local block = tab:_NewBlock(0)
			local hero = New("Frame", {
				Name = "Hero",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = tab:_NextOrder(),
				Theme = { BackgroundColor3 = "Group" },
				Parent = tab.Content,
			})
			Corner(hero, 12)
			Stroke(hero, "GroupStroke")
			Padding(hero, 22, 30, 20, 30)
			List(hero, nil, 4, { HorizontalAlignment = Enum.HorizontalAlignment.Center })
			IconTile(hero, tab.Icon or "layers", tab.TileColor, 60, 15, 32, { LayoutOrder = 1 })
			New("Frame",
				{ Name = "Gap", BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 6), LayoutOrder = 2, Parent = hero })
			tab.HeroTitle = New("TextLabel", {
				Name = "Title",
				Text = tab.Title,
				TextSize = 20,
				Weight = Enum.FontWeight.Bold,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = 3,
				Theme = { TextColor3 = "Text" },
				Parent = hero,
			})
			New("TextLabel", {
				Name = "Description",
				Text = tostring(info.Description),
				TextSize = 13,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				RichText = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = 4,
				Theme = { TextColor3 = "SubText" },
				Parent = hero,
			})
			block.Hero = hero
			tab.Hero = hero
		end

		local hideToken = 0
		tab.Page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if Window.CurrentTab ~= tab then
				return
			end
			UpdateToolbarDivider()
			HideTooltip()
			hideToken = hideToken + (1)
			local token = hideToken
			Tween(tab.Page, { ScrollBarImageTransparency = 0.35 }, 0.1)
			task.delay(1.1, function()
				if token == hideToken and tab.Page.Parent then
					Tween(tab.Page, { ScrollBarImageTransparency = 1 }, 0.4)
				end
			end)
		end)
		table.insert(Window.Tabs, tab)
		if not Window.CurrentTab and config.AutoSelect ~= false then
			Window:SelectTab(tab)
		end
		return tab
	end

	function Window:SelectTab(target, fromHistory)
		local tab = type(target) == "number" and Window.Tabs[target] or target
		if not tab or tab.Window ~= Window then
			return
		end
		Window:_ClosePopup()
		if tab == Window.CurrentTab then
			return
		end
		local previous = Window.CurrentTab
		Window.CurrentTab = tab
		for _, other in ipairs(Window.Tabs) do
			local selected = other == tab
			if other.Selected ~= selected then
				other.Selected = selected
				Restyle(other.Button, 0.15)
				Restyle(other.Label, 0.15)
				local icon = other.Button:FindFirstChild("Icon")
				if icon then
					Restyle(icon, 0.15)
				end
			end
		end
		Window.PillMoving = previous ~= nil
		MovePill(previous ~= nil)
		task.delay(0.32, function()
			Window.PillMoving = false
			MovePill(false)
		end)

		if previous then
			previous.Page.Visible = false
		end
		tab.Page.Visible = true
		if CarBgImage then
			local isHome = (tab.Title == "Trang Chủ")
			CarBgImage.Visible = isHome
		end
		if previous then
			tab.Page.Position = UDim2.fromOffset(0, 10)
			Tween(tab.Page, { Position = UDim2.fromOffset(0, 0) }, 0.32, Enum.EasingStyle.Quint)
			PageFade.BackgroundTransparency = 0
			Tween(PageFade, { BackgroundTransparency = 1 }, 0.26, Enum.EasingStyle.Quad)
		end

		if not fromHistory then
			for i = #Window.History, Window.HistoryIndex + 1, -1 do
				table.remove(Window.History, i)
			end
			table.insert(Window.History, tab)
			Window.HistoryIndex = #Window.History
		end
		UpdateNavigation()
		UpdateToolbarDivider()
		EmptyState.Visible = Window.SearchQuery ~= "" and not tab.HasResults
		EmitState()
	end

	function Window:GoBack()
		if Window.HistoryIndex > 1 then
			Window.HistoryIndex = Window.HistoryIndex - (1)
			Window:SelectTab(Window.History[Window.HistoryIndex], true)
		end
	end

	function Window:GoForward()
		if Window.HistoryIndex < #Window.History then
			Window.HistoryIndex = Window.HistoryIndex + (1)
			Window:SelectTab(Window.History[Window.HistoryIndex], true)
		end
	end

	if BackButton then
		BackButton.MouseButton1Click:Connect(function()
			Window:GoBack()
		end)
	end
	if ForwardButton then
		ForwardButton.MouseButton1Click:Connect(function()
			Window:GoForward()
		end)
	end

	----------------------------------------------------------------------------
	-- Search
	----------------------------------------------------------------------------

	function Window:_ApplySearch()
		local query = Window.SearchQuery
		for _, tab in ipairs(Window.Tabs) do
			local count = tab:_ApplySearch(query)
			tab.HasResults = count > 0
			tab.Matches = query == "" or count > 0
			Restyle(tab.Label, 0.15)
		end
		local current = Window.CurrentTab
		if query ~= "" and current and not current.HasResults then
			for _, tab in ipairs(Window.Tabs) do
				if tab.HasResults then
					Window:SelectTab(tab)
					current = tab
					break
				end
			end
		end
		if EmptyState then
			EmptyState.Visible = query ~= "" and current ~= nil and not current.HasResults
		end
		if EmptyTitle and SearchBox then
			EmptyTitle.Text = "No Results for “" .. SearchBox.Text .. "”"
		end
	end

	function Window:Search(text)
		if SearchBox then
			SearchBox.Text = tostring(text or "")
		end
	end

	if SearchBox then
		local searchToken = 0
		SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			searchToken = searchToken + (1)
			local token = searchToken
			task.delay(0.08, function()
				if token ~= searchToken then
					return
				end
				Window.SearchQuery = SearchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
				Window:_ApplySearch()
			end)
		end)
		local function UpdateSearchChrome()
			local empty = SearchBox.Text == ""
			if SearchClear then
				SearchClear.Visible = not empty
			end
			if SpotlightHint then
				SpotlightHint.Visible = config.Spotlight ~= false and empty and not SearchBox:IsFocused() and
				(UserInputService.KeyboardEnabled or touchSpotlight)
			end
		end
		SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateSearchChrome)
		SearchBox.Focused:Connect(function()
			if SearchStroke then
				Tween(SearchStroke, { Transparency = 0.55 }, 0.15)
			end
			UpdateSearchChrome()
		end)
		SearchBox.FocusLost:Connect(function(enterPressed)
			if SearchStroke then
				Tween(SearchStroke, { Transparency = 1 }, 0.2)
			end
			UpdateSearchChrome()
			if enterPressed and SearchBox.Text ~= "" then
				Window.SearchQuery = SearchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
				Window:_ApplySearch()
				for _, row in ipairs(Window.CurrentTab and Window.CurrentTab.Rows or {}) do
					if row.Frame.Visible then
						Window:Reveal(row)
						break
					end
				end
			end
		end)
		if SearchClear then
			SearchClear.MouseButton1Click:Connect(function()
				SearchBox.Text = ""
			end)
		end
	end

	-- Scrolls a row (element, row or option index) into view and flashes it.
	function Window:Reveal(target)
		if type(target) == "string" then
			target = MacUI.Options[target]
		end
		local row = type(target) == "table" and (target.Row or target) or nil
		if not row or not row.Frame or row.Destroyed or row.Window ~= Window then
			return
		end
		if Window.Minimized then
			Window:Restore()
		end
		if not row.Frame.Visible and Window.SearchQuery ~= "" then
			if SearchBox then SearchBox.Text = "" end
			Window.SearchQuery = ""
			Window:_ApplySearch()
		end
		local block = row.Group and row.Group.Block
		if block and block.Collapsed and block.Section then
			block.Section:SetCollapsed(false)
		end
		Window:SelectTab(row.Tab)
		task.delay(0.08, function()
			local page = row.Tab.Page
			local scale = Window:GetAbsoluteScale()
			local top = (row.Frame.AbsolutePosition.Y - row.Tab.Content.AbsolutePosition.Y) / scale
			local view = page.AbsoluteSize.Y / scale
			local canvas = page.AbsoluteCanvasSize.Y / scale
			local goal = math.clamp(top - view * 0.3, 0, math.max(canvas - view, 0))
			Tween(page, { CanvasPosition = Vector2.new(0, goal) }, 0.35)
			task.delay(0.15, function()
				row:Flash()
			end)
		end)
	end

	----------------------------------------------------------------------------
	-- Sidebar collapse
	----------------------------------------------------------------------------

	function Window:SetSidebarVisible(visible)
		Window.SidebarVisible = visible ~= false
		local width = Window.SidebarVisible and sidebarWidth or 0
		if Window.SidebarVisible then
			Sidebar.Visible = true
		end
		Tween(Sidebar, { Size = UDim2.new(0, width, 1, -toolbarHeight - 38) }, 0.32)
		Tween(Main, { Position = UDim2.fromOffset(width > 0 and (width + 24) or 12, toolbarHeight + 2), Size = UDim2.new(1, width > 0 and (-width - 36) or -24, 1, -toolbarHeight - 38) }, 0.32)
		if Leading then
			Tween(Leading, { Position = UDim2.new(0, 12, 0.5, 0) }, 0.32)
		end
		if MainSquare then
			Restyle(MainSquare, 0.32)
		end
		EmitState()
		if not Window.SidebarVisible then
			task.delay(0.33, function()
				if not Window.SidebarVisible then
					Sidebar.Visible = false
				end
			end)
		end
	end

	function Window:ToggleSidebar()
		Window:SetSidebarVisible(not Window.SidebarVisible)
	end

	if SidebarButton then
		SidebarButton.MouseButton1Click:Connect(function()
			Window:ToggleSidebar()
		end)
	end

	----------------------------------------------------------------------------
	-- Dragging & resizing
	----------------------------------------------------------------------------

	local drag, resize
	local lastToolbarClick = 0
	local DragExclusions = { RightControls }
	local function OverControl(position)
		for _, gui in ipairs(DragExclusions) do
			if gui and gui.Parent and gui.Visible then
				local topLeft, extent = gui.AbsolutePosition, gui.AbsoluteSize
				if position.X >= topLeft.X
					and position.X <= topLeft.X + extent.X
					and position.Y >= topLeft.Y
					and position.Y <= topLeft.Y + extent.Y
				then
					return true
				end
			end
		end
		return false
	end
	local function BeginDrag(input)
		if not IsPointer(input) or OverControl(input.Position) then
			return
		end
		local now = os.clock()
		if now - lastToolbarClick < 0.35 then
			lastToolbarClick = 0
			Window:SetMaximized(not Window.Maximized)
			return
		end
		lastToolbarClick = now
		if not Window.Maximized then
			drag = { Start = input.Position, Position = Root.Position, Input = input }
		end
	end
	TopBar.InputBegan:Connect(BeginDrag)
	if Toolbar then
		Toolbar.InputBegan:Connect(BeginDrag)
	end
	if SidebarDrag then
		SidebarDrag.InputBegan:Connect(BeginDrag)
	end

	local Grip = New("TextButton", {
		Name = "ResizeGrip",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		-- a finger needs a bigger corner to grab than a mouse
		Size = TouchOnly() and UDim2.fromOffset(34, 34) or UDim2.fromOffset(18, 18),
		ZIndex = 30,
		Visible = config.Resizable ~= false,
		Parent = Root,
	})
	Grip.InputBegan:Connect(function(input)
		if IsPointer(input) and not Window.Maximized then
			resize = { Start = input.Position, Size = Window.Size, Position = Root.Position, Input = input }
		end
	end)

	Connect(UserInputService.InputChanged, function(input)
		if drag and not DragMoves(drag.Input, input) then
			return
		elseif resize and not DragMoves(resize.Input, input) then
			return
		end
		if drag then
			local delta = input.Position - drag.Start
			local viewport = ScreenGui.AbsoluteSize
			local start = drag.Position
			local x = math.clamp(start.X.Offset + delta.X, -viewport.X / 2 + 60, viewport.X / 2 - 60)
			local y = math.clamp(start.Y.Offset + delta.Y, -viewport.Y / 2 + 30, viewport.Y / 2 - 30)
			Root.Position = UDim2.new(start.X.Scale, x, start.Y.Scale, y)
		elseif resize then
			local delta = input.Position - resize.Start
			local scale = Window.Scale
			local width = math.max(resize.Size.X + delta.X / scale, minSize.X)
			local height = math.max(resize.Size.Y + delta.Y / scale, minSize.Y)
			Window.Size = Vector2.new(width, height)
			wantedSize = Window.Size
			Root.Size = UDim2.fromOffset(width, height)
			local grow = (Window.Size - resize.Size) * scale / 2
			Root.Position = resize.Position + UDim2.fromOffset(grow.X, grow.Y)
		end
	end)
	Connect(UserInputService.InputEnded, function(input)
		local active = drag or resize
		if active and DragEnds(active.Input, input) then
			EmitState()
			drag = nil
			resize = nil
		end
	end)

	----------------------------------------------------------------------------
	-- Window state: open / minimise / maximise / close
	----------------------------------------------------------------------------

	local function BeginTransition()
		AnimGroup.Visible = true
		AnimGroup.GroupTransparency = 0
		local _SH_unused = nil
	end

	local function EndTransition()
		if MacUI.Unloaded then
			return
		end
		Holder.Parent = Root
		AnimGroup.Visible = false
	end

	function Window:SetVisible(visible, instant)
		visible = visible ~= false
		Window.Shown = visible
		Window:_ClosePopup(true)
		HideTooltip()
		MouseUnlock.Visible = visible
		Root.Visible = visible
		if ScreenGui then
			ScreenGui.Enabled = true
			if not ScreenGui.Parent and not MacUI.Unloaded then
				ParentGui(ScreenGui)
			end
		end
	end

	local SendenLogoToggle = New("TextButton", {
		Name = "SendenLogoToggle",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = Color3.fromRGB(16, 16, 20),
		BackgroundTransparency = 0.08,
		Text = "",
		ZIndex = 200,
		Visible = true,
		Parent = ScreenGui,
	})
	Corner(SendenLogoToggle, 10)
	New("UIStroke", {
		Color = Color3.fromRGB(220, 35, 50),
		Thickness = 1.6,
		Transparency = 0.15,
		Parent = SendenLogoToggle,
	})
	local SendenLogoToggleImg = New("ImageLabel", {
		Name = "LogoImage",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -6, 1, -6),
		BackgroundTransparency = 1,
		Image = GetSendenLogoAsset(),
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 201,
		Parent = SendenLogoToggle,
	})
	Corner(SendenLogoToggleImg, 20)
	table.insert(Cleanup, function()
		if SendenLogoToggle and SendenLogoToggle.Parent then
			pcall(function() SendenLogoToggle:Destroy() end)
		end
	end)

	do
		local logoBeganInput = nil
		local logoMoved = false
		local logoDragStart = Vector2.zero
		local logoStartPos = UDim2.new()
		Connect(SendenLogoToggle.InputBegan, function(input)
			if not IsPointer(input) then return end
			logoBeganInput = input
			logoMoved = false
			logoDragStart = Vector2.new(input.Position.X, input.Position.Y)
			logoStartPos = SendenLogoToggle.Position
		end)
		Connect(UserInputService.InputChanged, function(input)
			if not logoBeganInput or not DragMoves(logoBeganInput, input) then return end
			local delta = Vector2.new(input.Position.X, input.Position.Y) - logoDragStart
			if delta.Magnitude >= 8 then
				logoMoved = true
			end
			if logoMoved then
				local vp = ScreenGui.AbsoluteSize
				local curX = (logoStartPos.X.Scale * vp.X) + logoStartPos.X.Offset
				local curY = (logoStartPos.Y.Scale * vp.Y) + logoStartPos.Y.Offset
				local nx = math.clamp(curX + delta.X, 4, math.max(4, vp.X - 52))
				local ny = math.clamp(curY + delta.Y, 4, math.max(4, vp.Y - 52))
				SendenLogoToggle.Position = UDim2.fromOffset(nx, ny)
			end
		end)
		Connect(UserInputService.InputEnded, function(input)
			if not logoBeganInput or not DragEnds(logoBeganInput, input) then return end
			logoBeganInput = nil
			if not logoMoved then
				Window:Toggle()
			end
		end)
	end

	function Window:Minimize()
		Window.Minimized = true
		Window:SetVisible(false)
		if Dock then Dock.Visible = false end
	end

	function Window:Restore()
		Window.Minimized = false
		Window:SetVisible(true)
		if Dock then Dock.Visible = false end
	end

	function Window:Toggle()
		if Window.Loading then
			return -- the loading card is still up
		end
		if Root.Visible then
			Window:Minimize()
		else
			Window:Restore()
		end
	end

	local restoreState
	function Window:SetMaximized(maximized)
		if maximized == Window.Maximized then
			return
		end
		Window.Maximized = maximized
		if maximized then
			restoreState = { Position = Root.Position }
			local viewport = ScreenGui.AbsoluteSize
			local target = Vector2.new((viewport.X - 24) / Window.Scale, (viewport.Y - 24) / Window.Scale)
			Window.Size = target
			Tween(Root, { Size = UDim2.fromOffset(target.X, target.Y), Position = UDim2.fromScale(0.5, 0.5) }, 0.38)
		elseif restoreState then
			-- (the screen may have changed while it was maximised)
			local fitted, position = FittedLayout(restoreState.Position)
			Window.Size = fitted
			Tween(Root, { Size = UDim2.fromOffset(fitted.X, fitted.Y), Position = position }, 0.38)
		end
		EmitState()
	end

	-- Position, size, tab and sidebar state (InterfaceManager saves this). The
	-- size is the one asked for, not what a small screen shrank it to.
	function Window:GetState()
		local position = Window.Maximized and restoreState and restoreState.Position or Root.Position
		return {
			X = position.X.Offset,
			Y = position.Y.Offset,
			Width = wantedSize.X,
			Height = wantedSize.Y,
			Tab = Window.CurrentTab and Window.CurrentTab.Title or nil,
			Sidebar = Window.SidebarVisible,
		}
	end

	function Window:ApplyState(state)
		if type(state) ~= "table" then
			return
		end
		local width, height = tonumber(state.Width), tonumber(state.Height)
		if width and height then
			wantedSize = Vector2.new(math.max(width, minSize.X), math.max(height, minSize.Y))
		end
		local x, y = tonumber(state.X), tonumber(state.Y)
		if Window.Maximized then
			-- applies when it's restored
			if x and y and restoreState then
				restoreState.Position = UDim2.new(0.5, x, 0.5, y)
			end
		else
			if x and y then
				Root.Position = UDim2.new(0.5, x, 0.5, y)
			end
			-- (saved on a bigger screen: it shrinks and stays in view)
			FitToScreen()
		end
		if state.Tab then
			for _, tab in ipairs(Window.Tabs) do
				if tab.Title == state.Tab then
					Window:SelectTab(tab)
					break
				end
			end
		end
		if state.Sidebar == false then
			Window:SetSidebarVisible(false)
		end
	end

	function Window:SetAcrylic(enabled)
		if MacUI.Unloaded then
			return false
		end
		if Guard.Engaged and not Guard.Applying and Guard.Saved then
			-- effects are paused: remember the choice for when they come back
			Guard.Saved.Acrylic[Window] = (enabled == true) or nil
			return enabled == true and AcrylicSupported()
		end
		enabled = enabled == true and AcrylicSupported()
		Window.Acrylic = enabled
		Restyle(SidebarGlass, 0.25)
		if enabled and not Window.Blur then
			local ok, blur = pcall(CreateAcrylic, Sidebar)
			if ok then
				Window.Blur = blur
				table.insert(Cleanup, function()
					blur:Destroy()
				end)
			else
				warn("[MacUI] acrylic unavailable: " .. tostring(blur))
				Window.Acrylic = false
				Restyle(SidebarGlass, 0)
			end
		end
		if Window.Blur then
			Window.Blur:SetEnabled(Window.Acrylic and Window.Shown and not Window.Minimized)
		end
		return Window.Acrylic
	end

	-- Frosted glass as the user set it, even while the performance guard has it paused.
	function Window:GetAcrylic()
		if Guard.Engaged and Guard.Saved then
			return Guard.Saved.Acrylic[Window] == true
		end
		return Window.Acrylic == true
	end

	function Window:SetTitle(text)
		Window.Title = tostring(text)
		TitleLabel.Text = Window.Title
		DockTip.Text = Window.Title
		FitTitles()
	end

	function Window:SetSubtitle(text)
		Window.SubTitle = tostring(text or "")
		SubtitleLabel.Text = Window.SubTitle
		SubtitleLabel.Visible = Window.SubTitle ~= ""
		FitTitles()
	end

	Window.SetSubTitle = Window.SetSubtitle

	function Window:SetMinimizeKey(key)
		if key == "None" or key == false then
			Window.MinimizeKey = nil
			return
		end
		if type(key) == "string" then
			local ok, keycode = pcall(function()
				return Enum.KeyCode[key]
			end)
			key = ok and keycode or nil
		end
		if typeof(key) == "EnumItem" then
			Window.MinimizeKey = key
		end
	end

	function Window:Notify(options)
		return MacUI:Notify(options)
	end

	----------------------------------------------------------------------------
	-- Dialog (macOS alert)
	----------------------------------------------------------------------------

	function Window:Dialog(options)
		options = options or {}
		Window:_ClosePopup(true)
		if Window.CloseSpotlight then
			Window:CloseSpotlight() -- the dialog needs to be on top
		end
		local dialog = { Closed = false }
		local overlay = New("TextButton", {
			Name = "Dialog",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 40,
			Theme = { BackgroundColor3 = "Dim" },
			Parent = Holder,
		})
		Corner(overlay, 12)
		local panelWidth = 280
		local panelHolder = New("Frame", {
			Name = "Panel",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.48),
			Size = UDim2.fromOffset(panelWidth, 200),
			ZIndex = 41,
			Parent = overlay,
		})
		local panelScale = New("UIScale", { Scale = 1.08, Parent = panelHolder })
		local panelShadow = Shadow(panelHolder, 12, function(t)
			return dialog.Closed and 1 or t.ShadowTransparency
		end)
		panelShadow.ImageTransparency = 1
		local panel = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			GroupTransparency = 1,
			ZIndex = 2,
			Theme = { BackgroundColor3 = "Menu" },
			Parent = panelHolder,
		})
		Corner(panel, 14)
		local border = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(1, 1),
			Size = UDim2.new(1, -2, 1, -2),
			ZIndex = 20,
			Parent = panel,
		})
		Corner(border, 13)
		Stroke(border, "MenuStroke", 1, 0.1)
		local body = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = panel,
		})
		Padding(body, 20, 18, 16, 18)
		List(body, nil, 6, { HorizontalAlignment = Enum.HorizontalAlignment.Center })

		IconTile(body, options.Icon or config.Icon or "command",
			ResolveColor(options.IconColor or config.IconColor) or function()
				return MacUI.Accent
			end, 52, 13, 28, { LayoutOrder = 1 })
		New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 4), LayoutOrder = 2, Parent = body })
		New("TextLabel", {
			Text = tostring(options.Title or "Alert"),
			TextSize = 15,
			Weight = Enum.FontWeight.Bold,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = 3,
			Theme = { TextColor3 = "Text" },
			Parent = body,
		})
		if options.Content and options.Content ~= "" then
			New("TextLabel", {
				Text = tostring(options.Content),
				TextSize = 13,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true,
				RichText = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = 4,
				Theme = {
					TextColor3 = function(t)
						return t.Text:Lerp(t.SubText, 0.3)
					end
				},
				Parent = body,
			})
		end
		local inputBox
		if options.Input then
			local spec = type(options.Input) == "table" and options.Input or {}
			New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 4), LayoutOrder = 5, Parent = body })
			local field = New("Frame", {
				Name = "Field",
				Size = UDim2.new(1, 0, 0, 28),
				LayoutOrder = 6,
				Theme = { BackgroundColor3 = "Field" },
				Parent = body,
			})
			Corner(field, 6)
			local fieldStroke = Stroke(field, "FieldStroke")
			inputBox = New("TextBox", {
				Name = "Input",
				Text = tostring(spec.Default or ""),
				PlaceholderText = spec.Placeholder or "",
				TextSize = 13,
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -16, 1, 0),
				ClipsDescendants = true,
				Theme = { TextColor3 = "Text", PlaceholderColor3 = "Tertiary" },
				Parent = field,
			})
			inputBox.Focused:Connect(function()
				Themed(fieldStroke, { Color = "Accent" })
			end)
			inputBox.FocusLost:Connect(function()
				Themed(fieldStroke, { Color = "FieldStroke" })
			end)
			dialog.Input = inputBox
			task.defer(function()
				if inputBox.Parent then
					inputBox:CaptureFocus()
				end
			end)
		end
		New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 8), LayoutOrder = 7, Parent = body })

		local buttons = options.Buttons or { { Title = "OK" } }
		local row = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 8,
			Parent = body,
		})
		local stacked = #buttons > 2
		List(row, stacked and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal, 8, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})

		function dialog:Close()
			if dialog.Closed then
				return
			end
			dialog.Closed = true
			Tween(panel, { GroupTransparency = 1 }, 0.15)
			Restyle(panelShadow, 0.15)
			Tween(panelScale, { Scale = 0.96 }, 0.15)
			Tween(overlay, { BackgroundTransparency = 1 }, 0.2)
			task.delay(0.21, function()
				overlay:Destroy()
			end)
		end

		local count = #buttons
		local buttonWidth = stacked and (panelWidth - 36) or math.floor((panelWidth - 36 - 8 * (count - 1)) / count)
		for index, spec in ipairs(buttons) do
			local primary = index == 1
			local style = spec.Style or (primary and "Primary" or "Default")
			local push = PushButton(row, spec.Title or "OK", style, 28)
			push.Instance.AutomaticSize = Enum.AutomaticSize.None
			push.Instance.Size = UDim2.fromOffset(buttonWidth, 28)
			push.Instance.TextSize = 13
			push.Instance.LayoutOrder = stacked and index or (count - index + 1)
			push.Instance.MouseButton1Click:Connect(function()
				if dialog.Closed then
					return
				end
				dialog:Close()
				Spawn(spec.Callback, inputBox and inputBox.Text or nil)
			end)
		end
		if inputBox and buttons[1] then
			inputBox.FocusLost:Connect(function(enterPressed)
				if enterPressed and not dialog.Closed then
					dialog:Close()
					Spawn(buttons[1].Callback, inputBox.Text)
				end
			end)
		end

		panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			panelHolder.Size = UDim2.fromOffset(panelWidth, panel.AbsoluteSize.Y / (RootScale.Scale * panelScale.Scale))
		end)

		Tween(overlay, { BackgroundTransparency = MacUI.ThemeData.DimTransparency }, 0.2)
		Tween(panel, { GroupTransparency = 0 }, 0.18)
		Restyle(panelShadow, 0.25)
		Tween(panelScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
		return dialog
	end

	----------------------------------------------------------------------------
	-- Traffic light actions, dock, keyboard shortcut
	----------------------------------------------------------------------------

	local LightActions = {
		Close = function()
			if config.ConfirmClose == false then
				MacUI:Destroy()
				return
			end
			Window:Dialog({
				Title = "Close " .. Window.Title .. "?",
				Content = "This unloads the interface. Your scripts keep running until you rejoin.",
				Icon = "power",
				IconColor = rgb(255, 69, 58),
				Buttons = {
					{
						Title = "Close",
						Style = "Destructive",
						Callback = function()
							MacUI:Destroy()
						end
					},
					{ Title = "Cancel" },
				},
			})
		end,
		Minimize = function()
			Window:Minimize()
		end,
		Zoom = function()
			Window:SetMaximized(not Window.Maximized)
		end,
	}
	for name, action in pairs(LightActions) do
		LightButtons[name].MouseButton1Click:Connect(action)
		if LightTargets[name] then
			LightTargets[name].MouseButton1Click:Connect(action)
		end
	end

	Dock.MouseEnter:Connect(function()
		DockTip.Visible = true
		Tween(DockScale, { Scale = Window.Scale * 1.08 }, 0.2, Enum.EasingStyle.Back)
	end)
	Dock.MouseLeave:Connect(function()
		DockTip.Visible = false
		Tween(DockScale, { Scale = Window.Scale }, 0.2)
	end)
	Dock.MouseButton1Click:Connect(function()
		Window:Restore()
	end)

	----------------------------------------------------------------------------
	-- Spotlight (Ctrl/Cmd + K): find any setting, toggle or action and run it
	----------------------------------------------------------------------------

	local Spotlight = { Open = false }

	local function EntryValue(entry)
		if entry.Kind == "Tab" then
			return "Open"
		elseif entry.Kind == "Action" then
			return entry.ValueText
		elseif entry.Kind == "Command" then
			return entry.Command.Shortcut and KeyName(entry.Command.Shortcut) or "Run"
		end
		local element = entry.Element
		if not element or element.Type == "Paragraph" or element.Type == "Code" or element.Type == "Image" then
			return nil
		elseif element.Type == "Button" then
			if entry.Row.Disabled then
				return nil
			end
			if entry.Row.Timer then
				return "Run · " .. FormatClock(entry.Row.Timer.Ends - os.clock())
			end
			return "Run"
		end
		local ok, text = pcall(element.GetText, element)
		if entry.Row.Timer then
			return (ok and text and (text .. " · ") or "") .. FormatClock(entry.Row.Timer.Ends - os.clock())
		end
		return ok and text or nil
	end

	local function CollectEntries()
		local entries = {}
		for tabIndex, tab in ipairs(Window.Tabs) do
			table.insert(entries, {
				Kind = "Tab",
				Tab = tab,
				Title = tab.Title,
				Subtitle = tab.Description and tostring(tab.Description) or "Page",
				TitleLower = tab.Title:lower(),
				Search = (tab.Title .. " " .. tostring(tab.Description or "")):lower(),
				Order = tabIndex * 10000,
			})
			if tabIndex == 1 then
				for index, command in ipairs(Window.Commands) do
					table.insert(entries, {
						Kind = "Command",
						Command = command,
						Title = command.Title,
						Subtitle = command.Description or "Command",
						TitleLower = command.Title:lower(),
						Search = (tostring(command.Description or "") .. " " .. command.Keywords):lower(),
						Order = 5000 + index,
						Icon = command.Icon,
						TileColor = command.TileColor,
						UsageKey = "c:" .. command.Title,
					})
				end
			end
			for rowIndex, row in ipairs(tab.Rows) do
				if row.Title ~= "" and row:_IsShown() and not row.Destroyed then
					local section = row.Group.Block and row.Group.Block.Title
					table.insert(entries, {
						Kind = "Row",
						Row = row,
						Element = row.Element,
						Tab = tab,
						Title = row.Title,
						Subtitle = (section and section ~= "") and (tab.Title .. " › " .. section) or tab.Title,
						TitleLower = row.Title:lower(),
						Search = (row.Description .. " " .. row.Keywords .. " " .. tab.Title .. " " .. (section or ""))
						:lower(),
						Order = tabIndex * 10000 + rowIndex,
						UsageKey = row.Element and UsageKey(row.Element) or nil,
					})
				end
			end
		end
		return entries
	end

	local function Fuzzy(haystack, needle)
		local position = 1
		for i = 1, #needle do
			local found = haystack:find(needle:sub(i, i), position, true)
			if not found then
				return false
			end
			position = found + 1
		end
		return true
	end

	local function Score(entry, query)
		local title = entry.TitleLower
		if title == query then
			return 100
		elseif title:sub(1, #query) == query then
			return 90
		end
		local start = title:find(query, 1, true)
		if start then
			return title:sub(start - 1, start - 1):match("[%s%p]") and 80 or 70
		elseif entry.Search:find(query, 1, true) then
			return 50
		elseif #query >= 2 and Fuzzy(title, query) then
			return 30
		end
		return 0
	end

	----------------------------------------------------------------------------
	-- Spotlight actions: type what you want done. "walk speed 50", "auto farm
	-- off", "difficulty hard", "fill red", "name = Bob", "auto farm off in 30m",
	-- "collect every 10s", "reset fov", "play routine", "light mode", "undo"
	----------------------------------------------------------------------------

	local ON_WORDS = { on = true, enable = true, enabled = true, yes = true, ["true"] = true }
	local OFF_WORDS = { off = true, disable = true, disabled = true, no = true, ["false"] = true }
	local COLOR_WORDS = {
		red = rgb(255, 69, 58),
		orange = rgb(255, 159, 10),
		yellow = rgb(255, 214, 10),
		green = rgb(48, 209, 88),
		mint = rgb(99, 230, 226),
		teal = rgb(64, 200, 224),
		cyan = rgb(100, 210, 255),
		blue = rgb(10, 132, 255),
		indigo = rgb(94, 92, 230),
		purple = rgb(191, 90, 242),
		pink = rgb(255, 55, 95),
		brown = rgb(172, 142, 104),
		white = rgb(255, 255, 255),
		black = rgb(0, 0, 0),
		gray = rgb(142, 142, 147),
		grey = rgb(142, 142, 147),
	}
	-- checked in order: "turn on " before "turn "
	local ACTION_VERBS = {
		{ "turn on ",    "on" },
		{ "turn off ",   "off" },
		{ "switch on ",  "on" },
		{ "switch off ", "off" },
		{ "enable ",     "on" },
		{ "disable ",    "off" },
		{ "toggle ",     "toggle" },
		{ "reset ",      "reset" },
		{ "run ",        "run" },
		{ "press ",      "run" },
		{ "click ",      "run" },
		{ "repeat ",     "run" },
		{ "play ",       "play" },
		{ "set ",        "set" },
		{ "turn ",       "turn" },
		{ "switch ",     "turn" },
	}
	local SUGGESTABLE = {
		Toggle = true,
		Slider = true,
		Dropdown = true,
		Input = true,
		Keybind = true,
		Colorpicker = true,
		Segmented = true,
		Stepper = true,
		Radio = true,
		Button = true,
		Macro = true,
	}

	local function Location(row, tab)
		local section = row.Group.Block and row.Group.Block.Title
		return (section and section ~= "") and (tab.Title .. " › " .. section) or tab.Title
	end

	-- The controls a phrase names. Only title matches of a whole word or more
	-- count, and only the best of them: Enter runs the first action, so a
	-- partial match ("lights" in "Highlights") must never become one.
	local function FindControls(name)
		local found, best = {}, 0
		if #name < 2 then
			return found
		end
		for tabIndex, tab in ipairs(Window.Tabs) do
			for rowIndex, row in ipairs(tab.Rows) do
				if row.Element and row.Title ~= "" and not row.Destroyed and not row.Disabled and row:_IsShown() then
					local score = Score({ TitleLower = row.Title:lower(), Search = "" }, name)
					if score >= 80 and score >= best then
						if score > best then
							table.clear(found)
							best = score
						end
						table.insert(found, {
							Element = row.Element,
							Row = row,
							Tab = tab,
							Score = score,
							Order = tabIndex * 10000 + rowIndex,
						})
					end
				end
			end
		end
		return found
	end

	-- What `text` means for this control ("50", "off", "hard", "red"), or nil.
	-- Text fields only take a value from an explicit "name = value".
	local function Interpret(element, text, raw, explicit)
		local kind = element.Type
		if kind == "Toggle" then
			if ON_WORDS[text] then
				return true
			elseif OFF_WORDS[text] then
				return false
			end
		elseif kind == "Slider" or kind == "Stepper" then
			local min, max = tonumber(element.Min), tonumber(element.Max)
			if (text == "max" or text == "maximum") and max then
				return max
			elseif (text == "min" or text == "minimum") and min then
				return min
			end
			local number = tonumber(text:match("^(%-?%d*%.?%d+)%s*[^%d%s]*$"))
			if number then
				return (min and max) and math.clamp(number, min, max) or number
			end
		elseif kind == "Dropdown" or kind == "Segmented" or kind == "Radio" then
			local prefix, count = nil, 0
			for _, option in ipairs(element.Values or {}) do
				local lower = tostring(option):lower()
				if lower == text then
					return option
				elseif #text >= 2 and lower:sub(1, #text) == text then
					prefix, count = option, count + 1
				end
			end
			if count == 1 then
				return prefix
			end
		elseif kind == "Colorpicker" then
			if COLOR_WORDS[text] then
				return COLOR_WORDS[text]
			end
			local hex = text:match("^#?(%x%x%x%x%x%x)$")
			if hex then
				return Color3.fromHex(hex)
			end
		elseif kind == "Input" and explicit and raw ~= "" then
			return raw
		end
		return nil
	end

	local function Describe(element, value)
		if typeof(value) == "Color3" then
			return "#" .. value:ToHex():upper()
		elseif type(value) == "number" then
			return tostring(Round(value, 3)) .. tostring(element.Suffix or "")
		end
		return tostring(value)
	end

	local function NewAction(match, title, icon, valueText, run)
		local element, row = match.Element, match.Row
		local ok, current = pcall(element.GetText, element)
		local now = (ok and current and current ~= "") and ("  ·  now " .. tostring(current)) or ""
		return {
			Kind = "Action",
			Key = tostring(row) .. "|" .. title,
			Row = row,
			Element = element,
			Tab = match.Tab,
			Title = title,
			Subtitle = Location(row, match.Tab) .. now,
			Icon = icon or "wand-2",
			TileColor = function()
				return MacUI.Accent
			end,
			ValueText = valueText,
			Score = match.Score,
			Order = match.Order,
			Run = run,
		}
	end

	-- "Set X to V", "Turn off X", "Add V to X"; nil when nothing would change.
	local function ValueAction(match, value)
		local element, title = match.Element, match.Row.Title
		local kind = element.Type
		if kind == "Toggle" then
			if element.Value == value then
				return nil
			end
			return NewAction(match, "Turn " .. (value and "on " or "off ") .. title,
				value and "toggle-right" or "toggle-left", "Apply", function()
				element:SetValue(value)
				return title, value and "On" or "Off"
			end)
		elseif kind == "Dropdown" and element.Multi then
			local has = element.Value[value] == true
			local phrase = has and ("Remove " .. tostring(value) .. " from ") or ("Add " .. tostring(value) .. " to ")
			return NewAction(match, phrase .. title, "list-checks", "Apply", function()
				local set = table.clone(element.Value)
				set[value] = (not has) or nil
				element:SetValue(set)
				return title, element:GetText()
			end)
		elseif kind == "Colorpicker" then
			return NewAction(match, "Set " .. title .. " to " .. Describe(element, value), "palette", "Apply", function()
				element:SetValueRGB(value)
				return title, Describe(element, value)
			end)
		end
		if SameValue(element.Value, value) then
			return nil
		end
		return NewAction(match, "Set " .. title .. " to " .. Describe(element, value), nil, "Apply", function()
			element:SetValue(value)
			return title, element:GetText()
		end)
	end

	-- "Turn off X in 30 min" (value nil flips it)
	local function TimerAction(match, value, seconds)
		local element, title = match.Element, match.Row.Title
		if element.Type ~= "Toggle" then
			return nil
		end
		if value == nil then
			value = not element.Value
		end
		if value == element.Value then
			return nil
		end
		local when = DescribeDuration(seconds)
		return NewAction(match, "Turn " .. (value and "on " or "off ") .. title .. " in " .. when, "timer", "Start",
			function()
				element:SetTimer(seconds, value)
				return title, (value and "on" or "off") .. " in " .. when
			end)
	end

	-- "Press X every 10 s"
	local function RepeatAction(match, seconds)
		local element, title = match.Element, match.Row.Title
		if element.Type ~= "Button" then
			return nil
		end
		local every = DescribeDuration(seconds)
		return NewAction(match, "Press " .. title .. " every " .. every, "repeat", "Start", function()
			element:SetRepeat(seconds)
			return title, "every " .. every
		end)
	end

	local function WindowAction(key, title, subtitle, icon, run)
		return {
			Kind = "Action",
			Key = key,
			Title = title,
			Subtitle = subtitle,
			Icon = icon,
			TileColor = function()
				return MacUI.Accent
			end,
			Score = 100,
			Run = run,
		}
	end

	local function ParseActions(input)
		local raw = input:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
		local text = raw:lower()
		local actions, seen = {}, {}
		local function Add(action)
			if action and not seen[action.Key] then
				seen[action.Key] = true
				table.insert(actions, action)
			end
		end
		local function Done()
			table.sort(actions, function(a, b)
				if (a.Score or 0) ~= (b.Score or 0) then
					return (a.Score or 0) > (b.Score or 0)
				end
				return (a.Order or 0) < (b.Order or 0)
			end)
			while #actions > 3 do
				table.remove(actions)
			end
			return actions
		end
		if #text < 3 then
			return actions
		end

		-- the window itself: "light mode", "theme ocean", "accent purple", "undo"
		local themeWord = text:match("^(.+) theme$")
			or text:match("^(.+) mode$")
			or text:match("^theme (.+)$")
			or text:match("^switch to (.+)$")
		if themeWord then
			for _, name in ipairs(MacUI:GetThemes()) do
				if name:lower() == themeWord and name ~= MacUI.ThemeName then
					Add(WindowAction("theme:" .. name, "Switch to the " .. name .. " theme", "Appearance", "palette",
						function()
							MacUI:SetTheme(name)
							return "Theme", name
						end))
				end
			end
		end
		local accentWord = text:match("^accent (.+)$") or text:match("^(.+) accent$")
		if accentWord then
			for _, name in ipairs(MacUI.AccentOrder) do
				if name:lower() == accentWord and MacUI.Accents[name] ~= MacUI.Accent then
					Add(WindowAction("accent:" .. name, "Use " .. name .. " as the accent colour", "Appearance",
						"palette", function()
						MacUI:SetAccent(name)
						return "Accent", name
					end))
				end
			end
		end
		if text == "undo" and MacUI:CanUndo() then
			Add(WindowAction("undo", "Undo the last change", "Ctrl + Z", "undo-2", function()
				MacUI:Undo()
			end))
		elseif text == "redo" and MacUI:CanRedo() then
			Add(WindowAction("redo", "Redo the last change", "Ctrl + Shift + Z", "redo-2", function()
				MacUI:Redo()
			end))
		elseif (text == "cancel timers" or text == "stop timers") and next(ActiveTimers) ~= nil then
			Add(WindowAction("timers", "Cancel every timer", "Timers and repeats", "timer-off", function()
				MacUI:CancelTimers()
				return "Timers", "Cancelled"
			end))
		end

		-- "name = value" or "name: value": everything after the sign is the
		-- value, word for word ("status = back in 5" keeps its "in 5"). A colon
		-- needs a space after it, so titles like "Window:Minimize" stay titles.
		local name, at = text:match("^(.-)%s*=%s*()%S")
		if not name or name == "" then
			name, at = text:match("^(.-):%s+()%S")
		end
		if name and name ~= "" then
			name = name:gsub("^set ", "")
			local value, rawValue = text:sub(at), raw:sub(at)
			for _, match in ipairs(FindControls(name)) do
				local parsed = Interpret(match.Element, value, rawValue, true)
				if parsed ~= nil then
					Add(ValueAction(match, parsed))
				end
			end
			return Done()
		end

		-- "... in 20m" / "... after 1h" (a toggle timer), "... every 30s" (a
		-- repeat); the last "in" counts, so "sign in bonus off in 5m" works
		local first, last = 1, #text
		local timing, seconds
		local head, rest = text:match("^(.*) in (.+)$")
		if not head then
			head, rest = text:match("^(.*) after (.+)$")
		end
		local duration = head and head ~= "" and ParseDuration(rest, "m")
		if duration then
			timing, seconds, last = "in", duration, #head
		else
			head, rest = text:match("^(.*) every (.+)$")
			duration = head and head ~= "" and ParseDuration(rest, "s")
			if duration then
				timing, seconds, last = "every", duration, #head
			end
		end

		-- a leading verb: "turn off", "enable", "reset", "run", "play", "set"...
		local verb
		for _, spec in ipairs(ACTION_VERBS) do
			if text:sub(1, #spec[1]) == spec[1] and #spec[1] < last then
				verb, first = spec[2], #spec[1] + 1
				break
			end
		end
		local body = text:sub(first, last)
		local rawBody = raw:sub(first, last)

		-- Anything a verb can't do with a time ("press x in 5m") is left out
		-- rather than done straight away.
		if verb == "on" or verb == "off" or verb == "toggle" then
			if timing ~= "every" then
				for _, match in ipairs(FindControls(body)) do
					local element = match.Element
					if element.Type == "Toggle" then
						local value
						if verb == "toggle" then
							value = not element.Value
						else
							value = verb == "on"
						end
						if timing == "in" then
							Add(TimerAction(match, value, seconds))
						else
							Add(ValueAction(match, value))
						end
					end
				end
			end
		elseif verb == "reset" then
			if timing == nil then
				for _, match in ipairs(FindControls(body)) do
					local element = match.Element
					if (element.Default ~= nil or element._Reset) and not element:IsDefault() then
						Add(NewAction(match, "Reset " .. match.Row.Title, "rotate-ccw", "Reset", function()
							element:Reset()
							return match.Row.Title, "Reset"
						end))
					end
				end
			end
		elseif verb == "run" then
			for _, match in ipairs(FindControls(body)) do
				local element = match.Element
				if element.Type == "Button" then
					if timing == "every" then
						Add(RepeatAction(match, seconds))
					elseif timing == nil then
						Add(NewAction(match, "Press " .. match.Row.Title, "play", "Run", function()
							element:Fire()
							return match.Row.Title, nil
						end))
					end
				end
			end
			if timing == nil and #body >= 3 then
				for index, command in ipairs(Window.Commands) do
					local score = Score({ TitleLower = command.Title:lower(), Search = "" }, body)
					if score >= 80 then
						local entry = WindowAction("command:" .. command.Title, "Run " .. command.Title,
							command.Description or "Command", command.Icon, function()
							command:Run(true)
						end)
						entry.TileColor = command.TileColor
						entry.Score = score
						entry.Order = index
						Add(entry)
					end
				end
			end
		elseif verb == "play" then
			if timing == nil then
				for _, match in ipairs(FindControls(body)) do
					local element = match.Element
					if element.Type == "Macro" and #element.Steps > 0 then
						Add(NewAction(match, (element.Playing and "Stop " or "Play ") .. match.Row.Title, "play", "Play",
							function()
								element:_Activate(true)
							end))
					end
				end
			end
		end

		if (verb == nil or verb == "set" or verb == "turn") and timing ~= "every" then
			local function Offer(match, parsed)
				if timing == "in" then
					Add(TimerAction(match, parsed, seconds)) -- toggles only
				else
					Add(ValueAction(match, parsed))
				end
			end
			-- "walk speed to 50"; "set nickname to Bob" fills a text field too
			local toName, toAt = body:match("^(.-) to ()%S")
			if toName and toName ~= "" then
				local value, rawValue = body:sub(toAt), rawBody:sub(toAt)
				for _, match in ipairs(FindControls(toName)) do
					local parsed = Interpret(match.Element, value, rawValue, verb == "set")
					if parsed ~= nil then
						Offer(match, parsed)
					end
				end
			end
			-- "walk speed 50", "auto farm off", "difficulty hard", "fill red"
			local words = {}
			for word in body:gmatch("%S+") do
				table.insert(words, word)
			end
			for split = #words - 1, math.max(#words - 3, 1), -1 do
				local controlName = table.concat(words, " ", 1, split)
				local value = table.concat(words, " ", split + 1)
				for _, match in ipairs(FindControls(controlName)) do
					local parsed = Interpret(match.Element, value, value, false)
					if parsed ~= nil then
						Offer(match, parsed)
					end
				end
			end
		end
		-- "auto farm in 30m" flips it later; "collect every 10s" presses it
		if verb == nil and timing == "in" then
			for _, match in ipairs(FindControls(body)) do
				Add(TimerAction(match, nil, seconds))
			end
		elseif verb == nil and timing == "every" then
			for _, match in ipairs(FindControls(body)) do
				Add(RepeatAction(match, seconds))
			end
		end
		return Done()
	end

	local function Heading(title)
		return { Kind = "Header", Title = title }
	end

	local function SpotlightSearch(text)
		local query = text:lower():gsub("^%s+", ""):gsub("%s+$", "")
		local entries = CollectEntries()
		local results = {}
		if query == "" then
			-- what you use most, then pages and commands
			local suggestions = {}
			for _, entry in ipairs(entries) do
				local suggestable = entry.Kind == "Command" or
				(entry.Kind == "Row" and entry.Element and SUGGESTABLE[entry.Element.Type])
				if suggestable then
					entry.Frecency = Frecency(entry.UsageKey)
					if entry.Frecency > 0 then
						table.insert(suggestions, entry)
					end
				end
			end
			table.sort(suggestions, function(a, b)
				if a.Frecency ~= b.Frecency then
					return a.Frecency > b.Frecency
				end
				return a.Order < b.Order
			end)
			while #suggestions > 4 do
				table.remove(suggestions)
			end
			local suggested = {}
			if #suggestions > 0 then
				table.insert(results, Heading("Suggestions"))
				for _, entry in ipairs(suggestions) do
					suggested[entry] = true
					table.insert(results, entry)
				end
			end
			local pages, commands = {}, {}
			for _, entry in ipairs(entries) do
				if entry.Kind == "Tab" then
					table.insert(pages, entry)
				elseif entry.Kind == "Command" and not suggested[entry] then
					table.insert(commands, entry)
				end
			end
			-- headings only when there's more than the list of pages
			local headed = #suggestions > 0 or #commands > 0
			if headed then
				table.insert(results, Heading("Pages"))
			end
			for _, entry in ipairs(pages) do
				table.insert(results, entry)
			end
			if #commands > 0 then
				table.insert(results, Heading("Commands"))
				for _, entry in ipairs(commands) do
					table.insert(results, entry)
				end
			end
			return results
		end

		local matches = {}
		for _, entry in ipairs(entries) do
			local score = Score(entry, query)
			if score > 0 then
				entry.Score = score
				entry.Frecency = Frecency(entry.UsageKey)
				table.insert(matches, entry)
			end
		end
		table.sort(matches, function(a, b)
			if a.Score ~= b.Score then
				return a.Score > b.Score
			elseif (a.Kind == "Tab") ~= (b.Kind == "Tab") then
				return a.Kind == "Tab" -- pages first on a tie
			elseif a.Frecency ~= b.Frecency then
				return a.Frecency > b.Frecency -- then what you use most
			end
			return a.Order < b.Order
		end)
		while #matches > 40 do
			table.remove(matches)
		end
		local actions = ParseActions(text)
		if #actions == 0 then
			return matches
		end
		if matches[1] and matches[1].Score == 100 then
			-- an exact title stays first, so Enter does what it always did
			table.insert(results, Heading("Results"))
			for _, entry in ipairs(matches) do
				table.insert(results, entry)
			end
			table.insert(results, Heading("Actions"))
			for _, action in ipairs(actions) do
				table.insert(results, action)
			end
			return results
		end
		table.insert(results, Heading("Actions"))
		for _, action in ipairs(actions) do
			table.insert(results, action)
		end
		if #matches > 0 then
			table.insert(results, Heading("Results"))
			for _, entry in ipairs(matches) do
				table.insert(results, entry)
			end
		end
		return results
	end

	-- `query` (optional) starts Spotlight with that text typed in.
	function Window:OpenSpotlight(query)
		if Spotlight.Open or MacUI.Unloaded or config.Spotlight == false then
			return
		end
		if Window.Minimized then
			Window:Restore()
		end
		Window:_ClosePopup(true)
		HideTooltip()
		Spotlight.Open = true
		local scale = Window.Scale
		local width, searchHeight, itemHeight, maxVisible = 580, 54, 46, 7
		local headerHeight = 26
		local results, items, rendered, selected, visibleHeight = {}, {}, {}, 1, 0
		local pointerMoved, renderMouse = false, MousePosition()
		local connections = {}

		local overlay = New("TextButton", {
			Name = "Spotlight",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 300,
			Parent = PopupLayer,
		})
		InterfaceRoots[overlay] = true
		-- centred over the window, just under its toolbar, kept on screen
		local screen = PopupLayer.AbsoluteSize
		local rootPosition = Root.AbsolutePosition - PopupLayer.AbsolutePosition
		local rootSize = Root.AbsoluteSize
		local half = width * scale / 2
		local centerX = math.clamp(rootPosition.X + rootSize.X / 2, half + 8, math.max(half + 8, screen.X - half - 8))
		local top = math.clamp(rootPosition.Y + 44 * RootScale.Scale, 8,
			math.max(8, screen.Y - (searchHeight + maxVisible * itemHeight + 2 * headerHeight + 20) * scale))
		local holder = New("Frame", {
			Name = "Panel",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromOffset(centerX, top),
			Size = UDim2.fromOffset(width, searchHeight),
			ZIndex = 301,
			Parent = overlay,
		})
		local panelScale = New("UIScale", { Scale = scale * 0.96, Parent = holder })
		local sink = New("TextButton", { Name = "Sink", Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = holder })
		local shadow = Shadow(holder, 10, function(t)
			return Spotlight.Open and t.ShadowTransparency or 1
		end)
		shadow.ImageTransparency = 1
		local panel = New("Frame", {
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			GroupTransparency = 1,
			ZIndex = 2,
			Theme = { BackgroundColor3 = "Menu" },
			Parent = holder,
		})
		Corner(panel, 16)
		local border = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(1, 1),
			Size = UDim2.new(1, -2, 1, -2),
			ZIndex = 50,
			Parent = panel,
		})
		Corner(border, 15)
		Stroke(border, "MenuStroke", 1, 0.1)
		IconImage({
			Icon = "search",
			IconSize = 20,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 18, 0, searchHeight / 2),
			Theme = { ImageColor3 = "SubText" },
			Parent = panel,
		})
		local box = New("TextBox", {
			Name = "Query",
			Text = type(query) == "string" and query or "",
			PlaceholderText = "Search, or type a setting and a value",
			TextSize = 19,
			Position = UDim2.fromOffset(50, 0),
			Size = UDim2.new(1, -110, 0, searchHeight),
			ClipsDescendants = true,
			Theme = { TextColor3 = "Text", PlaceholderColor3 = "Tertiary" },
			Parent = panel,
		})
		local escHint = New("TextLabel", {
			Text = "esc",
			TextSize = 11,
			Weight = Enum.FontWeight.Medium,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -16, 0, searchHeight / 2),
			Size = UDim2.fromOffset(32, 18),
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 0,
			Theme = { BackgroundColor3 = "Control", TextColor3 = "SubText" },
			Parent = panel,
		})
		Corner(escHint, 5)
		local divider = New("Frame", {
			Name = "Divider",
			Position = UDim2.fromOffset(0, searchHeight),
			Size = UDim2.new(1, 0, 0, 1),
			Visible = false,
			Theme = { BackgroundColor3 = "Separator" },
			Parent = panel,
		})
		local list = New("ScrollingFrame", {
			Name = "Results",
			Position = UDim2.fromOffset(0, searchHeight + 1),
			Size = UDim2.new(1, 0, 1, -(searchHeight + 1)),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.4,
			VerticalScrollBarInset = Enum.ScrollBarInset.None,
			Theme = { ScrollBarImageColor3 = "Scrollbar" },
			Parent = panel,
		})
		local listContent = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = list,
		})
		Padding(listContent, 6, 8, 6, 8)
		List(listContent, nil, 0)
		local empty = New("TextLabel", {
			Name = "Empty",
			Text = "No Results",
			TextSize = 13,
			Size = UDim2.new(1, 0, 0, 40),
			TextXAlignment = Enum.TextXAlignment.Center,
			Visible = false,
			LayoutOrder = 100000,
			Theme = { TextColor3 = "SubText" },
			Parent = listContent,
		})

		local closed = false
		local function Close()
			if closed then
				return
			end
			closed = true
			Spotlight.Open = false
			Spotlight.Close = nil
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end
			if box:IsFocused() then
				box:ReleaseFocus()
			end
			Restyle(shadow, 0.15)
			Tween(panel, { GroupTransparency = 1 }, 0.15)
			Tween(panelScale, { Scale = scale * 0.97 }, 0.15)
			task.delay(0.16, function()
				overlay:Destroy()
			end)
		end
		Spotlight.Close = Close

		local function Activate(entry, reveal)
			if closed then
				return
			end
			Close()
			if entry.Kind == "Tab" then
				Window:SelectTab(entry.Tab)
				return
			elseif entry.Kind == "Command" then
				entry.Command:Run(true)
				return
			elseif entry.Kind == "Action" then
				local ok, title, detail = pcall(entry.Run)
				if not ok then
					warn("[MacUI] " .. tostring(title))
				elseif title then
					Window:Toast(title, { Detail = detail, Icon = entry.Icon, Highlight = true })
				end
				return
			end
			local element = entry.Element
			if not reveal and not entry.Row.Disabled and element and element._Activate then
				element:_Activate(true)
			else
				Window:Reveal(entry.Row)
			end
		end

		local function Paint()
			for index, item in ipairs(items) do
				item.Selected = index == selected
				for _, object in ipairs(item.Painted) do
					Restyle(object, 0.08)
				end
			end
			local item = items[selected]
			if not item then
				return
			end
			-- keep the selection (and the heading above it) in view
			local top = item.Top - (item.HeaderAbove and headerHeight or 0)
			local bottom = item.Top + itemHeight
			local current = list.CanvasPosition.Y
			if top < current then
				list.CanvasPosition = Vector2.new(0, math.max(top, 0))
			elseif bottom > current + visibleHeight then
				list.CanvasPosition = Vector2.new(0, bottom - visibleHeight)
			end
		end

		local function Render()
			for _, object in ipairs(rendered) do
				object:Destroy()
			end
			table.clear(rendered)
			table.clear(items)
			results = SpotlightSearch(box.Text)
			pointerMoved, renderMouse = false, MousePosition()
			local y, headingAbove, headings = 0, false, 0
			for order, entry in ipairs(results) do
				if entry.Kind == "Header" then
					headings = headings + (1)
					local heading = New("TextLabel", {
						Name = "Header",
						Text = entry.Title,
						TextSize = 11,
						Weight = Enum.FontWeight.Bold,
						Size = UDim2.new(1, 0, 0, headerHeight),
						TextYAlignment = Enum.TextYAlignment.Bottom,
						LayoutOrder = order,
						Theme = { TextColor3 = "SubText" },
						Parent = listContent,
					})
					Padding(heading, 0, 10, 6, 10)
					table.insert(rendered, heading)
					y = y + (headerHeight)
					headingAbove = true
				else
					local index = #items + 1
					local item = { Entry = entry, Selected = false, Top = y, HeaderAbove = headingAbove }
					headingAbove = false
					y = y + (itemHeight)
					local function Foreground(normal)
						return function(t)
							return item.Selected and t.SelectionText or t[normal]
						end
					end
					item.Button = New("TextButton", {
						Name = "Result",
						Size = UDim2.new(1, 0, 0, itemHeight),
						LayoutOrder = order,
						Theme = {
							BackgroundColor3 = "Accent",
							BackgroundTransparency = function()
								return item.Selected and 0 or 1
							end,
						},
						Parent = listContent,
					})
					Corner(item.Button, 9)
					local tab = entry.Tab
					IconTile(item.Button, entry.Icon or (tab and tab.Icon) or "layers",
						entry.TileColor or (tab and tab.TileColor), 28, 7, 16, {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 10, 0.5, 0),
					})
					local value = EntryValue(entry)
					local reserve = value and 150 or 60
					local title = New("TextLabel", {
						Text = entry.Title,
						TextSize = 14,
						Weight = Enum.FontWeight.Medium,
						Position = UDim2.fromOffset(50, 6),
						Size = UDim2.new(1, -reserve, 0, 18),
						TextTruncate = Enum.TextTruncate.AtEnd,
						Theme = { TextColor3 = Foreground("Text") },
						Parent = item.Button,
					})
					local subtitle = New("TextLabel", {
						Text = entry.Subtitle,
						TextSize = 12,
						Position = UDim2.fromOffset(50, 24),
						Size = UDim2.new(1, -reserve, 0, 15),
						TextTruncate = Enum.TextTruncate.AtEnd,
						Theme = { TextColor3 = Foreground("SubText") },
						Parent = item.Button,
					})
					item.Painted = { item.Button, title, subtitle }
					if value then
						table.insert(item.Painted, New("TextLabel", {
							Text = value,
							TextSize = 13,
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -14, 0.5, 0),
							Size = UDim2.fromOffset(110, 18),
							TextXAlignment = Enum.TextXAlignment.Right,
							TextTruncate = Enum.TextTruncate.AtEnd,
							Theme = { TextColor3 = Foreground("SubText") },
							Parent = item.Button,
						}))
					end
					local function Hover()
						if not pointerMoved and (MousePosition() - renderMouse).Magnitude > 1 then
							pointerMoved = true
						end
						if pointerMoved and selected ~= index then
							selected = index
							Paint()
						end
					end
					item.Button.MouseEnter:Connect(Hover)
					item.Button.MouseMoved:Connect(Hover)
					item.Button.MouseButton1Click:Connect(function()
						Activate(entry, false)
					end)
					table.insert(items, item)
					table.insert(rendered, item.Button)
				end
			end
			if box.Text:match("^%s*$") then
				-- nothing is picked until you type or move: Enter mustn't run a
				-- suggestion (a command, say) by accident
				selected = 0
			else
				selected = math.clamp(selected, 1, math.max(#items, 1))
			end
			empty.Visible = #items == 0 and box.Text ~= ""
			divider.Visible = #items > 0 or empty.Visible
			-- seven rows, plus room for up to two of the headings shown
			visibleHeight = math.min(y, maxVisible * itemHeight + math.min(headings, 2) * headerHeight)
			local listHeight = #items > 0 and (visibleHeight + 12) or (empty.Visible and 52 or 0)
			Tween(holder, { Size = UDim2.fromOffset(width, searchHeight + (listHeight > 0 and listHeight + 1 or 0)) },
				0.18)
			Paint()
		end

		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				pointerMoved = true
			end
		end))
		table.insert(connections, UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Down then
				selected = math.min(selected + 1, math.max(#items, 1))
				Paint()
			elseif input.KeyCode == Enum.KeyCode.Up then
				selected = math.max(selected - 1, 1)
				Paint()
			end
		end))
		box:GetPropertyChangedSignal("Text"):Connect(function()
			selected = 1
			Render()
		end)
		box.FocusLost:Connect(function(enterPressed, input)
			if not Spotlight.Open then
				return
			end
			if enterPressed then
				MarkActivity() -- Enter in Spotlight is the user acting
				local entry = items[selected] and items[selected].Entry
				if entry then
					local reveal = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or
					UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
					Activate(entry, reveal)
				else
					Close()
				end
			elseif input and input.KeyCode == Enum.KeyCode.Escape then
				Close()
			end
		end)
		sink.MouseButton1Click:Connect(function()
			box:CaptureFocus()
		end)
		overlay.MouseButton1Click:Connect(Close)
		overlay.MouseButton2Click:Connect(Close)

		Render()
		Tween(panel, { GroupTransparency = 0 }, 0.16)
		Tween(panelScale, { Scale = scale }, 0.28, Enum.EasingStyle.Back)
		Restyle(shadow, 0.2)
		task.defer(function()
			if Spotlight.Open then
				box:CaptureFocus()
				box.CursorPosition = #box.Text + 1
			end
		end)
	end

	function Window:CloseSpotlight()
		if Spotlight.Close then
			Spotlight.Close()
		end
	end

	if SpotlightHint then
		SpotlightHint.MouseButton1Click:Connect(function()
			Window:OpenSpotlight()
		end)
	end

	----------------------------------------------------------------------------
	-- Commands: actions that live in Spotlight (and optionally on a key)
	----------------------------------------------------------------------------

	--[[
		local rejoin = Window:AddCommand({
			Title = "Rejoin server",
			Description = "Teleports you back into this game.",
			Icon = "refresh-cw", IconColor = "Green",
			Keywords = "reconnect server hop",
			Shortcut = "F8",
			Callback = function() ... end,
		})
		rejoin:Run()  rejoin:SetShortcut("F9")  rejoin:Destroy()
	]]
	function Window:AddCommand(info)
		info = info or {}
		local command = {
			Title = tostring(info.Title or "Command"),
			Description = info.Description and tostring(info.Description) or nil,
			Icon = info.Icon or "command",
			TileColor = ResolveColor(info.IconColor) or function()
				return MacUI.Accent
			end,
			Keywords = tostring(info.Keywords or ""),
			Callback = info.Callback,
		}
		local connection
		-- Runs the command; a short toast confirms it unless announce is false.
		function command:Run(announce)
			if announce ~= false then
				Window:Toast(self.Title, { Icon = self.Icon })
			end
			NoteUsage("c:" .. self.Title)
			RunCallback(self, self.Callback)
		end

		function command:SetShortcut(key)
			if typeof(key) == "EnumItem" then
				key = key.Name
			end
			if key == "None" or key == "" or key == false then
				key = nil
			end
			self.Shortcut = key
			if connection then
				connection:Disconnect()
				connection = nil
			end
			if key then
				connection = Connect(UserInputService.InputBegan, function(input, processed)
					if processed or KeyCapture.Active or MacUI.Unloaded or UserInputService:GetFocusedTextBox() then
						return
					end
					if KeyMatches(input, key) then
						self:Run(true)
					end
				end)
			end
			ShortcutsChanged:Fire()
		end

		function command:Destroy()
			self:SetShortcut(nil)
			local index = table.find(Window.Commands, self)
			if index then
				table.remove(Window.Commands, index)
			end
		end

		table.insert(Window.Commands, command)
		if info.Shortcut then
			command:SetShortcut(info.Shortcut)
		end
		return command
	end

	----------------------------------------------------------------------------
	-- Shortcut list: a floating panel with every keybind and bound shortcut
	----------------------------------------------------------------------------

	local ShortcutPanel
	local shortcutRefreshQueued = false

	local function RefreshShortcutList()
		if not ShortcutPanel then
			return
		end
		local entries = {}
		local seen = {}
		local titleCount = {}
		for _, tab in ipairs(Window.Tabs) do
			for _, row in ipairs(tab.Rows) do
				titleCount[row.Title] = (titleCount[row.Title] or 0) + 1
			end
		end
		local function Label(element, fallback)
			local title = tostring(element.Title or element.Idx or fallback)
			local block = element.Row and element.Row.Group and element.Row.Group.Block
			if (titleCount[title] or 0) > 1 and block and block.Title and block.Title ~= "" then
				return block.Title .. " · " .. title
			end
			return title
		end
		local function Add(element)
			if seen[element] then
				return
			end
			seen[element] = true
			if element.Type == "Keybind" and element.Value ~= "None" then
				local ok, active = pcall(element.GetState, element)
				table.insert(entries,
					{ Title = Label(element, "Keybind"), Key = KeyName(element.Value), Active = ok and active == true })
			elseif element.Shortcut then
				table.insert(entries, {
					Title = Label(element, "Shortcut"),
					Key = KeyName(element.Shortcut),
					Active = element.Type == "Toggle" and element.Value == true,
				})
			end
		end
		for _, option in pairs(MacUI.Options) do
			if type(option) == "table" and option.Type then
				Add(option)
			end
		end
		for _, tab in ipairs(Window.Tabs) do
			for _, row in ipairs(tab.Rows) do
				if row.Element then
					Add(row.Element)
				end
			end
		end
		for _, command in ipairs(Window.Commands) do
			if command.Shortcut then
				table.insert(entries, { Title = command.Title, Key = KeyName(command.Shortcut), Active = false })
			end
		end
		table.sort(entries, function(a, b)
			return a.Title < b.Title
		end)
		for _, child in ipairs(ShortcutPanel.Rows:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		for index, entry in ipairs(entries) do
			local line = New("Frame", {
				Name = "Shortcut",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 24),
				LayoutOrder = index,
				Parent = ShortcutPanel.Rows,
			})
			New("TextLabel", {
				Text = entry.Title,
				TextSize = 13,
				Size = UDim2.new(1, -70, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Theme = { TextColor3 = entry.Active and "Text" or "SubText" },
				Parent = line,
			})
			local cap = New("TextLabel", {
				Text = entry.Key,
				TextSize = 11,
				Weight = Enum.FontWeight.Medium,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(0, 18),
				AutomaticSize = Enum.AutomaticSize.X,
				TextXAlignment = Enum.TextXAlignment.Center,
				BackgroundTransparency = 0,
				Theme = {
					BackgroundColor3 = entry.Active and "Accent" or "Control",
					TextColor3 = entry.Active and "SelectionText" or "SubText",
				},
				Parent = line,
			})
			Corner(cap, 5)
			Padding(cap, 0, 7, 0, 7)
		end
		if #entries == 0 then
			New("TextLabel", {
				Name = "Empty",
				Text = "Right-click a toggle to add one",
				TextSize = 12,
				Size = UDim2.new(1, 0, 0, 24),
				Theme = { TextColor3 = "SubText" },
				Parent = ShortcutPanel.Rows,
			})
		end
		ShortcutPanel.Holder.Size = UDim2.fromOffset(230, 38 + math.max(#entries, 1) * 26 + 8)
	end

	local function QueueShortcutRefresh()
		if shortcutRefreshQueued or not Window.KeybindListVisible then
			return
		end
		shortcutRefreshQueued = true
		task.defer(function()
			shortcutRefreshQueued = false
			RefreshShortcutList()
		end)
	end

	function Window:SetKeybindList(visible)
		visible = visible == true
		Window.KeybindListVisible = visible
		if visible and not ShortcutPanel then
			local holder = New("Frame", {
				Name = "ShortcutList",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 14),
				Size = UDim2.fromOffset(230, 72),
				ZIndex = 4,
				Parent = ScreenGui,
			})
			local listScale = New("UIScale", { Scale = Window.Scale, Parent = holder })
			InterfaceRoots[holder] = true
			local body = New("Frame", {
				Name = "Body",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.03,
				ZIndex = 2,
				Active = true,
				Theme = { BackgroundColor3 = "Menu" },
				Parent = holder,
			})
			Corner(body, 12)
			Stroke(body, "HudStroke", 1, 0)
			local header = New("Frame", {
				Name = "Header",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 36),
				Parent = body,
			})
			IconImage({
				Icon = "keyboard",
				IconSize = 15,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Theme = { ImageColor3 = "Accent" },
				Parent = header,
			})
			New("TextLabel", {
				Text = "Shortcuts",
				TextSize = 13,
				Weight = Enum.FontWeight.Bold,
				Position = UDim2.fromOffset(34, 0),
				Size = UDim2.new(1, -44, 1, 0),
				Theme = { TextColor3 = "Text" },
				Parent = header,
			})
			local rows = New("Frame", {
				Name = "Rows",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 36),
				Size = UDim2.new(1, 0, 1, -36),
				Parent = body,
			})
			Padding(rows, 0, 12, 8, 12)
			List(rows, nil, 2)
			ShortcutPanel = { Holder = holder, Rows = rows, Scale = listScale }

			local dragging
			header.InputBegan:Connect(function(input)
				if IsPointer(input) then
					dragging = { Start = input.Position, Position = holder.Position, Input = input }
				end
			end)
			Connect(UserInputService.InputChanged, function(input)
				if dragging and DragMoves(dragging.Input, input) then
					local delta = input.Position - dragging.Start
					holder.Position = dragging.Position + UDim2.fromOffset(delta.X, delta.Y)
				end
			end)
			Connect(UserInputService.InputEnded, function(input)
				if dragging and DragEnds(dragging.Input, input) then
					dragging = nil
				end
			end)
			Connect(ShortcutsChanged, QueueShortcutRefresh)
			Connect(MacUI.OptionChanged, function(_, _, element)
				if element and (element.Type == "Toggle" or element.Type == "Keybind") then
					QueueShortcutRefresh()
				end
			end)
		end
		if ShortcutPanel then
			ShortcutPanel.Holder.Visible = visible
		end
		if visible then
			RefreshShortcutList()
		end
	end

	function Window:_OnScale(scale)
		if ShortcutPanel then
			ShortcutPanel.Scale.Scale = scale
		end
		HideTooltip()
	end

	local MODIFIER_KEYS = {
		[Enum.KeyCode.LeftControl] = true,
		[Enum.KeyCode.RightControl] = true,
		[Enum.KeyCode.LeftShift] = true,
		[Enum.KeyCode.RightShift] = true,
		[Enum.KeyCode.LeftAlt] = true,
		[Enum.KeyCode.RightAlt] = true,
		[Enum.KeyCode.LeftSuper] = true,
		[Enum.KeyCode.RightSuper] = true,
		[Enum.KeyCode.LeftMeta] = true,
		[Enum.KeyCode.RightMeta] = true,
	}
	local pendingToggle

	Connect(UserInputService.InputBegan, function(input, processed)
		if pendingToggle and input.KeyCode ~= pendingToggle then
			pendingToggle = nil -- another key or a click while holding it: a chord
		end
		if processed or KeyCapture.Active or UserInputService:GetFocusedTextBox() then
			return
		end
		if config.Spotlight ~= false and input.KeyCode == (config.SpotlightKey or Enum.KeyCode.K) then
			-- Ctrl, or Command on a Mac (reported as Super or Meta)
			local modifier = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
				or UserInputService:IsKeyDown(Enum.KeyCode.LeftSuper)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightSuper)
				or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightMeta)
			if modifier then
				if Spotlight.Open then
					Window:CloseSpotlight()
				else
					Window:OpenSpotlight()
				end
				return
			end
		end
		if Window.MinimizeKey and input.KeyCode == Window.MinimizeKey then
			if MODIFIER_KEYS[input.KeyCode] then
				pendingToggle = input.KeyCode
			else
				Window:Toggle()
			end
		end
	end)

	Connect(UserInputService.InputEnded, function(input)
		if pendingToggle and input.KeyCode == pendingToggle then
			pendingToggle = nil
			if not KeyCapture.Active and not MacUI.Unloaded then
				Window:Toggle()
			end
		end
	end)

	-- a rotated phone, a resized game window
	Connect(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"), FitToScreen)

	function Window:Destroy()
		MacUI:Destroy()
	end

	function Window:_Cleanup()
		Window:CloseSpotlight()
		for _, fn in ipairs(Cleanup) do
			SafeCall(fn)
		end
	end

	-- Opens the window when a loading card is up (see config.Loading); does
	-- nothing otherwise.
	function Window:FinishLoading() end

	UpdateNavigation()
	if config.Undo == false then
		MacUI:SetUndoEnabled(false)
	end
	if config.Watermark then
		local spec = type(config.Watermark) == "table" and table.clone(config.Watermark) or {}
		spec.Text = spec.Text or Window.Title
		spec.Icon = spec.Icon or config.Icon
		spec.IconColor = spec.IconColor or config.IconColor
		MacUI:SetWatermark(spec)
	end
	if config.Loading then
		-- Loading = true | { Title, Subtitle, Icon, Duration = seconds | false }.
		-- The window stays hidden behind a loading card while the script builds
		-- its tabs. With Duration = false, drive Window.Loader:SetProgress() and
		-- call Window:FinishLoading() yourself.
		local spec = type(config.Loading) == "table" and config.Loading or {}
		Root.Visible = false
		local loader = MacUI:ShowLoading({
			Title = spec.Title or Window.Title,
			Subtitle = spec.Subtitle or "Loading…",
			Icon = spec.Icon or config.Icon,
			IconColor = spec.IconColor or config.IconColor,
			Dim = spec.Dim,
		})
		Window.Loader = loader
		Window.Loading = true
		local finished = false
		function Window:FinishLoading(text)
			if finished then
				return
			end
			finished = true
			loader:Finish(text)
			task.delay(0.4, function()
				Window.Loading = false
				if not MacUI.Unloaded and not Window.Minimized then
					Window:SetVisible(true)
				end
			end)
		end

		if spec.Duration == false then
			-- if the script stops (an error) before FinishLoading, don't leave
			-- the screen dimmed forever
			task.delay(tonumber(spec.Timeout) or 30, function()
				if not finished and not MacUI.Unloaded then
					Window:FinishLoading()
				end
			end)
		end
		if spec.Duration ~= false then
			task.spawn(function()
				local duration = tonumber(spec.Duration) or 1.4
				local steps = math.max(math.floor(duration / 0.05), 1)
				for step = 1, steps do
					task.wait(duration / steps)
					if finished or MacUI.Unloaded then
						break
					end
					loader:SetProgress(step / steps)
				end
				if MacUI.Unloaded then
					loader:Close()
					return
				end
				Window:FinishLoading()
			end)
		end
	else
		Window:SetVisible(true)
	end
	if config.Acrylic then
		Window:SetAcrylic(true)
	end
	if config.KeybindList then
		Window:SetKeybindList(true)
	end

	local function BuildSendenHomeDashboard(Window, HomeTab)
		local content = HomeTab.Content
		content.LayoutOrder = 1
		content.BackgroundTransparency = 1
	end

	local HomeTab = Window:AddTab({
		Title = "Trang Chủ",
		Icon = "house",
	})
	BuildSendenHomeDashboard(Window, HomeTab)
	Window:SelectTab(HomeTab)

	if config.PerformanceGuard then
		MacUI:SetPerformanceGuard(config.PerformanceGuard)
	end
	return Window
end

--------------------------------------------------------------------------------
-- Teardown
--------------------------------------------------------------------------------

function MacUI:Destroy()
	if self.Unloaded then
		return
	end
	self.Unloaded = true
	-- each runs until it first waits, so a slow one can't hold up the
	-- teardown (or a re-run of the script that is replacing this copy)
	for _, fn in ipairs(UnloadCallbacks) do
		task.spawn(SafeCall, fn)
	end
	for _, window in ipairs(self.Windows) do
		if window._ClosePopup then
			window:_ClosePopup(true)
		end
		if window._Cleanup then
			SafeCall(window._Cleanup, window)
		end
		for _, connection in ipairs(window.Connections) do
			connection:Disconnect()
		end
		for _, tab in ipairs(window.Tabs) do
			for _, row in ipairs(tab.Rows) do
				for _, connection in ipairs(row.Connections) do
					connection:Disconnect()
				end
			end
		end
		if window.ScreenGui then
			window.ScreenGui:Destroy()
		end
	end
	if NotificationGui then
		NotificationGui:Destroy()
	end
	for _, connection in ipairs(LibraryConnections) do
		connection:Disconnect()
	end
	table.clear(LibraryConnections)
	if WatermarkGui then
		WatermarkGui:Destroy()
		WatermarkGui = nil
	end
	for loader in pairs(ActiveLoaders) do
		loader:Close()
	end
	table.clear(ActiveTimers)
	Macros.Recorder = nil
	Activity.Pressing = nil
	if type(shared) == "table" and type(shared.__MacUIWindows) == "table" then
		for key, library in pairs(shared.__MacUIWindows) do
			if library == self then
				shared.__MacUIWindows[key] = nil
			end
		end
	end
	if Guard.Connection then
		Guard.Connection:Disconnect()
		Guard.Connection = nil
	end
	self:ClearHistory()
	table.clear(ThemeRegistry)
	table.clear(FontRegistry)
	table.clear(self.Options)
	table.clear(self.Windows)
end

MacUI.Unload = MacUI.Destroy

return MacUI
