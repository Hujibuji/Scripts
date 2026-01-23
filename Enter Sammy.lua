local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local running = false
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Enter Sammy | kaLLoware",
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
   },

   KeySystem = false,
})
local Tab = Window:CreateTab("Фарм", 4483362458)
Tab:CreateToggle({
	Name = "Авто победа",
	CurrentValue = false,
	Flag = "AutoWinTween",
	Callback = function(state)
		running = state
		if state then
			task.spawn(function()
				while running do
					local character = player.Character or player.CharacterAdded:Wait()
					local hrp = character:WaitForChild("HumanoidRootPart")
					local target = workspace.Zones.WinZone.Zone
					for _, v in ipairs(character:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end
					local tweenInfo = TweenInfo.new(
						2,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.Out
					)
					local goal = {
						CFrame = target.CFrame + Vector3.new(0, 3, 0)
					}
					local tween = TweenService:Create(hrp, tweenInfo, goal)
					tween:Play()
					tween.Completed:Wait()
					task.wait(13)
				end
			end)
		end
	end,
})
