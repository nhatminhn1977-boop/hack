local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local settings = { AimDash = true, AimSkills = true, espEnabled = false }
local targetPlayer = nil
local isLocking = false
local isDashing = false

-- --- UI ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 200, 0, 230); frame.Position = UDim2.new(0.05, 0, 0.3, 0); frame.BackgroundColor3 = Color3.new(0,0,0); frame.Active = true; frame.Draggable = true
local infoLabel = Instance.new("TextLabel", frame); infoLabel.Size = UDim2.new(1, 0, 0, 40); infoLabel.Text = "Target: None"; infoLabel.TextColor3 = Color3.new(1,1,1); infoLabel.BackgroundTransparency = 1
local avatarImg = Instance.new("ImageLabel", frame); avatarImg.Size = UDim2.new(0, 40, 0, 40); avatarImg.Position = UDim2.new(0.4, 0, 0.2, 0); avatarImg.BackgroundTransparency = 1

local function addBtn(text, key, y)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, y); btn.Text = text .. ": ON"; btn.MouseButton1Click:Connect(function() settings[key] = not settings[key]; btn.Text = text .. (settings[key] and ": ON" or ": OFF") end)
end
addBtn("Dash", "AimDash", 90); addBtn("Skills", "AimSkills", 130); addBtn("ESP", "espEnabled", 170)

-- --- Logic ---
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
            infoLabel.Text = "Target: " .. targetPlayer.Name
            pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    local isSkill = (settings.AimSkills and ({[Enum.KeyCode.One]=true, [Enum.KeyCode.Two]=true, [Enum.KeyCode.Three]=true, [Enum.KeyCode.Four]=true, [Enum.KeyCode.R]=true})[input.KeyCode])
    local isDash = (settings.AimDash and input.KeyCode == Enum.KeyCode.Q and not (UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)))
    
    if isSkill or isDash then
        isLocking = true
        isDashing = isDash
        task.wait(isDash and 0.4 or 0.01)
        isLocking = false
        isDashing = false
    end
end)

RunService.RenderStepped:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    
    if isLocking and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        if isDashing then
            -- XOAY NGƯỜI (Aim Ngang): Chỉ thay đổi trục X và Z để giữ độ cao không đổi
            if root then
                local targetPos = targetPlayer.Character.Head.Position
                local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                root.CFrame = CFrame.lookAt(root.Position, flatTarget)
                if hum then hum.AutoRotate = false end
            end
        else
            -- Aim bình thường (Camera)
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPlayer.Character.Head.Position)
            if hum then hum.AutoRotate = true end
        end
    else
        if hum then hum.AutoRotate = true end
    end

    -- ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local hl = p.Character:FindFirstChild("ESP_H") or Instance.new("Highlight", p.Character)
            hl.Enabled = settings.espEnabled
        end
    end
end)
