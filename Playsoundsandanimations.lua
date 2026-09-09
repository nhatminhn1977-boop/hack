local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Khởi tạo UI
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "AssetPlayerUI"
gui.ResetOnSpawn = false
gui.Parent = parentGui

-- Khung chứa chính (Frame)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 190)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Ô nhập ID
local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(1, -20, 0, 35)
idBox.Position = UDim2.new(0, 10, 0, 10)
idBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.PlaceholderText = "Nhập ID (Ví dụ: 12345678)..."
idBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
idBox.Font = Enum.Font.Gotham
idBox.TextSize = 12
idBox.Text = ""
Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6)

-- Nút Play Sound
local soundBtn = Instance.new("TextButton", frame)
soundBtn.Size = UDim2.new(1, -20, 0, 32)
soundBtn.Position = UDim2.new(0, 10, 0, 52)
soundBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
soundBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
soundBtn.Font = Enum.Font.GothamBold
soundBtn.TextSize = 12
soundBtn.Text = "🔊 Play Sound"
Instance.new("UICorner", soundBtn).CornerRadius = UDim.new(0, 6)

-- Nút Play Animation (Priority Cao Nhất)
local animBtn = Instance.new("TextButton", frame)
animBtn.Size = UDim2.new(1, -20, 0, 32)
animBtn.Position = UDim2.new(0, 10, 0, 90)
animBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
animBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
animBtn.Font = Enum.Font.GothamBold
animBtn.TextSize = 12
animBtn.Text = "💃 Play Animation (Action4)"
Instance.new("UICorner", animBtn).CornerRadius = UDim.new(0, 6)

-- Nút Stop Animation
local stopAnimBtn = Instance.new("TextButton", frame)
stopAnimBtn.Size = UDim2.new(1, -20, 0, 32)
stopAnimBtn.Position = UDim2.new(0, 10, 0, 128)
stopAnimBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
stopAnimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopAnimBtn.Font = Enum.Font.GothamBold
stopAnimBtn.TextSize = 12
stopAnimBtn.Text = "⏹️ Stop Animation"
Instance.new("UICorner", stopAnimBtn).CornerRadius = UDim.new(0, 6)

-- Dòng hiển thị trạng thái
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 165)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.Text = "Sẵn sàng"

-- [ LOGIC KÉO THẢ UI ]
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Biến lưu trữ đối tượng đang phát
local currentSound = nil
local currentAnimTrack = nil

-- Hàm làm sạch ID chỉ lấy chữ số
local function cleanId(str)
    return str:match("%d+") or ""
end

-- 1. LOGIC PLAY SOUND
soundBtn.MouseButton1Click:Connect(function()
    local rawId = cleanId(idBox.Text)
    if rawId == "" then
        statusLabel.Text = "Lỗi: ID Sound không hợp lệ!"
        statusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        return
    end

    if currentSound then
        currentSound:Destroy()
    end

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. rawId
    sound.Volume = 1
    sound.Parent = workspace
    sound:Play()
    currentSound = sound

    statusLabel.Text = "Đang phát Sound ID: " .. rawId
    statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
end)

-- 2. LOGIC PLAY ANIMATION (PRIORITY CAO NHẤT)
animBtn.MouseButton1Click:Connect(function()
    local rawId = cleanId(idBox.Text)
    if rawId == "" then
        statusLabel.Text = "Lỗi: ID Animation không hợp lệ!"
        statusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        return
    end

    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 2)
    if not animator then return end

    -- Dừng Animation cũ nếu đang phát
    if currentAnimTrack then
        currentAnimTrack:Stop()
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. rawId

    pcall(function()
        currentAnimTrack = animator:LoadAnimation(anim)
        -- Thiết lập Priority ở mức cao nhất (Action4)
        currentAnimTrack.Priority = Enum.AnimationPriority.Action4
        currentAnimTrack:Play()

        statusLabel.Text = "Đang phát Anim ID: " .. rawId
        statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    end)
end)

-- 3. LOGIC STOP ANIMATION
stopAnimBtn.MouseButton1Click:Connect(function()
    if currentAnimTrack then
        currentAnimTrack:Stop()
        currentAnimTrack = nil
        statusLabel.Text = "Đã dừng Animation"
        statusLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
    else
        statusLabel.Text = "Không có Animation nào đang chạy"
        statusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)
