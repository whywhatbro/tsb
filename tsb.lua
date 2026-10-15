-- Advanced Mobile Menu v7 (TSB Ultimate: Target Following, Auto M1 & Auto Skills)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("AdvancedMobileMenuV7") then
    CoreGui.AdvancedMobileMenuV7:Destroy()
end

-- Cấu hình trạng thái
local isEnabled = false
local currentMode = 3 -- 1: Danh sách, 2: Textbox, 3: Random riêng, 4: Ít máu nhất riêng
local targetPlayer = nil
local isFollowing = false
local distanceOffset = 4

-- Biến Auto M1 và Auto Skills
local autoM1Enabled = false
local autoSkills = {
    {key = "Enum.KeyCode.One", name = "Skill 1 (1)", enabled = false},
    {key = "Enum.KeyCode.Two", name = "Skill 2 (2)", enabled = false},
    {key = "Enum.KeyCode.Three", name = "Skill 3 (3)", enabled = false},
    {key = "Enum.KeyCode.Four", name = "Skill 4 (4)", enabled = false},
    {key = "Enum.KeyCode.Q", name = "Skill Q", enabled = false},
    {key = "Enum.KeyCode.E", name = "Skill E", enabled = false},
    {key = "Enum.KeyCode.R", name = "Skill R", enabled = false},
    {key = "Enum.KeyCode.F", name = "Skill F", enabled = false},
}

-- Hàm giả lập nhấn phím trên Roblox Mobile/PC
local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedMobileMenuV7"
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

-- Hàm kéo thả chung cho UI
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

-- 2. KHUNG MENU CHÍNH (Kéo thả toàn bộ khung)
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.02, 0, 0.23, 0)
mainFrame.Size = UDim2.new(0, 230, 0, 410)
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
title.Text = "☰ TSB MENU v7 (Kéo bất kỳ)"
local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 8) c3.Parent = title

-- Nút ON / OFF Tổng (Bám đuổi)
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

-- Nút Chuyển Chế Độ
local modeBtn = Instance.new("TextButton")
modeBtn.Parent = mainFrame
modeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeBtn.Position = UDim2.new(0, 10, 0, 65)
modeBtn.Size = UDim2.new(1, -20, 0, 25)
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
modeBtn.TextSize = 12
modeBtn.Text = "Chế độ: 3 (Random người chơi)"
local cMode = Instance.new("UICorner") cMode.CornerRadius = UDim.new(0, 4) cMode.Parent = modeBtn

-- Textbox Nhập Tên (Chế độ 2)
local nameBox = Instance.new("TextBox")
nameBox.Parent = mainFrame
nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameBox.Position = UDim2.new(0, 10, 0, 93)
nameBox.Size = UDim2.new(1, -20, 0, 23)
nameBox.Font = Enum.Font.SourceSans
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderText = "Nhập tên mục tiêu (Chế độ 2)..."
nameBox.Text = ""
nameBox.TextSize = 11
local cBox = Instance.new("UICorner") cBox.CornerRadius = UDim.new(0, 4) cBox.Parent = nameBox

-- Textbox BlackList
local blackBox = Instance.new("TextBox")
blackBox.Parent = mainFrame
blackBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
blackBox.Position = UDim2.new(0, 10, 0, 120)
blackBox.Size = UDim2.new(1, -20, 0, 23)
blackBox.Font = Enum.Font.SourceSans
blackBox.TextColor3 = Color3.fromRGB(255, 100, 100)
blackBox.PlaceholderText = "Ngoại lệ (vd: A,B,C)..."
blackBox.Text = ""
blackBox.TextSize = 11
local cBlack = Instance.new("UICorner") cBlack.CornerRadius = UDim.new(0, 4) cBlack.Parent = blackBox

-- Điều chỉnh khoảng cách
local distLabel = Instance.new("TextLabel")
distLabel.Parent = mainFrame
distLabel.Position = UDim2.new(0, 10, 0, 146)
distLabel.Size = UDim2.new(1, -20, 0, 16)
distLabel.BackgroundTransparency = 1
distLabel.Font = Enum.Font.SourceSans
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 11
distLabel.Text = "Khoảng cách sau lưng: 4"

local minusDist = Instance.new("TextButton")
minusDist.Parent = mainFrame
minusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minusDist.Position = UDim2.new(0, 10, 0, 164)
minusDist.Size = UDim2.new(0.48, 0, 0, 22)
minusDist.Text = "- Giảm"
minusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
minusDist.TextSize = 11
local cMin = Instance.new("UICorner") cMin.CornerRadius = UDim.new(0, 4) cMin.Parent = minusDist

local plusDist = Instance.new("TextButton")
plusDist.Parent = mainFrame
plusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
plusDist.Position = UDim2.new(0.52, 0, 0, 164)
plusDist.Size = UDim2.new(0.48, 0, 0, 22)
plusDist.Text = "+ Tăng"
plusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
plusDist.TextSize = 11
local cPlu = Instance.new("UICorner") cPlu.CornerRadius = UDim.new(0, 4) cPlu.Parent = plusDist

-- ScrollingFrame danh sách (Chế độ 1)
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainFrame
scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Position = UDim2.new(0, 10, 0, 190)
scrollingFrame.Size = UDim2.new(1, -20, 0, 70)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 3
local uiLayout = Instance.new("UIListLayout") uiLayout.Parent = scrollingFrame uiLayout.Padding = UDim.new(0, 3)
scrollingFrame.Visible = false

-- KHUNG AUTO M1 & AUTO SKILLS
local combatLabel = Instance.new("TextLabel")
combatLabel.Parent = mainFrame
combatLabel.Position = UDim2.new(0, 10, 0, 264)
combatLabel.Size = UDim2.new(1, -20, 0, 18)
combatLabel.BackgroundTransparency = 1
combatLabel.Font = Enum.Font.SourceSansBold
combatLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
combatLabel.TextSize = 12
combatLabel.Text = "--- AUTO COMBAT (M1 & SKILLS) ---"

-- Nút Auto M1
local autoM1Btn = Instance.new("TextButton")
autoM1Btn.Parent = mainFrame
autoM1Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
autoM1Btn.Position = UDim2.new(0, 10, 0, 285)
autoM1Btn.Size = UDim2.new(1, -20, 0, 24)
autoM1Btn.Font = Enum.Font.SourceSansBold
autoM1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoM1Btn.TextSize = 11
autoM1Btn.Text = "Auto M1 (Đánh thường): OFF"
local cM1 = Instance.new("UICorner") cM1.CornerRadius = UDim.new(0, 4) cM1.Parent = autoM1Btn

autoM1Btn.MouseButton1Click:Connect(function()
    autoM1Enabled = not autoM1Enabled
    if autoM1Enabled then
        autoM1Btn.Text = "Auto M1 (Đánh thường): ON"
        autoM1Btn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        autoM1Btn.Text = "Auto M1 (Đánh thường): OFF"
        autoM1Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

-- Tạo ScrollingFrame chứa các nút Auto Skill (1, 2, 3, 4, Q, E, R, F)
local skillFrame = Instance.new("ScrollingFrame")
skillFrame.Parent = mainFrame
skillFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
skillFrame.BorderSizePixel = 0
skillFrame.Position = UDim2.new(0, 10, 0, 313)
skillFrame.Size = UDim2.new(1, -20, 0, 85)
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

-- Logic nút Bật/Tắt Tổng Bám Đuổi
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

-- Điều chỉnh khoảng cách
minusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset - 1, 1, 15)
    distLabel.Text = "Khoảng cách sau lưng: " .. distanceOffset
end)
plusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset + 1, 1, 15)
    distLabel.Text = "Khoảng cách sau lưng: " .. distanceOffset
end)

-- Chuyển chế độ
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

-- Kiểm tra Blacklist
local function isBlacklisted(pName)
    local text = blackBox.Text
    for name in string.gmatch(text, "([^,]+)") do
        local cleanName = name:gsub("^%s*(.-)%s*$", ""):lower()
        if cleanName ~= "" and string.lower(pName):find(cleanName) then
            return true
        end
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

-- Vòng lặp bám dính liên tục
RunService.RenderStepped:Connect(function()
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
        
        local offset = targetHRP.CFrame * CFrame.new(0, 0, distanceOffset)
        hrp.CFrame = CFrame.new(offset.Position, targetHRP.Position)
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end)

-- Vòng lặp tự động đánh thường (Auto M1) và Tự động dùng kỹ năng (Auto Skills)
task.spawn(function()
    while true do
        task.wait(0.2)
        if autoM1Enabled then
            -- Giả lập click chuột trái đánh thường M1
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        
        for _, skill in ipairs(autoSkills) do
            if skill.enabled then
                local keyCode = Enum.KeyCode[string.match(skill.key, "Enum.KeyCode%.(%w+)") or "One"]
                if keyCode then
                    pressKey(keyCode)
                    task.wait(0.3)
                end
            end
        end
    end
end)

-- Cập nhật danh sách (Chế độ 1)
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

print("Advanced Mobile Menu v7 Loaded Successfully!")
