local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Cấu hình chi tiết cho từng Skill
local config = {
    Skills = { [Enum.KeyCode.One] = "Camera", [Enum.KeyCode.Two] = "Camera", [Enum.KeyCode.Three] = "Camera", [Enum.KeyCode.Four] = "Camera", [Enum.KeyCode.R] = "Camera" },
    DashMethod = "Root", -- Q luôn là xoay người
    espEnabled = false
}

local targetPlayer = nil
local isLocking = false
local currentMethod = "Camera" -- Phương pháp hiện tại

-- --- UI ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 240, 0, 400); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.new(0,0,0); frame.Active = true; frame.Draggable = true
local avatarImg = Instance.new("ImageLabel", frame); avatarImg.Size = UDim2.new(0, 50, 0, 50); avatarImg.Position = UDim2.new(0.05, 0, 0.05, 0); avatarImg.BackgroundTransparency = 1
local nameLabel = Instance.new("TextLabel", frame); nameLabel.Size = UDim2.new(0, 150, 0, 50); nameLabel.Position = UDim2.new(0.3, 0, 0.05, 0); nameLabel.TextColor3 = Color3.new(1,1,1); nameLabel.BackgroundTransparency = 1

local function addBtn(text, key, y)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, y); btn.Text = text
    btn.MouseButton1Click:Connect(function()
        if key == "ESP" then config.espEnabled = not config.espEnabled
        else config.Skills[key] = (config.Skills[key] == "Camera" and "Root" or "Camera") end
        btn.Text = text .. " (" .. (config.Skills[key] or (config.espEnabled and "ON" or "OFF")) .. ")"
    end)
end
addBtn("Skill 1 (Camera/Root)", Enum.KeyCode.One, 120); addBtn("Skill R (Camera/Root)", Enum.KeyCode.R, 160); addBtn("ESP", "ESP", 200)

-- --- Logic Aim Xử lý Shift Lock ---
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    
    local method = nil
    if input.KeyCode == Enum.KeyCode.Q and not (UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)) then
        method = "Root"; isLocking = true; task.wait(0.4)
    elseif config.Skills[input.KeyCode] then
        method = config.Skills[input.KeyCode]; isLocking = true; task.wait(0.01)
    end
    
    if method then
        currentMethod = method
        task.wait(0.1) -- Giữ lock
        isLocking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not isLocking or not targetPlayer or not targetPlayer.Character then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then return end

    if currentMethod == "Root" and root then
        local flatTarget = Vector3.new(head.Position.X, root.Position.Y, head.Position.Z)
        root.CFrame = CFrame.lookAt(root.Position, flatTarget)
    elseif currentMethod == "Camera" then
        -- Giải quyết Shift Lock: Ép Camera nhìn mục tiêu mà không bị khóa bởi Input game
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    end
end)

-- --- Cập nhật Target & Avatar ---
task.spawn(function()
    while task.wait(0.5) do
        local closest, min = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local d = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if d < min then min = d; closest = p end
            end
        end
        targetPlayer = closest
        if targetPlayer then
            nameLabel.Text = targetPlayer.Name
            pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        end
    end
end)
