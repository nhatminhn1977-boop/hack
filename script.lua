local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Cấu hình
local settings = { AimDash = true, AimSkills = true, espEnabled = false }
local targetPlayer = nil
local isLocking = false

-- --- UI Setup (Đơn giản hóa để không lỗi Font) ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "CombatAssist"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "COMBAT ASSIST"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
-- Đã bỏ Enum.Font.Bold để tránh lỗi Font

-- Hàm tạo nút bấm thủ công
local function createBtn(text, yPos, key)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. ": ON"
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    btn.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        btn.Text = text .. (settings[key] and ": ON" or ": OFF")
        btn.BackgroundColor3 = settings[key] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    end)
end

createBtn("Aim Dash", 50, "AimDash")
createBtn("Aim Skills", 90, "AimSkills")
createBtn("ESP", 130, "espEnabled")

-- --- Logic Cốt lõi ---
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
