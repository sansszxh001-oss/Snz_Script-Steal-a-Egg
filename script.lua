-- Steel a Egg Exploit Suite
-- Features: Auto-Farm, Teleport, Item Duplication, Custom UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ============================================================================
-- CONFIG
-- ============================================================================

local config = {
    farmEnabled = false,
    dupeEnabled = false,
    teleportMode = false,
    farmRadius = 100,
    farmDelay = 0.5,
    uiScale = 1
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function getEggParts()
    local eggs = {}
    for _, part in pairs(workspace:FindPartBoundsInRadius(player.Character.HumanoidRootPart.Position, config.farmRadius)) do
        if part.Name:lower():match("egg") or part.Parent.Name:lower():match("egg") then
            table.insert(eggs, part)
        end
    end
    return eggs
end

local function teleportTo(position)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

local function cloneEgg(egg)
    if egg and egg.Parent then
        local clone = egg:Clone()
        clone.Parent = player.Character
        clone.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(5, 0, 0)
        
        -- Try to register clone as owned
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            clone:MoveTo(player.Character.HumanoidRootPart.Position + Vector3.new(2, 2, 2))
        end
    end
end

local function collectEgg(egg)
    if egg and egg.Parent then
        egg.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, -3, 0)
        wait(0.1)
        
        local touchPart = Instance.new("Part")
        touchPart.CanCollide = false
        touchPart.Transparency = 1
        touchPart.Size = Vector3.new(1, 1, 1)
        touchPart.CFrame = egg.CFrame
        touchPart.Parent = workspace
        
        egg.CFrame = touchPart.CFrame
        game:GetService("Debris"):AddItem(touchPart, 0.2)
        
        wait(config.farmDelay)
    end
end

-- ============================================================================
-- AUTO-FARM LOOP
-- ============================================================================

local farmConnection
local function startFarm()
    if farmConnection then farmConnection:Disconnect() end
    
    farmConnection = RunService.Heartbeat:Connect(function()
        if not config.farmEnabled or not player.Character then return end
        
        local eggs = getEggParts()
        for _, egg in pairs(eggs) do
            if egg and egg.Parent then
                collectEgg(egg)
            end
        end
    end)
end

local function stopFarm()
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
end

-- ============================================================================
-- TELEPORT SYSTEM
-- ============================================================================

local teleportPoints = {
    ["spawn"] = Vector3.new(0, 10, 0),
    ["farm_zone_1"] = Vector3.new(50, 10, 50),
    ["farm_zone_2"] = Vector3.new(-50, 10, -50),
    ["nest"] = Vector3.new(0, 50, 0),
}

local function teleportToPoint(pointName)
    if teleportPoints[pointName] then
        teleportTo(teleportPoints[pointName])
    end
end

-- ============================================================================
-- DUPLICATION ENGINE
-- ============================================================================

local dupeConnection
local function startDupe()
    if dupeConnection then dupeConnection:Disconnect() end
    
    dupeConnection = RunService.Heartbeat:Connect(function()
        if not config.dupeEnabled or not player.Character then return end
        
        local eggs = getEggParts()
        for _, egg in pairs(eggs) do
            if math.random(1, 3) == 1 then
                cloneEgg(egg)
            end
        end
    end)
end

local function stopDupe()
    if dupeConnection then
        dupeConnection:Disconnect()
        dupeConnection = nil
    end
end

-- ============================================================================
-- UI SYSTEM (ScreenGui)
-- ============================================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SteelAEggUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
mainFrame.Parent = screenGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Steel a Egg | Exploit"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Button factory
local function createButton(name, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(100, 200, 255)
    btn.Parent = mainFrame
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- Farm Button
createButton("FarmBtn", "[OFF] Auto-Farm", 35, function()
    config.farmEnabled = not config.farmEnabled
    if config.farmEnabled then
        startFarm()
        script.Parent.MainFrame.FarmBtn.Text = "[ON] Auto-Farm"
        script.Parent.MainFrame.FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        stopFarm()
        script.Parent.MainFrame.FarmBtn.Text = "[OFF] Auto-Farm"
        script.Parent.MainFrame.FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Dupe Button
createButton("DupeBtn", "[OFF] Duplication", 75, function()
    config.dupeEnabled = not config.dupeEnabled
    if config.dupeEnabled then
        startDupe()
        script.Parent.MainFrame.DupeBtn.Text = "[ON] Duplication"
        script.Parent.MainFrame.DupeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        stopDupe()
        script.Parent.MainFrame.DupeBtn.Text = "[OFF] Duplication"
        script.Parent.MainFrame.DupeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Teleport Buttons
local yPos = 115
for pointName, _ in pairs(teleportPoints) do
    createButton("Tp" .. pointName, "TP: " .. pointName, yPos, function()
        teleportToPoint(pointName)
    end)
    yPos = yPos + 40
end

-- Keyboard Shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        config.farmEnabled = not config.farmEnabled
        if config.farmEnabled then startFarm() else stopFarm() end
    elseif input.KeyCode == Enum.KeyCode.D then
        config.dupeEnabled = not config.dupeEnabled
        if config.dupeEnabled then startDupe() else stopDupe() end
    elseif input.KeyCode == Enum.KeyCode.T then
        teleportToPoint("spawn")
    end
end)

-- Cleanup on death
player.CharacterAdded:Connect(function()
    wait(0.5)
    if config.farmEnabled then startFarm() end
    if config.dupeEnabled then startDupe() end
end)

print("Steel a Egg Exploit loaded. F=Farm toggle, D=Dupe toggle, T=Teleport home")
