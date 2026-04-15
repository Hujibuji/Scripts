--[[
    hueta.cc - Notoriety
    Улучшенная версия v2.2
    Автор: kaLLoware

    Список изменений v2.2:
    - Исправлен Kill All v2.
    - Интерфейс переписан под Rayfield
    - Весь текст переведён на русский язык
]]
-- ==================== ИНИЦИАЛИЗАЦИЯ ====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==================== СЕРВИСЫ ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ==================== СОЗДАНИЕ ОКНА ====================
local Window = Rayfield:CreateWindow({
    Name = "hueta.cc - Notoriety v2.2",
    Icon = "swords",
    LoadingTitle = "hueta.cc",
    LoadingSubtitle = "от kaLLoware — Версия ADMIN",
    ShowText = "hueta.cc",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
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

-- ==================== ПЕРЕМЕННЫЕ ====================
-- Оружие
local selectedGun = "M16"
local selectedClass = "Class 1"

-- Взаимодействие
local instantInteractEnabled = false
local instantInteractConnection = nil

-- Мод игрока
local infiniteStaminaEnabled = false
local infiniteStaminaLoop = nil

local walkSpeedEnabled = false
local walkSpeedValue = 50
local tpWalkConnection = nil

local infiniteJumpEnabled = false
local infJumpConnection = nil

local noclipEnabled = false
local noclipLoop = nil

local gravityValue = 196.2
local customGravityEnabled = false
local gravityLoop = nil

-- ESP
local cameraESPEnabled = false
local policeESPEnabled = false
local civilianESPEnabled = false
local keyCardESPEnabled = false
local cameraHighlights = {}
local policeHighlights = {}
local civilianHighlights = {}
local keyCardHighlights = {}
local espLoops = {}

-- ESP для конкретных карт
local selectedMap = "The Ozela Heist"
local ropeESPEnabled = false
local hookESPEnabled = false
local codeTableESPEnabled = false
local ropeHighlights = {}
local hookHighlights = {}
local codeTableHighlights = {}
local ropeESPLoop = nil
local hookESPLoop = nil
local codeTableESPLoop = nil

-- Система кодов Ozela Heist
local codeStatusLabel = nil
local usbStatusLabel = nil
local detectedCodes = {}
local correctCode = ""
local correctColorBox = ""

-- Прицеливание
local aimEnabled = false
local aimPart = "Head"
local aimFOV = 200
local aimSensitivity = 50
local useSensitivity = true
local fovCircleEnabled = false
local currentTarget = nil
local aiming = false

-- Боевые функции
local visualKillAllActive = false

-- ==================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ====================
local function getRS()
    return ReplicatedStorage:WaitForChild("RS_Package", 5)
end

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = 4483362458,
    })
end

local function safeCall(func, errorMsg)
    local success, err = pcall(func)
    if not success and errorMsg then
        warn(errorMsg .. ": " .. tostring(err))
    end
    return success
end

-- ==================== ФУНКЦИИ ПОДСВЕТКИ ====================
local function createHighlight(object, color)
    if not object or not object:IsDescendantOf(Workspace) then return nil end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Adornee = object
    highlight.Parent = object

    return highlight
end

local function clearHighlights(tbl)
    for i = #tbl, 1, -1 do
        if tbl[i] then
            safeCall(function()
                tbl[i]:Destroy()
            end)
        end
        tbl[i] = nil
    end
end

-- ==================== КРУГ FOV ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = aimFOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

-- ==================== ФУНКЦИИ ОРУЖИЯ ====================
local function getEquippedWeapon()
    local character = LocalPlayer.Character
    if not character then return nil end
    local tool = character:FindFirstChildOfClass("Tool")
    return tool
end

local function buffCurrentWeapon()
    safeCall(function()
        local charFolder = Workspace.Criminals:FindFirstChild(LocalPlayer.Name)
        if not charFolder then
            notify("Ошибка", "Вы не в команде Преступников!")
            return
        end

        local buffed = 0
        for _, obj in pairs(charFolder:GetChildren()) do
            local dataModule = obj:FindFirstChild("Data")
            if dataModule and dataModule:IsA("ModuleScript") then
                local weaponData = require(dataModule)

                -- Супер-усиление
                weaponData["Damage"] = 9999
                weaponData["FireDelay"] = 0.01
                weaponData["MagazineSize"] = 999
                weaponData["AmmoMax"] = 999
                weaponData["RecoilSpeed"] = 0
                weaponData["Accuracy"] = 100
                weaponData["ShakeMagnitude"] = 0
                weaponData["ShakeRoughness"] = 0
                weaponData["RecoilDirectionPattern"] = {Vector2.new(0,0)}
                weaponData["RecoilCameraDirectionPattern"] = {Vector2.new(0,0)}
                weaponData["BulletSpeed"] = 5000
                weaponData["ReloadTime"] = 0.1
                weaponData["LongerReloadTime"] = 0.1

                buffed = buffed + 1
            end
        end

        if buffed > 0 then
            notify("Оружие изменено", buffed .. " оружие(й) улучшено!", 4)
        else
            notify("Предупреждение", "Оружие для изменения не найдено")
        end
    end, "Ошибка при изменении оружия")
end

-- ==================== ФУНКЦИИ ПРИЦЕЛИВАНИЯ ====================
local function getClosestPolice()
    local closest = nil
    local shortestDistance = aimFOV

    for _, folderName in ipairs({"Police", "Bodies"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, npc in pairs(folder:GetChildren()) do
                if npc and npc:FindFirstChild(aimPart) then
                    local humanoid = npc:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local targetPart = npc:FindFirstChild(aimPart)
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                        if onScreen then
                            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (mousePos - targetPos).Magnitude

                            if distance < shortestDistance then
                                closest = npc
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

local function aimAtTarget(target)
    if not target or not target:FindFirstChild(aimPart) then return end

    local targetPart = target:FindFirstChild(aimPart)
    if not targetPart then return end

    local targetPos = targetPart.Position
    local cameraPos = Camera.CFrame.Position

    if useSensitivity then
        local lookAt = CFrame.new(cameraPos, targetPos)
        local lerpAmount = aimSensitivity / 100
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, lerpAmount)
    else
        Camera.CFrame = CFrame.new(cameraPos, targetPos)
    end
end

-- ==================== ФУНКЦИИ УНИЧТОЖЕНИЯ ====================
local function getTool()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
end

local function fireHit(tool, hitPart)
    if not tool or not hitPart then return false end

    return safeCall(function()
        local rs = getRS()
        if not rs then return end

        local args = {
            [1] = tool,
            [2] = hitPart,
            [3] = false,
            [6] = Vector3.new(0, 0, 0),
            [7] = 90,
            [9] = hitPart.Position
        }

        rs.Assets.Remotes.HitObject:FireServer(unpack(args, 1, 9))
    end)
end

-- ==================== БОЕВЫЕ ФУНКЦИИ ====================
local function visualKillAll()
    task.spawn(function()
        while visualKillAllActive do
            local character = LocalPlayer.Character
            if not character then
                task.wait(0.5)
                continue
            end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                task.wait(0.5)
                continue
            end

            -- Помещаем всех NPC в одно место (стопкой)
            local targetPos = hrp.CFrame * CFrame.new(0, 0, -10)

            for _, folderName in ipairs({"Police", "Bodies"}) do
                local folder = Workspace:FindFirstChild(folderName)
                if folder then
                    for _, npc in pairs(folder:GetChildren()) do
                        if not visualKillAllActive then break end

                        local npcHrp = npc:FindFirstChild("HumanoidRootPart")
                        local humanoid = npc:FindFirstChildOfClass("Humanoid")

                        if npcHrp and humanoid and humanoid.Health > 0 then
                            npcHrp.CFrame = targetPos
                            npcHrp.Anchored = true

                            local lookAt = CFrame.new(npcHrp.Position, hrp.Position)
                            npcHrp.CFrame = lookAt
                        end
                    end
                end
            end

            task.wait(0.1)
        end
    end)
end

-- ==================== ОПРЕДЕЛЕНИЕ КОДА OZELA HEIST ====================
local function detectColorBoxCode()
    local result = {
        codes = {},
        correctCode = "",
        correctTitle = "",
        colorSequence = "",
        colorBoxName = ""
    }

    safeCall(function()
        local cardReader = Workspace:FindFirstChild("prop_stadium_cardReader")
        if cardReader then
            local main = cardReader:FindFirstChild("main")
            if main then
                local serial = main:FindFirstChild("serial")
                if serial then
                    local surfaceGui = serial:FindFirstChild("SurfaceGui")
                    if surfaceGui then
                        local textLabel = surfaceGui:FindFirstChild("TextLabel")
                        if textLabel and textLabel.Text ~= "" then
                            result.correctCode = textLabel.Text
                        end
                    end
                end
            end
        end

        local blueprints = Workspace:FindFirstChild("Blueprints")
        if blueprints then
            local stadiumBlueprint = blueprints:FindFirstChild("prop_stadium_blueprintTableRNG")
            if stadiumBlueprint then
                local blueprint = stadiumBlueprint:FindFirstChild("prop_stadium_blueprint")
                if blueprint then
                    for i = 1, 3 do
                        local numbered = blueprint:FindFirstChild(tostring(i))
                        if numbered then
                            local serial = numbered:FindFirstChild("serial")
                            if serial then
                                local surfaceGui = serial:FindFirstChild("SurfaceGui")
                                if surfaceGui then
                                    local textLabel = surfaceGui:FindFirstChild("TextLabel")
                                    if textLabel and textLabel.Text ~= "" then
                                        local codeTitle = textLabel.Text

                                        if codeTitle == result.correctCode and result.correctCode ~= "" then
                                            result.correctTitle = codeTitle

                                            local colors = numbered:FindFirstChild("colors")
                                            if colors then
                                                local colorParts = {}
                                                for j = 1, 4 do
                                                    local colorPart = colors:FindFirstChild(tostring(j))
                                                    if colorPart then
                                                        local colorSurface = colorPart:FindFirstChild("SurfaceGui")
                                                        if colorSurface then
                                                            local colorLabel = colorSurface:FindFirstChild("TextLabel")
                                                            if colorLabel and colorLabel.Text ~= "" then
                                                                table.insert(colorParts, colorLabel.Text)
                                                            end
                                                        end
                                                    end
                                                end
                                                result.colorSequence = table.concat(colorParts, " ")
                                            end
                                        end

                                        table.insert(result.codes, {
                                            number = i,
                                            title = codeTitle,
                                            isCorrect = (codeTitle == result.correctCode and result.correctCode ~= "")
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local colorBoxRNG = Workspace:FindFirstChild("colorBoxRNG")
        if colorBoxRNG and result.correctTitle ~= "" then
            for _, colorBox in pairs(colorBoxRNG:GetChildren()) do
                if colorBox:IsA("Model") or colorBox:IsA("BasePart") then
                    local serial = colorBox:FindFirstChild("serial")
                    if serial then
                        local surfaceGui = serial:FindFirstChild("SurfaceGui")
                        if surfaceGui then
                            local textLabel = surfaceGui:FindFirstChild("TextLabel")
                            if textLabel and textLabel.Text == result.correctTitle then
                                result.colorBoxName = colorBox.Name
                                break
                            end
                        end
                    end
                end
            end
        end
    end, "Ошибка при определении кода цветного ящика")

    return result
end

local function getUSBComputerStatus()
    local status = "Не найдено"

    safeCall(function()
        local usbComputer = Workspace:FindFirstChild("UsedUSBComputer")
        if usbComputer then
            local screen = usbComputer:FindFirstChild("Screen")
            if screen then
                local surfaceGui = screen:FindFirstChild("SurfaceGui")
                if surfaceGui then
                    local textLabel = surfaceGui:FindFirstChild("TextLabel")
                    if textLabel and textLabel.Text ~= "" then
                        status = textLabel.Text
                    end
                end
            end
        end
    end, "Ошибка при получении статуса USB")

    return status
end

local function updateColorBoxStatus()
    if not codeStatusLabel then return end

    local info = detectColorBoxCode()

    local codeText = "🔐 Определение кода цветного ящика:\n\n"

    if #info.codes > 0 then
        codeText = codeText .. "📋 Доступные коды:\n"
        for _, code in ipairs(info.codes) do
            local marker = code.isCorrect and "✅" or "❌"
            codeText = codeText .. string.format("  %s Код #%d: %s\n", marker, code.number, code.title)
        end
        codeText = codeText .. "\n"
    else
        codeText = codeText .. "❌ Коды не обнаружены\n\n"
    end

    if info.correctCode ~= "" then
        codeText = codeText .. "✅ Правильный код: " .. info.correctCode .. "\n"
    else
        codeText = codeText .. "❌ Правильный код не найден\n"
    end

    if info.colorSequence ~= "" then
        codeText = codeText .. "🎨 Последовательность цветов: " .. info.colorSequence .. "\n"
    end

    if info.colorBoxName ~= "" then
        codeText = codeText .. "📦 Цветной ящик: " .. info.colorBoxName
    end

    codeStatusLabel:Set(codeText)

    return info
end

local function updateUSBStatus()
    if not usbStatusLabel then return end

    local status = getUSBComputerStatus()
    local usbText = "💻 Код компьютера USB:\n\n" .. status
    usbStatusLabel:Set(usbText)
end

-- ==================== ВКЛАДКИ ====================
local Tabs = {
    Weapons    = Window:CreateTab("Оружие",          "sword"),
    Interact   = Window:CreateTab("Взаимодействие",  "hand"),
    Teleports  = Window:CreateTab("Телепорты",       "navigation"),
    Destruction= Window:CreateTab("Разрушение",      "bomb"),
    Player     = Window:CreateTab("Мод игрока",      "user"),
    Aim        = Window:CreateTab("Боевые",          "crosshair"),
    ESP        = Window:CreateTab("ESP",             "eye"),
    Maps       = Window:CreateTab("Карты",           "map"),
    Stats      = Window:CreateTab("Статистика",      "bar-chart"),
    Changelog  = Window:CreateTab("Изменения",       "file-text"),
}

-- ==================== ВКЛАДКА ИЗМЕНЕНИЙ ====================
Tabs.Changelog:CreateSection("📋 История версий")

Tabs.Changelog:CreateLabel("🆕 Версия 2.2 — Текущая\n• Исправлен Kill All v2.\n• Интерфейс переписан под Rayfield.\n• Весь текст переведён на русский язык.")

Tabs.Changelog:CreateLabel("📦 Версия 2.1\n• Добавлен ESP и телепорт к Ключ-карте\n• Добавлена система определения кода Ozela Heist\n• Добавлено авто-обнаружение цветного ящика и телепорт\n• Добавлен монитор статуса USB компьютера\n• Удалены запатченные функции (Kill Aura, Kill All)\n• Добавлена вкладка Изменений\n• Улучшены функции Ozela Heist")

Tabs.Changelog:CreateLabel("📦 Версия 2.0\n• Исправлен и оптимизирован Kill Aura\n• Исправлена ошибка загрузки TP Walk\n• Улучшена система безопасности\n• Оптимизирована производительность\n• Более чистый и организованный код")

Tabs.Changelog:CreateSection("ℹ️ Информация")

Tabs.Changelog:CreateLabel("О hueta.cc\n\nАвтор: kaLLoware\n\nЭтот хаб предоставляет различные удобные функции для Notoriety.\n\nФункции регулярно обновляются для поддержания работоспособности.\n\nЕсли вы обнаружите баги — сообщите разработчику.")

-- ==================== ВКЛАДКА ОРУЖИЯ ====================
Tabs.Weapons:CreateSection("Улучшение оружия")

Tabs.Weapons:CreateButton({
    Name = "🔥 Улучшить текущее оружие (OP)",
    Callback = buffCurrentWeapon,
})

Tabs.Weapons:CreateSection("Получить оружие")

Tabs.Weapons:CreateInput({
    Name = "Название оружия",
    CurrentValue = "M16",
    PlaceholderText = "Пример: M16, AK47, Shotgun",
    RemoveTextAfterFocusLost = false,
    Flag = "GunName",
    Callback = function(value)
        selectedGun = value
    end,
})

Tabs.Weapons:CreateInput({
    Name = "Название класса",
    CurrentValue = "Class 1",
    PlaceholderText = "Пример: Class 1, Class 2",
    RemoveTextAfterFocusLost = false,
    Flag = "ClassName",
    Callback = function(value)
        selectedClass = value
    end,
})

Tabs.Weapons:CreateButton({
    Name = "Получить данные оружия",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.GetGunData:InvokeServer(selectedGun)
                notify("Оружие", "Данные получены: " .. selectedGun)
            end
        end, "Ошибка получения данных")
    end,
})

Tabs.Weapons:CreateButton({
    Name = "Назначить оружие классу",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.SetGunForClass:FireServer(selectedClass, selectedGun, 0)
                notify("Оружие", selectedGun .. " → " .. selectedClass)
            end
        end, "Ошибка назначения оружия")
    end,
})

Tabs.Weapons:CreateButton({
    Name = "Активировать класс",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.SetClass:FireServer(selectedClass)
                notify("Оружие", "Класс активирован: " .. selectedClass)
            end
        end, "Ошибка активации класса")
    end,
})

-- ==================== ВКЛАДКА ВЗАИМОДЕЙСТВИЙ ====================
Tabs.Interact:CreateSection("Быстрые взаимодействия")

Tabs.Interact:CreateToggle({
    Name = "⚡ Мгновенное взаимодействие",
    CurrentValue = false,
    Flag = "InstantInteract",
    Callback = function(value)
        instantInteractEnabled = value

        if instantInteractConnection then
            instantInteractConnection:Disconnect()
            instantInteractConnection = nil
        end

        if value then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                    obj.MaxActivationDistance = 20
                    obj.RequiresLineOfSight = false
                end
            end

            instantInteractConnection = Workspace.DescendantAdded:Connect(function(obj)
                if instantInteractEnabled and obj:IsA("ProximityPrompt") then
                    task.wait()
                    obj.HoldDuration = 0
                    obj.MaxActivationDistance = 20
                    obj.RequiresLineOfSight = false
                end
            end)

            notify("Взаимодействие", "Мгновенное взаимодействие ВКЛЮЧЕНО!", 2)
        else
            notify("Взаимодействие", "Мгновенное взаимодействие выключено", 2)
        end
    end,
})

Tabs.Interact:CreateButton({
    Name = "Применить мгновенное взаимодействие",
    Callback = function()
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
                obj.MaxActivationDistance = 20
                obj.RequiresLineOfSight = false
                count = count + 1
            end
        end
        notify("Взаимодействие", count .. " промптов изменено!", 3)
    end,
})

Tabs.Interact:CreateSection("Действия с NPC")

Tabs.Interact:CreateButton({
    Name = "Бросить сумку на пол",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.ThrowBag:FireServer(Vector3.new(-0.98, -0.16, 0.07))
                notify("Взаимодействие", "Сумка брошена!")
            end
        end, "Ошибка при броске сумки")
    end,
})

Tabs.Interact:CreateButton({
    Name = "Кричать на всех гражданских",
    Callback = function()
        safeCall(function()
            local citizens = Workspace:FindFirstChild("Citizens")
            if citizens then
                local targetList = {}
                for _, citizen in pairs(citizens:GetChildren()) do
                    table.insert(targetList, citizen)
                end

                local rs = getRS()
                if rs then
                    rs.Remotes.PlayerYell:FireServer(targetList)
                    notify("Взаимодействие", "Кричим на " .. #targetList .. " гражданских")
                end
            else
                notify("Взаимодействие", "Гражданских не найдено!")
            end
        end, "Ошибка при крике")
    end,
})

-- ==================== ВКЛАДКА ТЕЛЕПОРТОВ ====================
Tabs.Teleports:CreateSection("Общие телепорты")

Tabs.Teleports:CreateButton({
    Name = "🔑 Телепорт к Ключ-карте",
    Callback = function()
        safeCall(function()
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                notify("Телепорт", "❌ Персонаж не найден!")
                return
            end

            local hrp = character.HumanoidRootPart
            local map = Workspace:FindFirstChild("Map")
            if not map then notify("Телепорт", "❌ Карта не найдена!") return end

            local keyCardFolder = map:FindFirstChild("KeyCard")
            if not keyCardFolder then notify("Телепорт", "❌ Папка KeyCard не найдена!") return end

            local keyCard = keyCardFolder:FindFirstChild("KeyCard")
            if not keyCard then notify("Телепорт", "❌ KeyCard не найдена!") return end

            local targetPart = keyCard.PrimaryPart or keyCard:FindFirstChildWhichIsA("BasePart", true)
            if not targetPart then notify("Телепорт", "❌ У KeyCard нет частей!") return end

            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            notify("Телепорт", "✅ Телепортировался к Ключ-карте!", 2)
        end, "Ошибка телепорта к KeyCard")
    end,
})

-- ==================== ВКЛАДКА РАЗРУШЕНИЯ ====================
Tabs.Destruction:CreateSection("Разрушение")

Tabs.Destruction:CreateButton({
    Name = "💥 Разбить всё стекло",
    Callback = function()
        local tool = getTool()
        if not tool then
            notify("Ошибка", "Возьмите оружие в руки!")
            return
        end

        local glassFolder = Workspace:FindFirstChild("Glass")
        if glassFolder then
            local count = 0
            for _, glass in pairs(glassFolder:GetChildren()) do
                if glass:IsA("BasePart") then
                    if fireHit(tool, glass) then
                        count = count + 1
                    end
                end

                if count % 20 == 0 then
                    task.wait(0.05)
                end
            end
            notify("Разрушение", count .. " стёкол разбито!", 4)
        else
            notify("Разрушение", "Стекло не найдено!")
        end
    end,
})

Tabs.Destruction:CreateButton({
    Name = "📹 Уничтожить все камеры",
    Callback = function()
        local tool = getTool()
        if not tool then
            notify("Ошибка", "Возьмите оружие в руки!")
            return
        end

        local count = 0
        for _, folderName in ipairs({"Cameras", "BrokenCameras"}) do
            local folder = Workspace:FindFirstChild(folderName)
            if folder then
                for _, cam in pairs(folder:GetChildren()) do
                    local part = cam:FindFirstChild("Union")
                              or cam:FindFirstChild("Head")
                              or cam:FindFirstChildOfClass("MeshPart")

                    if part then
                        if fireHit(tool, part) then
                            count = count + 1
                        end
                    end
                end
            end
        end

        notify("Разрушение", count .. " камер уничтожено!", 4)
    end,
})

-- ==================== ВКЛАДКА МОДА ИГРОКА ====================
Tabs.Player:CreateSection("Движение")

Tabs.Player:CreateToggle({
    Name = "♾️ Бесконечная выносливость",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(value)
        infiniteStaminaEnabled = value

        if infiniteStaminaLoop then
            infiniteStaminaLoop:Disconnect()
            infiniteStaminaLoop = nil
        end

        if value then
            infiniteStaminaLoop = RunService.Heartbeat:Connect(function()
                safeCall(function()
                    local criminals = Workspace:FindFirstChild("Criminals")
                    if criminals then
                        local playerModel = criminals:FindFirstChild(LocalPlayer.Name)
                        if playerModel then
                            local stamina = playerModel:FindFirstChild("Stamina")
                            local maxStamina = playerModel:FindFirstChild("MaxStamina")

                            if stamina then stamina.Value = 90000 end
                            if maxStamina then maxStamina.Value = 90000 end
                        end
                    end
                end)
            end)
            notify("Игрок", "Бесконечная выносливость включена!")
        else
            notify("Игрок", "Бесконечная выносливость выключена")
        end
    end,
})

Tabs.Player:CreateSlider({
    Name = "Скорость передвижения",
    Range = {16, 200},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "WalkSpeed",
    Callback = function(value)
        walkSpeedValue = value
    end,
})

Tabs.Player:CreateToggle({
    Name = "🚀 TP Ходьба",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(value)
        walkSpeedEnabled = value

        if tpWalkConnection then
            tpWalkConnection:Disconnect()
            tpWalkConnection = nil
        end

        if value then
            tpWalkConnection = RunService.Heartbeat:Connect(function()
                if not walkSpeedEnabled then return end

                safeCall(function()
                    local character = LocalPlayer.Character
                    if not character then return end

                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                        local moveSpeed = walkSpeedValue / 50
                        hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * moveSpeed)
                    end
                end)
            end)
            notify("Игрок", "TP Ходьба включена — Скорость: " .. walkSpeedValue)
        else
            notify("Игрок", "TP Ходьба выключена")
        end
    end,
})

Tabs.Player:CreateToggle({
    Name = "Бесконечный прыжок",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(value)
        infiniteJumpEnabled = value

        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end

        if value then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                if not infiniteJumpEnabled then return end

                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            notify("Игрок", "Бесконечный прыжок включён!")
        else
            notify("Игрок", "Бесконечный прыжок выключен")
        end
    end,
})

Tabs.Player:CreateSection("Физика")

Tabs.Player:CreateSlider({
    Name = "Гравитация",
    Range = {0, 196},
    Increment = 1,
    Suffix = "",
    CurrentValue = 196,
    Flag = "Gravity",
    Callback = function(value)
        gravityValue = value
    end,
})

Tabs.Player:CreateToggle({
    Name = "Включить свою гравитацию",
    CurrentValue = false,
    Flag = "GravityToggle",
    Callback = function(value)
        customGravityEnabled = value

        if gravityLoop then
            gravityLoop:Disconnect()
            gravityLoop = nil
        end

        if value then
            gravityLoop = RunService.Heartbeat:Connect(function()
                if customGravityEnabled then
                    Workspace.Gravity = gravityValue
                end
            end)
            notify("Игрок", "Гравитация: " .. gravityValue)
        else
            Workspace.Gravity = 196.2
            notify("Игрок", "Гравитация сброшена")
        end
    end,
})

Tabs.Player:CreateToggle({
    Name = "👻 Ноклип",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(value)
        noclipEnabled = value

        if noclipLoop then
            noclipLoop:Disconnect()
            noclipLoop = nil
        end

        if value then
            noclipLoop = RunService.Stepped:Connect(function()
                if not noclipEnabled then return end

                safeCall(function()
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end)
            notify("Игрок", "Ноклип включён!")
        else
            safeCall(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end)
            notify("Игрок", "Ноклип выключен")
        end
    end,
})

Tabs.Player:CreateToggle({
    Name = "🎭 Незаметность БЕТА",
    CurrentValue = false,
    Flag = "UndetectedBeta",
    Callback = function(value)
        if value then
            safeCall(function()
                local rs = getRS()
                if rs then
                    local maskEvent = rs:FindFirstChild("Assets")
                    if maskEvent then
                        maskEvent = maskEvent:FindFirstChild("Remotes")
                        if maskEvent then
                            maskEvent = maskEvent:FindFirstChild("MaskOn")
                            if maskEvent then
                                maskEvent:FireServer(nil, "Primary")
                                notify("Незаметность", "✅ Маска надета!", 2)
                            end
                        end
                    end
                end

                notify("Незаметность", "✅ Обход инвентаря включён!", 2)
            end, "Ошибка активации режима незаметности")

            notify("Незаметность", "🎭 Режим незаметности включён! Ждите начала ограбления.", 4)
        else
            notify("Незаметность", "Выключено", 2)
        end
    end,
})

-- ==================== ВКЛАДКА БОЕВЫХ ====================
Tabs.Aim:CreateSection("⚠️ Внимание")

Tabs.Aim:CreateLabel("Функции Kill Aura и оригинальный Kill All запатчены разработчиками игры.\n\nФункция ниже — альтернативный метод, который всё ещё работает.")

Tabs.Aim:CreateSection("Альтернативный метод убийства")

Tabs.Aim:CreateToggle({
    Name = "👥 Притянуть охрану — Замена Kill All",
    CurrentValue = false,
    Flag = "BringGuards",
    Callback = function(value)
        visualKillAllActive = value

        if value then
            notify("Притянуть охрану", "👁️ Притягиваем всю охрану к вам! Держите включённым для авто-обновления.", 3)
            visualKillAll()
        else
            for _, folderName in ipairs({"Police", "Bodies"}) do
                local folder = Workspace:FindFirstChild(folderName)
                if folder then
                    for _, npc in pairs(folder:GetChildren()) do
                        local npcHrp = npc:FindFirstChild("HumanoidRootPart")
                        if npcHrp then
                            npcHrp.Anchored = false
                        end
                    end
                end
            end

            notify("Притянуть охрану", "✅ Остановлено и вся охрана освобождена", 3)
        end
    end,
})

Tabs.Aim:CreateSection("Аimbot")

Tabs.Aim:CreateToggle({
    Name = "🎯 Аimbot",
    CurrentValue = false,
    Flag = "AimEnabled",
    Callback = function(value)
        aimEnabled = value
        if not value then
            aiming = false
            currentTarget = nil
        end
        notify("Прицел", value and "Аimbot включён!" or "Аimbot выключен", 2)
    end,
})

Tabs.Aim:CreateDropdown({
    Name = "Цель прицела",
    Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "AimPart",
    Callback = function(options)
        aimPart = options[1]
    end,
})

Tabs.Aim:CreateSlider({
    Name = "FOV аimbot",
    Range = {50, 500},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "AimFOV",
    Callback = function(value)
        aimFOV = value
        FOVCircle.Radius = value
    end,
})

Tabs.Aim:CreateSlider({
    Name = "Чувствительность",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "AimSensitivity",
    Callback = function(value)
        aimSensitivity = value
    end,
})

Tabs.Aim:CreateToggle({
    Name = "Использовать чувствительность",
    CurrentValue = true,
    Flag = "UseSensitivity",
    Callback = function(value)
        useSensitivity = value
    end,
})

Tabs.Aim:CreateToggle({
    Name = "Показывать круг FOV",
    CurrentValue = false,
    Flag = "ShowFOV",
    Callback = function(value)
        fovCircleEnabled = value
        FOVCircle.Visible = value
    end,
})

-- ==================== ВКЛАДКА ESP ====================
Tabs.ESP:CreateSection("ESP (Подсветка)")

Tabs.ESP:CreateToggle({
    Name = "📹 ESP Камер",
    CurrentValue = false,
    Flag = "CameraESP",
    Callback = function(value)
        cameraESPEnabled = value

        if value then
            task.spawn(function()
                while cameraESPEnabled do
                    clearHighlights(cameraHighlights)

                    safeCall(function()
                        for _, folderName in ipairs({"Cameras", "BrokenCameras"}) do
                            local folder = Workspace:FindFirstChild(folderName)
                            if folder then
                                for _, cam in pairs(folder:GetChildren()) do
                                    local color = (folderName == "BrokenCameras")
                                        and Color3.fromRGB(255, 165, 0)
                                        or Color3.fromRGB(255, 0, 0)

                                    local hl = createHighlight(cam, color)
                                    if hl then
                                        table.insert(cameraHighlights, hl)
                                    end
                                end
                            end
                        end
                    end)

                    task.wait(2)
                end
                clearHighlights(cameraHighlights)
            end)
        else
            clearHighlights(cameraHighlights)
        end
    end,
})

Tabs.ESP:CreateToggle({
    Name = "👮 ESP Полиции",
    CurrentValue = false,
    Flag = "PoliceESP",
    Callback = function(value)
        policeESPEnabled = value

        if value then
            task.spawn(function()
                while policeESPEnabled do
                    clearHighlights(policeHighlights)

                    safeCall(function()
                        for _, folderName in ipairs({"Police", "Bodies"}) do
                            local folder = Workspace:FindFirstChild(folderName)
                            if folder then
                                for _, cop in pairs(folder:GetChildren()) do
                                    local hl = createHighlight(cop, Color3.fromRGB(0, 100, 255))
                                    if hl then
                                        table.insert(policeHighlights, hl)
                                    end
                                end
                            end
                        end
                    end)

                    task.wait(2)
                end
                clearHighlights(policeHighlights)
            end)
        else
            clearHighlights(policeHighlights)
        end
    end,
})

Tabs.ESP:CreateToggle({
    Name = "👥 ESP Гражданских",
    CurrentValue = false,
    Flag = "CivilianESP",
    Callback = function(value)
        civilianESPEnabled = value

        if value then
            task.spawn(function()
                while civilianESPEnabled do
                    clearHighlights(civilianHighlights)

                    safeCall(function()
                        local citizens = Workspace:FindFirstChild("Citizens")
                        if citizens then
                            for _, citizen in pairs(citizens:GetChildren()) do
                                local isTied = string.find(citizen.Name:lower(), "tied")
                                local color = isTied
                                    and Color3.fromRGB(255, 255, 0)
                                    or Color3.fromRGB(0, 255, 0)

                                local hl = createHighlight(citizen, color)
                                if hl then
                                    table.insert(civilianHighlights, hl)
                                end
                            end
                        end
                    end)

                    task.wait(2)
                end
                clearHighlights(civilianHighlights)
            end)
        else
            clearHighlights(civilianHighlights)
        end
    end,
})

Tabs.ESP:CreateToggle({
    Name = "🔑 ESP Ключ-карты",
    CurrentValue = false,
    Flag = "KeyCardESP",
    Callback = function(value)
        keyCardESPEnabled = value

        if value then
            task.spawn(function()
                while keyCardESPEnabled do
                    clearHighlights(keyCardHighlights)

                    safeCall(function()
                        local map = Workspace:FindFirstChild("Map")
                        if map then
                            local keyCardFolder = map:FindFirstChild("KeyCard")
                            if keyCardFolder then
                                local keyCard = keyCardFolder:FindFirstChild("KeyCard")
                                if keyCard then
                                    local hl = createHighlight(keyCard, Color3.fromRGB(255, 215, 0))
                                    if hl then
                                        table.insert(keyCardHighlights, hl)
                                    end
                                end
                            end
                        end
                    end)

                    task.wait(2)
                end
                clearHighlights(keyCardHighlights)
            end)
        else
            clearHighlights(keyCardHighlights)
        end
    end,
})

-- ==================== ВКЛАДКА КАРТ ====================
Tabs.Maps:CreateSection("Выбор карты")

Tabs.Maps:CreateDropdown({
    Name = "🗺️ Выбрать карту",
    Options = {"The Ozela Heist"},
    CurrentOption = {"The Ozela Heist"},
    MultipleOptions = false,
    Flag = "MapSelect",
    Callback = function(options)
        selectedMap = options[1]
    end,
})

Tabs.Maps:CreateButton({
    Name = "✅ Подтвердить карту",
    Callback = function()
        if selectedMap == "The Ozela Heist" then
            -- ESP секция
            Tabs.Maps:CreateSection("ESP — " .. selectedMap)

            Tabs.Maps:CreateToggle({
                Name = "🪢 ESP Верёвок",
                CurrentValue = false,
                Flag = "RopeESP",
                Callback = function(value)
                    ropeESPEnabled = value

                    if ropeESPLoop then
                        ropeESPLoop:Disconnect()
                        ropeESPLoop = nil
                    end

                    if value then
                        task.spawn(function()
                            while ropeESPEnabled do
                                clearHighlights(ropeHighlights)

                                safeCall(function()
                                    local mapEntities = Workspace:FindFirstChild("mapEntities")
                                    if mapEntities then
                                        local missionItems = mapEntities:FindFirstChild("missionItems")
                                        if missionItems then
                                            local ropes = missionItems:FindFirstChild("Ropes")
                                            if ropes then
                                                for _, rope in pairs(ropes:GetChildren()) do
                                                    local hl = createHighlight(rope, Color3.fromRGB(255, 255, 0))
                                                    if hl then
                                                        table.insert(ropeHighlights, hl)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end)

                                task.wait(2)
                            end
                            clearHighlights(ropeHighlights)
                        end)
                        notify("ESP Верёвок", "Включено!", 2)
                    else
                        clearHighlights(ropeHighlights)
                        notify("ESP Верёвок", "Выключено", 2)
                    end
                end,
            })

            Tabs.Maps:CreateToggle({
                Name = "🪝 ESP Крюков",
                CurrentValue = false,
                Flag = "HookESP",
                Callback = function(value)
                    hookESPEnabled = value

                    if hookESPLoop then
                        hookESPLoop:Disconnect()
                        hookESPLoop = nil
                    end

                    if value then
                        task.spawn(function()
                            while hookESPEnabled do
                                clearHighlights(hookHighlights)

                                safeCall(function()
                                    local mapEntities = Workspace:FindFirstChild("mapEntities")
                                    if mapEntities then
                                        local missionItems = mapEntities:FindFirstChild("missionItems")
                                        if missionItems then
                                            local hooks = missionItems:FindFirstChild("Hooks")
                                            if hooks then
                                                for _, hook in pairs(hooks:GetChildren()) do
                                                    local hl = createHighlight(hook, Color3.fromRGB(0, 255, 100))
                                                    if hl then
                                                        table.insert(hookHighlights, hl)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end)

                                task.wait(2)
                            end
                            clearHighlights(hookHighlights)
                        end)
                        notify("ESP Крюков", "Включено!", 2)
                    else
                        clearHighlights(hookHighlights)
                        notify("ESP Крюков", "Выключено", 2)
                    end
                end,
            })

            Tabs.Maps:CreateToggle({
                Name = "📋 ESP Таблицы кодов",
                CurrentValue = false,
                Flag = "CodeTableESP",
                Callback = function(value)
                    codeTableESPEnabled = value

                    if codeTableESPLoop then
                        codeTableESPLoop:Disconnect()
                        codeTableESPLoop = nil
                    end

                    if value then
                        task.spawn(function()
                            while codeTableESPEnabled do
                                clearHighlights(codeTableHighlights)

                                safeCall(function()
                                    local blueprints = Workspace:FindFirstChild("Blueprints")
                                    if blueprints then
                                        local stadiumBlueprint = blueprints:FindFirstChild("prop_stadium_blueprintTableRNG")
                                        if stadiumBlueprint then
                                            local codeTable = stadiumBlueprint:FindFirstChild("prop_office_TablePlastic")
                                            if codeTable then
                                                local hl = createHighlight(codeTable, Color3.fromRGB(200, 0, 255))
                                                if hl then
                                                    table.insert(codeTableHighlights, hl)
                                                end
                                            end
                                        end
                                    end
                                end)

                                task.wait(2)
                            end
                            clearHighlights(codeTableHighlights)
                        end)
                        notify("ESP Таблицы кодов", "Включено!", 2)
                    else
                        clearHighlights(codeTableHighlights)
                        notify("ESP Таблицы кодов", "Выключено", 2)
                    end
                end,
            })

            -- Секция определения кода
            Tabs.Maps:CreateSection("Определение кода — " .. selectedMap)

            codeStatusLabel = Tabs.Maps:CreateLabel("🔐 Код цветного ящика\n\nНажмите 'Определить код' для сканирования")
            usbStatusLabel  = Tabs.Maps:CreateLabel("💻 Код USB компьютера\n\nНажмите 'Проверить USB код' для просмотра")

            Tabs.Maps:CreateButton({
                Name = "🔍 Определить код цветного ящика",
                Callback = function()
                    local info = updateColorBoxStatus()
                    if info and info.correctCode ~= "" then
                        notify("Цветной ящик", "Правильный код: " .. info.correctCode, 4)
                    else
                        notify("Цветной ящик", "Коды ещё не обнаружены", 3)
                    end
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "💻 Проверить код USB компьютера",
                Callback = function()
                    updateUSBStatus()
                    local status = getUSBComputerStatus()
                    if status ~= "Не найдено" then
                        notify("USB Компьютер", "Код: " .. status, 4)
                    else
                        notify("USB Компьютер", "Компьютер не найден или код отсутствует", 3)
                    end
                end,
            })

            Tabs.Maps:CreateToggle({
                Name = "🔄 Авто-обновление кода USB",
                CurrentValue = false,
                Flag = "AutoRefreshUSB",
                Callback = function(value)
                    if value then
                        task.spawn(function()
                            while value do
                                updateUSBStatus()
                                task.wait(2)
                            end
                        end)
                        notify("Авто-USB", "Включено!", 2)
                    else
                        notify("Авто-USB", "Выключено", 2)
                    end
                end,
            })

            -- Секция телепортов
            Tabs.Maps:CreateSection("Телепорты — " .. selectedMap)

            Tabs.Maps:CreateButton({
                Name = "📍 ТП к ближайшей верёвке",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "Персонаж не найден!")
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local mapEntities = Workspace:FindFirstChild("mapEntities")

                        if mapEntities then
                            local missionItems = mapEntities:FindFirstChild("missionItems")
                            if missionItems then
                                local ropes = missionItems:FindFirstChild("Ropes")
                                if ropes then
                                    local closest = nil
                                    local shortestDist = math.huge

                                    for _, rope in pairs(ropes:GetChildren()) do
                                        if rope:IsA("Model") or rope:IsA("Part") then
                                            local ropePart = rope:IsA("Part") and rope or rope:FindFirstChildOfClass("Part")
                                            if ropePart then
                                                local dist = (hrp.Position - ropePart.Position).Magnitude
                                                if dist < shortestDist then
                                                    closest = ropePart
                                                    shortestDist = dist
                                                end
                                            end
                                        end
                                    end

                                    if closest then
                                        hrp.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
                                        notify("Телепорт", "Телепортировался к верёвке!", 2)
                                    else
                                        notify("Телепорт", "Верёвки не найдены!")
                                    end
                                else
                                    notify("Телепорт", "Папка Ropes не найдена!")
                                end
                            end
                        end
                    end, "Ошибка телепорта")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 ТП к ближайшему крюку",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "Персонаж не найден!")
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local mapEntities = Workspace:FindFirstChild("mapEntities")

                        if mapEntities then
                            local missionItems = mapEntities:FindFirstChild("missionItems")
                            if missionItems then
                                local hooks = missionItems:FindFirstChild("Hooks")
                                if hooks then
                                    local closest = nil
                                    local shortestDist = math.huge

                                    for _, hook in pairs(hooks:GetChildren()) do
                                        if hook:IsA("Model") or hook:IsA("Part") then
                                            local hookPart = hook:IsA("Part") and hook or hook:FindFirstChildOfClass("Part")
                                            if hookPart then
                                                local dist = (hrp.Position - hookPart.Position).Magnitude
                                                if dist < shortestDist then
                                                    closest = hookPart
                                                    shortestDist = dist
                                                end
                                            end
                                        end
                                    end

                                    if closest then
                                        hrp.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
                                        notify("Телепорт", "Телепортировался к крюку!", 2)
                                    else
                                        notify("Телепорт", "Крюки не найдены!")
                                    end
                                else
                                    notify("Телепорт", "Папка Hooks не найдена!")
                                end
                            end
                        end
                    end, "Ошибка телепорта")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 ТП к таблице кодов",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "Персонаж не найден!")
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local blueprints = Workspace:FindFirstChild("Blueprints")

                        if blueprints then
                            local stadiumBlueprint = blueprints:FindFirstChild("prop_stadium_blueprintTableRNG")
                            if stadiumBlueprint then
                                local codeTable = stadiumBlueprint:FindFirstChild("prop_office_TablePlastic")
                                if codeTable then
                                    local tablePart = codeTable.PrimaryPart or codeTable:FindFirstChildWhichIsA("BasePart")
                                    if tablePart then
                                        hrp.CFrame = tablePart.CFrame + Vector3.new(0, 5, 0)
                                        notify("Телепорт", "✅ Телепортировался к таблице кодов!", 2)
                                    else
                                        notify("Телепорт", "❌ У таблицы нет частей!")
                                    end
                                else
                                    notify("Телепорт", "❌ Таблица кодов не найдена!")
                                end
                            else
                                notify("Телепорт", "❌ Stadium Blueprint не найден!")
                            end
                        else
                            notify("Телепорт", "❌ Папка Blueprints не найдена!")
                        end
                    end, "Ошибка телепорта к таблице кодов")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 ТП к правильному цветному ящику",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "Персонаж не найден!")
                            return
                        end

                        local info = detectColorBoxCode()

                        if info.colorBoxName == "" then
                            notify("Телепорт", "❌ Сначала определите код цветного ящика!", 3)
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local colorBoxRNG = Workspace:FindFirstChild("colorBoxRNG")

                        if colorBoxRNG then
                            local colorBox = colorBoxRNG:FindFirstChild(info.colorBoxName)
                            if colorBox then
                                local boxPart = colorBox.PrimaryPart or colorBox:FindFirstChildWhichIsA("BasePart")
                                if boxPart then
                                    hrp.CFrame = boxPart.CFrame + Vector3.new(0, 5, 0)
                                    notify("Телепорт", "✅ Телепортировался к: " .. info.colorBoxName, 3)
                                else
                                    notify("Телепорт", "❌ У цветного ящика нет частей!")
                                end
                            else
                                notify("Телепорт", "❌ Цветной ящик не найден!")
                            end
                        else
                            notify("Телепорт", "❌ colorBoxRNG не найден!")
                        end
                    end, "Ошибка телепорта к цветному ящику")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 ТП в комнату администрации",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "Персонаж не найден!")
                            return
                        end
                        character.HumanoidRootPart.CFrame = CFrame.new(156, 42, -165)
                        notify("Телепорт", "✅ Телепортировался в комнату администрации!", 2)
                    end, "Ошибка телепорта")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🔑 ТП к Ключ-карте",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "❌ Персонаж не найден!")
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local map = Workspace:FindFirstChild("Map")
                        if not map then notify("Телепорт", "❌ Карта не найдена!") return end

                        local keyCardFolder = map:FindFirstChild("KeyCard")
                        if not keyCardFolder then notify("Телепорт", "❌ Папка KeyCard не найдена!") return end

                        local keyCard = keyCardFolder:FindFirstChild("KeyCard")
                        if not keyCard then notify("Телепорт", "❌ KeyCard не найдена!") return end

                        local targetPart = keyCard.PrimaryPart or keyCard:FindFirstChildWhichIsA("BasePart", true)
                        if not targetPart then notify("Телепорт", "❌ У KeyCard нет частей!") return end

                        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
                        notify("Телепорт", "✅ Телепортировался к Ключ-карте!", 2)
                    end, "Ошибка телепорта к KeyCard")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🏦 ТП в хранилище",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "❌ Персонаж не найден!")
                            return
                        end
                        character.HumanoidRootPart.CFrame = CFrame.new(487, 39, -222)
                        notify("Телепорт", "✅ Телепортировался в хранилище!", 2)
                    end, "Ошибка телепорта")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🚪 ТП в раздевалку",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "❌ Персонаж не найден!")
                            return
                        end
                        character.HumanoidRootPart.CFrame = CFrame.new(83, 39, -201)
                        notify("Телепорт", "✅ Телепортировался в раздевалку!", 2)
                    end, "Ошибка телепорта")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🚁 ТП к выходу/эвакуации",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Телепорт", "❌ Персонаж не найден!")
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local bagSecuredArea = Workspace:FindFirstChild("BagSecuredArea")
                        if not bagSecuredArea then notify("Телепорт", "❌ BagSecuredArea не найден!") return end

                        local floorPart = bagSecuredArea:FindFirstChild("FloorPart")
                        if not floorPart then notify("Телепорт", "❌ FloorPart не найден!") return end

                        hrp.CFrame = floorPart.CFrame + Vector3.new(0, 5, 0)
                        notify("Телепорт", "✅ Телепортировался к выходу!", 2)
                    end, "Ошибка телепорта к выходу")
                end,
            })

            notify("Карты", "Функции для " .. selectedMap .. " загружены!", 3)
        end
    end,
})

-- ==================== ВКЛАДКА СТАТИСТИКИ ====================
Tabs.Stats:CreateSection("Статистика игрока")

local statsParagraph = Tabs.Stats:CreateLabel("📊 Ваша статистика\n\nНажмите кнопку ниже для загрузки статистики.")

Tabs.Stats:CreateButton({
    Name = "🔄 Обновить статистику",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if not rs then
                notify("Статистика", "Ошибка доступа к ReplicatedStorage!")
                return
            end

            notify("Статистика", "Загрузка статистики...", 2)

            local stats = rs.Remotes.GetStats:InvokeServer()

            if stats then
                local statsText = "📊 Ваша статистика:\n\n"

                statsText = statsText .. "🎯 Убийства:\n"
                statsText = statsText .. "  • Полицейских убито: " .. (stats.PoliceKills or 0) .. "\n"
                statsText = statsText .. "  • Гражданских убито: " .. (stats.CivilianKills or 0) .. "\n"
                statsText = statsText .. "  • Выстрелов в голову: " .. (stats.Headshots or 0) .. "\n\n"

                statsText = statsText .. "💰 Деньги:\n"
                statsText = statsText .. "  • Мгновенные деньги: $" .. (stats.InstantCash or 0) .. "\n\n"

                statsText = statsText .. "🏥 Поддержка:\n"
                statsText = statsText .. "  • Воскрешений: " .. (stats.Revives or 0) .. "\n"
                statsText = statsText .. "  • Нокаутов: " .. (stats.Downs or 0) .. "\n\n"

                statsText = statsText .. "🔫 Статистика оружия:\n"
                if stats.GunStats and type(stats.GunStats) == "table" then
                    local hasGunStats = false
                    for gunName, gunData in pairs(stats.GunStats) do
                        if type(gunData) == "table" then
                            hasGunStats = true
                            statsText = statsText .. "  • " .. gunName .. ":\n"
                            if gunData.Kills then
                                statsText = statsText .. "    - Убийства: " .. gunData.Kills .. "\n"
                            end
                            if gunData.Shots then
                                statsText = statsText .. "    - Выстрелов: " .. gunData.Shots .. "\n"
                            end
                            if gunData.Headshots then
                                statsText = statsText .. "    - Выстрелов в голову: " .. gunData.Headshots .. "\n"
                            end
                        end
                    end
                    if not hasGunStats then
                        statsText = statsText .. "  • Статистика оружия не записана\n"
                    end
                else
                    statsText = statsText .. "  • Статистика оружия недоступна\n"
                end

                statsText = statsText .. "\n🎮 Взаимодействия:\n"
                statsText = statsText .. "  • Всего: " .. (stats.Interactions or 0)

                statsParagraph:Set(statsText)
                notify("Статистика", "Статистика успешно загружена!", 3)
            else
                statsParagraph:Set("❌ Ошибка загрузки статистики.\n\nПовторите попытку через несколько секунд.")
                notify("Статистика", "Не удалось загрузить статистику!")
            end
        end, "Ошибка загрузки статистики")
    end,
})

Tabs.Stats:CreateSection("Дополнительная информация")

Tabs.Stats:CreateLabel("ℹ️ О статистике\n\nСтатистика загружается напрямую с игрового сервера.\n\n• PoliceKills: Всего уничтожено полицейских\n• CivilianKills: Всего уничтожено гражданских\n• Headshots: Всего выстрелов в голову\n• InstantCash: Мгновенно заработанные деньги\n• Revives: Сколько раз вы воскрешали союзников\n• Downs: Сколько раз вас нокаутировали\n• GunStats: Статистика по каждому оружию\n• Interactions: Всего взаимодействий в игре")

-- ==================== ОБРАБОТКА ВВОДА ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if aimEnabled then
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
        currentTarget = nil
    end
end)

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
RunService.RenderStepped:Connect(function()
    -- Круг FOV
    if fovCircleEnabled then
        local mouseLocation = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mouseLocation.X, mouseLocation.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- Ближайшая цель
    local target = getClosestPolice()
    currentTarget = target

    -- Аimbot
    if aimEnabled and aiming and target then
        aimAtTarget(target)
    end
end)

-- ==================== ОЧИСТКА ====================
local function cleanup()
    clearHighlights(cameraHighlights)
    clearHighlights(policeHighlights)
    clearHighlights(civilianHighlights)
    clearHighlights(keyCardHighlights)
    clearHighlights(ropeHighlights)
    clearHighlights(hookHighlights)
    clearHighlights(codeTableHighlights)

    if FOVCircle then
        FOVCircle:Remove()
    end

    if tpWalkConnection then tpWalkConnection:Disconnect() end
    if infJumpConnection then infJumpConnection:Disconnect() end
    if noclipLoop then noclipLoop:Disconnect() end
    if gravityLoop then gravityLoop:Disconnect() end
    if infiniteStaminaLoop then infiniteStaminaLoop:Disconnect() end
    if instantInteractConnection then instantInteractConnection:Disconnect() end
    if ropeESPLoop then ropeESPLoop:Disconnect() end
    if hookESPLoop then hookESPLoop:Disconnect() end
    if codeTableESPLoop then codeTableESPLoop:Disconnect() end

    visualKillAllActive = false

    Workspace.Gravity = 196.2

    notify("hueta.cc", "Очистка завершена!", 2)
end

-- Очистка при телепорте
Players.LocalPlayer.OnTeleport:Connect(cleanup)

-- Ноклип после смерти
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if noclipEnabled then
        noclipEnabled = false
        task.wait(0.1)
        noclipEnabled = true
    end
end)

-- ==================== ЗАВЕРШЕНИЕ ИНИЦИАЛИЗАЦИИ ====================
notify("hueta.cc v2.2", "Хаб успешно загружен! ✅", 5)
notify("Улучшенные функции", "Все функции готовы к использованию!", 3)
