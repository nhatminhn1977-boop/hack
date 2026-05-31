-- Thêm dòng này vào đầu script để Humanoid không tự ý xoay camera
local humanoid = player.Character:FindFirstChild("Humanoid")
if humanoid then
    humanoid.AutoRotate = false -- Tắt cơ chế tự xoay theo hướng di chuyển của Roblox
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = target.Character.HumanoidRootPart
            
            if myRoot then
                local targetPos = Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z)
                
                -- Thay vì set CFrame trực tiếp (dễ gây lỗi camera), 
                -- chúng ta dùng CFrame.lookAt kết hợp với CFrame hiện tại để xoay
                myRoot.CFrame = CFrame.new(myRoot.Position, targetPos)
            end
        end
    else
        -- Khi tắt aimbot, bật lại để nhân vật di chuyển bình thường
        if humanoid then humanoid.AutoRotate = true end
    end
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Trạng thái Bật/Tắt
local aimbotEnabled = false

-- --- Tạo UI Menu ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 150, 0, 50)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true -- Cho phép kéo thả menu

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.Text = "Auto Aim: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Màu đỏ khi OFF
toggleBtn.Parent = frame

-- --- Logic Bật/Tắt ---
toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled -- Đảo ngược trạng thái
    
    if aimbotEnabled then
        toggleBtn.Text = "Auto Aim: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Màu xanh khi ON
    else
        toggleBtn.Text = "Auto Aim: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

-- --- Logic Auto Aim ---
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local targetPos = otherPlayer.Character.Head.Position
            local myPos = player.Character.HumanoidRootPart.Position
            local distance = (targetPos - myPos).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = otherPlayer
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = target.Character.HumanoidRootPart
            
            if myRoot then
                -- Tính toán vị trí mục tiêu nhưng giữ nguyên độ cao (Y) của nhân vật mình
                local targetPos = Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z)
                
                -- Xoay nhân vật hướng về phía đó
                myRoot.CFrame = CFrame.lookAt(myRoot.Position, targetPos)
            end
        end
    end
end)
