local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Cấu hình
local config = {
    Skills = { [Enum.KeyCode.One] = "Camera", [Enum.KeyCode.Two] = "Camera", [Enum.KeyCode.Three] = "Camera", [Enum.KeyCode.Four] = "Camera", [Enum.KeyCode.R] = "Camera" },
    espEnabled = false
}

local targetPlayer = nil
local isLocking = false
local currentMethod = "Camera" 

-- --- UI ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 240, 0, 300); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.new(0,0,0); frame.Active = true; frame.Draggable = true
local avatarImg = Instance.new("ImageLabel", frame); avatarImg.Size = UDim2.new(0, 50, 0, 50); avatarImg.Position = UDim2.new(0.05, 0, 0.05, 0); avatarImg.BackgroundTransparency = 1
local nameLabel = Instance.new("TextLabel", frame); nameLabel.Size = UDim2.new(0, 150, 0, 50); nameLabel.Position = UDim2.new(0.3, 0, 0.05, 0); nameLabel.TextColor3 = Color3.new(1,1,1); nameLabel.BackgroundTransparency = 1

-- --- Logic Aim Nâng Cao ---
local function startAim(method, duration)
    isLocking = true
    currentMethod = method
    task.wait(duration)
    isLocking = false -- Reset ngay lập tức sau thời gian quy định
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    
    -- Xử lý Dash (Q) - Chỉ xoay người trong 0.4s
    if input.KeyCode == Enum.KeyCode.Q then
        local moving = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
        if not moving then
            startAim("Root", 0.4)
        end
    -- Xử lý Skills
    elseif config.Skills[input.KeyCode] then
        startAim(config.Skills[input.KeyCode], 0.1) -- Aim nhanh cho chiêu thức
    end
end)

RunService.RenderStepped:Connect(function()
    if not isLocking or not targetPlayer or not targetPlayer.Character then return end
    
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head or not root then return end

    if currentMethod == "Root" then
        -- Xoay người (Phá Shift Lock để Dash)
        local flatTarget = Vector3.new(head.Position.X, root.Position.Y, head.Position.Z)
        root.CFrame = CFrame.lookAt(root.Position, flatTarget)
    elseif currentMethod == "Camera" then
        -- Xoay Cam (Aim Skill bình thường)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    end
end)

-- --- Cập nhật Target ---
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
