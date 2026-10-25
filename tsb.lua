-- Advanced Mobile Menu v20 (TSB Ultimate: Tabbed UI, Lockable Buttons, Click-to-Target, In-Place Respawn with Animation, Camera/Wall ESP & True Invis)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

if CoreGui:FindFirstChild("AdvancedMobileMenuV20") then
    CoreGui.AdvancedMobileMenuV20:Destroy()
end

-- Trạng thái tổng hợp
local isEnabled = false
local currentMode = 3 -- 1: Click chọn, 2: Textbox, 3: Random, 4: Ít máu nhất
local targetPlayer = nil
local isFollowing = false
local distanceOffset = 4
local followPositionMode = "Behind"

local antiVoidEnabled = true
local voidExecuterEnabled = true
local invisibilityEnabled = false
local respawnAtDeathEnabled = false
local wallHackEnabled = false
local uiLocked = false -- Khóa di chuyển các nút nổi

local deathPosition = nil
local isRespawning = false

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

-- Tàng hình mượt mà (Fix lỗi di chuyển)
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
screenGui.Name = "AdvancedMobileMenuV20"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Nút Menu Tròn
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Text = "Menu"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Nút Reset Nổi
local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetBtn"
resetBtn.Parent = screenGui
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
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character:FindFirstChild("HumanoidRootPart") then
                deathPosition = player.Character.HumanoidRootPart.CFrame
            end
            player.Character.Humanoid.Health = 0
        end
    end)
end)

-- Hàm kéo thả có kiểm tra khóa (Lock/Unlock)
local function makeDraggable(guiObject)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if uiLocked then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
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

-- Khung Menu Chính Ngang
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Position = UDim2.new(0.12, 0, 0.15, 0)
mainFrame.Size = UDim2.new(0, 540, 0, 340)
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Text = "  ☰ TSB MOBILE MENU v20 (Tabbed UI & Advanced Features)"
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- THANH TAB CHUYỂN ĐỔI (4 Tabs)
local tabButtonsFrame = Instance.new("Frame")
tabButtonsFrame.Parent = mainFrame
tabButtonsFrame.BackgroundTransparency = 1
tabButtonsFrame.Position = UDim2.new(0, 10, 0, 35)
tabButtonsFrame.Size = UDim2.new(1, -20, 0, 30)

local tabs = {"1. Combat", "2. Hồi sinh", "3. Visual & Wallhack", "4. Tổng hợp & Khóa"}
local tabContentFrames = {}

for i, tabName in ipairs(tabs) do
    local tBtn = Instance.new("TextButton")
    tBtn.Parent = tabButtonsFrame
    tBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 60, 120) or Color3.fromRGB(40, 40, 40)
    tBtn.Size = UDim2.new(0.24, 0, 1, 0)
    tBtn.Position = UDim2.new((i-1)*0.25, 0, 0, 0)
    tBtn.Font = Enum.Font.SourceSansBold
    tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tBtn.TextSize = 11
    tBtn.Text = tabName
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

    local cFrame = Instance.new("ScrollingFrame")
    cFrame.Parent = mainFrame
    cFrame.BackgroundTransparency = 1
    cFrame.Position = UDim2.new(0, 10, 0, 72)
    cFrame.Size = UDim2.new(1, -20, 1, -80)
    cFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
    cFrame.ScrollBarThickness = 3
    cFrame.Visible = (i == 1)
    table.insert(tabContentFrames, cFrame)

    tBtn.MouseButton1Click:Connect(function()
        for idx, frm in ipairs(tabContentFrames) do
            frm.Visible = (idx == i)
            -- Đổi màu nút tab
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
respawnBtn.Text = "Hồi sinh tại chỗ vừa chết: OFF"
Instance.new("UICorner", respawnBtn).CornerRadius = UDim.new(0, 6)

respawnBtn.MouseButton1Click:Connect(function()
    respawnAtDeathEnabled = not respawnAtDeathEnabled
    respawnBtn.Text = respawnAtDeathEnabled and "Hồi sinh tại chỗ vừa chết: ON" or "Hồi sinh tại chỗ vừa chết: OFF"
    respawnBtn.BackgroundColor3 = respawnAtDeathEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
end)

local respawnInfo = Instance.new("TextLabel", tab2)
respawnInfo.BackgroundTransparency = 1
respawnInfo.Size = UDim2.new(1, -5, 0, 60)
respawnInfo.Font = Enum.Font.SourceSans
respawnInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
respawnInfo.TextSize = 12
respawnInfo.TextWrapped = true
respawnInfo.Text = "• Khi bật, mỗi lần bạn chết, script sẽ lưu lại tọa độ và tự động dịch chuyển bạn về lại điểm đó kèm hiệu ứng hoạt ảnh hồi sinh mượt mà."

-- ================= TAB 3: VISUAL & WALLHACK =================
local tab3 = tabContentFrames[3]
local l3 = Instance.new("UIListLayout", tab3) l3.Padding = UDim.new(0, 8)

local wallhackBtn = Instance.new("TextButton", tab3)
wallhackBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
wallhackBtn.Size = UDim2.new(1, -5, 0, 35)
wallhackBtn.Font = Enum.Font.SourceSansBold
wallhackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wallhackBtn.TextSize = 13
wallhackBtn.Text = "Nhìn xuyên tường & Xóa vật cản: OFF"
Instance.new("UICorner", wallhackBtn).CornerRadius = UDim.new(0, 6)

wallhackBtn.MouseButton1Click:Connect(function()
    wallHackEnabled = not wallHackEnabled
    wallhackBtn.Text = wallHackEnabled and "Nhìn xuyên tường & Xóa vật cản: ON" or "Nhìn xuyên tường & Xóa vật cản: OFF"
    wallhackBtn.BackgroundColor3 = wallHackEnabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    
    camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    camera.FieldOfView = 70
end)

-- ================= TAB 4: TỔNG HỢP & KHÓA =================
local tab4 = tabContentFrames[4]
local l4 = Instance.new("UIListLayout", tab4) l4.Padding = UDim.new(0, 8)

local invisBtn = Instance.new("TextButton", tab4)
invisBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
invisBtn.Size = UDim2.new(1, -5, 0, 30)
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

local antiVoidBtn = Instance.new("TextButton", tab4)
antiVoidBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
antiVoidBtn.Size = UDim2.new(1, -5, 0, 30)
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

local voidExecBtn = Instance.new("TextButton", tab4)
voidExecBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
voidExecBtn.Size = UDim2.new(1, -5, 0, 30)
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

local lockUiBtn = Instance.new("TextButton", tab4)
lockUiBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
lockUiBtn.Size = UDim2.new(1, -5, 0, 30)
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

-- ================= HỆ THỐNG CLICK CHỌN NHÂN VẬT (CHẾ ĐỘ 1) =================
local clickPopup = Instance.new("Frame", screenGui)
clickPopup.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
clickPopup.Size = UDim2.new(0, 180, 0, 100)
clickPopup.Visible = false
Instance.new("UICorner", clickPopup).CornerRadius = UDim.new(0, 8)

local popupText = Instance.new("TextLabel", clickPopup)
popupText.BackgroundTransparency = 1
popupText.Size = UDim2.new(1, 0, 0, 35)
popupText.Font = Enum.Font.SourceSansBold
popupText.TextColor3 = Color3.fromRGB(255, 255, 255)
popupText.TextSize = 12
popupText.Text = "Chọn Mục Tiêu"

local selectBtn = Instance.new("TextButton", clickPopup)
selectBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
selectBtn.Position = UDim2.new(0, 10, 0, 40)
selectBtn.Size = UDim2.new(1, -20, 0, 25)
selectBtn.Font = Enum.Font.SourceSansBold
selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectBtn.TextSize = 11
selectBtn.Text = "Bám đuổi mục tiêu này"
Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 4)

local closePopupBtn = Instance.new("TextButton", clickPopup)
closePopupBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
closePopupBtn.Position = UDim2.new(0, 10, 0, 70)
closePopupBtn.Size = UDim2.new(1, -20, 0, 22)
closePopupBtn.Font = Enum.Font.SourceSansBold
closePopupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closePopupBtn.TextSize = 11
closePopupBtn.Text = "Đóng"
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
                popupText.Text = "Địch: " .. p.Name
                clickPopup.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y + 10)
                clickPopup.Visible = true
            end
        end
    end
end)

selectBtn.MouseButton1Click:Connect(function()
    if selectedClickedPlayer then
        targetPlayer = selectedClickedPlayer
        isEnabled = true
        isFollowing = true
        powerBtn.Text = "Bám đuổi: ON"
        powerBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        clickPopup.Visible = false
    end
end)

-- Hàm tìm kiếm theo Textbox (Chế độ 2)
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

-- ================= VÒNG LẶP CHÍNH =================
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

    if wallHackEnabled then
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
                    obj.Transparency = 0.65
                end
            end
        end)
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

-- Xử lý Hồi sinh tại chỗ kèm Animation
player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if respawnAtDeathEnabled and deathPosition then
        isRespawning = true
        local hrp = newChar:WaitForChild("HumanoidRootPart", 2)
        if hrp then
            -- Animation hiệu ứng mờ / biến hình hồi sinh tại chỗ
            for _, part in ipairs(newChar:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = 1 end
            end
            hrp.CFrame = deathPosition
            task.wait(0.4)
            for _, part in ipairs(newChar:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = invisibilityEnabled and 1 or 0 end
            end
        end
        isRespawning = false
    end
    if invisibilityEnabled then setTrueInvisibility(true) end
end)

-- Lắng nghe sự kiện chết để lưu tọa độ
player.CharacterAppearanceLoaded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        if char:FindFirstChild("HumanoidRootPart") then
            deathPosition = char.HumanoidRootPart.CFrame
        end
    end)
end)

-- Vòng lặp Combat (Auto M1 & Skills)
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

print("Advanced Mobile Menu v20 Loaded Successfully!")
