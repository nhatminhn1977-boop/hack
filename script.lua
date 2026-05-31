local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Cấu hình
local settings = { AimDash = true, AimSkills = true, espEnabled = false }
local targetPlayer = nil
local isLocking = false

-- --- UI Setup (Sửa lỗi Enum.Font) ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "CombatAssist"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "COMBAT ASSIST"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold -- SỬA LỖI TẠI ĐÂY

local targetLabel = Instance.new("TextLabel", frame)
targetLabel.Size = UDim2.new(0.9, 0, 0, 40)
targetLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
targetLabel.Text = "Target: Loading..."
targetLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
targetLabel.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", targetLabel)

-- Hàm tạo nút
local function createBtn(text, yPos, key)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. ": ON"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        btn.Text = text .. (settings[key] and ": ON" or ": OFF")
        btn.BackgroundColor3 = settings[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    return btn
end

createBtn("Aim Dash (Q)", 120, "AimDash")
createBtn("Aim Skills", 170, "AimSkills")
createBtn("ESP", 220, "espEnabled")

-- --- Logic ---
task.spawn(function()
    while task.wait(0.5) do
        local closest, min = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if dist < min then min = dist; closest = p end
            end
        end
        targetPlayer = closest
        targetLabel.Text = targetPlayer and ("Target: " .. targetPlayer.Name) or "Target: None"
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    
    local isSkill = (settings.AimSkills and ({[Enum.KeyCode.One]=true, [Enum.KeyCode.Two]=true, [Enum.KeyCode.Three]=true, [Enum.KeyCode.Four]=true, [Enum.KeyCode.R]=true})[input.KeyCode])
    local isDash = (settings.AimDash and input.KeyCode == Enum.KeyCode.Q and not (UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)))
    
    if isSkill or isDash then
        isLocking = true
        task.wait(isDash and 0.3 or 0.01)
        isLocking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocking and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPlayer.Character.Head.Position)
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local hl = p.Character:FindFirstChild("ESP_H") or Instance.new("Highlight", p.Character)
            hl.Enabled = settings.espEnabled
        end
    end
end)
