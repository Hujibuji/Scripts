local SupportedGames = {
    [137969408767471] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/Make%20A%20Army.lua",
    [2753915549] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/Blox%20Fruits%20Hub.lua",
    [109983668079237] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/Sab%20Hub.lua",
    [140374914197602] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/Speed%20Clicker.lua",
    [126509999114328] = "https://raw.githubusercontent.com/Hujibuji/Scripts/refs/heads/main/99%20Nights%20In%20Da%20Forest.lua",
}

local currentPlaceId = game.PlaceId

if SupportedGames[currentPlaceId] then
    loadstring(game:HttpGet(SupportedGames[currentPlaceId]))()
else
    print("Игра не поддерживается. ID:", currentPlaceId)
end
