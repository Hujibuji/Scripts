-- Загрузка Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- Создание окна с настройками
local Window = Rayfield:CreateWindow({
   Name = "Notoriety | kaLLoware",
   Icon = 0,
   LoadingTitle = "Notoriety",
   LoadingSubtitle = "by kaLLoware",
   ShowText = "Hub",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})
-- Локальные переменные
local Tab = Window:CreateTab("Битва")
local Tab2 = Window:CreateTab("Переджвижение")
local Tab3 = Window:CreateTab("ESP")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local flingPolice = false
local flingCitizens = false
local FLING_DIST = 20000
local FLING_HEIGHT = 50000
local staminaEnabled = false
local flying = false
local flingPolice = false
local policeLoop = nil
local BodyGyro, BodyVelocity
local speed = 75
local noclipConn
local oldCollide = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local itemEspParts = {}
local guardEspParts = {}
local cameraEspParts = {}
local keycardEspParts = {}
-- Фукнции
-- Получение всех охранников с ключами
local function getGuardsWithKeys()
    local keyHolders = {}
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, f in ipairs(map:GetDescendants()) do
            if f.Name == "Keys" and f:IsA("Folder") then
                for _, k in ipairs(f:GetDescendants()) do
                    if k:IsA("BasePart") then
                        local g = k:FindFirstAncestorOfClass("Model")
                        if g and g.Parent == workspace.Police then
                            keyHolders[g] = true
                        end
                    end
                end
            end
        end
    end
    for _, g in ipairs(workspace.Police:GetChildren()) do
        local lanyard = g:FindFirstChild("Lanyard")
        if lanyard and lanyard:FindFirstChild("PickpocketKeycard") then
            keyHolders[g] = true
        end
    end
    return keyHolders
end
-- Полет
local function startFlying()
    local character = player.Character or player.CharacterAdded:Wait()
    local HRP = character:WaitForChild("HumanoidRootPart")
    
    if flying then return end
    flying = true

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            oldCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end

    noclipConn = RunService.Stepped:Connect(function()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    BodyGyro.CFrame = HRP.CFrame
    BodyGyro.Parent = HRP

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = HRP

    RunService:BindToRenderStep("FlyStep", Enum.RenderPriority.Character.Value, function()
        local cam = workspace.CurrentCamera
        local look = cam.CFrame.LookVector
        local forward = Vector3.new(look.X, 0, look.Z).Unit
        local right = cam.CFrame.RightVector
        local up = Vector3.new(0, 1, 0)

        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += up end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= up end

        if move.Magnitude > 0 then move = move.Unit * speed else move = Vector3.zero end
        BodyGyro.CFrame = CFrame.new(Vector3.zero, Vector3.new(look.X, 0, look.Z))
        BodyVelocity.Velocity = move
    end)
end

local function stopFlying()
    if not flying then return end
    flying = false

    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end
    RunService:UnbindFromRenderStep("FlyStep")

    if noclipConn then noclipConn:Disconnect() end

    for part, wasColliding in pairs(oldCollide) do
        if part and part.Parent then part.CanCollide = wasColliding end
    end
    table.clear(oldCollide)
end
-- ESP Функции
local function clearESP(list)
    for _, objects in pairs(list) do
        for _, obj in pairs(objects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
    end
    table.clear(list)
end

local function createESP(part, labelText, color)
    local elements = {}
    if labelText then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 60, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.Text = labelText
        label.TextScaled = true
        label.Font = Enum.Font.SourceSansBold

        billboard.Parent = part
        table.insert(elements, billboard)
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = part:IsA("Model") and part or part:FindFirstAncestorOfClass("Model")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = part
    table.insert(elements, highlight)

    return elements
end
-- Кнопки и Тогглы
-- Выкинуть и убить полицию
local PoliceToggle = Tab:CreateToggle({
    Name = "Аннигилировать и выкинуть полицию",
    CurrentValue = false,
    Flag = "PoliceKillFling",
    Callback = function(Value)
        flingPolice = Value
        if Value then
            policeLoop = task.spawn(function()
                while flingPolice and task.wait() do
                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    local tool = char and char:FindFirstChildWhichIsA("Tool")
                    local policeFolder = workspace:FindFirstChild("Police")
                    
                    if char and char:FindFirstChild("HumanoidRootPart") and policeFolder then
                        local root = char.HumanoidRootPart
                        local skip = getGuardsWithKeys()

                        for _, guard in ipairs(policeFolder:GetChildren()) do
                            if guard:IsA("Model") and guard:FindFirstChild("HumanoidRootPart") then
                                local hrp = guard.HumanoidRootPart
                                local humanoid = guard:FindFirstChildWhichIsA("Humanoid")
                                local head = guard:FindFirstChild("Head")

                                -- Логика KILL (Damage Remote)
                                if tool and humanoid and head and humanoid.Health > 0 then
                                    game:GetService("ReplicatedStorage").RS_Package.Assets.Remotes.Damage:FireServer(
                                        "Damage", tool, humanoid, humanoid.Health, head, tool.Name, head.Position, {}
                                    )
                                end

                                -- Логика FLING (как в твоем коде)
                                if not skip[guard] then
                                    hrp.CFrame = CFrame.new(root.Position + Vector3.new(999999, -999999, 0))
                                end
                            end
                        end
                    end
                end
            end)

            Rayfield:Notify({
                Title = "Police Kill & Fling",
                Content = "Fitur Kill All Police Diaktifkan.",
                Duration = 3,
                Image = 4483362458,
            })
        else
            if policeLoop then
                task.cancel(policeLoop)
                policeLoop = nil
            end
        end
    end,
})
-- Флинг гражданских
local citizenToggle = Tab:CreateToggle({
    Name = "Выкинуть гражданских",
    CurrentValue = false,
    Flag = "FlingCitizens",
    Callback = function(Value)
        flingCitizens = Value
        if flingCitizens then
            task.spawn(function()
                while flingCitizens do
                    local player = game.Players.LocalPlayer
                    local char = player and player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local root = char.HumanoidRootPart
                        for _, citizen in pairs(workspace:WaitForChild("Citizens"):GetChildren()) do
                            if citizen:IsA("Model") and citizen:FindFirstChild("HumanoidRootPart") then
                                local hrp = citizen.HumanoidRootPart
                                local success, dir = pcall(function()
                                    return (hrp.Position - root.Position).Unit
                                end)
                                if not success or not dir or dir.Magnitude == 0 then
                                    dir = Vector3.new(1,0,0)
                                end
                                hrp.CFrame = CFrame.new(root.Position + Vector3.new(999999, -999999, 0))
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end,
})
-- Полет
local poletToggle = Tab2:CreateToggle({
   Name = "Полет",
   CurrentValue = false,
   Flag = "FlyToggle", 
   Callback = function(Value)
      if Value then
          startFlying()
      else
          stopFlying()
      end
   end,
})
-- Бесконечная выносливость
local StaminaToggle = Tab2:CreateToggle({
    Name = "Бесконечная выносливость",
    CurrentValue = false,
    Flag = "StaminaFlag",
    Callback = function(Value)
        staminaEnabled = Value
        if staminaEnabled then
            task.spawn(function()
                while staminaEnabled do
                    local plr = game.Players.LocalPlayer.Name
                    local v = game:GetService("Workspace").Criminals[plr]
                    
                    -- Твой код из кнопок:
                    v.MaxStamina.Value = 10000
                    v.Stamina.Value = 10000
                    
                    task.wait()
                end
            end)
        end
    end,
})
local ESPguard = Tab3:CreateToggle({
    Name = "Полиция ESP",
    CurrentValue = false,
    Flag = "GuardESP",
    Callback = function(state)
        clearESP(guardEspParts)
        if state then
            for _, guard in pairs(workspace:WaitForChild("Police"):GetChildren()) do
                if guard:IsA("Model") and guard:FindFirstChild("HumanoidRootPart") then
                    local label = "Guard"
                    local typeVal = guard:FindFirstChild("Type")
                    if typeVal and typeVal:IsA("StringValue") then
                        label = typeVal.Value
                    end
                    local esp = createESP(guard, label, Color3.fromRGB(0, 255, 0))
                    table.insert(guardEspParts, esp)
                end
            end
        end
    end,
})
local ESPcamera = Tab3:CreateToggle({
    Name = "Камеры ESP",
    CurrentValue = false,
    Flag = "CameraESP",
    Callback = function(state)
        clearESP(cameraEspParts)
        if state then
            for _, cam in pairs(workspace:WaitForChild("Cameras"):GetChildren()) do
                if cam:IsA("Model") then
                    local part = cam.PrimaryPart or cam:FindFirstChild("Handle") or cam:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local esp = createESP(cam, "Camera", Color3.fromRGB(255, 255, 0))
                        table.insert(cameraEspParts, esp)
                    end
                end
            end
        end
    end,
})
local ESPItem = Tab3:CreateToggle({
    Name = "Предметы ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(state)
        clearESP(itemEspParts)
        if not state then return end

        local lootablesFolder = workspace:WaitForChild("Lootables")
        for _, model in pairs(lootablesFolder:GetChildren()) do
            if model:IsA("Model") then
                local targetModel = nil
                local childrenModels = {}
                for _, ch in pairs(model:GetChildren()) do
                    if ch:IsA("Model") then table.insert(childrenModels, ch) end
                end

                if #childrenModels == 0 then
                    targetModel = model
                elseif #childrenModels == 1 then
                    targetModel = (childrenModels[1].Name == "Model") and model or childrenModels[1]
                else
                    for _, m in pairs(childrenModels) do
                        if m.Name ~= "Model" then targetModel = m break end
                    end
                    if not targetModel then targetModel = model end
                end

                local part = targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart")
                if part then
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "ESP_Item"; bill.Adornee = part; bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 120, 0, 30); bill.StudsOffset = Vector3.new(0, 2, 0)
                    bill.Parent = part

                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(0, 170, 255); lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.Code; lbl.TextSize = 16; lbl.Text = targetModel.Name

                    table.insert(itemEspParts, {bill})
                end
            end
        end
    end,
})
local ESPKeycard = Tab3:CreateToggle({
    Name = "Ключ-карта ESP",
    CurrentValue = false,
    Flag = "KeycardESP",
    Callback = function(state)
        clearESP(keycardEspParts)
        if state then
            task.spawn(function()
                while state do
                    clearESP(keycardEspParts)
                    for _, guard in pairs(workspace:WaitForChild("Police"):GetChildren()) do
                        local lanyard = guard:FindFirstChild("Lanyard")
                        local keycard = lanyard and lanyard:FindFirstChild("PickpocketKeycard")
                        local model = keycard and keycard:FindFirstChild("Model")
                        if model then
                            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local esp = createESP(model, "Keycard", Color3.fromRGB(255, 128, 0))
                                table.insert(keycardEspParts, esp)
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end,
})
local SpecialKeyESP = Tab3:CreateToggle({
    Name = "ESP специальных ключей",
    CurrentValue = false,
    Flag = "SpecialKeyESP",
    Callback = function(state)
        if _G.specialKeyESP then
            for _, v in pairs(_G.specialKeyESP) do
                if v and v.Parent then v:Destroy() end
            end
            _G.specialKeyESP = nil
        end

        if state then
            _G.specialKeyESP = {}
            local yellow = Color3.fromRGB(255, 255, 0)

            local function makeESP(part, name)
                if not part then return end
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP"; billboard.Adornee = part; billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 80, 0, 20); billboard.StudsOffset = Vector3.new(0, 2, 0)
                
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
                label.TextColor3 = yellow; label.Text = name; label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                
                billboard.Parent = part
                table.insert(_G.specialKeyESP, billboard)

                local hl = Instance.new("Highlight")
                hl.Adornee = part; hl.FillColor = yellow; hl.OutlineColor = Color3.fromRGB(255, 180, 0)
                hl.FillTransparency = 0.35; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = part
                table.insert(_G.specialKeyESP, hl)
            end

            -- Guard 14
            local policeFolder = workspace:FindFirstChild("Police")
            local guard14 = policeFolder and policeFolder:GetChildren()[14]
            local keyAcc = guard14 and guard14:FindFirstChild("KeyAccessory")
            if keyAcc and keyAcc:FindFirstChild("Handle") then
                makeESP(keyAcc.Handle, "Guard Key")
            end

            -- Map Keys
            local map = workspace:FindFirstChild("Map")
            if map then
                for _, subFolder in pairs(map:GetChildren()) do
                    if subFolder.Name == "Keys" then
                        for _, key in pairs(subFolder:GetChildren()) do
                            local handle = key:FindFirstChild("Handle") or key
                            makeESP(handle, "Map Key")
                        end
                    end
                end
            end
        end
    end,
})
