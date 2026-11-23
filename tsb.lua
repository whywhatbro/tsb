-- TSB CANDY BETA - Auto Hold 4.2s Candy Roll (500 Candy Only - Robux Protected)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("TSBCandyBetaGui") then
    playerGui.TSBCandyBetaGui:Destroy()
end

-- ==========================================
-- 1. CẤU HÌNH & TỰ ĐỘNG LƯU / TẢI SETTING
-- ==========================================
local CONFIG_FILE = "TSB_CandyBeta_Config.json"

local config = {
    autoCandy = false,
    autoDoor = false,
    autoBossCombat = false,
    autoFarmAll = false,
    espPumpkin = false,
    autoCandyRoll = false,
    skillOrder = {"1", "2", "3", "4"},
    actionQueue = {
        { id = "candy", label = "Nhặt kẹo", enabled = true },
        { id = "boss",  label = "Đánh Pumpkin", enabled = true },
        { id = "door",  label = "Gõ cửa nhà", enabled = true }
    }
}

local function saveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(config))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(decoded) == "table" then
                if type(decoded.autoCandy) == "boolean" then config.autoCandy = decoded.autoCandy end
                if type(decoded.autoDoor) == "boolean" then config.autoDoor = decoded.autoDoor end
                if type(decoded.autoBossCombat) == "boolean" then config.autoBossCombat = decoded.autoBossCombat end
                if type(decoded.autoFarmAll) == "boolean" then config.autoFarmAll = decoded.autoFarmAll end
                if type(decoded.espPumpkin) == "boolean" then config.espPumpkin = decoded.espPumpkin end
                if type(decoded.autoCandyRoll) == "boolean" then config.autoCandyRoll = decoded.autoCandyRoll end
                if type(decoded.skillOrder) == "table" and #decoded.skillOrder == 4 then
                    config.skillOrder = decoded.skillOrder
                end
                if type(decoded.actionQueue) == "table" and #decoded.actionQueue == 3 then
                    config.actionQueue = decoded.actionQueue
                end
            end
        end
    end)
end

loadConfig()

-- ==========================================
-- 2. GIAO DIỆN CHÍNH & THANH TRẠNG THÁI PUMPKIN
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSBCandyBetaGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(0, 110, 0, 22)
statusContainer.Position = UDim2.new(0.5, -55, 1, -145)
statusContainer.BackgroundTransparency = 1
statusContainer.Parent = screenGui

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(0, 0, 0.5, -4)
statusDot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
statusDot.Parent = statusContainer
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 150)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
toggleBtn.Text = "🍬"
toggleBtn.TextSize = 26
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 290, 0, 410)
mainFrame.Position = UDim2.new(0.5, -145, 0.5, -205)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
mainFrame.BackgroundTransparency = 0.08
mainFrame.Visible = true
mainFrame.ZIndex = 5
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "CANDY BETA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.SourceSansBold
title.ZIndex = 6
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local tabFarmBtn = Instance.new("TextButton")
tabFarmBtn.Size = UDim2.new(0.5, -12, 0, 28)
tabFarmBtn.Position = UDim2.new(0, 10, 0, 42)
tabFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
tabFarmBtn.Text = "FARM"
tabFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tabFarmBtn.TextSize = 11
tabFarmBtn.Font = Enum.Font.SourceSansBold
tabFarmBtn.ZIndex = 6
tabFarmBtn.Parent = mainFrame
Instance.new("UICorner", tabFarmBtn).CornerRadius = UDim.new(0, 6)

local tabActBtn = Instance.new("TextButton")
tabActBtn.Size = UDim2.new(0.5, -12, 0, 28)
tabActBtn.Position = UDim2.new(0.5, 2, 0, 42)
tabActBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
tabActBtn.Text = "ACT"
tabActBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
tabActBtn.TextSize = 11
tabActBtn.Font = Enum.Font.SourceSansBold
tabActBtn.ZIndex = 6
tabActBtn.Parent = mainFrame
Instance.new("UICorner", tabActBtn).CornerRadius = UDim.new(0, 6)

local farmContainer = Instance.new("Frame")
farmContainer.Size = UDim2.new(1, 0, 1, -76)
farmContainer.Position = UDim2.new(0, 0, 0, 76)
farmContainer.BackgroundTransparency = 1
farmContainer.Visible = true
farmContainer.ZIndex = 6
farmContainer.Parent = mainFrame

local actContainer = Instance.new("Frame")
actContainer.Size = UDim2.new(1, 0, 1, -76)
actContainer.Position = UDim2.new(0, 0, 0, 76)
actContainer.BackgroundTransparency = 1
actContainer.Visible = false
actContainer.ZIndex = 6
actContainer.Parent = mainFrame

local function switchTab(tabName)
    local isFarm = (tabName == "Farm")
    farmContainer.Visible = isFarm
    actContainer.Visible = not isFarm
    tabFarmBtn.BackgroundColor3 = isFarm and Color3.fromRGB(0, 140, 210) or Color3.fromRGB(55, 55, 55)
    tabActBtn.BackgroundColor3 = (not isFarm) and Color3.fromRGB(0, 140, 210) or Color3.fromRGB(55, 55, 55)
end

tabFarmBtn.MouseButton1Click:Connect(function() switchTab("Farm") end)
tabActBtn.MouseButton1Click:Connect(function() switchTab("Act") end)

local dragging, dragInput, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ==========================================
-- 3. NỘI DUNG TAB FARM
-- ==========================================
local function paintToggleBtn(btn, name, state)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 100, 100)
    btn.Text = name .. (state and ": [ON]" or ": [OFF]")
end

local function createFarmToggle(name, posY, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 31)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.ZIndex = 7
    btn.Parent = farmContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    paintToggleBtn(btn, name, config[key])

    btn.MouseButton1Click:Connect(function()
        config[key] = not config[key]
        paintToggleBtn(btn, name, config[key])
        saveConfig()
    end)
end

createFarmToggle("AUTO FARM ALL (ACT QUEUE)", 0, "autoFarmAll")
createFarmToggle("CANDY FARM", 35, "autoCandy")
createFarmToggle("AUTOMATIC DOOR", 70, "autoDoor")
createFarmToggle("AUTO ROLL CANDY (500)", 105, "autoCandyRoll")
createFarmToggle("PUMPKIN ESP", 140, "espPumpkin")

local teleBossBtn = Instance.new("TextButton")
teleBossBtn.Size = UDim2.new(1, -20, 0, 31)
teleBossBtn.Position = UDim2.new(0, 10, 0, 175)
teleBossBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
teleBossBtn.Text = "TELEPORT TO PUMPKIN"
teleBossBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleBossBtn.TextSize = 11
teleBossBtn.Font = Enum.Font.SourceSansBold
teleBossBtn.ZIndex = 7
teleBossBtn.Parent = farmContainer
Instance.new("UICorner", teleBossBtn).CornerRadius = UDim.new(0, 7)

createFarmToggle("AUTO PUMPKIN COMBAT", 210, "autoBossCombat")

local dropToggleBtn = Instance.new("TextButton")
dropToggleBtn.Size = UDim2.new(1, -20, 0, 28)
dropToggleBtn.Position = UDim2.new(0, 10, 0, 245)
dropToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropToggleBtn.Text = "▼ Select Combat Skills Order"
dropToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropToggleBtn.TextSize = 11
dropToggleBtn.Font = Enum.Font.SourceSansBold
dropToggleBtn.ZIndex = 7
dropToggleBtn.Parent = farmContainer
Instance.new("UICorner", dropToggleBtn).CornerRadius = UDim.new(0, 7)

local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Size = UDim2.new(1, -20, 0, 54)
dropdownFrame.Position = UDim2.new(0, 10, 0, 275)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
dropdownFrame.ScrollBarThickness = 4
dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 96)
dropdownFrame.Visible = false
dropdownFrame.ZIndex = 8
dropdownFrame.Parent = farmContainer
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 7)

local skillListOpen = false
dropToggleBtn.MouseButton1Click:Connect(function()
    skillListOpen = not skillListOpen
    dropdownFrame.Visible = skillListOpen
    dropToggleBtn.Text = (skillListOpen and "▲ " or "▼ ") .. "Select Combat Skills Order"
end)

local availableSkills = {"1", "2", "3", "4"}
for i = 1, 4 do
    local sBtn = Instance.new("TextButton")
    sBtn.Size = UDim2.new(1, -12, 0, 20)
    sBtn.Position = UDim2.new(0, 4, 0, 3 + (i - 1) * 23)
    sBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    sBtn.Text = "Skill Slot " .. i .. " : [" .. tostring(config.skillOrder[i]) .. "]"
    sBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sBtn.TextSize = 10
    sBtn.Font = Enum.Font.SourceSansBold
    sBtn.ZIndex = 9
    sBtn.Parent = dropdownFrame
    Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 4)

    sBtn.MouseButton1Click:Connect(function()
        for idx, val in ipairs(availableSkills) do
            if val == config.skillOrder[i] then
                config.skillOrder[i] = availableSkills[idx % #availableSkills + 1]
                break
            end
        end
        sBtn.Text = "Skill Slot " .. i .. " : [" .. tostring(config.skillOrder[i]) .. "]"
        saveConfig()
    end)
end

mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not mainFrame.Visible then
        skillListOpen = false
        dropdownFrame.Visible = false
        dropToggleBtn.Text = "▼ Select Combat Skills Order"
    end
end)

-- ==========================================
-- 4. NỘI DUNG TAB ACT (THỨ TỰ ƯU TIÊN & ON/OFF)
-- ==========================================
local actHint = Instance.new("TextLabel")
actHint.Size = UDim2.new(1, -20, 0, 24)
actHint.Position = UDim2.new(0, 10, 0, 0)
actHint.BackgroundTransparency = 1
actHint.Text = "Thứ tự ưu tiên (Làm xong mới sang bước sau):"
actHint.TextColor3 = Color3.fromRGB(210, 210, 210)
actHint.TextSize = 10
actHint.Font = Enum.Font.SourceSansBold
actHint.TextXAlignment = Enum.TextXAlignment.Left
actHint.ZIndex = 7
actHint.Parent = actContainer

local queueRows = {}
local refreshActUI

local function swapQueue(indexA, indexB)
    if indexA < 1 or indexB < 1 or indexA > #config.actionQueue or indexB > #config.actionQueue then
        return
    end
    local temp = config.actionQueue[indexA]
    config.actionQueue[indexA] = config.actionQueue[indexB]
    config.actionQueue[indexB] = temp
    saveConfig()
    refreshActUI()
end

for idx = 1, 3 do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 56)
    row.Position = UDim2.new(0, 10, 0, 28 + (idx - 1) * 64)
    row.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    row.ZIndex = 7
    row.Parent = actContainer
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -138, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 8
    lbl.Parent = row

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 28, 0, 34)
    upBtn.Position = UDim2.new(1, -126, 0.5, -17)
    upBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 95)
    upBtn.Text = "▲"
    upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    upBtn.TextSize = 11
    upBtn.Font = Enum.Font.SourceSansBold
    upBtn.ZIndex = 8
    upBtn.Parent = row
    Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 6)

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 28, 0, 34)
    downBtn.Position = UDim2.new(1, -94, 0.5, -17)
    downBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 95)
    downBtn.Text = "▼"
    downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    downBtn.TextSize = 11
    downBtn.Font = Enum.Font.SourceSansBold
    downBtn.ZIndex = 8
    downBtn.Parent = row
    Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 6)

    local stateBtn = Instance.new("TextButton")
    stateBtn.Size = UDim2.new(0, 52, 0, 34)
    stateBtn.Position = UDim2.new(1, -60, 0.5, -17)
    stateBtn.TextSize = 11
    stateBtn.Font = Enum.Font.SourceSansBold
    stateBtn.ZIndex = 8
    stateBtn.Parent = row
    Instance.new("UICorner", stateBtn).CornerRadius = UDim.new(0, 6)

    upBtn.MouseButton1Click:Connect(function() swapQueue(idx, idx - 1) end)
    downBtn.MouseButton1Click:Connect(function() swapQueue(idx, idx + 1) end)
    stateBtn.MouseButton1Click:Connect(function()
        config.actionQueue[idx].enabled = not config.actionQueue[idx].enabled
        saveConfig()
        refreshActUI()
    end)

    queueRows[idx] = { lbl = lbl, stateBtn = stateBtn }
end

refreshActUI = function()
    for idx = 1, 3 do
        local item = config.actionQueue[idx]
        local rowUI = queueRows[idx]
        rowUI.lbl.Text = string.format("%d. %s", idx, item.label)
        if item.enabled then
            rowUI.stateBtn.BackgroundColor3 = Color3.fromRGB(0, 175, 0)
            rowUI.stateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            rowUI.stateBtn.Text = "ON"
        else
            rowUI.stateBtn.BackgroundColor3 = Color3.fromRGB(190, 40, 40)
            rowUI.stateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            rowUI.stateBtn.Text = "OFF"
        end
    end
end

refreshActUI()

-- ==========================================
-- 5. NOCLIP, PUMPKIN ESP, HOLD-ROLL 500 CANDY & COMBAT
-- ==========================================
local validCandies = {
    ["DarkOrangeCandy1"] = true, ["DarkOrangeCandy2"] = true,
    ["DarkOrangeCandy3"] = true, ["DarkOrangeCandy4"] = true,
    ["OrangeCandy1"] = true, ["OrangeCandy2"] = true,
    ["OrangeCandy3"] = true, ["OrangeCandy4"] = true,
    ["MrBloxBar"] = true, ["BloxRoll"] = true,
    ["Chocoblox"] = true, ["BloxyDrops"] = true
}
local openedDoors = {}
local SAFE_SKY_CFRAME = CFrame.new(0, 950, 0)
local BEHIND_DISTANCE = 4.5
local SHOPKEEPER_FALLBACK_POS = Vector3.new(566.85, 445.70, -437.97)
local ROLL_HOLD_SECONDS = 4.2 -- Thời gian nhấn giữ 4.2 giây để roll bằng 500 kẹo

local isBossNoclipActive = false
local savedCollideStates = {}

local function setBossNoclip(enable)
    local char = player.Character
    if not char then return end

    if enable then
        if not isBossNoclipActive then
            savedCollideStates = {}
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    savedCollideStates[part] = part.CanCollide
                end
            end
            isBossNoclipActive = true
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    elseif isBossNoclipActive then
        for part, originalCollide in pairs(savedCollideStates) do
            if part and part.Parent then
                part.CanCollide = originalCollide
            end
        end
        savedCollideStates = {}
        isBossNoclipActive = false
    end
end

local function getBossTarget()
    local live = Workspace:FindFirstChild("Live")
    local penyta = live and live:FindFirstChild("Penyta")
    if penyta then
        local hrp = penyta:FindFirstChild("HumanoidRootPart")
        local hum = penyta:FindFirstChildOfClass("Humanoid")
        if hrp and hrp:IsA("BasePart") and (not hum or hum.Health > 0) then
            return penyta, hrp
        end
    end
    return nil, nil
end

local function clearPumpkinESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "TSB_PumpkinESP_Highlight" or obj.Name == "TSB_PumpkinESP_Billboard" then
            obj:Destroy()
        end
    end
end

local function updatePumpkinESP(bossModel, bossPart, playerHrp)
    if not config.espPumpkin or not bossModel or not bossPart then
        clearPumpkinESP()
        return
    end

    local hl = bossModel:FindFirstChild("TSB_PumpkinESP_Highlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "TSB_PumpkinESP_Highlight"
        hl.FillColor = Color3.fromRGB(0, 255, 80)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.55
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = bossModel
    end

    local bb = bossPart:FindFirstChild("TSB_PumpkinESP_Billboard")
    if not bb then
        bb = Instance.new("BillboardGui")
        bb.Name = "TSB_PumpkinESP_Billboard"
        bb.Size = UDim2.new(0, 140, 0, 32)
        bb.StudsOffset = Vector3.new(0, 4.2, 0)
        bb.AlwaysOnTop = true
        bb.Parent = bossPart

        local txt = Instance.new("TextLabel")
        txt.Name = "Label"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(0, 255, 80)
        txt.TextStrokeTransparency = 0.2
        txt.TextSize = 13
        txt.Font = Enum.Font.SourceSansBold
        txt.Parent = bb
    end

    local lbl = bb:FindFirstChild("Label")
    if lbl then
        local distText = ""
        if playerHrp then
            local studs = math.floor((bossPart.Position - playerHrp.Position).Magnitude)
            distText = string.format(" [%dm]", studs)
        end
        lbl.Text = "PUMPKIN" .. distText
    end
end

local function findBestCandy(hrp)
    local bestCandy = nil
    local bestScore = -math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and validCandies[obj.Name] and obj.Position.Y > -10 then
            local pos = obj.Position
            if not (pos.X > 500 and pos.X < 800 and pos.Z > -200 and pos.Z < 100) then
                local dist = (pos - hrp.Position).Magnitude
                local score = -dist
                if dist <= 35 then
                    score = score + 120
                end
                if score > bestScore then
                    bestScore = score
                    bestCandy = obj
                end
            end
        end
    end

    return bestCandy
end

local function findNextDoor()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "DOOR 1 NEW" and not openedDoors[obj] then
            local promptList = {}
            for _, p in ipairs(obj:GetDescendants()) do
                if p:IsA("ProximityPrompt") then
                    table.insert(promptList, p)
                end
            end
            if #promptList == 0 or not obj.Parent then
                openedDoors[obj] = true
            else
                local targetPart = obj:FindFirstChild("Right Door") or obj:FindFirstChild("RightDoor") or obj:FindFirstChild("Left Door") or obj:FindFirstChildOfClass("BasePart")
                if targetPart then
                    return obj, targetPart, promptList
                end
            end
        end
    end
    return nil, nil, nil
end

local function fireGuiButton(guiObj)
    if firesignal then
        pcall(function() firesignal(guiObj.TouchTap) end)
        pcall(function() firesignal(guiObj.MouseButton1Down) end)
        pcall(function() firesignal(guiObj.Activated) end)
        pcall(function() firesignal(guiObj.MouseButton1Click) end)
        pcall(function() firesignal(guiObj.MouseButton1Up) end)
    else
        local pos, size = guiObj.AbsolutePosition, guiObj.AbsoluteSize
        local cx, cy = pos.X + size.X / 2, pos.Y + size.Y / 2
        VirtualInputManager:SendTouchEvent(1, 0, cx, cy)
        task.wait(0.005)
        VirtualInputManager:SendTouchEvent(1, 2, cx, cy)
    end
end

-- Hàm nhấn giữ nút UI trên màn hình Mobile trong khoảng thời gian duration (4.2 giây)
local function holdGuiButton(guiObj, duration)
    local pos, size = guiObj.AbsolutePosition, guiObj.AbsoluteSize
    local cx, cy = pos.X + size.X / 2, pos.Y + size.Y / 2

    -- Bắt đầu giữ phím/cảm ứng
    if firesignal then
        pcall(function() firesignal(guiObj.MouseButton1Down) end)
    end
    pcall(function()
        VirtualInputManager:SendTouchEvent(2, 0, cx, cy)
    end)

    local elapsed = 0
    while elapsed < duration and config.autoCandyRoll and guiObj and guiObj.Parent and guiObj.Visible do
        task.wait(0.1)
        elapsed = elapsed + 0.1
    end

    -- Nhả phím/cảm ứng sau khi giữ đủ 4.2 giây
    if firesignal then
        pcall(function() firesignal(guiObj.MouseButton1Up) end)
        pcall(function() firesignal(guiObj.Activated) end)
        pcall(function() firesignal(guiObj.MouseButton1Click) end)
    end
    pcall(function()
        VirtualInputManager:SendTouchEvent(2, 2, cx, cy)
    end)
end

local function triggerMobileM1()
    pcall(function()
        for _, guiObj in ipairs(playerGui:GetDescendants()) do
            if guiObj:IsA("GuiButton") and guiObj.Visible and not guiObj:IsDescendantOf(screenGui) then
                local gName = string.lower(guiObj.Name)
                local pName = guiObj.Parent and string.lower(guiObj.Parent.Name) or ""
                if gName == "punch" or gName == "m1" or gName == "attack" or pName == "punch" or gName:find("punch") then
                    fireGuiButton(guiObj)
                    return
                end
            end
        end
    end)
end

local function triggerMobileSkill(slotStr)
    pcall(function()
        local hotbar = playerGui:FindFirstChild("Hotbar")
        local backpack = hotbar and hotbar:FindFirstChild("Backpack")
        local innerHotbar = backpack and backpack:FindFirstChild("Hotbar")
        local slotFrame = innerHotbar and innerHotbar:FindFirstChild(slotStr)
        if slotFrame then
            local btn = slotFrame:FindFirstChild("Base") or slotFrame:FindFirstChildOfClass("ImageButton") or slotFrame:FindFirstChildOfClass("TextButton")
            if btn and btn:IsA("GuiButton") then
                fireGuiButton(btn)
                return
            end
        end

        local screenHeight = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize.Y or 800
        for _, guiObj in ipairs(playerGui:GetDescendants()) do
            if guiObj:IsA("GuiButton") and guiObj.Visible and not guiObj:IsDescendantOf(screenGui) and guiObj.AbsolutePosition.Y > (screenHeight * 0.6) then
                local gName = guiObj.Name
                local pName = guiObj.Parent and guiObj.Parent.Name or ""
                if gName == slotStr or pName == slotStr or (gName == "Base" and pName == slotStr) then
                    fireGuiButton(guiObj)
                    return
                end
            end
        end
    end)
end

-- Tìm nút chọn Roll dòng 1 (500 kẹo), bỏ qua tuyệt đối dòng 2 (Robux)
local function findCandy500Button()
    local candidates = {}

    for _, guiObj in ipairs(playerGui:GetDescendants()) do
        if guiObj:IsA("GuiButton") and guiObj.Visible and not guiObj:IsDescendantOf(screenGui) then
            local combinedText = string.lower(guiObj.Name)
            if guiObj:IsA("TextButton") then
                combinedText = combinedText .. " " .. string.lower(guiObj.Text)
            end
            for _, child in ipairs(guiObj:GetDescendants()) do
                if child:IsA("TextLabel") then
                    combinedText = combinedText .. " " .. string.lower(child.Text)
                end
            end

            local isRobuxBtn = combinedText:find("robux") or combinedText:find("r%$") or combinedText:find("99")
            if not isRobuxBtn then
                if combinedText:find("500") or combinedText:find("candy") then
                    table.insert(candidates, guiObj)
                end
            end
        end
    end

    -- Nếu tìm thấy nhiều nút hợp lệ, ưu tiên nút nằm cao hơn trên màn hình (Dòng 1: 500 kẹo)
    if #candidates > 0 then
        table.sort(candidates, function(a, b)
            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
        end)
        return candidates[1]
    end

    return nil
end

local isHoldingRoll = false
local function runAutoCandyRoll(hrp)
    setBossNoclip(false)

    -- 1. Dịch chuyển tới vị trí Shopkeeper trong Workspace.Cart
    local cart = Workspace:FindFirstChild("Cart")
    local shopkeeper = cart and cart:FindFirstChild("Shopkeeper")
    local skRoot = shopkeeper and shopkeeper:FindFirstChild("HumanoidRootPart")
    local targetPos = skRoot and skRoot.Position or SHOPKEEPER_FALLBACK_POS

    if (hrp.Position - targetPos).Magnitude > 6 then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 0, 3.5), targetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end

    -- 2. Kích hoạt ProximityPrompt nếu có trong Workspace.Cart
    if cart then
        pcall(function()
            for _, desc in ipairs(cart:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    desc.MaxActivationDistance = 999999
                    desc.HoldDuration = 0
                    fireproximityprompt(desc)
                end
            end
        end)
    end

    -- 3. Tìm dòng 1 (500 kẹo) và nhấn giữ trong 4.2 giây
    if not isHoldingRoll then
        local candyBtn = findCandy500Button()
        if candyBtn then
            isHoldingRoll = true
            task.spawn(function()
                holdGuiButton(candyBtn, ROLL_HOLD_SECONDS)
                task.wait(0.3)
                isHoldingRoll = false
            end)
        end
    end
end

local function getBehindBossCFrame(bossPart)
    local bossCF = bossPart.CFrame
    local behindPos = (bossCF * CFrame.new(0, 0, BEHIND_DISTANCE)).Position
    return CFrame.lookAt(behindPos, bossPart.Position)
end

teleBossBtn.MouseButton1Click:Connect(function()
    local _, bossPart = getBossTarget()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and bossPart then
        char.HumanoidRootPart.CFrame = getBehindBossCFrame(bossPart)
    end
end)

RunService.Stepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
    end

    local bossModel, bossPart = getBossTarget()
    statusDot.BackgroundColor3 = (bossModel and bossPart) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(120, 120, 120)
    updatePumpkinESP(bossModel, bossPart, hrp)
end)

local skillCycleIndex = 1
local skillSpamTick = 0

local function runBossAction(hrp)
    local bossModel, bossPart = getBossTarget()
    if bossModel and bossPart then
        setBossNoclip(true)

        hrp.CFrame = getBehindBossCFrame(bossPart)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        triggerMobileM1()

        skillSpamTick = skillSpamTick + 1
        if skillSpamTick >= 4 then
            skillSpamTick = 0
            local slotToUse = config.skillOrder[skillCycleIndex]
            triggerMobileSkill(slotToUse)
            skillCycleIndex = (skillCycleIndex % #config.skillOrder) + 1
        end

        return true
    end

    setBossNoclip(false)
    return false
end

local function runCandyAction(hrp)
    setBossNoclip(false)
    local bestCandy = findBestCandy(hrp)
    if bestCandy then
        hrp.CFrame = CFrame.new(bestCandy.Position + Vector3.new(0, 1.5, 0), bestCandy.Position + Vector3.new(0, 1.5, 0) + hrp.CFrame.LookVector)
        hrp.AssemblyLinearVelocity = Vector3.zero
        return true
    end
    return false
end

local function runDoorAction(hrp)
    setBossNoclip(false)
    local doorObj, targetPart, promptList = findNextDoor()
    if doorObj and targetPart then
        hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
        for _ = 1, 8 do
            pcall(function()
                for _, prompt in ipairs(promptList) do
                    prompt.MaxActivationDistance = 999999
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                end
            end)
            task.wait(0.005)
        end

        local stillHasPrompt = false
        for _, p in ipairs(doorObj:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                stillHasPrompt = true
                break
            end
        end
        if not stillHasPrompt then
            openedDoors[doorObj] = true
        end
        return true
    end
    return false
end

local function executeActionById(id, hrp)
    if id == "boss" then
        return runBossAction(hrp)
    elseif id == "candy" then
        return runCandyAction(hrp)
    elseif id == "door" then
        return runDoorAction(hrp)
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(0.015)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if config.autoCandyRoll then
                runAutoCandyRoll(hrp)
                continue
            end

            if config.autoFarmAll then
                local didWork = false
                for _, item in ipairs(config.actionQueue) do
                    if item.enabled then
                        if executeActionById(item.id, hrp) then
                            didWork = true
                            break
                        end
                    end
                end
                if not didWork then
                    setBossNoclip(false)
                    hrp.CFrame = SAFE_SKY_CFRAME
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
                continue
            end

            local handled = false
            if config.autoBossCombat then
                handled = runBossAction(hrp)
            end
            if not handled and config.autoCandy then
                handled = runCandyAction(hrp)
            end
            if not handled and config.autoDoor then
                handled = runDoorAction(hrp)
            end
            if not handled then
                setBossNoclip(false)
            end
        else
            setBossNoclip(false)
        end
    end
end)
