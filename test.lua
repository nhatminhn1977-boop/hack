-- [[ MODERN MINIMALIST FLY GUI ]] --
-- Tối ưu hóa từ lõi FLY GUI V3 của XNEO, mượt mà hơn cho Mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Cấu hình tốc độ bay (Thay thế hệ thống bấm nút + - phức tạp cũ)
local FLY_SPEED = 2.5 

-- Khởi tạo UI bảo mật và hiện đại
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernFlyGui_Protected"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Khung nền (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Màu tối hiện đại
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 140, 0, 45)
MainFrame.Active = true

-- Bo góc cho Khung nền
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

-- Nút bấm duy nhất: FLY Toggle
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Parent = MainFrame
FlyButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75) -- Màu đỏ ban đầu (OFF)
FlyButton.Position = UDim2.new(0.06, 0, 0.12, 0)
FlyButton.Size = UDim2.new(0.88, 0, 0.76, 0)
FlyButton.Font = Enum.Font.GothamBold
FlyButton.Text = "FLY: OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 14

-- Bo góc cho Nút bấm
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = FlyButton

-- Thêm viền mờ cho đẹp mắt
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

--------------------------------------------------------
-- CƠ CHẾ KÉO THẢ (DRAG) HIỆN ĐẠI TƯƠNG THÍCH MOBILE
--------------------------------------------------------
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--------------------------------------------------------
-- LÕI XỬ LÝ BAY CHÍNH (CORE LOGIC)
--------------------------------------------------------
local isFlying = false
local hbConnection = nil

FlyButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not character or not humanoid or not rootPart then return end

    if isFlying then
        -- TRẠNG THÁI: TẮT BAY (OFF)
        isFlying = false
        if hbConnection then hbConnection:Disconnect() end
        
        -[span_4](start_span)- Bật lại các trạng thái vật lý và hoạt ảnh gốc[span_4](end_span)
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            humanoid:SetStateEnabled(state, true)
        end
        [span_5](start_span)humanoid:ChangeState(Enum.HumanoidStateType.Running)[span_5](end_span)
        
        if character:FindFirstChild("Animate") then
            [span_6](start_span)character.Animate.Disabled = false[span_6](end_span)
        end
        for _, track in next, humanoid:GetPlayingAnimationTracks() do
            track:AdjustSpeed(1)
        end
        
        [span_7](start_span)humanoid.PlatformStand = false[span_7](end_span)
        
        -[span_8](start_span)[span_9](start_span)- Dọn dẹp các lực chống trọng lực cũ[span_8](end_span)[span_9](end_span)
        if rootPart:FindFirstChild("MobileFly_Gyro") then rootPart.MobileFly_Gyro:Destroy() end
        if rootPart:FindFirstChild("MobileFly_Velocity") then rootPart.MobileFly_Velocity:Destroy() end
        
        -- Cập nhật Giao diện
        FlyButton.Text = "FLY: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    else
        -- TRẠNG THÁI: BẬT BAY (ON)
        isFlying = true
        FlyButton.Text = "FLY: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(75, 225, 75) -- Đổi sang màu xanh lá
        
        -[span_10](start_span)- Khóa hoạt ảnh (Animation) để tránh lỗi giật hình khi bay[span_10](end_span)
        if character:FindFirstChild("Animate") then
            [span_11](start_span)character.Animate.Disabled = true[span_11](end_span)
        end
        for _, track in next, humanoid:GetPlayingAnimationTracks() do
            [span_12](start_span)track:AdjustSpeed(0)[span_12](end_span)
        end
        
        -[span_13](start_span)- Tắt các trạng thái va chạm vật lý mặt đất, ép nhân vật vào trạng thái bơi[span_13](end_span)
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            [span_14](start_span)humanoid:SetStateEnabled(state, false)[span_14](end_span)
        end
        [span_15](start_span)humanoid:ChangeState(Enum.HumanoidStateType.Swimming)[span_15](end_span)
        [span_16](start_span)[span_17](start_span)humanoid.PlatformStand = true[span_16](end_span)[span_17](end_span)
        
        -[span_18](start_span)[span_19](start_span)- Tạo Gyro giữ thăng bằng chống lật và điều hướng theo góc nhìn Camera[span_18](end_span)[span_19](end_span)
        local bg = Instance.new("BodyGyro")
        bg.Name = "MobileFly_Gyro"
        bg.P = 9e4
        [span_20](start_span)[span_21](start_span)bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)[span_20](end_span)[span_21](end_span)
        [span_22](start_span)[span_23](start_span)bg.cframe = rootPart.CFrame[span_22](end_span)[span_23](end_span)
        bg.Parent = rootPart
        
        -[span_24](start_span)[span_25](start_span)- Tạo Vận tốc triệt tiêu trọng lực giúp nhân vật đứng im lơ lửng khi thả Joystick[span_24](end_span)[span_25](end_span)
        local bv = Instance.new("BodyVelocity")
        bv.Name = "MobileFly_Velocity"
        [span_26](start_span)[span_27](start_span)bv.velocity = Vector3.new(0, 0.1, 0)[span_26](end_span)[span_27](end_span)
        [span_28](start_span)[span_29](start_span)bv.maxForce = Vector3.new(9e9, 9e9, 9e9)[span_28](end_span)[span_29](end_span)
        bv.Parent = rootPart
        
        -[span_30](start_span)[span_31](start_span)- Vòng lặp đồng bộ di chuyển mượt mà thông qua Joystick (MoveDirection)[span_30](end_span)[span_31](end_span)
        hbConnection = RunService.Heartbeat:Connect(function()
            if isFlying and character and humanoid and humanoid.Parent and rootPart then
                -[span_32](start_span)[span_33](start_span)- Luôn giữ góc người khớp với hướng xoay Camera[span_32](end_span)[span_33](end_span)
                bg.cframe = workspace.CurrentCamera.CoordinateFrame
                
                -[span_34](start_span)[span_35](start_span)- Lõi Mobile: Đọc Joystick, nếu có đẩy hướng thì nhân vật sẽ di chuyển[span_34](end_span)[span_35](end_span)
                if humanoid.MoveDirection.Magnitude > 0 then
                    [span_36](start_span)[span_37](start_span)character:TranslateBy(humanoid.MoveDirection * (FLY_SPEED / 5))[span_36](end_span)[span_37](end_span)
                end
            end
        end)
    end
end)

-- Tự động reset trạng thái nếu nhân vật bị reset/chết
LocalPlayer.CharacterAdded:Connect(function()
    isFlying = false
    if hbConnection then hbConnection:Disconnect() end
end)

-- Thông báo kích hoạt thành công
game:GetService("StarterGui"):SetCore("SendNotification", { 
	Title = "Modern Fly GUI";
	Text = "Đã tối ưu hóa cho Mobile!";
	Duration = 3
})
