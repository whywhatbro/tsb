-- The Strongest Battlegrounds - CANDY BETA Farm (UI Visibility & Mobile Fix)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Chọn nơi chứa GUI an toàn cho cả Mobile và PC
local function getSafeGuiParent()
    local success, hui = pcall(function()
        return gethui and gethui()
    end)
    if success and hui then return hui end
    
    local coreSuccess = pcall(function()
        local _ = CoreGui.Name
    end)
    if coreSuccess then return CoreGui end
    
    return playerGui
end

local guiParent = getSafeGuiParent()

if guiParent:FindFirstChild("TSBCandyBetaGui") then
    guiParent.TSBCandyBetaGui:Destroy()
end

-- Anti-AFK (Không gọi sự kiện chuột để tránh làm mất nút Mobile)
player.Idled:Connect(function()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Unknown, false, game)
    end)
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSBCandyBetaGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

-- Thanh trạng thái PUMPKIN phía trên thanh nộ
local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(0, 110, 0, 22)
statusContainer.Position = UDim2.new(0.5, -55, 1, -145)
statusContainer.BackgroundTransparency = 1
statusContainer.Visible = true
statusContainer.Parent = screenGui

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(0, 0, 0.5, -4)
statusDot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
statusDot.Parent = statusContainer

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -14, 1, 0)
statusText.Position = UDim2.new(0, 14, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "PUMPKIN"
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.TextSize = 12
statusText.Font = Enum.Font.SourceSansBold
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusContainer

-- Nút bật/tắt menu hình viên kẹo
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 150)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
toggleBtn.Text = "🍬"
toggleBtn.TextSize = 26
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.AutoButtonColor = true
toggleBtn.Parent = screenGui

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleBtn

-- Khung menu chính (Mở sẵn khi chạy script)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 275)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -137)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "CANDY BETA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

local function toggleMenu()
    mainFrame.Visible = not mainFrame.Visible
end
toggleBtn.Activated:Connect(toggleMenu)

local settings = {
    autoCandy = false,
    autoDoor = false,
    autoBossCombat = false
}

local function createFeatureToggle(name, posY, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name .. ": [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.Activated:Connect(function()
        settings[key] = not settings[key]
        if settings[key] then
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = name .. ": [ON]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.Text = name .. ": [OFF]"
        end
    end)
end

createFeatureToggle("CANDY FARM", 45, "autoCandy")
createFeatureToggle("AUTOMATIC DOOR", 90, "autoDoor")

-- Nút dịch chuyển 1 lần đến Pumpkin
local teleBossBtn = Instance.new("TextButton")
teleBossBtn.Size = UDim2.new(1, -20, 0, 40)
teleBossBtn.Position = UDim2.new(0, 10, 0, 135)
teleBossBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
teleBossBtn.Text = "TELEPORT TO PUMPKIN"
teleBossBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleBossBtn.TextSize = 12
teleBossBtn.Font = Enum.Font.SourceSansBold
teleBossBtn.Parent = mainFrame

local teleCorner = Instance.new("UICorner")
teleCorner.CornerRadius = UDim.new(0, 8)
teleCorner.Parent = teleBossBtn

createFeatureToggle("AUTO PUMPKIN COMBAT", 180, "autoBossCombat")

-- Dropdown chọn thứ tự skill
local dropToggleBtn = Instance.new("TextButton")
dropToggleBtn.Size = UDim2.new(1, -20, 0, 35)
dropToggleBtn.Position = UDim2.new(0, 10, 0, 225)
dropToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropToggleBtn.Text = "▼ Select Combat Skills Order"
dropToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropToggleBtn.TextSize = 11
dropToggleBtn.Font = Enum.Font.SourceSansBold
dropToggleBtn.Parent = mainFrame

local dropToggleCorner = Instance.new("UICorner")
dropToggleCorner.CornerRadius = UDim.new(0, 8)
dropToggleCorner.Parent = dropToggleBtn

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1, -20, 0, 100)
dropdownFrame.Position = UDim2.new(0, 10, 0, 265)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame.Visible = false
dropdownFrame.Parent = mainFrame

local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0, 8)
dropCorner.Parent = dropdownFrame

local skillListOpen = false
dropToggleBtn.Activated:Connect(function()
    skillListOpen = not skillListOpen
    dropdownFrame.Visible = skillListOpen
    mainFrame.Size = skillListOpen and UDim2.new(0, 280, 0, 375) or UDim2.new(0, 280, 0, 275)
    dropToggleBtn.Text = (skillListOpen and "▲ " or "▼ ") .. "Select Combat Skills Order"
end)

local skillOrder = {"1", "2", "3", "4"}
local availableSkills = {"1", "2", "3", "4"}

for i = 1, 4 do
    local sBtn = Instance.new("TextButton")
    sBtn.Size = UDim2.new(1, -10, 0, 20)
    sBtn.Position = UDim2.new(0, 5, 0, 5 + (i - 1) * 23)
    sBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    sBtn.Text = "Skill Slot " .. i .. " : [" .. skillOrder[i] .. "]"
    sBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sBtn.TextSize = 10
    sBtn.Font = Enum.Font.SourceSansBold
    sBtn.Parent = dropdownFrame
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 4)
    sc.Parent = sBtn
    
    sBtn.Activated:Connect(function()
        for idx, val in ipairs(availableSkills) do
            if val == skillOrder[i] then
                local nextIdx = idx % #availableSkills + 1
                skillOrder[i] = availableSkills[nextIdx]
                break
            end
        end
        sBtn.Text = "Skill Slot " .. i .. " : [" .. skillOrder[i] .. "]"
    end)
end

mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not mainFrame.Visible then
        skillListOpen = false
        dropdownFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 280, 0, 275)
        dropToggleBtn.Text = "▼ Select Combat Skills Order"
    end
end)

local validCandies = {
    ["DarkOrangeCandy1"] = true, ["DarkOrangeCandy2"] = true,
    ["DarkOrangeCandy3"] = true, ["DarkOrangeCandy4"] = true,
    ["OrangeCandy1"] = true, ["OrangeCandy2"] = true,
    ["OrangeCandy3"] = true, ["OrangeCandy4"] = true,
    ["MrBloxBar"] = true, ["BloxRoll"] = true,
    ["Chocoblox"] = true, ["BloxyDrops"] = true
}

local openedDoors = {}

local function getBossTarget()
    local liveFolder = Workspace:FindFirstChild("Live")
    if liveFolder then
        local penytaModel = liveFolder:FindFirstChild("Penyta")
        if penytaModel then
            local hrp = penytaModel:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:IsA("BasePart") then
                return penytaModel, hrp
            end
        end
    end
    return nil, nil
end

local function tapMobileButton(buttonNames)
    pcall(function()
        for _, guiObj in pairs(playerGui:GetDescendants()) do
            if guiObj:IsA("GuiButton") and guiObj.Visible then
                local gName = string.lower(guiObj.Name)
                local pName = guiObj.Parent and string.lower(guiObj.Parent.Name) or ""
                for _, targetName in ipairs(buttonNames) do
                    if gName == targetName or pName == targetName or gName:find(targetName) then
                        if firesignal then
                            firesignal(guiObj.MouseButton1Down)
                            firesignal(guiObj.Activated)
                            firesignal(guiObj.MouseButton1Click)
                            firesignal(guiObj.MouseButton1Up)
                        else
                            local absPos = guiObj.AbsolutePosition
                            local absSize = guiObj.AbsoluteSize
                            local cx = absPos.X + absSize.X / 2
                            local cy = absPos.Y + absSize.Y / 2
                            VirtualInputManager:SendTouchEvent(1, 0, cx, cy)
                            task.wait(0.01)
                            VirtualInputManager:SendTouchEvent(1, 2, cx, cy)
                        end
                        return
                    end
                end
            end
        end
    end)
end

teleBossBtn.Activated:Connect(function()
    local _, bossPart = getBossTarget()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and bossPart then
        char.HumanoidRootPart.CFrame = bossPart.CFrame
    end
end)

RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
    end
    
    local bossModel, bossPart = getBossTarget()
    statusDot.BackgroundColor3 = (bossModel and bossPart) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(120, 120, 120)
end)

task.spawn(function()
    local currentSkillIndex = 1
    local actionDelay = 0
    
    while true do
        task.wait(0.03)
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            
            -- AUTO PUMPKIN COMBAT
            if settings.autoBossCombat then
                local bossModel, bossPart = getBossTarget()
                if bossModel and bossPart then
                    hrp.CFrame = bossPart.CFrame
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    tapMobileButton({"punch", "m1", "attack", "combat", "hit"})
                    
                    actionDelay = actionDelay + 1
                    if actionDelay >= 20 then
                        actionDelay = 0
                        local activeKey = skillOrder[currentSkillIndex]
                        tapMobileButton({tostring(activeKey), "slot" .. tostring(activeKey), "skill" .. tostring(activeKey), "move" .. tostring(activeKey)})
                        currentSkillIndex = currentSkillIndex % #skillOrder + 1
                    end
                    continue
                end
            end
            
            -- CANDY FARM
            if settings.autoCandy then
                local bestCandyCenter = nil
                local maxCandiesInCluster = 0
                local allCandies = {}
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and validCandies[obj.Name] and obj.Position.Y > -10 then
                        local pos = obj.Position
                        local isForbiddenArea = (pos.X > 500 and pos.X < 800 and pos.Z > -200 and pos.Z < 100)
                        if not isForbiddenArea then
                            table.insert(allCandies, obj)
                        end
                    end
                end
                
                for _, candy in ipairs(allCandies) do
                    local count = 0
                    for _, other in ipairs(allCandies) do
                        if (candy.Position - other.Position).Magnitude <= 30 then
                            count = count + 1
                        end
                    end
                    if count > maxCandiesInCluster then
                        maxCandiesInCluster = count
                        bestCandyCenter = candy
                    end
                end
                
                if not bestCandyCenter and #allCandies > 0 then
                    local minDist = math.huge
                    for _, candy in ipairs(allCandies) do
                        local dist = (candy.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            bestCandyCenter = candy
                        end
                    end
                end
                
                if bestCandyCenter then
                    hrp.CFrame = CFrame.new(bestCandyCenter.Position + Vector3.new(0, 2.5, 0), hrp.Position + hrp.CFrame.LookVector)
                    task.wait(0.02)
                    continue
                end
            end
            
            -- AUTOMATIC DOOR
            if settings.autoDoor then
                local foundDoor = false
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "DOOR 1 NEW" and not openedDoors[obj] then
                        local promptList = {}
                        for _, p in pairs(obj:GetDescendants()) do
                            if p:IsA("ProximityPrompt") then
                                table.insert(promptList, p)
                            end
                        end
                        
                        if #promptList == 0 or not obj.Parent then
                            openedDoors[obj] = true
                        else
                            local targetPart = obj:FindFirstChild("Right Door") or obj:FindFirstChild("RightDoor") or obj:FindFirstChild("Left Door") or obj:FindFirstChildOfClass("BasePart")
                            if targetPart then
                                hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
                                for i = 1, 8 do
                                    pcall(function()
                                        for _, prompt in ipairs(promptList) do
                                            prompt.MaxActivationDistance = 999999
                                            prompt.HoldDuration = 0
                                            fireproximityprompt(prompt)
                                        end
                                    end)
                                    task.wait(0.01)
                                end
                                
                                local stillHasPrompt = false
                                for _, p in pairs(obj:GetDescendants()) do
                                    if p:IsA("ProximityPrompt") then
                                        stillHasPrompt = true
                                        break
                                    end
                                end
                                if not stillHasPrompt then openedDoors[obj] = true end
                                foundDoor = true
                                break
                            end
                        end
                    end
                end
                if foundDoor then continue end
            end
        end
    end
end)
