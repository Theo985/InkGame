-- InkGame UI Alternative (Full Script with Library)
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- UI Library Import
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = lib.CreateLib("InkGame Kondax Panel", "Ocean")

-- Variables
local noclip = false
local antiRagdollFreeze = false
local noclipConnection

-- Noclip toggle function
local function toggleNoclip(state)
    noclip = state
    if noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- Reset CanCollide on all parts
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function teleportTo(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local espEnabled = false
local activeESP = {}

local function clearESP()
    for _, v in ipairs(activeESP) do
        if v and v.Parent then
            v:Destroy()
        end
    end
    activeESP = {}
end

local function createESP(target)
    if not target.Character then return end
    local char = target.Character
    local hasKnife = false

    local function hasTool(container)
        for _, item in ipairs(container:GetChildren()) do
            local name = item.Name:lower()
            if name:find("knife") then
                hasKnife = true
                break
            end
        end
    end

    pcall(function()
        hasTool(target:FindFirstChild("Backpack") or {})
        hasTool(char)
    end)

    local color = hasKnife and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Adornee = part
            adorn.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
            adorn.Color3 = color
            adorn.Transparency = 0.5
            adorn.AlwaysOnTop = true
            adorn.ZIndex = 10
            adorn.Parent = part
            table.insert(activeESP, adorn)
        end
    end

    local head = char:FindFirstChild("Head")
    if head then
        local tag = Instance.new("BillboardGui", head)
        tag.Adornee = head
        tag.Size = UDim2.new(0, 100, 0, 20)
        tag.StudsOffset = Vector3.new(0, 2, 0)
        tag.AlwaysOnTop = true

        local txt = Instance.new("TextLabel", tag)  
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = target.Name
        txt.TextColor3 = color
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true

        table.insert(activeESP, tag)
    end
end

-- Anti-Ragdoll (force Humanoid State back to standing)
RunService.Stepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        if hum:GetState() == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- Tabs and Sections
local tabControls = Window:NewTab("Controls")
local sectionControls = tabControls:NewSection("Player")

sectionControls:NewToggle("Toggle Noclip", "Active/Désactive les collisions", function(state)
    toggleNoclip(state)
end)

sectionControls:NewButton("Simuler vol (fly)", "Monte le joueur dans les airs", function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(0, 100, 0)
    end
end)

sectionControls:NewButton("TP to Random Player", "Se téléporter à un joueur aléatoire", function()
    local others = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, p)
        end
    end
    if #others > 0 then
        local randomPlayer = others[math.random(1, #others)]
        teleportTo(randomPlayer.Character.HumanoidRootPart.Position)
    end
end)

sectionControls:NewButton("Se relever instantanément", "Force le joueur à se lever s'il est ragdoll", function()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

sectionControls:NewSlider("Speed Hack", "Règle la vitesse du joueur", 100, 16, function(value)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

-- Anti-Ragdoll Freeze toggle
sectionControls:NewToggle("Anti-Ragdoll Freeze ( not working)", "Détecte chute et freeze le jeu 2 secondes", function(state)
    antiRagdollFreeze = state
    if state then
        coroutine.wrap(function()
            while antiRagdollFreeze do
                wait(0.1)
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    if hum:GetState() == Enum.HumanoidStateType.Physics then
                        -- Freeze: Disable input, walk speed 0, anchor parts
                        local UserInputService = game:GetService("UserInputService")

                        local connectionBegan
                        local connectionEnded
                        local function blockInput() return Enum.ContextActionResult.Sink end

                        connectionBegan = UserInputService.InputBegan:Connect(blockInput)
                        connectionEnded = UserInputService.InputEnded:Connect(blockInput)

                        local oldSpeed = hum.WalkSpeed
                        hum.WalkSpeed = 0

                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end

                        wait(2)

                        hum.WalkSpeed = oldSpeed
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end

                        if connectionBegan then connectionBegan:Disconnect() end
                        if connectionEnded then connectionEnded:Disconnect() end
                    end
                end
            end
        end)()
    end
end)

-- Game Tabs
local tabRedLight = Window:NewTab("Red Light, Green Light")
local sectionRed = tabRedLight:NewSection("Red Light")
sectionRed:NewButton("TP to the end", "Téléporte à la fin", function()
    teleportTo(Vector3.new(-83.7579, 1023.4667, 100.0126))
end)
sectionRed:NewButton("TP to the start", "Téléporte au début", function()
    teleportTo(Vector3.new(-52, 1023, -531))
end)

local tabDalgona = Window:NewTab("Dalgona")
local sectionDalgona = tabDalgona:NewSection("Dalgona")
-- Vide

local tabNight = Window:NewTab("Night Battle")
local sectionNight = tabNight:NewSection("Night Battle")
sectionNight:NewButton("TP to Night Battle", "Téléporte à la zone de nuit", function()
    teleportTo(Vector3.new(176, 144, -70))
end)

local tabHide = Window:NewTab("Hide and Seek")
local sectionHide = tabHide:NewSection("Hide and Seek")
sectionHide:NewToggle("ESP Global", "Affiche les joueurs avec ESP", function(state)
    espEnabled = state
    clearESP()
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                createESP(p)
            end
        end
    end
end)

sectionHide:NewButton("TP to random locked door", "Téléporte devant une porte verrouillée", function()
    local lockedDoors = {}
    local map = workspace:FindFirstChild("HideAndSeekMap")

    if map then
        for _, v in pairs(map:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "DoorIsLocked" then
                table.insert(lockedDoors, v)
            end
        end
    end

    if #lockedDoors > 0 then
        local door = lockedDoors[math.random(1, #lockedDoors)]
        -- Se téléporter à 3 studs devant la face avant de la porte
        local forward = door.CFrame.LookVector
        local targetPos = door.Position - (forward * 3)
        teleportTo(Vector3.new(targetPos.X, door.Position.Y, targetPos.Z))
    else
        warn("Aucune porte 'DoorIsLocked' trouvée dans HideAndSeekMap.")
    end
end)

sectionHide:NewButton("TP to hider", "Téléporte à un joueur sans couteau et vivant", function()
    local validTargets = {}

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = p.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local hasKnife = false

                local function check(container)
                    for _, tool in ipairs(container:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:lower():find("knife") then
                            hasKnife = true
                            break
                        end
                    end
                end

                pcall(function()
                    check(p:FindFirstChild("Backpack") or {})
                    check(p.Character)
                end)

                if not hasKnife then
                    table.insert(validTargets, p)
                end
            end
        end
    end

    if #validTargets > 0 then
        local target = validTargets[math.random(1, #validTargets)]
        teleportTo(target.Character.HumanoidRootPart.Position)
    else
        warn("Aucun joueur sans couteau vivant trouvé.")
    end
end)

local tabRope = Window:NewTab("Rope Game")
local sectionRope = tabRope:NewSection("Rope Game")
sectionRope:NewButton("TP to the end", "Téléporte à la fin du rope", function()
    teleportTo(Vector3.new(734, 197, 920))
end)

sectionRope:NewButton("Freeze Rope ( not working)", "Fige la corde en l'ancrant", function()
    local rope = workspace:FindFirstChild("JumpRope")
    if rope then
        local important = rope:FindFirstChild("Important")
        if important then
            local ropePart = important:FindFirstChild("ropetesting")
            if ropePart and ropePart:IsA("BasePart") then
                ropePart.Anchored = true
            end
        end
    end
end)
