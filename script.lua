local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH PRIME
local Config = {
    SkillMethods = { [Enum.KeyCode.One]="Camera", [Enum.KeyCode.Two]="Camera", [Enum.KeyCode.Three]="Camera", [Enum.KeyCode.Four]="Camera", [Enum.KeyCode.R]="Camera" },
    ESP = true
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- UI PRIME
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 220, 0, 350); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true
local avatar = Instance.new("ImageLabel", frame); avatar.Size = UDim2.new(0, 50, 0, 50); avatar.Position = UDim2.new(0.05, 0, 0.05, 0)
local name = Instance.new("TextLabel", frame); name.Size = UDim2.new(0, 150, 0, 50); name.Position = UDim2.new(0.35, 0, 0.05, 0); name.TextColor3 = Color3.new(1,1,1); name.BackgroundTransparency = 1

local function addButton(key)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = UDim2.new(0.05, 0, 0, 110 + (key.Value * 15))
    btn.Text = "Skill " .. key.Name .. ": " .. Config.SkillMethods[key]
    btn.MouseButton1Click:Connect(function()
        Config.SkillMethods[key] = (Config.SkillMethods[key] == "Camera" and "Root" or "Camera")
        btn.Text = "Skill " .. key.Name .. ": " .. Config.SkillMethods[key]
    end)
end
addButton(Enum.KeyCode.One); addButton(Enum.KeyCode.Two); addButton(Enum.KeyCode.Three); addButton(Enum.KeyCode.Four); addButton(Enum.KeyCode.R)

-- LOGIC PRIME: Tắt AutoRotate để bypass Shift Lock
local function triggerAim(method, time)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Phá khóa xoay của game
    task.wait(time)
    if hum then hum.AutoRotate = true end -- Trả lại quyền
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    if input.KeyCode == Enum.KeyCode.Q then
        triggerAim("Root", 0.4) -- Dash Prime: Xoay người cứng 0.4s
    elseif Config.SkillMethods[input.KeyCode] then
        triggerAim(Config.SkillMethods[input.KeyCode], 0.1)
    end
end)

-- LOOP CẬP NHẬT
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

-- TÌM TARGET (RESET 0.2S)
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
            if not target.Character:FindFirstChild("ESP") then Instance.new("Highlight", target.Character).Name = "ESP" end
        else
            for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESP") then p.Character.ESP:Destroy() end end
        end
    end
end)
