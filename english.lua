--[[
    hueta.cc - Notoriety
    Improved Version v2.2
    By kaLLoware

    Changelog v2.2:
    - Kill all v2 fixed.
    - Interface rewritten for Rayfield
    - All text translated to English
]]
-- ==================== INITIALIZATION ====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ==================== WINDOW CREATION ====================
local Window = Rayfield:CreateWindow({
    Name = "hueta.cc - Notoriety v2.2",
    Icon = "swords",
    LoadingTitle = "hueta.cc",
    LoadingSubtitle = "by kaLLoware — ADMIN Version",
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

-- ==================== VARIABLES ====================
-- Weapons
local selectedGun = "M16"
local selectedClass = "Class 1"

-- Interact
local instantInteractEnabled = false
local instantInteractConnection = nil

-- Player Mod
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

-- Map-Specific ESP
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

-- Ozela Heist Code System
local codeStatusLabel = nil
local usbStatusLabel = nil
local detectedCodes = {}
local correctCode = ""
local correctColorBox = ""

-- Aim
local aimEnabled = false
local aimPart = "Head"
local aimFOV = 200
local aimSensitivity = 50
local useSensitivity = true
local fovCircleEnabled = false
local currentTarget = nil
local aiming = false

-- Combat Features
local visualKillAllActive = false

-- ==================== UTILITY FUNCTIONS ====================
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

-- ==================== HIGHLIGHT FUNCTIONS ====================
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

-- ==================== FOV CIRCLE ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = aimFOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

-- ==================== WEAPON FUNCTIONS ====================
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
            notify("Error", "You are not in Criminals!")
            return
        end

        local buffed = 0
        for _, obj in pairs(charFolder:GetChildren()) do
            local dataModule = obj:FindFirstChild("Data")
            if dataModule and dataModule:IsA("ModuleScript") then
                local weaponData = require(dataModule)

                -- Super buffs
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
            notify("Weapon Modified", buffed .. " weapon(s) buffed!", 4)
        else
            notify("Warning", "No weapon found to modify")
        end
    end, "Error modifying weapon")
end

-- ==================== AIM FUNCTIONS ====================
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

-- ==================== DESTRUCTION FUNCTIONS ====================
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

-- ==================== COMBAT FUNCTIONS ====================
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

            -- Position all NPCs in the SAME spot (stacked)
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

                            -- Make NPC face player
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

-- ==================== OZELA HEIST CODE DETECTION ====================
local function detectColorBoxCode()
    local result = {
        codes = {},
        correctCode = "",
        correctTitle = "",
        colorSequence = "",
        colorBoxName = ""
    }

    safeCall(function()
        -- Detect correct code from card reader
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

        -- Detect codes from blueprints
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

                                        -- Check if this is the correct code
                                        if codeTitle == result.correctCode and result.correctCode ~= "" then
                                            result.correctTitle = codeTitle

                                            -- Get color sequence
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

        -- Detect correct color box
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
    end, "Error detecting color box code")

    return result
end

local function getUSBComputerStatus()
    local status = "Not found"

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
    end, "Error getting USB status")

    return status
end

local function updateColorBoxStatus()
    if not codeStatusLabel then return end

    local info = detectColorBoxCode()

    local codeText = "🔐 Color Box Code Detection:\n\n"

    if #info.codes > 0 then
        codeText = codeText .. "📋 Available Codes:\n"
        for _, code in ipairs(info.codes) do
            local marker = code.isCorrect and "✅" or "❌"
            codeText = codeText .. string.format("  %s Code #%d: %s\n", marker, code.number, code.title)
        end
        codeText = codeText .. "\n"
    else
        codeText = codeText .. "❌ No codes detected\n\n"
    end

    if info.correctCode ~= "" then
        codeText = codeText .. "✅ Correct Code: " .. info.correctCode .. "\n"
    else
        codeText = codeText .. "❌ Correct code not found\n"
    end

    if info.colorSequence ~= "" then
        codeText = codeText .. "🎨 Color Sequence: " .. info.colorSequence .. "\n"
    end

    if info.colorBoxName ~= "" then
        codeText = codeText .. "📦 Color Box: " .. info.colorBoxName
    end

    codeStatusLabel:Set(codeText)

    return info
end

local function updateUSBStatus()
    if not usbStatusLabel then return end

    local status = getUSBComputerStatus()
    local usbText = "💻 USB Computer Code:\n\n" .. status
    usbStatusLabel:Set(usbText)
end

-- ==================== TABS ====================
local Tabs = {
    Weapons    = Window:CreateTab("Weapons",          "sword"),
    Interact   = Window:CreateTab("Interactions",     "hand"),
    Teleports  = Window:CreateTab("Teleports",        "navigation"),
    Destruction= Window:CreateTab("Destruction",      "bomb"),
    Player     = Window:CreateTab("Player Mod",       "user"),
    Aim        = Window:CreateTab("Combat",           "crosshair"),
    ESP        = Window:CreateTab("ESP",              "eye"),
    Maps       = Window:CreateTab("Specific Maps",    "map"),
    Stats      = Window:CreateTab("Game Stats",       "bar-chart"),
    Changelog  = Window:CreateTab("Changelogs",       "file-text"),
}

-- ==================== CHANGELOGS TAB ====================
Tabs.Changelog:CreateSection("📋 Version History")

Tabs.Changelog:CreateLabel("🆕 Version 2.2 — Current\n• Kill All v2 fixed.\n• Interface rewritten for Rayfield.\n• All text translated to English.")

Tabs.Changelog:CreateLabel("📦 Version 2.1\n• Added KeyCard ESP and Teleport\n• Added Ozela Heist code identification system\n• Added Color Box auto-detection and teleport\n• Added USB Computer status monitor\n• Removed patched features (Kill Aura, Kill All)\n• Added Changelogs tab\n• Improved Ozela Heist features")

Tabs.Changelog:CreateLabel("📦 Version 2.0\n• Kill Aura fixed and optimized\n• TP Walk loading bug resolved\n• Improved security system\n• Optimized performance\n• Cleaner and organized code")

Tabs.Changelog:CreateSection("ℹ️ Information")

Tabs.Changelog:CreateLabel("About hueta.cc\n\nCreated by: kaLLoware\n\nThis hub provides various quality-of-life features for Notoriety.\n\nFeatures are continuously updated to maintain functionality.\n\nIf you encounter any bugs, please report them to the developer.")

-- ==================== WEAPONS TAB ====================
Tabs.Weapons:CreateSection("Modify Weapons")

Tabs.Weapons:CreateButton({
    Name = "🔥 Modify Current Weapon (OP)",
    Callback = buffCurrentWeapon,
})

Tabs.Weapons:CreateSection("Get Weapons")

Tabs.Weapons:CreateInput({
    Name = "Weapon Name",
    CurrentValue = "M16",
    PlaceholderText = "Ex: M16, AK47, Shotgun",
    RemoveTextAfterFocusLost = false,
    Flag = "GunName",
    Callback = function(value)
        selectedGun = value
    end,
})

Tabs.Weapons:CreateInput({
    Name = "Class Name",
    CurrentValue = "Class 1",
    PlaceholderText = "Ex: Class 1, Class 2",
    RemoveTextAfterFocusLost = false,
    Flag = "ClassName",
    Callback = function(value)
        selectedClass = value
    end,
})

Tabs.Weapons:CreateButton({
    Name = "Get Weapon Data",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.GetGunData:InvokeServer(selectedGun)
                notify("Weapons", "Data obtained: " .. selectedGun)
            end
        end, "Error getting data")
    end,
})

Tabs.Weapons:CreateButton({
    Name = "Set Weapon to Class",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.SetGunForClass:FireServer(selectedClass, selectedGun, 0)
                notify("Weapons", selectedGun .. " → " .. selectedClass)
            end
        end, "Error setting weapon")
    end,
})

Tabs.Weapons:CreateButton({
    Name = "Activate Class",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.SetClass:FireServer(selectedClass)
                notify("Weapons", "Class activated: " .. selectedClass)
            end
        end, "Error activating class")
    end,
})

-- ==================== INTERACT TAB ====================
Tabs.Interact:CreateSection("Quick Interactions")

Tabs.Interact:CreateToggle({
    Name = "⚡ Instant Interact",
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

            notify("Interact", "Instant Interact ENABLED!", 2)
        else
            notify("Interact", "Instant Interact disabled", 2)
        end
    end,
})

Tabs.Interact:CreateButton({
    Name = "Apply Instant Interact Now",
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
        notify("Interact", count .. " prompts modified!", 3)
    end,
})

Tabs.Interact:CreateSection("NPC Actions")

Tabs.Interact:CreateButton({
    Name = "Drop Bag on Ground",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if rs then
                rs.Remotes.ThrowBag:FireServer(Vector3.new(-0.98, -0.16, 0.07))
                notify("Interact", "Bag thrown!")
            end
        end, "Error throwing bag")
    end,
})

Tabs.Interact:CreateButton({
    Name = "Yell at All Civilians",
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
                    notify("Interact", "Yelling at " .. #targetList .. " civilians")
                end
            else
                notify("Interact", "No civilians found!")
            end
        end, "Error yelling")
    end,
})

-- ==================== TELEPORTS TAB ====================
Tabs.Teleports:CreateSection("General Teleports")

Tabs.Teleports:CreateButton({
    Name = "🔑 Teleport to KeyCard",
    Callback = function()
        safeCall(function()
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                notify("Teleport", "❌ Character not found!")
                return
            end

            local hrp = character.HumanoidRootPart
            local map = Workspace:FindFirstChild("Map")
            if not map then notify("Teleport", "❌ Map not found!") return end

            local keyCardFolder = map:FindFirstChild("KeyCard")
            if not keyCardFolder then notify("Teleport", "❌ KeyCard folder not found!") return end

            local keyCard = keyCardFolder:FindFirstChild("KeyCard")
            if not keyCard then notify("Teleport", "❌ KeyCard not found!") return end

            local targetPart = keyCard.PrimaryPart or keyCard:FindFirstChildWhichIsA("BasePart", true)
            if not targetPart then notify("Teleport", "❌ KeyCard has no parts!") return end

            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            notify("Teleport", "✅ Teleported to KeyCard!", 2)
        end, "Error teleporting to KeyCard")
    end,
})

-- ==================== DESTRUCTION TAB ====================
Tabs.Destruction:CreateSection("Destruction")

Tabs.Destruction:CreateButton({
    Name = "💥 Break All Glass",
    Callback = function()
        local tool = getTool()
        if not tool then
            notify("Error", "Hold a weapon!")
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
            notify("Destruction", count .. " glass broken!", 4)
        else
            notify("Destruction", "No glass found!")
        end
    end,
})

Tabs.Destruction:CreateButton({
    Name = "📹 Destroy All Cameras",
    Callback = function()
        local tool = getTool()
        if not tool then
            notify("Error", "Hold a weapon!")
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

        notify("Destruction", count .. " cameras destroyed!", 4)
    end,
})

-- ==================== PLAYER MOD TAB ====================
Tabs.Player:CreateSection("Movement")

Tabs.Player:CreateToggle({
    Name = "♾️ Infinite Stamina",
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
            notify("Player", "Infinite Stamina enabled!")
        else
            notify("Player", "Infinite Stamina disabled")
        end
    end,
})

Tabs.Player:CreateSlider({
    Name = "Movement Speed",
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
    Name = "🚀 TP Walk",
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
            notify("Player", "TP Walk enabled - Speed: " .. walkSpeedValue)
        else
            notify("Player", "TP Walk disabled")
        end
    end,
})

Tabs.Player:CreateToggle({
    Name = "Infinite Jump",
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
            notify("Player", "Infinite Jump enabled!")
        else
            notify("Player", "Infinite Jump disabled")
        end
    end,
})

Tabs.Player:CreateSection("Physics")

Tabs.Player:CreateSlider({
    Name = "Gravity",
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
    Name = "Enable Custom Gravity",
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
            notify("Player", "Gravity: " .. gravityValue)
        else
            Workspace.Gravity = 196.2
            notify("Player", "Gravity reset")
        end
    end,
})

Tabs.Player:CreateToggle({
    Name = "👻 Noclip",
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
            notify("Player", "Noclip enabled!")
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
            notify("Player", "Noclip disabled")
        end
    end,
})

Tabs.Player:CreateToggle({
    Name = "🎭 Undetected BETA",
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
                                notify("Undetected", "✅ Mask activated!", 2)
                            end
                        end
                    end
                end

                notify("Undetected", "✅ Inventory bypass enabled!", 2)
            end, "Error activating undetected mode")

            notify("Undetected", "🎭 Undetected mode enabled! Wait for heist to start.", 4)
        else
            notify("Undetected", "Disabled", 2)
        end
    end,
})

-- ==================== COMBAT TAB ====================
Tabs.Aim:CreateSection("⚠️ Notice")

Tabs.Aim:CreateLabel("Kill Aura and original Kill All features have been patched by the game developers.\n\nThe feature below is an alternative method that still works.")

Tabs.Aim:CreateSection("Alternative Kill Method")

Tabs.Aim:CreateToggle({
    Name = "👥 Bring Guards - Kill All Replacement",
    CurrentValue = false,
    Flag = "BringGuards",
    Callback = function(value)
        visualKillAllActive = value

        if value then
            notify("Bring Guards", "👁️ Bringing all guards to you! Keep it on to auto-update.", 3)
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

            notify("Bring Guards", "✅ Stopped and released all guards", 3)
        end
    end,
})

Tabs.Aim:CreateSection("Aimbot")

Tabs.Aim:CreateToggle({
    Name = "🎯 Aimbot",
    CurrentValue = false,
    Flag = "AimEnabled",
    Callback = function(value)
        aimEnabled = value
        if not value then
            aiming = false
            currentTarget = nil
        end
        notify("Aim", value and "Aimbot enabled!" or "Aimbot disabled", 2)
    end,
})

Tabs.Aim:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "AimPart",
    Callback = function(options)
        aimPart = options[1]
    end,
})

Tabs.Aim:CreateSlider({
    Name = "Aimbot FOV",
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
    Name = "Sensitivity",
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
    Name = "Use Sensitivity",
    CurrentValue = true,
    Flag = "UseSensitivity",
    Callback = function(value)
        useSensitivity = value
    end,
})

Tabs.Aim:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "ShowFOV",
    Callback = function(value)
        fovCircleEnabled = value
        FOVCircle.Visible = value
    end,
})

-- ==================== ESP TAB ====================
Tabs.ESP:CreateSection("ESP (Highlights)")

Tabs.ESP:CreateToggle({
    Name = "📹 Camera ESP",
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
    Name = "👮 Police ESP",
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
    Name = "👥 Civilian ESP",
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
    Name = "🔑 KeyCard ESP",
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

-- ==================== SPECIFIC MAPS TAB ====================
Tabs.Maps:CreateSection("Map Selection")

Tabs.Maps:CreateDropdown({
    Name = "🗺️ Select Map",
    Options = {"The Ozela Heist"},
    CurrentOption = {"The Ozela Heist"},
    MultipleOptions = false,
    Flag = "MapSelect",
    Callback = function(options)
        selectedMap = options[1]
    end,
})

Tabs.Maps:CreateButton({
    Name = "✅ Confirm Map",
    Callback = function()
        if selectedMap == "The Ozela Heist" then
            -- ESP Section
            Tabs.Maps:CreateSection("ESP - " .. selectedMap)

            Tabs.Maps:CreateToggle({
                Name = "🪢 Rope ESP",
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
                        notify("Rope ESP", "Enabled!", 2)
                    else
                        clearHighlights(ropeHighlights)
                        notify("Rope ESP", "Disabled", 2)
                    end
                end,
            })

            Tabs.Maps:CreateToggle({
                Name = "🪝 Hook ESP",
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
                        notify("Hook ESP", "Enabled!", 2)
                    else
                        clearHighlights(hookHighlights)
                        notify("Hook ESP", "Disabled", 2)
                    end
                end,
            })

            Tabs.Maps:CreateToggle({
                Name = "📋 Code Table ESP",
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
                        notify("Code Table ESP", "Enabled!", 2)
                    else
                        clearHighlights(codeTableHighlights)
                        notify("Code Table ESP", "Disabled", 2)
                    end
                end,
            })

            -- Code Detection Section
            Tabs.Maps:CreateSection("Code Detection - " .. selectedMap)

            codeStatusLabel = Tabs.Maps:CreateLabel("🔐 Color Box Code\n\nClick 'Detect Color Box Code' to scan")
            usbStatusLabel  = Tabs.Maps:CreateLabel("💻 USB Computer Code\n\nClick 'Check USB Code' to view")

            Tabs.Maps:CreateButton({
                Name = "🔍 Detect Color Box Code",
                Callback = function()
                    local info = updateColorBoxStatus()
                    if info and info.correctCode ~= "" then
                        notify("Color Box", "Correct code: " .. info.correctCode, 4)
                    else
                        notify("Color Box", "No codes detected yet", 3)
                    end
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "💻 Check USB Computer Code",
                Callback = function()
                    updateUSBStatus()
                    local status = getUSBComputerStatus()
                    if status ~= "Not found" then
                        notify("USB Computer", "Code: " .. status, 4)
                    else
                        notify("USB Computer", "Computer not found or no code", 3)
                    end
                end,
            })

            Tabs.Maps:CreateToggle({
                Name = "🔄 Auto-Refresh USB Code",
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
                        notify("USB Auto-Refresh", "Enabled!", 2)
                    else
                        notify("USB Auto-Refresh", "Disabled", 2)
                    end
                end,
            })

            -- Teleport Section
            Tabs.Maps:CreateSection("Teleport - " .. selectedMap)

            Tabs.Maps:CreateButton({
                Name = "📍 TP to Nearest Rope",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "Character not found!")
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
                                        notify("Teleport", "Teleported to Rope!", 2)
                                    else
                                        notify("Teleport", "No Rope found!")
                                    end
                                else
                                    notify("Teleport", "Ropes folder not found!")
                                end
                            end
                        end
                    end, "Error teleporting")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 TP to Nearest Hook",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "Character not found!")
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
                                        notify("Teleport", "Teleported to Hook!", 2)
                                    else
                                        notify("Teleport", "No Hook found!")
                                    end
                                else
                                    notify("Teleport", "Hooks folder not found!")
                                end
                            end
                        end
                    end, "Error teleporting")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 TP to Code Table",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "Character not found!")
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
                                        notify("Teleport", "✅ Teleported to Code Table!", 2)
                                    else
                                        notify("Teleport", "❌ Table has no parts!")
                                    end
                                else
                                    notify("Teleport", "❌ Code Table not found!")
                                end
                            else
                                notify("Teleport", "❌ Stadium Blueprint not found!")
                            end
                        else
                            notify("Teleport", "❌ Blueprints folder not found!")
                        end
                    end, "Error teleporting to Code Table")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 TP to Correct Color Box",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "Character not found!")
                            return
                        end

                        local info = detectColorBoxCode()

                        if info.colorBoxName == "" then
                            notify("Teleport", "❌ Detect Color Box code first!", 3)
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
                                    notify("Teleport", "✅ Teleported to: " .. info.colorBoxName, 3)
                                else
                                    notify("Teleport", "❌ Color box has no parts!")
                                end
                            else
                                notify("Teleport", "❌ Color box not found!")
                            end
                        else
                            notify("Teleport", "❌ colorBoxRNG not found!")
                        end
                    end, "Error teleporting to Color Box")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "📍 TP to Admin Room",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "Character not found!")
                            return
                        end
                        character.HumanoidRootPart.CFrame = CFrame.new(156, 42, -165)
                        notify("Teleport", "✅ Teleported to Admin Room!", 2)
                    end, "Error teleporting to Admin Room")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🔑 TP to KeyCard",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "❌ Character not found!")
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local map = Workspace:FindFirstChild("Map")
                        if not map then notify("Teleport", "❌ Map not found!") return end

                        local keyCardFolder = map:FindFirstChild("KeyCard")
                        if not keyCardFolder then notify("Teleport", "❌ KeyCard folder not found!") return end

                        local keyCard = keyCardFolder:FindFirstChild("KeyCard")
                        if not keyCard then notify("Teleport", "❌ KeyCard not found!") return end

                        local targetPart = keyCard.PrimaryPart or keyCard:FindFirstChildWhichIsA("BasePart", true)
                        if not targetPart then notify("Teleport", "❌ KeyCard has no parts!") return end

                        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
                        notify("Teleport", "✅ Teleported to KeyCard!", 2)
                    end, "Error teleporting to KeyCard")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🏦 TP to Vault",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "❌ Character not found!")
                            return
                        end
                        character.HumanoidRootPart.CFrame = CFrame.new(487, 39, -222)
                        notify("Teleport", "✅ Teleported to Vault!", 2)
                    end, "Error teleporting to Vault")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🚪 TP to Locker Room",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "❌ Character not found!")
                            return
                        end
                        character.HumanoidRootPart.CFrame = CFrame.new(83, 39, -201)
                        notify("Teleport", "✅ Teleported to Locker Room!", 2)
                    end, "Error teleporting to Locker Room")
                end,
            })

            Tabs.Maps:CreateButton({
                Name = "🚁 TP to Exit/Escape",
                Callback = function()
                    safeCall(function()
                        local character = LocalPlayer.Character
                        if not character or not character:FindFirstChild("HumanoidRootPart") then
                            notify("Teleport", "❌ Character not found!")
                            return
                        end

                        local hrp = character.HumanoidRootPart
                        local bagSecuredArea = Workspace:FindFirstChild("BagSecuredArea")
                        if not bagSecuredArea then notify("Teleport", "❌ BagSecuredArea not found!") return end

                        local floorPart = bagSecuredArea:FindFirstChild("FloorPart")
                        if not floorPart then notify("Teleport", "❌ FloorPart not found!") return end

                        hrp.CFrame = floorPart.CFrame + Vector3.new(0, 5, 0)
                        notify("Teleport", "✅ Teleported to Exit!", 2)
                    end, "Error teleporting to Exit")
                end,
            })

            notify("Specific Maps", "Features for " .. selectedMap .. " loaded!", 3)
        end
    end,
})

-- ==================== GAME STATS TAB ====================
Tabs.Stats:CreateSection("Player Statistics")

local statsParagraph = Tabs.Stats:CreateLabel("📊 Your Statistics\n\nClick the button below to load your stats.")

Tabs.Stats:CreateButton({
    Name = "🔄 Refresh Statistics",
    Callback = function()
        safeCall(function()
            local rs = getRS()
            if not rs then
                notify("Stats", "Error accessing ReplicatedStorage!")
                return
            end

            notify("Stats", "Loading statistics...", 2)

            local stats = rs.Remotes.GetStats:InvokeServer()

            if stats then
                local statsText = "📊 Your Statistics:\n\n"

                statsText = statsText .. "🎯 Kills:\n"
                statsText = statsText .. "  • Police Killed: " .. (stats.PoliceKills or 0) .. "\n"
                statsText = statsText .. "  • Civilians Killed: " .. (stats.CivilianKills or 0) .. "\n"
                statsText = statsText .. "  • Headshots: " .. (stats.Headshots or 0) .. "\n\n"

                statsText = statsText .. "💰 Money:\n"
                statsText = statsText .. "  • Instant Cash: $" .. (stats.InstantCash or 0) .. "\n\n"

                statsText = statsText .. "🏥 Support:\n"
                statsText = statsText .. "  • Revives: " .. (stats.Revives or 0) .. "\n"
                statsText = statsText .. "  • Downs (Knocked): " .. (stats.Downs or 0) .. "\n\n"

                statsText = statsText .. "🔫 Weapon Stats:\n"
                if stats.GunStats and type(stats.GunStats) == "table" then
                    local hasGunStats = false
                    for gunName, gunData in pairs(stats.GunStats) do
                        if type(gunData) == "table" then
                            hasGunStats = true
                            statsText = statsText .. "  • " .. gunName .. ":\n"
                            if gunData.Kills then
                                statsText = statsText .. "    - Kills: " .. gunData.Kills .. "\n"
                            end
                            if gunData.Shots then
                                statsText = statsText .. "    - Shots: " .. gunData.Shots .. "\n"
                            end
                            if gunData.Headshots then
                                statsText = statsText .. "    - Headshots: " .. gunData.Headshots .. "\n"
                            end
                        end
                    end
                    if not hasGunStats then
                        statsText = statsText .. "  • No weapon stats recorded\n"
                    end
                else
                    statsText = statsText .. "  • No weapon stats available\n"
                end

                statsText = statsText .. "\n🎮 Interactions:\n"
                statsText = statsText .. "  • Total: " .. (stats.Interactions or 0)

                statsParagraph:Set(statsText)
                notify("Stats", "Statistics loaded successfully!", 3)
            else
                statsParagraph:Set("❌ Error loading statistics.\n\nTry again in a few seconds.")
                notify("Stats", "Failed to load stats!")
            end
        end, "Error loading statistics")
    end,
})

Tabs.Stats:CreateSection("Additional Information")

Tabs.Stats:CreateLabel("ℹ️ About Stats\n\nStatistics are loaded directly from the game server.\n\n• PoliceKills: Total police eliminated\n• CivilianKills: Total civilians eliminated\n• Headshots: Total headshots\n• InstantCash: Money earned instantly\n• Revives: Times you revived allies\n• Downs: Times you were knocked down\n• GunStats: Statistics per weapon\n• Interactions: Total in-game interactions")

-- ==================== INPUT HANDLING ====================
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

-- ==================== MAIN LOOP ====================
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    if fovCircleEnabled then
        local mouseLocation = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mouseLocation.X, mouseLocation.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- Get closest target
    local target = getClosestPolice()
    currentTarget = target

    -- Aimbot
    if aimEnabled and aiming and target then
        aimAtTarget(target)
    end
end)

-- ==================== CLEANUP ====================
local function cleanup()
    -- Clear ESPs
    clearHighlights(cameraHighlights)
    clearHighlights(policeHighlights)
    clearHighlights(civilianHighlights)
    clearHighlights(keyCardHighlights)
    clearHighlights(ropeHighlights)
    clearHighlights(hookHighlights)
    clearHighlights(codeTableHighlights)

    -- Clear FOV Circle
    if FOVCircle then
        FOVCircle:Remove()
    end

    -- Disconnect loops
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

    -- Reset values
    Workspace.Gravity = 196.2

    notify("hueta.cc", "Cleanup completed!", 2)
end

-- Cleanup on teleport
Players.LocalPlayer.OnTeleport:Connect(cleanup)

-- Reapply noclip after spawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if noclipEnabled then
        noclipEnabled = false
        task.wait(0.1)
        noclipEnabled = true
    end
end)

-- ==================== COMPLETE INITIALIZATION ====================
notify("hueta.cc v2.2", "Hub loaded successfully! ✅", 5)
notify("Enhanced Features", "All features ready to use!", 3)
