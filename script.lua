local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local settings = { AimDash = true, AimSkills = true, espEnabled = false }
local targetPlayer = nil
local isLocking = false

-- --- UI Setup ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "CombatAssistUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 400); frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "COMBAT ASSIST"; title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1; title.Font = Enum.Font.Bold

-- Container chứa các nút (Sử dụng UIListLayout để không bị chồng chéo)
local container = Instance.new("Frame", frame)
container.Size = UDim2.new(0.9, 0, 0.8, 0); container.Position = UDim2.new(0.05, 0, 0.15, 0)
container.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", container); layout.Padding = UDim.new(0, 10)

-- Target Display
local targetLabel = Instance.new("TextLabel", container)
targetLabel.Size = UDim2.new(1, 0, 0, 40); targetLabel.Text = "Target: None"; targetLabel.TextColor3 = Color3.new(1, 1, 0)
targetLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", targetLabel)

-- Hàm tạo nút
local function createButton(text, settingKey)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 40); btn.Text = text .. ": ON"
    btn.BackgroundColor3 = Color3.fromRGB(60, 180, 60); Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        btn.Text = text .. (settings[settingKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
    end)
end

createButton("Aim Dash (Q)", "AimDash")
createButton("Aim Skills", "AimSkills")
createButton("ESP", "espEnabled")

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
            hl.Name = "ESP_H"; hl.Enabled = settings.espEnabled
        end
    end
end)
