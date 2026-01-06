-- гейфилд "Trash", "Durov", "REDO", "Magnate", "Cirque", "Plodder", "Office Clerk", "Manager", "Director", "Oligarch", "Frozen Heart", "Bubble Gum", "Cats", "Glitch", "Dream", "Bloody Night", "M5 F90", "G63", "Porsche 911", "URUS", "Gold", "Dark", "Palm", "Burj", "Luxury", "Monarch", "Angel"
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
local Tab2 = Window:CreateTab("Настройки")
-- локальные
local selectedCase = ""
local caseAmount = nil
local autoOpen = false
local autoSell = false
local autoChristmas = false
-- кнопочки
-- дропдаун кейсов
local Dropdown = Tab2:CreateDropdown({
   Name = "Выберите кейс",
   Options = {"Trash", "Durov", "REDO", "Magnate", "Cirque", "Plodder", "Office Clerk", "Manager", "Director", "Oligarch", "Frozen Heart", "Bubble Gum", "Cats", "Glitch", "Dream", "Bloody Night", "M5 F90", "G63", "Porsche 911", "URUS", "Gold", "Dark", "Palm", "Burj", "Luxury", "Monarch", "Angel"},
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
      selectedCase = Option[1]
   end,
})
local Section = Tab2:CreateSection("Или введите название кейса вручную")
-- инпут ручного ввода кейса
local CustomInput = Tab2:CreateInput({
   Name = "Вписать название кейса",
   PlaceholderText = "Введите имя кейса",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text ~= "" then
         selectedCase = Text
      end
   end,
})
-- инпут количества кейсов
local Input = Tab2:CreateInput({
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
local Paragraph = Tab2:CreateParagraph({Title = "Важно!", Content = "Если выбираете через меню, то ничего не пишите в строку ниже! И наоборот."})
-- тоггл автофарма
Tab:CreateToggle({
   Name = "Авто-открытие Кейсов",
   CurrentValue = false,
   Callback = function(Value)
      autoOpen = Value
      if autoOpen then
         task.spawn(function()
            while autoOpen do
               local args = {selectedCase, caseAmount}
               pcall(function()
                  game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("OpenCase"):InvokeServer(unpack(args))
               end)
               task.wait(0.5)
            end
         end)
      end
   end,
})
Tab:CreateToggle({
   Name = "Авто-продажа",
   CurrentValue = false,
   Callback = function(Value)
      autoSell = Value
      if autoSell then
         task.spawn(function()
            while autoSell do
               local args = {"Sell", "ALL", false}
               pcall(function()
                  game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Inventory"):FireServer(unpack(args))
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
