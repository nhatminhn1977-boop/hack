-- [[ ULTRA-SAFE MOBILE FLY GUI ]] --
-- Đã sửa lỗi ẩn UI, lỗi lag LocalPlayer và lỗi kéo thả trên các Executor Mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 1. Đảm bảo LocalPlayer đã tải xong hoàn toàn trước khi chạy tiếp
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

-- Cấu hình tốc độ bay mặc định
local FLY_SPEED = 2.5 

-- 2. Khởi tạo UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalFly_Target"
ScreenGui.ResetOnSpawn = false

-- Giải pháp chống Anti-Cheat xóa UI: Ưu tiên dùng gethui() hoặc CoreGui nếu Executor hỗ trợ
local targetParent = nil
if gethui then
    targetParent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    targetParent = game:GetService("CoreGui")
else
    targetParent = LocalPlayer:WaitForChild("PlayerGui")
end
ScreenGui.Parent = targetParent

-- Khung nền chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.15, 0, 0.45, 0)
MainFrame.Size = UDim2.new(0, 140, 0, 45)
MainFrame.Active = true

-- Bo góc khung nền
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

-- Nút bấm FLY
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Parent = MainFrame
FlyButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75) -- Màu đỏ mặc định (OFF)
FlyButton.Position = UDim2.new(0.06, 0, 0.12, 0)
FlyButton.Size = UDim2.new(0.88, 0, 0.76, 0)
FlyButton.Font = Enum.Font.SourceSansBold -- Dùng font gốc chuẩn, không lo lỗi font
FlyButton.Text = "FLY: OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 15

-- Bo góc nút bấm
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = FlyButton

--------------------------------------------------------
-- HỆ THỐNG KÉO THẢ (DRAG) 100% KHÔNG LỖI TRÊN MOBILE
--------------------------------------------------------
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--------------------------------------------------------
-- LÕI XỬ LÝ BAY (CORE FLY LOGIC)
--------------------------------------------------------
local isFlying = false
local hbConnection = nil

-- Sử dụng sự kiện .Activated (Tối ưu tốt nhất cho cả Chạm tay cảm ứng và Click chuột)
FlyButton.Activated:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not character or not humanoid or not rootPart then return end

    if isFlying then
        -- TẮT CHẾ ĐỘ BAY
        isFlying = false
        if hbConnection then hbConnection:Disconnect() end
        
        -- Trả lại trạng thái vật lý
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            pcall(function() humanoid:SetStateEnabled(state, true) end)
        end
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        if character:FindFirstChild("Animate") then
            character.Animate.Disabled = false
        end
        for _, track in next, humanoid:GetPlayingAnimationTracks() do
            track:AdjustSpeed(1)
        end
        
        humanoid.PlatformStand = false
        
        if rootPart:FindFirstChild("MobileFly_Gyro") then rootPart.MobileFly_Gyro:Destroy() end
        if rootPart:FindFirstChild("MobileFly_Velocity") then rootPart.MobileFly_Velocity:Destroy() end
        
        FlyButton.Text = "FLY: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    else
        -- BẬT CHẾ ĐỘ BAY
        isFlying = true
        FlyButton.Text = "FLY: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(75, 225, 75)
        
        if character:FindFirstChild("Animate") then
            character.Animate.Disabled = true
        end
        for _, track in next, humanoid:GetPlayingAnimationTracks() do
            track:AdjustSpeed(0)
        end
        
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            pcall(function() humanoid:SetStateEnabled(state, false) end)
        end
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        humanoid.PlatformStand = true
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "MobileFly_Gyro"
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = rootPart.CFrame
        bg.Parent = rootPart
        
        local bv = Instance.new("BodyVelocity")
        bv.Name = "MobileFly_Velocity"
        bv.velocity = Vector3.new(0, 0.1, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = rootPart
        
        -- Vòng lặp kiểm tra hướng di chuyển từ Joystick di động
        hbConnection = RunService.Heartbeat:Connect(function()
            if isFlying and character and humanoid and humanoid.Parent and rootPart then
                bg.cframe = workspace.CurrentCamera.CoordinateFrame
                if humanoid.MoveDirection.Magnitude > 0 then
                    character:TranslateBy(humanoid.MoveDirection * (FLY_SPEED / 5))
                end
            end
        end)
    end
end)

-- Tự động dọn dẹp biến và đưa nút về OFF khi nhân vật bị chết/reset
LocalPlayer.CharacterAdded:Connect(function()
    isFlying = false
    if hbConnection then hbConnection:Disconnect() end
    FlyButton.Text = "FLY: OFF"
    FlyButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
end)
