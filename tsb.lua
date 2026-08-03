-- PART 1: TSB ENGINE V16, FOV CIRCLE & DATA STORAGE
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = Player:WaitForChild("PlayerGui")

local CONFIG_FILE = "TSB_DaiTayTruong_V16.json"
local HttpService = game:GetService("HttpService")

local config = {
    aimMode = "FOV", -- FOV hoặc LowestHealth (Ít máu nhất)
    autoBlock = false,
    autoCombo = false,
    fovRadius = 150,
    menuTextureId = "rbxassetid://0"
}

local function saveConfig()
    pcall(function() if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(config)) end end)
end

local function loadConfig()
    pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then
            local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(saved) do config[k] = v end
        end
    end)
end
loadConfig()

local FovCircle = Instance.new("Frame")
FovCircle.Name = "TSB_FovCircle_V16"
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovCircle.BackgroundTransparency = 0.95
FovCircle.BorderSizePixel = 1
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovCircle

pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaiTayTruongTSBMenuV16"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = PlayerGui end
FovCircle.Parent = ScreenGui

local ToggleMenuButton = Instance.new("TextButton")
ToggleMenuButton.Size = UDim2.new(0, 50, 0, 50)
ToggleMenuButton.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleMenuButton.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
ToggleMenuButton.Text = "TSB"
ToggleMenuButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleMenuButton.Font = Enum.Font.SourceSansBold
ToggleMenuButton.TextSize = 14
ToggleMenuButton.ZIndex = 10
ToggleMenuButton.Parent = ScreenGui

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 25)
UICornerBtn.Parent = ToggleMenuButton

local MainFrame = Instance.new("ImageLabel")
MainFrame.Size = UDim2.new(0, 540, 0, 240)
MainFrame.Position = UDim2.new(0.5, -270, 0.4, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
MainFrame.Active = true
MainFrame.ScaleType = Enum.ScaleType.Slice
MainFrame.Parent = ScreenGui

if config.menuTextureId ~= "rbxassetid://0" then MainFrame.Image = config.menuTextureId end

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(70, 20, 20)
Title.BackgroundTransparency = 0.1
Title.Text = "FREE HACK BY ĐẠI TÀY TRƯỞNG - TSB LOWEST HEALTH AIM V16"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 10)
UICornerTitle.Parent = Title

local LeftColumn = Instance.new("Frame")
LeftColumn.Size = UDim2.new(0.46, 0, 0.8, 0)
LeftColumn.Position = UDim2.new(0.02, 0, 0.18, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.Parent = MainFrame

local RightColumn = Instance.new("Frame")
RightColumn.Size = UDim2.new(0.46, 0, 0.8, 0)
RightColumn.Position = UDim2.new(0.52, 0, 0.18, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.Parent = MainFrame
-- PART 2: UI LAYOUT BUTTONS & VALUE CONFIGURATIONS
local function createMenuButton(text, parent, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    return btn
end

local function createMenuTextBox(placeholder, parent, posY)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.45, 0, 0, 32)
    box.Position = UDim2.new(0, 0, 0, posY)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 12
    box.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = box
    return box
end

-- CÁC NÚT CỘT TRÁI (LEFT)
local AimModeBtn = createMenuButton("Chế Độ Aim: VÒNG FOV", LeftColumn, 5, Color3.fromRGB(0, 120, 200))
local AutoBlockBtn = createMenuButton("Auto Đỡ Đòn (Khi Có Địch Đánh): TẮT", LeftColumn, 45, Color3.fromRGB(200, 50, 50))
local AutoComboBtn = createMenuButton("Auto Combo Đấm PvP M1: TẮT", LeftColumn, 85, Color3.fromRGB(200, 50, 50))

-- CÁC NÚT CỘT PHẢI (RIGHT)
local FovRadiusBox = createMenuTextBox("Cỡ Vòng Aim: 150", RightColumn, 5)
FovRadiusBox.Size = UDim2.new(1, 0, 0, 32)

local TextureBox = createMenuTextBox("Nhập ID ảnh...", RightColumn, 45)
local TextureBtn = createMenuButton("Đổi Nền UI", RightColumn, 45, Color3.fromRGB(140, 20, 180))
TextureBtn.Size = UDim2.new(0.5, 0, 0, 32)
TextureBtn.Position = UDim2.new(0.5, 0, 0, 45)
-- PART 3: ADVANCED SCANNER - FOV AIM AND LOWEST HEALTH ENEMY FINDER
local function getClosestPlayerInFov()
    local closestTarget = nil local shortestDistance = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
            if p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distanceToCenter <= config.fovRadius and distanceToCenter < shortestDistance then
                        closestTarget = p shortestDistance = distanceToCenter
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Thuật toán tìm người chơi có chỉ số phần trăm máu thấp nhất server để đi "vét mạng"
local function getLowestHealthPlayer()
    local targetPlayer = nil
    local lowestHealth = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
            local enemyHum = p.Character:FindFirstChildOfClass("Humanoid")
            -- Đảm bảo kẻ địch còn sống và trong tầm quét (dưới 400 mét để tránh lỗi đứng camera)
            if enemyHum and enemyHum.Health > 0 then
                local distance = (p.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 400 and enemyHum.Health < lowestHealth then
                    lowestHealth = enemyHum.Health
                    targetPlayer = p
                end
            end
        end
    end
    return targetPlayer
end

-- Vòng lặp liên tục điều khiển hướng ngắm của Camera
RunService.RenderStepped:Connect(function()
    FovCircle.Size = UDim2.new(0, config.fovRadius * 2, 0, config.fovRadius * 2)
    
    local target = nil
    if config.aimMode == "FOV" then
        FovCircle.Visible = true
        target = getClosestPlayerInFov()
    elseif config.aimMode == "LowestHealth" then
        FovCircle.Visible = false -- Tắt vòng tròn mờ khi quét máu toàn server
        target = getLowestHealthPlayer()
    else
        FovCircle.Visible = false
    end
    
    if target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end)
-- PART 4: SYSTEM CONTROLS, COMBAT TRIGGERS & VISUAL RESTORATION
local function getClosestTargetDistance()
    local closestEnemy = nil local shortestDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then closestEnemy = p shortestDist = dist end
        end
    end
    return closestEnemy, shortestDist
end

RunService.Heartbeat:Connect(function()
    if config.autoBlock and Player.Character then
        local enemy, distance = getClosestTargetDistance()
        if enemy and distance <= 12 and enemy.Character then
            local enemyHum = enemy.Character:FindFirstChildOfClass("Humanoid")
            if enemyHum and (enemy.Character:FindFirstChild("Slam") or enemy.Character:FindFirstChild("Attacking") or enemyHum.MoveDirection.Magnitude >= 0) then
                local combatFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
                local blockRemote = combatFolder and (combatFolder:FindFirstChild("Block") or combatFolder:FindFirstChild("Guard"))
                if blockRemote and blockRemote:IsA("RemoteEvent") then
                    blockRemote:FireServer(true)
                else
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController() VirtualUser:Button1Down(Vector2.new(0,0))
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if config.autoCombo and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local _, distance = getClosestTargetDistance()
            if distance <= 7 then
                local aEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Attack")
                if aEvent then
                    aEvent:FireServer("M1")
                else
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController() VirtualUser:ClickButton1(Vector2.new(0,0))
                end
                task.wait(0.15)
            end
        end
    end
end)

FovRadiusBox.FocusLost:Connect(function() local num = tonumber(FovRadiusBox.Text) if num then config.fovRadius = num saveConfig() end end)
TextureBtn.MouseButton1Click:Connect(function()
    local id = tonumber(TextureBox.Text)
    if id then
        local assetId = "rbxassetid://" .. id
        MainFrame.Image = assetId config.menuTextureId = assetId saveConfig()
    end
end)

local function refreshVisuals()
    if config.aimMode == "FOV" then
        AimModeBtn.Text = "Chế Độ Aim: VÒNG FOV"
    elseif config.aimMode == "LowestHealth" then
        AimModeBtn.Text = "Chế Độ Aim: ÍT MÁU NHẤT"
    else
        AimModeBtn.Text = "Chế Độ Aim: TẮT"
    end
    
    AutoBlockBtn.Text = config.autoBlock and "Auto Đỡ Đòn Pro: BẬT" or "Auto Đỡ Đòn Pro: TẮT"
    AutoBlockBtn.BackgroundColor3 = config.autoBlock and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(200, 50, 50)
    
    AutoComboBtn.Text = config.autoCombo and "Auto Combo M1: BẬT" or "Auto Combo M1: TẮT"
    AutoComboBtn.BackgroundColor3 = config.autoCombo and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(200, 50, 50)
end

AimModeBtn.MouseButton1Click:Connect(function()
    if config.aimMode == "FOV" then
        config.aimMode = "LowestHealth"
    elseif config.aimMode == "LowestHealth" then
        config.aimMode = "None"
    else
        config.aimMode = "FOV"
    end
    saveConfig() refreshVisuals()
end)

AutoBlockBtn.MouseButton1Click:Connect(function() config.autoBlock = not config.autoBlock saveConfig() refreshVisuals() end)
AutoComboBtn.MouseButton1Click:Connect(function() config.autoCombo = not config.autoCombo saveConfig() refreshVisuals() end)

ToggleMenuButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = MainFrame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
MainFrame.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

refreshVisuals()
print("free hack by dai tay truong TSB V16 Active!")
