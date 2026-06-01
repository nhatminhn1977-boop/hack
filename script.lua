local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH
local Config = {
    -- SkillMethods: "Camera" hoặc "Root"
    SkillMethods = { [Enum.KeyCode.One]="Camera", [Enum.KeyCode.Two]="Camera", [Enum.KeyCode.Three]="Camera", [Enum.KeyCode.Four]="Camera", [Enum.KeyCode.R]="Camera" },
    ESP = true
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- UI TỐI GIẢN (KHÔNG FONT - ĐỂ TRÁNH LỖI)
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

-- LOGIC AIM (PHƯƠNG PHÁP CŨ: DÙNG AUTOROTATE)
local function setAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Phá Shift Lock ở đây!
    task.wait(duration)
    if hum then hum.AutoRotate = true end -- Trả lại quyền
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    if input.KeyCode == Enum.KeyCode.Q then
        setAim("Root", 0.4) -- Dash xoay người 0.4s
    elseif Config.SkillMethods[input.KeyCode] then
        setAim(Config.SkillMethods[input.KeyCode], 0.1)
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if currentMethod == "Root" and root then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

-- TÌM MỤC TIÊU & ESP
task.spawn(function()
    while task.wait(0.2) do
        local min, closest = 9999, nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local d = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if d < min then min = d; closest = p end
            end
        end
        target = closest
        if target then
            name.Text = target.Name
            pcall(function() avatar.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            -- ESP
            if not target.Character:FindFirstChild("ESP_Highlight") then
                local h = Instance.new("Highlight", target.Character); h.Name = "ESP_Highlight"
            end
        else
            -- Xóa ESP khi mất target
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("ESP_Highlight") then p.Character.ESP_Highlight:Destroy() end
            end
        end
    end
end)
