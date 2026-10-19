-- Advanced Mobile Menu v12 (TSB Ultimate: Force Reset Button, Predictive Aim & Void Executer on Crowd Control)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if CoreGui:FindFirstChild("AdvancedMobileMenuV12") then
    CoreGui.AdvancedMobileMenuV12:Destroy()
end

-- Cấu hình trạng thái
local isEnabled = false
local currentMode = 3 -- 1: Danh sách, 2: Textbox, 3: Random, 4: Ít máu nhất
local targetPlayer = nil
local isFollowing = false
local distanceOffset = 4
local followPositionMode = "Behind" -- "Behind" hoặc "Feet"

-- Biến Anti-Void
local antiVoidEnabled = true

-- Biến Void Executer (Dịch chuyển địch xuống void khi dùng chiêu khống chế)
local voidExecuterEnabled = true

-- Biến Auto M1 và Auto Skills
local autoM1Enabled = false
local autoSkills = {
    {key = "One", name = "Skill 1 (1)", enabled = false},
    {key = "Two", name = "Skill 2 (2)", enabled = false},
    {key = "Three", name = "Skill 3 (3)", enabled = false},
    {key = "Four", name = "Skill 4 (4)", enabled = false},
    {key = "Q", name = "Skill Q", enabled = false},
    {key = "E", name = "Skill E", enabled = false},
    {key = "R", name = "Skill R", enabled = false},
    {key = "F", name = "Skill F", enabled = false},
}

-- Hàm Aim thông minh tính toán trước hướng di chuyển của địch (Predictive Aim)
local function aimAndPressKey(keyName, targetChar)
    local keyCode = Enum.KeyCode[keyName]
    if keyCode and targetChar and targetChar:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        
        -- Tính toán vị trí dự đoán dựa trên vận tốc của kẻ địch để aim không trượt
        local predictedPos = targetHRP.Position + (targetHRP.Velocity * 0.1)
        
        local lookCFrame = CFrame.new(hrp.Position, Vector3.new(predictedPos.X, hrp.Position.Y, predictedPos.Z))
        hrp.CFrame = lookCFrame
        camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.08)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)

        -- Nếu tính năng Void Executer bật, khi dùng chiêu sẽ dịch chuyển thẳng mục tiêu xuống Void để kết liễu
        if voidExecuterEnabled and targetHRP then
            task.spawn(function()
                targetHRP.CFrame = CFrame.new(0, -50000, 0)
                targetHRP.Velocity = Vector3.new(0, 0, 0)
            end)
        end
    end
end

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedMobileMenuV12"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. NÚT MENU TRÒN MỞ BẢNG (Di chuyển được)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.BorderSizePixel = 0
toggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Text = "Menu"
local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = toggleBtn

-- 2. NÚT RESET NỔI CỰC MẠNH (Bất chấp combat/lỗi)
local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetBtn"
resetBtn.Parent = screenGui
resetBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
resetBtn.BorderSizePixel = 0
resetBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
resetBtn.Size = UDim2.new(0, 45, 0, 45)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 12
resetBtn.Text = "Reset"
local cReset = Instance.new("UICorner") cReset.CornerRadius = UDim.new(1, 0) cReset.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            -- Phá hủy Humanoid hoặc set máu về 0 để reset lập tức bất chấp trạng thái combat
            player.Character.Humanoid.Health = 0
            if player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart:Destroy()
            end
        end
    end)
end)

-- Hàm kéo thả chung
local function makeDraggable(guiObject)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
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
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(toggleBtn)
makeDraggable(resetBtn)

-- 3. KHUNG MENU CHÍNH
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.02, 0, 0.35, 0)
mainFrame.Size = UDim2.new(0, 230, 0, 500)
mainFrame.Visible = false
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = mainFrame
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Text = "☰ TSB MOBILE MENU v12"
local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 8) c3.Parent = title

local powerBtn = Instance.new("TextButton")
powerBtn.Parent = mainFrame
powerBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
powerBtn.Position = UDim2.new(0, 10, 0, 36)
powerBtn.Size = UDim2.new(1, -20, 0, 25)
powerBtn.Font = Enum.Font.SourceSansBold
powerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
powerBtn.TextSize = 12
powerBtn.Text = "Bám đuổi: OFF"
local cPow = Instance.new("UICorner") cPow.CornerRadius = UDim.new(0, 4) cPow.Parent = powerBtn

local antiVoidBtn = Instance.new("TextButton")
antiVoidBtn.Parent = mainFrame
antiVoidBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
antiVoidBtn.Position = UDim2.new(0, 10, 0, 64)
antiVoidBtn.Size = UDim2.new(1, -20, 0, 24)
antiVoidBtn.Font = Enum.Font.SourceSansBold
antiVoidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiVoidBtn.TextSize = 11
antiVoidBtn.Text = "Anti-Void (Chống chết vực): ON"
local cAnti = Instance.new("UICorner") cAnti.CornerRadius = UDim.new(0, 4) cAnti.Parent = antiVoidBtn

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    if antiVoidEnabled then
        antiVoidBtn.Text = "Anti-Void (Chống chết vực): ON"
        antiVoidBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        antiVoidBtn.Text = "Anti-Void (Chống chết vực): OFF"
        antiVoidBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

-- Nút Bật/Tắt Void Executer (Dịch chuyển địch xuống void khi dùng chiêu khống chế)
local voidExecBtn = Instance.new("TextButton")
voidExecBtn.Parent = mainFrame
voidExecBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
voidExecBtn.Position = UDim2.new(0, 10, 0, 92)
voidExecBtn.Size = UDim2.new(1, -20, 0, 24)
voidExecBtn.Font = Enum.Font.SourceSansBold
voidExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
voidExecBtn.TextSize = 11
voidExecBtn.Text = "Void Executer (Khống chế -> Void): ON"
local cVoidExec = Instance.new("UICorner") cVoidExec.CornerRadius = UDim.new(0, 4) cVoidExec.Parent = voidExecBtn

voidExecBtn.MouseButton1Click:Connect(function()
    voidExecuterEnabled = not voidExecuterEnabled
    if voidExecuterEnabled then
        voidExecBtn.Text = "Void Executer (Khống chế -> Void): ON"
        voidExecBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        voidExecBtn.Text = "Void Executer (Khống chế -> Void): OFF"
        voidExecBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

local posModeBtn = Instance.new("TextButton")
posModeBtn.Parent = mainFrame
posModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
posModeBtn.Position = UDim2.new(0, 10, 0, 120)
posModeBtn.Size = UDim2.new(1, -20, 0, 25)
posModeBtn.Font = Enum.Font.SourceSansBold
posModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
posModeBtn.TextSize = 12
posModeBtn.Text = "Vị trí bám: Sau lưng (Behind)"
local cPosMode = Instance.new("UICorner") cPosMode.CornerRadius = UDim.new(0, 4) cPosMode.Parent = posModeBtn

posModeBtn.MouseButton1Click:Connect(function()
    if followPositionMode == "Behind" then
        followPositionMode = "Feet"
        posModeBtn.Text = "Vị trí bám: Dưới chân (Ngửa mặt đánh)"
        posModeBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
    else
        followPositionMode = "Behind"
        posModeBtn.Text = "Vị trí bám: Sau lưng (Behind)"
        posModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
    end
end)

local modeBtn = Instance.new("TextButton")
modeBtn.Parent = mainFrame
modeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeBtn.Position = UDim2.new(0, 10, 0, 149)
modeBtn.Size = UDim2.new(1, -20, 0, 25)
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
modeBtn.TextSize = 12
modeBtn.Text = "Chế độ: 3 (Random người chơi)"
local cMode = Instance.new("UICorner") cMode.CornerRadius = UDim.new(0, 4) cMode.Parent = modeBtn

local nameBox = Instance.new("TextBox")
nameBox.Parent = mainFrame
nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameBox.Position = UDim2.new(0, 10, 0, 177)
nameBox.Size = UDim2.new(1, -20, 0, 23)
nameBox.Font = Enum.Font.SourceSans
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderText = "Nhập tên mục tiêu (Chế độ 2)..."
nameBox.Text = ""
nameBox.TextSize = 11
local cBox = Instance.new("UICorner") cBox.CornerRadius = UDim.new(0, 4) cBox.Parent = nameBox

local blackBox = Instance.new("TextBox")
blackBox.Parent = mainFrame
blackBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
blackBox.Position = UDim2.new(0, 10, 0, 204)
blackBox.Size = UDim2.new(1, -20, 0, 23)
blackBox.Font = Enum.Font.SourceSans
blackBox.TextColor3 = Color3.fromRGB(255, 100, 100)
blackBox.PlaceholderText = "Ngoại lệ (vd: A,B,C)..."
blackBox.Text = ""
blackBox.TextSize = 11
local cBlack = Instance.new("UICorner") cBlack.CornerRadius = UDim.new(0, 4) cBlack.Parent = blackBox

local distLabel = Instance.new("TextLabel")
distLabel.Parent = mainFrame
distLabel.Position = UDim2.new(0, 10, 0, 230)
distLabel.Size = UDim2.new(1, -20, 0, 16)
distLabel.BackgroundTransparency = 1
distLabel.Font = Enum.Font.SourceSans
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 11
distLabel.Text = "Khoảng cách (Xa/Gần hoặc Dưới chân): 4"

local minusDist = Instance.new("TextButton")
minusDist.Parent = mainFrame
minusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minusDist.Position = UDim2.new(0, 10, 0, 248)
minusDist.Size = UDim2.new(0.48, 0, 0, 22)
minusDist.Text = "- Giảm"
minusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
minusDist.TextSize = 11
local cMin = Instance.new("UICorner") cMin.CornerRadius = UDim.new(0, 4) cMin.Parent = minusDist

local plusDist = Instance.new("TextButton")
plusDist.Parent = mainFrame
plusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
plusDist.Position = UDim2.new(0.52, 0, 0, 248)
plusDist.Size = UDim2.new(0.48, 0, 0, 22)
plusDist.Text = "+ Tăng"
plusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
plusDist.TextSize = 11
local cPlu = Instance.new("UICorner") cPlu.CornerRadius = UDim.new(0, 4) cPlu.Parent = plusDist

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Position = UDim2.new(0, 10, 0, 273)
scrollingFrame.Size = UDim2.new(1, -20, 0, 45)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 3
local uiLayout = Instance.new("UIListLayout") uiLayout.Parent = scrollingFrame uiLayout.Padding = UDim.new(0, 3)
scrollingFrame.Visible = false

local combatLabel = Instance.new("TextLabel")
combatLabel.Parent = mainFrame
combatLabel.Position = UDim2.new(0, 10, 0, 324)
combatLabel.Size = UDim2.new(1, -20, 0, 18)
combatLabel.BackgroundTransparency = 1
combatLabel.Font = Enum.Font.SourceSansBold
combatLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
combatLabel.TextSize = 12
combatLabel.Text = "--- AUTO COMBAT (MOBILE M1 & SKILLS) ---"

local autoM1Btn = Instance.new("TextButton")
autoM1Btn.Parent = mainFrame
autoM1Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
autoM1Btn.Position = UDim2.new(0, 10, 0, 345)
autoM1Btn.Size = UDim2.new(1, -20, 0, 24)
autoM1Btn.Font = Enum.Font.SourceSansBold
autoM1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoM1Btn.TextSize = 11
autoM1Btn.Text = "Auto M1 (Đánh thường Mobile): OFF"
local cM1 = Instance.new("UICorner") cM1.CornerRadius = UDim.new(0, 4) cM1.Parent = autoM1Btn

autoM1Btn.MouseButton1Click:Connect(function()
    autoM1Enabled = not autoM1Enabled
    if autoM1Enabled then
        autoM1Btn.Text = "Auto M1 (Đánh thường Mobile): ON"
        autoM1Btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        autoM1Btn.Text = "Auto M1 (Đánh thường Mobile): OFF"
        autoM1Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

local skillFrame = Instance.new("ScrollingFrame")
skillFrame.Parent = mainFrame
skillFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
skillFrame.BorderSizePixel = 0
skillFrame.Position = UDim2.new(0, 10, 0, 373)
skillFrame.Size = UDim2.new(1, -20, 0, 115)
skillFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
skillFrame.ScrollBarThickness = 3
local skillLayout = Instance.new("UIListLayout") skillLayout.Parent = skillFrame skillLayout.Padding = UDim.new(0, 3)

for _, skill in ipairs(autoSkills) do
    local sBtn = Instance.new("TextButton")
    sBtn.Parent = skillFrame
    sBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    sBtn.Size = UDim2.new(1, -5, 0, 22)
    sBtn.Font = Enum.Font.SourceSansBold
    sBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sBtn.TextSize = 11
    sBtn.Text = skill.name .. ": OFF"
    local cSBtn = Instance.new("UICorner") cSBtn.CornerRadius = UDim.new(0, 3) cSBtn.Parent = sBtn
    
    sBtn.MouseButton1Click:Connect(function()
        skill.enabled = not skill.enabled
        if skill.enabled then
            sBtn.Text = skill.name .. ": ON"
            sBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        else
            sBtn.Text = skill.name .. ": OFF"
            sBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        end
    end)
end
skillFrame.CanvasSize = UDim2.new(0, 0, 0, skillLayout.AbsoluteContentSize.Y + 5)

powerBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        powerBtn.Text = "Bám đuổi: ON"
        powerBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        isFollowing = true
    else
        powerBtn.Text = "Bám đuổi: OFF"
        powerBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        isFollowing = false
        targetPlayer = nil
    end
end)

minusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset - 1, 1, 15)
    distLabel.Text = "Khoảng cách (Xa/Gần hoặc Dưới chân): " .. distanceOffset
end)
plusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset + 1, 1, 15)
    distLabel.Text = "Khoảng cách (Xa/Gần hoặc Dưới chân): " .. distanceOffset
end)

modeBtn.MouseButton1Click:Connect(function()
    currentMode = currentMode + 1
    if currentMode > 4 then currentMode = 1 end
    
    if currentMode == 1 then
        modeBtn.Text = "Chế độ: 1 (Chọn từ danh sách)"
        scrollingFrame.Visible = true
    elseif currentMode == 2 then
        modeBtn.Text = "Chế độ: 2 (Textbox nhận diện)"
        scrollingFrame.Visible = false
    elseif currentMode == 3 then
        modeBtn.Text = "Chế độ: 3 (Random người chơi)"
        scrollingFrame.Visible = false
    elseif currentMode == 4 then
        modeBtn.Text = "Chế độ: 4 (Người ít máu nhất)"
        scrollingFrame.Visible = false
    end
end)

local function isBlacklisted(pName)
    local text = blackBox.Text
    for name in string.gmatch(text, "([^,]+)") do
        local cleanName = name:gsub("^%s*(.-)%s*$", ""):lower()
        if cleanName ~= "" and string.lower(pName):find(cleanName) then return true end
    end
    return false
end

local function findTargetByText(query)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not isBlacklisted(p.Name) and (p.DisplayName and string.lower(p.DisplayName):sub(1, #query) == string.lower(query) or string.lower(p.Name):sub(1, #query) == string.lower(query)) then
            return p
        end
    end
    return nil
end

local function getRandomPlayer()
    local validList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and not isBlacklisted(p.Name) and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
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
        if p ~= player and not isBlacklisted(p.Name) and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 and hum.Health < minHealth then
                minHealth = hum.Health
                lowestP = p
            end
        end
    end
    return lowestP
end

RunService.RenderStepped:Connect(function()
    -- Chống Anti-Void toàn diện cho nhân vật của bạn ở mọi chế độ
    if antiVoidEnabled then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if char.HumanoidRootPart.Position.Y < -50 then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
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
    
    local char = player.Character
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

-- Vòng lặp Auto Combat (M1 & Predictive Aim Skills)
task.spawn(function()
    while true do
        task.wait(0.15)
        
        local targetChar = nil
        if targetPlayer and targetPlayer.Character then
            targetChar = targetPlayer.Character
        end
        
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
                aimAndPressKey(skill.key, targetChar)
                task.wait(0.35)
            end
        end
    end
end)

local function updateList()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Parent = scrollingFrame
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Size = UDim2.new(1, -5, 0, 25)
            btn.Font = Enum.Font.SourceSans
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 11
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            local cBtn = Instance.new("UICorner") cBtn.CornerRadius = UDim.new(0, 4) cBtn.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                targetPlayer = p
                isEnabled = true
                powerBtn.Text = "Bám đuổi: ON"
                powerBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
                isFollowing = true
            end)
        end
    end
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiLayout.AbsoluteContentSize.Y + 5)
end

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    if mainFrame.Visible and currentMode == 1 then updateList() end
end)

print("Advanced Mobile Menu v12 Loaded Successfully!")
