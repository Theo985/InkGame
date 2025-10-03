local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Shark.io",
   LoadingTitle = "Shark.io",
   LoadingSubtitle = "by Kondax and ar1hurgit",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "OrbScript",
      FileName = "OrbSettings"
   },
   KeySystem = false
})

local player = game.Players.LocalPlayer
local espOrbEnabled = false
local espPlayerEnabled = false
local autoTP = false
local orbsToPlayerNormal = false
local orbsToPlayerFast = false
local speedHackEnabled = false
local originalWalkSpeed = 16
local speedMultiplier = 2

local function getRoot()
    if player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart")
    end
end

----------------------------------------------------
-- 🔹 ESP
----------------------------------------------------
local ESPTab = Window:CreateTab("ESP", 4483362458)
local orbESPObjects, playerESPObjects = {}, {}

local function createESPOrb(orb)
    if orb:IsA("Model") and orb.Name:lower():find("orb") then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255,0,255)
        highlight.OutlineColor = Color3.fromRGB(255,255,0)
        highlight.Parent = orb
        orbESPObjects[orb] = highlight
    end
end

local function removeESPOrb()
    for _, h in pairs(orbESPObjects) do if h then h:Destroy() end end
    orbESPObjects = {}
end

local function refreshESPOrb()
    removeESPOrb()
    local folder = workspace:FindFirstChild("OrbSpawners")
    if folder then
        for _, zone in ipairs(folder:GetChildren()) do
            for _, obj in ipairs(zone:GetChildren()) do
                createESPOrb(obj)
            end
        end
    end
end

ESPTab:CreateToggle({
    Name = "ESP Orbs",
    CurrentValue = false,
    Callback = function(state)
        espOrbEnabled = state
        if state then
            task.spawn(function()
                while espOrbEnabled do
                    refreshESPOrb()
                    task.wait(1)
                end
            end)
        else
            removeESPOrb()
        end
    end
})

local function createESPPlayer(target)
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(0,255,255)
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.Parent = target.Character
        playerESPObjects[target] = highlight
    end
end

local function removeESPPlayer()
    for _, h in pairs(playerESPObjects) do if h then h:Destroy() end end
    playerESPObjects = {}
end

local function refreshESPPlayer()
    removeESPPlayer()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then createESPPlayer(plr) end
    end
end

ESPTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Callback = function(state)
        espPlayerEnabled = state
        if state then
            task.spawn(function()
                while espPlayerEnabled do
                    refreshESPPlayer()
                    task.wait(2)
                end
            end)
        else
            removeESPPlayer()
        end
    end
})

local velocityLabel = ESPTab:CreateLabel("Velocity: 0")
task.spawn(function()
    while task.wait(0.1) do
        local root = getRoot()
        if root then
            local speed = root.Velocity.Magnitude
            velocityLabel:Set("Velocity: "..math.floor(speed))
        end
    end
end)

----------------------------------------------------
-- 🔹 TP
----------------------------------------------------
local TPTab = Window:CreateTab("TP", 4483362458)

-- Auto TP to Orbs
TPTab:CreateToggle({
    Name = "Auto TP to Orbs",
    CurrentValue = false,
    Callback = function(state)
        autoTP = state
        task.spawn(function()
            while autoTP do
                local root = getRoot()
                local folder = workspace:FindFirstChild("OrbSpawners")
                if root and folder then
                    for _, zone in ipairs(folder:GetChildren()) do
                        for _, obj in ipairs(zone:GetChildren()) do
                            if obj:IsA("Model") and obj.Name:lower():find("orb") then
                                local part = obj:FindFirstChildWhichIsA("BasePart", true)
                                if part then
                                    part.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

-- Fonction pour récupérer la liste des joueurs (leaderboard)
local function getPlayerOptions()
    local options = {"Aucun joueur"}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local points, kills, coins = 0, 0, 0
            if plr:FindFirstChild("leaderstats") then
                local stats = plr.leaderstats
                if stats:FindFirstChild("Points") then points = stats.Points.Value end
                if stats:FindFirstChild("Kills") then kills = stats.Kills.Value end
                if stats:FindFirstChild("Coins") then coins = stats.Coins.Value end
            end
            table.insert(options, string.format("%s | Points: %d Kills: %d Coins: %d", plr.Name, points, kills, coins))
        end
    end
    return options
end

-- Dropdown Player
local playerDropdown = TPTab:CreateDropdown({
    Name = "Teleport Player",
    Options = getPlayerOptions(),
    CurrentOption = "Aucun joueur",
    Callback = function(option)
        local optionText = tostring(option)
        if optionText == "Aucun joueur" then return end

        -- Récupère le nom du joueur avant le ' | '
        local sep = string.find(optionText, " |")
        local playerName = sep and string.sub(optionText, 1, sep - 1) or optionText

        local targetPlayer = game.Players:FindFirstChild(playerName)
        if targetPlayer and targetPlayer.Character then
            local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = getRoot()
            if rootPart and myRoot then
                myRoot.CFrame = rootPart.CFrame + Vector3.new(0,3,0)
            end
        end
    end
})

-- Fonction pour rafraîchir la liste
local function refreshPlayerList()
    local options = getPlayerOptions()
    pcall(function()
        playerDropdown:SetOptions(options)
        if not table.find(options, playerDropdown.CurrentOption) then
            playerDropdown:SetOption(options[1])
        end
    end)
end

-- Refresh automatique
task.spawn(function()
    while task.wait(3) do
        refreshPlayerList()
    end
end)

-- Evenements
game.Players.PlayerAdded:Connect(refreshPlayerList)
game.Players.PlayerRemoving:Connect(refreshPlayerList)

refreshPlayerList()


-- Bouton pour rafraîchir manuellement
TPTab:CreateButton({
    Name = "Reload Player List",
    Callback = refreshPlayerList
})


----------------------------------------------------
-- 🔹 BUG
----------------------------------------------------
local BugTab = Window:CreateTab("Bug", 4483362458)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wheelRemote, shNetwork_upvr
pcall(function()
    wheelRemote = ReplicatedStorage:WaitForChild("Network",5):WaitForChild("RemoteEvent",5)
    shNetwork_upvr = ReplicatedStorage:WaitForChild("shNetwork_upvr",5)
end)

BugTab:CreateButton({ Name = "Spin Wheel x1", Callback = function()
    if wheelRemote then pcall(function() wheelRemote:FireServer("handleWheelSpin") end) end
end})

BugTab:CreateButton({ Name = "Spin Wheel x5/ne fonctionne pas ", Callback = function()
    if wheelRemote then
        pcall(function()
            for i=1,5 do wheelRemote:FireServer("handleWheelSpin") end
        end)
    end
end})

BugTab:CreateButton({ Name = "Revenge Action/ne fonctionne pas ", Callback = function()
    if shNetwork_upvr then pcall(function() shNetwork_upvr:FireServer("revenge") end) end
end})

BugTab:CreateButton({ Name = "Revive Player/ne fonctionne pas ", Callback = function()
    if shNetwork_upvr then pcall(function() shNetwork_upvr:FireServer("revive") end) end
end})

----------------------------------------------------
-- 🔹 AUTOFARM
----------------------------------------------------
local AutoFarmTab = Window:CreateTab("Autofarm", 4483362458)

AutoFarmTab:CreateToggle({
    Name = "Move Orbs to Me (Normal)",
    CurrentValue = false,
    Callback = function(state)
        orbsToPlayerNormal = state
        if state then
            task.spawn(function()
                while orbsToPlayerNormal do
                    local root = getRoot()
                    local folder = workspace:FindFirstChild("OrbSpawners")
                    if root and folder then
                        for _, zone in ipairs(folder:GetChildren()) do
                            for _, obj in ipairs(zone:GetChildren()) do
                                if obj:IsA("Model") and obj.Name:lower():find("orb") then
                                    local part = obj:FindFirstChildWhichIsA("BasePart",true)
                                    if part then part.CFrame = root.CFrame + Vector3.new(0,3,0) end
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

AutoFarmTab:CreateToggle({
    Name = "Move Orbs to Me (Fast)",
    CurrentValue = false,
    Callback = function(state)
        orbsToPlayerFast = state
        if state then
            task.spawn(function()
                while orbsToPlayerFast do
                    local root = getRoot()
                    local folder = workspace:FindFirstChild("OrbSpawners")
                    if root and folder then
                        for _, zone in ipairs(folder:GetChildren()) do
                            for _, obj in ipairs(zone:GetChildren()) do
                                if obj:IsA("Model") and obj.Name:lower():find("orb") then
                                    local part = obj:FindFirstChildWhichIsA("BasePart",true)
                                    if part then part.CFrame = root.CFrame + Vector3.new(0,3,0) end
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

----------------------------------------------------
-- 🔹 MISC
----------------------------------------------------
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateButton({
    Name = "Private Server TP",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/veil0x14/LocalScripts/refs/heads/main/pg.lua"))()
        end)
    end
})

MiscTab:CreateButton({
    Name = "Infinity Yield",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source',true))()
        end)
    end
})

MiscTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(state)
        speedHackEnabled = state
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart then
                if state then
                    originalWalkSpeed = humanoid.WalkSpeed
                    humanoid.WalkSpeed = originalWalkSpeed
                    task.spawn(function()
                        while speedHackEnabled and humanoid and rootPart do
                            local moving = humanoid.MoveDirection.Magnitude > 0
                            if moving then
                                local dir = humanoid.MoveDirection.Unit
                                rootPart.AssemblyLinearVelocity = dir * (originalWalkSpeed * speedMultiplier)
                            else
                                rootPart.AssemblyLinearVelocity = Vector3.zero
                            end
                            task.wait(0.005)
                        end
                    end)
                else
                    humanoid.WalkSpeed = originalWalkSpeed
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
})

MiscTab:CreateSlider({
    Name = "Speed Multiplier",
    Range = {1, 100},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 2,
    Callback = function(value)
        speedMultiplier = value
    end
})

local hidePlayerNametags = false

local function applyNametagVisibilityToCharacter(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tag = hrp:FindFirstChild("PlayerNametag", true)
    if not tag then return end
    pcall(function()
        if tag:IsA("BillboardGui") or tag:IsA("SurfaceGui") then
            tag.Enabled = not hidePlayerNametags
        elseif tag:IsA("GuiObject") then
            tag.Visible = not hidePlayerNametags
        elseif tag:IsA("BasePart") then
            if tag.LocalTransparencyModifier ~= nil then
                tag.LocalTransparencyModifier = hidePlayerNametags and 1 or 0
            else
                tag.Transparency = hidePlayerNametags and 1 or 0
            end
        elseif tag.GetAttribute and tag:GetAttribute("Visible") ~= nil then
            tag:SetAttribute("Visible", not hidePlayerNametags)
        end
    end)
end

local function applyNametagVisibilityToAll()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character then
            applyNametagVisibilityToCharacter(plr.Character)
        end
    end
end

MiscTab:CreateToggle({
    Name = "Hide Player Nametags",
    CurrentValue = false,
    Callback = function(state)
        hidePlayerNametags = state
        applyNametagVisibilityToAll()
    end
})

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.spawn(function()
            task.wait(0.1)
            applyNametagVisibilityToCharacter(char)
        end)
    end)
end)

for _, plr in ipairs(game.Players:GetPlayers()) do
    plr.CharacterAdded:Connect(function(char)
        task.spawn(function()
            task.wait(0.1)
            applyNametagVisibilityToCharacter(char)
        end)
    end)
end
