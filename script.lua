-- SCRIPT AIM BOT PRIME
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH CÁC PHÍM SKILL
local Config = {
    -- Tùy chọn: "Camera" hoặc "Root"
    SkillMethods = { [Enum.KeyCode.One]="Camera", [Enum.KeyCode.Two]="Camera", [Enum.KeyCode.Three]="Camera", [Enum.KeyCode.Four]="Camera", [Enum.KeyCode.R]="Camera" },
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- --- UI TỐI GIẢN (KHÔNG FONT ĐỂ TRÁNH LỖI) ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 200, 0, 300); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.new(0,0,0); frame.Active = true; frame.Draggable = true
local avatar = Instance.new("ImageLabel", frame); avatar.Size = UDim2.new(0, 50, 0, 50); avatar.Position = UDim2.new(0.1, 0, 0.05, 0)
local name = Instance.new("TextLabel", frame); name.Size = UDim2.new(0, 100, 0, 50); name.Position = UDim2.new(0.4, 0, 0.05, 0); name.TextColor3 = Color3.new(1,1,1); name.BackgroundTransparency = 1

local function createBtn(key)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, 100 + (key.Value * 10))
    btn.Text = "Skill " .. key.Name .. ": " .. Config.SkillMethods[key]
    btn.MouseButton1Click:Connect(function()
        Config.SkillMethods[key] = (Config.SkillMethods[key] == "Camera" and "Root" or "Camera")
        btn.Text = "Skill " .. key.Name .. ": " .. Config.SkillMethods[key]
    end)
end
createBtn(Enum.KeyCode.One); createBtn(Enum.KeyCode.Two); createBtn(Enum.KeyCode.Three); createBtn(Enum.KeyCode.Four); createBtn(Enum.KeyCode.R)

-- --- LOGIC AIM ---
local function startAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Phá Shift Lock
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    -- DASH: Xoay người (Root), Aim 0.4s, bỏ qua nếu đang Side Dash
    if input.KeyCode == Enum.KeyCode.Q then
        local side = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
        if not side then startAim("Root", 0.4) end
    -- SKILLS: Tùy chỉnh
    elseif Config.SkillMethods[input.KeyCode] then
        startAim(Config.SkillMethods[input.KeyCode], 0.1)
    end
end)

-- --- VÒNG LẶP RENDER ---
RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if currentMethod == "Root" and root then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

-- --- TÌM TARGET & ESP (RESET 0.2S) ---
task.spawn(function()
    while task.wait(0.2) do
        local min, closest = 9999, nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if dist < min then min = dist; closest = p end
            end
        end
        target = closest
        if target then
            name.Text = target.Name
            pcall(function() avatar.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            if not target.Character:FindFirstChild("ESP") then Instance.new("Highlight", target.Character).Name = "ESP" end
        else
            for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESP") then p.Character.ESP:Destroy() end end
        end
    end
end)
