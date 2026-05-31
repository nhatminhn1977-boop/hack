local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local targetPlayer = nil
local isLocking = false
local espEnabled = false
local isCollapsed = false

-- --- 1. Tạo UI ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 300)
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
    frame.Size = isCollapsed and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 300)
    for _, child in pairs(frame:GetChildren()) do if child ~= collapseBtn then child.Visible = not isCollapsed end end
end)

local aimBtn = Instance.new("TextButton", frame)
aimBtn.Size = UDim2.new(0.9, 0, 0, 40)
aimBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
aimBtn.Text = "Chọn Aim Gần Nhất"
aimBtn.MouseButton1Click:Connect(function()
    local closest, min = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
            if dist < min then min = dist; closest = p end
        end
    end
    targetPlayer = closest
    aimBtn.Text = targetPlayer and ("Target: " .. targetPlayer.Name) or "Không tìm thấy"
end)

local espBtn = Instance.new("TextButton", frame)
espBtn.Size = UDim2.new(0.9, 0, 0, 40)
espBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
espBtn.Text = "ESP: OFF"
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
end)

-- --- 2. Logic ESP (Highlight & NameTag) ---
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hl = p.Character:FindFirstChild("ESP_H") or Instance.new("Highlight", p.Character)
            hl.Name = "ESP_H"
            
            local tag = head:FindFirstChild("ESP_T") or Instance.new("BillboardGui", head)
            tag.Name = "ESP_T"
            tag.Size = UDim2.new(0, 100, 0, 50)
            tag.AlwaysOnTop = true
            tag.Enabled = espEnabled
            
            if not tag:FindFirstChild("Label") then
                local l = Instance.new("TextLabel", tag)
                l.Name = "Label"; l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1
                l.TextColor3 = Color3.new(1,1,0)
            end
            
            hl.Enabled = espEnabled
            tag.Label.Text = p.Name
        end
    end

    -- --- 3. Logic Lock Camera Skill ---
    if isLocking and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPlayer.Character.Head.Position)
    end
end)

-- --- 4. Lắng nghe Skill Keys ---
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not targetPlayer then return end
    local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R,Enum.KeyCode.Q}
    for _, key in pairs(keys) do
        if input.KeyCode == key then
            isLocking = true
            task.wait(0.01)
            isLocking = false
            break
        end
    end
end)
