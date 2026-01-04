local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- SETTINGS
local Settings = {
	Enabled = false,
	FOV = 180,
	Smoothness = 0.15,
	TeamCheck = true,
	WallCheck = true,
	AimPart = "Head",
	ShowFOV = true
}
local settings_esp = {
	Enabled = true,

	Boxes = true,
	Skeleton = true,
	Name = true,
	Distance = true,
	Health = true,

	MaxDistance = 2000,

	BoxColor = Color3.fromRGB(255, 0, 0),
	SkeletonColor = Color3.fromRGB(0, 255, 0),
	TextColor = Color3.fromRGB(255, 255, 255),
	HealthColor = Color3.fromRGB(0, 255, 0),
	HealthBack = Color3.fromRGB(60, 60, 60)
}

-- ===== RAYFIELD WINDOW =====
local Window = Rayfield:CreateWindow({
   Name = "Убийца килор",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Эдакий скрипт",
   LoadingSubtitle = "by kaLLoware",
   ShowText = "Hub", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("Аимбот")
local Tab1 = Window:CreateTab("ESP")

-- TOGGLES
Tab:CreateToggle({
	Name = "Аимбот",
	CurrentValue = false,
	Callback = function(v)
		Settings.Enabled = v
	end
})

Tab:CreateToggle({
	Name = "Team Check",
	CurrentValue = true,
	Callback = function(v)
		Settings.TeamCheck = v
	end
})

Tab:CreateToggle({
	Name = "Wall Check",
	CurrentValue = true,
	Callback = function(v)
		Settings.WallCheck = v
	end
})

Tab:CreateToggle({
	Name = "Показывать радиус",
	CurrentValue = true,
	Callback = function(v)
		Settings.ShowFOV = v
	end
})

-- SLIDERS
Tab:CreateSlider({
	Name = "Радиус",
	Range = {50, 400},
	Increment = 5,
	CurrentValue = 180,
	Callback = function(v)
		Settings.FOV = v
	end
})

Tab:CreateSlider({
	Name = "Плавность (больше - резко)",
	Range = {1, 100},
	Increment = 1,
	CurrentValue = 15,
	Callback = function(v)
		Settings.Smoothness = v / 100
	end
})
-- RAYFIELD ESP (BOX + SKELETON + INFO)
-- FINAL VERSION WITH settings_esp

-- ===== LOAD RAYFIELD ===
-- ===== SETTINGS =====
local settings_esp = {
	Enabled = true,

	Boxes = true,
	Skeleton = true,
	Name = true,
	Distance = true,
	Health = true,

	MaxDistance = 2000,

	BoxColor = Color3.fromRGB(255, 0, 0),
	SkeletonColor = Color3.fromRGB(0, 255, 0),
	TextColor = Color3.fromRGB(255, 255, 255),
	HealthColor = Color3.fromRGB(0, 255, 0),
	HealthBack = Color3.fromRGB(60, 60, 60)
}

-- ===== RAYFIELD UI =====
Tab1:CreateToggle({
	Name = "Включить ESP",
	CurrentValue = true,
	Callback = function(v) settings_esp.Enabled = v end
})

Tab1:CreateToggle({
	Name = "Боксы",
	CurrentValue = true,
	Callback = function(v) settings_esp.Boxes = v end
})

Tab1:CreateToggle({
	Name = "Скелетон",
	CurrentValue = true,
	Callback = function(v) settings_esp.Skeleton = v end
})

Tab1:CreateToggle({
	Name = "Имя",
	CurrentValue = true,
	Callback = function(v) settings_esp.Name = v end
})

Tab1:CreateToggle({
	Name = "Дистанция",
	CurrentValue = true,
	Callback = function(v) settings_esp.Distance = v end
})

Tab1:CreateToggle({
	Name = "Здоровье",
	CurrentValue = true,
	Callback = function(v) settings_esp.Health = v end
})

Tab1:CreateColorPicker({
	Name = "Цвет боксов",
	Color = settings_esp.BoxColor,
	Callback = function(v) settings_esp.BoxColor = v end
})

Tab1:CreateColorPicker({
	Name = "Цвет скелетона",
	Color = settings_esp.SkeletonColor,
	Callback = function(v) settings_esp.SkeletonColor = v end
})

-- ===== SKELETON MAP =====
local Bones = {
	{"Head","UpperTorso"},
	{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},
	{"LeftUpperArm","LeftLowerArm"},
	{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},
	{"RightUpperArm","RightLowerArm"},
	{"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"},
	{"LeftUpperLeg","LeftLowerLeg"},
	{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},
	{"RightUpperLeg","RightLowerLeg"},
	{"RightLowerLeg","RightFoot"}
}

-- ===== DRAWING UTILS =====
local function newLine()
	local l = Drawing.new("Line")
	l.Thickness = 2
	l.Visible = false
	return l
end

local function newText()
	local t = Drawing.new("Text")
	t.Size = 13
	t.Center = true
	t.Outline = true
	t.Visible = false
	return t
end

local function newBox()
	local s = Drawing.new("Square")
	s.Thickness = 2
	s.Filled = false
	s.Visible = false
	return s
end

local function newHealthBar()
	local back = Drawing.new("Square")
	back.Filled = true
	back.Visible = false

	local fill = Drawing.new("Square")
	fill.Filled = true
	fill.Visible = false

	return back, fill
end

-- ===== ESP STORAGE =====
local ESP = {}

local function removeESP(p)
	if ESP[p] then
		for _,obj in pairs(ESP[p]) do
			if typeof(obj) == "table" then
				for _,v in pairs(obj) do v:Remove() end
			else
				obj:Remove()
			end
		end
	end
	ESP[p] = nil
end

local function createESP(p)
	local e = {}

	e.Box = newBox()
	e.Name = newText()
	e.Info = newText()
	e.HealthBack, e.HealthFill = newHealthBar()

	e.Skeleton = {}
	for i = 1, #Bones do
		e.Skeleton[i] = newLine()
	end

	ESP[p] = e
end

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			if not ESP[p] then
				createESP(p)
			end

			local e = ESP[p]
			local char = p.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if not settings_esp.Enabled or not hrp or not hum or hum.Health <= 0 then
				removeESP(p)
				continue
			end

			local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
			if not onscreen then
				removeESP(p)
				continue
			end

			local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
			if dist > settings_esp.MaxDistance then
				removeESP(p)
				continue
			end

			-- BOX
			local size = Vector2.new(2000 / dist, 3000 / dist)
			local boxPos = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)

			e.Box.Visible = settings_esp.Boxes
			e.Box.Position = boxPos
			e.Box.Size = size
			e.Box.Color = settings_esp.BoxColor

			-- NAME
			e.Name.Visible = settings_esp.Name
			e.Name.Text = p.Name
			e.Name.Color = settings_esp.TextColor
			e.Name.Position = Vector2.new(pos.X, boxPos.Y - 14)

			-- DISTANCE
			e.Info.Visible = settings_esp.Distance
			e.Info.Text = math.floor(dist) .. "m"
			e.Info.Color = settings_esp.TextColor
			e.Info.Position = Vector2.new(pos.X, boxPos.Y + size.Y + 2)

			-- HEALTH
			if settings_esp.Health then
				local hp = hum.Health / hum.MaxHealth

				e.HealthBack.Visible = true
				e.HealthFill.Visible = true

				e.HealthBack.Size = Vector2.new(4, size.Y)
				e.HealthBack.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
				e.HealthBack.Color = settings_esp.HealthBack

				e.HealthFill.Size = Vector2.new(4, size.Y * hp)
				e.HealthFill.Position = Vector2.new(
					boxPos.X - 6,
					boxPos.Y + (size.Y * (1 - hp))
				)
				e.HealthFill.Color = settings_esp.HealthColor
			else
				e.HealthBack.Visible = false
				e.HealthFill.Visible = false
			end

			-- SKELETON
			for i,b in ipairs(Bones) do
				local l = e.Skeleton[i]
				if settings_esp.Skeleton and char:FindFirstChild(b[1]) and char:FindFirstChild(b[2]) then
					local p1, v1 = Camera:WorldToViewportPoint(char[b[1]].Position)
					local p2, v2 = Camera:WorldToViewportPoint(char[b[2]].Position)
					if v1 and v2 then
						l.Visible = true
						l.From = Vector2.new(p1.X, p1.Y)
						l.To = Vector2.new(p2.X, p2.Y)
						l.Color = settings_esp.SkeletonColor
					else
						l.Visible = false
					end
				else
					l.Visible = false
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(removeESP)
-- ===== FOV CIRCLE =====
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Color = Color3.fromRGB(255,0,0)
FOVCircle.Visible = true

-- ===== UTILS =====
local function sameTeam(p)
	return Settings.TeamCheck and p.Team == LP.Team
end

local function wallCheck(part)
	if not Settings.WallCheck then return true end
	local origin = Camera.CFrame.Position
	local dir = part.Position - origin

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LP.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local ray = Workspace:Raycast(origin, dir, params)
	return ray and ray.Instance:IsDescendantOf(part.Parent)
end

local function getTarget()
	local best, dist = nil, math.huge
	local center = Camera.ViewportSize / 2

	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LP and not sameTeam(p) then
			local c = p.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			local part = c and c:FindFirstChild(Settings.AimPart)

			if h and h.Health > 0 and part then
				local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude
					if mag < Settings.FOV and mag < dist and wallCheck(part) then
						best = part
						dist = mag
					end
				end
			end
		end
	end
	return best
end

-- ===== CAMERA OVERRIDE (КЛЮЧ) =====
RunService:BindToRenderStep(
	"RayfieldMobileAimbot",
	Enum.RenderPriority.Camera.Value + 1,
	function()
		local center = Camera.ViewportSize / 2

		-- FOV CIRCLE UPDATE
		FOVCircle.Position = Vector2.new(center.X, center.Y)
		FOVCircle.Radius = Settings.FOV
		FOVCircle.Visible = Settings.ShowFOV

		if not Settings.Enabled then return end

		local target = getTarget()
		if not target then return end

		local cf = Camera.CFrame
		Camera.CFrame = cf:Lerp(
			CFrame.new(cf.Position, target.Position),
			Settings.Smoothness
		)
	end
)
