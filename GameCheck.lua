-- ==================== CONFIG ====================
script_key = "DevToolsKey" -- mettre "DevToolsKey" pour valider et éviter le TP

-- ==================== VARIABLES GLOBALES ====================
if _G.SharkKeyValidated == nil then _G.SharkKeyValidated = false end
if _G.SharkTPDone == nil then _G.SharkTPDone = false end

-- ==================== URL ====================
local SHARK_GAME_ID = 71827013685940
local sharkScriptURL = "https://raw.githubusercontent.com/Theo985/InkGame/refs/heads/main/shark_io.lua"
local privateServerTPURL = "https://raw.githubusercontent.com/veil0x14/LocalScripts/refs/heads/main/pg.lua"

-- ==================== FONCTIONS ====================
local function loadSharkScript()
    pcall(function()
        loadstring(game:HttpGet(sharkScriptURL))()
    end)
end

local function launchPrivateServerTP()
    _G.SharkTPDone = true
    pcall(function()
        loadstring(game:HttpGet(privateServerTPURL))()
    end)
end

-- ==================== LOGIQUE ====================
local placeId = game.PlaceId

if placeId == SHARK_GAME_ID then
    -- Shark.io
    if _G.SharkKeyValidated then
        loadSharkScript() -- Clé déjà validée
    else
        if script_key == "DevToolsKey" then
            _G.SharkKeyValidated = true
            loadSharkScript() -- Clé correcte
        else
            if not _G.SharkTPDone then
                launchPrivateServerTP() -- TP unique
            else
                loadSharkScript() -- Après TP, charger Shark.io automatiquement
            end
        end
    end
else
    -- Autres jeux
    local scripts = {
        [99567941238278]   = "https://raw.githubusercontent.com/Theo985/InkGame/refs/heads/main/Ink%20Game%20Script.lua",
        [12411473842]      = "https://raw.githubusercontent.com/Theo985/InkGame/refs/heads/main/Pressure",
        [126884695634066]  = "https://raw.githubusercontent.com/Theo985/InkGame/refs/heads/main/GAG%20Script",
        [537413528]        = "https://raw.githubusercontent.com/Theo985/InkGame/refs/heads/main/BABFT.lua",
        [2753915549]       = "https://raw.githubusercontent.com/Theo985/InkGame/refs/heads/main/Blox%20Fruit.lua",
        [142823291]        = "https://raw.githubusercontent.com/Theo985/InkGame/refs/heads/main/MM2.lua",
        [8009328211]        = "https://raw.githubusercontent.com/Theo985/KXScriptDev/refs/heads/main/Raise-Animals",
    }

    local scriptURL = scripts[placeId]
    if scriptURL then
        pcall(function()
            loadstring(game:HttpGet(scriptURL))()
        end)
    else
        game.Players.LocalPlayer:Kick("Game is not in the list !")
    end
end
