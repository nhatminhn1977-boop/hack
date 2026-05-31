local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- Cấu hình & Biến ---
local aimbotEnabled = false
local espEnabled = false
local targetPlayer = nil

-- --- 1. Tạo Giao diện UI ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "ProMenu"
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 350)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "MENU HỖ TRỢ"
title.TextColor3 = Color3.new(1, 1, 1)

local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(1, 0, 0.6, 0)
listFrame.Position = UDim2.new(0, 0, 0.1, 0)
listFrame.BackgroundTransparency = 1

local toggleAimBtn = Instance.new("TextButton", frame)
toggleAimBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleAimBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
toggleAimBtn.Text = "Auto Aim: OFF"
toggleAimBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

local toggleEspBtn = Instance.new("TextButton", frame)
toggleEspBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleEspBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
toggleEspBtn.Text = "ESP: OFF"
toggleEspBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)

-- --- 2. Logic cập nhật danh sách ---
local function updatePlayerList()
    for _, child in pairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local yPos = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.Text = p.Name
            btn.MouseButton1Click:Connect(function()
                targetPlayer = (targetPlayer == p) and nil or p
                btn.BackgroundColor3 = targetPlayer == p and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
            end)
            yPos += 35
        end
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- --- 3. Các nút Bật/Tắt ---
toggleAimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleAimBtn.Text = aimbotEnabled and "Auto Aim: ON" or "Auto Aim: OFF"
    toggleAimBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

toggleEspBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleEspBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    toggleEspBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
end)

-- --- 4. Logic Xử lý chính (RenderStepped) ---
RunService.RenderStepped:Connect(function()
    -- Logic ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local highlight = p.Character:FindFirstChild("ESP_Highlight")
                local nameTag = head:FindFirstChild("ESP_NameTag")
                
                if espEnabled then
                    if not highlight then 
                        highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "ESP_Highlight"
                    end
                    if not nameTag then
                        nameTag = Instance.new("BillboardGui", head)
                        nameTag.Name = "ESP_NameTag"
                        nameTag.AlwaysOnTop = true
                        nameTag.StudsOffset = Vector3.new(0, 2, 0)
                        local label = Instance.new("TextLabel", nameTag)
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.new(1, 1, 0)
                        label.Text = p.Name
                    end
                    highlight.Enabled = true
                    nameTag.Enabled = true
                else
                    if highlight then highlight.Enabled = false end
                    if nameTag then nameTag.Enabled = false end
                end
            end
        end
    end

    -- Logic Aimbot
    if aimbotEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = false end
            
            local targetPos = Vector3.new(targetPlayer.Character.HumanoidRootPart.Position.X, myRoot.Position.Y, targetPlayer.Character.HumanoidRootPart.Position.Z)
            myRoot.CFrame = CFrame.lookAt(myRoot.Position, targetPos)
        end
    elseif player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.AutoRotate = true
    end
end)
