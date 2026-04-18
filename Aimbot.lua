local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "hueta.cc",
    Icon = 0,
    LoadingTitle = "Загрузка...",
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

-- сервисы
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local GuiService        = game:GetService("GuiService")
local UserInputService  = game:GetService("UserInputService")

local Camera = Workspace.CurrentCamera
local LP     = Players.LocalPlayer
local Mouse  = LP:GetMouse()

-- настройки аимбота
local AimbotEnabled  = false
local AimPart        = "Head"
local Smooth         = 0.2
local FOV            = 250
local MaxAimDistance  = 1500
local WallCheck      = false
local TeamCheck      = false
local FOVCircleColor = Color3.fromRGB(255, 255, 255)

-- настройки есп
local ESPEnabled  = false
local ESPBox      = false
local ESPHealth   = false
local ESPName     = false
local ESPDistance  = false
local BoxColor    = Color3.fromRGB(255, 255, 255)
local NameColor   = Color3.fromRGB(255, 255, 255)
local DistanceColor = Color3.fromRGB(200, 200, 200)

-- для отключения при выгрузке
local connections = {}

-- вкладки
local AimbotTab = Window:CreateTab("Аимбот")
local ESPTab    = Window:CreateTab("ESP")
local MiscTab   = Window:CreateTab("Прочее")

-- ui аимбота
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

AimbotTab:CreateToggle({
    Name = "Проверка на команду",
    CurrentValue = false,
    Callback = function(v) TeamCheck = v end
})

AimbotTab:CreateDropdown({
    Name = "Часть тела",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    Callback = function(v)
        if type(v) == "table" then
            AimPart = v[1]
        else
            AimPart = v
        end
    end
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

AimbotTab:CreateColorPicker({
    Name = "Цвет круга FOV",
    Color = FOVCircleColor,
    Callback = function(c) FOVCircleColor = c end
})

-- ui есп
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
    Name = "Полоска ХП",
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

-- кружок фов на экране
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled      = false
FOVCircle.Thickness   = 1.5
FOVCircle.Transparency = 1
FOVCircle.NumSides    = 64

-- проверяем жив ли чар
local function isAlive(char)
    if not char then return false end
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- тимчек (если оба нейтралы — считаем врагами)
local function sameTeam(p1, p2)
    if not TeamCheck then return false end

    if p1.Neutral and p2.Neutral then
        return false
    end

    if p1.Team and p2.Team then
        return p1.Team == p2.Team
    end

    if p1.TeamColor and p2.TeamColor then
        return p1.TeamColor == p2.TeamColor
    end

    return false
end

-- рейкаст для валлчека (один раз создаём параметры)
local rayParams = RaycastParams.new()
rayParams.FilterType  = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

-- проверка видимости (через стены)
local function isVisible(part)
    local myChar = LP.Character
    if not myChar then return true end

    rayParams.FilterDescendantsInstances = {myChar}

    local origin    = Camera.CFrame.Position
    local direction = part.Position - origin
    local ray = Workspace:Raycast(origin, direction, rayParams)

    if not ray then return true end
    return ray.Instance:IsDescendantOf(part.Parent)
end

-- позиция мыши для Drawing (с учётом инсета)
local function getMouseDrawingPos()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(Mouse.X + inset.X, Mouse.Y + inset.Y)
end

-- позиция мыши во вьюпорте (для WorldToViewportPoint)
local function getMouseViewportPos()
    return Vector2.new(Mouse.X, Mouse.Y)
end

-- ищем ближайшего врага в фов
local function getTarget()
    local best, bestDist2D = nil, FOV

    local myChar = LP.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local mousePos = getMouseViewportPos()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not sameTeam(LP, plr) then
            local char = plr.Character
            if char and isAlive(char) then
                local part = char:FindFirstChild(AimPart)
                local hrp  = char:FindFirstChild("HumanoidRootPart")

                if part and hrp then
                    local worldDist = (myHRP.Position - hrp.Position).Magnitude
                    if worldDist <= MaxAimDistance then
                        local visible = (not WallCheck) or isVisible(part)
                        if visible then
                            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local d = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                if d < bestDist2D then
                                    bestDist2D = d
                                    best = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return best
end

-- есп объекты для каждого игрока
local ESPObjects = {}

local function createESP(player)
    if ESPObjects[player] then return end

    local esp = {
        Box      = Drawing.new("Square"),
        HealthBG = Drawing.new("Square"),
        Health   = Drawing.new("Square"),
        Name     = Drawing.new("Text"),
        Dist     = Drawing.new("Text"),
    }

    esp.Box.Filled = false
    esp.Box.Thickness = 1.5

    esp.HealthBG.Filled = true
    esp.HealthBG.Color  = Color3.fromRGB(30, 30, 30)
    esp.HealthBG.Transparency = 0.6

    esp.Health.Filled = true

    for _, t in ipairs({esp.Name, esp.Dist}) do
        t.Size    = 13
        t.Center  = true
        t.Outline = true
    end

    for _, v in pairs(esp) do v.Visible = false end

    ESPObjects[player] = esp
end

local function removeESP(player)
    local esp = ESPObjects[player]
    if esp then
        for _, v in pairs(esp) do
            pcall(function() v:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- цвет хп-бара: зелёный > жёлтый > красный
local function healthColor(hp)
    if hp > 0.5 then
        local t = (hp - 0.5) * 2
        return Color3.fromRGB(
            math.floor(255 * (1 - t)),
            255,
            0
        )
    else
        local t = hp * 2
        return Color3.fromRGB(
            255,
            math.floor(255 * t),
            0
        )
    end
end

-- создаём есп для тех кто уже в игре
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then createESP(p) end
end

connections[#connections + 1] = Players.PlayerAdded:Connect(function(p)
    if p ~= LP then createESP(p) end
end)

connections[#connections + 1] = Players.PlayerRemoving:Connect(removeESP)

-- главный цикл
connections[#connections + 1] = RunService.RenderStepped:Connect(function()
    Camera = Workspace.CurrentCamera

    local drawingMousePos = getMouseDrawingPos()

    -- фов круг
    FOVCircle.Position = drawingMousePos
    FOVCircle.Radius   = FOV
    FOVCircle.Color    = FOVCircleColor
    FOVCircle.Visible  = AimbotEnabled

    -- аимбот (камера)
    if AimbotEnabled then
        local target = getTarget()
        if target then
            local smoothFactor = math.clamp(1 - Smooth, 0.05, 1)
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, target.Position),
                smoothFactor
            )
        end
    end

    -- есп
    local myChar = LP.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for plr, esp in pairs(ESPObjects) do
        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        local shouldDraw = ESPEnabled and char and hrp and hum and hum.Health > 0

        if shouldDraw then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local scale = 1 / (pos.Z / 50)
                local size  = Vector2.new(35, 50) * scale
                local tl    = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)

                -- бокс
                esp.Box.Size     = size
                esp.Box.Position = tl
                esp.Box.Color    = BoxColor
                esp.Box.Visible  = ESPBox

                -- хп бар
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                esp.HealthBG.Size     = Vector2.new(4, size.Y)
                esp.HealthBG.Position = tl - Vector2.new(6, 0)
                esp.HealthBG.Visible  = ESPHealth

                esp.Health.Size     = Vector2.new(4, size.Y * hp)
                esp.Health.Position = esp.HealthBG.Position + Vector2.new(0, size.Y * (1 - hp))
                esp.Health.Color    = healthColor(hp)
                esp.Health.Visible  = ESPHealth

                -- ник
                esp.Name.Text     = plr.DisplayName
                esp.Name.Color    = NameColor
                esp.Name.Position = Vector2.new(pos.X, tl.Y - 16)
                esp.Name.Visible  = ESPName

                -- дистанция
                if myHRP then
                    local dist = math.floor((myHRP.Position - hrp.Position).Magnitude)
                    esp.Dist.Text     = dist .. "m"
                    esp.Dist.Color    = DistanceColor
                    esp.Dist.Position = Vector2.new(pos.X, tl.Y + size.Y + 2)
                    esp.Dist.Visible  = ESPDistance
                else
                    esp.Dist.Visible = false
                end
            else
                for _, v in pairs(esp) do v.Visible = false end
            end
        else
            for _, v in pairs(esp) do v.Visible = false end
        end
    end
end)

-- фуллбрайт
local FullbrightEnabled = false
local originalAmbient, originalBrightness, originalOutdoorAmbient, originalTime, originalFog

local function saveOriginalLighting()
    local lighting = game:GetService("Lighting")
    originalAmbient        = lighting.Ambient
    originalBrightness     = lighting.Brightness
    originalOutdoorAmbient = lighting.OutdoorAmbient
    originalTime           = lighting.ClockTime
    originalFog            = lighting.FogEnd
end

local function applyFullbright()
    local lighting = game:GetService("Lighting")
    lighting.Ambient        = Color3.fromRGB(255, 255, 255)
    lighting.Brightness     = 2
    lighting.OutdoorAmbient  = Color3.fromRGB(255, 255, 255)
    lighting.ClockTime      = 12
    lighting.FogEnd         = 1e9

    -- убираем всё что затемняет
    for _, effect in ipairs(lighting:GetChildren()) do
        if effect:IsA("Atmosphere") then
            effect.Density = 0
        elseif effect:IsA("ColorCorrectionEffect") then
            effect.Brightness = 0
            effect.TintColor = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function restoreLighting()
    local lighting = game:GetService("Lighting")
    if originalAmbient then
        lighting.Ambient        = originalAmbient
        lighting.Brightness     = originalBrightness
        lighting.OutdoorAmbient = originalOutdoorAmbient
        lighting.ClockTime      = originalTime
        lighting.FogEnd         = originalFog
    end
end

MiscTab:CreateToggle({
    Name = "Фуллбрайт (Fullbright)",
    CurrentValue = false,
    Callback = function(v)
        FullbrightEnabled = v
        if v then
            saveOriginalLighting()
            applyFullbright()
        else
            restoreLighting()
        end
    end
})

-- если игра меняет освещение — ставим обратно
connections[#connections + 1] = game:GetService("Lighting").Changed:Connect(function()
    if FullbrightEnabled then
        task.defer(applyFullbright)
    end
end)

-- фпс буст
local FPSBoostApplied = false
local fpsBoostConnection = nil

local function stripObject(v)
    if v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter")
        or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles")
        or v:IsA("Trail") or v:IsA("Beam") or v:IsA("PointLight")
        or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
        v:Destroy()
    elseif v:IsA("MeshPart") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        pcall(function() v.TextureID = "" end)
    elseif v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
    end
end

local function applyFPSBoost()
    local lighting = game:GetService("Lighting")

    -- убиваем пост-эффекты, атмосферу, небо, облака
    for _, v in ipairs(lighting:GetDescendants()) do
        pcall(function()
            if v:IsA("PostEffect") or v:IsA("Atmosphere")
                or v:IsA("Sky") or v:IsA("Clouds") then
                v:Destroy()
            end
        end)
    end

    -- стрипаем воркспейс
    for _, v in ipairs(Workspace:GetDescendants()) do
        pcall(function() stripObject(v) end)
    end

    -- террейн
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            terrain.Decoration = false
        end)
    end

    -- рендер на минимум
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    -- совместимое освещение (если эксплоит поддерживает)
    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(lighting, "Technology", Enum.Technology.Compatibility)
        end)
    end

    -- новые объекты тоже стрипаем
    if fpsBoostConnection then
        fpsBoostConnection:Disconnect()
    end
    fpsBoostConnection = Workspace.DescendantAdded:Connect(function(v)
        task.defer(function()
            pcall(function() stripObject(v) end)
        end)
    end)
    connections[#connections + 1] = fpsBoostConnection
end

MiscTab:CreateButton({
    Name = "⚡ ФПС Буст (необратимо)",
    Callback = function()
        if FPSBoostApplied then return end
        FPSBoostApplied = true
        applyFPSBoost()
        Rayfield:Notify({
            Title = "ФПС Буст",
            Content = "Графика понижена до минимума. Для отмены — реджойн.",
            Duration = 5,
        })
    end
})

MiscTab:CreateButton({
    Name = "Выгрузить скрипт",
    Callback = function()
        -- дисконнектим всё
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}

        -- убираем фов круг
        pcall(function() FOVCircle:Remove() end)

        -- убираем есп
        local toRemove = {}
        for plr in pairs(ESPObjects) do
            toRemove[#toRemove + 1] = plr
        end
        for _, plr in ipairs(toRemove) do
            removeESP(plr)
        end

        -- закрываем ui
        Rayfield:Destroy()
    end
})
