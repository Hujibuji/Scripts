-- гейфилд
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- окно
local Window = Rayfield:CreateWindow({
   Name = "NFT Battle | kaLLoware",
   Icon = 0,
   LoadingTitle = "Загрузка...",
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
-- таб фарм
local Tab = Window:CreateTab("Фарм")
-- локальные
local selectedCase = "Trash"
local caseAmount = 10
local autoFarmActive = false
local autoChristmas = false
-- кнопочки
-- дропдаун кейсов
local Dropdown = Tab:CreateDropdown({
   Name = "Выберите кейс",
   Options = {"Trash", "Durov", "REDO", "Magnate", "Cirque", "Plodder", "Office Clerk", "Manager", "Director", "Oligarch", "Frozen Heart", "Bubble Gum", "Cats", "Glitch", "Dream", "Bloody Night", "M5 F90", "G63", "Porsche 911", "URUS", "Gold", "Dark", "Palm", "Burj", "Luxury", "Monarch", "Angel"},
   CurrentOption = {"Trash"},
   MultipleOptions = false,
   Callback = function(Option)
      selectedCase = Option[1]
   end,
})
-- инпут количества кейсов
local Input = Tab:CreateInput({
   Name = "Количество кейсов",
   PlaceholderText = "Введите число (1-10)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then
         if num > 10 then 
            caseAmount = 10 
         elseif num < 1 then 
            caseAmount = 1
         else
            caseAmount = num
         end
         print("OK")
      else
         warn("Пожалуйста, введите число!")
      end
   end,
})
-- тоггл автофарма
local Toggle = Tab:CreateToggle({
   Name = "Автофарм кейсов",
   CurrentValue = false,
   Callback = function(Value)
      autoFarmActive = Value
      if autoFarmActive then
         task.spawn(function()
            while autoFarmActive do
               local openArgs = {
                  selectedCase,
                  caseAmount
               }
               pcall(function()
                  game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("OpenCase"):InvokeServer(unpack(openArgs))
               end)
               task.wait(1)
               local sellArgs = {
                  "Sell",
                  "ALL",
                  false
               }
               pcall(function()
                  game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Inventory"):FireServer(unpack(sellArgs))
               end)
               task.wait(0.5)
            end
         end)
      end
   end,
})
local ChristmasToggle = Tab:CreateToggle({
   Name = "Авто-сбор снежинок",
   CurrentValue = false,
   Flag = "ChristmasFlag",
   Callback = function(Value)
      autoChristmas = Value
      if autoChristmas then
         task.spawn(function()
            while autoChristmas do
               local args = {
                  "Claim"
               }
               pcall(function()
                  game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Christmas"):InvokeServer(unpack(args))
               end)
               task.wait(5)
            end
         end)
      end
   end,
})
