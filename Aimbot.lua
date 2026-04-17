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

-- ═══════════════════════════════════════════
--  Сервисы и локальные переменные
-- ═══════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local GuiService        = game:GetService("GuiService")
local UserInputService  = game:GetService("UserInputService")

local Camera = Workspace.CurrentCamera
local LP     = Players.LocalPlayer
local Mouse  = LP:GetMouse()

-- ═══════════════════════════════════════════
--  Настройки аимбота (камера)
-- ═══════════════════════════════════════════
local AimbotEnabled  = false
local AimPart        = "Head"
local Smooth         = 0.2
local FOV            = 250
local MaxAimDistance  = 1500
local WallCheck      = false
local TeamCheck      = false
local FOVCircleColor = Color3.fromRGB(255, 255, 255)

-- ═══════════════════════════════════════════
--  Настройки Silent Aim
-- ═══════════════════════════════════════════
local SilentAimEnabled   = false
local SilentAimPart      = "Head"
local SilentAimFOV       = 250
local SilentAimMaxDist   = 1500
local SilentAimWallCheck = false
local SilentAimShowFOV   = true
local SilentAimFOVColor  = Color3.fromRGB(255, 50, 50)

-- Текущая цель silent aim (обновляется каждый кадр)
local silentTarget = nil

-- ═══════════════════════════════════════════
--  Настройки ESP
-- ═══════════════════════════════════════════
local ESPEnabled  = false
local ESPBox      = false
local ESPHealth   = false
local ESPName     = false
local ESPDistance  = false
local BoxColor    = Color3.fromRGB(255, 255, 255)
local NameColor   = Color3.fromRGB(255, 255, 255)
local DistanceColor = Color3.fromRGB(200, 200, 200)

-- Хранилище для соединений (cleanup)
local connections = {}

-- ═══════════════════════════════════════════
--  Вкладки
-- ═══════════════════════════════════════════
local AimbotTab = Window:CreateTab("Аимбот")
local SilentTab = Window:CreateTab("Silent Aim (не работает)")
local ESPTab    = Window:CreateTab("ESP")
local MiscTab   = Window:CreateTab("Прочее")

-- ═══════════════════════════════════════════
--  UI: Аимбот (камера)
-- ═══════════════════════════════════════════
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

-- ═══════════════════════════════════════════
--  UI: Silent Aim
-- ═══════════════════════════════════════════
SilentTab:CreateToggle({
    Name = "Включить Silent Aim",
    CurrentValue = false,
    Callback = function(v) SilentAimEnabled = v end
})

SilentTab:CreateToggle({
    Name = "Проверка на стены",
    CurrentValue = false,
    Callback = function(v) SilentAimWallCheck = v end
})

SilentTab:CreateToggle({
    Name = "Показывать круг FOV",
    CurrentValue = true,
    Callback = function(v) SilentAimShowFOV = v end
})

SilentTab:CreateDropdown({
    Name = "Часть тела",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    Callback = function(v)
        if type(v) == "table" then
            SilentAimPart = v[1]
        else
            SilentAimPart = v
        end
    end
})

SilentTab:CreateSlider({
    Name = "FOV",
    Range = {50, 800},
    Increment = 10,
    CurrentValue = 250,
    Callback = function(v) SilentAimFOV = v end
})

SilentTab:CreateSlider({
    Name = "Дистанция",
    Range = {0, 5000},
    Increment = 5,
    CurrentValue = 1500,
    Callback = function(v) SilentAimMaxDist = v end
})

SilentTab:CreateColorPicker({
    Name = "Цвет круга FOV",
    Color = SilentAimFOVColor,
    Callback = function(c) SilentAimFOVColor = c end
})

-- ═══════════════════════════════════════════
--  UI: ESP
-- ═══════════════════════════════════════════
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

-- ═══════════════════════════════════════════
--  Drawing: FOV-круги
-- ═══════════════════════════════════════════
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled      = false
FOVCircle.Thickness   = 1.5
FOVCircle.Transparency = 1
FOVCircle.NumSides    = 64

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Filled      = false
SilentFOVCircle.Thickness   = 1.5
SilentFOVCircle.Transparency = 1
SilentFOVCircle.NumSides    = 64

-- ═══════════════════════════════════════════
--  Утилиты
-- ═══════════════════════════════════════════

--- Проверка, жив ли персонаж
local function isAlive(char)
    if not char then return false end
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

--- Проверка на одну команду (учитывает Neutral)
local function sameTeam(p1, p2)
    if not TeamCheck then return false end

    -- если оба нейтралы — считаем врагами (игра без команд)
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

--- Raycast-params (создаём один раз, переиспользуем)
local rayParams = RaycastParams.new()
rayParams.FilterType  = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

--- Проверка видимости через стены
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

--- Позиция мыши для Drawing-объектов (абсолютные экранные координаты)
local function getMouseDrawingPos()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(Mouse.X + inset.X, Mouse.Y + inset.Y)
end

--- Позиция мыши в viewport (для сравнения с WorldToViewportPoint)
local function getMouseViewportPos()
    return Vector2.new(Mouse.X, Mouse.Y)
end

--- Универсальный поиск ближайшей цели в FOV
local function findTarget(fovRadius, aimPartName, maxDist, useWallCheck)
    local best, bestDist2D = nil, fovRadius

    local myChar = LP.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local mousePos = getMouseViewportPos()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not sameTeam(LP, plr) then
            local char = plr.Character
            if char and isAlive(char) then
                local part = char:FindFirstChild(aimPartName)
                local hrp  = char:FindFirstChild("HumanoidRootPart")

                if part and hrp then
                    local worldDist = (myHRP.Position - hrp.Position).Magnitude
                    if worldDist <= maxDist then
                        local visible = (not useWallCheck) or isVisible(part)
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

--- Обёртки для обратной совместимости
local function getTarget()
    return findTarget(FOV, AimPart, MaxAimDistance, WallCheck)
end

local function getSilentTarget()
    return findTarget(SilentAimFOV, SilentAimPart, SilentAimMaxDist, SilentAimWallCheck)
end

-- ═══════════════════════════════════════════
--  Silent Aim: Прямой вызов Damage:InvokeServer (без хуков!)
-- ═══════════════════════════════════════════
-- Флоу: Atirar (выстрел) → Damage (урон, InvokeServer) → HitEffect (визуал)
-- Никаких хуков метатаблицы — игра детектит.

local ACS_Events    = game:GetService("ReplicatedStorage"):WaitForChild("ACS_MICTLAN"):WaitForChild("Events")
local AtirarRemote  = ACS_Events:WaitForChild("Atirar")
local DamageRemote  = ACS_Events:WaitForChild("Damage")
local HitRemote     = ACS_Events:WaitForChild("HitEffect")
local HttpService   = game:GetService("HttpService")

--- Получить текущее оружие (Tool) в руках игрока
local function getEquippedWeapon()
    local char = LP.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end

--- Кэш конфига оружия (чтобы не require каждый кадр)
local cachedWeaponName   = nil
local cachedWeaponConfig = nil
local cachedModifiers    = nil

--- Извлечь конфиг оружия из его ModuleScript
local function getWeaponConfig(weapon)
    if cachedWeaponName == weapon.Name then
        return cachedWeaponConfig, cachedModifiers
    end

    -- Ищем ModuleScript внутри инструмента
    for _, child in ipairs(weapon:GetDescendants()) do
        if child:IsA("ModuleScript") then
            local ok, cfg = pcall(require, child)
            if ok and type(cfg) == "table" and cfg.gunName then
                cachedWeaponName = weapon.Name
                cachedWeaponConfig = cfg
                cachedModifiers = {
                    SpreadRM = 1,
                    MuzzleVelocity = 1,
                    MaxSpread = 1,
                    GLVelocity = 1,
                    DamageMod = 1,
                    AimRM = 1,
                    MaxRecoilPower = 1,
                    AimInaccuracyStepAmount = 1,
                    WalkMult = 1,
                    RecoilPowerStepAmount = 1,
                    minDamageMod = 1,
                    MinSpread = 1,
                    MinRecoilPower = 1,
                    AimInaccuracyDecrease = 1,
                    adsTime = 1,
                    ZoomValue = cfg.Zoom or 60,
                    Zoom2Value = cfg.Zoom2 or 50,
                    Zoom3Value = cfg.Zoom3 or 40,
                    gunRecoilMod = {
                        RecoilRight = 1,
                        RecoilUp = 1,
                        RecoilTilt = 1,
                        RecoilLeft = 1,
                    },
                    camRecoilMod = {
                        RecoilRight = 1,
                        RecoilTilt = 1,
                        RecoilUp = 1,
                        RecoilLeft = 1,
                    },
                }
                return cachedWeaponConfig, cachedModifiers
            end
        end
    end

    return nil, nil
end

--- Определить зону попадания (1=голова, 2=торс, 3=конечности)
local function getHitZone()
    if SilentAimPart == "Head" then return 1 end
    if SilentAimPart == "LowerTorso" then return 3 end
    return 2
end

--- Конструирование буфера для HitEffect (визуал)
local function constructHitBuffer(hitPos)
    local buf = buffer.create(17)
    buffer.writeu8(buf, 0, 1)
    buffer.writef32(buf, 1, hitPos.X)
    buffer.writef32(buf, 5, hitPos.Y)
    buffer.writef32(buf, 9, hitPos.Z)
    buffer.writeu8(buf, 13, 130)
    buffer.writeu8(buf, 14, 0)
    buffer.writeu8(buf, 15, 15)
    buffer.writeu8(buf, 16, 1)
    return buf
end

--- Выстрел silent aim: Atirar + Damage + HitEffect
local function silentFire(weapon, targetPart)
    local targetChar = targetPart.Parent
    if not targetChar then return end

    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local config, modifiers = getWeaponConfig(weapon)
    if not config then return end

    -- Расстояние от игрока до цели
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local distance = (myHRP.Position - targetPart.Position).Magnitude

    local hitZone = getHitZone()
    local token = HttpService:GenerateGUID(true) .. "-" .. tostring(math.random(1000000000, 9999999999))

    -- 1) Выстрел
    AtirarRemote:FireServer(weapon, false, false)

    -- 2) Урон (InvokeServer с 9 аргументами, args[7] и [8] = nil)
    pcall(function()
        DamageRemote:InvokeServer(weapon, humanoid, distance, hitZone, config, modifiers, nil, nil, token)
    end)

    -- 3) Визуальный эффект
    local collisionPart = targetChar:FindFirstChild("CollisionPart") or targetPart
    pcall(function()
        HitRemote:FireServer({collisionPart}, constructHitBuffer(targetPart.Position))
    end)
end

-- Трекаем зажатие ЛКМ
local isMouseDown = false
connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        isMouseDown = true
    end
end)
connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isMouseDown = false
    end
end)

-- Кулдаун между выстрелами silent aim
local lastSilentShot = 0
local SILENT_COOLDOWN = 0.1 -- ~10 выстрелов/сек

-- ═══════════════════════════════════════════
--  ESP: создание / удаление объектов
-- ═══════════════════════════════════════════
local ESPObjects = {}

local function createESP(player)
    if ESPObjects[player] then return end -- не дублировать

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

--- Цвет HP-бара на основе процента ХП (зелёный → желтый → красный)
local function healthColor(hp)
    if hp > 0.5 then
        -- зелёный → жёлтый
        local t = (hp - 0.5) * 2
        return Color3.fromRGB(
            math.floor(255 * (1 - t)),
            255,
            0
        )
    else
        -- жёлтый → красный
        local t = hp * 2
        return Color3.fromRGB(
            255,
            math.floor(255 * t),
            0
        )
    end
end

-- Инициализация ESP для уже присутствующих игроков
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then createESP(p) end
end

connections[#connections + 1] = Players.PlayerAdded:Connect(function(p)
    if p ~= LP then createESP(p) end
end)

connections[#connections + 1] = Players.PlayerRemoving:Connect(removeESP)

-- ═══════════════════════════════════════════
--  Главный цикл
-- ═══════════════════════════════════════════
connections[#connections + 1] = RunService.RenderStepped:Connect(function()
    -- Обновляем ссылку на камеру (может измениться при респавне)
    Camera = Workspace.CurrentCamera

    local drawingMousePos = getMouseDrawingPos()

    -- ────── Silent Aim: обновление цели + стрельба ──────
    if SilentAimEnabled then
        silentTarget = getSilentTarget()

        -- Стреляем по цели при зажатой ЛКМ
        if isMouseDown and silentTarget then
            local now = tick()
            if now - lastSilentShot >= SILENT_COOLDOWN then
                lastSilentShot = now
                task.spawn(function()
                    local weapon = getEquippedWeapon()
                    if not weapon then return end
                    local tgt = silentTarget
                    if not tgt then return end
                    silentFire(weapon, tgt)
                end)
            end
        end
    else
        silentTarget = nil
    end

    -- ────── FOV-круг аимбота ──────
    FOVCircle.Position = drawingMousePos
    FOVCircle.Radius   = FOV
    FOVCircle.Color    = FOVCircleColor
    FOVCircle.Visible  = AimbotEnabled

    -- ────── FOV-круг Silent Aim ──────
    SilentFOVCircle.Position = drawingMousePos
    SilentFOVCircle.Radius   = SilentAimFOV
    SilentFOVCircle.Color    = SilentAimFOVColor
    SilentFOVCircle.Visible  = SilentAimEnabled and SilentAimShowFOV

    -- ────── Аимбот (камера) ──────
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

    -- ────── ESP ──────
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

                -- Бокс
                esp.Box.Size     = size
                esp.Box.Position = tl
                esp.Box.Color    = BoxColor
                esp.Box.Visible  = ESPBox

                -- Полоска ХП
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                esp.HealthBG.Size     = Vector2.new(4, size.Y)
                esp.HealthBG.Position = tl - Vector2.new(6, 0)
                esp.HealthBG.Visible  = ESPHealth

                esp.Health.Size     = Vector2.new(4, size.Y * hp)
                esp.Health.Position = esp.HealthBG.Position + Vector2.new(0, size.Y * (1 - hp))
                esp.Health.Color    = healthColor(hp)
                esp.Health.Visible  = ESPHealth

                -- Ник
                esp.Name.Text     = plr.DisplayName
                esp.Name.Color    = NameColor
                esp.Name.Position = Vector2.new(pos.X, tl.Y - 16)
                esp.Name.Visible  = ESPName

                -- Дистанция
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
                -- вне экрана — скрыть
                for _, v in pairs(esp) do v.Visible = false end
            end
        else
            -- ESP выключен / персонаж мёртв — скрыть
            for _, v in pairs(esp) do v.Visible = false end
        end
    end
end)

-- ═══════════════════════════════════════════
--  UI: Фуллбрайт и прочее
-- ═══════════════════════════════════════════
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

    -- убираем все эффекты затемнения
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

-- Поддержка: принудительно восстанавливаем fullbright если игра меняет освещение
connections[#connections + 1] = game:GetService("Lighting").Changed:Connect(function()
    if FullbrightEnabled then
        task.defer(applyFullbright)
    end
end)

-- ═══════════════════════════════════════════
--  ФПС Буст
-- ═══════════════════════════════════════════
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

    -- Убиваем пост-эффекты, атмосферу, облака, небо
    for _, v in ipairs(lighting:GetDescendants()) do
        pcall(function()
            if v:IsA("PostEffect") or v:IsA("Atmosphere")
                or v:IsA("Sky") or v:IsA("Clouds") then
                v:Destroy()
            end
        end)
    end

    -- Обрабатываем все объекты в workspace
    for _, v in ipairs(Workspace:GetDescendants()) do
        pcall(function() stripObject(v) end)
    end

    -- Terrain
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

    -- Качество рендера на минимум
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    -- Технология освещения на совместимость (если доступно)
    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(lighting, "Technology", Enum.Technology.Compatibility)
        end)
    end

    -- Подписываемся на новые объекты — стрипаем и их
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
        -- Отключаем все соединения
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}

        -- Хуков нет — восстанавливать нечего

        silentTarget = nil

        -- Удаляем FOV-круги
        pcall(function() FOVCircle:Remove() end)
        pcall(function() SilentFOVCircle:Remove() end)

        -- Удаляем все ESP-объекты
        local toRemove = {}
        for plr in pairs(ESPObjects) do
            toRemove[#toRemove + 1] = plr
        end
        for _, plr in ipairs(toRemove) do
            removeESP(plr)
        end

        -- Закрываем UI
        Rayfield:Destroy()
    end
})
