local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "KXScript | Shark.io",
   LoadingTitle = "KXScript | Shark.io",
   LoadingSubtitle = "by Kondax",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "OrbScript",
      FileName = "OrbSettings"
   },
   KeySystem = false
})

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local espOrbEnabled = false
local espPlayerEnabled = false
local autoTP = false
local orbsToPlayerNormal = false
local orbsToPlayerFast = false
local spawnOrbSpamToggle = false

local function getRoot()
    if player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart")
    end
end

-- ========================== ESP TAB ==========================
local ESPTab = Window:CreateTab("ESP", 4483362458)
local orbESPObjects = {}
local playerESPObjects = {}

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

-- ========================== TP TAB ==========================
local TPTab = Window:CreateTab("TP", 4483362458)

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
                               local part = obj:FindFirstChildWhichIsA("BasePart",true)
                               if part then
                                   root.CFrame = part.CFrame + Vector3.new(0,3,0)
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

local playerDropdown = TPTab:CreateDropdown({
   Name = "Teleport Player",
   Options = {},
   CurrentOption = ""
})

TPTab:CreateButton({
   Name = "Reload Player List",
   Callback = function()
       local names = {}
       for _, plr in ipairs(game.Players:GetPlayers()) do
           if plr ~= player then table.insert(names, plr.Name) end
       end
       playerDropdown:SetOptions(names)
   end
})

-- ========================== BUG TAB ==========================
local BugTab = Window:CreateTab("Bug", 4483362458)
local wheelRemote
pcall(function()
   wheelRemote = ReplicatedStorage:WaitForChild("Network",5):WaitForChild("RemoteEvent",5)
end)

BugTab:CreateButton({
   Name = "Spin Wheel x1",
   Callback = function()
       if wheelRemote then
           pcall(function()
               wheelRemote:FireServer("handleWheelSpin")
           end)
       end
   end
})

-- ========================== AUTOFARM TAB ==========================
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
                                   if part then
                                       part.CFrame = root.CFrame + Vector3.new(0,3,0)
                                   end
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
                                   if part then
                                       part.CFrame = root.CFrame + Vector3.new(0,3,0)
                                   end
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

-- ========================== MISC TAB ==========================
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

MiscTab:CreateButton({
   Name = "Force R15",
   Callback = function()
       local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
       if hum then
           hum.RigType = Enum.HumanoidRigType.R15
       end
   end
})

-- ========================== SOUND TAB ==========================
local SoundTab = Window:CreateTab("Sound", 4483362458)

SoundTab:CreateTextBox({
    Name = "Set Orb Sound ID",
    PlaceholderText = "Enter Roblox Sound ID",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local soundId = tonumber(text)
        if soundId and ReplicatedStorage:FindFirstChild("Sounds") and ReplicatedStorage.Sounds:FindFirstChild("Blop") then
            ReplicatedStorage.Sounds.Blop.SoundId = "rbxassetid://"..soundId
        end
    end
})

-- ========================== SPAWN ORB TAB ==========================
local SpawnTab = Window:CreateTab("Spawn Orb", 4483362458)

SpawnTab:CreateButton({
    Name = "Spawn Orb Once",
    Callback = function()
        local root = getRoot()
        if root and ReplicatedStorage:FindFirstChild("Orbs") then
            for _, orbModel in ipairs(ReplicatedStorage.Orbs:GetChildren()) do
                if orbModel:IsA("Model") then
                    if not orbModel.PrimaryPart then
                        orbModel.PrimaryPart = orbModel:FindFirstChildWhichIsA("BasePart")
                    end
                    if orbModel.PrimaryPart then
                        local clone = orbModel:Clone()
                        clone.Parent = workspace
                        clone:SetPrimaryPartCFrame(root.CFrame + root.CFrame.LookVector*5)
                    end
                end
            end
        end
    end
})

SpawnTab:CreateToggle({
    Name = "Spam Orbs",
    CurrentValue = false,
    Callback = function(state)
        spawnOrbSpamToggle = state
        if state then
            task.spawn(function()
                while spawnOrbSpamToggle do
                    local root = getRoot()
                    if root and ReplicatedStorage:FindFirstChild("Orbs") then
                        for _, orbModel in ipairs(ReplicatedStorage.Orbs:GetChildren()) do
                            if orbModel:IsA("Model") then
                                if not orbModel.PrimaryPart then
                                    orbModel.PrimaryPart = orbModel:FindFirstChildWhichIsA("BasePart")
                                end
                                if orbModel.PrimaryPart then
                                    local clone = orbModel:Clone()
                                    clone.Parent = workspace
                                    clone:SetPrimaryPartCFrame(root.CFrame + root.CFrame.LookVector*5)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})
