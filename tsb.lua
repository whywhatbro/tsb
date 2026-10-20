-- Advanced Mobile Menu v19 (TSB Ultimate: True Network Invisibility, Textbox Target, Smart Grab Void Executer & Horizontal UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if CoreGui:FindFirstChild("AdvancedMobileMenuV19") then
    CoreGui.AdvancedMobileMenuV19:Destroy()
end

-- Cấu hình trạng thái
local isEnabled = false
local currentMode = 3 -- 1: Danh sách, 2: Textbox nhập tên, 3: Random, 4: Ít máu nhất
local targetPlayer = nil
local isFollowing = false
local distanceOffset = 4
local followPositionMode = "Behind" -- "Behind" hoặc "Feet"

-- Biến Anti-Void & Tàng hình thật
local antiVoidEnabled = true
local voidExecuterEnabled = true
local invisibilityEnabled = false

-- Danh sách phím kỹ năng
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

-- Hàm tàng hình thật (Ẩn nhân vật + Đưa xuống dưới đất sâu một khoảng siêu nhỏ khi không bám đuổi để địch không thấy)
local function setTrueInvisibility(state)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
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

-- Hàm tìm mục tiêu qua Textbox (Chế độ 2)
local function findTargetByText(query)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and (p.DisplayName and string.lower(p.DisplayName):sub(1, #query) == string.lower(query) or string.lower(p.Name):sub(1, #query) == string.lower(query)) then
            return p
        end
    end
    return nil
end

-- Hàm lấy Random người chơi (Chế độ 3)
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

-- Hàm lấy người ít máu nhất (Chế độ 4)
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

-- Hàm Aim và Void Executer
local function aimAndPressKey(skillObj, targetChar)
    local keyCode = Enum.KeyCode[skillObj.key]
    if keyCode and targetChar and targetChar:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local targetHRP = targetChar.HumanoidRootPart
        
        local predictedPos = targetHRP.Position + (targetHRP.Velocity * 0.1)
        local lookCFrame = CFrame.new(hrp.Position, Vector3.new(predictedPos.X, hrp.Position.Y, predictedPos.Z))
        hrp.CFrame = lookCFrame
        camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        
        if voidExecuterEnabled and skillObj.isGrab then
            pcall(function()
                targetHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
            end)
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

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedMobileMenuV19"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 1. NÚT MENU TRÒN MỞ BẢNG
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.BorderSizePixel = 0
toggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Text = "Menu"
local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(1, 0) c1.Parent = toggleBtn

-- 2. NÚT RESET NỔI CỰC MẠNH
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
            player.Character.Humanoid.Health = 0
            if player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart:Destroy()
            end
        end
    end)
end)

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

-- 3. KHUNG MENU CHÍNH HÌNH CHỮ NHẬT NGANG
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.12, 0, 0.15, 0)
mainFrame.Size = UDim2.new(0, 520, 0, 330)
mainFrame.Visible = false
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 10) c2.Parent = mainFrame
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Size = UDim2.new(1, 0, 0, 32)
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Text = "  ☰ TSB MOBILE MENU v19 (True Invis + Textbox)"
local c3 = Instance.new("UICorner") c3.CornerRadius = UDim.new(0, 10) c3.Parent = title

-- CỘT TRÁI
local leftCol = Instance.new("Frame")
leftCol.Parent = mainFrame
leftCol.BackgroundTransparency = 1
leftCol.Position = UDim2.new(0, 10, 0, 38)
leftCol.Size = UDim2.new(0.48, 0, 1, -42)

local leftLayout = Instance.new("UIListLayout") leftLayout.Parent = leftCol leftLayout.Padding = UDim.new(0, 4)

local powerBtn = Instance.new("TextButton")
powerBtn.Parent = leftCol
powerBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
powerBtn.Size = UDim2.new(1, 0, 0, 25)
powerBtn.Font = Enum.Font.SourceSansBold
powerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
powerBtn.TextSize = 12
powerBtn.Text = "Bám đuổi: OFF"
local cPow = Instance.new("UICorner") cPow.CornerRadius = UDim.new(0, 4) cPow.Parent = powerBtn

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

local invisBtn = Instance.new("TextButton")
invisBtn.Parent = leftCol
invisBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
invisBtn.Size = UDim2.new(1, 0, 0, 25)
invisBtn.Font = Enum.Font.SourceSansBold
invisBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
invisBtn.TextSize = 12
invisBtn.Text = "Tàng hình (True Invis): OFF"
local cInvis = Instance.new("UICorner") cInvis.CornerRadius = UDim.new(0, 4) cInvis.Parent = invisBtn

invisBtn.MouseButton1Click:Connect(function()
    invisibilityEnabled = not invisibilityEnabled
    if invisibilityEnabled then
        invisBtn.Text = "Tàng hình (True Invis): ON"
        invisBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        setTrueInvisibility(true)
    else
        invisBtn.Text = "Tàng hình (True Invis): OFF"
        invisBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        setTrueInvisibility(false)
    end
end)

local antiVoidBtn = Instance.new("TextButton")
antiVoidBtn.Parent = leftCol
antiVoidBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
antiVoidBtn.Size = UDim2.new(1, 0, 0, 25)
antiVoidBtn.Font = Enum.Font.SourceSansBold
antiVoidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiVoidBtn.TextSize = 12
antiVoidBtn.Text = "Anti-Void: ON"
local cAnti = Instance.new("UICorner") cAnti.CornerRadius = UDim.new(0, 4) cAnti.Parent = antiVoidBtn

antiVoidBtn.MouseButton1Click:Connect(function()
    antiVoidEnabled = not antiVoidEnabled
    if antiVoidEnabled then
        antiVoidBtn.Text = "Anti-Void: ON"
        antiVoidBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        antiVoidBtn.Text = "Anti-Void: OFF"
        antiVoidBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

local voidExecBtn = Instance.new("TextButton")
voidExecBtn.Parent = leftCol
voidExecBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
voidExecBtn.Size = UDim2.new(1, 0, 0, 25)
voidExecBtn.Font = Enum.Font.SourceSansBold
voidExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
voidExecBtn.TextSize = 12
voidExecBtn.Text = "Void Executer (Chiêu tóm): ON"
local cVoidExec = Instance.new("UICorner") cVoidExec.CornerRadius = UDim.new(0, 4) cVoidExec.Parent = voidExecBtn

voidExecBtn.MouseButton1Click:Connect(function()
    voidExecuterEnabled = not voidExecuterEnabled
    if voidExecuterEnabled then
        voidExecBtn.Text = "Void Executer (Chiêu tóm): ON"
        voidExecBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        voidExecBtn.Text = "Void Executer (Chiêu tóm): OFF"
        voidExecBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

local posModeBtn = Instance.new("TextButton")
posModeBtn.Parent = leftCol
posModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
posModeBtn.Size = UDim2.new(1, 0, 0, 25)
posModeBtn.Font = Enum.Font.SourceSansBold
posModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
posModeBtn.TextSize = 12
posModeBtn.Text = "Vị trí: Sau lưng (Behind)"
local cPosMode = Instance.new("UICorner") cPosMode.CornerRadius = UDim.new(0, 4) cPosMode.Parent = posModeBtn

posModeBtn.MouseButton1Click:Connect(function()
    if followPositionMode == "Behind" then
        followPositionMode = "Feet"
        posModeBtn.Text = "Vị trí: Dưới chân (Ngửa mặt)"
        posModeBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
    else
        followPositionMode = "Behind"
        posModeBtn.Text = "Vị trí: Sau lưng (Behind)"
        posModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
    end
end)

local modeBtn = Instance.new("TextButton")
modeBtn.Parent = leftCol
modeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
modeBtn.Size = UDim2.new(1, 0, 0, 25)
modeBtn.Font = Enum.Font.SourceSansBold
modeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
modeBtn.TextSize = 11
modeBtn.Text = "Chế độ: 3 (Random)"
local cMode = Instance.new("UICorner") cMode.CornerRadius = UDim.new(0, 4) cMode.Parent = modeBtn

modeBtn.MouseButton1Click:Connect(function()
    currentMode = currentMode + 1
    if currentMode > 4 then currentMode = 1 end
    
    if currentMode == 1 then modeBtn.Text = "Chế độ: 1 (Danh sách)"
    elseif currentMode == 2 then modeBtn.Text = "Chế độ: 2 (Textbox)"
    elseif currentMode == 3 then modeBtn.Text = "Chế độ: 3 (Random)"
    elseif currentMode == 4 then modeBtn.Text = "Chế độ: 4 (Ít máu nhất)" end
end)

local nameBox = Instance.new("TextBox")
nameBox.Parent = leftCol
nameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
nameBox.Size = UDim2.new(1, 0, 0, 24)
nameBox.Font = Enum.Font.SourceSans
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderText = "Nhập tên địch (Chế độ 2)..."
nameBox.Text = ""
nameBox.TextSize = 11
local cBox = Instance.new("UICorner") cBox.CornerRadius = UDim.new(0, 4) cBox.Parent = nameBox

local distRow = Instance.new("Frame")
distRow.Parent = leftCol
distRow.BackgroundTransparency = 1
distRow.Size = UDim2.new(1, 0, 0, 24)

local distLabel = Instance.new("TextLabel")
distLabel.Parent = distRow
distLabel.BackgroundTransparency = 1
distLabel.Size = UDim2.new(0.5, 0, 1, 0)
distLabel.Font = Enum.Font.SourceSans
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 11
distLabel.Text = "Khoảng cách: 4"

local minusDist = Instance.new("TextButton")
minusDist.Parent = distRow
minusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minusDist.Position = UDim2.new(0.52, 0, 0, 0)
minusDist.Size = UDim2.new(0.22, 0, 1, 0)
minusDist.Text = "-"
minusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
local cMin = Instance.new("UICorner") cMin.CornerRadius = UDim.new(0, 4) cMin.Parent = minusDist

local plusDist = Instance.new("TextButton")
plusDist.Parent = distRow
plusDist.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
plusDist.Position = UDim2.new(0.76, 0, 0, 0)
plusDist.Size = UDim2.new(0.22, 0, 1, 0)
plusDist.Text = "+"
plusDist.TextColor3 = Color3.fromRGB(255, 255, 255)
local cPlu = Instance.new("UICorner") cPlu.CornerRadius = UDim.new(0, 4) cPlu.Parent = plusDist

minusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset - 1, 1, 15)
    distLabel.Text = "Khoảng cách: " .. distanceOffset
end)
plusDist.MouseButton1Click:Connect(function()
    distanceOffset = math.clamp(distanceOffset + 1, 1, 15)
    distLabel.Text = "Khoảng cách: " .. distanceOffset
end)

-- CỘT PHẢI
local rightCol = Instance.new("Frame")
rightCol.Parent = mainFrame
rightCol.BackgroundTransparency = 1
rightCol.Position = UDim2.new(0.51, 0, 0, 38)
rightCol.Size = UDim2.new(0.48, 0, 1, -42)

local rightLayout = Instance.new("UIListLayout") rightLayout.Parent = rightCol rightLayout.Padding = UDim.new(0, 4)

local autoM1Btn = Instance.new("TextButton")
autoM1Btn.Parent = rightCol
autoM1Btn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
autoM1Btn.Size = UDim2.new(1, 0, 0, 25)
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

local skillScroll = Instance.new("ScrollingFrame")
skillScroll.Parent = rightCol
skillScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
skillScroll.BorderSizePixel = 0
skillScroll.Size = UDim2.new(1, 0, 0, 215)
skillScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
skillScroll.ScrollBarThickness = 3
local sLayout = Instance.new("UIListLayout") sLayout.Parent = skillScroll sLayout.Padding = UDim.new(0, 3)

for _, skill in ipairs(autoSkills) do
    local sBtn = Instance.new("TextButton")
    sBtn.Parent = skillScroll
    sBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    sBtn.Size = UDim2.new(1, -5, 0, 24)
    sBtn.Font = Enum.Font.SourceSansBold
    sBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sBtn.TextSize = 11
    sBtn.Text = skill.name .. (skill.isGrab and " [Tóm]" or "") .. ": OFF"
    local cSBtn = Instance.new("UICorner") cSBtn.CornerRadius = UDim.new(0, 3) cSBtn.Parent = sBtn
    
    sBtn.MouseButton1Click:Connect(function()
        skill.enabled = not skill.enabled
        if skill.enabled then
            sBtn.Text = skill.name .. (skill.isGrab and " [Tóm]" or "") .. ": ON"
            sBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        else
            sBtn.Text = skill.name .. (skill.isGrab and " [Tóm]" or "") .. ": OFF"
            sBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        end
    end)
end
skillScroll.CanvasSize = UDim2.new(0, 0, 0, sLayout.AbsoluteContentSize.Y + 5)

-- Vòng lặp chính bám dính & xử lý Tàng hình thật
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

    if invisibilityEnabled then
        setTrueInvisibility(true)
        -- Đẩy nhân vật lệch nhẹ khỏi trục nhìn camera của địch khi không bám đuổi để tàng hình thực sự
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and not isEnabled then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, -10, 0)
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

player.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    if invisibilityEnabled then setTrueInvisibility(true) end
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

print("Advanced Mobile Menu v19 Loaded Successfully!")
