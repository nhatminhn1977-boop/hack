local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local aimbotEnabled = false
local espEnabled = false
local targetPlayer = nil
local isCollapsed = false

-- UI Setup
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 400)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local collapseBtn = Instance.new("TextButton", frame)
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(0.85, 0, 0, 0)
collapseBtn.Text = "-"
collapseBtn.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    frame.Size = isCollapsed and UDim2.new(0, 200, 0, 100) or UDim2.new(0, 200, 0, 400)
    frame:FindFirstChild("ListContainer").Visible = not isCollapsed
end)

local listContainer = Instance.new("Frame", frame)
listContainer.Name = "ListContainer"
listContainer.Size = UDim2.new(1, 0, 0.6, 0)
listContainer.Position = UDim2.new(0, 0, 0.1, 0)
listContainer.BackgroundTransparency = 1

local listFrame = Instance.new("ScrollingFrame", listContainer)
listFrame.Size = UDim2.new(1, 0, 1, 0)
listFrame.BackgroundTransparency = 1

local closestBtn = Instance.new("TextButton", frame)
closestBtn.Size = UDim2.new(0.9, 0, 0, 30)
closestBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
closestBtn.Text = "Aim gần nhất"

-- --- Logic Chính ---
local function updatePlayerList()
    for _, child in pairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local yPos = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.Text = "  " .. p.Name
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            
            btn.MouseButton1Click:Connect(function()
                targetPlayer = p -- Chỉ chọn 1 người
                for _, other in pairs(listFrame:GetChildren()) do if other:IsA("TextButton") then other.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end end
                btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            end)
            yPos += 45
        end
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

closestBtn.MouseButton1Click:Connect(function()
    local closest, min = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < min then min = dist; closest = p end
        end
    end
    targetPlayer = closest
    updatePlayerList() -- Refresh UI để hiển thị người đang được aim
end)

-- Render Loop
RunService.RenderStepped:Connect(function()
    if aimbotEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = false end
            local targetPos = Vector3.new(targetPlayer.Character.HumanoidRootPart.Position.X, myRoot.Position.Y, targetPlayer.Character.HumanoidRootPart.Position.Z)
            myRoot.CFrame = CFrame.lookAt(myRoot.Position, targetPos)
        end
    end
end)

-- (Giữ nguyên phần toggle aimbot, esp và cập nhật playerlist từ code cũ vào đây)
