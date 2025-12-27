local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local SupportedGames = {
    [137969408767471] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/Make%20A%20Army.lua",
    [2753915549] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/Blox%20Fruits%20Hub.lua",
    [21532277] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/Notoriety.lua",
}

local currentPlaceId = game.PlaceId


if SupportedGames[currentPlaceId] then
    Rayfield:Notify({
        Title = "Загрузка...",
        Content = "Скрипт для этой игры найден!",
        Duration = 5,
        Image = 4483362458,
    })
    loadstring(game:HttpGet(SupportedGames[currentPlaceId]))()
else
    print("Игра не поддерживается. ID:", currentPlaceId)
end
