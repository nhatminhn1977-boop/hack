local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH
local Config = {
    -- Mặc định skill là Camera, có thể đổi sang Root
    SkillMethods = { [Enum.KeyCode.One]="Camera", [Enum.KeyCode.Two]="Camera", [Enum.KeyCode.Three]="Camera", [Enum.KeyCode.Four]="Camera", [Enum.KeyCode.R]="Camera" },
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- UI TỐI GIẢN (Sửa lỗi nút không hoạt động bằng cách định nghĩa hàm tạo nút tách biệt)
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 220, 0, 350); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); frame.Active = true; frame.Draggable = true
local avatar = Instance.new("ImageLabel", frame); avatar.Size = UDim2.new(0, 50, 0, 50); avatar.Position = UDim2.new(0.05, 0, 0.05, 0)
local name = Instance.new("TextLabel", frame); name.Size = UDim2.new(0, 150, 0, 50); name.Position = UDim2.new(0.35, 0, 0.05, 0); name.TextColor3 = Color3.new(1,1,1); name.BackgroundTransparency = 1

-- Hàm tạo nút chuẩn xác
local function createButton(keyCode, yOffset)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = UDim2.new(0.05, 0, 0, yOffset)
    btn.Text = "Skill " .. keyCode.Name .. ": " .. Config.SkillMethods[keyCode]
    
    btn.MouseButton1Click:Connect(function()
        Config.SkillMethods[keyCode] = (Config.SkillMethods[keyCode] == "Camera" and "Root" or "Camera")
        btn.Text = "Skill " .. keyCode.Name .. ": " .. Config.SkillMethods[keyCode]
    end)
end

createButton(Enum.KeyCode.One, 110); createButton(Enum.KeyCode.Two, 150); createButton(Enum.KeyCode.Three, 190); createButton(Enum.KeyCode.Four, 230); createButton(Enum.KeyCode.R, 270)

-- LOGIC AIM BYPASS SHIFT LOCK
local function executeAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Bypass Shift Lock bằng cách tắt tự xoay
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        -- Dash: Xoay người, bỏ qua nếu đang giữ A, S, D
        local movingSide = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
        if not movingSide then executeAim("Root", 0.4) end
    elseif Config.SkillMethods[input.KeyCode] then
        executeAim(Config.SkillMethods[input.KeyCode], 0.1)
    end
end)

-- LOOP CHÍNH
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

-- TARGETING & ESP (RESET 0.2S)
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
