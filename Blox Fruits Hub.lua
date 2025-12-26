local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Bf tuff boi sigma 67 hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Blox Fruits Hub",
   LoadingSubtitle = "by kaLLoware",
   ShowText = "Hub",
   Theme = "Ocean", 

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
local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection("Я давно не тестировал эти скрипты, если что-то не работает, то используйте другие")
local Button = Tab:CreateButton({
   Name = "Quantum Onyx",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/quantum.lua"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Ok Hub",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/anowerrrr333-star/scripts/refs/heads/main/okHUB.lua"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Volcano",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wpisstestfprg/Volcano/refs/heads/main/VolcanoNewUpdated.luau"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Gravity Hub",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-GravityHub/BloxFruit/refs/heads/main/Main.lua"))()
   end,
})
