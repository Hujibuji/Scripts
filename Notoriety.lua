local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "kalloware.space",
   Icon = 0,
   LoadingTitle = "kalloware.space",
   LoadingSubtitle = "by kaLLoware",
   ShowText = "kalloware.space",
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
local Tab = Window:CreateTab("лрйь йдддд")
local Section = Tab:CreateSection("Выбери язык | Choose language")
local Divider = Tab:CreateDivider()
local Button = Tab:CreateButton({
   Name = "Русский",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/russian.lua"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "English",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/english.lua"))()
   end,
})
