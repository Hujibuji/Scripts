local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "sab tuff boi sigma 67 hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Steal a Brainrot Hub",
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
local Section = Tab:CreateSection("Самый топчик тут nameless, используйте его")
local Button = Tab:CreateButton({
   Name = "Lemon Hub",
   Callback = function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/6d08fbf253529a4fefa32ff404bd5448.lua"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Lennze Hub",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/salmdoske2233-spec/LennzeHub/refs/heads/main/main.lua"))()
   end,
})
local Button = Tab:CreateButton({
   Name = "Nameless Hub",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ily123950/Vulkan/refs/heads/main/Tr"))()
   end,
})
