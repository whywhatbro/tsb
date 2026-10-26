-- Advanced Mobile Menu v23 (TSB Ultimate: Fixed Camera/Lighting, Fixed Movement/Jump, Persistent Target UI & Fling Exploit)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

if CoreGui:FindFirstChild("AdvancedMobileMenuV23") then
    CoreGui.AdvancedMobileMenuV23:Destroy()
end

-- Trạng thái tổng hợp
local isEnabled = false
local currentMode = 3
local targetPlayer = nil
local isFollowing = false
local distanceOffset = 4
local followPositionMode = "Behind"

local antiVoidEnabled = true
local voidExecuterEnabled = true
local invisibilityEnabled = false
local respawnAtDeathEnabled = false
local espEnabled = false
local wallhackEnabled = false
local uiLocked = false

local customWalkSpeed = 16
local customJumpPower = 50
local infiniteJumpEnabled = false

local deathPosition = nil
local tsbMountainWaypoint = CFrame.new(610, 677, 362)

local autoSkills = {
    {key = "One", name = "Skill 1 (1)", enabled = false, isGrab = true},
    {key = "Two", name = "Skill 2 (2)", enabled = false, isGrab = true},
    {key = "Three", name = "Skill 3 (3)", enabled = false, isGrab = false},
    {key = "Four", name = "Skill 4 (4)", enabled = false, isGrab = false},
    {key = "Q", name = "Skill Q", enabled = false, isGrab = false},
    {key = "E", name = "Skill E", enabled = false, isGrab = false},
    {key = "R", name = "Skill R", enabled = false, isGrab = false},
    {key = "F", name = "Skill F", enabled = false, isGrab = false},
}

-- Tàng hình thật sự
local function setTrueInvisibility(state)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = state and 1 or 0
        elseif part:IsA("Decal") or part:IsA("Accessory") or part:IsA("Clothing") then
            if part:IsA("Decal") then
                part.Transparency = state and 1 or 0
            else
                for _, subPart in ipairs(part:GetDescendants()) do
                    if subPart:IsA("BasePart") then subPart.Transparency = state and 1 or 0 end
                end
            end
        end
    end
end

-- Aim & Void Executer
local function aimAndPressKey(skillObj, targetChar)
    local keyCode = Enum.KeyCode[skillObj.key]
    if keyCode and targetChar and targetChar:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        
        local predictedPos = targetHRP.Position + (targetHRP.Velocity * 0.1)
        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(predictedPos.X, hrp.Position.Y, predictedPos.Z))
        camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        
        if voidExecuterEnabled and skillObj.isGrab then
            pcall(function() targetHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -2) end)
            task.wait(0.05)
        end
        
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.08)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)

        if voidExecuterEnabled and skillObj.isGrab and targetHRP then
            task.spawn(function()
                for i = 1, 15 do
                    if targetHRP and targetHRP.Parent then
                        targetHRP.CFrame = CFrame.new(0, -50000, 0)
                        targetHRP.Velocity = Vector3.new(0, -1000, 0)
                    end
                    task.wait(0.04)
                end
            end)
        end
    end
end

-- Tạo ScreenGui chính
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSB"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Nút Menu Tròn
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Name = "ToggleBtn"
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Text = "Menu"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Nút Reset Nổi
local resetBtn = Instance.new("TextButton", screenGui)
resetBtn.Name = "ResetBtn"
resetBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
resetBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
resetBtn.Size = UDim2.new(0, 45, 0, 45)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 12
resetBtn.Text = "Reset"
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(1, 0)

resetBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            deathPosition = player.Character.HumanoidRootPart.CFrame
        end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end)
end)

-- Nút Bay Lên Núi
local flyMountainBtn = Instance.new("TextButton", screenGui)
flyMountainBtn.Name = "FlyMountainBtn"
flyMountainBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
flyMountainBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
flyMountainBtn.Size = UDim2.new(0, 50, 0, 50)
flyMountainBtn.Font = Enum.Font.SourceSansBold
flyMountainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyMountainBtn.TextSize = 11
flyMountainBtn.Text = "Bay Núi"
Instance.new("UICorner", flyMountainBtn).CornerRadius = UDim.new(1, 0)

flyMountainBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local startPos = hrp.Position
        local targetPos = tsbMountainWaypoint.Position
        
        local steps = 15
        for i = 1, steps do
            hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, i / steps))
            hrp.Velocity = Vector3.new(0, 0, 0)
            task.wait(0.01)
        end
        hrp.CFrame = tsbMountainWaypoint
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            task.wait(0.5)
            hum.WalkSpeed = customWalkSpeed
            hum.JumpPower = customJumpPower
        end
    end
end)

local function makeDraggable(guiObject)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if uiLocked then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if uiLocked then return end
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(toggleBtn)
makeDraggable(resetBtn)
makeDraggable(flyMountainBtn)

-- Khung Menu Chính Ngang
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Position = UDim2.new(0.12, 0, 0.15, 0)
mainFrame.Size = UDim2.new(0, 560, 0, 350)
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
makeDraggable(mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 12
title.Text = "  ☰ TSB MOBILE MENU v23 (Fixed Lighting, Movement & Fling Target UI)"
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- THANH TAB (6 Tabs)
local tabButtonsFrame = Instance.new("Frame", mainFrame)
tabButtonsFrame.BackgroundTransparency = 1
tabButtonsFrame.Position = UDim2.new(0, 10, 0, 35)
tabButtonsFrame.Size = UDim2.new(1, -20, 0, 30)

local tabs = {"1. Combat", "2. Hồi sinh", "3. Movement", "4. Dịch chuyển", "5. Visual & ESP", "6. Cài đặt"}
local tabContentFrames = {}

for i, tabName in ipairs(tabs) do
    local tBtn = Instance.new("TextButton", tabButtonsFrame)
    tBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 60, 120) or Color3.fromRGB(40, 40, 40)
    tBtn.Size = UDim2.new(0.16, 0, 1, 0)
    tBtn.Position = UDim2.new((i-1)*0.168, 0, 0, 0)
    tBtn.Font = Enum.Font.SourceSansBold
    tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tBtn.TextSize = 10
    tBtn.Text = tabName
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

    local cFrame = Instance.new("ScrollingFrame", mainFrame)
    cFrame.BackgroundTransparency = 1
    cFrame.Position = UDim2.new(0, 10, 0, 72)
    cFrame.Size = UDim2.new(1, -20, 1, -80)
    cFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
    cFrame.ScrollBarThickness = 3
    cFrame.Visible = (i == 1)
    table.insert(tabContentFrames, cFrame)

    tBtn.MouseButton1Click:Connect(function()
        for idx, frm in ipairs(tabContentFrames) do
            frm.Visible = (idx == i)
            local btnObj = tabButtonsFrame:GetChildren()[idx]
            if btnObj and btnObj:IsA("TextButton") then
                btnObj.BackgroundColor3 = (idx == i) and Color3.fromRGB(60, 60, 120) or Color3.fromRGB(40, 40, 40)
            end
        end
    end)
end

-- ================= TAB 1: COMBAT =================
local tab1 = tabContentFrames[1]
local l1 = Instance.new("UIListLayout", tab1) l1.Padding = UDim.new(0, 5)

local powerBtn = Instance.new("TextButton", tab1)
powerBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
powerBtn.Size = UDim2.new(1, -5, 0, 26)
powerBtn.Font = Enum.Font.SourceSansBold
powerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
powerBtn.TextSize = 12
powerBtn.Text = "Bám đuổi: OFF"
Instance.new("UICorner", powerBtn).CornerRadius = UDim.new(0, 4)

powerBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    powerBtn.Text = isEnabled and "Bám đuổi: ON" or "Bám đuổi: OFF"
    powerBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    isFollowing = isEnabled
end)

local posModeBtn = Instance.new("TextButton", tab1)
posModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
posModeBtn.Size = UDim2.new(1, -5, 0, 26)
posModeBtn.Font = Enum.Font.SourceSansBold
posModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
posModeBtn.TextSize = 12
posModeBtn.Text = "Vị trí bám: Sau lưng (Behind)"
Instance.new("UICorner", posModeBtn).CornerRadius = UDim.new(0, 4)

posModeBtn.MouseButton1Click:Connect(function()
    if followPositionMode == "Behind" then
        followPositionMode = "Feet"
        posModeBtn.Text = "Vị trí bám: Dưới chân (Ngửa mặt)"
        posModeBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
    else
        followPositionMode = "Behind"
        posModeBtn.Text = "Vị trí bám: Sau lưng (Behind)"
        posModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
    end
end)

local distRow = Instance.new("Frame", tab1)
distRow.BackgroundTransparency = 1
distRow.Size = UDim2.new(1, -5, 0, 26)

local distLabel = Instance.new("TextLabel", distRow)
distLabel.BackgroundTransparency = 1
distLabel.Size = UDim2.new(0.5, 0, 1, 0)
distLabel.Font = Enum.Font.SourceSans
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 11
distLabel.Text = "Khoảng cách: 4"

local minusDist = Instance.new("TextButton", distRow)
minusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minusDist.Position = UDim2.new(0.52, 0, 0, 0)
minusDist.Size = UDim2.new(0.22, 0, 1, 0)
minusDist.Text = "-"
minusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", minusDist).CornerRadius = UDim.new(0, 4)

local plusDist = Instance.new("TextButton", distRow)
plusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
plusDist.Position = UDim2.new(0.76, 0, 0, 0)
plusDist.Size = UDim2.new(0.22, 0, 1, 0)
plusDist.Text = "+"
plusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", plusDist).CornerRadius = UDim.new(0, 4)

minusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset - 1, 1, 15)
    distLabel.Text = "Khoảng cách: " .. distanceOffset
end)
plusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset + 1, 1, 15)
    distLabel.Text = "Khoảng cách: " .. distanceOffset
end)

local modeBtn = Instance.new("TextButton", tab1)
modeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeBtn.Size = UDim2.new(1, -5, 0, 26)
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
modeBtn.TextSize = 11
modeBtn.Text = "Chế độ: 3 (Random)"
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 4)

modeBtn.MouseButton1Click:Connect(function()
    currentMode = currentMode + 1
    if currentMode > 4 then currentMode = 1 end
    if currentMode == 1 then modeBtn.Text = "Chế độ: 1 (Click vào nhân vật)"
    elseif currentMode == 2 then modeBtn.Text = "Chế độ: 2 (Textbox nhập tên)"
    elseif currentMode == 3 then modeBtn.Text = "Chế độ: 3 (Random)"
    elseif currentMode == 4 then modeBtn.Text = "Chế độ: 4 (Ít máu nhất)" end
end)

local nameBox = Instance.new("TextBox", tab1)
nameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
nameBox.Size = UDim2.new(1, -5, 0, 26)
nameBox.Font = Enum.Font.SourceSans
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderText = "Nhập tên địch (Chế độ 2)..."
nameBox.Text = ""
nameBox.TextSize = 11
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 4)

local autoM1Btn = Instance.new("TextButton", tab1)
autoM1Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
autoM1Btn.Size = UDim2.new(1, -5, 0, 26)
autoM1Btn.Font = Enum.Font.SourceSansBold
autoM1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoM1Btn.TextSize = 11
autoM1Btn.Text = "Auto M1: OFF"
Instance.new("UICorner", autoM1Btn).CornerRadius = UDim.new(0, 4)

local autoM1Enabled = false
autoM1Btn.MouseButton1Click:Connect(function()
    autoM1Enabled = not autoM1Enabled
    autoM1Btn.Text = autoM1Enabled and "Auto M1: ON" or "Auto M1: OFF"
    autoM1Btn.BackgroundColor3 = autoM1Enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

for _, skill in ipairs(autoSkills) do
    local sBtn = Instance.new("TextButton", tab1)
    sBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    sBtn.Size = UDim2.new(1, -5, 0, 24)
    sBtn.Font = Enum.Font.SourceSansBold
    sBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sBtn.TextSize = 11
    sBtn.Text = skill.name .. (skill.isGrab and " [Tóm]" or "") .. ": OFF"
    Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 3)
    
    sBtn.MouseButton1Click:Connect(function()
        skill.enabled = not skill.enabled
        sBtn.Text = skill.name .. (skill.isGrab and " [Tóm]" or "") .. (skill.enabled and ": ON" or ": OFF")
        sBtn.BackgroundColor3 = skill.enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    end)
end

-- ================= TAB 2: HỒI SINH =================
local tab2 = tabContentFrames[2]
local l2 = Instance.new("UIListLayout", tab2) l2.Padding = UDim.new(0, 8)

local respawnBtn = Instance.new("TextButton", tab2)
respawnBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
respawnBtn.Size = UDim2.new(1, -5, 0, 35)
respawnBtn.Font = Enum.Font.SourceSansBold
respawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
respawnBtn.TextSize = 13
respawnBtn.Text = "Hồi sinh tại chỗ kèm Animation: OFF"
Instance.new("UICorner", respawnBtn).CornerRadius = UDim.new(0, 6)

respawnBtn.MouseButton1Click:Connect(function()
    respawnAtDeathEnabled = not respawnAtDeathEnabled
    respawnBtn.Text = respawnAtDeathEnabled and "Hồi sinh tại chỗ kèm Animation: ON" or "Hồi sinh tại chỗ kèm Animation: OFF"
    respawnBtn.BackgroundColor3 = respawnAtDeathEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

-- ================= TAB 3: MOVEMENT =================
local tab3 = tabContentFrames[3]
local l3 = Instance.new("UIListLayout", tab3) l3.Padding = UDim.new(0, 8)

-- Tốc độ chạy (Fix triệt để cho TSB bằng cách bám theo RenderStepped)
local speedRow = Instance.new("Frame", tab3)
speedRow.BackgroundTransparency = 1
speedRow.Size = UDim2.new(1, -5, 0, 30)
local speedLbl = Instance.new("TextLabel", speedRow)
speedLbl.BackgroundTransparency = 1
speedLbl.Size = UDim2.new(0.6, 0, 1, 0)
speedLbl.Font = Enum.Font.SourceSansBold
speedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLbl.TextSize = 12
speedLbl.Text = "Tốc độ chạy: 16"

local speedPlus = Instance.new("TextButton", speedRow)
speedPlus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedPlus.Position = UDim2.new(0.8, 0, 0, 0)
speedPlus.Size = UDim2.new(0.18, 0, 1, 0)
speedPlus.Text = "+"
speedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", speedPlus).CornerRadius = UDim.new(0, 4)

local speedMin = Instance.new("TextButton", speedRow)
speedMin.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedMin.Position = UDim2.new(0.61, 0, 0, 0)
speedMin.Size = UDim2.new(0.18, 0, 1, 0)
speedMin.Text = "-"
speedMin.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", speedMin).CornerRadius = UDim.new(0, 4)

speedPlus.MouseButton1Click:Connect(function()
    customWalkSpeed = math.clamp(customWalkSpeed + 4, 16, 120)
    speedLbl.Text = "Tốc độ chạy: " .. customWalkSpeed
end)
speedMin.MouseButton1Click:Connect(function()
    customWalkSpeed = math.clamp(customWalkSpeed - 4, 16, 120)
    speedLbl.Text = "Tốc độ chạy: " .. customWalkSpeed
end)

-- Nhảy cao (Sử dụng JumpPower kết hợp Impulse)
local jumpRow = Instance.new("Frame", tab3)
jumpRow.BackgroundTransparency = 1
jumpRow.Size = UDim2.new(1, -5, 0, 30)
local jumpLbl = Instance.new("TextLabel", jumpRow)
jumpLbl.BackgroundTransparency = 1
jumpLbl.Size = UDim2.new(0.6, 0, 1, 0)
jumpLbl.Font = Enum.Font.SourceSansBold
jumpLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpLbl.TextSize = 12
jumpLbl.Text = "Độ cao nhảy: 50"

local jumpPlus = Instance.new("TextButton", jumpRow)
jumpPlus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
jumpPlus.Position = UDim2.new(0.8, 0, 0, 0)
jumpPlus.Size = UDim2.new(0.18, 0, 1, 0)
jumpPlus.Text = "+"
jumpPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", jumpPlus).CornerRadius = UDim.new(0, 4)

local jumpMin = Instance.new("TextButton", jumpRow)
jumpMin.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
jumpMin.Position = UDim2.new(0.61, 0, 0, 0)
jumpMin.Size = UDim2.new(0.18, 0, 1, 0)
jumpMin.Text = "-"
jumpMin.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", jumpMin).CornerRadius = UDim.new(0, 4)

jumpPlus.MouseButton1Click:Connect(function()
    customJumpPower = math.clamp(customJumpPower + 15, 50, 350)
    jumpLbl.Text = "Độ cao nhảy: " .. customJumpPower
end)
jumpMin.MouseButton1Click:Connect(function()
    customJumpPower = math.clamp(customJumpPower - 15, 50, 350)
    jumpLbl.Text = "Độ cao nhảy: " .. customJumpPower
end)

local infJumpBtn = Instance.new("TextButton", tab3)
infJumpBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
infJumpBtn.Size = UDim2.new(1, -5, 0, 32)
infJumpBtn.Font = Enum.Font.SourceSansBold
infJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpBtn.TextSize = 12
infJumpBtn.Text = "Nhảy vô hạn trên không (Inf Jump): OFF"
Instance.new("UICorner", infJumpBtn).CornerRadius = UDim.new(0, 4)

infJumpBtn.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    infJumpBtn.Text = infiniteJumpEnabled and "Nhảy vô hạn trên không (Inf Jump): ON" or "Nhảy vô hạn trên không (Inf Jump): OFF"
    infJumpBtn.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ================= TAB 4: DỊCH CHUYỂN =================
local tab4 = tabContentFrames[4]
local l4 = Instance.new("UIListLayout", tab4) l4.Padding = UDim.new(0, 8)

local tpMountainBtn = Instance.new("TextButton", tab4)
tpMountainBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
tpMountainBtn.Size = UDim2.new(1, -5, 0, 35)
tpMountainBtn.Font = Enum.Font.SourceSansBold
tpMountainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpMountainBtn.TextSize = 12
tpMountainBtn.Text = "Bay lên Ngọn núi TSB ngay lập tức"
Instance.new("UICorner", tpMountainBtn).CornerRadius = UDim.new(0, 6)

tpMountainBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = tsbMountainWaypoint
    end
end)

-- ================= TAB 5: VISUAL & ESP =================
local tab5 = tabContentFrames[5]
local l5 = Instance.new("UIListLayout", tab5) l5.Padding = UDim.new(0, 8)

local espBtn = Instance.new("TextButton", tab5)
espBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
espBtn.Size = UDim2.new(1, -5, 0, 32)
espBtn.Font = Enum.Font.SourceSansBold
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 12
espBtn.Text = "ESP Toàn bộ người chơi: OFF"
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 4)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP Toàn bộ người chơi: ON" or "ESP Toàn bộ người chơi: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

-- Xray Camera Thông Minh (Fix lỗi tối om màn hình, chỉ làm mờ vật thể che khuất và vô hiệu hóa va chạm camera)
local smartCameraBtn = Instance.new("TextButton", tab5)
smartCameraBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
smartCameraBtn.Size = UDim2.new(1, -5, 0, 32)
smartCameraBtn.Font = Enum.Font.SourceSansBold
smartCameraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
smartCameraBtn.TextSize = 12
smartCameraBtn.Text = "Xray vật thể che khuất camera: OFF"
Instance.new("UICorner", smartCameraBtn).CornerRadius = UDim.new(0, 4)

smartCameraBtn.MouseButton1Click:Connect(function()
    wallhackEnabled = not wallhackEnabled
    smartCameraBtn.Text = wallhackEnabled and "Xray vật thể che khuất camera: ON" or "Xray vật thể che khuất camera: OFF"
    smartCameraBtn.BackgroundColor3 = wallhackEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    
    if wallhackEnabled then
        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 400
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Transparency == 0.8 then
                obj.Transparency = 0
            end
        end
    end
end)

-- ================= TAB 6: CÀI ĐẶT =================
local tab6 = tabContentFrames[6]
local l6 = Instance.new("UIListLayout", tab6) l6.Padding = UDim.new(0, 8)

local invisBtn = Instance.new("TextButton", tab6)
invisBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
invisBtn.Size = UDim2.new(1, -5, 0, 32)
invisBtn.Font = Enum.Font.SourceSansBold
invisBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
invisBtn.TextSize = 12
invisBtn.Text = "Tàng hình (True Invis): OFF"
Instance.new("UICorner", invisBtn).CornerRadius = UDim.new(0, 4)

invisBtn.MouseButton1Click:Connect(function()
    invisibilityEnabled = not invisibilityEnabled
    invisBtn.Text = invisibilityEnabled and "Tàng hình (True Invis): ON" or "Tàng hình (True Invis): OFF"
    invisBtn.BackgroundColor3 = invisibilityEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    setTrueInvisibility(invisibilityEnabled)
end)

local antiVoidBtn = Instance.new("TextButton", tab6)
antiVoidBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
antiVoidBtn.Size = UDim2.new(1, -5, 0, 32)
antiVoidBtn.Font = Enum.Font.SourceSansBold
antiVoidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiVoidBtn.TextSize = 12
antiVoidBtn.Text = "Anti-Void: ON"
Instance.new("UICorner", antiVoidBtn).CornerRadius = UDim.new(0, 4)

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    antiVoidBtn.Text = antiVoidEnabled and "Anti-Void: ON" or "Anti-Void: OFF"
    antiVoidBtn.BackgroundColor3 = antiVoidEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

local voidExecBtn = Instance.new("TextButton", tab6)
voidExecBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
voidExecBtn.Size = UDim2.new(1, -5, 0, 32)
voidExecBtn.Font = Enum.Font.SourceSansBold
voidExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
voidExecBtn.TextSize = 12
voidExecBtn.Text = "Void Executer (Chiêu tóm): ON"
Instance.new("UICorner", voidExecBtn).CornerRadius = UDim.new(0, 4)

voidExecBtn.MouseButton1Click:Connect(function()
    voidExecuterEnabled = not voidExecuterEnabled
    voidExecBtn.Text = voidExecuterEnabled and "Void Executer (Chiêu tóm): ON" or "Void Executer (Chiêu tóm): OFF"
    voidExecBtn.BackgroundColor3 = voidExecuterEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

local lockUiBtn = Instance.new("TextButton", tab6)
lockUiBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
lockUiBtn.Size = UDim2.new(1, -5, 0, 32)
lockUiBtn.Font = Enum.Font.SourceSansBold
lockUiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lockUiBtn.TextSize = 12
lockUiBtn.Text = "Khóa di chuyển nút nổi (Lock UI): OFF"
Instance.new("UICorner", lockUiBtn).CornerRadius = UDim.new(0, 4)

lockUiBtn.MouseButton1Click:Connect(function()
    uiLocked = not uiLocked
    lockUiBtn.Text = uiLocked and "Khóa di chuyển nút nổi (Lock UI): ON" or "Khóa di chuyển nút nổi (Lock UI): OFF"
    lockUiBtn.BackgroundColor3 = uiLocked and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

-- ================= HỆ THỐNG BẢNG CỐ ĐỊNH CHỌN MỤC TIÊU & FLING =================
local clickPopup = Instance.new("Frame", screenGui)
clickPopup.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
clickPopup.Position = UDim2.new(0.5, -110, 0.05, 0)
clickPopup.Size = UDim2.new(0, 220, 0, 160)
clickPopup.Visible = false
Instance.new("UICorner", clickPopup).CornerRadius = UDim.new(0, 8)

local popupTitle = Instance.new("TextLabel", clickPopup)
popupTitle.BackgroundTransparency = 1
popupTitle.Size = UDim2.new(1, 0, 0, 30)
popupTitle.Font = Enum.Font.SourceSansBold
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.TextSize = 13
popupTitle.Text = "Đang chọn: [Chưa chọn]"

-- Nút Bay ra sau
local btnBehind = Instance.new("TextButton", clickPopup)
btnBehind.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
btnBehind.Position = UDim2.new(0, 10, 0, 35)
btnBehind.Size = UDim2.new(1, -20, 0, 26)
btnBehind.Font = Enum.Font.SourceSansBold
btnBehind.TextColor3 = Color3.fromRGB(255, 255, 255)
btnBehind.TextSize = 11
btnBehind.Text = "Bay bám đuổi (Sau lưng)"
Instance.new("UICorner", btnBehind).CornerRadius = UDim.new(0, 4)

-- Nút Bay dưới chân
local btnFeet = Instance.new("TextButton", clickPopup)
btnFeet.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
btnFeet.Position = UDim2.new(0, 10, 0, 65)
btnFeet.Size = UDim2.new(1, -20, 0, 26)
btnFeet.Font = Enum.Font.SourceSansBold
btnFeet.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFeet.TextSize = 11
btnFeet.Text = "Bay bám đuổi (Dưới chân)"
Instance.new("UICorner", btnFeet).CornerRadius = UDim.new(0, 4)

-- Nút Fling (Hất văng khỏi map)
local btnFling = Instance.new("TextButton", clickPopup)
btnFling.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
btnFling.Position = UDim2.new(0, 10, 0, 95)
btnFling.Size = UDim2.new(1, -20, 0, 26)
btnFling.Font = Enum.Font.SourceSansBold
btnFling.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFling.TextSize = 11
btnFling.Text = "FLING (Hất văng khỏi map)"
Instance.new("UICorner", btnFling).CornerRadius = UDim.new(0, 4)

local closePopupBtn = Instance.new("TextButton", clickPopup)
closePopupBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
closePopupBtn.Position = UDim2.new(0, 10, 0, 125)
closePopupBtn.Size = UDim2.new(1, -20, 0, 24)
closePopupBtn.Font = Enum.Font.SourceSansBold
closePopupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closePopupBtn.TextSize = 11
closePopupBtn.Text = "Đóng bảng"
Instance.new("UICorner", closePopupBtn).CornerRadius = UDim.new(0, 4)

closePopupBtn.MouseButton1Click:Connect(function() clickPopup.Visible = false end)

local selectedClickedPlayer = nil
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if currentMode == 1 and not gameProcessed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target and target.Parent then
            local char = target.Parent
            local p = Players:GetPlayerFromCharacter(char)
            if p and p ~= player then
                selectedClickedPlayer = p
                popupTitle.Text = "Đang chọn: " .. p.Name
                clickPopup.Visible = true
            end
        end
    end
end)

btnBehind.MouseButton1Click:Connect(function()
    if selectedClickedPlayer then
        targetPlayer = selectedClickedPlayer
        followPositionMode = "Behind"
        isEnabled = true
        isFollowing = true
        powerBtn.Text = "Bám đuổi: ON"
        powerBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        clickPopup.Visible = false
    end
end)

btnFeet.MouseButton1Click:Connect(function()
    if selectedClickedPlayer then
        targetPlayer = selectedClickedPlayer
        followPositionMode = "Feet"
        isEnabled = true
        isFollowing = true
        powerBtn.Text = "Bám đuổi: ON"
        powerBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        clickPopup.Visible = false
    end
end)

-- Chức năng Fling bay tới hất văng địch khỏi map
btnFling.MouseButton1Click:Connect(function()
    if selectedClickedPlayer and selectedClickedPlayer.Character and selectedClickedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local targetHRP = selectedClickedPlayer.Character.HumanoidRootPart
            
            task.spawn(function()
                local startTime = tick()
                while tick() - startTime < 1.5 do
                    if targetHRP and hrp then
                        hrp.CFrame = targetHRP.CFrame * CFrame.Angles(math.random(0,360), math.random(0,360), math.random(0,360))
                        hrp.Velocity = Vector3.new(99999, 99999, 99999)
                    end
                    RunService.RenderStepped:Wait()
                end
            end)
            clickPopup.Visible = false
        end
    end
end)

local function findTargetByText(query)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and (p.DisplayName and string.lower(p.DisplayName):sub(1, #query) == string.lower(query) or string.lower(p.Name):sub(1, #query) == string.lower(query)) then
            return p
        end
    end
    return nil
end

local function getRandomPlayer()
    local validList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 then table.insert(validList, p) end
        end
    end
    if #validList > 0 then return validList[math.random(1, #validList)] end
    return nil
end

local function getLowestHealthPlayer()
    local lowestP = nil
    local minHealth = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 and hum.Health < minHealth then
                minHealth = hum.Health
                lowestP = p
            end
        end
    end
    return lowestP
end

-- ================= VÒNG LẶP CHÍNH (RENDER STEPPED) =================
RunService.RenderStepped:Connect(function()
    if antiVoidEnabled then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if char.HumanoidRootPart.Position.Y < -50 then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end

    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum.Health > 0 then
            deathPosition = char.HumanoidRootPart.CFrame
        end

        -- Fix tốc độ chạy và nhảy cao hoạt động mượt mà trong TSB
        hum.WalkSpeed = customWalkSpeed
        hum.JumpPower = customJumpPower
    end

    -- Xray Camera Thông Minh (Chỉ làm mờ vật thể che khuất cơ thể khỏi camera)
    if wallhackEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local headPos = camera.CFrame.Position
            local charPos = char.HumanoidRootPart.Position
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = RaycastParams.RaycastType.Exclude
            raycastParams.FilterDescendantsInstances = {char}
            
            local result = Workspace:Raycast(headPos, charPos - headPos, raycastParams)
            if result and result.Instance and result.Instance:IsA("BasePart") then
                result.Instance.Transparency = 0.8
            end
        end)
    end

    if invisibilityEnabled then
        setTrueInvisibility(true)
    end

    if not isEnabled or not isFollowing then return end
    
    local isTargetDead = false
    if targetPlayer and targetPlayer.Character then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            isTargetDead = true
        end
    else
        isTargetDead = true
    end
    
    if currentMode == 2 then
        local query = nameBox.Text
        if query ~= "" then targetPlayer = findTargetByText(query) end
    elseif currentMode == 3 then
        if not targetPlayer or isTargetDead then targetPlayer = getRandomPlayer() end
    elseif currentMode == 4 then
        if not targetPlayer or isTargetDead then targetPlayer = getLowestHealthPlayer() end
    end
    
    if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPlayer = nil
        return
    end
    
    local targetChar = targetPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        
        if followPositionMode == "Behind" then
            local offset = targetHRP.CFrame * CFrame.new(0, 0, distanceOffset)
            hrp.CFrame = CFrame.new(offset.Position, targetHRP.Position)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        else
            local pos = targetHRP.Position - Vector3.new(0, distanceOffset, 0)
            hrp.CFrame = CFrame.lookAt(pos, pos + Vector3.new(0, 1, 0))
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end)

-- Hồi sinh tại chỗ kèm Animation
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.4)
    if respawnAtDeathEnabled and deathPosition then
        local hrp = newChar:WaitForChild("HumanoidRootPart", 2)
        local hum = newChar:WaitForChild("Humanoid", 2)
        local leftLeg = newChar:FindFirstChild("Left Leg") or newChar:FindFirstChild("LeftLowerLeg")
        local rightLeg = newChar:FindFirstChild("Right Leg") or newChar:FindFirstChild("RightLowerLeg")
        local torso = newChar:FindFirstChild("Torso") or newChar:FindFirstChild("UpperTorso")
        local head = newChar:FindFirstChild("Head")
        
        if hrp and hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hrp.CFrame = deathPosition
            
            local partsToAssemble = {leftLeg, rightLeg, torso, head}
            for _, part in ipairs(newChar:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = 1 end
            end
            
            task.wait(0.2)
            for _, p in ipairs(partsToAssemble) do
                if p and p:IsA("BasePart") then
                    p.Transparency = invisibilityEnabled and 1 or 0
                    task.wait(0.12)
                end
            end
            
            for _, part in ipairs(newChar:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = invisibilityEnabled and 1 or 0 end
            end
            hum.WalkSpeed = customWalkSpeed
            hum.JumpPower = customJumpPower
        end
    end
    if invisibilityEnabled then setTrueInvisibility(true) end
end)

player.CharacterAppearanceLoaded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    hum.Died:Connect(function()
        if respawnAtDeathEnabled then
            deathPosition = hrp.CFrame
            pcall(function()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = true
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(45), 0, 0) + Vector3.new(0, -2, 0)
                end
            end)
        end
    end)
end)

-- Vòng lặp Combat
task.spawn(function()
    while true do
        task.wait(0.15)
        local targetChar = nil
        if targetPlayer and targetPlayer.Character then targetChar = targetPlayer.Character end
        
        if autoM1Enabled then
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                else
                    VirtualUser:Button1Down(Vector2.new(0,0), camera.CFrame)
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(0,0), camera.CFrame)
                end
            end
        end
        
        for _, skill in ipairs(autoSkills) do
            if skill.enabled and targetChar then
                aimAndPressKey(skill, targetChar)
                task.wait(0.35)
            end
        end
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

print("Advanced Mobile Menu v23 Loaded Successfully!")
