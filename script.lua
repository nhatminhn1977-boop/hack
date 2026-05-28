local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- 1. Tạo GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.5, -125, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(0.8, 0, 0, 40)
inputBox.Position = UDim2.new(0.1, 0, 0.2, 0)
inputBox.PlaceholderText = "Nhập ID vật phẩm..."

local spawnBtn = Instance.new("TextButton", frame)
spawnBtn.Size = UDim2.new(0.8, 0, 0, 40)
spawnBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
spawnBtn.Text = "Spawn Item"
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

-- 2. Logic Kéo thả (Draggable)
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 3. Logic Spawn Item
spawnBtn.MouseButton1Click:Connect(function()
    local itemId = tonumber(inputBox.Text)
    if itemId then
        -- Lưu ý: Việc spawn item thường yêu cầu gọi RemoteEvent của game
        -- Mỗi game có một "tên" RemoteEvent khác nhau (ví dụ: game.ReplicatedStorage.SpawnItem)
        print("Đang cố gắng spawn vật phẩm ID: " .. itemId)
        
        -- Mẫu ví dụ: game.ReplicatedStorage.RemoteEvent:FireServer("Spawn", itemId)
    else
        warn("Vui lòng nhập ID hợp lệ!")
    end
end)
