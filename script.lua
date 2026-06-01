local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình Aim chi tiết
local cfg = {
    Q = "Root", ["1"] = "Camera", ["2"] = "Camera", ["3"] = "Camera", ["4"] = "Camera", ["R"] = "Camera",
    espEnabled = false
}

local target = nil
local isLocking = false
local dashDuration = 0.4

-- UI Setup
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 250, 0, 400); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.new(0,0,0); frame.Active = true; frame.Draggable = true
local avatarImg = Instance.new("ImageLabel", frame); avatarImg.Size = UDim2.new(0, 50, 0, 50); avatarImg.Position = UDim2.new(0.05, 0, 0.05, 0)
local nameLabel = Instance.new("TextLabel", frame); nameLabel.Size = UDim2.new(0, 150, 0, 50); nameLabel.Position = UDim2.new(0.3, 0, 0.05, 0); nameLabel.Text = "No Target"; nameLabel.TextColor3 = Color3.new(1,1,1); nameLabel.BackgroundTransparency = 1

local function createToggle(name, key, y)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, y); btn.Text = name .. ": " .. cfg[key]
    btn.MouseButton1Click:Connect(function()
        cfg[key] = (cfg[key] == "Camera" and "Root" or "Camera")
        btn.Text = name .. ": " .. cfg[key]
    end)
end

createToggle("Dash (Q)", "Q", 120); createToggle("Skill 1", "1", 160); createToggle("Skill 2", "2", 200); createToggle("Skill 3", "3", 240); createToggle("Skill 4", "4", 280); createToggle("Skill R", "R", 320)

-- Logic
task.spawn(function()
    while task.wait(0.5) do
        local closest, min = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local d = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if d < min then min = d; closest = p end
            end
        end
        target = closest
        if target then nameLabel.Text = target.Name; pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end) end
    end
end)

local activeMethod = nil
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    local keyMap = {[Enum.KeyCode.Q]="Q", [Enum.KeyCode.One]="1", [Enum.KeyCode.Two]="2", [Enum.KeyCode.Three]="3", [Enum.KeyCode.Four]="4", [Enum.KeyCode.R]="R"}
    local k = keyMap[input.KeyCode]
    
    if k then
        activeMethod = cfg[k]
        isLocking = true
        task.wait(k == "Q" and dashDuration or 0.1)
        isLocking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not isLocking or not target or not target.Character:FindFirstChild("Head") then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetPos = target.Character.Head.Position
    
    if activeMethod == "Root" and root then
        -- Root Aim: Xoay nhân vật bỏ qua Shift Lock
        local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        root.CFrame = CFrame.lookAt(root.Position, flatTarget)
        player.Character.Humanoid.AutoRotate = false
    elseif activeMethod == "Camera" then
        -- Camera Aim: Ép camera nhìn theo
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        player.Character.Humanoid.AutoRotate = true
    end
end)
