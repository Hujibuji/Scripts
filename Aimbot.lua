local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Aimbot | KaLLoware",
   Icon = 0,
   LoadingTitle = "ZагруZка...",
   LoadingSubtitle = "by kaLLoware",
   ShowText = "hub",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
   },

   Discord = {
      Enabled = false,
   },

   KeySystem = false,
})
-- локальные
local AimbotTab = Window:CreateTab("Аимбот")
local ESPTab = Window:CreateTab("ESP")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local AimbotEnabled = false
local AimPart = "Head"
local Smooth = 0.2
local FOV = 250
local MaxAimDistance = 1500
local WallCheck = false

-- ДОБАВЛЕНО: проверка на команду
local TeamCheck = false

local ESPEnabled = false
local ESPBox = false
local ESPHealth = false
local ESPName = false
local ESPDistance = false
local BoxColor = Color3.fromRGB(255,255,255)
local NameColor = Color3.fromRGB(255,255,255)
local DistanceColor = Color3.fromRGB(200,200,200)
-- кнопки
AimbotTab:CreateToggle({
    Name = "Включить аимбот",
    CurrentValue = false,
    Callback = function(v) AimbotEnabled = v end
})

AimbotTab:CreateToggle({
    Name = "Проверка на стены",
    CurrentValue = false,
    Callback = function(v) WallCheck = v end
})

-- ДОБАВЛЕНО: тоггл проверки на команду
AimbotTab:CreateToggle({
    Name = "Проверка на команду",
    CurrentValue = false,
    Callback = function(v) TeamCheck = v end
})

AimbotTab:CreateSlider({
    Name = "Плавность (меньше = резко)",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = 0.2,
    Callback = function(v) Smooth = v end
})

AimbotTab:CreateSlider({
    Name = "FOV",
    Range = {50, 600},
    Increment = 10,
    CurrentValue = 250,
    Callback = function(v) FOV = v end
})

AimbotTab:CreateSlider({
    Name = "Дистанция",
    Range = {0, 5000},
    Increment = 5,
    CurrentValue = 1500,
    Callback = function(v) MaxAimDistance = v end
})
ESPTab:CreateToggle({
    Name = "Включить ЕСП",
    CurrentValue = false,
    Callback = function(v) ESPEnabled = v end
})

ESPTab:CreateToggle({
    Name = "Бокс",
    CurrentValue = false,
    Callback = function(v) ESPBox = v end
})

ESPTab:CreateToggle({
    Name = "Полоска хп",
    CurrentValue = false,
    Callback = function(v) ESPHealth = v end
})

ESPTab:CreateToggle({
    Name = "Ник",
    CurrentValue = false,
    Callback = function(v) ESPName = v end
})

ESPTab:CreateToggle({
    Name = "Дистанция",
    CurrentValue = false,
    Callback = function(v) ESPDistance = v end
})

ESPTab:CreateColorPicker({
    Name = "Цвет боксов",
    Color = BoxColor,
    Callback = function(c) BoxColor = c end
})

ESPTab:CreateColorPicker({
    Name = "Цвет ника",
    Color = NameColor,
    Callback = function(c) NameColor = c end
})

ESPTab:CreateColorPicker({
    Name = "Цвет дистанции",
    Color = DistanceColor,
    Callback = function(c) DistanceColor = c end
})
-- приколы
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Thickness = 1.5
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255,255,255)
local function alive(char)
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- ДОБАВЛЕНО: проверка на тиммейтов (с фиксом для Neutral)
local function sameTeam(p1, p2)
    if not TeamCheck then return false end

    -- если игра без команд / все нейтралы — не фильтруем
    if p1.Neutral and p2.Neutral then
        return false
    end

    if p1.Team ~= nil and p2.Team ~= nil then
        return p1.Team == p2.Team
    end

    if p1.TeamColor ~= nil and p2.TeamColor ~= nil then
        return p1.TeamColor == p2.TeamColor
    end

    return false
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true
local function visible(part)
    if not WallCheck then return true end
    rayParams.FilterDescendantsInstances = {LP.Character}
    local ray = Workspace:Raycast(
        Camera.CFrame.Position,
        part.Position - Camera.CFrame.Position,
        rayParams
    )
    if not ray then return true end
    return ray.Instance:IsDescendantOf(part.Parent)
end
local function getTarget()
    local best, dist2D = nil, FOV
    local lpHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not lpHRP then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and alive(plr.Character) and not sameTeam(LP, plr) then
            local part = plr.Character:FindFirstChild(AimPart)
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if part and hrp then
                local worldDist = (lpHRP.Position - hrp.Position).Magnitude
                if worldDist <= MaxAimDistance and visible(part) then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X,pos.Y) - Vector2.new(Mouse.X,Mouse.Y)).Magnitude
                        if d < dist2D then
                            dist2D = d
                            best = part
                        end
                    end
                end
            end
        end
    end
    return best
end
local ESPObjects = {}
local function newESP(player)
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        HealthBG = Drawing.new("Square"),
        Health = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text")
    }
    ESPObjects[player].Box.Filled = false
    ESPObjects[player].HealthBG.Filled = true
    ESPObjects[player].Health.Filled = true
    for _,t in ipairs({ESPObjects[player].Name, ESPObjects[player].Dist}) do
        t.Size = 13
        t.Center = true
        t.Outline = true
    end
    for _,v in pairs(ESPObjects[player]) do v.Visible = false end
end
local function removeESP(player)
    if ESPObjects[player] then
        for _,v in pairs(ESPObjects[player]) do v:Remove() end
        ESPObjects[player] = nil
    end
end
for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LP then newESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LP then newESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = FOV
    FOVCircle.Visible = AimbotEnabled
    if AimbotEnabled then
        local target = getTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, target.Position),
                math.clamp(1 - Smooth, 0.05, 1)
            )
        end
    end
    for plr,esp in pairs(ESPObjects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if ESPEnabled and char and hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local scale = 1 / (pos.Z / 50)
                local size = Vector2.new(35, 50) * scale
                local tl = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                esp.Box.Size = size
                esp.Box.Position = tl
                esp.Box.Color = BoxColor
                esp.Box.Visible = ESPBox
                local hp = hum.Health / hum.MaxHealth
                esp.HealthBG.Size = Vector2.new(4, size.Y)
                esp.HealthBG.Position = tl - Vector2.new(6,0)
                esp.HealthBG.Visible = ESPHealth
                esp.Health.Size = Vector2.new(4, size.Y * hp)
                esp.Health.Position = esp.HealthBG.Position + Vector2.new(0, size.Y * (1-hp))
                esp.Health.Color = Color3.fromRGB(0,255,0)
                esp.Health.Visible = ESPHealth
                esp.Name.Text = plr.Name
                esp.Name.Color = NameColor
                esp.Name.Position = Vector2.new(pos.X, tl.Y - 14)
                esp.Name.Visible = ESPName
                esp.Dist.Text = math.floor(
                    (LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                ).."m"
                esp.Dist.Color = DistanceColor
                esp.Dist.Position = Vector2.new(pos.X, tl.Y + size.Y + 2)
                esp.Dist.Visible = ESPDistance
            else
                for _,v in pairs(esp) do v.Visible = false end
            end
        else
            for _,v in pairs(esp) do v.Visible = false end
        end
    end
end)
