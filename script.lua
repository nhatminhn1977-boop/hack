local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Cấu hình Setting
local settings = {
    AimDash = true,
    Aim1 = true, Aim2 = true, Aim3 = true, Aim4 = true, AimR = true,
    espEnabled = false
}

local targetPlayer = nil
local isLocking = false

-- --- 1. UI Setup (Thiết kế bo góc hiện đại) ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 250, 0, 350); frame.Position = UDim2.new(0.05, 0, 0.3, 0); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Header
local title = Instance.new("TextLabel", frame); title.Size = UDim2.new(1, 0, 0, 40); title.Text = "COMBAT ASSIST"; title.TextColor3 = Color3.new(1, 1, 1); title.BackgroundTransparency = 1; title.Font = Enum.Font.Bold

-- Target Info (Avatar + Name)
local targetFrame = Instance.new("Frame", frame); targetFrame.Size = UDim2.new(0.9, 0, 0, 60); targetFrame.Position = UDim2.new(0.05, 0, 0.15, 0); targetFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", targetFrame)
local avatar = Instance.new("ImageLabel", targetFrame); avatar.Size = UDim2.new(0, 50, 0, 50); avatar.Position = UDim2.new(0, 5, 0, 5); avatar.BackgroundTransparency = 1
local nameLabel = Instance.new("TextLabel", targetFrame); nameLabel.Size = UDim2.new(0, 150, 0, 50); nameLabel.Position = UDim2.new(0, 60, 0, 0); nameLabel.Text = "No Target"; nameLabel.TextColor3 = Color3.new(1, 1, 1); nameLabel.BackgroundTransparency = 1

-- Setting Buttons (Hàm tạo nút)
local function createToggle(text, settingKey, yPos)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, yPos); btn.Text = text .. ": ON"; btn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        btn.Text = text .. (settings[settingKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
    end)
end

createToggle("Aim Dash (Q)", "AimDash", 150); createToggle("Aim Skills (1-4, R)", "Aim1", 190); createToggle("ESP", "espEnabled", 230)

-- --- 2. Logic ---
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
        if targetPlayer then
            nameLabel.Text = targetPlayer.Name
            pcall(function() avatar.Image = Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        else
            nameLabel.Text = "No Target"
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    
    local isSkill = (settings.Aim1 and ({[Enum.KeyCode.One]=true, [Enum.KeyCode.Two]=true, [Enum.KeyCode.Three]=true, [Enum.KeyCode.Four]=true, [Enum.KeyCode.R]=true})[input.KeyCode])
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
