--[[
local args = {
	"Super Commander",
	"Troops"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
ремот для покупки юнитов
local args = {
	"Swordsman",
	"Troops"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
- pokupka unitov
--]]
local huy = false
local huy2 = false
local automatic = false
local automatic2 = false
local enabled = false
local workerRunning = false
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "kaLLoware | Make a Army",
   Icon = 0,
   LoadingTitle = "Make a Army",
   LoadingSubtitle = "by kaLLoware",
   ShowText = "Hub", 
   Theme = "Ocean", -- https://docs.sirius.menu/rayfield/configuration/themes

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
      Title = "Анти-пиратство",
      Subtitle = "Ключ система",
      Note = "Только олды знают",
      FileName = "Key",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"kaLLoware"}  -- ("hello","key22")
   }
})
local Tab = Window:CreateTab("Farm")
local Tab2 = Window:CreateTab("Auto Buy")
local Toggle = Tab:CreateToggle({
    Name = "Начать фарм",
    CurrentValue = false,
    Flag = "RunLoop",
    Callback = function(Value)
        enabled = Value

        if enabled and not workerRunning then
            workerRunning = true
            task.spawn(function()
                while enabled do
                    local args = {
                    	99,
                    	99,
                    	99
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DistanceWalked"):FireServer(unpack(args))
                    task.wait(0.001)
                end
                workerRunning = false
            end)
        end
    end
})
local Toggle = Tab2:CreateToggle({
    Name = "Начать авто покупку юнитов",
    CurrentValue = false,
    Flag = "buyloop",
    Callback = function(Value)
        automatic = Value

        if automatic and not automatic2 then
            automatic2 = true
            task.spawn(function()
                while automatic do
                    local args = {
                    	"Swordsman",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Archer",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Rookie Commander",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Withc",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Crossbow",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Healer",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Wizard",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Spearman",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Ballon",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Captain Commander",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Noob King",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Golem",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Dragon",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Super Commander",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Titan",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                    	"Juggernaut",
                    	"Troops"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    task.wait(10)
                end
                automatic2 = false
            end)
        end
    end
})
local Toggle = Tab2:CreateToggle({
    Name = "Начать автр покупку заклинаний",
    CurrentValue = false,
    Flag = "elixrun",
    Callback = function(Value)
        huy = Value

        if huy and not huy2 then
            huy2 = true
            task.spawn(function()
                while huy do
                    local args = {
                	    "Freeze",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                	    "Fireball",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                	    "Heal",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                	    "Rage",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                	    "Poison",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                	    "Earth",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                	    "Arthurs Sword",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    local args = {
                	    "Lightning",
	                    "Spells"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PurchaseItem"):FireServer(unpack(args))
                    task.wait(10)
                end
                huy2 = false
            end)
        end
    end
})
